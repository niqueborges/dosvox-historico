{----------------------------------------------------------}
{  Gravavox e MiniGrav: Módulo de tratamento das amostras  }
{  Autor: José Antonio Borges                              }
{  Em fev/2006                                             }
{----------------------------------------------------------}

unit gramost;

interface
uses sysutils, mmsystem, dvwav, dvGrav, dvCrt;

type
    TStereo16 = packed record
        left, right: smallInt;
    end;

const
    SILENCIO: TStereo16 = (left: 0; right: 0);

type
    TAmostras = class
    private
        FVetAmostras: packed array of smallInt;  // 16 bits
        FNumAmostras: integer;
        FMaxMemoria: integer;
        FFaltaDeMemoria: boolean;

        FCanais: integer;
        FVelocidade: integer;
        FBitsporAmostra: integer;

        FAmostrasAlocadas: integer;
        FAmostrasTocadas: integer;

        FNBufGravacao: integer;

        function realocaMemoria (novaAlocacao: integer): boolean;
        function get_amostra (n: integer): TStereo16;
        procedure set_amostra (n: integer; amostra: TStereo16);

        procedure set_canais (nCanais: integer);
        procedure set_velocidade (velocidade: integer);
        procedure set_bitsPorAmostra (nBits: integer);
        procedure set_nBufGravacao(nbuf: integer);

    public
        constructor Create;
        constructor CriaSilencio (nCanais, velocidade, nBits, nAmostras: integer);
        constructor Clone (origem: TAmostras);
        destructor Free;

        property numAmostras: integer read FNumAmostras;

        procedure zera;
        procedure removeTrecho(inicial, aRemover: integer);
        procedure abreTrecho(inicial, aIncluir: integer);

        function leArquivo (filename: string): boolean;
        function gravaArquivo (filename: string): boolean;
        function adiciona(novasAmostras: TAmostras): boolean;
        function mistura(novasAmostras: TAmostras; posicao: integer;
                        fatorAtual, fatorMistura: real): boolean;

        procedure rampa (inicio, fim: integer; fator1, fator2: real);

        procedure reamostra(origem: TAmostras; novaVelocidade: integer);

        procedure paraDeTocar;
        procedure toca(n1, numAmostras: integer);
        procedure tocaTudo;
        function grava (nomeArq: string): boolean;
        function estaTocando: boolean;

        property faltaDeMemoria: boolean read FFaltaDeMemoria;
        property maxMemoria: integer read FMaxMemoria write FMaxMemoria;

        property amostra [n: integer]: TStereo16
                          read get_amostra write set_amostra;

        property canais: integer read FCanais write set_canais;
        property velocidade: integer read FVelocidade write set_velocidade;
        property bitsPorAmostra: integer read FBitsporAmostra write set_BitsPorAmostra;

        property tocando: boolean read estaTocando;
        property amostrasTocadas: integer read FAmostrasTocadas;
        property nBufGravacao: integer read FNBufGravacao write set_nBufGravacao;
    end;

    function criaAmostra (esq, dir: integer): TStereo16;
    procedure separaCanais (amostra: TStereo16; var esq, dir: integer);

implementation


function criaAmostra (esq, dir: integer): TStereo16;
var a: TStereo16;
begin
    a.left := esq;
    a.right := dir;
    result := a;
end;

function clamp (x: integer): integer;
begin
    if x > 32767 then x := 32767
    else
    if x < -32768 then x := -32768;
    result := x;
end;

procedure separaCanais (amostra: TStereo16; var esq, dir: integer);
begin
    esq := amostra.left;
    dir := amostra.right;
end;

{ TAmostras }

constructor TAmostras.Create;
begin
    FCanais := 1;
    FVelocidade := 22050;
    FBitsporAmostra := 16;

    FNBufGravacao := 4;
end;

function TAmostras.realocaMemoria (novaAlocacao: integer): boolean;
begin
    realocaMemoria := false;
    FFaltaDeMemoria := true;
    if (maxMemoria > 0) and (maxMemoria < novaAlocacao) then
        exit;

    try
        SetLength (FVetAmostras, novaAlocacao);
        realocaMemoria := true;
        FFaltaDeMemoria := false;
    except
    end;
end;

constructor TAmostras.CriaSilencio (nCanais, velocidade, nBits, nAmostras: integer);
var i: integer;
begin
    FCanais := nCanais;
    FVelocidade := velocidade;
    FBitsporAmostra := nBits;

    FNBufGravacao := 4;

    FAmostrasAlocadas := nAmostras;
    if not realocaMemoria (nAmostras * FCanais) then exit;

    for i := 0 to nAmostras-1 do
        amostra[i] := SILENCIO;
