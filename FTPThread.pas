unit FTPThread;

{$IFDEF FPC}
  {$mode delphi}
{$endif}

interface

uses
  {$IFDEF WINDOWS}
    LCLIntf, LCLType,
  {$ENDIF}
  Classes, SysUtils, blcksock, synsock, synautil, fileutil;

type
  FTPStatusEvent = procedure(Status: String) of Object;

  TFTPServerThread = class(TThread)
  private
    Clients: TSocket;
    Username, Password, Main_Port, App_Version: String;
    FDataIP, FDataPort: String;
    FTPThrd_Status, Slash: String;
    FOnShow_FTPThrd_Status: FTPStatusEvent;
    procedure Show_FTPThrd_Status;
  protected
    procedure Execute; override;
    procedure Send(const Sock: TTcpBlocksocket; Value: String);
    procedure ParseRemote(Value: String);
    function buildname(dir, Value: String): String;
    function buildrealname(Value: String): String;
    function buildlist(Value: String): String;
  public
    constructor Create(sock: TSocket; FTP_Username, FTP_Password, FTP_Port, FTP_Version: String);
    property OnShow_FTPThrd_Status: FTPStatusEvent read FOnShow_FTPThrd_Status write FOnShow_FTPThrd_Status;
  end;

implementation

const
  timeout = 60000;
  MyMonthNames: array[1..12] of AnsiString =
    ('Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun',
     'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez');

{==============================================================================}
{ TFTPServerThread }

constructor TFTPServerThread.Create(Sock: TSocket; FTP_Username, FTP_Password, FTP_Port, FTP_Version: String);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  Clients := Sock;
  Username := FTP_Username;
  Password := FTP_Password;
  Main_Port := FTP_Port;
  App_Version := FTP_Version;
  {$ifdef  WINDOWS}
    Slash := '\';
  {$else}
    Slash := '/';
  {$endif}
end;

procedure TFTPServerThread.Show_FTPThrd_Status;
begin
  if Assigned(FOnShow_FTPThrd_Status) then
    FOnShow_FTPThrd_Status(FTPThrd_Status);
end;

procedure TFTPServerThread.Send(const sock: TTcpBlocksocket; Value: String);
begin
  Sock.SendString(Value + CRLF);
  FTPThrd_Status := Value;
  Synchronize(Show_FTPThrd_Status);
end;

procedure TFTPServerThread.ParseRemote(Value: String);
var
  n: Integer;
  nb, ne: Integer;
  s: String;
  x: Integer;
begin
  Value := trim(Value);
  nb := Pos('(',Value);
  ne := Pos(')',Value);
  if (nb = 0) or (ne = 0) then
  begin
    nb := RPos(' ',Value);
    s := Copy(Value, nb + 1, Length(Value) - nb);
  end
  else
  begin
    s := Copy(Value,nb+1,ne-nb-1);
  end;
  for n := 1 to 4 do
    if n = 1 then
      FDataIP := Fetch(s, ',')
    else
      FDataIP := FDataIP + '.' + Fetch(s, ',');
  x := StrToIntDef(Fetch(s, ','), 0) * 256;
  x := x + StrToIntDef(Fetch(s, ','), 0);
  FDataPort := IntToStr(x);
end;

function TFTPServerThread.buildname(dir, value: String): String;
begin
  if value = '' then
  begin
    result := dir;
    exit;
  end;
  if value[1] = '/' then
    result := value
  else
    if (dir <> '') and (dir[length(dir)] = '/') then
      Result := dir + value
    else
      Result := dir + '/' + value;
end;

function TFTPServerThread.buildrealname(value: String): String;
var
  Upload_Dir, Working_Dir: string;
