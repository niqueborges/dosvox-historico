unit mgArquivo;

interface
uses
    dvcrt,
    dvwin,
    dvform,
    mgVars,
    dvarq,
    mgmp3,
    gramost,
    sysUtils,mgMsg,windows;




procedure carregaSom;
procedure obtemNomeArquivo (inicial: boolean);
function gravaSomInicial: boolean;
procedure salvaArquivoRapido;
procedure veSeSalvaMP3 (nomeNovo: string);
procedure salvaArquivo (nomeArq: string);

implementation

{--------------------------------------------------------}

procedure carregaSom;
begin
    mensagem ('MGCRGSOM', 1);   {'Carregando som'}

    cursor := 0;
    marca := 0;
    som.maxMemoria := maxMemoria * 1024 * 1024;
    if nomeArq <> '' then
        if not som.leArquivo(nomeArq) then
            begin
                if som.faltaDeMemoria then
                    mensagem ('MGFALMEM', 1)   {'Não há memória suficiente para esta edição'}
                else
                    mensagem ('MGARQERR', 1);  {'Arquivo incompatível com este programa'}
                nomeArq := '';
                exit;
            end;
end;

{--------------------------------------------------------}

procedure obtemNomeArquivo (inicial: boolean);
var pnome: array [0..255] of char;
label repete;
begin

    if inicial and (paramCount <> 0) then
        begin
            nomeArq := cmdLine;
            if nomearq[1] = '"' then
                begin
                    delete(nomeArq,1,1);
                    delete(nomeArq,1,pos('"',nomeArq)+1);
                end
            else
                delete(nomeArq,1,pos(' ',nomeArq));
            if nomeArq [1] = '"' then
                begin
                    delete (nomeArq, 1, 1);
                    delete (nomeArq, length(nomeArq),1);
                end;
        end
    else
        begin
repete:
            garanteEspacoTela(10);
            mensagem ('MGNOMARQ', 1);            {'Informe o nome do arquivo: '}
            nomeArq := obtemNomeArqMasc(10, '*.WAV|*.MP3');
        end;

    if nomeArq = '' then
        if (teclaObtemNomeArq <> ENTER) and (teclaObtemNomeArq <> ESC) then
            begin
                mensagem('MGERRO_N',2);  {  'Nenhum arquivo foi selecionado'  }
                goto repete
            end
        else
            exit;

    if nomeArq [length (nomeArq)] = '\' then goto repete;

    if maiuscAnsi (copy (nomeArq, length (nomeArq)-3, 4)) = '.MP3' then
        begin
            if fileExists (nomeArq) then
                begin
                    writeln;
                    mensagem ('MGMP3WAV', 1 ); {'Vou converter de MP3 para WAV, aguarde'}

                    if not decodificaMP3 (nomeArq, nomeArq+'.wav') then
                        begin
                            mensagem ('MGERRCNV', 2);  {'Conversão mal sucedida'}
                            goto repete;
                        end;
                end;
        end;

    writeln (nomeArq);
    strPCopy (pnome, 'MINIGRAV ' + nomeArq);
    setWindowText (crtWindow, pnome);

    if maiuscAnsi (copy (nomeArq, length (nomeArq)-3, 4)) <> '.WAV' then
         nomeArq := nomeArq + '.wav';   // pode até ficar "nome.MP3.WAV"
end;

{--------------------------------------------------------}

function gravaSomInicial: boolean;
var
    c, c2: char;
    qualidade: char;
    nomeJanela: string;

