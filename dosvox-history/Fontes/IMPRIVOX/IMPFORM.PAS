{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Impressao formatada
{
{    Autor: Jose' Antonio Borges
{
{    Em marco/1996 - julho/2000
{
{--------------------------------------------------------}

unit impform;

interface

uses DVcrt, DVWin, windows,
     impvars, impmsg, impinipr, improdap;

function imprimeFormatado: boolean;

implementation

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicFormatador;
var i: integer;
begin
    jaLido := false;
    centrando := false;
    ultimoFoiNL := false;

    titulando := false;
    titulo := '';

    tipoLetra := NORMAL;
    ultAtrib := NORMAL;

    linha  := 1;
    coluna := 0;   { linha nao inicializada }
    linhaVazia := true;
    numPag := 0;
    nlinPag := 0;

    emRodape := false;
    primRodape := 0;
    nlRodape := 0;
    for i := 0 to MAXRODAPE-1 do
        begin
            new (txtRodape[i]);
            new (atribRodape[i]);
        end;

    primCol := 1;
    ultCol := ultColCabec-primColCabec+1;

    brancosMargem := '';
    for i := 1 to primColCabec-1 do
        brancosMargem := brancosMargem + ' ';

    impressaoPermitida := true;
    if pagInicial > 1 then
        begin
            impressaoPermitida := false;
            mensagem ('IMPULAPG', 1);   {'Pulando páginas iniciais'}
        end;
end;

{--------------------------------------------------------}
{                inicializa linha de saida
{--------------------------------------------------------}

procedure inicLinhaSaida (resto: string);
var i: integer;

begin
    fillchar (atribSaida, 256, NORMAL);

    linhaSaida := '';
    for i := 1 to primCol-1 do
        linhaSaida := linhaSaida + ' ';

    linhaSaida := linhaSaida + resto;
    for i := 1 to length (resto) do
        atribSaida[primCol+i-1] := atribResto [i];

    coluna := primCol+length(resto);
end;

{--------------------------------------------------------}
{              pega um caractere do texto
{--------------------------------------------------------}

procedure pegaCarac (var c: char; var codigo: LETRALIDA);
var
    lidos: integer;
label
    inicio, fimDeArquivo;

begin
    if jaLido then
        begin
           c := ultLetra;
           codigo := ultCodigo;
           jaLido := false;
           exit;
        end;

inicio:
    if eof (arqEntra) then  goto fimDeArquivo;

    {$I-} blockread (arqEntra, c, 1, lidos);  {$I+}
    if (lidos = 0) or (ioresult <> 0) then
        begin
            mensagem ('IMERRLEI', 1);    {'Erro de leitura no arquivo'}
            goto fimDeArquivo;
        end;

    if (lidos = 0) then  goto fimDeArquivo;

    case c of
        ' ':  codigo := ESPACO;
        '<':  codigo := ABRECOMANDO;
        #$0a: codigo := FIMLINHA;
        #$0d: goto inicio;
    else
        codigo := CARACTERE;
    end;

    ultLetra := c;
    ultCodigo := codigo;

    exit;

fimDeArquivo:
    c := ' ';
    codigo := FIMARQ;
end;

{--------------------------------------------------------}
{                    desle um caractere
{--------------------------------------------------------}

procedure desle (c: char; codigo: LETRALIDA);
begin
    jaLido := true;
    ultLetra := c;
    ultCodigo := codigo;
end;

{--------------------------------------------------------}
{                 padroniza o comando
{--------------------------------------------------------}

procedure padronizaComando (var trecho: string);
var i: integer;
begin
    while (trecho <> '') and (trecho [1] = ' ') do
        delete (trecho, 1, 1);
    while (trecho <> '') and (trecho [length(trecho)] = ' ') do
        delete (trecho, 1, 1);
    for i := 1 to length (trecho) do
        begin
            if trecho[i] = '=' then break;
            trecho[i] := upcase (trecho[i]);
        end;
end;

{--------------------------------------------------------}
{                   pega um trecho conexo
{--------------------------------------------------------}

procedure pegaTrecho (var trecho: string; var tipoTrecho: COISALIDA);
var
    c: char;
    codigo: LETRALIDA;

    {--------------------------------------------------------}

    procedure processaFimLinha;
    begin
        if ultimoFoiNL or (not autoFormata) then
            begin
                tipoTrecho := COMANDO;
                trecho := 'NL';
                exit;
            end;

        pegaCarac (c, codigo);

        case codigo of

            ESPACO, FIMARQ, FIMLINHA:
                    begin
                        trecho := 'NL';
                        tipoTrecho := COMANDO;
                        ultimoFoiNL := true;

                        if codigo = ESPACO then   {convenção DOSVOX: espaço isolado quebra linha }
                            begin
                                pegaCarac (c, codigo);
                                if c = ' ' then
                                    desle (c, codigo);
                            end;
                    end;

            CARACTERE:
                    begin
                        if linhaVazia then
                            trecho := ''
                        else
                            trecho := ' ';
                        tipoTrecho := BRANCOS;
                    end;

        end;

        desle (c, codigo);
    end;

    {--------------------------------------------------------}

begin
   pegaCarac (c, codigo);
   if codigo <> FIMLINHA then
        ultimoFoiNL := false;

    trecho := '';
    case codigo of

        ESPACO:
            begin
                repeat
                    trecho := trecho + c;
                    pegaCarac (c, codigo);
                until codigo <> ESPACO;

                tipoTrecho := BRANCOS;
                linhaVazia := false;

                desle (c, codigo);
            end;

        CARACTERE:
            begin
                repeat
                    trecho := trecho + c;
                    pegaCarac (c, codigo);
                until codigo <> CARACTERE;

                tipoTrecho := LETRAS;
                linhaVazia := false;

                desle (c, codigo);
            end;

        ABRECOMANDO:
            begin
                pegaCarac (c, codigo);
                if c = '<' then
                    begin
                        trecho := '<';
                        tipoTrecho := LETRAS;
                    end
                else
                    begin
                        tipoTrecho := COMANDO;
                        repeat
                            trecho := trecho + c;
                            pegaCarac (c, codigo);
                        until (codigo = FIMLINHA) or (c = '>');
                    end;

                padronizaComando (trecho);

                if trecho = 'NL' then
                    begin
                        pegaCarac (c, codigo);
                        if (codigo <> FIMLINHA) then
                            desle (c, codigo);
                    end;

            end;

        FIMLINHA:
                processaFimLinha;

        FIMARQ:
            begin
                processando := false;
                tipoTrecho := FIM;
            end;
    end;
end;

{--------------------------------------------------------}
{                   trata o cabecalho
{--------------------------------------------------------}

procedure trataCabecalho;
var i: integer;
    num, cabec: string;
    espaco, esquerda, direita: integer;

begin
    trataRodape;

    if yimpr > limyImpr then
        begin
            nlinPag := 0;
            if numPag <= pagFinal then
                jogaImpressora (pulaPag)
            else
                begin
                    impressaoPermitida := false;
                    processando := false;
                    exit;
                end;
        end;

    if nlinPag = 0 then
        begin
            alocaFonte (NORMAL);
            numPag := numPag + 1;

            if (not impressaoPermitida) and (numPag >= pagInicial) then
                begin
                    mensagem ('IMIMPR', 1);   {'Imprimindo'}
                    impressaoPermitida := true;
                end;

            if titulando then
                begin
                    str (numPag+numInicial-1, num);

                    espaco := (ultColCabec - primColCabec + 1) - length(num);
                    esquerda := (espaco - length(titulo)) div 2;
                    direita := espaco - esquerda - length(titulo);

                    cabec := '';
                    for i := 1 to primColCabec-1 do  cabec := cabec + ' ';
                    for i := 1 to esquerda       do  cabec := cabec + ' ';
                    for i := 1 to length(titulo) do  cabec := cabec + titulo[i];
                    for i := 1 to direita        do  cabec := cabec + ' ';
                    cabec := cabec + num;

                    for i := 2 to primLinha do
                        jogaImpressora (pulaLinha);
                    jogaImpressora (cabec);
                    jogaImpressora (pulaLinha);
                    jogaImpressora (pulaLinha);
                    nlinPag := 2 + primLinha;
                end
            else
                begin
                    for i := 2 to primLinha do
                        jogaImpressora (pulaLinha);
                    nlinPag := primLinha-1;
                end;
        end;
end;

{--------------------------------------------------------}
{             descarrega o buffer de impressao
{--------------------------------------------------------}

procedure descarregaImpressao;
var i: integer;
    s: string;
begin
    trataCabecalho;

    ultAtrib := NORMAL;
    alocaFonte (ultAtrib);
    if length(linhaSaida) <> 0 then
        begin
            jogaImpressora (brancosMargem);

            s := '';
            for i := 1 to length (linhaSaida) do
                begin
                    if atribSaida[i] <> ultAtrib then
                        begin
                             if s <> '' then jogaImpressora (s);
                             s := '';
                             ultAtrib := atribSaida [i];
                             alocaFonte (ultAtrib);
                        end;
                    s := s + linhaSaida[i];
                end;

            if s <> '' then jogaImpressora (s);
        end;

    jogaImpressora (pulaLinha);
    linhaSaida := '';
    nlinPag := nlinPag + 1;

    trataCabecalho;
    if nlinPag = 0 then nlinPag := 1;
end;

{--------------------------------------------------------}
{                     centra a saida
{--------------------------------------------------------}

procedure centraSaida;
var nbr, espaco, i, j: integer;
label limpouFim, achouNaoBranco, abreBrancos;

begin
    for i := length (linhaSaida) downto 1 do
        if linhaSaida [i] = ' ' then
            delete (linhaSaida, i, 1)
        else
            goto limpouFim;

    if length(linhaSaida) = 0 then exit;

limpouFim:
    for i := 1 to length (linhaSaida) do    {descobre primeiro não branco }
        if linhaSaida [i] <> '' then break;

    delete (linhaSaida, 1, i-1);
    for j := i to length (linhaSaida) do
        atribSaida [j-i+1] := atribSaida[j];

    espaco := ultCol-primCol+1;
    nbr := primCol-1 + (espaco - length(linhaSaida)) div 2;

    for i := 1 to nbr do
        begin
            linhaSaida := ' ' + linhaSaida;
            for j := length (linhaSaida) downto 1 do
                atribSaida [j] := atribSaida[j-1];
        end;
end;

{--------------------------------------------------------}
{                     alinha a saida
{--------------------------------------------------------}

procedure alinhaSaida;
var pbr, primCarac, i, j: integer;
label limpouFim, achouNaoBranco, abreBrancos;

begin
    for i := length (linhaSaida) downto 1 do
        if linhaSaida [i] = ' ' then
            delete (linhaSaida, i, 1)
        else
            goto limpouFim;

    if length(linhaSaida) = 0 then exit;

limpouFim:
    for primCarac := 1 to length(linhaSaida) do
        if linhaSaida [primCarac] <> ' ' then
            goto achouNaoBranco;
    primCarac := length(linhaSaida) + 1;

achouNaoBranco:
    {testa se palavra unica}
    for i := primCarac to length (linhaSaida) do
        if linhaSaida[i] = ' ' then
           goto abreBrancos;

    exit;

abreBrancos:
    if (length (linhaSaida) <> ultCol) and
       (pos (' ', linhaSaida) > 0) then
        begin
            pbr := length(linhaSaida)-1;
            while length (linhaSaida) <> ultCol do
                begin
                    while (pbr > primCarac) and (linhaSaida [pbr] <> ' ') do
                        pbr := pbr - 1;
                    if pbr <= primCarac then
                        pbr := length(linhaSaida)-1
                    else
                        begin
                            insert (' ', linhaSaida, pbr);
                            for j := length (linhaSaida) downto pbr+1 do
                                 atribSaida [j] := atribSaida [j-1];
                            pbr := pbr - 1;
                        end;
                end;
        end;
end;

{--------------------------------------------------------}
{                       corta saida
{--------------------------------------------------------}

procedure cortaSaida;
var posic, posResto, posUltLetra, i: integer;
label limpouFim, achou, cortaFimLinha;

begin
    resto := '';

    if length (linhaSaida) <= ultCol then exit;

    for posic := ultCol+1 downto 2 do
        begin
            if linhaSaida [posic] = ' ' then
                goto achou;

            if separaSilabas and alinhaDireita and (posic < ultCol) and
                 (linhaSaida [posic-1] in vogais + ['S', 's', 'N', 'n', 'R', 'r']) and
                 (linhaSaida [posic]   in consoantes) and
                 (linhaSaida [posic+1] in vogais) then
                goto achou;
        end;

    posic := ultCol+1;

achou:
    posUltLetra := posic-1;
    while (posUltLetra > 0) and (linhaSaida [posUltLetra] = ' ') do
        posUltLetra := posUltLetra - 1;

    if posUltLetra = 0 then
        posUltLetra := ultCol;

    for posResto := posUltLetra+1 to length (linhaSaida) do
        if linhaSaida[posResto] <> ' ' then
            begin
                resto := copy (linhaSaida, posResto,
                                      length(linhaSaida)-posResto+1);
                for i := 1 to length(resto) do
                    atribResto [i] := atribSaida [i+posResto-1];
                goto cortaFimLinha;
            end;

cortaFimLinha:
    delete (linhaSaida, posUltLetra+1, length(linhaSaida)-posUltLetra);

    if linhaSaida [posUltLetra] = ' ' then
        repeat
            delete (linhaSaida, posUltLetra, 1);
        until (linhaSaida = '') or (linhaSaida [posUltLetra] <> ' ')
    else
        if (length(linhaSaida) > posUltLetra) and
           (linhaSaida [posUltLetra+1] in consoantes) then
             linhaSaida := linhaSaida + '-';
end;

{--------------------------------------------------------}
{                      trata espacos
{--------------------------------------------------------}

procedure trataEspacos;
var i: integer;
begin
    if coluna = 0 then
        inicLinhaSaida ('');

    linhaSaida := linhaSaida + trecho;
    for i := 1 to length (trecho) do
        atribSaida [i+coluna-1] := tipoLetra;
    coluna := coluna + length(trecho);

    if coluna > ultCol then
        begin
            cortaSaida;
            if centrando then
                centraSaida
            else
            if alinhaDireita then
                alinhaSaida;
            if emRodape then armazenaRodape
                        else descarregaImpressao;
            inicLinhaSaida (resto);
        end;
end;

{--------------------------------------------------------}
{          trata um conjunto de letras e simbolos
{--------------------------------------------------------}

procedure trataLetras;
var i: integer;
begin
    if coluna = 0 then
        inicLinhaSaida ('');

    linhaSaida := linhaSaida + trecho;
    for i := 1 to length (trecho) do
        atribSaida [i+coluna-1] := tipoLetra;
    coluna := coluna + length(trecho);
end;

{--------------------------------------------------------}
{                    trata fim do texto
{--------------------------------------------------------}

procedure trataFim;
begin
    if coluna = 0 then
        resto := ' '
    else
        resto := linhaSaida;

    while resto <> '' do
        begin
            cortaSaida;
            if centrando then
                centraSaida
            else
            if (resto <> '') and alinhaDireita then
                alinhaSaida;

            if emRodape then armazenaRodape
                        else descarregaImpressao;
            inicLinhaSaida (resto);
        end;

    coluna := 0;
    linhaSaida := '';
    linhaVazia := true;
    centrando := false;
end;

{--------------------------------------------------------}
{               descarrega rodapes pendentes
{--------------------------------------------------------}

procedure descarregaRodapes;
begin
    while nlRodape <> 0 do
        begin
            trataRodape;
            if nlRodape <> 0 then
                begin
                    trataCabecalho;
                    jogaImpressora (pulaLinha);
                    nlinPag := nlinPag + 1;
                end;
        end;
end;

{--------------------------------------------------------}
{                     pula página
{--------------------------------------------------------}

procedure pulaPagina;
begin
    trataFim;

    if nlRodape <> 0 then
       descarregaRodapes
    else
        if yimpr <> y0pag then      {salta página}
            yimpr := limyImpr+1;
end;

{--------------------------------------------------------}
{              trata a execucao de um comando
{--------------------------------------------------------}

procedure trataComando;
var comando: string[4];
    p: integer;

    function pegaNumero: integer;
    var posic, num, erro: integer;
    begin
        num := 0;
        posic := pos ('=', trecho);
        if posic > 0 then
            begin
                val (copy (trecho, posic+1, length(trecho)-posic), num, erro);
                if erro <> 0 then
                    begin
                        mensagem ('IMFORINV', 1);     {'Comando de formato inválido'}
                        writeln (trecho);
                        sintSoletra (trecho);
                        trecho := '';
                    end;
            end
        else
            begin
                mensagem ('IMFORINV', 1);      {'Comando de formato inválido'}
                writeln (trecho);
                sintSoletra (trecho);
                trecho := '';
            end;

        if num <= 0 then
           num := 1;

        pegaNumero := num;
    end;

begin
    p := pos ('=', trecho);
    if p = 0 then
        comando := trecho
    else
        begin
            comando := copy (trecho, 1, p-1);
            delete (comando, 1, p);
        end;

    { comandos de margem e espacejamento }

    if comando = 'MS' then primLinha := pegaNumero
    else
    if comando = 'MI' then
        begin
            ultLinha := pegaNumero;
            limyImpr := y0pag + ((ultLinha-1) * deltay * (espacejamento+1)) div 2;
        end
    else
    if comando = 'ME' then primCol := pegaNumero
    else
    if comando = 'MD' then ultCol := pegaNumero
    else
    if comando = 'EL' then
        begin
            espacejamento := pegaNumero;
            limyImpr := y0pag + ((ultLinha-1) * deltay * (espacejamento+1)) div 2;
        end
    else

    { titulo }

    if comando = 'TIT' then
        begin
            titulo := copy (trecho, 4, length(trecho)-3);
            while (titulo <> '') and (titulo[1] = ' ') do delete (titulo, 1, 1);
            if (titulo <> '') and (titulo[1] = '=') then delete (titulo, 1, 1);
            while (titulo <> '') and (titulo[1] = ' ') do delete (titulo, 1, 1);
            titulando := true;
        end
    else
    if comando = 'NTIT' then  titulando := false
    else

    { alinhamento separacao de silabas }

    if comando = 'AL'  then  alinhaDireita := true
    else
    if comando = 'NAL' then  alinhaDireita := false
    else
    if comando = 'SS'  then  separaSilabas := true
    else
    if comando = 'NSS' then  separaSilabas := false
    else
    if comando = 'AF'  then  autoFormata := true
    else
    if comando = 'NAF' then  autoFormata := false
    else
    if comando = 'C'   then  centrando := true
    else

    { tipo de letra }

    if comando = 'IN'  then  tipoLetra := tipoLetra or NEGRITO
    else
    if comando = 'FN'  then  tipoLetra := tipoLetra and not NEGRITO
    else
    if comando = 'II'  then  tipoLetra := tipoLetra or ITALICO
    else
    if comando = 'FI'  then  tipoLetra := tipoLetra and not ITALICO
    else
    if comando = 'IS'  then  tipoLetra := tipoLetra or SUBLINHADO
    else
    if comando = 'FS'  then  tipoLetra := tipoLetra and not SUBLINHADO
    else
    if comando = 'ISO' then  tipoLetra := tipoLetra or SUPERESCRITO
    else
    if comando = 'FSO' then  tipoLetra := tipoLetra and not SUPERESCRITO
    else
    if comando = 'ISU' then  tipoLetra := tipoLetra or SUBESCRITO
    else
    if comando = 'FSU' then  tipoLetra := tipoLetra and not SUBESCRITO
    else

    { fim de pagina e de paragrafo }

    if comando = 'NL' then
        trataFim
    else
    if comando = 'P' then
        pulaPagina
    else

    { cores }

    if (length(comando) = 3) and
       (copy (comando, 1, 2) = 'CE') and
       (comando[3] in ['0'..'7']) then
        tipoLetra := (tipoLetra and $ff) or
                     ((ord (comando[3]) - ord('0')) shl 8)
    else

    { notas de rodapé }

    if (comando = 'IROD') and (not emRodape) then
        begin
            if not linhaVazia then trataFim;
            emRodape := true;

            salvaUltCol := ultCol;
            salvaPrimCol := primCol;
            salvaTipo := tipoLetra;
            primCol := round ((tamFonte / tamFonteRod) * primCol);
            ultCol := round ((tamFonte / tamFonteRod) * ultCol);
            tipoLetra := NORMAL;
            inicLinhaSaida ('');
        end
    else
    if (comando = 'FROD') and emRodape then
        begin
            trataFim;
            emRodape := false;
            primCol := salvaPrimCol;
            ultCol := salvaUltCol;
            tipoLetra := salvaTipo;
            inicLinhaSaida ('');
        end
    else

    { comando invalido }

    if comando <> '' then
        begin
            mensagem ('IMFORINV', 1);    {'Comando de formato inválido'}
            writeln (trecho);
            sintSoletra (trecho);
            trecho := '';
        end;
end;

{--------------------------------------------------------}
{                   imprime formatado
{--------------------------------------------------------}

function imprimeFormatado: boolean;
begin
    imprimeFormatado := true;

    inicFormatador;
    inicLinhaSaida ('');

    processando := true;
    while processando do
        begin
            if keypressed and (readkey = ESC) then
                begin
                    imprimeFormatado := false;
                    exit;
                end;

            pegaTrecho (trecho, tipoTrecho);

            case tipoTrecho of
                BRANCOS: trataEspacos;
                LETRAS:  trataLetras;
                COMANDO: trataComando;
                FIM: trataFim;
            end;
        end;

    descarregaRodapes;
end;

end.
