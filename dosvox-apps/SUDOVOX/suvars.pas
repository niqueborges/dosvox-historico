unit suvars;

interface
uses sysutils;

const
    versao = '1.1';
    arqDefault = 'sudovox.tmp';

var
    sudoku: array [0..8, 0..8] of byte;
    fixo: array [0..8, 0..8] of boolean;
    xcur, ycur: integer;
    horaInicial, horaFinal: TDateTime;
    fimDoJogo: boolean;
    nomeArqTrab, nomeArqSudoku: string;

implementation

end.
