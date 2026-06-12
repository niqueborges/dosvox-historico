program testaHims_cliente;

uses dvCrt, dvWin, dvInet;

label fim;

var
    sock: integer;
    s: string;
begin
    sintInic(0, '');
    abreWinSock;
    sintWriteln('Conectando com o servidor brlServer');
    sock := abreConexao('localhost', 80);
    if sock <= 32 then
    begin
        sintWriteln('Erro ao conectar com o servidor');
    goto fim;
    end;
    sintWriteln('Conectado ao servidor brlServer');
    writeln;
    repeat
        sintWriteln('Digite e tecle enter. @fim finaliza');
        sintReadln(s);
         if s <> '@fim' then writelnRede(sock, s);
    until s = '@fim';
(*
Quero apenas ver a escrita usando o servidor por enquanto
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
*)
    sintWriteln('Saindo do servidor');
    fechaConexao(sock);
    fechaWinSock;
fim:
    sintWriteln('Fim do programa');
    sintFim;
    doneWinCrt;
end.

(*
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
