unit cdVars;

interface

const
    versao = '2.5';

var
    dirDosvox, dirTexto, dirBackUp, dirSom, dirScript, dirCopia: string;
    velocidadeDOSVOX, confTipoSapi, confNum, confVeloc, confTonal: integer;
    nomearqTxt: array [0..999] of string;
    numArqs, numLinhas: integer;
    semArqTxt, semArqPar: boolean;
    geraMp3: boolean;
    sapiOK, alterouSAPI: boolean;
    qualidaMP3, qBaixa, qAlta, qMaxima: string;
    unidadeCD: string;
    remTotArqs, remDinamic: boolean;
    geraAuto, geraNovoDir: boolean;
    informa_avisos, introduz_silencio, introduz_efeito, introduz_cabec: boolean;
    nomeEfeitoWav, nomeBackUpWav: string;
    progLame: shortString;

    ativouComSapi, formatEsp: boolean;
    tipEsp, numEsp, velEsp, tonEsp: integer;

implementation

begin
end.
