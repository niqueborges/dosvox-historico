{--------------------------------------------------------}
{
{    I Ching-VOX - Módulo de gravação em disco
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{--------------------------------------------------------}

unit ichDisco;
interface
    uses dvcrt, dvWin, ichVars, ichTela;

function abreArqTexto (nome: string): boolean;
function gravaResumo: boolean;
function gravaDiagnostico (completo: boolean): boolean;
function gravaLinhas: boolean;
function gravaPrognostico (completo, forcada: boolean): boolean;
procedure gravaTudo;

var arqTexto: text;

implementation

{--------------------------------------------------------}
{                  grava o resumo
{--------------------------------------------------------}

function gravaResumo: boolean;
var i, n: integer;
begin
    writeln (arq, '*RESUMO');
    writeln (arq);

    n := 1;
    for i := 1 to 6 do
        begin
            write (arq, 'Linha ', i, '  ');
            write (arq, regMoedas [n], ' ', regMoedas [n+1], ' ', regMoedas [n+2], ' ');

            n := n + 3;
            write (arq, '= ', linDiag[i], '   ', desenho[linDiag[i]]);

            if (linDiag[i] = 6) or (linDiag[i] = 9) then
                 write (arq, ' => ', desenho[linProg[i]])
            else
                 write (arq, '    ', desenho[linProg[i]]);

            writeln (arq);
        end;

    writeln (arq);
    writeln (arq, 'Hexagrama diagnóstico: ', hexaDiag,
               ' - ', nomeHexagrama [hexaDiag]);
    writeln (arq, '    Abaixo:  ', nomePers [indBaixoDiag]);
    writeln (arq, '    Acima :  ', nomePers [indCimaDiag]);

    writeln (arq);
    writeln (arq, 'Linhas móveis:');

    case tipoMutacao of
        MUTACAO_TOTAL:   writeln (arq, 'Todas: caso especial (hexagrama em movimento)');

        MUTACAO_FIXA:    writeln (arq, 'Nenhuma');

    else
        begin
             for i := 1 to 6 do
                  begin
                      if (linDiag[i] = 6) or (linDiag[i] = 9) then
                            writeln (arq, linDiag[i] ,' na ', ordinal [i], ' posição');
                  end;
        end;
    end;

    writeln (arq);
    writeln (arq, 'Hexagrama prognóstico: ', hexaProg,
             ' - ', nomeHexagrama [hexaProg]);
    writeln (arq, '    Abaixo:  ', nomePers [indBaixoProg]);
    writeln (arq, '    Acima :  ', nomePers [indCimaProg]);
    writeln (arq);

    gravaResumo := true;
end;

{--------------------------------------------------------}
{                 verifica se arquivo existe
{--------------------------------------------------------}

function abreArqTexto (nome: string): boolean;
begin
    abreArqTexto := false;

    assign (arqTexto, dirTextos + nome);
    {$I-} reset (arqTexto); {$I+}
    if ioresult <> 0 then
        begin
            writeln ('Arquivo de texto não encontrado.  Reinstale o programa.');
            sintSom ('ICARQFAL');
            exit;
        end;

    abreArqTexto := true;
end;

{--------------------------------------------------------}
{                  pula a introducao
{--------------------------------------------------------}

procedure pulaIntroducao;
var
    s: string;
begin
    {$I-}  readln (arqTexto, s);  {$I+}
    if ioresult <> 0 then
        exit;
    writeln (arq, s);
    writeln (arq);

    while not (eof (arqTexto)) and (s <> '*JULGAMENTO') do
        readln (arqTexto, s);

    writeln (arq, s);
end;

{--------------------------------------------------------}
{                  grava o diagnostico
{--------------------------------------------------------}

function gravaDiagnostico (completo: boolean): boolean;
var s: string;
begin
    gravaDiagnostico := false;

    str (hexaDiag, s);
    if not abreArqTexto ('ICH' + s + '.TXT') then
        exit;

    writeln (arq, '*DIAGNOSTICO');
    writeln (arq);

    if not completo then   { sem introducao }
        pulaIntroducao;
    while not eof (arqTexto) and (copy (s, 1, 7) <> '*LINHAS') do
       begin
           readln (arqTexto, s);
           if (copy (s, 1, 7) <> '*LINHAS') then
               writeln (arq, s);
       end;

    close (arqTexto);

    gravaDiagnostico := true;
end;

{--------------------------------------------------------}
{                  grava as linhas
{--------------------------------------------------------}

function gravaLinhas: boolean;
var buscado, s: string;
    i: integer;

    {--------------------------------------------------------}

    procedure gravaMovel (i: integer);
    var n: string;
    begin
        reset (arqTexto);

        s := '';
        if i = 0 then  n := 'T'
                 else  str (i, n);

        buscado := '*' + n;
        while (not eof (arqTexto)) and (copy (s, 1, 2) <> buscado) do
            readln (arqTexto, s);

        s := ' ';
        while not eof (arqTexto) and (copy (s, 1, 1) <> '*') do
            begin
                 readln (arqTexto, s);
                 if (copy (s, 1, 1) <> '*') then
                     writeln (arq, s);
            end;

        writeln (arq);

        close (arqTexto);
    end;

    {--------------------------------------------------------}

begin
    gravaLinhas := false;

    str (hexaDiag, s);
    if not abreArqTexto ('ICH' + s + '.TXT') then
        exit;

    s := '';

    while (not eof (arqTexto)) and (copy (s, 1, 7) <> '*LINHAS') do
            readln (arqTexto, s);

    writeln (arq, '*LINHAS MÓVEIS');
    writeln (arq);

    while not eof (arqTexto) and (copy (s, 1, 1) <> '*') do
         begin
             readln (arqTexto, s);
             if (copy (s, 1, 1) <> '*') then
                 writeln (arq, s);
            end;

    case tipoMutacao of

        MUTACAO_USUAL:
            for i := 1 to 6 do
                if (linDiag[i] = 6) or (linDiag[i] = 9) then
                    gravaMovel (i);

        MUTACAO_TOTAL:
            gravaMovel (0);

        MUTACAO_FIXA:
            writeln (arq, 'Nenhuma');
    end;

    gravaLinhas := true;
end;

{--------------------------------------------------------}
{                  grava o prognostico
{--------------------------------------------------------}

function gravaPrognostico (completo, forcada: boolean): boolean;
var s: string;
begin
    gravaPrognostico := false;

    str (hexaProg, s);

    if not abreArqTexto ('ICH' + s + '.TXT') then
        exit;

    if (hexaDiag = hexaProg) and (not forcada) then
        begin
            writeln (arq);
            writeln (arq, 'Idêntico ao diagnóstico !');
            writeln (arq);
            gravaPrognostico := true;
            exit;
        end;

    writeln (arq, '*PROGNÓSTICO');
    writeln (arq);

    if not completo then
        pulaIntroducao;

    while not eof (arqTexto) and (copy (s, 1, 7) <> '*LINHAS') do
       begin
           readln (arqTexto, s);
           if (copy (s, 1, 7) <> '*LINHAS') then
               writeln (arq, s);
       end;

    close (arqTexto);

    gravaPrognostico := true;
end;

{--------------------------------------------------------}
{                   grava cabecalho
{--------------------------------------------------------}

function gravaCabecalho: boolean;
const
    diasem: array [0..6] of string[10] =
       ('Domingo', 'Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado');

var
    nomeArq: string;
    c: char;
    ano, mes, dia, semana: word;
label
    deNovo, grava, testaErro, erro;

begin
    gravaCabecalho := false;

    gotoxy (1,21);
    textBackground (MAGENTA);
    write ('Qual o nome do arquivo a gravar: ');
    sintSom ('ICNOMARQ');
    textBackground (BLACK);
    sintReadln (nomeArq);
    if nomeArq = '' then
         begin
             write ('Desistiu...');
             sintSom ('ICDESIS');
             exit;
         end;

    assign (arq, nomearq);
    {$I-}  reset (arq);  {$I+}
    if ioresult = 0 then
         begin
             close (arq);
deNovo:
             write ('Arquivo já existia: A-acrescenta, R-remove, ESC desiste? ');
             sintSom ('ICJAEXIS');
             c := readkey;
             writeln (c);

             case upcase(c) of
             #$1b, #$0:
                       begin
                           readkey;
                           write ('  Desistiu...');
                           sintSom ('ICDESIS');
                           exit;
                       end;

                 'R':  begin
                           {$I-}  erase (arq);  {$I+}
                           if ioresult <> 0 then;
                           goto grava;
                       end;

                 'A':  begin
                           {$I-}  append (arq);  {$I+}
                           goto testaErro;
                       end;
             else
                     goto deNovo;
             end;
        end
    else
        begin
grava:
            {$I+}  rewrite(arq);  {$I-}
testaErro:
            if ioresult <> 0 then
                begin
erro:
                    writeln ('Erro de escrita no disco. Gravação cancelada');
                    sintSom ('ICERRDSK');
                    {$I-} close (arq);  {$I+}
                    if ioresult <> 0 then;
                    exit;
                end;
        end;


    {$I-}
    writeln (arq, 'I CHING Simplificado - Projeto DOSVOX - v.', versao);
    {$I+}
    if ioresult <> 0 then
         goto erro;

    getDate (ano, mes, dia, semana);
    writeln (arq, 'Consulta realizada em ', dia, '/', mes, '/', ano,
            ' (', diasem [semana], ')');
    writeln (arq);
    writeln (arq, pergunta);
    writeln (arq);

    gravaCabecalho := true;
end;

{--------------------------------------------------------}
{                    grava tudo
{--------------------------------------------------------}

procedure gravaTudo;
begin
    if gravaCabecalho then
    if gravaResumo then
    if gravaDiagnostico (true) then
    if gravaLinhas then
    if gravaPrognostico (true, false) then
        begin
            writeln ('OK');    { so' grava o proximo se anterior ok }
            sintSom ('ICOK');
        end;

    {$I-} close (arq);  {$I+}
    if ioresult <> 0 then;
end;

end.