end;

constructor TAmostras.Clone (origem: TAmostras);
var i: integer;
begin
    zera;
    FCanais := origem.canais;
    FVelocidade := origem.velocidade;
    FBitsporAmostra := origem.bitsPorAmostra;

    amostra[origem.numAmostras-1] := SILENCIO;   // pré-aloca memória
    for i := 0 to origem.numAmostras-1 do
        amostra[i] := origem.amostra[i];
end;

procedure TAmostras.zera;
begin
    if FAmostrasAlocadas <> 0 then
        begin
            paraDeTocar;
            FVetAmostras := NIL;
            FAmostrasAlocadas := 0;
            FNumAmostras := 0;
        end;
end;

destructor TAmostras.Free;
begin
    zera;
end;

function TAmostras.get_amostra(n: integer): TStereo16;
begin
    if (n < 0) or (n >= FNumAmostras) then
        result := SILENCIO
    else
    if FCanais = 1 then
        result := criaAmostra (FVetAmostras[n], FVetAmostras[n])
    else
        result := criaAmostra (FVetAmostras[n*2], FVetAmostras[n*2+1]);
end;

procedure TAmostras.set_amostra(n: integer; amostra: TStereo16);
var novoTam: integer;
    i: integer;
begin
    if n < 0 then exit;

    if n >= FAmostrasAlocadas then
        begin
            if n < 25000 then
                novoTam := 30000
            else
                novoTam := trunc (n * 1.2);

            if not realocaMemoria (novoTam * FCanais) then exit;

            if FCanais = 1 then    // zera amostras
                for i := FAmostrasAlocadas to novoTam-1 do
                    FVetAmostras[i] := 0
            else
                for i := FAmostrasAlocadas to novoTam-1 do
                    begin
                        FVetAmostras[i*2] := 0;
                        FVetAmostras[i*2+1] := 0;
                    end;

            FAmostrasAlocadas := novoTam;
        end;

    if FCanais = 1 then
        FVetAmostras[n] := (integer(amostra.left) + amostra.right) div 2
    else
        begin
            i := n * 2;
            FVetAmostras[i] := amostra.left;
            FVetAmostras[i+1] := amostra.right;
        end;

    if FNumAmostras < n then FNumAmostras := n;
end;

procedure TAmostras.removeTrecho(inicial, aRemover: integer);
var i, aMover: integer;
begin
    if (inicial < 0) or (FNumAmostras = 0) then exit;
    if inicial+aRemover > FNumAmostras then
        aRemover := FNumAmostras-inicial;

    aMover := FnumAmostras - (inicial+aRemover);
    for i := 0 to aMover-1 do
        amostra [inicial+i] := amostra [inicial+i+aRemover];

    FnumAmostras := FNumAmostras - aRemover;
    if realocaMemoria (FNumAmostras * FCanais) then
        FAmostrasAlocadas := FNumAmostras;
end;

procedure TAmostras.abreTrecho(inicial, aIncluir: integer);
var i, final: integer;
begin
    if (inicial < 0) or (FNumAmostras = 0) then exit;
    if inicial > FNumAmostras then
        inicial := FNumAmostras;

    final := FNumAmostras-1;
    amostra[final+aIncluir] := SILENCIO;   { abre o espaço, atualiza FNumAmostras }

    for i := final downto inicial do
        amostra [i+aIncluir] := amostra [i];
    for i := inicial to inicial+aIncluir-1 do
        amostra [i] := SILENCIO;
end;

function TAmostras.leArquivo(filename: string): boolean;
const
    MAXBUFSIZE = 65534;

var
    f: integer;
    ioOk: boolean;
    size, soundSize: longint;
    transf: integer;
    lpFormat: PPCMWAVEFORMAT;
    achou: boolean;
    soundBuffer: pchar;
    quantAmostras: longint;
    i: integer;
    pvet: pchar;
    smint: array[0..MAXBUFSIZE-1 div 2] of smallInt;

