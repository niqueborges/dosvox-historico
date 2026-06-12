{--------------------------------------------------------}
{
{    Jogavox - criador de jogos educacionais
{
{    Módulo de programação do lugar (entrar e sair)
{
{    Autores: José Antonio Borges
{             Lidiane Figueira Silva
{             Bernard Condorcet
{
{    Em Janeiro/2009
{
{--------------------------------------------------------}

unit joprglug;

interface
uses
  dvWin,
  dvcrt,
  dvform,
  jovars,
  jomsg,
  dvDigiTexto,
  classes,
  sysutils,
  strUtils;

procedure programacaoDoLugar (indLocalAtual: integer);

implementation

function agregaPrograma (var sl: TStringList; rotulo: string): integer;
var c: char;
begin
    sintWrite (rotulo + ': ');
    mensagem ('JOCNFPRO', 0);  {'Confirma programação? '}
    c := popupMenuPorLetra('SN');
    writeln;
    if (upcase(c) = 'N') or (c = ESC) then
        begin
            mensagem ('JODESIST', 2);  {'Desistiu'}
            exit;
        end;

   if copy (rotulo, 1, 1) = '@' then
       delete (rotulo, 1, 1);

   if (sl.Count > 0) and (sl[sl.Count-1] <> '') then
       sl.Add ('');

   result := sl.Count;
   sl.Add('@' + rotulo);
   sl.Add('');
   sl.Add('*** Digite aqui a programação ***');
   sl.Add('');
   sl.Add('retorna');
end;

function tiraBrancos (s: string): string;
var i: integer;
begin
    for i := 1 to length(s) do
        if s[i] = ' ' then s[i] := '_';
    result := s;
end;

function tentaLocalizarRotulo (rotulo: string; nomeArqScript: string): integer;
var sl: TStringList;
    i: integer;
begin
    result := -1;
    if not FileExists(nomeArqScript) then exit;

    if copy (rotulo, 1, 1) = '@' then  // evita '@@'
        delete (rotulo, 1, 1);

    rotulo := '@' + ansiUpperCase(rotulo) + ' ';
    sl := TStringList.Create;
    sl.LoadFromFile (nomeArqScript);
    for i := 0 to sl.count-1 do
        if pos(rotulo, trim(ansiUpperCase(sl[i]))+' ') = 1 then
             begin
                 result := i;
                 break;
             end;
    sl.free;
end;

function tentaTrazerLegado (indLocalAtual: integer): boolean;
var
    nomeLegado, nomeArqScript: string;
    slLegado, sl: TStringList;
    s: string;

begin
    result := false;
    nomeLegado := jogo.lugares[indLocalAtual].nome;
    if fileExists (nomeLegado + '.pro') then
        begin
            mensagem ('JOLEGADO', 1);  {'Foi encontrado um script externo para este lugar'}
            mensagem ('JOVOUIMP', 1);  {'Vou importar, confirma (s/n)? '}
            if popupMenuPorLetra('SN') <> 'S' then
                exit;

            slLegado := TStringList.create;
            slLegado.LoadFromFile(nomeLegado + '.pro');

            sl := TStringList.create;
            nomeArqScript := copy (nomeArqJogo, 1, length(nomeArqJogo)-4) + '.pro';
            if FileExists(nomeArqScript) then
                sl.LoadFromFile (nomeArqScript);

            if slLegado.Count > 0 then
                begin
                    if copy (slLegado[0], 1, 1) = '@' then
                        slLegado.Delete (0);   // remove o rótulo antigo
                    sl.Add('');
                end;

            sl.Add('@' + tiraBrancos(nomeLegado));
            if slLegado.Count > 0 then
                begin
                    s := trim(slLegado[slLegado.count-1]);
                    if (upperCase(copy (s, 1, 7)) <> 'TERMINA') and
                       (upperCase(copy (s, 1, 7)) <> 'RETORNA') then
                    slLegado.add ('retorna');
                end;
            sl.addStrings (slLegado);
            sl.SaveToFile(nomeArqScript);

            slLegado.free;
            sl.Free;
            result := true;

        end;
end;

procedure programacaoDoLugar (indLocalAtual: integer);
var nomeArqScript: string;
    sl: TStringList;
    posScript, posScriptSai: integer;
begin
    nomeArqScript := copy (nomeArqJogo, 1, length(nomeArqJogo)-4) + '.pro';
    with jogo.lugares[indLocalAtual]^ do
        begin
            if scriptEntrada = '' then
                if (tentaLocalizarRotulo (nome, nomeArqScript) >= 0) or
                   (tentaTrazerLegado (indLocalAtual)) then
                        scriptEntrada := '@' + tiraBrancos(nome);

            if (scriptEntrada = '') and (scriptSaida = '') then
                begin
                    scriptEntrada := '@' + tiraBrancos(nome);
                    mensagem ('JOCRISCR', 0);  {'Criando script '}
                    sintWriteln (scriptEntrada);
                end;

            sl := TStringList.Create;
            if fileExists (nomeArqScript) then
                sl.LoadFromFile(nomeArqScript);

            posScript := -1;
            posScriptSai := -1;
            if scriptEntrada <> '' then
                begin
                    posScript := tentaLocalizarRotulo (scriptEntrada, nomeArqScript);
                    if posScript < 0 then
                        posScript := agregaPrograma (sl, scriptEntrada);
                end;
            if scriptSaida <> '' then
                begin
                    posScriptSai := tentaLocalizarRotulo (scriptSaida, nomeArqScript);
                    if posScriptSai < 0 then
                        posScriptSai := agregaPrograma (sl, scriptSaida);
                end;
        end;

    // nota: mudar o digiTexto para ele reposicionar no lugar da entrada
    if (posScriptSai >= 0) and (posScript < 0) then
        posScript := posScriptSai;

    if posScript >= 0 then
         begin
            dvdigitexto.digiTexto(sl, false, wherex, wherey, 80, 24-wherey,
                    black, white, yellow, green, nomeArqScript, true, posScript);
            sl.SaveToFile(nomeArqScript);
            mensagem ('JOPROREG', 1);    {'Programação registrada'}
         end;

    sl.free;
end;

end.

