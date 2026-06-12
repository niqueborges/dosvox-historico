{ modelo para programas que usam protecao de senha }

uses dvsenha, dvcrt;
var nomeUsuario: string;
    senha: string;
begin
   { este dia sera o primeiro de 10 dias de validade da senha }
   { este valor e' o que se informa ao usuario }
   senha := calculaSenhaOficial (2, 10, 1999, 'REGISTRO');
   writeln (senha);

   { este trecho registra uma senha } 
   writeln ('Tecle a senha');
   readln (senha);
   writeln ('Tecle o nome do usuário');
   readln (nomeUsuario);

   if registraCopia ('XXXXXVOX', '\TEMP\AAAAREG.DAT', 'REGISTRO', nomeUsuario, senha) then
      writeln ('Registro OK')
   else
      writeln ('Registro falhou');

   { este trecho verifica se um programa foi registrado }
   if copiaRegistrada ('XXXXXVOX', '\TEMP\AAAAREG.DAT', 'REGISTRO', nomeUsuario) then
       writeln ('Cópia está registrada para ', nomeUsuario)
   else
       writeln ('Cópia não está registrada', nomeUsuario);

   readln;
   doneWinCrt;
end.

end.
