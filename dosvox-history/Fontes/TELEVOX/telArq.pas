{--------------------------------------------------------}
{      Televox - rotinas de manipulação de arquivos
{--------------------------------------------------------}

unit telArq;

interface
uses windows, shellApi, sysutils, dvlenum,
     dvcrt, dvWin, dvarq, DVForm, winsock,
     telVars, telMsg, telTela, telItem, telUtil;

procedure exportaTelevox;
procedure arquiva;

implementation

{--------------------------------------------------------}
{        avisa sobre necessidade de compatibilidade
{--------------------------------------------------------}

function avisaCompatibilidade: boolean;
var c, c2: char;
begin
     result := true;
     mensagem ('TVMESCAM',1); {'Para realizar esta operação os campos das agendas devem ser identicos.'}
     mensagem ('TVINCMPT',1); {'Se forem diferentes haverá incompatibilidade de informações.'}
     mensagem ('TVDESCON',0); {'Deseja continuar? '}
     sintLeTecla (c, c2);
     c := upcase (c);
     if c <>  'S' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            result := false;
        end;
end;

{--------------------------------------------------------}
{                exportação tipo Televox
{--------------------------------------------------------}

procedure exportaTelevox;
var
    nomeExport, campo, dirAtual: string;
    arqExport: text;
    tipoExport, c, c2: char;
    nc, i, n, resulta: integer;

label erro, achou, deNovo;

begin
    limpaTela;
    gotoxy (1, 10);
    mensagem ('TVTODSEL', 0); {'Tecle T para todos ou S para os selecionados: '}

    sintLeTecla (c, c2);
    c := upcase (c);
    if (c = ESC) then exit;

    if not (c in['T','S']) then
        begin
            msgBaixo ('TVOPINV', ''); {'Operação inválida'}
            exit;
        end;

    tipoExport := c;
    getdir (0, dirAtual);
    if dirAtual[length(dirAtual)] = '\' then
        delete (dirAtual, length(dirAtual), 1);

    if dirAgendas <> '' then
        begin
            {$I-} chdir (dirAgendas);  {$I+}
            resulta := ioresult;
        end
    else
        resulta := 1;

    gotoxy (1, 13);
    mensagem ('TVNOMARQ', 0); {'Qual o nome do arquivo: '}
    clreol;
    garanteEspacoTela (10);
    nomeExport := obtemNomeArq (10);
    if (pos ('\', nomeExport) = 0) and (pos ('/', nomeExport) = 0) then
        if resulta = 0 then
            nomeExport := dirAgendas + '\' + nomeExport
        else
            nomeExport := dirAtual+ '\' + nomeExport;

    {$I-} chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;

    if nomeExport = '' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu...'}
            exit;
        end;

    assign (arqExport, nomeExport);
    {$I-} reset (arqExport); {$I+}
    if ioresult <> 0 then
        begin
            {$I-}  rewrite (arqExport); {$I+}
            if ioresult <> 0 then goto erro;
        end
    else
        begin
deNovo:
            msgBaixo ('TVADICRI', ''); {'Arquivo já existia, aperte A para adicionar, ENTER para recriar'}
            c := readkey;
            if c = #$1b then
                begin
                    msgBaixo ('TVDESIS', ''); {'Desistiu...'}
                    exit;
                end;

            case upcase(c) of
                #$0d:  begin
                           {$I-} rewrite (arqExport);  {$I+}
                           if ioresult <> 0 then goto erro;
                           {$I-} writeln (arqExport, '@'); {$I+}
                           if ioresult <> 0 then goto erro;
                           for nc := 1 to numCampos do
                               writeln (arqExport, tabTexto[nc],'|',
                                        tabFala[nc], '|', tabmaladir[nc]);
                           {$I-} writeln (arqExport, '@'); {$I+}
                       end;

                'A':   begin
                           mensagem ('TVMESCAM',1); {'Para realizar esta operação os campos das agendas devem ser idênticos.'}
                           mensagem ('TVINCMPT',1); {'Se forem diferentes haverá incompatibilidade de informações.'}
                           mensagem ('TVDESCON',0); {'Deseja continuar? '}
                           sintLeTecla (c, c2);
                           c := upcase (c);
                           if c <>  'S' then
                              begin
                                  msgBaixo ('TVDESIS', ''); {'Desistiu'}
                                  exit;
                              end;
                           {$I-} append (arqExport);  {$I+}
                       end;
            else
                goto denovo;
            end;
        end;

    If ioresult <> 0  Then
        goto erro;

    msgBaixo ('TVGRAVAN', ''); {'Gravando'}

    for i := 1 to cadastrados do
        begin
            if (tipoExport = 'T') or
               ((tipoExport = 'S') and (
                         (listaFone [i]^.status and SELECIONADO) <> 0)) then
                   begin
                       for nc := numCampos downto 2 do
                            if obtemItem (nc, i) <> '' then
                                goto achou;
                       nc := 1;
          achou:
                       for n := 1 to nc do
                           begin
                               campo := obtemItem (n, i);
                               writeln (arqExport, campo);
                               if ioresult <> 0 then goto erro;
                           end;

                       {$I-} writeln (arqExport, '@'); {$I+}
                       if ioresult <> 0 then goto erro;
                   end;
        end;

    {$I-} close (arqExport); {$I+}
    if ioresult <> 0 then goto erro;

    msgBaixo ('TVSALVA', ''); {'Arquivo gravado'}
    exit;

{--------------------------------------------------------}

erro:
    {$I-} close (arqExport); {$I+}
    if ioresult <> 0 then;

    limpaTela;
    msgBaixo ('TVNGRAV', ''); {'Deu problema na gravação'}
end;

{--------------------------------------------------------}
{                 importação de Televox
{--------------------------------------------------------}

procedure importaTelevox;
var
    salva: string;
begin
     if not avisaCompatibilidade then exit;
     salva := nomeCadastro;
     leCadastro (false, false);
     nomeCadastro := salva;
end;

{--------------------------------------------------------}
{                 exportação em formato CSV
{--------------------------------------------------------}

procedure exportaCSV;
var nomeCSV, ext: string;
    arqCSV: textFile;
    sep, c2: char;
    nc, i: integer;
    s: string;
begin
    mensagem ('TVCSVEXP', 1);  {'Digite o nome do arquivo .CSV a exportar'}
    nomeCSV := obtemNomeArq (10);
    if nomeCSV = '' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu...'}
            exit;
        end;

    ext := ansiUpperCase(copy (nomeCSV, length(nomeCSV)-3, 4));
    if ext <> '.CSV' then
        nomeCSV := nomeCSV + '.CSV';

    assignFile (arqCSV, nomeCSV);
    {$I-} rewrite (arqCSV); {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('TVERRDIS', '');  {'Erro no disco'}
            exit;
        end;

    mensagem ('TVESCSEP', 0);  {'Escolha caractere de separação de campos, Enter se ponto-e-vírgula: '}
    sintLeTecla (sep, c2);
    if (sep = #$0) or (sep = ESC) then
        begin
            msgBaixo ('TVDESIS', '');  {'Desistiu...'}
            exit;
        end;
    if sep = #$0d then sep := ';';

    msgBaixo ('TVGRAVAN', ''); {'Gravando'}

    for i := 1 to cadastrados do
        begin
            s := '';
            for nc := 1 to numCampos do
                s := s + sep + obtemItem (nc, i);
            delete (s, 1, 1);
            {$I-} writeln (arqCSV, s); {$I+}
            if ioresult <> 0 then
                begin
                    msgBaixo ('TVERRDIS', '');  {'Erro no disco'}
                    {$I-} closeFile (arqCSV); {$I+}
                    if ioresult <> 0 then;
                    exit;
                end;
        end;

    {$I-} closeFile (arqCSV); {$I+}
    if ioresult <> 0 then
        msgBaixo ('TVERRDIS', '');  {'Erro no disco'}
end;

{--------------------------------------------------------}
{                 importação de formato CSV
{--------------------------------------------------------}

procedure importaCSV;
var nomeCSV: string;
    arqCSV: textFile;
    sep, c, c2: char;
    lidos, nc, p: integer;
    campo, s: string;

begin
    mensagem ('TVMESCSV',1); {'Nesta operação os campos CSV devem corresponder aos do Televox.'}
    mensagem ('TVINCMPT',1); {'Se forem diferentes haverá incompatibilidade de informações.'}
    limpaBufTec;
    mensagem ('TVDESCON',0); {'Deseja continuar? '}
    sintLeTecla (c, c2);
    writeln;
    c := upcase (c);
    if c <>  'S' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu'}
            exit;
        end;

    writeln;
    mensagem ('TVCSVIMP', 1);  {'Digite o nome do arquivo .CSV a importar'}
    nomeCSV := obtemNomeArqMasc(10, '*.CSV');
    if nomeCSV = '' then
        begin
            msgBaixo ('TVDESIS', ''); {'Desistiu...'}
            exit;
        end;

    if not FileExists(nomeCSV) then
        begin
            msgBaixo ('TVARQNAO', ''); {'Arquivo não existe...'}
            exit;
        end;

    assignFile (arqCSV, nomeCSV);
    {$I-} reset (arqCSV); {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('TVERRDIS', '');  {'Erro no disco'}
            exit;
        end;

    mensagem ('TVESCSEP', 0);  {'Escolha caractere de separação de campos, Enter se ponto-e-vírgula: '}
    sintLeTecla (sep, c2);
    if (sep = #$0) or (sep = ESC) then
        begin
            msgBaixo ('TVDESIS', '');  {'Desistiu...'}
            exit;
        end;
    if sep = #$0d then sep := ';';

    lidos := 0;
    while not eof (arqCSV) do
        begin
            if ioresult <> 0 then
                begin
                    msgBaixo ('TVERRDIS', '');  {'Erro no disco'}
                    break;
                end;

            readln (arqCSV, s);
            s := trim(s);
            if s = '' then continue;

            inc (cadastrados);
            inc (lidos);
            novoRegistro (cadastrados);
            with listaFone [cadastrados]^ do
                begin
                    campo := '';
                    for nc := 1 to numCampos do
                        begin
                            p := pos (sep, s);
                            if p <> 0 then
                                begin
                                     campo := copy (s, 1, p-1);
                                     delete (s, 1, p);
                                end
                            else
                                campo := s;
                            atualizaItem(nc, cadastrados, campo);
                        end;
                end;
        end;

    closeFile (arqCSV);
    msgBaixo ('TVLIDOS', pegaTextoMensagem ('TVLIDOS') + intToStr(lidos));
    falaNumeroConv (numeroParaString (lidos), MASCULINO);
end;

{--------------------------------------------------------}
{                 zera base de dados
{--------------------------------------------------------}

procedure zeraBase;
var s: string;
begin
    mensagem ('TVRADICA', 1);  {'Tem certeza de quer mesmo fazer essa coisa tão radical?'}
    mensagem ('TVSEMVLT', 2);  {'Zerar base de dados não tem volta!'}
    mensagem ('TVCORAGE', 0);  {'Digite a seguinte palavra para confirmar: coragem  '}
    sintReadln (s);
    s := ansiUppercase(trim(s));
    if s <> 'CORAGEM' then
        begin
            msgBaixo ('TVDESIS', '');   {'Desistiu'}
            exit;
        end;

    cadastrados := 0;
    msgBaixo ('TVARQZER', '');   {'Arquivo zerado'}
end;


function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [7] = 'SNEIXCZ';

begin
    limpaBufTec;
    popupMenuCria (wherex, wherey, 50, 19, MAGENTA);
    MenuAdiciona ('TVOPARQ1');    {'S - salvar'}
    MenuAdiciona ('TVOPARQ2');    {'N - salvar com outro nome'}
    MenuAdiciona ('TVOPARQ3');    {'E - exportar Televox}
    MenuAdiciona ('TVOPARQ4');    {'I - importar Televox}
    MenuAdiciona ('TVOPARQ5');    {'X - exportar CSV}
    MenuAdiciona ('TVOPARQ6');    {'C - importar CSV}
    MenuAdiciona ('TVOPARQ7');    {'Z - Zerar base de dados'}

    n := popupMenuSeleciona;
    if n < 0 then
        selSetasOpcao := ESC
    else
        selSetasOpcao := tabLetrasOpcoes[n];
end;
 
{--------------------------------------------------------}
{           seleção de exportação e importação
{--------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('TVOPARQ1', 1);    {'S - salvar'}
    mensagem ('TVOPARQ2', 1);    {'N - salvar com outro nome'}
    mensagem ('TVOPARQ3', 1);    {'E - exportar Televox}
    mensagem ('TVOPARQ4', 1);    {'I - importar Televox}
    mensagem ('TVOPARQ5', 1);    {'X - exportar CSV}
    mensagem ('TVOPARQ6', 1);    {'C - importar CSV}
    mensagem ('TVOPARQ7', 1);    {'Z - Zerar base de dados'}
end;


procedure arquiva;
var c, c2: char;
    y: integer;
label deNovo;
begin
    limpaTela;
    gotoxy (1, 3);
    textBackGround (BLUE);
    mensagem ('TVARQUIV', 2); {'ARQUIVAMENTO:'}
    textBackground (BLACK);
    y := wherey;

deNovo:
    gotoxy (1, y);
    writeln;
    mensagem ('TVQUALF1', 0);   {'Qual a sua opção (F1 ajuda): '}
    sintLeTecla (c, c2);
    c := upcase (c);
    writeln;
    if (c2 = F1) then
        begin
            ajuda;
            goto deNovo;
        end
    else
    if (c2 = BAIX) or (c2 = CIMA) then
        c := selSetasOpcao;

    if (c = ESC) then
        begin
             msgbaixo ('TVDESIS', pegaTextoMensagem('TVDESIS'));
             exit;
        end
    else
        case c of
            'S': if gravaCadastro (false) then;
            'N': naoImplem;
            'E': exportaTelevox;
            'I': importaTelevox;
            'X': exportaCSV;
            'C': importaCSV;
            'Z': zeraBase;
        else
            msgBaixo ('TVARQINV', ''); {'Operação inválida - arquivamento cancelado'}
    end;
end;

end.

