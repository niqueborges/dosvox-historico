{--------------------------------------------------------}
{
{   Programa FichaVox - Fichario de Arquivos
{
{   Autor:  Neno' Henrique da Cunha Albernaz
{
{   Em Julho de 2001
{
{   Incluir no \windows\dosvox.ini
{   [FICHAVOX]
{   DIRFICHAVOX=@\som\fichavox
{   DIRPADRAO=@\fichario
{
{--------------------------------------------------------}

program fichavox;

uses dvcrt, dvwin, windows, dvForm, sysUtils,
     fvMsg, fvVars, fvDir, fvArqui, fvFolhe, fvSelect, fvImpri,
fvMontFi;

{----------------------------------------------------------------------}
{Inicializa tela principal , abrindo o diretório padrão declarado no dosvox.ini}
{ caso não exista , ele cria (Fichario padrão).}
{----------------------------------------------------------------------}

procedure inicializa;
var
    dirAtual: string;
    dir: string;
begin
    dir := sintambiente ('FICHAVOX', 'DIRFICHAVOX');
    if dir = '' then
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\fichavox';
    sintInic (0, dir);
    sintFalaPont := false;

    clrscr;
    textBackground (BLUE);
    mensagem ('FVINI', 0); {Programa FichaVox versão }
    write(VERSAO);
    sintSoletra (VERSAO);
    mensagem ('FVNCEUFR', 1); { - NCE/UFRJ}
    textBackground (BLACK);
    writeln;

    delay (200);
    dirAtual := sintAmbiente ('FICHAVOX', 'DIRPADRAO');
    if dirAtual = '' then
        dirAtual := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\fichario';
    {$i-}chdir (dirAtual);{$i+}
    if ioresult <> 0 then
        begin
            {$I-} mkdir (dirAtual);  {$I+}
            if ioresult <> 0 then;
            {$I-} chDir (dirAtual);  {$I+}  {se diretório padrão não puder ser criado, ignora }
            if ioresult <> 0 then;
        end;
    posAtual := 1;
end;

{----------------------------------------------------------------------}
{Chamada de salvamento do fichario.   }
{----------------------------------------------------------------------}

procedure guardar_ou_nao;
var
    opc: char;

begin
    mensagem ('FVDESGRA',0);{Deseja gravar as fichas?}
    opc := sintReadkey;
    writeln;
    if numFichas = 0 then exit;
    if upcase(opc) <> 'N' then
        begin
            guardar_fichas;
        end;
end;

{----------------------------------------------------------------------}
{Remove fichas selecionadas ou ultima lida.}
{----------------------------------------------------------------------}

procedure removerSelecionado;
var
    opc: char;
    naoSelecionada: boolean;
    i: integer;

begin
    naoSelecionada := TRUE;
    mensagem ('FVATUSEL',0);{'Remover ficha: Selecionadas ou Ultima lida.'}
    opc := upcase (readkey);
    writeln;
    if opc = 'U' then
        begin
            removeEste (TRUE);
            naoSelecionada := FALSE;
        end
    else
    if opc = 'S' then
        begin
            for i := numFichas downto 1 do
                begin
                    if fichario[i]^.selecionado then
                        begin
                            removeEste (TRUE);
                            naoSelecionada := FALSE;
                        end;
                end;
        end
    else
        begin
            mensagem ('FVDESIST',1);
            naoSelecionada := FALSE;
        end;

    if naoSelecionada then
        mensagem ('FVNAOSEL',1);

end;

{----------------------------------------------------------------------}
{pergunta se deseja fechar o fichavox, caso positivo, guarda as fichas}
{no FICHAS.IND e descarrega a memória.}
{----------------------------------------------------------------------}

procedure finaliza (var opc: char);
var
    dirAtual: shortString;
    s: string;
begin
    textBackGround (red);
    mensagem ('FVTEMCER', 0);{Tem certeza que deseja sair?}
    textBackGround (black);
    opc := upcase (readkey);
    writeln;
    if opc = 'S' then
        begin
            if numFichas > 0 then
                begin
                    guardar_fichas;
                    descarregar_fichas;
                end;

            getDir (0, dirAtual);
            s := dirAtual;
            sintGravaAmbiente('FICHAVOX', 'DIRPADRAO', s);

            mensagem ('FVFIM',1); {Fim do FichaVox'}
            opc := ESC;
        end
    else
        opc := 'N';
end;
//neno

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

procedure ajudaPrincipal;
begin
    writeln;
    mensagem ('FVOPC', 1); {'As opções do FichaVox são'}
     writeln;
            mensagem ('FVAJPP1', 1); {N-Nova ficha}
            mensagem ('FVAJPP2', 1); { S-Selecionar}
            mensagem ('FVAJPP3', 1); {F folhear}
            mensagem ('FVAJPP4', 1); {C-Configurar modelo}
            mensagem ('FVAJPP5', 1); {A-Arquivo externo}
            mensagem ('FVAJPP6', 1); {X-Indexar arquivo}
            mensagem ('FVAJPP7', 1); {M-Montar fichario apartir de diretório}
            mensagem ('FVAJPP8', 1); {I-Imprimir ficha}
            mensagem ('FVAJPP9', 1); {T-Trocar fichario}
    mensagem ('FVAJPP16', 1); {  ESC-Terminar programa}
    mensagem ('FVAJPP17', 1);  {'    Use as setas para selecionar ou conhecer todas as opções'}
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

procedure selSetasPrincipal(var c, c2: char);

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, cadeiaMsg (msg));
    end;

procedure tabLetrasPrincipal (k: integer);
begin
    if k = 1 then c := 'N'
    else
    if k = 2 then c := 's'
    else
    if k = 3 then c := 'F'
    else
    if k = 4 then c := 'C'
    else
    if k = 5 then c := 'A'
    else
    if k = 6 then c := 'X'
    else
    if k = 7 then c := 'M'
    else
    if k = 8 then c := 'I'
    else
    if k = 9 then c := 'T'
    else
    if k = 10 then
    begin
        c := #0;
        c2 := F2;
    end
    else
    if k = 11 then
    begin
        c := #0;
        c2 := F3;
    end
    else
    if k = 12 then
    begin
        c := #0;
        c2 := F5;
    end
    else
    if k = 13 then
    begin
        c := #0;
        c2 := F6;
    end
    else
    if k = 14 then
    begin
        c := #0;
        c2 := F7;
    end
    else
    if k = 15 then
    begin
        c := #0;
        c2 := F9;
    end
    else
    if k = 16 then c := #27;
end;

var n: integer;

begin
    popupMenuCria (wherex, wherey-14, 50, 16, MAGENTA);
    MenuAdiciona ('FVAJPP1'); {N-Nova ficha}
    MenuAdiciona ('FVAJPP2'); { S-Selecionar}
    MenuAdiciona ('FVAJPP3'); {F folhear}
    MenuAdiciona ('FVAJPP4'); {C-Configurar modelo}
    MenuAdiciona ('FVAJPP5'); {A-Arquivo externo}
    MenuAdiciona ('FVAJPP6'); {X-Indexar arquivo}
    MenuAdiciona ('FVAJPP7'); {M-Montar fichario apartir de diretório}
    MenuAdiciona ('FVAJPP8'); {I-Imprimir ficha}
    MenuAdiciona ('FVAJPP9'); {T-Trocar fichario}
    MenuAdiciona ('FVAJPP10'); {F2 Gravar Fichario}
    MenuAdiciona ('FVAJPP11'); {F3-Trocar fichario}
    MenuAdiciona ('FVAJPP12'); {F5-Configurar modelo}
    MenuAdiciona ('FVAJPP13'); {'F6-Informar fichario}
    MenuAdiciona ('FVAJPP14'); {'F7-Informar nUmero de Fichas}
    MenuAdiciona ('FVAJPP15'); {F9 Imprimir ficha}
    MenuAdiciona ('FVAJPP16'); {  ESC-Terminar programa}

    n := popupMenuSeleciona;
    if n > 0 then
         tabLetrasPrincipal(n);
    writeln;
end;

var opcIniImpri: boolean;
//neno
begin
    inicializa;
    abre_diretorio;
    tipoOrdenacao := 'N';
    carregar_fichas;
    opcIniImpri := TRUE;

    repeat
        textBackground (BLUE);
        mensagem ('FVPERGUN', 0); {FichaVox qual sua opção, F1 ajuda}
        textBackground (BLACK);

        sintLeTecla (c, c2);
        writeln;
        if (c = #0) and (c2 = F1) then
            ajudaPrincipal
        else
        if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                selSetasPrincipal (c, c2);

        if c = #0 then
            case c2 of
               F2: guardar_ou_nao;
               F3: begin
                        if numFichas > 0 then
                            begin
                                guardar_fichas;
                                descarregar_fichas;
                            end;
                        abre_diretorio;
                        carregar_fichas;
                   end;
               F5: configurarArquivoModelo;
               F6: diretorio_atual;
               F7: fala_numFichas;
               F9: begin
                        if opcIniImpri then
                            trataImpressao
                        else
                            imprimirSelecionadas;
                   end;
            end
        else
            case upcase(c) of
               'N': nova_ficha;
               'S': begin
                        opcIniImpri := FALSE;
                        seleciona;
                    end;

               'C': configurarArquivoModelo;
               'F': begin
                        folhear_fichas;
                        clrscr;
                        opcIniImpri := FALSE;
                    end;

               'A': imporArqParaFicha;
               'I': begin
                        if opcIniImpri then
                            trataImpressao
                        else
                            imprimirSelecionadas;
                    end;

               'R': removerSelecionado;
               'M': begin
                        if numFichas > 0 then guardar_fichas;
                        montarFichario;
                    end;
               'X': indexarArquivo;
               'T': begin
                        if numFichas >0 then
                            begin
                                guardar_fichas;
                                descarregar_fichas;
                            end;
                        abre_diretorio;
                        carregar_fichas;
                    end;

                        #$0d: ;
                   #$1b: finaliza (c)
            else
               mensagem ('FVERROPC',1); {Opcao errada: aperte F1 para ajuda}
        end;
        while keypressed do readkey;
    until c = ESC;

    sintFim;
    doneWinCrt;

end.
