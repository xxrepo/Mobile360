unit Form_MenuPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.MultiView, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts;

type
  TFrm_MenuPrincipal = class(TForm)
    MultiView1: TMultiView;
    Layout1: TLayout;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    ToolBar2: TToolBar;
    MasterButton2: TSpeedButton;
    Layout2: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_MenuPrincipal: TFrm_MenuPrincipal;

implementation

{$R *.fmx}

end.