begin
    gravaSomInicial := false;

    mensagem ('MGRADTLF', 0);  {'Qualidade CD, rádio ou telefone ? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
             nomeArq := '';
             exit;
        end;

    qualidade := upcase (c);

    som.zera;
    case qualidade of
        'C':  begin
                  som.velocidade := 44100;
                  som.bitsPorAmostra := 16;
              end;

        'T':  begin
                  som.velocidade := 11025;
                  som.bitsPorAmostra := 8;
              end;
        else
              begin
                  som.velocidade := 22050;
                  som.bitsPorAmostra := 16;
              end;
    end;

    mensagem ('MGSTMONO', 0);  {'Estéreo ou Mono? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
             nomeArq := '';
             exit;
        end;

    if upcase (c) in ['E', 'S'] then
        som.canais := 2
    else
        som.canais := 1;

    mensagem ('MGINIGRV', 1);   {'Tecle Enter para iniciar, ESC termina'}
    repeat
        c := readkey;
    until (c = ESC) or (c = ENTER);
    if c = ESC then
        begin
            nomeArq := '';
            exit;
        end;

    nomeJanela := 'MINIGRAV Gravando... ' + nomeArq;
    if length (nomeJanela) > 133 then
        nomeJanela := copy (nomeJanela, 1, 133) + '...';
    setWindowTitle (nomeJanela);
    som.zera;
    som.nBufGravacao := nbufGrava;
    if som.grava (nomeArq) then
        begin
            gravaSomInicial := true;
            mensagem ('MGOK', 1);   {'Ok'}
        end
    else
        begin
            gravaSomInicial := false;
            if som.faltaDeMemoria then
                mensagem ('MGFALMEM', 1)    {'Não há memória suficiente para esta edição'}
            else
                mensagem ('MGERRGRV', 1);   {'Erro de gravação'}
        end;
    nomeJanela := 'MINIGRAV ' + nomeArq;
    if length (nomeJanela) > 133 then
        nomeJanela := copy (nomeJanela, 1, 133) + '...';
    setWindowTitle (nomeJanela);
end;

{--------------------------------------------------------}

procedure salvaArquivoRapido;
var nomeNovo: string;
    pnome: array [0..255] of char;
begin
    nomeNovo := nomeArq;
    if nomeNovo = '' then
        begin
            mensagem ('MGNOMARQ', 1);            {'Informe o nome do arquivo: '}
            sintReadln (nomeNovo);
            if nomeNovo = '' then
                begin
                    mensagem ('MGDESIST', 1);    {'Desistiu'}
                    exit;
                end;
        end;

    if not som.gravaArquivo(nomeNovo) then
        mensagem ('MGERRGRV', 1)   {'Erro de gravação'}
    else
        begin
            mensagem ('MGARQSLV', 1);      {'OK, arquivo salvo'}
            nomeArq := nomeNovo;
            strPCopy (pnome, 'MINIGRAV ' + nomeArq);
            setWindowText (crtWindow, pnome);
        end;
end;

{--------------------------------------------------------}

procedure veSeSalvaMP3 (nomeNovo: string);
var arq: file;
begin
    if (length(nomeNovo) > 8) and
       (maiuscAnsi(copy (nomeNovo, length(nomeNovo)-7, 8)) = '.MP3.WAV') then
           begin
               mensagem ('MGWAVMP3', 1);  {'Vou converter de wav para mp3, aguarde'}
               if not codificaMp3 (nomeNovo, copy (nomeNovo, 1, length(nomeNovo)-4)) then
                   mensagem ('MGERRCNV', 2)  {'Conversão MP3 foi mal sucedida'}
               else
                   begin
                       assign (arq, nomeNovo);
                       {$I-} erase (arq); {$I+}
                       if ioresult <> 0 then;
                   end;
           end;
end;

{--------------------------------------------------------}

procedure salvaArquivo (nomeArq: string);
var t, c, c2: char;
    nomeNovo: string;
    som2: TAmostras;
    pnome: array [0..255] of char;

label desistiu, salvamentoMP3;
begin
    som2 := NIL;
    nomeNovo := nomeArq;

    mensagem ('MGMANTOR', 0);            {'Mantenho parâmetros originais da gravação? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then goto desistiu;

    if upcase (c) = 'S' then
        begin
            salvaArquivoRapido;
            goto salvamentoMP3;
        end;

    mensagem ('MGNOMNAR', 1);            {'Informe o novo nome do arquivo: '}
    garanteEspacoTela(2);
    c := sintEdita (nomeNovo, wherex, wherey, 255, true);
    writeln;
    if (c = ESC) or (nomeNovo = '') then goto desistiu;

    if (maiuscAnsi (copy (nomeNovo, length (nomeNovo)-3, 4)) = '.MP3') or
                                   (pos ('.', nomeNovo) = 0) then
         nomeNovo:= nomeNovo + '.wav';

    mensagem ('MGRADTLF', 0);  {'Qualidade CD, rádio ou telefone ? '}
    sintLeTecla (t, c2);
    writeln;
    if t = ESC then exit;

    mensagem ('MGSTMONO', 0);  {'Estéreo ou Mono? '}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then goto desistiu;

    som2:= TAmostras.Create;
    case upcase(t) of
        'C':  begin
                  som2.reAmostra (som, 44100);
                  som2.bitsPorAmostra := 16;
              end;
        'T':  begin
                  som2.reAmostra (som, 11025);
                  som2.bitsPorAmostra := 8;
              end;
        else
              begin
                  som2.reAmostra (som, 22050);
                  som2.bitsPorAmostra := 16;
              end;
    end;

    if upcase (c) in ['E', 'S'] then
        som2.canais := 2
    else
        som2.canais := 1;

    som.Free;
    som := som2;
    som2 := NIL;

    if not som.gravaArquivo(nomeNovo) then
        begin
            mensagem ('MGERRGRV', 1);      {'Erro de gravação'}
            exit;
        end
    else
        nomeArq := nomeNovo;

    mensagem ('MGARQSLV', 2);       {'OK, arquivo salvo'}
    strPCopy (pnome, 'MINIGRAV ' + nomeArq);
    setWindowText (crtWindow, pnome);

salvamentoMP3:
    veSeSalvaMP3 (nomeNovo);
    exit;

desistiu:
    if som2 <> NIL then som2.free;
    mensagem ('MGDESIST', 1);        {'Desistiu'}
end;


end.
