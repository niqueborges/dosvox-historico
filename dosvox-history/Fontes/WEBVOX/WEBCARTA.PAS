{-------------------------------------------------------------}
{
{    Webvox - Módulo para envio de página por e-mail
{
{    Autor: Bernard Condorcet
{
{    Em 18/12/2000
{
{-------------------------------------------------------------}

unit webCarta;

interface
uses dvcrt, dvWin, dvExec, dvForm,
    windows,
    webVars, webGrArq, webMsg, webMail, webBusca, webCatal;

function comparaSaida (s: string): string;
procedure enviaPagina;

implementation

Type
    ponteiro = ^itens;
    itens = Record
        item: String;
        prox: Ponteiro;
    End;

var
    arq, arqFinal: text;
    nomeArq, nomeFinal: string;
    tipo: string;
    recomenda: string;
    convertePadrao: boolean;
    p, prim: Ponteiro;
    enviarPara : string;
    assunto : string;
    meuEndereco: string;

{-------------------------------------------------------------}

function comparaSaida (s: string): string;
var
i: integer;

begin
    for i:= 1 to length (s) do
        begin

            if (s[i] = 'Á') or (s[i] = 'Ã') or (s[i] = 'À') or
            (s[i] = 'á') or (s[i] = 'ã') or (s[i] = 'à') then
                s[i]:= 'A';

            if (s[i] = 'É') or (s[i] = 'Ê') or
            (s[i] = 'é') or (s[i] = 'ê') then
                s[i]:= 'E';

            if (s[i] = 'Í') or
            (s[i] = 'í') then
                s[i]:= 'i';

            if (s[i] = 'Ó') or (s[i] = 'Õ') or
            (s[i] = 'ó') or (s[i] = 'õ') then
                s[i]:= 'O';

            if (s[i] = 'Ú') or
            (s[i] = 'ú') then
                s[i]:= 'U';

            if (s[i] = 'Ç') or
            (s[i] = 'ç') then
                s[i]:= 'C';

                if s[i] < #$20 then
                    s[i] := ' ';

                s [i] := upcase(s[i]);
        end;

        repeat
            i := pos (' ', s);
            if i <> 0 then
                delete (s, i, 1);
        until i = 0;

    comparaSaida := s;

    if debug then
        begin
            sintedita (s, wherex, wherey, 250, true);
        end;

end;

{-------------------------------------------------------------}

function preparaModoTransmissao (opcaoFormato: char): boolean;
var
    ano, mes, dia, sem: word;
    d1, d2, d3: string;
    podeGravar: boolean;
    s: string;

const
    tabMes: array [1..12] of string [3] = (
       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

begin
    preparaModoTransmissao := false;

    assign (arq, nomeArq);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBTRAAPA', 1);  {'Arquivo de trabalho foi apagado'}
            exit;
        end;

    nomeFinal := 'envia.cpr';
    assign (arqFinal, nomeFinal);
    {$I-}  rewrite(arqFinal);  {$I+}
    if ioresult <> 0 then
        begin
            close (arq);
            mensagem ('WBERRGRD', 1);  {'Problemas para gravar arquivo no disco'}
            exit;
        end;

    getdate (ano, mes, dia, sem);
    enviandoPaginaHtml := false; {utilizado em WebMail}
    str (dia, d1);
    str (mes, d2);
    str (ano, d3);

    if upcase(opcaoFormato) = 'O' then
        begin
            if (tipo = '.HTM') or (tipo = '.HTML') then
                begin
                    writeln;
                    mensagem ('WBENHTLM', 1);  {'Ok, irei enviar em formato html'}
                    enviandoPaginaHtml := true;
                    if recomenda <> 'FILE' then
                        begin
                            writeln (arqFinal, '<HTML>');
                            writeln (arqFinal, '<P><CENTER><HR></CENTER><P>');
                            writeln (arqFinal, '<CENTER>Serviço Webvox de recomendação</CENTER>');
                            writeln (arqFinal, '<P><A HREF="' + (nomePagAtual) + '">Confira aqui</A><P>');
                            writeln (arqFinal, '<MARQUEE ALIGN=MIDDLE BEHAVIOR=ALTERNATE BGCOLOR="blue" ');
                            writeln (arqFinal, 'DIRECTION=LEFT HEIGHT=0% WIDTH=95%');
                            write (arqFinal, 'HSPACE=10 VSPACE=10 LOOP= INFINITE SCROLLAMOUNT=2');
                            writeln (arqFinal, 'SCROLLDELAY=20> <FONTE SIZE=7><B>Projeto DOSVOX</B></FONTE> </MARQUEE><P>');
                            writeln (arqFinal, '<P><CENTER><HR></CENTER><P>');
                        end;
                    end;
                end
                else
                    if recomenda <> 'FILE' then
                        begin
                            writeln (arqFinal, 'Serviço Webvox de recomendação');
                            writeln (arqFinal);
                            writeln (arqFinal, 'Confira aqui : ' + nomePagAtual);
                            writeln (arqFinal);
                            writeln (arqFinal, 'Use o comando de bloco e copie para um de seus catálogos :');
                            writeln (arqFinal, nomePagAtual + '=Webvox recomenda ' + (d1) + '/' + (d2) + '/' + (d3));
                            writeln (arqFinal);
                    end;

    while not eof(arq) do
        begin
            readln (arq, s);

            if not convertePadrao then
                begin
                    podeGravar := true;

                    p := prim;
                    while p <> nil do
                        begin
                                if (comparaSaida(s) = comparaSaida(p^.item)) then
                                    begin
                                        podeGravar := false;
                                        p := nil;
                                    end
                                else
                                    p := p^.prox;
                        end; {Relativo ao while do ponteiro}

                    if podeGravar then
                        writeln (arqFinal, s);
                end {Relativo ao if da formatação padrão}

            else
                writeln (arqFinal, s);
        end; {Relativo ao while da leitura do arq}

    close (arq);
    close (arqFinal);

    preparaModoTransmissao := true;
end;

{-------------------------------------------------------------}

procedure armazenaItensExcluidos;
var
    arqItens: text;
    nomeItens: string;
    opcao: char;

begin
    convertePadrao := true;

    writeln;
    mensagem ('WVCNVPDR', 0);     {'Deseja usar a conversão padrão ? (S/N) : '}
    opcao := popupMenuPorLetra ('SN');
    writeln;
    if opcao <> 'N' then
        exit;

    nomeItens := sintDirAmbiente + '\webitens.ini';
    assign (arqItens, nomeItens);
    {$I-}  reset (arqItens);  {$I+}
    if ioresult <> 0 then
        begin
            writeln;
            mensagem ('WBMANTPD', 1); {'Não existe nenhum ítem relacionado, terei de manter o padrão'}
            exit;
        end;

    convertePadrao := false;

    while not eof(arqItens) do
        begin
            new (p);
            readln (arqItens, p^.item);
            p^.Prox := prim;
            prim := p;
        end;

    close (arqItens);
end;

{-------------------------------------------------------------}

procedure excluiItensExcluidos;
var p: Ponteiro;
begin
    while prim <> NIL do
        begin
             p := prim;
             prim := prim^.prox;
             dispose (p);
        end;
end;

{-------------------------------------------------------------}

procedure enviaPagina;
var
    nomeEditor : string;
    opcaoFormato, opcao: char;

label fim;

begin
    if nomeTemp = '' then
        begin
            mensagem ('WBNAOCAR', 1);  {'Não existe página carregada'}
            exit;
        end;

    prim := NIL;
    tipo := maiuscAnsi (copy (nomeTemp, pos ('.', nomeTemp), length(nomeTemp)));
    recomenda := maiuscAnsi (copy (nomePagAtual, 1, pos (':', nomePagAtual) - 1));

    writeln;
    mensagem ('WBDIGOT', 0); {'Digite O para enviar em formato original ou T para texto'}
    opcaoFormato := popupMenuPorLetra ('OT');
    writeln;
    if not (opcaoFormato in ['O', 'T', ENTER]) then
        exit;
    if opcaoFormato = ENTER then opcaoFormato := 'O';

    enviarPara := '';
    writeln;
    mensagem ('WBPQUEM', 1);  {'Para quem você deseja enviar esta página ? '}
    if sintEdita (enviarPara, wherex, wherey, 80, true) = ESC then exit;
    writeln;
    if enviarPara = '' then
        begin
            writeln;
            mensagem ('WBOPCANC', 1);  {'Operação cancelada'}
            goto fim;
        end;

    if recomenda = 'FILE' then
        assunto := 'Webvox recomenda: ' + (nomeTemp)
    else
        assunto := 'Webvox recomenda: ' + (nomePagAtual);
    writeln;
    mensagem ('WBCNFASU', 1);    {'Confirma como assunto : '}
    sintWriteln (assunto);
    mensagem ('WBSN', 0);    {' (S/N) : '}
    opcao := popupMenuPorLetra ('SN');
    writeln;
    if opcao= ESC then
        begin
            writeln;
            mensagem ('WBOPCANC', 1);  {'Operação cancelada'}
            goto fim;
        end;

    if opcao = 'N' then
        begin
            assunto := '';
            writeln;
            mensagem ('WBDIGNVA', 1);  {'Então digite um novo assunto: '}
            sintEdita (assunto, wherex, wherey, 80, true);
            writeln;
        end;

    meuEndereco := sintAmbiente ('CARTAVOX', 'ENDERUSUARIO');
    writeln;
    if meuEndereco = '' then meuEndereco := 'webvox';
    mensagem ('WBSEUEND', 0);  {'Seu endereço é: '}
    sintWriteln (meuEndereco);
    mensagem ('WBSN', 0);    {' (S/N) : '}
    opcao := popupMenuPorLetra ('SN');
    if opcao in ['N', ESC] then
        begin
            writeln;
            mensagem ('WBOPCANC', 1);  {'Operação cancelada'}
            goto fim;
        end;

(* //Neno - Se colocar endereço diferente do que está na configuração do Cartavox, dá erro.
    if opcao = 'N' then
        begin
            meuNovoEndereco := '';
            writeln;
            mensagem ('WBDIGNVE', 1);  {'Digite então o novo endereço: '}
            if sintEdita (meuNovoEndereco, wherex, wherey, 80, true) = ESC then exit;
            writeln;
            if meuNovoEndereco = '' then
                goto fim
            else
                meuEndereco := meuNovoEndereco;
        end;
*)//Neno

    if opcaoFormato = 'O' then
        begin
            nomeArq := nomeTemp;
            if not preparaModoTransmissao (opcaoFormato) then
                goto fim;
        end
    else
        begin
            nomeArq := 'envia.$$$';
            if (tipo = '.HTM') or (tipo = '.HTML') then
                begin
                    if not geraArqTexto (nomeTemp, nomeArq,  false) then exit;
                    armazenaItensExcluidos;
                end;

            if not preparaModoTransmissao (opcaoFormato) then
                goto fim
            else
                begin
                     {$I-}  erase (arq);  {$I+}
                     if ioresult <> 0 then;
                end;
        end;

    writeln;
    mensagem ('WBDESEDI', 0);    {'Deseja editar o arquivo ? '}
    opcao := popupMenuPorLetra ('SN');
    writeln;
    if opcao = ESC then
        begin
            writeln;
            mensagem ('WBOPCANC', 1);  {'Operação cancelada'}
            goto fim;
        end;

    if opcao = 'S' then
        begin
            nomeEditor := sintAmbiente ('CARTAVOX', 'EDITOR');
            if nomeEditor = '' then
                nomeEditor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\minied.exe';
            if executaProg (nomeEditor, '', nomeFinal) > 32 then
                begin
                    esperaProgVoltar;
                    while sintFalando do waitMessage;
                    sintBip;
//NenoNeno                    delay (1000);
                end
            else
                mensagem ('WBERREDI', 1);    {'Erro ao acionar o editor de textos'}
        end;

    writeln;
    mensagem ('WBCNFENV', 0);    {'Confirma envio ? (S/N): '}
    opcao := popupMenuPorLetra ('SN');
    writeln;
    if not (opcao in ['S', ENTER]) then
        begin
            writeln;
            mensagem ('WBOPCANC', 1);  {'Operação cancelada'}
            goto fim;
        end;

    transmiteCarta (enviarPara, meuEndereco, assunto, nomeFinal);
    assign (arq, nomeFinal);
    {$i-} erase (arq); {$I+}
    ioresult;   // limpa flags de erro

fim:
    excluiItensExcluidos;

    enviandoPaginaHtml := false;
    while keypressed do readkey;
end;

end.
