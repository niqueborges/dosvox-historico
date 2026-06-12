{--------------------------------------------------------}
{
{    brlServer, servidor de linhas Braille multi cliente
{
{    Módulo de seleção/utilização das linhas Braille
{
{    Autores: Patrick Barboza e Antonio Borges
{
{    Em julho/agosto/2023
{
{    Atualizado em Agosto/2024
{
{--------------------------------------------------------}

unit brlDispositivos;

interface
uses
    dvCrt,
    dvWin,
    dvForm,
    dvHims,
    dvFocus80,
    sysUtils,
    brlVars;

function inicializaDispositivo (nome: string): boolean;
function selecionarDispositivo: string;
procedure configuraDispositivo;
procedure jogaNaLinhaBraille (conteudo: string);
procedure fechaDispositivo;

implementation

{--------------------------------------------------------}

procedure jogaNaLinhaBraille (conteudo: string);
begin
    if debug then sintWriteln(conteudo);
    if nomeDisp = 'HIMS' then writeHIMS(0,0,conteudo)
    else if nomeDisp = 'FOCUS' then focus80_Write(conteudo);
    //Adicionar mais aqui
end;

{--------------------------------------------------------}

function parseLinha(tipo: integer; s: string): string;
var res: string;
begin
    res := '';
    if (tipo = 1) then res := copy (s, 1, pos(':', s)-1)   //Copia até :
    else if (tipo = 2) then res := copy(s, pos(':', s)+1, length(s));   //Copia de : para o final
    result := res;
end;

{--------------------------------------------------------}

procedure configuraDispositivo;

    function selSetasDisp: integer;

    procedure MenuAdiciona (msg: string);
    begin
            popupMenuAdiciona(parseLinha(1, msg), parseLinha(2, msg));
    end;

    var n, i: integer;
    begin
        popupMenuCria (1, wherey, 60, 20, BLACK);
        for i := 1 to MAXDISP do
            MenuAdiciona (nomesDisp[i]);
        n := popupMenuSeleciona;
        if n > 0 then
            selSetasDisp := n
        else
            selSetasDisp := 0;
    end;

var
    numOp: integer;
    dispEscolhido, dispEscolhidoExibe: string;
begin
    sintWriteln('Selecione o dispositivo desejado com as setas:');
    numOp := selSetasDisp;
    if numOp > 0 then
    begin
        dispEscolhido := parseLinha(1, nomesDisp[numOp]);
        dispEscolhidoExibe := parseLinha(2, nomesDisp[numOp]);
        sintGravaAmbiente('DOSVOX', 'LINHABRAILLE', dispEscolhido);
        nomeDisp := dispEscolhido;
        sintWriteln(dispEscolhidoExibe+' definido com sucesso');
    end
    else
    begin
        sintWriteln('Dispositivo inválido. Mantendo sem Braille');
    end;
end;

{--------------------------------------------------------}

procedure fechaDispositivo;
begin
    if nomeDisp = 'HIMS' then closeHIMS
    else if nomeDisp = 'FOCUS' then focus80_close;
    //Adicionar mais aqui
end;

{--------------------------------------------------------}

function inicializaDispositivo (nome: string): boolean;
var
    ret: integer;
    ok: boolean;
begin
    result := false;
    if (nome = SEM_BRAILLE) then
        exit;   //SEM BRAILLE não é dispositivo válido
    sintWriteln('Iniciando dispositivo...');
    if upperCase(nome) = 'HIMS' then
        begin
            ok := loadHIMS;   //HIMS primeiro necessita abrir a dll
            if (ok = false) then
            begin
                sintWriteln('Não foi possível inicializar a biblioteca do dispositivo');
                exit;
            end;

            ret := openHIMS;
            if debug then sintWriteln('Retorno da abertura: '+intToStr(ret));

            if (ret = 0) then
                begin
                    sintWriteln('Erro na abertura do dispositivo');
                    exit;
                end;

            if debug then sintWriteln('Número de colunas: '+intToStr(cellsTotal));
        end   { if nome   }
    else if upperCase(nome) = 'FOCUS' then
        begin
            ok := focus80_Open;
            if (ok = false) then
            begin
                    sintWriteln('Erro na abertura do dispositivo');
                exit;
            end;

            if debug then sintWriteln('Número de colunas: '+intToStr(focusNumCells));
        end;   { if nome   }

    //Adicionar mais aqui

    sintWriteln('Dispositivo ativo');
    result := true;
end;

{--------------------------------------------------------}

function selecionarDispositivo: string;
var
    disp: string;
begin
    disp := sintAmbiente('DOSVOX', 'LINHABRAILLE', SEM_BRAILLE);
    if debug then sintWriteln('Veio do Dosvox.ini '+disp);
    result := disp;
end;

begin
end.
