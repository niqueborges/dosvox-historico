{-------------------------------------------------------------}
{
{    Exibe conteúdo do S.M.A.R.T.
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{    S.M.A.R.T by Siaamk Arbatani  siamak.arbatani@gmail.com}
{
{-------------------------------------------------------------}

unit hardsmar;

interface

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  hardmsg;

procedure monitorSmartDisco;

type
    TSmartData = array[0..527] of byte;

implementation

{--------------------------------------------------------}
{                busca informações do smart
{--------------------------------------------------------}

procedure getsmartdata (drive: integer; var data: TSmartData);
const
    ipar:array[0..31] of byte =
        (0,$02,0,0,$d0,$01,$01,$4f,$c2,$a0,$b0,0,0,0,0,0,$8c,$fd,$14,0,0,$02,0,
         0,$03,0,0,0,$03,0,0,0);
var
    hdrive:cardinal;
    dwBytesReturned : DWORD;
    opar: TSmartData;
begin
    hdrive := CreateFile( PChar('\\.\PhysicalDrive' + chr (drive + ord('0'))),
                        3221225472, 3, nil, 3, 0, 0 );
    DeviceIoControl( hdrive, $0007C088, @ipar, 32, @opar, 528, dwBytesReturned, nil );
    closehandle(hdrive);
    data:=opar;
end;

{--------------------------------------------------------}
{         monitora as informações do S.M.A.R.T.
{--------------------------------------------------------}

procedure monitorSmartDisco;
var
    c, c2: char;
    smartdatavar: TSmartData;
    drive: integer;
    sval: array [1..17] of shortString;

    {--------------------------------------------------------}

    function sdint (i: integer): string;
    begin
        result := inttostr (smartdatavar[i]*256 + smartdatavar[i-1]);
    end;

    {--------------------------------------------------------}

    procedure campo (msg: string; var valor: shortString);
    begin
        formCampo(msg, pegaTextoMensagem(msg), valor, 40);
    end;

    {--------------------------------------------------------}

begin
    writeln;
    mensagem ('HVINFISD', 0);  // 'Qual a unidade física de disco (0 a 3)? '
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
            mensagem ('HVDESIST', 2);  // 'Desistiu'
            exit
        end;

    drive := ord (c) - ord('0');
    if (drive < 0) or (drive > 3) then
        begin
            mensagem ('HVDRVERR', 2);  // 'Drive errado'
            exit;
        end;

    writeln;
    garanteEspacoTela(17);
    defineNovoTamanhoDeRotulos(40);
    formCria;

    getsmartdata(drive, smartdatavar);
    sval[1] := sdint(24);
    campo ('HVTSPIN',  sval[1]);  // 'Tempo de Spin Up'
    sval[2] := sdint(36);
    campo ('HVCSTART', sval[2]);  // 'Contador Start/Stop'
    sval[3] :=sdint (48);
    campo ('HVCREALO', sval[3]);  // 'Contador de setores realocados'
    sval[4] :=sdint (60);
    campo ('HVMARGEL', sval[4]);  // 'Margem do canal de leitura'
    sval[5] :=sdint (72);
    campo ('HVERRPOS', sval[5]);  // 'Taxa de erros de posicionamento'
    sval[6] :=sdint (84);
    campo ('HVTEMPOS', sval[6]);  // 'Desempenho do tempo de posicionamento'
    sval[7] :=sdint (96);
    campo ('HVTLIGAD', sval[7]);  // 'Minutos no estado ligado'
    sval[8] :=sdint (108);
    campo ('HVCRETRY', sval[8]);  // 'Contador de Spin Retry'
    sval[9] :=sdint (120);
    campo ('HVTENTAR', sval[9]);  // 'Tentativas de Recalibragem'
    sval[10] :=sdint (132);
    campo ('HVCDPOWR', sval[10]); // 'Contador de ciclo de Device Power'
    sval[11] :=sdint (156);
    campo ('HVCCARGA', sval[11]); // 'Contador do ciclo de carga/descarga'
    sval[12] :=sdint (168);
    campo ('HVPRTEMP', sval[12]); // 'Problema de Temperatura'
    sval[13] :=sdint (192);
    campo ('HVCEVREA', sval[13]); // 'Contador do evento de realocação'
    sval[14] :=sdint (204);
    campo ('HVCSETPD', sval[14]); // 'Contador de setores correntes pendentes'
    sval[15] :=sdint (216);
    campo ('HVCSETNC', sval[15]); // 'Contador de setores não corrigíveis'
    sval[16] :=sdint (228);
    campo ('HVCERDMA', sval[16]); // 'Contador de erros UDMA CRC'
    sval[17] :=sdint (240);
    campo ('HVCERRES', sval[17]); // 'Taxa de erros de escrita'

    formEdita(false);
    restauraTamanhoDeRotulos;
end;

end.

