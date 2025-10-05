unit UPiece;

interface

uses
  USquare;

type
  TPiece = class
  private
    location: TSquare;
  published
    constructor create(location: TSquare);
  public
    function getLocation: TSquare;
    procedure setLocation(location: TSquare);
  end;

implementation

{ TPiece }

constructor TPiece.create(location: TSquare);
begin
  self.location := location;
end;

function TPiece.getLocation: TSquare;
begin
  result := location;
end;

procedure TPiece.setLocation(location: TSquare);
begin
  self.location := location;
end;

end.
