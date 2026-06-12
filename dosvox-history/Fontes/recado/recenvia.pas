{--------------------------------------------------------}
{                                                        }
{    Programa de envio e recepção de recados             }
{                                                        }
{    Módulo de envio de recados                          }
{                                                        }
{    Autor: José Antonio Borges                          }
{                                                        }
{    Em novembro/2014                                    }
{                                                        }
{--------------------------------------------------------}

unit recenvia;

interface
uses windows, classes, sysutils,
     dvcrt, dvwin, dvForm, dvGrav, dvwav, dvdigitexto,
     recvars, recmsg, recSmtp, lame_export;

procedure enviarRecadoFalado (destinatario: string);
procedure enviarRecadoTextual (destinatario: string);
procedure enviaPendentes;

implementation

{--------------------------------------------------------}

function entraDestinatario: string;
var c: char;
    i, p: integer;
    destinatario: string;
    salvay: integer;
    sl: TStringList;
    nomeArqApelidos: string;
label fim;
begin
    destinatario := '';
    salvay := wherey+1;

    mensagem ('RCINFDST', 1); {'Informe o email do destinatário ou use as setas:'}
    c := sintEdita (destinatario, wherex, wherey, 255, true);
    destinatario := trim(destinatario);

    if (destinatario <> '') and (copy (destinatario, 1, 1) <> '*') then
        if (c = ESC) or (c = ENTER) then
            begin
                writeln (destinatario);
                result := destinatario;
                exit;
            end;

    writeln;
    nomeArqApelidos := sintAmbiente ('CARTAVOX', 'APELIDOS');
    if nomeArqApelidos = '' then
        nomeArqApelidos := 'c:\winvox\apelidos.ini';
    sl := TStringList.Create;
    sl.LoadFromFile(nomeArqApelidos);
    for i := sl.count-1 downto 0 do
        begin
            sl[i] := trim (sl[i]);
            if (sl[i] = '') or
               (sl[i][1] = '[') or
               (sl[i][1] = ';') or
               (sl[i][1] = '*') then  sl.Delete(i);
        end;
    sl.sort;

    opcoesCria(wherex, wherey, 80);
    for i := 0 to sl.count-1 do
        begin
            p := pos ('=', sl[i]);
            if p = 0 then
                 opcoesAdiciona('', sl[i])
            else
                 opcoesAdiciona('', copy (sl[i], 1, p-1));
        end;
    i := opcoesSeleciona - 1;
    if i < 0 then
        begin
            result := '';
            goto fim;
        end;

    p := pos ('=', sl[i]);
    if p = 0 then
        result := sl[i]
    else
        result := copy (sl[i], p+1, 999);

fim:
    gotoxy (1, salvay);
    limpabaixo;
    if result <> '' then
        writeln (result);
    writeln;
end;

{--------------------------------------------------------}

procedure enviarRecadoFalado (destinatario: string);
var
    nomeArqTemp, nomeArqTxtTemp, nomeArqMP3Temp: string;
    c: char;
    erroConv: integer;
    texto: TStringList;
    saveCompact: boolean;
begin
    {$i-}  chdir (dirRecados);   {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RCDIRNAO', 2);    {'Diretório de recados não está configurado ou não existe.'}
            exit;
        end;

    if destinatario = '' then
        destinatario := entraDestinatario;
    if destinatario = '' then
        exit;

    mensagem ('RCENTINI', 1);   {'Aperte Enter para gravar, Enter de novo termina.'}
    nomeArqTemp := pegaNomeArqTemp ('WAV');

    repeat
        c := readkey;
        if c = ESC then
            begin
                mensagem ('RCDESIST', 1);   {'Desistiu...'}
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

    mensagem ('RCESCUTA', 0);  {'Quer escutar o recado? '}
    c := popupMenuPorLetra('SN');
    writeln;
    if upcase (c) = 'S' then
        begin
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

    if c = ESC then
        begin
            mensagem ('RCGRVCAN', 1);   {'Gravação cancelada'}
            deleteFile (nomeArqTemp);
            exit;
        end;

    nomeArqMP3Temp := nomeArqTemp;
    delete (nomeArqMP3Temp, length(nomeArqMP3Temp)-3, 4);
    nomeArqMP3Temp := nomeArqMP3Temp + '.MP3';

    erroConv := EncodeWavToMP3(nomeArqTemp, nomeArqMP3Temp, 56);
    if erroConv <> 0 then
        begin
           mensagem ('RCPRBMP3', 0);  {'Problema ao converter para MP3, código: '}
           sintWriteln (intToStr(erroConv));
           writeln;
           exit;
        end;

    deleteFile (nomeArqTemp);   // arquivo .wav não é mais necessário

    mensagem ('RCAGRTXT', 0);  {'Deseja agregar uma anotação escrita? '}
    c := popupMenuPorLetra ('SN');
    writeln;

    if upcase(c) <> 'S' then
        nomeArqTxtTemp := ''
    else
        begin
            mensagem ('RCDIGTXT', 1);   {'Digite o texto que deseja enviar como recado.'}
            mensagem ('RCFIMESC', 1);   {'Ao final tecle ESC'}
            writeln ('------------------------------------------------------------------------------');

            texto := TStringList.Create;
            nomeArqTxtTemp := pegaNomeArqTemp ('TXT');
            digiTexto(texto, true, wherex, wherey, 80, 23-wherey, BLACK, WHITE, YELLOW, GREEN, nomeArqTxtTemp, false, 1);
            texto.SaveToFile(nomeArqTxtTemp);
        end;

    if enviaRecadoSMTP (nomeArqTxtTemp, nomeArqMP3Temp, destinatario) then
        mensagem ('RCENVIAD', 1)    {'Recado enviado.'}
    else
        mensagem ('RCNENVIA', 1);   {'Recado não foi enviado.'}

    while sintFalando do waitMessage;
    delay (1000);
end;

{--------------------------------------------------------}

procedure enviarRecadoTextual (destinatario: string);
var
    nomeArqTxtTemp: string;
    texto: TStringList;
begin
    if destinatario = '' then
        destinatario := entraDestinatario;
    if destinatario = '' then
        exit;

    mensagem ('RCDIGTXT', 1);   {'Digite o texto que deseja enviar como recado.'}
    mensagem ('RCFIMESC', 1);   {'Ao final tecle ESC'}
    writeln ('------------------------------------------------------------------------------');

    texto := TStringList.Create;
    nomeArqTxtTemp := pegaNomeArqTemp ('TXT');
    digiTexto(texto, true, wherex, wherey, 80, 23-wherey, BLACK, WHITE, YELLOW, GREEN, nomeArqTxtTemp, false, 1);
    texto.SaveToFile(nomeArqTxtTemp);

    if enviaRecadoSMTP (nomeArqTxtTemp, '', destinatario) then
        mensagem ('RCENVIAD', 1)    {'Recado enviado.'}
    else
        mensagem ('RCNENVIA', 1);   {'Recado não foi enviado.'}
end;

{--------------------------------------------------------}

procedure enviaPendentes;
var contador: integer;
    sr: TSearchRec;
    FileAttrs: Integer;
    nomeArqTxtTemp: string;
begin
    contador := 0;
    FileAttrs := faArchive;
    if FindFirst('*.CPR', FileAttrs, sr) = 0 then
        repeat
            nomeArqTxtTemp := sr.FindData.cFileName;
            if enviaSMTP(nomeArqTxtTemp) then
                renameFile (nomeArqTxtTemp, ExtractFileName(nomeArqTxtTemp)+'.ENV');

        until FindNext(sr) <> 0;
    FindClose(sr);
end;

end.

