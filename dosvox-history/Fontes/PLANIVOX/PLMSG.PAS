{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de mensagens
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plmsg;

interface

uses dvCrt, dvWin,
     plVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string);
procedure falaPos;
procedure somaPos;
procedure som (s: string);
procedure mensagemSonora (s: string);
procedure pergunta (s: string);
procedure informa (s: string);

const msgErroExec = '=ERRO';

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin

    if nomeArq = 'PLINIC'   then
        s:= 'PLANILHA ELETRÔNICA VOX - VERSÃO '
    else
    if nomeArq = 'PLQUALOP' then
        s:= 'Qual a opção ? ESC retorna'
    else
    if nomeArq = 'PLPODEDI' then
        s:= 'Edite'
    else
    if nomeArq = 'PLCRIE' then
        s:= 'Crie'
    else
    if nomeArq = 'PLOK'     then
        s:= 'Ok'
    else
    if (nomeArq = 'PLDESIS') or (nomeArq = 'PLDESIST') then
        s:= 'Desistiu'
    else
    if nomeArq = 'PLLIMPA'  then
        s:= 'Célula limpa'
    else
    if nomeArq = 'PLERRNUM' then
        s:= 'Numero inválido, célula alfa criada'
    else
    if nomeArq = 'PLERRCAL' then
        s:= 'Erro ao calcular célula'
    else
    if nomeArq = 'PLERREXP' then
        s:= 'Expressão mal formada'
    else
    if nomeArq = 'PLCELINV' then
        s:= 'Célula inválida'
    else
    if nomeArq = 'PLERRVAL' then
        s:= 'Valor numérico inválido'
    else
    if nomeArq = 'PLERRCAD' then
        s:= 'Faltou terminar cadeia'
    else
    if nomeArq = 'PLFUNINV' then
        s:= 'Função inválida'
    else
    if nomeArq = 'PLBLKINV' then
        s:= 'Bloco inválido'
    else
    if nomeArq = 'PLERRPAR' then
        s:= 'Esperado abre parênteses'
    else
    if nomeArq = 'PLERRVIR' then
        s:= 'Esperada vírgula'
    else
    if nomeArq = 'PLERRFPA' then
        s:= 'Faltou fechar parênteses'
    else
    if nomeArq = 'PLRESINV' then
        s:= 'Resultado inválido'
    else
    if nomeArq = 'PLCARINV' then
        s:= 'Caractere inválido'
    else
    if nomeArq = 'PLCNFCOP' then
      s:= 'Confirma cópia para bloco ja preenchido (S/N) ? '
    else
    if nomeArq = 'PLCELCOP' then
        s:= 'Célula copiada para todo o bloco'
    else
    if nomeArq = 'PLCELMOV' then
        s:= 'Célula movida'
    else
    if nomeArq = 'PLBLKINI' then
        s:= 'Início do Bloco'
    else
    if nomeArq = 'PLBLKFIM' then
        s:= 'Fim do Bloco'
    else
    if nomeArq = 'PLBLKAPA'  then
        s:= 'Bloco apagado'
    else
    if nomeArq = 'PLCNFNOV' then
        s:= 'Abandona esta e cria nova planilha (s/n) ? '
    else
    if nomeArq = 'PLGRVAND' then
        s:= 'Gravando planilha'
    else
    if nomeArq = 'PLERRESC' then
        s:= 'Erro de escrita em disco'
    else
    if nomeArq = 'PLERRNOM' then
        s:= 'Nome de arquivo incorreto'
    else
    if nomeArq = 'PLLENDO' then
        s:= 'Lendo planilha'
    else
    if nomeArq = 'PLERRLEI' then
        s:= 'Erro de leitura em disco, aperte uma tecla'
    else
    if nomeArq = 'PLQUENOM' then
      s:= 'Qual o nome do arquivo da Planilha ?'
    else
    if nomeArq = 'PLGRAVAD' then
      s:= 'Planilha gravada'
    else
    if nomeArq = 'PLLIDA' then
      s:= 'Planilha lida'
    else
    if nomeArq = 'PLQUERVG' then
      s:= 'Quer salvar esta planilha (S/N)? ESC desiste'
    else
    if nomeArq = 'PLARQNAO' then
      s:= 'Arquivo não existe'
    else
    if nomeArq = 'PLNAOSAI' then
      s:= 'Finalização cancelada pois não consegui gravar no disco'
    else
    if nomeArq = 'PLCELDST' then
      s:= 'Informe as coordenadas da célula destino: '
    else
    if nomeArq = 'PLOPINV' then
        s:= 'Opção inválida'
    else
    if nomeArq = 'PLGAJU01' then
        s:= '  C - Célula'
    else
    if nomeArq = 'PLGAJU02' then
        s:= '  B - Bloco'
    else
    if nomeArq = 'PLGAJU03' then
        s:= '  P - Planilha'
    else
    if nomeArq = 'PLGAJU04' then
        s:= '  A - Arquivo'
    else
    if nomeArq = 'PLGAJU05' then
        s:= '  I - Imprimir'
    else
    if nomeArq = 'PLGAJU06' then
        s:= '  E - Extra'
    else
    if nomeArq = 'PLGAJU07' then
        s:= '  M - Macro'
    else
    if nomeArq = 'PLGAJU08' then
        s:= '  F - Fim'
    else
    if nomeArq = 'PLQUALCL' then
        s:= 'Qual a opção de célula ? '
    else
    if nomeArq = 'PLGAJU09' then
        s:= '  A - Apaga'
    else
    if nomeArq = 'PLGAJU10' then
        s:= '  C - Copia'
    else
    if nomeArq = 'PLGAJU11' then
        s:= '  M - Move'
    else
    if nomeArq = 'PLGAJ11A' then
        s:= '  D - Desmarca'
    else
    if nomeArq = 'PLGAJ11B' then
        s:= '  O - Ordena'
    else
    if nomeArq = 'PLGAJ11C' then
        s:= '  T - Textualiza'
    else
    if nomeArq = 'PLGAJ11D' then
        s:= '  N - Numera'
    else
    if nomeArq = 'PLGAJU12' then
        s:= '  F - Formato'
    else
    if nomeArq = 'PLGAJU13' then
        s:= '  L - Largura'
    else
    if nomeArq = 'PLGAJU14' then
        s:= '  J - Justifica'
    else
    if nomeArq = 'PLGAJ14A' then
        s:= '  I - Insere na coluna'
    else
    if nomeArq = 'PLGAJ14B' then
        s:= '  R - Remove da coluna'
    else
    if nomeArq = 'PLQUALBL' then
        s:= 'Qual a opção de bloco ? '
    else
    if nomeArq = 'PLGAJU15' then
        s:= '  I - Início'
    else
    if nomeArq = 'PLGAJU16' then
        s:= '  F - Fim'
    else
    if nomeArq = 'PLQUALPL' then
        s:= 'Qual a opção de planilha ? '
    else
    if nomeArq = 'PLGAJU17' then
        s:= '  N - Nova planilha'
    else
    if nomeArq = 'PLGAJU17' then
        s:= '  N - Nova planilha'
    else
    if nomeArq = 'PLGAJU18' then
        s:= '  I - Insere linha'
    else
    if nomeArq = 'PLGAJU19' then
        s:= '  C - Insere coluna'
    else
    if nomeArq = 'PLGAJU20' then
        s:= '  R - Remove linha'
    else
    if nomeArq = 'PLGAJU21' then
        s:= '  K - Remove coluna'
    else
    if nomeArq = 'PLGAJU22' then
        s:= '  O - Ordena'
    else
    if nomeArq = 'PLGAJU23' then
        s:= '  P - Procura'
    else
    if nomeArq = 'PLQUALAR' then
        s:= 'Qual a opção de arquivo ? '
    else
    if nomeArq = 'PLGAJU24' then
        s:= '  L - Lê'
    else
    if nomeArq = 'PLGAJU25' then
        s:= '  G - Grava'
    else
    if nomeArq = 'PLGAJ25A' then
        s := '  T - Grava TXT'
    else
    if nomeArq = 'PLGAJU26' then
        s:= '  R - Renomeia'
    else
    if nomeArq = 'PLGAJU27' then
        s:= '  I - Importa CSV'
    else
    if nomeArq = 'PLGAJU28' then
        s:= '  E - Exporta CSV'
    else
    if nomeArq = 'PLQUALIM' then
        s:= 'Qual a opção para imprimir ? '
    else
    if nomeArq = 'PLGAJU29' then
        s:= '  T - Tudo'
    else
    if nomeArq = 'PLGAJU30' then
        s:= '  B - Bloco'
    else
    if nomeArq = 'PLQUALFI' then
        s:= 'Qual a opção para finalizar ? '
    else
    if nomeArq = 'PLGAJU31' then
        s:= '  A - Abandona'
    else
    if nomeArq = 'PLGAJU32' then
        s:= '  S - Salva'
    else
    if nomeArq = 'PLGAJU33' then
        s:= '  D - Desiste'
    else
    if nomeArq = 'PLFIM' then
        s:= 'Fim da planilha'
    else
    if nomeArq = 'PLARMDIS' then
        s:= 'OK, armazenei em disco'
    else
    if nomeArq = 'PLINIFUN' then
        s:= 'Editando - F9 opções gerais'
    else
    if nomeArq = 'PLEDITAN' then
        s:= 'Editando'
    else
    if nomeArq = 'PLNAOIMP' then
        s:= 'Função não implementada'
    else
    if nomeArq = 'PLQUERGV' then
        s:= 'Posso gravar esta planilha? '
    else
    if nomeArq = 'PLEXPORT' then
        s:= 'Exportando planilha'
    else
    if nomeArq = 'PLVAZIA' then
        s:= 'Planilha está vazia'
    else
    if nomeArq = 'PLEDICSV' then
        s:= 'Editore o nome do arquivo .CSV'
    else
    if nomeArq = 'PLEDITXT' then
        s := 'Editore o nome do arquivo TXT'
    else
    if nomeArq = 'PLLININS' then
        s := 'Linha inserida'
    else
    if nomeArq = 'PLLINREM' then
        s := 'Linha removida'
    else
    if nomeArq = 'PLCOLINS' then
        s := 'Coluna inserida'
    else
    if nomeArq = 'PLCOLREM' then
        s := 'Coluna removida'
    else
    if nomeArq = 'PLINSBAI' then
        s := 'Inserido embaixo'
    else
    if nomeArq = 'PLREMBAI' then
        s := 'Removido embaixo'
    else
    if nomeArq = 'PLLINREM' then
        s := 'Linha removida'
    else
    if nomeArq = 'PLQUAFOR' then
        s:= 'Qual o formato ? '
    else
    if nomeArq = 'PLGAJUF1' then
        s:= '  G - Geral'
    else
    if nomeArq = 'PLGAJUF2' then
        s:= '  $ - Dinheiro'
    else
    if nomeArq = 'PLGAJUF5' then
        s:= '  N - Numérico'
    else
    if nomeArq = 'PLGAJUF3' then
        s:= '  C - Científico'
    else
    if nomeArq = 'PLGAJUF4' then
        s:= '  D - Data'
    else
    if nomeArq = 'PLQUAJUS' then
        s:= 'Qual a justificativa ? '
    else
    if nomeArq = 'PLGAJUJ1' then
        s:= '  A - Alto'
    else
    if nomeArq = 'PLGAJUJ2' then
        s:= '  E - Esquerda'
    else
    if nomeArq = 'PLGAJUJ3' then
        s:= '  D - Direita'
    else
    if nomeArq = 'PLGAJUJ4' then
        s:= '  C - Centro'
    else
    if nomeArq = 'PLPROCUR' then
        s:= 'Informe o conteúdo a procurar: '
    else
    if nomeArq = 'PLACHEI' then
        s:= 'Achei'
    else
    if nomeArq = 'PLNACHEI' then
        s:= 'Não achei'
    else
    if nomeArq = 'PLQLARG' then
        s := 'Qual a largura para esta coluna ? '
    else
    if nomeArq = 'PLBLKDSM' then
        s := 'Bloco desmarcado'
    else
    if nomearq = 'PLMINVAL' then
        s := 'Opção inexistente'
    else
    if nomeArq = 'PLTFORM' then
        s := 'Formato: qual opção ? '
    else
    if nomeArq = 'PLTJUST' then
        s := 'Justificar: qual opção ?'
    else
    if nomeArq = 'PLINFSET' then
        s:= 'Informe a fórmula com as setas ou pela letra '
    else
    if nomeArq = 'PLFMAT01' then
        s:= 'R  Resto da divisão'
    else
    if nomeArq = 'PLFMAT02' then
        s:= 'A  Arredonda valor'
    else
    if nomeArq = 'PLFMAT10' then
        s:= 'I  Parte inteira da divisão'
    else
    if nomeArq = 'PLFMAT11' then
        s:= 'F  Parte fracionária da divisão'
    else
    if nomeArq = 'PLFMAT12' then
        s:= 'T  Fatorial'
    else
    if nomeArq = 'PLFMAT14' then
        s:= 'P  Percentual'
    else
    if nomeArq = 'PLFMAT13' then
        s:= 'E  Exponencial'
    else
    if nomeArq = 'PLFMAT03' then
        s:= '\  Raiz quadrada'
    else
    if nomeArq = 'PLFMAT04' then
        s:= 'M  Média do bloco'
    else
    if nomeArq = 'PLFMAT05' then
        s:= 'S  Soma do bloco'
    else
    if nomeArq = 'PLFMAT06' then
        s:= '>  Valor máximo no bloco'
    else
    if nomeArq = 'PLFMAT07' then
        s:= '<  Valor mínimo no bloco'
    else
    if nomeArq = 'PLFMAT09' then
        s:= 'N  Número de celulas no bloco'
    else
    if nomeArq = 'PLFMAT08' then
        s:= 'D  Data de hoje'
    else
    if nomeArq = 'PLPFBLK' then
        s:= 'Por favor, marque antes o bloco desejado'
    else
    if nomeArq = 'PLINFDID' then
        s:= 'Informe o valor ou a célula do dividendo: '
    else
    if nomeArq = 'PLINFDIS' then
        s:= 'Informe o valor ou a célula do divisor: '
    else
    if nomeArq = 'PLARRED' then
        s:= 'Informe o valor ou a célula a arredondar: '
    else
    if nomeArq = 'PLDIVID' then
        s:= 'Informe o valor, a célula ou a expressão: '
    else
    if nomeArq = 'PLFAT' then
        s:= 'Informe o valor ou a célula: '
    else
    if nomeArq = 'PLPERC' then
        s:= 'Informe o percentual a ser calculado: '
    else
    if nomeArq = 'PLINFBAS' then
        s:= 'Informe o valor ou a célula da base: '
    else
    if nomeArq = 'PLINFEXP' then
        s:= 'Informe o valor ou a célula do expoente: '
    else
    if nomeArq = 'PLRAIZ' then
        s:= 'Informe o valor ou a célula a radiciar: '
    // ajustar essas mensagens *)
    else
    if nomeArq = 'PLMFORM' then
        s := 'Geral Dinheiro Cientifico Hora Dia Invisivel'
    else
    if nomeArq = 'PLMJUST' then
        s := 'Esquerda Direita Centro Auto'
    else
    if nomeArq = 'PLVALINI' then
        s:= 'Informe o valor inicial: '
    else
    if nomeArq = 'PLINFINT' then
        s:= 'Informe o intervalo desejado: '
    else
    if nomeArq = 'PLCALINT' then
        s:= 'Não pude calcular o intervalo, operação cancelada'
    else
    if nomeArq = 'PLERMAXI' then
        s:= 'Excedido tamanho máximo para importação'
    else
    if nomeArq = 'PLNCASAS' then
        s := 'Se número, quantas decimais? '

    else
    if nomeArq = 'PLGAJ11E' then
        s := '  $ - Formata'
    else
    if nomeArq = 'PLGAJ11F' then
        s := '  A - Alinha'

    else
    if nomeArq = 'PLGAJU34' then
        s := '  X - Musicaliza'

    else
    if nomeArq = 'PLDURNOT' then
        s := 'Qual a duração da nota (100 a 1000)? '
    else
    if nomeArq = 'PLESCALA' then
        s := 'Número da escala (0 a 7)? '
    else
    if nomeArq = 'PLVARREC' then
        s := 'Varrer por linha ou por coluna (L ou C) ? '
    else
    if nomeArq = 'PLGAJ14C' then
       s := '  V - Vai para célula'
    else
    if nomeArq = 'PLQUALCE' then
        s := 'Qual célula? '

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string);
var
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);
    write (s);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{                      executa som
{--------------------------------------------------------}

procedure som (s: string);
begin
    if s = 'PLPLAN' then
        sintetiza ('Planivox')
    else
        begin
            sintbip;
            sintbip;
            sintetiza ('Erro: mensagem inválida');
        end;
end;

{--------------------------------------------------------}
{                     mensagem sonora
{--------------------------------------------------------}

procedure mensagemSonora (s: string);
begin
    if existeArqSom(s) then
        sintSom (s)
    else
        sintetiza (pegaTextoMensagem (s));
end;

{--------------------------------------------------------}
{                 fala a posicao atual
{--------------------------------------------------------}

procedure falaPos;
var s: string;
begin
    sintCarac (chr (ord('A')+ xatual-1));
    str (yatual, s);
    sintetiza (s);
end;

{--------------------------------------------------------}
{        Soma várias posições numa variavel global
{--------------------------------------------------------}

procedure somaPos;
var s: string;
begin

    posicArmazenada := posicArmazenada + chr(ord('A')+ xatual-1);
    str(yatual, s);
    posicArmazenada:= posicArmazenada + s + ' ';

    sintBip;
    falaPos;

end;

{--------------------------------------------------------}
{                     Escreve na linha 2
{--------------------------------------------------------}

procedure pergunta (s: string);
begin
    gotoxy (1, 3);  clreol;
    gotoxy (1, 2);  clreol;
    TextBackGround (blue);
    if s <> '' then
        mensagem (s);
    TextBackGround (black);
end;

{--------------------------------------------------------}
{                      Escreve na linha 25
{--------------------------------------------------------}

procedure informa (s: string);
var br, msg: string;
    nbr: integer;
const brancos = '                                        ';
begin                 
    if s = '' then
        msg := ''
    else
        msg := pegaTextoMensagem (s);

    nbr := (80-length (msg)) div 2;
    br := copy (brancos, 1, nbr);

    gotoxy (1, 25);
    clreol;
    TextBackGround (black);
    if s <> '' then
        begin
            TextColor (YELLOW);
            write (br);
            mensagem (s);
            TextColor (WHITE);
            gotoxy (1, 2);
        end;
end;

end.
