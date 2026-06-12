{----------------------------------------------------------------}
{
{    Levox - leitor de documentos
{    Guarda e recupera posição de arquivos anteriores
{    Autor: Antonio Borges
{    Em 2/6/2002
{
{----------------------------------------------------------------}

unit leRetoma;

interface
uses
  dvcrt,
  dvWin,
  dvForm,
  lemsg,
  leVars,
  windows,
  sysutils,
  classes;

function recupPosicao: integer;
procedure salvaPosicao;
function obtemNomeAntigo: string;

implementation

{----------------------------------------------------------------}
{                  reposiciona onde parou leitura
{----------------------------------------------------------------}

function recupPosicao: integer;
var nomeCompleto, nomeAntigo: string;
    c: char;
    ref: string;
    p, linhaRef, erro: integer;
begin
    result := 0;
    nomeCompleto := expandFilename (nomeArq);

    for c := '0' to '9' do
        begin
            ref := sintAmbiente ('LEVOX', c);
            if trim(ref) = '' then continue;
            p := pos(',', ref);
            val (trim(copy (ref, 1, p-1)), linhaRef, erro);
            if erro <> 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, 999));

            if nomeAntigo = nomeCompleto then
                begin
                    result := linhaRef;
                    exit;
                end;
        end;
end;

{----------------------------------------------------------------}
{             guarda referência para continuar leitura
{----------------------------------------------------------------}

procedure salvaPosicao;
var nomeCompleto, nomeAntigo: string;
    c: char;
    ref, s, n: string;
    i, p: integer;
    sl: TStringList;
begin
    nomeCompleto := expandFilename (nomeArq);
    sl := TStringList.Create;

    for c := '0' to '9' do
        begin
            ref := sintAmbiente ('LEVOX', c);
            if trim(ref) <> '' then
                sl.Add (ref);
        end;

    for i := 0 to sl.Count-1 do
        begin
            ref := sl[i];
            p := pos(',', ref);
            if p = 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, 999));
            if nomeAntigo = nomeCompleto then
                begin
                    sl.Delete(i);
                    break;
                end;
        end;

    sl.Insert(0, intToStr(posy) + ',' + nomeCompleto);
    if sl.Count > 10 then
        sl.Delete(10);

    for i := 0 to 9 do
        begin
            n := intToStr(i);
            if i < sl.Count then
                begin
                    s := sl[i];
                    sintGravaAmbiente('LEVOX', n, s);
                end
            else
                sintRemoveAmbiente('LEVOX', n);
        end;

    sl.Free;
end;

{----------------------------------------------------------------}
{             guarda referência para continuar leitura
{----------------------------------------------------------------}

function obtemNomeAntigo: string;
var nomeAntigo: string;
    dir, dirA, nomeA: string;
    c: char;
    ref: string;
    p, n: integer;
begin
    result := '';
    getDir (0, dir);
    popupMenuCria(wherex, wherey, 80, 10, RED);

    for c := '0' to '9' do
        begin
            ref := sintAmbiente ('LEVOX', c);
            if trim(ref) = '' then continue;
            p := pos(',', ref);
            if p = 0 then continue;
            nomeAntigo := trim (copy (ref, p+1, 999));
            if FileExists (nomeAntigo) then
                begin
                    dirA  := ExcludeTrailingBackslash(ExtractFilePath(nomeAntigo));
                    nomeA := ExtractFileName(nomeAntigo);

                    if dir <> dirA then
                        popupMenuAdiciona ('', nomeA + ', em ' + dirA)
                    else
                        popupMenuAdiciona ('', nomeA);
                end;
        end;

    n := popupMenuSeleciona;
    if n <= 0 then exit;
    result := opcoesItemSelecionado;
    p := pos (', em ', result);
    if p <> 0 then
        result := copy (result, p+5, 999) + '\'+ copy(result, 1, p-1);
end;

end.

