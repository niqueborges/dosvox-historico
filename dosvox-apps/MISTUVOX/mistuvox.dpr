{--------------------------------------------------------}
{
{   Jogo Mistuvox
{   Autor: Jose' Antonio Borges
{   Em 30/12/1994
{   Revisto por Patrick Barbosa em julho/2021
{
{--------------------------------------------------------}

program mistuvox;

uses dvCrt, dvWin, dvWav;

type 
    BUF = array [0..65000] of byte;
    PBUF = ^BUF;

var nomeArqSom: string;
    arqSom: file;
    tamSom: longint;
    nivel: integer;
    ganhou: boolean;
    sequencia, seqtec, salvaseq: array [1..9] of integer;
    pfala: PBUF;

{--------------------------------------------------------}
{             da uma mensagem falada e na tela
{--------------------------------------------------------}

procedure msg (m : string);
begin
    while keypressed do readkey;

    if m = 'MISAPRES' then
        begin
            textBackground (BLACK);
            clrscr;
            textBackground (BLUE);
            write ('Jogo Mistura VOX');
            textBackground (BLACK);
            writeln;
            writeln;
            sintSom ('MISE2');
        end
    else
    if m = 'MISDINST' then
        write ('Deseja instruções (s/n) ? ')
    else
    if m = 'MISINSTR' then
        begin
            writeln;
            writeln ('O jogo apresenta para você um som partido e misturado.');
            writeln ('Voce tem que encontrar a ordem do som original, representada');
            writeln ('por números de 1 a 9.  Boa sorte !');
        end
    else
    if m = 'MISBYE' then
        begin
            writeln;
            textBackground (BLUE);
            write ('Nunca deixe sua mente se enferrujar.  Ela é sua arma.');
            textBackground (BLACK);
            writeln;
            sintSom ('MISE2');
        end
    else
    if m = 'MISPARAB' then
        begin
            writeln;
            textBackground (BLUE);
            write ('Parabéns. Você conseguiu.');
            textBackground (BLACK);
            writeln;
            sintSom ('MISE2');
        end
    else
    if m = 'MISSIFU' then
        begin
            writeln;
            textBackground (BLUE);
            write ('Nao deu, amigo. Você está com a mente entupida.');
            textBackground (BLACK);
            writeln;
            sintSom ('MISE10');
        end
    else
    if m = 'MISCOMPL' then
        writeln ('O som completo era: ')
    else
    if m = 'MISNIVEL' then
        begin
            writeln ('Vamos ao nível ', nivel);
            sintSom ('MISE2');
        end
    else
    if m = 'MISCOMEC' then
        begin
            textBackground (BLUE);
            write ('Começando.');
            textBackground (BLACK);
            writeln;
        end
    else
    if m = 'MISSEQ' then
        write ('A sequencia era ')
    else
    if m = 'MISTENTA' then
        begin
            write ('Digite a tentativa: ');
            sintSom ('MISE3');
        end
    else
    if m = 'MISERRO' then
        begin
            writeln;
            writeln ('Erro ! Tecle toda sequência de novo.');
            sintSom ('MISE7');
        end
    else
    if m = 'MISDNOVO' then
        begin
            writeln;
            write ('Quer jogar de novo (S/N) ? ')
        end
    else
    if m = 'MISDESIS' then
        begin
            writeln;
            write ('Desistiu... ');
            sintSom ('MISE10');
        end
    else
    if m = 'MISREPET' then
        begin
            writeln;
            writeln ('Repetindo...');
        end
    else
    if m = 'MISDMAIS' then
        begin
            writeln;
            write ('Você é bom demais !');
            sintSom ('MISE8');
        end
    else
    if m = 'MISOTIMA' then
        begin
            writeln;
            write ('Você está com a mente ótima !');
            sintSom ('MISE8');
        end
    else
    if m = 'MISARNEN' then
        writeln ('Arquivo mistuvox.arq nao encontrado. Programa cancelado.')
    else
    if m = 'MISMSERA' then
        writeln ('O som todo era: ')
    else
    if m = 'MISNENC' then
        writeln ('Arquivo de som não encontrado. Programa cancelado.')
    else
    if m = 'MISQNIVL' then
        write ('Escolha seu nível, de 3 a 9: ')
    else
        writeln (chr(7)+chr(7)+chr(7)+'Mensagem errada: ' + m);

    while sintFalando do;
    sintsom (m);
end;

{--------------------------------------------------------}
{              le uma resposta com uma letra
{--------------------------------------------------------}

procedure le (var r : char);
begin
   r := readkey;
   write (r);
   sintCarac (r);
   r := upcase (r);
end;

{--------------------------------------------------------}
{                 inicializa o programa
{--------------------------------------------------------}

procedure inicializa;
var r: char;
    dir: string;
begin
    dir := sintAmbiente ('MISTUVOX', 'DIRMISTUVOX');
    if dir = '' then
        dir := 'c:\winvox\som\mistuvox';
    sintinic (0, dir);

    randomize;
    clrscr;
    msg ('MISAPRES');
    msg ('MISDINST');
    le (r);
    if r = 'S' then msg ('MISINSTR');
    writeln;

    new (pfala);
end;

{--------------------------------------------------------}
{                   finaliza o programa
{--------------------------------------------------------}

procedure finaliza;
begin
    msg ('MISBYE');
    dispose (pfala);
    while sintFalando do;
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                  escolhe um som
{--------------------------------------------------------}

procedure escolheSom;
var 
    dir: string;
    arq: text;
    i, n, nlin: integer;
    numRead: integer;

begin
    dir := sintAmbiente('MISTUVOX', 'DIRMISTUVOX');
    if dir = '' then
        dir := 'c:\winvox\som\mistuvox';
    if dir [length(dir)] <> '\' then    { Neste ponto, dir <> '' }
        dir := dir + '\';

    assign (arq, dir+'mistuvox.arq');
    {$i-}   reset (arq);   {$i+}
    if ioresult <> 0 then
        begin
            msg ('MISARNEN');
            delay (2000);
            sintFim;
            doneWinCrt;
        end;

    nlin := 0;
    while not eof (arq) do
        begin
            readln (arq, nomeArqSom);
            nlin := nlin + 1;
        end;

    close (arq);
    reset (arq);

    randomize;
    n := random (nlin);
    for i := 0 to n do
        readln (arq, nomeArqSom);

    assign (arqsom, nomeArqSom);
    {$I-} reset (arqsom, 1); {$I+}
    if ioresult <> 0 then
        begin
            writeln;
            writeln (nomeArqSom);
            sintSoletra (nomeArqSom);
            msg ('MISNENC');
            delay (2000);
            sintFim;
            doneWinCrt;
        end;

    tamSom := fileSize (arqsom) - 50;
    blockread (arqsom, pfala^, 49, numRead);    { ignora header }
    blockread (arqsom, pfala^, tamsom, numRead);
end;

{--------------------------------------------------------}
{                    escolhe nivel
{--------------------------------------------------------}

procedure escolheNivel;
var c: char;
begin
    repeat
        msg ('MISQNIVL');
        le (c);
        writeln;
    until c in ['3'..'9'];
    nivel := ord (c) - ord ('0');
end;

{--------------------------------------------------------}
{                       vitoria
{--------------------------------------------------------}

procedure vitoria;
begin
    msg ('MISPARAB');
end;

{--------------------------------------------------------}
{                       derrota
{--------------------------------------------------------}

procedure derrota;
var i: integer;
begin
    msg ('MISSIFU');
    msg ('MISSEQ');
    for i := 1 to nivel do
        begin
            sintCarac (chr (sequencia [i] + ord ('0')));
            write (sequencia [i], ' ');
        end;

    clreol;
    writeln;
end;

{--------------------------------------------------------}
{                  embaralha o jogo
{--------------------------------------------------------}

procedure embaralha;
var
   seq: array [0..8] of integer;
   i, r: integer;
   embaralhado: boolean;

begin
    repeat
        for i:= 0 to 8 do
            seq[i] := i+1;

        randomize;
        for i := 1 to nivel do
            begin
                r := random (nivel);
                while seq [r] = 255 do
                    r := (r + 1) mod nivel;
                sequencia [i] := seq [r];
                seq [r] := 255;
            end;

        embaralhado := false;
        for i := 1 to nivel do     { garante embaralhamento }
            if sequencia [i] <> i then embaralhado := true;

    until embaralhado;
end;

{--------------------------------------------------------}
{                        avaliacao
{--------------------------------------------------------}

function avaliacao: real;
var 
    i: integer;
begin
    avaliacao := 10.0;

    for i := 1 to nivel do
        if sequencia[seqtec [i]] <> i then
            avaliacao := 0;
end;

{--------------------------------------------------------}
{                     toca a sequencia
{--------------------------------------------------------}

procedure tocaSequencia;
type
    RECFALA = record
        cabFala: array [0..43] of byte;
        bufFala: array [0..65000] of byte;
    end;

var tambloco: word;
    p: ^RECFALA;
    i: integer;
begin
    tambloco := tamSom div nivel;
    new (p);
    for i := 1 to nivel do
        begin
            delay (1000);
            limpabufTec;
            sintcarac (chr (seqtec[i]+ord('0')));
            delay (500);

            move (pfala^[tambloco * (sequencia[seqtec[i]]-1)], p^.bufFala, tamBloco);
            geraCabWav (pchar (p), tamBloco, 11025, 8, 1);
            sintMem (pchar(p));
            while sintFalando do;
        end;
    dispose (p);
end;

{--------------------------------------------------------}
{                  inicializa um jogo novo
{--------------------------------------------------------}

procedure joga;
var 
    jogadas, i: integer;
    c: char;
    nota: real;

label denovo, fim;

begin
    ganhou := false;
    msg ('MISCOMEC');

    delay (1000);
    embaralha;

    for i := 1 to nivel do
        seqtec[i] := i;

    tocaSequencia;
    delay (1000);

    writeln;
    for jogadas := 1 to nivel do
        begin

deNovo:
            salvaseq := seqtec;

            msg ('MISTENTA');

            for i := 1 to nivel do
                begin
                    le (c);
                    if c = #$1b then
                        begin
                            msg ('MISDESIS');
                            goto fim;
                        end;

                    if (c = ' ') then
                        begin
                            msg ('MISREPET');
                            seqtec := salvaseq;
                            limpaBufTec;
                            tocaSequencia;
                            goto deNovo;
                        end;

                    if (c < '1') or (c > chr (nivel+ord('0'))) then
                        begin
                            msg ('MISERRO');
                            seqtec := salvaseq;
                            goto deNovo;
                        end;

                    seqtec [i] := ord(c) - ord ('0');

                end;

            writeln;
            tocaSequencia;

            nota := avaliacao;
            if nota = 10 then
                begin
                    vitoria;
                    ganhou := true;
                    goto fim;
                end;
        end;

    derrota;

fim:
    msg ('MISMSERA');
    close (arqSom);

    while sintFalando do;
    {
        nomeArqSom := nomeArqSom + #$0;
        sndPlaySound (@nomeArqSom[1], SND_SYNC);
    }
    wavePlayFile (nomeArqSom);
    while sintFalando do;

    writeln;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

var r: char;
label fim;
begin
    inicializa;
    escolheNivel;

    repeat
        msg ('MISNIVEL');
        sintcarac (chr (nivel+ord('0')));

        escolheSom;

        joga;

        if ganhou then
            begin
                nivel := nivel + 1;
                if nivel > 9 then
                    begin
                        msg ('MISDMAIS');
                        goto fim;
                    end
                else
                if nivel > 5 then
                    msg ('MISOTIMA');
            end;

        msg ('MISDNOVO');
        le (r);
        writeln;
    until r <> 'S';

fim:
    finaliza;
end.
