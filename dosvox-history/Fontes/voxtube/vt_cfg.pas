{
    VoxTube - utilitário de acessibilização do YouTube  ;

Rotina de configuração;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_cfg;

interface
procedure configura;

implementation
uses
dvcrt,
dvwin,
dvform,
vt_aju,
 vt_msg,
vt_var;

procedure configura;
var
    n: integer;
const
    opmenu: string = 'D';
begin
    writeln;
    mensagem ('VTSELCNF', 1);  {'Selecione com as setas a opção de configuração:'}

    popupMenuCria(1, wherey, 40, length(opmenu), RED);
    MenuAdiciona('VTOP_DEB');       {'D - Ativa modo debug para programadores'}
    n := popupMenuSeleciona;

    if (n < 1) then
        mensagem ('VTOK', 2)       {'Ok!'}
    else
        begin
            case opmenu[n] of

                'D':  debug := not debug;
            end;
            mensagem ('VTOK', 2);
        end;

    limpaBufTec;
end;

end.
