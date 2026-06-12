{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Rotinas de gravação da rádio
{                                                        }
{    Autor:  Neno Henrique da Cunha Albernaz
{                                                        }
{    Em Dezembro/2021                                     }
{                                                        }
{--------------------------------------------------------}

unit rdGravar;

interface
uses
    dvcrt,
    dvwin,
    Windows,
    dvexec,
//    dvForm,
//    dvHora,
    dvAmplia,
    sysUtils,
//    rdPipeEx,
//    rdVars,
//    classes,
    rdmsg;

procedure gravarRadio (url: string);
function  finalizarGravacoesRadio: boolean;

implementation

var gravandoRadio: boolean = false;

{--------------------------------------------------------}
{         grava o áudio com o ffmpeg em um arquivo de saida padrão.
{--------------------------------------------------------}

procedure gravarRadio (url: string);
var
    dirDosvox, dirGravacao, nomeArq: string;
    erro: integer;
    modoJanela: integer;
    janelaGravacaoAparente: boolean;
begin
    if gravandoRadio then
        begin
            sintbip;
            mensagem ('RDJAGRAVANDO', 1); {Rádio já gravando'}
            sintbip;
            exit;
        end;

    dirDosvox := sintAmbiente('DOSVOX', 'PGMDOSVOX', 'C:\Winvox');
    if dirDosvox[length(dirDosvox)] <> '\' then dirDosvox := dirDosvox + '\';
    dirGravacao := sintAmbiente('RADIO50', 'DIRGRAVACAO', copy(dirDosvox, 1, 3) + 'RadiosGravadas');
    while pos(' ', dirGravacao) <> 0 do dirGravacao[pos(' ', dirGravacao)] := '-';

    if not DirectoryExists (dirGravacao)  then
        begin
            {$I-}  mkdir (dirGravacao);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('RDDIRNCRI', 1); {'Não consegui criar o diretório destino da gravação.'}
                    exit;
                end;
        end;

    if dirGravacao[length(dirGravacao)] <> '\' then dirGravacao := dirGravacao + '\';
    nomeArq := dirGravacao + 'R50G' + formatdatetime('YYYY-MM-DD',now) + 'H' + formatdatetime('HH-MM-SS',now) + '.mp3';

    janelaGravacaoAparente := upcase(sintAmbiente ('RADIO50', 'JANELAGRAVACAOAPARENTE', 'NAO')[1]) = 'S';
    if janelaGravacaoAparente then
        modoJanela := SW_SHOWNORMAL
    else
        modoJanela := sw_hide;

    erro := executaProgEx (dirDosvox + 'ffmpeg.exe', dirDosvox, '-i "' + url + '" ' + nomeArq, modoJanela);
    if erro < 32 then
        begin
            if erro = 2 then
                begin
                    mensagem ('RDPRGNAOENC', 0);        { 'Programa não encontrado ' }
                    sintWriteLn (dirDosvox + 'ffmpeg.exe');
                end
            else
                begin
                    mensagem ('RDERROPRGCOD', 0);  { 'Erro na execução do programa: código ' }
                    sintWriteInt (erro); writeln;
                end;
            writeln;
            exit;
        end;

    sintBip;
    writeln;
    mensagem ('RDGRAVANDO', 1); {'Gravando'}
    if janelaGravacaoAparente then
        mensagem ('RDTEALTF4', 1) {'Tecle Alt + F4 para finalizar a gravação'}
    else
        mensagem ('RDESCPAGRA', 1); {'Tecle ESC para finalizar a gravação'}
    writeln;
    sintBip;

    gravandoRadio := not janelaGravacaoAparente;
end;

{--------------------------------------------------------}
{       Finaliza a gravação se estiver gravando: gravandoRadio = true
{--------------------------------------------------------}

function finalizarGravacoesRadio: boolean;
begin
    result := false;
    if not gravandoRadio then exit;
    gravandoRadio := false;
    if executaProg ('taskkill', '', '/f /im ffmpeg.exe') < 32 then exit;
    sintbip;
    mensagem ('RDFIMGRA', 1);   {'Fim da gravação'}
    sintbip;

    result := true;
end;

{--------------------------------------------------------}

begin
end.
