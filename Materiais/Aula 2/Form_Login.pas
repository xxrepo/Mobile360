unit Form_Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts;

type
  TFrm_Login = class(TForm)
    Image1: TImage;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabCadastro: TTabItem;
    Label1: TLabel;
    Layout1: TLayout;
    Image2: TImage;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    edt_email: TEdit;
    StyleBook1: TStyleBook;
    Layout3: TLayout;
    Rectangle2: TRectangle;
    edt_senha: TEdit;
    Layout4: TLayout;
    Rectangle3: TRectangle;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Login: TFrm_Login;

implementation

{$R *.fmx}

procedure TFrm_Login.FormCreate(Sender: TObject);
begin
        TabControl.TabPosition := TTabPosition.None;
end;

end.
