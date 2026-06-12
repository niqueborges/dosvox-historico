{-------------------------------------------------------------}
{
{    Webvox - Módulo de leitura interativa
{
{    Autores: Jose' Antonio Borges e Bernard Condorcet
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webleit;
interface

uses windows, sysutils, classes, shellApi,
     dvcrt, dvWin, winsock, dvexec, videoVox, dvform, dvarq, dvHora,
     webVars, webConf, webTraz, webMsg, webComp, webCabec,
     webUrl, webMail, webUtil, webGrava;

procedure lerPagina (var voltando: boolean);

implementation

var
    cmd, sentenca: string;
    centrando: integer;
    emTabela: boolean;
    paginaATrazer: string;
    coluna: integer;
    nt: integer;
    emBold, emItalico, emRefer: boolean;
    nomeRef: string;
    passoAPasso: boolean;
    lido1, lido2: char;
    preLido: boolean;
    alteraModo: boolean;

procedure linkAnterior (var nt: integer);   forward;

{-------------------------------------------------------------}
{            extrai um comando de um tag da pagina
{    Esta rotina retorna as variaveis globais cmd e sentenca
{-------------------------------------------------------------}

procedure extraiCmd (nt: integer);
var p: integer;
begin
    if nt > ntags then
        begin
            cmd := '</HTML>';
            sentenca := '';
            exit;
        end;

    p := pos ('|', tagsPagina^[nt]);
    cmd := copy (tagsPagina^[nt], 1, p-1);
    sentenca := copy (tagsPagina^[nt], p+1, length(tagsPagina^[nt])-p);
end;

{-------------------------------------------------------------}
{      extrai (e remove) o primeiro parâmetro da sentença
{-------------------------------------------------------------}

function extraiSentenca: string;
var p: integer;
begin
    p := pos (#$D, sentenca);
    if p > 0 then
       delete (sentenca, p, 999);
    paginaQueFoiAberta := sentenca;
    p := pos ('|', sentenca);
    if p > 0 then
         begin
             extraiSentenca := copy (sentenca, 1, p-1);
             delete (sentenca, 1, p);
         end
    else
        begin
            extraiSentenca := sentenca;
            sentenca := '';
        end;
end;

{-------------------------------------------------------------}
{       extrai um comando de um tag do formulario editado
{    Esta rotina retorna as variaveis globais cmd e sentenca
{-------------------------------------------------------------}

procedure extraiCmdForm (ntForm: integer);
var p: integer;
begin
    p := pos ('|', tagsForms^[ntForm]);
    cmd := copy (tagsForms^[ntForm], 1, p-1);
    sentenca := copy (tagsForms^[ntForm], p+1, length(tagsForms^[ntForm])-p);
end;

{-------------------------------------------------------------}
{                    da saída numa linha
{-------------------------------------------------------------}

procedure sailinha (s: string);
var s2, s3: string;
    i, nbr: integer;

begin
    if emItalico then
        textColor (CYAN)
    else
    if emBold then
        textColor (YELLOW)
    else
    if emRefer then
        textColor (GREEN)
    else
        textColor (LIGHTGRAY);

    if (centrando > 0) and (wherex = 1) then
        begin
            while (s <> '') and (s[1] = ' ') do
                    delete (s, 1, 1);
                nbr := (72 - length (s)) div 2;
                for i := 1 to nbr do
                     s := ' ' + s;

            write (s);
            textColor (LIGHTGRAY);
            if not keypressed then
                 sintetiza (s);
            exit;
        end;

    while (s <> '') and (s[1] = ' ') do
        delete (s, 1, 1);
    if wherex <> 1 then
        s := ' ' + s;

    s2 := '';
    s3 := s;
    while s <> '' do
        begin
            repeat
                 s2 := s2 + s[1];
                 delete (s, 1, 1);
            until (s = '') or (s2 [length(s2)] = ' ');

            if wherex + length (s2) > 79 then
                 begin
                     writeln;
                     if (s2 <> '') and (s2[1] = ' ') then delete (s2, 1, 1);
                 end;

            write (s2);
            s2 := '';

            while (s <> '') and (s[1] = ' ') do
                delete (s, 1, 1);
        end;

    textColor (LIGHTGRAY);
    if not keypressed then
        begin
            for i := 1 to length (s3) do
                if s3[i] = #9 then s3[i] := ' ';

            sintetiza (s3);
        end;
end;

{-------------------------------------------------------------}
{      desmarca outros botoes de radio com mesmo nome
{-------------------------------------------------------------}

procedure marcaRadio (nt: integer; nome: string);
var
    ponteiro, tipo: string;
    i, erro, indPreenc: integer;
label ok1, ok2;

    procedure desmarcaInput;
    begin
        if cmd = 'INPUT' then
            begin
                ponteiro  := extraiSentenca;
                val (ponteiro, indPreenc, erro);
                tipo      := extraiSentenca;
                if tipo = 'RADIO' then
                    if extraiSentenca = nome then
                        tagsForms^[indPreenc+1][8] := 'N';
            end;
    end;

begin
    for i := nt-1 downto 1 do
        begin
            extraiCmd (i);
            if cmd = 'FORM' then goto ok1;
            desmarcaInput;
        end;

ok1:
    for i := nt+1 to nTags do
        begin
            extraiCmd (i);
            if cmd = '/FORM' then goto ok2;
            desmarcaInput;
        end;

ok2:
    extraiCmd (nt);
    ponteiro  := extraiSentenca;
    val (ponteiro, indPreenc, erro);

    tagsForms^[indPreenc+1][8] := 'S';
end;

{-------------------------------------------------------------}
{                   trata o comando INPUT
{-------------------------------------------------------------}

procedure trataInput;
var ponteiro, tipo, nome, valor, tamanho, tamVisual,
    nomRef, valorDefault: string;
    ativado: boolean;
    tam, tamVisu, erro, i, indPreenc: integer;
    salvaCor: word;
    salva, inicForm: integer;
begin
    passoAPasso := true;
    ponteiro  := extraiSentenca;
    val (ponteiro, indPreenc, erro);

    tipo      := extraiSentenca;
    nome      := extraiSentenca;
    tamanho   := extraiSentenca;
    val (tamanho, tam, i);
    tamVisual := extraiSentenca;
    val (tamVisual, tamVisu, i);
    if tamVisu >= 80 then tamVisu := 79;
    nomRef    := extraiSentenca;

    valorDefault := copy (tagsForms^[indPreenc+1], 10, 9999);

    ativado := copy (tagsForms^[indPreenc+1], 8, 1) = 'S';
    valor := copy (tagsForms^[indPreenc+1], 10, 9999);

    if wherex <> 1 then
        writeln;

    if tipo = 'RESET' then
        begin
            if valor <> '' then sintWriteln (valor);
            textBackground (RED);
            mensagem ('WBINRSET', 0);   {'Botão para limpar formulario, aperte 'S' para limpar'}
            textBackground (BLACK);
            sintLeTecla (lido1, lido2);
            writeln;

            if (lido1 = #0) then
                begin
                    prelido := true;
                    exit;
                end;

            if upcase (lido1) <> 'S' then
                begin
                    prelido := true;
                    if upcase(lido1) in [TAB, 'A'..'Z'] then
                        lido1 := ' ';
                    exit;
                end;

            while (nt > 1) and (copy (tagsPagina^[nt], 1, 4) <> 'FORM') do
                nt := nt - 1;
            inicForm := nt;

            while (nt <= ntags) and (copy (tagsPagina^[nt], 1, 5) <> '/FORM') do
                begin
                    extraiCmd (nt);
                    if (cmd = 'INPUT2') or (cmd = 'TEXTAREA2') then
                        begin
                            ponteiro  := extraiSentenca;
                            val (ponteiro, indPreenc, erro);
                            tagsForms^[indPreenc] := '';

                            sentenca := cmd + '|' + sentenca;
                            tagsForms^[indPreenc] := sentenca;
                        end;
                    nt := nt + 1;
                end;

            nt := inicForm;
            mensagem ('WBRESTAD', 1);  {'Formulário recriado'}
        end

    else
    if tipo = 'HIDDEN' then
        prelido := true    {nada faz}

    else
    if (tipo = 'TEXT') or (tipo = 'FILE') then
        begin
            textBackground (RED);
            if tipo = 'TEXT' then
                mensagem ('WBINTEXT', 0)     {'Campo de entrada, pode editar, valor atual'}
            else
                mensagem ('WBINFILE', 0);    {'Campo de entrada, informe o nome do arquivo'}
            textBackground (BLACK);
            writeln;

            if valor = '' then
                begin
                   sintClek; sintClek;
                end;

            write (copy (valor, 1, tamVisu));
            if not keypressed then
                sintetiza (valor);
            gotoxy (1, wherey);

            if tipo = 'TEXT' then
                lido2 := sintEditaCampo (valor, 1, wherey, tam, 79, true)  // tamVisu
            else
                begin
                   garanteEspacoTela (10);
                   valor := obtemNomeArq (10);
                   lido2 := ENTER;
                   if valor = '' then lido2 := ESC;
                   write (valor);
                end;

            writeln;
            if lido2 <> ESC then
                begin
                    valor := copy (tagsForms^[indPreenc+1], 1, 9) + valor;
                    tagsForms^[indPreenc+1] := valor;
                end;

            prelido := true;
            lido1 := #$0;
            if (lido2 = TAB) or (lido2 = ENTER) or (lido2 = ESC) then
                lido1 := ' ';
        end

    else
    if tipo = 'PASSWORD' then
        begin
            textBackground (RED);
            mensagem ('WBINPASS', 0);     {'Campo de senha, pode digitar'}
            textBackground (BLACK);
            writeln;

            salvaCor := textAttr;
            textColor (black);
            lido2 := editaSenha (valor);
            textAttr := salvaCor;

            if lido2 <> ESC then
                begin
                    valor := copy (tagsForms^[indPreenc+1], 1, 9) + valor;
                    tagsForms^[indPreenc+1] := valor;
                end;

            prelido := true;
            lido1 := #$0;
            if (lido2 = TAB) or (lido2 = ENTER) or (lido2 = ESC) then
                lido1 := ' ';
        end

    else
    if tipo = 'CHECKBOX' then
        begin
            textBackground (RED);
            mensagem ('WBCHKBOX', 0);     {'Item de seleção: '}
            textBackground (BLACK);
            clreol;

            salva := nt;
            repeat
                 nt := nt + 1;
                 extraiCmd (nt);
            until (cmd = 'T') or (cmd = '/HTML');
            saiLinha (sentenca);
            nt := salva;

            if ativado then
                 mensagem ('WBLIGADO', 0)      {'ligado.'}
            else
                 mensagem ('WBDESLIG', 0);     {'desligado.'}

            mensagem ('WBPMARCA', 0);   {'Deixa essa marca ? '}
            sintLeTecla (lido1, lido2);
            writeln;

            if upcase(lido1) = 'S' then
                 begin
                     tagsForms^[indPreenc+1][8] := 'S'
                 end
            else
            if upcase(lido1) = 'N' then
                begin
                    tagsForms^[indPreenc+1][8] := 'N';
                end;

            prelido := true;
            if upcase(lido1) in [TAB, 'A'..'Z'] then
                begin
                    repeat
                         nt := nt + 1;
                         extraiCmd (nt);
                    until cmd  = 'T';
                    lido1 := ' ';
                end;
        end

    else
    if tipo = 'RADIO' then
        begin
            textBackground (RED);
            if tipo = 'RADIO' then
                mensagem ('WBRADIO', 0);      {'Ítem de seleção exclusiva: '}
            textBackground (BLACK);
            clreol;

            salva := nt;
            repeat
                 nt := nt + 1;
                 extraiCmd (nt);
            until (cmd = 'T') or (cmd = '/HTML');
            saiLinha (sentenca);
            nt := salva;

            if ativado then
                mensagem ('WBLIGADO', 0)      {'ligado.'}
            else
                begin
                    mensagem ('WBDESLIG', 0); {'desligado.'}
                    mensagem ('WBLIGA', 0);   {'Devo ligar ? '}
                    sintLeTecla (lido1, lido2);
                    writeln;
                    if upcase(lido1) = 'S' then
                         begin
                             marcaRadio (nt, nome);
                         end;
                end;

            prelido := true;
            if upcase(lido1) in [TAB, 'A'..'Z'] then
                begin
                    repeat
                         nt := nt + 1;
                         extraiCmd (nt);
                    until cmd  = 'T';
                    lido1 := ' ';
                end;
        end

    else
    if (tipo = 'SUBMIT') or (tipo = 'IMAGE') then
        begin
            if valor <> '' then sintWriteln (valor);
            textBackground (RED);
            mensagem ('WBINSUBM', 0);   {'Botão de envio, aperte 'S' para submeter'}
            textBackground (BLACK);
            sintLeTecla (lido1, lido2);
            writeln;
            if upcase (lido1) = 'S' then
                begin
                    submeteu := true;
                    mensagem ('WMSUBMET', 1);   {'Submetendo formulário'}
                end;

            prelido := true;
            if upcase(lido1) in [TAB, 'A'..'Z'] then
                lido1 := ' ';
        end

    else
    ;

    if (lido1 <> BS) and (not (lido1 = #$0) and (lido2 = PGUP)) then
         nt := nt + 1;   {pula input2}
end;

{-------------------------------------------------------------}
{                     trata selecoes
{-------------------------------------------------------------}

procedure trataSelect;
type
    POpcaoForm = ^TOpcaoForm;
    TOpcaoForm = record
        indForm: integer;
        tabOp: string;
        selec: boolean;
    end;

var
    i: integer;
    opcao: POpcaoForm;
    listaOpcoes: TList;
    selecAlguem: boolean;
    lixo, nome, tamanho, ponteiro: string;
    multiplo: boolean;
    ind, indPreenc, erro: integer;
    salva: integer;
label sai;

    procedure montaOpcoes;
    begin
        listaOpcoes := Tlist.Create;

        selecAlguem := false;
        repeat
            nt := nt + 1;
            extraiCmd (nt);

            if cmd = 'OPTION' then
                begin
                    ponteiro  := extraiSentenca;
                    val (ponteiro, indPreenc, erro);
                    sentenca := tagsForms^[indPreenc];

                    new (opcao);
                    listaOpcoes.Add(opcao);
                    with opcao^ do
                        begin
                            {--ignora cmd--}  extraiSentenca;
                            lixo := extraiSentenca;
                            if lixo = 'SELECTED' then
                                begin
                                    selec := true;
                                    selecAlguem := true;
                                end
                            else
                                selec := false;
                            tabOp := extraiSentenca;
                            indForm := indPreenc;
                        end;
                end;

        until (cmd = '/SELECT') or (nt >= ntags);
    end;

    procedure liberaOpcoes;
    var i: integer;
    begin
        for i := 0 to listaOpcoes.Count-1 do
            begin
                opcao := listaOpcoes[i];
                opcao.tabOp := '';
                dispose (opcao);
            end;
        listaOpcoes.Free;
    end;

begin
    if wherex <> 1 then writeln;
    textBackground (RED);
    mensagem ('WBSELSET', 0);    {Selecione a opção com as setas depois ENTER ou ESC}
    textBackground (BLACK);
    writeln;

    salva := nt;
    extraiCmd (nt);
    ponteiro := extraiSentenca;
    nome := extraiSentenca;
    tamanho := extraiSentenca;
    multiplo := extraiSentenca = 'MULTIPLE';
    if multiplo then
        mensagem ('WBSEMULT', 1);   {Você pode marcar mais de uma seleção}

    montaOpcoes;
    if listaOpcoes.Count = 0 then goto sai;

    if not selecAlguem then
        begin
            opcao := listaOpcoes[0];
            opcao^.selec := true;
        end;

    ind := 0;
    repeat
        lido1 := readkey;

        if lido1 = ENTER then
            if (ind > 0) and (ind <= listaOpcoes.count) then
                begin
                    if not multiplo then
                         for i := 0 to listaOpcoes.count-1 do
                              begin
                                  opcao := listaOpcoes[i];
                                  opcao.selec := false;
                              end;

                    opcao := listaOpcoes[ind-1];
                    opcao.selec := not opcao.selec;
                    if not opcao.selec  then
                        mensagem ('WBDMARK', 1);  {' desmarcado'}
                end;

        lido2 := #$0;
        if lido1 = #$0 then
            begin
                lido2 := readkey;
                case lido2 of
                    CIMA: begin
                              if ind > 0 then ind := ind - 1;
                          end;
                    BAIX: begin
                              if ind <= listaOpcoes.Count then ind := ind + 1;
                          end;
                    PGUP: begin
                              nt := salva;
                              goto sai;
                          end;
                else
                    goto sai;
                end;
            end;

        if (lido1 <> ESC) and (lido1 <> TAB) then
             begin
                if (ind > 0) and (ind <= listaOpcoes.Count) then
                    begin
                        gotoxy (1, wherey);
                        opcao := listaOpcoes[ind-1];
                        sintWrite (opcao.tabOp);
                        if opcao.selec then
                            mensagem ('WBMARK', 0);  {' marcado'}
                        writeln;
                    end
                else
                    sintbip;
             end;

    until (lido1 = ESC) or (lido1 = TAB) or (lido1 = BS);

sai:
    for ind := 0 to listaOpcoes.Count-1 do
        begin
            opcao := listaOpcoes[ind];
            sentenca := tagsForms^[opcao.indForm];

            delete (sentenca, 1, 7);
            while sentenca[1] <> '|' do
                delete (sentenca, 1, 1);
            if opcao.selec then
                sentenca := 'OPTION|SELECTED' + sentenca
            else
                sentenca := 'OPTION|' + sentenca;
            tagsForms^[opcao.indForm] := sentenca;
        end;

    liberaOpcoes;

    preLido := true;
    if lido1 = BS then  nt := salva;
    if lido1 = ESC then lido1 := ' ';
end;

{-------------------------------------------------------------}
{                 trata o comando text area
{-------------------------------------------------------------}

procedure trataTextArea (descendo: boolean);
var
    s, nome, ponteiro: string;
    linhas: integer;
//  colunas: integer;
    posTxt, indOpcoes, erro: integer;
    i: integer;

    {-------------------------------------------------------------}

    function extraiTextArea (ind: integer): string;
    begin
        extraiCmdForm (ind);
        extraiTextArea := sentenca;
    end;

    {-------------------------------------------------------------}

    procedure substituiTextArea (ind: integer; novaCadeia: string);
    begin
        sentenca := tagsForms^[ind];
        delete (sentenca, pos('|', sentenca)+1, 999);
        sentenca := sentenca + novaCadeia;
        tagsForms^[ind] := sentenca;
    end;

    {-------------------------------------------------------------}

label fim;
begin
    textBackground (RED);
    mensagem ('WBCAMPOD', 0);   {'Campo de digitação, tecle ENTER para editar '}
    textBackground (BLACK);
    lido2 := #$0;
    sintLeTecla (lido1, lido2);
    writeln;

    if lido1 <> ENTER then goto fim;

    while (nt <> 1) and (cmd <> 'TEXTAREA') do
        begin
            nt := nt - 1;     {posiciona no início do comando}
            extraiCmd (nt);
        end;
    if nt = 1 then exit;

    ponteiro := extraiSentenca;
    val (ponteiro, indOpcoes, erro);
    nome := extraiSentenca;
    s := extraiSentenca;
//  val (s, colunas, erro);
    s := extraiSentenca;
    val (s, linhas, erro);

    mensagem ('WBPODEDI', 1);   {'Pode editar, use ESC para sair'}

    posTxt := 1;
    repeat
         s := extraiTextArea (indOpcoes+posTxt);
         sintetiza (s);
         lido1 := #$0;
         lido2 := sintEditaCampo (s, 1, wherey, 150, 79, true);  // colunas
         substituiTextArea (indOpcoes+posTxt, s);
         case lido2 of
              CIMA:  if posTxt > 1 then
                         begin
                             posTxt := posTxt - 1;
                             gotoxy (1, wherey-1);
                         end
                     else
                         sintBip;
              ENTER,
              BAIX:  if posTxt < linhas then
                         begin
                             posTxt := posTxt + 1;
                             writeln;
                         end
                     else
                         sintBip;
              F7:    begin
                         gotoxy (1, wherex);
                         mensagem ('WBLINREM', 0);   {Linha removida}
                         delLine;
                         for i := posTxt to linhas-1 do
                             begin
                                 s := extraiTextArea (indOpcoes+i+1);
                                 substituiTextArea (indOpcoes+i, s);
                             end;
                         substituiTextArea (indOpcoes+linhas, '');
                     end;
              PGUP:  ;
              TAB:  lido2 := ESC;

         end;
    until lido2 = ESC;

    for i := posTxt to linhas do
        writeln;
    mensagem ('WBOK', 1);

    lido1 := ' ';

fim:
    extraiCmd (nt);
    if lido2 = PGUP then lido1 := BS;
    if (lido1 = BS) or (lido2 = CIMA) then
        begin
            while (nt > 1) and (cmd <> 'TEXTAREA') do
                begin
                    nt := nt - 1;
                    extraiCmd (nt);
                end;
        end
    else
        begin
            while (nt < ntags) and (cmd <> '/TEXTAREA') do
                begin
                    nt := nt + 1;
                    extraiCmd (nt);
                end;
        end;

    preLido := true;
end;

{-------------------------------------------------------------}
{              pega trecho final de um http
{-------------------------------------------------------------}

function trechoFinal (sentenca: string): string;
var i: integer;
begin
    trechoFinal := sentenca;
    for i := length (sentenca) downto 1 do
        if sentenca [i] = '/' then
            begin
                trechoFinal := copy (sentenca, i+1, length(sentenca)-i);
                exit;
            end;
end;

{-------------------------------------------------------------}
{           elimina alguns comandos em modo texto
{-------------------------------------------------------------}

procedure trocasModoTexto (var cmd: string);
begin
    if (cmd = 'IMG') or (cmd = 'MAP') or (cmd = '/MAP') or (cmd = 'AREA HREF') then
        cmd := 'BR'
    else

    if (cmd = 'INPUT') or (cmd = 'INPUT2') or
       (cmd = 'TEXTAREA') or (cmd = 'TEXTAREA2') or (cmd = '/TEXTAREA') or
       (cmd = 'SELECT') or (cmd = '/SELECT') then
        cmd := 'IGNORE';
end;

{-------------------------------------------------------------}
{                  interpreta os tags HTML
{-------------------------------------------------------------}

procedure processaLinha;
var
    tit: string;
    s: string;
label fazInput;
begin
    if modoFala = 'T' then
        trocasModoTexto (cmd)
    else
        if not keypressed then
            begin
                somTag (cmd);
                while sintFalando do waitMessage;
            end;

    if cmd = 'T' then
        begin
            if pegandoTitulo then
                tituloJan := tituloJan + sentenca;
            saiLinha (sentenca);
        end

    else
    if cmd = 'TITLE' then
        begin
            textBackground (BLUE);
            pegandoTitulo := true;
            tituloJan := '';
        end

    else
    if cmd = '/TITLE' then
        begin
            textBackground (BLACK);
            writeln; writeln;
            if pegandoTitulo then
                begin
                    pegandoTitulo := false;
                    tit := 'WEBVOX ' + tituloJan;
                    setWindowText (crtWindow, @tit[1]);
                    pilhaPag[topoPilhaPag]^.tituloPagPilha := tituloJan;
                end;
        end

    else
    if cmd = 'CENTER' then
        centrando := centrando + 1

    else
    if cmd = '/CENTER' then
        begin
            if centrando > 0 then centrando := centrando - 1;
        end

    else
    if (cmd = 'BR') or (cmd = 'DIV') then
        writeln

    else
    if (cmd = 'P')  or
       (cmd = 'H1') or (cmd = 'H2') or (cmd = 'H3') or
       (cmd = 'H4') or (cmd = 'H5') or (cmd = 'H6') then
        begin
            if wherex <> 1 then
                writeln;
            writeln;
            while sintFalando do waitMessage;
            if not keypressed then delay (100);
        end

    else
    if (cmd = 'B') then
        emBold := true

    else
    if (cmd = '/B') then
        emBold := false

    else
    if (cmd = 'I') then
        emItalico := true

    else
    if (cmd = '/I') then
        emItalico := false

    else
    if cmd = 'HR' then
        begin
            if wherex <> 1 then writeln;
            writeln ('----------------------------------------------------------------');
        end

    else
    if (cmd = 'PRE') or (cmd = '/PRE') then
        begin
            if wherex <> 1 then writeln;
        end

    else
    if cmd = 'TABLE' then
        begin
            if not keypressed then delay (100);
            emTabela := true;
            coluna := 1;
            writeln;
        end
    else

    if cmd = '/TABLE' then
        begin
            if wherex <> 1 then writeln;
            emTabela := false;
        end

    else
    if cmd = '/CAPTION' then
         begin
             writeln;
         end

    else
    if (cmd = 'TH') or (cmd = 'TD') then
        begin
            if wherex > coluna then writeln;
            while wherex < coluna do
                coluna := coluna + 8;
            while coluna > wherex do write (' ');
        end

    else
    if (cmd = '/TH') or (cmd = '/TD')  then
        begin
            coluna := coluna - 8;
            if coluna < 1 then coluna := 1;
            if coluna < wherex then writeln;
            while coluna > wherex do write (' ');
        end

    else
    if cmd = 'TR' then
        begin
            writeln;
            if not keypressed then delay (100);
            coluna := 1;
        end

    else
    if cmd = 'IMG' then
        begin
            if wherex <> 1 then write (' ');
            write ('[');
            s := extraiSentenca;  {ignora primeiro parâmetro}
            if keypressed then
                write (sentenca)
            else
                sintWrite (sentenca);
            write ('] ');
        end
    else

    if (cmd = 'UL') or (cmd = 'OL') or (cmd = 'DD') then
        begin
            if wherex <> 1 then writeln;
        end

    else
    if (cmd = '/UL') or (cmd = '/OL') or (cmd = '/DD') then
        begin
            if wherex <> 1 then writeln;
        end

    else
    if cmd = 'DL' then
        begin
            if wherex <> 1 then writeln;
            writeln;
        end

    else
    if (cmd = 'LI') then
        begin
            if wherex <> 1 then writeln;
            saiLinha (sentenca);
        end

    else
    if cmd = 'MAP' then
        begin
            if wherex <> 1 then writeln;
            if keypressed then
                writeln (MAPACLICAVEL)
            else
                sintWriteln (MAPACLICAVEL);
        end

    else
    if cmd = '/MAP' then
        begin
            writeln;
            emRefer := false;
        end

    else
    if cmd = 'AREA HREF' then   { processamento parcial de map }
        begin
            if not keypressed then
                sintBip;
            if wherex <> 1 then writeln;
            emRefer := true;
            paginaATrazer := extraiSentenca;
            ultimoLinkLido := paginaATrazer;
            s := extraiSentenca;
            if s = '' then
                saiLinha (trechoFinal (paginaATrazer))
            else
                saiLinha (s);
        end

    else
    if cmd = 'A ACCESSKEY' then
        begin
        end

    else
    if cmd = 'A HREF' then
        begin
            if biparEmLinks and (not keypressed) then
                sintBip;
            emRefer := true;
            paginaATrazer := sentenca;
            nomeRef := sentenca;
            ultimoLinkLido := sentenca;
        end

    else
    if cmd = '/A' then
        emRefer := false

    else
    if cmd = 'FRAMESET' then
         begin
             if wherex <> 1 then writeln;
             mensagem ('WBFRAMES', 1);   {'Partes divisórias desta página (frames)'}
         end

    else
    if cmd = 'FRAME' then
         begin
             if wherex <> 1 then writeln;
             paginaATrazer := extraiSentenca;
             s := extraiSentenca;

             if s <> '' then
                 sentenca := s
             else
             if sentenca = '' then
                if pos ('/', paginaATrazer) <> 0 then
                    sentenca := trechoFinal (paginaATrazer)
                else
                    sentenca := paginaATrazer;

             emRefer := true;
             saiLinha (sentenca);
             emRefer := false;
        end

    else
    if cmd = 'FORM' then
        begin
             if wherex <> 1 then writeln;
             if modoFala <> 'T' then
                 mensagem ('WBINIFRM', 1);     {'--- Início do Formulário ---'}
        end

    else
    if cmd = '/FORM' then
        begin
             if wherex <> 1 then writeln;
             if modoFala <> 'T' then
                 mensagem ('WBFIMFRM', 1);     {'--- Fim do Formulário ---'}
        end

    else
    if cmd = 'INPUT' then
        begin
fazInput:
            emRefer := false;
            trataInput;
        end

    else
    if cmd = 'INPUT2' then
        begin end

    else
    if cmd = 'TEXTAREA' then
        trataTextArea (true)

    else
    if cmd = 'TEXTAREA2' then
        begin end

    else
    if cmd = '/TEXTAREA' then
        trataTextArea (false)

    else
    if cmd = 'SELECT' then
        trataSelect

    else
    if cmd = '/SELECT' then
        begin
            repeat
                nt := nt - 1;
                extraiCmd (nt);
            until (nt = 1) or (cmd = 'SELECT');
            if nt > 1 then nt := nt - 1;
        end

    else
    if cmd = 'OPTION' then
        { nunca processo isso }

    else
    if (cmd = 'BLOCKQUOTE') or (cmd = '/BLOCKQUOTE') then
        begin
            if wherex <> 1 then
                writeln;
            writeln;
        end

    else

    if cmd = '/HTML' then
        begin
            passoAPasso := true;
            if wherex > 1 then writeln;
            textBackground (RED);
            mensagem ('WBFIMPAG', 0);    {'Fim da pagina'}
            textBackground (BLACK);
            writeln;
            sintBip;
        end

    else
        if debug then
            if (cmd <> 'HTML') and (cmd <> 'BODY') then
                 writeln ('Tag ignorado ', cmd)
    ;

end;

{-------------------------------------------------------------}
{                    ajuda da navegação
{-------------------------------------------------------------}

procedure ajudaNaveg;
begin
    writeln;
    textColor (YELLOW);
    textBackground (BLUE);
    mensagem ('WVAJUN1',  0);     {'Os comandos são:'}
    textBackground (BLACK);
    writeln;
    mensagem ('WVAJUN2',  1);     {'CIMA e BAIXO  caminham e leem o texto'}
    mensagem ('WVAJUN3',  1);     {'DIREITA       avança para proximo texto ou elo'}
    mensagem ('WVAJUN4',  1);     {'Espaço/CTLF1  leitura continua'}
    mensagem ('WVAJUN5',  1);     {'ENTER         entra neste elo, ou se for um campo, executa entrada de dados'}
    mensagem ('WVAJUN6',  1);     {'TAB           pula para ler o próximo elo'}
    mensagem ('WVAJUN7',  1);     {'BS            pula para ler o elo anterior'}
    mensagem ('WVAJUN8',  1);     {'PGUP e PGDN   pula parágrafo'}
    mensagem ('WVAJUN9',  1);     {'CTL PGUP      início e fim da página'}
    mensagem ('WVAJUN10', 1);     {'CTL PGDN      início e fim da página'}
    mensagem ('WVAJUN11', 1);     {'HOME          detalha cláusulas HTML'}
    mensagem ('WVAJUN12', 1);     {'F3            Le nome da página atual'}
    mensagem ('WVAJUN13', 1);     {'F4            Configura'}
    mensagem ('WVAJUN14', 1);     {'F5            Busca texto'}
    mensagem ('WVAJUN15', 1);     {'F6            Informa percentual lido da página'}
    mensagem ('WVAJUN19', 1);     {'ESC           termina leitura'}
    textColor (LIGHTGRAY);
    while keypressed do readkey;
    writeln;
end;

{-------------------------------------------------------------}
{                leitura tipo edição
{-------------------------------------------------------------}

procedure editaInfo;
var
    p: integer;
    c: char;

begin
    repeat
        p := pos ('|', tagsPagina^[nt]);
        cmd := copy (tagsPagina^[nt], 1, p-1);
        sentenca := copy (tagsPagina^[nt], p+1, length(tagsPagina^[nt])-p);

        if cmd <> 'T' then
            begin
                mensagem ('WBTIPO', 0);   {tipo}
                sintWriteln (cmd);
            end;

        if sentenca <> '' then
            begin
                writeln;
                mensagem ('WBSOLET', 1);    {'Soletre ou edite com as setas, ESC termina'}
                if length (sentenca) > 254 then
                    SetLength (sentenca, 254);
                c := sintEditaCampo (sentenca, 1, wherey, length(sentenca)+1, 79, false);
                writeln;
            end
        else
            c := ESC;

        case c of
            CIMA:    if nt > 1 then nt := nt - 1;
            BAIX:    if nt < ntags then nt := nt + 1;
        end;

    until c = ESC;
end;

{-------------------------------------------------------------}
{       executa leitura até encontrar o fim de um link
{-------------------------------------------------------------}

procedure leEsteLink;
var lendo: boolean;
begin
    extraiCmd (nt);

    if cmd = 'AREA HREF' then
        processaLinha

    else
    if cmd = 'A HREF' then
        begin
           processaLinha;
           writeln;
           nt := nt + 1;

           lendo := true;
           while lendo do
               begin
                   if nt > ntags then
                       lendo := false
                   else
                       begin
                           extraiCmd (nt);
                           if cmd = '/A' then
                               lendo := false
                           else
                               begin
                                   processaLinha;
                                   nt := nt + 1;
                               end;
                       end;
               end;
        end

    else
    if cmd = 'FRAME' then
        begin
           processaLinha;
           emRefer := true;
        end

    else
    if (cmd = 'INPUT')  or (cmd = 'TEXTAREA') or
       (cmd = 'SELECT') then
        begin
            emRefer := false;
            processaLinha;
        end
    else
    ;
end;

{-------------------------------------------------------------}
{                  avanca para proximo link
{-------------------------------------------------------------}

procedure proximoLink (var nt: integer);
var n: integer;
begin
    textBackGround (BLACK);
    emRefer := false;
    n := nt;
    repeat
        n := n + 1;
        if n <= ntags then
            extraiCmd (n);
    until (n > ntags) or
          (cmd = 'AREA HREF') or
          (cmd = 'A HREF') or
          (cmd = 'FRAME') or
          (cmd = 'INPUT') or
          (cmd = 'TEXTAREA') or
          (cmd = 'SELECT') or
          (cmd = 'FORM') or (cmd = '/FORM');

    if n <= ntags then
        begin
            nt := n;
            if cmd = 'A HREF' then
                leEsteLink;
        end
    else
        begin
            writeln;
            mensagem ('WBNAOLNK', 1);   {'Não há mais referencias nesta página'}
        end;
end;

{-------------------------------------------------------------}
{                  recua para link anterior
{-------------------------------------------------------------}

procedure linkAnterior (var nt: integer);
var n: integer;
begin
    textBackGround (BLACK);
    emRefer := false;
    n := nt;
    repeat
        n := n - 1;
        if n >= 1 then
            extraiCmd (n);
    until (n < 1) or
          (cmd = 'AREA HREF') or
          (cmd = 'A HREF') or
          (cmd = 'FRAME') or
          (cmd = 'INPUT') or
          (cmd = 'TEXTAREA') or
          (cmd = 'SELECT') or
          (cmd = 'FORM') or (cmd = '/FORM');

    if n >= 1 then
        begin
            nt := n;
            if cmd = 'A HREF' then
                leEsteLink;
            nt := n;   { de novo...}
            emRefer := true;
        end
    else
        begin
            writeln;
            mensagem ('WBNAOLNK', 1);   {'Não há mais referencias nesta página'}
            emRefer := false;
        end;
end;

{-------------------------------------------------------------}
{                   executa uma funcao
{-------------------------------------------------------------}

function executa (nt: integer; peloWindows, peloYoutube: boolean): boolean;     {note: nt não é alterado !}
label traz;
begin
    extraiCmd (nt);
    executa := false;

    if getKeyState (vk_Shift) < 0 then
        begin
            while (nt > 1) and (cmd <> 'IMG') do
                begin
                    nt := nt - 1;
                    extraiCmd (nt);
                end;

            if cmd <> 'IMG' then exit;
            goto traz;
        end;

    if  (cmd <> 'AREA HREF') and
        (cmd <> 'A HREF')    and
        (cmd <> 'FRAME')     and
        (cmd <> 'INPUT')     and
        (cmd <> 'TEXTAREA')  and
        (cmd <> 'SELECT')    then linkAnterior (nt)
    else
        emRefer := true;

    if not emRefer then exit;

    extraiCmd (nt);
    if (cmd = 'AREA HREF') or
       (cmd = 'A HREF')    or
       (cmd = 'FRAME') then
            begin
traz:
                paginaATrazer := extraiSentenca;
                if peloWindows then
                    executaProg (paginaATrazer, '', '')
                else
                if peloYoutube then
                    gravarVideoYoutube (paginaATrazer)
                else
                    executa := true;
            end;
end;

{-------------------------------------------------------------}
{                     busca um texto
{-------------------------------------------------------------}

procedure buscaTexto (pergunta: boolean);
var n, i: integer;
begin
    if pergunta then
        begin
            if wherex <> 1 then writeln;
            mensagem ('WBQUALTX', 1);   {'Qual o texto a buscar ? '}
            sintReadln (textoBuscado);
            if textoBuscado = '' then
                begin
                    textoBuscado :=  sintambiente ('WEBVOX','TEXTOBUSCADO');
                    exit;
                end;
            n := nt;
        end
    else
        n := nt + 1;

    textoBuscado := maiuscAnsi (textoBuscado);
    for i := n to nTags do
        begin
            extraiCmd (i);
            if cmd = 'T' then
                begin
                    if pos (textoBuscado, maiuscAnsi (sentenca)) <> 0 then
                         begin
                             nt := i;
                             exit;
                         end;
                end;
        end;
    mensagem ('WBNAOACH', 1);    {'Texto não encontrado após esta posição do texto'}
end;

{-------------------------------------------------------------}
{                    trata accesskey
{-------------------------------------------------------------}

procedure trataAccesskey(tecAtalho: char);
var
    p, procTag: integer;
begin

    for procTag := 1 to ntags do
        begin
            p := pos ('|', tagsPagina^[procTag]);
            cmd := copy (tagsPagina^[procTag], 1, p-1);
            if cmd = 'A ACCESSKEY' then
                begin
                    sentenca := copy (tagsPagina^[procTag], p+1, length(tagsPagina^[procTag])-p);

                    if sentenca = tecAtalho then
                        begin
                            if debug then
                                writeln('Accesskey: ' + sentenca + ': próxima tag href|link: ' + tagsPagina^[procTag+1]);

                            sintClek; sintClek;
                            nt := procTag+1;
                            writeln;
                            mensagem ('WBOK', 2);
                            break;
                        end
                end
        end;
     sintBip;
end;

{-------------------------------------------------------------}
{                 trata funções de interação
{-------------------------------------------------------------}

procedure trataFuncoes (c: char);
const
    atalhos: array [0..25] of char = (
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
    'z', 'x', 'c', 'v', 'b', 'n', 'm');

var n: integer;
    s: string;
begin
    if c <> BAIX then
        begin
            textColor (LIGHTGRAY);    {para evitar mas interpretacoes}
            textBackground (BLACK);
            centrando := 0;
            emBold := false;
            emItalico := false;
            emRefer := false;
            if wherex <> 1 then writeln;
        end;

    case c of
        #16..#25: trataAccesskey(atalhos[ord(c)-16]);
        #30..#38: trataAccesskey(atalhos[ord(c)-20]);
        #44..#50: trataAccesskey(atalhos[ord(c)-25]);

        CTLF1:   begin
                     passoAPasso := false;
                     nt := nt + 1;
                 end;

        F1:      ajudaNaveg;

    F2:          begin
                     biparEmLinks := not biparEmLinks;
                     if biparEmLinks then sintBip
                     else sintClek;
                  end;

        F3:      begin
                     writeln;
                     textBackground (RED);
                     sintetiza (nomePagAtual);
                     sintEditaCampo(nomePagAtual, wherex, wherey, 255, 79, false);
                     textBackground (BLACK);
                     writeln;
                end;

        F4:      configura;
        CTLF4:   trocaLingua;

        F5:      buscaTexto (true);
        CTLF5:   buscaTexto (false);

        F6:      begin
                     writeln;
                     textBackground (RED);
                     n := round ((nt / nTags) * 100);
                     sintWriteint (n);
                     sintWriteln (TXTPORCENTO);   { por cento lido }
                     textBackground (BLACK);
                     repeat until keypressed;
                     while keypressed do readkey;
                     writeln;
                 end;

        F8 :     falaHora;
        CTLF8 :   falaDia;

        F9 : begin
            leitorDeTela;
            passoAPasso := false;
            nt := nt + 1;
        end;

        CTLF9 : begin
                    if not alteraModo then
                        begin
                            alteraModo := true;
                            modoFala := 'T';
                            prepSonsTags ('');
                            if wherex <> 1 then writeln;
                            textBackGround (RED);
                            sintWriteln ('Modo texto');
                            textBackGround (BLACK);
                        end
                    else
                        begin
                            alteraModo := false;
                            s := sintAmbiente ('WEBVOX', 'MODOFALA') + 'N'; //Garante pelo menos uma letra
                            modoFala := upcase(s[1]);
                            s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS');
                            if s = '' then
                                s := sintDirAmbiente + '\webtags.ini';
                                prepSonsTags (s);
                            if wherex <> 1 then writeln;
                            textBackGround (RED);
                            sintWriteln ('Modo normal');
                            textBackGround (BLACK);
                    end;
                    passoAPasso := false;
                    nt := nt + 1;
                end;

        DEL:   clrscr;

        HOME:    editaInfo;

        CIMA:    begin
                     emRefer := false;
                     if wherex <> 1 then writeln;
                     writeln ('^');
                     repeat
                         if nt >= 1 then nt := nt - 1;
                         if nt > 0 then extraiCmd (nt);
                     until (nt < 1) or
                           (cmd = 'AREA HREF') or
                           (cmd = 'FRAME') or
                           ((cmd = 'T') and (sentenca <> ''));
                     if nt < 1 then
                         begin
                             mensagem ('WBINITXT', 2);   {'Fui para o início do texto'}
                             nt := 1;
                         end;
                 end;

        CTLUP:    begin
                     emRefer := false;
                     if wherex <> 1 then writeln;
                     writeln ('^');
                     if nt > 1 then
                         nt := nt - 1
                     else
                         mensagem ('WBINITXT', 2);   {'Fui para o início do texto'}
                 end;

        BAIX :   if nt < ntags then
                     repeat
                         nt := nt + 1;
                         extraiCmd (nt);
                         if (cmd <> 'AREA HREF') and (cmd <> 'FRAME') then
                             if (cmd <> 'T') or (trim (sentenca) = '') then
                                    processaLinha;
                     until (nt >= ntags) or
                           (cmd = 'AREA HREF') or
                           (cmd = 'FRAME') or
                           ((cmd = 'T') and (trim (sentenca) <> ''));

        CTLDOWN :   if nt < ntags then
                    nt := nt + 1;

        DIR:     repeat
                    if nt < ntags then
                        begin
                            nt := nt + 1;
                            extraiCmd (nt);
                        end;
                until (nt >= nTags) or
                      (cmd = 'T') or
                      (cmd = 'BLOCKQUOTE') or
                      (cmd = 'AREA HREF') or
                      (cmd = 'A HREF') or
                      (cmd = 'FRAME') or
                      (cmd = 'INPUT') or
                      (cmd = 'TEXTAREA') or
                      (cmd = 'SELECT');

        PGUP:    begin
                     n := 0;
                     repeat
                        if nt > 1 then
                            begin
                                 nt := nt - 1;
                                 extraiCmd (nt);
                                 if cmd = 'BR' then n := n + 1
                                 else
                                 if cmd = 'P' then n := n + 2;
                            end;
                     until (n > 20) or (nt < 2);
                     clrscr;
                     sintClek; sintClek;
                 end;

        PGDN:    begin
                     n := 0;
                     repeat
                        if nt < ntags then
                            begin
                                 nt := nt + 1;
                                 extraiCmd (nt);
                                 if cmd = 'BR' then n := n + 1
                                 else
                                 if cmd = 'P' then n := n + 2;
                                 processaLinha;
                            end;
                     until (n > 20) or (nt >= ntags);
                     sintClek; sintClek;
                 end;

        CTLPGUP, CTLHOME: begin
                     nt := 1;
                     writeln;
                     mensagem ('WBINITXT', 2);   {'Fui para o início do texto'}
                 end;

        CTLPGDN, CTLEND: begin
                     nt := ntags;
                     writeln;
                     mensagem ('WBFIMTXT', 2);   {'Fui para o fim do texto'}

                 end;
    end;
end;

{-------------------------------------------------------------}
{         converte cadeia para o padrao codificado HTTP
{-------------------------------------------------------------}

function converteValorParaHTTP (valor: string): string;
const
    tabHexa: array [0..15] of char = (
     '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var s: string;
    i: integer;
begin
    s := '';
    for i := 1 to length (valor) do
        begin
            case valor[i] of
                '@', '*', '.', '_',
                '0'..'9', 'A'..'Z', 'a'..'z':  s := s + valor[i];
                ' ':  s := s + '+';
            else
                s := s + '%' +
                     tabHexa [ord (valor[i]) shr 4] +
                     tabHexa [ord (valor[i]) and $f];
            end;
        end;
    converteValorParaHTTP := s;
end;

{-------------------------------------------------------------}
{           tenta adivinhar o que o Java Script faria
{-------------------------------------------------------------}

function nomeRefAlternativo (nt: integer): string;
var
    i, indPreenc, erro: integer;
    lixo, nome, valor, selec, ponteiro: string;
label ok1, ok2;
begin
    nome := '';

    for i := nt-1 downto 1 do
        begin
            extraiCmd (i);
            if cmd = 'FORM' then goto ok1;
        end;
    i := 1;

ok1:
    for i := i+1 to nTags do
        begin
            extraiCmd (i);
            if cmd = '/FORM' then goto ok2;

            if cmd = 'OPTION' then
                begin
                    ponteiro  := extraiSentenca;
                    val (ponteiro, indPreenc, erro);
                    sentenca := tagsForms^[indPreenc];

                    lixo := extraiSentenca;
                    selec := extraiSentenca;
                    nome := extraiSentenca;
                    valor := extraiSentenca;

                    if selec = 'SELECTED' then
                        begin
                            if copy (valor, 1, 7) = 'http://' then
                                begin
                                    nomeRefAlternativo := valor;
                                    exit;
                                end;

                            montaURLrelativa (valor, nomeBase, lixo);
                            nomeRefAlternativo := lixo;
                            exit;
                        end;
                end;
        end;

ok2:

    nomeRefAlternativo := '';
end;

{-------------------------------------------------------------}
{                  gera chave de acesso Mime
{-------------------------------------------------------------}

procedure geraChaveMime;
var i, n: integer;
    s: string;
begin
    s := '';
    chaveMime := '-----------';
    for i := 1 to 5 do
         begin
             n := random (255);
             str (n, s);
             chaveMime := chaveMime + s;
         end;
end;

{-------------------------------------------------------------}
{             adiciona à string de saída de post
{-------------------------------------------------------------}

procedure addStringPost (s: string);
var p: pointer;
begin
    p :=  @s[1];
    move (p^, dadosPost^[tamDadosPost], length (s));
    tamDadosPost := tamDadosPost + length (s);
end;

{-------------------------------------------------------------}

procedure addBinPost (p: pointer; tam: integer);
begin
    move (p^, dadosPost^[tamDadosPost], tam);
    tamDadosPost := tamDadosPost + tam;
end;

{-------------------------------------------------------------}
{                   gera area de post
{-------------------------------------------------------------}

procedure geraPost (chave, valor: string);
var
   s: string;
begin
    if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
       begin
           s := '--' + chaveMime + CRLF +
                'Content-Disposition: ' + copy (formContentType, 11, 999) +
                '; name="' + chave + '"' + CRLF +
                CRLF +
                valor + CRLF;
           addStringPost (s);
       end
    else
       begin
          if tamDadosPost <> 0 then
             addStringPost ('&');
          s := converteValorParaHTTP(chave);
          if valor <> '' then
             s := s + '=' + valor
          else
             s := s + '=';
          addStringPost (s);
       end;
end;

{--------------------------------------------------------}
{        codifica um arquivo em formato texto
{--------------------------------------------------------}

procedure CodifTexto (chave, nomeArq, tipoAplic: string);
var
   s: string;
   arq: File;
   buf: array [0..8192] of byte;
   lidos: integer;
begin
   s := '--' + chaveMime + CRLF +
        'Content-Disposition: ' + copy (formContentType, 11, 999) +
        '; name="' + chave + '"; filename="' + nomeArq + '"' + CRLF +
        'Content-Type: ' + tipoAplic + CRLF + CRLF;
   addStringPost (s);

   assignFile (arq, nomeArq);
   {$I-}  reset (arq, 1);  {$I+}
   if ioresult = 0 then
       begin
            while not eof (arq) do
               begin
                   blockRead (arq, buf, 8192, lidos);
                   addBinPost (@buf, lidos);
               end;
           close (arq);
       end;

    s := CRLF;
    addStringPost (s);
end;

{-------------------------------------------------------------}
{                   gera o tipo de mime
{-------------------------------------------------------------}

function geraTipoAplic (nome: string): string;
var ext: string [4];
    i: integer;
label achou;
begin
    ext := '';
    for i := length (nome) downto length (nome)-3 do
        if nome[i] = '.' then goto achou
        else ext := upcase(nome[i]) + ext;
achou:
    if      ext = 'ZIP'  then  geraTipoAplic := 'application/zip'
    else if ext = 'WAV'  then  geraTipoAplic := 'audio/x-wav'
    else if ext = 'MP3'  then  geraTipoAplic := 'audio/mpeg'
    else if ext = 'WMA'  then  geraTipoAplic := 'audio/x-ms-wma'
    else if ext = 'MID'  then  geraTipoAplic := 'audio/midi'
    else if ext = 'BMP'  then  geraTipoAplic := 'image/bmp'
    else if ext = 'GIF'  then  geraTipoAplic := 'image/gif'
    else if ext = 'JPG'  then  geraTipoAplic := 'image/jpeg'
    else if ext = 'MPG'  then  geraTipoAplic := 'video/mpeg'
    else if ext = 'MPEG' then  geraTipoAplic := 'video/mpeg'
    else if ext = 'HTM'  then  geraTipoAplic := 'text/html'
    else if ext = 'HTML' then  geraTipoAplic := 'text/html'
    else if ext = 'TXT'  then  geraTipoAplic := 'text/plain'
    else
        geratipoAplic := 'application/octet-stream';
end;

{-------------------------------------------------------------}
{                   gera area de post para o File
{-------------------------------------------------------------}

procedure geraPostFile (chave, nomeArq: string);
var
   tipoAplic: string;
begin
    if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
       begin
           tipoAplic := geraTipoAplic (nomeArq);
           codifTexto (chave, nomeArq, tipoAplic);
       end
    else
       geraPost (chave, converteValorParaHTTP (nomeArq));
end;

{-------------------------------------------------------------}
{           coloca marca final se transmissão MIME
{-------------------------------------------------------------}

procedure fechaPost;
var s: string;
begin
    if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
        begin
            s := '--' + chaveMime + '--' + CRLF;
            addStringPost (s);
        end;
end;

{-------------------------------------------------------------}
{           executa uma submissao de formulario
{-------------------------------------------------------------}

procedure trataSubmissao (var nt: integer; var novoMetodo: char; var nomeRef: string);
var i, cmdInic, n, erro, indPreenc: integer;
    selec, nomeSelec,
    s, sfinal, altern, lixo, metodo, valor,
    ponteiro, tipo, nome, nomeArqInput: string;
    validas, linhas: integer;
    temSubmit: boolean;
label achou, fim;

   procedure trataNomeArq (var nomeArquivo: string);
   var
      s2: string;
   begin
      if pos ('\', nomeArquivo) = 0 then
         begin
            getDir (0,s2);
            nomeArquivo := s2 + '\' + nomeArquivo;
         end;
   end;
begin
    geraChaveMime;
    novoMetodo := 'G';
    nomeRef := '';
    tamDadosPost := 0;

    for cmdInic := nt-1 downto 1 do
        begin
            extraiCmd (cmdInic);
            if cmd = 'FORM' then goto achou;
        end;

    cmdInic := nt-1;    // bobagem para o compilador não acusar advertência
    exit;

achou:
    lixo := extraiSentenca;
    metodo := extraiSentenca;
    novoMetodo := upcase(metodo [1]);
    nomeRef := extraiSentenca;
    temSubmit := false;

    for n := cmdInic to ntags do
        begin
            extraiCmd (n);
            if cmd = '/FORM' then
                begin
                     fechaPost;
                     goto fim;
                end;

            if cmd = 'INPUT' then
                begin
                    ponteiro := extraiSentenca;
                    val (ponteiro, indPreenc, erro);

                    tipo     := extraiSentenca;
                    nome     := extraiSentenca;
                    valor := '';
                    if (tipo = 'IMAGE') then      // verificar em formulario com file
                        begin
                            gerapost (nome, '.x=0');
                            gerapost (nome, '.y=0');
                        end
                    else
                    if (tipo = 'FILE') then
                        begin
                           nomeArqInput := copy (tagsForms^[indPreenc+1], 10, 9999);
                           trataNomeArq (nomeArqInput);
                           geraPostFile (nome, nomeArqInput);
                        end
                    else
                    if (tipo = 'SUBMIT') then
                        begin
                            temSubmit := true;
                            if (nome <> '') and (n = nt) then
                                 begin
                                     valor := copy (tagsForms^[indPreenc+1], 10, 9999);
                                     gerapost (nome, converteValorParaHTTP (valor));
                                 end;
                        end
                    else
                    if tipo = 'CHECKBOX' then
                        begin
                            if copy (tagsForms^[indPreenc+1], 8, 1) = 'N' then valor := 'off'
                                                                          else valor := 'on';
                            if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
                               gerapost (nome, valor)
                            else
                               gerapost (nome, converteValorParaHTTP (valor));
                        end
                    else
                    if (tipo = 'TEXT') or (tipo = 'PASSWORD') or
                       (tipo = 'RADIO') or (tipo='HIDDEN') then
                         if copy (tagsForms^[indPreenc+1], 8, 1) <> 'N' then
                           begin
                               valor := copy (tagsForms^[indPreenc+1], 10, 9999);
                               if charsetAtual = 'UTF-8' then
                                      valor := AnsiToUtf8(valor);

                               if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
                                  gerapost (nome, valor)
                               else
                                  gerapost (nome, converteValorParaHTTP (valor));
                           end;
                end
            else
            if cmd = 'SELECT' then
                begin
                    ponteiro := extraiSentenca;
                    val (ponteiro, indPreenc, erro);
                    sentenca := tagsForms^[indPreenc];

                    lixo := extraiSentenca;
                    nomeSelec := extraiSentenca;  {é o segundo}
                end
            else
            if cmd = 'OPTION' then
                begin
                    ponteiro := extraiSentenca;
                    val (ponteiro, indPreenc, erro);
                    sentenca := tagsForms^[indPreenc];

                    lixo := extraiSentenca;
                    selec := extraiSentenca;
                    nome := extraiSentenca;
                    valor := extraiSentenca;
                    if selec = 'SELECTED' then
                       begin
                          if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
                             gerapost (nomeSelec, valor)
                          else
                             gerapost (nomeSelec, converteValorParaHTTP (valor));
                       end;
                end
            else
            if cmd = 'TEXTAREA' then
                begin
                    ponteiro := extraiSentenca;
                    val (ponteiro, indPreenc, erro);

                    nome := extraiSentenca;
                    s := extraiSentenca;
                    s := extraiSentenca;
                    val (s, linhas, erro);

                    validas := 0;
                    for i := 1 to linhas do
                        begin
                            sentenca := tagsForms^[indPreenc+i];
                            lixo := extraiSentenca;
                            s := extraiSentenca;
                            if s <> '' then validas := i;
                        end;

                    sfinal := '';
                    for i := 1 to validas do
                        begin
                            sentenca := tagsForms^[indPreenc+i];
                            lixo := extraiSentenca;
                            s := extraiSentenca;
                            if charsetAtual = 'UTF-8' then
                                 s := AnsiToUtf8(s);
                            if i <> validas then
                               begin
                                  if maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART' then
                                     s := s + #$0d + #$0a
                                  else
                                     s := converteValorParaHTTP (s + #$0d + #$0a);
                                end
                            else
                               if not (maiuscAnsi (copy (formContentType, 1, 9)) = 'MULTIPART') then
                                  s := converteValorParaHTTP (s);

                            sfinal := sfinal + s;
                        end;
                    gerapost (nome, sfinal);
                end
            else
                ;
        end;

fim:
    if (nomeRef = '') or (not temSubmit) then
        begin
            altern := nomeRefAlternativo (nt);
            if altern <> '' then
                begin
                    writeln;
                    mensagem ('WBJAVA', 1);      {'Simulando Java Script'}
                    novoMetodo := 'G';
                    nomeRef := altern;
                    tamDadosPost := 0;
                end;
        end;

    if nomeRef = '' then nomeRef := nomePagAtual;

    if novoMetodo = 'G' then
        begin
            if tamDadosPost <> 0 then
                begin
                    dadosPost^[tamDadosPost] := 0;
                    if (length(nomeRef) > 0) and (nomeRef[length(nomeRef)] <> '?') then
                        nomeRef := nomeRef + '?';
                    nomeRef := nomeRef + strPas (pchar(dadosPost));
                end;
        end;

    repeat
        nt := nt - 1;
        if nt > 1 then
            extraiCmd (nt);
    until (nt <= 1) or (cmd = 'FORM');
end;

{-------------------------------------------------------------}
{                busca um rotulo nesta página
{-------------------------------------------------------------}

function buscaRotulo (rotulo: string): integer;
var i: integer;
begin
    buscaRotulo := 1;
    for i := 1 to ntags do
        begin
            extraiCmd (i);
            if cmd = 'A NAME' then
                if extraiSentenca = rotulo then
                    begin
                        buscaRotulo := i;
                        exit;
                    end;
        end;
end;

{-------------------------------------------------------------}

function buscaTag (nt: integer; qualTag: string): integer;
var
    i: integer;
begin
    for i := nt to ntags-1 do
         begin
             extraiCmd (i);
             if cmd = qualTag then
                begin
                    nt := i;
                    break;
                end;
         end;

    result := nt;
end;

{-------------------------------------------------------------}

function buscaHeader (nt: integer): integer;
var
    i: integer;
begin
    for i := nt to ntags-1 do
         begin
             extraiCmd (i);
             if (cmd = 'H1') or (cmd = 'H2') or (cmd = 'H3') or (cmd = 'H4') or (cmd = 'H5') or (cmd = 'H6') then
                begin //Patrick colocou h4 h5 h6
                    nt := i;
                    break;
                end;
         end;

    result := nt;
end;

{-------------------------------------------------------------}
{                leitura interativa da pagina
{-------------------------------------------------------------}

procedure leituraInterativa (nomeArqOrig: string;
       var novaPagina: string; var novoMetodo: char; var voltando: boolean);

var salvaPasso, processando: boolean;
    s: string;

label deNovo, fim, execSubmissao;

begin
    voltando := false;
    if not extraiTagsPagina (nomeArqOrig) then
        begin
            novaPagina := '';
            novoMetodo := 'G';
            exit;
        end;

deNovo:
    if rotuloInicial <> '' then
        linhaAtual := buscaRotulo (rotuloInicial);
    rotuloInicial := '';

    submeteu := false;
    clrscr;

    gotoxy (1, 1);
    window (1,1, 80, 24);

    centrando := 0;
    emBold := false;
    emItalico := false;
    emRefer := false;

    nt := linhaAtual;
    processando := true;
    preLido := false;
    lido1 := ' ';

    passoAPasso := false;
    sintFalaPont := falandoPontuacao;

    voltando := false;
    while processando do
        begin
            extraiCmd (nt);     { se nt > ntags, a rotina retornará /HTML }
            processaLinha;
            if submeteu then goto execSubmissao;

            salvaPasso := passoAPasso;
            if nt > nTags then
                begin
                    passoAPasso := true;
                    nt := nTags;
                end
            else
                if keypressed then
                    passoApasso := true;

            if not passoAPasso then
                nt := nt + 1
            else
                begin
                    if not prelido then
                        begin
                            checkbreak := false;
                            lido1 := readkey;
                            if lido1 = #$0 then lido2 := readkey;
                            if (lido1 = #$0) and (lido2 = F4) and (getKeyState (VK_MENU) < 0)then lido1 := ^W;
                            sintPara;
                            checkbreak := true;
                        end;
                    preLido := false;

                    case upcase(lido1) of
                        #$0:   begin
                                   sintFalaPont := true;
                                   trataFuncoes (lido2);
                                   sintFalaPont := falandoPontuacao;
                               end;

                        ENTER: if executa (nt, false, false) then
                                   processando := false;

                        CTLENTER: executa (nt, true, false);

                        ^Y: executa (nt, false, true); // Youtube

                        ^C:    begin
                                   if ultimoLinkLido <> '' then
                                       putClipboard (@ultimoLinkLido[1]);
                                   sintClek; sintclek;
                               end;

                        TAB:   if getKeyState (vk_Shift) < 0 then
                                   linkAnterior (nt)
                               else
                                   proximoLink (nt);

                        BS:    linkAnterior (nt);

                        ' ':   begin
                                   passoAPasso := not salvaPasso;
                                   nt := nt + 1;
                               end;

                        'V':   begin
                                   textColor (LIGHTGRAY);
                                   novaPagina := '';
                                   linhaAtual := nt;
                                   novoMetodo := ' ';
                                   voltando := true;
                                   goto fim;
                               end;

                        'F':  begin
                                  nt := buscaTag (nt, 'FORM');
                                  textBackground (BLACK);  textColor (WHITE);
                                  insertKeyBuf (' ');
                              end;

                        'H':  begin
                                  nt := buscaHeader (nt);
                                  textBackground (BLACK);  textColor (WHITE);
                                  insertKeyBuf (' ');
                              end;

                        'T': begin
                                sintetiza(tituloJan);
                                if not keypressed then delay (500);
                              end;

                        ESC, ^F, ^W:
                            begin
                                if lido1 = ^W then fecharPrograma := true;
                                if alteraModo then
                                    begin
                                        s := sintAmbiente ('WEBVOX', 'MODOFALA') + 'N'; //Garante pelo menos uma letra, modo normal
                                        modoFala := upcase (s[1]);
                                        s := sintAmbiente ('WEBVOX', 'AMBWEBTAGS');
                                        if s = '' then
                                             s := sintDirAmbiente + '\webtags.ini';
                                            prepSonsTags (s);
                                        if wherex <> 1 then writeln;
                                        textBackGround (RED);
                                        sintWriteln ('Retornando ao modo normal');
                                        textBackGround (BLACK);
                                    end;
                                textColor (LIGHTGRAY);
                                novaPagina := '';
                                linhaAtual := nt;
                                novoMetodo := ' ';
                                goto fim;
                            end;
                    else
                        begin
                            if wherex <> 1 then writeln;
                            textBackGround (RED);
                            mensagem ('WBCMDINV', 0);    {'Comando inválido, F1 ajuda'}
                            textBackGround (BLACK);
                            writeln
                        end;
                    end;
                end;
        end;

execSubmissao:
    novoMetodo := 'G';
    if submeteu then
        trataSubmissao (nt, novoMetodo, novaPagina)
    else
        begin
            novaPagina := paginaATrazer;
            if (novaPagina <> '') and (novaPagina[1] = '#') then
                begin
                    rotuloInicial := copy (novaPagina, 2, length(novaPagina)-1);
                    goto deNovo;
                end;
        end;

fim:
    pilhaPag [topoPilhaPag]^.posicao := nt;
    sintFalaPont := true;
    window (1,1, 80, 25);
    gotoxy (1, 25);
    textBackground (BLACK);
    textColor (LIGHTGRAY);
    clreol;
end;

{-------------------------------------------------------------}
{               chama um dos leitores do webvox
{-------------------------------------------------------------}

procedure chamaLeitor (tipo: string; nomeArq: string);
var nomeProg: string;
    nomeDir: string;
    nomeAntigo, nomeNovo: string;
    i: integer;
const
    letrasValidas: set of char = ['a'..'z', 'A'..'Z', '0'..'9', '~', '-', '_', '$', '.', ':', '\'];

begin
    nomeProg := sintAmbiente ('WEBVOX', tipo);
    if nomeProg = '' then
        begin
            if (tipoParaDownload(tipo)) and (nomeArqDownload <> '') then //Patrick, antes testava diretamente o Content-Type
                 nomePagAtual := nomeArqDownload;
            nomeNovo := pilhaPag[topoPilhaPag]^.nomeArqTemp + '-' + nomeResumido (nomePagAtual);
            for i := 1 to length (nomeNovo) do
                if not (nomeNovo[i] in letrasValidas) then
                    nomeNovo[i] := '_';
            nomeAntigo := pilhaPag[topoPilhaPag]^.nomeArqTemp;
            if pos ('.TMP.', nomeNovo) = 0 then
                begin
                    MoveFile(@nomeAntigo[1], @nomeNovo[1]);
                    nomeTemp := nomeNovo;
                    pilhaPag[topoPilhaPag]^.nomeArqTemp := nomeNovo;
                    pilhaPag[topoPilhaPag]^.podeApagarTemp := false;
                end;
            if fileExists (nomeTemp) then
                if DirectoryExists (dirDownload)  then
                    gravarOriginal (true)
                else
                    mensagem ('WBTIPNAO', 1);   {'Tipo não processavel, para armazenar use a funcao O'}
            exit;
        end;

    getdir (0, nomeDir);

    writeln (nomeprog);
    writeln (nomedir);
    writeln (nomearq);

    if executaProg (nomeProg, nomeDir, nomeArq) > 32 then
        esperaProgVoltar
    else
        mensagem ('WBNAOEXE', 1);   {'Execução do programa trazido não foi possível'}
end;

{-------------------------------------------------------------}
{            checa se arquivo tipo texto nao é html
{-------------------------------------------------------------}

procedure checaTipoTexto (var tipo: string; nomeArq: string);
var
    s1, s2: string;
    arq: text;
begin
    assign (arq, nomearq);
    {$I-}  reset (arq);  {$I+}
    if ioresult = 0 then
        begin
            {$I-}  readln (arq, s1);  {$I+}   if ioresult <> 0 then;
            {$I-}  readln (arq, s2);  {$I+}   if ioresult <> 0 then;
            close (arq);

            if (maiusc(s1) = '<HTML>') or  (maiusc(s2) = '<HTML>') then
                   begin
                       tipo := 'text/html';
                       exit;
                   end;
        end;
end;

{-------------------------------------------------------------}
{                      executa leitura
{-------------------------------------------------------------}

procedure lerPagina (var voltando: boolean);
var
    novaPagina: string;
    novoMetodo: char;
    tipo: string;
    p: integer;
    tit: string;

label le, fim;

begin
//    invertColorMask := $FFFFFF;
    invertColorMask := 0;
    voltando := false;
    novoMetodo := 'G';
    alteraModo := false;

    tipo := '';
    if nomeTemp = '' then
        begin
             mensagem ('WBNAOCAR', 2);  {'Não existe página carregada'}
             invertColorMask := 0;
             exit;
        end;

    repeat
         tipo := buscaInfoCabec ('Content-type:');
         if tipo = '' then tipo := 'text/html';

         if pos(';', tipo) <> 0 then
             delete (tipo, pos(';', tipo), 999);
         tipo := trim (tipo);
         if (tipo = 'application/xml') or (tipo = 'application/xhtml+xml') or
            (tipo = 'application/xhtml') then tipo := 'text/html';

         p := pos (';', tipo);
         if p <> 0 then tipo := copy (tipo, 1, p-1);

         if tipo = 'text/plain' then
             checaTipoTexto (tipo, nomeTemp);      { as vezes vem errado, e' realmente html }

         if tipo = 'text/html' then
             begin
                leituraInterativa (nomeTemp, novaPagina, novoMetodo, voltando);

                if novaPagina <> '' then
                     begin
                         if wherex <> 0 then writeln;
                         textBackGround (RED);
                         if falarCarregamento then
                             mensagem ('WBTRAPAG', 0)   {'Trazendo página'}
                         else
                             write (pegaTextoMensagem ('WBTRAPAG'));   {'Trazendo página'}
                         textBackGround (BLACK);
                         writeln (' ',  novaPagina);

                         tit := 'WEBVOX Buscando ' + novaPagina;
                         setWindowText (crtWindow, @tit[1]);

                         if not trazerPagina (novaPagina, novoMetodo) then
                             novaPagina := ''
                         else
                             begin
                                 linhaAtual := 1;    {faltou verificar se é fragmento}
                                 emRefer := false;
                             end;
                     end;
             end
         else
             chamaLeitor (tipo, nomeTemp);

    until (novaPagina = '') or (tipo <> 'text/html');
    writeln;
    invertColorMask := 0;
end;

end.
