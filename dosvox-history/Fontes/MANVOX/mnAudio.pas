{--------------------------------------------------------}
{
{    Manual interativo do DOsvox
{
{    Módulo de execuçao dos arquivos em audio
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

unit mnAudio;

interface
uses
  dvcrt,
  dvwin,
  dvform,
  dvexec,
  sysutils,
  classes,
  mnmsg;

Procedure curso_em_audio;

implementation

Procedure executaAudio (aExecutar : String);
var
    nomeMidia, nomePasta: String;
begin
    nomePasta := sintAmbiente('MANVOX','DIRAUDIOS');
    if nomePasta = '' then
        nomePasta := 'c:\winvox\manual\audios';

    nomeMidia := sintAmbiente('MANVOX','MIDIA');
    if nomeMidia = '' then
        nomeMidia := 'c:\winvox\midiavox.exe';

    executaProg(nomeMidia, nomePasta , aexecutar );
    esperaProgVoltar;
end;

Procedure curso_em_audio;
var
    arq: Textfile;
    p, n: integer;
    linha, nomeLeitor, aler, nomelinha : String;
    nomesAudios: TStringList;

Begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem('MNINIC'));             {'Manual eletrônico do Dosvox'}
    textBackground (BLACK);
    writeln;

    mensagem ('MNESCAUD', 2);              {'Escolha com as setas a aula em áudio e aperte Enter.'}

    nomesAudios := TStringList.Create;
    popupMenuCria (wherex, wherey, 50, 25-wherey, RED);

    nomeLeitor := sintAmbiente('MANVOX','AUDIOS');
    if nomeLeitor = '' then
         nomeLeitor := 'c:\winvox\manual\audios.cfg';

    assign(arq, nomeLeitor);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MNAUDNAO', 2);  {'Arquivo audios.cfg não foi encontrado'}
            mensagem ('MNOPCANC', 2);  {'Operação cancelada'}
            exit;
        end;

    while not eof (arq) do
        Begin
            readln(arq, linha);
            p := pos('=', linha);
            nomelinha:= copy (linha, p+1, 999);
            nomesAudios.add (copy(linha, 1, p-1));
            popupMenuAdiciona ('', nomelinha);
        end;
    closefile(arq);

    n := popupMenuSeleciona;
    if n < 1 then
        begin
            mensagem ('MNDESIST', 1);   {'Desistiu'}
            exit;
        end;

    aLer := opcoesItemSelecionado;
    writeln (aLer);
    writeln;
    mensagem ('MNMOMENT', 2);   {'Um momento...'}
    executaAudio (nomesAudios[n-1]);

    nomesAudios.free;
    writeln;
end;

end.
