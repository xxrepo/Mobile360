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
    FlowLayout1: TFlowLayout;
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    VertScrollBox1: TVertScrollBox;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_MenuPrincipal: TFrm_MenuPrincipal;

implementation

{$R *.fmx}

procedure TFrm_MenuPrincipal.FormResize(Sender: TObject);
begin
  if FlowLayout1.ControlsCount > 0 then
    FlowLayout1.Height := FlowLayout1.Controls.Last.BoundsRect.Bottom +5
  else
    FlowLayout1.Height := VertScrollBox1.Height + 5;


end;

end.
