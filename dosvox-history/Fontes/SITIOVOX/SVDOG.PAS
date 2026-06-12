{--------------------------------------------------------}
{          sitiovox - cachorro virtual
{--------------------------------------------------------}

unit svDog;
interface
uses dvCrt, dvWin, dvinet, winprocs, wintypes,
     svvars, svMsg, svFila, svrede;

procedure lateCachorro;

implementation

procedure lateCachorro;
const
    latidos: array [0..19] of string [40] =
        ('au', 'au au',  'au au au', 'au au au au',
         'au!', 'au au!',  'au au au!', 'au au au au!',
         'au?', 'au au?',  'au au au?', 'au au au au?',
         'cáin!', 'cáin cáin cáin!',
         'rwrrrrrrrrrrrrrrrrrrrrrrrrrr áu!',
         'rwrrrrrrrrrrrrrrrrrrrrrrrrr áu! áu áu!',
         'srlup srlup srlup !',
         'arf arf arf arf',
         'arf arf arf arf áu arf arf',
         'arf arf arf áu ! arf arf arf áu áu !'
        );


begin
    insereFilaMsg ('cachorrinho', '*', latidos [random(20)]);
end;

end.
