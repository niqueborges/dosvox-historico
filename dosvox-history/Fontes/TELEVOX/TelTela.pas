{--------------------------------------------------------}
{       televox - rotinas de manuseio da tela
{--------------------------------------------------------}

unit teltela;

interface
Uses
    DVCrt, DVWin, TelVars, telMsg;

Procedure logotipo;
Procedure limpatela;
function obtemItem (qual, postab: integer): string;
function mostraItem (qual, postab: integer; falando: boolean): string;
procedure imprime (cima: boolean);
procedure liga;
procedure desliga;
procedure recua (quanto: integer);
procedure avanca (quanto: integer);
procedure vaiParaPrimeiro;
procedure vaiParaUltimo;

const
    topo = 5;    {Posição limite superior da tela do folheamento}
    FUNDOPADRAO = 23;    {Posição limite inferior da tela do folheamento}

var
    posFolheia: integer; {Posição de folheamento na tela}
    posAtualFolheia: integer; {Posição verdadeira do campo do registro}
    posTabFolheia: integer; {Posição verdadeira do registro}
    fundo: integer; {Posição inferior da tela}
    campoConfigura: boolean; {Verdadeiro tela de configuraçao, falso folheia registros}

implementation

{--------------------------------------------------------}
{                    limpa a tela
{--------------------------------------------------------}

Procedure logotipo;
begin
    gotoxy (1, 1);
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('TVCADTV') + VERSAO); {'CADERNO DE TELEFONES - VOX - Versão '}
    textBackground (BLACK);

    gotoxy (1, 10);
    writeln ('******  *******  **       ******   **   **   *****   **   **');
    writeln ('  **    **       **       **       **   **  **   **   ** ** ');
    writeln ('  **    **       **       **       **   **  **   **    ***  ');
    writeln ('  **    *****    **       *****    **   **  **   **     *   ');
    writeln ('  **    **       **       **        ** **   **   **    ***  ');
    writeln ('  **    **       **       **         ***    **   **   ** ** ');
    writeln ('  **    *******  *******  *******     *      *****   **   **');
    writeln;
end;

{--------------------------------------------------------}
{                 limpa a tela
{--------------------------------------------------------}

procedure limpaTela;
begin
    clrscr;
    writeln (pegaTextoMensagem ('TVCADTV') + VERSAO); {'CADERNO DE TELEFONES - VOX - Versão '}
    writeln;
end;

{--------------------------------------------------------}
{                  obtem um item pelo numero
{--------------------------------------------------------}

function obtemItem (qual, postab: integer): string;
var
    pcampo: pString;
begin
    pcampo := listaFone [postab]^.campoCad[qual];
    if pcampo = NIL then
        obtemItem := ''
    else
        obtemItem := pcampo^;
end;

{--------------------------------------------------------}
{                  mostra itens na tela
{--------------------------------------------------------}

function mostraItem (qual, postab: integer; falando: boolean): string;
var
     texto, fala: string;
    campo: string;
begin
    texto := tabTexto [qual];
    fala := tabFala [qual];
    campo := obtemItem (qual, posTab);
    posTabFolheia := posTab;
    posAtualFolheia := qual;

    if falando then
        if (fala <> '') and (existeArqSom (fala)) then
            sintsom (fala)
        else
            sintetiza (texto);

    mostraItem := campo;
end;

{--------------------------------------------------------}
{          Tratamento da tela com rolagem
{--------------------------------------------------------}

function escreveNome (qual: integer): string;
const brancos = '                                                         ';
var
    s, s1, s2: string;
begin
    if campoConfigura then
    begin
            s :=copy (tabTexto[qual] + BRANCOS, 1, 20);
            s1 :=copy (tabFala[qual] + BRANCOS, 1, 13);
            s2 := tabMalaDir[qual];
    end
    else
        begin
            s := copy (tabTexto [qual]+brancos, 1, 15);
            s1 := obtemItem (qual, posTabFolheia);
            s2:= '';
        end;

    escreveNome:= copy (s + s1 + s2, 1, 80);
end;

{--------------------------------------------------------}

procedure liga;
begin
    textColor (yellow);
    gotoxy (1, posFolheia);
    write (escreveNome (posAtualFolheia));
    textColor (WHITE);
    clreol;
end;

{--------------------------------------------------------}

procedure desliga;
begin
    textColor (WHITE);
    gotoxy (1, posFolheia);
    write (escreveNome (posAtualFolheia));
    clreol;
end;

{--------------------------------------------------------}

procedure limpaTelaFolheia;
var i: integer;
begin
    for i := topo to fundo do
    begin
        gotoxy (1,i); clreol;
    end;
end;

{--------------------------------------------------------}

procedure imprime (cima: boolean);
var i: integer;
begin
    limpaTelaFolheia;
    if numCampos = (fundo - topo + 1) then
        for i := 0 to (fundo - topo) do
        begin
            gotoxy (1, (topo + i));
            write (escreveNome (i + 1));
        end
    else
    if cima then
        for i := (fundo - topo) downto 0 do
        begin
            gotoxy (1, (posFolheia - i));
            write (escreveNome (posAtualFolheia - i));
        end
    else
        for i := 0 to (fundo - topo) do
        begin
            gotoxy (1, (posFolheia + i));
            if (posAtualFolheia + i) > numCampos then
                break;
            write (escreveNome (posAtualFolheia + i));
        end;
end;

{--------------------------------------------------------}

procedure avanca (quanto: integer);
var i: integer;
begin
    desliga;
    i := posAtualFolheia;
    posAtualFolheia := posAtualFolheia + quanto;
    if posAtualFolheia > numCampos then
    begin
        posAtualFolheia := numCampos;
        posFolheia := posFolheia + posAtualFolheia - i;
    end
    else
        posFolheia := posFolheia + quanto;

    if posFolheia > fundo then
    begin
        posFolheia := fundo;
        imprime (TRUE);
    end;

    liga;
end;

{--------------------------------------------------------}

procedure vaiParaUltimo;
begin
    desliga;
    posAtualFolheia := numCampos;
    posFolheia := fundo;
    imprime (TRUE);
    liga;
end;

{--------------------------------------------------------}

procedure recua (quanto: integer);
begin
    desliga;
    posAtualFolheia := posAtualFolheia - quanto;
    if posAtualFolheia < 1 then
    begin
        posAtualFolheia := 1;
        posFolheia := topo;
    end
    else
        posFolheia := posFolheia - quanto;

    if posFolheia < topo then
    begin
        posFolheia := topo;
        imprime (FALSE);
    end;

    liga;
end;

{--------------------------------------------------------}

procedure vaiParaPrimeiro;
begin
    desliga;
    posAtualFolheia := 1;
    posFolheia := topo;
    imprime (FALSE);
    liga;
end;

end.
