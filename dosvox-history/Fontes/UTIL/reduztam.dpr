{ Altera o arquivo difones.ind, para refletir a variação do arquivo difones.dif }
{ Autor: Antonio Borges }
{ Modificado em 2010 a partir de um programa criado em 1994 }

program reduzTam;
uses dvcrt;

type
    INFODIFONE = packed record
        nomedifo: string[8];
        tamdifo: word;
        posdifo: longint;
    end;

    TABDIFONES = array [0..2000] of INFODIFONE;

var
    tabDifo: ^TABDIFONES;
    posFinal, tamTabDifo, i: integer;
    dirDifones: string;
    arqIndice: file;
    nomeArq: string;
    fator: real;

begin
    writeln ('Qual o nome do arquivo IND a criar? (por exemplo, DIFONES5.IND)');
    readln (nomeArq);
    writeln ('Qual o fator de ampliação do arquivo DIFONES.DIF?');
    writeln ('Por exemplo, digite 0.5 caso o DIFONES.DIF teve seu tempo reduzido à metade: ');
    readln (fator);

    dirDifones := '\winvox\som\difones\';
    assign (arqIndice, dirDifones + 'DIFONES.IND');
    reset (arqIndice, 1);

    tamTabDifo := filesize (arqIndice) div sizeof (INFODIFONE);
    getMem (tabdifo, filesize (arqIndice));
    blockread (arqIndice, tabdifo^, filesize (arqIndice));
    close(arqIndice);

    posFinal := 0;
    for i := 0 to tamTabDifo-1 do
        with tabDifo^[i] do
            begin
                posdifo := trunc (posdifo * fator);
                tamdifo := trunc (tamdifo * fator)-1;
                if posdifo > tabDifo^[posFinal].posDifo then
                    posFinal := i;
            end;

    with tabDifo^[posFinal] do
        writeln ('Tamanho maximo: ', posDifo+tamDifo+1);

    assign (arqIndice, dirDifones + nomeArq);
    rewrite (arqIndice, 1);
    blockwrite (arqIndice, tabdifo^, tamTabDifo * sizeOf (INFODIFONE));
    close(arqIndice);
     
    readln;
end.
