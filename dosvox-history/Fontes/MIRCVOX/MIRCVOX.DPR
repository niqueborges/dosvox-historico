{------------------------------------------------------}
{   Programa MircVox - Cliente para IRC
{   Por Leondeniz Cândido de Freitas
{
{   Colaborações:
{   Joyce Fernanda Guerra (Voz e testes)
{   André L. Baldo (Testes)
{   Fernando Zamboni (Testes)
{------------------------------------------------------}

program MircVox;

uses
    dvwin, dvcrt, windows, sysutils, dvform, videovox,
    winsock, dvinet,
    mvmsg, mvvars, mvcontro;


Procedure inicializa;
var i:integer;
    dirSom: string;
Begin
    clrscr;
    setWindowText (crtWindow, 'MircVox');

    for i:=0 to 127 do
        ignorados[i]:='';
    porta:=6667;
    sock:=0;
    Nomeconf:='';

    dirSom := sintAmbiente ('MIRCVOX', 'DIRMIRCVOX');
    if dirSom = '' then
        dirSom := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\mircvox';
    sintInic (0, dirSom);

    pont:=false;
    sintfalapont:=false;

    NomeConf := sintambiente ('MIRCVOX', 'ARQCONF');
    if nomeconf = '' then
        nomeconf:= sintDirAmbiente + '\mircvox.ini';
    if (not FileExists(NomeConf)) then
        begin
            Mensagem ('MVINIC', 0);
            SintWriteln (versao);
            writeln;
            Configura;
        end;

    assignfile (arqconf, nomeconf);
    reset (arqconf);
    while not eof (arqconf) do
    begin
        readln (arqconf, aux);
        if (copy (aux, 1, 8)='Servidor') then
        Servidor:=copy (aux, pos('=', aux)+1, length(aux))
        else if (copy (aux, 1, 4)='Nick') then
        Nick:=copy (aux, pos('=', aux)+1, length(aux))
        else if (copy (aux, 1, 5)='Senha') then
        Senha:=copy (aux, pos('=', aux)+1, length(aux));
    end;
    Close (arqconf);
end;

{--------------------------------------------------------}
{               ciclo de processamento geral
{--------------------------------------------------------}

Procedure Processa;
var c, c2:char;
    processando:boolean;
    xc, yc:integer;
Label opcao;
begin
    Textbackground (BLUE);
    Writeln (' ##    ##   ###   ##    ##   #  #   ###   #  #  ');
    writeln ('#  #  #  #   #   #  #  #  #  #  #  #   #  #  #  ');
    writeln ('#  #  #  #   #   #  #  #     #  #  #   #  #  #  ');
    writeln ('#  #  #  #   #   ###   #     #  #  #   #   ##   ');
    writeln ('#  #  #  #   #   # #   #  #  #  #  #   #  #  #  ');
    writeln ('#   ##   #  ###  #  #   ##    ##    ###   #  #  ');
    textbackground (BLACK);

    textcolor (lightgray);
    gotoxy (52, 1);
    Writeln ('Desenvolvido por Leondeniz');
    Gotoxy (58, 3);
    Writeln ('Colaborações:');
    Gotoxy (52, 4);
    Writeln ('Joyce Fernanda Guerra (Voz)');
    Gotoxy (52, 5);
    Writeln ('André L. Baldo( Programação)');
    Gotoxy (52, 6);
    Writeln ('Fernando Zamboni (Testes)');
    Mensagem ('MVINIC', 0);
    SintWriteln (versao);
    window (1, 8, 80, 24);

    Processando:=true;
    while processando do
        Begin
            canal:='';
    opcao:
            If sock > 0 then
                While TemMensagem Do
                    Begin
                        ReadlnBufRede (buf, msg, 15);
                        ProcessaMsg (msg);
                        goto opcao;
                    End;

            While keypressed do readkey;

            Textcolor (white);
            textbackground (blue);
            mensagem ('MVOPCAO', 0);
            textbackground (black);
            While (not keypressed) and (sock > 0) do
                if ChegouRede (sock) then
                    Begin
                        Readlnbufrede (buf, msg, 15);
                        ProcessaMsg  (msg);
                    End
                else
                    if not keypressed then waitMessage;

            Sintletecla (c, c2);
            writeln;
            Case upcase (C) of
                'O': configura;
                'C': Begin
                        Mensagem ('MVCONECT', 1);
                        Conecta;
                    End;
                'J': Begin
                    if sock<1 then
                    Begin
                        Mensagem ('MVNAOCON', 1);
                        Goto opcao;
                    End;
                    Canal:='';
                    mensagem ('MVCANAL', 0);
                    Sintreadln (Canal);
                    If (Canal='') then goto opcao;
                    JCanal (Canal);
                    End;
                'R': RegNick;
                'M': EnviaMsg;
                'L': ListaCanais;
                #$0: if (c2=f1) then ajuda
                    Else if c2=f9 then
                     begin
                         sintBip;
                         xc := wherex;
                         yc := wherey;
                         Window (1 , 1 , 80 , 24);
                         leitorDeTela;
                         gotoxy (xc , yc);
                     end;
                Esc: Begin
                    Mensagem ('MVFIM', 0);
                    c:=Readkey;
                    Sintetiza (c);
                    Writeln;
                    if (c='S') or (c='s') then
                    Begin
                        Mensagem ('MVTCHAU', 0);
                        Delay (500);
                        Donewincrt;
                    End;
                End
            Else
                mensagem ('MVOPINV', 1);
            End;
        end;
End;


Begin
    inicializa;
    processa;
End.
