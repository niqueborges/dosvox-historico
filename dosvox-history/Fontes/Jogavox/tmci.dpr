program tmci;

uses
  SysUtils, dvcrt, dvwin, jomci;

begin
     clrscr;
//     iniciaMciSlide ('c:\winvox\jogavox\instrumentos\violão.mp3');
     iniciaMciSlide ('c:\winvox\treino\strauss.mp3');
     while tocandoMciSlide and (not keypressed) do
         delay (100);
     terminaMciSlide;
     donewincrt;
end.
 