label fim;
begin
    result := false;

    // tratamento do cabeçalho

    f := FileOpen(fileName, fmOpenRead or fmShareDenyNone);
    if f < 0 then exit;

    zera;
    ioOk := false;

    getMem (soundBuffer, MAXBUFSIZE);

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
            FVelocidade := nSamplesPerSec;
            FBitsporAmostra := wBitsPerSample;
            FCanais := nChannels;
        end;

    repeat
        transf := fileRead (f, soundBuffer^, 8);     { ignora chunks até data }
        if transf < 8 then goto fim;
        achou := strlicomp (soundBuffer, 'data', 4) = 0;
        move (soundBuffer[4], size, 4);
        if not achou then
            begin
               transf := fileRead (f, soundBuffer^, size);     { checa fmt }
               if size <> transf then goto fim;
            end;
    until achou;

    // alocação de memória para conter o arquivo

    quantAmostras := size div (FCanais * (FBitsporAmostra div 8));
    if size = 0 then
        begin
            iook := true;
            goto fim;
        end;

    amostra [quantAmostras-1] := SILENCIO;   // ao alterar a última posição, tudo é alocado
    if faltaDeMemoria then
         goto fim;                           // impossível alocar tanto

    pvet := @FVetAmostras[0];

    // processamento das amostras do arquivo

    soundSize := size;

    ioOk := false;
    while soundSize > 0 do
        begin
            if (size >= soundSize) and (size <= MAXBUFSIZE) then
                size := soundSize
            else
                size := MAXBUFSIZE;
            soundSize := soundSize - size;

            transf := fileRead (f, soundBuffer^, size);
            ioOk := transf = size;
            if transf = 0 then break;

            if FBitsporAmostra = 8 then
                begin
                    for i := 0 to size-1 do    // transforma em 16 bits
                        smint[i] := (ord(soundBuffer[i]) - 128) shl 8;
                    move (smint, pvet^, size*2);
                    inc (pvet, size*2);
                end
            else
                begin
                    move (soundBuffer^, pvet^, size);   // conveniente para 16 bits
                    inc (pvet, size);
                end;
        end;

fim:
    freeMem (soundBuffer, MAXBUFSIZE);
    fileClose (f);
    result := ioOk;
end;

