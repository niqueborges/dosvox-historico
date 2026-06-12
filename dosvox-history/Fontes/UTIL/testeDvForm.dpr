program ex_form;

uses
  dvcrt,
  dvwin,
  dvform;

var
  nome: string[50];
  idade: integer;
  altura: real;

  exibe: boolean;

begin
  sintInic (0,'');

  formCria;
  formCampo('','Nome:', nome, 50);
  formCampoInt('','Idade:', idade);
  formCampoReal('','Altura:', altura,2);
  formCampoBool('','Deseja exibir? ', exibe);
  formEdita(True);

  if exibe then
    begin
      clrscr;
      write('Nome: ');
      sintwrite(nome);
      writeln; 
      write('Idade: ');  
      sintwriteint(idade);
      writeln; 
      write('Altura: ');
      sintWriteReal(altura,3,2);
      writeln; 
    end
  else
    sintetiza('Programa finalizado');

  readln;
  sintFim;

end.
 