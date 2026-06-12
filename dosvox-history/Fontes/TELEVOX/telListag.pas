{--------------------------------------------------------}
{               Televox - rotinas de impressao
{--------------------------------------------------------}

unit telListag;

interface
Uses
    DVCrt, DVWin, dvForm, sysutils, windows,
    TelVars, TelTela, TelItem, telMsg, telUtil, telIniPr, telAmbie;

procedure ImprimeListagem;

implementation

uses Types;
var
    xcampo, larguraCampo: array [1..MAXCAMPOS] of integer;
    tipoImpr: char;
    largMediaLetras: integer;

{--------------------------------------------------------}
{       Seleciona os tamanhos dos campos a imprimir
{--------------------------------------------------------}

procedure configuraFormulario;
var
    nr: integer;
    qual: integer;
    largCampo: integer;
    erro: integer;
label deNovo;
begin
    limpaTela;

    mensagem ('TVCARFRM', 2); {'Configuração do formulário'}

    mensagem ('TVTAMCMP', 1); {'Informe o número esperado de letras de cada campo'}
    mensagem ('TVDEIXBR', 1); {'Deixe em branco os campos que não vai imprimir'}
    mensagem ('TVAJUNEG', 1); {'Use números negativos para alinhamento pela direita'}
    mensagem ('TVESCCNC', 1); {'Aperte ESC para concluir'}

    { usa um elemento nao existente, para trabalho }

    novoRegistro (cadastrados+1);
    with listaFone [cadastrados+1]^ do     { transforma em maiusculas }
        begin
            for qual := 1 to numCampos do
                begin
                    largCampo := 0;
                    for nr := 1 to cadastrados do
                         if largCampo < length(obtemItem(qual, nr)) then
                             largCampo := length(obtemItem(qual, nr));
                    if largCampo = 0 then
                        atualizaItem (qual, cadastrados+1, '')
                    else
                        atualizaItem (qual, cadastrados+1, intToStr(largCampo));
                end;
        end;

deNovo:
    posTabFolheia := cadastrados + 1;
    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    passeiaNosItens (cadastrados+1, true);

    with listaFone [cadastrados+1]^ do     { transforma em maiusculas }
        for qual := 1 to numCampos do
            begin
                if obtemItem(qual, cadastrados+1) = '' then
                    larguraCampo[qual] := 0
                else
                    begin
                        val (trim(obtemItem(qual, cadastrados+1)), larguraCampo[qual], erro);
                        if erro <> 0 then
                            begin
                                 msgBaixo ('TVERRFRM', ''); {'Houve erro no preenchimento do formulário'}
                                 goto deNovo;
                            end;
                    end;
            end;

    removeRegistro (cadastrados+1);
    limpaTela;
end;

{--------------------------------------------------------}
{                escolha da fonte
{--------------------------------------------------------}

procedure escolheFonte (var nomeFonte: string; var corpoFonte: integer;
                        var dyLinha, nlinPag: integer);
var
    i, l: integer;
    erro: integer;
    dximpr, dxlinha: integer;
    alturaFonteMM, espac: real;
    s: string;
    DC: HDC;
    fnt: HFont;
    extent: TSIZE;

begin
    mensagem ('TVESCFNT', 0);  {'Escolha com as setas a fonte desejada: '}

    popupMenuCria(wherex, wherey, 15, 4, RED);
    popupMenuAdiciona('TVCOURIE', 'Courier New');
    popupMenuAdiciona('TVARIAL',  'Arial');
    popupMenuAdiciona('TVTIMES',  'Times New Roman');
    popupMenuAdiciona('TVVERDAN', 'Verdana');
    popupMenuSeleciona;
    nomeFonte := opcoesItemSelecionado;
    writeln (nomeFonte);

    mensagem ('TVCORPFN', 0);    {'Corpo da fonte (sugiro 12): '}
    sintReadInt (corpoFonte);
    if (corpoFonte <= 0) or (corpoFonte > 20) then
        corpoFonte := 12;

    s := 'OOOO';  { 4 espaços na margem esquerda, 2 entre campos }
    for i := 1 to numCampos do
        begin
            if larguraCampo[i] <> 0 then
                begin
                    for l := 1 to abs(larguraCampo[i])+1 do s := s + 'O';
                    s := s + 'OO';
                end;
        end;

    DC := criaDCImpr;
    fnt := criaFonteSimples (DC, nomeFonte, corpoFonte, 400, alturaFonteMM);
    SelectObject (DC, fnt);
    dxImpr := getDeviceCaps (DC, HORZRES);
    GetTextExtentPoint32 (DC, @s[1], length(s), extent);
    dxLinha := extent.cx;
    dyLinha := extent.cy;
    largMediaLetras := dxLinha div length(s);

    if dxLinha > dxImpr then
         begin
             mensagem ('TVLINGRD', 1);  {'A fonte escolhida extrapola o tamanho da página'}
             mensagem ('TVESCNTM', 0);  {'Escolha um corpo menor, sugiro '}
             sintWriteInt (trunc (corpoFonte * (dxImpr / dxLinha)));
             write (': ');
             sintReadInt (corpoFonte);
             writeln;
         end;

    mensagem ('TVESPACJ', 0);   {'Escolha o espacejamento: 1, 1.5 ou 2): }
    sintReadln (s);
    val (s, espac, erro);
    if erro <> 0 then espac := 1.0;

    dyLinha := trunc(dyLinha * espac);
    nlinPag := GetDeviceCaps(DC, VERTRES) div dyLinha;

    deleteDC (DC);
    DeleteObject(fnt);
end;

{--------------------------------------------------------}
{       calcula as posições de cada campo na linha
{--------------------------------------------------------}

procedure calculaPosCampos;
var i: integer;
    acum: integer;
begin
    acum := largMediaLetras * 4;
    for i := 1 to numCampos do
        begin
             xCampo[i] := acum;
             acum := acum + (larguraCampo[i]+2) * largMediaLetras;
        end;
end;

{--------------------------------------------------------}
{                   Imprime listagem
{--------------------------------------------------------}

procedure imprimeListagem;
var
    c, c2: char;
    posArq: integer;
    nomeFonte: string;
    corpoFonte: integer;
    alturaFonteMM: real;
    dyImpr, nlPag: integer;
    titulo: string;
    linhaAtual, npag: integer;
    i: integer;

label desist;

        procedure imprimeCabecalho (titulo: string; npag: integer; var linhaAtual: integer);
        var i: integer;
        begin
            iniciaPagImpressora;
            selectObject (DCImpr, fonteNeg);

            linhaAtual := linhaAtual + 2;
            jogaImpressora (xCampo[1], dyImpr*linhaAtual, titulo + '      pag. ' + intToStr(npag));
            linhaAtual := linhaAtual + 2;

            for i := 1 to numCampos do
                if larguraCampo[i] <> 0 then
                     jogaImpressora (xCampo[i], dyImpr*linhaAtual, tabTexto[i]);
            linhaAtual := linhaAtual + 1;

            selectObject (DCImpr, fonte);
        end;

begin
    limpaTela;

    gotoxy (1, 3);
    clreol;
    textBackGround (BLUE);
    mensagem ('TVLISTAG', 0);      {'LISTAGEM:'}
    textBackground (BLACK);

    {--- pergunta se e' para todos ---}

    writeln;
    writeln;
    mensagem ('TVTODSEL', 0); {'Tecle T para todos ou S para os selecionados: '}

    sintLeTecla(c, c2);
    c := upcase (c);
    if (c = ESC) then exit;

    if not (c in ['T','S']) then
        begin
            msgBaixo ('TVOPINV', ''); {'Operação inválida'}
            exit;
        end;

    tipoImpr := c;

    configuraFormulario;
    escolheFonte (nomeFonte, corpoFonte, dyImpr, nlPag);

    mensagem ('TVINFTIT', 1);   {'Informe o título a imprimir'}
    sintReadln (titulo);

    writeln;
    mensagem ('TVENTIMP', 1);    {'Tecle Enter para iniciar a impressão, Esc cancela'}
    repeat
        c := readkey;
        if c = #0 then c := readkey;
    until c in [ENTER, ESC];

    if c = ESC then
        begin
            msgBaixo ('TVCANC', 'Operação Cancelada');
            exit;
        end;

    msgBaixo ('TVINIIMP', ''); {'Iniciando impressão'}

    if not abreImpressora ('Listagem Televox') then
        begin
            msgBaixo ('TVERRABR', 'Erro ao abrir arquivo de impressão');
            exit;
        end;

    criaFonteSimplesImpressora (nomeFonte, corpoFonte, alturaFonteMM);
    calculaPosCampos;

    posArq := 1;
    linhaAtual := 0;
    npag := 0;
    while posArq <= cadastrados do
        begin
            if (tipoImpr = 'T') or
               ((tipoImpr = 'S') and (
                         (listaFone [posArq]^.status and SELECIONADO) <> 0)) then
               begin
                   if linhaAtual = 0 then
                        begin
                            npag := npag + 1;
                            imprimeCabecalho (titulo, npag, linhaAtual);
                        end;

                   for i := 1 to numCampos do
                       if larguraCampo[i] <> 0 then
                           jogaImpressora(xCampo[i], dyImpr*linhaAtual, obtemItem(i, posArq));

                   linhaAtual := linhaAtual + 1;
                   if linhaAtual >= nlPag then
                       linhaAtual := 0;
               end;

            posArq := posArq + 1;
        end;

    fechaImpressora;
    msgBaixo ('TVIMPFIM', ''); {'Impressão finalizada'}
end;

end.

