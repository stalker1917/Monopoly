unit UProperties;

interface
uses UMGame,Math,UDie,System.SysUtils,Language;

const PropIndex : array[0..39] of Integer = (31,0,35,1,37,24 ,2,36,3,4,
32,5,22,6,7,25,8,35,9,10,
33,11,36,12,13,26,14,15,23,16,
34,17,18,35,19,27,36,20,38,21);

//31 - Start
//32 - Jail
//33 - Rest
//34 - GoTo Jail
//35 - CommunityChest
//36 - ?(Chance)
//37 - Tax 200
//38 - Tax 100
NBots = 1;
ChanceCardCount = 16;
CommunityChestCardCount = 16;

type
  TProperty = record
    Name: string;
    Cost: Integer;
    Rent: array[0..5] of Integer; // Rent values for 0 to 4 houses and a hotel
    FullStreetRent: Integer;
    HouseCost: Integer;
    HotelCost: Integer;
    PropType : Byte; //0 - Common 1- Utility  2 - RailRoad
    Owner:Byte;    //0 -No Owner 1-Player  2-Computer
    Mortage :Boolean;
    RentState :Byte;  //0 - Standart //1- full street //2 - one house...
  end;
  TChangeState = record
    YesChange : Boolean;
    ChangeArr : Array[0..2] of Byte;
    P1,P2 : Byte;
  end;


var
Properties: array[0..27] of TProperty; // Array to hold the properties
P1Cards : TArray<Byte>;
P2Cards : TArray<Byte>;
Banks : array[0..NBots] of Integer;
JailPass : array[0..NBots] of Integer;
HumanIndex : Byte;
OldPos : array[0..NBots] of Byte;
ChanceCards: array[0..ChanceCardCount - 1] of string;
CommunityChestCards: array[0..CommunityChestCardCount - 1] of string;
Random15:Byte;
MGame: TMGame;
TwiceRentFlag : Boolean=False;



procedure InitializeProperties;
procedure Buy(Player,Index:Byte);
procedure Sell(Player,Index:Byte);
procedure GetCard(Player,Index:Byte);
procedure InsertCard(Var A:TArray<Byte>;Index:Byte);
procedure DeleteCard(Player,Index:Byte);
procedure ChangeOwner(Player,Index:Byte);
procedure Mortage(Player,Index:Byte);
procedure UnMortage(Player,Index:Byte);
procedure BuyHouse(Player,Index:Byte);
procedure SellHouse(Player,Index:Byte);
function  FindCardByIndex(Index:Byte):Byte;
procedure TestOldPos(Player,Pos:Byte);
function  ImportantCard(Index,Owner:Byte):Boolean;
procedure SetResetRentState(Index,NewState:Byte);
function  MinRentState(Index:Byte):Byte;
function  MaxRentState(Index:Byte):Byte;
function  MinMaxRentState(Index:Byte;aMin:Boolean):Byte;
function  MinMax2(Index:Byte;aMin:Boolean):Byte;
function  MinMax3(Index:Byte;aMin:Boolean):Byte;
function  Min3Index(Index:Byte):Byte;
function  Max3Index(Index:Byte):Byte;
function  WorkWithField(Player,Index:Byte):Boolean;
procedure EveryPay(Player,Tax:Integer);
procedure Pay(Sender,Receiver,Money:Integer);
procedure PayOwner(Sender,Index:Integer);
function  CalcRent(Index:Byte):Integer;
function  GetRentString(Index:Byte):String;
procedure RepairHouse(Player:Byte;RentState:Byte;HouseCost:Byte;HotelCost:Byte);
function GetChangeState(Index:Byte):TChangeState;
function GetRotateAngle(Index:Byte):SmallInt;


implementation
procedure InitChanceCards;
begin
  ChanceCards[0] := CurrentLanguage.GetChance('CC0');//'Advance to Go (Collect $200)';
  ChanceCards[1] := CurrentLanguage.GetChance('CC1');//'Advance to Illinois Ave. If you pass Go, collect $200';
  ChanceCards[2] := CurrentLanguage.GetChance('CC2');//'Advance to St. Charles Place. If you pass Go, collect $200';
  ChanceCards[3] := CurrentLanguage.GetChance('CC3'); //'Advance token to the nearest Utility. If unowned, you may buy it. If owned, pay owner 10 times the dice roll.';
  ChanceCards[4] := CurrentLanguage.GetChance('CC4'); //'Advance token to the nearest Railroad. Pay twice the rent if owned. If unowned, you may buy it.';
  ChanceCards[5] := CurrentLanguage.GetChance('CC5'); //'Bank pays you dividend of $50';
  ChanceCards[6] := CurrentLanguage.GetChance('CC6'); //'Get out of Jail Free. This card may be kept until needed or sold.';
  ChanceCards[7] := CurrentLanguage.GetChance('CC7'); //'Go Back 3 Spaces';
  ChanceCards[8] := CurrentLanguage.GetChance('CC8'); //'Go to Jail. Go directly to Jail. Do not pass Go, do not collect $200';
  ChanceCards[9] := CurrentLanguage.GetChance('CC9'); //'Make general repairs on all your property. For each house pay $25. For each hotel $100.';
  ChanceCards[10] := CurrentLanguage.GetChance('CC10'); //'Pay poor tax of $15';
  ChanceCards[11] := CurrentLanguage.GetChance('CC11'); //'Take a trip to Reading Railroad. If you pass Go, collect $200';
  ChanceCards[12] := CurrentLanguage.GetChance('CC12'); //'Take a walk on the Boardwalk. Advance token to Boardwalk';
  ChanceCards[13] := CurrentLanguage.GetChance('CC13'); //'You have been elected Chairman of the Board. Pay each player $50';
  ChanceCards[14] := CurrentLanguage.GetChance('CC14'); //'Your building loan matures. Receive $150';
  ChanceCards[15] := CurrentLanguage.GetChance('CC15'); //'Advance token to the nearest Railroad. Pay twice the rent if owned. If unowned, you may buy it.';
