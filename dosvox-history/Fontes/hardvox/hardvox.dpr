{-------------------------------------------------------------}
{
{    Programa de exibição de características da máquina
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

program hardvox;

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  hardmsg,
  hardhd,
  hardcpu,
  hardmoni,
  hardnome,
  hardmem,
  hardsmar,
  harduser,
  hardespd,
  hardaud,
  hardmbrd;

var versao: string = '3.0a';

{-------------------------------------------------------------}
{                  inicialização
{-------------------------------------------------------------}

procedure inicializa;
var ambiente: string;
begin
    ambiente := sintAmbiente ('HARDVOX', 'DIRHARDVOX', sintAmbiente('DOSVOX', 'PGMDOSVOX')+'\som\Hardvox');
    sintInic (0, ambiente);

    textBackground (BLUE);
    mensagem ('HVINIC', 0);   {'Hardvox - v.'}
    sintSoletra (versao);
    write(versao);
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    nopc = 11;
    tabLetrasOpcoes: string [nopc] = 'SPCMHEAVDU' + ESC;

begin
    garanteEspacoTela (nopc);
    popupMenuCria (wherex, wherey, 50, nopc, MAGENTA);
    MenuAdiciona ('HVOP_S');   // '  S - informações sobre o Sistema Operacional'
    MenuAdiciona ('HVOP_P');   // '  P - placa mãe'

    MenuAdiciona ('HVOP_C');   // '  C - CPU sob a perspectiva do Windows'
    MenuAdiciona ('HVOP_M');   // '  M - memoria RAM'
    MenuAdiciona ('HVOP_H');   // '  H - informações físicas sobre os HD'
    MenuAdiciona ('HVOP_E');   // '  E - espaço nos discos'
    MenuAdiciona ('HVOP_A');   // '  A - áudio e midi'
    MenuAdiciona ('HVOP_V');   // '  V - monitores de vídeo'
    MenuAdiciona ('HVOP_D');   // '  D - diagnostico SMART dos discos'
    MenuAdiciona ('HVOP_U');   // '  U - usuários da máquina'
    MenuAdiciona ('HVESC');    // '  ESC - termina'
    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcoes[n];
            gotoxy (20, wherey-1);
            write (tabLetrasOpcoes[n]);
            writeln;
        end
    else
        selSetasOpcao := ENTER;
end;

{-------------------------------------------------------------}
{                  loop de processamento
{-------------------------------------------------------------}

procedure processa;
var
    c, c2: char;
label
    executa,
    firstTime;

begin
    goto firstTime;
    repeat
        ClrScr;
        TextBackground (BLUE);
        Writeln (pegaTextoMensagem ('HVINIC') + versao);
        textBackground (BLACK);
        writeln;

firstTime:
        textBackground (RED);
        mensagem ('HVOPCAO', 0);    // 'Hardvox - opção: '
        textBackground (BLACK);

        salvaXY;
        sintLetecla (c, c2);
        writeln;

        if c = #0 then
            begin
                if c2 = F1 then
                    mensagem ('HVUSESET', 1)   // 'Para selecionar, use as setas'
                else
                if (c2 = CIMA) or (c2 = BAIX) then
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end
                else
                begin
                    writeln;
                    mensagem ('HVOPINV', 1);    // 'Opção inválida: aperte F1 para ajuda'
                end;
            end
        else
            begin
executa:
                restauraXY;
                limpaBaixo;
                textBackground (BLUE);
                write (pegaTextoMensagem ('HVOPCAO'));    // 'Hardvox - opção: '
                textBackground (BLACK);
                c := upcase (c);
                if c in ['A'..'Z'] then
                    write (c);
                writeln;

                case upcase(c) of
                    'S': informacoesSistema;
                    'P': infoPlacaMae;
//                  'T': temperaturaEOutros;
                    'C': infoCPU;
                    'M': infoMemoria;
                    'H': infoHD;
                    'E': mostraCaracDisco;
                    'A': infoAudio;
                    'V': infoVideo;
                    'D': monitorSmartDisco;
                    'U': infoUsuarios;
                    ESC, BS:  ;
                else
                    mensagem ('HVOPINV', 1);    // 'Opção inválida: aperte F1 para ajuda'
                end;
            end;

        writeln;
    until c = ESC;
end;

{-------------------------------------------------------------}
{                  finalização
{-------------------------------------------------------------}

procedure termina;
begin
    mensagem ('HVOBRIG', 1);   {'Obrigado por usar o hardvox'}
    sintFim;
end;

{-------------------------------------------------------------}
{                  programa principal
{-------------------------------------------------------------}

begin
    inicializa;
    processa;
    termina;
    doneWinCrt;
end.
