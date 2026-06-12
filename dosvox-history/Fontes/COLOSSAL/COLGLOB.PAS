{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de rotinas globais
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colglob;
interface
    uses colvars, colmsg;

{
 * macro functions
 *
 * liq()   = object number of liquid in bottle
 * liqloc(loc)  = object number of liquid (if any) at loc
 * bitset(l,n)  = true if cond(l) has bit n set (bit 0 is units bit)
 * forced(loc)  = true if loc moves without asking for input (cond=2)
 * dark()  = true if location "loc" is dark
 * pct(n)       = true n% of the time (n integer from 0 to 100)
}

function liq: integer;
function liq2(pbottle: integer): integer;
function liqloc(loc: integer): integer;
function forced(atloc: integer): boolean;
function dark: boolean;
function pct(x: integer): boolean;

function toting(item: integer): boolean;
function here(item: integer): boolean;
function at(item: integer): boolean;

procedure actspk(verb: integer);
procedure carry (obj, where: integer);
procedure xdrop(obj, where: integer);
procedure xmove(obj, where: integer);
function put(obj, where, pval: integer): integer;
procedure dstroy(obj: integer);
procedure juggle(loc: integer);

implementation

{--------------------------------------------------------}
{    diz se um lugar provoca uma movimentação forçada
{--------------------------------------------------------}

function forced(atloc: integer): boolean;
begin
    forced := cond[atloc] = 2;
end;

{--------------------------------------------------------}
{           vê se um item está sendo carregado
{--------------------------------------------------------}

function toting(item: integer): boolean;
begin
    if (item <= 0) or (item > MAXOBJ) then
        toting := false
    else
        toting := place[item] = -1;
end;

{--------------------------------------------------------}
{              vê se um item está presente
{--------------------------------------------------------}

function here(item: integer): boolean;
begin
    if (item <= 0) or (item > MAXOBJ) then
        here := false
    else
        here := (place[item] = loc) or toting(item);
end;

{--------------------------------------------------------}
{        diz se o jogador está em um dos lados de
{                um objeto com dois lados
{--------------------------------------------------------}

function at(item: integer): boolean;
begin
    if (item <= 0) or (item > MAXOBJ) then
        at := false
    else
        at := (place[item] = loc) or (fixed[item] = loc);
end;

{--------------------------------------------------------}
{                   vê se está escuro
{--------------------------------------------------------}

function dark: boolean;
begin
    dark :=((cond[loc] and LIGHT) = 0) and
           ((prop[LAMP] = 0) or (not here(LAMP)));
end;

{--------------------------------------------------------}
{              retorna verdade um % do tempo
{--------------------------------------------------------}

function pct(x: integer): boolean;
begin
    pct := random (100) < x;
end;

{--------------------------------------------------------}
{                   carrega um objeto
{--------------------------------------------------------}

procedure carry (obj, where: integer);
begin
    if obj < MAXOBJ then
        begin
	    if place[obj] = -1 then
                exit;
	    place[obj] := -1;
	    holding := holding + 1;
        end;
end;

{--------------------------------------------------------}
{                   larga um objeto
{--------------------------------------------------------}

procedure xdrop(obj, where: integer);
begin
    if obj < MAXOBJ then
        begin
	    if place[obj] = -1 then
	        holding := holding - 1;
	    place[obj] := where;
	end
    else
        fixed[obj-MAXOBJ] := where;
end;

{--------------------------------------------------------}
{                   move um objeto
{--------------------------------------------------------}

procedure xmove(obj, where: integer);
var from: integer;
begin
    if obj < MAXOBJ then
        from := place[obj]
    else
        from := fixed[obj-MAXOBJ];
    if (from > 0) and (from <= 300) then   {???????????}
        carry(obj, from);
    xdrop(obj, where);
end;

{--------------------------------------------------------}
{   move um objeto e retorna o valor usado para setar as
{       valores de prog negados para o repositório
{--------------------------------------------------------}

function put(obj, where, pval: integer): integer;
begin
    xmove (obj, where);
    put := -1-pval;
end;

{--------------------------------------------------------}
{                   destrói um objeto
{--------------------------------------------------------}

procedure dstroy(obj: integer);
begin
    xmove(obj, 0);
end;

{--------------------------------------------------------}
{                juggle um objeto (noop)
{--------------------------------------------------------}

procedure juggle(loc: integer);
begin
end;

{--------------------------------------------------------}
{	Converte 0 para WATER
{		 1 para nada
{		 2 para OIL
{--------------------------------------------------------}

function liq2(pbottle: integer): integer;
begin
    liq2 := ((1-pbottle)*WATER+(pbottle shr 1)*(WATER+OIL));
end;

{--------------------------------------------------------}
{              vê se tem líquido na garrafa
{--------------------------------------------------------}

function liq: integer;
var i: integer;
begin
    if prop[BOTTLE] > (-1-i) then    { esta rotina está errada !!!!!!!!!!!!!!!!}
        liq := liq2(prop[BOTTLE])
    else
        liq := liq2(-1-i);
end;

{--------------------------------------------------------}
{             determina o líquido num lugar
{--------------------------------------------------------}

function liqloc(loc: integer): integer;
begin

    if (cond[loc] and LIQUID) <> 0 then
        liqloc := liq2(cond[loc] and WATOIL)
    else
        liqloc := liq2(1);
end;

{--------------------------------------------------------}
{            fala a mensagem padrão do verbo
{--------------------------------------------------------}

procedure actspk(verb: integer);
var i: integer;
begin
    if (verb < 1) or (verb > 31) then
       bug(39);

    i := actmsg[verb];
    if i <> 0 then rspeak(i);
end;

end.