{-------------------------------------------------------------}
{             gera um cabecalho de arquivo .WAV
{-------------------------------------------------------------}

procedure genWavHdr (pvet: pchar; veloc: longint; bits, channels: word; size: longint);
const
    wavHdr: array [0..43] of byte = (
        $52, $49, $46, $46,    {'RIFF'}
        $ff, $ff, $ff, $ff,    {riff size}
        $57, $41, $56, $45, $66, $6d, $74, $20,    {'WAVEFMT '}
        $10, $00, $00, $00,    {hdr size}
        $01, $00, $01, $00, $11, $2b, $00, $00, $11, $2b, $00, $00, $01, $00, $08, $00,  {reg}
        $64, $61, $74, $61,    {'data'}
        $ff, $ff, $ff, $ff);   {data size}

var l: longint;
    p: pointer;
    lpFormat: PPCMWAVEFORMAT;

begin
    new (lpFormat);
    with lpFormat^, lpFormat^.wf do
        begin
            wFormatTag := WAVE_FORMAT_PCM;
            nSamplesPerSec := veloc;
            wBitsPerSample := bits;
            nChannels := channels;
            nBlockAlign := (wBitsPerSample div 8) * nChannels;
            nAvgBytesPerSec := nBlockAlign * nSamplesPerSec;
        end;

    p := @wavHdr[20];
    move (lpFormat^, p^, sizeof (lpFormat^));
    l := size + 36;
    p := @wavHdr[4];
    move (l, p^, sizeof (l));
    p := @wavHdr[40];
    move (size, p^, sizeof (size));

    move (wavHdr, pvet^, sizeof (wavHdr));
    dispose (lpFormat);
end;

function TAmostras.gravaArquivo(filename: string): boolean;
const MAXBUFSIZE = 32768;
var
    cabecWav: array [0..43] of byte;
    f: integer;
    size: integer;
    aGravar, transf: integer;
    buf: packed array [0..MAXBUFSIZE-1] of byte;
    i: integer;
    p: pchar;
    a: TStereo16;
    bl, br: byte;
label fim;

begin
    result := false;
    f := FileCreate(filename);
    if f < 0 then exit;

    genWavHdr(@cabecWav, FVelocidade, FBitsporAmostra, FCanais,
              FNumAmostras*FCanais*(FBitsporAmostra div 8));
    transf := FileWrite (f, cabecWav, sizeof (cabecWav));
    if transf = 0 then goto fim;

    if FBitsporAmostra = 8 then
        begin
            p := @buf[0];
            for i := 0 to FNumAmostras-1 do
                begin
                    a := amostra[i];
                    if FCanais = 1 then
                        begin
                            bl := ((((integer(a.left) + a.right) div 2) div 256) + 128) and $ff;
                            p^ := chr(bl);  inc (p);
                        end
                    else
                        begin
                            bl := ((a.left shr 8)+ 128) and $ff;
                            p^ := chr(bl);  inc (p);
                            br := ((a.right shr 8) + 128) and $ff;
                            p^ := chr(br);  inc (p);
                        end;

                    if p > @buf[MAXBUFSIZE-1] then
                        begin
                            aGravar := p - @buf[0];
                            p := @buf[0];
                            transf := FileWrite(f, p^, aGravar);
                            if transf <> aGravar then goto Fim;
                        end;
                end;

            if p <> @buf[0] then
                begin
                    aGravar := p - @buf[0];
                    p := @buf[0];
                    transf := FileWrite(f, p^, aGravar);
                    if transf <> aGravar then goto fim;
                end;
        end
    else
        begin
            size := FNumAmostras * (FBitsporAmostra div 8) * FCanais;
            if size > 0 then
                begin
                    p := @FVetAmostras[0];
                    while size > 0 do
                        begin
                            aGravar := size;
                            if aGravar > MAXBUFSIZE then aGravar := MAXBUFSIZE;
                            transf := FileWrite(f, p^, aGravar);
                            if transf <> aGravar then
                                goto fim;
                            inc (p, aGravar);
                            size := size - MAXBUFSIZE;
                        end;
                end;
        end;

    result := true;

fim:
    fileClose (f);
end;

function TAmostras.adiciona(novasAmostras: TAmostras): boolean;
var i: integer;
    n: integer;
begin
    if novasAmostras.FVelocidade <> FVelocidade then
        begin
            result := false;
            exit;
        end;
    result := true;

    n := numAmostras;
    amostra[FNumAmostras+novasAmostras.numAmostras-1] := SILENCIO;  // pré-aloca memória
    for i := 0 to novasAmostras.numAmostras-1 do
        amostra[n+i] := novasAmostras.amostra[i];
end;

function TAmostras.mistura(novasAmostras: TAmostras; posicao: integer;
                        fatorAtual, fatorMistura: real): boolean;
var i: integer;
    a, b: TStereo16;
    vl, vr: integer;
begin
    if (novasAmostras.FVelocidade <> FVelocidade) or
       (posicao > FNumAmostras) then
        begin
            result := false;
            exit;
        end;
    result := true;

    for i := 0 to novasAmostras.numAmostras-1 do
        begin
            a := amostra[posicao+i];
            b := novasAmostras.amostra[i];
            vl := trunc ((a.left  * fatorAtual) + (b.left  * fatorMistura));
            vr := trunc ((a.right * fatorAtual) + (b.right * fatorMistura));
            amostra[posicao+i] := criaAmostra(clamp(vl), clamp(vr));
        end;
end;

procedure TAmostras.set_BitsPorAmostra(nBits: integer);
begin
    FBitsporAmostra := nBits;
end;

procedure TAmostras.set_canais(nCanais: integer);
var
   i: integer;
   a: smallInt;

begin
   if nCanais = FCanais then exit;

   if FCanais = 1 then    // amplia amostras
       begin
           if not realocaMemoria (FNumAmostras*2) then exit;

           if FNumAmostras <> 0 then
               for i := FNumAmostras-1 downto 0 do
                   begin
                       a := FVetAmostras[i];
                       FVetAmostras [i*2] := a;
                       FVetAmostras [i*2+1] := a;
                   end;
           FCanais := 2;
       end
   else
       begin
           if FNumAmostras <> 0 then
               for i := 0 to FNumAmostras-1 do
                   FVetAmostras [i] := (FVetAmostras [i*2] div 2) +
                                       (FVetAmostras [i*2+1] div 2);
           FCanais := 1;
           realocaMemoria (FNumAmostras);
       end;
end;

procedure TAmostras.set_velocidade(velocidade: integer);

begin
    if (velocidade <>   8000) and (velocidade <>   9600) and
       (velocidade <>  11025) and (velocidade <>  12000) and
       (velocidade <>  15000) and (velocidade <>  16000) and
       (velocidade <>  22050) and (velocidade <>  24000) and
       (velocidade <>  32000) and (velocidade <>  44100) and
       (velocidade <>  48000) and (velocidade <>  88200) and
       (velocidade <>  96000) and (velocidade <> 176400) and
       (velocidade <> 192000) and (velocidade <> 352800) and
       (velocidade <> 384000) then
            exit;    // não deixa mudar exceto para valores razoáveis

    FVelocidade := velocidade;
end;

procedure TAmostras.toca(n1, numAmostras: integer);
const
    tamBuf = 2048;
var
    localbuf: packed array [0..tamBuf-1] of TStereo16;
    i, p: integer;

begin
    FAmostrasTocadas := 0;
    if n1+numAmostras-1 > FNumAmostras then exit;

    p := 0;
    for i := 0 to numAmostras-1 do
        begin
            if keyStopsWave and keypressed then exit;

            localbuf[p] := amostra[i+n1];
            p := p + 1;
            if (p >= tamBuf) or (i = numAmostras-1) then
                begin
                    wavePlay (@localBuf, p*4, velocidade, 16, 2);
                    FAmostrasTocadas := i;
                    p := 0;
                end;
        end;
end;

procedure TAmostras.tocaTudo;
begin
    paraDeTocar;
    toca (0, FNumAmostras);
    while waveIsPlaying do delay (100);
end;

function TAmostras.grava (nomeArq: string): boolean;
begin
    result := false;
    if not preparaGravacao (nomeArq, FVelocidade, FBitsporAmostra, FCanais,
                            FNBufGravacao, 512*FBitsPorAmostra*FCanais) = 0 then
        exit;

    iniciaGravacao;                                    
    while (not keypressed) or (readkey <> #$1b) do
        begin
            monitoraGravacao;
            delay (50);
        end;

    terminaGravacao;

    result := leArquivo(nomeArq);
end;

procedure TAmostras.paraDeTocar;
begin
    waveStop;
end;

function TAmostras.estaTocando: boolean;
begin
    result := waveIsPlaying;
end;

procedure TAmostras.reamostra(origem: TAmostras; novaVelocidade: integer);
var
    passo, x, delta: real;
    i, final: integer;
    a1, a2: TStereo16;
    esq1, dir1, esq2, dir2: integer;
begin
    if (velocidade <>   8000) and (velocidade <>   9600) and
       (velocidade <>  11025) and (velocidade <>  12000) and
       (velocidade <>  15000) and (velocidade <>  16000) and
       (velocidade <>  22050) and (velocidade <>  24000) and
       (velocidade <>  32000) and (velocidade <>  44100) and
       (velocidade <>  48000) and (velocidade <>  88200) and
       (velocidade <>  96000) and (velocidade <> 176400) and
       (velocidade <> 192000) and (velocidade <> 352800) and
       (velocidade <> 384000) then
            exit;    // não deixa mudar exceto para valores razoáveis

    zera;
    CriaSilencio(origem.canais, origem.velocidade, origem.bitsPorAmostra, 0);
    if velocidade = novaVelocidade then
        begin
            amostra[origem.numAmostras-1] := SILENCIO;   // pré-aloca memória
            for i := 0 to origem.numAmostras-1 do
                amostra[i] := origem.amostra[i];
            exit;
        end;

    velocidade := novaVelocidade;
    zera;

    passo := origem.velocidade / novaVelocidade;
    final := trunc(origem.numAmostras / passo);
    x := 0;
    amostra[final-1] := SILENCIO;   // pré-aloca memória

    for i := 0 to final-2 do
        begin
            delta := frac(x);
            if delta = 0 then
                amostra[i] := origem.amostra[trunc(x)]
            else
                begin
                    a1 := origem.amostra[trunc(x)];
                    a2 := origem.amostra[trunc(x)+1];
                    separaCanais(a1, esq1, dir1);
                    separaCanais(a2, esq2, dir2);
                    esq1 := trunc (esq1 + delta * (esq2-esq1));
                    dir1 := trunc (dir1 + delta * (dir2-dir1));
                    amostra[i] := criaAmostra(clamp(esq1), clamp(dir1));
                end;
            x := x + passo;
        end;
end;

procedure TAmostras.rampa(inicio, fim: integer; fator1, fator2: real);
var a: TStereo16;
    fatorAmpl, fator: real;
    i: integer;
begin
    if fim <= inicio then exit;

    fatorAmpl := (fator2 - fator1) / (fim - inicio);
    for i := inicio to fim do
        begin
            a := amostra[i];
            fator := fator1 + (fatorAmpl * (i - inicio));
            a.left  := clamp (trunc (a.left  * fator));
            a.right := clamp (trunc (a.right * fator));
            amostra[i] := a;
        end;
end;

procedure TAmostras.set_nBufGravacao(nbuf: integer);
begin
    if nbuf < 2 then nbuf := 2;
    if nbuf > 8 then nbuf := 8;
    FNBufGravacao := nbuf;
end;

end.
