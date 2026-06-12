{------------------------------------------------------}
{
{    PyVox - interface sonora para Python
{
{    Por Antonio Borges
{
{    Em 09/12/2010
{
{    Atualizado por Patrick Barboza
{
{    Em 17/05/2024
{
{------------------------------------------------------}

program pyvox;
uses
  dvcrt,
  dvwin,
  dvarq,
  dvForm,
  dvHora,
  dvExec,
  sysUtils,
  Windows,
  Classes,
  pyPipe,
  pyTrad,
  pyLetela,
  pyLocal;

const
    versao = '3.1';
var
    pythonCommand: string;
    pythonScript: string;
    log: string;
    s: string;
    c: char;
    processing: boolean;
    dirInicial: string;
    teclagem: TStringList;

const
    CR = #$0d;
    LF = #$0a;

procedure fechaPython;
var s: string;
begin
    WritePipeOut(InputPipeWrite, 'import sys' + LF);
    WritePipeOut(InputPipeWrite, 'sys.exit()' + LF);
    sleep (200);
    repeat
        s := ReadPipeInput(OutputPipeRead);
        if s <> '' then sintWrite (s);
    until s = '';
    repeat
        s := ReadPipeInput(ErrorPipeRead);
        if s <> '' then sintWrite (s);
    until s = '';

    pythonStop;
end;

procedure sai(s: string; escrevendo: boolean);
begin
    if escrevendo then
        if s = '>>> ' then
            begin
                write (s);
                sintClek;
            end
        else
            sintWrite (s);
    log := log + s;
end;

procedure salvaLog;
var nomeArqLog: string;
    arqLog: textfile;
begin
    if wherex <> 1 then writeln;
    textColor (yellow);
    sintWriteln ('Arquivo de registro: ');
    sintReadln (nomeArqLog);
    if nomeArqLog <> '' then
         begin
              assignFile (arqLog, nomeArqLog);
              {$I-} rewrite (arqLog); {$I+}
              if ioresult <> 0 then
                  sintWriteln ('Não pude gravar')
              else
                  begin
                      {$I-} write (arqLog, log); {$I+}
                      if ioresult <> 0 then
                          sintWriteln ('Não pude gravar');
                  end;
              closeFile (arqLog);
              sintetiza ('Gravado');
         end;

    textColor (white);
end;

procedure chamaEditor;
begin
    sintWriteln ('Abrindo editor');
    executaProg('c:\winvox\edivox', dirInicial, pythonScript);
end;

procedure reiniciaPrograma;
begin
    sintWriteln ('Reiniciando o programa');
    fechaPython;
    chdir (dirInicial);

    sai ('-------------------------', false);
    pythonExecute (pythonCommand, pythonScript);
end;

procedure reveTeclagem;
var p: integer;
    c, c2: char;
    x, maxCarac: integer;
begin
    sintetiza ('Reteclando');
    p := teclagem.Count;
    c := ' ';
    x := wherex;
    maxCarac := 79 - x;
    while (c <> ENTER) and (c <> ESC) do
        begin
            c := readkey;
            if c = #$0 then
                begin
                   c2 := readkey;
                   case c2 of
                       CIMA: begin
                                 p := p - 1;
                                 if p < 0 then p := -1;
                             end;
                       BAIX: begin
                                 p := p + 1;
                                 if p >= teclagem.Count then
                                      p := teclagem.count;
                             end;

                       HOME: p := 0;
                       TEND: p := teclagem.Count - 1;
                   end;

                    gotoxy (x, wherey);
                    clreol;
                    if (p < 0) or (p >= teclagem.Count) then
                        sintBip
                    else
                        begin
                            write (copy (teclagem[p], 1, maxCarac));
                            sintetiza (teclagem[p]);
                        end;
                end;

        end;

    if (c = ESC) or (p < 0) or (p >= teclagem.Count) then
        begin
            clreol;
            sintBip;
            exit;
        end;

    WritePipeOut(InputPipeWrite, teclagem[p] + LF);
    gotoxy (x, wherey);
    clreol;
    sai (teclagem[p] + CR + LF, true);
end;



procedure configura;
begin
    s := localizaPython;
    if s <> '' then
       begin
            sintWriteln ('Assumido: ' + s);
            pythonCommand := s;
       end;
end;

procedure pegaArqScript;
var
    c: char;
    arq: text;
begin
    sintWrite ('Nome do Script: ');
    pythonScript := trim(obtemNomeArqMasc (10, '*.py'));
    if (pythonScript <> '') and (not fileExists (pythonScript)) then
        begin
            sintWriteln ('Arquivo não existe, deseja criar?');
            c := upcase(sintReadkey);
            if c in ['S', ENTER] then
                begin
                    assign (arq, pythonScript);
                    {$i-} rewrite (arq); {$I+}
                    if ioresult <> 0 then;
                    {$i-} close (arq); {$I+}
                    if ioresult <> 0 then;
                end
            else
                sintwriteln ('Desistiu ...');
        end;
end;

procedure funcoesEspeciais (func: char);
label deNovo;
begin
deNovo:
    case func of
        F1, F9: begin
                if wherex <> 1 then writeln;
                textColor (yellow);
                sintWriteln ('Funções do programa');
                sintWriteln ('F1 - ajuda');
                sintWriteln ('F2 - salva histórico');
                sintWriteln ('F3 - zera histórico');
                sintWriteln ('F4 - configura');
                sintWriteln ('F5 - chama editor');
                sintWriteln ('F6 - reinicia programa');
                sintWriteln ('F7 - limpa tela');
                sintWriteln ('F8 - fala dia e hora');
                sintWriteln ('control F9 - ativa leitor de tela');
                sintWriteln ('seta cima - permite redigitar');
                sintWriteln ('control T - traduz linha anterior');
                sintWriteln ('ESC - termina a execução');
                textColor (white);
            end;
        F2: salvaLog;
        F3: log := '';
        F4 :    if getKeyState (vk_Menu) < 0 then
                    processing := false
                else
                    configura;
        F5: chamaEditor;
        CTLF5: pegaArqScript;

        F6: reiniciaPrograma;
        F7: begin
                clrscr;
                sintetiza ('Tela limpa');
            end;
        F8: begin
               falaDia;
               falaHora;
            end;
     CTLF9: leitorDeTela;
      CIMA: reveTeclagem;
    end;

end;

procedure inicializa;
begin
    clrscr;
    textColor (white);
    setWindowTitle('Pyvox - v' + versao);
    sintInic(0, '');
    sintWrite ('Pyvox - v');
    sintWriteln (versao);
    writeln;

    teclagem := TStringList.Create;
    getDir (0, dirInicial);

    if paramcount <> 0 then
        pythonScript := paramStr(1)
    else
        pegaArqScript;

    pythonScript := trim (pythonScript);
    if pos (' ', pythonScript) <> 0 then
         if pythonScript[1] <> '"' then
              pythonScript := '"' + pythonScript + '"';

    if pythonScript = '' then
        begin
            sintWriteln ('Modo interativo');
            while sintFalando do;
        end
    else
        begin
            setWindowTitle('pyvox ' + pythonScript);
            writeln(pythonScript);
        end;
    writeln;
end;

procedure traduzLinha (linha: integer);
var s: string;
    col: integer;
begin
    if (linha > 1) and (abreGoogle) then
        begin
            s := '';
            for col := 1 to screenSize.x do
                s := s + letela (linha, col);
            traduzFraseGoogle (s, s);
            fechaGoogle;
            sintetiza (s);
        end
    else
        begin
            sintBip; sintBip;  sintBip;
        end;
end;


begin
    inicializa;
    checkbreak := false;

    pythonCommand := sintAmbiente ('PYVOX', 'PYTHONW');
    if pythonCommand = '' then
        pythonCommand := localizaPython;
    if not FileExists(pythonCommand) then
        begin
            sintWriteln ('Não achei o interpretador pythonw');
            sintGravaAmbiente('PYVOX', 'PYTHONW', '');
            sintWriteln ('Configurações reinicializadas, execute novamente o Pyvox');

            sintFim;
            doneWinCrt;
        end;

    processing := true;
    if pythonExecute (pythonCommand, pythonScript) then
        begin
            while processing do
                begin
                    sleep(40);

                    s := ReadPipeInput(OutputPipeRead);
                    if s <> '' then sai (s, true);
                    s := ReadPipeInput(ErrorPipeRead);
                    if s <> '' then sai (s, true);

                    if keypressed then
                        begin
                            c := readkey;
                            if c = #$1b then
                                processing := false
                            else
                            if c = ^T then
                                traduzLinha (wherey-1)
                            else
                            if c = #$0 then
                                funcoesEspeciais (readkey)
                            else
                                begin
                                    insertKeyBuf(c);
                                    sintReadln (s);
                                    teclagem.Add(s);
                                    WritePipeOut(InputPipeWrite, s + LF);
                                    sai (s + CR + LF, false);
                                end;
                        end;
                end;
        end
    else
        begin
            sintBip;
            sintWriteln ('Erro ao executar o interpretador pythonw');
            sintWriteln (pythonCommand);
            sintWriteln ('Aperte enter ou Ctrl F9 para ler a tela');
            if (sintReadkey = #$0) and (sintReadkey = CTLF9) then
                leitorDeTela;

            sintBip;
        end;

    sintWriteln ('Saindo');
    fechaPython;
    sintFim;
end.
