unit cdSelec;

interface

uses dvCrt, dvWin, dvArq, dvForm,
    sysUtils,
    cdUtil, cdVars, cdMsg;

procedure InsMasc;
procedure remMasc;

procedure selArqs;
procedure modificaSelec;

implementation

{--------------------------------------------------------}

procedure insMasc;
var opcao: char;
begin

    writeln;
    mensagem ('CDINS', 1); {'Inserindo')}
    delay (100);

    mensagem ('CDDIGTP', 0); {'Digite T para TXT ou P para partes já divididas : ')}
    opcao:= popupMenuPorLetra ('TP');

    if opcao = 'T' then
    begin
        if not selNomArqs(dirTexto, 'T') then
        begin
            mensagem ('CDNAOTXT', 1); {'Não há TXT para que eu possa incluir')}
            semArqTXt:= true;
            if selNomArqs(dirTexto, 'P') then
                semArqPAR:= false;
            exit;
        end;
    end
    else
    if opcao = 'P' then
    begin
        if not selNomArqs(dirTexto, 'P') then
        begin
            mensagem ('CDNAOPAR', 1); {'Não há partes divididas para que eu possa incluir')}
            semArqPar:= true;
            if selNomArqs(dirTexto, 'T') then
                semArqTXT:= false;
            exit;
        end;
    end
    else
    begin
        mensagem ('CDOPCAN', 1); {'Opção inválida, operação cancelada')}
        exit;
    end;

    writeln;
    mensagem ('CDTOTAL', 0); {'Total de arquivo(s) incluído(s) --- ')}
    sintWriteInt (numArqs);
    writeln;

    dirSom:= '';

end;

{--------------------------------------------------------}

procedure remMasc;
var opcao: char;
begin

    writeln;
    mensagem ('CDREM', 1); {'Removendo')}
    delay (100);

    if remTotArqs then
        mensagem ('CDREMQQ', 0) {'Digite T para TXT, P para partes já divididas  ou * para todos : ')}
    else
    mensagem ('CDDIGTP', 0); {'Digite T para TXT ou P para partes já divididas : ')}
    opcao:= popupMenuPorLetra ('TP');

    if opcao = 'T' then
        remNomArqs(dirTexto, 'T')
    else
    if opcao = 'P' then
        remNomArqs(dirTexto, 'P')
    else
    if remTotArqs then
    begin
        if opcao = '*' then
            remNomArqs(dirTexto, '*');
            remTotArqs:= false;
    end
    else
        mensagem ('CDOPCAN', 1); {'Opção inválida, operação cancelada')}

end;

{--------------------------------------------------------}

procedure selArqs;
var
    i, j, k: integer;
    c1, c2: char;
    s: string;
    selec: boolean;
label cancela;

begin

    j := 0;
    if (semArqTxt) and (semArqPar) then
        begin
            mensagem ('CDNAOSEL', 1); {'O diretório padrão não contém nenhum arquivo a selecionar')}
            exit;
        end;

    mensagem ('CDSELSET', 1); {'Escolha o(s) arquivo(s) com as setas')}
    delay (100);
    mensagem ('CDENTFIN', 1); {'Pressione ENTER ao final da seleção')}

    k:= numArqs;

    folheiaCria (0, wherey, 80, wherey+ k);

    for i:= 1 to k do
        folheiaAdiciona (nomeArqTxt[i]);

    if folheiaExecuta (1, k, c1, c2, true) then
        begin
//            clrscr;
//            sintWriteln ('Item selecionado ' + intToStr(numArqs));
//            sintWriteln ('caracteres ' + intTostr(ord(c1)) + ' ' + intToStr(ord(c2)));
//            writeln;
            if c1 <> ENTER then
                goto cancela;
            j:= 0;
            for i := 1 to k do
                begin
                    folheiaObtemItem(i, s, selec);
                    if selec then
                    begin
                        j:= j + 1;
                        nomeArqtxt[j]:= s;
//                        clrscr;
//                        sintWrite ('Selecionei : ');
//                        sintWriteln (intToStr(i) + ' ' + s);
                    end;
                end;
        end;
//    else
//        sintWriteln ('Retornou falso');

    cancela:

    clrscr;
    writeln;

    if selec then
    begin
        numArqs:= j;
        mensagem ('CDOKSEL', 1); {'OK, feita a seleção'}
    end
    else
        mensagem ('CDDESIST', 1);

end;

{--------------------------------------------------------}

procedure modificaSelec;
var opcao: char;
begin

    if (semArqTxt) and (semArqPar) then
        begin
            sintBip; sintBip;
            mensagem ('CDNAOSEL', 1); {'O diretório padrão não contém nenhum arquivo a selecionar')}
            exit;
        end;

    mensagem ('CDDIG', 1); {'Digite : ')}
    delay (200);
    mensagem ('CDINSMAS', 1); {'I para inserir por máscara')}
//    delay (100);
//    mensagem ('CDREMMAS', 1); {'R para remover por máscara')}
    delay (100);
    mensagem ('CDSELARQ', 1); {'S para selecionar por arquivo')}
    write ('Qual sua opção ? ');
    opcao:= popupMenuPorLetra ('IS');

    if opcao = 'I' then
        insMasc
//    else
//    if upcase(opcao) = 'R' then
//        remMasc
    else
    if opcao = 'S' then
        selArqs
    else
    if opcao = ESC then
        mensagem ('CDDESIST', 1)
    else
        mensagem ('CDOPCAN', 1); {'Opção inválida, operação cancelada')}

end;

{--------------------------------------------------------}

begin
end.