end;


procedure InitCommunityChestCards;
begin
  CommunityChestCards[0] := CurrentLanguage.GetCommunity('CCC0');//'Advance to Go (Collect $200)';
  CommunityChestCards[1] := CurrentLanguage.GetCommunity('CCC1');//'Bank error in your favor. Collect $200';
  CommunityChestCards[2] := CurrentLanguage.GetCommunity('CCC2');//'Doctor’s fees. Pay $50';
  CommunityChestCards[3] := CurrentLanguage.GetCommunity('CCC3');//'From sale of stock you get $50';
  CommunityChestCards[4] := CurrentLanguage.GetCommunity('CCC4');//'Get Out of Jail Free. This card may be kept until needed or sold.';
  CommunityChestCards[5] := CurrentLanguage.GetCommunity('CCC5');//'Go to Jail. Go directly to jail. Do not pass Go. Do not collect $200.';
  CommunityChestCards[6] := CurrentLanguage.GetCommunity('CCC6');//'Grand Opera Night. Collect $50 from every player for opening night seats.';
  CommunityChestCards[7] := CurrentLanguage.GetCommunity('CCC7');//'Holiday Fund matures. Receive $100';
  CommunityChestCards[8] := CurrentLanguage.GetCommunity('CCC8');//'Income tax refund. Collect $20';
  CommunityChestCards[9] := CurrentLanguage.GetCommunity('CCC9');//'It is your birthday. Collect $10 from every player.';
  CommunityChestCards[10] := CurrentLanguage.GetCommunity('CCC10');//'Life insurance matures. Collect $100';
  CommunityChestCards[11] := CurrentLanguage.GetCommunity('CCC11');//'Hospital Fees. Pay $100';
  CommunityChestCards[12] := CurrentLanguage.GetCommunity('CCC12');//'School fees. Pay $50';
  CommunityChestCards[13] := CurrentLanguage.GetCommunity('CCC13');//'Receive $25 consultancy fee';
  CommunityChestCards[14] := CurrentLanguage.GetCommunity('CCC14');//'You are assessed for street repair. Pay $40 per house and $115 per hotel you own.';
  CommunityChestCards[15] := CurrentLanguage.GetCommunity('CCC15');//'You have won second prize in a beauty contest. Collect $10';
end;


