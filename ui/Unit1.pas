unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation,Unit2, Unit3, UMGame,
  UProperties, Ai,CardChangeProposal,LoadSave,Language,System.Threading;


const
  CenterSize = 450;
  CardHeight = 80;
  CardWidth = 50;

type
  TCardType = (ctSquare, ctRectangleHorizontal, ctRectangleVertical);
  T27Images = Array[0..27] of  FMX.Objects.TImage;
  T41Images =Array[1..41] of TImage;
  THouseImages = Array[0..21,0..4] of TImage;

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    LabelBank1: TLabel;
    LabelBank2: TLabel;
    Chip1: TImage;
    Chip2: TImage;
    Button2: TButton;
    Label5: TLabel;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CardImagesClick(Sender: TObject);
   // procedure Image7Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Form2Close(Sender:TObject; var Action:TCloseAction);
  private

  public
    { Public declarations }
    BoardImg : T41Images;
    CardsImages : T27Images;
    HouseImages : THouseImages;
    InterruptFlag : Byte;
    function Scale(A:Integer):Integer;
    function GetCardType(Position: Integer): TCardType;
    function GetCardPosition(Position,Number: Integer): TPoint;
    procedure RepositionChips;
    //procedure HumanChange;
    //procedure BotChange;
    procedure Change(Player:Byte);
    procedure PickProrerties(Index:Byte);
    procedure PickChance(PIndex:Byte);
    procedure Refresh;
    procedure CreateMainImages(var Images: T41Images; var Etalon: TImage; Index: Integer);
    procedure CreateImages(var Images: T27Images; var Etalon: TImage; Index: Integer);
    procedure CreateOneImage(var Image: TImage; var Etalon: TImage;Index: Integer;Filename:String);
    procedure CreateHouseImages(var Images: THouseImages; var Etalon: TImage; Index: Integer);
    //function ScaleY(A:Word):Word;
  end;
var
  Form1: TForm1;
  ChipSize :Byte = 40;
implementation

{$R *.fmx}

function TForm1.Scale;
begin
  result := Round(A*ClientHeight/610);
end;

procedure TForm1.RepositionChips;
Var A : TPoint;
begin
  A := GetCardPosition(MGame.getPlayers.First.GetLocation.getIndex,0);
  Chip1.Position.Y := A.Y;
  Chip1.Position.X := A.X;
  A := GetCardPosition(MGame.getPlayers.Last.GetLocation.getIndex,1);
  Chip2.Position.Y := A.Y;
  Chip2.Position.X := A.X;
end;

procedure TForm1.Change(Player: Byte);
var
PIndex,Pos:Integer;
NextTurn:Boolean;
begin

  Pos := MGame.getPlayers.Items[Player].GetLocation.getIndex;
   if InterruptFlag=0 then
    begin
  if MGame.getPlayers.Items[Player].JailFlag=1 then
    begin
      MGame.getPlayers.Items[Player].JailFlag := 0;
      Banks[Player] := Banks[Player] - 50;
    end;
  TestOldPos(Player,Pos);
    end;
  PIndex := PropIndex[Pos];

  case PIndex of
    0..27:
      if Player=0 then
        begin
          if InterruptFlag=0 then
            begin
          if Properties[PIndex].Owner=0 then
            begin
              PickProrerties(PIndex);  //Два раза должно быть,  ибо владелец меняется
              if InterruptFlag>0 then exit;
            end
                                        else PayOwner(Player,Pindex);
            end;
          if Properties[PIndex].Owner=0 then AiGetCard(PIndex);
        end
      else
        begin
          if Properties[PIndex].Owner=0 then AiGetCard(PIndex)
                                        else PayOwner(Player,Pindex);
          if Properties[PIndex].Owner=0 then PickProrerties(PIndex);
        end;
    34 : WorkWithField(Player,Pindex);
    35..36 :
      begin
        NextTurn := WorkWithField(Player,Pindex);
        if Player=0 then PickChance(Pindex);
        if NextTurn then Change(Player);
      end;
    37..38: WorkWithField(Player,Pindex);
  end;
 if (Banks[1]>0) then
   begin
     AiBuildHotels;  //+Unmortage
     AiUnMortage;
   end
 else AIAntiBankrupt;
 if (Banks[1]<0) then Label5.Visible := True;
 if AiProposal then
  begin
    if CardChangeProposalForm= nil then CardChangeProposalForm := TCardChangeProposalForm.Create(Self);
    CardChangeProposalForm.SetProposals(ProrosalHuman,ProrosalAI,ProposalPay,ProposalPay2);
    {$IFDEF ANDROID}
     CardChangeProposalForm.Show;
     if CardChangeProposalForm.IsCancel then ProposalLag:=4;
   {$ELSE}
     if CardChangeProposalForm.ShowModal=mrCancel then ProposalLag:=4;
   {$ENDIF}

  end;
 InterruptFlag:=0;
