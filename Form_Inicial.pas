unit Form_Inicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.Gestures;

type
  TFrm_Inicial = class(TForm)
    Layout_Slide1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout_Slide2: TLayout;
    Image2: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Layout_Fundo: TLayout;
    Layout1: TLayout;
    Image4: TImage;
    Label9: TLabel;
    Label10: TLabel;
    BtnCriarNovaConta: TButton;
    btnJaTenhoCadastro: TButton;
    ActionList1: TActionList;
    TabControl: TTabControl;
    Tab1: TTabItem;
    Tab2: TTabItem;
    Tab3: TTabItem;
    Tab4: TTabItem;
    Layout5: TLayout;
    Layout6: TLayout;
    Label3: TLabel;
    Label4: TLabel;
    Layout7: TLayout;
    Layout8: TLayout;
    Circle4: TCircle;
    Circle5: TCircle;
    Circle6: TCircle;
    GestureManager1: TGestureManager;
    Proximo: TChangeTabAction;
    Anterior: TChangeTabAction;
    Image5: TImage;
    Image6: TImage;
    Image8: TImage;
    Layout19: TLayout;
    Layout20: TLayout;
    Label19: TLabel;
    Label20: TLabel;
    Layout21: TLayout;
    Layout22: TLayout;
    Circle13: TCircle;
    Circle14: TCircle;
    Circle15: TCircle;
    Layout23: TLayout;
    Image9: TImage;
    Label21: TLabel;
    Label22: TLabel;
    Image10: TImage;
    Layout2: TLayout;
    Layout3: TLayout;
    Label11: TLabel;
    Label12: TLabel;
    Layout4: TLayout;
    Layout9: TLayout;
    Circle1: TCircle;
    Circle2: TCircle;
    Circle3: TCircle;
    procedure FormShow(Sender: TObject);
    procedure lblProximoClick(Sender: TObject);
    procedure lblVoltarClick(Sender: TObject);
    procedure btnJaTenhoCadastroClick(Sender: TObject);
    procedure BtnCriarNovaContaClick(Sender: TObject);
    procedure ProximoUpdate(Sender: TObject);
    procedure AnteriorUpdate(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  Frm_Inicial: TFrm_Inicial;

implementation

{$R *.fmx}

uses Form_Login, Form_Principal;

procedure TFrm_Inicial.AnteriorUpdate(Sender: TObject);
begin
//23

 if Proximo.Tab = Tab4 then
   exit;
 if TabControl.ActiveTab = Tab1 then
  Anterior.Tab:= nil
 else
 if TabControl.ActiveTab = Tab2 then
  Anterior.Tab:= Tab1
 else
 if TabControl.ActiveTab = Tab3 then
  Anterior.Tab:= Tab2
 else
 if TabControl.ActiveTab = Tab4 then
  Anterior.Tab:= nil;

end;

procedure TFrm_Inicial.BtnCriarNovaContaClick(Sender: TObject);
begin
 application.CreateForm(TFrm_Login,Frm_Login);
 Frm_Login.TabControl.ActiveTab:= Frm_Login.TabCadastro;
 Frm_Login.Show;
end;

procedure TFrm_Inicial.btnJaTenhoCadastroClick(Sender: TObject);
begin
 application.CreateForm(TFrm_Login,Frm_Login);
 Frm_Login.TabControl.ActiveTab:= Frm_Login.TabLogin;
 Frm_Login.Show;
end;

procedure TFrm_Inicial.FormShow(Sender: TObject);
begin
 TabControl.TabPosition:= TTabPosition.None;
end;

procedure TFrm_Inicial.lblProximoClick(Sender: TObject);
begin
 if TabControl.ActiveTab = Tab1 then
  Proximo.Tab:= Tab2
 else
 if TabControl.ActiveTab = Tab2 then
  Proximo.Tab:= Tab3
 else
 if TabControl.ActiveTab = Tab3 then
  Proximo.Tab:= Tab4;

 Proximo.ExecuteTarget(Sender);

end;

procedure TFrm_Inicial.lblVoltarClick(Sender: TObject);
begin
 if TabControl.ActiveTab = Tab1 then
  Anterior.Tab:= nil
 else
 if TabControl.ActiveTab = Tab2 then
  Anterior.Tab:= Tab1
 else
 if TabControl.ActiveTab = Tab3 then
  Anterior.Tab:= Tab2
 else
 if TabControl.ActiveTab = Tab4 then
  Anterior.Tab:= Tab3;

 Anterior.ExecuteTarget(Sender);
end;

procedure TFrm_Inicial.ProximoUpdate(Sender: TObject);
begin
 if TabControl.ActiveTab = Tab1 then
  Proximo.Tab:= Tab2
 else
 if TabControl.ActiveTab = Tab2 then
  Proximo.Tab:= Tab3
 else
 if TabControl.ActiveTab = Tab3 then
  Proximo.Tab:= Tab4;
end;

procedure TFrm_Inicial.TabControlChange(Sender: TObject);
begin
 if TabControl.ActiveTab = tab4 then
  self.Touch.GestureManager:= nil;
end;

end.
