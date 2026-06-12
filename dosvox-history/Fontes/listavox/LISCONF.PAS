{--------------------------------------------------------}
{
{    Programa de impressao comum
{
{    Configuração
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

unit lisconf;
interface

uses dvwin, dvcrt, dvForm, windows, sysutils,
     lismsg, lisvars;

function pegaParametros: boolean;

implementation

{--------------------------------------------------------}
{                 assume valores padrao
{--------------------------------------------------------}

procedure pegaParamDefault;

    function pegaParam (param: string; default: integer): integer;
    var erro, i: integer;
        s: string;
    begin
        pegaParam := default;
        s := sintAmbiente ('LISTAVOX', param);
        if s <> '' then
            begin
                val (s, i, erro);
                if erro = 0 then pegaParam := i;
            end
        else
            begin
                sintGravaAmbiente ('LISTAVOX', param, intToStr(default));
            end;
    end;

begin
    numerando := false;
    ncopias := 1;
    pagInicial := 1;
    pagFinal := 9999;
    numInicial := 1;

    colunasPapel := pegaParam ('ColunasPapel', 80);
    LinhasPapel  := pegaParam ('LinhasPapel', 66);
    primLinha :=  pegaParam ('PrimeiraLinha', 3);
    ultLinha := pegaParam ('UltimaLinha', 62);
    primCol := pegaParam ('PrimeiraColuna', 8);
    ultCol := pegaParam ('UltimaColuna', 79);
end;

{--------------------------------------------------------------}
{    substitui a impressora padrão por outra existente
{--------------------------------------------------------------}

function modifImpressoraPadrao: boolean;

var
   imp: array [1..30] of pchar;
   nImp: integer;
   returnString: array [0..2000] of char;
   paramImp, padrao: array [0..200] of char;
   i, n, l: integer;
   s :string;

begin
  modifImpressoraPadrao := false;

  GetProfileString('Devices', nil, '', returnString, 2000);

  nImp := 0;
  i := 0;
  while returnString[i] <> #0 do
      begin
          nImp := nImp + 1;
          imp[nimp] := @returnString[i];
          while returnString[i] <> #0 do
              i := i + 1;
          i := i + 1;
      end;

  if nImp = 0 then
      begin
          mensagem ('LISEMIMP', 1);    {'Não existe impressora instalada'}
          exit;
      end;

  mensagem ('LIIMEX',1);  {  As impressoras existentes são: }

  for n := 1 to nImp do
      begin
          str (n, s);
          sintWriteln (s + ' ' + strPas (imp[n]));
      end;

  mensagem ('LIQUDEPA',0);   { Qual impressora você desejá tornar padrão ? }
  l := 0;
  SintReadInt (l);
  if l = 0 then
      mensagem ('LIMAIMAT',1)    { Mantida impressora atual }
  else
      begin
          if (l < 1) or (l > nImp) then l := 1;

          GetProfileString('Devices', imp[l], '', paramImp, 200);
          strcopy (padrao, imp[l]);
          strcat (padrao, ',');
          strcat (padrao, paramImp);
          writeProfileString ('windows', 'device', padrao);

          mensagem ('LIIMPAAL',1);  { impressora padrão alterada }
      end;

  modifImpressoraPadrao := true;
end;

{--------------------------------------------------------}
{          altera configuração física da página
{--------------------------------------------------------}

function configFisica: boolean;
var c: char;
    guardaValores: boolean;

        procedure guardaParam (param: string; valor: integer);
        begin
            sintGravaAmbiente ('LISTAVOX', param, intToStr(valor));
        end;

begin
    configFisica := true;
    writeln;
    mensagem ('LITRIMPA',0);         {'Deseja trocar impressora padrão do DOSVOX ?}
    c := sintReadKey;
    writeln (c);
    if upcase (c) = 'S' then
        if not modifImpressoraPadrao then
            begin
            configFisica := false;
            exit;
        end;

    garanteEspacoTela(8);

    guardaValores := true;

    tamRotulosForm := 50;
    formCria;
    formCampoInt('LICOLPAP', pegaTextoMensagem ('LICOLPAP'), colunasPapel);
                             {'Quantas colunas tem o papel (geralmente 80) ? '}
    formCampoInt('LILINPAP', pegaTextoMensagem ('LILINPAP'), linhasPapel);
                             {'Quantas linhas tem o papel (geralmente 66)  ? '}
    formCampoInt('LIPRILIN', pegaTextoMensagem ('LIPRILIN'), primLinha);
                             {'Primeira linha a imprimir (geralmente 3):  '}
    formCampoInt('LIULTLIN', pegaTextoMensagem ('LIULTLIN'), ultLinha);
                             {'Última linha a imprimir (geralmente 62):   '}
    formCampoInt('LIPRICOL', pegaTextoMensagem ('LIPRICOL'), primCol);
                             {'Primeira coluna a imprimir (geralmente 8): '}
    formCampoInt('LIULTCOL', pegaTextoMensagem ('LIULTCOL'), ultCol);
                             {'Última coluna a imprimir (geralmente 72):  '}
    formCampoBool('LIGUARDA', pegaTextoMensagem ('LIGUARDA'), guardaValores);
                             {'Guardo esses valores como novos padrões ? '}
    formEdita (true);

    if guardaValores then
        begin
            guardaParam ('ColunasPapel', colunasPapel);
            guardaParam ('LinhasPapel', LinhasPapel);
            guardaParam ('PrimeiraLinha', primLinha);
            guardaParam ('UltimaLinha', ultLinha);
            guardaParam ('PrimeiraColuna', primCol);
            guardaParam ('UltimaColuna', ultCol);
        end;
end;

{--------------------------------------------------------}
{            pega parametros para a impressao
{--------------------------------------------------------}

function pegaParametros: boolean;
var c: char;
    trocaPrt: boolean;
begin
    pegaParametros := true;
    pegaParamDefault;

    textBackground (RED);
    mensagem ('LIPADRAO', 0);               {'Posso usar a configuração habitual ? '}
    textBackground (BLACK); clreol;
    c := sintReadKey;
    writeln (c);

    if c = #$1b then
        begin
            writeln;
            mensagem ('LIIMPCAN', -1); {'Impressão cancelada'}
            pegaParametros := false;
            exit;
        end;

    if upcase(c) = 'N' then
        begin
            writeln;

            trocaPrt := false;

            tamRotulosForm := 50;
            formCria;
            formCampoBool ('LINUMERA', pegaTextoMensagem ('LINUMERA'), numerando);
                                       {'Deseja numeração de páginas ? '}
            formCampoInt  ('LINCOP',   pegaTextoMensagem ('LINCOP'), ncopias);
                                       {'Quantas cópias ? '}
            formCampoInt  ('LIPAGINI', pegaTextoMensagem ('LIPAGINI'), pagInicial);
                                       {'Página inicial a imprimir (assumo 1) ? '}
            formCampoInt  ('LIPAGFIN', pegaTextoMensagem ('LIPAGFIN'), pagInicial);
                                       {'Página final a imprimir (assumo 9999) ? '}
            formCampoInt  ('LINUMINI', pegaTextoMensagem ('LINUMINI'), numInicial);
                                       {'Página final a imprimir (assumo 9999) ? '}
            formCampoBool ('LIMUDPAD', pegaTextoMensagem ('LIMUDPAD'), trocaPrt);
                                       {'Deseja configurar padrões físicos de impressão ? }
            formEdita (true);

            if trocaPrt then
                if not configFisica then
                    begin
                        pegaParametros := false;
                        exit;
                    end;

            writeln;
            mensagem ('LIPOSIMP', 0);        {'Posso imprimir agora ? '}
            c := sintReadKey;
            writeln(c);
            if upcase (c) = 'N' then pegaParametros := false;
        end;
end;

end.