procedure InitializeProperties;
var i:Integer;
begin
  Randomize;
  InitChanceCards;
  InitCommunityChestCards;
  Properties[0].Name := CurrentLanguage.GetProperties('P0');//'Mediterranean Avenue';
  Properties[0].Cost := 60;
  Properties[0].Rent[0] := 2;
  Properties[0].Rent[1] := 10;
  Properties[0].Rent[2] := 30;
  Properties[0].Rent[3] := 90;
  Properties[0].Rent[4] := 160;
  Properties[0].Rent[5] := 250; // Rent with hotel
  Properties[0].FullStreetRent := 4;
  Properties[0].HouseCost := 50;
  Properties[0].HotelCost := 50;


  Properties[1].Name := CurrentLanguage.GetProperties('P1');//'Baltic Avenue';
  Properties[1].Cost := 60;
  Properties[1].Rent[0] := 4;
  Properties[1].Rent[1] := 20;
  Properties[1].Rent[2] := 60;
  Properties[1].Rent[3] := 180;
  Properties[1].Rent[4] := 320;
  Properties[1].Rent[5] := 450; // Rent with hotel
  Properties[1].FullStreetRent := 8;
  Properties[1].HouseCost := 50;
  Properties[1].HotelCost := 50;

  Properties[2].Name :=  CurrentLanguage.GetProperties('P2');//'Oriental Avenue';
  Properties[2].Cost := 100;
  Properties[2].Rent[0] := 6;
  Properties[2].Rent[1] := 30;
  Properties[2].Rent[2] := 90;
  Properties[2].Rent[3] := 270;
  Properties[2].Rent[4] := 400;
  Properties[2].Rent[5] := 550; // Rent with hotel
  Properties[2].FullStreetRent := 12;
  Properties[2].HouseCost := 50;
  Properties[2].HotelCost := 50;

  Properties[3].Name :=  CurrentLanguage.GetProperties('P3');//'Vermont Avenue';
  Properties[3].Cost := 100;
  Properties[3].Rent[0] := 6;
  Properties[3].Rent[1] := 30;
  Properties[3].Rent[2] := 90;
  Properties[3].Rent[3] := 270;
  Properties[3].Rent[4] := 400;
  Properties[3].Rent[5] := 550; // Rent with hotel
  Properties[3].FullStreetRent := 12;
  Properties[3].HouseCost := 50;
  Properties[3].HotelCost := 50;

  Properties[4].Name :=  CurrentLanguage.GetProperties('P4'); //'Connecticut Avenue';
  Properties[4].Cost := 120;
  Properties[4].Rent[0] := 8;
  Properties[4].Rent[1] := 40;
  Properties[4].Rent[2] := 100;
  Properties[4].Rent[3] := 300;
  Properties[4].Rent[4] := 450;
  Properties[4].Rent[5] := 600; // Rent with hotel
  Properties[4].FullStreetRent := 16;
  Properties[4].HouseCost := 50;
  Properties[4].HotelCost := 50;

  Properties[5].Name :=  CurrentLanguage.GetProperties('P5');//'St. Charles Place';
  Properties[5].Cost := 140;
  Properties[5].Rent[0] := 10;
  Properties[5].Rent[1] := 50;
  Properties[5].Rent[2] := 150;
  Properties[5].Rent[3] := 450;
  Properties[5].Rent[4] := 625;
  Properties[5].Rent[5] := 750; // Rent with hotel
  Properties[5].FullStreetRent := 20;
  Properties[5].HouseCost := 100;
  Properties[5].HotelCost := 100;

  Properties[6].Name :=  CurrentLanguage.GetProperties('P6'); //'States Avenue';
  Properties[6].Cost := 140;
  Properties[6].Rent[0] := 10;
  Properties[6].Rent[1] := 50;
  Properties[6].Rent[2] := 150;
  Properties[6].Rent[3] := 450;
  Properties[6].Rent[4] := 625;
  Properties[6].Rent[5] := 750; // Rent with hotel
  Properties[6].FullStreetRent := 20;
  Properties[6].HouseCost := 100;
  Properties[6].HotelCost := 100;

  Properties[7].Name := CurrentLanguage.GetProperties('P7'); //'Virginia Avenue';
  Properties[7].Cost := 160;
  Properties[7].Rent[0] := 12;
  Properties[7].Rent[1] := 60;
  Properties[7].Rent[2] := 180;
  Properties[7].Rent[3] := 500;
  Properties[7].Rent[4] := 700;
  Properties[7].Rent[5] := 900; // Rent with hotel
  Properties[7].FullStreetRent := 24;
  Properties[7].HouseCost := 100;
  Properties[7].HotelCost := 100;

  Properties[8].Name :=  CurrentLanguage.GetProperties('P8');//'St. James Place';
  Properties[8].Cost := 180;
  Properties[8].Rent[0] := 14;
  Properties[8].Rent[1] := 70;
  Properties[8].Rent[2] := 200;
  Properties[8].Rent[3] := 550;
  Properties[8].Rent[4] := 750;
  Properties[8].Rent[5] := 950; // Rent with hotel
  Properties[8].FullStreetRent := 28;
  Properties[8].HouseCost := 100;
  Properties[8].HotelCost := 100;

  Properties[9].Name :=  CurrentLanguage.GetProperties('P9');//'Tennessee Avenue';
  Properties[9].Cost := 180;
  Properties[9].Rent[0] := 14;
  Properties[9].Rent[1] := 70;
  Properties[9].Rent[2] := 200;
  Properties[9].Rent[3] := 550;
  Properties[9].Rent[4] := 750;
  Properties[9].Rent[5] := 950; // Rent with hotel
  Properties[9].FullStreetRent := 28;
  Properties[9].HouseCost := 100;
  Properties[9].HotelCost := 100;

  Properties[10].Name :=  CurrentLanguage.GetProperties('P10');//'New York Avenue';
  Properties[10].Cost := 200;
  Properties[10].Rent[0] := 16;
  Properties[10].Rent[1] := 80;
  Properties[10].Rent[2] := 220;
  Properties[10].Rent[3] := 600;
  Properties[10].Rent[4] := 800;
  Properties[10].Rent[5] := 1000; // Rent with hotel
  Properties[10].FullStreetRent := 32;
  Properties[10].HouseCost := 100;
  Properties[10].HotelCost := 100;

  Properties[11].Name :=  CurrentLanguage.GetProperties('P11');//'Kentucky Avenue';
  Properties[11].Cost := 220;
  Properties[11].Rent[0] := 18;
  Properties[11].Rent[1] := 90;
  Properties[11].Rent[2] := 250;
  Properties[11].Rent[3] := 700;
  Properties[11].Rent[4] := 875;
  Properties[11].Rent[5] := 1050; // Rent with hotel
  Properties[11].FullStreetRent := 36;
  Properties[11].HouseCost := 150;
  Properties[11].HotelCost := 150;

  Properties[12].Name :=  CurrentLanguage.GetProperties('P12');//'Indiana Avenue';
  Properties[12].Cost := 220;
  Properties[12].Rent[0] := 18;
  Properties[12].Rent[1] := 90;
  Properties[12].Rent[2] := 250;
  Properties[12].Rent[3] := 700;
  Properties[12].Rent[4] := 875;
  Properties[12].Rent[5] := 1050; // Rent with hotel
  Properties[12].FullStreetRent := 36;
  Properties[12].HouseCost := 150;
  Properties[12].HotelCost := 150;

  Properties[13].Name := CurrentLanguage.GetProperties('P13'); //'Illinois Avenue';
  Properties[13].Cost := 240;
  Properties[13].Rent[0] := 20;
  Properties[13].Rent[1] := 100;
  Properties[13].Rent[2] := 300;
  Properties[13].Rent[3] := 750;
  Properties[13].Rent[4] := 925;
  Properties[13].Rent[5] := 1100; // Rent with hotel
  Properties[13].FullStreetRent := 40;
  Properties[13].HouseCost := 150;
  Properties[13].HotelCost := 150;

  Properties[14].Name :=  CurrentLanguage.GetProperties('P14');//'Atlantic Avenue';
  Properties[14].Cost := 260;
  Properties[14].Rent[0] := 22;
  Properties[14].Rent[1] := 110;
  Properties[14].Rent[2] := 330;
  Properties[14].Rent[3] := 800;
  Properties[14].Rent[4] := 975;
  Properties[14].Rent[5] := 1150; // Rent with hotel
  Properties[14].FullStreetRent := 44;
  Properties[14].HouseCost := 150;
  Properties[14].HotelCost := 150;

  Properties[15].Name :=  CurrentLanguage.GetProperties('P15');//'Ventnor Avenue';
  Properties[15].Cost := 260;
  Properties[15].Rent[0] := 22;
  Properties[15].Rent[1] := 110;
  Properties[15].Rent[2] := 330;
  Properties[15].Rent[3] := 800;
  Properties[15].Rent[4] := 975;
  Properties[15].Rent[5] := 1150; // Rent with hotel
  Properties[15].FullStreetRent := 44;
  Properties[15].HouseCost := 150;
  Properties[15].HotelCost := 150;

  Properties[16].Name :=  CurrentLanguage.GetProperties('P16');//'Marvin Gardens';
  Properties[16].Cost := 280;
  Properties[16].Rent[0] := 24;
  Properties[16].Rent[1] := 120;
  Properties[16].Rent[2] := 360;
  Properties[16].Rent[3] := 850;
  Properties[16].Rent[4] := 1025;
  Properties[16].Rent[5] := 1200; // Rent with hotel
  Properties[16].FullStreetRent := 48;
  Properties[16].HouseCost := 150;
  Properties[16].HotelCost := 150;

  Properties[17].Name :=  CurrentLanguage.GetProperties('P17');//'Pacific Avenue';
  Properties[17].Cost := 300;
  Properties[17].Rent[0] := 26;
  Properties[17].Rent[1] := 130;
  Properties[17].Rent[2] := 390;
  Properties[17].Rent[3] := 900;
  Properties[17].Rent[4] := 1100;
  Properties[17].Rent[5] := 1275; // Rent with hotel
  Properties[17].FullStreetRent := 52;
  Properties[17].HouseCost := 200;
  Properties[17].HotelCost := 200;

  Properties[18].Name :=  CurrentLanguage.GetProperties('P18');//'North Carolina Avenue';
  Properties[18].Cost := 300;
  Properties[18].Rent[0] := 26;
  Properties[18].Rent[1] := 130;
  Properties[18].Rent[2] := 390;
  Properties[18].Rent[3] := 900;
  Properties[18].Rent[4] := 1100;
  Properties[18].Rent[5] := 1275; // Rent with hotel
  Properties[18].FullStreetRent := 52;
  Properties[18].HouseCost := 200;
  Properties[18].HotelCost := 200;

  Properties[19].Name :=  CurrentLanguage.GetProperties('P19');//'Pennsylvania Avenue';
  Properties[19].Cost := 320;
  Properties[19].Rent[0] := 28;
  Properties[19].Rent[1] := 150;
  Properties[19].Rent[2] := 450;
  Properties[19].Rent[3] := 1000;
  Properties[19].Rent[4] := 1200;
  Properties[19].Rent[5] := 1400; // Rent with hotel
  Properties[19].FullStreetRent := 56;
  Properties[19].HouseCost := 200;
  Properties[19].HotelCost := 200;

  Properties[20].Name :=  CurrentLanguage.GetProperties('P20');//'Park Place';
  Properties[20].Cost := 350;
  Properties[20].Rent[0] := 35;
  Properties[20].Rent[1] := 175;
  Properties[20].Rent[2] := 500;
  Properties[20].Rent[3] := 1100;
  Properties[20].Rent[4] := 1300;
  Properties[20].Rent[5] := 1500; // Rent with hotel
  Properties[20].FullStreetRent := 70;
  Properties[20].HouseCost := 200;
  Properties[20].HotelCost := 200;

  Properties[21].Name := CurrentLanguage.GetProperties('P21');//'Boardwalk';
  Properties[21].Cost := 400;
  Properties[21].Rent[0] := 50;
  Properties[21].Rent[1] := 200;
  Properties[21].Rent[2] := 600;
  Properties[21].Rent[3] := 1400;
  Properties[21].Rent[4] := 1700;
  Properties[21].Rent[5] := 2000; // Rent with hotel
  Properties[21].FullStreetRent := 100;
  Properties[21].HouseCost := 200;
  Properties[21].HotelCost := 200;

  // Utility properties
  Properties[22].Name := CurrentLanguage.GetProperties('P22');//'Electric Company';
  Properties[22].Cost := 150;
  Properties[22].Rent[0] := 4; // Rent is variable, typically 4x dice roll if one utility owned
  Properties[22].Rent[1] := 10; // 10x dice roll if both utilities owned
  Properties[22].FullStreetRent := 0;
  Properties[22].HouseCost := 0;
  Properties[22].HotelCost := 0;
  Properties[22].PropType := 1;

  Properties[23].Name := CurrentLanguage.GetProperties('P23');//'Water Works';
  Properties[23].Cost := 150;
  Properties[23].Rent[0] := 4; // Rent is variable, typically 4x dice roll if one utility owned
  Properties[23].Rent[1] := 10; // 10x dice roll if both utilities owned
  Properties[23].FullStreetRent := 0;
  Properties[23].HouseCost := 0;
  Properties[23].HotelCost := 0;
  Properties[23].PropType := 1;

  // Railroad properties
  Properties[24].Name := CurrentLanguage.GetProperties('P24');//'Reading Railroad';
  Properties[24].Cost := 200;
  Properties[24].Rent[0] := 25;
  Properties[24].Rent[1] := 50;
  Properties[24].Rent[2] := 100;
  Properties[24].Rent[3] := 200;
  Properties[24].Rent[4] := 400; //If Pay Twice
  Properties[24].FullStreetRent := 0;
  Properties[24].HouseCost := 0;
  Properties[24].HotelCost := 0;

  Properties[25].Name := CurrentLanguage.GetProperties('P25');//'Pennsylvania Railroad';
  Properties[25].Cost := 200;
  Properties[25].Rent[0] := 25;
  Properties[25].Rent[1] := 50;
  Properties[25].Rent[2] := 100;
  Properties[25].Rent[3] := 200;
  Properties[25].FullStreetRent := 0;
  Properties[25].HouseCost := 0;
  Properties[25].HotelCost := 0;

  Properties[26].Name := CurrentLanguage.GetProperties('P26');//'B&O Railroad';
  Properties[26].Cost := 200;
  Properties[26].Rent[0] := 25;
  Properties[26].Rent[1] := 50;
  Properties[26].Rent[2] := 100;
  Properties[26].Rent[3] := 200;
  Properties[26].FullStreetRent := 0;
  Properties[26].HouseCost := 0;
  Properties[26].HotelCost := 0;

  Properties[27].Name :=CurrentLanguage.GetProperties('P27'); //'Short Line';
  Properties[27].Cost := 200;
  Properties[27].Rent[0] := 25;
  Properties[27].Rent[1] := 50;
  Properties[27].Rent[2] := 100;
  Properties[27].Rent[3] := 200;
  Properties[27].FullStreetRent := 0;
  Properties[27].HouseCost := 0;
  Properties[27].HotelCost := 0;

  for I := 0 to 21 do Properties[i].PropType := 0;
  for I := 24 to 27 do Properties[i].PropType := 2;
  for I := 0 to 27 do Properties[i].Owner := 0;
  for I := 0 to 27 do Properties[i].Mortage := False;
  for I := 0 to 27 do Properties[i].RentState := 0;

  SetLength(P1Cards,0);
  SetLength(P2Cards,0);
  for I := 0 to 1 do
    begin
      Banks[i] := 1500;
      JailPass[i] := 0;
      OldPos[i] := 0;
    end;

