program ttrad2;
uses dvcrt, dvwin;

var
    s: string;
    c: char;

begin
    sintInic (0, '');
    sintAcumulaFala := false;

    sintWrite ('Digite uma letra ');
    c := sintReadkey;
    writeln;   // isso não afera o sintetizador, é só estético.
    sintWriteln ('Reparou que o sintWrite falou porque veio um sintReadkey?');

    sintWrite ('A valor Ascii da tecla lida foi ');
    sintWriteint (ord(c));
    sintWriteln ('');

    sintWrite ('Escreva uma pequena frase:');
    sintReadln (s);
    sintWriteln ('Reparou que o sintWrite falou porque veio um sintReadln?');

    sintWriteln ('Tecle linhas, ponto termina');
    sintWriteln ('Linhas em branco fazem falar');

    repeat
        readln (s);
        if s <> '.' then
            sintetiza (s);
    until s = '.';

    sintFim;
    donewincrt;
end.
