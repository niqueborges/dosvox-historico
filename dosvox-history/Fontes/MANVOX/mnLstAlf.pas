{--------------------------------------------------------}
{
{    Manual interativo do DOsvox
{
{    Módulo de exibir todos os manuais
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

unit mnLstAlf;

interface
uses
  dvcrt,
  dvwin,
  dvform,
  dvexec,
  sysutils,
  classes,
  mnmsg;

procedure manual_de_programa;

implementation


procedure manual_de_programa;
var
    arq : textfile;
    lista : TStringlist;
    x ,nomeConfig, nomeLeitor, nomePasta:String;
    p ,i :Integer;
begin
    clrscr;
    textBackground (BLUE);
    mensagem ('MNINIC', 1);             {'Manual eletrônico do Dosvox'}
    textBackground (BLACK);
    writeln;

    mensagem ('MNESCPRO', 1);              {'Escolha com as setas o programa e aperte Enter.'}

    nomeConfig := sintAmbiente('MANVOX','PORCATEGORIA');
    if nomeConfig = '' then
        nomeConfig := 'c:\winvox\manual\porCategoria.cfg';

    lista:= TStringlist.Create;
    assign(arq, nomeConfig);
     {$I-}  reset(arq);  {$I+}
     if ioresult <> 0 then
         writeln('erro');
     while not eof (arq) do
         begin
             readln(arq, x);
             if (x<>'') and (x[1] <> ';') and (x[1] <> '[') then
                 begin
                     p := pos('=', x);
                     lista.add(copy(x, 1, p-1));
                 end;
         end;
     lista.sort;

     popupMenuCria (wherex, wherey, 20, 25-wherey, RED);
     for i:=0 to lista.count-1 do
         popupMenuAdiciona('', lista[i]);
     i := popupMenuSeleciona;

     if i <= 0 then
         begin
             mensagem ('MNDESIST', 1);   {'Desistiu'}
             exit;
         end;

     nomeLeitor := SintAmbiente( 'MANVOX', 'LEITOR');
     if nomeLeitor = '' then
         nomeLeitor :='c:\winvox\levox.exe';

     nomePasta := SintAmbiente('MANVOX', 'DIRMANUAIS');
     if nomePasta = '' then
         nomePasta := 'c:\winvox\manual';

    executaprog(nomeLeitor, '.', nomePasta+'\'+lista[i-1]+'.txt');
    esperaProgVoltar;
    lista.Free;
end;

end.