end;

procedure Buy;
begin
  Banks[Player] := Banks[Player]-Properties[Index].Cost;


  GetCard(Player,Index);

  //Сортировать массив
end;

procedure InsertCard;
var i,l,InsertIndex:Integer;
begin
 l:=Length(A);
 InsertIndex := l;
 for i := 0 to l-1 do
  begin
    if Index < A[i] then
    begin
      InsertIndex := i;
      Break;
    end;
  end;
 System.SetLength(A,l+1);
  // Shift elements to the right
  for i := l downto InsertIndex + 1 do
    A[i] := A[i - 1];

  // Insert new value
  A[InsertIndex] := Index;
end;

procedure GetCard;
begin
  //if Properties[Index].Owner =Player+1 then exit;
  if Player=0 then InsertCard(P1Cards,Index)//P1Cards := P1Cards + [Index]
              else InsertCard(P2Cards,Index);//P2Cards := P2Cards + [Index];
  Properties[Index].Owner :=Player+1;
  //if Index<24 then
  if ImportantCard(Index,Player+1) then  SetResetRentState(Index,1);
end;

procedure Sell;
begin
   if Properties[Index].Mortage then Unmortage(Player,Index);
   Banks[Player] := Banks[Player]+Properties[Index].Cost;
   DeleteCard(Player,Index);

   //Сортировать массив
