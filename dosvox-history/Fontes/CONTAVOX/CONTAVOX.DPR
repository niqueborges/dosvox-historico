{--------------------------------------------------------}
{
{   Jogo das Continhas VOX
{
{   Baseado no Jogo das Continhas do CD Menino Curioso
{
{   Autores:  Sonia Maria Paixao Borges
{             Berta Regina Paixao Pissurno
{             Jose' Antonio Borges
{
{    Em 10/05/2001
{
{--------------------------------------------------------}

program contaVox;
uses dvwin, dvcrt;

const MAXFASES=10;
      MAXJOGOSFASE=30;

var arq: text;
    nivelEscolhido, nfases: integer;
    njogosFase: array [1..MAXFASES] of integer;
    jogo: array [1..MAXFASES, 1..MAXJOGOSFASE] of ^string;

procedure operaTabuadona (oper: char);  forward;

{--------------------------------------------------------}
{                 fala uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; apular: integer);
var i: integer;
    s: string;
begin
    s := '';
    if nomeArq = 'CVINIC' then
        s := 'Tem início o jogo Contavox'
    else
    if nomeArq = 'CVFIM' then
        s := 'Fim do Jogo Contavox'
    else
    if nomeArq = 'CVARQNAO' then
        s := 'Arquivo contavox.cnf não foi achado'
    else
    if nomeArq = 'CVNIVEL' then
        s := 'Em que campeonato você quer jogar?'
    else
    if nomeArq = 'CVNIVEL1' then
        s := 'Treino no quintal'
    else
    if nomeArq = 'CVNIVEL2' then
        s := 'Amistoso Colegas da Rua'
    else
    if nomeArq = 'CVNIVEL3' then
        s := 'Campeonato do Bairro'
    else
    if nomeArq = 'CVNIVEL4' then
        s := 'Taça Inter-bairros'
    else
    if nomeArq = 'CVNIVEL5' then
        s := 'Campeonato Juvenil'
    else
    if nomeArq = 'CVNIVEL6' then
        s := 'Campeonato Estadual'
    else
    if nomeArq = 'CVNIVEL7' then
        s := 'Copa Brasil'
    else
    if nomeArq = 'CVNIVEL8' then
        s := 'Copa Libertadores da América'
    else
    if nomeArq = 'CVNIVEL9' then
        s := 'Copa do Mundo'
    else
    if nomeArq = 'CVNIVEL0' then
        s := 'Digite TAB para treinamento tático avançado (só para craques)'
    else
    if nomeArq = 'CVDESIST' then
        s := 'Já sei, está cansado, tudo bem, fica para a próxima!'
    else
    if nomeArq = 'CVDENOVO' then
        s := 'Você tem que digitar o número do campeonato.  Vou repetir.'
    else
    if nomeArq = 'CVERRARQ' then
        s := 'Arquivo contavox.cnf está estragado, verifique!'
    else
    if nomeArq = 'CVERRMAX' then
        s := 'Só posso realizar 30 jogos por fase'
    else
    if nomeArq = 'CVFASE' then
        s := 'Tem início agora a fase '
    else
    if nomeArq = 'CVFIMFAS' then
        s := 'Excelente, ganhou a fase!'
    else
    if nomeArq = 'CVERRESP' then
        s := 'Não, não...  Tecle um ou mais números e depois enter'
    else
    if nomeArq = 'CVERRTEC' then
        s := 'Nãnãnã, é pra teclar um número e depois ENTER.'
    else
    if nomeArq = 'CVQUERTB' then
        s := 'Quer conferir na tabuada?'
    else
    if nomeArq = 'CVCONFTB' then
        s := 'Conferindo na tabuadinha!'
    else
    if nomeArq = 'CVCNFTBG' then
        s := 'Vamos treinar na tabuadona?'
    else
    if nomeArq = 'CVNGOL' then
        s := 'Uh! '
    else
    if nomeArq = 'CVGOL' then
        s := 'Gol! '
    else
    if nomeArq = 'CVCONFER' then
        s := 'Conferindo...'
    else
    if nomeArq = 'CVERREXP' then
        s := 'Erro em uma conta!!!  Arquivo contavox.cnf estragado!'
    else
    if nomeArq = 'CVDENOV1' then
        s := 'É, essa fase foi difícil, não deu para ganhar...'
    else
    if nomeArq = 'CVDENOV2' then
        s := 'Vai ter que jogar essa fase de novo...'
    else
    if nomeArq = 'CVGANHOU' then
        s := 'GANHOU O CAMPEONATO!!!'
    else
    if nomeArq = 'CVTREITB' then
       s := 'Tem início o treino no Campo Federal da Tabuadona!'
    else
    if nomeArq = 'CVUSESET' then
       s := 'Use as setinhas para andar'
    else
    if nomeArq = 'CVAPENTR' then
       s := 'Aperte ENTER para saber o resultado, ESC termina'
    else
        begin
            writeln;
            writeln ('------------------------------------');
            writeln ('--- mensagem errada: ', nomeArq, ' ---');
            writeln ('------------------------------------');
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
{                   mensagens de gol
{--------------------------------------------------------}

const
    msgGol: array [1..25] of pchar = (
        'Gol de placa!',
        'Gol de bicicleta!',
        'Gol no ângulo!',
        'Foi la no canto, lá onde a coruja dorme!',
        'Gol de cobertura!',
        'Gol de cabeça!',
        'Gol no canto direito!',
        'Gol no canto esquerdo!',
        'Gol no ângulo direito!',
        'Gol no ângulo esquerdo!',
        'Bateu nas duas traves e entrou!',
        'Passou por baixo das pernas do goleiro, que frangaço!',
        'Bola para um canto, goleiro pro outro!',
        'A bola bateu no montinho artilheiro e enganou o goleiro!',
        'Uma fantástica folha seca!',
        'Entrou com bola e tudo!',
        'Esse foi de calcanhar!',
        'Voleio espetacular!',
        'Uma meia bicicleta!',
        'Que loucura, um gol de barriga!',
        'Pimba na gorduchinha!',
        'O goleiro nem viu a bola!',
        'Tá no filó!',
        'Golaço!',
        'Esse é de craque!'
    );

procedure narraGol;
var nomearq, s: string;
    i: integer;
begin
    mensagem ('CVGOL', 0);  {'Gol! '}
    i := random (25)+1;
    writeln (msgGol [i]);
    str (i, s);
    nomeArq := 'CVGOL' + s;

    if existeArqSom (nomeArq) then
        sintsom (nomeArq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{                mensagens de erro de gol
{--------------------------------------------------------}

const
    msgSemGol: array [1..13] of pchar = (
        'Gol contra!',
        'Arrancou a grama!',
        'Chutou o chão!',
        'Quase quebrou o pé!',
        'Errou a bola!',
        'Na trave!',
        'Chutou e não achou nada!',
        'Minha nossa, a bola saiu do estádio!',
        'Chutou mauzão!',
        'O que que eu vou dizer lá em casa!',
        'Esse até minha avó fazia!',
        'Pelo amor dos meus filhinhos!',
        'Foi chutar a bola e acertou no juiz!'
    );

procedure narraSemGol;
var s, nomeArq: string;
    i: integer;
begin
    mensagem ('CVNGOL', 0);  {'Uh! '}
    i := random (13)+1;
    writeln (msgSemGol [i]);
    str (i, s);
    nomeArq := 'CVNGOL' + s;

    if existeArqSom (nomeArq) then
        sintsom (nomeArq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{             fala um número com voz de homem
{--------------------------------------------------------}

procedure numeroHomem (i: integer);
var s: string;
begin
    str (i, s);
    sintetiza (s);
end;

{--------------------------------------------------------}
{             fala um número com voz de homem
{--------------------------------------------------------}

procedure numeroMulher (i: integer);
var s: string;
begin
    str (i, s);
    sintSoletra (s);
end;

{--------------------------------------------------------}
{                    limpa a tela
{--------------------------------------------------------}

procedure limpaTela;
var y: integer;
begin
    for y := 2 to 25 do
        begin
            gotoxy (1, y);
            clreol;
        end;
    gotoxy (1, 3);
end;

{--------------------------------------------------------}
{                    fecha o programa
{--------------------------------------------------------}

procedure fechaTudo;
begin
    sintFim;
    delay (1000);
    doneWinCrt;
end;

{--------------------------------------------------------}
{                    inicialização
{--------------------------------------------------------}

procedure inicializa;
var nomearq: string;
begin
    sintInic (0, sintAmbiente ('CONTAVOX', 'DIRCONTAVOX'));
    sintFalaPont := false;

    writeln ('Contavox - NCE/UFRJ e Escola Municipal Rio Grande do Sul - v1.0');
    writeln;
    sintSom ('CVMUSINI');

    mensagem ('CVINIC', 2);    {'Vai começar o jogo Contavox'}
    nomeArq := sintAmbiente ('CONTAVOX', 'CONFIGCONTAVOX');
    if nomeArq = '' then nomeArq := 'contavox.cnf';
    assign (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CVARQNAO', 1);   {'Arquivo contavox.cnf não foi achado'}
            fechaTudo;
        end;
    close (arq);
end;

{--------------------------------------------------------}
{                  escolhe o campeonato
{--------------------------------------------------------}

function escolheCampeonato: integer;
var c, c2: char;
    n, erro: integer;
label deNovo;
begin

deNovo:
    writeln;
    while keypressed do readkey;
    mensagem ('CVNIVEL', 2);    {'Em que campeonato você quer jogar?'}

    for c := '1' to '9' do
        begin
            write (c);
            sintSom (c);
            write (' - ');
            mensagem ('CVNIVEL'+c, 1);   {... campeonatos ...}
        end;
    writeln;

    writeln;
    mensagem ('CVNIVEL0', 1);     {'Digite TAB para treinamento tático'}

    repeat
        sintLeTecla (c, c2);
        if c = #$0d then
            mensagem ('CVNIVEL', 1);    {'Em que campeonato você quer jogar?'}
    until (c <> #$0d) and (c <> #$08);
    writeln;
    if c = ESC then
        begin
            mensagem ('CVDESIST', 1);   {'Já sei, está cansado, tudo bem, fica para a próxima!'}
            mensagem ('CVFIM', 1);      {'Fim do Jogo Contavox'}
            fechaTudo;
        end
    else
        if c = TAB then
             begin
                 operaTabuadona ('*');
                 limpaTela;
                 goto deNovo;
             end
        else
        if not (c in ['1'..'9']) then
            begin
                mensagem ('CVDENOVO', 1); {'Você tem que teclar o número do campeonato.  Vou repetir.'}
                limpaTela;
                goto deNovo;
            end;

    val (c, n, erro);
    escolheCampeonato := n;
end;

{--------------------------------------------------------}
{                  carrega um jogo do banco
{--------------------------------------------------------}

procedure carregaBanco (njogo: integer);
var i, j, fase: integer;
    s: string;
label erro, leMaisUma;
begin
    reset (arq);
    for i := 1 to njogo do
        begin
            repeat
                if eof (arq) then goto erro;
                readln (arq, s);
            until (s <> '') and (s[1] = '*');
        end;

    delete (s, 1, 1);
    writeln (s);

    nfases := 0;
    for fase := 1 to 20 do
        begin
            j := 0;
leMaisUma:
            if eof (arq) then
                s := '*'
            else
                readln (arq, s);

            if (s <> '') and (s[1] = '*') then
                begin
                   if j <> 0 then
                       begin
                           njogosFase [fase] := j;
                           nfases := fase;
                       end;
                   break;
                end;

            if s = '' then
                begin
                   if j = 0 then
                       goto leMaisUma   {múltiplas linhas em branco são ignoradas}
                   else
                       begin
                           njogosFase [fase] := j;
                           nfases := fase;
                           continue;        {vai para a próxima fase}
                       end;
                end;

            if j > MAXJOGOSFASE then
                begin
                    mensagem ('CVERRMAX', 1);  {'Só posso realizar 30 jogos por fase'}
                    goto erro;
                end;

            j := j + 1;
            new (jogo[fase, j]);
            jogo[fase, j]^ := s;
            goto leMaisUma;
        end;

    close (arq);
    exit;

erro:
    close (arq);
    mensagem ('CVERRARQ', 1);   {'Arquivo contavox.cnf está estragado, verifique!'}
    fechaTudo;
end;

{--------------------------------------------------------}
{                   prepara um jogo
{--------------------------------------------------------}

procedure preparaJogo (fase: integer);
var c1, c2, i: integer;
    temp: pointer;
begin
    clrscr;
    writeln ('Contavox');
    writeln;
    sintSom ('CVTANA');
    mensagem ('CVFASE', 0);    {'Tem início agora a fase '}
    writeln (fase);
    sintSoletra (chr(fase+ord('0')));
    sintSom ('CVTANA3');
    writeln;

    { embaralha os jogos }

    for i := 1 to 20 do
        begin
            c1 := random (njogosFase[fase]) + 1;
            c2 := random (njogosFase[fase]) + 1;
            temp := jogo [fase, c1];
            jogo [fase, c1] := jogo [fase, c2];
            jogo [fase, c2] := temp;
        end;
end;

{--------------------------------------------------------}
{                isola partes da conta
{--------------------------------------------------------}

function isolaOper (s: string;
                    var op1: integer;
                    var oper: char;
                    var op2, res: integer): boolean;
var
    salva, n: string;
    erro: integer;
    problemas: boolean;
begin
    salva := s;

    problemas := false;
    op1 := 0;
    oper := '+';
    op2 := 0;
    res := 0;

    while pos (' ', s) <> 0 do      { por garantia }
        delete (s, pos (' ', s), 1);

    n := '';
    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            n := n + s[1];
            delete (s, 1, 1);
        end;
    val (n, op1, erro);
    if erro <> 0 then problemas := true;

    if s <> '' then
         oper := s[1];
    delete (s, 1, 1);
    if not (oper in ['+', '-', '*', 'x', 'X', '/', ':']) then problemas := true;

    n := '';
    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            n := n + s[1];
            delete (s, 1, 1);
        end;
    val (n, op2, erro);
    if erro <> 0 then problemas := true;

    if (s = '') or (s[1] <> '=') then problemas := true;
    delete (s, 1, 1);

    n := '';
    while (s <> '') and (s[1] in ['0'..'9']) do
        begin
            n := n + s[1];
            delete (s, 1, 1);
        end;
    val (n, res, erro);
    if erro <> 0 then problemas := true;

    if problemas then
        begin
            mensagem ('CVERREXP', 1);    {'Erro em uma conta!!!  Arquivo contavox.cnf estragado!'}
            sintWriteln (salva);
            isolaOper := false;
        end
    else
        isolaOper := true;
end;

{--------------------------------------------------------}
{                    exibe um número
{--------------------------------------------------------}

procedure mostraNum (op: integer);
begin
    if op in [0..9] then
        begin
            write (op);
            sintSom (chr (op+ord('0')));
        end
    else
        sintWriteint (op);
    while sintfalando do;
end;

{--------------------------------------------------------}
{                   mostra uma conta
{--------------------------------------------------------}

function mostraConta (fase, chute: integer): string;
var s: string;
    op1, op2, res: integer;
    oper: char;
begin
    mostraConta := '';
    s := jogo[fase, chute]^;

    if not isolaOper (s, op1, oper, op2, res) then
        fechaTudo;

    sintSom ('CVTANA2');
    mostraNum (op1);
    write (oper);
    case oper of
        '+':           sintsom ('CVMAIS');
        '-':           sintsom ('CVMENOS');
        '*', 'x', 'X': sintsom ('CVVEZES');
        '/', ':':      sintsom ('CVDIVID');
    end;
    mostraNum (op2);
    write ('=');
    sintSom ('CVIGUAL');

    str (res, s);
    mostraConta := s;
end;

{--------------------------------------------------------}
{                  le a resposta
{--------------------------------------------------------}

function leResposta: string;
var resp: string;
    i: integer;
    ok: boolean;
    c: char;
begin
    repeat
        ok := true;
        resp := '';
        c := sintEdita (resp, wherex, wherey, 10, true);
        if c <> ENTER then
            begin
                leResposta := c;
                exit;
            end;

        for i := 1 to length (resp) do
            if not (resp[i] in ['0'..'9', '.']) then ok := false;
        if not ok then
            mensagem ('CVERRTEC', 1);   {'Nãnãnã, é pra teclar um número e depois ENTER.'}
    until ok;
    leResposta := resp;
end;

{--------------------------------------------------------}
{                   Confere a conta
{--------------------------------------------------------}

procedure confere (fase, chute: integer);
var i: integer;
    op1, op2, res: integer;
    oper: char;
begin
    isolaOper (jogo[fase,chute]^, op1, oper, op2, res);
    if (oper = '*') or (oper = 'x') or (oper = 'X') or
       (oper = '/') or (oper = ':') then
        exit;
    if (op1 > 10) or (op2 > 10) then exit;

    mensagem ('CVCONFER', 1);   {'Conferindo...'}

    mostraNum (op1);
    delay (500);
    for i := 1 to op1 do
        begin
            sintSom ('CVCLOK');
            delay (500);
        end;

    delay (500);
    write (oper);
    case oper of
        '+':           sintsom ('CVMAIS');
        '-':           sintsom ('CVMENOS');
        '*', 'x', 'X': sintsom ('CVVEZES');
        '/', ':':      sintsom ('CVDIVID');
    end;

    delay (500);
    mostraNum (op2);

    for i := 1 to op2 do
        begin
            sintSom ('CVCLOK');
            delay (500);
        end;

    delay (500);
    write ('=');
    sintSom ('CVIGUAL');
    mostraNum (res);
    writeln;
end;

{--------------------------------------------------------}
{                     Fim de fase
{--------------------------------------------------------}

procedure fimDaFase (fase: integer);
begin
    writeln;
    sintSom ('CVTANA');
    sintSom ('CVUAU');
    mensagem ('CVFIMFAS', 1);   {'Excelente!  Ganhou a fase'}
    writeln;
end;

{--------------------------------------------------------}
{                  ganha o campeonato
{--------------------------------------------------------}

procedure ganhouCampeonato;
var c: char;
begin
    writeln;
    writeln;
    sintSom ('CVUAU');
    mensagem ('CVGANHOU', 2);   {'GANHOU O CAMPEONATO'}
    sintSom ('CVPALMAS');
    sintSom ('CVMUSFIM');
    mensagem ('CVFIM', 1);

    repeat
        c := readkey;
    until (c = ENTER) or (c = #$0a);
end;

{--------------------------------------------------------}
{           inventa motivo para desistência
{--------------------------------------------------------}

procedure inventaMotivo;
begin
    mensagem ('CVDESIST', 2);
    delay (2000);
end;

{--------------------------------------------------------}
{                  mostra uma tabuada
{--------------------------------------------------------}

procedure mostraTabuada (op1: integer; oper: char);
var y, res: integer;
    c: char;

        procedure desenhaConta (falando: boolean);
        begin
            if (y < 0) or (y > 10) then exit;
            gotoxy (30, y+6);
            write (op1:2, ' ', oper, ' ', y:2, ' = ');
            case oper of
                '+':            res := op1 + y;
                '-':            res := op1 - y;
                '*', 'x', 'X':  res := op1 * y;
                '/', ':':       res := op1 div y;
            end;
            write (res:2);

            if falando then
                begin
                    numeroHomem (op1);
                    case oper of
                        '+':           sintsom ('CVMAIS');
                        '-':           sintsom ('CVMENOS');
                        '*', 'x', 'X': sintsom ('CVVEZES');
                        '/', ':':      sintsom ('CVDIVID');
                    end;
                    numeroHomem (y);
                    sintSom ('CVIGUAL');
                    numeroHomem (res);
                end;
        end;

begin
    limpaTela;

    mensagem ('CVCONFTB', 1);      {'Conferindo na tabuadinha!'}
    for y := 0 to 10 do
        desenhaConta (false);
    gotoxy (30, 6);

    y := -1;
    repeat
        c := readkey;
        if c = #$0 then c := readkey;

        desenhaConta (false);
        case c of
            ESC, ENTER: ;
            CIMA: y := y - 1;
            BAIX: y := y + 1;
        else
            sintbip;
        end;

        if y < 0 then
            begin
                sintBip;
                y := -1;
            end;
        if y > 10 then
            begin
                sintBip;
                y := 11;
            end;

        textColor (yellow);
        desenhaConta (true);
        textColor (lightGray);

    until (c = ESC) or (c = ENTER);

    limpaTela;
end;

{--------------------------------------------------------}
{           mostra uma tabuada de linhas e colunas
{--------------------------------------------------------}

procedure desenhaTabuadona (oper: char);
                           {Na verdade só chamada para vezes}
var x, y, res: integer;
begin
    gotoxy (16, 6);
    writeln (oper, '     0   1   2   3   4   5   6   7   8   9');
    gotoxy (16, 7);
    writeln (      '   ----------------------------------------');
    res := 0;
    for y := 0 to 9 do
         begin
             gotoxy (16, 8+y);
             write (y, ' |');
             for x := 0 to 9 do
                 begin
                     case oper of
                         '+':            res := x + y;
                         '-':            res := x - y;
                         '*', 'x', 'X':  res := x * y;
                         '/', ':':       res := x div y;
                     end;
                     write (res:4);
                 end;
         end;

    gotoxy (16, 6);
end;

{--------------------------------------------------------}
{                 anda na tabuadona
{--------------------------------------------------------}

function andaNaTabuadona (oper: char): char;
                                {Na verdade só chamada para vezes}
var x, y: integer;
    c: char;
    res: integer;
    sres: string;
    mostrandoPos: boolean;

    function conta (x: integer; oper: char; y: integer): integer;
    begin
        conta := 0;
        case oper of
            '+':            conta := x + y;
            '-':            conta := x - y;
            '*', 'x', 'X':  conta := x * y;
            '/', ':':       if y <> 0 then conta := x div y else conta := 0;
        end;
    end;

    procedure lepos (x, y: integer);
    begin
        if mostrandoPos then
            begin
                numeroHomem (y);
                numeroMulher (x);
            end
        else
            begin
                res := conta (x, oper, y);
                str (res, sres);
                sintetiza (sres);
            end;
    end;

begin
    x := -1;
    y := -1;
    mostrandoPos := true;
    repeat
         c := readkey;
         if c = #$0 then c := readkey;

         if c = ESC then break;

         case c of
             TAB:  begin
                       mostrandoPos := not mostrandoPos;
                       sintBip;
                       if mostrandoPos then sintBip;
                   end;

             ' ':  if x >= 0 then
                         begin
                             sintSom (chr (y+ord('0')));
                             sintSom ('CVVEZES');
                             sintSom (chr (x+ord('0')));
                             sintBip;
                         end;

             HOME:   begin
                         x := 0;
                         lePos (x, y);
                     end;

             ENTER:  if x >= 0 then
                         begin
                             res := conta (x, oper, y);
                             sintSom (chr (y+ord('0')));
                             sintSom ('CVVEZES');
                             sintSom (chr (x+ord('0')));
                             sintSom ('CVIGUAL');
                             str (res, sres);
                             sintetiza (sres);
                         end;

             ESQ:    begin
                         x := x - 1;
                         if x < 0 then x := 0;
                         if y < 0 then y := 0;
                         lePos (x, y);
                     end;

             DIR:    begin
                         x := x + 1;
                         if x > 9 then x := 9;
                         if y < 0 then y := 0;
                         lePos (x, y);
                     end;

             CIMA:   begin
                         y := y - 1;
                         if y < 0 then y := 0;
                         if x < 0 then x := 0;
                         lePos (x, y);
                     end;

             BAIX:   begin
                         y := y + 1;
                         if y > 9 then y := 9;
                         if x < 0 then x := 0;
                         lePos (x, y);
                     end;
         end;

         if x < 0 then x := 0;
         if y < 0 then y := 0;

         gotoxy (16+3+x*4, 8+y);
         textColor (YELLOW);
         res := conta (x, oper, y);
         write (res:4);
         gotoxy (16+6+x*4, 6);     write (x);
         gotoxy (16, 8+y);         write (y);

         while not keypressed do;

         gotoxy (16+3+x*4, 8+y);
         textColor (LIGHTGRAY);
         write (res:4);
         gotoxy (16+6+x*4, 6);   write (x);
         gotoxy (16, 8+y);       write (y);

    until (c = ESC);

    andaNaTabuadona := c;
end;

{--------------------------------------------------------}
{                   opera tabuadona
{--------------------------------------------------------}

procedure operaTabuadona;
var c: char;
begin
    limpaTela;
    c := #$0;
    repeat
        if c = #$0 then
            begin
                sintSom ('CVTANA3');
                gotoxy (1, 3);
                mensagem ('CVTREITB', 2);   {'Tem início o treino no Campo Federal da Taboadona!'}
                sintSom ('CVINITRT');

                gotoxy (1, 20);
                mensagem ('CVUSESET', 1);   {'Use as setinhas para andar'}
                mensagem ('CVAPENTR', 1);   {'Aperte ENTER para saber o resultado, ESC termina'}
                writeln ('Professor: Aperte ESPAÇO para ler só a conta');
                writeln ('           TAB para escolher entre ler posição ou ler resultado');
                write   ('           HOME: volta ao início da linha');

            end;

        desenhaTabuadona ('*');
        c := andaNaTabuadona ('*');
    until c = ESC;

    limpaTela;
end;

{--------------------------------------------------------}
{               confere na tabuadona
{--------------------------------------------------------}

procedure confereTabuadona (fase, chute: integer);
var
    op1, op2, res: integer;
    oper: char;
    c, c2: char;
begin
    mensagem ('DVCNFTBG', 0);     {'Vamos treinar na tabuadona?'}
    sintLeTecla (c, c2);
    writeln;
    if upcase (c) <> 'N' then
        begin
            isolaOper (jogo[fase, chute]^, op1, oper, op2, res);
            operaTabuadona (oper);
        end;
end;

{--------------------------------------------------------}
{                   termina o programa
{--------------------------------------------------------}

procedure termina;
begin
    while keypressed do readkey;

    textBackground (BLACK);
    clrscr;
    writeln;
    writeln;
    textColor (WHITE);
    writeln ('   O CONTAVOX é um programa sonoro, criado para auxiliar');
    writeln ('   na educação básica de crianças com deficiência visual e sua');
    writeln ('   integração com outras crianças.');
    writeln;
    textColor (YELLOW);
    writeln ('   Argumento Original: Prof. Sonia Borges e Prof. Berta Paixao');
    writeln ('   Adaptação e Programação:  Prof. José Antonio Borges');
    writeln;
    textColor (WHITE);
    writeln ('   Projeto DOSVOX - NCE/UFRJ');
    writeln ('   Coordenação: Prof. José Antonio Borges');
    writeln ('   e-mail: antonio2@nce.ufrj.br');
    writeln ('   FAX: (021)270-8554 - tel.: (021)598-3339');

    readkey;
    fechatudo;
end;

{--------------------------------------------------------}
{                  confere com a tabuada
{--------------------------------------------------------}

procedure confereTabuada (fase, chute: integer);
var c, c2: char;
    op1, op2, res: integer;
    oper: char;
begin
    mensagem ('CVQUERTB', 0);   {'Quer conferir na tabuada?'}
    sintLeTecla (c, c2);
    writeln;
    if upcase (c) <> 'N' then
        begin
            isolaOper (jogo[fase, chute]^, op1, oper, op2, res);
            mostraTabuada (op1, oper);
        end;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

var fase, chute, nchutes: integer;
    resposta, respCorreta: string;
    errou: boolean;

label cancela, jogaFaseDeNovo;

begin
    randomize;
    inicializa;
    nivelEscolhido := escolheCampeonato;
    carregaBanco (nivelEscolhido);
    for fase := 1 to nfases do
        begin
            nchutes := njogosFase [fase];
jogaFaseDeNovo:
            errou := false;
            preparaJogo (fase);
            for chute :=1 to nchutes do
                begin
                    repeat
                        writeln;
                        respCorreta := mostraConta (fase, chute);
                        resposta := leResposta;
                    until resposta <> '';
                    writeln;
                    if resposta = '.' then
                        begin
                           errou := true;
                           confereTabuada (fase, chute);
                        end
                    else
                    if resposta = TAB then
                        begin
                           errou := true;
                           operaTabuadona ('*');
                        end
                    else
                    if resposta[1] = ESC then
                        begin
                            inventaMotivo;
                            goto cancela;
                        end
                    else
                    if resposta = respCorreta then
                        begin
                            sintSom ('CVCHUTE');
                            narraGol;
                        end
                    else
                        begin
                            sintSom ('CVCHUTE');
                            narraSemGol;
                            confere (fase, chute);
                            errou := true;
                        end;
                end;
            if errou then
                begin
                    writeln;
                    mensagem ('CVDENOV1', 1);   {'É, essa fase foi difícil, não deu para ganhar...'}
                    mensagem ('CVDENOV2', 1);   {'Vai ter que jogar essa fase de novo...'}
                    goto jogaFaseDeNovo;
                end
            else
                if fase <> nfases then
                    fimDaFase (fase);
        end;

    ganhouCampeonato;
cancela:
    termina;
end.
