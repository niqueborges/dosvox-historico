unit mgMistura;

interface
uses
    dvcrt,
    dvwin,
    mgVars,
    mgArquivo,
    gramost,
    mgmsg,
    dvarq,
    windows,
    mgmp3,
    sysUtils;
//, , dvform, , dvwav,
//  , messages, sysutils, mmsystem,

procedure misturaOutroSom;
implementation

{--------------------------------------------------------}

procedure misturaOutroSom;
var
    nomeMist: string;
    som3, som4: TAmostras;
    fatorOrig, fatorMist: real;
    c, c2: char;
    inicioMist: integer;
    tipoMist: char;
    erro: boolean;
    nomeTemp: string;
    pnome, tempPath: array[0..255] of char;
    arqTemp: file;
    ns: string;
    erroDig: integer;

label fim;
begin
    mensagem ('MGNOMMIS', 1);   {'Qual o arquivo de som a misturar ?'}
    nomeMist := obtemNomeArqMasc(10, '*.WAV');
    if nomeMist = '' then exit;
    if pos ('.', nomeMist) = 0 then
        nomeMist := nomeMist + '.wav';
    writeln (nomeMist);

    if not FileExists(NomeMist) then
        begin
            mensagem ('MGERRNOM', 1);   {'Erro no nome do arquivo'}
            exit;
        end;

    nomeTemp := '';
    if maiuscAnsi (copy (nomeMist, length (nomeMist)-3, 4)) = '.MP3' then
        begin
            getTempPath (256, tempPath);
            getTempFilename (tempPath, 'WAV', 0, pnome);
            nomeTemp := strPas (pnome);

            if not decodificaMp3 (nomeMist, nomeTemp) then
                begin
                    mensagem ('MGERRCNV', 2);   {'Conversão MP3 foi mal sucedida'}
                    exit;
                end;

            nomeMist := nomeTemp;
        end;

    som3 := TAmostras.Create;
    som3.leArquivo(nomeMist);

    if nomeTemp <> '' then
        begin
            assign (arqTemp, nomeTemp);
            {$I-} erase (arqTemp);  {$I+}
            if ioresult <> 0then;
        end;

    som3.canais := som.canais;
    som3.bitsPorAmostra := som.bitsPorAmostra;

    if som3.velocidade <> som.velocidade then   // compatibiliza velocidades
        begin
            som4 := TAmostras.Create;
            som4.Clone(som3);
            som4.reamostra (som3, som.velocidade);
            som3.free;
            som3 := som4;
        end;

    fatorOrig := 1.0;
    fatorMist := 1.0;
    inicioMist := 0;

    repeat
        erro := false;

        mensagem ('MGADIFUN', 0);    {'Adição, Mistura ou Fundo sonoro? '}
        sintLeTecla (c, c2);
        writeln;
        tipoMist := upcase(c);

        case tipoMist of
            'A', 'M':  ;
            'F':
                    begin
                         mensagem ('MGFATORI', 0);   {'Percentual do som original, sugiro 70'}
                         sintReadln (ns);
                         val (trim(ns), fatorOrig, erroDig);
                         if (erroDig = 0) and (fatorOrig < 100) then
                             fatorOrig := fatorOrig / 10
                         else
                             fatorOrig := 0.7;

                         mensagem ('MGFATMIS', 0);   {'Percentual do som a misturar, sugiro 30'}
                         sintReadln (ns);
                         val (trim(ns), fatorMist, erroDig);
                         if (erroDig = 0) and (fatorMist < 100) then
                             fatorMist := fatorMist / 10
                         else
                             fatorMist := 0.3;
                    end;
            ESC:
                    begin
                        mensagem ('MGDESIST', 1);  {'Desistiu...'}
                        goto fim;
                    end;
        else
            erro := true;
        end;
    until not erro;

    repeat
        erro := false;

        mensagem ('MGONDMST', 0);   {'Mistura no Início, no Cursor ou no Fim do som? '}
        sintLeTecla (c, c2);
        writeln;

        case upcase(c) of
            'I':  inicioMist := 0;
            'F':  inicioMist := som.numAmostras-1;
            'C':  inicioMist := cursor;
            ESC:  begin
                      mensagem ('MGDESIST', 1);  {'Desistiu...'}
                      goto fim;
                  end;
        else
            erro := true;
        end;
    until not erro;

    if tipoMist = 'A' then
        som.abreTrecho(inicioMist, som3.numAmostras);

    som.mistura(som3, inicioMist, fatorOrig, fatorMist);
    mensagem ('MGMISTUR', 1);   {'Sons misturados'}

fim:
    som3.free;
end;

end.
 