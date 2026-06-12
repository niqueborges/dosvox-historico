{--------------------------------------------------------}
{
{      Processador de Scripts
{
{      Autor: José Antonio Borges
{
{      Em 25/6/2000
{
{--------------------------------------------------------}

program scripvox;

uses
  windows,
  classes,
  sysUtils,
  dvwin,
  dvcrt,
  dvform,
  dvarq,
  dvdigitexto,
  dvscript57;

const
    subVersao = '';
    versao = VERSAO_DVSCRIPT + subVersao;

var
    nomeArq, rotulo: string;
    arq: text;
    interativo: boolean;
    scriptTrab: TStringList;

{--------------------------------------------------------}
{                 fala uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; apular: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'SCINIC' then
        s := 'ScriptVox - v'
    else
    if nomeArq = 'SCNOMARQ' then
        s := 'Nome do arquivo .CMD a executar: '
    else
    if nomeArq = 'SCFIM' then
        s := 'Fim do script'
    else
    if nomeArq = 'SCARQNAO' then
        s := 'Arquivo .CMD inexistente'
    else
    if nomeArq = 'SCERREXE' then
        s := 'Erro de execução na linha '
    else
    if nomeArq = 'SCERRROT' then
        s := 'Este rótulo não existe !'
    else
    if nomeArq = 'SCERRO' then
        s := 'Erro'
    else
    if nomeArq = 'SCEXPRE' then
        s := 'Expressão mal formada'
    else
    if nomeArq = 'SCEDITE' then
        s := 'Editore e aperte enter'
    else
    if nomeArq = 'SCINTER' then
        s := 'Modo interativo'
    else
        begin
            writeln;
            writeln ('-------------------------------');
            writeln ('--- mensagem errada: ', s, '---');
            writeln ('-------------------------------');
            writeln;
        end;

    write (s);
    for i := 1 to apular do writeln;

    if existeArqSom (nomeArq) then
        sintsom (nomeArq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{      remove brancos ao inicio e fim de uma cadeia
{--------------------------------------------------------}

procedure trim (var lido: string);
begin
    while (lido <> '') and (lido[1] = ' ') do
        delete (lido, 1, 1);
    while (lido <> '') and (lido[length(lido)] = ' ') do
        delete (lido, length(lido), 1);
end;

{--------------------------------------------------------}
{             transforma cadeia em maiusculos
{--------------------------------------------------------}

function maiusc (s: string): string;
begin
    s := s + #$0;
    ansiUpper (@s[1]);
    delete (s, length (s), 1);
    maiusc := s;
end;

{--------------------------------------------------------}
{                    inicialização
{--------------------------------------------------------}

function inicializa: boolean;
var s: string;
    dirAtual: string;
    p: integer;
label deNovo;
begin
    inicializa := true;
    scriptTrab := TStringList.Create;

    sintInic (0, sintAmbiente ('SCRIPVOX', 'DIRSCRIPVOX'));
    clrscr;
    setWindowText (crtWindow, 'SCRIPVOX');

    if paramCount <> 0 then
        nomeArq := paramStr(1)
    else
        begin
            textBackground (BLUE);
            mensagem ('SCINIC', 0);   {'ScriptVox - v'}
            sintWriteln (versao);
            textBackground (BLACK);
            writeln;

            getDir (0, dirAtual);

            s := sintAmbiente ('SCRIPVOX', 'DIRDEFAULT');
            if s = '' then s := 'c:\winvox\scripts';
            {$I-}  chdir (s);  {$I+}
            if ioresult <> 0 then ;

            mensagem ('SCNOMARQ', 0);    {'Nome do arquivo .CMD a executar: '}
            nomeArq := obtemNomeArqMasc (20, '*.CMD');
            trim (nomeArq);
            writeln (nomeArq);
            if teclaObtemNomeArq = ESC then
                begin
                    sintFim;
                    doneWinCrt;
                end;

            chDir (dirAtual);
        end;

    interativo := false;
    if nomeArq = '' then
        begin
            s := 'SCRIPVOX (interativo)';
            setWindowText (crtWindow, @s[1]);
            interativo := true;
            exit;
        end;

    rotulo := '';
    p := pos ('@', nomeArq);
    if p <> 0 then
        begin
            rotulo := copy (nomeArq, p+1, 999);
            delete (nomeArq, p, 999);
            trim (nomeArq);
            trim (rotulo);
        end;

    s := 'SCRIPVOX ' + nomeArq;
    setWindowText (crtWindow, @s[1]);

deNovo:
    assign (arq, nomeArq);
    {$I-}  reset (arq);  {$I+}
    if ioresult = 0 then
        begin
            close (arq);
            exit;
        end
    else
        begin
            if (maiusc (copy (nomeArq, length(nomeArq)-3, 4)) <> '.CMD') and
               (maiusc (copy (nomeArq, length(nomeArq)-3, 4)) <> '.PRO') then
                begin
                    nomeArq := nomeArq + '.CMD';
                    goto deNovo;
                end;
        end;

    if pos ('\', nomeArq) = 0 then
        begin
            s := sintAmbiente ('SCRIPVOX', 'DIRDEFAULT');
            if s = '' then s := '.';
            if s [length(s)] <> '\' then s := s + '\';
            nomeArq := s + nomeArq;
            assign (arq, nomeArq);
            if fileExists (nomeArq) then
                exit;
        end;

    mensagem ('SCARQNAO', 1);   {'Arquivo .CMD inexistente'}
    inicializa := false;
end;

{--------------------------------------------------------}
{                    processamento
{--------------------------------------------------------}

procedure processaInterativo;
var c, v: char;
    idx: integer;
    i: integer;
    listaCmd: TStringList;
    lido, salva: string;
    valor: string;

    {--------------------------------------------------------}

    function podeCalcular (lido: string): boolean;
    begin
        result := (lido[1] = '(') or
                  (lido[1] = '|') or
                  ((length(lido) = 1) and (upcase(lido[1]) in ['A'..'Z'])) or
                  ((length(lido) > 1) and (upcase(lido[1]) in ['A'..'Z'])
                                      and not (upcase(lido[2]) in ['A'..'Z'])
                                      and (pos('=', lido) = 0)) or
                  ((lido[1] = '$')
                        and (pos('"', lido) = 0) and (pos('=', lido) = 0)) or
                  (lido[1] in ['0'..'9']);
    end;

    {--------------------------------------------------------}

    procedure mostraValor;
    begin
        if extraiValor (lido, valor) then
            begin
                if lido = '' then
                    sintWriteln (valor)
                else
                    mensagem ('SCEXPRE', 1);   {'Expressão mal formada'}
            end;
    end;

var retorno, ultLinProc: integer;
    contUltLinha: string;
label interage;

begin
    mensagem ('SCINTER', 2);    {'Modo interativo'}
    listaCmd := TStringList.create;
    fimScript := false;

    while not fimScript do
        begin
interage:
            lido := '';
            repeat
                c := sintEdita(lido, wherex, wherey, 255, true);
                writeln;

                if c = ESC then
                    fimScript := true
                else
                if c = F9 then
                    begin
                        garanteEspacoTela (11);
                        popupDigiTexto(scriptTrab, false, true, 1, wherey, 80, 10, true);
                        goto interage;
                    end;

                if c = CTLF9 then
                    begin
                        retorno := executaScriptList (scriptTrab, '',
                                     ultLinProc, contUltLinha);
                        if retorno = 0 then
                             sintWriteln ('Ok')
                        else
                            begin
                                 sintWriteln ('Erro na linha ' + intToStr(ultLinProc));
                                 sintwriteln (contUltLinha);
                            end;

                        fimScript := false;
                        goto interage;
                    end;

                if (c = CIMA) or (c = BAIX) then
                    begin
                        garanteEspacoTela (5);
                        popupMenuCria(wherex, wherey, 80, listaCmd.Count, RED);
                        for i := 0 to listaCmd.Count-1 do
                            popupMenuAdiciona('', listaCmd[i]);
                        i := popupMenuSeleciona;
                        if i >= 1 then
                            begin
                                lido := opcoesItemSelecionado;
                                mensagem ('SCEDITE', 1);
                            end;
                    end;
            until (c = ENTER) or (c = ESC);

            if not fimScript then
                begin
                    if lido = '' then continue;

                    if listaCmd.Count = 0 then
                        listaCmd.Add(lido)
                    else
                        listaCmd.Insert(0, lido);

                    if podeCalcular(lido) then
                        begin
                            salva := lido;
                            extraiVariavel(lido, v, idx);
                            lido := salva;

                            if listaScript[v] <> NIL then
                                begin
                                    if idx = -1 then
                                        for i := 0 to listaScript[v].Count-1 do
                                            sintWriteln (listaScript[v][i])
                                    else
                                    if idx < listaScript[v].Count then
                                        mostraValor;
                                end
                            else
                                mostraValor;
                       end
                    else
                    if not cmdScript (lido) then
                        mensagem ('SCERRO', 1);   {'Erro'}
                    lido := '';
                end;
        end;

    if not fimScriptMudo then
        mensagem ('SCFIM', 1);   {'Fim do script'}
end;

{--------------------------------------------------------}
{                    processamento
{--------------------------------------------------------}

procedure processa;
var retorno, ultLinProc: integer;
    contUltLinha: string;
begin
    retorno := executaScript (nomeArq, rotulo, ultLinProc, contUltLinha);
    case retorno of
        SCR_OK:
            if not fimScriptMudo then
                mensagem ('SCFIM', 1);   {'Fim do script'}

        SCR_ERROEXEC:
            begin
                showWindow (crtWindow, SW_RESTORE);
                gotoxy (1, 23);
                clreol;  writeln; clreol; writeln; clreol;

                gotoxy (1, 23);
                textColor (YELLOW);
                sintbip; sintbip; sintbip;
                mensagem ('SCERREXE', 0);   {'Erro de execução na linha '}
                sintWriteint (ultLinProc);
                writeln;
                clreol;
                sintEdita (contUltLinha, wherex, wherey, 80, false);
                writeln (contUltLinha);
                clreol;
                textColor (WHITE);

                readln;
            end;

        SCR_SEMARQUIVO:
            mensagem ('SCARQNAO', 1);   {'Arquivo inexistente'}

        SCR_ROTULOINVALIDO:
            mensagem ('SCERRROT', 1);   {''Este rótulo não existe !'}
    end;
end;

{--------------------------------------------------------}
{                      finalização
{--------------------------------------------------------}

procedure finaliza;
begin
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                     processamento
{--------------------------------------------------------}

begin
    if inicializa then
        if interativo then
            processaInterativo
        else
            processa
    else
        delay (1000);
    finaliza;
end.
