program testaHims;

uses dvCrt, dvWin, dvHims;

label fim;

var
    retorno: integer;
    wParam: integer;
    lParam: longint;
    processando: boolean;
    s: string;
begin
    sintInic(0, '');
    sintWriteln('Testando linha braille Hims');

    if loadHIMS then
        sintWriteln('Carregou dll')
    else
        begin
        sintWriteln('Não carregou dll');
        goto fim;
    end;
    writeln;
    sintWriteln('Abrindo a linha braille HIMS');

    retorno := openHIMS;
    sintWrite('Retorno da abertura:');
    sintWriteInt(retorno);
    writeln;
    if retorno = 0 then
        goto fim;
    writeln;
    sintWriteln('Número de colunas:');
    sintWriteInt(cellsTotal);
    writeln;

    repeat
        sintWriteln('Digite e tecle enter. @limpa limpa, @fim finaliza.');
        sintReadln(s);
        if s = '@limpa' then writeHIMS(0,0,'')
        else if s <> '@fim' then writeHIMS(0,0,s);
    until s = '@fim';
    delay(1000);

    sintWriteln('Vou ler da linha braille. Aperte ESC para terminar');
    processando := true;
    while processando do begin
        if keyPressed and (readKey = #$1b) then break;
        if getKeyData_HIMS (@wParam, @lParam) then
            begin
                sintWriteInt(wParam);
                write(' ');
                sintWriteInt(lParam);
                writeln;
            end;
        end;
    sintWriteln('Vou fechar a conexão com a linha braille');
    closeHIMS;
fim:
    sintWriteln('Fim do programa');
    sintFim;
    doneWinCrt;
end.
*)


    3333:   begin
                   WRITE (WPARAM, ' ',
(LPARAM SHR 19) AND $1,
(LPARAM SHR 18) AND $1,
(LPARAM SHR 17) AND $1,
(LPARAM SHR 16) AND $1,
(LPARAM SHR 15) AND $1,
(LPARAM SHR 14) AND $1,
(LPARAM SHR 13) AND $1,
(LPARAM SHR 12) AND $1,
(LPARAM SHR 11) AND $1,
(LPARAM SHR 9) AND $1,
(LPARAM SHR 8) AND $1,
(LPARAM SHR 7) AND $1,
(LPARAM SHR 6) AND $1,
(LPARAM SHR 5) AND $1,
(LPARAM SHR 4) AND $1,
(LPARAM SHR 3) AND $1,
(LPARAM SHR 2) AND $1,
(LPARAM SHR 1) AND $1,
(LPARAM SHR 0) AND $1, ' '
 );
             end;
*)
