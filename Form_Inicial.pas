unit Form_Inicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, Vcl.Graphics;

type
  TFrm_Inicial = class(TForm)
    Layout_wizard: TLayout;
    Layout_Slide1: TLayout;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Layout2: TLayout;
    lblVoltar: TLabel;
    lblProximo: TLabel;
    Layout3: TLayout;
    Layout_Slide2: TLayout;
    Image2: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Layout_Slide3: TLayout;
    Image3: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Layout_Fundo: TLayout;
    Layout1: TLayout;
    Image4: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Button1: TButton;
    Button2: TButton;
    StyleBook1: TStyleBook;
    Layout4: TLayout;
    Circle1: TCircle;
    Circle2: TCircle;
    Circle3: TCircle;
    procedure FormShow(Sender: TObject);
    procedure lblProximoClick(Sender: TObject);
    procedure lblVoltarClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  var
    nSlide:integer;
    procedure TrataSlide(Slide:integer);

  public
    { Public declarations }
  end;

var
  Frm_Inicial: TFrm_Inicial;

implementation

{$R *.fmx}

procedure TFrm_Inicial.Button1Click(Sender: TObject);
begin
//
end;

procedure TFrm_Inicial.Button2Click(Sender: TObject);
begin
///
end;

procedure TFrm_Inicial.FormShow(Sender: TObject);
begin
 nSlide:= 1;
 TrataSlide(nSlide);
end;

procedure TFrm_Inicial.lblProximoClick(Sender: TObject);
begin
 if nSlide>= 4 then
  exit;
 inc(nSlide);
 TrataSlide(nSlide);
end;

procedure TFrm_Inicial.lblVoltarClick(Sender: TObject);
begin
 if nSlide<= 0 then
  exit;
 dec(nSlide);
 TrataSlide(nSlide);
end;

procedure TFrm_Inicial.TrataSlide(Slide:integer);
begin
 case Slide of
 1: begin
      Layout_wizard.Visible:= true;
      Layout_Fundo.Visible:= false;

      Layout_Slide1.Visible:= true;
      Layout_Slide2.Visible:= false;
      Layout_Slide3.Visible:= false;

      Circle1.Fill.Color:= TAlphaColorRec.Dodgerblue;
      Circle2.Fill.Color:= TAlphaColorRec.Silver;
      Circle3.Fill.Color:= TAlphaColorRec.Silver;

      lblVoltar.Visible:= false;
    end;
 2: begin
      Layout_wizard.Visible:= true;
      Layout_Fundo.Visible:= false;
      Layout_Slide1.Visible:= false;
      Layout_Slide2.Visible:= true;
      Layout_Slide3.Visible:= false;

      Circle1.Fill.Color:= TAlphaColorRec.Silver;
      Circle2.Fill.Color:= TAlphaColorRec.Dodgerblue;
      Circle3.Fill.Color:= TAlphaColorRec.Silver;

      lblVoltar.Visible:= true;
    end;
 3: begin
      Layout_wizard.Visible:= true;
      Layout_Fundo.Visible:= false;
      Layout_Slide1.Visible:= false;
      Layout_Slide2.Visible:= false;
      Layout_Slide3.Visible:= true;

      Circle1.Fill.Color:= TAlphaColorRec.Silver;
      Circle2.Fill.Color:= TAlphaColorRec.Silver;
      Circle3.Fill.Color:= TAlphaColorRec.Dodgerblue;

      lblVoltar.Visible:= true;
    end;
 4: begin
      Layout_Fundo.Visible:= true;
      Layout_wizard.Visible:= false;
    end;
 end;

end;


end.
