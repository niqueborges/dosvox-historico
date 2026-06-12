{
    VoxTube - utilitário de acessibilização do YouTube  ;

    Programa Principal;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

program voxtube;

uses
dvcrt,
dvwin,
vt_msg, //rotinas de controle das mensagens
vt_ini; //rotinas de inicialização

begin
    inicializa;
    processa;

    clrscr;
    mensagem ('VTFIM',1); {'Fim do programa'}
    sintfim;
    doneWinCrt;
end.
