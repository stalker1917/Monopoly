unit Ai;

interface
uses
UProperties;
const BotReserve=400;

Procedure AiGetCard(Index:Byte;AUnmortage:Boolean=False);
Procedure AiBuildHotels;
Procedure AIAntiBankrupt;
Procedure AIUnmortage;
Function AIProposal:Boolean;
Function GetProposalCost(Index:Integer):Integer;

var
  ProrosalAI :TChangeState;
  ProrosalHuman : TChangeState;
  ProposalPay,ProposalPay2 : Integer;
  ProposalLag : Integer = 0;



implementation



Procedure AiGetCard;
begin
  if ImportantCard(Index,2) or ((ImportantCard(Index,1)) and (not AUnmortage))  then    //Перекрываем игроку важную карту.
    begin
      //Вплоть до залога неважных карт
      if Banks[1]>=Properties[Index].Cost then
        if AUnmortage then Unmortage(1,Index)
        else Buy(1,Index);
    end
  else
    if Banks[1]>=Properties[Index].Cost+BotReserve then
      if AUnmortage then Unmortage(1,Index)
      else Buy(1,Index);
end;

Procedure AiBuildHotels;
var i,j:Integer;
P:TProperty;
Pmin,Pmax,Pmax2 :Byte;
begin
  Pmin := 6;
  Pmax := 0;
  Pmax2 := 0;
  for I := Low(P2Cards) to High(P2Cards) do   //Выбираем максимально развитую <3
    begin
      P := Properties[P2Cards[i]];
      if (P.RentState>0) and (P.RentState<Pmin) then Pmin := P.RentState;
      if (P.RentState<4) and (P.RentState>Pmax) and (P.RentState=MinRentState(P2Cards[i])) then Pmax := P.RentState;
      if (P.RentState<6) and (P.RentState>Pmax2) and (P.RentState=MinRentState(P2Cards[i])) then Pmax2 := P.RentState;
    end;
  if Pmax2=0 then exit;      //No cars for hotel;
  if Pmax=0 then Pmax :=Pmax2;
  for I := 10 to 49 do
    begin
      j:= PropIndex[i mod 40];
      if j>21 then continue;
      P := Properties[j];
      if (P.Owner=2) and (P.RentState>0) and (P.RentState=Pmax) // and ((P.RentState<6)
        and (P.RentState=MinRentState(j)) and (Banks[1]>=P.HouseCost) then  BuyHouse(1,j);
    end;

      //if (P.RentState>0) and (P.RentState<6) and (P.RentState=MinRentState(i))
                             // and (Banks[0]>=P.HouseCost)
end;

Procedure AIAntiBankrupt;
var i :Integer;
Pmin:Byte;
P:TProperty;
AllCycle:Boolean;
begin
   // Step 1: Mortgage properties with no houses and other not important
   for I := Low(P2Cards) to High(P2Cards) do
     if (not ImportantCard(P2Cards[i],2)) and (not Properties[P2Cards[i]].Mortage) then
       Mortage(1,P2Cards[i]);
   if (Banks[1]>=0) then exit;

   // Step 2: Sell houses
    repeat
      Pmin := 7;
      for I := Low(P2Cards) to High(P2Cards) do
        if (Properties[P2Cards[i]].RentState>1) and (Properties[P2Cards[i]].RentState<Pmin) and  (Properties[P2Cards[i]].RentState=MaxRentState(P2Cards[i]))
          then Pmin := Properties[P2Cards[i]].RentState;
      if Pmin=7 then break;
      for I := Low(P2Cards) to High(P2Cards) do
        if (Properties[P2Cards[i]].RentState=Pmin) then
          begin
            SellHouse(1,P2Cards[i]);
            Break;
          end;
    until (Banks[1]>=0);
    if (Banks[1]>=0) then exit;
    // Step 3: Mortgage anything left
    for I := Low(P2Cards) to High(P2Cards) do
     if not Properties[P2Cards[i]].Mortage then Mortage(1,P2Cards[i]);
    if (Banks[1]>=0) then exit;
    // Step 4: Sell not important
    repeat
    AllCycle := True;
    for I := Low(P2Cards) to High(P2Cards) do
     if (not ImportantCard(P2Cards[i],2)) then
      begin
        Sell(1,P2Cards[i]);
        AllCycle := False;
        break;
      end;
    until (Banks[1]>=0) or (AllCycle);
     // Step 5: Sell not all cards
    while (Length(P2Cards)>0) and (Banks[1]<0) do
      Sell(1,P2Cards[0]);
//if (Banks[1]<0) Victory
end;

procedure AIUnmortage;
var i :Integer;
begin
  for I := Low(P2Cards) to High(P2Cards) do
    if Properties[P2Cards[i]].Mortage then AiGetCard(P2Cards[i],True);
end;

Function GetProposalCost;
begin
  result :=  Properties[Index].Cost;
  if result>280 then result:=result-50;
  if result<70 then result := 0;
end;

Function AIProposal;
var i :Integer;
ChangeAI :TChangeState;
ChangeHuman : TChangeState;
begin
  result := False;
  if ProposalLag>0 then
   begin
    dec(ProposalLag);
    exit;
   end;
  ChangeAI.YesChange := False;
  for I := Low(P2Cards) to High(P2Cards) do
    begin
      ChangeAI := GetChangeState(P2Cards[i]);
      if (ChangeAI.YesChange) and (ChangeAI.P2>=ChangeAI.P1) then break;
    end;
  if not ChangeAI.YesChange then exit;
  ChangeHuman.YesChange := False;
  for I := Low(P1Cards) to High(P1Cards) do
    begin
      ChangeHuman := GetChangeState(P1Cards[i]);
      if (ChangeHuman.YesChange) and (ChangeHuman.P1>=ChangeHuman.P2) and (ChangeHuman.ChangeArr[0]<>ChangeAI.ChangeArr[0]) then break;
    end;
  if not ChangeHuman.YesChange then exit;
  result:=True;
  ProposalLag := 4;
  ProrosalAI := ChangeAI;
  ProrosalHuman := ChangeHuman;
  for I := 0 to 2 do
   begin
    if ProrosalAI.ChangeArr[i]<200 then   //Pay if change Owner;
     if Properties[ProrosalAI.ChangeArr[i]].Owner=1 then  ProposalPay := ProposalPay - GetProposalCost(ProrosalAI.ChangeArr[i])
                                                    else  ProposalPay2 := ProposalPay2 + GetProposalCost(ProrosalAI.ChangeArr[i]);
    if ProrosalHuman.ChangeArr[i]<200 then   //Pay if change Owner;
     if Properties[ProrosalHuman.ChangeArr[i]].Owner=2 then  ProposalPay := ProposalPay + GetProposalCost(ProrosalHuman.ChangeArr[i])
                                                       else  ProposalPay2 := ProposalPay2 - GetProposalCost(ProrosalHuman.ChangeArr[i]);
   end;
end;



end.
