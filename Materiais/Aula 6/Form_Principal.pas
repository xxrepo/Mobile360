unit Form_Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  System.ImageList, FMX.ImgList, FMX.Layouts, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  TFrm_Principal = class(TForm)
    StyleBook1: TStyleBook;
    Layout1: TLayout;
    TabPedido: TLayout;
    TabCliente: TLayout;
    TabNotificacao: TLayout;
    TabMais: TLayout;
    lbl_tab_pedido: TLabel;
    img_tab_pedido: TImage;
    lbl_tab_cliente: TLabel;
    lbl_tab_notificacao: TLabel;
    lbl_tab_mais: TLabel;
    img_tab_cliente: TImage;
    img_tab_notificacao: TImage;
    img_tab_mais: TImage;
    circle_notificacao: TCircle;
    Label1: TLabel;
    tab_pedido: TLayout;
    toolbar: TRectangle;
    Layout2: TLayout;
    Rectangle2: TRectangle;
    edt_email: TEdit;
    lv_pedido: TListView;
    Label2: TLabel;
    Image1: TImage;
    procedure img_tab_pedidoClick(Sender: TObject);
    procedure img_tab_clienteClick(Sender: TObject);
    procedure img_tab_notificacaoClick(Sender: TObject);
    procedure img_tab_maisClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Principal: TFrm_Principal;

implementation

{$R *.fmx}

procedure Seleciona_Tab(tab : integer);
begin
        with Frm_Principal do
        begin
                img_tab_pedido.Opacity := 0.2;
                img_tab_cliente.Opacity := 0.2;
                img_tab_notificacao.Opacity := 0.2;
                img_tab_mais.Opacity := 0.2;

                lbl_tab_pedido.FontColor := $FFA0A0A0;
                lbl_tab_cliente.FontColor := $FFA0A0A0;
                lbl_tab_notificacao.FontColor := $FFA0A0A0;
                lbl_tab_mais.FontColor := $FFA0A0A0;


                if tab = 1 then
                begin
                        img_tab_pedido.Opacity := 1;
                        lbl_tab_pedido.FontColor := $FF4D7EC3;
                end;
                if tab = 2 then
                begin
                        img_tab_cliente.Opacity := 1;
                        lbl_tab_cliente.FontColor := $FF4D7EC3;
                end;
                if tab = 3 then
                begin
                        img_tab_notificacao.Opacity := 1;
                        lbl_tab_notificacao.FontColor := $FF4D7EC3;
                end;
                if tab = 4 then
                begin
                        img_tab_mais.Opacity := 1;
                        lbl_tab_mais.FontColor := $FF4D7EC3;
                end;
        end;
end;

procedure TFrm_Principal.img_tab_clienteClick(Sender: TObject);
begin
        Seleciona_Tab(2);
end;

procedure TFrm_Principal.img_tab_maisClick(Sender: TObject);
begin
        Seleciona_Tab(4);
end;

procedure TFrm_Principal.img_tab_notificacaoClick(Sender: TObject);
begin
        Seleciona_Tab(3);
end;

procedure TFrm_Principal.img_tab_pedidoClick(Sender: TObject);
begin
        Seleciona_Tab(1);
end;

end.
