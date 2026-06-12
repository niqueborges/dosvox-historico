{-------------------------------------------------------------}
{
{    Programa CDMP3
{
{    Autores : Bernard Condorcet e Antonio Borges
{
{    Em 26/07/2007
{
{-------------------------------------------------------------}

program CDMP3;

uses dvcrt, dvwin, dvForm, videoVox, dvwav, sysutils,
    cdDir, cdSelec, cdConfig, cdScript, cdRecord, cdConver, cdDivid, cdUtil, cdVars, cdMsg,
    windows;

{--------------------------------------------------------}

procedure finaliza;
begin
    if sintFalarTudo then
        begin
            sintSom ('CDSAI');
            mensagem ('CDFIM', 0);  {'Fim do programa'}
        end;

    sintFim;
    doneWincrt;
end;

{--------------------------------------------------------}

procedure testaDirArq;
var infDirTrab: char;
begin

    if not geraAuto then
    begin
        writeln;
        mensagem ('CDINFTRA', 1); {'Informe o diretório de trabalho')}
        delay (100);
        mensagem ('CDPREENT', 1); {'Pressionando ENTER usarei o padrão')}
        infDirTrab:= sintEditaCampo (dirTexto, 1, wherey, 255, 80, true);
        if dirTexto = '' then
            getDir (0, dirTexto);
        if (infDirTrab = ESC) or (dirTexto = '') then
            finaliza;
    end;

    if not trocaDir(dirTexto) then
        begin
            sintBip; sintBip;
            writeln;
            mensagem ('CDPROTDT', 1); {'Problemas para trabalhar com o diretório de texto')}
            finaliza;
        end
        else
        begin
            writeln;
            mensagem ('CDIRETRA', 0); {'OK, irei trabalhar em : ')}
            sintWriteln (dirTexto);
        end;

    if not selNomArqs(dirTexto, 'P') then
        semArqPar:= true;

    if not selNomArqs(dirTexto, 'T') then
        semArqTxt:= true
    else
    begin
    delay (100);
    writeln;
    mensagem ('CDTOTCON', 0); {'Total de arquivo(s) à converter --- ')}
    sintWriteInt (numArqs);
    writeln; writeln;
    end;

    limpaBufTec;

end;

{--------------------------------------------------------}

procedure geraArqSom;
var
    maxArqs, erro: integer;
    opcao: char;
label automatiza, interrompe, cancela;
begin

    if not sapiOk then
        begin
            val (sintAmbiente('CDMP3', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
            if erro <> 0 then confTipoSapi := 3;
            val (sintAmbiente('CDMP3', 'NUMEROSAPI'), confNum, erro);
            if erro <> 0 then confNum:= 1;
            val (sintAmbiente('CDMP3', 'VELOCIDADESAPI'), confVeloc, erro);
            if erro <> 0 then confVeloc:= 0;
            val (sintAmbiente('CDMP3', 'TONALIDADESAPI'), confTonal, erro);
            if erro <> 0 then confTonal:= 0;
            sapiOK:= true;
            alterouSapi:= true;
        end;

    if geraAuto then
        goto automatiza;

    if (semArqTxt) and (semArqPar) then
        begin
            mensagem ('CDDIRNAO', 1); {'O diretório padrão não contém nenhum arquivo a converter')}
            goto cancela;
        end;

    if not listNomArqs then
        goto cancela
    else
        begin
            if dirSom = '' then
                dirSom:= 'WAVMP3';

            writeln;
            mensagem ('CDOSARSE', 0); {'Os arquivos convertidos serão gerados em : ')}
            sintWriteln (dirTexto + '\' + dirSom);
            writeln;
            while sintFalando do waitMessage;
        end;

    geraMp3:= false;

    mensagem ('CDDIGW3', 0); {'Digite W para converter no formato WAV ou 3 para MP3 : ')}
    opcao:= popupMenuPorLetra ('W3PD');

    if opcao = 'W' then
        mensagem ('CDCONWAV', 1) {'OK, irei converter no formato WAV')}
    else
    if opcao in ['3', 'P', ENTER] then
        begin
            mensagem ('CDCONMP3', 1); {'OK, irei converter no formato MP3')}
            geraMp3:= true;
        end
    else
    if opcao in [ESC, 'D'] then
        begin
            mensagem ('CDDESIST', 1);
            goto cancela;
        end
    else
        begin
            mensagem ('CDOPCAN', 1); {'Opção inválida, operação cancelada')}
            goto cancela;
        end;

    automatiza:

    dirSom:= dirTexto + '\' + dirSom;
    maxArqs:= numArqs;
    numArqs:= 0;

    while numArqs <> maxArqs do
    begin

        numArqs:= numArqs + 1;

        if not fileExists (dirTexto + '\' + nomeArqTxt[numArqs]) then
            begin
                sintBip; sintBip;
                mensagem ('CDPROABE', 1); {'Problemas na abertura do arquivo de texto')}
                goto cancela;
            end;

        if informa_avisos then
        begin
            writeln;
            mensagem ('CDCONVER', 0); {'Convertendo : ')}
            sintWriteln (nomeArqTxt[numArqs]);
            writeln;
            while sintFalando do waitMessage;
        end;

        if not trocaDir (dirSom) then
            finaliza;

        transfTxtSom;

        if not trocaDir (dirTexto) then
            finaliza;

        if keypressed then
        begin
        sintBip; sintBip;
            mensagem ('CDUMATEC', 1); {'Uma tecla foi pressionada durante o processo de conversão');}
            delay (100);
            mensagem ('CDMODPAU', 1); {'Modo pausa ativado, ESC cancela'}
            opcao:= popupMenuPorLetra ('C' + ESC);

            if opcao = ESC then
            begin
                mensagem ('CDDCC', 0); {'Deseja cancelar a conversão do(s) arquivo(s) ? ');}
                opcao:= popupMenuPorLetra ('SN');

                if opcao = 'S' then
                begin
                    mensagem ('CDOK', 1);
                    finaliza;
                end;
            end
        else
            limpaBufTec;
            mensagem ('CDPAUDES', 1); {'Modo pausa desativado'}
        end;