end;

procedure DeleteCard;
var i:Integer;
begin
 // if Properties[Index].Owner =Player+1 then exit;
 if ImportantCard(Index,Player+1) then  SetResetRentState(Index,0); //До понижения надо убрать состояние ренты
  //P1Cards := P1Cards + [Index];
   if Player=0 then
     for I := Low(P1Cards) to High(P1Cards) do
       if P1Cards[i]=Index then
        begin
          Delete(P1Cards,i,1);
          break;
        end
       else
   else
     for I := Low(P2Cards) to High(P2Cards) do
       if P2Cards[i]=Index then
        begin
          Delete(P2Cards,i,1);
          break;
        end;
   Properties[Index].Owner :=0;
end;

procedure ChangeOwner;
var OldPlayer:Byte;
begin
  OldPlayer :=Properties[Index].Owner - 1;
  if (OldPlayer>=0) and (OldPlayer<>Player) then
    begin
      DeleteCard(OldPlayer,Index);
      GetCard(Player,Index);
    end;
end;

procedure Mortage;
begin
  Banks[Player] := Banks[Player]+Properties[Index].Cost div 2;
  //P1Cards := P1Cards + [Index];
  Properties[Index].Mortage := True;
  if (ImportantCard(Index,Player+1) {and (Properties[Index].PropType<2)}) then  SetResetRentState(Index,0);   //Может так внаглую и не сработает.