end;




procedure TForm1.Button2Click(Sender: TObject);
begin
  InitializeProperties;
  Button1.Enabled := True;
  Label5.Visible := False;
  //SetLength(P1Cards,0)
  Mgame.getPlayers[0].SetLocation(0);
  Mgame.getPlayers[1].SetLocation(0);
  Mgame.getPlayers[0].JailFlag := 0;
  Mgame.getPlayers[1].JailFlag := 0;
  RepositionChips;
  Refresh;
end;

procedure TForm1.CardImagesClick(Sender: TObject);
var i:Integer;
begin
  for i := Low(CardsImages) to High(CardsImages) do
   if Sender=CardsImages[i] then break;
  if i<=High(CardsImages) then
    begin
      PickProrerties(i);
      if (Banks[0]<0) or (Banks[1]<0) then Button1.Enabled := False
                                      else Button1.Enabled := True;
      InterruptFlag:=0;
      Refresh;
    end;
end;

procedure TForm1.PickChance(PIndex: Byte);
begin
  if Form3=nil then  Form3:=TForm3.Create(nil);
  Form3.Memo1.Lines[0] := '';
  if Form3.Memo1.Lines.Count>1 then  Form3.Memo1.Lines[1] := '';

  if Pindex=35 then
    begin
      Form3.Image1.Bitmap.LoadFromFile( GetPath+'images/4.PNG');
      Form3.Memo1.Lines[0] := CommunityChestCards[Random15];
    end
   else
     begin
       Form3.Image1.Bitmap.LoadFromFile(GetPath+'images/9.PNG');
       Form3.Memo1.Lines[0] := ChanceCards[Random15];
     end;

  {$IFDEF ANDROID}
      Form3.Show;
   {$ELSE}
     Form3.ShowModal;
   {$ENDIF}
end;



procedure TForm1.PickProrerties(Index: Byte);
begin
    HumanIndex := Index;
    if Form2=nil then  Form2:=TForm2.Create(nil);
    Form2.ShowPropertyInfo(Properties[Index]);

  {$IFDEF ANDROID}
      Form2.Show;
      InterruptFlag := 1;
      Form2.OnClose := Form2Close;
   {$ELSE}
     Form2.ShowModal;
   {$ENDIF}


 
  //if Properties[Index].Owner=0 then    //Покупаем ботом
end;

procedure TForm1.Refresh;
var I,j:Integer;
begin
  LabelBank1.Text := IntToStr(Banks[0]) + '$';
  LabelBank2.Text := IntToStr(Banks[1]) + '$';
  for I :=0 to 27 do CardsImages[i].Visible := False;
  for i := 0 to 4 do
    for j := 0 to 21 do
       HouseImages[j,i].Visible := False;


  for I := Low(P1Cards) to High(P1Cards) do
   begin
     if i<10 then
       begin
         CardsImages[P1Cards[i]].Position.X :=  Label3.Position.X+i*Scale(46);
         CardsImages[P1Cards[i]].Position.Y := LabelBank1.Position.Y+Scale(25);
       end
     else
       begin
         CardsImages[P1Cards[i]].Position.X :=  Label3.Position.X+(i-10)*Scale(46);
         CardsImages[P1Cards[i]].Position.Y := LabelBank1.Position.Y+Scale(95);
       end;
     CardsImages[P1Cards[i]].Visible := True;
     if P1Cards[i]>21 then continue;
     for j := 0 to 4 do  HouseImages[P1Cards[i],j].Position.X := CardsImages[P1Cards[i]].Position.X  +Scale(12);
     for j := 0 to 3 do  HouseImages[P1Cards[i],j].Position.Y := CardsImages[P1Cards[i]].Position.Y +Scale(17)+Scale(9*j);
     HouseImages[P1Cards[i],4].Position.Y := CardsImages[P1Cards[i]].Position.Y +Scale(17);
     if (Properties[P1Cards[i]].RentState>1) and (Properties[P1Cards[i]].RentState<6) then
       for j := 2 to Properties[P1Cards[i]].RentState do
         HouseImages[P1Cards[i],j-2].Visible := True;
     if Properties[P1Cards[i]].RentState>5 then HouseImages[P1Cards[i],4].Visible := True;
   end;
  for I := Low(P2Cards) to High(P2Cards) do
   begin
     if i<10 then
       begin
         CardsImages[P2Cards[i]].Position.X :=  Label4.Position.X+i*Scale(46);
         CardsImages[P2Cards[i]].Position.Y := LabelBank2.Position.Y+Scale(25);
       end
     else
       begin
         CardsImages[P2Cards[i]].Position.X :=  Label4.Position.X+(i-10)*Scale(46);
         CardsImages[P2Cards[i]].Position.Y := LabelBank2.Position.Y+Scale(95);
       end;
     CardsImages[P2Cards[i]].Visible := True;
     if P2Cards[i]>21 then continue;
     for j := 0 to 4 do  HouseImages[P2Cards[i],j].Position.X := CardsImages[P2Cards[i]].Position.X  +Scale(12);
     for j := 0 to 3 do  HouseImages[P2Cards[i],j].Position.Y := CardsImages[P2Cards[i]].Position.Y +Scale(17)+Scale(9*j);

     HouseImages[P2Cards[i],4].Position.Y := CardsImages[P2Cards[i]].Position.Y +Scale(17);

     if (Properties[P2Cards[i]].RentState>1) and (Properties[P2Cards[i]].RentState<6) then
       for j := 2 to Properties[P2Cards[i]].RentState do
         HouseImages[P2Cards[i],j-2].Visible := True;
     if Properties[P2Cards[i]].RentState>5 then HouseImages[P2Cards[i],4].Visible := True;
   end;