//        if remDinamic then
//            if maiuscAnsi (copy (nomeArqTxt[numArqs], length (nomeArqTxt[numArqs])-3, 4)) = '.PAR' then
//            begin
//                assign (arqTxt, dirTexto + '\' + nomeArqTxt[numArqs]);
//                {$I-} erase (arqTxt); {$I+}
//                if ioResult <> 0 then;
//            end;

        writeln;
        writeln ('Verificando a existência de outro arquivo');
        writeln;

    end; //Relativo ao while

    removePartesDivididas;

    mensagem ('CDULTARQ', 1); {'Último arquivo')}
    mensagem ('CDCONSUC', 1); {'Conversão bem sucedida')}

    keyStopsWave := true;

    interrompe:

//    if remDinamic then
//    begin
//        if not selNomArqs(dirTexto, 'P') then
//            semArqPar:= true;
//        if not selNomArqs(dirTexto, 'T') then
//            semArqTxt:= true
//    end;

    cancela:

//    remDinamic:= false;
    setWindowTitle ('CDMP3');

end;

{--------------------------------------------------------}

procedure inicializa;
var jan: integer;
    n_l: string;
    erro: integer;
begin

    jan := findWindowEx(0, 0, 'dvwincrt', 'CDMP3');
    if jan <> 0 then
        halt;

    clrscr;
    setWindowText (crtWindow, 'CDMP3');

    SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));

    textBACKGROUND (BLUE);
    write (pegaTextoMensagem('CDINIC')); {'CDMP3 VOX - V.'}
    write (versao);
    textBackground (BLACK);
    writeln;
    writeln;

    if sintFalarTudo then
        begin
            mensagem ('CDINIC', -1); {'CDMP3 VOX - V.'}
            sintetiza (versao);
        end
    else
        mensagem ('CDMP3VOX', -1); {'CDMP3 VOX'}

    if not sapiPresente then
    begin
        textBackground (RED);
        mensagem ('CDSAPDOS', 1); {'Fala SAPI não está ativada no DOSVOX')}
        textBackground (BLACK);
        sapiOk:= false;
        ativouComSapi:= false;
    end
    else
    begin
        sapiOk:= true;
        ativouComSapi:= true;
    end;

    //Valor inicial das variáveis

    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');

    dirTexto:= sintAmbiente ('CDMP3', 'DIRTXT');
    if dirTexto = '' then
        getDir (0, dirTexto);

    dirSom:= '';

    dirScript:= dirDosvox + '\scripts\cdmp3';

    unidadeCd:= sintAmbiente ('CDMP3', 'CD', 'D');

    val(sintAmbiente('TRADUTOR', 'VELOCIDADE'), velocidadeDOSVOX, erro);
    if erro <> 0 then
        velocidadeDOSVOX:= 3;

    val (sintAmbiente('SERVFALA', 'TIPOSAPI'), confTipoSapi, erro);
    if erro <> 0 then confTipoSapi := 3;

    informa_avisos:= upcase(sintAmbiente ('CDMP3', 'CLEK', 'SIM')[1]) = 'S';
    introduz_efeito:= upcase(sintAmbiente ('CDMP3', 'COMEFEITO', 'SIM')[1]) = 'S';
    if confTipoSapi = 4 then introduz_efeito:= false;

    introduz_silencio:= upcase(sintAmbiente ('CDMP3', 'COMSILENCIO', 'NAO')[1]) = 'S';
    introduz_cabec:= upcase(sintAmbiente ('CDMP3', 'ESCREVECABEC', 'SIM')[1]) = 'S';
    qBaixa:= sintAmbiente ('CDMP3', 'QBAIXA', '--abr 40');
    qAlta:= sintAmbiente ('CDMP3', 'QALTA', '--abr 80');
    qMaxima:= sintAmbiente ('CDMP3', 'QMAXIMA', '--abr 160');

    qualidaMp3:= primeiraLetra(sintAmbiente ('CDMP3', 'QUALIDADEMP3', 'A'));
    if qualidaMp3 = 'B' then
        qualidaMp3:= qBaixa
    else
    if qualidaMp3 = 'M' then
        qualidaMp3:= qMaxima
    else
        qualidaMp3:= qAlta;

    nomeEfeitoWav:= sintAmbiente ('CDMP3', 'SOMEFEITO');
    if (nomeEfeitoWav = '') or (not fileExists (nomeEfeitoWav)) then introduz_efeito:= false;

    semArqTxt:= false;
    semArqPar:= false;
    remTotArqs:= false;
