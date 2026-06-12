{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de seleção de pastas                         }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iupastas;

interface

uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes,
    dvinet,
    dvssl,
    dvform,
    iurede,
    iufolhe,
    iuenvel,
    iuvars,
    iumsg;

function pegaNum (s: string): integer;
function select (mailbox: string; mostraQuantas: boolean): boolean;
procedure obtemPastas;
procedure escolherPasta;
procedure criarPasta;
procedure apagarpasta;
procedure renomearpasta;
function decodInternat (nome: string): string;
function codifInternat (nome: string): string;

implementation

{--------------------------------------------------------}
{ extrai o primeiro número de uma  resposta              }
{--------------------------------------------------------}

function pegaNum (s: string): integer;
var erro, n: integer;
begin
    delete (s, 1, 1);
    s := trim (s);
    delete (s, pos(' ', s), 999);
    val (s, n, erro);
    result := n;
end;

{--------------------------------------------------------}
{ executa a decodificação internacional de pastas imap   }
{--------------------------------------------------------}

function decodInternat (nome: string): string;
var p: integer;
    s, conv: string;
begin
    s := '';
    while nome <> '' do
        begin
            p := pos ('&', nome);
            if p = 0 then
                begin
                    s := s + nome;
                    break;
                end;

            s := s + copy (nome, 1, p-1);
            delete (nome, 1, p);
            p := pos ('-', nome);
            if p = 0 then p := length(nome)+1;

            conv := copy (nome, 1, p-1);
            conv := DecodFraseMime64(conv);

            s := s + conv;
            delete (nome, 1, p);
        end;
    result := s;
end;

{--------------------------------------------------------}
{ executa a decodificação internacional de pastas imap   }
{--------------------------------------------------------}

