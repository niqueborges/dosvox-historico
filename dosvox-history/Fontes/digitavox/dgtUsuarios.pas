{-------------------------------------------------------------}
{
{       Digitavox - Tratamento dos usuários
{
{       Autor: Neno Henrique da Cunha Albernaz
{              neno@intervox.nce.ufrj.br
{       Em 05 de Outubro de 2019
{
{-------------------------------------------------------------}

unit dgtUsuarios;

interface

uses
    dvcrt,
    dvWin,
    sysutils,
    windows,
    dvform,
    dgtMsg,
    dgtTela,
    dgtUtil,
    dgtVars;

function registrarUsuario: boolean;

implementation

{-------------------------------------------------------------}
{       Retorna se existe caracter válido para formar o nome do arquivo do usuário.
{-------------------------------------------------------------}

function validarNomeUsuario (nomeUsuario: string): boolean;
var
    i: integer;
begin
    result := false;
    if trim (nomeUsuario) <> '' then
        for i :=  length(nomeUsuario) downto 1 do
            if nomeUsuario[i] in ['-', '_', 'A'..'Z', 'a'..'z', '0'..'9'] then
                begin
                    result := true;
                    break;
                end;
end;

{-------------------------------------------------------------}
{       Retorna o nome do arquivo do usuário a partir do nome.
{-------------------------------------------------------------}

function criarNomeArqUsuario (nomeUsuario: string): string;
var
    i: integer;
    s: string;
begin
    s := '';
    nomeUsuario := semAcentos (nomeUsuario);
    for i :=  length(nomeUsuario) downto 1 do
        if nomeUsuario[i] = ' ' then nomeUsuario[i] := '_';
    for i :=  length(nomeUsuario) downto 1 do
        if nomeUsuario[i] in ['-', '_', 'A'..'Z', 'a'..'z', '0'..'9'] then
            s := nomeUsuario[i] + s;
    result := dirUsuarios + '\' + s + '.ini';
end;

{-------------------------------------------------------------}
{       Cria um arquivo texto, retorna false se não conseguir criar
{-------------------------------------------------------------}

function criarArquivo (nomeArq: string): boolean;
var arq: text;
begin
    assign (arq, nomeArq);
    {$I-} rewrite (arq); {$I+}
    result := ioresult = 0;
    {$I-} close (arq); {$I+}
    if  ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Pede e verifica se existe o usuário, caso negativo pergunta se cadastra.
{-------------------------------------------------------------}

function registrarUsuario: boolean;
var
    c: char;
    s: string;

label sair, redigita;

begin
    result := false;
    telaPrincipal;
    nomeUsuario := '';
    repeat
        limpaBaixo (3);
        textBackground (RED);
        mensagem ('DGTDIGNOM', 0); {'Digite seu nome para identificação, depois tecle Enter para entrar no Digitavox.'}
        textBackground (BLACK);
        writeln;
redigita:
        limpaBaixo (4);
        c := sintEditaCampo (nomeUsuario, 1, wherey, 255, 80, true);
        writeln;

        if (c = BAIX) and (nomeUsuario = '') then   // lembra do último usuário
            begin
                nomeUsuario := sintAmbiente ('DIGITAVOX', 'ULTIMOUSUARIO');
                gotoxy (1, wherey-1);
                clreol;
                sintWriteln (nomeUsuario);
                goto redigita;
            end;
        if c = ESC then goto sair;
    until c = ENTER;

    writeln;
    nomeUsuario := trim(nomeUsuario);
    sintGravaAmbiente('DIGITAVOX', 'ULTIMOUSUARIO', nomeUsuario);

    if nomeUsuario = '' then
        repeat
            limpabaixo (5);
            textBackground (RED);
            mensagem ('DGTUSUANO', 0); {'Sem nome, deseja entrar como anônimo?'}
            textBackground (BLACK);
            writeln;
            c := upcase(popupMenuPorLetra ('SN'));
            if c = ESC then goto sair;
            if c in ['S', ENTER] then nomeUsuario := 'Anônimo'
            else
            if c = 'N' then
                begin
                    result := registrarUsuario;
                    exit;
                end;
        until c in ['S', ENTER];

    if validarNomeUsuario (nomeUsuario) then
        nomeArqUsuario := criarNomeArqUsuario (nomeUsuario)
    else
        begin
            mensagem ('DGTNAUIN', 1); {'Erro: nome de usuário inválido, por favor digite letras.'}
            result := registrarUsuario;
            exit;
        end;

    if not FileExists(nomeArqUsuario) then
        repeat
            limpaBaixo (10);
            textBackground (RED);
            mensagem ('DGTTUSUARI', 0); {'Usuário '}
            sintWrite (nomeUsuario);
            mensagem ('DGTNAOCAD', 1); {' não cadastrado.'}
            mensagem ('DGTDECAUS', 0); {'Deseja cadastra-lo agora? Tecle S para confirmar ou N para cancelar: '}
            textBackground (BLACK);
            c := upcase(popupMenuPorLetra ('SN'));

            if c = ESC then goto sair;
            if c = 'N' then
                begin
                    result := registrarUsuario;
                    exit;
                end
            else
            if c in ['S', ENTER] then
                if not criarArquivo (nomeArqUsuario) then
                    begin
                        mensagem ('DGTERCRARQ', 1); {'Não foi possível cadastrar este nome, por favor tente outro.'}
                        result := registrarUsuario;
                        exit;
                    end
                else
                    sintGravaAmbienteArq ('USUARIO', 'NOMEUSUARIO', nomeUsuario, nomeArqUsuario);
        until c in ['S', ENTER]
    else
        begin
            s := sintAmbienteArq ('USUARIO', 'NOMEUSUARIO', '', nomeArqUsuario);
            if trim(s) = '' then
                sintGravaAmbienteArq ('USUARIO', 'NOMEUSUARIO', nomeUsuario, nomeArqUsuario)
            else
                nomeUsuario := s;
        end;

    if length(nomeUsuario) > 25 then
        setWindowTitle ('Digitavox - ' + copy (nomeUsuario, 1, 25) + '...')
    else
        setWindowTitle ('Digitavox - ' + nomeUsuario);

    limpaBaixo (15);
    tocaEfeito ('TECLADO');
    mensagem ('DGTBEMVIN', 0); {'Bem vindo '}
    sintWriteln (nomeUsuario);
    mensagem ('DGTDEHAB', 2); {'O Digitavox vai te ajudar a desenvolver habilidades no teclado do computador.'}
    tocaEfeito ('TECLADO');

    result := true;
    exit;

sair:
    repeat
        limpaBaixo (20);
        textBackground (RED);
        mensagem('DGTSAIDIGI', 0); {'Gostaria de realmente sair do Digitavox? '}
        textBackground (BLACK);
        writeln;
        c := upcase(popupMenuPorLetra ('SN'));

        if c in ['N', ESC] then
            begin
                result := registrarUsuario;
                exit;
            end
        else
        if c in ['S', ENTER] then
            result := false;
    until c in ['S', ENTER];
end;

{-------------------------------------------------------------}

begin
end.
