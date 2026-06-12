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
    dvscript, dialogs;

function jogaLugar (lugar: string) : string;
procedure jogaJogoPartindoDe (indLugar: integer);
procedure jogaJogo;
function buscaLugar (nome: string): integer;

implementation

{--------------------------------------------------------}
{                      busca um lugar
{--------------------------------------------------------}

function buscaLugar (nome: string): integer;
var i: integer;
begin
    result := -1;
    if nome = '' then exit;
    for i := 1 to jogo.numLugares do
        if ansiUpperCase (jogo.lugares[i]^.nome) = ansiUpperCase (nome) then
            begin
                result := i;
                break;
            end;
end;

{--------------------------------------------------------}
{                      fim do jogo
{--------------------------------------------------------}

procedure fimJogo;
begin
    clrscr;
    mensagem ('JOFIMJOG', 2);   {'Fim do Jogo'}
    mensagem ('JOAPTENT', 0);   {'Aperte Enter'}
    readln;
end;

{--------------------------------------------------------}
{     tratamento de variáveis do script (nomes longos)
{--------------------------------------------------------}

procedure setScriptVar (nomeVar: string; valor: string);
var n: integer;
    v: char;
begin
    n := nomeVarLonga.indexOf('lugar');
    v := chr (n+1 + ord('Z'));
    varScript[v] := '';
end;

{--------------------------------------------------------}
{            processa script ao início ou fim
{--------------------------------------------------------}

procedure processaScript (arqScript, rotuloScript: string;
                          var jogando: boolean; var indLugar: integer);
var ultimaLinha: integer;
    novoLugar: string;
    status: integer;
    i: integer;
begin
    for i := 1 to length(rotuloScript) do
        if rotuloScript[i] = ' ' then rotuloScript[i] := '_';

    status := executaScript (arqScript, rotuloScript, ultimaLinha);
    case status of
        SCR_SEMARQUIVO, SCR_ROTULOINVALIDO:
            exit;   // aqui não é erro, só não existe

        SCR_OK:
            begin
                pontosJogo := strToInt (obtemVarLongaScript ('PONTOS'));
                novoLugar := obtemVarLongaScript ('LUGAR');
                if novoLugar <> '' then
                    indLugar := buscaLugar(novoLugar);
            end;

        SCR_ERROEXEC:
            begin
                clrscr;
                mensagem ('JOERRSCP', 0);   {'Erro de execução no script '}
                sintWriteln (arqScript);
                mensagem ('JOLINHA', 0);    {'O problema está na linha '}
                sintWriteln (intToStr(ultimaLinha));
                limpaBufTec;
                mensagem ('JOAPTENT', 0);   {'Aperte enter'}
                readln;
                indLugar := -1;
            end;
    end;
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
                            if lugar = '' then
                                indLugar := indLugar + 1
                            else
                                indLugar := buscaLugar(lugar);
                        end
                    else
                        begin
                            novoLugar := expandeVar(lugarErro);
                            if lugarErro = '' then
                                indLugar := indLugar + 1
                            else
                                indLugar := buscaLugar(lugarErro);
                        end;
                end;
        end;

    alteraVarLongaScript ('LUGAR', novoLugar);
end;

{--------------------------------------------------------}
{           joga o jogo a partir de um ponto
{--------------------------------------------------------}

procedure jogaJogoPartindoDe (indLugar: integer);
var
    ultCarac, c: char;
    ultLugar: integer;
    lido: string;
    nomeArqScript: string;
    novoLugar: string;
label loop;
begin
    lugarEmJogo := indLugar;
    jogando := true;
    pontosJogo := 0;
    ultCarac := #$0;
    ultLugar := indLugar;

    nomeArqScript := copy (nomeArq, 1, length(nomeArq)-4) + '.PRO';

    while jogando and (lugarEmJogo >= 1) and (lugarEmJogo <= jogo.numLugares) do
        begin
            with jogo.lugares[lugarEmJogo]^ do
                begin
                    pontosJogo := pontosJogo + pontuacao;
                    alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));
                    alteraVarLongaScript ('LUGAR', nome);

                    processaScript (nomeArqScript, nome + '_entra', jogando, lugarEmJogo);
                    if (lugarEmJogo = -1) or (not jogando) then break;
                end;

        loop:
            visualizaLugar (lugarEmJogo, ultCarac, lido);
            alteraVarLongaScript ('RESPOSTA', trim(lido));

            if ultCarac = ESC then
                begin
                    clrscr;
                    mensagem ('JOCNFFIM', 1);   {'Confirma fim? '}
                    c := upcase(sintReadkey);
                    writeln (c);
                    if c <> 'S' then goto loop;

                    jogando := false;
                end;

            if jogando then
                if jogo.lugares[lugarEmJogo]^.jogoTerminaAqui then
                    jogando := false
                else
                    begin
                        ultLugar := lugarEmJogo;
                        processaTransicao (lido, jogando, lugarEmJogo, novoLugar);
                        if lugarEmJogo = -1 then
                             jogando := false
                        else
                            with jogo.lugares[ultLugar]^ do
                                begin
                                    processaScript (nomeArqScript, nome + '_sai', jogando, lugarEmJogo);
                                    if lugarEmJogo > jogo.numLugares then
                                        jogando := false;
                                    if (lugarEmJogo = -1) or (not jogando) then break;
                                end;
                    end;
        end;

    if lugarEmJogo = -1 then
          begin
               clrscr;
               mensagem ('JOPRGINC', 1);     {'Programação de desvio incorreto no lugar: '}
               sintWriteln (jogo.lugares[ultLugar]^.nome + ' -- ' +  novoLugar);
               mensagem ('JOAPTENT', 0);     {'Aperte enter'}
               readln;
          end;

    fimJogo;
end;

{--------------------------------------------------------}
{           executa um único lugar
{--------------------------------------------------------}

function jogaLugar (lugar: string) : string;
var
    ultCarac: char;
    lido: string;
    novoLugar: string;
    indLugar: integer;
begin
    ultCarac := #$0;
    indLugar := buscaLugar (lugar);

    if (lugarEmJogo >= 1) and (lugarEmJogo <= jogo.numLugares) then
        begin
           jogaLugar := '$ERRO$';
           exit
        end;

    alteraVarLongaScript ('LUGAR', lugar);

    with jogo.lugares[indLugar]^ do
        begin
            pontosJogo := pontosJogo + pontuacao;
            alteraVarLongaScript ('PONTOS', intToStr(pontosJogo));

            visualizaLugar (indLugar, ultCarac, lido);
            alteraVarLongaScript ('RESPOSTA', trim(lido));

            if ultCarac = ESC then
              begin
                 jogaLugar := '$ESC$';
                 exit
              end;

           if jogoTerminaAqui then
              begin
                 jogaLugar := '$FIM$';
                 exit
              end;

           processaTransicao (lido, jogando, indLugar, novoLugar);
           alteraVarLongaScript ('LUGAR', trim(lido));
        end;
   jogaLugar := '$OK$';
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

     dirJogo := escolhePastaJogo (false);
     if dirJogo = '' then exit;

     if not pegaNomeJogo (nomeArq) then exit;
     if not carregaEstruturaJogo (nomeArq) then exit;

     clrscr;

     window (8, 9, 72, 19);
     textBackGround (WHITE);
     clrscr;

     window (10, 8, 70, 18);
     textColor (WHITE);
     textBackGround (RED);
     clrscr;

     with jogo.dadosGerais do
         begin
             writeln;
             margem; writeln (nomeJogo);
             writeln;
             margem; write (pegaTextoMensagem('JOAUTOR'));
                     writeln (autor);
             writeln;
             margem; write (pegaTextoMensagem('JOVERSAO'));
                     writeln (versao);
             writeln;
             for i := 1 to ncoment do
                 begin
                     margem;
                     write (comentarios[i]);
                 end;
             writeln;

             sintetiza (nomeJogo);
             sintetiza (pegaTextoMensagem('JOAUTOR'));
             sintetiza(autor);
             sintetiza (pegaTextoMensagem('JOVERSAO'));
             sintetiza(versao);
             for i := 1 to 5 do
                 sintetiza(comentarios[i]);
         end;

     window (1, 1, 80, 25);
     gotoxy (1, 24);
     mensagem ('JOAPTENT', 0);    {'Aperte Enter'}
     while readkey <> ENTER do;

     textColor (WHITE);
     textBackGround (BLACK);

     apresentacao := true;
end;

{--------------------------------------------------------}
{                joga o jogo do início
{--------------------------------------------------------}

procedure jogaJogo;
var ultLinha: integer;
    nome_script: string;
begin
    if apresentacao then
        begin
            zeraVarScript;
            nome_script := copy (nomeArq, 1, length(nomeArq)-3) + 'PRO';
            if FileExists (nome_script) then
                begin
                    if executaScriptControlador(nome_script, @jogaLugar, ultLinha) <> SCR_OK then
                        mensagem ('JOERRSCP', 2); {'Erro de execução no script '}
                end
            else
                jogaJogoPartindoDe (1);
        end;
end;

end.



function executaScriptControlador (nomeArq: string; rotina: RotinaExterna; var ultLinhaProc: integer): integer;
begin
    rotinaExternaPtr := rotina;
    executaScriptControlador := executaScript (nomeArq, '', ultLinhaProc);
    rotinaExternaPtr := NIL;
end;

