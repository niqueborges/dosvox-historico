{-------------------------------------------------------------}
{                   papovox - configuracao
{-------------------------------------------------------------}

unit ppconf;

interface

uses dvwin, dvcrt, dvinet, dvForm, dvDic,
    windows, shellApi, sysUtils, winSock,
    ppvars, ppmsg, ppsnomes;

procedure configura;

implementation

{--------------------------------------------------------}
{                   configuração geral - recuperando e salvando alterações
{--------------------------------------------------------}

procedure configura;
var arq: text;
    nomeArq: shortString;
    c1, c2: char;
    regServNomes: shortString;
begin

    //Recupera dados do DOSVOX.INI

    servNomes    := sintAmbiente ('PAPOVOX', 'SERVNOMES');
    nomeUsuario  := sintAmbiente ('PAPOVOX', 'NOMEUSUARIO');
    enderUsuario := sintAmbiente ('PAPOVOX', 'ENDERUSUARIO');
    soletra:= sintAmbiente ('PAPOVOX', 'SOLETRA');
    pontua:= sintAmbiente ('PAPOVOX', 'PONTUA');
    acelerado:= sintAmbiente ('PAPOVOX', 'ACELERADO');
    dicion:= sintAmbiente ('PAPOVOX', 'COMDIC');
    entDir:= sintAmbiente ('PAPOVOX', 'ENTRADIRETO');
    regServNomes:= 'Não';

    //Apresenta formulário

    textBackground (BLUE);
    writeln;
    mensagem ('PPUSES', 1); {'Painel de configuração'}
    textBackground (BLACK);
    garanteEspacoTela (12);

    formCria;
    formCampo    ('PPS', 'Servidor: ', servNomes, 80);
    formCampo    ('PPN', 'Nome: ', nomeUsuario, 80);
    formCampo    ('PPE', 'Endereço eletrônico: ', enderUsuario, 80);
    formCampo    ('PPA', 'Arquivo pessoal: ', nomeArq, 80);
    formCampo    ('PPD', 'Ouvir digitação: ', soletra, 4);
    formCampo    ('PPP', 'Ouvir pontuação: ', pontua, 4);
    formCampo    ('PPMA', 'Modo acelerado: ', acelerado, 4);
    formCampo    ('PPCD', 'Com dicionário: ', dicion, 4);
    formCampo    ('PPCXD', 'Conexão direta: ', entDir, 4);
    formCampo    ('PPRS', 'Registro no servidor: ', regServNomes, 4);
    formEdita (true);

    //Reescrevendo no DOSVOX.INI

    sintGravaAmbiente ('PAPOVOX', 'SERVNOMES', servNomes);
    sintGravaAmbiente ('PAPOVOX', 'NOMEUSUARIO', nomeusuario);
    sintGravaAmbiente ('PAPOVOX', 'ENDERUSUARIO', enderUsuario);
    sintGravaAmbiente ('PAPOVOX', 'SOLETRA', soletra);
    sintGravaAmbiente ('PAPOVOX', 'PONTUA',  pontua);
    sintGravaAmbiente ('PAPOVOX', 'ACELERADO', acelerado);
    sintGravaAmbiente ('PAPOVOX', 'COMDIC', dicion);
    sintGravaAmbiente ('PAPOVOX', 'ENTRADIRETO', entDir);

    //Assume configurações

    if servNomes <> '' then
        selecionado:= servNomes;
    soletrando    := (soletra = '')   or (maiuscAnsi (copy (soletra, 1, 1)) <> 'N');
    sintFalaPont  := (pontua  = '')   or (maiuscAnsi (copy (pontua, 1, 1)) <> 'N');
    modoAcelerado := (acelerado = '') or (maiuscAnsi (copy (acelerado, 1, 1)) = 'S');
    comDic := (dicion <> '') and (maiuscAnsi (dicion[1]) = 'S');

    if not comDic then
    begin
        fechaDic;
        sintSom ('PPDD'); {'dicionário desativado'}
    end;

    if comDic then
        if carregaDic (nomeArqDic, nomeArqSufixos, nomeArqInexist, nomeArqNomes, nomeArqSugTroca) = 0 then
            sintSom ('PPDA') {'Dicionário ativado'}
        else
            sintSom ('PPNCD'); {'Não pude carregar o dicionário'}

    //Verifica desejo do usuário quanto ao registro no servidor de nomes

    if (regServNomes <> '') and (upcase(regServNomes[1]) <> 'S') then
        exit;

    //Verifica a existencia das informações pessoais

            if nomeArq <> '' then
                begin
                    assign (arq, nomeArq);
                    {$I-} reset (arq); {$I+}
                    if ioresult <> 0 then
                        begin
                            mensagem ('PPCARNAO', 1);   {'Arquivo não existe, cartão de visitas não será criado.}
                            nomeArq := '';
                        end;
                end;

    //Pede confirmação do registro

    mensagem ('PPCNFREG', 0);    {Confirma registro}
    sintLeTecla (c1, c2);
    writeln;
    if upcase (c1) <> 'S' then
        exit;

    if not anonimo then
        logonUsuario (enderUsuario, 'logoff');
    delay (500);
    if enderUsuario <> '' then
        registraUsuario (nomeUsuario, enderusuario, nomeArq);

end;

end.
