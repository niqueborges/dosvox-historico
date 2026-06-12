{--------------------------------------------------------}
{
{    Programa Editor Vocal
{
{    Autor da versão original: Marcelo Luis Pimentel Pinheiro
{
{    Autor: Neno Albernaz
{
{    Orientador Academico: Jose' Antonio Borges
{
{    Em 10/12/93
{
{    Versao 3.0 de 25/4/96
{    Versao 6.0 em 06/11/2007
{    Versao 7.0 em 25/05/2018
{    Versao 8.0 em 19/07/2020
{
{--------------------------------------------------------}

program Edivox;

uses
  Windows,
  SysUtils,
  Classes,
  dvCrt,
  dvForm,
  dvWin,
  dvWav,
  dvHora,
  dvexec,
  dvAmplia,
  dvstring,
  edVars,
  edUtil,
  edMensag,
  edFala,
  edTela,
  edCursor,
  edAcento,
  edLinha,
  edArq,
  edBloco,
  edBusca,
  edMargem,
  edConfig,
  edTransf,
  edCalcul,
  edDoc,
  edDocUti,
  edMd5,
  edDicion,
  edPagina,
  edEpub,
  edEmbel,
  edDesfaz,
  edBraille,
  edDicvox,
  edDicio,
  edTraduvox,
  edRd50,
  sonoraMat;

{ dicionário }

var
    progAcabou: boolean;
    quebrarLinhasNaAbertura: boolean;     {Quebra as linhas no limite da margem direita após a abertura do arquivo}
    CtrlTTabula: boolean;
    CtrlTXRecorta: boolean;
    limparTempAutomatico: boolean;
    biparLinhaVazia: boolean;
    biparLinhaVaziaSuave: boolean;

function confirmasaida(perguntaSeSai: boolean): boolean; forward;
procedure trataControls (tecla: char; apertouShift: boolean); forward;

{-----------------------------}

procedure inicializa;
var
     s: string;
     erro: integer;
     velGeral, confTipoSapi, confNum, confVeloc, confTonal: integer;
     par: string;
     c: char;

begin
    clrscr;
    texto := TStringList.create;
    texto.append('');

    tamMaxLinha := 79;
    desenhaTelaInicial;
    setWindowText (crtWindow, 'EDIVOX');

    dirSomEdivox := sintAmbiente ('EDIVOX', 'DIREDIVOX');

    s := sintAmbiente ('EDIVOX', 'VELOCIDADE', '0');
    if s = '0' then
        s := sintAmbiente ('TRADUTOR', 'VELOCIDADE', '3');
    val (s, velGeral, erro);
    sintInic (velGeral, DirSomEdivox);

    c := primeiraLetra (sintAmbiente('EDIVOX', 'SAPIATIVADO'));
    if trim(c) = '' then
        begin
            comSapi := uppercase(copy (sintAmbiente ('TRADUTOR', 'SAPI', 'SIM'), 1, 1)) <> 'N';
            if comSapi then
                begin
                    val (sintAmbiente('SERVFALA', 'VOZ'), confNum, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'NUMEROSAPI'), confNum, erro);
                    if erro <> 0 then confNum := 1;

                    val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'TIPOSAPI'), confTipoSapi, erro);
                    if erro <> 0 then confTipoSapi := 3;

                    val (sintAmbiente('SERVFALA', 'VELOCIDADE'), confVeloc, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'VELOCIDADESAPI'), confVeloc, erro);
                    if erro <> 0 then confVeloc:= 0;

                    val (sintAmbiente('SERVFALA', 'TOM'), confTonal, erro);
                    if erro <> 0 then val (sintAmbiente('EDIVOX', 'TONALIDADESAPI'), confTonal, erro);
                    if erro <> 0 then confTonal:= 0;

                    sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
                end;
        end
    else
        begin
            comSapi := upcase(c) = 'S';
            val (sintAmbiente('EDIVOX', 'NUMEROSAPI'), confNum, erro);
            if erro <> 0 then val (sintAmbiente('SERVFALA', 'VOZ'), confNum, erro);
            if erro <> 0 then confNum := 1;

            val (sintAmbiente('EDIVOX', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then confTipoSapi := 3;

            val (sintAmbiente('EDIVOX', 'VELOCIDADESAPI'), confVeloc, erro);
            if erro <> 0 then confVeloc:= 0;
            val (sintAmbiente('EDIVOX', 'TONALIDADESAPI'), confTonal, erro);
            if erro <> 0 then confTonal:= 0;

            sintReinic (velGeral, comSapi, confTipoSapi, confNum, confVeloc, confTonal);
        end;

    checkbreak := false;
    checkFocus := true;
    while keypressed do readkey;

    nomeArq := '';
    somenteLeitura := false;
    if paramCount >= 1 then
        begin
            nomeArq := trim (paramStr(paramCount));
            par := maiuscAnsi (paramStr(1));
            if (par = '/D') or (par = '/L') then
                begin
                    somenteLeitura := true;
                    if par = '/D' then veioDoDos := true;
                    if paramCount = 1 then nomeArq := '';
                end;
        end;

    informaCarga := not somenteLeitura;

    window (57,3, 80,7);
    TextColor (yellow);
    if not somenteLeitura then
        fala ('EDMSGINI') {'EDIVOX - ...}
    else
        write (txtmsg('EDMSGINI'));
    TextColor (WHITE);
    window (1,1,80,25);

    texto.clear;
    val (sintAmbiente('EDIVOX', 'MARGDIR'), margDir, erro);
    if (erro <> 0) or (margDir < 10)   then margDir := 79;
    margEsq := 1;
    ntabs := 0;
    mudo := false;
    s := sintAmbiente ('EDIVOX', 'SOLETRANDO');
    if s = '' then sintGravaAmbiente('EDIVOX', 'SOLETRANDO', 'SIM');
    soletrando := upcase((s+'S')[1]) = 'S';
    s := sintAmbiente ('EDIVOX', 'FALANDOPALAVRA');
    if s = '' then sintGravaAmbiente('EDIVOX', 'FALANDOPALAVRA', 'NAO');
    falandoPalavra := upcase((s+'N')[1]) = 'S';
    rapidinho := false;

    enterInsLinha := copy (sintAmbiente ('EDIVOX', 'ENTERINSLINHA'), 1, 1) = 'S';
    quebraAuto := copy (sintAmbiente ('EDIVOX', 'QUEBRARLINHAS'), 1, 1) <> 'N';
    falaPontuacao := copy (sintAmbiente ('EDIVOX', 'FALARPONTUACAO'), 1, 1) <> 'N';
    falaEspacos := copy (sintAmbiente ('EDIVOX', 'FALAESPACOS'), 1, 1) = 'S';
    biparLinhaVazia := copy (sintAmbiente('EDIVOX', 'BIPARNALINHAVAZIA', 'SIM'), 1, 1) = 'S';
    biparLinhaVaziaSuave := copy (sintAmbiente('EDIVOX', 'BIPARNALINHAVAZIASUAVE', 'NÃO'), 1, 1) = 'S';
    autofala := copy (sintAmbiente ('EDIVOX', 'FALAAUTOMATICA'), 1, 1) = 'S';
    escreveApenasTexto := copy (sintAmbiente ('EDIVOX', 'ESCREVEAPENASTEXTO'), 1, 1) = 'S';
    perguntaAoSair := copy (sintAmbiente ('EDIVOX', 'PERGUNTAAOSAIR', 'SIM'), 1, 1) <> 'N';
    sairMudo := copy (sintAmbiente ('EDIVOX', 'SAIRMUDO', 'NAO'), 1, 1) = 'S';
    quebrarLinhasNaAbertura:= copy (sintAmbiente ('EDIVOX', 'QUEBRARLINHASNAABERTURA', 'NAO'), 1, 1) = 'S';
    CtrlTTabula := copy (sintAmbiente ('EDIVOX', 'CTRL_T_TABULA', 'SIM'), 1, 1) = 'S';
    CtrlTXRecorta := copy (sintAmbiente ('EDIVOX', 'CTRL_X_RECORTA', 'NAO'), 1, 1) = 'S';
    limparTempAutomatico := copy (sintAmbiente ('EDIVOX', 'LIMPARTEMPAUTOMATICO', 'NAO'), 1, 1) = 'S';

    modoFalaFormatacao := upcase(sintAmbiente ('EDIVOX', 'MODOFALAFORMATACAO', 'N')[1]);

    statusTecControle := 0;
    maxlinhas := 0;
    buscado := sintAmbiente ('EDIVOX', 'BUSCADO1');
    formatarBuscado;
    linhaRemovida := '';

    salvaCurx := 1;
    salvaCury := 1;

    deslocEsqTela := 0;
    corLetra := WHITE;
    corFundo := BLACK;
    extPadrao := sintAmbiente ('EDIVOX', 'EXTENSAOPADRAO', 'txt');

    inicBloco;

    if somenteLeitura then
        dicionarioAtivado := false //Para não deixar lenta a abertura do texto no Cartavox
    else
        begin
            s := sintAmbiente ('EDIVOX', 'DICIONARIOATIVADO');
            dicionarioAtivado := maiuscAnsi (copy (s, 1, 1)) <> 'N';
            if dicionarioAtivado then
                begin
                    verificaDicionario (1, 0);
                end;
        end;

    corrigirTodoTexto := copy (sintAmbiente ('EDIVOX', 'CORRIGIRTODOTEXTO', 'NÃO'), 1, 1) = 'S';
    retomarNaLinha := copy (sintAmbiente ('EDIVOX', 'RETOMARNALINHA', 'SIM'), 1, 1) <> 'N';
    iniMarca := 0;
    fimMarca := 0;
    inicializaPaginas;
    inicializaDesfazer;
end;

{--------------------------------------------------------}

procedure abreOutroEditor;
var
    nomeProg: string;
begin
    nomeProg := sintAmbiente ('DOSVOX', 'EDITOR');
    if nomeProg = '' then
        nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\edivox.exe';
    if executaProg (nomeProg, '', '') < 32 then
        fala ('EDNEXEC'); {'Não pude executar'}
end;

{--------------------------------------------------------}

function comandoInterativo ( Var apertouShift, apertouCtrl, apertouAlt: boolean): char;
var c1, c2: char;

label deNovo;

begin
    apertouShift := false;
    apertouCtrl := false;
    apertouAlt := false;
    result := ESC;
    fala ('EDCOMAND');   { comando ? }
    c1 := leTeclaMaiusc(c2);

deNovo:
    escreveTela;

    case c1 of
        'C': cmdCursor;
        'L': cmdLinha;
        'P': cmdBusca;
        'M': cmdMargem;
        'A': cmdArquivo;
        'B': trataBloco (true);
        'F': cmdFala;
        'I': cmdConfig;
        'E': trataLetrasEspeciais;
        'W': tratamentoWord;
        'R': trataRadio;
        'H': result := ajudaOpcDiretas(apertouShift, apertouCtrl, apertouAlt);

        #$0: begin
                c1 := ajuda (c2, 'EDAJIN', 13);
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

procedure trataPFeALT (tecla: char);
var
    salva: integer;
    mantemMarca, saiuDaLinha, apertouShift: boolean;
    apertouCtrl, apertouAlt: boolean;
    jaFalou: boolean;
    sf: string;
    n: integer;
label reprocTecla;
begin
    apertouShift := GetKeyState(VK_SHIFT) < 0;
    apertouAlt := getKeyState (VK_MENU) < 0;
    apertouCtrl := GetKeyState(VK_CONTROL) < 0;
reprocTecla:
    jaFalou := false;
    mantemMarca := apertouShift or
           (tecla = DEL) or (tecla = SHIFTINS) or (tecla = CTLINS);
    saiuDaLinha := (tecla in [ALTF1, F3, F5, CTLF5, F6, CTLF6,
                    F7, CTLF7, F9, F10,
                    CTLPGUP, CTLPGDN, CIMA, BAIX, PGUP, PGDN ,CTLHOME, CTLEND ,CTLUP, CTLDOWN]);

    if saiuDaLinha then
        amplEsconde;

    if (not mantemMarca) or saiuDaLinha then
        begin
            iniMarca := 0;
            fimMarca := 0;
        end
    else
        begin
            if iniMarca <= 0 then
                iniMarca := posx;
        end;

    Case tecla of
        F1:      if not apertouAlt then
                     begin
                         falaPalavra;
                         if dicionarioAtivado then verificaPalavraAntes (false);
                     end
                 else
                    begin
                        tecla := ALTF1;
                        goto reprocTecla;
                    end;

        #33:     insereFormatacao;                 // Alt+F
        #34:     chamaTratamentoWord ('');         // Alt+G
        #31:     begin                             // Alt+S
                         chamaTratamentoWord ('/W');
                         sairMudo := true;
                         terminaPrograma (true);
                  end;

        #32:     chamaTratamentoWord ('/G');       // Alt+D
        #25:     chamaTratamentoWord ('/I');       // Alt+P
        #23:     falaFormatacaoAtual;              // Alt+I
        #50:     cmdmodoFalaFormatacao;            // Alt+M
        #24:     ocultarFormatacaoTela;            // Alt+O
        #21, 'Y':trataTraduvox (not apertouShift); // Alt+Y
        #35:     if lendoMat then sonoraMat.fechaSintMat
                 else sonoramat.abreSintMat;       // Alt+H
        #45:     gravaETermina;                    // Alt+X
        #48:     trocaModoSoletrar;                // Alt+B
        CTLF1:   falaRestoLinha (apertouShift);
        ALTF1:   begin
                         falaRestoTexto (apertouShift);
                         iniMarca := 0;
                         fimMarca := 0;
                  end;

        F2:      if not apertouAlt then
                     salvaArquivo (1, maxlinhas, true, apertouShift)
                 else // Alt+F2
                     memorizaLinha;

        CTLF2:   salvaComo (apertouShift);
        F3:      if not apertouAlt then
                     begin
                         trocaarquivo;
                         inicBloco;
                         escreveTela;
                     end
                 else // Alt+F3
                     posicionaNaLinhaMemorizada;

        CTLF3:   abreOutroEditor;
        F4:      if not apertouAlt then
                     acionaSoletragem
                 else
                     progAcabou := somenteLeitura or confirmasaida(false);

        CTLF4:   if apertouShift then trocaModoFalaNaDigitacao
                 else formConfig;

        F5:      if apertouAlt then buscaDeNovo (apertouShift, true)
                 else buscaPalavra (apertouShift);
        CTLF5:   buscaDeNovo (apertouShift, false);
        F6:      if apertouAlt then FalarQuantidadeTextos (apertouShift)
                 else trocaPalavra (false);
        CTLF6: if apertouShift then trocaPalavra (true)
                 else if copy(texto[posy], length(texto[posy]), 1) = '=' then conversaoInterativa
                 else calcula;

        F7:      RemoveApenasUmaLinha;
        CTLF7:   trocaTamTela;
        F8:      falaHora;
        CTLF8:   falaDia;

        F9, #30: // #30 é a combinação Alt+a.
            if (tecla = F9) and apertouShift then limpaTexto (false, false, false)
            else
                 begin
                     tecla := comandoInterativo (apertouShift, apertouCtrl, apertouAlt);
                     if (tecla < ' ') and (tecla <> ESC) and (not apertouAlt)  then trataControls (tecla, apertouShift)
                     else
                     if tecla <> ESC then goto reprocTecla;
                 end;

        CTLF9:   limpaTexto (not apertouShift, true, false);
        F10:     pedeMargens;
        F11:     ativaDicionario (false, apertouShift);
        F12:     executaPalavra (apertouShift);
        CTLF12:  falaVersao;
        CTLHOME: begin
                     if apertouShift then selecionarBloco  (1, posy, false);
                     inicioTexto;
                 end;

        CTLEND:  begin
                     if apertouShift then selecionarBloco  (posy, maxLinhas, false);
                     fimTexto;
                 end;

        CTLPGUP: vaiParaPagina (-1, apertouShift);
        CTLPGDN: vaiParaPagina (1, apertouShift);

        CTLDIR:  begin
                     salva := posx;
                     palavraDir (true);
                     n := posx-salva;
                     sf := copy (texto[posy], salva, n);
                     if trim (sf) = '' then
                         sintclek
                     else
                         sintetiza (sf);
                     if dicionarioAtivado then verificaPalavraAntes (false);
                 end;

        CTLESQ:  begin
                     salva := posx;
                     palavraEsq (true);
                     n := salva-posx;
                     sf := copy (texto[posy], posx, n);
                     if trim (sf) = '' then
                         sintclek
                     else
                         sintetiza (sf);
                     if dicionarioAtivado then verificaPalavraAntes (true);
                 end;

        CTLUP:   setaVertCima (apertouShift);
        CTLDOWN: setaVertBaixo (apertouShift);
        INS:     acionaInsert;
        DEL:     if apertouCtrl then
                     begin
                         if apertouShift then
                             removeBloco
                         else
                             RemoveApenasUmaLinha;
                     end
                 else
                 if (iniMarca > 0) and (fimMarca > 0) then
                     removeAreaMarcada
                 else
                 If posx > length ( texto[posy]) then
                     juntaLinhas
                 Else
                     begin
                         gravarDesfazer;
                         removeProxLetra (true, true);
                     end;

        DIR:     setaDir;
        ESQ:     setaEsq;

        CIMA:    if (statusTecControle and CONTROL) <> 0 then
                     SetaVertCima (apertouShift)
                 else
                     jaFalou := SetaCima (apertouShift);

        BAIX:    if (statusTecControle and CONTROL) <> 0 then
                     SetaVertBaixo (apertouShift)
                 else
                 if apertouAlt then // Alt+Baixo
                    begin
                        tecla := ALTF1;
                        goto reprocTecla;
                    end
                 else
                     jaFalou := Setabaixo (apertouShift);

        HOME:    coluna1;
        TEND:    ultimaColuna;
        PGUP:    voltaPag (apertouShift);
        PGDN:    pulaPag (apertouShift);
        CTLINS:  jogaAreaTransf (false);
        SHIFTINS:pegaAreaTransf (false);

        #129:     selFala('N');   // Alt+0
        #120:    selFala('1');   // Alt+1
        #121:    selFala('2');   // Alt+2
        #122:    selFala('3');   // Alt+3
        #123:    selFala('4');   // Alt+4
        #124:    selFala('5');   // Alt+5
        #125:    selFala('6');   // Alt+6
        #126:    selFala('7');   // Alt+7
        #127:    selFala('8');   // Alt+8
        #128:    selFala('9');   // Alt+9

    else    { of case }
        sintBip;
        sintBip;
    end;

    if apertouShift then
        fimMarca := posx;

    if tecla in [CTLF1, ALTF1, F3, F5, CTLF5, F6, F7, F9, F10, F12,
             CTLPGUP, CTLPGDN, CTLDIR, CTLESQ, CTLHOME, CTLEND,
             CIMA, BAIX, PGUP, PGDN, DEL, CTLDOWN, CTLUP,
             SHIFTINS] then
        escreveTela
    else
        escreveLinha;

    if autoFala and (not jaFalou) then
        begin
            salva := posx;
            if tecla in [CIMA,BAIX, PGUP, PGDN, CTLPGUP, CTLPGDN,
                         CTLHOME, CTLEND, F3] then
                begin
                    if (pos(#9, texto[posy]) = 0) and (length (trim(texto[posy])) = 0) and (pos(#$0C, texto[posy]) = 0) then
                        begin
                            if (not keypressed) and (biparLinhaVazia) then
                                if not biparLinhaVaziaSuave then
                                    sintBip
                                else
                                    sintclek;
                        end
                    else
                        sintTextoFormatado (texto[posy]);
                end
            else
                if (tecla in [F5, CTLF5, F6]) and (not ((tecla = F6) and apertouAlt)) then
                    falaRestoLinha (false);

            posx := salva;
        end;
end;

{--------------------------------------------------------}

function criaLinhaNaMargem: string;
var s: string;
    i: integer;
begin
    s := '';
    for i := 1 to margEsq-1 do
        s := s + ' ';

    sintClek;
    if margEsq > 1 then
        sintClek;

    criaLinhaNaMargem := s;
end;

{--------------------------------------------------------}

procedure proxLinhaNaMargem;
var salva: string;

begin
    gravarDesfazer;
    setaBaixo (false);
    salva := texto[posy];
    while length (salva) < margEsq do
        salva := salva + ' ';
    texto[posy] := salva;
    posx := margEsq;
end;

{--------------------------------------------------------}

procedure trataControls (tecla: char; apertouShift: boolean);

    procedure tratamentoCtrlShiftT;
    begin
        if CtrlTTabula and apertouShift then
            selecionarBloco  (1, maxLinhas, false)
        else
        if CtrlTTabula and (not apertouShift) then
            tabula
        else
        if apertouShift then
            tabula
        else
            selecionarBloco  (1, maxLinhas, false);
    end;

    procedure tratamentoCtrlX;
    begin
        if not CtrlTXRecorta then
        gravaETermina
        else
        begin
            jogaAreaTransf (false);
            removeBloco;
        end;
    end;

begin
    if (tecla <> ^c) and (tecla <> ^v) then
        begin
            iniMarca := 0;
            fimMarca := 0;
        end;

    case tecla of
        ^A:      avancaParag (false,apertouShift);
        ^R:      recuaParag (false, apertouShift);
        ^n:      informaNomeArq (false, apertouShift);
        ^y:      if apertouShift then voltaRemovida
                 else removeApenasUmaLinha;

        ^d:      if apertouShift then trataDicvox
                 else apagaFimlinha;

        ^s:      apagaInicioLinha;
        ^q:      quebralinha;
        ^j:      if apertouShift then
                    trataPFeALT (#30)
                 else
                     begin {Ctrl+Enter}
                         gravarDesfazer;
                         insereLinha (criaLinhaNaMargem, true);
                     end;

        ^m:      {tratamento de enter}
                 if apertouShift then falaBlocoSelecionado
                 else
                     begin
                         if dicionarioAtivado then verificaPalavraAntes (false);
                         if falandoPalavra then falaPalavraAntes;
                         if enterInsLinha or (posy = maxLinhas) then
                             insereProxLinha (criaLinhaNaMargem, true)
                         else
                             proxLinhaNaMargem;
                     end;

        ^I:      tabulaInsere (apertouShift);
        ^T:      tratamentoCtrlShiftT;
        ^H:      begin
                     gravarDesfazer;
                     removeLetra (true, true);
                 end;

        ^b:      if apertouShift then informaBloco
                 else trataBloco (false);

        ^l:      if apertouShift then falaNumeroPagina (true, false)
                 else informaLinha (posy, maxLinhas, true);

        ^k:      informaColuna;
        ^u:      if apertouShift then acharPalavraAnteriorErrada
                 else acharProximaPalavraErrada;

        ^e:      trataLetrasEspeciais;
        ^x:      tratamentoCtrlX;
        ^g:      if apertouShift then vaiParaPagina (0, false)
                 else posicEmLinha;

        ^f:      falaAtePonto (apertouShift);
        ^c:     if apertouShift then falaAreaTransf
                 else jogaAreaTransf (true);

        ^v:      pegaAreaTransf (true);
        ^\:      sintTelefona (texto[posy]);

        ^O:      if apertouShift then
                     trataDicio
                 else
                     begin
                         falaEspacos := not falaEspacos;
                         sintbip;
                     end;

        ^p:      if apertouShift then blocoParagrafo
                 else imprime;

        ^w:      if apertouShift then MostrarPalavrasRepetidas
                 else trocaPalavraDic;

        ^Z:      if apertouShift then recuperarRefazer
                 else recuperarDesfazer;

        CTLBS:   apagaPalavra;

    else         { case }

        sintBip;   { teclas invalidas dao dois bips }
        sintBip;
    end;

    escreveTela;
    if tecla in [^A, ^R] then
        sintTextoFormatado (texto[posy]);
end;

{--------------------------------------------------------}

function confirmasaida(perguntaSeSai: boolean): boolean;
var
    resp: char;
begin
    confirmaSaida := true;

    if perguntaSeSai and perguntaAoSair then
    begin
        repeat
            fala ('EDCNFSAI');     {--- confirma saida ---}
            resp := popupMenuPorLetra('SN');
        until resp in ['S','N', ESC];

        if resp in ['N', ESC] then
            begin
                confirmaSaida := false;
                fala ('EDDESIST');
                exit;
            end;
    end;

    if md5DoArquivo = calculaMd5 then
        exit;

    repeat                     {--- ve se quer salvar o arquivo ---}
        fala ('EDQUERSV');
        resp := popupMenuPorLetra ('SN');
    until resp in ['S', 'N', ESC];

    if resp = ESC then
        begin
            confirmaSaida := false;
            fala ('EDDESIST');
            exit;
        end;

    if resp = 'S' then
        result := salvaArquivo (1, maxLinhas, false, false);
end;

{--------------------------------------------------------}

var
    tecla, tecla2: char;
    ultimoTitulo: array [0..80] of char;
    dummy: integer;

begin
    inicializa;
    amplPegaConfig(fatorAmpl, dummy, dummy, dummy);

    if not abreArquivo then
        terminaPrograma (false);

    if length(texto[1]) > 200000 then
        quebrarLinhasBloco (1, maxlinhas, false)
    else
    if quebrarLinhasNaAbertura then
        quebrarLinhasBloco (1, maxlinhas, false);

    escreveTela;
    getWindowText (getFocus, ultimoTitulo, 80);

    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    checkBreak := false;

    posx := 1;
    progAcabou := false;

    if (not somenteLeitura) and autoFala then
        begin
            sintTextoFormatado (texto[posy]);
            posx := 1;
        end
    else
        begin
            if somenteLeitura and limparTempAutomatico and ((ansiUpperCase(extractFileExt(nomeArq)) = '.TMP') or (extractFileExt(nomeArq) = '.$')) then
                limpaTexto (true, false, true);
            falaRestoTexto (false);
        end;

    repeat
        gotoxy (posx-deslocEsqTela, 15);
        forceCursor;
        amplCampo(texto[posy], posx);

        while not keypressed do
            begin
                waitMessage;
                if not keypressed then
                    if getForegroundWindow = crtWindow then
                        begin
                            trataStatusTec (statusTecControle);
                            gotoxy (posx-deslocEsqTela, 15);
                        end;
            end;

        tecla := readkey;
        if comSapi then sintPara;
        unforceCursor;

        tecla2 := #0;
        if tecla = #0 then
            begin
                tecla2 := readkey;
                if tecla2 in [#16..#18] then
                    tecla := readkey; {ALT-GR q,w,e}
            end;

        case tecla of
            GOTFOCUS, NOFOCUS: ;
            #0:          trataPFeALT (tecla2);
            #27:         begin
                              amplEsconde;
                              progAcabou := somenteLeitura or confirmasaida(true);
                          end;
            #1..#26,
            #28..#31,
            #127:        trataControls (tecla, GetKeyState(VK_SHIFT) < 0);
        else
            if tecla in [' ', '.', ',', ';', '?', '!', ':',
                         '@', '#', '$', '%', '¨', '¡', '&', '*', '(', ')',
                         'ª', 'º', '°', '_', '=', '+', '\', '|', '<', '>', '/'] then
                begin
                    if dicionarioAtivado then verificaPalavraAntes (false);
                    if falandoPalavra then falaPalavraAntes;
                end;

            iniMarca := 0;
            fimMarca := 0;

            gravarDesfazer;
            insereLetra (tecla);
        End;

    Until progAcabou;
    terminaPrograma (true);
end.
