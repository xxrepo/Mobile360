program Pedidos;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form_Inicial in 'Form_Inicial.pas' {Frm_Inicial},
  Form_MenuPrincipal in 'Form_MenuPrincipal.pas' {Frm_MenuPrincipal},
  Form_Login in 'Form_Login.pas' {Frm_Login},
  Form_Principal in 'Form_Principal.pas' {Frm_Principal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Inicial, Frm_Inicial);
  Application.CreateForm(TFrm_Principal, Frm_Principal);
  Application.Run;
end.
