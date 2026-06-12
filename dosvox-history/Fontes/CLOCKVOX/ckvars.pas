Unit ckvars;

interface

uses windows;

const
    versao = '1.2c';
    MAX_EVENTOS = 50;

type
    reg= record
        dia_b, mes_b, ano_b: word;
        hora_b, minuto_b: word;
        execDia_b: string [80];
        diaSemana_b: word;
        frase_b, programa_b, arquivo_b: string [80];
        sinal_b: integer;
    end;

const
    enter= #13;
    esc= #27;
    espaco= #32;
    cima= #72;
    baixo= #80;
    F1= #59;
    F8= #66;

var
    arq, arq_tmp: file of reg;
    x: reg;
    dia_m, mes_m, ano_m: array [0..MAX_EVENTOS] of word;
    hora_m, minuto_m: array [0..MAX_EVENTOS] of word;
    execDia_m: array [0..MAX_EVENTOS] of string[80];
    diaSemana_m: array [0..MAX_EVENTOS] of word;
    frase_m, programa_m, arquivo_m: array [0..MAX_EVENTOS] of string[80];
    sinal_m: array [0..MAX_EVENTOS] of integer;
    execAtrib: array [0..MAX_EVENTOS] of boolean;
    indice: integer;
    numEvento, numDia: integer;
    ano, mes, dia, sem: word; {GETDATE}
    hora, minuto, segundo, cents: word; {GETTIME}
    start, falaJanela, sairLoop: boolean;
    numeroRegistros: integer;
    nomeProg, nomeDir, nomeArq: string[80];
    meuNome: array [0..100] of char;
    dataString: string [20];
    horaString: string[10];
    senha: string[8];
    nomeDat, nomeTemp: string;
    commandCom: string;

implementation

end.
