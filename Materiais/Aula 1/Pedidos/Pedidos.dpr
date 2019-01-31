program Pedidos;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form_Inicial in 'Form_Inicial.pas' {Frm_Inicial};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Inicial, Frm_Inicial);
  Application.Run;
end.
