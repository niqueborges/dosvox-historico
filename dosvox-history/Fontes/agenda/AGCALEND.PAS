{--------------------------------------------------------}
{                  AGENVOX - calendário
{--------------------------------------------------------}

unit agCalend;

interface

uses dvCrt, dvWin, dvHora,
    agCalen2, agFolhei, agUtil, agVars, agMsg;

procedure menuCalendario;
procedure trataTecladoCalendario;
procedure falaDiaAtual (c: char);
procedure carregaCalendario;

var calend: TCalend;

implementation

{--------------------------------------------------------}
{Menu de opções no calendario
{--------------------------------------------------------}

procedure menuCalendario;
begin

    tocaEfeito ('agMenu');
    clrscr;

    mensagem ('AGOPTEC', 1);  {'Opções nas teclas:'}
    mensagem ('AGMOVLIN', 1);  {'Setas cima e baixo, proporcionam a movimentação nas linhas'}
    mensagem ('AGMOVCOL', 1);  {'Setas direita e esquerda, proporcionam a movimentação nas colunas'}
    mensagem ('AGUPDN', 1);  {'As teclas PGUP e PGDOWN, alternam os meses'}
    mensagem ('AGHMED', 1);  {'As teclas HOME e END, alternam os anos'}
    mensagem ('AGIS', 1);  {'A tecla INS, informa dia, mês e ano'}
    mensagem ('AGER', 1);  {'A tecla ENTER, ativa a função de folheamento'}
    mensagem ('AGQUALOP', 0);  {Qual sua opção? '}

    calend.mostraCalend;

end;

{--------------------------------------------------------}
{Trata teclado no calendario
{--------------------------------------------------------}

procedure trataTecladoCalendario;
var c1, c2: char;
    processando: boolean;
label executa;
begin

    processando := true;
    while (processando)  do
       begin
           sintTecla (c1, c2);

           if (c1 = #0) and (c2 = CIMA) then
                begin
                    tocaEfeito ('agColuna');
                    calend.dia:= calend.dia - 7;
                    falaDiaAtual ('d');
                end
           else
           if (c1 = #0) and (c2 = BAIX) then
                begin
                    tocaEfeito ('agColuna');
                    calend.dia:= calend.dia + 7;
                    falaDiaAtual ('d');
                end
           else
           if (c1 = #0) and (c2 = DIR) then
                begin
                    tocaEfeito ('agLInha');
                    calend.dia:= calend.dia + 1;
                    falaDiaAtual ('d');
                end
           else
           if (c1 = #0) and (c2 = ESQ) then
                begin
                    tocaEfeito ('agLinha');
                    calend.dia:= calend.dia - 1;
                    falaDiaAtual ('d');
                end
           else
           if (c1 = #0) and (c2 = PGUP) then
                begin
                    calend.dia:= 1;
                    calend.Mes := calend.mes - 1;
                    falaDiaAtual ('m');
                end
           else
           if (c1 = #0) and (c2 = PGDN) then
                begin
                    calend.dia:= 1;
                    calend.Mes := calend.mes + 1;
                    falaDiaAtual ('m');
                end
           else
           if (c1 = #0) and (c2 = HOME) then
                begin
                    calend.dia:= 1;
                    calend.ano:= calend.ano - 1;
                    falaDiaAtual ('a');
                end
           else
           if (c1 = #0) and (c2 = TEND) then
                begin
                    calend.dia:= 1;
                    calend.ano:= calend.ano + 1;
                    falaDiaAtual ('a');
                end
           else
           if (c1 = #0) and (c2 = ins) then
                begin
                    falaDiaAtual ('*');
                end
           else
           if (c1 = #0) and (c2 = F1) then
               menuCalendario
           else
           if (c1 = #0) and (c2 = F8) then
               begin
                   falaDia;
                   FalaHora;
               end
           else
executa:
               case upcase(c1) of

                   ^X: sintReadln (dbg);

                   ENTER:
                       begin
                           dia:= calend.dia;
                           mes:= calend.mes;
                           ano:= calend.ano;
                           verificaCompromissos;
                           trataTecladoFolhear;
                           tocaEfeito ('agVolta');
                           mensagem ('AGSETCAL', 1);  {'Calendário, use as setas, F1 ajuda'}
                       end;
                   ESC:  processando := false;
               else
                   mensagem ('AGOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
               end;
       end;
    clrscr;
end;

{--------------------------------------------------------}
{Fala dia da semana, dia, mês e ano
{--------------------------------------------------------}

procedure falaDiaAtual (c: char);
var s: string;
begin

    calend.marcaDia:= calend.dia;

    if c = 'd' then
        begin
            str (calend.dia, s);
            if s <> '0' then
                begin
                    sintetiza (calend.NomeDoDia);
                    sintetiza ('Dia' + s);
                end
                else
                    tocaEfeito ('agNada');
            exit;
        end;

    if c = 'm' then
        begin
            sintetiza (nomeMes [calend.Mes]);
            exit;
        end;

    if c = 'a' then
        begin
            str (calend.ano, s);
            sintetiza (s);
            exit;
        end;

    if c = '*' then
        begin
            sintetiza (calend.nomeDoDia);
            str (calend.dia, s);
            sintetiza (s + ' de ' + nomeMes [calend.Mes] + ' de ');
            str (calend.ano, s);
            sintetiza (s);
            exit;
        end;

end;

{--------------------------------------------------------}
{Inicializa calendário
{--------------------------------------------------------}

procedure carregaCalendario;
begin

    calend := TCalend.create;
    calend.posX:= 20;
    calend.posY:= 10;
    calend.Ano := ano;
    calend.Mes := mes;
    calend.Dia := dia;
    clrscr;
    calend.mostraCalend;
    mensagem ('AGSETCAL', 1);  {'Calendário, use as setas, F1 ajuda'}
    trataTecladoCalendario;
    calend.destroy;

end;

end.
