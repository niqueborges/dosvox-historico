{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de jogar
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em dezembro/2010
{
{--------------------------------------------------------}

unit jojoga;

interface

uses
    sysutils, dvwin, dvcrt, dvform, jovars, jomsg, joarq, joexibe,
    dvscript, dialogs, classes;

procedure jogaJogoPartindoDe (indLugar: integer; aleatPermitida: boolean);
procedure jogaJogo (carregado: boolean);
function buscaLugar (nome: string): integer;

implementation

const
    MAXCATEGORIAS = 20;
    MAXLUGARPORCATEGORIA = 1000;

type
    TCateg = record
        nome: string;
        lugarFimCateg: string;
        numItensTotal, numItensUsar: integer;
        numVisitados: integer;
        aVisitar: array [1..MAXLUGARPORCATEGORIA] of integer;
    end;

var
    ncategs: integer;
    categs: array [1..MAXCATEGORIAS] of TCateg;

{--------------------------------------------------------}
{               busca uma categoria
{--------------------------------------------------------}

function buscaCategoria (cat: string): integer;
var n: integer;
begin
    result := 0;
    for n := 1 to ncategs do
       if categs[n].nome = ansiUpperCase(cat) then
           begin
               result := n;
               exit;
           end;
end;

{--------------------------------------------------------}
{               monta a lista de categorias
{--------------------------------------------------------}

procedure montaListaDeCategorias;
var l, achada: integer;
    cat: string;
(*  nc: integer; *)
begin
    ncategs := 0;
    for l := 1 to jogo.numLugares do
        begin
            cat := ansiUpperCase (trim(jogo.lugares[l].categoria));
            if cat = '' then continue;

            achada := buscaCategoria(cat);
            if achada <= 0 then
                begin
                    if ncategs > MAXCATEGORIAS then
                        begin
                            sintWriteln (cat);
                            mensagem ('JOCATEXC', 1);  {'Número de categorias esgotada, aperte enter'}
                            while readKey <> ENTER do;
                            continue;
                        end
                    else
                        begin
                            ncategs := ncategs + 1;
                            with categs[ncategs] do
                                begin
                                    nome := cat;
                                    lugarFimCateg := 'FIM';
                                    numItensTotal := 1;
                                    numItensUsar := 1;
                                    aVisitar[numItensTotal] := l;
                                    numVisitados := 0;
                                end;
                        end
                end
            else
                begin
                    with categs[achada] do
                        begin
                            inc (numItensTotal);
                            inc (numItensUsar);
                            aVisitar[numItensTotal] := l;
                        end;
                end;
        end;

(*
    for nc := 1 to ncategs do
        with categs[nc] do
            writeln ('Categoria: ', nome,
                               '|', lugarFimCateg,
                               '|', numItensTotal,
                               '|', numItensUsar,
                               '|', numVisitados);
    while readKey <> ENTER do;
*)
end;

{--------------------------------------------------------}
{                 embaralhas as categorias
{--------------------------------------------------------}

procedure embaralhaCategorias;
var r, i: integer;
    temp: integer;
    nc: integer;
begin
    randomize;
    for nc := 1 to ncategs do
        with categs[nc] do
            for i := numItensTotal downto 1 do
                begin
                    r := random (i) + 1;
                    temp := avisitar[r];
                    aVisitar[r] := aVisitar [i];
                    aVisitar[i] := temp;
                end;
end;

{--------------------------------------------------------}
{              registra limites da categoria
{--------------------------------------------------------}

procedure limitaCategoria (novaCat: string);
var p: integer;
    nomeCat: string;
    posCat: integer;
begin
    p := pos(',', novaCat);
    nomeCat := ansiUpperCase (trim (copy (novaCat, 1, p-1)));
    posCat := buscaCategoria(nomeCat);
    delete (novaCat, 1, p);
    novaCat := trim(novaCat);

    if posCat <= 0 then
        begin
            sintWriteln (nomeCat);
            mensagem ('JOCATNEX', 1);  {'Categoria inexistente, aperte enter'}
            while readKey <> ENTER do;
            exit;
        end;

    p := pos(',', novaCat);
    if p = 0 then
        begin
            categs[posCat].lugarFimCateg := novaCat;
            categs[posCat].numItensUsar := categs[posCat].numItensTotal;
        end
    else
        begin
            categs[posCat].lugarFimCateg := ansiUpperCase ((copy (novaCat, 1, p-1)));
            delete (novaCat, 1, p);
            novaCat := trim(novaCat);
            try
                categs[posCat].numItensUsar := strToInt(novaCat);
            except end;

        end;
end;

{--------------------------------------------------------}
{                 busca por categoria
{--------------------------------------------------------}

function proxLugarDaCategoria (nome: string): integer;
var nc, i: integer;
begin
    result := -1;
    nc := buscaCategoria (nome);
    if nc <= 0 then exit;

    with categs[nc] do
        begin
            numVisitados := numVisitados + 1;
            if numVisitados <= numItensUsar then
                result := categs[nc].aVisitar[categs[nc].numVisitados]
            else
                begin
                    for i := 1 to jogo.numLugares do
                        begin
                            if ansiUpperCase (jogo.lugares[i]^.nome) =
                               ansiUpperCase (lugarFimCateg) then
                                begin
                                    result := i;
                                    exit;
                                end;
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{                      busca um lugar
{--------------------------------------------------------}

function buscaLugar (nome: string): integer;
var i: integer;
begin
    result := -1;
    if nome = '' then exit;

    if pos (',', nome) <> 0 then
        begin
            limitaCategoria (nome);
            nome := trim (copy (nome, 1, pos(',', nome)-1));
        end;

    result := proxLugarDaCategoria(nome);
    if result > 0 then exit;

    for i := 1 to jogo.numLugares do
        if ansiUpperCase (jogo.lugares[i]^.nome) = ansiUpperCase (nome) then
            begin
                result := i;
                exit;
            end;
end;

{--------------------------------------------------------}
{                      fim do jogo
{--------------------------------------------------------}

procedure fimJogo;
begin
    closeBmp;
    clrscr;
    mensagem ('JOFIMJOG', 2);   {'Fim do Jogo'}
    mensagem ('JOAPTENT', 0);   {'Aperte Enter'}
    while readKey <> ENTER do;
    setWindowTitle('jogavox');   //Normaliza o título após jogo terminar
end;

{--------------------------------------------------------}
{     processa transição ao fim da série de slides
{--------------------------------------------------------}

procedure processaTransicao (lido: string;
                             var jogando: boolean; var indLugar: integer;
                             var novoLugar: string);

var i, n, p, qualop: integer;
    resp, lugar, lugares: string;
begin
    with jogo.lugares[indLugar]^ do
        begin
            lido := ansiUpperCase (trim(lido));
            if (respostaEsperada = '') and
               (lugarOk = '') and (lugarErro = '') then
                begin
                    indLugar := indLugar + 1;
                    novoLugar := '';
                end
            else
                begin
                    lido := '|' + lido + '|';
                    resp := '|' + expandeVar(ansiUpperCase(respostaEsperada)) + '|';
                    n := pos (lido, resp);

                    qualOp := 1;
                    for i := 1 to length(resp)-1 do
                        begin
                            if i = n then break;
                            if resp[i] = '|' then qualop := qualOp + 1;
                        end;

                    if n <> 0 then
                        begin
                            lugares := '|' + lugarOk + '|';
                            lugar := '';
                            for i := 1 to length(lugares) do
                                if lugares[i] = '|' then
                                    begin
                                        qualOp := qualOp - 1;
                                        if qualOp = 0 then
                                            begin
                                                delete (lugares, 1, i);
                                                p := pos('|',lugares);
                                                if p = 0 then
                                                    lugar := lugares
                                                else
                                                    lugar := copy (lugares, 1, p-1);
                                                break;
                                            end;
                                    end;

                            novoLugar := expandeVar(lugar);
                            if novoLugar = '' then
                                indLugar := indLugar + 1
                            else
                                indLugar := buscaLugar(novoLugar);
                        end
                    else
                        begin
                            novoLugar := expandeVar(lugarErro);
                            if lugarErro = '' then
                                indLugar := indLugar + 1
                            else
                                indLugar := buscaLugar(novoLugar);
                        end;
                end;
        end;

    alteraVarLongaScript ('ANTERIOR', obtemVarLongaScript('LUGAR'));
    alteraVarLongaScript ('LUGAR', novoLugar);
end;

{--------------------------------------------------------}
{           joga o jogo a partir de um ponto
{--------------------------------------------------------}

procedure jogaJogoPartindoDe (indLugar: integer; aleatPermitida: boolean);
var
    ultCarac, c: char;
    ultLugar: integer;
    lido: string;
    novoLugar: string;
    indNovoLugar: integer;
    ok: boolean;
    ultLinhaProc: integer;
    linhaProc: string;
    memo: string;
label loop;

        function executaScriptDoLugar (lugarEmJogo: integer; deEntrada: boolean): integer;
        var
            nomeArqScript, nomeLegado, rotulo, s: string;
            p: integer;
            temLegado: boolean;
        begin
            temLegado := false;
            nomeArqScript := copy (nomeArqJogo, 1, length(nomeArqJogo)-4) + '.pro';  // por default

            if deEntrada then
                begin
                    rotulo := jogo.lugares[lugarEmJogo]^.scriptEntrada;

                    if rotulo = '' then
                        begin   // processa legado, com scripts separados
                            nomeLegado := jogo.lugares[lugarEmJogo]^.nome;
                            if fileExists(nomeLegado + '.pro') then
                                begin
                                    temLegado := true;
                                    nomeArqScript := nomeLegado + '.pro';
                                end;
                        end;
                end
            else
                 rotulo := jogo.lugares[lugarEmJogo]^.scriptSaida;

            if (rotulo = '') and (not temLegado) then
                begin
                    result := lugarEmJogo;
                    exit;
                end;

            p := pos ('@', rotulo);
            if p >= 1 then
                begin
                    s := copy (rotulo, 1, p-1);
                    if s = '' then
                        delete (rotulo, 1, 1)
                    else
                        begin
                            nomeArqScript := s;
                            delete (rotulo, 1, p);
                        end;
                end;

            if fileExists(nomeArqScript) then
                begin
                    ok := executaScript (nomeArqScript, rotulo, ultLinhaProc, linhaProc) = SCR_OK;
                    if not ok then
                        begin
                             mensagem ('JOERRSCP', 1);     {'Erro no script do lugar: '}
                             sintWriteln (nomeArqScript);
                             sintWriteln (linhaProc);
                             result := -1;
                             exit;
                        end;

                    novoLugar := obtemVarLongaScript('LUGAR');
                    result := buscaLugar(novoLugar);
                end
            else
                result := lugarEmJogo;
        end;

begin
    ncategs := 0;
    lugarEmJogo := indLugar;
    jogando := true;
    pontosJogo := 0;
    alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));
    ultCarac := #$0;
    ultLugar := indLugar;

    montaListaDeCategorias;
    if aleatPermitida then
        embaralhaCategorias;

    clrscr;
    processCrtWindowQueue;

    while jogando and (lugarEmJogo >= 1) and (lugarEmJogo <= jogo.numLugares) do
        begin
            alteraVarLongaScript ('LUGAR', jogo.lugares[lugarEmJogo]^.nome);

            indNovoLugar := executaScriptDoLugar (lugarEmJogo, true);
            if indNovoLugar <> lugarEmJogo then
                begin
                    lugarEmJogo := indNovoLugar;
                    continue;
                end;

            with jogo.lugares[lugarEmJogo]^ do
                begin
                    pontosJogo := strToInt(obtemVarLongaScript ('PONTOS')) + pontuacao;
                    alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));
                end;

        loop:
            visualizaLugar (lugarEmJogo, ultCarac, lido);
            alteraVarLongaScript ('RESPOSTA', trim(lido));

            if jogo.lugares[lugarEmJogo].memoriaResposta <> '' then
                begin
                    memo := trim (jogo.lugares[lugarEmJogo].memoriaResposta);
                    if memo[1] = '$' then delete (memo, 1, 1);
                    if memo <> '' then
                        alteraVarLongaScript (memo, trim(lido));
                end;

            if ultCarac = ESC then
                begin
                    clrscr;
                    mensagem ('JOCNFFIM', 1);   {'Confirma fim? '}
                    c := upcase(sintreadKey);
                    writeln (c);
                    if c <> 'S' then goto loop;

                    jogando := false;
                end;

            if jogando then
                begin
                    indNovoLugar := executaScriptDoLugar (lugarEmJogo, false);   // script de saída
                    if indNovoLugar <> lugarEmJogo then
                        begin
                            lugarEmJogo := indNovoLugar;
                            continue;
                        end;

                    if jogo.lugares[lugarEmJogo]^.jogoTerminaAqui then
                        jogando := false
                    else
                        begin
                            ultLugar := lugarEmJogo;
                            processaTransicao (lido, jogando, lugarEmJogo, novoLugar);
                            if (lugarEmJogo = -1) or (lugarEmJogo > jogo.numLugares) then
                                 jogando := false;
                        end;
                end;
        end;

    if lugarEmJogo = -1 then
          begin
               clrscr;
               mensagem ('JOPRGINC', 1);     {'Programação de desvio incorreto no lugar: '}
               sintWriteln (jogo.lugares[ultLugar]^.nome + ' -- ' +  novoLugar);
               mensagem ('JOAPTENT', 0);     {'Aperte enter'}
               while readKey <> ENTER do;
          end;

    fimJogo;
end;

{--------------------------------------------------------}
{      executa um único lugar, sem executar script
{--------------------------------------------------------}

function jogaLugar (lugar: string) : string;
var
    ultCarac: char;
    lido: string;
    novoLugar, status: string;

label fim;

begin
    status := '$OK$';
    ultCarac := #$0;
    novoLugar := lugar;
    lido := '';

    lugarEmJogo := buscaLugar (lugar);

    if (lugarEmJogo < 1) and (lugarEmJogo > jogo.numLugares) then
        begin
           status := '$ERRO$';
           goto fim;
        end;

    alteraVarLongaScript ('LUGAR', lugar);

    with jogo.lugares[lugarEmJogo]^ do
        begin
            pontosJogo := pontosJogo + pontuacao;
            alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));
            visualizaLugar (lugarEmJogo, ultCarac, lido);

            if ultCarac = ESC then
               status := '$ESC$'
            else
            if jogoTerminaAqui then
               status := '$FIM$'
            else
               processaTransicao (lido, jogando, lugarEmJogo, novoLugar);
        end;

fim:
   alteraVarLongaScript ('RESPOSTA', trim(lido));
   alteraVarLongaScript ('LUGAR', novoLugar);
   alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));
   alteraVarLongaScript ('STATUS', status);

   lugarEmJogo := buscaLugar (lugar);
   if (lugarEmJogo < 1) and (lugarEmJogo > jogo.numLugares) then
       status := '$ERRO$';

   jogaLugar := status;
end;

{--------------------------------------------------------}
{                   faz a apresentação
{--------------------------------------------------------}

function apresentacao: boolean;

     procedure margem;
     begin
         write ('    ');
     end;

var i: integer;

begin
     apresentacao := false;

     clrscr;
     setWindowTitle('Jogavox');
     textBackground (BLUE);
     write (pegaTextoMensagem ('JOINIC'));   {'Jogavox - editor de jogos educacionais'}
     textBackground (BLACK);
     writeln; writeln;

     dirJogo := escolhePastaJogo;
     if dirJogo = '' then exit;

     if not pegaNomeJogo (nomeArqJogo) then exit;
     if not carregaEstruturaJogo (nomeArqJogo) then exit;

     clrscr;
     setWindowTitle('Jogavox ' + nomeArqJogo);
     window (6, 11, 66, 21);
     textBackGround (WHITE);
     clrscr;

     window (8, 10, 68, 20);
     textColor (WHITE);
     textBackGround (RED);
     clrscr;

     openBMP(dirBaseJogos+'\jogavox_logo.bmp');
     paintBMP(WindowSize.X-dvcrt.BMPwidth-20, 20);

     with jogo.dadosGerais do
         begin
             writeln;
             margem; writeln (nomeJogo);
             writeln;
             margem; // write (pegaTextoMensagem('JOAUTOR'));
                     writeln (autor);
             writeln;
             margem; write (pegaTextoMensagem('JOVERSAO'));
                     writeln (versao);
             writeln;
             for i := 1 to ncoment do
                 begin
                     margem;
                     writeln (comentarios[i]);
                 end;

             if jogo.narrando then
                 begin
                     sintetiza (nomeJogo);
                     //sintetiza (pegaTextoMensagem('JOAUTOR'));
                     sintetiza(autor);
                     sintetiza (pegaTextoMensagem('JOVERSAO'));
                     sintetiza(versao);
                     for i := 1 to 5 do
                         sintetiza(comentarios[i]);
                 end;
         end;

     window (1, 1, 80, 25);
     gotoxy (1, 24);
     mensagem ('JOAPTENT', 0);    {'Aperte Enter'}
     while readKey <> ENTER do;

     closeBMP;
     textColor (WHITE);
     textBackGround (BLACK);

     apresentacao := true;
end;

{--------------------------------------------------------}
{                joga o jogo do início
{--------------------------------------------------------}

procedure jogaJogo (carregado: boolean);
var ultLinha: integer;
    scriptControlador: string;
    linhaProc: string;
begin
    arqTempGrafico := getTempFile('bmp');

    ncategs := 0;

    if carregado or apresentacao then
        begin
            zeraVarScript;
            scriptControlador := jogo.dadosGerais.nomeScriptControlador;
            if scriptControlador = '' then
                jogaJogoPartindoDe (1, jogo.aleatorio)
            else
            if FileExists (scriptControlador) then
                begin
                    if executaScriptControlador(scriptControlador, @jogaLugar, ultLinha, linhaProc) <> SCR_OK then
                        begin
                            mensagem ('JOERRPGM', 0); {'Erro de execução no programa '}
                            sintWriteln (scriptControlador);
                            sintWriteln (pegaTextoMensagem('JO_LINHA') + intToStr(ultLinha) + ': ' + linhaProc);
                            writeln;
                            readln;
                        end
                end
            else
                begin
                    mensagem ('JOPGMNEX', 0);  {'Programa ainda não existe, executando a programação simples.'}
                    jogaJogoPartindoDe (1, jogo.aleatorio);
                end;
        end;

    closebmp;

    if FileExists(arqTempGrafico) then
         deleteFile (arqTempGrafico);
end;

end.
