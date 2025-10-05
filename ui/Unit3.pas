unit Unit3;

interface

uses
  FMX.Forms,FMX.Controls,FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, System.Classes, FMX.Types, FMX.Objects,Language;

type
  TForm3 = class(TForm)
    ButtonReturn: TButton;
    Image1: TImage;
    Memo1: TMemo;
    procedure ButtonReturnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}

procedure TForm3.ButtonReturnClick(Sender: TObject);
begin
 close;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  ButtonReturn.Text := CurrentLanguage.GetGuiString('Return');
  {$IFDEF ANDROID}
  ButtonReturn.Position.X := Memo1.Position.X;
  ButtonReturn.Width := Memo1.Width;
  {$ENDIF}
end;

end.
