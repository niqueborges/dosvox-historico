{--------------------------------------------------------}
{
{           TXTWord, tipos de formatação
{
{--------------------------------------------------------}

unit twtipofo;

interface

uses
    dvWin,
    sysutils,
    classes,
    comobj,
    activex,
    twVars;

function trataFormatacao (f: string): boolean;
function testaFormatacao (f: string): boolean;

implementation

{--------------------------------------------------------}
{       Liga ou desliga tipos de formatação
{--------------------------------------------------------}

function trataFormatacao (f: string): boolean;
var
    valor: string;
    p: integer;


    procedure trocaCorFonte;
    begin
        if (p < 0) and (p > 16) then p := 0;

        if p = 0 then aplicWord.Selection.Font.ColorIndex := wdAuto
        else
        if p = 1 then aplicWord.Selection.Font.ColorIndex := wdBlack
        else
        if p = 2 then aplicWord.Selection.Font.ColorIndex := wdBlue
        else
        if p = 3 then aplicWord.Selection.Font.ColorIndex := wdTurquoise
        else
        if p = 4 then aplicWord.Selection.Font.ColorIndex := wdBrightGreen
        else
        if p = 5 then aplicWord.Selection.Font.ColorIndex := wdPink
        else
        if p = 6 then aplicWord.Selection.Font.ColorIndex := wdRed
        else
        if p = 7 then aplicWord.Selection.Font.ColorIndex := wdYellow
        else
        if p = 8 then aplicWord.Selection.Font.ColorIndex := wdWhite
        else
        if p = 9 then aplicWord.Selection.Font.ColorIndex := wdDarkBlue
        else
        if p = 10 then aplicWord.Selection.Font.ColorIndex := wdTeal
        else
        if p = 11 then aplicWord.Selection.Font.ColorIndex := wdGreen
        else
        if p = 12 then aplicWord.Selection.Font.ColorIndex := wdViolet
        else
        if p = 13 then aplicWord.Selection.Font.ColorIndex := wdDarkRed
        else
        if p = 14 then aplicWord.Selection.Font.ColorIndex := wdDarkYellow
        else
        if p = 15 then aplicWord.Selection.Font.ColorIndex := wdGray50
        else
        if p = 16 then aplicWord.Selection.Font.ColorIndex := wdGray25;
    end;


begin
    trataFormatacao := true;

    P := pos ('=', f);
    if p <> 0 then
        begin
            valor := copy (f, p+1, length (f)-p-1);
            delete (f, p+1, length (f));
            f := maiuscansi (f);
            if (trim (valor) <> '') and (valor [1] in ['0' .. '9']) then
                p := strToInt (valor)
            else
                p := 0;

            {Font, tipo de letra parte 1}
            if f = '<TF=' then //Tipo de fonte
                aplicWord.Selection.Font.Name := valor
            else
            if f = '<SF=' then //Tamanho da fonte
                aplicWord.Selection.Font.size := p
            else
            if f = '<CE=' then //Coloca cor da fonte
                trocaCorFonte
            else

            {comandos de margem e espacejamento}

            if f = '<MS=' then //<MS=valor> margem superior
                sintetiza ('Colocar comando Word')
            else
            if f = '<MI=' then //<MI=valor> margem inferior
                sintetiza ('Colocar comando Word')
            else
            if f = '<ME=' then //<ME=valor> margem esquerda
                sintetiza ('Colocar comando Word')
            else
            if f = '<MD=' then //<MD=valor> margem direita
                sintetiza ('Colocar comando Word')
            else
            if f = '<EL=' then //<EL=valor> espacejamento entre linhas
                sintetiza ('Colocar comando Word')
            else
(*neno5*)            if f = '<RP=' then //<RP=valor> recuo de parágrafo
                begin
                    if p > 0 then
                        aplicWord.Selection.ParagraphFormat.LeftIndent := p
                    else
                        begin
                            aplicWord.Selection.ParagraphFormat.SpaceBeforeAuto := False;
                            aplicWord.Selection.ParagraphFormat.SpaceAfterAuto := False;
                        end;
                end
            else
                trataFormatacao := false;
        end
    else
        begin
            f := maiuscansi (f);

            {paginação e título}
        if f = '<P>' then //Força salto de pagina
                sintetiza ('Colocar comando Word')
            else
            if f = '<IROD>' then //O texto a sseguir é colocado no rodapé
                sintetiza ('Colocar comando Word')
            else
            if f = '<FROD>' then //Fim do texto de rodapé
                sintetiza ('Colocar comando Word')
            else

            //alinhamento e separação de sílabas
            if f = '<AF>' then //Ativa a autoformatação de parágrafos (Justificar)
                aplicWord.Selection.paragraphFormat.Alignment := wdAlignParagraphJustify
            else
            if f = '<C>' then //Centraliza texto seguinte
                aplicWord.Selection.paragraphFormat.Alignment := wdAlignParagraphCenter
            else
            if f = '<AL>' then //Faz alinhamento à esquerda das linhas
                aplicWord.Selection.paragraphFormat.Alignment := wdAlignParagraphLeft
            else
            if f = '<AR>' then //Faz alinhamento à direita das linhas
                aplicWord.Selection.paragraphFormat.Alignment := wdAlignParagraphRight
            else
            if f = '<SS>' then //Separa sílabas
                sintetiza ('Colocar comando Word')
            else
            if f = '<NSS>' then //Não separa sílabas
                sintetiza ('Colocar comando Word')
            else

            //Font, tipo de letra parte 2
            if f = '<IN>' then //Início de texto negritado
                aplicWord.Selection.Font.Bold := 1
            else
            if f = '<FN>' then //Fim de texto negritado
                aplicWord.Selection.Font.Bold := 0
            else
            if f = '<II>' then //Inicio de texto em itálico
            aplicWord.Selection.Font.Italic := 1
            else
            if f = '<FI>' then //Fim de texto em itálico
            aplicWord.Selection.Font.Italic := 0
            else
            if f = '<IS>' then //Início de texto sublinhado
                aplicWord.Selection.Font.Underline := 1
            else
            if f = '<FS>' then //Fim de texto sublinhado
                aplicWord.Selection.Font.Underline := 0
            else
            if f = '<ISO>' then //Início de texto sobrescrito
                sintetiza ('Colocar comando Word')
            else
            if f = '<FSO>' then //Fim de texto sobrescrito
                sintetiza ('Colocar comando Word')
            else
            if f = '<ISU>' then //Início de texto subscrito
                sintetiza ('Colocar comando Word')
            else
            if f = '<FSU>' then //Fim de texto subscrito
                sintetiza ('Colocar comando Word')

            else
                trataFormatacao := false;
        end;
end;

{--------------------------------------------------------}
{       Testa se o código de formatação é válido
{--------------------------------------------------------}

function testaFormatacao (f: string): boolean;
var
    p: integer;
begin
    testaFormatacao := true;
    f := maiuscansi (f);
    P := pos ('=', f);
    if p > 0 then
        begin
            delete (f, p+1, length (f)-p);

            if pos (f, '<TF= <SF= <CE= <MS= <MI= <ME= <MD= <EL= <RP= <TIT=') = 0 then
                testaFormatacao := false;
        end
    else
        begin
            if pos (f, '<NTIT> <P> <IROD> <FROD> <AF> <C> <AL> <AR> <SS> <NSS> <IN> <FN> <II> <FI> <IS> <FS> <ISO> <FSO> <ISU> <FSU>') = 0 then
                testaFormatacao := false;
        end;
end;

{--------------------------------------------------------}
begin
end.
