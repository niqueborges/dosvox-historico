{--------------------------------------------------------}
{               Televox - impressao de etiquetas
{--------------------------------------------------------}

unit telImpEtq;

interface
Uses
    DVCrt, DVWin, dvForm, sysutils, windows,
    TelVars, TelTela, TelItem, telMsg, telUtil, telIniPr, telAmbie;

procedure imprimeEtiquetas;

implementation
var
    imprimeCampo: array [1..MAXCAMPOS] of boolean;

    etiqNaHorizontal, etiqNaVertical: integer;
    larguraEtiq, alturaEtiq: real;
    margemEsq, margemSup: real;
    fonteEtiq: shortString;
    corpoFonteEtiq: integer;
    alturaFonteMM: real;

{--------------------------------------------------------}
{                  Seleciona os campos
{--------------------------------------------------------}

procedure selecionaCampos;
var c: char;
    qual: integer;
begin
    limpaTela;
    msgBaixo ('TVINFCAM', ''); {'Marque com um x os campos desejados, depois ESC'}

    { usa um elemento nao existente, para trabalho }

    novoRegistro (cadastrados+1);
    posTabFolheia := cadastrados + 1;
    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    c := passeiaNosItens (cadastrados+1, true);
    if c = '' then;

    with listaFone [cadastrados+1]^ do     { transforma em maiusculas }
        begin
            for qual := 1 to numCampos do
                imprimeCampo [qual] := obtemItem (qual, cadastrados+1) <> '';
        end;

    removeRegistro (cadastrados+1);
    limpaTela;
end;

{--------------------------------------------------------}
{         pede as caracteristicas do formulario
{--------------------------------------------------------}

function pedeCaracEtiqueta: boolean;
var c, c2: char;

var
    s: string;

label desist;
begin
    result := true;

    etiqNaHorizontal := pegaIntAmbiente  ('EtiqNaHorizontal', 1);
    etiqNaVertical   := pegaIntAmbiente  ('EtiqNaVertical', 10);
    larguraEtiq      := pegaRealAmbiente ('LarguraEtiq', 66.0);
    alturaEtiq       := pegaRealAmbiente ('AlturaEtiq',  25.4);
    margemEsq        := pegaRealAmbiente ('MargemEsq', 10.0);
    margemSup        := pegaRealAmbiente ('MargemSup', 10.0);
    fonteEtiq        := pegaAmbiente     ('FonteEtiq', 'Arial');
    corpoFonteEtiq   := pegaIntAmbiente  ('CorpoFonteEtiq', 12);

    writeln; writeln;
    mensagem ('TVFRMPAD', 0);  {'Posso usar o formulário padrão? '}
    sintLeTecla (c, c2);
    writeln;

    if upcase(c) = 'S' then
        exit;

    if c = ESC then
        begin
desist:
            msgBaixo ('TVDESIS', 'Desistiu...');
            result := false;
            exit;
        end;

    limpatela;
    mensagem ('TVCNFFRM', 2);      {'Configure o formulário'}

    tamRotulosForm := 40;
    formCria;
    formCampoInt ('TVETQHOR', 'Número de etiquetas na horizontal', etiqNaHorizontal);
    formCampoInt ('TVETQVER', 'Número de etiquetas na vertical', etiqNaVertical);
    formCampoReal('TVLARETQ', 'Largura da etiqueta em mm', larguraEtiq, 2);
    formCampoReal('TVALTETQ', 'Altura da etiqueta em mm', alturaEtiq, 2);
    formCampoReal('TVMRGESQ', 'Margem esquerda em mm', margemEsq, 2);
    formCampoReal('TVMRGDIR', 'Margem superior em mm', margemSup, 2);
    formCampo    ('TVFONTE',  'Fonte (sugiro Arial)', fonteEtiq, 80);
    formCampoInt ('TVCORPOL', 'Corpo da letra (sugiro 12)', corpoFonteEtiq);
    formEdita(true);

    mensagem ('TVASMPAD', 0);     {'Guardo como novo modelo padrão? '}
    sintLeTecla (c, c2);
    writeln;
    writeln;

    c := upcase (c);
    if c = ESC then goto desist;
    if c = 'N' then exit;

    sintGravaAmbiente ('TELEVOX', 'EtiqNaHorizontal', intToStr(etiqNaHorizontal));
    sintGravaAmbiente ('TELEVOX', 'EtiqNaVertical',   intToStr(etiqNaVertical));

    str(larguraEtiq, s);    sintGravaAmbiente ('TELEVOX', 'LarguraEtiq', s);
    str(alturaEtiq:7:2, s); sintGravaAmbiente ('TELEVOX', 'AlturaEtiq',  s);
    str(margemEsq:7:2, s);  sintGravaAmbiente ('TELEVOX', 'MargemEsq',   s);
    str(margemSup:7:2, s);  sintGravaAmbiente ('TELEVOX', 'MargemSup',   s);

    sintGravaAmbiente ('TELEVOX', 'FonteEtiq',      fonteEtiq);
    sintGravaAmbiente ('TELEVOX', 'CorpoFonteEtiq', intToStr(CorpoFonteEtiq));
end;

{--------------------------------------------------------}
{                  calcula posição na página
{--------------------------------------------------------}

procedure calculaPosicaoPag (campoImpr, netiq: integer; var x, y: integer);
var netiqLocal: integer;
begin
    netiqLocal := netiq mod (etiqNaHorizontal * etiqNaVertical);
    x := x_mmParaPtImpressora (
             margemEsq +
             (netiqLocal mod etiqNaHorizontal) * larguraEtiq);

    y := y_mmParaPtImpressora (
             margemSup +
             (netiqLocal div etiqNaHorizontal) * alturaEtiq +
             campoImpr * alturaFonteMM);
end;

{--------------------------------------------------------}
{                    Gera uma etiqueta
{--------------------------------------------------------}

procedure geraEtiqueta (nEtiq, posArq: integer);
var nc: integer;
    s: string;
    campoImpr: integer;
    x, y: integer;
begin
    if (netiq  mod (etiqNaHorizontal * etiqNaVertical)) = 0 then
        iniciaPagImpressora;

    campoImpr := 0;
    for nc := 1 to numCampos do
       if imprimeCampo [nc] then
            begin
                s := trim (obtemItem (nc, posArq));
                calculaPosicaoPag (campoImpr, netiq, x, y);
                campoImpr := campoImpr + 1;
                jogaImpressora (x, y, s);
            end;
end;

{--------------------------------------------------------}
{                   Imprime etiquetas
{--------------------------------------------------------}

procedure imprimeEtiquetas;
var i: integer;
    s: string;
    c, c2: char;
    saltar, etiqsPorPessoa: integer;
    erro: integer;
    netiq, saltadas, posArq: integer;
    tipoImpr: char;
     
label desist;

begin
    limpaTela;

    gotoxy (1, 3);
    clreol;
    textBackGround (BLUE);
    mensagem ('TVIMPETQ', 0);      {'IMPRESSAO DE ETIQUETAS:'}
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

    selecionaCampos;
    if not pedeCaracEtiqueta then
        exit;

    mensagem ('TVETIQPP', 0);    {'Quantas etiquetas por pessoa (sugiro 1)? '}
    sintReadln (s);
    if s = '' then s := '0';
    val (trim(s), etiqsPorPessoa, erro);
    if erro <> 0 then etiqsPorPessoa := 0;

    mensagem ('TVETQSAL', 0);    {'Número de etiquetas a saltar (assumo 0): '}
    sintReadln (s);
    if s = '' then s := '0';
    val (trim(s), saltar, erro);
    if erro <> 0 then saltar := 0;

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

    posArq := 1;
    saltadas := 0;
    netiq := 0;

    if not abreImpressora ('Etiquetas Televox') then
        begin
            msgBaixo ('TVERRABR', 'Erro ao abrir arquivo de impressão');
            exit;
        end;

    criaFonteSimplesImpressora (fonteEtiq, corpoFonteEtiq, alturaFonteMM);

    while posArq <= cadastrados do
        begin
            if (tipoImpr = 'T') or
               ((tipoImpr = 'S') and (
                         (listaFone [posArq]^.status and SELECIONADO) <> 0)) then
               begin
                  if saltadas < saltar then
                      saltadas := saltadas + 1
                  else
                      for i := 1 to etiqsPorPessoa do
                          begin
                              geraEtiqueta (nEtiq, posArq);
                              netiq := netiq + 1;
                          end;
               end;

            posArq := posArq + 1;
        end;

    fechaImpressora;
    msgBaixo ('TVIMPFIM', ''); {'Impressão finalizada'}
end;

end.