end;

procedure UnMortage;
begin
  Banks[Player] := Banks[Player]-Round(Properties[Index].Cost*0.55);
  //P1Cards := P1Cards + [Index];
  Properties[Index].Mortage := False;
  if (ImportantCard(Index,Player+1) {and (Properties[Index].PropType<2)}) then  SetResetRentState(Index,1);

  end;

function FindCardByIndex;
begin
  for result := 0 to 39 do  if PropIndex[result]=Index then break;
end;

procedure TestOldPos;
begin
  if Pos < OldPos[Player] then Banks[Player] := Banks[Player] + 200;
  OldPos[Player] := Pos;
end;

function ImportantCard;
begin
  case Index of
    //First
    0,1: result := Properties[(Index+1) mod 2].Owner = Owner;
    2,3,4: result := (Properties[(Index-1) mod 3+2].Owner = Owner) and (Properties[(Index) mod 3+2].Owner = Owner);
    //Second
    5,6,7: result := (Properties[(Index-4) mod 3+5].Owner = Owner) and (Properties[(Index-3) mod 3+5].Owner = Owner);
    8,9,10:  result := (Properties[(Index-7) mod 3+8].Owner = Owner) and (Properties[(Index-6) mod 3+8].Owner = Owner);
    //Third
    11,12,13: result := (Properties[(Index-10) mod 3+11].Owner = Owner) and (Properties[(Index-9) mod 3+11].Owner = Owner);
    14,15,16: result := (Properties[(Index-14) mod 3+14].Owner = Owner) and (Properties[(Index-12) mod 3+14].Owner = Owner);
    //Fourth
    17,18,19: result := (Properties[(Index-16) mod 3+17].Owner = Owner) and (Properties[(Index-15) mod 3+17].Owner = Owner);
    20,21: result := Properties[(Index-19) mod 2 + 20].Owner = Owner;
    //Commumal
    22,23: result := Properties[(Index-21) mod 2 + 22].Owner = Owner;
    //Railroad
    24,25,26,27: result := (Properties[(Index-23) mod 3+24].Owner = Owner) or (Properties[(Index-22) mod 3+24].Owner = Owner) or (Properties[(Index-21) mod 3+24].Owner = Owner);
  end;
end;

procedure SetResetRentState;
var i:Integer;
begin
  case Index of
    //First
    0,1: for i := 0 to 1 do Properties[i].RentState := NewState;
    2,3,4: for i := 2 to 4 do Properties[i].RentState := NewState;
    //Second
    5,6,7: for i := 5 to 7 do Properties[i].RentState := NewState;
    8,9,10: for i := 8 to 10 do Properties[i].RentState := NewState;
    //Third
    11,12,13: for i := 11 to 13 do Properties[i].RentState := NewState;
    14,15,16: for i := 14 to 16 do Properties[i].RentState := NewState;
    //Fourth
    17,18,19: for i := 17 to 19 do Properties[i].RentState := NewState;
    20,21: for i := 20 to 21 do Properties[i].RentState := NewState;
    //Commuma;
    22,23: for i := 22 to 23 do Properties[i].RentState := NewState;
    //Railroad
    24,25,26,27:
      begin
       if NewState=1 then
        begin
        Properties[Index].RentState := 1; //If one Prorerty;
        for i := 24 to 27 do
          if (Properties[i].Owner = Properties[Index].Owner) and (i<>Index) then
            begin
              inc(Properties[i].RentState);
              Properties[Index].RentState := Properties[i].RentState;
            end
          else

        end
       else
         begin
           for i := 24 to 27 do
           if (Properties[i].Owner = Properties[Index].Owner) and (i<>Index) and (not Properties[i].Mortage) then  dec(Properties[i].RentState)
           else Properties[Index].RentState := 0;
         end;
      end;
  end;
