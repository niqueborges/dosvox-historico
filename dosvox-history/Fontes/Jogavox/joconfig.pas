{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de configuração
{
{    Autores: José Antonio Borges e Lidiane Figueira Silva
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joconfig;

interface
uses
    dvwin, dvcrt, sysutils, dvform, classes,
    jovars, joArq, jomsg;

procedure editarDadosGerais;
procedure configurarApresentacao;

implementation

{--------------------------------------------------------}
{                editar dados gerais
{--------------------------------------------------------}

procedure editarDadosGerais;
var nom: array [0..10] of shortString;
    c1, c2: char;
    i: integer;
begin
    writeln;
    garanteEspacoTela (12);
    with jogo.dadosGerais do
        begin
            nom[1] := nomeJogo;
            nom[2] := autor;
            nom[3] := dataCriacao;
            nom[4] := versao;
            nom[5] := dataVersao;
            nom[6] := comentarios[1];
            nom[7] := comentarios[2];
            nom[8] := comentarios[3];
            nom[9] := comentarios[4];
            nom[10]:= comentarios[5];
        end;

    formCria;
    campo('JO_NOME',  nom[1], 60);    {'Nome do Jogo'}
    campo('JO_AUTOR', nom[2], 60);    {'Autor'}
    campo('JO_CRIAC', nom[3], 60);    {'Data de Criação'}
    campo('JO_VERS',  nom[4], 60);    {'Versão'}
    campo('JO_DATA',  nom[5], 60);    {'Data da versão'}
    campo('JO_COMEN1', nom[6], 60);   {'Comentários: 1'}
    campo('JO_COMEN2', nom[7], 60);   {'2'}
    campo('JO_COMEN3', nom[8], 60);   {'3'}
    campo('JO_COMEN4', nom[9], 60);   {'4'}
    campo('JO_COMEN5', nom[10], 60);  {'5'}
    formEdita(true);

    mensagem ('JOCONFAL', 0);            {'Confirma as alterações? '}
    sintLeTecla (c1, c2);
    writeln;
    if (upcase(c1) = 'N') or (c1 = ESC) then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu'}
            exit;
        end;

    with jogo.dadosGerais do
        begin
            nomeJogo    := nom[1];
            autor       := nom[2];
            dataCriacao := nom[3];
            versao      := nom[4];
            dataVersao  := nom[5];
            comentarios[1] := nom[6];
            comentarios[2] := nom[7];
            comentarios[3] := nom[8];
            comentarios[4] := nom[9];
            comentarios[5] := nom[10];
        end;

    nComent := 0;
    for i := 1 to 5 do
        if jogo.dadosGerais.comentarios[i] <> '' then ncoment := i;
end;

{--------------------------------------------------------}
{                configura a apresentação
{--------------------------------------------------------}

procedure configurarApresentacao;

var nom: array [0..10] of shortString;
    c1, c2: char;
    listaArqs: string;

begin
    writeln;
    garanteEspacoTela (10);
    with jogo do
        begin
            nom[1] := fundoDefault;
            nom[2] := fonteTexto.nomeFonte;
            nom[3] := intToStr(fonteTexto.tamFonte);
            if fonteTexto.negrito then nom[4] := 'SIM' else nom[4] := 'NÃO';
            nom[5] := corFundoDefault;
            nom[6] := corLetraDefault;
            if aleatorio then nom[7] := 'SIM' else nom[7] := 'NÃO';
            if narrando then nom[8] := 'SIM' else nom[8] := 'NÃO';
        end;

    formCria;

    listaArqs   := geraListaArqs ('*.jpg')  + '|' +
                   geraListaArqs ('*.jpeg') + '|';
    listaArqs   := normalizaLista (listaArqs);

    campoLista('JO_IMG',    nom[1], 60, listaArqs);      {'Imagem de fundo'}
    campoLista('JO_FONTE',  nom[2], 60, listaFontes);    {'Fonte do texto'}
    campoLista('JO_TFONT',  nom[3], 60, listaTamanhos);  {'Tamanho'}
    campoLista('JO_NEGRI',  nom[4], 60, simNao);         {'Negrito'}
    campoLista ('JOC_CFND', nom[5], 60, listaCores);     {'Cor do Fundo'}
    campoLista ('JOC_CLET', nom[6], 60, listaCores);     {'Cor da Letra'}
    campoLista('JO_ALEAT',  nom[7], 60, simNao);         {'Aleatório'}
    campoLista('JO_NARRA',  nom[8], 60, simNao);         {'Narrando'}
    formEdita(true);

    mensagem ('JOCONFAL', 0);            {'Confirma as alterações? '}
    sintLeTecla (c1, c2);
    writeln;
    if (upcase(c1) = 'N') or (c1 = ESC) then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu'}
            exit;
        end;

    with jogo do
        begin
            fundoDefault := nom[1];
            fonteTexto.nomeFonte := nom[2];
            try fonteTexto.tamFonte := strToInt (nom[3]);       except end;
            fonteTexto.negrito := (nom[4] <> '') and (copy (ansiUpperCase (nom[4])[1], 1, 1) <> 'N');
            corFundoDefault := nom[5];
            corLetraDefault := nom[6];
            aleatorio := (nom[7] = '') or (copy (ansiUpperCase (nom[7])[1], 1, 1) <> 'N');
            narrando := (nom[8] = '') or (copy (ansiUpperCase (nom[8])[1], 1, 1) <> 'N');
        end;
end;

end.

