{-----------------------------------------------------------}
{
{    Programa para testes de multipla escolha falados
{
{    Autor: Jose' Antonio Borges
{
{    Em 22/01/97
{
{-----------------------------------------------------------}

program questvox;
uses
    dvcrt, dvwin, dvarq, winprocs, messages, sysutils, classes, dvwav;

const versao = '2.1';

var nomeArq, nomeArqResp, dirSom: string;
    arq: text;

type
    strNome = string[8];

    plistaLinhas = ^listaLinhas;
    listaLinhas = record
        linha: string[80];
        proxLinha: pListaLinhas;
    end;

type
    tquestao = record
        som: strNome;
        texto: plistaLinhas;
        nitems: integer;
        item: array [1..10] of plistaLinhas;
        valorItem: array [1..10] of integer;
        resposta: char;
    end;

var
    somTitulo: strNome;
    textoTitulo: plistaLinhas;

    nomePessoa: string;
    questao: array [1..200] of tquestao;
    nquestoes: integer;
    linha: string;

    ninterAval: integer;
    somAval: strNome;
    textoAval: plistaLinhas;

    limAval: array [0..200] of integer;
    somCritAval: array [0..200] of strNome;
    critAval: array [0..200] of pListaLinhas;
    nota: integer;

{-----------------------------------------------------------}
{                        mensagens
{-----------------------------------------------------------}

procedure mensagem (m: string; nlf: integer);
const CRLF = #$0d+#$0a;
var s: string;
    i: integer;
begin
     if m = 'QVINIC' then
             s := 'Projeto DOSVOX         ' + CRLF +
                  'Q U E S T V O X        ' + CRLF +
                  'Questionário automático' + CRLF +
                  'Versão '
     else
     if m = 'QVQUENOM' then
         s := 'Informe o nome do arquivo de questões'
     else
     if m = 'QVDESIS' then
         s := 'Desistiu...'
     else
     if m = 'QVARQNAO' then
         s := 'Arquivo de questões não existe'
     else
     if m = 'QVFIM' then
         s := 'Fim do programa'
     else
     if m = 'QVINSTRU' then
         s := 'Responda cada pergunda com uma letra' + CRLF +
              'PAGE UP ou PAGE DOWN trocam de página' + CRLF +
              'Aperte ESC quando tiver terminado tudo'
     else
     if m = 'QVARQVAZ' then
          s := 'Arquivo de questões vazio'
     else
     if m = 'QVQUESTA' then
          s := 'Questão '
     else
     if m = 'QVINCORR' then
          s := ' incorretamente especificada'
     else
     if m = 'QVRESINC' then
          writeln (' com uma resposta inválida.')
     else
     if m = 'QVAVALER' then
          s := 'Intervalos de avaliação inválidos'
     else
     if m = 'QVERTIT' then
          s := 'Título incorretamente especificado'
     else
     if m = 'QVNQUEST' then
          s := 'Número de questões: '
     else
     if m = 'QVERRARQ' then
          s := 'Erro de escrita no arquivo ! '
     else
     if m = 'QVLETINV' then
          s := 'Letra inválida! '
     else
     if m = 'QVCNFFIM' then
          s := 'Confirma término de suas respostas ? '
     else
     if m = 'QVJAULT' then
          s := 'Esta foi a última pergunta, ESC termina'
     else
     if m = 'QVJAPRIM' then
          s := 'Estamos na primeira pergunta'
     else
     if m = 'QVQUESTN' then
          s := 'Questão '
     else
     if m = 'QVNOME' then
          s := 'Informe seu nome'
     ;

     write (s);
     for i := 1 to nlf do writeln;
     if existeArqSom(m) then
          sintSom (m)
     else
          sintetiza (s);
end;

{-----------------------------------------------------------}
{          sintetiza um som do diretorio de trabalho
{-----------------------------------------------------------}

procedure sintSomArq (s: string);
begin
    s := dirSom + s + '.wav';
    wavePlayFile(s);
end;

{-----------------------------------------------------------}
{                        finaliza
{-----------------------------------------------------------}

procedure finaliza;
begin
    mensagem ('QVFIM', 1);   {'Fim do programa'}
    delay (1000);
    sintFim;
    doneWincrt;
end;

{-----------------------------------------------------------}
{            insere uma cadeia na lista de textos
{-----------------------------------------------------------}

procedure insLisTexto (var texto: pListaLinhas; s: string);
var
    p, q: plistaLinhas;
begin
    new (q);
    with q^ do
        begin
            linha := s;
            proxLinha := NIL;
        end;

    if texto = NIL then
        texto := q
    else
        begin
            p := texto;
            while p^.proxLinha <> NIL do
                p := p^.proxLinha;
            p^.proxLinha := q;
        end;

    if length (s) > 80 then
        begin
            mensagem ('QVLONGA', 1);   {'Linha muito longa'}
            finaliza;
        end;
end;

{-----------------------------------------------------------}
{                pega um texto do arquivo
{-----------------------------------------------------------}

function pegaTexto (var nomeSom: strnome; var texto: plistaLinhas): boolean;
var nome: string;
begin
    pegaTexto := true;

    while linha = '' do
        begin
            if eof (arq) then
                begin
                     mensagem ('QVARQVAZ', 1);   {'Arquivo de questões vazio'}
                     finaliza;
                end
            else
                readln (arq, linha);
        end;

    nome := '';
    nomeSom := '';
    texto := NIL;

    while copy (linha, 1, 1) = '[' do
        begin
            if copy (linha, 1, 8) = '[DIRSOM=' then
                begin
                    dirSom := copy (linha, 9, 100);
                    delete (dirSom, length(dirSom), 1);
                    trim (dirSom);
                    if dirSom [length(dirSom)] <> '\' then
                        dirSom := dirSom + '\';
                end
            else
            if copy (linha, 1, 10) = '[RESPOSTA=' then
                begin
                    nomeArqResp := copy (linha, 11, 100);
                    delete (nomeArqResp, length(nomeArqResp), 1);
                    trim (nomeArqResp);
                end
            else
                nomeSom := trim (copy (linha, 2, length(linha)-2));

            if eof (arq) then
                linha := ''
            else
                readln (arq, linha);
        end;

    if linha = '' then
        begin
            pegaTexto := false;
            exit;
        end;

    repeat
        while (linha <> '') and (linha[1] = ' ') do
            delete (linha, 1, 1);
        insLisTexto (texto, linha);
        if eof (arq) then
            linha := ''
        else
            readln (arq, linha);
    until (linha = '') or (linha[1] <> ' ');
end;

{-----------------------------------------------------------}
{                pega uma resposta do arquivo
{-----------------------------------------------------------}

procedure pegaUmaResposta (nr: integer;
                  var texto: plistaLinhas; var valor: integer);
var num: string;
    erro: integer;
label errou;

begin
    { ja leu a linha }

    if upcase(linha[1]) <> chr (nr-1+ord('A')) then
        begin
errou:
            mensagem ('QVQUESTA', 0);    {'Questão '}
            sintWriteInt (nQuestoes);
            mensagem ('QVRESINC', 1);    {' com uma resposta inválida.'}
            finaliza;
        end;

    repeat
        delete (linha, 1, 1);
    until (linha = '') or (linha[1] <> ' ');

    num := '';
    while (linha <> '') and (linha[1] in ['0'..'9']) do
        begin
            num := num + linha[1];
            delete (linha, 1, 1);
        end;

    if num = '' then goto errou;
    val (num, valor, erro);
    if erro <> 0 then goto errou;

    texto := NIL;
    repeat
        while (linha <> '') and (linha[1] = ' ') do
            delete (linha, 1, 1);
        if linha <> '' then
            insLisTexto (texto, linha);
        if eof (arq) then
            linha := ''
        else
            readln (arq, linha);
    until (linha = '') or (linha[1] <> ' ');
end;

{-----------------------------------------------------------}
{              carrega as questoes na memoria
{-----------------------------------------------------------}

procedure carregaQuestoes;
var
    i: integer;
begin
    nquestoes := 0;
    linha := '';
    if not pegaTexto (somTitulo, textoTitulo) then
        begin
            mensagem ('QVERTIT', 1);   {'Título incorretamente especificado'}
            finaliza;
        end;

    while not eof (arq) do
        begin
            nquestoes := nquestoes + 1;

            with questao[nquestoes] do
                begin
                    for i := 1 to 10 do
                        begin
                            item [i] := NIL;
                            valorItem [i] := 0;
                        end;
                    resposta := ' ';

                    if not pegaTexto (som, texto) then
                        begin
                            mensagem ('QVQUESTAO', 0);    {'Questão '}
                            sintWriteInt (nQuestoes);
                            mensagem ('QVINCORR', 1);    {' incorretamente especificada'}
                            finaliza;
                        end;

                    if texto^.linha = '*' then
                        begin
                            nquestoes := nquestoes - 1;
                            exit;
                        end;

                    nitems := 0;
                    while linha <> '' do
                        begin
                            nitems := nitems + 1;
                            pegaUmaResposta (nitems,
                                        item[nitems], valorItem[nitems]);
                        end;
                end;
        end;
end;

{-----------------------------------------------------------}
{               carrega atributos da avaliacao
{-----------------------------------------------------------}

procedure carregaAvaliacao;
var erro: integer;
    i, j, temp: integer;
    tempc: pointer;
    temps: string;
begin
    linha := '';
    nInterAval := 0;

    if not pegaTexto (somAval, textoAval) then
        exit;

    repeat
            readln (arq, linha);
            ninterAval := ninterAval + 1;
            val (linha, limAval[ninterAval], erro);
            if erro <> 0 then
                begin
                    mensagem ('QVAVALER', 1);   {'Intervalos de avaliação inválidos'}
                    finaliza;
                end;

            linha := '';
            if not pegaTexto (somCritAval [ninterAval],
                              critAval [ninterAval]) then
                begin
                    mensagem ('QUAVALER', 1);   {'Intervalos de avaliação inválidos'}
                    finaliza;
                end;
    until eof (arq);
    close (arq);

    for i := 1 to ninterAval-1 do
        for j := i+1 to ninterAval do
             if limAval [i] > limAval [j] then
                 begin
                      temp := limAval [i];
                      limAval [i] := limAval [j];
                      limAval [j] := temp;

                      temps := somCritAval [i];
                      somCritAval [i] := somCritAval [j];
                      somCritAval [j] := temps;

                      tempc := critAval [i];
                      critAval [i] := critAval [j];
                      critAval [j] := tempc;
                 end;
end;

{-----------------------------------------------------------}
{                   sintetiza um texto
{-----------------------------------------------------------}

procedure falaTexto (p: plistaLinhas);
begin
    while p <> NIL do
        begin
            sintetiza (p^.linha);
            p := p^.proxLinha;
        end;
end;

{-----------------------------------------------------------}
{                   centra uma linha
{-----------------------------------------------------------}

procedure centraLinha (y: integer; s: string);
begin
    gotoxy ((80-length(s)) div 2, y);
    write (s);
end;

{-----------------------------------------------------------}
{               apresenta um texto centrado
{-----------------------------------------------------------}

procedure textoCentrado (var y: integer; p: plistaLinhas);
begin
    while p <> NIL do
        begin
            centraLinha (y, p^.linha);
            y := y + 1;
            p := p^.proxLinha;
        end;
end;

{-----------------------------------------------------------}
{           apresenta um texto alinhado a esquerda
{-----------------------------------------------------------}

procedure textoEsquerda (var y: integer; p: plistaLinhas);
begin
    while p <> NIL do
        begin
            writeln (p^.linha);
            y := y + 1;
            p := p^.proxLinha;
        end;
end;

{-----------------------------------------------------------}
{                  apresenta uma questao
{-----------------------------------------------------------}

procedure apresentaQuestao (qAtual: integer);
var i, y: integer;
begin
    while keypressed do readkey;

    clrscr;
    gotoxy (1, 1);
    mensagem ('QVQUESTN', 0);     {'Questão '}
    sintWriteInt (qAtual);

    with questao [qatual] do
        begin
            writeln;
            y := 3;
            textoEsquerda (y, texto);
            writeln;
            for i := 1 to nItems do
                begin
                    write (chr (ord ('A')-1+i), ' - ');
                    textoEsquerda (y, item[i]);
                end;

            gotoxy (20, wherey+1);

            if som = '' then
                begin
                    falaTexto (texto);
                    for i := 1 to nItems do
                          begin
                              if not keypressed then delay (200);
                              sintCarac (chr (ord ('A')-1+i));
                              if not keypressed then delay (200);
                              falaTexto (item[i]);
                          end;
                 end
            else
                sintSomArq (som);
        end;

end;

{-----------------------------------------------------------}
{                   aplica as questoes
{-----------------------------------------------------------}

procedure aplicaQuestoes;
var
    processando: boolean;
    c, ultLetra: char;
    qAtual: integer;


    procedure trataControles;
    var c: char;
    begin
        c := readkey;
        case c of
            PGUP,
            CIMA: if qatual > 1 then
                      qAtual := qAtual - 1
                  else
                      begin
                          clrscr;
                          mensagem ('QVJAPRIM', 0);   {'Estamos na primeira pergunta'}
                          qatual := 1;
                      end;

            PGDN,
            BAIX: if qatual < nQuestoes then
                      qAtual := qAtual + 1
                  else
                      begin
                          clrscr;
                          mensagem ('QVJAULT', 0);   {'Estamos na última pergunta'}
                          qatual := nQuestoes;
                      end;

            HOME, CTLPGUP: qAtual := 1;
            TEND, CTLPGDN: qAtual := nQuestoes;
        end;

    end;


begin
    writeln; writeln;
    mensagem ('QVNQUEST', 0);          {'Número de questões: '}
    sintWriteInt (nQuestoes);

    processando := true;

    qatual := 1;
    while processando do
        begin
            sintBip; sintBip;

            if qatual < 1 then
                 begin
                     clrscr;
                     mensagem ('QVJAPRIM', 0);   {'Estamos na primeira pergunta'}
                 end
            else
            if qatual > nQuestoes then
                 begin
                     clrscr;
                     mensagem ('QVJAULT', 0);   {'Estamos na última pergunta'}
                 end
            else
                apresentaQuestao (qAtual);

            with questao [qatual] do
                begin
                    c := upcase(readkey);
                    ultLetra := chr (nitems-1 + ord('A'));

                    if c = #$0 then
                        trataControles
                    else
                    if c = #$1b then
                        begin
                            clrscr;
                            mensagem ('QVCNFFIM', 0);    {'Confirma fim?'}
                            c := upcase(readkey);
                            sintCarac (c);
                            if c = 'S' then
                                processando := false;
                        end
                    else
                    if (qatual > 0) and (qatual <= nquestoes) and
                       (c in ['A'..ultLetra]) then
                        begin
                            write (c);
                            sintCarac (c);
                            resposta := c;
                            qatual := qatual + 1;
                        end
                    else
                        begin
                            gotoxy (1, 16);
                            clreol;
                            mensagem ('QVLETINV', 0);   {'Letra inválida'}
                        end;
                end;
        end;
end;

{-----------------------------------------------------------}
{              registra as respostas num arquivo
{-----------------------------------------------------------}

procedure registraRespostas;
var arq: text;
    i: integer;
begin
    assign (arq, nomeArqResp);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            {$I-}  rewrite (arq);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('QVERRARQ', 1);   {'Erro de escrita no arquivo !'}
                    finaliza;
                end;
        end
    else
        begin
            close (arq);
            {$I-}  append (arq);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('QVERRARQ', 1);   {'Erro de escrita no arquivo !'}
                    finaliza;
                end;
        end;

    writeln (arq, nomePessoa);
    for i := 1 to nquestoes do
        with questao [i] do
            write (arq, resposta);
    writeln (arq);
    writeln (arq, nota);

    close (arq);
end;

{-----------------------------------------------------------}
{                   mostra a avaliacao
{-----------------------------------------------------------}

procedure avalia;
var y, i: integer;
    p, q: plistaLinhas;
    s: strNome;
label achou;
begin
    nota := 0;
    for i := 1 to nquestoes do
        with questao [i] do
            if resposta <> ' ' then
                nota := nota + valorItem [ord(resposta) and $f];

    p := textoAval;
    q := NIL;

    s := '';
    for i := ninterAval downto 1 do
        if nota >= limAval [i] then
            begin
                q := critAval [i];
                s := somCritAval [i];
                goto achou;
            end;

achou:
    clrscr;
    y := 8;
    textoCentrado (y, p);
    textoCentrado (y, q);

    if somAval = '' then
        falaTexto (textoAval)
    else
        sintSomArq (somAval);

    if s = '' then
        falaTexto (q)
    else
        sintSomArq (s);

    readkey;
    writeln;
    writeln;
end;

{-----------------------------------------------------------}
{                 pergunta o nome do usuario
{-----------------------------------------------------------}

procedure perguntaNome;
begin
    writeln;  writeln;
    mensagem ('QVNOME', 1);   {'Informe seu nome'}
    sintReadln (nomePessoa);
    if nomePessoa = '' then
        begin
            mensagem ('QVDESIS', 1);    {'Desistiu...'}
            finaliza;
        end;

end;

{-----------------------------------------------------------}
{                    escreve tela inicial
{-----------------------------------------------------------}

procedure telaInicial;
var y: integer;
begin
    clrscr;
    y := 3;
    textoCentrado (y, textoTitulo);
    if somTitulo <> '' then
        sintSomArq (somTitulo)
    else
        falaTexto (textoTitulo);
    writeln;
    writeln;
end;

{-----------------------------------------------------------}
{                 pede arquivo de questões
{-----------------------------------------------------------}

procedure pedeArquivo;
begin
    if paramcount <> 0 then
        nomeArq := paramstr(1)
    else
        begin
            writeln;  writeln;
            mensagem ('QVQUENOM', 1);    {'Informe o nome do arquivo de questões'}
            nomearq := obtemNomeArq (7);

            if nomeArq = '' then
                begin
                    writeln;  writeln;
                    mensagem ('QVDESIS', 1);    {'Desistiu'}
                    finaliza;
                end;

        end;

    assign (arq, nomeArq);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            assign (arq, nomeArq+'.QST');
            {$I-} reset (arq); {$I+}
            if ioresult <> 0 then
                begin
                    writeln;
                    mensagem ('QVARQNAO', 1);   {'Arquivo de questões não existe'}
                    finaliza;
                end;
        end;
end;

{-----------------------------------------------------------}
{                 inicializa e abre arquivo
{-----------------------------------------------------------}

procedure inicializa;
var dir: string;
begin
    dir := sintAmbiente ('QUESTVOX', 'DIRQUESTVOX');
    if dir = '' then
        dir := 'c:\winvox\som\questvox';
    sintinic (0, dir);
    sintFalaPont := false;

    clrscr;
    setWindowText (crtWindow, 'QUESTVOX');

    textBackground (BLUE);
    mensagem ('QVINIC', 0);                  {'QuestVox - versão'}
    sintWriteln (versao);
    textBackground (black);

    getDir (0, dirSom);
    if dirSom [length(dirSom)] <> '\' then
        dirSom := dirSom + '\';
    nomeArqResp := 'resposta.txt';

    perguntaNome;
    pedeArquivo;
end;

{-----------------------------------------------------------}
{                       programa principal
{-----------------------------------------------------------}

begin
    inicializa;

    carregaQuestoes;
    carregaAvaliacao;

    telaInicial;

    mensagem ('QVINSTRU', 1);    {instruções de uso do programa}
    while keypressed do readkey;

    aplicaQuestoes;
    avalia;
    registraRespostas;

    finaliza;
end.
