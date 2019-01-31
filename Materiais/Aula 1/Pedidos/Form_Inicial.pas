unit Form_Inicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts;

type
  TFrm_Inicial = class(TForm)
    layout_wizard: TLayout;
    Layout1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Circle1: TCircle;
    Circle2: TCircle;
    Circle3: TCircle;
    Layout2: TLayout;
    Label3: TLabel;
    Label4: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Inicial: TFrm_Inicial;

implementation

{$R *.fmx}

end.
