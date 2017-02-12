program WachalarmIP_Client;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}
    cthreads,
  {$endif}
  Interfaces, Forms, Main, Anzeige, Splash, Funktionen;

{$R *.res}

begin
  Application.Title := 'Wachalarm IP - Client';
  Application.Initialize;
  Application.CreateForm(TFrm_Splash, Frm_Splash);
  Frm_Splash.ShowModal;
  Frm_Splash.Free;
  Frm_Splash := nil;
  Application.ShowMainForm := False;
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.CreateForm(TFrm_Anzeige, Frm_Anzeige);
  Application.Run;
end.

