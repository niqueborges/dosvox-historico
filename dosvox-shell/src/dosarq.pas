unit dosarq;
interface
uses windows, sysUtils, classes,
     dvcrt, dvwin, dvlenum, dvarq, dvform, dvhora, dvexec, dvamplia,
     dosVars, dostoca, dosEmail, dosgeral, dosmsg, dosimpr, dosed, dosCopia, dosProc,
     dosconvert,
     mmsystem, jpeg, shellapi;

procedure editaLeUmArquivo (nomeArq: string; opcao: integer);
procedure trataArquivos    (nomeJanelaComDir: boolean; var vaiParaSubdiretorios: boolean);

implementation

var
    textoBusc: string;
    numArqAtual: integer;
    masc: string;
    atrib: word;
    tipoOrd: integer;

{--------------------------------------------------------}
{                  opcao de arquivos
{--------------------------------------------------------}

procedure ajudaArquivos;
begin
    writeln;
    mensagem ('DV_AJUA_SET', 1);    {'Use as setas para escolher e tecle'}
    mensagem ('DV_AJUA_E',   1);    {'      E - editar o arquivo'}
    mensagem ('DV_AJUA_I',   1);    {'      I - imprimir'}
    mensagem ('DV_AJUA_L',   1);    {'      L - ler'}
    mensagem ('DV_AJUA_R',   1);    {'      R - remover'}
    mensagem ('DV_AJUA_X',   1);    {'      X - executar o arquivo'}
    mensagem ('DV_AJUA_N',   1);    {'      N - trocar o nome'}
    mensagem ('DV_AJUA_C',   1);    {'      C - tirar uma cópia'}
    sintBip;
    mensagem ('DV_AJU_F9',  1);  {'Aperte F9 para conhecer outras opções'}
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasArquivo: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
label menuContinua;

const
    tabLetrasPrincipal: string [20] = 'eilrxncdsqgtomzpbfu+';
    tabLetrasCont     : string [10] =  ^b+^c+^d+^n+^p+^q+^t+^v+^x+^o;
begin
    popupMenuCria (1, wherey, 60, 20, BLACK);
    MenuAdiciona ('DV_AJUA_E');     {'   E - editar o arquivo'}
    MenuAdiciona ('DV_AJUA_I');     {'   I - imprimir'}
    MenuAdiciona ('DV_AJUA_L');     {'   L - ler'}
    MenuAdiciona ('DV_AJUA_R');     {'   R - remover'}
    MenuAdiciona ('DV_AJUA_X');     {'   X - executar o arquivo'}
    MenuAdiciona ('DV_AJUA_N');     {'   N - trocar o nome'}
    MenuAdiciona ('DV_AJUA_C');     {'   C - tirar uma cópia'}
    MenuAdiciona ('DV_AJUA_D');     {'   D - obter dados sobre o arquivo'}
    MenuAdiciona ('DV_AJU_S' );     {'   S - subdiretórios'}
    MenuAdiciona ('DV_AJUA_Q');     {'   Q - informar qual arquivo do total'}
    MenuAdiciona ('DV_AJUA_G');     {'   G - exibir um grupo de arquivos'}
    MenuAdiciona ('DV_AJUA_T');     {'   T - falar o tamanho total dos arquivos'}
    MenuAdiciona ('DV_AJUA_O');     {'   O - ordenar os arquivos'}
    MenuAdiciona ('DV_AJUA_M');     {'   M - enviar arquivo como email'}
    MenuAdiciona ('DV_AJUA_Z');     {'   Z - compactar o arquivo'}
    MenuAdiciona ('DV_AJUA_P');     {'   P - desproteger o arquivo'}
    MenuAdiciona ('DV_AJUA_B');     {'   B - buscar um arquivo que contenha um texto'}
    MenuAdiciona ('DV_AJUA_F');     {'   F - procurar arquivos'}
    MenuAdiciona ('DV_AJUA_U');     {'   U - converter formatos'}
    MenuAdiciona ('DV_AJU_MA');     {'   + - folhear mais opções'}

    n := popupMenuSeleciona;
    if n > 0 then
        if tabLetrasPrincipal[n] = '+' then
            goto menuContinua
        else
            selSetasArquivo := tabLetrasPrincipal[n]
    else
        begin
             selSetasArquivo := ESC;
             clreol;
        end;
    exit;

menuContinua:
    popupMenuCria (20, wherey, 60, 10, BLACK);
    MenuAdiciona ('DV_AJUA_CTL_B');     {'  Ctrl+B - buscar novamente'}
    MenuAdiciona ('DV_AJUA_CTL_C');     {'  Ctrl+C - copiar nomes para área de transferência'}
    MenuAdiciona ('DV_AJUA_CTL_D');     {'  Ctrl+D - informar o nome do diretório atual'}
    MenuAdiciona ('DV_AJUA_CTL_N');     {'  Ctrl+N - jogar os nomes sem incluir diretório'}
    MenuAdiciona ('DV_AJUA_CTL_P');     {'  Ctrl+P - proteger o arquivo'}
    MenuAdiciona ('DV_AJUA_CTL_Q');     {'  Ctrl+Q - informar quantos selecionados do total'}
    MenuAdiciona ('DV_AJUA_CTL_T');     {'  Ctrl+T - falar o tamanho dos selecionados'}
    MenuAdiciona ('DV_AJUA_CTL_V');     {'  Ctrl+V - copiar arquivos da área de transferência'}
    MenuAdiciona ('DV_AJUA_CTL_X');     {'  Ctrl+X - mover arquivos para área de transferência'}
    MenuAdiciona ('DV_AJUA_CTL_O');     {'  Ctrl+O - alterar padrão de ordenação'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasArquivo := tabLetrasCont[n]
    else
        begin
             selSetasArquivo := ESC;
             clreol;
        end;
end;

{--------------------------------------------------------}
{               recria a lista de arquivos
{--------------------------------------------------------}

procedure recriaLista (masc: string; atrib: word; tipoOrd: integer);
begin
    if listArquivos <> NIL then
        liberaListArq;
    listArquivos := criaListArq (masc, atrib);
    ordenaListArq(tipoOrd);
end;

{--------------------------------------------------------}

procedure dadosArquivo (somenteData, somenteTamanho: boolean);
const
    maxTipos = 41;
    tiposArq: array [1..maxTipos] of string = (
        'ADV:Dados do programa Caverna Colossal',
        'ASP:Programa para Active Server Pages',
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
        'XLSM:Planilha do Microsoft Excel',
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

        sintWriteln ('Velocidade: ' +  intToStr(velocidade));
        sintWriteln ('Bits por Amostra: ' +  intToStr(BitsporAmostra));
        writeln ('Canais: ' +  intToStr(Canais));
        exit;

    fim:
        fileClose (f);
        sintWriteln ('Arquivo não é um WAV legítimo');
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
           sintWriteln ('Informações da música não estão disponíveis')
       else
           begin
               if trim(ID3.Title) <> '' then
                   sintWriteln ('Título: ' + ID3.Title);
               if trim(ID3.Artist) <> '' then
                   sintWriteln ('Artista: ' + ID3.Artist);
               if trim(ID3.Album) <> '' then
                   sintWriteln ('Álbum: ' + ID3.Album);
               sintWriteln ('Ano: ' + ID3.Year);
               if ID3.Genre in [0..MaxID3Genre] then
                    sintWriteln ('Gênero: ' + ID3Genre[ID3.Genre])
               else
                    sintWriteln ('Gênero: desconhecido');
               if trim(ID3.Comment) <> '' then
                   sintWriteln ('Comentários: ' + ID3.Comment);
           end;
    end;

    procedure dadosJPG(nomeArq: string);
    var
        FStreamJpg  : TStream;
        FJpeg    : TJpegImage;
    const
        boolToStr: array [boolean] of string = ('não', 'sim');

    begin
        FStreamJpg := TFileStream.Create(nomeArq, fmOpenRead);
        FJpeg := TJPEGImage.Create;
        FJpeg.LoadFromStream(FStreamJpg);

        sintWriteln ('Número de pixels: ' +
                     intToStr(FJpeg.Width) + ' por ' + intToStr(FJpeg.Height));
        if FJpeg.PixelFormat = jf24bit then
            sintWriteln ('Bits por pixel: 24')
        else
            sintWriteln ('Bits por pixel: 8');

        sintWriteln ('Exibição progressiva: ' + boolToStr[FJpeg.ProgressiveEncoding]);
        sintWriteln ('Qualidade da imagem: '  + intToStr(FJpeg.CompressionQuality) + '%');

        FStreamJpg.Free;
        FJpeg.Free;
    end;

    procedure dadosBMP(nomeArq: string);
    begin
        if openBmp(nomeArq) then
        sintWriteln ('Número de pixels: ' +
                     intToStr(BMPwidth) + ' por ' + intToStr(BMPheight));
        closeBmp;
    end;


var sr: TSearchRec;
    ext, ext2, t: string;
    i: integer;
begin
    if (numArqAtual < 0) or (numArqAtual >= listArquivos.count) then exit;

    sr := PMySearchRec(listArquivos[numArqAtual]).sr;

    if somenteTamanho then
        begin
            falaTamanhoArq (Int64(sr.FindData.nFileSizeHigh) shl Int64(32) +
                            Int64(sr.FindData.nFileSizeLow), false);
            writeln;
            exit;
        end;

    if not somenteData then
        if (fileGetAttr (sr.FindData.cFileName) and faReadOnly) <> 0 then
            mensagem ('DV_PROTEG', 1);     { 'Arquivo está protegido para regravação' }

    if not somenteData then
        begin
            falaTamanhoArq (Int64(sr.FindData.nFileSizeHigh) shl Int64(32) +
                            Int64(sr.FindData.nFileSizeLow), sintFalarTudo);
            writeln;

            if sintFalarTudo then
                mensagem ('DV_DATACRI', 0);     { 'Data de criação: ' }
            sintWriteln (tabNomesDias [dayOfWeek (FileDateToDateTime(sr.Time))]
                                + ' ' + dateToStr(FileDateToDateTime(sr.Time))
                                + ' ' + timeToStr(FileDateToDateTime(sr.Time)));
        end
    else
        begin
            sintWriteln (dateToStr(FileDateToDateTime(sr.Time))
                         + ' ' + timeToStr(FileDateToDateTime(sr.Time)));
            exit;
        end;

    ext := ansiUpperCase(extractFileExt(sr.Name));
    delete (ext, 1, 1);
    sintWrite ('Conteúdo: ');
    for i := 1 to maxTipos do
        begin
            t := tiposArq[i];
            ext2 := copy (t, 1, pos(':', t)-1);
            if ext2 = ext then
                break;
        end;

    if i > maxTipos then
        sintWriteln ('Desconhecido')
    else
        sintWriteln (copy (t, pos(':', t)+1, 999));

    if ext = 'WAV' then dadosWav(sr.Name)
    else
    if ext = 'MP3' then dadosMP3(sr.Name)
    else
    if (ext = 'JPG') or (ext = '.JPEG') then dadosJPG(sr.Name)
    else
    if ext = 'BMP' then dadosBMP(sr.Name);
end;

{--------------------------------------------------------}

procedure tamanhoTodosArq (selecionado: boolean);
var i, cont: integer;
    tam: int64;
begin
    tam := 0;
    cont := 0;
    for i := listArquivos.count-1 downto 0 do
        begin
            if selecionado then
                begin
                    if PMySearchRec(listArquivos[i]).marcado then
                        tam := tam + PMySearchRec(listArquivos[i]).sr.Size;
                end
            else
                    tam := tam + PMySearchRec(listArquivos[i]).sr.Size;
            if cont > 200 then
                begin
                    sintClek;
                    cont := 0;
                end
            else
                cont := cont + 1;
        end;

    falaTamanhoArq (tam, sintFalarTudo);
end;

{-------------------------------------------------------------}
{                seleção interativa de email
{-------------------------------------------------------------}

function selecInterativaEmail: string;
var
    nomes: TStringList;
    nomeArqApelidos, s: string;
    arq: textFile;
    email: array [0..255] of char;
    i, p: integer;
begin
    nomeArqApelidos := sintAmbiente ('CARTAVOX', 'APELIDOS');
    if nomeArqApelidos = '' then
        nomeArqApelidos := sintDirAmbiente + '\apelidos.ini';

    if not FileExists(nomeArqApelidos) then
        begin
            sintWriteln (nomeArqApelidos);
            mensagem ('DV_ARQNAOEX', 1);    { 'Arquivo não existe, sinto muito.' }
            exit;
        end;

    assignFile (arq, nomeArqApelidos);
    {$I-}  reset(arq);   {$I+}
    if ioresult <> 0 then exit;         { Erro improvável }

    nomes := TStringList.Create;
    while not eof (arq) do
        begin
            readln (arq, s);
            s := trim (s);
            if (s = '') or (s[1] = ';') then continue;
            p := pos ('=', s);
            if (p = 0) then continue;
            s := trim(copy (s, 1, p-1));
            if (s = '') or (s[1] = '[') then continue;   // simplificação
            nomes.add (s);
        end;
    closefile (arq);

    garanteEspacoTela (10);
    popupMenuCria (wherex, wherey, 79-wherex, nomes.count, MAGENTA);
    nomes.Sort;
    for i := 0 to nomes.count-1 do
        popupMenuAdiciona ('', nomes[i]);
    nomes.Free;

    popupMenuSeleciona;
    if opcoesItemSelecionado = '' then
        exit;

    getPrivateProfileString ('APELIDOS', @opcoesItemSelecionado[1], '', email, 10000, @nomeArqApelidos[1]);
    writeln (email);
    selecInterativaEmail := email;
end;

{--------------------------------------------------------}

procedure enviaEmail;
var nomeUsuario, nomeArqEnviar, nomeDest, assunto, nome: string;
    listaNomes: TStringList;
    i, n, narq: integer;
    c: char;
    h, m, s, cent: word;
    label desist;


    function pegaDestinatario: string;
    var c: char;
        s: string;
    begin
        pegaDestinatario := '';
        s := '';
        c := sintEdita (s, wherex, wherey, 255, true);
        if c = ESC then exit;

        pegaDestinatario := s;
        if (c = ENTER) or (s <> '') then
            begin
                writeln;
                exit;
            end;

        pegaDestinatario := selecInterativaEmail;
    end;

begin
    mensagem ('DV_EMAILDEST', 1);   {'Email do destinatário'}
    nomeDest := pegaDestinatario;
    if trim (nomeDest) = '' then goto desist;

    while keypressed do readkey;
    mensagem ('DV_ASSUNTCART', 1);  {'Assunto da carta'}
    sintReadln (assunto);

    narq := 0;
    for i := 0 to listArquivos.count-1 do
        if PMySearchRec(listArquivos[i]).marcado then
            narq := narq + 1;

    n := 1;
    if narq <> 0 then n := narq;
    mensagem ('DV_VOUENVIAR', 0);   {'Vou enviar '}
    sintWriteint (n);
    writeln;
    mensagem ('DV_CONFIRMA', 0);    {'Confirma? '}
    c := popupMenuPorLetra ('SN');

        if (c = 'N') or (c = ESC) then
        begin
desist:
            mensagem ('DV_DESIST', 1);  {'Desistiu...'}
            exit;
        end;

    listaNomes := TStringList.Create;
    if narq = 0 then
        begin
            nome := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
            listaNomes.add (nome);
            writeln (nome);
        end
    else
        for i := 0 to listArquivos.count-1 do
            if PMySearchRec(listArquivos[i]).marcado then
                begin
                    nome := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                    listaNomes.Add(nome);
                    writeln (nome);
                end;

    gettime (h, m, s, cent);
    nomeArqEnviar := sintAmbiente ('CARTAVOX', 'DIRENVIA');
    nomeArqEnviar := nomeArqEnviar + '\'+
        intToStr (h) + intToStr (m) + intToStr (s) + intToStr (cent) + '.CPR';
    nomeUsuario := '"' + sintAmbiente ('CARTAVOX', 'NOMEUSUARIO') + '" <' +
                         sintAmbiente ('CARTAVOX', 'ENDERUSUARIO') + '>';
    preparaCarta (nomeArqEnviar, nomeUsuario, nomeDest, assunto, listaNomes);
    listaNomes.Free;
end;

{--------------------------------------------------------}

procedure criaZip;
var nomeDestino: string;
    nomeCompactador: string;
    compactaTodas: boolean;
    i, n: integer;
    c: char;
    nome: string;

        function compacta (nome: string): boolean;
        begin
            if not executaPrograma (nomeCompactador, '', '"'+nomeDestino+'"' + ' ' + nome, SW_SHOWMINIMIZED) then
                begin
                    mensagem ('DV_NAOCOMPAC', 1);   {'Não consegui acionar o compactador'}
                    compacta := false;
                end
            else
                begin
                    esperaProgVoltar;
                    compacta := true;
                end;
        end;

label fim;
begin
    mensagem ('DV_CTODSL', 1);  {'Tecle T para todo diretório ou S só as selecionadas: '}
    c := popupMenuPorLetra ('TS');
    writeln (c);

    compactaTodas := false;
    if upcase(c) = 'T' then
        compactaTodas := true;

    mensagem ('DV_NOMECOMPAC', 1);  {'Qual o nome do arquivo compacto? '}
    nomeDestino := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
    while (nomeDestino <> '') and (nomeDestino[length(nomeDestino)] <> '.') do
        delete (nomeDestino, length (nomeDestino), 1);
    if (nomeDestino <> '') and (nomeDestino[length(nomeDestino)] = '.') then
        delete (nomeDestino, length (nomeDestino), 1);
    c := sintEditaCampo (nomeDestino, wherex, wherey, 255, 80, true);
    writeln;
    nomeDestino := trim (nomeDestino);
    if (c= ESC) or (nomeDestino = '') then
        begin
            mensagem ('DV_DESIST', 1);  {'Desistiu...'}
            exit;
        end;

    mensagem ('DV_AGUCOMPACT', 1);  {'Um momento, compactando'}
    n := 0;

    nomeCompactador := sintAmbiente ('DOSVOX', 'COMPACTADOR');
    if nomeCompactador = '' then
        nomeCompactador := '"rar32" a -y';

    if compactaTodas then
        begin
            if not compacta ('*') then goto fim;
        end
    else
        begin
            for i := 0 to listArquivos.count-1 do
                if PMySearchRec(listArquivos[i]).marcado then
                    begin
                        nome := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                        nome := '"' + nome + '"';
                        if not compacta (nome) then goto fim;
                        n := n + 1;
                        while keypressed do readkey;
                        sintClek;
                    end;

            if n = 0 then
                begin
                    nome := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
                    nome := '"' + nome + '"';
                    if not compacta(nome) then goto fim;
                end;
        end;

    sintBip;
    mensagem ('DV_OKCOMPAC', 1);    {'Ok, compactado'}
    writeln;
fim:
//    recriaLista (masc, atrib, tipoOrd);
//        é melhor não recriar a lista, pois usuário pode querer apagar
//        os arquivos selecionados.
end;

{--------------------------------------------------------}

procedure protegeArquivo (poeProtecao: boolean);
var i: integer;
    s: string;
    attrib: word;
begin
    getDir (0, s);
    if s[length(s)] <> '\' then s := s + '\';

    attrib := fileGetAttr (s + PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName);
    if poeProtecao then
       attrib := attrib or faReadOnly
    else
       attrib := attrib and (not faReadOnly);
    if temSelecionados then
        begin
            for i := 0 to listArquivos.count-1 do
                if PMySearchRec(listArquivos[i]).marcado then
                    FileSetAttr( s + PMySearchRec(listArquivos[i]).sr.FindData.cFileName, attrib);
        end
    else
       FileSetAttr(s + PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName, attrib);

    if poeProtecao then
        mensagem ('DV_PROTEG', 1)       { 'Arquivo está protegido para regravação' }
    else
        mensagem ('DV_DESPRO', 1);      { 'Arquivo está desprotegido' }
end;

{--------------------------------------------------------}

procedure procuraConteudo (procuraDeNovo: boolean);

    function buscaNoArq (narq: integer): boolean;
    var s: string;
        arq: text;
    begin
        buscaNoArq := false;
        if (narq < 0) or (narq > (listArquivos.count-1)) then
            exit;
        assign (arq, PMySearchRec(listArquivos[narq]).sr.FindData.cFileName);
        {$I-}  reset (arq);  {$I+}
        if ioresult <> 0 then exit;
        while not eof (arq) do
            begin
                readln (arq, s);
                if length (s) >= length (textoBusc) then
                    if pos (textoBusc, ansiUpperCase(s)) > 0 then
                        begin
                            buscaNoArq := true;
                            break;
                        end;
            end;
        {$I-} close (arq); {$I+}
        if ioresult <> 0 then;
    end;

var cont, narq: integer;
begin
    if not procuraDeNovo then
        begin
            mensagem ('DV_DIGPALAV', 1);    {'Digite a palavra ou frase a buscar'}
            sintReadln (textoBusc);
            if textoBusc = '' then exit;
            textoBusc := ansiUpperCase (textoBusc);
        end
    else
        numArqAtual := numArqAtual + 1;

    cont := 0;
    for narq := numArqAtual to listArquivos.count-1 do
        begin
            if buscaNoArq (narq) then
                begin
                    numArqAtual := narq;
                    clreol;
                    mensagem ('DV_ACHEI', 0);   {'Achei '}
                    writeln (PMySearchRec(listArquivos[narq]).sr.FindData.cFileName);
                    exit;
                end
            else
            if cont > 30 then
                begin
                    sintClek;
                    cont := 0;
                end
            else
                cont := cont + 1;
        end;

    clreol;
    mensagem ('DV_NACHEI', 1);  {'Não achei '}
    sintBip;
    if procuraDeNovo then
        numArqAtual := numArqAtual - 1;
end;

{--------------------------------------------------------}

procedure procuraArquivo (procuraDeNovo: boolean);
var cont, narq: integer;
begin
    if not procuraDeNovo then
        begin
            mensagem ('DV_DIGPALAV', 1);    {'Digite a palavra ou frase a buscar'}
            sintReadln (textoBusc);
            if textoBusc = '' then exit;
            textoBusc := ansiUpperCase (textoBusc);
        end;

    numArqAtual := numArqAtual + 1;
    cont := 0;
    for narq := numArqAtual to listArquivos.count-1 do
        begin
            if pos (textoBusc, ansiUpperCase(PMySearchRec(listArquivos[narq]).sr.FindData.cFileName)) <> 0 then
                begin
                    numArqAtual := narq;
                    clreol;
                    mensagem ('DV_ACHEI', 0);   {'Achei '}
                    writeln (PMySearchRec(listArquivos[narq]).sr.FindData.cFileName);
                    exit;
                end
            else
            if cont > 500 then
                begin
                    sintClek;
                    cont := 0;
                end
            else
                cont := cont + 1;
        end;

    clreol;
    mensagem ('DV_NACHEI', 1);  {'Não achei '}
    sintBip;
    if procuraDeNovo then
        numArqAtual := numArqAtual - 1;
end;

{--------------------------------------------------------}

procedure removeArquivo (guardaLixeira: boolean);
var
    c: char;
    apagaSelecionados: boolean;
    i, tipoPergunta: integer;
    nomeArqAtual, nomeAlt: string;

    function estaNaLixeira: boolean;
    var
        salvaDir, dirAtual, dirLixeira: string;
    begin
        estaNaLixeira := false;

        dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
        if dirLixeira = '' then dirLixeira := 'c:\recycled';

        getDir (0, salvaDir);
        {$I-} chdir (dirLixeira);  {$I+}
        if ioresult <> 0 then exit;

        getDir (0, dirAtual);
        if dirAtual = salvaDir then
            estaNaLixeira := true;

        chdir (salvaDir);
    end;

    procedure apagaUm (nomeArq, nomeAlt: string; var tipoPergunta: integer);
    begin
        if tipoPergunta > 0 then
            begin
                mensagem ('DV_CNFAPA', 0);      { 'Confirma remoção de ' }
                sintWrite (nomeArq);
                write ('?  ');

                if tipoPergunta = 1 then
                    mensagem ('DV_SIMNAO', 0)   { ' (S/N)? ' }
                else
                    mensagem ('DV_SNTOD', 0);   { 'Sim, não ou todos? ' }

                c := popupMenuPorLetra('SNT');
                if c = 'T' then
                    tipoPergunta := 0
                else
                if c = ESC then
                    begin
                        tipoPergunta := 3; //Para cancelar o apagar arquivos selecionados.
                        exit;
                    end
                else
                    if c <> 'S' then exit;
            end;

        if guardaLixeira and (not estaNaLixeira) then
            copiaRapidaLixeira (nomeArq);

        if not FileExists(nomeAlt) then nomeAlt := nomeArq;
        if FileExists(nomeAlt) then
            if not deleteFile (nomeAlt) then
                begin
                    mensagem ('DV_PROTEG', 1);      { 'Arquivo está protegido para regravação' }
                    exit;
                end;

        if i <= numArqAtual then numArqAtual := numArqAtual -1;
        if tipoPergunta <> 0 then
            mensagem ('DV_FOIAPA', 1);      { 'Apaguei o arquivo '}
    end;


var
    nomeArq: string;
begin
    apagaSelecionados := false;
    if temSelecionados then
        begin
            mensagem ('DV_APGSELEC', 0);    {'Apaga todos os selecionados? '}
            c := popupMenuPorLetra('SN');
            if c = ESC then
                begin
                    mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                    exit;
                end
            else
                apagaSelecionados := c = 'S';
        end;

    if (numArqAtual >= 0) and (numArqAtual < listArquivos.count) then
        begin
            nomeArqAtual := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
            nomeAlt := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cAlternateFileName;
        end
    else
        nomeArqAtual := '';

    tipoPergunta := 2;
    if apagaSelecionados then
        begin
            for i := listArquivos.count-1 downto 0 do
                if PMySearchRec(listArquivos[i]).marcado then
                    begin
                        nomeArq := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                        nomeAlt := PMySearchRec(listArquivos[i]).sr.FindData.cAlternateFileName;
                        apagaUm (nomeArq, nomeAlt, tipoPergunta);
                        if tipoPergunta = 3 then //Cancelou apagamento
                            begin
                                mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                                break;
                            end;
                    end;
        end
    else
        begin
            tipoPergunta := 1;
            apagaUm (nomeArqAtual, nomeAlt, tipoPergunta);
        end;

    recriaLista (masc, atrib, tipoOrd);

    if numArqAtual < 0 then numArqAtual := 0
    else if numArqAtual >= listArquivos.count then numArqAtual := listArquivos.count -1;
end;

{--------------------------------------------------------}

function checaNome (s: string; mudo: boolean): boolean;
begin
    checaNome := true; //Sem problema no nome
    if  (pos ('`', s) <> 0) or
        (pos ('´', s) <> 0) or
        (pos ('~', s) <> 0) or
        (pos ('/', s) <> 0) or
        (pos ('^', s) <> 0) then
            begin
                if not mudo then
                    begin
                        sintclek;
                        mensagem ('DV_NOARQMAU', 1);  {'Nome de Arquivo mal formado, sugiro trocar o nome.'}
                        sintclek;
                    end;
                checaNome := false;
            end;
end;

{--------------------------------------------------------}

function acertaNome (s: string): string;
var i: integer;
begin
    acertaNome := s;
    if checaNome (s, true) then exit;
    i := 1;
    While (s <> '') and (i < length(s)) do
        if s[i] in ['`', '´', '~', '^'] then delete(s, i, 1)
        else if s[i] = '/' then s[i] := '-'
        else inc(i);

    if (trim(s) <> '') and (s[1] <> '.') then
        acertaNome := s;
end;

{--------------------------------------------------------}

procedure trocaNomeArquivo (nomeArq, nomeAlt: string; acertarNome: boolean);
var novoNome: string;
    arq: file;
    c: char;
begin
    if not acertarNome then
        begin
            garanteEspacoTela (2);
            mensagem ('DV_EDITRO', 1);      { 'Edite o novo nome' }
            novoNome := nomeArq;
            c := sintEdita (novoNome, wherex, wherey, 255, true);
            if (c = ESC) or (novoNome = '') then
                exit;
            writeln (novoNome);
        end
    else
        novoNome := acertaNome (nomeArq);

    if novoNome = nomeArq then exit;

    if not FileExists(nomeAlt) then nomeAlt := nomeArq;
    assignFile (arq, nomeAlt);
    {$I-} rename (arq, novoNome);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('DV_PROTEG', 0);      { 'Arquivo está protegido para regravação' }
            write (' ');
            mensagem ('DV_OUJAEXI', 1);  { 'ou já existe' }
            exit;
        end;

    mensagem ('DV_TROCAD', 0);          { 'Troquei o nome do arquivo para ' }
    sintWriteln (novoNome);

    if not acertarNome then
        recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure acertaNomeArquivo (nomeArq, nomeAlt: string);
var
    i: integer;
    c: char;
    selecionados, corrigeAuto: boolean;
begin
    mensagem ('DV_COAUNO', 0); {'Corrijo automaticamente o nome do arquivo?'}
    c := popupMenuPorLetra ('SN');

    if c = ESC then
        begin
            mensagem ('DV_DESIST', 1); {'Desistiu...'}
            exit;
        end;
    corrigeAuto := upcase(c) = 'S';

    selecionados := false;
    if temSelecionados then
        repeat
            mensagem ('DV_VARSEL', 0); {'Vários arquivos estão selecionados, processo todos? '}
            c := popupMenuPorLetra('SN');
            if c = ESC then
                begin
                    mensagem ('DV_OPCANCEL', 2);    { 'Certo, operação foi cancelada' }
                    exit;
                end
            else
                selecionados := c = 'S';
        until c in ['S', 'N'];

    if selecionados then
        begin
            for i := 0 to listArquivos.count-1 do
                if PMySearchRec(listArquivos[i]).marcado then
                    begin
                        nomeArq := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                        nomeAlt := PMySearchRec(listArquivos[i]).sr.FindData.cAlternateFileName;
                        trocaNomeArquivo (nomeArq, nomeAlt, corrigeAuto);
                    end;
        end
    else
        trocaNomeArquivo (nomeArq, nomeAlt, corrigeAuto);

    mensagem ('DV_OK', -1); {'Ok ! '}
    recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure copiaArquivo;
var recriar: boolean;
begin
    fazCopias (numArqAtual, recriar);
    if recriar then
        recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure imprimeArquivo;
var nomearq: string;
begin
    nomearq := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
    fazImpressao (nomearq);
end;

{--------------------------------------------------------}
procedure editaLeUmArquivo (nomeArq: string; opcao: integer); overload; { 0: Editar --- 1: Ler }
var
    nomeDir: string;
    nomeProg: string;
    ext, _ext_: string;
begin
    ext := maiuscAnsi (ExtractFileExt(nomeArq));
    if (ext <> '') and (ext[1] = '.') then delete (ext, 1, 1);

    nomeProg := '';
    case opcao of
        0:  nomeProg := sintAmbiente ('DOSVOX', 'EDITAR.' + ext);
        1:  nomeProg := sintAmbiente ('DOSVOX', 'LER.'    + ext);
    end;
    if nomeProg <> '' then
    begin
        // Extensão indicada nas seções EDITAR | LER
        getdir (0, nomeDir);
        if pos (' ', nomeArq) <> 0 then
            nomeArq := '"' + nomeArq + '"';
        if executaPrograma (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
            esperaProgVoltar;
        exit;
    end;

    _ext_ := '|'+ext+'|';
    if (opcao = 0) and (pos (_ext_, '|BMP|JPG|M4A|MID|MP4|WMA|') <> 0) then
    begin
        mensagem ('DV_ERRNAOED', 1);    { 'Este arquivo não pode ser editado.' }
        exit;
    end;
    if pos (_ext_, '|7Z|ARJ|GZ|RAR|ZIP|') <> 0 then
    begin
        mensagem ('DV_ERRZIP', 1);      { 'Este é um arquivo compactado. Use a função executar.' }
        exit;
    end;
    if pos (_ext_, '|BIN|DLL|EXE|COM|ISO|') <> 0 then
    begin
        mensagem ('DV_ERRNAOTXT', 1);    { 'Este arquivo não pode ser processado textualmente.' }
        exit;
    end;

    // Extensão não encontrada nas seções EDITAR | LER
    if pos (_ext_, '|DOC|DOCX|') <> 0 then
        editarLerArquivo (nomeArq, 0, '')
    else
    if (opcao = 0) and (pos (_ext_, '|MP3|WAV|') <> 0) then
        editarSom (nomeArq)
    else
    if (opcao = 1) and (pos (_ext_, '|M4A|MID|MP3|WAV|WMA|') <> 0) then
        tocarMidia (nomeArq)
    else
        editarLerArquivo (nomearq, opcao, '');
end;

{--------------------------------------------------------}
procedure editaLeUmArquivo (opcao: integer); overload;    { 0: Editar --- 1: Ler }
begin
    editaLeUmArquivo (PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName, opcao);
end;

{--------------------------------------------------------}

procedure editaLeArquivo (opcao: integer);      { 0: Editar --- 1: Ler }
var salva, i: integer;
    c: char;
begin
    if not temSelecionados then
        begin
            editaLeUmArquivo (opcao);
            exit;
        end;

    mensagem ('DV_VARSEL', 0);   {'Vários arquivos estão selecionados, processo todos? '}
    c := popupMenuPorLetra('SN');
    case c of
        ESC:  mensagem ('DV_OPCANCEL', 2);      { 'Certo, operação foi cancelada' }
        'N':  editaLeUmArquivo (opcao);
    else
        salva := numArqAtual;
        for i := 0 to listArquivos.count-1 do
            if PMySearchRec(listArquivos[i]).marcado then
                begin
                    numArqAtual := i;
                    sintBip;
                    sintWriteln (PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName);
                    while sintFalando do
                        if keypressed and (readkey = ESC) then
                            break;
                    editaLeUmArquivo (opcao);
                end;
        writeln;
        numArqAtual := salva;
    end;
end;

{--------------------------------------------------------}

function tocaArquivos(dirMusic, extensao: string): boolean;
var
    nomeProg, nomeArq: string;
    arq: text;
    _ext_: string;

    function criaNomeArqTemp: string;
    var
        tempPath: array [0..144] of char;
    begin
        getTempPath (144, tempPath);
        criaNomeArqTemp := strPas(tempPath) + '\MusicList.m3u';
    end;

    procedure montaListaMusic;
    var
        i: integer;
        nArqAux: string;
    begin
        if dirMusic[Length(dirMusic)] <> '\' then dirMusic := dirMusic + '\';
        for i := 0 to listArquivos.count-1 do
            if PMySearchRec(listArquivos[i]).marcado then
                begin
                    nArqAux := PMySearchRec(listArquivos[i]).sr.FindData.cFileName;
                    if  (nArqAux <> '.') and (nArqAux <> '..') and
                     ((pos ('.MP3',maiuscansi(nArqAux)) = length (nArqAux) - 3) or
                      (pos ('.WAV',maiuscansi(nArqAux)) = length (nArqAux) - 3) or
                      (pos ('.WMA',maiuscansi(nArqAux)) = length (nArqAux) - 3) or
                      (pos ('.M4A',maiuscansi(nArqAux)) = length (nArqAux) - 3) or
                      (pos ('.MID',maiuscansi(nArqAux)) = length (nArqAux) - 3)) then
                        begin
                            {$I-} writeln(arq, dirMusic + nArqAux); {$I+}
                            if ioresult <> 0 then
                                mensagem  ('DV_ERRMID', 2);  {'Não consegui gerar a lista de mídias.'}
                        end;
                end;
    end;

begin
    _ext_ := '|'+maiuscansi(extensao)+'|';
    tocaArquivos := false;
    if (not temSelecionados) or (pos(_ext_, '|MP3|WAV|WMA|M4A|MID|') = 0) then
        exit;

    nomeArq := criaNomeArqTemp;
    mensagem ('DV_UMMOMENTO', 1);   {'Um momento...'}
    assign (arq, nomeArq);
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        mensagem  ('DV_ERRMID', 2)  {'Não consegui gerar a lista de mídias.'}
    else
        begin
            montaListaMusic;
            {$i-} close (arq); {$i+}
            if ioresult <> 0 then
                mensagem  ('DV_ERRMID', 2)  {'Não consegui gerar a lista de mídias.'}
            else
                begin
                    nomeProg := sintAmbiente ('DOSVOX', 'PROG.M3U');
                    if nomeProg = '' then
                        begin
                            nomeProg := nomeArq;
                            nomeArq := '';
                        end;
                    if pos (' ', nomeArq) <> 0 then
                        nomeArq := '"' + nomeArq + '"';

                    if executaPrograma (nomeProg, '', nomeArq, SW_SHOWNORMAL) then
                        esperaProgVoltar;
                end;
            limpaBufTec;
            mensagem ('DV_OK', 1);      { 'Ok ! '}
        end;
    tocaArquivos := true;
end;

{--------------------------------------------------------}

procedure executaArquivo (executaSistOp: boolean);
var
    extensao: string;
    nomeProg, nomearq, nomeDir: string;
begin
    nomearq := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
    extensao := maiuscAnsi (ExtractFileExt(nomeArq));
    if (extensao <> '') and (extensao[1] = '.') then delete (extensao, 1, 1);
    getdir (0, nomeDir);

    if extensao = '' then
        begin
            editaLeArquivo (1);
            exit;
        end;

    if temSelecionados then
        if tocaArquivos(nomeDir, extensao) then exit;

    if (extensao = 'EXE') or (extensao = 'COM') then
        begin
            if nomeDir [length (nomeDir)] = '\' then
                nomeProg := nomedir + nomeArq
            else
                nomeProg := nomedir + '\' + nomeArq;
            nomeArq := '';
        end
    else
        begin
            if executaSistOp then
                nomeProg := ''
            else
                nomeProg := sintAmbiente ('DOSVOX', 'PROG.' + extensao);
            if nomeProg = '' then
                begin
                    nomeProg := nomeArq;
                    nomeArq := '';
                end;
    end;

    if pos (' ', nomeArq) <> 0 then
        nomeArq := '"' + nomeArq + '"';

    while sintFalando do waitMessage;
    if executaPrograma (nomeProg, nomeDir, nomeArq, SW_SHOWNORMAL) then
        esperaProgVoltar;

    while sintFalando do waitMessage;
    recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure selecaoPorMascara;
begin
    mensagem ('DV_MASC', 1);        {'Informe a máscara de seleção, p. ex., *.TXT' }
    sintReadln (masc);
    if (masc = '') or (masc[1] = ' ') then
        masc := '*.*';

    recriaLista (masc, atrib, tipoOrd);
    numArqAtual := 0;

    mensagem ('DV_TROCMASC', 0);    { 'Troquei a máscara de seleção de arquivos para ' }
    soletra (masc, 1);
    mensagem ('DV_NUMARQD', 0);     { 'Número de arquivos neste diretório: ' }
    sintWriteInt (listArquivos.count);
    writeln;
end;

{--------------------------------------------------------}

procedure copiaTransfSelec (comDir: boolean);
var i: integer;
    s, dir: string;
begin
    s := '';
    if comDir then
        begin
            getdir (0, dir);
            if dir [length(dir)] <> '\' then
                dir := dir + '\';
        end;

    for i := 0 to listArquivos.count-1 do
        begin
            if PMySearchRec(listArquivos[i]).marcado then
                 s := s + dir + PMySearchRec(listArquivos[i]).sr.Name + #$0d + #$0a;
        end;
    if s = '' then
        if numArqAtual >= 0 then
            s := s + dir + PMySearchRec(listArquivos[numArqAtual]).sr.Name + #$0d + #$0a;

    putClipBoard(@s[1]);
    sintclek;
end;

{--------------------------------------------------------}

procedure informaDiretorio;
var dir: string;
begin
    getDir (0, dir);
    sintwriteln (dir);
end;

{--------------------------------------------------------}

procedure reordena (mudarPadrao: boolean);
var c: char;
begin
    if mudarPadrao then mensagem ('DV_ALTERAR', 1);  {'Alterar'}
    mensagem ('DV_TIPORD', 0);  {'Ordena por Nome, Extensao, Tamanho ou Data? '}
    c := popupMenuPorLetra('NETD');
    if c = ESC then
        begin
            mensagem ('DV_OPCANCEL', 2);        { 'Certo, operação foi cancelada' }
            exit;
        end;

    case c of
        'E': tipoOrd := 1;
        'T': tipoOrd := 2;
        'D': tipoOrd := 3;
    else
        tipoOrd := 0;
    end;

    if mudarPadrao then sintGravaAmbiente('DOSVOX', 'TIPOORDENACAOARQ', intToStr(tipoOrd));
    numArqAtual := 0;
    recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure copiaArqUsandoTransf (movendo: boolean);
begin
    copiaUsandoTransf (movendo);
    recriaLista (masc, atrib, tipoOrd);
end;

{--------------------------------------------------------}

procedure trataArquivos (nomeJanelaComDir: boolean; var vaiParaSubdiretorios: boolean);
var
    c, c2: char;
    ymin, i: integer;
    nomeArq, nomeAlt: string;
    dir: string;
    fator, dummy, erro: integer;
    apertouShift: boolean;
    totalNumDir: longInt;

const
    OPCAOEXIGEARQUIVO: set of char = [
        'E', 'C', 'L', 'I', 'P', ^P, 'X', ^A, ^R, 'A', 'R', 'D', 'N', 'M', 'Z', ^C, ^N, ^M, {CTLENTER} ^j, 'U', ^u];

label executaFunc;
begin
    vaiParaSubdiretorios := false;

    listArquivos := NIL;
    masc := '*.*';
    atrib := faArchive;
    val (sintAmbiente ('DOSVOX', 'TIPOORDENACAOARQ', '0'), tipoOrd, erro);
    if (erro <> 0) or (not (tipoOrd in [0, 1, 2, 3])) then tipoOrd := 0;

    getDir (0, dir);
    if nomeJanelaComDir then
        setWindowTitle('Arquivos - ' + dir);

    if isAudioCd (dir[1]) then
        mensagem ('DV_AUDIOCDDETEC', 1)         {'Audio CD foi detectado'}
    else
        if DiskSize(0) < 1 then
            begin
                mensagem ('DV_DISCOREMOV', 2);   {'Disco foi removido.'}
                exit;
            end;

    if upcase(sintAmbiente('DOSVOX', 'FALARTOTALDIR', 'SIM')[1]) <> 'N' then
        begin
            recriaLista (masc, faDirectory, tipoOrd);
            totalNumDir := listArquivos.count;
        end
    else
        totalNumDir := 0;

    recriaLista (masc, atrib, tipoOrd);
    if (upcase(sintAmbiente('DOSVOX', 'FALARTOTALARQ', 'SIM')[1]) <> 'N') and (listArquivos.count > 0) then
        begin
            if sintFalarTudo then
                begin
                    mensagem ('DV_NUMARQ', 0);      { 'Número de arquivos: ' }
                    sintWriteInt (listArquivos.count);
                end
            else
                begin
                    write (pegaTextoMensagem('DV_NUMARQ'));      { 'Número de arquivos: ' }
                    sintWriteInt (listArquivos.count);
                    mensagem ('DV_ESCARQ', -1); {'Arquivos - '}
                end;
            writeln;
        end;

    if totalNumDir > 0 then
        begin
            if sintFalarTudo then
                begin
                    mensagem ('DV_NUMPAST', 0);     { 'Número de pastas:   ' }
                    sintWriteInt (totalNumDir);
                end
            else
                begin
                    write (pegaTextoMensagem('DV_NUMPAST'));     { 'Número de pastas:   ' }
                    sintWriteInt (totalNumDir);
                    mensagem ('DV_PASTAS', -1);     { 'Pastas - ' }
                end;
            writeln;
        end;

    textBackground (RED);
    if sintFalarTudo then
        mensagem ('DV_ARQ1', 0)               { 'Arquivos: use as setas para selecionar.' }
    else
        write (pegaTextoMensagem('DV_ARQ1')); { 'Arquivos: use as setas para selecionar.' }
    textBackground (BLACK); clreol;
    writeln;
    if sintFalarTudo and (not keypressed) then
        mensagem ('DV_ARQ2', 1);    { 'Depois tecle sua opção.' }

    limpabuf;
    numArqAtual := 0;

    amplPegaConfig(fator, dummy, dummy, dummy);
    repeat
        ymin := 25-listArquivos.count+1;
        if ymin <= fator then ymin := fator+1;
        if ymin < 1 then ymin := 1;
        preparaTelaArq (41, ymin, 79, 25);

        salvaTelaArq;
        escolheFuncaoListArq (numArqAtual, c, c2);
        recuperaTelaArq;
        apertouShift := getKeyState (vk_Shift) < 0;

executaFunc:
        if ((numArqAtual >= 0) and (numArqAtual < listArquivos.count)) or
                 not (upcase(c) in OPCAOEXIGEARQUIVO)  then
            begin
                if numArqAtual >= 0 then
                    begin
                        nomeArq := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName;
                        nomeAlt := PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cAlternateFileName;
                    end;

                if c = #$0 then
                    case c2 of
                        CTLDIR: dadosArquivo (true, false);
                        CTLESQ: dadosArquivo (true, true);

                        F1: ajudaArquivos;
                        F2: trocaNomeArquivo (nomeArq, nomeAlt, false);
                        CTLF2: acertaNomeArquivo (nomeArq, nomeAlt);
                        F7, DEL:
                                begin
                                    c := 'r';
                                    goto executaFunc;
                                end;
                        F8:     begin
                                    falaHora;
                                    if not keypressed then delay (150);
                                end;
                        CTLF8:  begin
                                    falaDia;
                                    if not keypressed then delay (150);
                                end;
                        F9:     begin
                                    write (#$0d, nomeArq, #$0d);
                                    c := selSetasArquivo;
                                    goto executaFunc;
                                end;
                    end
                else
                    begin
                        if not (c in [GOTFOCUS, ESC]) then
                            begin
                                if upcase(c) in OPCAOEXIGEARQUIVO then
                                    write (PMySearchRec(listArquivos[numArqAtual]).sr.FindData.cFileName, ' ');
                                if sintEcoarOpcao and (not (upcase(c) in [#0..#31 {ENTER, #$0}, ' ', 'Q'])) then
                                    begin
                                        write ('-> ');
                                        mensagem ('DV_OPCAO', 0);   { ' opção ' }
                                        soletra (c, 1);
                                    end
                                else
                                    writeln;
                            end;

                         if not(upcase(c) in ['Q', ^Q, 'A', ^A, 'R', ^R, ESC, 'V']) then checaNome (nomeArq, false);
                         case upcase(c) of
                             'E': editaLeArquivo (0);
                             'C': copiaArquivo;
                             'L': editaLeArquivo (1);
                             'I': imprimeArquivo;
                             'P': protegeArquivo (false);
                             ^P : protegeArquivo (true);
                  {ENTER} 'X',^m: executaArquivo (false);
                  {CTLENTER}  ^j: executaArquivo (true);
                          ^A,^R : removeArquivo (false);
                         'A','R': removeArquivo (true);
                             'D': dadosArquivo (false, false);
                             'H': dadosArquivo (true, false);
                             'N': trocaNomeArquivo (nomeArq, nomeAlt, false);
                             ^N : copiaTransfSelec (false);
                             ^C, ^X :  begin
                                        copiaTransfSelec (true);
                                        moverObjetos := c = ^X;
                                   end;
                             ^V :  begin
                                        copiaArqUsandoTransf (moverObjetos);
                                        moverObjetos := false;
                                   end;
                         'O', ^O: reordena (c = ^O);
                         'Q', ^Q: falaQualItemDeQuantos (numArqAtual+1, c = ^Q, listArquivos);

                             'M': enviaEmail;
                             'V': for i := (numArqAtual+1) to listArquivos.count-1 do
                                        if not checaNome (PMySearchRec(listArquivos[i]).sr.FindData.cFileName, false) then
                                            begin
                                                numArqAtual := i;
                                                break;
                                            end
                                        else if i =  listArquivos.count-1 then begin sintclek; sintclek; end;

                             'U': if converterArquivo (numArqAtual, false) then recriaLista (masc, atrib, tipoOrd);
                             ^U : if converterArquivo (numArqAtual, true) then recriaLista (masc, atrib, tipoOrd);
                             'Z': criaZip;

                             'G':  selecaoPorMascara;
                             'F', ^F: procuraArquivo (c = ^F);

                             'B':  procuraConteudo (false);
                             ^B :  procuraConteudo (true);
                             'T':  tamanhoTodosArq (false);
                             ^T :  tamanhoTodosArq (true);
                             ^S :  for i := 0 to listArquivos.count-1 do
                                       PMySearchRec(listArquivos[i]).marcado := true;

                             ^D :  if apertouShift then dadosArquivo (true, false)
                                   else informaDiretorio;
                             'S':  begin
                                      vaiParaSubdiretorios := true;
                                      c := ESC;
                                  end;

                             GOTFOCUS: ;
                             ESC: ;
                         else
                             begin
                                 mensagem ('DV_OPCINV', 1);     { 'Opção inválida.' }
                                 if not (keypressed) then
                                     mensagem ('DV_SEF1', 1);   { 'Aperte F1 para ajuda.' }
                             end;
                         end;

                         limpabuf;
                         if not (upcase(c) in [ESC, 'B', ^B, 'F', ^F, ^S, 'V']) then
                             begin
                                 writeln;
                                 textBackground (RED);
                                 if sintFalarTudo then
                                    mensagem ('DV_CONTSEL', 0)    { 'Continue selecionando ou tecle ESC' }
                                 else
                                    write (pegaTextoMensagem('DV_CONTSEL'));    { 'Continue selecionando ou tecle ESC' }
                                 textBackground (BLACK);
                                 writeln;
                             end;
                    end;
            end
        else
            begin
                if c <> ESC then
                    begin
                        mensagem ('DV_NAOSELEC', 1);    { 'Não posso fazer: não existe nenhum arquivo selecionado.' }
                        while sintFalando do waitMessage;
                    end;
            end;

    until c = ESC;

    liberaListArq;
    if sintFalarTudo and (not vaiParaSubdiretorios) then
    mensagem ('DV_OK', 2);      { 'Ok ! '}
end;

begin
end.
