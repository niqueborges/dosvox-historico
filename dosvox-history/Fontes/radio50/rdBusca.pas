{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Busca uma rádio pelo nome                           }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdBusca;

interface
uses
    dvcrt,
    dvwin,
    Windows,
    dvForm,
    dvAmplia,
    dvHora,
    sysUtils,
    classes,
    rdAjuda,
    rdmsg,
    rdvars,
    rdUtil,
    rdbass,
    rdFFPlay;

procedure buscaRadioPeloNome (continuarFolheando: boolean);

implementation

var slBusca: TStringList;

{--------------------------------------------------------}
{         Toca a rádio buscada.
{--------------------------------------------------------}

procedure tocarRadio (n: integer; s: string);
var
    nomeRadio, url: string;
    ok: boolean;
begin
    nomeRadio := pegaNomeRadio(s);
    url := pegaSite(s);
    clrscr;
    textBackground (BLUE);
    write (nomeRadio);
    textBackground (BLACK);
    writeln;

    ultimaTocada := url;
    if not comTocadorExterno (url) then
        ok := tocaRadioBass (nomeRadio, url) >= 0
    else
        ok := tocaRadioExterna (nomeRadio, tirarTocadorExterno(url)) >= 0;

    if (not ok) and veSeApaga (nomeRadio) then
        begin
            sintRemoveAmbienteArq (pegaCategoria(s), nomeRadio, arqIndice);
            slBusca.Delete(n-1);
            mensagem ('RDOKRM', 2);        {'Ok, removido'}
            folheiaRemoveItem (n);
        end;
end;

{--------------------------------------------------------}
{         busca uma rádio por parte do nome
{--------------------------------------------------------}

procedure buscaRadioPeloNome (continuarFolheando: boolean);
var
    nomeBusca: string;
    s: string;
    slOrig: TStringList;
    i: longInt;
    n, p: integer;
    categoria, nomeRadio, site: string;
    c1, c2: char;
    falarItem, apertouShift: boolean;
begin
    mensagem ('RDNOMBUS', 1);  {'Informe parte do nome a buscar: '}
    sintReadln (nomeBusca);
    if nomeBusca = '' then
        begin
            mensagem ('RDDESIST', 1);  {'Desistiu'}
            exit;
        end;

    nomeBusca := lowerCase(semAcentos(nomeBusca));

    slOrig := TStringList.Create;
    slOrig.LoadFromFile(arqIndice);
    slBusca := TStringList.Create;

    categoria := '';
    for i := 0 to slOrig.Count-1 do
        begin
            if slOrig[i] = '' then continue;
            if slOrig[i][1] = ';' then continue;
            s := slOrig[i];
            if s[1] = '[' then
                categoria := copy (s, 2, length(s)-2)
            else
                begin
                    p := pos ('=', s);   // evita erros
                    if p = 0 then continue;
                    nomeRadio := copy (s, 1, p-1);
                    if pos (nomeBusca, lowerCase(semAcentos(nomeRadio))) <> 0 then
                        slBusca.add ('['+categoria+']'+s);
                end;
        end;

    slOrig.Free;

    if slBusca.Count = 0 then
        begin
            mensagem ('RDNADAPA', 2);   {'Não encontrei nada parecido'}
            slBusca.Free;
            exit;
        end;

    folheiaCria(1, wherey, 79, 24-amplFator);
    for i := 0 to slBusca.count-1 do
        folheiaAdiciona (pegaNomeRadio (slBusca[i]));

    n := 1;
    falarItem := true;
    repeat
        clrscr;
        textBackground (BLUE);
    write ('Folheando as rádios da busca.');
        textBackground (BLACK);
        writeln;

        folheiaExecuta(n, n, c1, c2, falarItem);
        apertouShift := GetKeyState(VK_SHIFT) < 0;
        if n < 1 then n := 1
        else if n > folheiaNumItens then n := folheiaNumItens;

        if (c1 = #0) and (c2 = F9) then
            c1 := selSetasFolheiaRadios (c2, apertouShift);

        if c1 = #0 then
            case c2 of
                F1: ajudaFolheiaRadios;
                DIR, CTLDIR:
                    begin
                        if comTocadorExterno (pegaSite (slBusca[n-1])) then sintBip;
                        if c2 = DIR then sintetiza (pegaSite(slBusca[n-1]))
                        else sintSoletra  (pegaSite(slBusca[n-1]));
                    end;
                ESQ: sintetiza (pegaCategoria(slBusca[n-1]));
                CTLESQ: sintsoletra (pegaCategoria(slBusca[n-1]));
                F5: n := folheiaBuscaItem (n);
                CTLF5: n := folheiaBuscaItemNovamente (n);
                F8: falaHora;
                CTLF8: falaDia;
            end
        else
            case c1 of
                ^Q: falaQualItemDeQuantos (n, apertouShift);
                ^C: copiaAreaTransfSelec (n, '', arqIndice, apertouShift, slBusca);
                '3': geraArqivosM3U (n, '', arqIndice, slBusca);
                ^S: selecionarTodosItensFolheamento;
                ^E:
                    begin
                        nomeRadio := pegaNomeRadio (slBusca[n-1]);
                        site := pegaSite (slBusca[n-1]);
                        if editarRadioFolheamento (n, pegaCategoria(slBusca[n-1]),  nomeRadio, site) then
                            slBusca[n-1] := '[' + pegaCategoria(slBusca[n-1]) + ']' + nomeRadio + '=' + site;
                    end;
                ^P: adicionarAosPreferidos(pegaNomeRadio (slBusca[n-1]), pegaSite (slBusca[n-1]));
                ^R: n := removerRadio (n, '', slBusca);
//Neno falta implementação em rdUtil.pas                ^V: verificarSeRadioToca (n, '', slBusca);
                ^T: n := procurarSeUsaTocadorExterno (n,  '', slBusca);
                ENTER: tocarRadio (n, slBusca[n-1]);
                ESC: ;
            else
                n := folheiaPosicionaInicial (c1, n);
            end;

        if folheiaNumItens = 0 then c1 := ESC;
        if n > slBusca.count then sintbip;
        if (c1 in [^Q, ^C]) or ((c1 = #0) and (c2 in [DIR, CTLDIR, ESQ, CTLESQ, F8, CTLF8])) then falarItem := false
        else falarItem := true;

    until (c1 = ESC) or ((c1 = ENTER) and (not continuarFolheando));

    folheiaDestroi;
    slBusca.Free;
end;

{--------------------------------------------------------}

begin
end.
