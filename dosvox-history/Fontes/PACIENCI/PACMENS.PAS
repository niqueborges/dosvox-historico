{--------------------------------------------------------}
{
{   Mensagens do Jogo de Paciencia Falado
{
{   Autor: Jose' Antonio Borges
{
{   Em 27/9/97
{
{--------------------------------------------------------}

unit pacmens;
interface

uses DVcrt, pacVars, DVWin;

procedure mensagem (codigo: string);
procedure mensCont (codigo: string);
procedure mensCarta (qualCarta: integer);
procedure mensNumero (n: integer);
procedure mensAjuda;

const
    tabSomNaipes: array [COPAS..ESPADAS] of string [8]= (
        'PACOPAS',   { de copas }
        'PAOUROS',   { de ouros }
        'PAPAUS',    { de paus }
        'PAESPADA'); { de espadas }

    tabSomNumero : array [1..7] of string [8] = (
         'PAUM',      { mensagens de 1 ate' 7 }
         'PADOIS',
         'PATRES',
         'PAQUATRO',
         'PACINCO',
         'PASEIS',
         'PASETE');

    tabCartas: array [0..13] of string [4] = (
        'nada',
        'A', '2', '3', '4', '5', '6', '7','8','9', '10',
        'J', 'Q', 'K'
    );

    tabSomCarta: array [0..13] of string [8] = (
         'PANADA',    { nada }
         'PAAS',      { mensagens de as ate' rei }
         'PADOIS',
         'PATRES',
         'PAQUATRO',
         'PACINCO',
         'PASEIS',
         'PASETE',
         'PAOITO',
         'PANOVE',
         'PADEZ',
         'PAVALETE',
         'PADAMA',
         'PAREI');

    tabNaipes: array [COPAS..ESPADAS] of char = (
        #$3, #$4, #$5, #$6);

implementation

{-----------------------------------------------------------}
{                    lista de mensagens
{-----------------------------------------------------------}

function mens (codigo: string): string;
begin
    if codigo = 'PAUM' then mens := 'um'
    else
    if codigo = 'PATEMPOJ' then mens := 'Tempo de jogo: '
    else
    if codigo = 'PAVAZIA'  then mens := ' vazia.'
    else
    if codigo = 'PAATE'    then mens := ' a '
    else
    if codigo = 'PANASPIL' then mens := 'Nas pilhas:'
    else
    if codigo = 'PAINTRO'  then mens := '' {'Paciencia Vox !'}
    else
    if codigo = 'PACOLUNA' then mens := 'Coluna '
    else
    if codigo = 'PAFECHAD' then mens := 'Por abrir: '
    else
    if codigo = 'PAQUEPIL' then mens := 'De que pilha (Copas, Ouros, Paus ou Espadas) ? '
    else
    if codigo = 'PADESIST' then mens := 'Desistiu !'
    else
    if codigo = 'PAINCOMP' then mens := 'Naipes incompativeis ! '
    else
    if codigo = 'PAPILNAD' then mens := 'Esta pilha nao tem nada !'
    else
    if codigo = 'PAVALINC' then mens := 'Valores incompativeis ! '
    else
    if codigo = 'PANAPILH' then mens := 'Na pilha tem '
    else
    if codigo = 'PAMOVVAZ' then mens := 'Movi, coluna ficou vazia.'
    else
    if codigo = 'PAAGORA'  then mens := 'Agora '
    else
    if codigo = 'PAMOVFIC' then mens := 'Movi, ficou '
    else
    if codigo = 'PADSTERR' then mens := 'Comando errado, escolha destino !'
    else
    if codigo = 'PADESTIN' then mens := 'Escolha destino'
    else
    if codigo = 'PADESINV' then mens := 'Destino invalido, comando cancelado !'
    else
    if codigo = 'PAVAZIO'  then mens := 'Vazio.'
    else
    if codigo = 'PAMOVABR' then mens := 'Movi e abri '
    else
    if codigo = 'PANAOTIR' then mens := 'Nao existem cartas tiradas !'
    else
    if codigo = 'PAULTTIR' then mens := 'Ultimas cartas tiradas: '
    else
    if codigo = 'PAACABAC' then mens := 'Acabaram-se todas as cartas.'
    else
    if codigo = 'PARETBAR' then mens := 'Retornando o maco do baralho.'
    else
    if codigo = 'PATIRADO' then mens := 'Tirado '
    else
    if codigo = 'PAFIMBAR' then mens := 'Fim do baralho !'
    else
    if codigo = 'PANAOTIR' then mens := 'Nao ha cartas tiradas !'
    else
    if codigo = 'PANAIINC' then mens := 'Naipes incompativeis !'
    else
    if codigo = 'PACARINC' then mens := 'Carta incompativel, nao posso mover !'
    else
    if codigo = 'PAMOVBAR' then mens := 'Tirei do baralho '
    else
    if codigo = 'PANOBAR'  then mens := 'No baralho agora '
    else
    if codigo = 'PANADA'   then mens := 'nada'
    else
    if codigo = 'PANAOPOS' then mens := 'Nao posso, na pilha tem '
    else
    if codigo = 'PACNFFIM' then mens := 'Confirma fim desta partida (sim ou nao) ? '
    else
    if codigo = 'PAOPCERR' then mens := 'Opcao errada, aperte F1 para ajuda'
    else
    if codigo = 'PAINIJOG' then mens := 'Iniciando jogo !'
    else
    if codigo = 'PADENOVO' then mens := 'Quer jogar de novo (sim ou nao) ? '
    else
    if codigo = 'PAGANHOU' then mens := ''
    else
    if codigo = 'PAFIM'    then mens := 'Entao tchau !'
    else
        mens := ^g^g^g^g^g^g^g + codigo;
end;

{--------------------------------------------------------}
{      escreve e fala um texto na linha de mensagens
{--------------------------------------------------------}

procedure mensagem (codigo: string);
var s: string;
begin
    textBackGround (RED);
    gotoxy (1, 25);
    clreol;
    if codigo = '' then exit;

    s := mens(codigo);
    write (s);
    sintSom (codigo)
end;

{--------------------------------------------------------}
{                 ajuda geral da paciencia
{--------------------------------------------------------}

procedure mensAjuda;
begin
    textBackGround (BLACK);
    clrscr;
    textBackGround (RED);
    writeln ('Paciencia VOX - Lista de comandos');
    textBackGround (BLACK);
    writeln;
    writeln ('Comandos de coluna');
    writeln ('    Dir e Esq     vai para proxima coluna');
    writeln ('    Cima e Baixo  escolhem a parte desejada desta coluna');
    writeln ('    Enter         move cartas selecionadas para outra coluna');
    writeln ('    Del           move da coluna atual para a pilha de naipes');
    writeln ('    PageUp        le toda coluna');
    writeln ('    Home          informa cartas selecionadas');
    writeln;
    writeln ('Comandos de baralho');
    writeln ('    Tab     da cartas');
    writeln ('    espaco  move do baralho para a coluna atual');
    writeln ('    End     rele as tres ultimas cartas tiradas');
    writeln;
    writeln ('Comandos da pilha');
    writeln ('    PageDn  le as pilhas dos 4 naipes');
    writeln ('    Bs      move do baralho uma pilha de naipes');
    writeln ('    Ins     move de uma pilha de naipes para a coluna atual');
    writeln;
    writeln ('Outros comandos');
    writeln ('    F1      ajuda;');
    writeln ('    F8      mostra o tempo de jogo');
    write   ('    Esc     cancela o jogo');

    sintSom ('PAAJUDA');

    readkey;
    while keypressed do readkey;

    sintSom ('PAEFEIT1');
end;

{--------------------------------------------------------}
{         escreve e fala um texto em continuacao
{--------------------------------------------------------}

procedure mensCont (codigo: string);
var s: string;
begin
    s := mens(codigo);
    write (s);
    sintSom (codigo)
end;

{--------------------------------------------------------}
{                 escreve e fala uma carta
{--------------------------------------------------------}

procedure mensCarta (qualCarta: integer);
var
    naipe, valor: byte;

begin
    valor := qualCarta shr 3;
    if valor = 0 then
        begin
             write (tabCartas [valor]);
             sintSom (tabSomCarta [valor]);
             exit;
        end;

    naipe := qualCarta and 7;
    write (tabCartas [valor], tabNaipes [naipe]);

    sintSom (tabSomCarta [valor]);
    sintSom (tabSomNaipes [naipe]);
end;

{--------------------------------------------------------}
{                 escreve e fala um numero
{--------------------------------------------------------}

procedure mensNumero (n: integer);
begin
    write (n);
    sintSom (tabSomNumero [n]);
end;

end.
