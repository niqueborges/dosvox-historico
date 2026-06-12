{ mostra os nomes dos sons num difones.dif, e sua posição neste arquivo }
{ Autor: Antonio Borges }

program varredifones;
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
    writeln ('Qual o nome do arquivo de índices? (por exemplo, DIFONES2.IND)');
    readln (nomeArq);
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
            writeln (nomeDifo:8, tamdifo:8, posdifo:8);

    readln;
end.
