unit CardChangeProposal;
interface
uses FMX.Forms,FMX.Controls,FMX.StdCtrls,UProperties, System.Classes, FMX.Types,
  FMX.Controls.Presentation,FMX.Objects,System.SysUtils,System.UITypes,Language,LoadSave;

type
 { TCardRecord = record
    Index: Byte;
    // Add other card properties as needed
    // Image: TBitmap;
    // Name: string;
    // Value: Integer;
  end;
  TProposal = array[0..2] of TCardRecord;}
  TCardChangeProposalForm = class(TForm)
    btnProposalOne: TButton;
    btnProposalTwo: TButton;
    btnCancel: TButton;
    ProposalOnePanel: TPanel;
    ProposalTwoPanel: TPanel;
    lblProposalOne: TLabel;
    lblProposalTwo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnProposalClick(Sender: TObject);
  private
    FProposalOne: TChangeState ;
    FProposalTwo: TChangeState ;
    FProposalC1: Integer;
    FProposalC2: Integer;
    FCardImages: array of TImage;
    procedure ClearCardImages;
    procedure DisplayProposal(ProposalPanel: TPanel; Proposal: TChangeState ; Cost: Integer);
  public
    IsCancel : Boolean;
    procedure SetProposals(ProposalOne, ProposalTwo: TChangeState ; ProposalC1, ProposalC2: Integer);
  end;
var
  CardChangeProposalForm: TCardChangeProposalForm;
implementation
{$R *.fmx}
procedure TCardChangeProposalForm.FormCreate(Sender: TObject);
begin
  // Initialize form
  FProposalC1 := 0;
  FProposalC2 := 0;
  SetLength(FCardImages, 0);
  btnCancel.Text := CurrentLanguage.GetGuiString('Cancel');
  btnProposalOne.Text := CurrentLanguage.GetGuiString('Proposal1');
  btnProposalTwo.Text := CurrentLanguage.GetGuiString('Proposal2');
  IsCancel :=False;
 // {$IFDEF ANDROID}
  ProposalOnePanel.Width := ClientWidth;
  ProposalTwoPanel.Width := ClientWidth;
  ProposalOnePanel.Height := ClientHeight/3;
  ProposalTwoPanel.Height := ClientHeight/3;
  ProposalTwoPanel.Position.Y := ClientHeight/3;
  lblProposalOne.Position.Y :=  ClientHeight/3-45;
  lblProposalTwo.Position.Y :=  2*ClientHeight/3-45;
  btnCancel.Position.Y := ClientHeight-btnCancel.Height-10;
  btnProposalOne.Position.Y  := btnCancel.Position.Y;
  btnProposalTwo.Position.Y := btnCancel.Position.Y;
//  {$ENDIF}
end;
procedure TCardChangeProposalForm.FormDestroy(Sender: TObject);
begin
  ClearCardImages;
end;
procedure TCardChangeProposalForm.btnCancelClick(Sender: TObject);
begin
  ModalResult :=mrCancel;
  IsCancel := True;
  Close;
end;

procedure TCardChangeProposalForm.btnProposalClick(Sender: TObject);
var Pay:Integer;
i:Integer;
begin
  IsCancel := False;
  if Sender=btnProposalOne then Pay := FProposalC1
                           else Pay := FProposalC2;
  for I :=0 to 2 do
   begin
     if Sender=btnProposalOne then
       begin
         if FProposalOne.ChangeArr[i]<250 then ChangeOwner(0,FProposalOne.ChangeArr[i]);//Properties[FProposalOne.ChangeArr[i]].Owner :=1;
         if FProposalTwo.ChangeArr[i]<250 then ChangeOwner(1,FProposalTwo.ChangeArr[i]);//Properties[FProposalTwo.ChangeArr[i]].Owner :=2;
       end
     else
       begin
         if FProposalOne.ChangeArr[i]<250 then ChangeOwner(1,FProposalOne.ChangeArr[i]);//Properties[FProposalOne.ChangeArr[i]].Owner :=2;
         if FProposalTwo.ChangeArr[i]<250 then ChangeOwner(0,FProposalTwo.ChangeArr[i]);//Properties[FProposalTwo.ChangeArr[i]].Owner :=1;
       end;
   end;
