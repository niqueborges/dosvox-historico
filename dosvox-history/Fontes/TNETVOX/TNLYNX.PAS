{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Controles do modo Lynx
{
{    Autor: Jose' Antonio Borges
{
{    Em 10/01/99
{
{-------------------------------------------------------------}

unit tnlynx;
interface
uses
    winprocs, dvcrt, dvWin, sysUtils, winsock,
    tnVars, tnFala, tnAnsi, tnRede, tnMsg, tnVideo,
    dvHora, videovox;

procedure recebeTelaLynx;

implementation

uses tnterm;

{--------------------------------------------------------}
{               recebe um "print" do lynx
{--------------------------------------------------------}

procedure recebeTelaLynx;
var arq: text;
    espera: integer;
    c: char;
    s: string;
    contaClek: integer;
label fim;


    function trataTeclado: boolean;
    begin
        trataTeclado := true;

        if keypressed then
            case c of
                #$1b: begin
                          trataTeclado := false;
                          exit;
                      end;

                 #$0:
                      begin
                          c := readkey;
                          if c = TEND then leLinhaVideo (22)
                          else
                          if c = HOME then leLinhaVideo (1);
                      end;

            else
                     begin
                         esclink (readkey);
                         if soletrando then sintCarac (c);
                     end;
            end;
    end;


begin
    gotoxy (1, numLinhasTerm);
    textBackGround (BLACK);
    clreol;
    textBackground (RED);

    mensagem ('TNNOMREC', 0);  {'Qual o nome do arquivo a receber ? '}
    textBackGround (BLACK);
    sintReadln (s);
    if s <> '' then nomeArqLynx := s;

    assign (arq, nomeArqLynx);
    {$I-} reset (arq);  {$I+}
    if ioresult = 0 then
        begin
            close (arq);
            {$I-} append (arq); {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('TNERRARQ', 1);  {'Erro ao criar arquivo. Recepcao cancelada'}
                    exit;
                end;
        end
    else
        begin
            {$I-} rewrite (arq);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('TNERRARQ', 1);  {'Erro ao criar arquivo. Recepcao cancelada'}
                    exit;
                end;
        end;

    mensagem ('TNRECTEL', 1);      {'Arquivando pagina www'}

    esclink ('P');
    delay (2000);
    while chegouLink do
        lelink (c);
    esclink (#$1b);  esclink ('[');  esclink ('B');
    esclink (#$1b);  esclink ('[');  esclink ('B');
    delay (1000);
    while chegouLink do
        lelink (c);

    esclink (#$0d);

    repeat
        if not trataTeclado then goto fim;

        if chegouLink then
            begin
                lelink (c);
                ansiwrite (c);
                if c = ']' then esclink ('y');
            end;
    until c = ':';

    writeln (arq, '------------- Inicio de texto do Lynx ------------');
    esclink (#$0d);

    espera := 0;
    contaClek := 0;
    while espera < 40 do
         begin
             if not trataTeclado then goto fim;

             while chegouLink do
                 begin
                     espera := 0;
                     leLink (c);
                     write (c);
                     write (arq, c);
                     if c = #$0d then
                          begin
                              contaClek := (contaClek + 1) mod 20;
                              if contaClek = 0 then sintclek;
                          end;
                 end;

             espera := espera + 1;
             delay (200);
         end;
fim:
    writeln (arq);
    writeln (arq, '------------- Fim de texto do Lynx ------------');
    close (arq);

    msgBaixo ('TNGRAV');  {'Arquivo gravado'}
    delay (1000);
    msgBaixo ('');
    esclink (#$0d);
    clrscr;
end;

end.