unit Unit2;

interface

uses
   FMX.Forms,FMX.Controls,FMX.StdCtrls,UProperties, FMX.Controls.Presentation,
  System.Classes, FMX.Types, FMX.Objects,System.SysUtils,Language,LoadSave;

type
  TForm2 = class(TForm)
    Image1   : TImage;
    LabelName: TLabel;
    LabelCost: TLabel;
    LabelRent: TLabel;
    LabelOwner: TLabel;
    LabelMortgaged: TLabel;
    ButtonBuy: TButton;
    ButtonSell: TButton;
    ButtonMortgage: TButton;
    ButtonUnmortgage: TButton;
    LabelMCost: TLabel;
    ButtonReturn: TButton;
    ButtonBuyHouse: TButton;
    ButtonSellHouse: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonReturnClick(Sender: TObject);
    procedure ButtonBuyClick(Sender: TObject);
    procedure ButtonMortgageClick(Sender: TObject);
    procedure ButtonUnmortgageClick(Sender: TObject);
    procedure ButtonSellClick(Sender: TObject);
    procedure ButtonBuyHouseClick(Sender: TObject);
    procedure ButtonSellHouseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowPropertyInfo(const P: TProperty);
  end;

var
  Form2: TForm2;
  //Prop : ^TProperty;

implementation

{$R *.fmx}

procedure TForm2.ButtonBuyClick(Sender: TObject);
begin
  if Banks[0]>=Properties[HumanIndex].Cost then
    begin
      Buy(0,HumanIndex);
      ShowPropertyInfo(Properties[HumanIndex]);
      //ButtonBuy.Visible := False;
      //ButtonMortgage.Visible := True;
    end;
end;

procedure TForm2.ButtonBuyHouseClick(Sender: TObject);
begin
  BuyHouse(0,HumanIndex);
  ShowPropertyInfo(Properties[HumanIndex]);
end;

procedure TForm2.ButtonMortgageClick(Sender: TObject);
begin
  Mortage(0,HumanIndex);
  ShowPropertyInfo(Properties[HumanIndex]);
end;

procedure TForm2.ButtonReturnClick(Sender: TObject);
begin
 Close;
end;

procedure TForm2.ButtonSellClick(Sender: TObject);
begin
 Sell(0,HumanIndex);
 Close;
end;

procedure TForm2.ButtonSellHouseClick(Sender: TObject);
begin
  SellHouse(0,HumanIndex);
  ShowPropertyInfo(Properties[HumanIndex]);
end;

procedure TForm2.ButtonUnmortgageClick(Sender: TObject);
begin
  UnMortage(0,HumanIndex);
  ShowPropertyInfo(Properties[HumanIndex]);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  LabelMortgaged.Text := CurrentLanguage.GetGuiString('Mortgaged')+'!';
  ButtonBuy.Text := CurrentLanguage.GetGuiString('Buy');
  ButtonSell.Text := CurrentLanguage.GetGuiString('Sell');
  ButtonMortgage.Text := CurrentLanguage.GetGuiString('Mortgage');
  ButtonUnmortgage.Text := CurrentLanguage.GetGuiString('Unmortgage');
  ButtonReturn.Text := CurrentLanguage.GetGuiString('Return');
  ButtonBuyHouse.Text := CurrentLanguage.GetGuiString('BuyHouse');
  ButtonSellHouse.Text := CurrentLanguage.GetGuiString('SellHouse');
  {$IFDEF ANDROID}
  LabelName.Font.Size := 13;
  LabelCost.Font.Size := 13;
  LabelRent.Font.Size := 13;
  LabelOwner.Font.Size := 13;
  LabelMortgaged.Font.Size := 13;
  LabelMCost.Font.Size := 13;
  LabelName.Width := ClientWidth-LabelName.Position.X-10;
  ButtonBuy.Position.X := LabelName.Position.X;
  ButtonMortgage.Position.X := LabelName.Position.X;
  ButtonBuyHouse.Position.X := LabelName.Position.X;
  ButtonBuy.Width := 120;
  ButtonMortgage.Width := ButtonBuy.Width;
  ButtonBuyHouse.Width := ButtonBuy.Width;
  ButtonSell.Width := ButtonBuy.Width;
  ButtonUnMortgage.Width := ButtonBuy.Width;
  ButtonSellHouse.Width := ButtonBuy.Width;
  ButtonSell.Position.X := LabelName.Position.X+ButtonBuy.Width+10;
  ButtonUnMortgage.Position.X := ButtonSell.Position.X;
  ButtonSellHouse.Position.X := ButtonSell.Position.X;
  ButtonReturn.Position.X := LabelName.Position.X;
  ButtonReturn.Width := 2*ButtonBuy.Width+10;

  {$ENDIF}
  //ShowPropertyInfo(Properties[HumanIndex]);
end;

procedure TForm2.ShowPropertyInfo(const P: TProperty);
var I:Integer;
begin
  ButtonBuy.Visible := False;
  ButtonSell.Visible := False;
  ButtonMortgage.Visible := False;
  ButtonUnMortgage.Visible := False;
  ButtonBuyHouse.Visible := False;
  ButtonSellHouse.Visible := False;
  LabelName.Text := {'Name: '}CurrentLanguage.GetGuiString('Name')+': ' + P.Name;
  LabelCost.Text := {'Cost: '}CurrentLanguage.GetGuiString('Cost') +': ' + P.Cost.ToString +'$';
  LabelRent.Text := {'Rent: '}CurrentLanguage.GetGuiString('Rent') +': ' + GetRentString(HumanIndex);
  LabelMCost.Text := {'Mortage cost: '} CurrentLanguage.GetGuiString('Mortgagecost') +': '+IntToStr(P.Cost div 2)+'$';
  if P.Owner=0 then
    begin
      LabelOwner.Text := CurrentLanguage.GetGuiString('No owner');//'No owner';
      if Banks[0]>=P.Cost then ButtonBuy.Visible := True;
    end
  else
   begin
     LabelOwner.Text := 'Owner: Player ' + IntToStr(P.Owner);
     case P.Owner of
       1: LabelOwner.Text := CurrentLanguage.GetGuiString('Owner') +': ' + CurrentLanguage.GetGuiString('Player1');
       2: LabelOwner.Text := CurrentLanguage.GetGuiString('Owner') +': ' + CurrentLanguage.GetGuiString('Player2');
     end;
     if P.Owner=1 then
       begin
         ButtonSell.Visible:= True;
         if P.Mortage then
          if Banks[0]>=Round(P.Cost*0.55) then ButtonUnMortgage.Visible:= True
          else
         else
           if ((P.RentState<2) or (P.PropType>0)) then ButtonMortgage.Visible := True;
         if (P.RentState>0) and (P.RentState<6) and (P.RentState=MinRentState(HumanIndex))
                            and (Banks[0]>=P.HouseCost) then ButtonBuyHouse.Visible := True;
         if (P.RentState>1) and (P.RentState=MaxRentState(HumanIndex)) then ButtonSellHouse.Visible := True;
       end;
   end;
  LabelMortgaged.Visible := P.Mortage;
  Image1.Bitmap.LoadFromFile(GetPath+'images/'+IntToStr(FindCardByIndex(HumanIndex)+2)+'.PNG');
  Image1.Bitmap.Rotate(GetRotateAngle(HumanIndex));
  //for I := 0 to 39 do
   // if PropIndex[i]=HumanIndex then  Image1.Picture.LoadFromFile('./images/'+IntToStr(i+2)+'.PNG');

  //Prop := @P;
end;

end.
