{--------------------------------------------------------}
{
{             Ajusta o arquivo de configuração do Dosvox
{
{    Versão 2 utiliza a constante definida em
{    dvCrt.pas (DOSVOXINIFILE)
{
{    Autor: Patrick Barboza
{
{    Em fevereiro/2024
{
{    Programa escrito originalmente por Neno Albernaz
{
{--------------------------------------------------------}

program ajustaIni;
uses windows, dvcrt, dvwin, sysutils, minireg;

function mudaArrobas (s, dirOriginal: string): string;
var p: integer;
begin
     p := pos ('@@', s);
     if p <> 0 then
         begin
             delete (s, p, 2);
             insert (sintDirAmbiente, s, p);
         end;

     p := pos ('=@', s);
     if p <> 0 then
         begin
             delete (s, p+1, 1);
             insert (dirOriginal, s, p+1);
         end;

     p := pos ('@\', s);
     if p <> 0 then
         begin
             delete (s, p, 1);
             insert (dirOriginal, s, p);
         end;

     result := s;
end;

{----------------------------------------------------------------}
{      copia o arquivo de configuração para appdata\roaming\dosvox
{----------------------------------------------------------------}

procedure criaDosvoxIni (dirConfigs, dirDoExecutavel: string);
var
    arqOrig, arqDest: text;
    s: string;
begin
    {$I-} mkdir (dirConfigs);  {$i-}  ioresult;   // cria, se não existe

    assignFile (arqOrig, dirDoExecutavel + '\iniOriginal\'+DOSVOXINIFILE);
    {$I-}  reset (arqOrig);   {$I+}
    if ioresult <> 0 then
        begin
            beep; beep; beep;
            writeln (DOSVOXINIFILE+' não foi encontrado no diretório de execução');
            writeln ('Reconfiguração do Dosvox foi cancelada, aperte enter.');
            readln;
            doneWinCrt;
        end;

    assignFile (arqDest, dirConfigs + '\'+DOSVOXINIFILE);
    {$I-} rewrite (arqDest); {$I+}
    if ioresult <> 0 then exit;

    while not eof (arqOrig) do
         begin
             readln (arqOrig, s);
             s := mudaArrobas (s, dirDoExecutavel);
             writeln (arqDest, s);
         end;

    closeFile (arqOrig);
    closeFile (arqDest);
end;

{--------------------------------------------------------------}
{          se o arquivo de configuração não está correto, recria
{--------------------------------------------------------------}

procedure checaDosvoxIni;
var
    dirDoExecutavel, dirConfigs: string;
    pnomeDir: array [0..255] of char;
    s: string;
    confirma: char;

begin
    // Não remova a chamada abaixo. Na primeira execução do Dosvox,
    // a função dosvoxIniDir pode retornar valores não confiáveis.
    regGetString (HKEY_CURRENT_USER,
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData',
            DirConfigs);
    DirConfigs := DirConfigs + '\Dosvox';

    GetModuleFileName (0, pnomeDir, 255);
    dirDoExecutavel := ExtractFilePath(strPas (pnomeDir));
    delete (dirDoExecutavel, length(dirDoExecutavel), 1);

    if fileExists (dirConfigs+ '\'+DOSVOXINIFILE) then
        begin
            s := sintAmbiente ('TRADUTOR', 'DIRDIFONES');
            if not fileExists (s + '\PORTUG.EXC') then
                begin
                    beep;
                    deleteFile (dirConfigs+ '\'+DOSVOXINIFILE);
                end
            else
                begin
                    write (DOSVOXINIFILE+' já existia, quer recriá-lo (s/n)? ');
                    readln (confirma);
                    if upcase(confirma) = 'S' then
                        begin
                            beep;
                            deleteFile (dirConfigs+ '\'+DOSVOXINIFILE);
                        end
                    else
                        exit;  // deixa como está...
                end;
        end;

    criaDosvoxIni (dirConfigs, dirDoExecutavel);
end;

begin
    screenSize.y := 10;
    writeln ('Checando '+DOSVOXINIFILE);
    checaDosvoxIni;
    writeln ('Ok');
    delay (2000);
end.