end;

function Min3Index;
begin
  result := Min(Properties[Index].RentState,Min(Properties[Index+1].RentState,Properties[Index+2].RentState));
end;

function Max3Index;
begin
  result := Max(Properties[Index].RentState,Max(Properties[Index+1].RentState,Properties[Index+2].RentState));
end;

function MinRentState;
begin
 result:= MinMaxRentState(Index,True);
end;

function MaxRentState;
begin
 result:= MinMaxRentState(Index,False);
end;

function MinMax2;
begin
  if aMin then result := Min(Properties[Index].RentState,Properties[Index+1].RentState)
          else result := Max(Properties[Index].RentState,Properties[Index+1].RentState);
end;

function MinMax3;
begin
  if aMin then result := Min3Index(Index)
          else result := Max3Index(Index);
end;



function MinMaxRentState;
begin
  case Index of
    //First
    0,1: result := MinMax2(0,aMin);
    2,3,4: result := MinMax3(2,aMin);
    //Second
    5,6,7: result := MinMax3(5,aMin);
    8,9,10:  result := MinMax3(8,aMin);
    //Third
    11,12,13: result := MinMax3(11,aMin);
    14,15,16: result := MinMax3(14,aMin);
    //Fourth
    17,18,19: result := MinMax3(17,aMin);
    20,21: result := MinMax2(20,aMin);
  end;
  {
    //Commumal
    22,23: result := Properties[(Index-21) mod 2 + 22].Owner = Owner;
    //Railroad
    24,25,26,27: result := (Properties[(Index-23) mod 3+24].Owner = Owner) or (Properties[(Index-22) mod 3+24].Owner = Owner) or (Properties[(Index-21) mod 3+24].Owner = Owner);
  }
end;

procedure EveryPay;
var i:Integer;
begin
  for I := 0 to NBots do
    if i<>Player then
      begin
        Banks[i]:=Banks[i]-Tax;
        Banks[Player] := Banks[Player] +Tax;
      end;
end;

procedure StreetRepair(Player,House,Hotel:Byte);
var i:Integer;
begin
  case Player of
    0:  for I := Low(P1Cards) to High(P1Cards) do RepairHouse(Player,Properties[P1Cards[i]].RentState,House,Hotel);
    1:  for I := Low(P2Cards) to High(P2Cards) do RepairHouse(Player,Properties[P2Cards[i]].RentState,House,Hotel);
  end;
end;

function WorkWithField;
begin
  result:=False;
  case Index of
    34: MGame.getPlayers.Items[Player].GoToJail;
    35: //Community chest
      begin
        Random15:=Random(16);
        case Random15 of
          0:Result := True;
        end;
        case Random15 of
          0: MGame.getPlayers.Items[Player].SetLocation(0);
          1: Banks[Player] := Banks[Player] + 200;
          2: Banks[Player] := Banks[Player] -50;
          3: Banks[Player] := Banks[Player] +50;
          4: inc(JailPass[Player]);
          5: MGame.getPlayers.Items[Player].GoToJail;
          6: EveryPay(Player,50);
          7: Banks[Player] := Banks[Player] +100;
          8: Banks[Player] := Banks[Player] +20;
          9: EveryPay(Player,10);
          10: Banks[Player] := Banks[Player] +100;
          11: Banks[Player] := Banks[Player] -100;
          12: Banks[Player] := Banks[Player] -50;
          13: Banks[Player] := Banks[Player] +25;
          14: StreetRepair(Player,40,115);
          15: Banks[Player] := Banks[Player] +10;
        end;
      end;
    36: //Chance
      begin
        Random15:=Random(16);
        case Random15 of
          0..4:Result := True;
          7,11,12,15:Result := True;
        end;
        case Random15 of
          3,4,15 : TwiceRentFlag := True;
        end;

        case Random15 of
          0: MGame.getPlayers.Items[Player].SetLocation(0);
          1: MGame.getPlayers.Items[Player].SetLocation(24);
          2: MGame.getPlayers.Items[Player].SetLocation(11);
          3: if (MGame.getPlayers.Items[Player].GetLocation.getIndex>11) and (MGame.getPlayers.Items[Player].GetLocation.getIndex<28)
              then MGame.getPlayers.Items[Player].SetLocation(28)
              else MGame.getPlayers.Items[Player].SetLocation(12);
          4,15: if (MGame.getPlayers.Items[Player].GetLocation.getIndex>15) then
               if (MGame.getPlayers.Items[Player].GetLocation.getIndex>25)
                 then  MGame.getPlayers.Items[Player].SetLocation(5)
                 else  MGame.getPlayers.Items[Player].SetLocation(25)
             else MGame.getPlayers.Items[Player].SetLocation(25); //Так как у нас 3 знака вопроса.
          5: Banks[Player] := Banks[Player] +50;
          6: inc(JailPass[Player]);
          7: MGame.getPlayers.Items[Player].SetLocation(MGame.getPlayers.Items[Player].GetLocation.getIndex-3);
          8: MGame.getPlayers.Items[Player].GoToJail;
          9: StreetRepair(Player,25,100);
          10: Banks[Player] := Banks[Player] -15;
          11: MGame.getPlayers.Items[Player].SetLocation(5);
          12: MGame.getPlayers.Items[Player].SetLocation(39);
          13: EveryPay(Player,-50);
          14: Banks[Player] := Banks[Player] +150;
        end;
      end;
    37: Banks[Player] :=  Banks[Player] - 200;
    38: Banks[Player] :=  Banks[Player] - 100;
  end;
