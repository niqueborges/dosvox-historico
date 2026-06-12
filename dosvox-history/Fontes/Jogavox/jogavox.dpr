{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo principal
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{             Amanda Medeiros (versão 3)
{             Marcolino Nascimento
{             Bruno Cesar Soares Dile Robalinho (versão 4)
{
{    Versão protótipo em Janeiro/2009
{
{    Versão 1.0 em Novembro/2010
{    Versão 2.0 em Junho/2012
{    Versão 2.4 em Janeiro/2013
{    Versão 2.5 em Junho/2014
{    Versão 3.0 em Junho/2015
{    Versão 4.0 em Maio/2018
{
{--------------------------------------------------------}

program jogavox;

uses
  dvWin,
  dvcrt,
  dvform,
  jovars,
  jomsg,
  joarq,
  joedjogo,
  jojoga,
  joprog,
  jobaixa,
  joimport,
  joprglug,
  jomci,
  classes,
  sysutils;

{$R jogavox.res}

{--------------------------------------------------------}
{                      inicialização
{--------------------------------------------------------}

procedure inicializa;
var
    ambiente: string;
begin
    ambiente := sintAmbiente ('JOGAVOX', 'DIRJOGAVOX');
    if ambiente = '' then
        ambiente := 'c:\winvox\som\jogavox';
    sintInic (0, ambiente);

    url_jogos := sintAmbiente ('JOGAVOX', 'URLJOGOS', URL_JOGOS_DEFAULT);
    if url_jogos[length(url_jogos)] <> '/' then
        url_jogos := url_jogos + '/';

    clrscr;
    setWindowTitle('Jogavox');
    textBackground (BLUE);
    limpaBufTec;

    dirBaseJogos := sintAmbiente ('JOGAVOX', 'DIRJOGOS', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\jogavox');

    openBMP(dirBaseJogos+'\jogavox_logo.bmp');
    paintBMP(WindowSize.X-dvcrt.BMPwidth - 20, 20);

    mensagem ('JOINIC', 0);     {'Jogavox - editor de jogos educacionais'}
    write (' - ');
    mensagem ('JOVERSAO', 0);   {'Versão '}
    sintSoletra(versao);
    writeln (versao);
    textBackground (BLACK);
    writeln;

    nomeArqJogo := '';
    indLocalEditando := 0;

    listaDirJogos := TStringList.create;

    listaDirMidias := TStringList.create;
    dirBaseMidias := sintAmbiente ('JOGAVOX', 'DIRMIDIAS', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\midias');

    dirBaseModelos := sintAmbiente ('JOGAVOX', 'DIRMODELOS', sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\jogavox_modelos');

    {$I-} chdir (dirBaseJogos);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('JODIRNAO', 2);  {'Diretório que contém os jogos não foi encontrado'}
            sintWriteln (dirBaseJogos);
            mensagem ('JODIRATU', 2);  {'Foi assumido o diretório atual para as pastas de jogos'}
            exit;
        end;
end;

{--------------------------------------------------------}
{                      finalização
{--------------------------------------------------------}

procedure finaliza;
begin
    listaDirJogos.free;

    writeln;
    textBackground (BLUE);
    mensagem ('JOFIM', 0);     {'Fim do editor de jogos'}
    textBackground (BLACK);
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{              seleção interativa de opções
{--------------------------------------------------------}

function selInterativa: char;
var n: integer;
    c: char;
begin
    popupMenuCria (wherex, wherey, 12, 4, MAGENTA);
    MenuAdiciona ('JOJOGAR');    // 'J - jogar'
    MenuAdiciona ('JOCRIAR');    // 'C - criar'
    MenuAdiciona ('JOEDITAR');   // 'E - criar'
    MenuAdiciona ('JOBAIXAR');   // 'B - baixar'
    limpaBufTec;
    n := popupMenuSeleciona;

    case n of
        1: c := 'J';
        2: c := 'C';
        3: c := 'E';
        4: c := 'B';
    else
        c := #$1b;
    end;

    if (c <> #$1b) and (c <>'B') then writeln (c);
    writeln;
    selInterativa := c;
end;

{--------------------------------------------------------}
{                      escolha da opção
{--------------------------------------------------------}

procedure processa;
var c: char;
begin
    repeat
        limpaBaixo (2);
        paintBMP(WindowSize.X-dvcrt.BMPwidth - 20, 20);

        gotoxy (1, 4);
        c := pergunta ('JOJOGCRIB', 0, BLUE);  {'Opção: Jogar, Criar, Editar ou Baixar? '}
        if c = ESC then exit;
        if c = #0 then c := selInterativa;

        chdir (dirBaseJogos);
        nomeArqJogo := '';
        case upcase(c) of
            'C':  criaJogo;
            'E':  editaJogo;
            'B':  selCategoria;
            'J':  jogaJogo(false);
        end;

    until c = ESC;
    if c = ESC then exit;
end;

{--------------------------------------------------------}
{                      programa principal
{--------------------------------------------------------}
                   
begin
    inicializa;

    if paramCount = 0 then
        processa
    else
        begin
            dirJogo := extractFileDir (paramStr(1));
            {$I-}  chdir (dirJogo);   {$I+}
            if ioresult <> 0 then;
            nomeArqJogo := extractFileName (paramStr(1));

            if not pegaNomeJogo (nomeArqJogo) then exit;
            if not carregaEstruturaJogo (nomeArqJogo) then exit;

            jogaJogo(true);
        end;
    finaliza;
end.
