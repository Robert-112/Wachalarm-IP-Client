unit Funktionen;

{$mode objfpc}{$H+}

interface

uses
  Process, Classes, SysUtils, FileUtil, Dialogs, Grids, IniFiles,
  {$IFDEF WINDOWS} mmsystem {$ELSE} asyncprocess {$ENDIF};

type
  TPlayStyle = (psAsync, psSync);

procedure SaveStringGrid(FileName : String; StringGrid : TStringGrid);
procedure LoadStringGrid(FileName : TFileName; var StringGrid : TStringGrid);
procedure GridDeleteRow(const Grid : TStringGrid; RowNumber : Integer);
function FindStrAndCount(const TargetString, Symbol: String): Integer;
function GetIpAddrList(): string;
procedure PlaySound(Const szSoundFilename:String);
procedure StopSound;

var
  {$IFNDEF WINDOWS}
    SoundPlayerAsyncProcess:Tasyncprocess;
    SoundPlayerSyncProcess:Tprocess;
  {$ENDIF}
  fPlayCommand:String;
  fDefaultPlayCommand:String;
  fPathToSoundFile:String;
  fPlayStyle:TPlayStyle;

CONST
  C_UnableToPlay = 'Unable to play ';
  {$IFNDEF WINDOWS}
    // Defined in mmsystem
    SND_SYNC=0;
    SND_ASYNC=1;
    SND_NODEFAULT=2;
  {$ENDIF}

implementation

uses
  Main;

procedure SaveStringGrid(FileName : String; StringGrid : TStringGrid);
var
  IndexA  : Integer;
  IndexB  : Integer;
  IniFile : TIniFile;
begin
  if (FileName <> '') then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      IniFile.WriteInteger(StringGrid.Name + '.Main', 'Cols', StringGrid.ColCount);
      IniFile.WriteInteger(StringGrid.Name + '.Main', 'Rows', StringGrid.RowCount);
      for IndexA := 0 to Pred(StringGrid.ColCount) do
      begin
        for IndexB := 0 to Pred(StringGrid.RowCount) do
          IniFile.WriteString(StringGrid.Name + '.' + IntToStr(Succ(IndexB)), IntToStr(Succ(IndexA)), StringGrid.Cells[IndexA, IndexB]);
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
end;

procedure LoadStringGrid(FileName : TFileName; var StringGrid : TStringGrid);
var
  IndexA  : Integer;
  IndexB  : Integer;
  IniFile : TIniFile;
  SectionExists : Boolean;
begin
  SectionExists := false;
  if (FileExists(FileName)) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if IniFile.SectionExists(StringGrid.Name + '.Main') then
      begin
        SectionExists := true;
        //ColCount bei TGridColumn nicht funktional
        //StringGrid.ColCount := IniFile.ReadInteger(StringGrid.Name + '.Main', 'Cols', 1);
        StringGrid.RowCount := IniFile.ReadInteger(StringGrid.Name + '.Main', 'Rows', 1);
        for IndexA := 0 to Pred(StringGrid.ColCount) do
        begin
          for IndexB := 0 to Pred(StringGrid.RowCount) do
            StringGrid.Cells[IndexA, IndexB] := IniFile.ReadString(StringGrid.Name + '.' + IntToStr(Succ(IndexB)), IntToStr(Succ(IndexA)), '');
        end;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
      StringGrid.AutoSizeColumns;
    end;
  end;
  if SectionExists = false then
    SaveStringGrid(Filename,StringGrid);
end;

procedure GridDeleteRow(const Grid : TStringGrid; RowNumber : Integer);
var
  i : Integer;
begin
  for i := RowNumber to Grid.RowCount - 2 do
    Grid.Rows[i].Assign(Grid.Rows[i+ 1]);
  Grid.Rows[Grid.RowCount-1].Clear;
  Grid.RowCount := Grid.RowCount - 1;
end;

function FindStrAndCount(const TargetString, Symbol: String): Integer;
var i: Integer;
begin
 Result:= 0;
 i:= Length(TargetString);
 for i:= 1 to i do
 begin
  if TargetString[i] = Symbol then
    inc(Result);
 end;
end;

function GetIpAddrList(): string;
var
  AProcess: TProcess;
  s: string;
  sl: TStringList;
  i: integer;
  {$IFDEF UNIX}
  n: integer;
  {$ENDIF}
begin
  Result:='';
  sl:=TStringList.Create();
  {$IFDEF WINDOWS}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable  := 'ipconfig.exe';
  AProcess.Options := AProcess.Options + [poUsePipes, poNoConsole];
  try
    AProcess.Execute();
    Sleep(500); // poWaitOnExit not working as expected
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;
  for i:=0 to sl.Count-1 do
  begin
    if (Pos('IPv4', sl[i])=0) and (Pos('IP-Adresse', sl[i])=0) and (Pos('IP Address', sl[i])=0) then Continue;
    s:=sl[i];
    s:=Trim(Copy(s, Pos(':', s)+1, 999));
    if Pos(':', s)>0 then Continue; // IPv6
    if Result = '' then
      Result := s
    else
      Result := Result +', ' + s;
  end;
  {$ENDIF}
  {$IFDEF UNIX}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable := '/sbin/ifconfig';
  AProcess.Options := AProcess.Options + [poUsePipes, poWaitOnExit];
  try
    AProcess.Execute();
    //Sleep(500); // poWaitOnExit not working as expected
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;
  for i:=0 to sl.Count-1 do
  begin
    n:=Pos('inet ', sl[i]);
    if n=0 then Continue;
    s:=sl[i];
    s:=Copy(s, n+Length('inet '), 999);
    if pos('addr:' ,s) > 0 then
      s:=StringReplace(s,'addr:','',[rfReplaceAll]);
    s:=Trim(Copy(s, 1, Pos(' ', s)));
    if leftstr(s,8) <> '127.0.0.' then
    begin
      if Result = '' then
        Result := s
      else
        Result := Result +', ' + s;
    end;
  end;
  {$ENDIF}
  sl.Free();
