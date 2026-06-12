program gravadosvox;

uses
  Forms,
  uprinc in 'uprinc.pas' {Form1},
  dvgrav in 'c:\WINVOX\fontes\TRADUTOR\DVGRAV.PAS';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
