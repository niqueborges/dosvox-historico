unit ppFonte;

interface

uses
  dvcrt,
  dvwin,
  windows,
  classes,
  ppjanela,
  ppEdita,
  ppArq,
  ppMsg,
  ppvars;

procedure criaFontes;
procedure destroiFontes;

implementation

{--- cria uma fonte para o título, outra para os detalhes ---}

procedure criaFontes;
begin

//    fonteTitulo := criaFonte (36, 'Times New Roman', true);
//    fonteDetalhe := criaFonte (24, 'Arial', false);

    fonteTitulo := criaFonte (t_tit, f_tit, true);
    fonteDetalhe := criaFonte (t_lin, f_lin, false);
    fonteSimbolo := criaFonte (24, 'Symbol', true);
end;

{--- destrói as fontes criadas ---}

procedure destroiFontes;
begin
    deleteObject (fonteTitulo);
    deleteObject (fonteDetalhe);
    deleteObject (fonteSimbolo);
end;

end.
