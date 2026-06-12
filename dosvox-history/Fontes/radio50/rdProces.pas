{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Processamento de opções                             }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{   Modificado por Patrick Barboza                       }
{                                                        }
{   Em Outubro / Novembro / 2021                         }
{                                                        }
{--------------------------------------------------------}

unit rdproces;

interface
uses
    windows,
    dvcrt,
    dvwin,
    dvForm,
    dvSapi,
    dvSapGlb,
    dvAmplia,
    dvInet,
    dvHora,
    sysUtils,
    rdprefer,
    rdatuIni,
    rdbass,
    rdffplay,
    rdBusca,
    rdAjuda,
    rdmsg,
    rdUtil,
    rdvars,
    classes;

procedure processa;
function escolheCategoria: string;

implementation

{--------------------------------------------------------}
{                exibe o total de rádios                   }
{--------------------------------------------------------}

procedure exibeTotalRadios (valor: integer; falar: boolean);
begin
    write (intToStr(valor) + ' ');
    writeln (pegaTextoMensagem('RDNUMIT'));  {'rádios nesta categoria'}
    if sintFalarTudo and falar then
        begin
            sintetiza(intToStr(valor));
            mensagem ('RDNUMIT', -1);  {'rádios nesta categoria'}
        end;
end;

{--------------------------------------------------------}
{          folheia as rádios de certa categoria
{--------------------------------------------------------}

procedure folheiaRadios (categoria: string);
var
    radios: array [0..TOTALLETRAS] of char;
    p: pchar;
    i, n: integer;
    c1, c2: char;
    nomeRadio, url: string;
    sl: TStringList;
    falarItem, apertouShift: boolean;

    procedure tocarUmaRadio (var n: integer);
    var
        ok: boolean;
    begin
        nomeRadio := sl[n-1];
        url := sintAmbienteArq (categoria, nomeRadio, '', arqIndice);
        if url = '' then exit;

        limpabaixo (3);
        textBackground (RED);
        writeln (nomeRadio);
        textBackground (BLACK);
        writeln (url);
        writeln;

        ultimaTocada := url;
        if not comTocadorExterno (url) then
            ok := tocaRadioBass (nomeRadio, url) >= 0
        else
            ok := tocaRadioExterna (nomeRadio, tirarTocadorExterno(url)) >= 0;

        if (not ok) and veSeApaga (nomeRadio) then
            begin
                sintRemoveAmbienteArq (categoria, nomeRadio, arqIndice);
                sl.Delete(n-1);
                folheiaRemoveItem (n);
                dec (n);
                mensagem ('RDOKRM', 2);        {'Ok, removido'}
            end;
    end;

    procedure cabecalhoFolheamento (falar: boolean);
    begin
        clrscr;
        textBackground (BLUE);
        if sintFalarTudo and falar then
            sintWriteln (categoria)
        else
            write (categoria);
        textBackground (BLACK);
        writeln;
        textBackground (RED);
        exibeTotalRadios(sl.count, falar);
        write (pegaTextoMensagem('RDSELRAD'));  {'Selecione com as setas a rádio e tecle Enter'}
        textBackground (BLACK);
        writeln;
    end;

begin
    getprivateProfileString (pchar(categoria), NIL, '', radios, TOTALLETRAS, pchar(arqIndice));

    p := radios;
    sl := TStringList.Create;
    while p^ <> #$0 do
        begin
            sl.add (pchar(p));
            p := p + strlen(p) + 1;
        end;
    sl.Sort;

    mensagem ('RDSELRAD', -1);  {'Selecione com as setas a rádio e tecle Enter'}
    cabecalhoFolheamento (true);

    folheiaCria(1, wherey, 50, 24-amplFator);
    for i := 0 to sl.Count-1 do
        folheiaAdiciona (sl[i]);

    n := 1;
    falarItem := true;
    repeat
        cabecalhoFolheamento (false);
        folheiaExecuta(n, n, c1, c2, falarItem);
        apertouShift := GetKeyState(VK_SHIFT) < 0;
        if n < 1 then n := 1
        else if n > folheiaNumItens then n := folheiaNumItens;

        if (c1 = #0) and (c2 = F9) then
            c1 := selSetasFolheiaRadios (c2, apertouShift);

        if c1 = #0 then
            case c2 of
                F1: ajudaFolheiaRadios;
                DIR, CTLDIR:
                    begin
                        if comTocadorExterno (sintAmbienteArq (categoria, sl[n-1], '', arqIndice)) then sintbip;
                        if c2 = DIR then sintetiza (tirarTocadorExterno(sintAmbienteArq (categoria, sl[n-1], '', arqIndice)))
                        else sintsoletra (tirarTocadorExterno(sintAmbienteArq (categoria, sl[n-1], '', arqIndice)));
                    end;
                ESQ: sintetiza (categoria);
                CTLESQ: sintsoletra (categoria);
                F5: n := folheiaBuscaItem (n);
                CTLF5: n := folheiaBuscaItemNovamente (n);
                F8: falaHora;
                CTLF8: falaDia;
            end
        else
            case c1 of
                ^Q: falaQualItemDeQuantos (n, apertouShift);
                ^C: copiaAreaTransfSelec (n, categoria, arqIndice, apertouShift, sl);
                '3': geraArqivosM3U (n, categoria, arqIndice, sl);
                ^S: selecionarTodosItensFolheamento;
                ^E:
                    begin
                        nomeRadio := sl[n-1];
                        url := sintAmbienteArq (categoria, sl[n-1], '', arqIndice);
                        editarRadioFolheamento (n, categoria, nomeRadio, url);
                        sl[n-1] := nomeRadio;
                    end;
                ^P: adicionarAosPreferidos (sl[n-1], sintAmbienteArq (categoria, sl[n-1], '', arqIndice));
                ^R: n := removerRadio (n, categoria, sl);
                ^T: n := procurarSeUsaTocadorExterno (n,  categoria, nil);
                ENTER: tocarUmaRadio (n);
            ESC: ;
            else
                n := folheiaPosicionaInicial (c1, n);
            end;

        if n > sl.count then sintbip;

        if (c1 in [^Q, ^C]) or ((c1 = #0) and (c2 in [DIR, CTLDIR, ESQ, CTLESQ, F8, CTLF8])) then falarItem := false
        else falarItem := true;

        if folheiaNumItens = 0 then c1 := ESC;

    until c1 = ESC;

    folheiaDestroi;

    if sintFalarTudo then mensagem ('RDFIMFOL', 2)   {'Fim do Folheamento'}
    else writeln (pegaTextoMensagem('RDFIMFOL')); writeln;
    sl.Free;
end;

{--------------------------------------------------------}
{          Escolhe uma categoria para processar
{--------------------------------------------------------}

function escolheCategoria: string;
var
    categorias: array [0..TOTALLETRAS] of char;
    p: pchar;
    n: integer;
    c1, c2: char;
    falarItem: boolean;
    categoria: string;

begin
    result := '';
    textBackground (RED);
    mensagem ('RDSELCAT', 1);  {'Selecione com as setas a categoria'}
    textBackground (BLACK);

    getprivateProfileString (NIL, NIL, '', categorias, TOTALLETRAS, pchar(arqIndice));
    p := categorias;
    while p^ <> #$0 do
        p := p + strlen(p) + 1;

    p := categorias;

        folheiaCria(1, wherey, 80, 26-amplFator);
    while p^ <> #$0 do
        begin
            if upperCase(strPas(p)) <> 'PREFERIDAS' then
              folheiaAdiciona (strPas(p));
            p := p + strlen(p) + 1;
        end;

    n := 1;
    falarItem := true;
    repeat
        folheiaExecuta(n, n, c1, c2, falarItem);
        if n < 1 then n := 1
        else if n > folheiaNumItens then n := folheiaNumItens;
        folheiaObtemItem (n, categoria, falarItem);

        if c1 = #0 then
            case c2 of
                DIR: sintsoletra (categoria);
                ESQ: sintetiza (categoria);
                F5: n := folheiaBuscaItem (n);
                CTLF5: n := folheiaBuscaItemNovamente (n);
                F8: falaHora;
                CTLF8: falaDia;
            end
        else
            case c1 of
                ^Q: falaQualItemDeQuantos (n, false);
                ENTER: result := categoria;
            ESC: result := '';
            else
                n := folheiaPosicionaInicial (c1, n);
            end;

        if (c1 in [^Q]) or ((c1 = #0) and (c2 in [DIR, ESQ, F8, CTLF8])) then falarItem := false
        else falarItem := true;
    until c1 in [ESC, ENTER];
    folheiaDestroi;
end;

{--------------------------------------------------------}
{                edita uma categoria
{--------------------------------------------------------}

procedure editaCategoria (nomeCategoria: string);
var
    itens: array [0..TOTALLETRAS] of char;
    p: pchar;
    n, total: integer;
    umaRadio, infoRadio: string;

begin
    total := 0;
    repeat
        gotoxy (1, 5);
        p := itens;
        getPrivateProfileString (pchar(nomeCategoria), NIL, '', itens, TOTALLETRAS, pchar(arqIndice));
        while p^ <> #$0 do
            begin
            p := p + strlen(p) + 1;
            total := total + 1; //Indicar quantas rádios na categoria
        end;

        p := itens;

        exibeTotalRadios(total, true);
        mensagem ('RDITEMED', 1);      {'Escolha com as setas o item a editar'}

        popupMenuCria (1, wherey, 80, 26-wherey-amplFator, MAGENTA);
        while p^ <> #$0 do
            begin
                popupMenuAdiciona ('', strPas(p));
                p := p + strlen(p) + 1;
            end;

        popupMenuOrdena;
        n := popupMenuSeleciona;
        if n <= 0 then exit;

        umaRadio := opcoesItemSelecionado;
        writeln (umaRadio);

        writeln;
        limpaBaixo (wherey);
        textBackground (RED);
        mensagem ('RDEDENDR', 1);     {'Editore o endereço de acesso da rádio: '}
        textBackground (BLACK);

        infoRadio := sintAmbienteArq (nomeCategoria, umaRadio, '', arqIndice);
        if sintEditaCampo (infoRadio, wherex, wherey, 255, 80, true) = ENTER then
            begin
                sintGravaAmbienteArq (nomeCategoria, umaRadio, infoRadio, arqIndice);
                writeln;
                mensagem ('RDOK', 1);
            end
        else
            begin
                clreol;
                mensagem ('RDDESIST', 1);  {'Desistiu'}
            end;

        writeln;
    until false;
end;

{--------------------------------------------------------}
{                inclui um item
{--------------------------------------------------------}

procedure incluiItem (nomeCategoria: string);
var item, conteudo: string;

begin
    repeat
        mensagem ('RDITEMIN', 1);   {'Nome do item a incluir'}
        sintReadln (item);
        if item = '' then exit;

        mensagem ('RDITEMCT', 1);   {'Informe o conteúdo deste item'}
        sintReadln (conteudo);

        sintGravaAmbienteArq (nomeCategoria, item, conteudo, arqIndice);
        mensagem ('RDOK', 2);        {'Ok'}
    until false;
end;

{--------------------------------------------------------}
{                    remove um item
{--------------------------------------------------------}

procedure removeItem (nomeCategoria: string);
var
    itens: array [0..TOTALLETRAS] of char;
    p: pchar;
    i, n, total: integer;
    c: char;

begin
    total := 0;
    repeat
        p := itens;
        getPrivateProfileString (pchar(nomeCategoria), NIL, '', itens, TOTALLETRAS, pchar(arqIndice));
        while p^ <> #$0 do
            begin
            p := p + strlen(p) + 1;
            total := total + 1;
        end;

        p := itens;

        gotoxy (1, 5);
        limpaBaixo (wherey);
        exibeTotalRadios(total, true);

        mensagem ('RDITEMRM', 1);      {'Escolha com as setas o item a remover'}

        popupMenuCria (1, wherey, 80, 26-wherey-amplFator, MAGENTA);
        while p^ <> #$0 do
            begin
                popupMenuAdiciona ('', strPas(p));
                p := p + strlen(p) + 1;
            end;

        n := popupMenuSeleciona;
        if n <= 0 then exit;

        p := itens;
        for i := 2 to n do
            p := p + strlen(p) + 1;

        mensagem ('RDCNFRMI', 0);    {'Confirma remoção do item '}
        sintWrite (strPas (p));
        write ('? ');
        c := popupMenuPorLetra('SN');
        writeln;
        if upcase(c) = 'S' then
            begin
                sintRemoveAmbienteArq (nomeCategoria, p, arqIndice);
                mensagem ('RDOKRM', 2);        {'Ok, removido'}
            end;

    until false;
end;

{--------------------------------------------------------}
{                cria uma nova categoria
{--------------------------------------------------------}

procedure criaNovaCategoria;
var novaCategoria: string;
const lixo = 'xyxyxyxyxyxyxyxyxy';
begin
    mensagem ('RDNOVSEC', 1);      {'Informe o nome da nova categoria:'}
    sintReadln (novaCategoria);
    if novaCategoria = '' then exit;

    sintGravaAmbienteArq (novaCategoria, lixo, lixo, arqIndice);
    sintRemoveAmbienteArq (novaCategoria, lixo, arqIndice);

    mensagem ('RDOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{                destrói uma categoria
{--------------------------------------------------------}

procedure destroiUmaCategoria;
var categDestruir: string;
    c, c2: char;
begin
    mensagem ('RDCATDST', 1);      {'Informe o nome da categoria a destruir:'}
    sintReadln (categDestruir);
    if categDestruir = '' then exit;

    mensagem ('RDPERIGO', 1);      {'Destruirei a categoria com este nome, perdendo todas as rádios.'}
    mensagem ('RDAPTD', 0);        {'Aperte D para destruir sem chance de voltar. '}
    sintLeTecla (c, c2);
    writeln;
    if upcase(c) <> 'D' then
        begin
            mensagem ('RDDESIST', 2);  {'Desistiu'}
            exit;
        end;

    sintRemoveAmbienteArq (categDestruir, '', arqIndice);

    mensagem ('RDOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}

procedure testaRadioPelaURL;
var url: string;
    c: char;
begin
    mensagem ('RDDIGURL', 1);   {'Digite a URL da rádio:'}
    sintReadln (url);
    if url = '' then
        begin
            mensagem ('RDDESIST', 1);   {'Desistiu'}
            exit;
        end;

    mensagem ('RDTOCEXT', 0);   {'Precisa usar um tocador externo? '}
    c := popupMenuPorLetra('SN');
    if c = ESC then
        begin
            mensagem ('RDDESIST', 1);   {'Desistiu'}
            exit;
        end;

    ultimaTocada := url;
    if c <> 'S' then
        tocaRadioBass (url, url)
    else
        tocaRadioExterna (url, url);
end;

{--------------------------------------------------------}
{       Fala o total de rádios no arquivo Radio50.ini
{--------------------------------------------------------}

procedure falarTotalRadios;
var
    slOrig: TStringList;
    p: integer;
    i, totalRadios: longInt;
begin
    slOrig := TStringList.Create;
    slOrig.LoadFromFile(arqIndice);
    totalRadios := 0;

    for i := 0 to slOrig.Count-1 do
        begin
            if slOrig[i] = '' then continue;
            if slOrig[i][1] in [';', '['] then continue;
            p := pos ('=', slOrig[i]);   // evita erros
            if p <> 0 then inc(totalRadios);
        end;

    slOrig.Free;

    sintetiza (intToStr(totalRadios));
    mensagem ('RDRADIOS', -1);
end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}

procedure processa;
var c, c2: char;
    nomeCategoria: string;
    opcao: string;
label fim;

begin
    while true do
        begin
            cabecalho (false);
            textBackground (BLUE);
            mensagem ('RDOQUE', 0);      {'Rádio50 - que deseja? '}
            textBackground (BLACK);
            sintLeTecla (c, c2);
            opcao := '';

            if (c = #0) and (c2 in [CIMA, BAIX, F9]) then
                begin
                    c := selSetasOpcaoPrincipal;
                    if not (c in [#0, ESC]) then
                        opcao := copy (opcoesItemSelecionado, pos ('-', opcoesItemSelecionado)-1, length(opcoesItemSelecionado));
                end;

            if (c = #0) and (c2 = F4) then goto fim;

            if (c = #0) and (c2 = F1) then
                ajudaOpcaoPrincipal
            else
            if (c = #0) and (c2 = HOME) then
                begin
                    mensagem ('RDINIC', -1);   {'Radio50 - versão '}
                    sintetiza (VERSAO);
                end
            else
                begin
                    clrscr;
                    textBackground (BLUE);
                    writeln ('Radio50' + opcao);
                    textBackground (BLACK);
                    writeln;

                    if upcase (c) in ['F', 'E', 'I', 'R'] then
                        begin
                            nomeCategoria := escolheCategoria;
                            if nomeCategoria = '' then continue;
                        end;

                    if upcase(c) = 'J'  then c := ^B; // Para facilitar quem tem problema de teclar Ctrl+B

                    case upcase(c) of
                        'Q': falarTotalRadios;
                        'P': radiosPreferidas;
                        ^P: folheiaPreferidas (true);
                        'F': folheiaRadios (nomeCategoria);
                        'E': editaCategoria (nomeCategoria);
                        'I': incluiItem (nomeCategoria);
                        'R': removeItem (nomeCategoria);
                        'C': criaNovaCategoria;
                        'D': destroiUmaCategoria;
                        'A': atualizarIni;
                        'T': testaRadioPelaURL;
                        'B', ^B: buscaRadioPeloNome (c = ^B);
                        #0: ; // Para selSetasOpcaoPrincipal sem seleção não falar "Opção inválida".
                        ESC: goto fim;
                     else
                         mensagem ('RDOPINV', 1); {'Opção inválida'}
                     end;
                 end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}

begin
end.
