{--------------------------------------------------------}
{              Televox - configuração da base
{--------------------------------------------------------}

unit telconf;

interface
uses windows, dvwin, dvcrt, telVars, teltela, telItem, telUtil, telMsg;

procedure configura;

implementation

{--------------------------------------------------------}
{               Mostra as opcoes de configuracao
{--------------------------------------------------------}

procedure mostraOpConf;
begin
    limpaTela;
    mensagem ('TVAJC1', 1);  {'CONTROL-ENTER - abre espaço para um novo campo antes desse'}
    mensagem ('TVAJC2', 1);  {'CONTROL-CIMA  - move campo para cima'}
    mensagem ('TVAJC3', 1);  {'CONTROL-BAIXO - move campo para baixo'}
    mensagem ('TVAJC4', 1);  {'F6 - altera som e impressão deste campo'}
    mensagem ('TVAJC5', 1);  {'F7 - remove campo inclusive as informações de todos os registros'}
    mensagem ('TVAJC6', 1);  {'ESC - termina'}
    mensagem ('TVTECENT', 1);{'Tecle enter'}

    repeat waitMessage until keypressed;
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{               Inicia a tela da configuração
{--------------------------------------------------------}

procedure iniciaCampos;
begin
    gotoxy (1, 24);
    clreol;
    msgBaixo ('TVEDICAM', ''); {'Use as setas e editore os nomes dos campos. F9 mostra opções.'}
end;

{--------------------------------------------------------}
{               Troca o nome dos campos
{--------------------------------------------------------}

procedure editaCampo (i: integer);
var c: char;
    s: string;

label sai;
begin
    gotoxy (1, 24);
    clreol;
    mensagem ('TVEDNOCA', 0); {'Edite o nome do campo'}
    s := tabTexto[i];
    sintetiza (s);
    c := sintEdita (s, 1, 25, 15, true);
    if (c = ESC) or (s = '') then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            goto sai;
        end
    else
        begin
            s := semAcentos(s);
            tabTexto[i]   := s;
            tabFala[i]    := 'TV' + s;
            tabMalaDir[i] := '[' + s + ']';
        end;

    gotoxy (1, 24);
    clreol;
    mensagem ('TVINSOCA', 0); {'Informe o nome do arquivo do som do campo'}
    s := tabFala[i];
    sintetiza (s);
    c := sintEdita (s, 1, 25, 9, true);
    if c = ESC then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            goto sai;
        end
    else
        tabFala[i] := semAcentos (s);

    gotoxy (1, 24);
    clreol;
    mensagem ('TVEDNOMD', 0); {'Edite o nome da mala direta'}
    s := tabMalaDir[i];
    sintetiza (s);
    c := sintEdita (s, 1, 25, 10, true);
    if (c = ESC) or (s = '') then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            goto sai;
        end
    else
        tabMalaDir[i] := semAcentos (s);

    sintSom ('TVOK');
sai:
    iniciaCampos;
    liga;
end;

{--------------------------------------------------------}
{               Cria um novo campo na agenda
{--------------------------------------------------------}

procedure novoCampo (nc: integer);
var i, postab: integer;
    s: string;
begin
    if (numCampos + 1) > MAXCAMPOS then
        begin
            sintBip;
            exit;
        end;

    for i := numCampos downto nc do
        begin
            tabTexto[i+1] := tabTexto[i];
            tabFala[i+1] := tabFala[i];
            tabMalaDir[i+1] := tabMalaDir[i];
        end;

    tabTexto[nc] := 'Novo campo';
    tabFala[nc] := '';
    tabMalaDir[nc] := '';

    for postab := 1 to cadastrados do
        begin
            listaFone[postab]^.campoCad[numCampos+1] := NIL;
            for i := numCampos downto nc do
                begin
                    s := obtemItem (i, postab);
                    atualizaItem (i+1, postab, s);
                end;
            atualizaItem (nc, postab, '');
        end;
    numCampos := numCampos + 1;
    if fundo  + 1 <= FUNDOPADRAO then fundo := fundo + 1;
    desliga;
    imprime (false);
    editaCampo (nc);
end;

{--------------------------------------------------------}
{               Move campo para baixo
{--------------------------------------------------------}

procedure campoParaBaixo (nc: integer);
var s, s1, s2: string;
    postab: integer;
begin
    sintClek;

    s := tabTexto[nc+1];
    tabTexto[nc+1] := tabTexto[nc];
    tabTexto[nc] := s;

    s := tabFala[nc+1];
    tabFala[nc+1] := tabFala[nc];
    tabFala[nc] := s;

    s := tabMalaDir[nc+1];
    tabMalaDir[nc+1] := tabMalaDir[nc];
    tabMalaDir[nc] := s;

    for postab := 1 to cadastrados do
        begin
            s1 := obtemItem (nc, postab);
            s2 := obtemItem (nc+1, postab);
            atualizaItem (nc, postab, s2);
            atualizaItem (nc+1, postab, s1);
        end;
    msgBaixo ('TVMOVIDO', '');
end;

{--------------------------------------------------------}
{               Move campo para cima
{--------------------------------------------------------}

procedure campoParaCima (nc: integer);
var s, s1, s2: string;
    postab: integer;
begin
    sintClek;

    s := tabTexto[nc-1];
    tabTexto[nc-1] := tabTexto[nc];
    tabTexto[nc] := s;

    s := tabFala[nc-1];
    tabFala[nc-1] := tabFala[nc];
    tabFala[nc] := s;

    s := tabMalaDir[nc-1];
    tabMalaDir[nc-1] := tabMalaDir[nc];
    tabMalaDir[nc] := s;

    for postab := 1 to cadastrados do
        begin
            s1 := obtemItem (nc, postab);
            s2 := obtemItem (nc-1, postab);
            atualizaItem (nc, postab, s2);
            atualizaItem (nc-1, postab, s1);
        end;
    msgBaixo ('TVMOVIDO', '');
end;

{--------------------------------------------------------}
{               Remove um campo de toda a agenda
{--------------------------------------------------------}

procedure removeCampo (nc: integer);
var i, postab: integer;
    s: string;
    c: char;
begin
    msgBaixo ('TVCNFRMC', ''); {'Confirma remoção deste campo e de todos seus registros?'}
    c := readkey;
    if upcase(c) <> 'S' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            exit;
        end;

    if nc < numCampos then
        begin
            for i := nc+1 to numCampos do
                begin
                    tabTexto[i-1] := tabTexto[i];
                    tabFala[i-1] := tabFala[i];
                    tabMalaDir[i-1] := tabMalaDir[i];
                end;

            for postab := 1 to cadastrados do
                begin
                    for i := nc+1 to numCampos do
                        begin
                            s := obtemItem (i, postab);
                            atualizaItem (i-1, postab, s);
                        end;
                    atualizaItem (numCampos, postab, '');
                end;
        end;
    numCampos := numCampos - 1;
    if numCampos < (fundo - topo + 1) then         fundo := numCampos + topo - 1;
    desliga;
    posFolheia := posFolheia -1;
    if posFolheia < TOPO then posFolheia := TOPO;
        posAtualFolheia := posAtualFolheia - 1;
    if posAtualFolheia <= 0 then posAtualFolheia := 1;
    imprime (false);
    liga;
    iniciaCampos;
end;

{--------------------------------------------------------}
{               Modulo principal da configuracao da base
{--------------------------------------------------------}

procedure configura;
var nc: integer;
    editando: boolean;
    s: string;
    c: char;

    procedure sobe;
    begin
        nc := nc - 1;
        if nc <= 0 then
            begin
                sintBip;
                nc := 1;
            end
        else
            recua (1);
    end;

    procedure desce;
    begin
        nc := nc + 1;
        if nc > numCampos then
            begin
                sintBip;
                nc := numCampos;
            end
        else
            avanca (1);
    end;


begin
    limpaTela;
    campoConfigura := true;

    posFolheia := TOPO;
    posAtualFolheia := 1;
    imprime (FALSE);
    liga;
    iniciaCampos;

    editando := true;
    nc := 1;
    while editando do
        begin
            limpaBuftec;
            s := tabTexto[nc];
            if (tabFala[nc] <> '') and (existeArqSom (tabFala[nc])) then
                sintSom (tabFala[nc])
            else
            if s <> '' then
                sintetiza (s);
            c := sintEdita (s, 1, 24, 15, true);
            case c of
                ESC:    editando := false;
                F9: begin
                        mostraOpConf;
                        limpaTela;
                        imprime (false);
                        liga;
                        iniciaCampos;
                    end;

                CTLENTER:   novoCampo (nc);
                F6:         editaCampo (nc);
                F7:         removeCampo (nc);

                CTLDOWN:    if nc < numCampos then
                                 begin
                                     campoParaBaixo (nc);
                                     desce;
                                 end
                            else
                                 sintBip;

                CTLUP:      if nc > 1  then
                                begin
                                     campoParaCima (nc);
                                     sobe;
                                end
                            else
                                 sintBip;

                CIMA:       sobe;

                BAIX, ENTER:  desce;

                PGUP, CTLPGUP:  begin
                                    nc := 1;
                                    vaiParaPrimeiro;
                                end;
                PGDN, CTLPGDN:  begin
                                    nc := numCampos;
                                    vaiParaUltimo;
                                end;
            else
                msgBaixo ('TVEDICAM', '');
                    {'Use as setas e editore os nomes dos campos. F9 mostra opções.'}
            end;
        end;

    campoConfigura := false;
    limpaTela;
    msgBaixo ('TVOKCONF', ''); {'Ok, configurado'}
    fundo := FUNDOPADRAO;
    if numCampos < (fundo - topo + 1) then         fundo := numCampos + topo - 1;
end;

end.
