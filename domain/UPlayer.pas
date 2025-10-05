unit UPlayer;
interface
uses
  SysUtils, Classes, Generics.Collections, Generics.Defaults,
  UPiece, UBoard, UDie, USquare;
type
  TPlayer = class
  private
    name: string;
    piece: TPiece;
    board: TBoard;
    dice: TList<TDie>;
  published
    constructor create(name: string; dice: TDie; board: TBoard);
  public
    JailFlag :Byte;
    function takeTurn:boolean;
    procedure SetLocation(Index:Byte);
    procedure GoToJail;
    function GetLocation: TSquare;
    function getName: string;
  end;
implementation
{ TPlayer }
constructor TPlayer.create(name: string; dice: TDie; board: TBoard);
begin
  self.name := name;
  //self.dice := dice;
  self.dice := TList<TDie>.create;
  self.dice.Add(dice);
  self.dice.Add(TDie.create);
  self.board := board;
  piece := TPiece.create(board.getStartSquare);
end;
function TPlayer.GetLocation: TSquare;
begin
  result := piece.GetLocation;
end;
function TPlayer.getName: string;
begin
  result := name;
end;
function TPlayer.takeTurn;
var
  rollTotal, i: integer;
  newLoc: TSquare;
  dice2 : Boolean;
begin
  // бросание кубиков
  result := True;
  rollTotal := 0;
  for i := 0 to dice.Count-1 do
  begin // length = 2
    dice.Items[i].roll;
    rollTotal := rollTotal + self.dice.Items[i].getFaceValue;
  end;
  dice2 := (dice.Items[0].getFaceValue=dice.Items[1].getFaceValue);
  if (JailFlag<3) or dice2  then
    begin
      newLoc := board.getSquare(piece.GetLocation, rollTotal);
      piece.setLocation(newLoc);
    end
  else result :=False;
  if (JailFlag>0) and (not dice2)  then result :=False;
end;
procedure TPlayer.SetLocation(Index: Byte);
var
  newLoc: TSquare;
begin
  newLoc := board.getSquare(board.getStartSquare,Index);
  piece.setLocation(newLoc);
end;
procedure TPlayer.GoToJail;
begin
  JailFlag := 4;
  SetLocation(10);
end;

end.
