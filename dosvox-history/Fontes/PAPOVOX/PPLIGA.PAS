{-------------------------------------------------------------}
{                      papovox - ligacao
{-------------------------------------------------------------}

unit ppliga;

interface
uses dvwin, dvcrt, winsock, dvinet,
     ppvars, ppmsg, ppContro, ppSNomes;

procedure liga;

implementation

{--------------------------------------------------------}
{                  realiza conexao
{--------------------------------------------------------}

procedure liga;
var
    endip: string;
    s, liga: string;
    c, c2: char;
label pegouEnder;
begin
    if selecionado <> '' then
        begin
            mensagem ('PPPOSSO', 0);   {Posso conectar '}
            sintWrite (selecionado);
            write (' ? ');
            sintLeTecla (c, c2);
            writeln;
            if c = ESC then exit;
            if upcase(c) <> 'N' then
                begin
                    endIp := selecionado;
                    goto pegouEnder;
                end;
        end;

    mensagem ('PPQUALIP', 1);  {Qual o endereço a conectar}
    sintReadln (endip);
    if endip = '' then exit;

pegouEnder:
    selecionado := endip;

    if pos ('@', endip) <> 0 then
        begin
            descobreIp (endip, endip);
            if endip = '' then exit;
        end;

    mensagem ('PPESPLIG', 1);        {Tentando estabelecer conexão}

    sock := abreConexao (endip, PORTA_PAPOVOX);
    if sock < 0 then
        begin
            mensagem ('PPERCON', 1);  {Não consegui realizar a conexão}
            exit;
        end;

    liga := sintAmbiente ('PAPOVOX', 'SOMLIGA');
    sintsom (liga);

    bufSock:= inicBufRede (sock);
    if not readlnBufRede (bufSock, s, 15) then s := '-';
    if s[1] = '-' then
        begin
            mensagem ('PPNAODSP', 1);  {Parceiro não disponível}
            fimbufRede (bufSock);
            fechaConexao (sock);
            exit;
        end;

    if nomeUsuario = '' then nomeUsuario := 'Fulano';
    writelnRede (sock, nomeUsuario);
    if not readlnBufRede (bufSock, s, 15) then s := '-Conexão caiu';
    if s[1] = '+' then
        batePapo
    else
        begin
            mensagem ('PPRECUSA', 1); {Parceiro recusou conexão, veja mensagem}
            sintWriteln (s);
        end;

    fechaConexao (sock);
end;

end.
