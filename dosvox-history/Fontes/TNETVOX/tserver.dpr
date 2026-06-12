program tserver;

uses dvcrt, dvinet, winsock;

const
    porta = 80;
    emhexa: boolean = false;

var
    sockListen, sock: longint;
    escritos, lidos: integer;
    c: char;
    numero: string;

function hexa (c: char): string;
const tabhexa: array [0..15] of char = (
   '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
begin
    hexa := tabHexa[ord(c) shr 4] + tabHexa[ord(c) and $f];
end;

procedure enviaArquivo;
var arq: file;
    i: integer;
    buf: array [0..511] of char;
begin
    if paramCount = 0 then exit;
    assign (arq, paramStr(1));
    reset (arq, 1);
    while not eof (arq) do
        begin
             keypressed;
             blockRead (arq, buf, 512, escritos);
             escritos := send (sock, buf, escritos, 0);
             for i := 0 to escritos-1 do
                 write (buf[i]);
        end;
    close (arq);
end;

begin
    abreWinSock;

    writeln ('Esperando conexão na porta ', porta);

    sockListen := escutaConexao (porta);
    repeat
         delay (500);
    until chegouRede (sockListen);

    sock := aceitaConexao (sockListen);
    writeln ('Conectou, termine com control-z');
    fechaConexao (sockListen);

//    enviaArquivo;

    c := ' ';
    repeat
        if chegouRede (sock) then
             begin
                 lidos := recv (sock, c, 1, 0);
                 if lidos <> 0 then
                     if emHexa then
                         write (hexa(c))
                     else
                         write (c)
                 else
                     c := #$1a;
             end
        else
            if keypressed then
                begin
                    c := readkey;
                    write (c);
                    send (sock, c, 1, 0);
                end;

    until keypressed;

    fechaConexao (sock);
    fechaWinSock;

    writeln;
    write ('Tecle enter');
    readln;
    donewincrt;
end.