end;

procedure Pay;
begin
  Banks[Sender] := Banks[Sender] - Money;
  Banks[Receiver] := Banks[Receiver] + Money;
end;

function CalcRent;
begin
  case Properties[Index].PropType of
    0:
     case Properties[Index].RentState of
       0: result := Properties[Index].Rent[0];
       1: result := Properties[Index].FullStreetRent;
       else result :=Properties[Index].Rent[Properties[Index].RentState-1];
     end;
    1: result := Properties[Index].Rent[Properties[Index].RentState];
    2: result := Properties[Index].Rent[Properties[Index].RentState];
  end;
end;

function GetRentString;
begin
  if Properties[Index].PropType=1 then result := IntToStr(CalcRent(Index))+'x'+CurrentLanguage.GetGuiString('Twodices')+'$'
                                  else result := IntToStr(CalcRent(Index))+'$';
end;

procedure PayOwner;
var Money:Integer;
var Die : TDie;
begin
  Die := TDie.create;
  if ((Properties[Index].Owner-1)<>Sender) and (not Properties[Index].Mortage) then
    begin
      {
      case Properties[Index].PropType of
        0:
          case Properties[Index].RentState of
            0: Money := Properties[Index].Rent[0];
            1: Money := Properties[Index].FullStreetRent;
            else Money :=Properties[Index].Rent[Properties[Index].RentState-1];
          end;
        1: Money := (Random(5)+1)*Properties[Index].Rent[Properties[Index].RentState];
        2: Money := Properties[Index].Rent[Properties[Index].RentState];
      end; }
      Money := CalcRent(Index);
      if Properties[Index].PropType=1 then Money := Money*(Die.RollAndFace+Die.RollAndFace);
      if TwiceRentFlag then
        begin
          if Properties[Index].PropType<>1 then Money := Money*2
                                           else Money := (Die.RollAndFace+Die.RollAndFace)*10;
          TwiceRentFlag := False;
        end;
      Pay(Sender,Properties[Index].Owner-1,Money);
    end;
  Die.Free;
end;

procedure BuyHouse(Player,Index:Byte);
begin
  inc(Properties[Index].RentState);
  banks[Player] := banks[Player]-Properties[Index].HouseCost; //В отдельную зафигачить
end;

procedure SellHouse(Player,Index:Byte);
begin
  dec(Properties[Index].RentState);
  banks[Player] := banks[Player]+Properties[Index].HouseCost div 2;
end;

procedure RepairHouse;
begin
  if RentState>1 then
   if RentState=6 then Banks[Player] := Banks[Player] - HotelCost
                  else Banks[Player] := Banks[Player] - HouseCost*(RentState-1);
end;

function GetChangeState(Index:Byte):TChangeState;
var A,B,I:Integer;
begin
  if index>21 then
   begin
     result.YesChange:=False;
     exit;
   end;
   result.P1 := 0;
   result.P2 := 0;
   case Index of
    //First
    0,1: A := 0;
    2,3,4: A :=2;
    //Second
    5,6,7: A :=5;
    8,9,10:  A :=8;
    //Third
    11,12,13: A :=11;
    14,15,16: A :=14;
    //Fourth
    17,18,19: A :=17;
    20,21: A :=20;
  end;
  if (A=0) or (A=20) then B:=A+1
                     else B:=A+2;
  if (A=0) or (A=20) then result.ChangeArr[2] := 255;
  for I := A to B do
    begin
      result.ChangeArr[i-A] :=i;
      if Properties[I].Owner=1 then inc(result.P1);
      if Properties[I].Owner=2 then inc(result.P2);
    end;
  result.YesChange := ((result.P1=2) and (result.P2=1)) or ((result.P1=1) and (result.P2=2));


end;

function GetRotateAngle;
begin
  case Index of
   5..10,22,25 : result := -90;
   11..16,23,26 : result := 180;
   17..21,27 : result := 90;
   else  result := 0;
  end;
end;


end.
