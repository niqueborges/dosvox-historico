{--------------------------------------------------------}
{          Fichavox - procedimentos de folheamento
{--------------------------------------------------------}

unit fvFolhe;
interface
uses windows, dvcrt, dvwin, sysUtils, dvlenum, dvHora, dvArq, dvForm,
fvVars, fvMsg, fvArqui, fvDir, fvEdita, fvLerArq, fvImpri, fvExecut,
fvCopia;

procedure folhear_fichas;
procedure removeEste (arquivo: boolean);

implementation
var
    nlinhasFolheia: integer;
    ytelaFolheia: integer;

{--------------------------------------------------------}
{          escreve um nome na area de folheamento
{--------------------------------------------------------}

procedure limpaTela (item:TFicha);
const brancos = '                                                         ';
var
    s1, s2: string;
    sel: char;
begin
   clrscr;
   textBackground (BLUE);
   writeln (MSG_PROG);
   textBackground (black);
   textColor (Cyan);
   writeln (TITULO_FOLHEIA);
   textColor (LightGray);

   with item do
      begin
         s1 := copy (chave+brancos, 1, 57);
         s2 := copy (nomeArq+brancos, 1, 12);
         sel := ' ';
         if selecionado then sel := '*';

         writeln (s1 + ' ' + s2 + ' ' + sel );
      end;
   writeln;
end;

procedure tela;
var
   i: integer;
begin
   for i := 1 to 5 do
      begin
         gotoxy (1,i); clreol;
      end;
   gotoxy (1,1);

   textBackground (BLUE);
   writeln (MSG_PROG);
   textBackground (BLACK);

end;

procedure escreveNome (qual: integer; aviva: boolean);
const brancos = '                                                         ';
var
    s1, s2: string;
    sel: char;
begin
    if aviva and (qual = posAtual) then
        textColor (yellow)
    else
        textColor (lightGray);

    gotoxy (1, ytelaFolheia-posFolheia+qual);
    if qual > numFichas then
        clreol
    else
        with fichario[qual]^ do
            begin
                s1 := copy (chave+brancos, 1, 57);
                s2 := copy (nomeArq+brancos, 1, 12);
                sel := ' ';
                if selecionado then sel := '*';

                write (s1 + ' ' + s2 + ' ' + sel );
            end;

    textColor (lightGray);
    gotoxy (1, ytelaFolheia-posFolheia+qual);
end;

{--------------------------------------------------------}
{                  mostra todos os nomes
{--------------------------------------------------------}

procedure mostraTodosNomes;
var i: integer;
begin
    while posFolheia > posAtual do
        posFolheia := posFolheia-10;
    while posFolheia < posAtual-nlinhasFolheia+1 do
        posFolheia := posAtual-nlinhasFolheia+10;
    if posFolheia > numFichas then
        posFolheia := numFichas;
    if posFolheia < 1 then posFolheia := 1;

    for i := posFolheia to posFolheia+nLinhasFolheia-1 do
        escreveNome (i, true);
end;

{--------------------------------------------------------}
{  Remove uma Ficha. Recebendo TRUE apaga o arquivo      }
{  e recebendo FaLSE não apaga, apaga apenas do          }
{  FICHAS.IND, do indice.                                }
{--------------------------------------------------------}

procedure removeEste (arquivo: boolean);
var
    opc: char;
    arq: text;
    i: integer;
    s: string;

begin
    if numFichas <= 0 then exit;
    textBackGround (red);
    mensagem ('FVCNFREM',0);    {'Confirma remoção de '}
    s := fichario[posAtual]^.chave;
    sintWrite (s);

    if not (arquivo) then
        mensagem ('FVDOINDI',0){Do indice das fichas?}
    else
        write ('?');
    textBackGround (black);

    opc := upcase(readkey);
    writeln;

    if opc <> 'S' then
       begin
          msgBaixo ('FVDESIST');
          exit;
       end
    else
        begin
            if arquivo then
                begin
                    s := fichario[posAtual]^.nomeArq;
                    assign (arq, s);
                    {$I-}  erase (arq);  {$I+}
                    if ioresult <> 0 then
                        begin
                            mensagem ('FVARQNRE',1);
                            {'Erro na ficha, arquivo da ficha não removido'}
                            delay (10);
                            textBackGround (magenta);
                            mensagem ('FVRFIND',0);
                            textBackGround (black);
                            {'Deseja remover ficha com erro do registro? '}
                            opc := upcase (readkey);
                            writeln;
                            if opc <> 'S' then
                                begin
                                    mensagem ('OK',1);
                                    exit;
                                end;
                        end;
                end;

            assign (arq, 'FICHAS.IND');
            {$i-} reset (arq); {$i+}
            if ioresult <> 0 then exit
            else close (arq);

            dispose (fichario[posAtual]);
            for i := posAtual to numFichas-1 do
                fichario[i] := fichario[i+1];
            numFichas := numFichas - 1;
            msgBaixo ('FVREMOVI');     {'Removido'}
            if numFichas = 0 then
                begin
                    assign (arq, 'FICHAS.IND');
                        {$i-} reWrite (arq); {$i+}
                    if ioresult <> 0 then
                    begin
                        mensagem ( 'FVPROBLE', 1); {'houve problemas no disco !'}
                        exit;
                    end;
                    close (arq);
                    exit;
                end;
            if posAtual > numFichas then
                if posAtual > 1 then posAtual := posAtual - 1
            else
            if numFichas > posAtual then
                if posAtual > 1 then posAtual := posatual - 1
            else
            if numFichas = posAtual then posAtual := 1;
        end;

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                 procura próxima ficha
{--------------------------------------------------------}

procedure conteudoFicha (buscado: string);
    var
    linha: string;
    i, cont: integer;

begin
    cont := 0;
    for i := posAtual+1 to numFichas do
        begin
            cont := cont + 1;
            if cont > 40 then
                begin
                    cont := 0;
                    sintClek;
                end;
            assign (arqFicha, fichario[i]^.nomeArq);
            {$I-}  reset(arqFicha);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('FVERROAF', 1);{Erro no arquivo.}
                    posAtual := i;
                    exit;
                end
            else
                begin
                    while not eof (arqFicha) do
                        begin
                            Readln (arqFicha, linha);
                            if pos (buscado, maiuscAnsi (semAcentos (linha))) <> 0 then
                                begin
                                    msgBaixo ('FVACHEI');    {'Achei'}
                                    posAtual := i;
                                    close (arqFicha);
                                    exit;
                                end;
                        end;
                end;
            close (arqFicha);
        end;
                    msgBaixo ('FVNACHEI');    {'Não achei'}
end;

{--------------------------------------------------------------------}
procedure procuraProximo;
var i: integer;
    buscado: string;
begin
    buscado := maiuscAnsi (semAcentos (nomeBusc));
    case opcBusc of
        'N': begin
                for i := posAtual+1 to numFichas do
                    begin
                        if pos (buscado, maiuscAnsi (semAcentos (fichario[i]^.chave))) <> 0 then
                            begin
                                msgBaixo ('FVACHEI');    {'Achei'}
                                posAtual := i;
                                exit;
                            end;
                    end;
                msgBaixo ('FVNACHEI');    {'Não achei'}
             end;

        'A': begin
                for i := posAtual+1 to numFichas do
                    begin
                        if pos (buscado, maiuscAnsi (semAcentos (fichario[i]^.nomeArq))) <> 0 then
                            begin
                                msgBaixo ('FVACHEI');    {'Achei'}
                                posAtual := i;
                                exit;
                            end;
                    end;
                msgBaixo ('FVNACHEI');    {'Não achei'}
             end;
        'C': conteudoFicha (buscado);
    end;
end;

{--------------------------------------------------------}
{Tipo de procura: por Nome da ficha, nome do arquivo ou conteudo.}
{--------------------------------------------------------}
procedure procuraNAC;
begin
    textbackground (red);
    mensagem ('FVPERPRO', 1); {Que tipo de procura: '}
    mensagem ('FVPROMSG', 0);{N-Nome da ficha,  A-Arquivo da ficha  ou C-Conteúdo da ficha'}
    textbackground (black);
    opcBusc := upcase (readkey);
    writeln;
    if not (opcBusc in ['N', 'A', 'C']) then
        begin
            msgBaixo ('FVDESIST');{Desistiu}
            exit;
        end;

    case opcBusc of
        'N': mensagem ('FVNOMPRC', 1);    {'Nome da ficha a procurar'}
        'A': mensagem ('FVARQPRC', 1);    {'Nome do arquivo a procurar'}
        'C': mensagem ('FVCONPRC', 1);    {'Palavra ou frase a procurar'}
end;
    sintReadln (nomeBusc);
    if nomeBusc = '' then exit;
    procuraProximo;
end;

{--------------------------------------------------------}
{               recria tela de folheamento
{--------------------------------------------------------}

procedure recriaTelaFolheia;
begin
    tela;
    if numFichas = 0 then
        begin
            mensagem ('FVFICVAZ', 1);    {'Fichario vazio'}
            exit;
        end;

    msgBaixo ('FOLHEAR'); {Folheie as fichas com as setas, depois tecle sua opção.}
    gotoxy (1, 6);

    textColor (CYAN);
    write (TITULO_FOLHEIA);
    textColor (LIGHTGRAY);
    if wherex <> 1 then writeln;

    ytelaFolheia := wherey;
    nlinhasFolheia := 25-ytelaFolheia;
end;

{--------------------------------------------------------}
{Procedimento que troca o Nome da ficha ou o nome do arquivo da ficha}
{--------------------------------------------------------}

procedure renomearFicha;
var
    arq: text;
    s:string;
    k: integer;
    opc: char;

begin
    textBackGround (red);
    mensagem ('FVQUAOPC', 0);{Qual sua opção?}
    write ('(');
    mensagem ('FVPRENON', 0);{N : Troca nome da ficha}
    write (', ');
    mensagem ('FVPRENOA', 0);{A : Troca nome do arquivo}
    write (')');
    textBackGround (black);
    opc := upcase(readkey);
    writeln;
    case opc of
        'N':
            begin
                k := 0;
                repeat
                    if k = 0 then
                        mensagem ('FVINNF', 1){Informe o novo nome da ficha: '}
                    else
                        mensagem ('OUTRONC', 1);{Já existe ficha com este nome, digite outro: }
                    sintetiza (fichario[posAtual]^.chave);
                    newChave := fichario[posAtual]^.chave;
                    if sintEdita (newChave, 1, 1, 100, TRUE) = '' then;
                    if newChave = '' then exit;
                    k := k+1;
                until (teste_newChave(newChave)) or
                (newChave = fichario[posAtual]^.chave);
                mensagem ('FVTNFP', 0);{Troquei o nome da ficha para:'}
                sintwrite (newChave);
                fichario[posAtual]^.chave := newChave;
            end;

        'A':
            begin
                k := 0;
                repeat
                    if k = 0 then
                        mensagem ('FVINNA', 1) {Informe o nomo nome do arquivo, ou tecle ENTER para assumir padrão: }
                    else
                        mensagem ('FVARQEXI', 1);{Já existe arquivo com este nome, digite outro: }
                    sintSoletra (fichario[posAtual]^.nomeArq);
                    newNomeArq := fichario[posAtual]^.nomeArq;
                    if sintEdita (newNomeArq, 1, 1, 100, TRUE) = '' then;
                    k := k+1;
                    if newNomeArq = '' then
                        newNomeArq := newNomeArq_padrao;
                until (teste_newNomeArq(newNomeArq)) or
                ( newNomeArq = fichario[posAtual]^.nomeArq);
                s := fichario[posAtual]^.nomeArq;
                assign (arq, s);
                {$i-} rename (arq, newNomeArq);  {$I+}
                if ioresult <> 0 then
                    msgBaixo ('FVNCTNA'){Não consegui trocar o nome do arquivo.}
                else
                    begin
                        fichario[posAtual]^.nomeArq := newNomeArq;
                        mensagem ('FVTNAP', 0);{'Troquei o nome do arquivo para '}
                        write (newNomeArq);
                        sintSoletra (newNomeArq);
                    end;
            end;

        ESC: msgBaixo ('FVDESIST'){Desistiu}
    else
        msgBaixo ('FVDESIST');{Desistiu}
    end;
end;

{--------------------------------------------------------}
{Dados sobre o arquivo - selecionado ou não, tamanho, data de criação e hora de criação.}
{--------------------------------------------------------}

procedure dadosArquivo;
var
    s: string;
    dt: TdateTime;
begin
    mensagem ('FVTAMBYT', 0);{Tamanho do arquivo em byte: }
    sintWriteint (PMySearchRec(fichario[posAtual]^.nomeArq).sr.Size);
    writeln;

    mensagem ('FVDATCRI', 0);{Data de criação: }
    dt := FileDateToDateTime(PMySearchRec(fichario[posAtual]^.nomeArq).sr.Time);
    s := dateTimeToStr (dt);
    delete (s, pos(' ', s), 99);
    sintWriteln (s);

    mensagem ('FVHORCRI', 0);{Hora de criação '}
    s := dateTimeToStr (dt);
    delete (s, 1, pos(' ', s));
    delete (s, length (s)-2, 3);
    sintWriteln (s);
end;

{--------------------------------------------------------}
{                mostra opcoes de folheamento
{--------------------------------------------------------}

procedure ajudaFolheia;
var i: integer;
    s: string;
begin
    for i := 3 to 25 do
        begin
            gotoxy (1, i);  clreol;
        end;

    gotoxy (1, 3);
    mensagem ('FVAJUFOL', 1);   { Folhei as fichas com as setas depois tecle:}
    for i := 1 to 13 do
        begin
            str (i, s);
            mensagem ('FVAJUF'+s, 1);
        end;

(*
    E-Editar
    L-Lêr
    P-Procurar
    X-Execultar arquivo
    A-Arquivo da ficha
    D-Dados sobre a ficha
    N-Renomeia a ficha
C-copiar arquivo
    O-Ordena fichario
    R-Remove ficha
    Q-Remove deixando o arquivo;
S-Seleciona ou deseleciona
    I-Imprimir

*)

    while keypressed do readkey;
    if not keypressed then
        mensagem ('FVEXICON', 2); {Existem mais controles}
    readkey;
    if not keypressed then
        for i := 14 to 21 do
            begin
                str (i, s);
                mensagem ('FVAJUF'+s, 1);
            end;

(*
    F2-Nova ficha
    F3-Configurar modelo
    F5-Procura
    control F5-Procura novamente
    F6-Informa diretório de trabalho
    F7-Informa nUmero de Fichas
    F9-Imprimir
    ESC: termina folheamento
*)
    writeln;
    mensagem ('FVPREENT',1);
    while not keypressed do
       if ENTER = readkey then
          exit;
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                   folheia registros
{--------------------------------------------------------}

procedure folhear_fichas;
var
    folheando, inibeFala, mostraTudo: boolean;
    opc, opc2: char;
    numFichasAux: integer;
begin
    clrscr;
    if numFichas = 0 then
        begin
            mensagem ('FVFICVAZ', 1);    {'Fichario vazio'}
            exit;
        end;

    sort (1, numfichas);
    recriaTelaFolheia;
    mostraTodosNomes;

    folheando := true;
    inibeFala := false;
    posAtual := 1;

    repeat
        mostraTudo := true;
        escreveNome (posAtual, true);
        if (not inibeFala) and (not keypressed) then
            sintetiza (fichario[posAtual]^.chave);

        opc := readkey;
        opc2 := opc;
        if opc = #$0 then opc2 := readkey;
        escreveNome (posAtual, false);
        inibeFala := false;

        if opc = #$0 then
            case opc2 of
                F1: begin
                       ajudaFolheia;
                       recriaTelaFolheia;
                    end;
                F2: begin
                       clrscr;
                       nova_ficha;
                       recriaTelaFolheia;
                    end;
                F3: begin
                       limpatela (fichario[posAtual]^);
                       configurarArquivoModelo;
                       recriaTelaFolheia;
                    end;
                F5: begin
                       tela;
                       procuraNAC;
                    end;
                CTLF5: begin
                          tela;
                          procuraProximo;
                       end;
                F6: begin
                       tela;
                       diretorio_atual;
                    end;
                F7: begin
                      tela;
                      fala_numFichas;
                    end;
            F9: begin
                    tela;
                    fazImpressao (fichario[posAtual]^.nomeArq, 'S');
                    inibeFala := true;
                    recriaTelaFolheia;
                end;

                CIMA:   begin
                            msgBaixo ('');
                            if posAtual <= 1 then
                                msgBaixo ('FVULTIMO')   {'Última ficha'}
                            else
                                posAtual := posAtual - 1;
                            if posAtual >= posFolheia then
                                 mostraTudo := false;
                        end;

                BAIX:  begin
                            msgBaixo ('');
                            if posAtual >= numFichas then
                                msgBaixo ('FVULTIMO')   {'Última ficha'}
                            else
                                posAtual := posAtual + 1;
                            if posFolheia > posAtual-nlinhasFolheia+1 then
                                 mostraTudo := false;
                        end;

                ESQ:    begin
                            sintetiza (fichario[posAtual]^.chave);
                            inibeFala := true;
                        end;

                DIR:    begin
                            sintSoletra (fichario[posAtual]^.chave);
                            inibeFala := true;
                        end;

                CTLPGUP:    begin
                                msgBaixo ('');
                                posAtual := 1;
                            end;

                HOME:    begin
                                msgBaixo ('');
                                posAtual := 1;
                            end;

                CTLPGDN:    begin
                                msgBaixo ('');
                                posAtual := numFichas;
                            end;

                TEND:    begin
                                msgBaixo ('');
                                posAtual := numFichas;
                            end;

                PGUP:   begin
                            msgBaixo ('');
                            posAtual := posAtual - nLinhasFolheia;
                            if posAtual <= 1 then
                                begin
                                    msgBaixo ('FVULTIMO');   {'Última ficha'}
                                    posAtual := 1;
                                end;
                        end;

                PGDN:  begin
                            msgBaixo ('');
                            posAtual := posAtual + nLinhasFolheia;
                            if posAtual >= numFichas then
                                begin
                                    posAtual := numFichas;
                                    msgBaixo ('FVULTIMO');   {'Última ficha'}
                                end;
                        end;
            end
        else
            with fichario[posAtual]^ do
            begin
                case upcase(opc) of
                    'E': editarArquivo (nomeArq);
                    'L': LerArquivo (nomeArq);
                    'X': executaArquivo;
                    ENTER: executaArquivo;
(*neno*)                    'A': begin
                             sintWriteln (fichario[posAtual]^.nomeArq);
                             delay (50);
                             mensagem ('FVPERSOL',0); {Quer que soletre, SIM ou NÃO?}
                             opc := upcase (readkey);
                             writeln;
                             if opc = 'S' then
                                sintSoletra (fichario[posAtual]^.nomeArq);
                             delay (200);
                             inibeFala := false;
                             while keypressed do readkey;
                         end;
                    'C': begin
                             tela;
                             fazCopias (fichario[posAtual]^.nomeArq);
                             if numFichas > 0 then
                                begin
                                    inibeFala := true;
                                    recriaTelaFolheia;
                                end;
                         end;

                    'D': begin
                             tela;
                             dadosArquivo;
                             inibeFala := true;
                         end;

                    'N': begin
                             tela;
                             renomearFicha;
                             inibeFala := true;
                             recriaTelaFolheia;
                         end;

                'P': begin
                       tela;
                       procuraNAC;
                     end;
                ^P: procuraProximo;
                    'O': begin
                             tela;
                             ordenaNomes;
                             msgBaixo ('FVORDENA');
                             inibeFala := true;
                             recriaTelaFolheia;
                         end;

                    'R': begin
                             numFichasAux := numFichas;
                             tela;
                             removeEste (TRUE);
                             if numFichas < numFichasAux then
                                begin
                                    guardar_fichas;
                                    descarregar_fichas;
                                     carregar_fichas;
                                end;
                             inibeFala := true;
                             sintetiza (fichario[posAtual]^.chave);
                         end;

                    'Q': begin
                             tela;
                             removeEste (FALSE);
                             if numFichas > 0 then
                                begin
                                    guardar_fichas;
                                    descarregar_fichas;
                                     carregar_fichas;
                                end;
                             inibeFala := true;
                             sintetiza (fichario[posAtual]^.chave);
                         end;

                    'I': begin
                            tela;
                            fazImpressao (fichario[posAtual]^.nomeArq, 'S');
                            inibeFala := true;
                            recriaTelaFolheia;
                         end;

                    'S': begin
                            if not (selecionado) then
                                begin
                                    msgBaixo ('FVSELEC');   {'Selecionado'}
                                    selecionado := true;
                                end
                            else
                                begin
                                    msgBaixo ('FVNSELEC');   {'Não selecionado'}
                                    selecionado := false;
                                end;
                         end;

                    ESC: begin
                             folheando := false;
                         end;
                end;
            end;

        if opc <> ESC then
            if mostraTudo then
                  mostraTodosNomes;

        if numFichas = 0 then
            begin
                msgBaixo ('FVFICVAZ');    {'Fichario vazio'}
                folheando := false;
            end;

   until not folheando;
end;

end.
