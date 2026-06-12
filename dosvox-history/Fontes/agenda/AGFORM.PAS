{--------------------------------------------------------}
{                  AGENVOX - tratamento de entrada e saída das ocorrências
{--------------------------------------------------------}

unit agForm;

interface

uses dvCrt, dvWin, dvForm, dvAmplia,
    agMail, agGastos, agUtil, agVars, agMsg;

procedure existeNomeArqNoVetor;
procedure carregaVariaveis;
procedure pegaDadosNoDisco;
procedure verificaAtributos;
procedure ordenaVetor;
procedure procuraCompromissos;
procedure removeCompromissosPassados;
procedure removeCompromissos;
procedure gravaNomeArq;
procedure formDados;
procedure gravaFormDados;
procedure iniciaDados;

var compromisso, um, dois, tres, aviso, mail, endMai, textMai,
    gastos, debCred, nomGru, valor, descri: shortString;
    ComparaCompromisso: string;
    podeGravarNomeArq: boolean;

implementation

{--------------------------------------------------------}
{Verifica se nome do arquivo já consta no vetor
{--------------------------------------------------------}

procedure existeNomeArqNoVetor;
var numLin: integer;
begin

    podeGravarNomeArq:= true;
    comparaCompromisso:= '';

    for numLin:= 1 to maxLin do
        begin
            if copy (linhaCompromisso[numLin], 1,
            pos ('=', linhaCompromisso[numLin]) - 1) = nomeDados then
                begin
                    comparaCompromisso:= copy (linhaCompromisso[numLin],
pos ('=', linhaCompromisso[numLin]) + 1, length (linhaCompromisso[numLin]));
                    podeGravarNomeArq:= false;
                    exit;
                end;
        end;

end;

{--------------------------------------------------------}
{Inicializa variáveis
{--------------------------------------------------------}

procedure carregaVariaveis;
begin

    if podeGravarNomeArq then
        begin
    compromisso:= '';
    um:= '';
    dois:= '';
    tres:= '';
    aviso:= '';
    mail:= '';
        endMai:= '';
    textMai:= '';
    gastos:= '';
    nomGru:= '';
        valor:= '';
    descri:= '';
        end
        else
            pegaDadosNoDisco;

end;

{--------------------------------------------------------}
{Carrega variáveis a partir do disco
{--------------------------------------------------------}

procedure pegaDadosNoDisco;
var arq: text;
    s: string;
begin

                assign (arq, nomeDados);
                {$i-} reset (arq); {$i+}

                if IoResult <> 0 then
                    exit;

                readln (arq, s);
                delete (s, 1, pos ('=', s));
                compromisso:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                um:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                dois:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                tres:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                aviso:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                mail:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                endMai:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                textMai:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                gastos:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                nomGru:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                debCred:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                valor:= s;
                readln (arq, s);
                delete (s, 1, pos ('=', s));
                descri:= s;

                close (arq);

end;

{--------------------------------------------------------}
{Verifica atributos de cada evento
{--------------------------------------------------------}

procedure verificaAtributos;
var temQueRemover: boolean;
    opcao: char;
begin

    pegaDadosNoDisco;
    temQueRemover:= false;

    if (aviso = 's') or (aviso = 'S') then
        begin
            usarRelogio:= true;
            despertaOk:= true;
            somaDespert:= true;
        end
        else
            somaDespert:= false;

    if (mail = 's') or (mail = 'S') then
        begin
            tocaEfeito ('agEmail');
            mensagem ('AGEXIMAI', 0);  {'Existe um evento relacionado à geração de email automático, deseja realizá-lo agora? '}
            opcao:= sintReadKey;
            writeln;
            if upcase (opcao) = 'S' then
                begin
                    preparaCarta (endMai, compromisso, textMai);
                    temQueRemover:= true;
                end
                else
                    begin
                        mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
                    end;
        end;

    if (gastos = 's') or (gastos = 'S') then
        begin
            tocaEfeito ('agMoeda');
            mensagem ('AGEXIGAS', 0);  {'Existe um evento relacionado à gastos pessoais , deseja realizá-lo agora? '}
            opcao:= sintReadKey;
            writeln;
            if upcase (opcao) = 'S' then
                begin
                    lancaGastos (nomGru, debCred, valor, descri);
                    temQueRemover:= true;
                end
                else
                    begin
                        mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
                    end;
        end;

    if temQueRemover then
        if not trocaDir (dir_agenda) then
            exit
        else
            begin
                mensagem ('AGTEMREM', 1);  {'É extremamente aconselhável que este compromisso seja removido'}
                removeCompromissos;
        end;

end;

{--------------------------------------------------------}
{Ordena vetor pela data e hora
{--------------------------------------------------------}

procedure ordenaVetor;
var numLin, numLin1: integer;
    nom, nom1: integer;
    erro: integer;
    guarda: string;
begin

    for numLin:= 1 to maxLin - 1 do
        for numLin1:= numLin + 1 to maxLin do
            begin
                val (copy (linhaCompromisso[numLin], 1, 12), nom, erro);
                val (copy (linhaCompromisso[numLin1], 1, 12), nom1, erro);
                if nom > nom1 then
                    begin
                        guarda:= linhaCompromisso[numLin];
                        linhaCompromisso[numLin]:= linhaCompromisso[numLin1];
                        linhaCompromisso[numLin1]:= guarda;
                    end;
            end;

end;

{--------------------------------------------------------}
{Procura por compromissos existentes no vetor
{--------------------------------------------------------}

procedure procuraCompromissos;
var procuraTexto, linhaTexto: string;
    numLIn: integer;
    numCarac, varreLinha: integer;
    encontrou: boolean;
    dd, mm, aa, hh, mn: string;
    opcao: char;
begin

    mensagem ('AGPROC', 0);  {'Informe o compromisso desejado: '}
    sintReadln (procuraTexto);

    encontrou:= false;

    if procuraTexto = '' then
        exit;

    ordenaVetor;

    if procuraTexto = '*' then
        begin

            for numLin:= 1 to maxLin do
                sintWriteln ('* ' + copy (linhaCompromisso[numLin], 18, length (linhaCompromisso[numLin])));

            if maxLin > 0 then
                begin
                    mensagem ('AGCONTEL', 1);  {'Pressione ENTER para retornar ou CONTROL + ALT + F9 para congelar a tela'}
                    sintReadln (procuraTexto);
                end
                else
                    begin
                        tocaEfeito ('agNada1');
                        mensagem ('AGNAOCON', 1);  {'Não consta'}
                    end;
            exit;
        end;

    procuraTexto:= maiuscAnsi (semAcentos(procuraTexto));
    numCarac:= length (procuraTexto);

    for numLin:= 1 to maxLin do
        begin
            linhaTexto:= copy (linhaCompromisso[numLin], 18,
            length (linhaCompromisso[numLin]));
            linhaTexto:= maiuscAnsi (semAcentos (linhaTexto));
            for varreLinha:=1 to length (linhaTexto) do
                if procuraTexto = copy (linhaTexto, varreLinha, numCarac) then
                begin
                    encontrou:= true;
                    nomeDados:= copy (linhaCompromisso[numLin], 1, 16);
                    aa:= copy (linhaCompromisso[numLin], 1, 4);
                    mm:= copy (linhaCompromisso[numLin], 5, 2);
                    dd:= copy (linhaCompromisso[numLin], 7, 2);
                    hh:= copy (linhaCompromisso[numLin], 9, 2);
                    mn:= copy (linhaCompromisso[numLin], 11, 2);
                    mensagem ('AGCOMAGE', 0);  {'O compromisso está agendado para o dia '}
                    sintWrite (dd + '/' + mm + '/' + aa);
                    sintWriteln (' às ' + hh + ' horas e ' + mn +' minutos');
                    mensagem ('AGDESEDI', 0);  {'Deseja editá-lo? '}
                    opcao:= sintReadKey;
                    writeln;
                    if upcase (opcao) = 'S' then
                        begin
                            pegaDadosNoDisco;
                            procurandoCompromissos:= true;
                            formDados;
                        end;
                break;
                end;
        end;

    if not encontrou then
        begin
            tocaEfeito ('agNada1');
            mensagem ('AGNAOCON', 1);  {'Não consta'}
        end;

end;

{--------------------------------------------------------}
{Remove todos os compromissos anteriores à data atual
{--------------------------------------------------------}

procedure removeCompromissosPassados;
var arq, arq1: text;
    nomeArq: string;
    dataDeHoje, dataDoVetor: integer;
    erro: integer;
    numLin: integer;
    arquivoRemovido: boolean;
    opcao: char;
begin

    tocaEfeito ('agFreia');
    mensagem ('AGCOMTOD', 0);  {'Confirma a remoção de todos os compromissos anteriores à esta data? '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) <> 'S' then
        begin
                writeln;
                mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
            recargaNoVetor:= false;
            exit;
        end;

    recargaNoVetor:= false;
    arquivoRemovido:= false;
    val (copy (nomeDados, 1, 8), dataDeHoje, erro);

    for numLin:=1 to maxLin do
        begin
            val (copy (linhaCompromisso[numLin], 1, 8), dataDoVetor, erro);
            if dataDoVetor < dataDeHoje then
                begin
                    nomeArq:= copy (linhaCompromisso[numLin], 1, 16);
                    assign (arq, nomeArq);
                    {$i-} reset (arq); {$i+}
                    if IoResult <> 0 then
                        exit
                        else
                            begin
                                close (arq);
                                erase (arq);
                                linhaCompromisso[numLin]:= '';
                                arquivoRemovido:= true;
                                sintBip;
                            end;
                end;
        end;

    if arquivoRemovido then
        begin
            assign (arq1, 'Compromissos da Agenda');
            {$i-} rewrite (arq1); {$i+}
            if IOresult <> 0  then
                exit;

            for numLin:= 1 to maxLin do
                begin
                    if linhaCompromisso[numLin] <> '' then
                    writeln (arq1, linhaCompromisso[numLin]);
                end;
            close (arq1);
            recargaNoVetor:= true;
        end;

end;

{--------------------------------------------------------}
{Remove compromissos existentes no disco
{--------------------------------------------------------}

procedure removeCompromissos;
var arq, arq1: text;
    numLin: integer;
    opcao: char;
begin

        assign (arq, nomeDados);
    {$i-} reset (arq); {$i+}
    if IoResult <> 0 then
        begin
            mensagem ('AGNAOCOM', 1);  {'Este compromisso não pode ser removido pois não existe'}
            recargaNoVetor:= false;
            exit;
        end;

    tocaEfeito ('agFreia');
    mensagem ('AGCONFEX', 0);  {'Confirma a remoção do compromisso? '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) <> 'S' then
        begin
                writeln;
                mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
            recargaNoVetor:= false;
            close (arq);
            exit;
        end;

    close (arq);

    assign (arq1, 'Compromissos da Agenda');
    {$i-} rewrite (arq1); {$i+}
    if IOresult <> 0  then
        exit;

    for numLin:= 1 to maxLin do
        begin
            if copy (linhaCompromisso[numLin], 1,
            pos ('=', linhaCompromisso[numLin]) - 1) <> nomeDados then
                writeln (arq1, linhaCompromisso[numLin]);
        end;

    erase (arq);
    close (arq1);

    tocaEfeito ('agFaca');
    recargaNoVetor:= true;

end;

{--------------------------------------------------------}
{Grava nome do arquivo em "Compromissos da Agenda"
{--------------------------------------------------------}

procedure gravaNomeArq;
var arq: text;
begin

    assign (arq, 'Compromissos da Agenda');
    {$i-} append (arq); {$i+}
    if IoResult <> 0 then
        exit;

    writeln (arq, (nomeDados) + '=' + (compromisso));

    close (arq);

end;

{--------------------------------------------------------}
{Apresenta o formulário para entrada dos dados
{--------------------------------------------------------}

procedure formDados;
var arq: text;
    numLin: integer;
    opcao: char;
label erro;
begin

    clrscr;
    textBackground (BLUE);
    mensagem ('AGFORM', 2);   {'Use as setas e preencha os campos'}
    textBackground (BLACK);

    gotoxy (1, amplFator+1);
    formCria;

    formCampo ('AGCOMPRO', inf_compromisso, compromisso, 40); {'Informe o compromisso: '}
    formCampo ('AGUM', '1:', um, 40);
    formCampo ('AGDOIS', '2:', dois, 40);
    formCampo ('AGTRES', '3:', tres, 40);
    formCampo ('AGAVIS', inf_aviso, aviso, 2); {'Deseja ser avisado? '}
    formCampo ('AGMAIL', inf_mail, mail, 2); {'Deseja criar e-mail? '}
    formCampo ('AGENDMAI', inf_endMai, endMai, 40); {'Endereço eletrônico: '}
    formCampo ('AGTEXMAI', inf_textMai, textMai, 40); {'Arquivo do e-mail: '}
    formCampo ('AGGASTOS', inf_gastos, gastos, 2); {'Inserir gastos pessoais? '}
    formCampo ('AGNOMGRU', inf_nomeGru, nomGru, 40); {'Grupo de trabalho: '}
    formCampo ('AGDEBCRD', inf_debcred, debCred, 2); {'Débito ou crédito? '}
    formCampo ('AGVALOR', inf_valor, valor, 30); {'Valor'}
    formCampo ('AGDESCRI', inf_descri, descri, 40); {'Descrição: '}

    formEdita (true);

    if procurandoCompromissos then
        exit;

    if compromisso = '' then
        begin
            mensagem ('AGCOMVAZ', 1);  {'Campo compromisso está vazio'}
            goto erro;
        end;

    if ((mail = 's') or (mail = 'S'))
    and ((endmai = '') or (textMai = '')) then
        begin
            mensagem ('AGNAOMAI', 1);  {'Um dos campos relativos à criação de e_mail não foi preenchido corretamente'}
            goto erro;
        end;

    if (gastos = 's') or (gastos = 'S') then
        if (debCred <> 'd') and (debCred <> 'D')
        and (debCred <> 'c') and (debCred <> 'C') then
            begin
                mensagem ('AGNAOGAS', 1);  {'Um dos campos relativos à gastos pessoais não foi preenchido corretamente'}
                goto erro;
            end;

    if ((gastos = 's') or (gastos = 'S'))
    and ((nomGru = '')
    or (valor = '') or (descri = '')) then
        begin
            mensagem ('AGNAOGAS', 1);  {'Um dos campos relativos à gastos pessoais não foi preenchido corretamente'}
            goto erro;
        end;

    if not podeGravarNomeArq and (compromisso <> comparaCompromisso) then
        begin
            assign (arq, 'Compromissos da Agenda');
            {$i-} rewrite (arq); {$i+}
            if IOresult <> 0  then
                goto erro;

            for numLin:= 1 to maxLin do
                begin

                    if copy (linhaCompromisso[numLin], 1, 16) = nomeDados then
                        begin
                            delete (linhaCompromisso[numLin], 18, length (linhaCompromisso[numLin]));
                            linhaCompromisso[numLin]:= (linhaCompromisso[numLin] + compromisso);
                        end
                        else
                            writeln (arq, linhaCompromisso[numLin]);
                end;
            close (arq);
            podeGravarNomeArq:= true;
            recargaNoVetor:= true;
            exit;
        end;

    mensagem ('AGCONINC', 0);  {'Confirma a inclusão do compromisso? '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) = 'S' then
        begin
            recargaNoVetor:= true;
            exit;
        end;

erro:
    mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
    recargaNoVetor:= false;
    podeGravarNomeArq:= false;

end;

{--------------------------------------------------------}
{Grava os dados em disco
{--------------------------------------------------------}

procedure gravaFormDados;
var arq: text;
begin

    assign (arq, nomeDados);
    {$i-} rewrite (arq); {$i+}
    if IoResult <> 0 then
        exit;

    writeln (arq, 'COMPROMISSO=' + (compromisso));
    writeln (arq, '1=' + (um));
    writeln (arq, '2=' + (dois));
    writeln (arq, '3=' + (tres));
    writeln (arq, 'AVISO=' + (aviso));
    writeln (arq, 'MAIL=' + (mail));
    writeln (arq, 'ENDMAI=' + (endMai));
    writeln (arq, 'TEXTMAI=' + (textMai));
    writeln (arq, 'GASTOS=' + (gastos));
    writeln (arq, 'NOMGRU=' + (nomGru));
    writeln (arq, 'DEBCRED=' + (debCred));
    writeln (arq, 'VALOR=' + (valor));
    writeln (arq, 'DESCRI=' + (descri));

    close (arq);

    mensagem ('AGDADGRA', 1);  {'OK, os dados foram gravados'}

end;

{--------------------------------------------------------}
{Rotina principal
{--------------------------------------------------------}

procedure iniciaDados;
begin

    existeNomeArqNoVetor;
    carregaVariaveis;
    formDados;
    if recargaNoVetor then
        gravaFormDados;
    if podeGravarNomeArq then
    gravaNomeArq;

end;

end.
