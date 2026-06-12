unit mvconfig;

interface
uses dvcrt, dvwin, dvform, mvmsg, mvVars, windows, messages, sysutils, mvposjan;

procedure configura;

implementation

{--------------------------------------------------------}
{                configuração de voz
{--------------------------------------------------------}

procedure configura;
var
    s: string;
    c: char;

begin
    posjan (0,0, 45, 10);
    mensagem ('MOEDICNF', 1);  {'Editore as configurações, ao final tecle ESC'}

    formCria;
    formCampoInt  ('MOVELSIN', pegaTextoMensagem ('MOVELSIN'), veloc);       {'Velocidade do sintetizador'}
    formCampoBool ('MOUSASAP', pegaTextoMensagem ('MOUSASAP'), usaSapi);     {'Usa fala Sapi'}
    formCampoInt  ('MOTIPSAP', pegaTextoMensagem ('MOTIPSAP'), tipoFalaSapi);{'Tipo Sapi (4 ou 5)'}
    formCampoInt  ('MOVOZSAP', pegaTextoMensagem ('MOVOZSAP'), vozSapi);     {'Número da voz Sapi'}
    formCampoInt  ('MOVELSAP', pegaTextoMensagem ('MOVELSAP'), velSapi);     {'Velocidade Sapi'}
    formCampoInt  ('MOTOMSAP', pegaTextoMensagem ('MOTOMSAP'), tomSapi);     {'Tonalidade Sapi'}
    formCampoBool ('MOCORTAF', pegaTextoMensagem ('MOCORTAF'), cortaFala);   {'Corta fala automática? '}
    formEdita (true);

//    if (veloc < 0) or (veloc > 5) then veloc := 3;
    sintGravaAmbiente ('MONITVOX', 'VELOCIDADE', intToStr(veloc));

    if (tipoFalaSapi > 5) or (tipoFalaSapi < 3) then tipoFalaSapi := 4;
    if vozSapi < 0 then vozSapi := 1;
//    if velSapi < 0 then velSapi := 100;
//    if tomSapi < 0 then tomSapi := 100;
    if usaSapi then s := 'SIM' else s := 'NÃO';

    sintGravaAmbiente ('MONITVOX', 'SAPI', s);
    sintGravaAmbiente ('MONITVOX', 'TIPOSAPI',  intToStr(tipoFalaSapi));
    sintGravaAmbiente ('MONITVOX', 'VOZSAPI',   intToStr(vozSapi));
    sintGravaAmbiente ('MONITVOX', 'VELOCSAPI', intToStr(velSapi));
    sintGravaAmbiente ('MONITVOX', 'TOMSAPI',   intToStr(tomSapi));

    if cortaFala then s := 'SIM' else s := 'NÃO';
    sintGravaAmbiente('MONITVOX', 'CORTAFALA', s);

    writeln;
    mensagem ('MOCONFIR', 0);   {'Confirma configuração? '}
    c := sintReadkey;
    writeln (c);
    if upcase(c) <> 'N' then
        sintReinic (veloc, usaSapi, tipoFalaSapi, vozSapi, velSapi, tomSapi);

    posJan (0, 0, 43, 4);
end;

end.
