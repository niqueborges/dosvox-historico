{-------------------------------------------------------------}
{                 papovox - espera conexão
{-------------------------------------------------------------}

unit ppconec;

interface
uses dvwin, dvcrt, windows, sysUtils, winsock, dvinet,
     ppvars, ppmsg, ppcontro, ppsnomes, ppurgent;

procedure esperaConexao;

implementation

{--------------------------------------------------------}
{                    espera uma conexao
{--------------------------------------------------------}

procedure esperaConexao;
var
    aceitou: boolean;
    sockEscuta: integer;
    c, c2: char;
    nomeDele, liga: string;
    jan: hwnd;
begin
     jan := findWindow ('dvwincrt', 'SITIOVOX');
     if jan <> 0 then
         begin
             mensagem ('PPCONREC', 1);  {Recusei a conexão}
             exit;
         end;

    mensagem ('PPESPERA', 1);  {esperando parceiro}
    sockEscuta:= escutaConexao (PORTA_PAPOVOX);

    logonUsuario (enderUsuario, 'listening');

    aceitou := false;
    repeat
        if temMsgUrgente then
            begin
                writeln;
                recebeMsgUrgente;
            end;

        if chegouRede (sockEscuta) then
            begin
                sock:= aceitaConexao (sockescuta);
                bufSock := inicBufRede (sock);

                liga := sintAmbiente ('PAPOVOX', 'SOMRECEBE');

                repeat
                    sintsom (liga);
                    delay (2000);
                until keyPressed;

                while keyPressed do readkey;

                writelnRede (sock, '+OK '+ nomeUsuario);

                readlnBufRede (bufSock, nomeDele, 15);

                mensagem ('PPCONPED', 0);   {Conexão pedida por }
                sintWriteln (nomeDele);
                mensagem ('PPACEITA', 0);   {Aceita ?}
                sintLeTecla (c, c2);
                writeln;

                if (upcase (c) = 'N') or (c = ESC) then
                    begin
                        writelnRede (sock, '-Usuário não disponível no momento');
                        fimBufRede (bufSock);
                        fechaConexao (sock);
                        mensagem ('PPCONREC', 1);  {Recusei a conexão}
                    end
                else
                    begin
                        aceitou := true;
                        writelnRede (sock, '+OK');
                        mensagem ('PPOTIMO', 1);   {Otimo}
                        fechaConexao (sockEscuta);
                    end;
            end;

        if keypressed and (readkey = ESC) then
            begin
                mensagem ('PPESPCAN', 1);   {Espera cancelada}
                fechaConexao (sockEscuta);
                logonUsuario (enderUsuario, 'logon');
                exit;
            end;
    until aceitou;

    batePapo;

    fechaConexao (sock);
end;

end.
