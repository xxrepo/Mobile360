unit Form_Principal;

interface

uses
  {$IFDEF ANDROID}
  //DW.Firebase.Messaging,
  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, IPPeerClient, REST.Backend.PushTypes, System.JSON,
  System.PushNotification, Data.Bind.Components, Data.Bind.ObjectScope,
  REST.Backend.BindSource, REST.Backend.PushDevice;

type
  TFrm_Principal = class(TForm)
    StyleBook1: TStyleBook;
    LayoutRodape: TLayout;
    TabPedido: TLayout;
    TabCliente: TLayout;
    TabNotificacao: TLayout;
    TabMais: TLayout;
    lblPedidos: TLabel;
    ImgPedido: TImage;
    lblClientes: TLabel;
    lblNotificacoes: TLabel;
    lblMais: TLabel;
    ImgCliente: TImage;
    ImgNotificacoes: TImage;
    ImgMais: TImage;
    Circle1: TCircle;
    Label5: TLabel;
    LayoutTabPedido: TLayout;
    Rectangle1: TRectangle;
    Layout2: TLayout;
    Rectangle2: TRectangle;
    Edit1: TEdit;
    lvPedido: TListView;
    toolbar: TLabel;
    Image1: TImage;
    procedure ImgPedidoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgClienteClick(Sender: TObject);
    procedure ImgNotificacoesClick(Sender: TObject);
    procedure ImgMaisClick(Sender: TObject);
  private
    { Private declarations }
  public
    const OpacidadeSemFoco = 0.2;
    procedure SelecionaTab(Tab:integer);

  //push
  {$IFDEF ANDROID}
 { var
   FFCM:TFirebaseMessaging;
  procedure FCMAuthorizationResultHandler(Sender:TObject; const aGranted:Boolean);
  procedure FCMTokenReceivedHandler(Sender:TObject;const AToken:string);
  procedure FCMMessageReceibedHandle(Sender:TObject;const APayload:Tstrings);  }
  {$ENDIF}


  end;

var
  Frm_Principal: TFrm_Principal;

implementation

{$R *.fmx}

{ TFrm_Principal }

{$IFDEF ANDROID}
{procedure TFrm_Principal.FCMAuthorizationResultHandler(Sender:TObject; const aGranted:Boolean);
begin
 //...
end;

procedure TFrm_Principal.FCMTokenReceivedHandler(Sender:TObject;const AToken:string);
begin
 Edit1.text:= AToken;
 ShowMessage(AToken);
end;

procedure TFrm_Principal.FCMMessageReceibedHandle(Sender:TObject;const APayload:Tstrings);
var
 x:integer;
begin
 for x := 0 to APayload.count -1 do
 begin
  ShowMessage(APayload[x]);
 end;
end;  }
{$ENDIF}


procedure TFrm_Principal.FormShow(Sender: TObject);
begin

 //notificação push..
 {$IFDEF ANDROIND}
{ FFCM: Tfirebasemessaging.Create;
 FFCM.onAutorizationResul:= FCMAuthorizationResultHandler;
 FFCM.OnTokenReceived:= FCMTokenReceivedHandler;
 FFCM.onMenssageReceived:= FCMMessageReceivedHandler;
 FFCM.Connect;}
 {$ENDIF}

 SelecionaTab(1);
end;

procedure TFrm_Principal.ImgClienteClick(Sender: TObject);
begin
 SelecionaTab(2);
end;

procedure TFrm_Principal.ImgMaisClick(Sender: TObject);
begin
 SelecionaTab(4);
end;

procedure TFrm_Principal.ImgNotificacoesClick(Sender: TObject);
begin
 SelecionaTab(3);
end;

procedure TFrm_Principal.ImgPedidoClick(Sender: TObject);
begin
 SelecionaTab(1);
end;

procedure TFrm_Principal.SelecionaTab(Tab: integer);
begin
 ImgPedido.Opacity:= OpacidadeSemFoco;
 ImgCliente.Opacity:= OpacidadeSemFoco;
 ImgNotificacoes.Opacity:= OpacidadeSemFoco;
 ImgMais.Opacity:= OpacidadeSemFoco;

 lblPedidos.TextSettings.FontColor:= $FFBCBCBC;
 lblClientes.FontColor:= $FFBCBCBC;
 lblNotificacoes.FontColor:= $FFBCBCBC;
 lblMais.FontColor:= $FFBCBCBC;

 case tab of
 1:begin
    ImgPedido.Opacity:= 1;
    lblPedidos.FontColor:= TAlphaColorRec.Royalblue;
   end;

 2:begin
    ImgCliente.Opacity:= 1;
    lblClientes.FontColor:= TAlphaColorRec.Royalblue;
   end;

 3:begin
    ImgNotificacoes.Opacity:= 1;
    lblNotificacoes.FontColor:= TAlphaColorRec.Royalblue;
   end;

 4:begin
    ImgMais.Opacity:= 1;
    lblMais.FontColor:= TAlphaColorRec.Royalblue;
   end;
 end;

end;

end.