end;


procedure TForm1.Button1Click(Sender: TObject);
//var i:Integer;
begin
  if InterruptFlag=0 then MGame.playRound;
  //TTask.Run(procedure
  //begin
  for var I := 0 to Nbots do
   begin
     Change(i);
     if InterruptFlag>0 then exit;
   end;
  //Label1.Text := MGame.getPlayers.First.getName + ' in the ' + MGame.getPlayers.First.GetLocation.getName;
  //Label2.Text := MGame.getPlayers.Last.getName + ' in the  ' + MGame.getPlayers.Last.GetLocation.getName;
  RepositionChips; //TThread.Synchronize( nil,RepositionChips);
  if (Banks[0]<0) or (Banks[1]<0) then Button1.Enabled := False
                                  else Button1.Enabled := True;
  //for .. if    Banks[i]<0    //Выполнить антибанротство.

  //HumanChange;
  //BotChange;
  Refresh;//TThread.Synchronize(nil, Refresh);
  SaveGameState('game.sav');

 //if AIProposal then Formxxx.ShowModal;
 // end);
end;
procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  InterruptFlag :=0;
  CreateLog('Log.txt');
  WriteTolog('Start Logging');
  if GetOSLangID='ru' then CurrentLanguage := TLanguage.Create(7)
                      else CurrentLanguage := TLanguage.Create(1);
  WriteTolog('Language loaded');
  MGame := TMGame.create;
  CreateMainImages(BoardImg,Image1,10);
  WriteTolog('Main images loaded');
  Label3.Text := CurrentLanguage.GetGuiString('Player1');
  Label4.Text := CurrentLanguage.GetGuiString('Player2');
  Label5.Text := CurrentLanguage.GetGuiString('Victory');
  Button2.Text := CurrentLanguage.GetGuiString('NewGame');


   for I := 1 to 41 do
    begin
     //BoardImg[i].Picture.LoadFromFile('./images/'+IntToStr(i)+'.PNG');
     BoardImg[i].WrapMode:=TImageWrapMode.Stretch;
     BoardImg[i].Visible := True;
     BoardImg[i].SendToBack;
     //BoardImg[i].Stretch := True;
    end;
  //RegisterClass(TImage);

  CreateImages(CardsImages,BoardImg[32],100);
  WriteTolog('Board images loaded');
  CreateHouseImages(HouseImages,BoardImg[32],200);
  WriteTolog('House images loaded');
  InitializeProperties; //TO new Game + SetPosition(00)
  LoadGameState('game.sav');
  WriteTolog('Loaded game state');
end;

procedure TForm1.FormResize(Sender: TObject);
var
  I,j: Integer;
