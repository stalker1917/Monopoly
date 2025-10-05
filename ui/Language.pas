unit Language;

interface
uses System.IniFiles,FMX.Platform;
type
  TLanguage = class(TObject)
  constructor Create(LNumber:Integer);
  function GetGuiString(S:String):String;
  function GetChance(S:String):String;
  function GetCommunity(S:String):String;
  function GetProperties(S:String):String;
  Destructor Destroy;
  private
  FCurrentLanguage : TIniFile;
  end;

//
//function GetPackageVersion:String;

var
  CurrentLanguage : TLanguage;

function GetOSLangID: String;
implementation
uses LoadSave;

constructor TLanguage.Create;
begin
 case LNumber of
  1: FCurrentLanguage := TIniFile.Create(GetPath+'English.ini');
  7: FCurrentLanguage := TIniFile.Create(GetPath+'Russian.ini');
  else FCurrentLanguage := TIniFile.Create(GetPath+'English.ini');
 end;
end;

Destructor TLanguage.Destroy;
begin
  FCurrentLanguage.Free;
end;

function TLanguage.GetGuiString(S:String):String;
begin
  Result := FCurrentLanguage.ReadString('Main',S,'');
end;

function TLanguage.GetChance(S:String):String;
begin
  Result := FCurrentLanguage.ReadString('ChanceCards',S,'');
end;
function TLanguage.GetCommunity(S:String):String;
begin
  Result := FCurrentLanguage.ReadString('CommunityChestCards',S,'');
end;
function TLanguage.GetProperties(S:String):String;
begin
  Result := FCurrentLanguage.ReadString('Properties',S,'');
end;

function GetOSLangID: String;

  {$IFDEF ANDROID} var
    LocServ: IFMXLocaleService;
  begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXLocaleService,
      IInterface(LocServ)) then
      Result := LocServ.GetCurrentLangID;
  end;
  {$ENDIF}
{$IFDEF MSWINDOWS}
  begin
        Result := 'en';

  end; { code }
  {$ENDIF}
end.