begin
  Upload_Dir := 'data';
  // Arbeitsverzeichnis auslesen
  getdir(0, Working_Dir);
  // Verzeichnis data erstellen, falls nicht existent
  If Not DirectoryExists(Working_Dir + Slash + Upload_Dir) then
    CreateDir(Working_Dir + Slash + Upload_Dir);
  value := replaceString(value, '..', '.');
  {$ifdef  WINDOWS}
    value := replaceString(value, '/', '\');
  {$endif}
  result := '.' + Slash + Upload_Dir + value;
  FTPThrd_Status := 'FILESTOR - ' +   Working_Dir + Slash + Upload_Dir + value;
  Synchronize(Show_FTPThrd_Status);
end;

function fdate(value: integer): String;
var
  st: tdatetime;
  wYear, wMonth, wDay: word;
begin
  st := filedatetodatetime(value);
  DecodeDate(st, wYear, wMonth, wDay);
  Result:= Format('%d %s %d', [wday, MyMonthNames[wMonth], wyear]);
end;

function TFTPServerThread.buildlist(value: String): String;
var
  SearchRec: TSearchRec;
  r: Integer;
  s: String;
begin
  result := '';
  if value = '' then
    exit;
  if value[length(value)] <> Slash then
    value := value + Slash;
  R := FindFirst(value + '*.*', faanyfile, SearchRec);
  while r = 0 do
  begin
    if ((searchrec.Attr and faHidden) = 0)
      and ((searchrec.Attr and faSysFile) = 0)
      and ((searchrec.Attr and faVolumeID) = 0) then
    begin
      s := '';
      if (searchrec.Attr and faDirectory) > 0 then
      begin
        if (searchrec.Name <> '.') and (searchrec.Name <> '..') then
        begin
          s := s + 'drwxrwxrwx   1 root     root         1   ';
          s := s + fdate(searchrec.time) + '  ';
          s := s + searchrec.name;
        end;
      end
      else
      begin
        s := s + '-rwxrwxrwx   1 root     other        ';
        s := s + inttostr(searchrec.Size) + ' ';
        s := s + fdate(searchrec.time) + '  ';
        s := s + searchrec.name;
      end;
      if s <> '' then
        Result := Result + s + CRLF;
    end;
    r := findnext(SearchRec);
  end;
  Findclose(searchrec);
end;

procedure TFTPServerThread.Execute;
var
  Sock, DSock, PSock: TTCPBlockSocket;
  s, t: String;
  authdone: boolean;
  user: String;
  cmd, par: String;
  pwd: String;
  st: TFileStream;
  bPassiveMode:boolean;
begin
  Sock := TTCPBlockSocket.Create;
  DSock := TTCPBlockSocket.Create;
  bPassiveMode:=false;
  try
    Sock.Socket := Clients;
    FTPThrd_Status := 'CONNECT - from ' + Sock.GetRemoteSinIP;
    Synchronize(Show_FTPThrd_Status);
    Send(Sock, '220 Welcome ' + Sock.GetRemoteSinIP + ', ' + App_Version);
    authdone := false;
    user := '';
    repeat
      s := Sock.RecvString(timeout);
      cmd := uppercase(separateleft(s, ' '));
      par := separateright(s, ' ');
      if Sock.lasterror <> 0 then
        exit;
      if terminated then
        exit;
      if cmd = 'USER' then
      begin
        user := par;
        Send(Sock, '331 Please specify the password.');
        continue;
      end;
      if cmd = 'PASS' then
      begin
        //user verification...
        if ((user = Username) and (par = Password)) //  or (user = 'anonymous')
        then
        begin
          Send(Sock, '230 Login successful.');
          authdone := true;
          continue;
        end;
      end;
      Send(Sock, '500 Syntax error, command unrecognized.');
    until authdone;

    pwd := '/';
    repeat
      s := Sock.RecvString(timeout);
      FTPThrd_Status := 'FTP-Server get Command from Client: ' + s;
      Synchronize(Show_FTPThrd_Status);
      cmd := uppercase(separateleft(s, ' '));
      par := separateright(s, ' ');
      if par = s then
        par := '';
      if Sock.lasterror <> 0 then
        exit;
      if terminated then
        exit;
      if cmd = 'QUIT' then
      begin
        Send(Sock, '221 Service closing control connection.');
        break;
      end;
      if cmd = 'NOOP' then
      begin
        Send(Sock, '200 no operation - dummy packet.');
        continue;
      end;
      if cmd = 'PWD' then
      begin
        Send(Sock, '257 ' + Quotestr(pwd, '"'));
        continue;
      end;
      if cmd = 'CWD' then
      begin
        t := unquotestr(par, '"');
        t := buildname(pwd, t);
        if directoryexists(Buildrealname(t)) then
        begin
          pwd := t;
          Send(Sock, '250 OK ' + t);
        end
        else
          Send(Sock, '550 Requested action not taken.');
        continue;
      end;
      if cmd = 'MKD' then
      begin
        t := unquotestr(par, '"');
        t := buildname(pwd, t);
        if CreateDir(Buildrealname(t)) then
        begin
          pwd := t;
          Send(Sock, '257 "' + t + '" directory created');
        end
        else
          Send(Sock, '521 "' + t + '" Requested action not taken.');
        continue;
      end;
      if cmd = 'CDUP' then
      begin
        pwd := '/';
        Send(Sock, '250 OK');
        continue;
      end;
      if (cmd = 'TYPE')
        or (cmd = 'ALLO')
        or (cmd = 'STRU')
        or (cmd = 'MODE') then
      begin
        Send(Sock, '200 OK');
        continue;
      end;
      if cmd = 'PORT' then
      begin
        Parseremote(par);
        Send(Sock, '200 OK');
        continue;
      end;
	  if cmd = 'PASV' then
      begin
        DSock.CloseSocket;
        PSock := TTCPBlockSocket.Create;
        //Anpassung des Port für Passiv-Modus
        PSock.bind(sock.GetLocalSinIP, IntToStr(StrToInt(Main_Port) - 1));
        PSock.setLinger(true, 10000);
        PSock.listen;
        if PSock.LastError = 0 then
          begin
          send(sock, format('227 Entering Passive Mode (%s,%d,%d)',
            [StringReplace(sock.GetLocalSinIP,'.',',',[rfReplaceAll]),PSock.GetLocalSinPort div 256,PSock.GetLocalSinPort mod 256]));
          bPassiveMode := Sock.LastError = 0;
          DSock.socket := PSock.Accept;
          end;
        continue;
      end;
      if cmd = 'LIST' then
      begin
        t := unquotestr(par, '"');
        t := buildname(pwd, t);
        if bPassiveMode then
          begin
          try
          send(sock, '150 OK ' + t);
          dsock.SendString(buildlist(buildrealname(t)));
          send(sock, '226 OK ' + t);
          finally
            dsock.CloseSocket;
            psock.Free;
          end;
          end
        else
          begin
          dsock.CloseSocket;
          dsock.Connect(Fdataip, Fdataport);
          if dsock.LastError <> 0 then
            send(sock, '425 Can''t open data connection.')
          else
          begin
            send(sock, '150 OK ' + t);
            dsock.SendString(buildlist(buildrealname(t)));
            send(sock, '226 OK ' + t);
          end;
          dsock.CloseSocket;
          end;
        continue;
      end;
      if cmd = 'RETR' then
      begin
        t := unquotestr(par, '"');
        t := buildname(pwd, t);
        if FileExistsUTF8(buildrealname(t)) { *Converted from FileExists*  } then
        begin
          if bPassiveMode then
            begin
              try
              send(sock, '150 OK ' + t);
              try
                st := TFileStream.Create(buildrealname(t), fmOpenRead or fmShareDenyWrite);
                try
                  dsock.SendStreamRaw(st);
                finally
                  st.free;
                end;
                send(sock, '226 OK ' + t);
              except
                on exception do
                  send(sock, '451 Requested action aborted: local error in processing.');
              end;
              finally
                dsock.CloseSocket;
                psock.Free;
              end;
            end
          else
            begin
            dsock.CloseSocket;
            dsock.Connect(Fdataip, Fdataport);
            dsock.SetLinger(true, 10000);
            if dsock.LastError <> 0 then
              send(sock, '425 Can''t open data connection.')
            else
            begin
              send(sock, '150 OK ' + t);
              try
                st := TFileStream.Create(buildrealname(t), fmOpenRead or fmShareDenyWrite);
                try
                  dsock.SendStreamRaw(st);
                finally
                  st.free;
                end;
                send(sock, '226 OK ' + t);
              except
                on exception do
                  send(sock, '451 Requested action aborted: local error in processing.');
              end;
            end;
            dsock.CloseSocket;
            end;
        end
        else
          send(sock, '550 File unavailable. ' + t);
        continue;
      end;
      if cmd = 'STOR' then
      begin
        t := unquotestr(par, '"');
        t := buildname(pwd, t);
        if DirectoryExistsUTF8(extractfiledir(buildrealname(t))) { *Converted from DirectoryExists*  } then
        begin
          if bPassiveMode then
            begin
              try
              send(sock, '150 OK ' + t);
              try
                st := TFileStream.Create(buildrealname(t), fmCreate or fmShareDenyWrite);
                try
                  dsock.RecvStreamRaw(st, timeout);
                finally
                  st.free;
                end;
                send(sock, '226 OK ' + t);
              except
                on exception do
                  send(sock, '451 Requested action aborted: local error in processing.');
              end;
              finally
                dsock.CloseSocket;
                psock.Free;
              end;
            end
          else
            begin
            dsock.CloseSocket;
            dsock.Connect(Fdataip, Fdataport);
            dsock.SetLinger(true, 10000);
            if dsock.LastError <> 0 then
              send(sock, '425 Can''t open data connection.')
            else
            begin
              send(sock, '150 OK ' + t);
              try
                st := TFileStream.Create(buildrealname(t), fmCreate or fmShareDenyWrite);
                try
                  dsock.RecvStreamRaw(st, timeout);
                finally
                  st.free;
                end;
                send(sock, '226 OK ' + t);
              except
                on exception do
                  send(sock, '451 Requested action aborted: local error in processing.');
              end;
            end;
            dsock.CloseSocket;
          end;
        end
        else
          send(sock, '553 Directory not exists. ' + t);
        continue;
      end;
      Send(Sock, '500 Syntax error, command unrecognized: ' + s);
    until false;
  finally
    FTPThrd_Status := 'DISCONNECTED - from ' + Sock.GetRemoteSinIP;
    Synchronize(Show_FTPThrd_Status);
    DSock.free;
    Sock.free;
  end;
end;

{==============================================================================}
end.