begin
  BoardImg[22].Position.X := 0;
  BoardImg[22].Width := Scale(CardHeight);
  BoardImg[23].Position.X := Scale(CardHeight);
  for I := 22 to 32 do
    begin
      BoardImg[i].Position.Y := 0;
      BoardImg[i].Height:= Scale(CardHeight);
      if i>23 then BoardImg[i].Position.X := Scale(CardWidth)*(i-23)+BoardImg[23].Position.X;
      if i>22 then BoardImg[i].Width := Scale(CardWidth);
    end;
  BoardImg[32].Width := Scale(CardHeight);
  for I := 33 to 41 do
    begin
      BoardImg[i].Position.Y := BoardImg[i-1].Position.Y+BoardImg[i-1].Height;
      BoardImg[i].Position.X := BoardImg[32].Position.X;
      BoardImg[i].Width := BoardImg[32].Width;
      BoardImg[i].Height := Scale(CardWidth);
    end;
  BoardImg[2].Position.Y := BoardImg[41].Position.Y + BoardImg[41].Height;
  BoardImg[2].Position.X := BoardImg[32].Position.X;
  BoardImg[2].Width := BoardImg[32].Width;
  BoardImg[2].Height := BoardImg[32].Height;
  BoardImg[1].Position.Y := BoardImg[22].Height;
  BoardImg[1].Position.X := BoardImg[22].Width;
  BoardImg[1].Width := BoardImg[32].Position.X-BoardImg[1].Position.X;
  BoardImg[1].Height := BoardImg[2].Position.Y-BoardImg[1].Position.Y;
  for I := 3 to 12 do
    begin
      BoardImg[i].Position.Y := BoardImg[2].Position.Y;
      BoardImg[i].Width := Scale(CardWidth);
      BoardImg[i].Height := Scale(CardHeight);
      BoardImg[i].Position.X := BoardImg[i-1].Position.X-BoardImg[i].Width;
    end;
  BoardImg[12].Position.X := 0;
  BoardImg[12].Width := Scale(CardHeight);
  for I := 13 to 21 do
    begin
      BoardImg[i].Position.X := 0;
      BoardImg[i].Width := Scale(CardHeight);
      BoardImg[i].Height := Scale(CardWidth);
      BoardImg[i].Position.Y := BoardImg[i-1].Position.Y - BoardImg[i].Height;
    end;
  Button1.Height := Scale(CardHeight);
  Button2.Height := Scale(CardHeight)*2/3;
  Button1.Position.X := BoardImg[32].Position.X + Scale(CardHeight+10);
  Button2.Position.X := Button1.Position.X ;
  Label3.Position.X := Button1.Position.X ;
  Label4.Position.X := Button1.Position.X ;
  LabelBank1.Position.X := Label4.Position.X + Label4.Width + Scale(3);
  LabelBank2.Position.X := LabelBank1.Position.X;
  Label3.Position.Y := Scale(21) + Button1.Height;
  LabelBank1.Position.Y := Label3.Position.Y;
  Label4.Position.Y := Label3.Position.Y + Scale(184);
  LabelBank2.Position.Y := Label4.Position.Y;
  Button2.Position.Y := Label4.Position.Y + Scale(184);
  Label5.Position.X := Button1.Position.X + Button1.Width + Scale(10);
  Label5.Position.Y := Button1.Position.Y;
  for i := 0 to 27 do
    begin
      CardsImages[i].WrapMode := TImageWrapMode.Stretch;
      CardsImages[i].Width := Scale(40);
      CardsImages[i].Height := Scale(65);
    end;
  for I := 0 to 4 do
    for j := 0 to 21 do
      begin
        HouseImages[j,i].Width := Scale(17);
        HouseImages[j,i].Height := Scale(17);
      end;
  ChipSize := Scale(35);
  Chip1.Height := ChipSize;
  Chip2.Height := ChipSize;
  Chip1.Width := ChipSize;
  Chip2.Width := ChipSize;
  Label3.Font.Size := Scale(20);
  Label4.Font.Size := Scale(20);
  Label5.Font.Size := Scale(40);
  LabelBank1.Font.Size := Scale(20);
  LabelBank2.Font.Size := Scale(20);
  Refresh;
  RepositionChips;
  //Image1.To
   //CardHeight
end;

function TForm1.GetCardType(Position: Integer): TCardType;
begin
  Result := ctSquare;
  if (Position mod 10 = 0) then
    Result := ctSquare
  else
   case Position of
    1..9: Result := ctRectangleHorizontal;
    11..19: Result := ctRectangleVertical;
    21..29: Result := ctRectangleHorizontal;
    31..39: Result := ctRectangleVertical;
   end;
