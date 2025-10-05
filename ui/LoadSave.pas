unit LoadSave;

interface
uses
  System.IniFiles, System.IOUtils, System.SysUtils,System.Generics.Collections,

  Uplayer,Uproperties,UmGame,AI;

var F:Text;

procedure SaveGameState(const AFileName: string);
procedure LoadGameState(const AFileName: string);
function GetPath:String;
procedure CreateLog(const AFileName: string);
procedure WriteToLog(S:String);



implementation


procedure SaveGameState(const AFileName: string);
var
  Ini: TIniFile;
  I, J: Integer;
  Path: string;
  PlayersList: TList<TPlayer>;
  Player: TPlayer;
begin
  // Determine the appropriate path for each platform
  {$IFDEF MSWINDOWS}
  Path := ExtractFilePath(ParamStr(0)) + AFileName;
  {$ENDIF}
  {$IFDEF ANDROID}
  Path := TPath.GetPublicPath + PathDelim + AFileName;
  {$ENDIF}
  PlayersList := MGame.getPlayers;
  DeleteFile(Path);
  // Create the INI file
  Ini := TIniFile.Create(Path);
  try
    // Save player positions and jail status
    for I := 0 to PlayersList.Count - 1 do
    begin
      Player := PlayersList[I] as TPlayer;
      Ini.WriteInteger('Players', 'Player' + IntToStr(I) + '_Position', Player.GetLocation.getIndex);
      Ini.WriteInteger('Players', 'Player' + IntToStr(I) + '_Jail', Player.JailFlag);
    end;

    // Save properties
    for I := 0 to 27 do
    begin
      //if Properties[I] <> nil then
     // begin
        Ini.WriteInteger('Properties', 'Property' + IntToStr(I) + '_Owner', Properties[I].Owner);
        Ini.WriteBool('Properties', 'Property' + IntToStr(I) + '_Mortgage', Properties[I].Mortage);
        Ini.WriteInteger('Properties', 'Property' + IntToStr(I) + '_RentState', Properties[I].RentState);
      //end;
    end;

    // Save player cards
    for I := 0 to High(P1Cards) do
      Ini.WriteInteger('Cards', 'P1Card' + IntToStr(I), P1Cards[I]);

    for I := 0 to High(P2Cards) do
      Ini.WriteInteger('Cards', 'P2Card' + IntToStr(I), P2Cards[I]);

    // Save banks
    for I := 0 to High(Banks) do
      Ini.WriteInteger('Banks', 'Bank' + IntToStr(I), Banks[I]);

    // Save jail passes
    for I := 0 to High(JailPass) do
      Ini.WriteInteger('JailPass', 'JailPass' + IntToStr(I), JailPass[I]);

    // Save human index
    Ini.WriteInteger('Game', 'HumanIndex', HumanIndex);

  finally
    Ini.Free;
  end;
end;


procedure LoadGameState(const AFileName: string);
var
  Ini: TIniFile;
  I: Integer;
  Path: string;
  Player: TPlayer;
  PlayersList: TList<TPlayer>;
  //Sections: TStringList;
begin
  // Determine the appropriate path for each platform
  {$IFDEF MSWINDOWS}
  Path := ExtractFilePath(ParamStr(0)) + AFileName;
  {$ENDIF}
  {$IFDEF ANDROID}
  Path := TPath.GetPublicPath  + PathDelim + AFileName;
  {$ENDIF}

  PlayersList := MGame.getPlayers;

  // Check if the file exists
  if not FileExists(Path) then
    Exit;

  // Create the INI file
  Ini := TIniFile.Create(Path);
  try
    // Load player positions and jail status
    for I := 0 to PlayersList.Count - 1 do
    begin
      Player := PlayersList[I] as TPlayer;
      Player.SetLocation(Ini.ReadInteger('Players', 'Player' + IntToStr(I) + '_Position', 0));
      Player.JailFlag := Ini.ReadInteger('Players', 'Player' + IntToStr(I) + '_Jail', 0);
    end;

    // Load properties
    for I := 0 to 27 do
    begin
      //if Properties[I] <> nil then
      //begin
        Properties[I].Owner := Ini.ReadInteger('Properties', 'Property' + IntToStr(I) + '_Owner', 255);
        Properties[I].Mortage := Ini.ReadBool('Properties', 'Property' + IntToStr(I) + '_Mortgage', False);
        Properties[I].RentState := Ini.ReadInteger('Properties', 'Property' + IntToStr(I) + '_RentState', 0);
      //end;
    end;

    // Load player cards - first determine how many cards were saved
    I := 0;
    SetLength(P1Cards, 0);
    while Ini.ValueExists('Cards', 'P1Card' + IntToStr(I)) do
    begin
      SetLength(P1Cards, I + 1);
      P1Cards[I] := Ini.ReadInteger('Cards', 'P1Card' + IntToStr(I), 0);
      Inc(I);
    end;

    I := 0;
    SetLength(P2Cards, 0);
    while Ini.ValueExists('Cards', 'P2Card' + IntToStr(I)) do
    begin
      SetLength(P2Cards, I + 1);
      P2Cards[I] := Ini.ReadInteger('Cards', 'P2Card' + IntToStr(I), 0);
      Inc(I);
    end;

    // Load banks
    for I := 0 to High(Banks) do
      Banks[I] := Ini.ReadInteger('Banks', 'Bank' + IntToStr(I), 0);

    // Load jail passes
    for I := 0 to High(JailPass) do
      JailPass[I] := Ini.ReadInteger('JailPass', 'JailPass' + IntToStr(I), 0);

    // Load human index
    HumanIndex := Ini.ReadInteger('Game', 'HumanIndex', 0);
    ProposalLag := 0;


  finally
    Ini.Free;
  end;
end;


function GetPath:String;
begin
   {$IFDEF ANDROID}
     result:=TPath.GetDocumentsPath + PathDelim;
   {$ELSE}
     result:='./';
   {$ENDIF}
end;


procedure CreateLog(const AFileName: string);
var Path :String;
begin
  // Determine the appropriate path for each platform
  {$IFDEF MSWINDOWS}
  Path := ExtractFilePath(ParamStr(0)) + AFileName;
  {$ENDIF}
  {$IFDEF ANDROID}
  Path := TPath.GetPublicPath  + PathDelim + AFileName;
  {$ENDIF}
  Assignfile(F,Path);
  Rewrite(F);
end;

procedure WriteToLog(S:String);
begin
  WriteLn(F,S);
  Flush(F);
end;

end.
