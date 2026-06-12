unit mgVars;

interface

uses grAmost;

const
    VERSAO = '4.0c';
    TIPOVERSAO = '';

    {---- fatores usados na aplicação do eco e reverberação ----}

    DEF_DIST_ECO = 3000;
    DEF_FATOR_ECO = 75;
    DEF_DIST_REVERB = 2000;
    DEF_FATOR_REVERB = 80;

    {---- número de buffers para tocar e gravar ----}

    DEF_BUFTOCA = 4;
    DEF_BUFGRAVA = 4;

var
    sox_Existe: boolean; //False quando sox.exe não for encontrado

    nomeArq, nomeArq1: string;
    ArqTemp1: string;
    ArqTemp2: string;
    dirTrab: string;
    qualidade: string;
    ramostra: integer;
    x: integer;
    cursor: integer;
    marca: integer;
    dirSox: String;

    som: TAmostras;


    nbufToca, nbufGrava: integer;

    dist_eco: integer;
    fator_eco: integer;
    dist_reverb: integer;
    fator_reverb: integer;
    maxMemoria: integer;

    {---- parametros para acesso ao ffmpeg ----}

    progFfmpeg: shortString;

    {---- processamento de undo ----}

    novoNome: string;
    temp: Integer = 1;

implementation

end.