end;

procedure TForm1.Image12Click(Sender: TObject);
begin
 //Если в тюрьме - открывать окно тюрьмы
end;

function TForm1.GetCardPosition;
var
  _CardWidth, _CardHeight: Integer;
  xOffset, yOffset: Integer;
  CardType: TCardType;
begin
  CardType := GetCardType(Position);
  case CardType of
    ctSquare:
    begin
      _CardWidth := Scale(CardHeight);
      _CardHeight := Scale(CardHeight);
    end;
    ctRectangleHorizontal:
    begin
      _CardWidth := Scale(CardWidth);
      _CardHeight := Scale(CardHeight);
    end;
    ctRectangleVertical:
    begin
      _CardWidth := Scale(CardHeight);
      _CardHeight :=Scale(CardWidth);
    end;
  end;
  if (Position >= 0) and (Position < 10) then
  begin
    xOffset := Scale(CardHeight)+(9-Position) * Scale(CardWidth);
    yOffset := Round(ChipSize*(Number-0.5))+Scale(CardHeight)+9*Scale(CardWidth);
    Result := Point(xOffset + (_CardWidth-ChipSize) div 2, yOffset + (_CardHeight-ChipSize) div 2);
  end
  else if (Position >= 10) and (Position < 21) then
  begin
    xOffset := Round(ChipSize*(Number-0.5));
    yOffset := Scale(CardHeight)+(19-Position) * Scale(CardWidth);
    Result := Point(xOffset + (_CardWidth-ChipSize) div 2, yOffset + (_CardHeight-ChipSize) div 2);
  end
  else if (Position >= 20) and (Position < 30) then
  begin
    xOffset := Scale(CardHeight)+ (Position-21)*Scale(CardWidth);
    yOffset := Round(ChipSize*(Number-0.5));
    Result := Point(xOffset + (_CardWidth-ChipSize) div 2, yOffset + (_CardHeight-ChipSize) div 2);
  end
  else if (Position >= 30) and (Position < 40) then
  begin
    xOffset := Round(ChipSize*(Number-0.5))+Scale(CardHeight)+9*Scale(CardWidth);
    yOffset := (Position - 31)  * Scale(CardWidth) +Scale(CardHeight);
    Result := Point(xOffset + (_CardWidth-ChipSize) div 2, yOffset + (_CardHeight-ChipSize) div 2);
  end;
end;

procedure TForm1.CreateOneImage(var Image: TImage; var Etalon: TImage; Index: Integer; Filename: string);
var
ms: TMemoryStream;
component: TComponent;
begin
      Image := Etalon.Clone(nil) as TImage;
      Image.Name := 'Image'+IntToStr(Index);
      Image.Parent := Self;
      Image.Visible :=False;
     // Image.Proportional := True;
      Image.WrapMode := TImageWrapMode.Fit;//TImageWrapMode.Stretch;
      //Image.Stretch := True;
      Image.Bitmap.LoadFromFile(Filename);
      Image.OnClick := CardImagesClick;
end;

procedure TForm1.CreateMainImages;
var

i : Integer;
begin
  // Etalon.Parent := Self;
  for i := 1 to 41 do CreateOneImage(Images[i],Etalon,Index+i,GetPath+'images/'+IntToStr(i)+'.PNG');
end;

procedure TForm1.CreateImages(var Images: T27Images; var Etalon: TImage; Index: Integer);
var

i : Integer;
begin
  // Etalon.Parent := Self;
  for i := 0 to 27 do CreateOneImage(Images[i],Etalon,Index+i,GetPath+'images/'+IntToStr(FindCardByIndex(i)+2)+'.PNG');
  for I := 5 to 27 do Images[i].Bitmap.Rotate(GetRotateAngle(i));

end;

procedure TForm1.CreateHouseImages(var Images: THouseImages; var Etalon: TImage; Index: Integer);
var

i,j : Integer;
begin
  for I := 0 to 4 do
    for j := 0 to 21 do
      begin
        if i<4 then  CreateOneImage(Images[j,i],Etalon,Index+i,GetPath+'images/house.png')
               else  CreateOneImage(Images[j,i],Etalon,Index+i,GetPath+'images/hotel.png');
        Images[j,i].Width := Scale(17);
        Images[j,i].Height := Scale(17);
        Images[j,i].OnClick := nil;
      end;


end;


procedure TForm1.Form2Close;
begin
  if InterruptFlag>0 then Button1Click(Sender)
                     else Refresh;
end;






end.