//    remDinamic:= false;
    geraAuto:= false;
    alterouSAPI:= false;
    geraNovoDir:= false;

{--------------------------------------------------------}

    if paramCount <> 0 then
    begin

        if paramStr(1) = '*' then
        exit;

//        if not sapiOK then
//            finaliza;

        getDir (0, dirTexto);
        geraAuto:= true;

        numArqs:= 1;
        nomeArqTxt[numArqs]:= paramStr(1);

        n_l:= sintAmbiente ('CDMP3', 'QUEBRARLINHA', '100');
        val (n_l, numLinhas, erro);
        if (erro <> 0) or (numLinhas <= 0)  then
            numLinhas:= 100;

        divideArq;
        geraMp3:= true;
        geraArqSom;
        geraAuto:= false;
        finaliza;
    end;

end;

{--------------------------------------------------------}

procedure menuCDMP3;
begin

    sintSom ('CDMENU');
    delay (100);
    mensagem ('CDOP', 1); {'Opções nas teclas:'}
    delay (100);
    mensagem ('CDGERCD', 1);  {'  G   Gerar CD'}
    mensagem ('CDGERSOM', 1);  {'  C   Converter para audio'}
    mensagem ('CDCONQUA', 1);  {'  A   Ajustar saída'}
    mensagem ('CDFORARQ', 1);  {'  F   Formatar arquivo'}
    mensagem ('CDDIVARQ', 1);  {'  D   Dividir arquivo'}
    mensagem ('CDLIS', 1);  {'  L   Listar selecionados'}
    mensagem ('CDMOD', 1);  {'  M   Modificar selecionados'}
    mensagem ('CDVERVOZ', 1); {'  V   Verificar vozes instaladas')}
    mensagem ('CDTESARQ', 1); {'  T   Testar voz em arquivo')}
    mensagem ('CDCTRLI', 1);  {'  I   Informações sobre o projeto'}
    mensagem ('CDSCRIPT', 1);  {'  E   Executar script'}

    sintBip; sintBip;
    delay (100);
    mensagem ('CDUSECON', 1); {'Utilizando CONTROL')}
    delay (100);
    mensagem ('CDCTRLG', 1); {'CTRL+G  Gravar novo projeto')}
    mensagem ('CDCTRLD', 1); {'CTRL+D  Dividir alternando vozes')}
    mensagem ('CDCTRLC', 1); {'CTRL+C  Copiar esse projeto')}
    mensagem ('CDCTRLN', 1); {'CTRL+N  Consultar manual')}

    limpaBufTec;

end;

{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

{--------------------------------------------------------}

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string [11] = 'gcafdlmvtie';

begin
    garanteEspacoTela(16);
    popupMenuCria (wherex, wherey, 50, 16, MAGENTA);
    MenuAdiciona ('CDGERCD');  {'  G   Gerar CD'}
    MenuAdiciona ('CDGERSOM');  {'  C   Converter para audio'}
    MenuAdiciona ('CDCONQUA');  {'  A   Ajustar saída'}
    MenuAdiciona ('CDFORARQ');  {'  F   Formatar arquivo'}
    MenuAdiciona ('CDDIVARQ');  {'  D   Dividir arquivo'}
    MenuAdiciona ('CDLIS');  {'  L   Listar selecionados'}
    MenuAdiciona ('CDMOD');  {'  M   Modificar selecionados'}
    MenuAdiciona ('CDVERVOZ'); {'  V   Verificar vozes instaladas')}
    MenuAdiciona ('CDTESARQ'); {'  T   Testar voz em arquivo')}
    MenuAdiciona ('CDCTRLI');  {'  I   Informações sobre o projeto'}
    MenuAdiciona ('CDSCRIPT');  {'  E   Executar script'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}

