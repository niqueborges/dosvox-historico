unit mgdivide;

interface
uses
    dvcrt, dvwin, dvArq, dvForm, dvWav, sysutils, mmsystem,
    mgvars, mgMsg, gramost;

procedure extraiArquivo;

implementation

{--------------------------------------------------------}

procedure extraiArquivo;
var
    nomeArqDivide: string;
    pcmFormat: TPCMWAVEFORMAT;
    soundSize, hdrSize: integer;
    iniciais, nomeArqDest: string;
    erroArq: boolean;

    iniSeg, fimSeg, tamSeg: integer;          // em segundos
    pontoIni, pontoFim: integer;              // em bytes

    nbytesTrecho, nAmostrasTrecho: integer;
    npartes: integer;
    c: char;
    f: integer;
    lidos, escritos: integer;

    {--------------------------------------------------------}

    function geraTrecho (nomeArqParte: string; pontoIni, nbytesTrecho: integer): boolean;
    var buf: array [0..65535] of byte;
        fsai: integer;
    label erro;
    begin
        Result := false;
        if fileSeek (f, pontoIni, 0) < 0 then exit;

        fsai := FileCreate(nomeArqParte);
        if fsai < 0 then goto erro;

        with pcmFormat, pcmFormat.wf do
            begin
                geraCabWav (@buf, nbytesTrecho, nSamplesPerSec, wBitsPerSample, nChannels);
                if FileWrite(fsai, buf, 44) <= 0 then goto erro;
            end;

        repeat
            lidos := FileRead(f, buf, 65536);
            if nbytesTrecho > 0 then
                begin
                    escritos := FileWrite (fsai, buf, lidos);
                    if escritos <> lidos then goto erro;
                    nbytesTrecho := nbytesTrecho - lidos;
                end
            else
                nbytesTrecho := 0;
        until nbytesTrecho = 0;

        fileClose (fsai);
        result := true;
        exit;

    erro:
        if fsai >= 0 then
            fileClose (fsai);
        mensagem ('MGERRGRV', 1); {'Erro de gravação'}
        result := false;
    end;

    {--------------------------------------------------------}

begin
    mensagem ('MGNOMDIV', 1);  {'Informe o nome do arquivo original'}
    garanteEspacoTela (10);
    nomeArqDivide := obtemNomeArqMasc(10, '*.WAV');
    writeln (nomeArqDivide);
    if nomeArqDivide = '' then
        begin
            mensagem ('MGDESIST', 1);   {'Desistiu'}
            exit;
        end;

    if maiuscAnsi (copy (nomeArqDivide, length(nomeArqDivide)-3, 4)) = '.MP3' then
        begin
            mensagem ('MGNDIV', 1);  {'Nâo posso dividir arquivos MP3, só de arquivos WAV'}
            exit;
        end;

    if pos ('.WAV', maiuscAnsi (nomeArqDivide)) = 0 then
        nomeArqDivide := trim (nomeArqDivide) + '.WAV';

    if not fileExists (nomeArqDivide) then
        begin
            mensagem ('MGARQNAO', 1);   {'Arquivo inexistente'}
            exit;
        end;

    if not waveFileParse (nomeArqDivide, @pcmFormat, soundSize, hdrsize) then
        begin
            mensagem ('MGARQERR', 1);   {'Arquivo incompatível com este programa'}
            exit;
        end;

    mensagem ('MGDIVPED', 0);     {'Posso dividir em trechos iguais? '}
    c := sintReadkey;
    writeln (c);
    if c = ESC then exit;

    if upcase(c) <> 'N' then
        begin
            tamSeg := 0;
            mensagem ('MGDIVSEG', 0);   {'Informe em segundos o tamanho dos trechos'}
            sintReadint (tamSeg);
            if tamSeg = 0 then
                begin
                    mensagem ('MGDESIST', 1);  {'desistiu'}
                    exit;
                end;

            if tamSeg < 1 then tamSeg := 1;
            with pcmFormat do
                begin
                    nAmostrasTrecho := tamSeg * integer(wf.nSamplesPerSec);
                    nbytesTrecho := nAmostrasTrecho * integer(wBitsPerSample div 8) *
                                                      integer(wf.nChannels);
                end;

            mensagem ('MGINIDST', 1);   {'Informe iniciais dos arquivos de destino'}
            sintReadln (iniciais);

            f := FileOpen(nomeArqDivide, fmOpenRead or fmShareDenyNone);

            npartes := 0;
            pontoIni := npartes * nbytesTrecho;
            erroArq := false;
            while (pontoIni < soundSize) and (not erroArq) do
                begin
                    npartes := npartes + 1;
                    if soundSize - pontoIni < nbytesTrecho then
                        nbytesTrecho := soundSize - pontoIni;
                    erroArq := not geraTrecho (iniciais + intToStr (npartes) + '.wav',
                                               hdrSize+pontoIni, nbytesTrecho);
                    sintSom ('MGCLEK');
                    pontoIni := pontoIni + nbytesTrecho;
                end;

            fileClose (f);

            limpaBufTec;
            if not erroArq then
                mensagem ('MGARFDIV', 1);   {'Arquivo foi dividido.'}
            mensagem ('MGNPART', 0);    {'Número de partes: '}
            sintWriteint (npartes);
            writeln;
            writeln;
        end
    else
        begin
            mensagem ('MGPONINI', 0);   {'Informe em segundos o ponto inicial: '}
            sintReadint (iniSeg);
            if iniSeg < 0 then iniSeg := 0;
            mensagem ('MGPONFIN', 0);   {'Informe em segundos o ponto final  : '}
            sintReadint (fimSeg);
            if fimSeg < iniSeg then fimSeg := iniSeg;

            with pcmFormat do
                begin
                    pontoIni := iniSeg * integer(wf.nSamplesPerSec) * integer(wBitsPerSample div 8) * integer(wf.nChannels);
                    pontoFim := fimSeg * integer(wf.nSamplesPerSec) * integer(wBitsPerSample div 8) * integer(wf.nChannels);
                    if pontoFim > soundSize then
                        nbytesTrecho := soundSize - pontoIni
                    else
                        nbytesTrecho := pontoFim - pontoIni;
                end;

            mensagem ('MGINFDST', 1);   {'Informe nome do arquivo destino'}

            garanteEspacoTela (10);
            nomeArqDest := obtemNomeArqMasc(10, '*.WAV');
            writeln (nomeArqDest);
            if nomeArqDest = '' then
                begin
                    mensagem ('MGDESIST', 1);  {'Desistiu'}
                    exit;
                end;

            if maiuscAnsi (copy (nomeArqDest, length(nomeArqDest)-3, 4)) = '.MP3' then
                begin
                    mensagem ('MGNDIV', 1);  {'Nâo posso dividir arquivos MP3, só de arquivos WAV'}
                    exit;
                end;

            if maiuscAnsi (copy (nomeArqDest, length(nomeArqDest)-3, 4)) <> '.WAV' then
                nomeArqDest := nomeArqDest + '.WAV';

            f := FileOpen(nomeArqDivide, fmOpenRead or fmShareDenyNone);
            erroArq := not geraTrecho (nomeArqDest, hdrSize+pontoIni, nbytesTrecho);
            if not erroArq then
                mensagem ('MGARFEXT', 1);   {'Trecho do arquivo foi extraido.'}
            fileClose (f);
        end;
end;

end.
