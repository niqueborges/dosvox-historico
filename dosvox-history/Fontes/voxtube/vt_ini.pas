{
    VoxTube - utilitário de acessibilização do YouTube  ;

Rotinas de inicialização

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_ini;

interface
procedure inicializa;
procedure processa;
procedure cabecalho (falando: boolean);

implementation
uses
    dvcrt,
dvform,
    dvwin,
sysutils,
vt_bus,
vt_cfg,
vt_msg,
vt_var;

procedure inicializa;
var i: integer;
    dir: string;
begin
pagatual := 1;
limite := 30;
    clrscr;
    setWindowTitle('VoxTube ' + VERSAO);

dir := sintambiente('DOSVOX','PGMDOSVOX')+'\som\voxtube';
 if sintambiente('VOXTUBE','DIRVOXTUBE') = '' then
sintgravaambiente('VOXTUBE','DIRVOXTUBE','@\som\voxtube');

    sintInic (0, dir);

    for i := 1 to 10 do
        ultimasBuscas[i] := sintAmbiente ('VOXTUBE', intToStr(i));

if sintambiente('VOXTUBE', 'QUANTOSPORBUSCA') = '' then
sintgravaambiente('VOXTUBE','QUANTOSPORBUSCA',inttostr(limite))
else
limite := strtoint(SintAmbiente('VOXTUBE','QUANTOSPORBUSCA'));
end;

procedure cabecalho (falando: boolean);
begin
    textbackground (BLUE);
    if falando and sintFalarTudo then
        begin
            mensagem ('VTINIC',0);    {'Programa de Pesquisa no YouTube'}
            sintWriteln (VERSAO);
        end
    else
         writeln (pegaTextoMensagem('VTINIC') + VERSAO);
    textbackground (BLACK);
end;

procedure processa;
var
    primeiraVez: boolean;
    c: char;
    busca: string;

label inicio, fim;

begin
    debug := false;
    primeiraVez := true;
    repeat
        window (1, 1, 80, 25);
        clrscr;

        cabecalho (primeiraVez);

        primeiraVez := false;

        gotoxy (1, 2);
        mensagem ('VTQBUSCA', 0);   {'Qual sua busca: '}
        busca := '';
        c := sintEditaCampo (busca, wherex, wherey, 200, 80, true);
        writeln;

        if c = CTLHOME then
             begin
                 mensagem ('VTINIC',-1);    {'Programa de Pesquisa no YouTube'}
                 sintetiza (VERSAO);
                 continue;
             end
        else
        if c = F9 then
             begin
                 configura;
                 continue;
             end
        else
        if c = BAIX then
            busca := escolheBusca
        else
        if ( busca = '') or (c = ESC)  then
            goto fim;

        adicionaAosUltimos(busca);
        processaBusca (busca);

        clrscr;
fim:
pagatual := 1;
quantoslinks := 0;
if sintfalartudo then begin
        mensagem ('VTOUTRO', 0);   {'Deseja pesquisar outro assunto? '}
        c := upcase(popupMenuPorLetra ('SN'));
end;
    until c in ['N', ESC];
end;

end.
