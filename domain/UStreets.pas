type
  TProperty = record
    Name: string;
    Cost: Integer;
    Rent: array[0..5] of Integer; // Rent values for 0 to 4 houses and a hotel
    FullStreetRent: Integer;
    HouseCost: Integer;
    HotelCost: Integer;
  end;

var
  Properties: array[0..27] of TProperty; // Array to hold the properties
  
procedure InitializeProperties;
begin
  Properties[0].Name := 'Mediterranean Avenue';
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

  Properties[1].Name := 'Baltic Avenue';
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

  Properties[2].Name := 'Oriental Avenue';
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
 
  Properties[3].Name := 'Vermont Avenue';
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

  Properties[4].Name := 'Connecticut Avenue';
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

  Properties[5].Name := 'St. Charles Place';
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

  Properties[6].Name := 'States Avenue';
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

  Properties[7].Name := 'Virginia Avenue';
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

  Properties[8].Name := 'St. James Place';
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

  Properties[9].Name := 'Tennessee Avenue';
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

  Properties[10].Name := 'New York Avenue';
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

  Properties[11].Name := 'Kentucky Avenue';
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

  Properties[12].Name := 'Indiana Avenue';
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

  Properties[13].Name := 'Illinois Avenue';
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

  Properties[14].Name := 'Atlantic Avenue';
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

  Properties[15].Name := 'Ventnor Avenue';
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

  Properties[16].Name := 'Marvin Gardens';
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

  Properties[17].Name := 'Pacific Avenue';
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

  Properties[18].Name := 'North Carolina Avenue';
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

  Properties[19].Name := 'Pennsylvania Avenue';
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

  Properties[20].Name := 'Park Place';
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

  Properties[21].Name := 'Boardwalk';
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
  Properties[22].Name := 'Electric Company';
  Properties[22].Cost := 150;
  Properties[22].Rent[0] := 4; // Rent is variable, typically 4x dice roll if one utility owned
  Properties[22].Rent[1] := 10; // 10x dice roll if both utilities owned
  Properties[22].FullStreetRent := 0;
  Properties[22].HouseCost := 0;
  Properties[22].HotelCost := 0;

  Properties[23].Name := 'Water Works';
  Properties[23].Cost := 150;
  Properties[23].Rent[0] := 4; // Rent is variable, typically 4x dice roll if one utility owned
  Properties[23].Rent[1] := 10; // 10x dice roll if both utilities owned
  Properties[23].FullStreetRent := 0;
  Properties[23].HouseCost := 0;
  Properties[23].HotelCost := 0;

  // Railroad properties
  Properties[24].Name := 'Reading Railroad';
  Properties[24].Cost := 200;
  Properties[24].Rent[0] := 25;
  Properties[24].Rent[1] := 50;
  Properties[24].Rent[2] := 100;
  Properties[24].Rent[3] := 200;
  Properties[24].FullStreetRent := 0;
  Properties[24].HouseCost := 0;
  Properties[24].HotelCost := 0;

  Properties[25].Name := 'Pennsylvania Railroad';
  Properties[25].Cost := 200;
  Properties[25].Rent[0] := 25;
  Properties[25].Rent[1] := 50;
  Properties[25].Rent[2] := 100;
  Properties[25].Rent[3] := 200;
  Properties[25].FullStreetRent := 0;
  Properties[25].HouseCost := 0;
  Properties[25].HotelCost := 0;

  Properties[26].Name := 'B&O Railroad';
  Properties[26].Cost := 200;
  Properties[26].Rent[0] := 25;
  Properties[26].Rent[1] := 50;
  Properties[26].Rent[2] := 100;
  Properties[26].Rent[3] := 200;
  Properties[26].FullStreetRent := 0;
  Properties[26].HouseCost := 0;
  Properties[26].HotelCost := 0;

  Properties[27].Name := 'Short Line';
  Properties[27].Cost := 200;
  Properties[27].Rent[0] := 25;
  Properties[27].Rent[1] := 50;
  Properties[27].Rent[2] := 100;
  Properties[27].Rent[3] := 200;
  Properties[27].FullStreetRent := 0;
  Properties[27].HouseCost := 0;
  Properties[27].HotelCost := 0;


  // Add more properties as needed...

end;  