program Pedidos;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form_Inicial in 'Form_Inicial.pas' {Frm_Inicial},
  Form_Login in 'Form_Login.pas' {Frm_Login};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Login, Frm_Login);
  Application.CreateForm(TFrm_Inicial, Frm_Inicial);
  Application.Run;
end.
