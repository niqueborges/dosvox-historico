{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Buffer de vídeo para otimizar velocidade
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnbufvid;
interface
uses dvcrt;

procedure escBufVideo;
procedure insBufVideo (c: char);

implementation
var
    bufVideo: string [80];

{-------------------------------------------------------------}
{                  descarrega buffer de video
{-------------------------------------------------------------}

procedure escBufVideo;
begin
    if length (BufVideo) = 0 then exit;
    write (bufVideo);
    bufVideo := '';
end;

{-------------------------------------------------------------}
{                  insere no buffer de video
{-------------------------------------------------------------}

procedure insBufVideo (c: char);
var x: integer;
begin
     if (c = #$0d) or (c = #$0a) or (c = #$0c) or (c = #$08) then
         begin
             escBufVideo;
             if c = #$08 then
                 gotoxy (wherex-1, wherey)
             else
             if c = #$0c then
                 clrscr
             else
                 begin
                     x := wherex;
                     write (c);
                     if c = #$0a then gotoxy (x, wherey);
                 end;
         end
     else
         begin
             bufVideo := bufVideo + c;
             if length (bufVideo) = 80 then
                 escBufVideo;
         end;
end;

begin
   BufVideo := '';
end.