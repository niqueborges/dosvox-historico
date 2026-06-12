unit dosquem;

interface
uses windows, dvcrt, dvwin, dosmsg;

procedure mostraAutores (lendo: boolean);
procedure mostraQuem (versao: string);

implementation

{--------------------------------------------------------}
{                    mostra os autores
{--------------------------------------------------------}

procedure mostraAutores (lendo: boolean);
begin
     window (1, wherey, 80, wherey+9);
     textBackground (DarkGray);
     clrscr;
     write   (DV_AUT_01);   {'    Projeto DOSVOX:      '}
     textColor (YELLOW);
     writeln (DV_AUT_02);   {'http://intervox.nce.ufrj.br/dosvox'}
     textColor (WHITE);
     writeln;
     write   (DV_AUT_03);   {'    Dúvidas técnicas:    '}
     textColor (YELLOW);
     writeln (DV_AUT_04);  {'(021)3938-3198 - CAEC - UFRJ'}
     textColor (WHITE);
     writeln;
     write   (DV_AUT_05);  {'    Responsável técnico: '}
     textColor (YELLOW);
     writeln (DV_AUT_06);  {'Prof. Dr. Antonio Borges'}
     writeln (DV_AUT_07);  {'                         (021)3938-3339 - antonio2@nce.ufrj.br'}
     textColor (WHITE);
     writeln;
     write (DV_AUT_08);    {'    Autores da versão 1.0 - 1993    '}
     textColor (YELLOW);
     writeln (DV_AUT_08a); {'Antonio Borges e Marcelo Pimentel'}
     textColor (WHITE);
     write (DV_AUT_09);    {'             Versão 6.1 (2021)     '}
     textColor (YELLOW);
     writeln (DV_AUT_09A); {'Antonio Borges, Neno Albernaz,'}
     write (DV_AUT_10);    {'                                   Júlio Silveira, Bruna Lima e Patrick Barboza'}
     textColor (WHITE);

     window (1, 1, 80, 25);
     gotoxy (1, 24);
     textBackground (BLACK);

     if lendo then
         begin
             sintetiza (DV_AUT_01);
             sintetiza (DV_AUT_02);
             sintetiza (DV_AUT_03);
             sintetiza (DV_AUT_04);
             sintetiza (DV_AUT_05);
             sintetiza (DV_AUT_06);
             sintetiza (DV_AUT_07);
             sintetiza (DV_AUT_08);
             sintetiza (DV_AUT_08A);
             sintetiza (DV_AUT_09);
             sintetiza (DV_AUT_09a);
             sintetiza (DV_AUT_10);
         end;
end;

{--------------------------------------------------------}
{                  mostra o nome do dono
{--------------------------------------------------------}

procedure mostraQuem (versao: string);
var arq: text;
    nomeArq, s: string;
    i: integer;
begin
    nomeArq := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    nomeArq := nomeArq + '\DOSVOX.DON';

    assignFile (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('DOSVOX versão ' + versao);
            writeln;
            sintWriteln ('Instituto Tércio Pacitti de Aplicações e Pesquisas Computacionais');
            sintWriteln ('      (originalmente Núcleo de Computação Eletrônica)');
            writeln;
            sintWriteln ('Universidade Federal do Rio de Janeiro');
            writeln;
            sintWriteln ('O DOSVOX é um software livre, distribuído segundo a licença GPL');
            writeln;
            sintWriteln ('Registrado no INPI (1994) em nome de José Antonio Borges e Marcelo Pimentel');
            writeln;
            exit;
        end;

    while not eof (arq) do
        begin
            readln (arq, s);
            for i := 1 to length (s) do
                s[i] := chr (ord (s[i]) xor ((i+10) mod 20));
            s := s + #$0;
            oemToAnsi (@s[1], @s[1]);
            writeln (s);
            sintetiza (s);
        end;

    {$I-} closeFile (arq); {$I+}
    if ioresult <> 0 then;
    writeln;
end;

end.
