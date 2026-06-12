unit mgToca;

interface
uses
    dvcrt,
    dvwin,
    mgVars,
    mgArquivo,
    mgMsg,
    windows,
    sysUtils,
    dvwav,
    dvGrav;

procedure tocaSom;

implementation

{--------------------------------------------------------}

function cursorParaTempo (cursor: integer): string;
begin
    cursorParaTempo := intToStr (cursor div som.velocidade)+
         ':'+ intToStr (cursor mod som.velocidade div (som.velocidade div 10));
end;

{--------------------------------------------------------}

procedure informaPosicao;
begin
    sintclek;
    mensagem ('MGPOSCUR', 0);  {'posição do cursor: '}
    sintWrite (cursorParaTempo (cursor));
    write ('  ');
    mensagem ('MGTEMPOT', 0);  {'Tempo total: '};
    sintWrite (cursorParaTempo (som.numAmostras));
    write ('  ');

    mensagem ('MGPERCEN', 0);  {'percentual: '}
    sintWrite ((intToStr((100 * cursor) div som.numAmostras)) + ' %');
    writeln;
end;

{--------------------------------------------------------}

procedure tocaSom;
var c, c2: char;
    passo: integer;
    erro: integer;
    salva: integer;
    s: string;
label ativa;

    procedure mostraPosicao;
    begin
        gotoxy (1, wherey);
        write (cursorParaTempo (cursor) + '       ');
    end;

begin
    mensagem ('MGESPTOC', 1);  {'Use espaço para tocar, F1 ajuda'}

    while sintFalando do waitMessage;
    keyStopsWave := false;   // para teclado não interromper

    salva := maxBufWaves;
    maxBufWaves := nbufToca;
    passo := som.velocidade div 10;

    repeat
        c2 := #0;
        c := readkey;
        if c = #$0 then c2 := readkey;
        while keypressed do readkey;

