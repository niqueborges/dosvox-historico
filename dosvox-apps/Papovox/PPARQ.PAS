{--------------------------------------------------------}
{         papovox - trata transmissao de arquivos
{--------------------------------------------------------}

unit pparq;

interface

uses dvwin, dvcrt, winsock, dvinet, mmsystem,
     winprocs, wintypes, dvgrav, sysUtils,
     ppvars, ppmsg, pprede;

procedure transmiteArq;
procedure cancelaRecepcao;
procedure trataInicioRecebe (bufao: pchar);
procedure trataFimRecebe;
procedure trataArqRecebe (bufao: pchar; lidos: integer);
procedure trataCancArqRecebe;
procedure trataInicioTransm;
procedure trataCancTransm;

implementation

{--------------------------------------------------------}
{                    transmite um arquivo
{--------------------------------------------------------}

procedure transmiteArq;
var nomeArq: string;
begin
    if enviandoArq or autorEnvioPendente then
        begin
            {$I-}  close (arqEnvia);  {$I+}
            if ioresult <> 0 then {};

            if not enviaRede (CANCARQENVIA, @bufTec[1], length (bufTec)) then
                 conversando := false;

            if wherex <> 1 then writeln;
            mensagem ('PPTRACAN', 1);   {Transmissão de arquivo cancelada}

            autorEnvioPendente := false;
            enviandoArq := false;
            exit;
        end;

    if wherex <> 1 then writeln;
    textBackGround (RED);
    mensagem ('PPNOMTRA', 0);   {Qual o nome do arquivo a transmitir ?}
    textBackGround (BLACK);
    writeln;

    sintReadln (nomeArq);
    if nomeArq = '' then
        begin
            sintBip;
            exit;
        end;

    assign (arqEnvia, nomeArq);
    {$I-}  reset (arqEnvia, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('PPARQNAO', 1);   {Arquivo não existe}
            exit;
        end;

    if not enviaRede (INICIOARQENVIA, @nomeArq[1], length (nomeArq)) then
        conversando := false;

    enviandoArq := true;
    autorEnvioPendente := true;
end;

{--------------------------------------------------------}
{                cancelamento de recepcao
{--------------------------------------------------------}

procedure cancelaRecepcao;
begin
    if not enviaRede (CANCELAMANDAR, NIL, 0) then
        conversando := false;

    if wherex <> 1 then writeln;
    mensagem ('PPRECCAN', 1);   {Recepção de arquivo cancelada}
end;

{--------------------------------------------------------}
{              aceita pedido de transmissão
{--------------------------------------------------------}

procedure trataInicioRecebe (bufao: pchar);
var
    nomeArqRec: string;
    j: integer;
    c, c2: char;
begin
    contaSpeaker := 0;
    for j := 1 to 3 do
         begin
            bipSpeaker (40);
            bipSpeaker (47);
         end;
    delay (1000);

    if wherex <> 1 then writeln;
    mensagem ('PPQUERGV', 0);   {Parceiro deseja enviar }
    nomeArqRec := strPas (bufao);
    sintWriteln (nomeArqRec);

    mensagem ('PPACEITA', 0);    {Aceita ?}
    sintLeTecla (c, c2);
    writeln;
    if upcase(c) <> 'S' then
        begin
            mensagem ('PPNOMREC', 1);   {Qual o nome do arquivo a receber ?}
            sintReadln (nomeArqRec);
        end;

    if nomeArqRec = '' then
        begin
            mensagem ('PPRECCAN', 1);   {Recepção de arquivo cancelada}
            if not enviaRede (CANCELAMANDAR, NIL, 0) then
                conversando := false;
            exit;
        end;

    assign (arqRecebe, nomeArqRec);
    {$I-}  rewrite (arqRecebe, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('PPNAOCRI', 1);   {Não consegui criar o arquivo}
            mensagem ('PPRECCAN', 1);   {Recepção de arquivo cancelada}
            if not enviaRede (CANCELAMANDAR, NIL, 0) then
                conversando := false;
        end
    else
        begin
            recebendoArq := true;
            if not enviaRede (PODEMANDAR, NIL, 0) then
                conversando := false;
        end;
end;

{--------------------------------------------------------}
{              trata fim de recepcao de arquivo
{--------------------------------------------------------}

procedure trataFimRecebe;
var j: integer;
begin
    if wherex <> 1 then writeln;

    {$I-} close (arqRecebe);  {$I+}
    for j := 1 to 3 do
         begin
            bipSpeaker (40);
            bipSpeaker (47);
         end;

    if ioresult <> 0 then
        mensagem ('PPPROREC', 1)    {Problemas na recepção do arquivo}
    else
        mensagem ('PPBEMREC', 1);   {Arquivo bem recebido}
    recebendoArq := false;
end;

{--------------------------------------------------------}
{              trata recepcao do arquivo
{--------------------------------------------------------}

procedure trataArqRecebe (bufao: pchar; lidos: integer);
begin
    {$I-} blockwrite (arqRecebe, bufao^, lidos);  {$I+}
    if ioresult <> 0 then
        begin
            if not enviaRede (CANCARQENVIA, NIL, 0) then
                conversando := false;
        end;

    contaSpeaker := contaSpeaker + 1;
    if contaSpeaker > 8 then
        begin
            bipSpeaker (40);
            contaSpeaker := 0;
        end;
end;

{--------------------------------------------------------}
{              trata cancelamento da recepcao
{--------------------------------------------------------}

procedure trataCancArqRecebe;
begin
    if wherex <> 1 then writeln;
    mensagem ('PPPROTRA', 1);   {Problemas na transmissão do arquivo}

    {$I-} close (arqEnvia); {$I-}
    if ioresult <> 0 then
        ;
    enviandoArq := false;
    autorEnvioPendente := false;
end;

{--------------------------------------------------------}
{            trata inicio do envio do arquivo
{--------------------------------------------------------}

procedure trataInicioTransm;
begin
    contaSpeaker := 0;
    autorEnvioPendente := false;
    if wherex <> 1 then writeln;
    mensagem ('PPINITRA', 1);   {'Iniciando transmissão do arquivo'}
end;

{--------------------------------------------------------}
{            trata cancelamento de transmissão
{--------------------------------------------------------}

procedure trataCancTransm;
begin
    if wherex <> 1 then writeln;
    mensagem ('PPTRACAN', 1);   {Transmissão de arquivo cancelada}
    {$I-} close (arqEnvia); {$I-}
    if ioresult <> 0 then
        ;
    enviandoArq := false;
end;

end.
