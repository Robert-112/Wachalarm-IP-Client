unit Anzeige;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, pingsend;

{ Ping-Thread Deklaration }

Type
  Ping_TShowStatusEvent = procedure(Ping_Status: Boolean) of Object;
  Ping_Thread = class(TThread)
  private
    Ping_Status: Boolean;
    Ping_IP: String;
    Ping_FOnShowStatus: Ping_TShowStatusEvent;
    procedure ShowStatus;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
    property Ping_OnShowStatus: Ping_TShowStatusEvent read Ping_FOnShowStatus write Ping_FOnShowStatus;
  end;

{ TFrm_Anzeige Deklaration }

  TFrm_Anzeige = class(TForm)
    I_Alarmbild: TImage;
    L_LongDate: TLabel;
    L_Clock: TLabel;
    L_Infotext: TLabel;
    Panel_AllePanels: TPanel;
    Panel_L_Date: TPanel;
    Panel_L_Clock: TPanel;
    Panel_Zeit: TPanel;
    Panel_Infotext: TPanel;
    Timer_Infotextanzeigen: TTimer;
    Timer_AktuelleUhrzeit: TTimer;
    Timer_UhrVerschieben: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure I_AlarmbildDblClick(Sender: TObject);
    procedure L_ClockDblClick(Sender: TObject);
    procedure L_InfotextDblClick(Sender: TObject);
    procedure L_LongDateDblClick(Sender: TObject);
    procedure Panel_AllePanelsDblClick(Sender: TObject);
    procedure Panel_InfotextDblClick(Sender: TObject);
    procedure Panel_InfotextResize(Sender: TObject);
    procedure Panel_L_ClockDblClick(Sender: TObject);
    procedure Panel_L_ClockResize(Sender: TObject);
    procedure Panel_L_DateDblClick(Sender: TObject);
    procedure Panel_L_DateResize(Sender: TObject);
    procedure Panel_ZeitDblClick(Sender: TObject);
    procedure Timer_AktuelleUhrzeitTimer(Sender: TObject);
    procedure Timer_InfotextanzeigenTimer(Sender: TObject);
    procedure Timer_UhrVerschiebenTimer(Sender: TObject);
    procedure ReCalculate_Form;
    procedure DatumUhrzeit_setzen;
    procedure Nur_Zeit_anzeigen;
    procedure Zeit_und_Infotext_anzeigen(Minuten: integer; Infotext: String);
    procedure Uhr_verschieben;
    procedure DoPing;
  private
    { private declarations }
    MyPing_Thread: Ping_Thread;
    procedure Ping_ServerStatus(Status: Boolean);
  public
    { public declarations }
  end; 

var
  Frm_Anzeige: TFrm_Anzeige;
  Old_Screen_Width, Old_Screen_Height, Connect_Error, Ping_Timer: Integer;
  Slash, Dir: String;

implementation

uses
  Main;

{$R *.lfm}

{==============================================================================}
{=========== TFrm_Anzeige =====================================================}
{==============================================================================}

procedure TFrm_Anzeige.FormCreate(Sender: TObject);
var MonitorNr: integer;
begin
  // Counter für Verbindungsfehler, bei start auf 1 nicht auf 0
  Connect_Error := -1;
  // Counter für Ping-Interval
  Ping_Timer := 0;
  //Anzeige über ganzen Monitor ausrichten
  MonitorNr := Frm_Main.SP_Alarmbild_Monitor.Value - 1;
  Frm_Anzeige.Left := Screen.Monitors[MonitorNr].Left;
  Frm_Anzeige.Top := Screen.Monitors[MonitorNr].Top;
  Frm_Anzeige.WindowState := wsmaximized;
  Old_Screen_Width := Screen.Width;
  Old_Screen_Height := Screen.Height;
  Frm_Anzeige.Width := Old_Screen_Width;
  Frm_Anzeige.Height := Old_Screen_Height;
  // Schriftart DejaVu Sans Mono setzen, sofern vorhanden, sonst default
  if Screen.Fonts.IndexOf('DejaVu Sans') <> -1 then
  begin
    L_Clock.Font.Name := 'DejaVu Sans';
    L_LongDate.Font.Name := 'DejaVu Sans';
    L_Infotext.Font.Name := 'DejaVu Sans';
  end;
  // Uhrzeit ermitteln und anzeigen
  DatumUhrzeit_setzen;
  Nur_Zeit_anzeigen;
  Uhr_verschieben;
  // DoubleBuffered setzen um Grafik zu verbessern, benötigt RAM
  Frm_Anzeige.DoubleBuffered := true;
  If Frm_Main.CB_Show_Clock.Checked = true then
  begin
    Frm_Anzeige.Show;
    Frm_Main.A_Uhr_anzeigen.Enabled := true;
  end;
end;