Banks[0] := Banks[0] - Pay;
Banks[1] := Banks[1] + Pay;
Close;
end;

procedure TCardChangeProposalForm.ClearCardImages;
var
  i: Integer;
begin
  for i := 0 to High(FCardImages) do
    FCardImages[i].Free;
  SetLength(FCardImages, 0);
end;
procedure TCardChangeProposalForm.DisplayProposal(ProposalPanel: TPanel; Proposal: TChangeState; Cost: Integer);
var
  i, VisibleCount: Integer;
  CardImage: TImage;
  CardLeft: Single;
begin
  // Clear existing images
  for i := ProposalPanel.ChildrenCount - 1 downto 0 do
    if ProposalPanel.Children[i] is TImage then
      ProposalPanel.Children[i].Free;
  // Calculate how many cards are visible in this proposal
  VisibleCount := 0;
  for i := 0 to 2 do
    if Proposal.ChangeArr[i] <> 255 then
      Inc(VisibleCount);
  if VisibleCount = 0 then Exit;
  // Position cards in the center of the panel
  CardLeft := (ProposalPanel.Width - (VisibleCount * 80 + (VisibleCount - 1) * 10))*2/3;
  // Create and position card images
  for i := 0 to 2 do
  begin
    if Proposal.ChangeArr[i] <> 255 then
    begin
      CardImage := TImage.Create(ProposalPanel);
      CardImage.Parent := ProposalPanel;
      CardImage.Width := 80;
      CardImage.Height := 120;
      CardImage.Position.X := CardLeft;
      CardImage.Position.Y := 10;
      
      // Here you would load the actual card image based on Proposal[i].Index
      // For example:
      // CardImage.Picture.LoadFromFile('card_' + IntToStr(Proposal[i].Index) + '.jpg');
      // For now, we'll just create a placeholder
      CardImage.Bitmap.LoadFromFile(GetPath+'images/'+IntToStr(FindCardByIndex(Proposal.ChangeArr[i])+2)+'.PNG');
      CardImage.Bitmap.Rotate(GetRotateAngle(Proposal.ChangeArr[i]));
      //CardImage.Canvas.Brush.Color := clWhite;
      //CardImage.Canvas.Rectangle(0, 0, CardImage.Width, CardImage.Height);
     // CardImage.Canvas.TextOut(10, 10, 'Card ' + Properties[Proposal.ChangeArr[i]].Name);
      CardLeft := CardLeft + 90; // Move right for next card
    end;
  end;
end;
procedure TCardChangeProposalForm.SetProposals(ProposalOne, ProposalTwo: TChangeState; ProposalC1, ProposalC2: Integer);
begin
  FProposalOne := ProposalOne;
  FProposalTwo := ProposalTwo;
  FProposalC1 := ProposalC1;
  FProposalC2 := ProposalC2;
  // Update labels with cost information
  if FProposalC1 > 0 then
    lblProposalOne.Text := {'You pay}CurrentLanguage.GetGuiString('Pay')+': ' + IntToStr(FProposalC1)
  else
    lblProposalOne.Text := {'You take}CurrentLanguage.GetGuiString('Take')+': ' + IntToStr(-FProposalC1);
  if FProposalC2 > 0 then
    lblProposalTwo.Text := {'You pay}CurrentLanguage.GetGuiString('Pay')+': ' + IntToStr(FProposalC2)
  else
    lblProposalTwo.Text := {'You take}CurrentLanguage.GetGuiString('Take')+': ' + IntToStr(-FProposalC2);
  // Display the proposals
  ClearCardImages;
  DisplayProposal(ProposalOnePanel, FProposalOne, FProposalC1);
  DisplayProposal(ProposalTwoPanel, FProposalTwo, FProposalC2);
end;

end.