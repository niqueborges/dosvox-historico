{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de tratamento de formulas matemáticas
{
{    Autor:  Bernard Condorcet
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plFormul;
interface
uses
    dvCrt, dvWin, dvForm, sysutils,
    plCelula, plCalc, plComp, plVars, plMsg, plBloco;

procedure selMenuForMat;

implementation

{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}
{            Pega as coordenadas do bloco atual
{--------------------------------------------------------}

function pegaBloco (var s1, s2: string): boolean;
begin
    if not blocoValido then
        begin
            informa ('PLPFBLK'); {'Por favor, marque antes o bloco desejado'}
            pegaBloco := false;
        end
    else
        begin
            s1 := chr(blocoAtual.xbloco1 + ord ('A') - 1) +
                      intToStr (blocoAtual.ybloco1);
            s2 := chr(blocoAtual.xbloco2 + ord ('A') - 1) +
                      intToStr (blocoAtual.ybloco2);
            pegaBloco := true;
        end;
end;

{--------------------------------------------------------}
{            Insere formula na celula
{--------------------------------------------------------}

procedure insereForm (abrevForm: char);
var s1, s2: string;
    s3, erro: integer;
    formula: string;
begin

    formula := '';

    gotoxy (1, 3);  clreol;
    gotoxy (1, 2);  clreol;

    case abrevForm of
    'R': begin
             pergunta ('PLINFDID'); {'Informe o valor ou a célula do dividendo: '}
             sintReadln (s1);
             pergunta ('PLINFDIS'); {'Informe o valor ou a célula do divisor: '}
             sintReadln (s2);
             if (s1 <> '') and (s2 <> '') then
                 formula := ('=@RESTO(' + S1 + ',' + S2 + ')')
             else
                 informa ('PLDESIST');  {'Desistiu'}
         end;

    'I':
        begin
            pergunta ('PLDIVID'); {'Informe o valor, a célula ou a expressão: '}
            sintReadln (s1);
            if s1 <> '' then
                formula := ('=@TRUNC(' + S1 + ')')
            else
                informa ('PLDESIST');  {'Desistiu'}
        end;

    'F':
        begin
            pergunta ('PLDIVID'); {'Informe o valor, a célula ou a expressão: '}
            sintReadln (s1);
            if s1 <> '' then
                formula := ('=@FRAC(' + S1 + ')')
            else
                informa ('PLDESIST');  {'Desistiu'}
        end;

    'A':
        begin
            pergunta ('PLARRED'); {'Informe o valor ou a célula a arredondar: '}
            sintReadln (s1);
            if s1 <> '' then
                formula := ('=@ARRED(' + S1 + ')')
            else
                informa ('PLDESIST');  {'Desistiu'}
        end;

    'T': begin
            pergunta ('PLFAT'); {'Informe o valor ou a célula: '}
            sintReadln (s1);
            if s1 <> '' then
                 formula := ('=@FAT(' + S1 + ')')
             else
                 informa ('PLDESIST');  {'Desistiu'}
          end;

    'P': begin
             pergunta ('PLFAT'); {'Informe o valor ou a célula: '}
             sintReadln (s1);
             pergunta ('PLPERC'); {'Informe o percentual a ser calculado: '}
             sintReadln (s2);
             if (s1 <> '') and (s2 <> '') then
             begin
                 val (s2, s3, erro);
                 if (s3 >= 1) and (s3 < 10) then
                     formula := ('=(' + S1 + '*' + '0.0' + S2 + ')')
                 else
                 if (s3 >= 10) and (s3 < 100) then
                     formula := ('=(' + S1 + '*' + '0.' + S2 + ')')
                 else
                 if (s3 < 1) or ((s3 >= 100) and (s3 < 1000)) then
                     formula := ('=(' + S1 + '*' + S2 + ')' + '/100');
             end
             else
                 informa ('PLDESIST');  {'Desistiu'}
         end;

    'E': begin
             pergunta ('PLINFBAS'); {'Informe o valor ou a célula da base: '}
             sintReadln (s1);
             pergunta ('PLINFEXP'); {'Informe o valor ou a célula do expoente: '}
             sintReadln (s2);
             if (s1 <> '') and (s2 <> '') then
                 formula := ('=@ELEV(' + S1 + ',' + S2 + ')')
             else
                 informa ('PLDESIST');  {'Desistiu'}
         end;

    '\': begin
            pergunta ('PLRAIZ'); {'Informe o valor ou a célula a radiciar: '}
            sintReadln (s1);
            if s1 <> '' then
                 formula := ('=@RAIZ(' + S1 + ')')
             else
                 informa ('PLDESIST');  {'Desistiu'}
          end;

    '>': begin
             if not pegaBloco (s1, s2) then exit;
             formula := '=@MAX(' + S1 + '..' + S2 + ')';
         end;

    '<': begin
             if not pegaBloco (s1, s2) then exit;
             formula := '=@MIN(' + S1 + '..' + S2 + ')';
         end;

    'M': begin
             if not pegaBloco (s1, s2) then exit;
             formula := '=@MEDIA(' + S1 + '..' + S2 + ')';
         end;

    'S': begin
             if not pegaBloco (s1, s2) then exit;
             formula := '=@SOMA(' + S1 + '..' + S2 + ')';
         end;

    'N': begin
             if not pegaBloco (s1, s2) then exit;
             formula := '=@CONTA(' + S1 + '..' + S2 + ')';
         end;

    'D':  formula:= '=@HOJE';

    end;

    formataCelula (xAtual, yAtual, formula);
    compilaFormula (xAtual, yAtual, formula);
    recalcular;
    falaCelula (xAtual, yAtual);

end;

{--------------------------------------------------------}
{            Lista formulas matemáticas
{--------------------------------------------------------}

const
    tabLetrasOpcoes: string = 'RIFATPE\><MSND';
    opcoesValidas: set of char = ['R','I','F','A','T','P','E','\','>','<','M','S','N','D'];

function selSetasOpMat: char;
var n: integer;
begin
    popupMenuCria (wherex, wherey, 32, 18, MAGENTA);
    MenuAdiciona ('PLFMAT01');
    MenuAdiciona ('PLFMAT10');
    MenuAdiciona ('PLFMAT11');
    MenuAdiciona ('PLFMAT02');
    MenuAdiciona ('PLFMAT12');
    MenuAdiciona ('PLFMAT14'); {'P  Percentual'}
    MenuAdiciona ('PLFMAT13');
    MenuAdiciona ('PLFMAT03');
    MenuAdiciona ('PLFMAT06');
    MenuAdiciona ('PLFMAT07');
    MenuAdiciona ('PLFMAT04');
    MenuAdiciona ('PLFMAT05');
    MenuAdiciona ('PLFMAT09');
    MenuAdiciona ('PLFMAT08');

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpMat := tabLetrasOpcoes[n]
    else
        selSetasOpMat := ESC;
end;

{--------------------------------------------------------}
{                 seleciona pelo menu formulas matemáticas
{--------------------------------------------------------}

procedure selMenuForMat;
var c1, c2: char;
begin
    pergunta ('PLINFSET');  {'Informe com as setas a formula desejada'}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpMat
    else
        c1 := upcase (c1);

        if c1 in opcoesValidas then
            insereForm (c1)
        else
    if c1 = ESC then
        informa ('PLDESIST') {'Desistiu'}
    else
        informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}

    mensagemSonora ('PLEDITAN');
end;

end.
