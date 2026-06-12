{--------------------------------------------------------}
{
{    Cartavox - Correio Eletrônico do Dosvox
{
{    Módulo de gravação de recados
{
{    Autor: Neno Henrique daCunha Albernaz
{
{    Retirado do original de autoria de José Antonio Borges

{    Em Abril /2015
{
{--------------------------------------------------------}

unit carRecad;

interface

uses
    windows,
    sysutils,
    dvcrt,
    dvwin,
    dvForm,
    dvGrav,
    dvwav,
    carMsg,
    carUtil,
    carVars,
    lame_export;

function gravaRecadoFalado: string;

implementation

{--------------------------------------------------------}

function pegaNomeArqTemp (ext: string): string;
var
    tempPath: array [0..144] of char;
    tempFileName: array [0..144] of char;
    s, s2: string;
begin
    getTempPath (144, tempPath);
    s := strPas (tempPath);

    if trim (nomeUsuario) <> '' then s2 := nomeUsuario
    else s2 := copy(enderUsuario, 1, pos ('@', enderUsuario));
    s := s + '\RECADO de ' + s2 + ' gravado em ' + pegaAnoMesDia(true) +' às ' + pegaHoraMinuto(true) + '.' + ext;
    strPCopy (tempFileName, s);
    result := strPas (tempFileName);
end;

{--------------------------------------------------------}

function gravaRecadoFalado: string;
var
    nomeArqTemp, nomeArqMP3Temp: string;
    c: char;
    erroConv: integer;
    saveCompact: boolean;

label tocarNovamente;
begin
    gravaRecadoFalado := '';

    msgBaixo ('CTENTINI');   {'Aperte Enter para gravar, Enter de novo termina.'}
    nomeArqTemp := pegaNomeArqTemp ('WAV');

    repeat
        c := readkey;
        if c = ESC then
            begin
                msgBaixo('CTDESIST');   {'Desistiu...'}
                exit;
            end;
    until c = ENTER;
    writeln;

    preparaGravacao(nomeArqTemp, 22050, 16, 1, 8, 8192);
    iniciaGravacao;
    c := 'x';
    repeat
        delay (100);
        monitoraGravacao;
        if keypressed then
            c := readkey;
    until (c = Enter) or (c = ESC);
    terminaGravacao;

    repeat
        mensagem ('CTESCUTA', 1);  {'Quer escutar o recado? '}
        c := upcase(popupMenuPorLetra ('SN'));
        writeln;
    until c in ['S', 'N', ENTER, ESC];

    if c = 'S' then
        begin
tocarNovamente:
            saveCompact := compactWaves;
            compactWaves := false;

            wavePlayFile (nomeArqTemp);
            while waveIsPlaying do
                if keypressed then
                    begin
                        waveStop;
                        while keypressed do
                            c := readkey;
                        break;
                    end;

            compactWaves := saveCompact;
        end;

    if c <> ESC then
        repeat
            mensagem ('CTANESOM', 1);  {'Tecle A para anexar ou ESC para cancelar'}
            c := upcase(popupMenuPorLetra ('AN'));
            writeln;
        until c in ['A', 'N', ENTER, ESC];

    if c in ['N', ESC] then
        begin
            msgBaixo ('CTGRVCAN');   {'Gravação cancelada'}
            deleteFile (nomeArqTemp);
            exit;
        end;

    nomeArqMP3Temp := nomeArqTemp;
    delete (nomeArqMP3Temp, length(nomeArqMP3Temp)-3, 4);
    nomeArqMP3Temp := nomeArqMP3Temp + '.MP3';

    erroConv := EncodeWavToMP3(nomeArqTemp, nomeArqMP3Temp, 56);
    if erroConv <> 0 then
        begin
            mensagem ('CTPRBMP3', 0);  {'Problema ao converter para MP3, código: '}
            sintWriteln (intToStr(erroConv));
            writeln;
            exit;
        end;

    deleteFile (nomeArqTemp);   // arquivo .wav não é mais necessário

    gravaRecadoFalado := nomeArqMP3Temp;
end;

begin
end.
