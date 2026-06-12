{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de edição dos locais
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joedlugs;

interface

uses
    dvwin, dvcrt, windows, classes, sysutils, dvform,
    jovars, jomsg, joarq, joslides, joexibe, jojoga, joprglug;

function inicializaLugar: PLugar;
procedure editarListaDeLugares;

implementation

{--------------------------------------------------------}
{               limpa tela e desenha o cabecalho
{--------------------------------------------------------}

procedure cabecalho;
begin
    clrscr;
    TextBackground(BLUE);
    writeln (pegaTextoMensagem ('JOEDILOC'));      {'Editando os locais do jogo'}
    TextBackground (BLACK);
    writeln;
    writeln (pegaTextoMensagem ('JOEDISET'));      {'Escolha o local com as setas, depois tecle F9'}
    writeln;
end;

{--------------------------------------------------------}
{               cria um lugar e inicializa
{--------------------------------------------------------}

function inicializaLugar: PLugar;
var
    pl: pLugar;
begin
    new (pl);
    with pl^ do
        begin
            nome := 'Novo lugar';
            categoria := '';
            respostaEsperada := '';
            lugarOk := '';
            lugarErro := '';
            pontuacao := 0;
            jogoTerminaAqui := false;
            midiaLugar := '';
            corFundo := '';
            corLetra := 'BRANCO';
            fundo := '';
            numSlides := 0;
            scriptEntrada := '';
            scriptSaida := '';
        end;

    result := pl;
end;

{--------------------------------------------------------}
{                   insere um lugar
{--------------------------------------------------------}

procedure insereLugar (indLocalAtual: integer);
var
    pl: pLugar;
    i: integer;
    nome: string;
    posic: char;
begin
    pl := inicializaLugar;

    mensagem ('JOTITLUG', 1);   {'Informe o nome do lugar:'}
    sintReadln (nome);
    if nome = '' then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu'}
            exit;
        end;
    pl.nome := nome;

    mensagem ('JOANTDEP', 0);   {'Insere antes ou depois daqui? }
    posic := upcase(sintReadkey);
    if posic = ESC then
        begin
            mensagem ('JODESIST', 1);  {'Desistiu'}
            exit;
        end
    else
        begin
            write (posic);
            if posic = 'D' then
                if indLocalAtual <= jogo.numLugares then
                     indLocalAtual := indLocalAtual + 1;
        end;

    for i := jogo.numLugares downto indLocalAtual do
        jogo.lugares[i+1] := jogo.lugares[i];
    inc (jogo.numLugares);
    jogo.lugares[indLocalAtual] := pl;
end;

{--------------------------------------------------------}
{     monta todos os nomes de lugares separados por "|"
{--------------------------------------------------------}

function criaListaDeLugares: string;
var i: integer;
    s: string;
begin
    s := '';
    for i := 1 to jogo.numLugares do
        with jogo.lugares[i]^ do
            s := s + '|' + nome;
    if s <> '' then
        delete (s, 1, 1);
    result := s;
end;

{----------------------------------------------------------}
{     monta os rótulos do arquivo .pro, separados por "|"
{----------------------------------------------------------}

function criaListaDeRotulos: string;
var sl: TStringList;
    s: string;
    i: integer;
    nomePro: string;

begin
    nomePro := copy (nomeArqJogo, 1, length(nomeArqJogo)-4) + '.pro';
    if not FileExists(nomePro) then
        begin
            result := '';
            exit;
        end;

    sl := TStringList.Create;
    sl.loadFromFile (nomePro);
    s := '';
    for i := 0 to sl.Count-1 do
        if (sl[i] <> '') and (sl[i][1] = '@') then
            s := s + '|' + sl[i];
    if s <> '' then
        delete (s, 1, 1);
    result := s;
    sl.free;
end;

{--------------------------------------------------------}
{           preview do Script (para videntes)
{--------------------------------------------------------}

procedure previewScript (indLocalAtual: integer);
var nomeArqScript: string;
    sl: TStringList;
    i: integer;
begin
    sl := TStringList.Create;
    nomeArqScript := jogo.lugares[indLocalAtual].nome + '.PRO';
    textColor (LIGHTGREEN);
    if fileExists(nomeArqScript) then
        begin
            writeln ('------------------------------Script associado-------------------------------');
            sl := TStringList.create;
            sl.LoadFromFile(nomeArqScript);
            i := 0;
            gotoxy (1, wherey);
            while (i < sl.Count) and (wherey <> 24) do
                begin
                    writeln (copy (sl[i], 1, 79));
                    i := i + 1;
                end;
            if sl.Count > i then
                writeln ('... continua ...');
        end;
    textColor (WHITE);
    sl.free;
end;

{--------------------------------------------------------}
{                    edita um lugar
{--------------------------------------------------------}

function editaCaracLugar (indLocalAtual: integer): char;
const
    MAXCAMPOS = 14;
var
    nom, copiaNom: array [1..MAXCAMPOS] of shortString;
    nada: shortString;
    c1, c2, resultEdita: char;
    listaFundos, listaMidias, listaLugs, listaRotulos: string;
    iguais: boolean;
    i: integer;

begin
    window (1, 1, 80, 25);
    cabecalho;

    gotoxy (1, 3);
    clreol;
    mensagem ('JOEDNLUG', 2);  {'Editando lugar'}
    with jogo.lugares[indLocalAtual]^ do
        begin
            nom[1] := nome;
            nom[2] := categoria;
            nom[3] := fundo;
            nom[4] := midiaLugar;
            nom[5] := corFundo;
            nom[6] := corLetra;
            nom[7] := intToStr(pontuacao);
            nom[8] := respostaEsperada;
            nom[9] := lugarOk;
            nom[10] := lugarErro;
            nom[11] := strBool (jogoTerminaAqui);
            nom[12] := memoriaResposta;
            nom[13] := scriptEntrada;
            nom[14] := scriptSaida;
        end;

    listaFundos := geraListaArqs ('*.bmp')  + '|' +
                   geraListaArqs ('*.jpg')  + '|' +
                   geraListaArqs ('*.jpeg') + '|' +
                   geraListaArqs ('*.png');
    listaFundos := normalizaLista (listaFundos);

    listaMidias := geraListaArqs ('*.wav') + '|' +
                   geraListaArqs ('*.wma') + '|' +
                   geraListaArqs ('*.mid') + '|' +
                   geraListaArqs ('*.mp3') + '|' +
                   geraListaArqs ('*.avi') + '|' +
                   geraListaArqs ('*.mp4') + '|' +
                   geraListaArqs ('*.mpg') + '|' +
                   geraListaArqs ('*.mpeg');
    listaMidias := normalizaLista (listaMidias);

    listaLugs := criaListaDeLugares;
    listaRotulos := criaListaDeRotulos;

    copiaNom := nom;

    nada := '';

    formCria;
    campo('JOC_NOME', nom[1], 50);                    {'Nome'}
    campo('JOC_CATE', nom[2], 80);                    {'Categoria'}
    campoLista('JOG_IMGF',  nom[3], 80, listaFundos); {'Imagem de fundo'}
    campoLista ('JOC_MID',  nom[4], 80, listaMidias); {'Mídia de fundo'}
    campoLista ('JOC_CFND', nom[5], 50, listaCores);  {'Cor do Fundo'}
    campoLista ('JOC_CLET', nom[6], 50, listaCores);  {'Cor da Letra'}
    formCampo('', '------------------', nada, 0);
    campo('JOC_PONT', nom[7], 10);                    {'Pontos ganhos ao chegar'}
    campo('JOC_RESP', nom[8], 80);                    {'Resposta esperada'}
    campoLista ('JOC_LUOK', nom[9], 80, listaLugs);   {'Se OK, que lugar?'}
    campoLista('JOC_LERR', nom[10], 80, listaLugs);   {'Se erro, que lugar?'}
    campoLista ('JOC_JOGT', nom[11], 4, simNao);      {'Jogo termina aqui?'}
    formCampo('', '------------------', nada, 0);
    campo ('JOC_MEMR', nom[12], 80);                  {'Memória da resposta'}
    campoLista ('JOC_SCIN', nom[13], 80, listaRotulos);   {'Script de entrada'}
    campoLista ('JOC_SCOUT', nom[14], 80, listaRotulos);  {'Script de saída'}

    resultEdita := formEdita(true);

    iguais := true;
    for i := 1 to MAXCAMPOS do
        if nom[i] <> copiaNom [i] then
            begin
                iguais := false;
                break;
            end;
    if iguais then
        begin
            sintetiza (pegaTextoMensagem ('JOOK'));
            cabecalho;
            result := resultEdita;
            exit;
        end;

    mensagem ('JOCONFAL', 0);            {'Confirma as alterações? '}
    sintLeTecla (c1, c2);
    writeln;
    if (upcase(c1) = 'N') or (c1 = ESC) then
        begin
            mensagem ('JODESIST', 1);    {'Desistiu'}
            while sintFalando do delay (100);
            delay (1000);
            cabecalho;
            result := ESC;
            exit;
        end;

    with jogo.lugares[indLocalAtual]^ do
        begin
            nome := nom[1];
            categoria := nom[2];
            fundo := nom[3];
            midiaLugar := nom[4];
            corFundo := nom[5];
            corLetra := nom[6];
            pontuacao := pegaNumero (nom[7]);
            respostaEsperada := nom[8];
            lugarOk := nom[9];
            lugarErro := nom[10];
            jogoTerminaAqui := (nom[11] <> '') and
                               (copy (ansiUpperCase (nom[11])[1], 1, 1) = 'S');
            memoriaResposta := nom[12];
            scriptEntrada := nom[13];
            scriptSaida := nom[14];

            if numSlides = 0 then
                criaSlideAuto (jogo.lugares[indLocalAtual]);
        end;

    cabecalho;
    result := resultEdita;
end;

{--------------------------------------------------------}
{                    remove um local
{--------------------------------------------------------}

procedure removeLugar (indLocalAtual: integer);
var c1, c2: char;
    i: integer;
begin
    if (indLocalAtual < 1) or (indLocalAtual > jogo.numLugares) then
        begin
             mensagem ('JOLUGINV', 1);   {'Lugar inválido'}
             exit;
        end;

    mensagem ('JOCONREM', 0);            {'Confirma a remoção? '}
    sintLeTecla (c1, c2);
    writeln;
    if (upcase(c1) = 'N') or (c1 = ESC) then
        begin
            mensagem ('JODESIST', 2);    {'Desistiu'}
            exit;
        end;

    with jogo.lugares[indLocalAtual]^ do
        begin
            for i := 1 to numSlides do
                desalocaSlide (slides[i]);
            numSlides := 0;

            for i := indLocalAtual to jogo.numLugares-1 do
                jogo.lugares[i] := jogo.lugares[i+1];
            dec (jogo.numLugares);
        end;
end;

{--------------------------------------------------------}
{                     move um local
{--------------------------------------------------------}

procedure moveLugar (indLocalAtual: integer);
var
    i: integer;
    pl: PLugar;
    c1, c2: char;
    salvaInd: integer;
begin
    mensagem ('JOINFMOV', 1);   {'Informe o lugar para o qual vai mover'}

    salvaInd := indLocalAtual;

    window (1, 1, 25, 80);
    folheiaCria (1, 7, 30, 7+9);
    for i := 1 to jogo.numLugares do
        folheiaAdiciona (intToStr (i) + ' - ' + jogo.lugares[i].nome);
    folheiaAdiciona ('Último lugar');

    if (not folheiaExecuta (indLocalAtual, indLocalAtual, c1, c2, true)) or
            (indLocalAtual <= 0) or (indLocalAtual > jogo.numLugares) then
        begin
             folheiaDestroi;
             gotoxy (1, 24);
             mensagem ('JODESIST', 1);   {'Desistiu'}
             while sintFalando do delay (100);
             delay (1000);
             exit;
        end;

    folheiaDestroi;
    pl := jogo.lugares[salvaInd];

    for i := salvaInd to jogo.numLugares-1 do
        jogo.lugares[i] := jogo.lugares[i+1];
    for i := jogo.numLugares downto indLocalAtual do
        jogo.lugares[i+1] := jogo.lugares[i];
    jogo.lugares[indLocalAtual] := pl;

    limpaMensagens;
end;

{--------------------------------------------------------}
{                  ajuda da edição de locais
{--------------------------------------------------------}

procedure ajudaEditaLugares (falando: boolean);

    procedure msg (som: string; pula: integer);
    begin
        if falando then
            mensagem (som, pula)
        else
            msgMuda (som, pula);
    end;

begin
    window (40, 7, 80, 15);
    textBackground (MAGENTA);
    clrscr;
    msg ('JOOPCOES', 1);    {'As opções são:'}
    msg ('JOAJU_E', 1);     {'E - editar lugar'}
    msg ('JOAJU_I', 1);     {'I - inserir novo lugar'}
    msg ('JOAJU_R', 1);     {'R - remover'}
    msg ('JOAJU_M', 1);     {'M - mover'}
    msg ('JOAJU_S', 1);     {'S - slides deste lugar'}
    msg ('JOAJU_V', 1);     {'V - visualizar'}
    msg ('JOAJU_PX', 1);    {'P - programação extra'}
    msg ('JOAJU_X', 0);     {'X - executar a partir daqui'}
    textBackground (BLACK);
    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}
{                   menu de opções
{--------------------------------------------------------}

const
    nitens = 8;

function menuEditaLugares: char;
const
    letrasMenu: array [0..nitens] of char = (ESC, 'E', 'I', 'R', 'M', 'S', 'V', 'P', 'X');
var
    item: integer;
begin
    window (40, 8, 80, 8+nitens);
    textBackground (BLACK);
    clrscr;
    window (1, 1, 80, 25);

    popupMenuCria(40, 8, 38, nitens, MAGENTA);
    MenuAdiciona('JOAJU_E');  {'E - editar características do lugar'}
    MenuAdiciona('JOAJU_I');  {'I - inserir novo lugar'}
    MenuAdiciona('JOAJU_R');  {'R - remover'}
    MenuAdiciona('JOAJU_M');  {'M - mover'}
    MenuAdiciona('JOAJU_S');  {'S - editar os slides'}
    MenuAdiciona('JOAJU_V');  {'V - visualizar'}
    MenuAdiciona('JOAJU_PX'); {'P - programação extra'}
    MenuAdiciona('JOAJU_X');  {'X - executar a partir daqui'}

    item := popupMenuSeleciona;

    if (item <= 0) or (item > nitens) then item := 0;
    menuEditaLugares := letrasMenu[item];
end;

{--------------------------------------------------------}
{                edita a lista de locais
{--------------------------------------------------------}

procedure editarListaDeLugares;
var
    ultCarac: char;
    lido: string;
    c1, c2: char;
    codEdita: char;
    i: integer;
label inicio, interpreta;
begin
    indLocalEditando := 1;
inicio:
    window (1, 1, 80, 25);
    clrScr;
    setWindowTitle('Jogavox ' + nomeArqJogo);

    TextBackground(BLUE);
    mensagem ('JOEDILOC', 2);      {'Editando os locais do jogo'}
    TextBackground (BLACK);

    mensagem ('JOEDISET', 1);      {'Escolha o local com as setas, depois tecle F9'}
    writeln (pegaTextoMensagem('JOMINITE'));      {'Seta para a direita: mini visualizador'}

    repeat
        folheiaCria (1, 7, 30, 7+8);
        for i := 1 to jogo.numLugares do
            folheiaAdiciona (intToStr (i) + ' - ' + jogo.lugares[i]^.nome);
        folheiaAdiciona ('Último local');

        ajudaEditaLugares (false);

        if not folheiaExecuta (indLocalEditando, indLocalEditando, c1, c2, true) then
            c1 := ESC;
        folheiaDestroi;

interpreta:
        if indLocalEditando < 1 then continue;
        if (indLocalEditando > jogo.numLugares) and
            (upcase(c1) <> 'I') and (c2 <> F9) then continue;

        gotoxy (1, 3); clreol;
        writeln (opcoesItemSelecionado);
        writeln;

        window (40, 7, 80, 25);
        textBackground (BLACK);
        clrscr;

        if c1 <> #$0 then
            case upcase(c1) of
                'I': insereLugar (indLocalEditando);
                'E', ENTER:
                     begin
                         window (1, 1, 80, 25);
                         repeat
                             codEdita := editaCaracLugar (indLocalEditando);
                             case codEdita of
                                  PGUP:      begin
                                                 if indLocalEditando <= 1 then break;
                                                 dec (indLocalEditando);
                                             end;
                                  PGDN:      begin
                                                 if indLocalEditando >= jogo.numLugares then break;
                                                 inc (indLocalEditando);
                                             end;
                                  CTLPGUP:   indLocalEditando := 1;
                                  CTLPGDN:   indLocalEditando := jogo.numLugares;
                             end;
                         until codEdita = ESC;
                     end;
                'R': removeLugar (indLocalEditando);
                'M': moveLugar (indLocalEditando);
                'S': begin
                        editaSlides (jogo.lugares[indLocalEditando]);
                        goto inicio;
                     end;
                'V': begin
                         if jogo.lugares[indLocalEditando]^.numSlides = 0 then
                            criaSlideAuto (jogo.lugares[indLocalEditando]);
                         clrScr;
                         gotoxy (1, 80);
                         visualizaLugar (indLocalEditando, ultCarac, lido);
                         closeBmp;
                         sintetiza (pegaTextoMensagem ('JOAPTENT'));   {'Aperte enter'}
                         readln;
                         clrscr;
                         goto inicio;
                     end;
                'X': begin
                         if jogo.dadosGerais.nomeScriptControlador <> '' then
                             mensagem ('JOPRGINB', 1);   {'Programa inibido no teste de lugar.'}
                         jogaJogoPartindoDe (indLocalEditando, false);
                         goto inicio;
                     end;
                'P': begin
                         programacaoDoLugar (indLocalEditando);
                         goto inicio;
                     end;
                ESC: ;
            else
                begin
                    mensagem ('JOOPINV', 1);    {'Opção inválida'}
                end;
            end
        else
            case c2 of
                F1: ajudaEditaLugares (true);
                F2: salvaJogo;
                F7: removeLugar (indLocalEditando);

                F9: begin
                        c1 := menuEditaLugares;
                        c2 := #$0;
                        if c1 <> ESC then goto interpreta;
                    end;
                DIR:
                    if jogo.lugares[indLocalEditando]^.numSlides <> 0 then
                        begin
                             exibeSlide (jogo.lugares[indLocalEditando], 1, 'minitela');
                             while not keypressed do waitMessage;
                             InvalidateRect (crtWindow, NIL, true);
                        end;
            else
                mensagem ('JOOPINV', 1);    {'Opção inválida'}
                mensagem ('JOF1F9', 2);     {'Aperte F9 para menu, F1 para ajuda'}
            end;

        window (1, 1, 80, 25);

    until c1 = ESC;
end;

end.

