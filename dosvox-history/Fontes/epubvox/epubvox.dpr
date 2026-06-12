program epubvox;

uses
  DvCrt,
  DvWin,
  DvForm,
  DvArq,
  SysUtils,
  epTrataXml,
  eptrataHTML,
  epmsg,
  epvars;


var
    parametro: string;

{--------------------------------------------------------}
{             mostra o logotipo do MIDIAVOX
{--------------------------------------------------------}

procedure mostraLogo;
begin
    clrscr;
    textBackground (BLUE);
    writeln ('  *******  ******   **   **  ******   **   **   *****   **   **  ');
    writeln ('  **       **   **  **   **  **   **  **   **  **   **   ** **   ');
    writeln ('  **       **   **  **   **  **   **  **   **  **   **    ***    ');
    writeln ('  ******   ******   **   **  ******   **   **  **   **     *     ');
    writeln ('  **       **       **   **  **   **   ** **   **   **    ***    ');
    writeln ('  **       **       **   **  **   **    ***    **   **   ** **   ');
    writeln ('  *******  **       *******  ******      *      *****   **   **  ');
    textBackground (BLACK);
end;

{--------------------------------------------------------}

{--------------------------------------------------------}
{                  Inicializa o sistema
{--------------------------------------------------------}

procedure Inicializa;
var
    amb: string;

begin
    amb := sintAmbiente ('EPUBVOX', 'DIREPUBVOX');
    if amb = '' then
       amb := 'C:\Winvox\Som\EPUBVOX';
    sintInic(0, amb);
    mostralogo;

    If paramCount = 0  Then
        begin
            mensagem ('EPUBVOX', 0); {  'EPUBVOX - Versão '  }
            sintWriteln(versao);
            writeln;
        end;
end;

{--------------------------------------------------------}
{                  Finaliza o sistema
{--------------------------------------------------------}

procedure finaliza;
begin
    if ParamCount < 2 then
        mensagem('EPFIM',1); {  'Fim do EPUBVOX'  }
    sintFim;
    doneWincrt;
end;

{--------------------------------------------------------}
{                     escolha da opção
{--------------------------------------------------------}

procedure pegaLocalSaida(s: string);
begin
    mensagem('EPNLVTXT',1);  {  'Informe o nome do arquivo de texto a salvar: '  }
    Sintreadln(LocalSaida);
    if localSaida = '' then
        begin
            novoNomeLivro := nomeCurLivro;
            mensagem('EPSAIDAD',1); {  Será salvo no diretório atual  }
            localSaida := changeFileExt(s,'.txt');
        end;
    if  (ansiUpperCase(ExtractFileExt(localSaida)) <> '.TXT') then
        begin
            writeln;
            mensagem('EPERRORN',1);  {  'Nome de arquivo inválido.'  }
            finaliza;
        end
    else
    if (pos('\',localSaida)<=0) then
        localSaida := ExtractFilePath(s)+localSaida;

    NovoNomeLivro := ansiUpperCase(ChangeFileExt(ExtractFileName(localSaida),''));
    writeln;
end;

{--------------------------------------------------------}
{                     escolha da opção
{--------------------------------------------------------}

procedure processa;
var
    s, dir: string;
    c: char;
begin
    limpabaixo(10);

    mensagem('EPQNEPUB',1);  { 'Informe o nome do livro:' }
    s := obtemNomeArqMasc (25-wherey, '*.epub');
    writeln;    writeln;

    if s = '' then
        begin
            writeln;
            mensagem ('EPNENCON', 1);  {  'Pasta vazia ou nenhum arquivo selecionado.'  }
            exit;
        end;

    if pos('\',s)<=0 then
        begin
            getdir(0,dir);
            s := dir+'\'+s;
        end;

    caminhoCurLivro := ansiUpperCase(ExtractFilePath(s));
    extCurLivro := ansiUpperCase(ExtractFileExt(s));
    nomeCurLivro := ansiUpperCase(ChangeFileExt(ExtractFileName(s),''));

    if nomeCurLivro = '' then
        nomeCurLivro := 'Sem Nome';

    mensagem('EPNLIVRO',0); { Livro: }
    sintwriteln(nomeCurLivro);
    writeln;

    limpaBufTec;
    mensagem('EPIMAGTB',0);  {  'Extrai imagens também? '  }
    repeat
        c := Readkey;
        case upcase(c) of
            'N', ENTER:
            begin
                mensagem('EPNAO',0); {  Não  }
                processaImagem := false;
            end;

            'S':
            begin
                mensagem('EPSIM',0); {  Sim  }
                processaImagem := true;
            end;

            ESC:
            begin
                writeln;
                writeln;
                exit;
            end;
        end;
    until (upcase(c) = 'N') or (upcase(c) = 'S') or (c = ESC) or (c = ENTER);

    writeln;
    writeln;
    pegaLocalSaida(s);

    processaEpub(s);
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

begin
    inicializa;
    If paramCount > 0  Then
        begin
            limpabaixo(10);
            parametro := paramStr(1);
            LocalSaida := paramStr(2);
            caminhoCurLivro := ansiUpperCase(ExtractFilePath(parametro));
            nomeCurLivro := ansiUpperCase(ChangeFileExt(ExtractFileName(parametro),''));
            extCurLivro := ansiUpperCase(ExtractFileExt(parametro));

            if LocalSaida = '' then
                pegaLocalSaida(parametro)
            else
                NovoNomeLivro := ansiUpperCase(ChangeFileExt(ExtractFileName(localSaida),''));

            processaImagem := false;

            mensagem('EPNLIVRO',0); { Livro: }
            sintwriteln(nomeCurLivro);
            writeln;

            processaEpub(parametro);
        end
    else
        processa;

    limpabuftec;
    finaliza;
end.


