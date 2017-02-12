unit Splash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls;

type

  { TFrm_Splash }

  TFrm_Splash = class(TForm)
    Image1: TImage;
    Label3: TLabel;
    ProgressBar1: TProgressBar;
    Shape1: TShape;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Frm_Splash: TFrm_Splash;
  x: Integer;

implementation

{$R *.lfm}

{ TFrm_Splash }

procedure TFrm_Splash.FormCreate(Sender: TObject);
begin
  x := 1;
end;

procedure TFrm_Splash.Timer1Timer(Sender: TObject);
begin
  if x < 5 then
    begin
      x:= x+1;
      Progressbar1.StepIt;
    end
  else
    Frm_Splash.close;
end;

end.