procedure TFrm_Anzeige.ReCalculate_Form;
begin
  Uhr_verschieben;
  if Frm_Anzeige.Panel_Infotext.Showing then
    Zeit_und_Infotext_anzeigen(Timer_Infotextanzeigen.Interval div 60000,L_Infotext.Caption)
  else
    Nur_Zeit_anzeigen;
end;

procedure TFrm_Anzeige.DatumUhrzeit_setzen;
begin
  // Uhrzeit setzen
  Frm_Anzeige.L_Clock.Caption := FormatDateTime('hh:nn:ss', now);
  // Datum setzen, falls Verbindung Okay
  {if Connect_Error < 6 then
  begin}
    if Frm_Anzeige.L_LongDate.Caption <> FormatDateTime('dddd, d. mmmm', now) then
    begin
      Frm_Anzeige.L_LongDate.Caption := FormatDateTime('dddd, d. mmmm', now);
      Frm_Anzeige.L_LongDate.Font.Color := clWhite;
      L_LongDate.AdjustFontForOptimalFill;
      L_LongDate.AdjustSize;
    end;
  {end
  else
  // sonst Fehlermeldung anzeigen
  begin
    Frm_Anzeige.L_LongDate.Caption := #$E2#$9A#$A0 + ' Verbindung prüfen ' + #$E2#$9A#$A0;
    Frm_Anzeige.L_LongDate.Font.Color := clRed;
    L_LongDate.AdjustFontForOptimalFill;
    L_LongDate.AdjustSize;
  end;}
end;

procedure TFrm_Anzeige.Nur_Zeit_anzeigen;
begin
  // Infotext-Panel ausblenden
  Frm_Anzeige.Panel_Infotext.Height := 0;
  Frm_Anzeige.Panel_Infotext.Hide;
  Frm_Anzeige.L_Infotext.Caption := '';
  // Panel-Zeit voll ausdehnen
  Frm_Anzeige.Panel_Zeit.Height := Frm_Anzeige.Panel_AllePanels.Height;
  // Uhrzeit und Datum verteilen
  Frm_Anzeige.Panel_L_Clock.Height := Round(Frm_Anzeige.Panel_Zeit.Height * 0.62);
  Frm_Anzeige.Panel_L_Date.Height := Frm_Anzeige.Panel_Zeit.Height - Frm_Anzeige.Panel_L_Clock.Height;
end;

procedure TFrm_Anzeige.Zeit_und_Infotext_anzeigen(Minuten: integer; Infotext: String);
begin
  if Minuten <> 0 then
  begin
    // Timer zurücksetzen
    Frm_Anzeige.Timer_Infotextanzeigen.Enabled := false;  
    // Fläche für Uhrzeit anpassen
    Frm_Anzeige.Panel_Zeit.Height := Round(Frm_Anzeige.Panel_AllePanels.Height * 0.62);
    // Uhrzeit und Datum verteilen
    Frm_Anzeige.Panel_L_Clock.Height := Round(Frm_Anzeige.Panel_Zeit.Height * 0.62);
    Frm_Anzeige.Panel_L_Date.Height := Frm_Anzeige.Panel_Zeit.Height - Frm_Anzeige.Panel_L_Clock.Height;
    // Fläche für Infotext anpassen
    Frm_Anzeige.Panel_Infotext.Height := Frm_Anzeige.Panel_AllePanels.Height - Frm_Anzeige.Panel_Zeit.Height;
    Frm_Anzeige.Panel_Infotext.Show;
    // Infotext hinterlegen und Zeit zum anzeigen setzen
    Frm_Anzeige.L_Infotext.Caption := Infotext;
    Frm_Anzeige.Timer_Infotextanzeigen.Interval := (Minuten * 60000);
    Frm_Anzeige.Timer_Infotextanzeigen.Enabled := true;
  end
  else
    Nur_Zeit_anzeigen;
end;

procedure TFrm_Anzeige.Uhr_verschieben;
var tmp1, tmp2: integer;
begin
  Randomize;
  // Panel für alle Objekte neu ausrichten
  Panel_AllePanels.Align := alNone;
  Panel_AllePanels.Top := 0;
  Panel_AllePanels.Left := 0;
  Panel_AllePanels.Height:=Round(Frm_Anzeige.Height * 0.9);
  Panel_AllePanels.Width:=Round(Frm_Anzeige.Width * 0.9);
  // Maximalen Bewegungsraum für Panel ermitteln
  tmp1 := Frm_Anzeige.Height - Round(Frm_Anzeige.Height * 0.9);
  tmp2 := Frm_Anzeige.Width - Round(Frm_Anzeige.Width * 0.9);
  // Panel per Zufall neu ausrichten
  Panel_AllePanels.Top := Random(tmp1);
  Panel_AllePanels.Left := Random(tmp2);
end;

