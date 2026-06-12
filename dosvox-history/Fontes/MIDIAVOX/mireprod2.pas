unit mireprod;
interface

uses
  windows,
  mmsystem,
  SysUtils,
  classes,
  DvCrt,
  DvHora,
  DvForm,
  DvWin,
  DvArq,
  mimsg,
  miLegendas,
  miAudio,
  mivars;

procedure inicializaReprod;
function AcionaTocador: String;
procedure mostraStatus(nomeMidia, status, tempo: String; falando: boolean);
Function EnviaComandoMCI (cmd : string): longint;
function pegaRetornoMci: longint;
function comandosMCI(nomeMidia, comando: String): boolean;

var
    marcadores: TStringList;

implementation

var
    brancos: string [80] =  '                                        ' +
                            '                                        ' ;
const
    xIniTela = 1;       {* Linha e Coluna para reprodução de vídeo *}
    yIniTela = 4;
var
    tocandoVideo: boolean;

{--------------------------------------------------------}
{         Inicializa ambiente de reprodução.
{--------------------------------------------------------}

procedure inicializaReprod;
begin
    tocandoVideo := false;
    volumeMidia := MAXVOL;
end;

{--------------------------------------------------------}
{         Verifica se a mídia está tocando
{--------------------------------------------------------}

function isPlaying: boolean;
var
    retorno: array [0..80] of char;
begin

    mciSendString('status midia mode', retorno, 80, 0);
    if retorno = 'playing' then
        result := true
    else
        result := false;
end;

{--------------------------------------------------------}
{          Pega dados do arquivo de mídia
{--------------------------------------------------------}

procedure dadosArquivo(nomeArq: string);

const
    maxTipos = 40;
    tiposArq: array [1..maxTipos] of string = (
        'ADV:Dados do programa Caverna Colossal',
        'ASP:Programa para Activec Server Pages',
        'CMD:Script de comandos para Scriptvox',
        'COM:Programa executável',
        'DOC:Documento do Microsoft Word',
        'DOCX:Documento do Microsoft Word',
        'EXE:Programa executável',
        'FLV:Filme em formato Flash Video',
        'GIF:Arquivo gráfico',
        'HTM:Documento hipertextual para Internet',
        'HTML:Documento hipertextual para Internet',
        'INI:Arquivo de configuração',
        'JPEG:Imagem ou foto',
        'JPG:Imagem ou foto',
        'MID:Música',
        'MP3:Áudio ou música',
        'MPG:Filme',
        'MPEG:Filme',
        'PAG:Arquivo para criação de homepages',
        'PDF:Texto formatado',
        'PLA:Planilha para o programa Planivox',
        'PNG:Gráficos ou imagens',
        'PPS:Apresentações interativas não modificáveis',
        'PPT:Apresentações interativas modificáveis',
        'PY:Programa escrito na linguagem Python',
        'PYW:Programa escrito na linguagem Python para Windows',
        'QST:Questionário automático',
        'RAR:Repositório de arquivos compactados',
        'RM:Áudio no formato Real Media',
        'RAM:Especificação de execução para Real Media',
        'RTF:Texto formatado',
        'TEL:Caderno de telefones do Dosvox',
        'TM3:Texto para geração de MP3',
        'TXT:Texto sem formatação',
        'WAV:Áudio não compactado',
        'WMA:Áudio compactado',
        'WMV:Filme',
        'XLS:Planilha do Microsoft Excel',
        'XLSX:Planilha do Microsoft Excel',
        'ZIP:Repositório de arquivos compactados'
    );

    procedure dadosWav(nomeArq: string);
    var
        soundBuffer: pchar;
        lpFormat: PPCMWAVEFORMAT;
        f: integer;

        Canais, Velocidade, BitsporAmostra: integer;
        size: longint;
        transf: integer;

    label fim;

    begin
        getMem (soundBuffer, 128);

        f := FileOpen(nomeArq, fmOpenRead or fmShareDenyNone);
        if f < 0 then exit;

        transf := fileRead (f, soundBuffer^, 12);     { checa cabeçalho RIFF }
        if transf < 12 then goto fim;
        if strlicomp (soundBuffer, pchar('RIFF'), 4) <> 0 then goto fim;

        transf := fileRead (f, soundBuffer^, 8);      { checa fmt }
        if transf < 8 then goto fim;
        if strlicomp (soundBuffer, 'fmt ', 4) <> 0 then goto fim;

        move (soundBuffer[4], size, 4);
        transf := fileRead (f, soundBuffer^, size);   { checa fmt }
        if size <> transf then goto fim;

        lpFormat := @soundBuffer[0];

        if lpFormat^.wf.wFormatTag <> WAVE_FORMAT_PCM then
            goto fim;    // só processo PCM

        with lpFormat^, lpFormat^.wf do
            begin
                Velocidade := nSamplesPerSec;
                BitsporAmostra := wBitsPerSample;
                Canais := nChannels;
            end;

        freeMem (soundBuffer, 128);
        fileClose (f);

        mensagem('MIINFOVE',0);  {  'Velocidade: ' }
        sintWriteln(intToStr(velocidade));
        mensagem('MIINFOBI',0); {  'Bits por Amostra: ' }
        sintWriteln(intToStr(BitsporAmostra));
        mensagem('MIINFOCA',0);  {  'Canais: ' }
        sintWriteln(intToStr(Canais));

        exit;

    fim:
        fileClose (f);
         mensagem ('MIERRMP3',1); { 'Arquivo não é um WAV legítimo' }
    end;


    procedure dadosMP3(nomeArq: string);
    type
      TID3Rec = packed record
        Tag     : array[0..2] of Char;
        Title,
        Artist,
        Comment: array[0..29] of Char;
        Year    : array[0..3] of Char;
        Album   : array[0..29] of Char;
        Genre   : Byte;
      end;

    const
      MaxID3Genre=147;
      ID3Genre: array[0..MaxID3Genre] of string = (
        'Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge',
        'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B',
        'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska',
        'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient',
        'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical',
        'Instrumental', 'Acid', 'House', 'Game', 'Sound Clip', 'Gospel',
        'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative',
        'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic',
        'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk',
        'Eurodance', 'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta',
        'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American',
        'Cabaret', 'New Wave', 'Psychadelic', 'Rave', 'Showtunes', 'Trailer',
        'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro',
        'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock',
        'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival',
        'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progressive Rock',
        'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band',
        'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson',
        'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus',
        'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba',
        'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle',
        'Duet', 'Punk Rock', 'Drum Solo', 'Acapella', 'Euro-House', 'Dance Hall',
        'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie',
        'BritPop', 'Negerpunk', 'Polsk Punk', 'Beat', 'Christian Gangsta Rap',
        'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian',
        'Christian Rock', 'Merengue', 'Salsa', 'Trash Metal', 'Anime', 'Jpop',
        'Synthpop'  {and probably more to come}
      );

    function c30 (p: pchar): string;
    var s: string;
        i: integer;
    begin
         s := '                              ';
         for i := 0 to 29 do s[i+1] := p[i];
    end;

    var tag: string[3];
        fMP3: file;
        ID3: TID3Rec;
    begin
       AssignFile(fMP3, nomeArq);
       Reset(fMP3, 1);
       if FileSize(fMP3) > 128 then
           begin
               Seek(fMP3, FileSize(fMP3) - 128);
               BlockRead(fMP3, ID3, 128);
               CloseFile(fMP3);
               tag := ID3.Tag[0] + ID3.Tag[1] + ID3.Tag[2];
           end
       else
           tag := '';

       if tag <> 'TAG' then
            mensagem('MINOINFO',1) { 'Informações da música não estão disponíveis' }
       else
           begin
               if trim(ID3.Title) <> '' then
               begin
                    mensagem('MIINFOTI',0); {  'Título: ' }
                    sintWriteln(ID3.Title);
               end;

               if trim(ID3.Artist) <> '' then
               begin
                    mensagem('MIINFOAR',0);  {  'Artista: ' }
                    sintWriteln(ID3.Artist);
               end;

               if trim(ID3.Album) <> '' then
               begin
                    mensagem('MIINFOAL',0);  {  'Álbum: ' }
                    sintWriteln(ID3.Album);
               end;

               mensagem('MIINFOAN',0);  {  'Ano: ' }
               sintWriteln(ID3.Year);

               if ID3.Genre in [0..MaxID3Genre] then
               begin
                     mensagem('MIINFOGE',0); {'Gênero: ' }
                     sintWriteln(ID3Genre[ID3.Genre]);
               end
               else
                     mensagem('MIERRGEN',1);  {  'Gênero: desconhecido'  }
               if trim(ID3.Comment) <> '' then
               begin
                    mensagem('MIINFOCO',0); {  'Comentários: ' }
                    sintWriteln(ID3.Comment);
               end;
           end;
    end;

var sr: TSearchRec;
    ext, ext2, t: string;
    i: integer;
const
    tabNomesDias: array [0..6] of String = ('Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sabado');

begin
    if FindFirst(nomeArq, faAnyFile, sr) = 0 then
        begin
            mensagem('MIINFONO',0); {  'Nome do arquivo: ' }
            sintWriteln(sr.Name);
            mensagem('MIINFOSI',0);  { 'Tamanho do arquivo: '  }
            sintWriteln(IntToStr(sr.Size));

            FindClose(sr);
        end;

    if (fileGetAttr (sr.FindData.cFileName) and faReadOnly) <> 0 then
         mensagem('MIERRPRO',1);     { 'Arquivo está protegido para regravação' }

//    sintWriteln(intToStr(sr.FindData.nFileSizeLow));
//    writeln;

    mensagem('MIINFODT',0); {  'Data de criação: ' }
    sintWriteln (tabNomesDias [dayOfWeek (FileDateToDateTime(sr.Time))]
                        + ' ' + dateToStr(FileDateToDateTime(sr.Time))
                        + ' ' + timeToStr(FileDateToDateTime(sr.Time)));

    ext := ansiUpperCase(extractFileExt(sr.Name));
    delete (ext, 1, 1);
    mensagem ('MIINFOCT',0); {  Conteúdo: '  }
    for i := 1 to maxTipos do
        begin
            t := tiposArq[i];
            ext2 := copy (t, 1, pos(':', t)-1);
            if ext2 = ext then
                break;
        end;

    if i > maxTipos then
         mensagem('MIERRDSC',1)  {  'Desconhecido'  }
    else
         sintWriteln (copy (t, pos(':', t)+1, 999));

    if ext = 'WAV' then dadosWav(nomeArq)
    else
    if ext = 'MP3' then dadosMP3(nomeArq)
    else
    mensagem('MINOINFO',1);  { 'Informações da música não estão disponíveis' }
end;

{--------------------------------------------------------}
{              Informações sobre a mídia
{--------------------------------------------------------}

procedure infoMidia;
begin
    textBackground (BLACK);
    window (1, 5, 48, 25);
    clrscr;
    gotoxy (1, 1);
    dadosArquivo(midiaAtual);
    limpabuftec;
    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}
{               Ajuda do menu da midia
{--------------------------------------------------------}

procedure ajudaControles(falando: boolean);

    procedure msg (som: string; pula: integer);
    begin
        if falando then
            mensagem (som, pula)
        else
            msgMuda (som, pula);
    end;

begin
    if tocandoVideo and not falando then
    begin
        textBackground (BLACK);
        window (1, 5, 80, 25);
        limpabaixo(1);
        window (1, 1, 80, 25);
        exit;
    end;

    textBackground (BLACK);
    window (1, 5, 48, 25);
    limpabaixo(1);

    window (1, 5, 48, 15);
    textBackground (red);
    limpabaixo(1);

    window (1, 1, 80, 25);

    gotoxy (1, 5);
    msg('MIOPCSMM'        , 1);   {'As opções são:'}
    msg('MI_MM_TOCAR'     , 1);   {'    T  - Tocar mídia do início'}
    msg('MI_MM_PAUSAR'    , 1);   {'    P  - Pausar mídia'}
    msg('MI_MM_REPETIR'   , 1);   {'    R  - Repetir ou não a mídia atual'}
    msg('MI_MM_EXIBIR'    , 1);   {'    L  - Exibir lista de reprodução'}
    msg('MI_MM_INFORMA'   , 1);   {'    I  - Informações de tempo e duração'}
    msg('MI_MM_ANTERIOR'  , 1);   {'   CIMA  - Mídia anterior'}
    msg('MI_MM_AVANCAR'   , 1);   {'   BAIXO - Próxima mídia'}
    msg('MI_MM_AUMDIMVOL' , 1);   {' '+'/'-' - Ajusta volume'}
    msg('MI_MM_FINALIZAR' , 1);   {'    F    - Interromper execução' }
    msg('MI_PL_PARAR'     , 1);   {'   ESC   - Terminar'  }

    writeln;

    textBackground (BLACK);
    msg('MI_CTLEXE'       , 1);   {'Controles de execução:'}
    msg('MI_ESPACO'       , 1);   {'    Espaço     - Pausa/retoma reprodução'}
    msg('MI_INFORMA'      , 1);   {'    I          - Informa tempo/duração'}
    msg('MI_DIRESQ'       , 1);   {'    DIR/ESQ    - Avança/Recua'}
    msg('MI_CIMBAI'       , 1);   {'    CIMA/BAIXO - Mídia anterior/seguinte'}
    msg('MI_MAIMEN'       , 1);   {'    '+'/'-'    - Aumenta/Diminui volume'}
    msg('MI_TAB'          , 1);   {'    Tab        - Salta para frente '}
    msg('MI_SHTAB'        , 1);   {'    Shift+Tab  - Salta para trás'}
    limpabuftec;
end;

{--------------------------------------------------------}
{                      Controles
{--------------------------------------------------------}

procedure menuControles (var c1, c2: char);
var
    n: integer;

begin
    window (1, 1, 48, 25);
    limpaBaixo(5);

    window (1, 5, 48, 15);
    textBackground (BLACK);

    msgMuda ('MI_CTLEXE', 1);           {'Controles de execução:'}

    popupMenuCria(4, 2, 45, 9, red);
    menuAdiciona('MI_MM_TOCAR');        {'    T - Tocar mídia do início' }
    menuAdiciona('MI_MM_REPETIR');      {'    R - Repetir música atual' }
    menuAdiciona('MI_MM_INFORMA');      {'    I - Informações de tempo e duração'}
    menuAdiciona('MI_MM_ANTERIOR');     {'   CIMA  - Mídia anterior'}
    menuAdiciona('MI_MM_AVANCAR');      {'   BAIXO - Próxima mídia'}
    menuAdiciona('MI_MM_AUMENTAVOL');   {'   '+'   - Aumenta volume'}
    menuAdiciona('MI_MM_DIMINUIVOL');   {'   '-'   - Diminui volume'}
    menuAdiciona('MI_MM_FINALIZAR');    {'    F    - Interromper execução'   }
//    menuAdiciona('MI_MM_FIMMIDIA');   {'   END - Ir para o final da mídia'}
    menuAdiciona('MI_PL_PARAR');        {'ESC - Terminar'   }

    c1 := #0;
    c2 := #0;
    n := popupMenuSeleciona;
    case n of
        1: c1 := 'T';
        2: c1 := 'R';
        3: c1 := 'I';
        4: c2 := CIMA;
        5: c2 := BAIX;
        6: c1 := '+';
        7: c1 := '-';
        8: c1 := 'F';
//        9: c2 := TEND; //Fim da mídia
        9: c1 := ESC;
    else
        c2 := ESC;
    end;

    textBackground (BLACK);
    clrscr;
    window (1, 1, 80, 25);
end;

{--------------------------------------------------------}
{                Modifica a playlist atual
{--------------------------------------------------------}

function completa(s:string; n:integer): string;
begin
    if length(s) > n then
        begin
            s := copy(s,1,n-11)+'...'+copy(s,length(s)-7,8);
        end;

    result := copy(s+'                                          ',1,n)

end;

{-------------------------------------------------------------}
{           Acerta o tempo de duracao da midia
{-------------------------------------------------------------}

function acertaTempo(posicao: array of char): TDateTime;
var
    hora,minuto,segundo:integer;
    tempo,d:string;
    i,t: integer;

begin
    if posicao[0] = #0 then
        result:= strtoDateTime('00:00:00')
    else
    begin
        tempo := '';
        i := 0;
        while true do
            begin
                if posicao[i] = #0 then
                break;
                tempo := tempo+posicao[i];
                i := i+1;
            end;
        t:= strtoint(tempo);
        hora:=t div 3600000;
        minuto:=t mod 3600000 div 60000;
        segundo:=t mod 3600000 mod 60000 div 1000;
        d := inttoStr(hora)+':'+inttoStr(minuto)+':'+inttoStr(segundo);
        result := strtoTime(d);
    end;
end;

{-------------------------------------------------------------}
{                Mostra o estado da execução
{-------------------------------------------------------------}

procedure mostraStatus(nomeMidia, status, tempo: String; falando: boolean );
begin
    TextBackground(BLUE);
    TextColor(Yellow);
    gotoxy(1,3);

    if tempo <> '' then
        begin
            textcolor(green);
            write(completa(status,8));
            textcolor(yellow);
            write(completa(nomeMidia,31),' ');
            write(tempo);
        end
    else
        begin
            textcolor(green);
            write(completa(status,16));
            textcolor(yellow);
            write(completa(nomeMidia,31),' ');
            if falando then
                begin
                    sintetiza (status);
                    sintetiza (nomeMidia);
                end;
        end;
    textcolor(WHITE);
    TextBackground(BLACK);
end;

{-------------------------------------------------------------}
{              Exibe tempo e duracao.
{-------------------------------------------------------------}

procedure exibeTempos (falando: boolean);
var
    tempo, duracao: string;
    retorno: array [0..80] of char;

begin
    TextBackground(BLUE);
    TextColor(Yellow);
    gotoxy(1,3);
    write (copy (brancos, 1, 48));
    gotoxy(1,3);

    mciSendString ('status midia position',retorno,80,0);
    tempo   := timetostr(acertaTempo(retorno));
    mciSendString ('status midia length',retorno,80,0);
    duracao := timetostr(acertaTempo(retorno));

    textcolor (green);  write ('Tempo atual: ');
    textcolor (yellow); write (tempo);
                        write ('  ');
    textcolor (green);  write ('Duração: ');
    textcolor (yellow); write (duracao);

    if falando then
        begin
            sintetiza ('Tempo atual: ');
            sintetiza (tempo);
            sintetiza ('Duração: ');;
            sintetiza (duracao);
        end;
    textcolor(WHITE);
    TextBackground(BLACK);
end;

{-------------------------------------------------------------}
{                      Envia comando MCI
{-------------------------------------------------------------}

Function EnviaComandoMCI (cmd : string): longint;
var
    comando : array [0..512] of char;
    erro: longint;
    retorno: array [0..512] of char;

begin
    strPCopy (comando, cmd);
    erro := mciSendString(comando, retorno, 512, 0);
    result := erro;
end;

{-------------------------------------------------------------}
Function GetParamComandoMCI (cmd : string): string;
var
    comando : array [0..512] of char;
    erro: longint;
    retorno: array [0..512] of char;

begin
    result := '';
    strPCopy (comando, cmd);
    erro := mciSendString(comando, retorno, 512, 0);
    if erro = 0 then
        result := StrPas(retorno);
end;

{-------------------------------------------------------------}
{                     erro no MCI
{-------------------------------------------------------------}

Procedure erroMCI (qualErro : longInt);
var
    retPas : string;
    retorno: array [0..512] of char;

begin
    mciGetErrorString(qualErro, retorno, 255);
    sintsom ('MIERRMCI');
    retPas := strPas (retorno);
    sintWriteln (retPas);
end;

{-------------------------------------------------------------}
{                     prepara regiao da tela para reprodução de vídeos
{-------------------------------------------------------------}

procedure preparaVideo;
var
    s: string;
    p: integer;

    xTela:  integer;
    yTela:  integer;
    dxTela: integer;
    dyTela: integer;

    dxVideo: integer;
    dyVideo: integer;

label
    pronto;

begin
    { Local destinado a reprodução de vídeos }
    xTela  := (xIniTela-1)  * CharSize.X;
    yTela  := (yIniTela-1)  * CharSize.Y;
    dxTela := 80 * CharSize.X - xTela -1;
    dyTela := 24 * CharSize.Y - yTela -1;

    s := trim (GetParamComandoMCI ('where midia source'));

    p := pos (' ', s);
    if p = 0 then goto pronto;
    delete (s, 1, p);
    s := trim (s);

    p := pos (' ', s);
    if p = 0 then goto pronto;
    delete (s, 1, p);
    s := trim (s);

    p := pos (' ', s);
    if p = 0 then goto pronto;
    dxVideo := StrToInt (trim (copy (s, 1, p))) * 100;
    dyVideo := StrToInt (trim (copy (s, p, length(s) - p+1))) * 100;

    if dxVideo > dxTela then
        begin
            dyVideo := trunc (dyVideo * (dxTela / dxVideo));
            dxVideo := dxTela;
        end;
    if dyVideo > dyTela then
        begin
            dxVideo := trunc (dxVideo * (dyTela / dyVideo));
            dyVideo := dyTela;
        end;

pronto:
    tocandoVideo := True;
    enviaComandoMci ('put midia destination at ' +
                intToStr(xTela + (dxTela - dxVideo) div 2) + ' ' +
                intToStr(yTela + (dyTela - dyVideo) div 2) + ' ' +
                intToStr(dxVideo) + ' ' +
                intToStr(dyVideo));
end;

{-------------------------------------------------------------}
{               transforma retorno MCI em inteiro
{-------------------------------------------------------------}

function pegaRetornoMci: longint;
var
    valor: longint;
    erro: integer;
    retorno: array [0..512] of char;
begin
    val (strPas (retorno), valor, erro);
    pegaRetornoMci := valor;
end;

{-------------------------------------------------------------}
{               Comandos MCI
{-------------------------------------------------------------}

function comandosMCI(nomeMidia, comando: String): boolean;
var
    erro : longInt;
begin
    erro := 0;
    result := false;

    if nomemidia[1] <> '"' then
        nomemidia := '"'+ nomemidia+ '"';

    comando := UpperCase(comando);
    if comando = 'OPEN' then
        begin
            tocandoVideo := False;
            enviaComandoMCI ('close midia');
            erro := EnviaComandoMCI('open '+PAnsiChar(nomeMidia)+' alias midia');
            if erro = 0 then
                erro := EnviaComandoMCI('set midia time format milliseconds');
        end
    else
    if comando = 'PLAY' then
        erro := EnviaComandoMCI('play midia')
    else
    if comando = 'PAUSE' then
        erro := EnviaComandoMCI('pause midia')
    else
    if comando = 'STOP' then
        erro := EnviaComandoMCI('stop midia')
    else
    if comando = 'CLOSE' then
        erro := EnviaComandoMCI('close midia')
    else

    if comando = 'VIDEO' then
    begin
        erro := enviaComandoMci ('window midia handle ' + intToStr(crtwindow));
        if erro = 0 then
            preparaVideo;
    end;

    if erro = 0 then
        result := true;
end;

{-------------------------------------------------------------}
{               Controle de volume
{-------------------------------------------------------------}
(*
function leVolume: integer;
var
    i: integer;
    strVolume: string;
    retorno: array [0..80] of char;
begin
    mciSendString('status midia volume',retorno,80,0);
    strVolume := '';
    i := 0;
    while true do
        begin
            if retorno[i] = #0 then
            break;
            strVolume := strVolume + retorno[i];
            i := i+1;
        end;
    result := strtoint(strVolume);
end;
*)
{-------------------------------------------------------------}

function defineVolume (vol: integer): integer;
begin
    volumeMidia := vol;
    result := enviaComandoMci ('setaudio midia volume to ' + inttostr(volumeMidia));
end;

{-------------------------------------------------------------}
{    reduz volume para reproduzir a legenda
{-------------------------------------------------------------}

procedure reduzVolume;
var i: integer;
begin
    for i := 1 to 20 do
    begin
        defineVolume(volumeMidia-40);
        delay(15);
    end;
end;

{-------------------------------------------------------------}
{    Restaura volume após reproduzir a legenda
{-------------------------------------------------------------}

procedure sobeVolume;
var i: integer;
begin
    for i := 1 to 20 do
    begin
        defineVolume(volumeMidia+40);
        delay(15);
    end;
end;

{-------------------------------------------------------------}
{    Exibe a legenda atual ajustando volume durante síntese
{-------------------------------------------------------------}

procedure tocaLegenda (indLegenda, tempoAtual: integer);
var
    afalar: string;
    arqSom: string;

begin
    arqSom := '';
    arqSom := legendas[indLegenda].arqSom;

    afalar := legendas[indLegenda].texto;
    if legendas[indLegenda].texto2 <> '' then
        aFalar := aFalar + ' ' + legendas[indLegenda].texto2;

    {*
     *  Exibe legenda na tela.
     *}
    if indLegenda <> ultimaLegendaMostrada then
    begin
        gotoxy (1,25);
        textColor(YELLOW);
        write (copy(aFalar, 1, 79));
        textColor(WHITE);
        clreol;
        ultimaLegendaMostrada := indLegenda;
    end
    else
    begin
gotoXy(50, 25);
write(legendas[indLegenda].tempoFinal, ' ', tempoAtual);
        if legendas[indLegenda].tempoFinal >= tempoAtual then
        begin
            gotoxy(1, 25);
            clreol;
        end;
    end;
    {*
     *  Toca legenda dublada.
     *}
    if ultimaLegendaFalada = indLegenda then
        exit;
    if tocandoSom then
        paraSom;
        reduzVolume;
    if arqSom = '' then
    begin
        sintetiza(aFalar);
        while sintFalando do waitMessage;
    end
    else
    begin
        tocaSom (arqSom);
    end;
    ultimaLegendaFalada := indLegenda;
    sobeVolume;
end;

{-------------------------------------------------------------}
{              Avança ou retrocede na midia
{-------------------------------------------------------------}

procedure andaNaMidia (comando: string; passo: integer);
var
    tempo:string;
    i,t: integer;
    erro : longInt;
    retorno: array [0..80] of char;
    posicao: array [0..80] of char;
begin
    mciSendString('status midia position',posicao,80,0);
    tempo := '';
    i := 0;
    while true do
        begin
            if posicao[i] = #0 then
            break;
            tempo := tempo+posicao[i];
            i := i+1;
        end;
    t := strtoint(tempo);
    mciSendString('status midia mode', retorno, 80, 0);
    if retorno = 'playing' then
        begin
            erro := 0;

            if UpperCase(comando) = 'AVANCANAMIDIA' then
            begin
                t := t+passo;
                erro := enviaComandoMci ('play midia from ' + inttostr(t));
            end
            else
            if UpperCase(comando) = 'VOLTANAMIDIA' then
            begin
                t := t-passo;
                if t < 0 then
                    t := 0;
                erro := enviaComandoMci ('play midia from ' + inttostr(t));
            end;
            if erro <> 0 then sintBip;
        end
end;

{-------------------------------------------------------------}
{              Aumenta ou diminui volume sonono de reprodução
{-------------------------------------------------------------}

procedure AjustaVolume (comando: string; passo: integer);
var
    vol: integer;
    erro : longInt;
    retorno: array [0..80] of char;
begin
    passo := abs (passo);
    if passo = 0 then
        exit;
    mciSendString('status midia mode', retorno, 80, 0);
    if retorno <> 'playing' then
        exit;
    vol := volumeMidia;

    erro := 0;
    if UpperCase(comando) = 'AUMENTAVOLUME' then
        begin
            if vol = MAXVOL then
                exit;
            vol := vol + passo;
            if vol > MAXVOL then
                vol := MAXVOL;
            erro := defineVolume (vol);
        end
    else
    if UpperCase(comando) = 'DIMINUIVOLUME' then
        begin
            if vol = MINVOL then
                exit;
            vol := vol - passo;
            if vol < MINVOL then
                vol := MINVOL;
            erro := defineVolume (vol);
        end;
    if erro <> 0 then sintBip;
end;

{-------------------------------------------------------------}
{               carrega a lista de marcadores
{-------------------------------------------------------------}

procedure carregaMarcadores;
var
   tempoAtual, nomeConfig, t: string;
   i: integer;

begin
    nomeConfig := sintAmbiente('MIDIAVOX','ARQTEMPOS');
    if nomeConfig = '' then
        nomeConfig := sintDirAmbiente + '\midiaTempos.ini';
    midiaAtual := AnsiUpperCase(midiaAtual); { melhorar tirando letras especiais }
    t := '0';
    tempoAtual := sintAmbienteArq (midiaAtual, t, '0', nomeConfig);

    marcadores := TStringList.create;
    marcadores.add(tempoAtual);

    for i := 1 to 9 do
        begin
            t := sintAmbienteArq (midiaAtual, inttostr(i), '0', nomeConfig);

            if t = '0' then
                marcadores.add('VAZIO')
            else
                marcadores.add(t);
        end;
end;

{-------------------------------------------------------------}
{             Salva marcadores em midiaTempos.ini
{-------------------------------------------------------------}

procedure salvaMarcadores;

var
   nomeConfig, si, t: string;
   i: integer;
   tempoAtual: array [0..80] of char;

begin
    mciSendString('status midia position',tempoAtual,80,0);
    nomeConfig := sintAmbiente('MIDIAVOX','ARQTEMPOS');
    if nomeConfig = '' then
        nomeConfig := sintDirAmbiente + '\midiaTempos.ini';
    midiaAtual := AnsiUpperCase(midiaAtual); { melhorar tirando letras especiais }

    t := '0';
    sintGravaAmbienteArq (midiaAtual,t,tempoAtual, nomeConfig);

    for i := 1 to 9 do
        begin
            si := inttostr(i);
            sintGravaAmbienteArq (midiaAtual,si,marcadores[i], nomeConfig);
        end;
end;

{-------------------------------------------------------------}
{          adiciona a posição a lista de marcadores
{-------------------------------------------------------------}

procedure adicionaMarcador(posicao: array of char);
var
    tempo: string;
    t, i, index: integer;
begin

    if posicao[0] = #0 then
        t := 0
    else
    begin
        tempo := '';
        i := 0;
        while true do
            begin
                if posicao[i] = #0 then
                break;
                tempo := tempo+posicao[i];
                i := i+1;
            end;
        t:= strtoint(tempo);
    end;
    index := marcadores.IndexOf('VAZIO');
    marcadores[index] := inttostr(t);

end;

{-------------------------------------------------------------}
{              Remove marcador da lista
{-------------------------------------------------------------}

procedure removeMarcador;
var
    c: char;
    i, t, hora, minuto, segundo: integer;

begin
    window (1, 1, 80, 25);
    limpaBaixo(5);

    window(1,5,24,15);
    TextBackground(BLUE);
    clrscr;

    repeat
        for i := 1 to 9 do
            begin
                TextBackground(BLUE);
                if marcadores[i] <> 'VAZIO' then
                    begin
                        t:= strtoint(marcadores[i]);
                        hora:=t div 3600000;
                        minuto:=t mod 3600000 div 60000;
                        segundo:=t mod 3600000 mod 60000 div 1000;
                        writeln(timetostr(strtoTime(inttoStr(hora)+':'+inttoStr(minuto)+':'+inttoStr(segundo))));
                    end
                else
                    writeln(marcadores[i]);
            end;

        writeln;
        TextBackground(BLACK);
        mensagem('MISELTAG',0); {    'Qual marcador apagar? '    }
        c := sintReadkey;

        if upcase(c) >= 'T' then
            begin
                for i := 1 to 9 do
                    marcadores[i] := 'VAZIO';
                break;
            end;
        if (c>='1') and (c<='9') then
            begin
                if marcadores[strtoint(c)] <> 'VAZIO' then
                    begin
                        marcadores[(strtoint(c))] := 'VAZIO';
                        sintbip; sintbip;
                        break;
                    end
                else
                    sintetiza('VAZIO');;
            end
        else
            continue;

    until c = ESC;
    window (1, 1, 80, 25);
end;

{-------------------------------------------------------------}
{                   aciona o tocador
{-------------------------------------------------------------}

function AcionaTocador: String;
var cmdTecla, cmdMenu: char;
    tocando: boolean;
    retorno: array [0..80] of char;
    posicao: array [0..80] of char;
    index, i2: integer;
    salvaVol: integer;
    tempo, nomeMidia: string;
    salvatocando: boolean;

label interpretaComando;

    {-------------------------------------------------------------}

    procedure inicia;
    const
//        invalidos: set of char = ['|', '?', '!', '*', '"', '<', '>', '¦'];
        invalidos: set of char = ['|', '?', '*', '"', '<', '>', '¦', '/' ];
    var
        i: integer;
    begin
        nomeMidia := ExtractFileName(midiaAtual);
        extMidiaAtual := UpperCase (ExtractFileExt(midiaAtual));
        for i := 1 to length(midiaAtual) do
            begin
                if midiaAtual[i] in invalidos then
                begin
                    mostraStatus('', pegaTextoMensagem('MIEROPEN')+' '+ midiaAtual, '', true);  {  'Erro ao abrir' }
                    exit;
                end;
            end;
        comandosMCI(midiaAtual,'close');
        if comandosMCI(midiaAtual, 'open') then
            begin
                if extensaoVideo (extMidiaAtual) then
                    comandosMCI(midiaAtual,'video');
                defineVolume(volumeMidia);
                if comandosMCI(midiaAtual, 'play') then
                    begin
                        ajudaControles (False);
                        setWindowTitle ('Midiavox - ' + nomeMidia);
                        mciSendString('status midia position',posicao,80,0);
                        tempo := timetostr(acertaTempo(posicao));
                        mostraStatus(nomeMidia, 'Tocando' , tempo, false);
                        tocando := true;
                    end
                else
                   mostraStatus(nomeMidia, pegaTextoMensagem('MIERPLAY'), '', true) {  'Erro no play' }
            end
        else
            mostraStatus(nomeMidia, pegaTextoMensagem('MIEROPEN'), '', true);  {  'Erro ao abrir' }
    end;

    {--------------------------------------------------------}

    procedure calcPosAtual(var pos: integer);
    var
        i: integer;
        s: string;
    Begin
        //Obtém inteiro com a posição atual
        s := strPas(posicao);
        i := strToInt(s);
        if (pos = 0) or (legendas[pos].tempoinicial <= i) then
        begin
            {*
             *  Avança posArqLegenda até i (tempo atual da mídia)
             *}
            if pos = 0 then
                pos := 1;
            while (pos <= numlegendas) and (legendas[pos].tempoinicial <= i) do
                pos := pos +1;
            if pos > 0 then
                pos := pos -1;
        end
        else
        begin
            {*
             *  Retrocede posArqLegenda até i (tempo atual da mídia)
             *}
            repeat
                pos := pos -1;
            until (pos <= 0) or (legendas[pos].tempoinicial <= i);
            if pos < 0 then
                pos := pos +1;
        end;
    end;

    {-------------------------------------------------------------}

    procedure pausa (fala: boolean);
    begin
        if tocando then
            begin
                comandosMCI(midiaAtual,'pause');
                tocando := false;
                if fala then
                    sintetiza('Pausado');
                mciSendString('status midia position',posicao,80,0);
                tempo := timetostr(acertaTempo(posicao));
                mostraStatus(nomeMidia, 'Pausado', tempo, true);
            end
        else
            begin
                if comandosMCI(midiaAtual, 'play') then
                    begin
                        ajudaControles (False);
                        setWindowTitle ('Midiavox - ' + nomeMidia);

                        mciSendString('status midia position',posicao,80,0);
                        tempo := timetostr(acertaTempo(posicao));
                        mostraStatus(nomeMidia, 'Tocando', tempo, false);

                        tocando := true;
                    end
                else
                    mostraStatus(nomeMidia, pegaTextoMensagem('MIERPLAY'), '', true); {  'Erro no play' }
            end;
    end;

   {-------------------------------------------------------------}

begin
    inicia;
    carregaMarcadores;
    ultimaLegendaFalada := 0;
    UltimaLegendaMostrada := 0;
    dublando := inicializaLegendas;   {    True se arquivo srt com o mesmo nome da mídia foi carregado e lido corretamente   }
    repeat
        delay (100);
        mciSendString('status midia mode', retorno, 80, 0);
        mciSendString('status midia position',posicao,80,0);

        tempo := timetostr(acertaTempo(posicao));

        if dublando then   {   Exibe legendas   }
        begin
            calcPosAtual(posArqLegendas);
//            if (posArqLegendas > 0) and (ultimaLegendaFalada <> posArqLegendas) then
            begin
                tocaLegenda(posArqLegendas, strToInt(strPas(posicao)));
            end;
        end;

        if tocando then
            mostraStatus(nomeMidia, 'Tocando', tempo, false)
        else
            mostraStatus(nomeMidia, 'Pausado', tempo, true);

        if not keypressed then continue;

        cmdTecla := upcase(readKey);
        if cmdTecla = #0 then cmdMenu := readkey;

interpretaComando:

        case cmdTecla of

            ' ', ENTER, 'P':
                pausa (not modosilencioso);

            '+':
                ajustaVolume ('AUMENTAVOLUME', passoVol);
            '-':
                ajustaVolume ('DIMINUIVOLUME', passoVol);

            CTLENTER:
            begin
                repetidos.add(inttostr(item));
                aleatorio := not aleatorio;
            end;

            'I':
                begin
                    if tocando then
                        pausa (false);
                    sintbip;
                    salvaVol := volumeMidia;
                    defineVolume (volBaixo);
                    exibeTempos (true);
                    sintbip;
                    if not tocando then
                        pausa (false);
                    defineVolume (salvaVol);
                end;
            'D':
                begin
                    if tocando then
                        pausa (false);
                    removeMarcador;
                    salvaMarcadores;
                    if not tocando then
                        pausa (false);
                 end;

            'F','L':
                begin
                    if execucaoAutomatica then
                        execucaoAutomatica := false;
                    cmdTecla := ESC;
                    fimPlaylist := True;
                end;

            ESC:
                begin
                    cmdTecla := ESC;
                    fimPlaylist := True;
                end;

            '0'..'9':
                begin
                    index := strtoint(cmdTecla);
                    if marcadores[index] <> 'VAZIO' then
                        begin
                            mciSendString('status midia mode', retorno, 80, 0);
                            if retorno = 'playing' then
                                enviaComandoMci ('play midia from ' + marcadores[index]);
                        end;
                end;

            'R':
                begin
                    salvaVol := volumeMidia;
                    defineVolume (volBaixo);
                    repete := not repete;
                    if repete then
                        begin
                            mostraStatus('', 'Repetir', '', true);
                            sintbip; sintBip;
                        end
                    else
                        begin
                            mostraStatus('', 'Não repetir', '', true);
                            sintbip;
                        end;
                    defineVolume (salvaVol);
                end;

            'T':
                begin
                    reinicia := True;
                    cmdTecla := ESC;
                end;
            TAB:
                begin
                    if getkeystate(VK_SHIFT) < 0 then
                        andaNaMidia('VOLTANAMIDIA',10000);
                    if getkeystate(VK_SHIFT) >= 0 then
                        andaNaMidia('AVANCANAMIDIA',10000);
                end;

            #0:
                case cmdMenu of
                    ESC:
                        continue;
                    HOME:
                    begin
                        reinicia := True;
                        cmdTecla := ESC;
                    end;
                    TEND: begin //Patrick
                        mciSendString('status midia length', retorno, 80, 0);
                        i2 := strtoint(retorno);
                        if i2 > 4000 then //Só avança para o final se a mídia tiver mais de 4 segundos. Retorno colocado em i2 é em miliSegundo
                            begin
                            enviaComandoMci ('stop midia');
                            i2 := i2 - 4000;
                            enviaComandoMci ('play midia from '+intToStr(i2));
                            end;
                    end;

                    F1:
                    begin
                        if tocando then
                            pausa (false);
                        ajudaControles(True);
                        if not tocando then
                            pausa (false);
                    end;

                    F2:
                    begin
                        if not marcadores.Find('VAZIO', index) then
                            begin
                                sintetiza('Atingiu o limite');
                                continue;
                            end
                        else
                            begin
                                sintbip;    sintbip;
                                adicionaMarcador(posicao);
                                salvaMarcadores;
                            end;
                    end;

                    F3:
                    begin
                        if tocando then
                            pausa (false);
                        infoMidia;
                        if not tocando then
                            pausa (false);
                     end;

                    F8:
                    begin
                        salvatocando := tocando;
                        if tocando then
                            pausa (false);
                        tocando := false;
                        falaHora;
                        if salvatocando then
                            pausa (false);
                    end;
                    CTLF8:
                    begin
                        salvatocando := tocando;
                        if tocando then
                            pausa (false);
                        tocando := false;
                        falaDia;
                        if salvatocando then
                            pausa (false);
                    end;

                    F9:
                    begin
                        salvatocando := tocando;
                        if tocando then
                            pausa (false);
                        tocando := false;
                        mciSendString('status midia position',posicao,80,0);
                        tempo := timetostr(acertaTempo(posicao));
                        mostraStatus(nomeMidia, pegatextomensagem('MIPAUSAD'), tempo, false); {  'Pausado'  }
                        menuControles (cmdTecla, cmdMenu);  // executa o menu
                        if salvatocando then
                            pausa (true);
                        goto interpretaComando;

                    end;

                    CIMA:
                        begin
                            cmdTecla := ESC;
                            volta := TRUE;
                        end;

                    BAIX:
                        begin
                            cmdTecla := ESC;
                            avanca := TRUE;
                        end;
                    ESQ:
                        andaNaMidia('VOLTANAMIDIA',1000);
                    DIR:
                        andaNaMidia('AVANCANAMIDIA',1000);
                end;
        end;

    until (retorno = 'stopped') or (cmdTecla = ESC) or (cmdTecla = 'F');

    comandosMCI(midiaAtual,'stop');
    salvaMarcadores;
    comandosMCI(midiaAtual,'close');
    marcadores.Destroy;

    textBackground (BLACK);
    window (1, 5, 48, 25);
    clrscr;
    window (1, 1, 80, 25);
    gotoxy (1, 25);
    clreol;
    gotoxy (1, 5);
end;

end.
