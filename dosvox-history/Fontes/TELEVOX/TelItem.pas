{--------------------------------------------------------}
{       televox - rotinas de tratamento de itens
{--------------------------------------------------------}

unit telitem;

interface
Uses
    Windows, DVCrt, DVWin, DVarq, DVForm, SysUtils, DVLenum,
    TelVars, TelTela, telMsg, telUtil;

procedure novoRegistro (postab: integer);
Procedure inclui;
function editaItem (qual, posTab: integer; altera: boolean): char;
function passeiaNosItens (postab: integer; alterando: boolean): char;
procedure remove;
procedure limpaLista;
Procedure leCadastro (novo, trataParam: boolean);
Function gravaCadastro (pergunta: boolean): boolean;
procedure trocaArquivo;

implementation

{--------------------------------------------------------}
{                  inclusao de um nome
{--------------------------------------------------------}

Procedure inclui;
var
    c: char;
    qual: integer;
    preenchido: boolean;

Begin
    limpaTela;
    textBackGround (BLUE);
    mensagem ('TVINCLUI', 0);  {'NOVO REGISTRO:'}
    textBackground (BLACK);

    If cadastrados > MAXCADASTRO then
        begin
            msgBaixo ('TVCHEIO', '');
            {'Caderno de telefones cheio, não posso mais incluir'}
            delay (1000);
            exit;
        end;

    cadastrados := cadastrados + 1;
    novoRegistro (cadastrados);
    posTabFolheia := cadastrados;
    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    passeiaNosItens (cadastrados, true);

    preenchido := false;
    for qual := 1 to numCampos do
        if obtemItem (qual, cadastrados) <> '' then preenchido := true
        else
        if qual = 1 then atualizaItem (1, cadastrados, 'VAZIO');

    if not preenchido then
        begin
            cadastrados := cadastrados - 1;
            msgBaixo ('TVIGNORA', ''); {'Entrada foi ignorada'}
            exit;
        end;

    repeat
        msgBaixo ('TVCNFINC', ''); {'Confirma inclusao (s/n) ?'}
        c := sintReadkey;
    until upcase(c) in ['S', 'N'];
    if upcase (c) = 'N' then
        begin
            cadastrados := cadastrados - 1;
            msgBaixo ('TVIGNORA', ''); {'Entrada foi ignorada'}
            exit;
        end;

    msgBaixo ('TVREGINC', '');  {'Registro foi incluído'}
    posatual := cadastrados;
end;

{--------------------------------------------------------}
{                 troca de arquivo
{--------------------------------------------------------}

procedure trocaArquivo;
begin
    if gravaCadastro (true) then
        begin
            msgBaixo ('TVTROCAR', ''); {'Trocando de arquivo'}
            limpaLista;
            leCadastro (true, false);
        end;
end;

{--------------------------------------------------------}
{                 cria novo item
{--------------------------------------------------------}

procedure novoRegistro (postab: integer);
var i: integer;
begin
    new (listaFone [postab]);
    with listaFone[postab]^ do
        begin
            status := 0;
            for i := 1 to numCampos do
                campoCad[i] := NIL;
        end;
end;

{--------------------------------------------------------}
{                    edita um item
{--------------------------------------------------------}

function editaItem (qual, posTab: integer; altera: boolean): char;
var c: char;
    campo: string;

    function isnumeric (campo: string): boolean;
    var i: integer;
    begin
        isNumeric := false;
        for i := 1 to length (campo) do
            if not (campo[i] in ['0'..'9', ' ', '-']) then exit;
        isNumeric := true;
    end;

begin
    campo := mostraItem (qual, posTab, true);
    if length (campo) > 3 then
        begin
            if isNumeric (campo) then
                sintSoletra (trim(campo))
            else
                sintetiza (campo);
        end
    else
        sintetiza (campo);

    c := sintEdita (campo, 16, posFolheia, 128, altera);
    editaItem := c;
    atualizaItem (qual, posTab, campo);
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

    const
    tabLetrasOpcoes: string [6] = F2+ F3+ CTLF3+ F5+ F6+ F7;
var n: integer;
begin
    while keypressed do readkey;
    popupMenuCria (40, 10, 40, 14, MAGENTA);
    MenuAdiciona ('TVAJ11');  {'F2  - grava cadastro'}
    MenuAdiciona ('TVAJ20');  {'F3  - fala número de registros'}
    MenuAdiciona ('TVAJ23');  {'CONTROL F3  - fala quantos selecionados do total de registros'}
    MenuAdiciona ('TVAJ20A'); {'F5  - Procura registro pela inicial'}
    MenuAdiciona ('TVAJ21A'); {'F6  - seleciona este registro'}
    MenuAdiciona ('TVAJ22A'); {'CONTROL F6  - tira a seleção deste registro'}
    MenuAdiciona ('TVAJ19');  {'F7  - remove'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <= 6) then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := #0;
    limpabuftec;
end;

{--------------------------------------------------------}
{                 passeia sobre os itens
{--------------------------------------------------------}

function passeiaNosItens (postab: integer; alterando: boolean): char;
var
    qual: integer;
    acabou: boolean;
    c: char;

label aciona;

begin
    qual := 1;
    acabou := false;
    repeat
        c := editaItem (qual, postab, alterando);
aciona:
        case c of
            CIMA:              begin
                                    qual := qual - 1;
                                    recua (1);
                               end;
            BAIX, TAB, ENTER:  begin
                                    qual := qual + 1;
                                    avanca (1);
                               end;
            F2: if gravaCadastro (false) then;
            f3: falaNumRegs (true);
            CTLF3: falaQuantosSelecionados;
            F6: marcaEste (postab);
            CTLF6: desmarcaEste (postab);
            F7: begin
                    posAtual := postab;
                    removeUltimo;
                    if posAtual <> postab then postab := posAtual
                end;
            F9: begin
                    c := selSetasOpcao;
                    goto aciona;
                end;

            F5, CTLPGUP, CTLPGDN, ESC, PGUP, PGDN:   acabou := true;
        end;
        if qual < 1 then qual := 1;
        if qual > numCampos then qual := numCampos;
        if posTabFolheia <> posTab then
            begin
                posTabFolheia := posTab;
                posFolheia := TOPO;
                posAtualFolheia := 1;
                imprime (FALSE);
                liga;
            end;
    until acabou;
    passeiaNosItens := c;
end;

{--------------------------------------------------------}
{                         remoção
{--------------------------------------------------------}

procedure remove;
var i, removidos: integer;
    s: string;
    c, c2: char;
begin
    textBackGround (BLUE);
    mensagem ('TVREMOV', 0); {'REMOVE:'}
    textBackground (BLACK);

    mensagem ('TVESCREM', 0); {'Tecle U para remover o último lido ou S para os selecionados: '}

    sintLeTecla (c, c2);
    c := upcase (c);
    if (c = ESC) then exit;

    case c of
        'U': removeUltimo;

        'S': begin
                 removidos := 0;
                 i := cadastrados;
                 while i > 0 do
                     begin
                        if (listaFone [i]^.status and SELECIONADO) <> 0 then
                            begin
                                 removeRegistro (i);
                                 removidos := removidos + 1;
                            end;
                        i := i - 1;
                     end;

                 str (removidos, s);
                 msgBaixo ('TVNREMOV', pegaTextoMensagem ('TVNREMOV') + s); {'Registros removidos: '}
                 falaNumeroConv (numeroParaString (removidos), MASCULINO);
             end;
    else
        msgBaixo ('TVOPINV', ''); {'Operação invalida'}
    end;

    posAtual := 0;
end;

{--------------------------------------------------------}
{                  limpa a lista
{--------------------------------------------------------}

procedure limpaLista;
var i: integer;
begin
    for i := 1 to cadastrados do
        begin
            removeTodosItens (i);
            dispose (listaFone [i]);
        end;

    cadastrados := 0;
end;

{--------------------------------------------------------}
{                  le arquivo do disco
{--------------------------------------------------------}

Procedure leCadastro (novo, trataParam: boolean);

    procedure removeCampoPadrao (nc: integer);
    var i: integer;
    begin
        for i := nc+1 to numCampos do
            begin
                tabTexto[i-1] := tabTexto[i];
                tabFala[i-1] := tabFala[i];
                tabMalaDir[i-1] := tabMalaDir[i];
            end;

        numCampos := numCampos - 1;
    end;

var
    c: char;
    s: string;
    qual, resulta: integer;
    temDados, criaArqRapido, editaArqRapido: boolean;
    lidos: integer;
    x, dirAtual: string;
    nc, p: integer;
    nomeJan: array [0..200] of char;

label abre, proximo, inicio, fimDoArquivo, cadNovo, formatoAntigo, formatoAntigo2, erroDisco;

    function verificaArqDir (d: string): boolean;
    begin
        assign (arqfone, d + nomeCadastro);
        {$I-}  reset (arqfone); {$I+}
        If Ioresult = 0  Then
            begin
                {$I-}  close (arqfone); {$I+}
                If Ioresult <> 0  Then;
                verificaArqDir := true;
            end
        else
            verificaArqDir := false;
    end;

    procedure testaArq;
    begin
        if (pos ('\', nomeCadastro) = 0) and (pos ('/', nomeCadastro) = 0) then
            if verificaArqDir (dirAgendas + '\') then
                nomeCadastro := dirAgendas + '\' + nomeCadastro
            else
            if verificaArqDir (dirAtual + '\') then
                nomeCadastro := dirAtual+ '\' + nomeCadastro
            else
            if resulta = 0 then
                nomeCadastro := dirAgendas + '\' + nomeCadastro;
    end;

Begin
    getdir (0, dirAtual);
    if dirAtual[length(dirAtual)] = '\' then
        delete (dirAtual, length(dirAtual), 1);

    if dirAgendas <> '' then
        begin
            {$I-} chdir (dirAgendas);  {$I+}
            resulta := ioresult;
        end;

    if trataParam and (paramcount <> 0) then
        begin
            nomeCadastro := paramStr(1);
            testaArq;
            goto abre;
        end;

inicio:

    gotoxy (1, 3);
    mensagem ('TVNOMARQ', 0);{'Qual o nome do arquivo ? '}
    garanteEspacoTela (10);
    nomeCadastro := obtemNomeArq (21-wherey);
    if nomeCadastro = '' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu...'}
            sintFim;
            doneWinCRT;
        end;
    writeln (nomeCadastro);

    testaArq;
abre:
    {$I-} chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
    lidos := 0;

    assign (arqfone, nomeCadastro);
    {$I-}  reset (arqfone); {$I+}
    If Ioresult = 0  Then
        begin
            msgBaixo ('TVCARGA', ''); {'Carregando arquivo'}

            {$I-}  readln (arqfone, x);  {$I+}
            if not eof (arqfone) then
                begin
                    if x <> '@' then
                        begin
formatoAntigo2:
                            msgBaixo ('TVFORANT', '');
                            {'O caderno está no formato antigo e será atualizado'}
                            msgBaixo ('TVVERGRA', '');
                            {'Confira se as mudanças estão corretas antes de gravar'}
                            inicCamposDefault;
                            removeCampoPadrao (3);
                            removeCampoPadrao (3);
                            {$I-}  close (arqfone); {$I+}
                            If Ioresult <> 0  Then;
                            {$I-}  reset (arqfone); {$I+}
                            If Ioresult <> 0  Then;
                            delay (4000);
                            goto formatoAntigo;
                        end;

                    numCampos := 0;
                    repeat
                        if not eof (arqfone) then
                            begin
                                readln (arqFone, x);
                                if x <> '@' then
                                    begin
                                        numCampos := numCampos + 1;
                                        p := pos ('|', x);
                                        if p = 0 then goto formatoAntigo2;
                                        tabTexto [numCampos] := copy (x, 1, p-1);
                                        delete (x, 1, p);
                                        p := pos ('|', x);
                                        tabFala [numCampos] := copy (x, 1, p-1);
                                        delete (x, 1, p);
                                        tabMalaDir [numCampos] := x;
                                    end;
                            end;

                    until eof (arqFone) or (x = '@');
                    if numCampos = 0 then numCampos := 1;
                end;

            while not eof (arqfone) do
                Begin
formatoAntigo:
                    gotoxy (70, 14);
                    write (lidos+1);

                    inc (cadastrados);
                    inc (lidos);
                    novoRegistro (cadastrados);

                    with listaFone [cadastrados]^ do
                        begin
                            status := 0;
                            temDados := false;

                            for qual := 1 to 100 do
                                begin
                                    if eof(arqfone) then goto proximo;
                                    {$I-} readln (arqfone, s); {$I+}
                                    if ioresult <> 0 then
                                        begin
                                            msgBaixo ('TVERRLEI', ''); {'Erro no arquivo, Enter ignora, ESC termina leitura'}
                                            c := readkey;
                                            if c = #$1b then goto
                                                fimDoArquivo;
                                            s := pegaTextoMensagem ('TVERRDIS'); {'Erro no disco'}
                                        end;

                                    if (s <> '') and (s <> '@') then
                                        temDados := true;

                                    if (s <> '') and (s[1] = '@') then
                                        goto proximo;

                                    if (s = '') and (qual = 1) then
                                        s := 'VAZIO';
                                    atualizaItem (qual, cadastrados, s);
                                end;
           proximo:
                            if not temDados then
                                removeRegistro (cadastrados);
                        end;
                end;

fimDoArquivo:
            close (arqfone);

            strPCopy (nomeJan, 'TELEVOX ' + nomeCadastro);
            setWindowText (crtWindow, nomeJan);
            gotoxy (1, 14);
            write ('     ');
            str (cadastrados, s);
            msgBaixo ('TVLIDOS', pegaTextoMensagem ('TVLIDOS') + s);
            falaNumeroConv (numeroParaString (cadastrados), MASCULINO);
        end
    else
        begin
        cadNovo:
            criaArqRapido := upcase(sintAmbiente ('TELEVOX', 'CRIAARQRAPIDO', 'NAO')[1]) = 'S'; //Patrick
            if not criaArqRapido then //Patrick. Falso pergunta se quer criar caderno novo
            begin
                msgBaixo ('TVCNFNOV', ''); {'Tecle S para criar um caderno novo'}
                repeat
                    c := upcase(readkey);
                until not keypressed;
                if (c <> 'S') and (c <> ESC) then
                    begin
                        logotipo;
                        goto inicio;
                    end
                else
                if c = ESC then
                    begin
                        logotipo;
                        gotoxy (1, 14);
                        mensagem ('TVPROCAN', 1); {'Programa cancelado'}
                        clreol;
                        sintFim;
                        doneWinCRT;
                    end;
                end;

            assign (arqfone, nomeCadastro);
            {$I-}  rewrite (arqfone);  {$I+}
            if ioresult = 0 then
                begin
                    inicCamposDefault;

                    {$I-} writeln (arqFone, '@'); {$I+}
                    if ioresult <> 0 then goto erroDisco;
                    for nc := 1 to numCampos do
                        writeln (arqFone, tabTexto[nc],'|',tabFala[nc], '|', tabmaladir[nc]);
                    writeln (arqFone, '@');

                    close (arqfone);
                    msgBaixo ('TVNOVO', '');  {'Foi criado um caderno novo'}
                    editaArqRapido := upcase(sintAmbiente ('TELEVOX', 'EDITAARQRAPIDO', 'NAO')[1]) = 'S'; //Patrick
                    if editaArqRapido then inclui; //Patrick. Verdadeiro aciona a rotina de inclusão de novo registro
                end
            else
                begin
erroDisco:
                    msgBaixo ('TVNOMINV', ''); {'Nome de arquivo novo não foi aceito'}
                    logotipo;
                    goto Inicio;
                end;
        end;

    limpaTela;
    posAtual := 0;
    achados := 0;
end;

{--------------------------------------------------------}
{                  gravacao do arquivo
{--------------------------------------------------------}

Function gravaCadastro (pergunta: boolean): boolean;
var
    nome, dirAtual: string;
    i, n, nc, resulta: integer;
    campo: string;
    c: char;

label achou, errodisco;
begin
    gravaCadastro := true;

    if pergunta then
    repeat
         msgBaixo ('TVSALVSN', ''); {'Aperte S para salvar o que você fez, N para não gravar'}
         c := upcase(readkey);
         if c = 'N' then exit;
         if c = #$1b then
             begin
                 msgBaixo ('TVDESIS', ''); {'Desistiu...'}
                 gravaCadastro := false;
                 exit;
             end;
    until (c = 'S') or (c = ENTER);

    assign (arqfone, nomeCadastro);
    repeat
        {$I-} rewrite (arqfone); {$I+}
        resulta := ioresult;
        if resulta <> 0 then
            begin
erroDisco:
                {$I-} close (arqfone);  {$I+}
                resulta := ioresult;  { limpa eventual erro }

                limpaTela;
                msgBaixo ('TVNGRAV', ''); {'Deu problema na gravação'}

                getdir (0, dirAtual);
                if dirAtual[length(dirAtual)] = '\' then
                    delete (dirAtual, length(dirAtual), 1);

                if dirAgendas <> '' then
                    begin
                        {$I-} chdir (dirAgendas);  {$I+}
                        resulta := ioresult;
                    end;

                mensagem ('TVNOMARQ', 1); {'Qual o nome do arquivo ? '}
                repeat
                    clreol;
                    garanteEspacoTela (10);
                    nome := obtemNomeArq (10);
                until nome <> '';

                if (pos ('\', nome) = 0) and (pos ('/', nome) = 0) then
                    if resulta = 0 then
                        nome := dirAgendas + '\' + nome
                    else
                        nome := dirAtual+ '\' + nome;

                {$I-} chdir (dirAtual);  {$I+}
                if ioresult <> 0 then;

                assign (arqfone, nome);
            end;

    until resulta = 0;

    {$I-} writeln (arqFone, '@'); {$I+}
    if ioresult <> 0 then goto erroDisco;
    for nc := 1 to numCampos do
        writeln (arqFone, tabTexto[nc],'|',tabFala[nc], '|', tabmaladir[nc]);
    {$I-} writeln (arqFone, '@'); {$I+}
    if ioresult <> 0 then goto erroDisco;

    for i := 1 to cadastrados do
        begin
             for nc := numCampos downto 2 do
                  if obtemItem (nc, i) <> '' then
                      goto achou;
             nc := 1;
achou:
             for n := 1 to nc do
                 begin
                     campo := obtemItem (n, i);
                     {$I-}  writeln (arqFone, campo);   {$I+}
                     if ioresult <> 0 then goto erroDisco;
                 end;

             {$I-} writeln (arqFone, '@'); {$I+}
             if ioresult <> 0 then goto erroDisco;
        end;

    {$i-} close (arqfone); {$I+}
    if ioresult <> 0 then goto erroDisco;
    msgBaixo ('TVSALVA', ''); {'Arquivo gravado'}
end;

end.
