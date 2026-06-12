program testaAleat;

{$APPTYPE CONSOLE}

uses
  SysUtils;

const numItensTotal = 10;
var avisitar: array [1..10] of integer;

procedure geraCategorias;
var i: integer;
begin
     for i := 1 to numItensTotal do
         avisitar[i] := i;
end;


procedure embaralhaCategorias;
var r, i: integer;
    temp: integer;
    nc: integer;
begin
//    for nc := 1 to ncategs do
        //with categs[nc] do
            for i := numItensTotal downto 1 do
                begin
                    r := random (i) + 1;
                    temp := avisitar[r];
                    aVisitar[r] := aVisitar [i];
                    aVisitar[i] := temp;
                end;
     //   end;
end;

var i, n: integer;
begin
    randomize;
   for n := 1 to 10 do
       begin
           geraCategorias;
           embaralhaCategorias;
           for i := 1 to numItensTotal do
               write (avisitar[i], ' ');
           writeln;
       end;
   readln;
end.
