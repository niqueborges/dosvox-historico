{----------------------------------------------------------------------}
{ PROGRAMA DE ADIVINHAR O NUMERO PROPOSTO PELO COMPUTADOR
{ PROGRAMADOR: AIRTON SIMILLE MARQUES
{ CRIADO EM: MARÇO DE 1996
{ READAPTADO EM: JUNHO DE 1996
{ ENDEREÇO: RUA MARIA GUEBUR No. 84
{ 082300-150 CURITIBA PARANA BRASIL
{ TELEFONE: (041)2721943
{----------------------------------------------------------------------}

program sortevox;

uses dvcrt, dvwin, sysutils, dvLenum;

var amb: string;
    buscado, conte, numero: integer;
    s: string;
    jogando: boolean;
    c: char;
    x, y: integer;

begin
    textBackground (red);
    textColor (yellow);
    clrscr;

    { formando a tela.}
    window (19,22,59,24);
    textbackground (blue);
    clrscr;
    gotoxy (10, 2);
    write ('TECLE <<ESC>> PARA SAIR');

    window (19,02,59,04);
    clrscr;
    gotoxy (13, 2);
    write ('    SORTEVOX');

    window (19,6,59,20);
    clrscr;
    window (20,6,59,20);
    gotoxy (1, 1);

    { sons de abertura }
    amb := sintAmbiente ('SORTEVOX', 'DIRSORTEVOX');
    if amb = '' then
        amb := 'c:\winvox\som\sortevox';
    sintInic (0, amb);
    sintSom('so_abre');

    writeln ('Sortevox, o jogo da sorte');
    writeln ('Digite números de 00 a 99');
    writeln ('Tecle ESC para sair');
    sintSom('so_sorte');

    { loop para não sair do jogo. }

    randomize;
    while true do
        begin
            { criando variavel para pegar o número aleatório. }
            buscado := random (100);
            conte := 0;

            { looping para adivinhar o número. }
              jogando := true;
              while jogando do
                  begin
                      numero := 0; // limpa variavel

                    { sons das perguntas do jogo. }
                      sintSom ('so_plim');
                      writeln;
                      x := wherex;
                      y := wherey;
                      repeat
                          s := '';
                          gotoxy (x, y);
                          sintSom ('so_senha');
                          write ( 'Qual é o número?  ');
                          c := sintEdita(s, wherex, wherey, 2, true);
                          writeln (s);
                          if (c = ENTER) and (s = '') then c := ' ';
                      until (c = ENTER) or (c = ESC);

                    { saindo do jogo.}
                      IF c = ESC then
                            begin
                                writeln;
                                while keypressed do readkey;
                                sintSom ('so_bomba');
                                writeln ('Desistiu!!!');
                                write ('O número era ', buscado);
                                sintSom ('so_fimjo');
                                falaNumeroConv (numeroParaString (buscado), 0);
                                delay (1000);
                                writeln;
                                writeln;
                                writeln ('Tente sempre a sua sorte');
                                writeln ('Estou aqui te esperando...');
                                writeln ('Tchau');
                                sintSom ('so_fim');

                                sintFim;
                                donewincrt;
                            end
                        else
                            numero := strToInt (s);

                    { somando mais uma vez nas tentativas.}
                                conte := conte + 1;

                    { verificando se o número é menor.}
                        if numero > buscado then
                            begin
                                writeln ('O número é menor...');
                                sintSom ('so_ria');
                                sintSom ('so_menor');
                                continue;
                            end;

                    { verificando se o número é maior.}
                        if numero < buscado then
                            begin
                                writeln ('O número é maior...');
                                sintSom ('so_ria');
                                sintSom ('so_maior');
                                continue;
                            end;

                    { verificando se o número certo é o primeiro digitado.}
                        jogando := false;
                        if conte = 1 then
                            begin
                                limpaBufTec;
                                writeln ('PARABÉNS!  Acertou na primeira!');
                                sintSom ('so_aplau');
                                sintSom ('so_1vez');
                            end
                        else
                            begin
                                limpaBufTec;
                                writeln ('Parabéns, cara, você acertou!');
                                sintSom ('so_aplau');
                                writeln  ('Você fez ', conte, ' tentativas');
                                sintSom ('so_certo');
                                falaNumeroConv (numeroParaString (conte), 1);
                                sintSom ('so_tenta');
                                writeln;
                            end;
                  end;
        end;
end.



