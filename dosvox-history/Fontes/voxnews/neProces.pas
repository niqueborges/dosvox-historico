{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Processamento de opções                             }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit neproces;
interface
uses
    windows,
    classes,
    dvcrt,
    dvwin,
    dvForm,
    dvSapi,
    dvSapGlb,
    sysUtils,
    nenavega,
    nemsg,
    nevars;

procedure processa;

implementation

{--------------------------------------------------------}
{             ajuda
{--------------------------------------------------------}

procedure ajudaOpcao;
begin
    writeln;
    mensagem ('NEOPCAO',  1);  {'As opções são:'}
    mensagem ('NEAJCN01', 1);  {'N - navegar'}
    mensagem ('NEAJCN02', 1);  {'E - editar uma categoria'}
    mensagem ('NEAJCN03', 1);  {'I - incluir item em uma categoria'}
    mensagem ('NEAJCN04', 1);  {'R - remover item de uma categoria'}
    mensagem ('NEAJCN05', 1);  {'C - criar nova categoria'}
    mensagem ('NEAJCN06', 1);  {'A - atualizar a base de notícias via arquivo'}
    mensagem ('NEAJCN07', 1);  {'D - destruir uma categoria'}
    mensagem ('NEAJCN08', 1);  {'T - testar um feed ou podcast'}
    mensagem ('NEAJCN99', 1);  {'ESC - terminar'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcao: string [9] = 'NEIRCADT' + ESC;

begin
    garanteEspacoTela (8);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    MenuAdiciona ('NEAJCN01');  {'N - navegar'}
    MenuAdiciona ('NEAJCN02');  {'E - editar uma categoria'}
    MenuAdiciona ('NEAJCN03');  {'I - incluir item em uma categoria'}
    MenuAdiciona ('NEAJCN04');  {'R - remover item de uma categoria'}
    MenuAdiciona ('NEAJCN05');  {'C - criar nova categoria'}
    MenuAdiciona ('NEAJCN06');  {'A - atualizar a base de notícias via arquivo'}
    MenuAdiciona ('NEAJCN07');  {'D - destruir uma categoria'}
    MenuAdiciona ('NEAJCN08');  {'T - testar um feed ou podcast'}
    MenuAdiciona ('NEAJCN99');  {'ESC - terminar'}
    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        selSetasOpcao := ESC;
end;

{--------------------------------------------------------}
{                escolhe uma categoria
{--------------------------------------------------------}

function escolheCategoria (configurar: boolean): string;
var
    sl: TStringList;
    s: string;
    n, i: integer;
begin
    if configurar then
        mensagem ('NESELSEC', 1)  {'Selecione com as setas a categoria a configurar'}
    else
        mensagem ('NESELNAV', 1);  {'Selecione com as setas a categoria a navegar'}

    sl := TStringList.Create;
    sl.LoadFromFile (arqIndice);
    popupMenuCria (1, wherey, 50, 26-wherey, MAGENTA);

    for i := 0 to sl.Count-1 do
        begin
            s := trim(sl[i]);
            if (s <> '') and (s[1] = '[') and (s[length(s)] = ']') then
                begin
                    delete (s, 1, 1);
                    delete (s, length(s), 1);
                    popupMenuAdiciona ('', s);
                end;
        end;

    sl.free;

    popupMenuOrdena;
    n := popupMenuSeleciona;
    if n <= 0 then
        begin
            escolheCategoria := '';
            exit;
        end;

    s := opcoesItemSelecionado;
    gotoxy (1, wherey-1);
    write (s, ' - ');
    clreol;

    escolheCategoria := s;
end;

{--------------------------------------------------------}
{                edita uma categoria
{--------------------------------------------------------}

procedure editaCategoria (nomeCategoria: string);
var
    sl: TStringList;
    s: string;
    i, n, p, tam, primCateg: integer;
    nitens: integer;
    salva: integer;
    itens, valores: array of string[128];

begin
    mensagem ('NEEDICNF', 1);  {'Editore as configurações, ao final tecle ESC'}

    salva := tamRotulosForm;
    tamRotulosForm := 3;

    sl := TStringList.Create;
    sl.LoadFromFile(arqIndice);

    primCateg := 99999;
    for i := 0 to sl.Count-1 do
        begin
            if trim(sl[i]) = '[' + nomeCategoria + ']' then
                begin
                    primCateg := i+1;
                    for n := primCateg to sl.Count-1 do
                        begin
                            s := trim(sl[n]);
                            if s = '' then continue;
                            if s[1] = '[' then break;

                            p := pos ('=', s);
                            tam := length(trim(copy(s, 1, p-1)));
                            if tamRotulosForm < tam then
                                tamRotulosForm := tam;
                        end;

                    setLength(itens, n-primCateg+2);
                    setLength(valores, n-primCateg+2);
                    break;
               end;
        end;

    tamRotulosForm := tamRotulosForm + 1;

    formCria;
    nitens := 0;
    for n := primCateg to sl.Count-1 do
        begin
            s := trim(sl[n]);
            if s = '' then continue;
            if s[1] = '[' then break;

            p := pos ('=', s);
            itens[nitens] := trim(copy(s, 1, p-1));
            valores[nitens] := trim(copy(s, p+1, 999));
            formCampo ('', itens[nitens], valores[nitens], 255);
            nitens := nitens + 1;
        end;

    sl.free;

    formEdita (true);
    limpaBaixo (3);

    for i := 0 to nitens-1 do
        sintGravaAmbienteArq (nomeCategoria, itens[i], valores[i], arqIndice);

    tamRotulosForm := salva;
end;

{--------------------------------------------------------}
{                inclui um item
{--------------------------------------------------------}

procedure incluiItem (nomeCategoria: string);
var item, conteudo: string;

begin
    repeat
        mensagem ('NEITEMIN', 1);   {'Nome do item a incluir'}
        sintReadln (item);
        if item = '' then exit;

        mensagem ('NEITEMCT', 1);   {'Informe o conteúdo deste item'}
        sintReadln (conteudo);

        sintGravaAmbienteArq (nomeCategoria, item, conteudo, arqIndice);
        mensagem ('NEOK', 2);        {'Ok'}
    until false;
end;

{--------------------------------------------------------}
{                cria uma nova categoria
{--------------------------------------------------------}

procedure removeItem (nomeCategoria: string);
var
    sl: TStringList;
    s: string;
    i, n, p, y: integer;

begin
    y := wherey;
    repeat
        limpaBaixo(y);
        mensagem ('NEITEMRM', 1);      {'Escolha com as setas o item a remover'}

        sl := TStringList.Create;
        sl.LoadFromFile(arqIndice);
        popupMenuCria (1, wherey, 80, 26-wherey, MAGENTA);

        for i := 0 to sl.Count-1 do
            begin
                if trim(sl[i]) = '[' + nomeCategoria + ']' then
                    begin
                        for n := i+1 to sl.Count-1 do
                            begin
                                s := trim(sl[n]);
                                if s = '' then continue;
                                if s[1] = '[' then break;

                                p := pos ('=', s);
                                popupMenuAdiciona('', trim(copy(s, 1, p-1)));
                            end;
                        break;
                    end;
            end;

        sl.free;

        n := popupMenuSeleciona;
        if n <= 0 then exit;

        mensagem ('NECNFRMI', 0);    {'Confirma remoção do item '}
        sintWrite (opcoesItemSelecionado);
        write ('? ');
        if popupMenuPorLetra('SN') = 'S' then
            begin
                sintRemoveAmbienteArq (nomeCategoria, opcoesItemSelecionado, arqIndice);
                mensagem ('NEOKRM', 2);        {'Ok, removido'}
            end
        else
            mensagem ('NEDESIST', 1);  {'Desistiu'}

    until false;
end;

{--------------------------------------------------------}
{                cria uma nova categoria
{--------------------------------------------------------}

procedure criaNovaCategoria;
const lixo = 'xyxyxyxyxyxyxyxyxy';
var novaCategoria: string;
begin
    mensagem ('NENOVSEC', 1);      {'Informe o nome da nova categoria:'}
    sintReadln (novaCategoria);
    if novaCategoria = '' then exit;

    sintGravaAmbienteArq (novaCategoria, lixo, lixo, arqIndice);
    sintRemoveAmbienteArq (novaCategoria, lixo, arqIndice);

    mensagem ('NEOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{                destrói uma categoria
{--------------------------------------------------------}

procedure destroiUmaCategoria;
var categDestruir: string;
    i, n: integer;
    s: string;
    sl: TStringList;
begin
    mensagem ('NEDSTCAT', 1);      {'Escolha com as setas a categoria a destruir:'}

    sl := TStringList.Create;
    sl.LoadFromFile(arqIndice);

    popupMenuCria(1, wherey, 79, 26-wherey, RED);
    for i := 0 to sl.Count-1 do
        begin
            s := trim(sl[i]);
            if (s <> '') and (s[1] = '[') then
                begin
                    delete (s, 1, 1);
                    delete (s, length(s), 1);
                    popupMenuAdiciona ('', s);
                end;
        end;

    sl.free;

    n := popupMenuSeleciona;
    if n <= 0 then
        begin
            mensagem ('NEDESIST', 1);  {'Desistiu'}
            exit;
        end;

    categDestruir := opcoesItemSelecionado;

    mensagem ('NEPERIGO', 1);      {'Destruirei a categoria com este nome, com todas as referências.'}
    mensagem ('NEAPTD', 0);        {'Aperte D para destruir sem chance de voltar. '}
    if popupMenuPorLetra ('DN') <> 'D' then
        begin
            mensagem ('NEDESIST', 2);  {'Desistiu'}
            exit;
        end;

    sintRemoveAmbienteArq (categDestruir, '', arqIndice);

    mensagem ('NEOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{      atualiza INI a partir de um arquivo
{--------------------------------------------------------}

procedure atualizarIni;
var
    c, c2: char;
    realtera: boolean;
    categoria, item, valor, s: string;
    arq: text;
    nomeArq: string;
    p: integer;

    function existeChave (categoria, item: string): boolean;
    begin
        existeChave := sintAmbiente (categoria, item) <> '';
    end;

begin
     mensagem ('NEARQMUD', 1);  {'Informe o nome do arquivo que contém as mudanças'}
     sintReadln (nomeArq);
     if nomeArq = '' then exit;

     assign (arq, nomeArq);
     {$I-} reset (arq);  {$I+}
     if ioresult <> 0 then
         begin
             mensagem ('NEARQNEX', 2);  {'Arquivo não existe'}
             exit;
         end;

     mensagem ('NEMODIFA', 0);  {'Deseja modificar itens anteriormente criados?'}
     sintLeTecla (c, c2);
     writeln;
     if c = ESC then exit;
     realtera := upcase (c) = 'S';

     categoria := '';
     while not eof (arq) do
         begin
             readln (arq, s);
             s := trim(s);
             if (s <> '') and (s[1] <> ';') and (s[1] <> '*') then
                 begin
                     if s[1] = '[' then
                          begin
                              delete (s, 1, 1);
                              delete (s, length(s), 1);
                              categoria := s;
                          end
                     else
                          begin
                              p := pos ('=', s);
                              if p > 1 then
                                  begin
                                      item := copy (s, 1, p-1);
                                      valor := copy (s, p+1, length(s));
                                      if realtera or (not existeChave (categoria, item)) then
                                          sintGravaAmbienteArq (categoria, item, valor, arqIndice);
                                  end
                              else
                                  begin
                                      mensagem ('NECHINVA', 1); {'Chave inválida'}
                                      sintWriteln (s);
                                  end;
                          end;
                 end;
         end;

     close (arq);
     mensagem ('NEOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}

procedure processa;
var c, c2: char;
    nomeCategoria: string;
    opcao: string;
label fim;

begin
    while true do
        begin
            clrscr;
            textBackground (BLUE);
            writeln (pegaTextoMensagem ('NEINIC'), versao);   {'VoxNews - versão '}
            textBackground (BLACK);
            writeln;

            textBackground (RED);
            mensagem ('NEOQUE', 0);      {'Qual sua opção? '}
            textBackground (BLACK);
            sintLeTecla (c, c2);
            opcao := '';

            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                  begin
                      c := selSetasOpcao;
                      if c <> #$1b then
                          opcao := copy (
                             opcoesItemSelecionado, pos ('-', opcoesItemSelecionado)-1, 999);
                  end;

            if c = #$1b then
                begin
                    writeln;
                    goto fim;
                end;

            if (c = #0) and (c2 = F1) then
                 ajudaOpcao
            else
                 begin
                     clrscr;
                     textBackground (BLUE);
                     writeln ('VoxNews' + opcao);
                     textBackground (BLACK);
                     writeln;

                     if upcase (c) in ['N', 'E', 'I', 'R'] then
                         begin
                             nomeCategoria := escolheCategoria (upcase(c) <> 'N');
                             if nomeCategoria = '' then continue;
                         end;

                     case upcase(c) of
                         'N': navegaNosSitesRss (nomeCategoria);
                         'E': editaCategoria (nomeCategoria);
                         'I': incluiItem (nomeCategoria);
                         'R': removeItem (nomeCategoria);
                         'C': criaNovaCategoria;
                         'D': destroiUmaCategoria;
                         'T': testaRSS;
                         'A': atualizarIni;
                     else
                         mensagem ('NEOPINV', 1); {'Opção inválida'}
                     end;
                 end;
        end;
fim:
    writeln;
end;

end.

