program Monopoly;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'ui\Unit1.pas' {Form1},
  UBoard in 'domain\UBoard.pas',
  UDie in 'domain\UDie.pas',
  UMGame in 'domain\UMGame.pas',
  UPiece in 'domain\UPiece.pas',
  UPlayer in 'domain\UPlayer.pas',
  USquare in 'domain\USquare.pas',
  Ai in 'ui\Ai.pas',
  LoadSave in 'ui\LoadSave.pas',
  UProperties in 'ui\UProperties.pas',
  CardChangeProposal in 'ui\CardChangeProposal.pas',
  Unit2 in 'ui\Unit2.pas',
  Unit3 in 'ui\Unit3.pas',
  Language in 'ui\Language.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
