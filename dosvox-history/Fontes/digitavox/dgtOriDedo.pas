{--------------------------------------------------------}
{
{       Digitavox - Fala o dedo e explicação de funcionalidade de algumas teclas.
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 29/09/2019
{
{--------------------------------------------------------}

unit dgtOriDedo;

interface

uses
    dvcrt,
    dvwin,
    dgtmsg;

procedure falaDedoTecla (c, c2: char);
procedure explicarEspeciais (chave: string);
procedure orientacaoTecla (c, c2: char);

implementation

procedure falaDedoTecla (c, c2: char);
var nomeArqSom: string;
begin
    nomeArqSom := '';

    if c <> #0 then
        begin
            case upcase(c) of
                #$09 {Tab}, '\', '|', 'Q', 'A','Z','1', '2', '!', '@', '''', '"' : nomeArqSom := 'DGTMINESQ'; {'Mínimo esquerdo'}
                'S', 'W', 'X' : nomeArqSom := 'DGTANEESQ'; {'Anelar esquerdo'}
                'D', 'E', 'C', '3', '#' : nomeArqSom := 'DGTMEDESQ'; {'Médio esquerdo'}
                'F', 'G', 'R', 'T', 'V', 'B', '4', '$', '5', '%', '6', '¨' : nomeArqSom := 'DGTINDESQ'; {'Indicador esquerdo'}

                #$08 {backspace}, ENTER, 'Ç', #231, '~', '^', ']', '}', 'P', '´', '`', '[', '{', '-', '_', '=', '+', '/', '?', ';', ':' : nomeArqSom := 'DGTMINDIR'; {'Mínimo direito'}
                'L','O', '0', '9', ')', '(', '.', '>' : nomeArqSom := 'DGTANEDIR'; {'Anelar direito'}
                'K', 'I', ',', '<' : nomeArqSom := 'DGTMEDDIR'; {'Médio direito'}
                'J', 'H', 'U', 'Y', '8', '*', '7', '&', 'M','N' : nomeArqSom := 'DGTINDDIR'; {'Indicador direito'}

                ' ' : nomeArqSom := 'DGTPOLEGAR'; {'Polegar'}
            end;
        end
    else
        begin
            case c2 of
                F1: nomeArqSom := 'DGTMINESQ'; {'Mínimo esquerdo'}
                F2: nomeArqSom := 'DGTANEESQ'; {'Anelar esquerdo'}
                F3: nomeArqSom := 'DGTMEDESQ'; {'Médio esquerdo'}
                F4, F5, F6: nomeArqSom := 'DGTINDESQ'; {'Indicador esquerdo'}
                F9, F8, F7: nomeArqSom := 'DGTINDDIR'; {'Indicador direito'}
                F10: nomeArqSom := 'DGTMEDDIR'; {'Médio direito'}
                F11: nomeArqSom := 'DGTANEDIR'; {'Anelar direito'}
                F12: nomeArqSom := 'DGTMINDIR'; {'Mínimo direito'}

                 INS, DEL: nomeArqSom := 'DGTINDDIR'; {'Indicador direito'}
                HOME, TEND: nomeArqSom := 'DGTMEDDIR'; {'Médio direito'}
                PGUP, PGDN: nomeArqSom := 'DGTANEDIR'; {'Anelar direito'}

                ESQ: nomeArqSom := 'DGTINDDIR'; {'Indicador direito'}
                CIMA, BAIX: nomeArqSom := 'DGTMEDDIR'; {'Médio direito'}
                DIR: nomeArqSom := 'DGTANEDIR'; {'Anelar direito'}
            end;
        end;

    if nomeArqSom <> '' then
        mensagem (nomeArqSom, -1);
end;

{--------------------------------------------------------}

procedure explicacaoTecla (c, c2: char);
var nomeArqSom: string;
begin
    nomeArqSom := '';

    if c <> #0 then
        begin
            case c of
                #$08     : nomeArqSom := 'DGTEXPBKP';  // backspace
                #$09     : nomeArqSom := 'DGTEXPTAB';  // Tab
                ' '      : nomeArqSom := 'DGTEXPBSP';
                ENTER    : nomeArqSom := 'DGTEXPENT';
                '/'      : nomeArqSom := 'DGTEXPBAR'; 
                '*'      : nomeArqSom := 'DGTEXPAST'; 
                '-'      : nomeArqSom := 'DGTEXPINF'; 
                '+'      : nomeArqSom := 'DGTEXPMAI'; 
            end;
        end
    else
        begin
            case c2 of
                f2 .. F12: nomeArqSom := 'DGTEXPFND'; 
                F1       : nomeArqSom := 'DGTEXPF1';  
                HOME     : nomeArqSom := 'DGTEXPHOM'; 
                TEND     : nomeArqSom := 'DGTEXPEND'; 
                DEL      : nomeArqSom := 'DGTEXPDEL'; 
                INS      : nomeArqSom := 'DGTEXPINS'; 
                PGDN     : nomeArqSom := 'DGTEXPPGD'; 
                PGUP     : nomeArqSom := 'DGTEXPPGU'; 
                BAIX     : nomeArqSom := 'DGTEXPBAI'; 
                CIMA     : nomeArqSom := 'DGTEXPCIM';
                DIR      : nomeArqSom := 'DGTEXPDIR';
                ESQ      : nomeArqSom := 'DGTEXPESQ';
            end;
        end;

    if nomeArqSom <> '' then
        mensagem (nomeArqSom, 1);
end;

{--------------------------------------------------------}

procedure explicarEspeciais (chave: string);
var nomeArqSom: string;
begin
    if chave = 'DGTSHIFT' then { '<shift>' }
        nomeArqSom := 'DGTEXPSHIFT'
    else
    if (chave = 'DGTCAPS') or (chave = 'DGTNOCAPS') then { '<caps lock>' }
        nomeArqSom := 'DGTEXPCAPS'
    else
    if (chave = 'DGTNUM') or (chave = 'DGTNONUM') then { '<num.lock>' }
        nomeArqSom := 'DGTEXPNUMLO'
    else
    if chave = 'DGTCTLALT' then { '<control alt>' }
        nomeArqSom := 'DGTEXPALTGR'
    else
    if chave = 'DGTCONTRL' then { '<control>' }
        nomeArqSom := 'DGTEXPCTRL'
    else
    if chave = 'DGTALT' then { '<alt>' }
        nomeArqSom := 'DGTEXPALT'
    else
    if chave = 'DGTBLWIN' then { '<iniciar>' }
        nomeArqSom := 'DGTEXPBINIW'
    else
    if chave = 'DGTBRWIN' then { '<iniciar>' }
        nomeArqSom := 'DGTEXPBINIW'
    else
    if chave = 'DGTBRAPPL' then { '<aplicações>' }
        nomeArqSom := 'DGTEXPAPLIC'
    else
    if chave = 'DGTBPAUSE' then { '<pause>' }
        nomeArqSom := 'DGTEXPPAUSA'
    else
    if chave = 'DGTBSLOCK' then{ '<scroll lock>' }
        nomeArqSom := 'DGTEXPSCROLL'
    else
    if chave = 'DGTBPRSCR' then { '<print screen>' }
        nomeArqSom := 'DGTEXPPRINT'
    else
        exit;

    mensagem (nomeArqSom, 1);
end;

{--------------------------------------------------------}

procedure orientacaoTecla (c, c2: char);
begin
    falaDedoTecla (c, c2);
    delay (50);
    explicacaoTecla (c, c2);
end;

{--------------------------------------------------------}

begin
end.
