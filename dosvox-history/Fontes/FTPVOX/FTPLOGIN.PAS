{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotina para login
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpLogin;
interface

uses
    dvCrt, dvWin, sysUtils, winsock, winprocs,
    FTPDECOD,
    FTPDIR,
    ftpVars, ftpMsg, ftpDlg, ftpRede;

function pedeContaESenha (digitarContaSenha: boolean): boolean;

implementation

{-------------------------------------------------------------}
{                     pede conta e senha
{-------------------------------------------------------------}

function pedeContaESenha (digitarContaSenha: boolean): boolean;
var s: string;
    pediuSenha, pediuAccount: boolean;
    continua, erroFatal: boolean;
    codigo: integer;
begin
    result := false;
    pediuSenha := false;
    pediuAccount := false;
    erroFatal := true;
    senha := '';
    conta := '';

    if (not digitarContaSenha) and (upcase(sintAmbiente('FTPVOX','GUARDARSCCV', 'NAO')[1]) = 'S')  and (nomeHost = sintAmbiente ('FTPVOX', 'NOMECOMPUTADOR')) then
        begin
            conta := trim(sintAmbiente ('FTPVOX', 'CONTA'));
            senha := decodFraseMime64(trim(sintAmbiente ('FTPVOX', 'SCCV')));
        end;

            if conta = '' then
        begin
            mensagem ('FTCONTA', 0);  {'Qual a conta   '}
            sintReadln (conta);
        end;

    if conta = '' then
        mensagem ('FTDESIS', 1)  {'Desistiu'}
    else
        begin
            erroFatal := not enviaComando ('USER ' + conta);
            if not erroFatal then
                begin
                    while pins <> pret do
                        begin
                            repeat
                                pegaResposta (s, codigo, continua);
                                if continua and (pins = pret) then processaRede;
                            until not continua;

                            if codigo = 331 then
                                pediuSenha := true
                            else
                            if codigo = 332 then
                                pediuAccount := true
                            else
                            if (codigo = 530) or (codigo = 500) or (codigo = 501) or
                               (codigo = 421) then
                                begin
                                    if not erroFatal then
                                      begin
                                        mensagem ('FTERCONT', 1);  {'Problemas com a conta, código'}
                                        if not verboso then
                                            sintetiza (s);
                                      end;
                                    erroFatal := true;
                                end
                        end;
                end;
        end;

    if erroFatal then exit;

    if pediuSenha then
        begin
            if senha = '' then
                begin
                    mensagem ('FTSENHA', 0);  {'Qual a senha   '}
                    textColor (black);
                    readln (senha);
                    textColor (white);
                end;

            erroFatal := not enviaComando ('PASS ' + senha);
            if not erroFatal then
                begin
                    repeat
                        while pins <> pret do
                            begin
                                repeat
                                    pegaResposta (s, codigo, continua);
                                    if continua and (pins = pret) then processaRede;
                                until not continua;

                                if codigo = 332 then
                                    pediuAccount := true
                                else
                                if (codigo = 500) or (codigo = 501) or (codigo = 530)
                                                  or (codigo = 421) then
                                    begin
                                        if not erroFatal then
                                          begin
                                            mensagem ('FTERSENH', 1);  {'Senha não foi aceita, código'}
                                            if not verboso then
                                               sintetiza (s);
                                            end;
                                        erroFatal := true;
                                    end
                            end;
                        until not continua;
                end;
        end;

    if erroFatal then exit;

    if pediuAccount then
        begin
            mensagem ('FTCHAVE', 0);  {'Qual a sua chave de acesso   '}
            textColor (black);
            readln (senha);
            textColor (white);

            if enviaComando ('ACCT ' + senha) then
                begin
                    while pins <> pret do
                        begin
                            pegaResposta (s, codigo, continua);
                            if (codigo = 500) or (codigo = 501) or (codigo = 421) then
                                begin
                                    if not erroFatal then
                                        begin
                                          mensagem ('FTERCHAV', 1);  {'Chave de acesso não foi aceita, código'}
                                          if not verboso then
                                             sintetiza (s);
                                        end;
                                    erroFatal := true;
                                end
                        end;
                end;
        end;

    if not erroFatal then
        begin
            result := true;
            mensagem ('FTACLIBE', 1);  {'Acesso liberado'}
            if upcase(sintAmbiente('FTPVOX','GUARDARSCCV', 'NAO')[1]) = 'S' then
                begin
                    sintGravaAmbiente('FTPVOX', 'NOMECOMPUTADOR', nomeHost);
                    sintGravaAmbiente('FTPVOX', 'CONTA', conta);
                    sintGravaAmbiente('FTPVOX', 'SCCV', codFraseMime64 (senha));
                end;

    trocaDir (trim(sintAmbiente ('FTPVOX', 'DIRETORIOTRABALHO', '')), true);
        end;
end;

begin
end.