ativa:
        if c = ' ' then
            begin
                if cursor >= som.numAmostras then
                    mensagem ('MGFIMSOM', 1)    {'Fim do som'}
                else
                    begin
                        if cursor < 0 then cursor := 0;
                        while (cursor <= som.numAmostras) and (not keypressed) do
                              begin
                                  som.toca (cursor, passo);
                                  cursor := cursor + passo;
                                  mostraPosicao;
                              end;

                        writeln;
                        if keypressed then
                            begin
                                c2 := #0;
                                c := readkey;
                                if c = #$0 then c2 := readkey;
                                if c <> ' ' then goto ativa;
                            end;
                    end;
            end
        else
        if (upcase (c) = 'M') or (upcase (c) = 'B') then
            begin
                marca := cursor;
                mensagem ('MGMEMOR', 1);   {'Posição do cursor memorizada'}
            end
        else
        if upcase (c) = 'V' then
            begin
                cursor := marca;
                mensagem ('MGOK', 1);      {'Ok'}
            end
        else
        if upcase (c) = 'I' then   //Patrick. Similar a home, para melhor uso em notebooks
            begin
                cursor := 0;
                mostraPosicao;
                mensagem ('MGINISOM', 1);    {'Início do som'}
            end
        else
        if upcase (c) = 'F' then   //Patrick. Similar a end, para melhor uso em notebooks
            begin
                cursor := som.numAmostras;
                mostraPosicao;
                mensagem ('MGFIMSOM', 1);    {'Fim do som'}
            end
        else
        if c = #$0 then
            begin

                if c2 = F1 then
                    begin
                        textBackground (RED);
                        mensagem ('MGASOPC',1); {'As opções são:'}
                        textBackground (BLACK);
                        mensagem ('MGAJTOC1', 1);  {'Espaço toca e para, esc termina'}
                        mensagem ('MGAJTOC2', 1);  {'Posicione com direita, esquerda, home e end.'}
                        mensagem ('MGAJTOC3', 1);  {'Page Up e Page Down saltam 10 segundos'}
                        mensagem ('MGAJTOC4', 1);  {'M memoriza o ponto do cursor'}
                        mensagem ('MGAJTOC5', 1);  {'V volta ao ponto memorizado'}
                    end
                else

                if c2 = HOME then
                    begin
                         cursor := 0;
                         mostraPosicao;
                         mensagem ('MGINISOM', 1);    {'Início do som'}
                    end
                else
                if c2 = TEND then
                    begin
                         cursor := som.numAmostras;
                         mostraPosicao;
                         mensagem ('MGFIMSOM', 1);    {'Fim do som'}
                    end
                else

                if c2 = DIR then
                    begin
                        if cursor <= som.numAmostras then
                                som.toca (cursor, passo);
                        if GetKeyState(VK_SHIFT) < 0 then
                            cursor := cursor + passo div 10
                        else
                            cursor := cursor + passo;
                        if cursor >= som.numAmostras then
                            begin
                                sintBip;
                                cursor := som.numAmostras;
                            end;
                        mostraPosicao;
                    end
                else

                if c2 = ESQ then
                    begin
                        if GetKeyState(VK_SHIFT) < 0 then
                            cursor := cursor - passo div 10
                        else
                            cursor := cursor - passo;
                        if cursor >= 0 then
                            som.toca (cursor, passo);
                        if cursor <= 0 then
                            begin
                                sintBip;
                                cursor := 0;
                            end;
                        mostraPosicao;
                    end
                else
                if c2 = CTLPGDN then
                    begin
                        if cursor < som.numAmostras then
                            begin
                                sintClek;
                                cursor := cursor + passo * 100;
                            end;
                        if cursor >= som.numAmostras then
                            begin
                                sintBip;
                                cursor := som.numAmostras;
                            end;
                        mostraPosicao;
                    end
                else

                if c2 = CTLPGUP then
                    begin
                        if cursor > 0 then
                        begin
                            sintClek;
                            cursor := cursor - passo * 100;
                        end;
                        if cursor < 0 then
                            begin
                                sintBip;
                                cursor := 0;
                            end;
                        mostraPosicao;
                    end
                else

                if c2 = PGDN then
                    begin
                        if cursor < som.numAmostras then
                            begin
                                sintClek;
                                cursor := cursor + passo * 10;
                            end;
                        if cursor >= som.numAmostras then
                            begin
                                sintBip;
                                cursor := som.numAmostras;
                            end;
                        mostraPosicao;
                    end
                else

                if c2 = PGUP then
                    begin
                        if cursor > 0 then
                        begin
                            sintClek;
                            cursor := cursor - passo * 10;
                        end;
                        if cursor < 0 then
                            begin
                                sintBip;
                                cursor := 0;
                            end;
                        mostraPosicao;
                    end
                else
                if c2 = CTLDIR then
                    som.toca (cursor, som.numAmostras - cursor)
                else
                if c2 = CTLESQ then
                    som.toca (0, cursor)
                else
                if c2 = F6 then
                    informaPosicao
                else
                if c2 = F5 then
                    begin
                        writeln;
                        sintWrite ('Informe a posição em segundos: ');
                        sintReadln (s);
                        s := trim (s);
                        if s <> '' then
                            begin
                                val (s, cursor, erro);
                                if (erro <> 0) or (cursor < 0) then
                                    begin
                                        mensagem ('MGERPOSI', 1);  {'Erro de posicionamento'}
                                        cursor := 0;
                                    end
                                else
                                    begin
                                        cursor := cursor * som.velocidade;
                                        if cursor >= som.numAmostras then
                                            begin
                                                sintBip;
                                                cursor := som.numAmostras;
                                            end;
                                    end;
                            end;
                    end;
            end;

    until (c = #$1b) or (c = ENTER);

    keyStopsWave := true;
    maxBufWaves:= salva;
    writeln;
end;

end.