procedure trataTecladoCDMP3;
var c1, c2: char;
    processando: boolean;
    trocaDirTexto: char;
    erro: integer;
label executa;
begin

    processando := true;
    while (processando)  do
        begin
            delay (200);
            textBackground (BLUE);
            mensagem ('CDQUALOP', 0);  {'Qual sua opção ? '}
            textBackground (BLACK);

            sintLeTecla (c1, c2);
            writeln;
            if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasOpcao;
                    goto executa;
                end
            else
            if (c1 = #0) and (c2 = F1) then
                menuCDMP3
            else
            if (c1 = #0) and (c2 = HOME) then
                begin
                    mensagem ('CDINIC', -1); {'CDMP3 VOX - V.'}
                    sintetiza (versao);
                end
            else
            if (c1 = #0) and (c2 = F9) then
               leitorDeTela
           else
executa:
               case upcase(c1) of
                   'L': listNomArqs;
                   'F': formatArq;
                   'D': divideArq;
                   'M': modificaSelec;
                   'A': ajustarSaida;
                   'C': geraArqSom;
                   'E': executaCMD;
                   'I': informaProjeto;
                   'G': geraCd;
                   'T': testSapi;
                   'V': ouvirSapi;

                   ^N: lerManual;
                   ^D: begin
                       formatEsp:= true;

                       if (not ativouComSapi) or (alterouSapi) then
                           val (sintAmbiente('SERVFALA', 'TIPOSAPI'), tipEsp, erro)
                       else
                           val (sintAmbiente('CDMP3', 'TIPOSAPI'), tipEsp, erro);
                       if erro <> 0 then formatEsp:= false;

                       if (not ativouComSapi) or (alterouSapi) then
                           val (sintAmbiente('SERVFALA', 'VOZ'), numEsp, erro)
                       else
                           val (sintAmbiente('CDMP3', 'NUMEROSAPI'), numEsp, erro);
                       if erro <> 0 then formatEsp:= false;

                       if (not ativouComSapi) or (alterouSapi) then
                           val (sintAmbiente('SERVFALA', 'VELOCIDADE'), velEsp, erro)
                       else
                           val (sintAmbiente('CDMP3', 'VELOCIDADESAPI'), velEsp, erro);
                       if erro <> 0 then formatEsp:= false;

                       if (not ativouComSapi) or (alterouSapi) then
                           val (sintAmbiente('SERVFALA', 'TOM'), tonEsp, erro)
                       else
                          val (sintAmbiente('CDMP3', 'TONALIDADESAPI'), tonEsp, erro);
                       if erro <> 0 then formatEsp:= false;

                       if formatEsp then
                       begin
                           divideArq;
                           formatEsp:= false;
                           end
                       else
                           mensagem ('CDPARINV', 1); {'Divisão cancelada, parâmetros inválidos'}
                   end;
//                   ^R: begin
//                       remDinamic:= not remDinamic;
//                       writeln;
//                       if not remDinamic then
//                           mensagem ('CDREMDES', 1) {'Remoção desativada')}
//                       else
//                           mensagem ('CDREMATI', 1); {'Remoção ativada')}
//                       end;
                   ^C: begin
                       mensagem ('CDCAMCOM', 0); {'Informe o caminho completo do diretório destino : '}
                       sintReadln (dirCopia);
                       if dirCopia <> '' then
                       begin
                           {$I-} chDir (dirCopia); {$I+}
                           if ioResult <> 0 then
                               {$I-} mkDir (dirCopia); {$I+}
                               if ioResult <> 0 then
                                   mensagem ('CDPRODIC', 1) {'Problemas no disco, não será possível efetuar a cópia'}
                               else
                                   if trocaDir (dirTexto) then
                                       copiaDirPadrao;
                       end
                       else
                           mensagem ('CDDESIST', 1);
                   end;
                   ^G: begin
                       dirBackup:= dirTexto;
                       mensagem ('CDNOVDIR', 1); {'Informe o novo diretório : ')}
                       trocaDirTexto:= sintEditaCampo (dirTexto, 1, wherey, 255, 80, true);
                       writeln;
                       if (trocaDirTexto = ESC) or (dirTexto = '') then
                       begin
                           dirTexto:= dirBackup;
                           mensagem ('CDDESIST', 1);
                       end
                           else
                               if trocaDir (dirTexto) then
                               begin
                                   geraNovoDir:= true;
                                   mensagem ('CDOK', 1);
                                   informaProjeto;
                                   geraCd;
                               end;
                   end;

                   ESC:  processando := false;
                   #$0d: ;
               else
                   mensagem ('CDOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

{--------------------------------------------------------}

begin

    inicializa;
    testaDirArq;
    trataTecladoCDMP3;
    finaliza;

end.
