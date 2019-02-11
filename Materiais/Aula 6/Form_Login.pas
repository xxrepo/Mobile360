unit Form_Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts,
  System.Actions, FMX.ActnList;

type
  TFrm_Login = class(TForm)
    Image1: TImage;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabCadastro: TTabItem;
    lbl_rodape: TLabel;
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
    Label4: TLabel;
    Label5: TLabel;
    Layout5: TLayout;
    Image3: TImage;
    Layout6: TLayout;
    Rectangle4: TRectangle;
    edt_nome_cad: TEdit;
    Layout7: TLayout;
    Rectangle5: TRectangle;
    edt_senha_cad: TEdit;
    Layout8: TLayout;
    Rectangle6: TRectangle;
    Label6: TLabel;
    Layout9: TLayout;
    Rectangle7: TRectangle;
    edt_email_cad: TEdit;
    ActionList1: TActionList;
    ActTabLogin: TChangeTabAction;
    ActTabCadastro: TChangeTabAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbl_rodapeClick(Sender: TObject);
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

procedure TFrm_Login.FormShow(Sender: TObject);
begin
        if TabControl.ActiveTab = TabLogin then
                lbl_rodape.Text := 'Não tem cadastro? Criar nova conta.'
        else
                lbl_rodape.Text := 'Já tem uma conta? Faça o login aqui.';
end;

procedure TFrm_Login.lbl_rodapeClick(Sender: TObject);
begin
        if TabControl.ActiveTab = TabLogin then
        begin
                ActTabCadastro.ExecuteTarget(sender);
                lbl_rodape.Text := 'Já tem uma conta? Faça o login aqui.';
        end
        else
        begin
                ActTabLogin.ExecuteTarget(sender);
                lbl_rodape.Text := 'Não tem cadastro? Criar nova conta.'
        end;
end;

end.
