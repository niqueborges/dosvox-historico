program sapi4cnf;

uses
  Forms,
  usapi in 'usapi.pas',
  uformInfo in 'uformInfo.pas' {FormInfo},
  utesta in 'utesta.pas' {form_fala};

{MainForm}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFormInfo, FormInfo);
  Application.CreateForm(Tform_fala, form_fala);
  Application.Run;
end.
