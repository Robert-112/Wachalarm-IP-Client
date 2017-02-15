unit Main;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
    comobj, ActiveX, ShellApi,
  {$ELSE}
    asyncprocess, process,
  {$ENDIF}
  FileUtil, LCLType, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  ComCtrls, LCLIntf, StdCtrls, ActnList, Menus, ExtCtrls, Spin, LazUTF8,
  LResources, Grids, inifiles, FTPThread, blcksock, synsock, Anzeige,
  Funktionen;

{ UDP-Server Thread Deklaration }  

Type
  UDP_TShowStatusEvent = procedure(UDP_Status: String) of Object;
  UDP_Thread = class(TThread)
  private
    { Private declarations }
    UDP_StatusText, UDP_Port: String;
    UDP_FOnShowStatus: UDP_TShowStatusEvent;
    procedure UDP_ShowStatus;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
    property UDP_OnShowStatus: UDP_TShowStatusEvent read UDP_FOnShowStatus write UDP_FOnShowStatus;
  end;

{ FTP-Server Thread Deklaration }    

Type
  FTP_TShowStatusEvent = procedure(Status: String) of Object;
  FTP_Thread = class(TThread)
  private
    { Private declarations }
    FTP_StatusText, FTP_User, FTP_Pass, FTP_Port, FTP_Version: String;
    FTP_FOnShowStatus: FTP_TShowStatusEvent;
    FTP_ServerThread: TFtpServerThread;
    procedure FTP_ShowStatus;
    procedure FTP_ServerShowStatus(Status: String);      
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
    property FTP_OnShowStatus: FTP_TShowStatusEvent read FTP_FOnShowStatus write FTP_FOnShowStatus;
  end;

{ Sound Thread Deklaration}  

Type
  Sound_Thread = class(TThread)
  private
    Sound_Txt: String;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
  end;