function codifInternat (nome: string): string;
var saida, aconv: string;
    i: integer;

        function convInternat (aconv: string): string;
        var s: string;
            i: integer;
        begin
            for i := 0 to length(aconv)-1 do
                 insert (#0, aconv, i*2+1);
            s := codFraseMime64 (aconv);
            while s[length(s)] = '=' do
                delete (s, length(s), 1);
            result := '&' + s + '-';
        end;

begin
    saida := '';
    i := 1;
    while i <= length(nome) do
        begin
            if nome[i] = '&' then
                saida := saida + '&-'
            else
            if nome[i] in [#$20..#$7e] then
                saida := saida + nome[i]
            else
                begin
                    aconv := '';
                    while (i <= length(nome)) and
                          (not (nome[i] in [#$20..#$7e])) do
                        begin
                            aconv := aconv + nome[i];
                            i := i + 1;
                        end;
                    saida := saida + convInternat(aconv);
                    i := i - 1;
                end;

            i := i + 1;
        end;

    result := saida;
end;

{--------------------------------------------------------}
{  Obtem a lista de pastas                               }
{--------------------------------------------------------}

procedure obtemPastas;
var i, ind: integer;
    nome: string;
begin
    pastasImap.Clear;
    if execComando('LIST "" *') then
        begin
            for i := 0 to respserv.Count-2 do
                begin
                    if pos ('\Noselect', respserv[i]) <> 0 then
                        continue;
                    nome := respserv[i];
                    if nome[length(nome)] = '"' then
                        begin
                            delete (nome, length(nome), 1);
                            ind := lastDelimiter ('"', nome);
                            delete (nome, 1, ind);
                        end
                    else
                        begin
                            ind := lastDelimiter ('"', nome);
                            delete (nome, 1, ind);
                            nome := trim(nome);
                        end;
                    nome := decodInternat (nome);
                    pastasImap.add (nome);
                end;
        end;

    if pastasImap.Count = 0 then
         pastasImap.Add('INBOX');   // evitando problemas
end;

{--------------------------------------------------------}
{ seleciona um mailbox                                   }
{--------------------------------------------------------}

function select (mailbox: string; mostraQuantas: boolean): boolean;
var i: integer;
    s: string;
begin
    result := false;
    cartasNaPasta := 0;
    if execComando ('select ' + '"' + codifInternat(mailbox) + '"') then
        begin
           result := true;
           for i := 0 to respServ.count-1 do
               begin
                   s := upperCase (respServ[i]);
                   if pos ('EXISTS', s) <> 0 then
                       begin
                           cartasNaPasta := peganum(s);
                           break;
                       end;
               end;
            if mostraQuantas then
                begin
                    if sintFalarTudo then
                        begin
                            mensagem ('IUNUMCAR', 0);  {'Número de cartas na pasta '}
                            sintWriteln (mailbox + ': ' + intToStr(cartasNaPasta));
                        end
                    else
                        begin
                            write (pegaTextoMensagem('IUNUMCAR') + mailbox + ': ');  {'Número de cartas na pasta '}
                            sintWriteln (intToStr(cartasNaPasta));
                        end;

                    while sintFalando do waitMessage;
                end;
        end;
end;

{--------------------------------------------------------}
{ escolhe pasta imap interativamente                     }
{--------------------------------------------------------}

procedure escolherPasta;
var i: integer;
    nitem: integer;
    nome: string;
begin
    clrscr;
    writeln (pegaTextoMensagem ('IUESCOLP'));  {'ImapUtil - escolhendo pastas'}
    writeln;

    obtemPastas;

    mensagem ('IUESETAP', 1);  {'Escolha com as setas a pasta desejada'}
    popupMenuCria (wherex, wherey, 80, 20, RED);
    for i := 0 to pastasImap.count-1 do
        begin
            nome := pastasImap[i];
            if copy (nome, 1, 8) = '[Gmail]/' then
                nome := '~' + copy (nome, 9, 999);
            popupMenuAdiciona('', nome);
        end;
    popupMenuOrdena;
    nitem := popupMenuSeleciona;

    if (nitem > 0) and (nitem <= pastasImap.Count) then
        begin
            pastaAtual := opcoesItemSelecionado;
            if pastaAtual[1] = '~' then
                pastaAtual := '[Gmail]/' + copy (pastaAtual, 2, 999);
        end
    else
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;

    if not select (pastaAtual, true) then
        begin
            mensagem ('IUNSEL', 1);  {'Não foi possível selecionar, voltando a INBOX'}
            pastaAtual := 'INBOX';
            select (pastaAtual, true);
        end;
end;

{--------------------------------------------------------}
{ cria uma pasta imap                                    }
{--------------------------------------------------------}

procedure criarPasta;
var
    novapasta: string;
    c: char;
begin
    mensagem ('IUPASCRI', 1);  {'Qual o nome da pasta a criar?'}
    sintreadln(novapasta);
    mensagem ('IUQERSEL', 0);  {'Quer selecioná-la após a criação? '}
    c := readkey;
    if c = esc then exit;
        writeln(c);

    if not execcomando('CREATE ' + '"' + codifInternat(novapasta) + '"') then
        mensagem ('IUNAOCRI', 1)  {'Não consegui criar.'}
    else
        if upcase(c) <> 'S' then
            mensagem ('IUOK', 1)  {'OK!'}
        else
            if select(novapasta, true) then
                mensagem ('IUOK', 1);  {'OK!'}
end;

{--------------------------------------------------------}
{ apaga uma pasta imap                                   }
{--------------------------------------------------------}

procedure apagarPasta;
var i: integer;
    nitem: integer;
    c1, c2: char;
begin
    clrscr;
    writeln (pegaTextoMensagem ('IUAPPAST'));  {'ImapUtil - apagando pasta'}
    writeln;

    obtemPastas;

    mensagem ('IUESCPAP', 1);  {'Escolha com as setas a pasta a apagar'}
    folheiaCria (wherex, wherey, 80, 24);
    nitem := 1;
    for i := 0 to pastasImap.count-1 do
        folheiaAdiciona(pastasImap[i]);
    folheiaExecuta(nitem, nitem, c1, c2, true);
    folheiaDestroi;

    if (c1 = ENTER) and (nitem > 0) and (nitem <= pastasImap.Count) then
        begin
            if not execComando('DELETE ' + '"' + codifInternat(pastasImap[nitem-1]) + '"') then
                mensagem ('IUPASNAP', 1)  {'Pasta não foi apagada.'}
            else
                mensagem ('IUPASAP', 1);  {'OK, pasta apagada.'}
        end
    else
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;
end;

{--------------------------------------------------------}
{ troca o nome de uma pasta imap                         }
{--------------------------------------------------------}

procedure renomearPasta;
var i: integer;
    nitem: integer;
    c1, c2: char;
    nomeantigo: string;
    novonome: string;
begin
    clrscr;
    writeln (pegaTextoMensagem ('IURENOP'));  {'ImapUtil - renomeando pasta'}
    writeln;

    obtemPastas;

    mensagem ('IUESCRNO', 1);  {'Escolha com as setas a pasta a renomear'}
    folheiaCria (wherex, wherey, 80, 24);
    nitem := 1;
    for i := 0 to pastasImap.count-1 do
        folheiaAdiciona(pastasImap[i]);
    folheiaExecuta(nitem, nitem, c1, c2, true);
    folheiaDestroi;

    if (c1 = ENTER) and (nitem > 0) and (nitem <= pastasImap.Count) then
        begin
            mensagem ('IUNOVNOM', 1);  {'Editore o novo nome:'}
            nomeantigo := pastasImap[nitem-1];
            novonome := nomeantigo;
            c1 := sintedita(novonome,wherex,wherey,80,true);
            if c1 = esc then
                begin
                    mensagem ('IUDESIST', 1);  {'Desistiu'}
                    exit;
                end;

            if not execComando('RENAME ' +
                 '"' + codifInternat(nomeantigo) + '" "' +
                       codifinternat(novonome) +'"') then
                mensagem ('IUNAORNO', 0)  {'Não consegui renomear a pasta.'}
            else
                mensagem ('IUOKRNO', 1);  {'OK, pasta renomeada.'}
        end
    else
        begin
            mensagem ('IUDESIST', 1);  {'Desistiu'}
            exit;
        end;

end;

end.
