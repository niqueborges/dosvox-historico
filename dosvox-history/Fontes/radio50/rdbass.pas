{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Módulo de execução da rádio pela BASS.DLL           }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdBass;

interface
uses
    windows, dvcrt, dvwin, dvHora, sysutils, classes, bass, bass_aac, basshls,
    rdGravar,
    rdAjuda,
    rdMsg, rdDownld;

function  inicBass: boolean;
procedure fimBass;
procedure mudaVolumeBass;
function  tocaRadioBass (nomeRadio, linkRadio: string): integer;

implementation

type
    TIcy_attrib = record
        titulo: string;
        imagem: string;
        bitrate: string;
        genero: string;
        nome: string;
        nota1: string;
        nota2: string;
        pub: string;
        url: string;
        metaint: string;
    end;

var
    Proxy: array [0..99] of AnsiChar; //proxy server
    atributos: TIcy_attrib;
    titAntigo: string;

{--------------------------------------------------------}
{        inicializa as características da stream
{--------------------------------------------------------}

procedure inicParamTransm;
begin
    with atributos do
        begin
            titulo := '';
            imagem := '';
            bitrate := '';
            genero := '';
            nome := '';
            nota1 := '';
            nota2 := '';
            pub := '';
            url := '';
            metaint := '';
        end;
end;

{--------------------------------------------------------}
{           mostra as características da stream
{--------------------------------------------------------}

procedure mostraParamTransm (tituloPadrao: string);
begin
    with atributos do
        begin
            if titulo <> '' then
                sintWriteln ('Título:  ' + titulo)
            else
                sintWriteln ('Título:  ' + tituloPadrao);
            if imagem  <> '' then   sintWriteln ('Imagem:  ' + imagem);
            if bitrate <> '' then   sintWriteln ('Taxa:    ' + bitrate);
            if genero  <> '' then   sintWriteln ('Gênero:  ' + genero);
            if nome    <> '' then   sintWriteln ('Nome:    ' + nome);
            if nota1   <> '' then       writeln ('Obs1:    ' + nota1);
            if nota2   <> '' then       writeln ('Obs2:    ' + nota2);
            if pub     <> '' then   sintWriteln ('Pub:     ' + pub);
            if url     <> '' then       writeln ('URL:     ' + url);
            if metaint <> '' then   sintWriteln ('Metaint: ' + metaint);
        end;
end;

{--------------------------------------------------------}
{           inicializa a biblioteca BASS.DLL
{--------------------------------------------------------}

function inicBass: boolean;
begin
    if (not BASS_Init(-1, 44100, 0, crtWindow, nil)) then
        begin
            mensagem ('RDERRBAS', 2);  {'Não consegui inicializar o dispositivo na BASS.DLL'}
            result := false;
        end
    else
        begin
            BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1);
            BASS_SetConfig(BASS_CONFIG_NET_PREBUF, 0);
            BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY, @proxy[0]);
            result := true;
        end;
end;

{--------------------------------------------------------}
{           libera a biblioteca BASS.dll
{--------------------------------------------------------}

procedure fimBass;
begin
    BASS_Free;
end;

{--------------------------------------------------------}
{                     altera o volume
{--------------------------------------------------------}

procedure mudaVolumeBass;
var
    s: string;
    n, erro: integer;
    vol: dword;
begin
    vol := BASS_getconfig(BASS_CONFIG_GVOL_STREAM);
    mensagem ('RDVOLATU', 0);   {'Volume atual: '}
    sintWriteln (intToStr ((vol+1) div 100));

    mensagem ('RDQUEVOL', 0);   {'Qual o volume de 1 a 100? '}
    sintReadln (s);
    val (s, n, erro);
    if erro <> 0 then
        sintBip
    else
        begin
            if n < 1 then n := 1;
            if n > 100 then n := 100;
            vol := n * 100;
            BASS_setconfig(BASS_CONFIG_GVOL_STREAM, vol);
        end;
end;

{--------------------------------------------------------}
{                     captura meta dados
{--------------------------------------------------------}

procedure capturaMeta (chan: HSTREAM);
var
    meta: PAnsiChar;
    p, p2: Integer;
    s: string;
begin
    meta := BASS_ChannelGetTags(chan, BASS_TAG_META);
    if meta <> NIL then
        begin
            s := String(AnsiString(meta));

            p := pos('StreamTitle=', s);
            if p = 0 then exit;
            p := p + 13;
            p2 := pos (';', s);
            atributos.titulo := UTF8ToAnsi (copy (s, p, p2-p-1));
            delete (s, 1, p2);

            p := pos('StreamUrl=', s);
            if p = 0 then exit;
            p := p + 11;
            p2 := pos (';', s);
            atributos.imagem := UTF8ToAnsi (copy (s, p, p2-p-1));
        end;
end;

{--------------------------------------------------------}
{                     callbacks
{--------------------------------------------------------}

procedure MetaSync(handle: HSYNC; channel, data: DWORD; user: Pointer); stdcall;
begin
    capturaMeta (channel);
end;

procedure StatusProc(buffer: Pointer; len: DWORD; user: Pointer); stdcall;
begin
//    if (buffer <> nil) and (len = 0) then
//       writeln (PChar(buffer));
end;

{--------------------------------------------------------}
{               analisa e guarda os dados ICY
{--------------------------------------------------------}

procedure guardaAtributoICY (s: string);
var ls: string;
    p: integer;
begin
    ls := lowercase(s);
    p := pos(':', s)+1;
    with atributos do
        begin
            if copy(s, 1, 6) = 'icy-br' then
                bitrate := copy(s, p, 999)
            else
            if copy(s, 1, 9) = 'icy-genre' then
                genero := copy(s, p, 999)
            else
            if copy(s, 1, 11) = 'icy-notice1' then
                nota1 := copy(s, p, 999)
            else
            if copy(s, 1, 11) = 'icy-notice2' then
                nota2 := copy(s, p, 999)
            else
            if copy(s, 1, 6) = 'icy-pub' then
                pub := copy(s, p, 999)
            else
            if copy(s, 1, 6) = 'icy-url' then
                url := copy(s, p, 999)
            else
            if copy(s, 1, 6) = 'icy-metaint' then
                metaint := copy(s, p, 999);
        end;
end;

{--------------------------------------------------------}
{               Conecta a stream de rádio
{--------------------------------------------------------}

function conectaRadio (nomeRadio: string; var chan: HSTREAM; falando: boolean): integer;
var
    url: PAnsiChar;
    icy: PAnsiChar;
    Len, Progress: DWORD;
    s: string;
begin
    url := pchar (nomeRadio);
    Result := 0;

    progress := 0;
    if sintFalarTudo and falando then
        mensagem ('RDTNTCNX', 1);   {'Tentando conexão'}

    if chan <> 0 then
        BASS_StreamFree(chan);

    chan := BASS_StreamCreateURL(url, 0,
            BASS_STREAM_BLOCK or BASS_STREAM_STATUS or BASS_STREAM_AUTOFREE,
            @StatusProc, NIL);

    if (chan = 0) then
        chan := BASS_AAC_StreamCreateURL(url, 0,
            BASS_STREAM_BLOCK or BASS_STREAM_STATUS or BASS_STREAM_AUTOFREE,
            @StatusProc, NIL);

    if (chan = 0) then
        chan := BASS_HLS_StreamCreateURL(url,
            BASS_STREAM_BLOCK or BASS_STREAM_STATUS or BASS_STREAM_AUTOFREE,
            @StatusProc, NIL);

    if (chan = 0) then
        begin
            result := Bass_ErrorGetCode();
            exit;
        end;

    if sintFalarTudo and falando then
        mensagem ('RDOK', 2);  {'OK!'}

    // espera pelo menos 75% preenchido (ou o fim do download)
    repeat
        len := BASS_StreamGetFilePosition(chan, BASS_FILEPOS_END);
        if (len = DW_Error) then
            break;
        progress := BASS_StreamGetFilePosition(chan, BASS_FILEPOS_BUFFER) * 100 div len;
    until (progress > 75) or
          (BASS_StreamGetFilePosition(chan, BASS_FILEPOS_CONNECTED) = 0);

    // pega o nome da transmissão e o bitrate (entre outros)
    icy := BASS_ChannelGetTags(chan, BASS_TAG_ICY);
    if (icy = NIL) then
        icy := BASS_ChannelGetTags(chan, BASS_TAG_HTTP);
    if (icy <> NIL) then
        while (icy^ <> #0) do
            begin
                s := strPas(icy);
                guardaAtributoICY(s);
                icy := icy + Length(icy) + 1;
            end;

    // Pega o título da stream, preparando para sincronizar os títulos seguintes
    capturaMeta(chan);
    BASS_ChannelSetSync(chan, BASS_SYNC_META, 0, @MetaSync, nil);

    // inicia a thread de captura e execução
    BASS_ChannelPlay(chan, FALSE);
end;

{--------------------------------------------------------}
{     ajusta a lista de programas segundo o formato
{--------------------------------------------------------}

procedure ajustaStringList (ext: string; var listaProgramas: TStringList);
var i: integer;
    s: string;
begin
    if ext = '.M3U' then
        begin
            for i := listaProgramas.count-1 downto 0 do
                begin
                    listaProgramas[i] := trim(listaProgramas[i]);
                    if (listaProgramas[i] = '') or (listaProgramas[i][1] = '#') then
                        listaProgramas.Delete(i);
                end;
        end
    else
        begin   // PLS
            for i := listaProgramas.count-1 downto 0 do
                begin
                    s := trim (listaProgramas[i]);
                    if uppercase(copy (s, 1, 4)) = 'FILE' then
                        begin
                            delete (s, 1, pos('=', s));
                            listaProgramas[i] := s;
                        end
                    else
                        listaProgramas.Delete(i);
                end;
        end;
end;

{--------------------------------------------------------}
{                     interação
{--------------------------------------------------------}

function interage (nomeRadio, url: string): integer;
var
    chan: HSTREAM;
    processando, progParado, pausado, falando: boolean;
    c: char;
    status: integer;
    listaProgramas: TStringList;
    nomePrograma, nomeReduzido, ext: string;
    nprog: integer;

    {--------------------------------------------------------}

    procedure pulaProgramacao (n: integer);
    begin
        BASS_StreamFree(chan);
        nprog := n;
        if nprog < 0 then
            nprog := 0;
        progParado := true;
    end;

    {--------------------------------------------------------}

    function exibeNomeReduzido (nomePrograma: string): string;
    var p: integer;
    begin
        limpabaixo (5);
        nomePrograma := trim (nomePrograma);
        p := lastDelimiter('/', nomePrograma);
        if p <> 0 then
            nomeReduzido := copy (nomePrograma, p+1, 999)
        else
            nomeReduzido := nomePrograma;
        if copy (nomeReduzido, 1, 1) = ';' then
            delete (nomeReduzido, 1, 1);
        nomeReduzido := trim (nomeReduzido);

        textColor(yellow);
        if listaProgramas.Count > 1 then
            writeln (nprog+1, ' - ', nomeReduzido)
        else
            writeln (nomeReduzido);
        textColor(white);

        result := nomeReduzido;
    end;

    {--------------------------------------------------------}

    procedure mostraTitulo;
    var x, y: integer;
    begin
        if titAntigo <> atributos.titulo then
            begin
                x := wherex;
                y := wherey;
                gotoxy (1, 3);
                textColor (CYAN);
                write (atributos.titulo);
                textColor (WHITE);
                clreol;
                titAntigo := atributos.titulo;
                gotoxy (x, y);
            end;
    end;

    {--------------------------------------------------------}

begin
    result := 0;

    listaProgramas := TStringList.Create;

    ext := uppercase(copy (url, length(url)-3, 4));
    if (ext = '.M3U') or (ext = '.PLS') then
        begin
            if BaixaStringList (url, listaProgramas) then
                ajustaStringList (ext, listaProgramas)
            else
                begin
                    listaProgramas.Free;
                    result := 2;    // stream não foi achada
                    exit;
                end;
        end
    else
        listaProgramas.Add (url);

    nprog := 0;
    progParado := true;
    falando := true;
    pausado := false;
    titAntigo := '@#$%';

    limpabaixo(wherey);
    if listaProgramas.Count > 1 then
        begin
            mensagem ('RDNPROG', 0); {'Número de programas: '}
            sintWriteInt (listaProgramas.count);
            writeln;
        end;

    processando := true;
    while processando  do
        begin
            sleep(100);    // economiza bateria de laptops

            if progParado then
                begin
                    if nprog >= listaProgramas.Count then
                        break;    // while processando

                    nomePrograma := listaProgramas[nprog];
                    nomeReduzido := exibeNomeReduzido (nomePrograma);

                    status := conectaRadio (nomePrograma, chan, falando);
                    falando := false;
                    if status <> 0 then
                        begin
                            result := status;
                            break;   // while processando
                        end;

                    pausado := false;
                    progParado := false;
                    titAntigo := '@#$%';
                end;

            while BASS_ChannelIsActive(chan) <> BASS_ACTIVE_STOPPED do
                begin
                    sleep(100);    // permite interação só quando canal ativo
                    if keypressed then
                         break;
                    mostraTitulo;
                end;

            if BASS_ChannelIsActive(chan) = BASS_ACTIVE_STOPPED then
                begin
                    pulaProgramacao(nprog+1);
                    if nprog >= listaProgramas.Count then
                        break;   // while processando
                end;

            if not keypressed then continue;
            c := readkey;
            if c = ENTER then c := '?';
            writeln;

            gotoxy (1, 3);
            clreol;
            limpaBaixo(6);

            if c = #$0 then
                begin
                    case readkey of
                        F8:    falaHora;
                        CTLF8: falaDia;
                        PGUP:  pulaProgramacao(nprog-1);
                        PGDN:  pulaProgramacao(nprog+1);
                        HOME:  pulaProgramacao(0);
                        TEND:  pulaProgramacao(listaProgramas.count-1);
                    else
                        BASS_ChannelPause(chan);
                        pausado := true;
                        ajudaTocaRadioBass;
                    end;
                end
            else
            case upcase(c) of
                ' ': begin
                         pausado := not pausado;
                         if pausado then
                             BASS_ChannelPause(chan)
                         else
                             BASS_ChannelPlay(chan, TRUE);
                     end;

                'N': sintetiza(nomeReduzido);
                'V': mudaVolumeBass;
                'P': mostraParamTransm (nomeReduzido);
                'E': begin
                         mensagem ('RDENDSEL', 1);  {'Endereço selecionado:'}
                         sintWriteln (url);
                     end;
                ^R:  begin
                         result := -1;
                         processando := false;
                     end;
                ^C:  putClipBoard(pchar(nomeRadio + '=' + url));
                'R':  sintetiza (nomeRadio);
                'G':  gravarRadio(url);
                'F': if not finalizarGravacoesRadio then sintBip;
                ESC: processando := false;
            else
                mensagem ('RDOPINV', 1);  {'Opção inválida'}
            end;

        end;   // fim de while processando

    if chan <> 0 then
        begin
            BASS_StreamFree(chan);
            BASS_ChannelStop(chan);
        end;
    chan := 0;
end;

{--------------------------------------------------------}
{      toca a rádio usando a biblioteca BASS.dll
{--------------------------------------------------------}

function tocaRadioBass (nomeRadio, linkRadio: string): integer;
var
    status: integer;
    c: char;
begin
    if nomeRadio <> '' then setwindowtitle(nomeRadio + ' - Radio50');
    inicParamTransm;

    status := interage (nomeRadio, linkRadio);
    limpaBufTec;
    case status of
        0: if sintFalarTudo then mensagem ('RDDESLIG', 2)  {'Rádio desligada.'}
            else writeln (pegaTextoMensagem('RDDESLIG'));  {'Rádio desligada.'}
        2: mensagem ('RDSTNACH', 2);  {'Erro: stream não foi achada'}
        40: mensagem ('RDTIMOUT', 2);  {'Tempo excedido na conexão'}
        41: mensagem ('RDERRFMT', 2);  {'Erro: este formato de stream não é suportado'}
    else
        mensagem ('RDERSTAT', 0);     {'Erro: status: '}
        sintWriteln (intToStr(status));
    end;

    finalizarGravacoesRadio;

    if status <> 0 then
        begin
            mensagem ('RDAPTENT', 1);  {'Aperte enter...'}
            repeat
                c := readkey;
                if c = ^R then
                    status := -1;
            until (c = ENTER) or (c = ESC) or (c = ^R);
        end;

    setwindowtitle('Radio50');

    result := status;
end;

end.