procedure TFrm_Anzeige.DoPing;
begin
  // Ping-Timer erhöhen, damit Ping nur alle 10 Sekunden ausgeführt wird
  Ping_Timer := Ping_Timer + 1;
  // Ping alle 30 Sekunden
  if (Ping_Timer = 30) then
  begin
    // aber nur falls Server-IP bekannt
    if not (Frm_Main.L_Server_IP.Caption = '') and not (Frm_Main.L_Server_IP.Caption = 'unbekannt') then
    begin
      // Thread für Ping erzeugen
      MyPing_Thread := Ping_Thread.Create(True);
      if Assigned(MyPing_Thread.FatalException) then
        raise MyPing_Thread.FatalException;
      // Variablen an Thread zuweisen
      MyPing_Thread.Ping_OnShowStatus := @Ping_ServerStatus;
      MyPing_Thread.Ping_IP := Frm_Main.L_Server_IP.Caption;
      // UDP-Server starten
      MyPing_Thread.Start;
    end;
    // Ping-Timer zurücksetzen
    Ping_Timer := 0;
  end;
end;

procedure TFrm_Anzeige.Ping_ServerStatus(Status: Boolean);
begin
  // Ping auswerten
  if Status = true then
  begin
    Connect_Error := 0;
    Frm_Main.L_LastServerMsg.Font.Color := clGreen;
    Frm_Main.L_LastServerMsg.Caption := 'Verbindung OK (' + datetostr(date) + '-' + timetostr(time) + ')';
  end
  else
  begin
    // Connect-Error nur hochzählen, wenn Ping bereits einmal Okay war (es könnte ja die Firewall gesperrt sein)
    if Connect_Error >= 0 then
    begin
      Connect_Error := Connect_Error + 1;
      Frm_Main.L_LastServerMsg.Font.Color := clRed;
      Frm_Main.L_LastServerMsg.Caption := 'Verbindung unterbrochen! (' + datetostr(date) + '-' + timetostr(time) + ')';
    end;
  end;
end;

procedure TFrm_Anzeige.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #27 then
    Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.FormResize(Sender: TObject);
begin
  ReCalculate_Form;
end;

procedure TFrm_Anzeige.FormDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.I_AlarmbildDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.L_ClockDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.L_InfotextDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.L_LongDateDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Panel_AllePanelsDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Panel_InfotextDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Panel_InfotextResize(Sender: TObject);
begin
  L_Infotext.AdjustFontForOptimalFill;
  L_Infotext.AdjustSize;
end;

procedure TFrm_Anzeige.Panel_L_ClockDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Panel_L_ClockResize(Sender: TObject);
begin
  L_Clock.AdjustFontForOptimalFill;
  L_Clock.AdjustSize;
end;

procedure TFrm_Anzeige.Panel_L_DateDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Panel_L_DateResize(Sender: TObject);
begin
  L_LongDate.AdjustFontForOptimalFill;
  L_LongDate.AdjustSize;
end;

procedure TFrm_Anzeige.Panel_ZeitDblClick(Sender: TObject);
begin
  Frm_Anzeige.Hide;
end;

procedure TFrm_Anzeige.Timer_AktuelleUhrzeitTimer(Sender: TObject);
begin
  // Bildschirm anpassen, falls änderung in der letzten Sekunde
  if (Screen.Width <> Old_Screen_Width) or (Screen.Height <> Old_Screen_Height) then
  begin
    Old_Screen_Width := Screen.Width;
    Old_Screen_Height := Screen.Height;
    Frm_Anzeige.Width := Old_Screen_Width;
    Frm_Anzeige.Height := Old_Screen_Height;
    ReCalculate_Form;
  end;
  // Datum und Uhrzeit neu setzen
  DatumUhrzeit_setzen;
  // Server anpingen
  DoPing;
end;

procedure TFrm_Anzeige.Timer_InfotextanzeigenTimer(Sender: TObject);
begin
  Nur_Zeit_anzeigen;
  Frm_Anzeige.Timer_Infotextanzeigen.Enabled := false;
end;

procedure TFrm_Anzeige.Timer_UhrVerschiebenTimer(Sender: TObject);
begin
  Uhr_verschieben;
end;

{==============================================================================}
{=========== Ping_Thread ======================================================}
{==============================================================================}

constructor Ping_Thread.Create(CreateSuspended : boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure Ping_Thread.ShowStatus;
begin
  if Assigned(Ping_FOnShowStatus) then
    Ping_FOnShowStatus(Ping_Status);
end;
 
procedure Ping_Thread.Execute;
var
  MyPing: TPingSend;
begin
  Ping_Status := false;
  if Ping_IP <> '' then
  begin
    MyPing := TPingSend.Create;
    try
      Ping_Status := MyPing.Ping(Ping_IP);
    finally
      MyPing.Free;
    end;
    Synchronize(@Showstatus);
  end;
end;

end.

