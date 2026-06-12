unit mgGrava;

interface
uses
    dvcrt,
    dvwin,
    mgVars,
    mgArquivo,
    mgmsg,
    gramost,
    windows,
    sysUtils;

procedure novaGravacao;
procedure gravaMais;

implementation

{--------------------------------------------------------}

procedure novaGravacao;
var c, c2: char;
begin
    mensagem ('MGQUERSV', 0);   {'Quer salvar arquivo atual? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
            mensagem ('MGDESIST', 2);  {'Desistiu'}
            exit;
        end;

    if upcase(c) <> 'N' then
        begin
            salvaArquivoRapido;
            veSeSalvaMP3 (nomeArq);
        end;

    som.zera;
    mensagem ('MGNOVSOM', 1);  {'Novo som criado'}
    obtemNomeArquivo (false);
    if not FileExists(nomeArq) then
        gravaSomInicial;
    carregaSom;
end;

{--------------------------------------------------------}

procedure gravaMais;
var c, c2: char;
    som2: TAmostras;
    arqTemp: file;
    nomeTemp, nomeJanela: string;
    pnome, tempPath: array[0..255] of char;
    passo: integer;


begin
    getTempPath (256, tempPath);
    getTempFilename (tempPath, 'WAV', 0, pnome);
    nomeTemp := strPas (pnome);

    som2 := TAmostras.CriaSilencio (som.canais, som.velocidade, som.bitsPorAmostra, 0);
    som2.nBufGravacao := nbufGrava;
    cursor := som.numAmostras;
    passo := som.velocidade*10;

    repeat
        nomeJanela := 'MINIGRAV ' + nomeArq;
        if length (nomeJanela) > 133 then
            nomeJanela := copy (nomeJanela, 1, 133) + '...';
        setWindowTitle (nomeJanela);
        mensagem ('MGCONTGR', 1);  {'Aperte enter para continuar gravação, ESC termina'}
        c := readkey;
        if sintFalando then sintPara;

        if c = ENTER then
            begin
                nomeJanela := 'MINIGRAV Gravando... ' + nomeArq;
                if length (nomeJanela) > 133 then
                nomeJanela := copy (nomeJanela, 1, 133) + '...';
                setWindowTitle (nomeJanela);
                som2.grava(nomeTemp);
                som.adiciona(som2);
                som2.zera;
                sintBip;
            end
        else
        if c = #$0 then
            if readkey = PGUP then
                begin
                    sintClek;
                    cursor := cursor - passo;
                    if cursor < 0 then cursor := 0;
                    som.toca (cursor, som.numAmostras-cursor);
                    sintBip;
                end;

        cursor := som.numAmostras;
    until c = #$1b;
    writeln;
    som2.free;

    assign (arqTemp, nomeTemp);
    {$I-} erase (arqTemp); {$I-}
    if ioresult <> 0 then ;  // ignora erro

    nomeJanela := 'MINIGRAV ' + nomeArq;
    if length (nomeJanela) > 133 then
        nomeJanela := copy (nomeJanela, 1, 133) + '...';
    setWindowTitle (nomeJanela);
    mensagem ('MGSALVAG', 1);   {'Já posso armazenar em disco? }
    sintLeTecla (c, c2);
    writeln;
    if (upcase(c) <> 'N') and (c <> ESC) then
        salvaArquivoRapido;
end;

end.
