program editadic;

uses
  Forms,
  uescolhedic in 'uescolhedic.pas' {FormEscolher},
  ueditadic in 'ueditadic.pas' {FormEditar};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormEditar, FormEditar);
  Application.CreateForm(TFormEscolher, FormEscolher);
  Application.Run;
end.
