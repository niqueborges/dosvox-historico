{--------------------------------------------------------}
{
{    Jogo didatico para memorizar o teclado
{    Autor: Jose' Antonio Borges
{    Em 9/7/94
{
{--------------------------------------------------------}

program memovox;
uses dvcrt, dvwin;
var
    nivel: char;
    resp: char;

{--------------------------------------------------------}
{                      da mensagem falada
{--------------------------------------------------------}

procedure mensagem (s: string);
begin
    if s = 'MVINIC' then begin
                         textBackGround (BLUE);
                         writeln ('JOGO DE MEMORIA VOX');
                         textBackGround (BLACK);
                         end
    else
    if s = 'MVNIVEL' then write ('Escolha seu nivel de 1 a 9: ')
    else
    if s = 'MVERROU' then
               begin
                       writeln;
                       writeln ('Tsc, tsc, tsc, tsc, tsc, errou...')
               end
    else
    if s = 'MVOK' then writeln ('***** Maravilhoso, explendido, tremendo ! *****')
    else
    if s = 'MVDENOVO' then write ('Quer jogar de novo (s/n) ? ')
    else
    if s = 'MVNANANI' then writeln ('Nananinanana...')
    else
    if s = 'MVERA' then writeln ('Era apenas o seguinte: ')
    else
    if s = 'MVTCHAU' then writeln ('Tchau.')
    else
    if s = 'MVPLIM' then
        begin
            delay (500);
            sintSom ('MVPLIM');
            delay (500);
        end;

    sintSom (s);
end;

{--------------------------------------------------------}
{                   geracao randomica
{--------------------------------------------------------}

function ran (n: integer): integer;
begin
    ran := random (256) mod n;
end;

{--------------------------------------------------------}
{                    gera uma letra
{--------------------------------------------------------}

const
    tamCadeia: array ['1'..'9'] of integer =
    {1}     ( 5,  { so' vogais }
    {2}      10,  { so' numeros }
    {3}      15,  { vogais e numeros }
    {4}      20,  { vogais e consoantes }
    {5}      20,  { consoantes e numeros }
    {6}      25,  { vogais, consoantes e numeros }
    {7}      20,  { numeros e especiais }
    {8}      15,  { vogais e especiais }
    {9}      35   { tudo }
    );

function geraletra: char;
const
    vogais: array [0..4] of char = ('a', 'e', 'i', 'o', 'u');

    consoantes: array [0..20] of char = ('b', 'c', 'd', 'f', 'g',
                                         'h', 'j', 'k', 'l', 'm',
                                         'n', 'p', 'q', 'r', 's',
                                         't', 'v', 'w', 'x', 'y', 'z');

    numeros: array [0..9] of char = ('0', '1', '2', '3', '4',
                                     '5', '6', '7', '8', '9');

    especiais: array [0..31] of char = (',', '.', '/', '<', '>', '?',
                                       ';', '''', ':', '"',
                                       '[', ']', '{', '}',
                                       '`', '~',
                                       '!', '@', '#', '$', '%', '^',
                                       '&', '*', '(', ')', '-', '_',
                                       '=', '+', '\', '|');

var r: integer;

begin
    geraletra := ' ';
    case nivel of
        '1':  geraletra := vogais [ran(5)];

        '2':  geraletra := numeros [ran (10)];

        '3':  begin
                  r := random (2);
                  if r = 0 then
                      geraletra := vogais [ran (5)]
                  else
                      geraletra := numeros [ran (10)];
              end;

        '4':  begin
                  r := random (2);
                  if r = 0 then
                      geraletra := vogais [ran (5)]
                  else
                      geraletra := consoantes [ran (21)];
              end;

        '5':  begin
                  r := random (2);
                  if r = 0 then
                      geraletra := numeros [ran (10)]
                  else
                      geraletra := consoantes [ran (21)];
              end;

        '6':  begin
                  r := random (3);
                  if r = 0 then
                      geraletra := vogais [ran (5)]
                  else if r = 1 then
                      geraletra := numeros [ran (10)]
                  else
                      geraletra := consoantes [ran (21)];
              end;

        '7':  begin
                  r := random (2);
                  if r = 0 then
                      geraletra := numeros [ran (10)]
                  else
                      geraletra := especiais [ran (32)];
              end;

        '8':  begin
                  r := random (2);
                  if r = 0 then
                      geraletra := vogais[ran (5)]
                  else
                      geraletra := especiais [ran (32)];
              end;

        '9':  begin
                  r := random (4);
                  case r of
                      0: geraletra := vogais[ran (5)];
                      1: geraletra := consoantes [ran (21)];
                      2: geraletra := numeros [ran (9)];
                      3: geraletra := especiais [ran (32)];
                  end;
              end;
    end;
end;

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    dir := sintAmbiente ('MEMOVOX', 'DIRMEMOVOX');
    if dir = '' then
        dir := 'c:\winvox\som\memovox';
    sintInic (0, dir);
    sintTeclaCorta (false);
    mensagem ('MVINIC');
    randomize;
end;

{--------------------------------------------------------}
{                  pede o nivel de execucao
{--------------------------------------------------------}

procedure pedeNivel;
begin
    writeln;
    repeat
        delay (200);
        while sintFalando do;
        while keypressed do readkey;
        mensagem ('MVNIVEL');
        nivel := sintReadkey;
        writeln (nivel);

        if nivel = #$1b then
            begin
                sintFim;
                doneWinCrt;
            end;

        if not (nivel in ['1'..'9']) then
            mensagem ('MVNANANI');
        while keypressed do readkey;
    until nivel in ['1'..'9'];
end;

{--------------------------------------------------------}
{                jogo propriamente dito
{--------------------------------------------------------}

procedure joga;
var s: string;
    i, j: integer;
    c: char;
label maisum;

begin
    s := '';
    delay (1000);

    while length (s) < tamCadeia [Nivel] do
        begin
            write (#$0d);
            clreol;
            while keypressed do readkey;

            s := s + geraletra;              { mostra desafio }

            mensagem ('MVPLIM');
            for i := 1 to length (s) do
                begin
                    write (s[i]);
                    sintCarac (s[i]);
                end;

            while keypressed do readkey;
            delay (500);                     { apaga e cleeek }
            for i := 1 to length (s) do
                write (#8, ' ', #8);

            for i := 1 to length (s) do      { le as respostas }
                begin
                    c := sintReadkey;
                    if c >= #20 then
                        write (c);

                    if c <> s[i] then
                        begin
                            writeln;
                            mensagem ('MVERROU');
                            mensagem ('MVERA');
                            for j := 1 to length (s) do
                                begin
                                    sintcarac (s[j]);
                                    write (s[j]);
                                end;
                            writeln;
                            exit;
                        end;
                end;
        end;

    writeln;
    mensagem ('MVOK');
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

begin
    inicializa;

    repeat
        pedeNivel;
        joga;

        writeln;
        mensagem ('MVDENOVO');
        while keypressed do readkey;
        resp := sintReadkey;
        if resp > #20 then writeln (resp);

    until upcase (resp) <> 'S';
    mensagem ('MVTCHAU');
    sintFim;
    doneWinCrt;
end.