end;

function GetPlayCommand: String;
begin
  if FPlayCommand = '' then
    Result := FDefaultPlayCommand
  else
    Result := FplayCommand;
end;

function GetNonWindowsPlayCommand: String;
begin
  Result := '';
  // Try mplayer
  if (Result = '') then
    if (FindDefaultExecutablePath('mplayer') <> '') then
      Result := 'mplayer -really-quiet';
  // Try play
  if (Result = '') then
    if (FindDefaultExecutablePath('play') <> '') then
      Result := 'play';
  // Try aplay
  if (result = '') then
    if (FindDefaultExecutablePath('aplay') <> '') then
      Result := 'aplay -q';
  // Try paplay
  if (Result = '') then
    if (FindDefaultExecutablePath('paplay') <> '') then
      Result := 'paplay';
  // Try CMus
  if (Result = '') then
    if (FindDefaultExecutablePath('CMus') <> '') then
      Result := 'CMus';
  // Try pacat
  if (Result = '') then
    if (FindDefaultExecutablePath('pacat') <> '') then
      Result := 'pacat -p';
  // Try ffplay
  if (Result = '') then
    if (FindDefaultExecutablePath('ffplay') <> '') then
      result := 'ffplay -autoexit -nodisp';
  // Try cvlc
  if (Result = '') then
    if (FindDefaultExecutablePath('cvlc') <> '') then
      result := 'cvlc -q --play-and-exit';
  // Try canberra-gtk-play
  if (Result = '') then
    if (FindDefaultExecutablePath('canberra-gtk-play') <> '') then
      Result := 'canberra-gtk-play -c never -f';
  // Try Macintosh command?
  if (Result = '') then
    if (FindDefaultExecutablePath('afplay') <> '') then
      Result := 'afplay';
end;

procedure PlaySound(const szSoundFilename: string);
var
{$IFDEF WINDOWS}
  flags: word;
{$ELSE}
  L: TStrings;
  i: Integer;
  playCmd: String;
{$ENDIF}
begin
  fPlayStyle := psSync;
  {$IFDEF WINDOWS}
    fDefaultPlayCommand := 'sndPlaySound';
  {$ELSE}
    fDefaultPlayCommand := GetNonWindowsPlayCommand; // Linux, Mac etc.
  {$ENDIF}
{$IFDEF WINDOWS}
  if fPlayStyle = psASync then
    flags := SND_ASYNC or SND_NODEFAULT
  else
    flags := SND_SYNC or SND_NODEFAULT;
  try
    sndPlaySound(PChar(szSoundFilename), flags);
  except
    ShowMessage(C_UnableToPlay + szSoundFilename);
  end;
{$ELSE}
  // How to play in Linux? Use generic Linux commands
  // Use asyncprocess to play sound as SND_ASYNC
  // proceed if we managed to find a valid command
  playCmd := GetPlayCommand;
  if (playCmd <> '') then
  begin
    L := TStringList.Create;
    try
      L.Delimiter := ' ';
      L.DelimitedText := playCmd;
      if fPlayStyle = psASync then
      begin
        if SoundPlayerAsyncProcess = nil then
          SoundPlayerAsyncProcess := TaSyncProcess.Create(nil);
        SoundPlayerAsyncProcess.CurrentDirectory := ExtractFileDir(szSoundFilename);
        SoundPlayerAsyncProcess.Executable := FindDefaultExecutablePath(L[0]);
        SoundPlayerAsyncProcess.Parameters.Clear;
        for i := 1 to L.Count-1 do
          SoundPlayerAsyncProcess.Parameters.Add(L[i]);
        SoundPlayerAsyncProcess.Parameters.Add(szSoundFilename);
        try
          SoundPlayerAsyncProcess.Execute;
        except
          On E: Exception do
            E.CreateFmt('Playstyle=paASync: ' + C_UnableToPlay +
              '%s Message:%s', [szSoundFilename, E.Message]);
        end;
      end
      else
      begin
        if SoundPlayerSyncProcess = nil then
          SoundPlayerSyncProcess := TProcess.Create(nil);
        SoundPlayerSyncProcess.CurrentDirectory := ExtractFileDir(szSoundFilename);
        SoundPlayerSyncProcess.Executable := FindDefaultExecutablePath(L[0]);
        SoundPlayersyncProcess.Parameters.Clear;
        for i:=1 to L.Count-1 do
          SoundPlayerSyncProcess.Parameters.Add(L[i]);
        SoundPlayerSyncProcess.Parameters.Add(szSoundFilename);
        try
          SoundPlayerSyncProcess.Execute;
          SoundPlayersyncProcess.WaitOnExit;
        except
          On E: Exception do
            E.CreateFmt('Playstyle=paSync: ' + C_UnableToPlay +
              '%s Message:%s', [szSoundFilename, E.Message]);
        end;
      end;
    finally
      L.Free;
    end;
  end
  else
    raise Exception.CreateFmt('The play command %s does not work on your system',
      [fPlayCommand]);
{$ENDIF}
end;

procedure StopSound;
begin
{$IFDEF WINDOWS}
   sndPlaySound(nil, 0);
{$ELSE}
  if SoundPlayerSyncProcess <> nil then SoundPlayerSyncProcess.Terminate(1);
  if SoundPlayerAsyncProcess <> nil then SoundPlayerAsyncProcess.Terminate(1);
{$ENDIF}
end;

end.

