unit dosmonit;

interface
uses windows, dvcrt, dvwin, dosvars, classes, sysutils, dvMsaa;

procedure iniciaMonitoracao;
procedure fimMonitoracao (falando: boolean);
var
    noDosvox: boolean;
    monitAtiva: boolean;

implementation

type
    TThreadMonit = class (TThread)
        procedure execute;  override;
    end;

var
    f, r: integer;

procedure TThreadMonit.execute;
var
    ultNome, x: string;
    filaFala: array [0..2] of string;
begin
    freeOnTerminate := true;
    while monitAtiva do
        begin
            while MSAAPegaEvento do
                begin
                    ultNome := MSAANome + ' ' + MSAATipo;
                    filaFala[f] := MSAANome;
                    f := (f + 1) mod 3;
                    if f = r then r := (r + 1) mod 3;
                end;

            if (r <> f) and (not sintFalando) then
                begin
                    sintPara;
                    x := filaFala[r];
                    r := (r + 1) mod 3;
                    if x <> ultNome then
                        begin
                            sintetiza (x);
                            ultNome := x;
                        end;
                end;
            delay (100);
        end;
end;

procedure iniciaMonitoracao;
begin
    sintetiza ('Monitoração ligada');
    monitAtiva := true;
    MSAAmonitora (true);
    TThreadMonit.Create (false);
end;

procedure fimMonitoracao (falando: boolean);
begin
    MSAAmonitora (false);
    f := r;
    if falando then
        sintetiza ('Monitoração desligada');
    monitAtiva := false;
end;

end.
