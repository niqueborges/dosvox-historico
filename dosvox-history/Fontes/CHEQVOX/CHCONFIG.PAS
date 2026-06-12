{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Módulo de variáveis
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chConfig;

interface
uses dvcrt, dvwin, dvForm, windows, sysUtils,
     chvars, chmsg, chImprim;

procedure configura;
procedure configInicial;
procedure carregaBanco (nomeBanco: string);
procedure guardaBanco (nomeBanco: string);
procedure geraBancoPadrao (nomeBanco, nomeArq: string);

implementation

{--------------------------------------------------------}

procedure geraSaldoAnterior;
var arqLanc: text;
begin
    assign (arqLanc, nomeArqLanc);

    {$I-} reset (arqLanc);  {$I+}      {'não recria arquivo se ele já existia'}
    if ioresult = 0 then
        begin
            close (arqLanc);
            exit;
        end;

    {$I-} rewrite (arqLanc);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CHLANNAT', 1);  {'Erro no arquivo de lançamentos.'}
            exit;
        end;

    writeln (arqLanc, '          ');
    writeln (arqLanc, 'Saldo Anterior');
    writeln (arqLanc, '0,00');
    writeln (arqLanc, 'C');
    writeln (arqLanc, '');
    writeln (arqLanc, '');
    writeln (arqLanc, '');
    writeln (arqLanc, 'Saldo Anterior');
    writeln (arqLanc, '----------------------------------------');
    close (arqLanc);
end;

{--------------------------------------------------------}

procedure acertaNomeArq (var nomeNovo: string);
var nomeDir: string;
begin
    if pos ('\', nomeNovo) = 0 then
        begin
            getDir (0, nomeDir);
            if nomeDir [length (nomeDir)] <> '\' then
                nomeDir := nomeDir + '\';
            nomeNovo := nomeDir + nomeNovo;
        end;

    if pos ('.', nomeNovo) = 0 then
        nomeNovo := nomeNovo + '.CHQ';
end;

{--------------------------------------------------------}

procedure configInicial;
var
    conf: string;
begin
    moeda  := sintAmbiente ('CHEQVOX', 'MOEDA');    {no Brasil sempre muda...}
    moedas := sintAmbiente ('CHEQVOX', 'MOEDAS');
    if (moeda = '') or (moedas = '') then
        begin
            moeda := 'real';
            moedas := 'reais';
            sintGravaAmbiente ('CHEQVOX', 'MOEDA', 'real');
            sintGravaAmbiente ('CHEQVOX', 'MOEDAS', 'reais');
        end;

    bancoAtual := sintAmbiente ('CHEQVOX', 'BANCOATUAL');
    if bancoAtual= '' then
        begin
            bancoAtual := 'Banco do Brasil';
            sintGravaAmbiente ('CHEQVOX', 'BANCOATUAL', bancoAtual);
        end;

    if fileExists (ini_cheqvox) then
        conf := sintAmbienteArq (bancoAtual, 'ano4Digitos', '', ini_cheqvox);

    if  conf = '' then
        begin
            nomeArqLanc := 'brasil.chq';
            acertaNomeArq (nomeArqLanc);
            geraBancoPadrao (bancoAtual, nomeArqLanc);
            geraSaldoAnterior;
        end;

    carregaBanco (bancoAtual);

    setWindowText (crtWindow, pchar('Cheque Vox ' + bancoAtual));

    nomePessoa := sintAmbiente ('CHEQVOX', 'Nome');
    identidade := sintAmbiente ('CHEQVOX', 'Identidade');
    expedidor  := sintAmbiente ('CHEQVOX', 'Expedidor');
    cpf        := sintAmbiente ('CHEQVOX', 'CPF');
    endereco   := sintAmbiente ('CHEQVOX', 'Endereco');
    telefone   := sintAmbiente ('CHEQVOX', 'Telefone');
    bairro     := sintAmbiente ('CHEQVOX', 'Bairro');
    cidade     := sintAmbiente ('CHEQVOX', 'Cidade');

    if nomePessoa = '' then
        mensagem ('CHEXECAD', 2);     {'Atenção: informações incompletas, atualize seus dados pessoais'}

    mensagem ('CHBANATU', 0);    {'Banco atual: '}
    sintWriteln (bancoAtual);
end;

{--------------------------------------------------------}

procedure guardaBanco (nomeBanco: string);
const
    naoSim: array[boolean] of string = ('N', 'S');

    function CoordToString (xy: TCoord): string;
    var s1, s2: string;
    begin
            str (xy.x, s1);
            str (xy.y, s2);
            result := s1+','+s2;
    end;

begin
    if nomeBanco = '' then exit;

    sintGravaAmbienteArq (nomeBanco, 'Bancos', '', ini_cheqvox);

    sintGravaAmbienteArq (nomeBanco, 'arquivoLanc',    nomeArqLanc,         ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'ano4Digitos',    naoSim[ano4Digitos], ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'imprimeDeitado', naoSim[deitado],     ini_cheqvox);

    sintGravaAmbienteArq (nomeBanco, 'ajusteMM',      coordToString (ajusteMM),      ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posValor',      coordToString (posValor),      ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posExtenso1',   coordToString (posExtenso1),   ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posExtenso2',   coordToString (posExtenso2),   ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posFavorecido', coordToString (posFavorecido), ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posCidade',     coordToString (posCidade),     ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posDia',        coordToString (posDia),        ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posMes',        coordToString (posMes),        ini_cheqvox);
    sintGravaAmbienteArq (nomeBanco, 'posAno',        coordToString (posAno),        ini_cheqvox);
end;

{--------------------------------------------------------}

procedure carregaBanco (nomeBanco: string);
const
    pSim: pchar = 'S';
    pNao: pchar = 'N';

var s: string;

    procedure pcharToCoord (p: pchar; var coord: TCoord);
    var n: integer;
    begin
        while (p^ <> #$0) and (not (p^ in ['0'..'9'])) do
            p := p + 1;
        n := 0;
        while (p^ <> #$0) and (p^ in ['0'..'9']) do
            begin
                n := n * 10 + (ord (p^) - ord ('0'));
                p := p + 1;
            end;
        coord.x := n;

        while (p^ <> #$0) and (not (p^ in ['0'..'9'])) do
            p := p + 1;
        n := 0;
        while (p^ <> #$0) and (p^ in ['0'..'9']) do
            begin
                n := n * 10 + (ord (p^) - ord ('0'));
                p := p + 1;
            end;

        coord.y := n;
    end;

    function ambienteCoordArq (chave: string): TCoord;
    var s: string;
        coord: TCoord;
    begin
        s := sintAmbienteArq (nomeBanco, chave, '0,0', ini_cheqvox);
        pcharToCoord (pchar(s), coord);
        result := coord;
    end;

begin
    nomeArqLanc := sintAmbienteArq (nomeBanco, 'arquivoLanc',  '', ini_cheqvox);

    s := sintAmbienteArq (nomeBanco, 'ano4Digitos', 'S', ini_cheqvox);
    ano4Digitos := upperCase (copy (s, 1, 1))  <> 'N';

    s := sintAmbienteArq (nomeBanco, 'imprimeDeitado', 'N', ini_cheqvox);
    deitado := upperCase (copy (s, 1, 1))  <> 'N';

    ajusteMM      := ambienteCoordArq ('ajusteMM');
    posValor      := ambienteCoordArq ('posValor');
    posExtenso1   := ambienteCoordArq ('posExtenso1');
    posExtenso2   := ambienteCoordArq ('posExtenso2');
    posFavorecido := ambienteCoordArq ('posFavorecido');
    posCidade     := ambienteCoordArq ('posCidade');
    posDia        := ambienteCoordArq ('posDia');
    posMes        := ambienteCoordArq ('posMes');
    posAno        := ambienteCoordArq ('posAno');

    sintGravaAmbiente ('CHEQVOX', 'BANCOATUAL', nomeBanco);
    bancoAtual := nomeBanco;
end;

{--------------------------------------------------------}

procedure geraPosicoesPadrao;
begin
    { dados em milímetros }
    ajusteMM.x := 0;         ajusteMM.y := 0;
    posValor.x := 130;       posValor.y := 0;
    posExtenso1.x := 26;     posExtenso1.y := 6;
    posExtenso2.x := 8;      posExtenso2.y := 12;
    posFavorecido.x := 8;    posFavorecido.y := 18;
    posCidade.x := 70;       posCidade.y := 25;
    posDia.x := 108;         posDia.y := 25;
    posMes.x := 125;         posMes.y := 25;
    posAno.x := 157;         posAno.y := 25;
end;

{--------------------------------------------------------}

procedure geraBancoPadrao (nomeBanco, nomeArq: string);
begin
    geraPosicoesPadrao;
    ano4digitos := true;
    deitado := true;
    nomeArqLanc := nomeArq;

    guardaBanco (nomeBanco);
end;

{--------------------------------------------------------}

procedure dadosPessoais;
begin
    clrscr;
    writeln ('Cheque Vox');
    writeln;
    mensagem ('CHALTPES', 2);   {'Use as setas para alterar os dados pessoais, ESC termina'}
    formCria;
    formCampo ('CHNOME',   'Nome', nomePessoa, 50);
    formCampo ('CHIDENT',  'Identidade', identidade, 20);
    formCampo ('CHEXPEDI', 'Expedidor', expedidor, 20);
    formCampo ('CHCPF',    'CPF', cpf, 20);
    formCampo ('CHTELEFO', 'Telefone', telefone, 20);
    formCampo ('CHENDERE', 'Endereço', endereco, 50);
    formCampo ('CHBAIRRO', 'Bairro', bairro, 40);
    formCampo ('CHCIDADE', 'Cidade', cidade, 40);
    formEdita (true);

    sintGravaAmbiente ('CHEQVOX', 'Nome',       nomePessoa);
    sintGravaAmbiente ('CHEQVOX', 'Identidade', identidade);
    sintGravaAmbiente ('CHEQVOX', 'Expedidor',  expedidor);
    sintGravaAmbiente ('CHEQVOX', 'CPF',        cpf);
    sintGravaAmbiente ('CHEQVOX', 'Telefone',   telefone);
    sintGravaAmbiente ('CHEQVOX', 'Endereco',   endereco);
    sintGravaAmbiente ('CHEQVOX', 'Bairro',     bairro);
    sintGravaAmbiente ('CHEQVOX', 'Cidade',     cidade);

    writeln;
    mensagem ('CHOKCONF', 1);   {'Ok, configurado'}
end;

{--------------------------------------------------------}

function selecionaUmBanco: string;
var
    qual: integer;
    i, nbancos: integer;
    vet: array [0..4000] of char;
    vetBancos: array [1..1000] of pchar;
    p: pchar;

begin
    GetPrivateProfileString('Bancos', NIL, '', vet, 4000, pchar(ini_cheqvox));
    p := vet;
    nbancos := 0;
    while p^ <> #$0 do
        begin
            nbancos := nbancos + 1;
            vetBancos [nbancos] := p;
            p := p + strlen (p) + 1;
        end;

    if nbancos = 0 then
        begin
            selecionaUmbanco := '';
            mensagem ('CHSEMREG', 1);   {'Nenhum banco foi registrado'}
            exit;
        end;

    for i := 1 to nbancos do writeln;
    gotoxy (1, wherey-nbancos-1);
    mensagem ('CHSELBNK', 1);   {'Use as setas para selecionar o banco, ENTER termina'}

    opcoesCria (1, wherey, 60);
    for i := 1 to nbancos do
        opcoesAdiciona ('', strPas (vetBancos[i]));
    qual := opcoesSeleciona;

    if qual = 0 then
        begin
            mensagem ('CHDESIST', 1);          {'Desistiu...'}
            selecionaUmbanco := '';
        end
    else
        selecionaUmbanco := strPas (vetBancos[qual]);
end;

{--------------------------------------------------------}

procedure trocaBancoAtual;
var nomeEscolhido: string;
begin
    nomeEscolhido := selecionaUmBanco;
    if nomeEscolhido <> '' then
        begin
            bancoAtual := nomeEscolhido;
            carregaBanco (bancoAtual);

            mensagem ('CHBANATU', 0);    {'Banco atual: '}
            sintWriteln (bancoAtual);
            writeln;
            mensagem ('CHOKCONF', 1);   {'Ok, configurado'}
        end;
end;

{--------------------------------------------------------}

procedure removeBanco;
var nomeEscolhido: string;
    pbanco: array [0..100] of char;
begin
    nomeEscolhido := selecionaUmBanco;
    if nomeEscolhido = '' then exit;

    strPCopy (pbanco, nomeEscolhido);
    writePrivateProfileString('Bancos', pbanco, NIL, pchar(ini_cheqvox));

    if nomeEscolhido = bancoAtual then
        begin
            bancoAtual := '';
            mensagem ('CHCNFNOV', 1);  {'Atenção, configure o banco atual'}
        end;
end;

{--------------------------------------------------------}

procedure criaNovoBanco;
var nomeBanco: string;
begin
    mensagem ('CHNOVBNK', 1);     {'Informe o nome do novo banco'}
    sintReadln (nomeBanco);
    if nomeBanco = '' then
        begin
            mensagem ('CHDESIST', 1);   {'Desistiu'}
            exit;
        end;

    sintGravaAmbienteArq ('Bancos', nomeBanco, '', ini_cheqvox);

    if sintAmbienteArq (nomeBanco, 'posValor', '', ini_cheqvox) <> '' then
        mensagem ('CHPREVRG', 1)   {'Atenção, este banco havia sido anteriormente cadastrado'}
    else
        begin
            mensagem ('CHINFARQ', 1);  {'Informe o nome do arquivo de registro (sugiro usar extensão .chq):'}
            sintReadln (nomeArqLanc);
            acertaNomeArq (NomeArqLanc);

            geraBancoPadrao (nomeBanco, nomeArqLanc);
            geraSaldoAnterior;
        end;

    carregaBanco (nomeBanco);

    mensagem ('CHBANATU', 0);    {'Banco atual: '}
    sintWriteln (bancoAtual);
end;

{--------------------------------------------------------}

procedure ajustaPosicoes;

    procedure ajusta (var v: TCoord);
    var op: integer;
        n: integer;
    begin
        mensagem ('CHATUALM', 0);      {' atualmente '}
        sintWriteint (v.x);
        write (', ');
        sintWriteint (v.y);
        writeln;

        mensagem ('CHSELDSL', 1);      {'Escolha com as setas a direção a deslocar e aperte enter'}
        opcoesCria (wherex, wherey, 8);
        opcoesAdiciona ('CHESQ',   'Esquerda');
        opcoesAdiciona ('CHDIR',   'Direita');
        opcoesAdiciona ('CHCIMA',  'Cima');
        opcoesAdiciona ('CHBAIXO', 'Baixo');
        op := opcoesSeleciona;

        if op = 0 then exit;

        mensagem ('CHINFMIL', 0);       {'Quantos milímetros desloco ? '}
        sintReadint (n);
        writeln;

        case op of
            1: v.x := v.x - n;
            2: v.x := v.x + n;
            3: v.y := v.y - n;
            4: v.y := v.y + n;
        end;
        mensagem ('CHOK', 1);   {'OK.'}
    end;

var op: integer;
begin
    repeat
        clrscr;
        mensagem ('CHDESAJU', 1);  {'Selecione com as setas o campo desajustado e aperte enter'}
        mensagem ('CHTERESC', 2);  {'Termine com ESC'}

        opcoesCria (wherex, wherey, 23);
        opcoesAdiciona ('CHVALOR',  'Valor');
        opcoesAdiciona ('CHEXT1',   'Primeiro número extenso');
        opcoesAdiciona ('CHEXT2',   'Segundo número extenso');
        opcoesAdiciona ('CHFAVORE', 'Favorecido');
        opcoesAdiciona ('CHCIDADE', 'Cidade');
        opcoesAdiciona ('CHDIA',    'Dia');
        opcoesAdiciona ('CHMES',    'Mês');
        opcoesAdiciona ('CHANO',    'Ano');
        op := opcoesSeleciona;

        writeln;

        case op of
             0: mensagem ('CHPOSALT', 2);  {'Posições de impressão foram alteradas.'}
             1: ajusta (posValor);
             2: ajusta (posExtenso1);
             3: ajusta (posExtenso2);
             4: ajusta (posFavorecido);
             5: ajusta (posCidade);
             6: ajusta (posDia);
             7: ajusta (posMes);
             8: ajusta (posAno);
        end;
    until op = 0;
end;

{--------------------------------------------------------}

procedure configBanco;
var restaura: boolean;
    c, c2: char;
    nomeNovo: string;
label fimConf;
begin
    writeln;
    sintBip;
    restaura := false;

    mensagem ('CHARQATU', 1);  {'O nome do arquivo de lançamentos é'}
    sintWriteln (nomearqLanc);
    mensagem ('CHDESALT', 0);  {'Deseja trocar de arquivo? '}
    sintLetecla (c, c2);
    writeln;
    writeln;

    if upcase (c) = 'S' then
        begin
            mensagem ('CHDIGNOM', 1);  {'Digite o novo nome do arquivo atual (use extensão .CHQ)'}
            sintReadln (nomeNovo);

            while (nomeNovo <> '') and (nomeNovo[1] = ' ') do delete (nomeNovo, 1, 1);
            if nomeNovo = '' then
                mensagem ('CHDESIST', 1)   {'Desistiu'}
            else
                begin
                    acertaNomeArq (nomeNovo);
                    nomeArqLanc := nomeNovo;
                    geraSaldoAnterior;
                    mensagem ('CHOK', 2);   {'OK'}
                end;
        end;

    mensagem ('CHCNFPOS', 0);  {'Quer configurar a impressão? '}
    sintLetecla (c, c2);
    writeln;
    if upcase (c) = 'N' then goto fimConf;

    clrscr;
    mensagem ('CHCNFIMP', 2);  {'Configuração da impressão'}
    mensagem ('CHPFMESC', 2);  {'Preencha o formulário a seguir, termine com ESC'}

    formCria;
    formCampoBool ('CHANO4',   'Escreve ano com 4 digitos',   ano4Digitos);
    formCampoBool ('CHIMPDEI', 'Imprime cheque deitado',      deitado);
    formCampoBool ('CHRESTAU', 'Restaura valores de fábrica', restaura);
    formCampoInt  ('CHMILDIR', 'Milímetros para a direita',   ajusteMM.x);
    formCampoInt  ('CHMILBAI', 'Milímetros para baixo',       ajusteMM.y);
    formEdita (true);

    if restaura then
        geraPosicoesPadrao;

    writeln;
    mensagem ('CHAJUSP', 1);   {'Ajustando posições de escrita.'}
    mensagem ('CHREGUA', 1);   {'Alguém vai ajudá-lo a medir com uma régua.'}

    repeat
        writeln;
        imprimeModelo;

        mensagem ('CHMODOK', 0);   {'O modelo foi impresso nas posições corretas?'}
        sintLetecla (c, c2);
        writeln;
        c := upcase (c);
        if c = 'N' then
            ajustaPosicoes;
    until c <> 'N';

fimConf:
    writeln;
    guardaBanco (bancoAtual);
    mensagem ('CHOKCONF', 1);   {'Ok, configurado'}
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
    tabLetrasOpcoes: string [5] = 'pnbcr';

begin
    garanteEspacoTela(5);
    popupMenuCria (wherex, wherey, 50, 5, MAGENTA);
    MenuAdiciona ('CHAJC1'); {'   P    altera dados pessoais'}
    MenuAdiciona ('CHAJC2'); {'   N    registra novo banco'}
    MenuAdiciona ('CHAJC3'); {'   B    troca banco atual'}
    MenuAdiciona ('CHAJC4'); {'   C    altera a configuração do banco atual'}
    MenuAdiciona ('CHAJC5'); {'   R    remove um banco registrado'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('CHAJC0', 1); {'As opções de configuração são:'}
    mensagem ('CHAJC1', 1); {'   P    altera dados pessoais'}
    mensagem ('CHAJC2', 1); {'   N    registra novo banco'}
    mensagem ('CHAJC3', 1); {'   B    troca banco atual'}
    mensagem ('CHAJC4', 1); {'   C    altera a configuração do banco atual'}
    mensagem ('CHAJC5', 1); {'   R    remove um banco registrado'}
    mensagem ('CHAJC9', 1); {'   ESC  fim das configurações'}
    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{               configuração
{--------------------------------------------------------}

procedure configura;
var c, c2: char;
    fimConf: boolean;
label executa;
begin
    fimConf := false;
    repeat
        writeln;
        textBackground (MAGENTA);
        mensagem ('CHOPCONF', 0);   {'O que deseja configurar?'}
        textBackground (BLACK);
        sintLeTecla (c, c2);
        writeln;

        if c = #$0 then
            begin
                if (c2 = F1) then
                    ajuda
                else
                if (c2 = CIMA) or (c2 = BAIX) then
                    begin
                        c := selSetasOpcao;
                        goto executa;
                    end;
            end
        else
            begin
    executa:
                case upcase(c) of
                    'P': dadosPessoais;
                    'B': trocaBancoAtual;
                    'N': criaNovoBanco;
                    'C': configBanco;
                    'R': removeBanco;
                    ESC: fimConf := true;
                else
                    mensagem ('CHOPINV', 1);  {'Opção inválida, aperte F1 para ajuda'}
                end;
            end;
    until fimConf;
end;

end.
