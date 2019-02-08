program Pedidos;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form_Inicial in 'Form_Inicial.pas' {Frm_Inicial},
  Form_MenuPrincipal in 'Form_MenuPrincipal.pas' {Frm_MenuPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Inicial, Frm_Inicial);
  Application.CreateForm(TFrm_MenuPrincipal, Frm_MenuPrincipal);
  Application.Run;
end.
