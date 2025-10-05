unit UDie;
interface
type
  TDie = class
  const
    MAX = 6;
  private
    faceValue: integer;
  public
    procedure roll;
    function getFaceValue: integer;
    function RollAndFace:Integer;
  published
    constructor create;
  end;
implementation
{ TDie }
constructor TDie.create;
begin
  roll;
end;
function TDie.getFaceValue: integer;
begin
  result := faceValue;
end;
procedure TDie.roll;
begin
  faceValue := random(MAX) + 1;
end;
function TDie.RollAndFace;
begin
  Roll;
  result:=getFaceValue;
end;
end.
