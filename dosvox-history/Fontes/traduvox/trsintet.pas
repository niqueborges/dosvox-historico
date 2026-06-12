{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Módulo de síntese da tradução
{
{    Autor: José Antonio Borges
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{-------------------------------------------------------------}

unit trsintet;

interface
uses windows, dvwin, dvcrt, dvsapi, dvsapglb, sysutils;

procedure obtemVoz (lingua: string; var tipoSapi, numVoz: integer);
procedure presetSapi;


implementation

procedure obtemVoz (lingua: string; var tipoSapi, numVoz: integer);
var
    info: string;
begin
    tipoSapi := 0;
    numVoz := 1;
    info := trim (sintAmbiente('TRADUVOX', lingua));
    if info <> '' then
        begin
            try
                tipoSapi := strToInt (copy (info, 1, 1));
            except
                tipoSapi := 4;
            end;

            delete (info, 1, 2);
            info := trim (info);

            try
                numVoz := strToInt (info);
            except
                numVoz := 1;
            end;
        end;
end;

procedure presetSapi;
var
    param: TParamVoz;
    paramSapi: TInfoSapi;
    n, maxVozes: integer;
    sapi: integer;
    salvaParam: TParamVoz;
    info: string;


    procedure setaVoz (lingua: string; numero: integer);
    begin
        info := trim ( sintAmbiente ('TRADUVOX', lingua));
        if info = '' then
            begin
                if lingua = 'pt' then
                    info := '0,1'
                else
                    info := '4,' + intToStr(numero);
                    sintGravaAmbiente ('TRADUVOX', lingua, info);
            end;
    end;

begin
    sapiPegaParam (salvaParam);
    sapi := 4;
    sapiInic (1, 0, 0, sapi, '');

    sapiPegaParam (param);
    maxVozes := sapiNumVozes;
    if maxVozes = 0 then
        begin
            sapiInic (salvaParam.voz, salvaParam.velocidade, salvaParam.tom, salvaParam.tipoSapi, '');
            exit;
        end;

    for n := 1 to maxVozes do
        begin
            sapiInfo (n, paramSapi);
            if pos ('English', paramSapi.modo) <> 0 then setaVoz ('en', n)
            else
            if pos ('Portuguese', paramSapi.modo) <> 0 then setaVoz ('pt', n)
            else
            if pos ('Spanish', paramSapi.modo) <> 0 then setaVoz ('es', n)
            else
            if pos ('French', paramSapi.modo) <> 0 then setaVoz ('fr', n)
            else
            if pos ('Italian', paramSapi.modo) <> 0 then setaVoz ('it', n)
            else
            if pos ('German', paramSapi.modo) <> 0 then setaVoz ('de', n);
        end;

    sapiInic (salvaParam.voz, salvaParam.velocidade, salvaParam.tom, salvaParam.tipoSapi, '');
end;

end.
