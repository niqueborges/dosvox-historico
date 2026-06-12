{--------------------------------------------------------}
{                  AGENVOX - variáveis
{--------------------------------------------------------}

unit agVars;

interface

const
    VERSAO = '3.4';

    dir_agenda= 'Agenda';
    dir_bloco= 'Agenda\Notas';
    dir_telefones= 'Agenda\Fones';
    dir_entradaDeDadosGastos= 'Agenda\Gastos';
    dir_extratosGerados= 'Agenda\Gastos\Extratos';
    dir_sonsDoDespertador= 'Agenda\Desperta';

var
    hora, min, seg, cent: word;
    dia, mes, ano, sem: word;
    dd, mm, aa: string[4];
    data: shortString;

    linhaCompromisso: array [1..2000] of string[100];
    maxLin: integer;
    nomeDados: string[16];
    usarRelogio: boolean;
    despertaOk, somaDespert: boolean;
    recargaNoVetor: boolean;
    velocidadeDosvox: integer;
    somDespert: string[13];
    dirTrab, dirTrab_bk, dirTemp, funInicial: string;
    iniSelec: char;
    bipaNoSpeaker: boolean;
    jaEscolheuDia, procurandoCompromissos: boolean;
    dbg: string;

implementation

end.
