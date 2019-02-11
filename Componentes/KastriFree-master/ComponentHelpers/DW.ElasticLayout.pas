unit DW.ElasticLayout;

{*******************************************************}
{                                                       }
{                    Kastri Free                        }
{                                                       }
{          DelphiWorlds Cross-Platform Library          }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Types,
  // FMX
  FMX.Types, FMX.Controls, FMX.Layouts;

type
  /// <summary>
  ///   Layout that adjusts its size to accomodate the controls within it
  /// </summary>
  /// <remarks>
  ///   Place the unit name *after* FMX.Layouts in the uses clause of the unit where you have layouts that you want to be elastic
  /// </remarks>
  TLayout = class(FMX.Layouts.TLayout)
  private
    FIsElastic: Boolean;
    function GetChildrenOnlyRect: TRectF;
    procedure SetIsElastic(const Value: Boolean);
  protected
    procedure DoRealign; override;
  public
    /// <summary>
    ///   Set this property to True when you want the layout to adjust its size automatically
    /// </summary>
    property IsElastic: Boolean read FIsElastic write SetIsElastic;
  end;

implementation

{ TLayout }

function TLayout.GetChildrenOnlyRect: TRectF;
var
  I: Integer;
  Control: TControl;
  LChildrenRect: TRectF;
begin
  Result := TRectF.Empty;
  if not (ClipChildren or SmallSizeControl) and (Controls <> nil) then
  begin
    for I := GetFirstVisibleObjectIndex to GetLastVisibleObjectIndex - 1 do
    begin
      Control := Controls[I];
      if Control.Visible and not (Control.Align in [TAlignLayout.Contents, TAlignLayout.Client]) then
      begin
        LChildrenRect := Control.ChildrenRect;
        LChildrenRect.Top := LChildrenRect.Top - Control.Margins.Top;
        LChildrenRect.Left := LChildrenRect.Left - Control.Margins.Left;
        LChildrenRect.Bottom := LChildrenRect.Bottom + Control.Margins.Bottom;
        LChildrenRect.Right := LChildrenRect.Right + Control.Margins.Right;
        if Result.IsEmpty then
          Result := LChildrenRect
        else
          UnionRectF(Result, Result, LChildrenRect);
      end;
    end
  end;
end;

procedure TLayout.DoRealign;
var
  LRect: TRectF;
begin
  if FIsElastic then
  begin
    LRect := GetChildrenOnlyRect;
    FDisableAlign := True;
    try
      Width := LRect.Width;
      Height := LRect.Height;
    finally
      FDisableAlign := False;
    end;
  end;
  inherited;
end;

procedure TLayout.SetIsElastic(const Value: Boolean);
begin
  if Value = FIsElastic then
    Exit; // <======
  FIsElastic := Value;
  Realign;
end;

end.
