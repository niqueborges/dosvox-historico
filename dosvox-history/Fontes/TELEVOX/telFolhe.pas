{--------------------------------------------------------}
{               Televox - rotinas de Folheamento
{--------------------------------------------------------}

unit telFolhe;
interface

uses windows, shellApi, sysutils, dvlenum,
     dvcrt, dvWin, dvarq, DVForm, winsock,
     telVars, telMsg, telTela, telItem, telUtil;

procedure folheia (masc: byte);
procedure folheiaCadastro;
procedure procura;
procedure seleciona;
procedure ordena;

implementation

{--------------------------------------------------------}
{                Folheia registros
{--------------------------------------------------------}

procedure folheia (masc: byte);
var
    s: string;
    c: char;
    postab, salva: integer;

label canc, achei;

begin
    if masc = TODOS then
        achados := cadastrados
    else
        begin
            achados := 0;
            for postab := 1 to cadastrados do
                if (listaFone[postab]^.status and masc) <> 0 then
                     achados := achados + 1;
        end;

    str (achados, s);
    msgBaixo ('TVACHAD', pegaTextoMensagem ('TVACHAD') + s);
    falaNumeroConv (numeroParaString (achados), MASCULINO);

    if achados = 0 then
        begin
             postab := 1;
             goto canc;
        end;
    sintSom ('TVPODLER');  { pode ler...}

    postab := 0;
    c := PGDN;
    repeat
        if c = CTLPGUP then
            begin
                postab := 0;
                c := PGDN;
            end
        else
        if c = CTLPGDN then
            begin
                postab := cadastrados+1;
                c := PGUP;
            end;

        if c = F5 then
            begin
                msgBaixo ('TVTINICI', '');   {'Avançar até que letra inicial?'}
                while keypressed do c := readkey;
                if c = ESC then
                    msgBaixo ('TVDESIS', '')
                else
                    begin
                        salva := postab;
                        for postab := postab+1 to cadastrados do
                            begin
                                if (masc = TODOS) or
                                   ((listaFone [postab]^.status and masc) <> 0) then
                                        if ansiUpperCase(copy (listaFone[posTab]^.campoCad[1]^, 1, 1)) = ansiUpperCase(c) then
                                            goto achei;
                            end;
                        postab := salva;
                        sintBip;
                    end;
            end;

        if c = PGDN then
            begin
                for postab := postab+1 to cadastrados do
                    begin
                        if masc = TODOS then goto achei;
                        if (listaFone [postab]^.status and masc) <> 0 then
                            goto achei;
                    end;
                postab := cadastrados + 1;
            end
        else
            begin
                for postab := postab-1 downto 1 do
                    begin
                        if masc = TODOS then goto achei;
                        if (listaFone [postab]^.status and masc) <> 0 then
                            goto achei;
                    end;
                postab := 0;
            end;
achei:
        if (postab > cadastrados) or (postab <= 0) then
            begin
                msgBaixo ('TVCLEK', ''); {'Último registro'}
                c := readkey;
                if c = #0 then c := readkey;
            end
        else
            begin
    if listaFone[posTab]^.status <> 0 then
        sintbip;
                limpaTela;
                posTabFolheia := posTab;
                posFolheia := TOPO;
                posAtualFolheia := 1;
                imprime (FALSE);
                liga;
                c := passeiaNosItens (postab, true);
            end;
    until c = #$1b;

canc:
    msgBaixo ('TVTERM', ''); {'Operação terminada'}
    posAtual := postab;
end;

{--------------------------------------------------------}
{                       procura um nome
{--------------------------------------------------------}

procedure procura;
var
    texto, nomeLista: string;
    cod: char;
    postab, p: integer;
    procuraNoInicio: boolean;

label buscaCadeia, canc;

begin
    limpaTela;
    gotoxy (1, 11);
    clreol;
    textBackGround (BLUE);
    mensagem ('TVPROCUR', 0);     {'PROCURA:'}
    textBackground (BLACK);

    gotoxy (1, 13);
    mensagem ('TVNOMPRO', 0); {'Nome a procurar: '}

    texto := '';
    cod := sintEdita (texto, 1, 14, 80, true);
    if (cod = ESC) or (texto = '') then
        goto canc;
    texto := maiuscAnsi (semAcentos(texto));
    procuraNoInicio := false;
    if (length (texto) >= 2) and (texto[length(texto)] = '*') then
        begin
            procuraNoInicio := true;
            delete (texto, length (texto), 1);
        end;

buscaCadeia:
    for postab := 1 to cadastrados do
        with listaFone [postab]^ do
            begin
                nomeLista := maiuscAnsi (semAcentos (campoCad[1]^));
                if procuraNoInicio then
                    begin
                        if length (texto) <= length (nomeLista) then
                            p := pos (texto, copy (nomeLista, 1, length (texto)))
                        else
                            p := 0;
                    end
                else
                    p := pos (texto, nomeLista);

                if p <> 0then
                    begin
                        status := status or ACHADO;
                        achados := achados + 1;
                    end
                else
                     status := status and not ACHADO;
            end;

     folheia (ACHADO);
canc:
end;

{--------------------------------------------------------}
{                seleciona registros
{--------------------------------------------------------}

procedure seleciona;
var
    campo, s, texto: string;
    buscado: array [1..MAXCAMPOS] of string;
    postab, qual, p: integer;

label proximo, canc;

begin
    msgBaixo ('TVINFSEL', ''); {'Preencha os itens que contém informações desejadas'}

    { usa um elemento nao existente, para comparacoes }

    novoRegistro (cadastrados+1);
    limpaTela;
    posTabFolheia := cadastrados + 1;
    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    passeiaNosItens (cadastrados+1, true);

    with listaFone [cadastrados+1]^ do
        begin
            for qual := 1 to numCampos do
                begin
                    campo := obtemItem (qual, cadastrados+1);
                    buscado[qual] := maiuscAnsi (semAcentos (campo));
                end;
        end;

    removeRegistro (cadastrados+1);

    desmarcaTodos;
    achados := 0;

    for postab := 1 to cadastrados do
        with listaFone [postab]^ do
            begin
                for qual := 1 to numCampos do
                    if buscado[qual] <> '' then
                        begin
                            texto := buscado[qual];
                            campo := obtemItem (qual, postab);
                            campo := maiuscAnsi (semAcentos (campo));
                            if (length (texto) >= 2) and (texto[length(texto)] = '*') then
                                begin
                                    delete (texto, length(texto), 1);
                                    if length (texto) <= length (campo) then
                                        p := pos (texto, copy (campo, 1, length (texto)))
                                    else
                                        p := 0;
                                end
                            else
                                p := pos (texto, campo);

                            if p = 0then
                                begin
                                    status := status and not SELECIONADO;
                                    goto proximo;
                                end;
                        end;

                achados := achados + 1;
                status := status or SELECIONADO;
proximo:
            end;


    str (achados, s);
    msgBaixo ('TVACHAD', pegaTextoMensagem ('TVACHAD') + s); {'Registros achados: '}
    falaNumeroConv (numeroParaString (achados), MASCULINO);
end;

{--------------------------------------------------------}
{         escolhe tipo de folheamento de registros
{--------------------------------------------------------}

procedure folheiaCadastro;
var c, c2: char;
begin
    limpaTela;
    textBackGround (BLUE);
    mensagem ('TVFOLHEA', 0);     {'Folhear:'}
    textBackground (BLACK);

    gotoxy (1, 13);
    mensagem ('TVTODSEL', 1); {'Tecle T para todos ou S para os selecionados: '}

    sintLeTecla (c, c2);
    c := upcase (c);
    if (c = ESC) then exit;

    if c = #$0 then
        begin
            if (c2 = CIMA) or (c2 = BAIX) then c := 'T';
        end;

    case c of
        ENTER, 'T': folheia(TODOS);
        'S': folheia(SELECIONADO);
    else
        msgBaixo ('TVOPINV', ''); {'Operação inválida'}
    end;
end;

{--------------------------------------------------------}
{                       ordena a lista
{--------------------------------------------------------}

procedure ordena;
var
    p: pCadastro;
    s, campo: string;
    i, j, qual: integer;
    ordenaCampo: array [1..MAXCAMPOS] of boolean;

begin
    msgBaixo ('TVORDSEL', ''); {'Marque com um x os campos de ordenação'}

    { usa um elemento nao existente, para trabalho }

    novoRegistro (cadastrados+1);
    limpaTela;
    posTabFolheia := cadastrados + 1;
    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    passeiaNosItens (cadastrados+1, true);

    with listaFone [cadastrados+1]^ do     { transforma em maiusculas }
        begin
            for qual := 1 to numCampos do
                ordenaCampo [qual] := obtemItem (qual, cadastrados+1) <> '';
        end;

    removeRegistro (cadastrados+1);

    msgBaixo ('TVAGUARD', ''); {'Aguarde, ordenando'}

    for qual := 1 to numCampos do
        if ordenaCampo [qual] then

            for i := 1 to cadastrados-1 do
                begin
                    s := maiuscAnsi (semAcentos (obtemItem (qual, i)));

                    for j := i+1 to cadastrados do
                        begin
                            campo := maiuscAnsi (semAcentos (
                                                    obtemItem (qual, j)));
                            if s >= campo then
                               begin
                                   p := listaFone [j];
                                   listaFone [j] := listaFone [i];
                                   listaFone [i] := p;
                                   s := campo;
                               end;
                        end
                end;

    msgBaixo ('TVOKORD', ''); {'Ok, ordenado'}
    posAtual := 0;
end;

end.