{ TFrm_Main Deklaration}

  TFrm_Main = class(TForm)
    A_Beenden: TAction;
    A_Uhr_anzeigen: TAction;
    A_Info: TAction;
    CB_Play_Gong: TCheckBox;
    CB_Play_Sound: TCheckBox;
    CB_Show_Alarmbild: TCheckBox;
    CB_Show_Clock: TCheckBox;
    CB_Show_PopUp: TCheckBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Image1: TImage;
    I_Alarmbild: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    L_Weblink: TLabel;
    L_Version: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    L_Dauer: TLabel;
    L_LastServerMsg: TLabel;
    L_Server_IP: TLabel;
    L_LastUpload: TLabel;
    L_Monitor: TLabel;
    Memo_EM_TTS: TMemo;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    L_Local_IP: TLabel;
    MenuItem8: TMenuItem;
    M_Programm_beenden: TMenuItem;
    PC_Config: TPageControl;
    SP_Alarmbild_Dauer: TSpinEdit;
    SP_Alarmbild_Monitor: TSpinEdit;
    SG_Zeitkriterien: TStringGrid;
    TB_Sonstiges: TTabSheet;
    TB_Anzeige: TTabSheet;
    TB_Sound: TTabSheet;
    TB_Info: TTabSheet;
    TB_Config: TTabSheet;
    A_Chronik_anzeigen: TAction;
    A_Einstellungen: TAction;
    ActionList1: TActionList;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    MainMenu1: TMainMenu;
    Memo_Chronik: TMemo;
    Memo_Log: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem7: TMenuItem;
    PC_Main: TPageControl;
    PopupMenu1: TPopupMenu;
    StatusBar1: TStatusBar;
    TB_Chronik: TTabSheet;
    TB_Log: TTabSheet;
    Timer_Anzeigedauer: TTimer;
    TB_TTS: TToggleBox;
    TrayIcon: TTrayIcon;
    procedure A_BeendenExecute(Sender: TObject);
    procedure A_Chronik_anzeigenExecute(Sender: TObject);
    procedure A_EinstellungenExecute(Sender: TObject);
    procedure A_InfoExecute(Sender: TObject);
    procedure A_Uhr_anzeigenExecute(Sender: TObject);
    procedure CB_Play_GongChange(Sender: TObject);
    procedure CB_Play_SoundChange(Sender: TObject);
    procedure CB_Show_AlarmbildChange(Sender: TObject);
    procedure CB_Show_ClockChange(Sender: TObject);
    procedure CB_Show_PopUpChange(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure L_WeblinkClick(Sender: TObject);
    procedure Memo_ChronikChange(Sender: TObject);
    procedure Memo_EM_TTSEditingDone(Sender: TObject);
    procedure Memo_LogChange(Sender: TObject);
    procedure SG_ZeitkriterienEditingDone(Sender: TObject);
    procedure SG_ZeitkriterienKeyDown(Sender: TObject; var Key: Word);
    procedure SG_ZeitkriterienValidateEntry(sender: TObject; aCol,
      aRow: Integer; const OldValue: string; var NewValue: String);
    procedure SP_Alarmbild_DauerChange(Sender: TObject);
    procedure SP_Alarmbild_MonitorChange(Sender: TObject);
    procedure SP_Alarmbild_MonitorEditingDone(Sender: TObject);
    procedure TB_TTSChange(Sender: TObject);
    procedure Timer_AnzeigedauerTimer(Sender: TObject);
    procedure UDP_Stream_Auswerten(Stream: string);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure Bildanzeigen;
    procedure Einstellungen_speichern;
    procedure Einstellungen_lesen;
    procedure Log_schreiben(Memo, Memo_Text: String);
  private
    { private declarations }
    MyFTP_Thread: FTP_Thread;
    MyUDP_Thread: UDP_Thread;
    procedure FTP_ServerStatus(Status: String);
    procedure UDP_ServerStatus(Status: String);
  public
    { public declarations }
  end; 

{ globale Variablen }  
  
var
  Frm_Main: TFrm_Main;
  Anzeigedauer: Integer;
  Dir, Slash, Upload_Dateipfad, Upload_Datei, UDP_Text: String;
  User, Pass, App_Version: String;
  Programmstart, Bild_wird_angezeigt, Upload_Success: boolean;
  Config_INI: TIniFile;

implementation

{$R *.lfm}
{$R credentials.res}
{$R sounds.res}

{==============================================================================}
{=========== TFrm_Main ========================================================}
{==============================================================================}

procedure TFrm_Main.FormCreate(Sender: TObject);
var
  EM_Replace, Chronik, Log: File;
  RS: TResourceStream;
  OS: String;
begin
  // Slash für Dateiverarbeitung je nach Betriebssystem setzen
  {$IFDEF  WINDOWS}
    Slash := '\';
  {$ELSE}
    Slash := '/';
  {$ENDIF}
  // Format für Datum und Uhrzeit festlegen
  DefaultFormatSettings.LongDayNames[1]:='Sonntag';
  DefaultFormatSettings.LongDayNames[2]:='Montag';
  DefaultFormatSettings.LongDayNames[3]:='Dienstag';
  DefaultFormatSettings.LongDayNames[4]:='Mittwoch';
  DefaultFormatSettings.LongDayNames[5]:='Donnertag';
  DefaultFormatSettings.LongDayNames[6]:='Freitag';
  DefaultFormatSettings.LongDayNames[7]:='Samstag';
  DefaultFormatSettings.LongMonthNames[1]:='Januar';
  DefaultFormatSettings.LongMonthNames[2]:='Februar';
  DefaultFormatSettings.LongMonthNames[3]:='März';
  DefaultFormatSettings.LongMonthNames[4]:='April';
  DefaultFormatSettings.LongMonthNames[5]:='Mai';
  DefaultFormatSettings.LongMonthNames[6]:='Juni';
  DefaultFormatSettings.LongMonthNames[7]:='Juli';
  DefaultFormatSettings.LongMonthNames[8]:='August';
  DefaultFormatSettings.LongMonthNames[9]:='September';
  DefaultFormatSettings.LongMonthNames[10]:='Oktober';
  DefaultFormatSettings.LongMonthNames[11]:='November';
  DefaultFormatSettings.LongMonthNames[12]:='Dezember';
  DefaultFormatSettings.DateSeparator := '.';
  DefaultFormatSettings.TimeSeparator := ':';
  DefaultFormatSettings.ShortDateFormat := 'dd.mm.yyyy';
  DefaultFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  // aktuelles Verzeichnis auslesen und auf Ordner config setzen
  getdir(0,Dir);
  // Verzeichnis config erstellen, falls nicht existent
  If Not DirectoryExists(Dir + Slash + 'config') then
    CreateDir(Dir + Slash + 'config');
  Dir := Dir + slash + 'config';
  // Variablen setzen
  Anzeigedauer := 0;
  Bild_wird_angezeigt := false;
  Upload_Success := true;
  // Variable Programmstart ist notwendig, da beim einlesen der config.ini auch die OnChange Prozeduren ausgeführt werden
  Programmstart := false;
  // lokale IP-Adresse auslesen
  L_Local_IP.caption := GetIpAddrList();
  // Anzahl der Monitore auslesen und festelegen
  SP_Alarmbild_Monitor.MaxValue := screen.MonitorCount;
  // Einsatzmittelersetzungen erstellen/lesen
  if FileExists(Dir + Slash + 'em_replace.txt') then
    begin
      AssignFile(EM_Replace, Dir + Slash + 'em_replace.txt');
      ReSet(EM_Replace, 1);
    end
  else
    begin
      AssignFile(EM_Replace, Dir + Slash + 'em_replace.txt');
      ReWrite(EM_Replace, 1);
    end;
  CloseFile(EM_Replace);
  // Datei mit Standard-Werten befüllen
  Memo_EM_TTS.Lines.SaveToFile(Dir + Slash + 'em_replace.txt');
  // Alarmchronik erstellen/lesen
  if FileExists(Dir + Slash + 'chronik.txt') then
    begin
      AssignFile(Chronik, Dir + Slash + 'chronik.txt');
      ReSet(Chronik, 1);
    end
  else
    begin
      AssignFile(Chronik, Dir + Slash + 'chronik.txt');
      ReWrite(Chronik, 1);
    end;
  CloseFile(Chronik);
  // Logbuch erstellen/lesen
  if FileExists(Dir + Slash + 'log.txt') then
    begin
      AssignFile(Log, Dir + Slash + 'log.txt');
      ReSet(Log, 1);
    end
  else
    begin
      AssignFile(Log, Dir + Slash + 'log.txt');
      ReWrite(Log, 1);
    end;
  CloseFile(Log);
  // Memos befüllen
  try
    Memo_Chronik.Lines.LoadFromFile(Dir + Slash + 'chronik.txt')  ;
    Memo_Log.Lines.LoadFromFile(Dir + Slash + 'log.txt');
    Memo_EM_TTS.Lines.LoadFromFile(Dir + Slash + 'em_replace.txt');
  except
  end;
  // Einstellungen einlesen falls config.ini vorhanden ist
  if FileExists (Dir + Slash + 'config.ini') then
    begin
      Programmstart := true;
      Einstellungen_lesen;
    end
  else
    Einstellungen_speichern;
  // Tabellendaten laden
  LoadStringGrid(Dir + Slash + 'config.ini',SG_Zeitkriterien);
  // kleinere Form-Anpassungen
  PC_Main.ActivePage := TB_Info;
  PC_Config.ActivePage := TB_Anzeige;
  // TTS deaktivieren, wenn nicht Windows
  {$IFNDEF WINDOWS}
    TB_TTS.Checked := false;
    TB_TTS.Enabled := false;
  {$ENDIF}
  // Login-Daten aus Resource laden
  try
    RS := TResourceStream.Create(hinstance, 'FTPLOGIN', RT_RCDATA);
    SetString(Pass, RS.Memory, RS.Size);
    RS.Free;
    // Benutzername und Password ermitteln
    User := copy(Pass, 1, pos(',', Pass) - 1);
    Pass := stringreplace(Pass, User +',', '', []);
  except
    // Falls kein User/Pass ermittelbar (weil z.B. keine Resourcen-Datei), soll auch nichts gesetzt werden
    Log_schreiben('Log','Benutzername/Passwort konnte nicht eingelesen werden!');
    User := '';
    Pass := '';
  end;
  // Informationen zum Betriebssystem sammeln
  OS := 'unknown';
  {$IFDEF WIN32}
    OS := 'Windows x86';
  {$ENDIF}
  {$IFDEF WIN64}
    OS := 'Windows x64';
  {$ENDIF}
  {$IFDEF LINUX}
      OS := 'Linux';
  {$ENDIF}
  // JSON für Version-Info erstellen
  App_Version := '{' +
    '"WachalarmIP-Client": {' +
      '"Version": "' + L_Version.Caption + '",' +
      '"OS": "' + os + '",' +
      '"IP": "' + Frm_Main.L_Local_IP.Caption + '",' +
      '"Anzeige_Screen": {' +
          '"Anzeige_Width": "' + IntToStr(Screen.Monitors[SP_Alarmbild_Monitor.Value - 1].Width) + '",' +
          '"Anzeige_Height": "' + IntToStr(Screen.Monitors[SP_Alarmbild_Monitor.Value - 1].Height) + '"' +
      '}' +
    '}' +
  '}';
  // FTP-Server erstellen
  MyFTP_Thread := FTP_Thread.Create(True);
  if Assigned(MyFTP_Thread.FatalException) then
    raise MyFTP_Thread.FatalException;
  // Variablen an Thread zuweisen
  MyFTP_Thread.FTP_OnShowStatus := @FTP_ServerStatus;
  MyFTP_Thread.FTP_User := User;
  MyFTP_Thread.FTP_Pass := Pass;
  MyFTP_Thread.FTP_Port := '60144';
  MyFTP_Thread.FTP_Version := App_Version;
  // FTP-Server starten
  MyFTP_Thread.Start;
  // UDP-Server erstellen
  MyUDP_Thread := UDP_Thread.Create(True);
  if Assigned(MyUDP_Thread.FatalException) then
    raise MyUDP_Thread.FatalException;
  // Variablen an Thread zuweisen
  MyUDP_Thread.UDP_OnShowStatus := @UDP_ServerStatus;
  MyUDP_Thread.UDP_Port := '60132';
  // UDP-Server starten
  MyUDP_Thread.Start;
  // Log schreiben
  Log_schreiben('Log','Anwendung gestartet');
end;

procedure TFrm_Main.Timer_AnzeigedauerTimer(Sender: TObject);
var CanClose: boolean;
begin
  //Alarmbild wieder ausschalten
  if Bild_wird_angezeigt = true then
  begin
    Anzeigedauer := Anzeigedauer + 1000;
    // wenn Zeit aus Dauer (in Minuten) erreicht, dann Bild wieder ausblenden
    if Anzeigedauer = SP_Alarmbild_Dauer.Value * 60000 then
    begin
      Frm_Anzeige.I_Alarmbild.Hide;
      Frm_Anzeige.Panel_AllePanels.Show;
      //Wenn keine Digitaluhr gesetzt ist, dann gesamte ANZEIGE wieder ausblenden
      if Frm_Main.CB_Show_Clock.Checked = false then
        Frm_Anzeige.Hide
      else
      //Wenn Digitaluhr angezeigt werden soll, dann zunächst prüfen ob Anzeige im Vordergrund
      begin
        if Frm_Anzeige.Visible = true then
        begin;
          Frm_Main.FormCloseQuery(Sender,CanClose);
          Frm_Anzeige.Show;
          Frm_Anzeige.WindowState := wsMaximized;
        end;
      end;
      Bild_wird_angezeigt := false;
      Anzeigedauer := 0;
    end;
  end;
end;

procedure TFrm_Main.Bildanzeigen;
var
  AlarmImage: TJpegImage;
begin
  if Frm_Main.CB_Show_Alarmbild.Checked = true then
  begin
    AlarmImage := TJpegImage.Create;
    AlarmImage.LoadFromFile(Upload_Dateipfad);
    try
      Frm_Anzeige.I_Alarmbild.Picture.Assign(AlarmImage);
    finally
      AlarmImage.Free;
    end;
    Frm_Anzeige.Panel_AllePanels.Hide;
    Frm_Anzeige.Show;
    Frm_Anzeige.WindowState := wsmaximized;
    Frm_Anzeige.I_Alarmbild.Stretch := true;
    Frm_Anzeige.I_Alarmbild.Width := Frm_Anzeige.Width;
    Frm_Anzeige.I_Alarmbild.Height := Frm_Anzeige.Height ;
    Frm_Anzeige.I_Alarmbild.Visible := true;
    Frm_Anzeige.I_Alarmbild.BringToFront;
    // jetzt kann der Timer_Anzeigedauer seine Funktion erfüllen
    Bild_wird_angezeigt := true;
    // Anzeigedauer zurücksetzen
    Anzeigedauer := 0;
    // Datei wieder löschen
    if FileExists(Upload_Dateipfad)then
      DeleteFile(Upload_Dateipfad);
  end;
end;

procedure TFrm_Main.UDP_Stream_Auswerten(Stream:string);
var Tmp_Str, Gong_to_Play ,Text_to_Play, Sounds_to_Play, Einsatzart, Einsatzort, Stichwort, Einsatzmittel, Sondersignal, Funkkenner, Einsatzmitteltyp, Einsatzmittel_Nr: string;
    i: Integer;
    PlaySoundThread: Sound_Thread;
    von_Zeit, bis_Zeit, aktuelle_Zeit: TDateTime;
    Nachtruhe_Gesamt, Nachtruhe_Zeit, Nachtruhe_Einsatzart, Funkkenner_unbekannt : Boolean;
begin
  // UDP-Stream Bestandteile auswerten
  // 1. Einsatzart
  Einsatzart := Copy(Stream, 0, pos('|', Stream) - 1);
  Stream := StringReplace(Stream, Einsatzart + '|', '', []);
  StringReplace(Einsatzart,' ','',[rfReplaceAll]);
  // 2. Einsatzort
  Einsatzort := Copy(Stream, 0, pos('|', Stream) - 1);
  Stream := StringReplace(Stream, Einsatzort + '|', '', []);
  // 3. Stichwort
  Stichwort := Copy(Stream, 0, pos('|', Stream) - 1);
  Stream := StringReplace(Stream, Stichwort + '|', '', []);
  // 4. Einsatzmittel
  Einsatzmittel := Copy(Stream, 0, pos('|', Stream) - 1);
  Stream := StringReplace(Stream, Einsatzmittel + '|', '', []);
  // 5. Sondersignal
  Sondersignal := Copy(Stream, 0, length(Stream));
  Stream := StringReplace(Stream, Sondersignal, '', []);
  // Tooltip anzeigen, falls gewollt
  if Frm_Main.CB_Show_PopUp.Checked = true then
  begin
    TrayIcon.BalloonHint := Einsatzart + #13#10 + Stichwort + #13#10 + Einsatzort + #13#10 + Einsatzmittel + #13#10 + Sondersignal;
    TrayIcon.ShowBalloonHint;
  end;
  // Sounds auswerten und entsprechend den Resourcen in sounds.res zuordnen
{ 1  -> Alarmgong_Gross.wav
  2  -> Alarmgong_Klein.wav
  3  -> Alarmgong_Pager.wav
  4  -> Alarmgong_Trommel.wav
  5  -> Einsatzart_Brandeinsatz.wav
  6  -> Einsatzart_Hilfeleistungseinsatz.wav
  7  -> Einsatzart_Krankentransport.wav
  8  -> Einsatzart_Probe.wav
  9  -> Einsatzart_Rettungseinsatz.wav
  10 -> Einsatzmittel_NEF.wav
  11 -> Einsatzmittel_RTW.wav
  12 -> Text_Ende-der-Durchsage.wav
  13 -> Text_mit-Sondersignal.wav
  14 -> Zahl_0.wav
  15 -> Zahl_1.wav
  16 -> Zahl_2.wav
  17 -> Zahl_3.wav
  18 -> Zahl_4.wav
  19 -> Zahl_5.wav
  20 -> Zahl_6.wav
  21 -> Zahl_7.wav
  22 -> Zahl_8.wav
  23 -> Zahl_9.wav
  24 -> Zx_Ansagen-GongA.wav
  25 -> Zx_Ansagen-GongB.wav }
  // Variablen zurücksetzen
  Gong_to_Play := '';
  Sounds_to_Play := '';
  Text_to_Play := 'TEXT:';
  // Sound des Gongs setzen, falls gewollt
  if Frm_Main.CB_Play_Gong.Checked = true then
  begin
    if (Einsatzart = 'Brandeinsatz') or (Einsatzart = 'Hilfeleistungseinsatz') then
      Gong_to_Play := '1,'
    else
      Gong_to_Play := '2,';
  end;
  // weitere Sounds setzen, falls gewollt
  if Frm_Main.CB_Play_Sound.Checked = true then
  begin
    // Sound der Einsatzart setzen
    if Einsatzart = 'Brandeinsatz' then
    begin
      Text_to_Play := Text_to_Play + 'Brandeinsatz;';
      Sounds_to_Play := Sounds_to_Play + '5,';
    end;
    if Einsatzart = 'Rettungseinsatz' then
    begin
      Text_to_Play := Text_to_Play + 'Rettungseinsatz;';
      Sounds_to_Play := Sounds_to_Play + '9,';
    end;
    if Einsatzart = 'Hilfeleistungseinsatz' then
    begin
      Text_to_Play := Text_to_Play + 'Hilfeleistungseinsatz;';
      Sounds_to_Play := Sounds_to_Play + '6,';
    end;
    if Einsatzart = 'Krankentransport' then
    begin
      Text_to_Play := Text_to_Play + 'Krankentransport;';
      Sounds_to_Play := Sounds_to_Play + '7,';
    end;
    if Einsatzart = 'Sonstiges' then
    begin
      Text_to_Play := Text_to_Play + 'Sonstiges;';
      // 'Sonstiges' in sounds.res nicht vorhanden
    end;
    // Sound für Stichwort - nur TTS
    Text_to_Play := Text_to_Play + StringReplace(Stichwort, ',', '', [rfReplaceAll])  + ';';
    // Sound für Einsatzort - nur TTS
    Text_to_Play := Text_to_Play + StringReplace(Einsatzort, ',', '', [rfReplaceAll])  + ';';
    // Sounds für Fahrzeuge
    // BSP Einsatzmittel-String: 01/83-01 01/82-01 01/83-03 (FL CB 01/83-01 FL CB 01/82-01 FL CB 01/83-03)
    Einsatzmittel := LeftStr(Einsatzmittel, pos('(', Einsatzmittel) - 1);
    // Funkkenner erkennen (jeder Funkkenner hat 8 Zeichen, daher div 8)
    repeat
      Funkkenner_unbekannt := true;
      // ersten Funkkenner isolieren!
      Funkkenner := Copy(Einsatzmittel, 0, pos(' ',Einsatzmittel) -1);
      // aus Syntax des Funkkenner den Einsatzmitteltyp extrahieren wenn diese der Normierung 01/XX-01 entspricht
      if (Pos('/', Funkkenner) = 3) and (Pos('-', Funkkenner) = 6) then
      begin
        Einsatzmitteltyp := Copy(Funkkenner, 4, 2);
        // Memo mit TTS-Ersetzungen durchgehen und prüfen ob Einsatzmitteltyp-Ersetzung vorhanden
        for i := 0 to Memo_EM_TTS.Lines.Count - 1 do
        begin
    	  // Einsatzmitteltyp mit gesprochenem Namen ersetzen, falls vorhanden
          if Copy(Memo_EM_TTS.Lines[i], 0, pos('==',Memo_EM_TTS.Lines[i]) - 1) = Einsatzmitteltyp then
          begin
            Funkkenner_unbekannt := false;
            Einsatzmittel_Nr := Copy(Funkkenner, pos(Einsatzmitteltyp, Funkkenner) + 3, 2);
    	    // kleine Unterscheidung der Einsatzmittel_Nr, BSP 1 -> eins, oder 01 -> null eins
            if LeftStr(Einsatzmittel_Nr, 1) = '0' then
              Text_to_Play := Text_to_Play + Copy(Memo_EM_TTS.Lines[i], pos('==', Memo_EM_TTS.Lines[i]) + 2, 100) + ' ' + Copy(Einsatzmittel_Nr, 2, 1) + ';'
            else
              Text_to_Play := Text_to_Play + Copy(Memo_EM_TTS.Lines[i], pos('==', Memo_EM_TTS.Lines[i]) + 2, 100) + ' ' + Einsatzmittel_Nr + ';';
          end;
        end;
    	// Für NEF und RTW alternativ Ansagen aus der Resource hinterlegen
    	if Einsatzmitteltyp = '82' then
    	begin
    	  // Sound für NEF setzen
    	  Sounds_to_Play := Sounds_to_Play + '10,';
    	  // Sound für Ordnungszahl setzen
    	  Sounds_to_Play := Sounds_to_Play + IntToStr(StrToInt(copy(Funkkenner, pos('82', Funkkenner) + 4, 1)) + 14) + ',';
    	end;
    	if Einsatzmitteltyp = '83' then
    	begin
    	  // Sound für RTW setzen
    	  Sounds_to_Play := Sounds_to_Play + '11,';
    	  // Sound für Ordnungszahl setzen
    	  Sounds_to_Play := Sounds_to_Play + IntToStr(StrToInt(copy(Funkkenner, pos('83', Funkkenner) + 4, 1)) + 14) + ',';
    	end;
      end;
      // Wenn Einsatzmitteltyp nicht hinterlegt, dann Funkkenner duchsagen
      if Funkkenner_unbekannt = true then
      begin
        // Sonderzeichen entfernen
        Tmp_Str :=  Funkkenner;
        Tmp_Str :=  StringReplace(Tmp_Str, ',', '', [rfReplaceAll]);
        Tmp_Str :=  StringReplace(Tmp_Str, '-', ' ', [rfReplaceAll]);
        Tmp_Str :=  StringReplace(Tmp_Str, '/', ' ', [rfReplaceAll]);
        Text_to_Play := Text_to_Play + Tmp_Str + ';';
        Tmp_Str := '';
      end;
      // Einsatzmittel löschen für nächsten Durchgang
      Delete(Einsatzmittel, 1, length(Funkkenner) + 1);
    until Einsatzmittel = '';
    // Sound für Sondersignal setzen
    if Sondersignal = '[mit Sondersignal]' then
    begin
      Text_to_Play := Text_to_Play + 'mit Sondersignal;';
      Sounds_to_Play := Sounds_to_Play + '13,'
    end
    else
    begin
      Text_to_Play := Text_to_Play + 'ohne Sonderrechte;';
      // 'ohne Sonderrechte' in sounds.res nicht vorhanden
    end;
    // Sound für "Ende der Durchsage" setzen
    Text_to_Play := Text_to_Play + 'Ende der Durchsage';
    Sounds_to_Play := Sounds_to_Play + '12,';
  end;
  // Nachtruhekriterien auswerten
  Nachtruhe_Gesamt := false;
  for i := 1 to SG_Zeitkriterien.RowCount - 2 do
  begin
    // temporäre Variablen zurücksetzen
    Nachtruhe_Zeit := false;
    Nachtruhe_Einsatzart := false;
    // Zeitkriterien ermitteln
    von_Zeit := StrToTime(SG_Zeitkriterien.Cells[0,i] + ':' + SG_Zeitkriterien.Cells[1,i] + ':00');
    bis_Zeit := StrToTime(SG_Zeitkriterien.Cells[2,i] + ':' + SG_Zeitkriterien.Cells[3,i] + ':00');
    aktuelle_Zeit := Time;
    // feststellen ob Zeitkriterium greift
    if von_Zeit > bis_Zeit then
    begin
      if (aktuelle_Zeit > von_Zeit) or (aktuelle_Zeit < bis_Zeit) then
        Nachtruhe_Zeit := true;
    end
    else
    begin
      if (aktuelle_Zeit > von_Zeit) and (aktuelle_Zeit < bis_Zeit) then
        Nachtruhe_Zeit := true;
    end;
    // feststellen ob auch Einsatzartkriterium greift
    if Einsatzart = 'Brandeinsatz' then
    begin
      if SG_Zeitkriterien.Cells[4,i] = '1' then
        Nachtruhe_Einsatzart := true;
    end;
    if Einsatzart = 'Hilfeleistungseinsatz' then
    begin
      if SG_Zeitkriterien.Cells[5,i] = '1' then
        Nachtruhe_Einsatzart := true;
    end;
    if Einsatzart = 'Rettungseinsatz' then
    begin
      if SG_Zeitkriterien.Cells[6,i] = '1' then
        Nachtruhe_Einsatzart := true;
    end;
    if Einsatzart = 'Krankentransport' then
    begin
      if SG_Zeitkriterien.Cells[7,i] = '1' then
        Nachtruhe_Einsatzart := true;
    end;
    if Einsatzart = 'Sonstiges' then
    begin
      if SG_Zeitkriterien.Cells[8,i] = '1' then
        Nachtruhe_Einsatzart := true;
    end;
    // prüfen ob beide Nachtruhe-Kriterien gesetzt sind
    if (Nachtruhe_Zeit = true) and (Nachtruhe_Einsatzart = true) then
      Nachtruhe_Gesamt := true;
  end;
  // Sound-Thread ausführen, sofern alle Bedingungen erfüllt sind
  if (Nachtruhe_Gesamt = false) and ((Frm_Main.CB_Play_Gong.Checked = true) or (Frm_Main.CB_Play_Sound.Checked = true)) then
  begin
    PlaySoundThread := Sound_Thread.Create(true);
    if Assigned(PlaySoundThread.FatalException) then
      raise PlaySoundThread.FatalException;
    // bestimmen ob TTS oder Resource
    if TB_TTS.Checked = true then
      PlaySoundThread.Sound_Txt := Gong_to_Play + Text_to_Play + ','
    else
      PlaySoundThread.Sound_Txt := Gong_to_Play + Sounds_to_Play;
    // an Thread übergeben
    PlaySoundThread.Start;
  end;
end;

procedure TFrm_Main.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := false;
  Frm_Main.Visible := false;
  If Frm_Main.CB_Show_Clock.Checked = true then
    Frm_Anzeige.Show;
end;

procedure TFrm_Main.TrayIconDblClick(Sender: TObject);
begin
  Frm_Main.Show;
  Frm_Anzeige.Hide;
end;

procedure TFrm_Main.SP_Alarmbild_DauerChange(Sender: TObject);
begin
  //Wert für Timer der Anzeigedauer setzen
  L_Dauer.Caption := IntToStr(SP_Alarmbild_Dauer.Value);
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.SP_Alarmbild_MonitorChange(Sender: TObject);
begin
  L_Monitor.Caption := IntToStr(SP_Alarmbild_Monitor.Value);
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.SP_Alarmbild_MonitorEditingDone(Sender: TObject);
begin
  ShowMessage('Achtung:'+ #13#10+'Die Einstellung für den Ausgabemonitor wird erst nach Neustart des Programms wirksam!');
end;

procedure TFrm_Main.TB_TTSChange(Sender: TObject);
begin
  if TB_TTS.Checked = true then
    TB_TTS.Caption := 'Text-To-Speech Funktion ist aktiviert!';
  if TB_TTS.Checked = false then
    TB_TTS.Caption := 'Text-To-Speech Funktion ist deaktiviert';
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.CB_Show_AlarmbildChange(Sender: TObject);
begin
  if Programmstart = false then
   Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.CB_Play_GongChange(Sender: TObject);
begin
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.A_Uhr_anzeigenExecute(Sender: TObject);
var CanClose:boolean;
begin
  If Frm_Main.Visible = true then
    Frm_Main.FormCloseQuery(Sender,CanClose)
  else
  begin
    Frm_Main.CB_Show_Clock.Checked := true;
    Frm_Main.Visible := false;
    Frm_Anzeige.Show;
  end;
end;

procedure TFrm_Main.A_Chronik_anzeigenExecute(Sender: TObject);
begin
  Frm_main.Show;
  Frm_Main.TB_Chronik.Show;
end;

procedure TFrm_Main.A_EinstellungenExecute(Sender: TObject);
begin
  Frm_main.Show;
  Frm_Main.TB_Config.Show;
end;

procedure TFrm_Main.A_InfoExecute(Sender: TObject);
begin
  Frm_main.Show;
  Frm_Main.TB_Info.Show;
end;

procedure TFrm_Main.CB_Play_SoundChange(Sender: TObject);
begin
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.CB_Show_ClockChange(Sender: TObject);
begin
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.CB_Show_PopUpChange(Sender: TObject);
begin
  if Programmstart = false then
    Frm_Main.Einstellungen_speichern;
end;

procedure TFrm_Main.FormDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Main.L_WeblinkClick(Sender: TObject);
begin
  OpenURL('https://github.com/Robert-112/Wachalarm-IP-Client');
end;

procedure TFrm_Main.Memo_ChronikChange(Sender: TObject);
begin
  //damit das Chronik nicht zu groß wird, Zeilen löschen
  while Memo_Chronik.Lines.Count > 5000 do
    Memo_Chronik.Lines.Delete(Memo_Chronik.Lines.Count - 1);
end;

procedure TFrm_Main.Memo_EM_TTSEditingDone(Sender: TObject);
begin
  Memo_EM_TTS.Lines.SaveToFile(Dir + Slash + 'em_replace.txt');
end;

procedure TFrm_Main.Memo_LogChange(Sender: TObject);
begin
  //damit das Log nicht zu groß wird, Zeilen löschen
  while Memo_Log.Lines.Count > 10000 do
    Memo_Log.Lines.Delete(Memo_Log.Lines.Count - 1);
end;

procedure TFrm_Main.SG_ZeitkriterienEditingDone(Sender: TObject);
begin
  // neue leer-Zeile anfügen
  if SG_Zeitkriterien.Cells[0, SG_Zeitkriterien.RowCount - 1] <> '' then
     SG_Zeitkriterien.RowCount := SG_Zeitkriterien.RowCount + 1;
  // Tabelle anpassen und speichern
  SG_Zeitkriterien.AutoSizeColumns;
  SaveStringGrid(Dir + Slash + 'config.ini',SG_Zeitkriterien);
end;

procedure TFrm_Main.SG_ZeitkriterienKeyDown(Sender: TObject; var Key: Word);
begin
if (Key = VK_DELETE) then
  begin
    GridDeleteRow(SG_Zeitkriterien,SG_Zeitkriterien.Row);
    SaveStringGrid(Dir+ Slash + 'config.ini',SG_Zeitkriterien);
  end;
end;

procedure TFrm_Main.SG_ZeitkriterienValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  if SG_Zeitkriterien.Columns.Items[aCol].PickList.Count <> 0 then
  begin
    if SG_Zeitkriterien.Columns.Items[aCol].PickList.IndexOf(NewValue) = -1 then
    begin
      ShowMessage('Ungültige Eingabe: ' + NewValue + #13#10 + 'Bitte Eintrag aus Liste wählen!');
      NewValue := '';
    end;
  end;
end;

procedure TFrm_Main.Einstellungen_speichern;
begin
  Config_INI := TIniFile.Create(Dir + Slash + 'config.ini');
  try
    Config_INI.WriteBool('Einstellungen','Alarmbild_anzeigen',Frm_Main.CB_Show_Alarmbild.Checked);
    Config_INI.WriteInteger('Einstellungen','Alarmbild_Dauer',Frm_Main.SP_Alarmbild_Dauer.Value);
    Config_INI.WriteInteger('Einstellungen','Alarmbild_Monitor',Frm_Main.SP_Alarmbild_Monitor.Value);
    Config_INI.WriteBool('Einstellungen','Digitaluhr_anzeigen',Frm_Main.CB_Show_Clock.Checked);
    Config_INI.WriteBool('Einstellungen','PopUp_anzeigen',Frm_Main.CB_Show_PopUp.Checked);
    Config_INI.WriteBool('Einstellungen','Alarmgong_wiedergeben',Frm_Main.CB_Play_Gong.Checked);
    Config_INI.WriteBool('Einstellungen','Alarmansage_wiedergeben',Frm_Main.CB_Play_Sound.Checked);
    Config_INI.WriteBool('Einstellungen','TTS_aktivieren',Frm_Main.TB_TTS.Checked);
  finally
    Config_INI.Free;
  end;
  Programmstart := false;
end;

procedure TFrm_Main.Einstellungen_lesen;
begin
  Config_INI := TIniFile.Create(Dir + Slash + 'config.ini');
  try
    Frm_Main.CB_Show_Alarmbild.Checked := Config_INI.ReadBool('Einstellungen','Alarmbild_anzeigen',true);
    Frm_Main.SP_Alarmbild_Dauer.Value := Config_INI.ReadInteger('Einstellungen','Alarmbild_Dauer',0);
    Frm_Main.SP_Alarmbild_Monitor.Value := Config_INI.ReadInteger('Einstellungen','Alarmbild_Monitor',0);
    Frm_Main.CB_Show_Clock.Checked := Config_INI.ReadBool('Einstellungen','Digitaluhr_anzeigen',true);
    Frm_Main.CB_Show_PopUp.Checked := Config_INI.ReadBool('Einstellungen','PopUp_anzeigen',true);
    Frm_Main.CB_Play_Gong.Checked := Config_INI.ReadBool('Einstellungen','Alarmgong_wiedergeben',true);
    Frm_Main.CB_Play_Sound.Checked := Config_INI.ReadBool('Einstellungen','Alarmansage_wiedergeben',true);
    Frm_Main.TB_TTS.Checked := Config_INI.ReadBool('Einstellungen','TTS_aktivieren',true);
  finally
    Config_INI.Free;
  end;
  Programmstart := false;
end;

procedure TFrm_Main.Log_schreiben(Memo, Memo_Text: string);
begin
  if Memo = 'Log' then
    begin
      Memo_Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': '+ Memo_Text);
      Memo_log.Lines.SaveToFile(Dir + Slash + 'log.txt');
    end;
  if Memo = 'Chronik' then
    begin
      Memo_Chronik.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': '+ Memo_Text);
      Memo_Chronik.Lines.SaveToFile(Dir + Slash + 'chronik.txt');
    end;
end;

procedure TFrm_Main.A_BeendenExecute(Sender: TObject);
var Reply,BoxStyle:integer;
begin
  with Application do begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := MessageBox('Möchten Sie WachalarmIP wirklich beenden?', 'Programm beenden', BoxStyle);
  // bei Ja-Klick Programm beenden
  if Reply = IDYES then
    begin
      Log_schreiben('Log','Anwendung beendet');
      // Programm beenden, Threads beenden sich selbst
      Application.Terminate;
    end;
  end;
end;

{==============================================================================}
{=========== FTP_Thread =======================================================}
{==============================================================================}

constructor FTP_Thread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure FTP_Thread.FTP_ShowStatus;
begin
  if Assigned(FTP_FOnShowStatus) then
    FTP_FOnShowStatus(FTP_StatusText);
end;

procedure TFrm_Main.FTP_ServerStatus(Status: string);
var Ergebnis, New_Status: String;
begin
  New_Status := Status;
  // DEBUG AUSGABEN
  Log_schreiben('Log','DEBUG: '+ New_Status);
  // bei Connect Server-IP setzen und von OK ausgehen
  if Copy(New_Status,0,15)  = 'CONNECT - from ' then
  begin
    Upload_Success := true;
    L_Server_IP.Caption := StringReplace(New_Status, 'CONNECT - from ', '', []);
  end;
  // Upload-Verzeichnis auslesen
  if Copy(New_Status,0,11)  = 'FILESTOR - ' then
  begin
    Upload_Success := true;
    Upload_Dateipfad := StringReplace(New_Status, 'FILESTOR - ', '', []);
  end;
  // bei 226 ist Upload OK
  if Copy(New_Status,0,6)  = '226 OK' then
  begin
    Upload_Success := true;
    Upload_Datei := Copy(New_Status,9,200);
    L_LastUpload.Caption := DateToStr(date) + '-' + TimeToStr(time);
  end;
  // wenn Meldung mit 4 oder 5 (ausgenommen 500), dann ist Upload fehlerhaft
  if Copy(New_Status,0,1) = '4' then
    Upload_Success := false;
  if Copy(New_Status,0,1) = '5' then
  begin
    if Copy(New_Status,0,3) <> '500' then
      Upload_Success := false;
  end;
  // Nach Disconnect Bild anzeigen
  if Copy(New_Status,0,20) = 'DISCONNECTED - from ' then
  begin
    if Upload_Success = true then
    begin
      Ergebnis := 'Dateiupload erfolgreich: ' + #39 + Upload_Dateipfad + #39;
      if Upload_Datei = 'WA_Server.jpg' then
        Bildanzeigen;
      Upload_Dateipfad := '';
      Upload_Datei := '';
    end
    else
    begin
      Ergebnis := 'FEHLER - Dateiupload nicht erfolgreich!';
      Upload_Dateipfad := '';
      Upload_Datei := '';
    end;
    Log_schreiben('Log', Ergebnis);
    // für nächsten Durchlauf wieder auf true setzen
    Upload_Success := true;
  end;
end;

procedure FTP_Thread.FTP_ServerShowStatus(Status: string);
begin
  FTP_StatusText := Status;
    Synchronize(@FTP_ShowStatus);
end;

procedure FTP_Thread.Execute;
var
  ClientSock: TSocket;
  Sock: TTCPBlockSocket;
begin
  Sock := TTCPBlockSocket.Create;
  try
    Sock.Bind('0.0.0.0', FTP_Port);
    Sock.SetLinger(true, 10000);
    Sock.Listen;
    if Sock.LastError <> 0 then
      exit;
    while not terminated do
    begin
      if Sock.CanRead(1000) then
      begin
        ClientSock := Sock.Accept;
        FTP_StatusText := 'FTP_Thread.Execute';
        Synchronize(@FTP_ShowStatus);
        if Sock.LastError = 0 then
        begin
          // FTP-Thread starten und Benutzer, Passwort, Port, Version übergeben
          FTP_ServerThread := TFtpServerThread.create(ClientSock, FTP_User, FTP_Pass, FTP_Port, FTP_Version);
          FTP_ServerThread.OnShow_FTPThrd_Status := @FTP_ServerShowStatus;
        end;
      end;
    end;
  finally
    Sock.Free;
  end;
end;

{==============================================================================}
{=========== UDP_Thread =======================================================}
{==============================================================================}

constructor UDP_Thread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure UDP_Thread.UDP_ShowStatus;
begin
  if Assigned(UDP_FOnShowStatus) then
    UDP_FOnShowStatus(UDP_StatusText);
end;

procedure UDP_Thread.Execute;
var
  Sock: TUDPBlockSocket;
  Buf: String;
begin
  Sock := TUDPBlockSocket.Create;
  try
    Sock.Bind('0.0.0.0', UDP_Port);
    if Sock.LastError <> 0 then exit;
    while true do
    begin
      if terminated then break;
        Buf := Sock.RecvPacket(1000);
      if Sock.lasterror = 0 then
      begin
        UDP_StatusText := Buf;
        Synchronize(@UDP_ShowStatus);
      end;
      Sleep(1);
    end;
    Sock.CloseSocket;
  finally
    Sock.Free;
  end;
end;

procedure TFrm_Main.UDP_ServerStatus(Status: string);
var
  Minuten: Integer;
  PlaySoundThread: Sound_Thread;
  Update_Client, Update_Batch: Boolean;
begin
  UDP_Text := Status;
  if UDP_Text = '' then
    Log_schreiben('Log', 'FEHLER - UDP-Nachricht wurde nicht richtig übertragen! Es konnte kein Text ermittelt werden')
  else
  begin
    if LeftStr(UDP_Text,9) <> 'ANWEISUNG' then
    begin
      if FindStrAndCount(UDP_Text,'|') = 4 then
      begin
        UDP_Stream_Auswerten(UDP_Text);
        Log_schreiben('Chronik', UDP_Text);
        Log_schreiben('Log', 'Alarmtext (UDP) erhalten ' + #39 + UDP_Text + #39);
      end
      else
        Log_schreiben('Log', 'FEHLER - Alarmtext (UDP) ist falsch formatiert! ' + #39 + UDP_Text + #39);
    end
    else
    begin
      // handelt es sich um eine ANWEISUNG?
      // BSP für Kodierung der UDP-Meldung: ANWEISUNG-User|Pass~~ART:irgendein Text zum Bespiel
      if LeftStr(UDP_Text, 10) = 'ANWEISUNG-' then
      begin
        // Ist die Anweisung autorisiert?
        if LeftStr(UDP_Text, pos('~~', UDP_Text) + 1) <> 'ANWEISUNG-' + User + '|' + Pass + '~~' then
          Log_schreiben('Log', 'FEHLER - ANWEISUNG (UDP) nicht autorisiert! ' + #39 + UDP_Text + #39)
        else
        begin
          UDP_Text := StringReplace(UDP_Text, 'ANWEISUNG-' + User + '|' + Pass + '~~', '', []);
          // Einsatzmittel ersetzen
          if LeftStr(UDP_Text, 3) = 'EM:' then
          begin
            UDP_Text := StringReplace(UDP_Text, 'EM:', '', []);
            // BSP: 'EM:11==ELW  //14==KDOW  //19==MTW
            Memo_EM_TTS.Lines.Clear;
            Memo_EM_TTS.Lines.Text := UDP_Text;
            Memo_EM_TTS.Lines.SaveToFile(Dir + Slash + 'em_replace.txt');
            Log_schreiben('Log', 'ANWEISUNG-EM erhalten (UDP), neue EM wurden gesetzt: ' + #39 + UDP_Text + #39);
          end;
          // Durchsage ausgeben
          if LeftStr(UDP_Text, 10) = 'DURCHSAGE:' then
          begin
            UDP_Text := StringReplace(UDP_Text, 'DURCHSAGE:', '', []);
            // BSP: 'ANWEISUNG-DURCHSAGE:Herr Muster die 6320, Herr Muster bitte die 6320'
            // Sound-Thread erstellen und Daten übergeben
            PlaySoundThread := Sound_Thread.Create(true);
            if Assigned(PlaySoundThread.FatalException) then
              raise PlaySoundThread.FatalException;
            PlaySoundThread.Sound_Txt := '25,' + 'TEXT:' + UDP_Text + ',';
            PlaySoundThread.Start;
            Log_schreiben('Log', 'ANWEISUNG-DURCHSAGE erhalten (UDP), ' + #39 + UDP_Text + #39 );
          end;
          if LeftStr(UDP_Text, 5) = 'INFO:' then
          begin
            // BSP: 'ANWEISUNG-INFO:5;Informationstext'
            UDP_Text := StringReplace(UDP_Text, 'INFO:', '', []);
            // Minuten für Anzeigedauer aus String extrahieren, falls nicht vorhanden 0 setzen
            Minuten := StrToIntDef(LeftStr(UDP_Text, pos(';', UDP_Text)-1), 0);
            Delete(UDP_Text, 1, pos(';', UDP_Text));
            Frm_Anzeige.Zeit_und_Infotext_anzeigen(Minuten, UDP_Text);
            Log_schreiben('Log', 'ANWEISUNG-INFO erhalten (UDP), zeige ' + #39 + UDP_Text + #39 + ' für ' + IntToStr(Minuten) + ' Minuten an');
          end;
          if LeftStr(UDP_Text, 6) = 'UPDATE' then
          begin
            // BSP: 'ANWEISUNG-UPDATE'
            Log_schreiben('Log', 'ANWEISUNG-UPDATE erhalten (UDP), starte Update-Prozess');
            Update_Client := false;
            Update_Batch := false;
            {$IFDEF WINDOWS}
              // prüfen ob Wachalarm-Client vorhanden ist
              if FileExists(Dir + Slash + '..' + Slash + 'data' + Slash + 'WachalarmIP-Client.exe')then
              begin
                Update_Client := true;
                Log_schreiben('Log', 'Update-Prozess 1 von 3: Wachalarm-Client vorhanden.');
              end
              else
              begin
                Update_Client := false;
                Log_schreiben('Log', 'Update-Prozess 1 von 3: Wachalarm-Client nicht vorhanden!');
              end;
              // prüfen ob Update-Skript vorhanden ist
              if FileExists(Dir + Slash + '..' + Slash + 'data' + Slash + 'Wachalarm-Update.bat')then
              begin
                Update_Batch := true;
                Log_schreiben('Log', 'Update-Prozess 2 von 3: Update-Skript vorhanden.');
              end
              else
              begin
                Update_Batch := false;
                Log_schreiben('Log', 'Update-Prozess 2 von 3: Update-Skript nicht vorhanden!');
              end;
              // Update durchführen
              if (Update_Client = true) and (Update_Batch = true) then
              begin
                Log_schreiben('Log', 'Update-Prozess 3 von 3: Update-Skript wird ausgeführt.');
                ShellExecute(0,nil, PChar('cmd'),PChar('/c ' + Dir + Slash + '..' + Slash + 'data' + Slash + 'Wachalarm-Update.bat'),nil,1);
              end
              else
                Log_schreiben('Log', 'Update abgebrochen! Fehler bei Update-Prozess');
            {$ELSE}
              Log_schreiben('Log', 'Update abgebrochen! Update-Prozess wird aktuell nur für Windows unterstützt.');
            {$ENDIF}
          end;
        end;
      end;
    end
  end;
  UDP_Text := '';
end;

{==============================================================================}
{=========== Sound_Thread =====================================================}
{==============================================================================}

constructor Sound_Thread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := true;
  inherited Create(CreateSuspended);
end;

procedure Sound_Thread.Execute;
var
  Sound_ID_int: integer;
  Sound_ID_str: String;
  Sound_File: String;
  rStream: TResourceStream;
  {$IFDEF WINDOWS}
    SavedCW: Word;
    SpVoice: Variant;
    WideSoundString : WideString;
  {$ENDIF}
begin
  //BSP: 1,1,3,11,3,23,23,2,
  Sound_ID_int := 0;
  Sound_ID_str := '';
  Sound_File := Dir + Slash + 'temp.wav';
  fPlayStyle := psSync;
  repeat
    Sound_ID_str := Copy(Sound_Txt, 0, pos(',', Sound_Txt) - 1);
    Sound_ID_int := StrToIntDef(Sound_ID_str,0);
    if Sound_ID_int > 0 then
    // Sound aus Resource wiedergeben
    begin
      rStream := TResourceStream.CreateFromID(HInstance, Sound_ID_int, PCHAR('WAVE'));
      try
        rStream.SaveToFile(Sound_File);
        PlaySound(Sound_File);
        if FileExists(Sound_File)then
          DeleteFile(Sound_File);
      finally
        rStream.Free;
      end;
    end
    else
    // Sound über Text-To-Speach wiedergeben
    begin
    {$IFDEF WINDOWS}
      CoInitialize(nil);
      SpVoice := CreateOleObject('SAPI.SpVoice');
      // Change FPU interrupt mask to avoid SIGFPE exceptions
      SavedCW := Get8087CW;
      WideSoundString := UTF8ToUTF16(StringReplace(Sound_ID_str, 'TEXT:', '', []));
      try
        Set8087CW(SavedCW or $4);
        SpVoice.Volume := 100;
        SpVoice.Rate := 0;
        SpVoice.Speak(WideSoundString, 0);
        CoUnInitialize;
      finally
        // Restore FPU mask
        Set8087CW(SavedCW);
      end;
    {$ENDIF}
    end;
    Delete(Sound_Txt, 1, length(Sound_ID_str) + 1);
  until Sound_Txt = '';
  StopSound;
end;

end.

