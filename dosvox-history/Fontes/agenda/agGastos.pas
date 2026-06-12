{--------------------------------------------------------}
{                  AGENVOX - controle de gastos
{--------------------------------------------------------}

unit agGastos;

interface

uses dvcrt, dvWin, dvForm, dvArq, dvHora, dvExec, dvAmplia,
    winDows, shellApi, sysUtils,
    agProg, agUtil, agVars, agMsg;

function consisteConvValor (v: string; var valor: double): boolean;
function poeZeroZero (s: string): string;
procedure lancaGastos (n, dc, v, d: shortString);
procedure imprimiExtrato;
procedure editaExtrato;
procedure editaGrupo;
procedure geraExtrato;
procedure gravaFormGastos;
procedure formGastos;
procedure removeGrupoDeTrabalho;
procedure escolheGrupoDeTrabalho;
procedure menuGastos;
procedure trataTecladoGastos;

var arq, arq1: text;
    nomeGrupo, debCred, valor, descri: shortString;
    jaCarregouVar: boolean;

implementation

{--------------------------------------------------------}

function consisteConvValor (v: string; var valor: double): boolean;
var
    p1, p2, pErro: integer;
label retErro;
begin
    p1 := pos ('.', v);
    p2 := pos (',', v);

    if (p1 <> 0) and (p2 <> 0) then
        goto retErro;

    if p2 <> 0 then
         begin
             v[p2] := '.';
             p1 := p2;
         end;

    if (p1 = 0) or (p1 <> (length (v) - 2)) then
        goto retErro;

    val (v, valor, pErro);
    if pErro <> 0 then goto retErro;
    if valor < 0.0 then goto retErro;

    consisteConvValor := true;
    exit;

retErro:
    consisteConvValor := false;
    valor := 0;
end;

{--------------------------------------------------------}

function poeZeroZero (s: string): string;
var i: integer;
begin

    i:= pos (',', s);
    if i <> 0 then
        begin
            delete (s, i, 1);
            insert ('.', s, i);
        end;

    i:= pos ('.', s);
    if i = 0 then
        poeZeroZero := (s + '.00')
    else
        poeZeroZero := (s);

end;

{--------------------------------------------------------}
{Trata gastos vindos da geração de e_mail automático
{--------------------------------------------------------}

procedure lancaGastos (n, dc, v, d: shortString);
begin

    nomeGrupo:= n;
    data:= (dd + '/' + mm + '/' + aa);
    debCred:= dc;
    valor:= v;
    descri:= d;

    jaCarregouVar:= true;
    formGastos;

end;

{--------------------------------------------------------}
{Possibilita a impressão dos extratos gerados
{--------------------------------------------------------}

procedure imprimiExtrato;
var nomeProg: string;
begin

    if not trocaDir (dir_extratosGerados) then
        exit;

    if not existeGrupo (nomeGrupo) then
        exit;

    nomeProg := sintAmbiente ('AGENDA', 'PRINTPROG');

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\listavox.exe';
        nomeGrupo:= '"' + nomeGrupo + '"';

    delay (500);
    if executaProg (nomeProg, '', nomeGrupo) < 32 then;
        esperaProgVoltar;
    delay (1000);

        delete (nomeGrupo, 1, 1);
        delete (nomeGrupo, length(nomeGrupo), 1);

end;

{--------------------------------------------------------}
{Possibilita a edição dos extratos gerados
{--------------------------------------------------------}

procedure editaExtrato;
var nomeProg: string;
begin

    if not trocaDir (dir_extratosGerados) then
        exit;

    if not existeGrupo (nomeGrupo) then
        exit;

    nomeProg := sintAmbiente ('AGENDA', 'BLOCOPROG');

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\edivox.exe';
        nomeGrupo:= '"' + nomeGrupo + '"';

    delay (500);
    if executaProg (nomeProg, '', nomeGrupo) < 32 then;
        esperaProgVoltar;
    delay (1000);

        delete (nomeGrupo, 1, 1);
        delete (nomeGrupo, length(nomeGrupo), 1);

end;

{--------------------------------------------------------}
{Possibilita a edição dos gastos gerados - Não disponível ao usuário
{--------------------------------------------------------}

procedure editaGrupo;
var nomeProg: string;
begin

    if not trocaDir (dir_entradaDeDadosGastos) then
        exit;

    if not existeGrupo (nomeGrupo) then
        exit;

    nomeProg := sintAmbiente ('AGENDA', 'BLOCOPROG');

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\edivox.exe';
        nomeGrupo:= '"' + nomeGrupo + '"';

    delay (500);
    if executaProg (nomeProg, '', nomeGrupo) < 32 then;
        esperaProgVoltar;
    delay (1000);

        delete (nomeGrupo, 1, 1);
        delete (nomeGrupo, length(nomeGrupo), 1);

end;

{--------------------------------------------------------}
{Gera extrato e grava em disco
{--------------------------------------------------------}

procedure geraExtrato;
var linha: shortString;
    cr, db, calculoGeral: double;
    v: double;
label deNovo;
begin

    if not trocaDir (dir_extratosGerados) then
        exit;

    assign (arq, dirTrab + dir_entradaDeDadosGastos + '\' + nomeGrupo);
    {$i-} reset(arq); {$i+}
    if IOresult <> 0  then
        exit;

    assign (arq1, nomeGrupo);
    {$i-} rewrite (arq1); {$i+}
    if IOresult <> 0  then
        exit;

    writeln (arq1, 'Extrato gerado em: ' + (data));
    writeln (arq1);

    cr:= 0;
    db:= 0;
    v:= 0;

    while not eof (arq) do
        begin
            deNovo:
            readln (arq, linha);

            if linha[1] = '*' then
                begin
                    delete (linha , 1, 1);
                    write (arq1, (linha) + ' = ');
                    goto deNovo;
                end;

            if (linha[1] = 'c') or (linha[1] = 'C') then
                begin
                    delete (linha, 1, 1);
                    write (arq1, 'CR ');
                    write (arq1, linha);
                    consisteConvValor (linha, v);
                    cr:= cr + v;
                            goto deNovo;
                end;

            if (linha[1] = 'd') or (linha[1] = 'D') then
                begin
                    delete (linha, 1, 1);
                    write (arq1, 'DB ');
                    write (arq1, linha);
                    consisteConvValor (linha, v);
                    db:= db - v;
                    goto deNovo;
                end;

            if linha[1] = '#' then
                begin
                    delete (linha , 1, 1);
                    writeln (arq1, ' dia: ' + (linha));
                    goto deNovo;
                end;

        end;
    close (arq);

    writeln (arq1);
    write (arq1, 'Total a creditar: ');
    writeln (arq1, cr:10:2);
    write (arq1, 'Total a debitar: ');
    writeln (arq1, db:10:2);
    write (arq1, 'Cálculo geral: ');

    calculoGeral:= (cr + db);
    if calculoGeral < 0 then
        write (arq1, 'negativo em R$')
    else
        write (arq1, 'R$');

    writeln (arq1, calculoGeral:10:2);
    writeln (arq1, 'Fim do extrato');

    close (arq1);

    mensagem ('AGOKEXT', 1);  {'OK, extrato gerado'}

end;

{--------------------------------------------------------}
{Grava o formulário em disco
{--------------------------------------------------------}

procedure gravaFormGastos;
begin

    if not trocaDir (dir_entradaDeDadosGastos) then
        exit;

    assign (arq, nomeGrupo);
    {$i-} append(arq); {$i+}
    if IOresult <> 0  then
        rewrite (arq);

    writeln (arq, '@');
    writeln (arq, '*' + (descri));
    write (arq, debCred);
    writeln (arq, valor);
    writeln (arq, '#' + (data));

    close (arq);

    mensagem ('AGDADGRA', 1);  {'OK, os dados foram gravados'}

end;

{--------------------------------------------------------}
{Apresenta o formulário para entrada dos gastos
{--------------------------------------------------------}

procedure formGastos;
var opcao: char;
begin

    if not jaCarregouVar then
        begin
            debCred:= '';
            valor:= '';
            descri:= '';
        end;

    clrscr;
    textBackground (BLUE);
    mensagem ('AGFORM', 2);   {'Use as setas e preencha os campos'}
    textBackground (BLACK);

    gotoxy (1, amplFator+1);
    formCria;

    formCampo     ('AGNOMGRU', inf_nomeGru, nomeGrupo, 40); {'Grupo de trabalho'}
    formCampo     ('AGDATA', inf_data, data, 20); {'Data'}
    formCampo ('AGDEBCRD', inf_debCred, debCred, 2); {'Débito ou crédito'}
    formCampo ('AGVALOR', inf_valor, valor, 30); {'Valor'}
    formCampo     ('AGDESCRI', inf_descri, descri, 40); {'Descrição: '}

    formEdita (true);

    if nomeGrupo = '' then
        begin
            mensagem ('AGGRUAPA', 1);  {'Grupo de trabalho foi apagado'}
            exit;
        end;

    if (debCred <> 'd') and (debCred <> 'D')
    and (debCred <> 'c') and (debCred <> 'C') then
        begin
            mensagem ('AGNAODC', 1);  {'Você não indicou corretamente se a operação será debitada ou creditada '}
            exit;
        end;

    if valor = '' then
        begin
            mensagem ('AGVALINC', 1);  {'Valor incorreto'}
            exit;
        end;

    if descri = '' then
        begin
            mensagem ('AGNAODES', 1);  {'Você não informou a descrição da operação'}
            exit;
        end;

    mensagem ('AGCONDAD', 0);  {'Confirma a inclusão destes dados? '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) = 'S' then
        begin
            valor:= poeZeroZero (valor);
            gravaFormGastos;
        end
        else
            mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}

end;

{--------------------------------------------------------}
{Remove grupo de trabalho
{--------------------------------------------------------}

procedure removeGrupoDeTrabalho;
var opcao: char;
begin

    if not trocaDir (dir_entradaDeDadosGastos) then
        exit;

    assign (arq, nomeGrupo);
    {$i-} reset (arq); {$i+}
    if IOresult <> 0  then
        exit;

    tocaEfeito ('agFreia');
    mensagem ('AGOPREM', 0);  {'Deseja remover '}
    sintWriteln (nomeGrupo);
    mensagem ('AGSIMNAO', 0);  {', sim ou não: '}
    opcao:= sintReadKey;
    writeln;
    if upcase (opcao) = 'S' then
        begin
            close (arq);
            erase (arq);
            assign (arq1, dirTrab + dir_extratosGerados + '\' + nomeGrupo);
            {$i-} reset (arq1); {$i+}
            if IOresult = 0  then
                begin
                    close (arq1);
                    erase (arq1);
                end;
        tocaEfeito ('agFaca');
            nomeGrupo:= '';
            exit;
        end
        else
            begin
                close (arq);
                mensagem ('AGOKCAN', 1);  {'OK, operação cancelada'}
                tocaEfeito ('agVolta');
            end;

end;

{--------------------------------------------------------}
{Escolhe ou cria grupo de trabalho
{--------------------------------------------------------}

procedure escolheGrupoDeTrabalho;
begin

    if not trocaDir (dir_entradaDeDadosGastos) then
        exit;

    tocaEfeito ('agCaixa');

    getdate (ano, mes, dia, sem);
    data:= int2 (dia) + '/' + int2 (mes) + '/' + int2str (ano);

    mensagem ('AGDEFGRU', 1);  {'Definindo grupo de trabalho'}
    mensagem ('AGSETGRU', 1);  {'Caminhe com as setas ou informe um novo grupo: '}
    garanteEspacoTela (10);
    nomeGrupo:= obtemNomeArq (10);
    writeln (nomeGrupo);

end;

{--------------------------------------------------------}
{Mostra menu gastos
{--------------------------------------------------------}

procedure menuGastos;
begin

    tocaEfeito ('agMenu');

    mensagem ('AGOPTEC', 1); {'Opções nas teclas:'}
    mensagem ('AGNOVGAS', 1);  {'  N   Novos lançamentos'}
    mensagem ('AGGEREXT', 1);  {'  G   Gerar extrato'}
    mensagem ('AGEDIEXT', 1);  {'  L   Ler extrato'}
    mensagem ('AGIMPEXT', 1);  {'  I   Imprimir extrato'}
    mensagem ('AGTROGRU', 1);  {'  T   Trocar grupo'}
    mensagem ('AGREMGRU', 1);  {'  R   Remover grupo'}
    mensagem ('AGCALC', 1);  {'  F9   Calculadora'}

end;

{--------------------------------------------------------}
{            seleciona a opção com as setas no menu gastos
{--------------------------------------------------------}

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

function selSetasOpcao: char;
var n: integer;
const
    tabLetrasOpcoes: string [6] = 'nglitr';

begin
    popupMenuCria (wherex, wherey, 50, 10, MAGENTA);
    MenuAdiciona ('AGNOVGAS');  {'  N   Novos lançamentos'}
    MenuAdiciona ('AGGEREXT');  {'  G   Gerar extrato'}
    MenuAdiciona ('AGEDIEXT');  {'  L   Editar extrato'}
    MenuAdiciona ('AGIMPEXT');  {'  I   Imprimir extrato'}
    MenuAdiciona ('AGTROGRU');  {'  T   Trocar grupo'}
    MenuAdiciona ('AGREMGRU');  {'  R   Remover grupo'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}
{Tratamento do teclado no menu gastos
{--------------------------------------------------------}

procedure trataTecladoGastos;
var c1, c2: char;
    processando: boolean;
label executa;
begin

    escolheGrupoDeTrabalho;

    if nomeGrupo = '' then
        begin
            tocaEfeito ('agNada1');
            mensagem ('AGNAOESP', 1);  {'Grupo de trabalho não foi especificado'}
            exit;
        end;

    jaCarregouVar:= false;
    processando := true;
    while (processando)  do
       begin
           if nomeGrupo = '' then
               exit;

           sintWrite (nomeGrupo + ', ');
           mensagem ('AGQUALOP', 0);  {'Qual sua opção ? '}

           sintTecla (c1, c2);
           writeln;
           if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
                begin
                    c1 := selSetasOpcao;
                    goto executa;
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuGastos
           else
           if (c1 = #0) and (c2 = F9) then
           begin
               if not trocaDir (dir_entradaDeDadosGastos) then
                   exit;
               abreCalculadora;
           end
           else
           if (c1 = #0) and (c2 = F8) then
               begin
                   falaDia;
                   FalaHora;
               end
           else
executa:
               case upcase(c1) of
                   'N': formGastos;
                   'G': geraExtrato;
                   'L': editaExtrato;
                   ^E: editaGrupo;
                   'I': imprimiExtrato;
                   'T': escolheGrupoDeTrabalho;
                   'R': removeGrupoDeTrabalho;

                   ESC:  processando := false;
                   #$0d: ;
               else
                   mensagem ('AGOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;

end;

end.
