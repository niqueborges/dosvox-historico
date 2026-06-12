{--------------------------------------------------------}
{
{    Busca e Substituicao de Cadeias
{
{    Autor: Marcelo Luis Pinheiro
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{    Atualizado por: Neno Henrique da Cunha Albernaz
{    Em 23/09/2018
{    Em 20/10/2018
{    Em 17/11/2024
{
{--------------------------------------------------------}

Unit edBusca;

interface

uses
    DVcrt, DVWin, dvForm, sysutils, classes,
    dvArqLog,
    edUtil,
    EDTRANSF,
    edDesfaz, edBloco, edvars, edmensag, edAcento, edTela, edLinha, edCursor;

procedure cmdBusca;
procedure buscaDeNovo (paraTraz, ciclica: boolean);
procedure formatarBuscado;
procedure buscaPalavra (paraTraz: boolean);
procedure trocaPalavra (trocarTab: boolean);
procedure limpaTexto (limparTexto, Pt_Br, limparTudoMudo: boolean);
procedure FalarQuantidadeTextos (JogaAreaTransfer: boolean);

implementation

{--------------------------------------------------------}

const TOTALBUSCADOSGRAVADOS = 20;
var buscarIdentica: boolean;

{--------------------------------------------------------}

procedure buscaParaFrente (ciclica: boolean);
var i, x, posyAux: integer;
    linha: string;
    umaVez: boolean;
label buscaCiclica;
begin
    umaVez := true;
    posyAux := posy;
buscaCiclica:

    for i := posyAux to maxlinhas do
        begin
            if not buscarIdentica then
                linha := semAcentos(texto [i]) + ^a
            else
                linha := texto [i] + ^a;
            if i = posy then
                for x := 1 to posx do
                    linha[x] := ^a;

            x := pos (buscado, linha);
            if x > 0 then
                begin
                    fala ('EDTXTENC');
                    posy := i;
                    posx := x;
                    exit;
                end;
        end;

    if ciclica and umaVez then
        begin
            umaVez := false; // Para não ficar em loop quando não encontrar no texto.
            sintClek;
            posyAux := 1;
            goto buscaCiclica;
        end;

    fala ('EDTXNENC');
end;

{--------------------------------------------------------}

procedure buscaParaTraz;
var i, x: integer;
    linha: string;
begin
    for i := posy downto 1 do
        begin
            if not buscarIdentica then
                linha := semAcentos (texto [i]) + ^a
            else
                linha := texto [i] + ^a;
            if i = posy then
                for x :=  posx to length(linha) do
                    linha[x] := ^a;

            x := pos (buscado, linha);
            if x > 0 then
                begin
                    fala ('EDTXTENC');
                    posy := i;
                    posx := x;
                    exit;
                end;
        end;

    fala ('EDTXNENC');
end;

{--------------------------------------------------------}

Procedure buscaDeNovo (paraTraz, ciclica: boolean);
begin
    if buscado = '' then
        buscaPalavra (paraTraz)
    else
    if paraTraz then
        buscaParaTraz
    else
        buscaParaFrente (ciclica);
end;

{--------------------------------------------------------}

procedure formatarBuscado;
begin
    buscarIdentica := false;
    if (length(buscado) > 1) and ((pos ('&', buscado) = 1) or (buscado[length(buscado)] = '&')) then
        begin
            buscarIdentica := true;
            if buscado[1] = '&' then delete (buscado, 1, 1);
            if (length(buscado) > 1) and (buscado[length(buscado)] = '&') then delete (buscado, length(buscado), 1);
        end
    else
        buscado := semAcentos (buscado);
end;

{--------------------------------------------------------}

function agruparItensGravados (secao, chave: string; totalItens: integer): integer;
var i, n, qtdExistente: integer;
begin
    qtdExistente := 0;
    // Conta quantas pesquisas guardadas e atualiza agrupando todas no início.
    for i := 1 to totalItens do
        begin
            if sintAmbiente (secao, chave + intToStr(i)) <> '' then inc (qtdExistente)
            else
            for n := (i +1) to totalItens do
                if sintAmbiente (secao, chave + intToStr(n)) <> '' then
                    begin
                        sintGravaAmbiente(secao, chave + intToStr(i), sintAmbiente (secao, chave + intToStr(n)));
                        sintGravaAmbiente(secao, chave + intToStr(n), '');
                        break;
                    end;
        end;

    result := qtdExistente;
end;

{--------------------------------------------------------}

function selecionarBuscaGravada (var buscado: string): char;
var
    i, n, qtdMostra: integer;
begin
    qtdMostra := agruparItensGravados ('EDIVOX', 'BUSCADO', TOTALBUSCADOSGRAVADOS);

    popupMenuCria(40, 9, 30, qtdMostra, RED);
    for i := 1 to TOTALBUSCADOSGRAVADOS do
        if sintAmbiente ('EDIVOX', 'BUSCADO' + intToStr(i)) <> '' then
            popupMenuAdiciona ('', sintAmbiente ('EDIVOX', 'BUSCADO' + intToStr(i)));

    n := popupMenuSeleciona;

    if n = 0 then
        begin
            buscado := '';
            result := ESC;
        end
    else
        begin
            buscado := sintAmbiente ('EDIVOX', 'BUSCADO' + intToStr(n));
            result := #0;
        end;
end;

{--------------------------------------------------------}

procedure gravarNoPrimeiroItem (secao, chave, novoItem: string; totalItens: integer);
var i: integer;
begin
    // Verifica se o novo item já está gravado. Se estiver, atualiza a variavel totalItens para a posição do item.
    for i := 1 to  totalItens do
        if sintAmbiente (secao, chave + intToStr(i)) = novoItem then
            begin
                totalItens := i;
                break;
            end;
    // Atualiza deixando o primeiro item vazio para guardar a busca.
    for i := totalItens downto 2 do
        sintGravaAmbiente(secao, chave + intToStr(i), sintAmbiente (secao, chave + intToStr(i-1)));
    // Grava o novo item buscado na posição 1.
    sintGravaAmbiente(secao, chave + '1', novoItem);
end;

{--------------------------------------------------------}

Procedure buscaPalavra (paraTraz: boolean);
var
    c: char;
begin
    buscado := sintAmbiente ('EDIVOX', 'BUSCADO1');
    fala ('EDTXTPRC');
    repeat
        c := sintEditaCampo (buscado , 1, wherey, 2048, 80, true);
        if (c = BAIX) or (c = CIMA) then
            begin
                c := selecionarBuscaGravada (buscado);
                if c <> ESC then //fala ('EDEDITENT');  {'Editore e tecle Enter'}
                    if existeArqSom ('_REEDIT') then sintSom ('_REEDIT')   {'Reedite e tecle Enter'}
                    else sintetiza ('Reedite e tecle enter');
            end;
    until c in [ESC, ENTER];

    if (c = ESC) or (buscado = '') then
        begin
            fala ('EDDESIST');
            exit;
        end;

    gravarNoPrimeiroItem ('EDIVOX', 'BUSCADO', buscado, TOTALBUSCADOSGRAVADOS);
    formatarBuscado;

    buscaDeNovo (paraTraz, false);
end;

{--------------------------------------------------------}

function existeNoTexto (s: string; falar: boolean): boolean;
var i: integer;
begin
    for i := 1 to maxLinhas do
        if pos (s, texto[i]) <> 0 then
            begin
                result := true;
                exit;
            end;

    if falar then
        fala ('EDTXNENC'); {'Texto não encontrado'}

    result := false;
end;

{--------------------------------------------------------}

procedure trocaPalavra (trocarTab: boolean);
var
    c: char;
    buscado, aTrocar: string;
    nl: integer;
    achou: boolean;
    totalPalavras: int64;

    function trocaTexto (nl: integer): boolean;
    var linha, saida: string;
        tamb, x: integer;
    begin
        linha := texto[nl];
        saida := '';
        tamb := length (buscado);

        trocaTexto := false;
        while linha <> '' do
            begin
                x := pos (buscado, linha);
                if x <= 0 then
                    begin
                        saida := saida + linha;
                        linha := '';
                    end
                else
                    begin
                        trocaTexto := true;
                        totalPalavras := totalPalavras + 1;
                        delete (linha, x, tamb);
                        if x > 1 then
                            saida := saida + copy (linha, 1, x-1);
                        saida := saida + atrocar;
                        linha := copy (linha, x, length(linha)-x+1);
                    end;
            end;

        texto[nl] := saida;
    end;

begin
    if trocarTab then
        buscado := #$09
    else
        begin
            fala ('EDTXTPRC');
            sintReadln (buscado);
        end;

    if buscado = '' then
        begin
            fala ('EDDESIST');
            exit;
        end;
    if (length(buscado) > 1) and (buscado[length(buscado)] = '&') then delete (buscado, length(buscado), 1);

    if not  existeNoTexto (buscado, true) then exit;

    if trocarTab then
        aTrocar := '        '
    else
        begin
            fala ('EDINFTXT');
            c := sintEdita(aTrocar, wherex, wherey, 300, true);
            if c <> ENTER then
                begin
                    fala ('EDDESIST');
                    exit;
                end;
        end;
    if (length(aTrocar) > 1) and (aTrocar[length(aTrocar)] = '&') then delete (aTrocar, length(aTrocar), 1);

    if blocoInvalido or blocoTodoTexto then
        c := 'T'
    else
        repeat
            fala ('EDTODBLK');
            c := popupMenuPorLetra ('TB');
            if c = #$1b then
                begin
                    fala ('EDDESIST');
                    exit;
                end;
        until c in ['T', 'B'];

    totalPalavras := 0;
    achou := false;
    if c = 'T' then
        begin
            gravarDesfazer;
            for nl := 1 to maxLinhas do
                if trocaTexto (nl) then achou := true;
        end
    else
        begin
            if iniBloco > 0 then
                gravarDesfazer;
                for nl := iniBloco to fimBloco do
                    if trocaTexto (nl) then achou := true;
        end;

    escreveTela;

    if achou then
        begin
            fala ('EDTXTTRC');
            sintetiza (intToStr(totalPalavras));
            sintclek;
        end
    else
        fala ('EDTXNENC');
end;

{--------------------------------------------------------}

procedure FalarQuantidadeTextos (JogaAreaTransfer: boolean);
var
    c: char;
    s, buscado: string;
    totalTextos: int64;
    y: integer;

    procedure contarTextos (s: string);
    var p: integer;
    begin
        p := pos (buscado, s);
        while p  > 0  do
            begin
                inc(totalTextos);
                delete (s, 1, p+length(buscado)-1);
                p := pos (buscado, s);
            end;
    end;

begin
    if blocoInvalido then
         begin
             fala ('EDBLKINV');   { bloco invalido }
             exit;
         end;

    buscado := sintAmbiente ('EDIVOX', 'BUSCADO1');
    fala ('EDTXTPRC');
    repeat
        c := sintEditaCampo (buscado , 1, wherey, 2048, 80, true);
        if (c = BAIX) or (c = CIMA) then
            begin
                c := selecionarBuscaGravada (buscado);
                if c <> ESC then //fala ('EDEDITENT');  {'Editore e tecle Enter'}
                    if existeArqSom ('_REEDIT') then sintSom ('_REEDIT')   {'Reedite e tecle Enter'}
                    else sintetiza ('Reedite e tecle enter');
            end;
    until c in [ESC, ENTER];

    if (c = ESC) or (buscado = '') then
        begin
            fala ('EDDESIST');
            exit;
        end;

    gravarNoPrimeiroItem ('EDIVOX', 'BUSCADO', buscado, TOTALBUSCADOSGRAVADOS);
    formatarBuscado;

    totalTextos := 0;
    for y := iniBloco to fimBloco do
        begin
            s := texto[y];
            contarTextos (s);
        end;

    if JogaAreaTransfer then
        jogaStringAreaTransf (intToStr(totalTextos));

    if totalTextos = 0 then
        fala ('EDTXNENC') {'Texto não encontrado'}
    else
        escreveNumero (totalTextos);
end;

{--------------------------------------------------------}

procedure cmdBusca;
var
    c1, c2: char;
label deNovo;
begin
    fala ('EDOPCAO');   { qual opcao ? }
    c1 := leTeclaMaiusc(c2);

deNovo:
    escreveTela;

    case c1 of

       'P': buscaPalavra (false);
       'A': buscaPalavra (true);
       'N': buscaDeNovo (false, false);
       'T': trocaPalavra (false);
       'B': trocaPalavra (true);
       'C', ^C: FalarQuantidadeTextos (c1 = ^C);

       #$0: begin
                c1 := ajuda (c2, 'EDAJBU', 6);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;

    escreveTela;
end;

{--------------------------------------------------------}
{       Limpa um texto retirando caracteres estranhos
{       O arquivo de caracteres com nome arqTroca.ini deve estar na pasta de arquivos de configuração do Dosvox.
{       Outro arquivo de troca é o arqTroca_PT_BR.ini para limpar e traduzir textos de Portugal
{--------------------------------------------------------}

procedure limpaTexto (limparTexto, Pt_Br, limparTudoMudo: boolean);
const MAXTROCASPORLINHA = 10000; // Utilizado para sair da chamada retroativa da procedure trocaTexto se houver erro no arquivo de troca, por exemplo a lihnha *|*, trocando * por *.
var
    i, k, yIni, yFim: integer;
    nomeArqLimpa, nomeArqTroca, saida, textoATrocar, novoTextoATrocar: string;
    linhasArqLimpa: TStringList;
    c: char;
    totalTrocas: int64;
    totalTrocasPorLinha: integer; //Utilizado para sair da chamada retroativa da procedure trocaTexto, não pode exceder MAXTROCASPORLINHA.
label fim;

    procedure trocaTexto (nl: integer);
    var
        linha, saida: string;
        tamb, x: integer;
    begin
        linha := texto[nl];
        saida := '';
        tamb := length (textoATrocar);
        while linha <> '' do
            begin
                x := pos (textoATrocar, linha);
                if x <= 0 then
                    begin
                        saida := saida + linha;
                        linha := '';
                    end
                else
                    begin
                        inc (totalTrocas);
                        inc (totalTrocasPorLinha);
                        delete (linha, x, tamb);
                        if x > 1 then
                            saida := saida + copy (linha, 1, x-1);
                        saida := saida + novoTextoATrocar;
                        linha := copy (linha, x, length(linha)-x+1);
                    end;
            end;
        texto[nl] := saida;

        // Tratamento abaixo para limpar mais ocorrências na mesma linha.
        // Não é utilizado nas "traduções". Implementado em  17/11/2024
        x := pos (textoATrocar, saida);
        if (limparTexto) and (x > 0) and (totalTrocasPorLinha < MAXTROCASPORLINHA) then
            trocaTexto (nl)
        else if totalTrocasPorLinha >= MAXTROCASPORLINHA then
            gravarArqLog ('Erro na linha com o texto: ' + textoATrocar + '|' + novoTextoATrocar, nomeArqLimpa+ '.log');
    end;

begin
    totalTrocas := 0;
    if limparTexto then
        begin
             if not limparTudoMudo then fala ('EDLIMTXT'); {'Limpando o texto ...'}
            nomeArqTroca := '\arqTroca.ini';
        end
    else
    if Pt_Br then
        begin
            fala ('EDPTPBR'); {'Traduzindo de Pt para Br ...'}
            nomeArqTroca := '\arqTroca_Pt_Br.ini';
        end
    else
        begin
            fala ('EDBRPPT'); {'Traduzindo de Br para Pt ...'}
            nomeArqTroca := '\arqTroca_Br_Pt.ini';
        end;

    nomeArqLimpa := sintDirAmbiente + nomeArqTroca;
    if not fileExists (nomeArqLimpa) then
        begin
            fala ('EDARQNAO'); {'Arquivo não existe'}
            sintetiza (nomeArqLimpa);
            exit;
        end;

    if limparTudoMudo or blocoInvalido or blocoTodoTexto then
        c := 'T'
    else
    repeat
        fala ('EDTODBLK'); {'Todo texto (T) ou bloco (B): '}
        c := popupMenuPorLetra ('TB');
    until c in ['T', 'B', ESC];

    if c = ESC then
        begin
                    fala ('EDDESIST');
            exit;
        end;

    if c = 'T' then
        begin
            yIni := 1;
            yFim := maxLinhas;
        end
    else
    if  fimbloco < iniBloco then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end
    else //Bloco válido
        begin
            yIni := iniBloco;
            yFim := fimBloco;
        end;

    linhasArqLimpa := TStringList.create;
    try
        linhasArqLimpa.loadFromFile (nomeArqLimpa);
    except
        fala ('EDARQNAO'); {'Arquivo não existe'}
        sintetiza (nomeArqLimpa);
        exit;
    end;

    gravarDesfazer;

    for k := 0 to (linhasArqLimpa.count -1) do
        begin
            totalTrocasPorLinha := 0;
            saida := linhasArqLimpa[k];
            i := pos ('|', saida);
            if i < 2 then continue;
            textoATrocar := copy (saida, 1, i-1);
            if trim(textoATrocar) = '' then continue;
            delete (saida, 1, i);
            novoTextoATrocar := saida;
            for i := yIni to yFim do
                begin
                    if keypressed and ((yfim - yIni) > 1000) then
                        begin
                            c := readkey;
                            if c = ESC then
                                begin
                                            fala ('EDDESIST');
                                    goto fim;
                                end
                            else
                                begin
                                    escreveNumero (((k+1)*100)div (linhasArqLimpa.count-1));
                                    sintWrite ('%');
                                end;
                        end;
                    trocaTexto (i);
                end;
        end;

fim:
    linhasArqLimpa.free;
    inicBloco;
    escreveTela;
    if not limparTudoMudo then
        begin
            if totalTrocas > 0 then sintetiza(intToStr(totalTrocas));
            fala ('EDOK'); {'OK'}
         end;
    posx := 1;
end;

{--------------------------------------------------------}

begin
end.
