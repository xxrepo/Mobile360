unit DW.VKVertScrollbox;

{*******************************************************}
{                                                       }
{                    Kastri Free                        }
{                                                       }
{          DelphiWorlds Cross-Platform Library          }
{                                                       }
{*******************************************************}

// ***** NOTE: For Android, this unit should be used only in conjunction with the workaround described here:
//   https://https://github.com/DelphiWorlds/KastriFree/blob/master/Workarounds/RSP-17917.txt
// For an example of how to use this unit, please refer to the demo, here:
//   https://github.com/DelphiWorlds/KastriFree/tree/master/Demos/VKVertScrollbox

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Types, System.Classes, System.Messaging,
  // FMX
  FMX.Layouts, FMX.Controls;

type
  TVertScrollBox = class(FMX.Layouts.TVertScrollBox)
  private
    FCaretPos: TPointF;
    FFocusChanged: Boolean;
    FFocusedControl: TControl;
    FControlsLayout: TControl;
    FRestoreViewport: Boolean;
    FStoredHeight: Single;
    FVKRect: TRect;
    function IsFocusedObject: Boolean;
    function HasCaretPosChanged: Boolean;
    procedure IdleMessageHandler(const Sender: TObject; const M: TMessage);
    procedure MoveControls;
    procedure OrientationChangedMessageHandler(const Sender: TObject; const M: TMessage);
    procedure Restore(const AIgnoreRestoreViewport: Boolean);
    procedure RestoreControls;
    procedure SetControlsLayout(const Value: TControl);
    procedure VKStateChangeMessageHandler(const Sender: TObject; const M: TMessage);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// <summary>
    ///   Call this method when a condition may require control positions to be updated
    /// </summary>
    procedure ControlsChanged;
    /// <summary>
    ///   The layout which will resize in order for the scrollbox to be scrolled
    /// </summary>
    property ControlsLayout: TControl read FControlsLayout write SetControlsLayout;
    /// <summary>
    ///   Determines whether the viewport is restored when the VK disappears
    /// </summary>
    /// <remarks>
    ///   If the user has "scrolled" the view to a certain position before setting focus on a control,
    ///   When the VK is dismissed, the viewport will be set back to its topmost position.
    ///   You will likely never need to set this to True
    /// </remarks>
    property RestoreViewport: Boolean read FRestoreViewport write FRestoreViewport;
  end;

implementation

uses
  // RTL
  System.SysUtils,
{$IF Defined(IOS)}
  // iOS
  iOSapi.Helpers,
{$ENDIF}
  // FMX
  FMX.Forms, FMX.Types, FMX.Edit, FMX.Memo,
  // DW
  DW.VirtualKeyboard.Helpers;

function GetStatusBarHeight: Single;
begin
{$IF Defined(IOS)}
  Result := TiOSHelper.SharedApplication.statusBarFrame.size.height;
{$ELSE}
  Result := 0;
{$ENDIF}
end;

{ TVertScrollBox }

constructor TVertScrollBox.Create(AOwner: TComponent);
begin
  inherited;
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, OrientationChangedMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TVKStateChangeMessage, VKStateChangeMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TIdleMessage, IdleMessageHandler);
end;

destructor TVertScrollBox.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, OrientationChangedMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TVKStateChangeMessage, VKStateChangeMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TIdleMessage, IdleMessageHandler);
  inherited;
end;

procedure TVertScrollBox.ControlsChanged;
begin
  if not FVKRect.IsEmpty then
    MoveControls;
end;

procedure TVertScrollBox.SetControlsLayout(const Value: TControl);
begin
  if Value = FControlsLayout then
    Exit; // <======
  if FControlsLayout <> nil then
    FControlsLayout.RemoveFreeNotification(Self);
  FControlsLayout := Value;
  FControlsLayout.FreeNotification(Self);
end;

procedure TVertScrollBox.VKStateChangeMessageHandler(const Sender: TObject; const M: TMessage);
begin
  if FControlsLayout = nil then
    Exit; // <=======
  FVKRect := TVKStateChangeMessage(M).KeyboardBounds;
  if TVKStateChangeMessage(M).KeyboardVisible then
    MoveControls
  else
    RestoreControls;
end;

function TVertScrollBox.HasCaretPosChanged: Boolean;
var
  LMemo: TCustomMemo;
begin
  Result := False;
  if FFocusedControl is TCustomMemo then
  begin
    LMemo := TCustomMemo(FFocusedControl);
    if LMemo.Caret.Pos.Y <> FCaretPos.Y then
    begin
      Result := True;
      FCaretPos.Y := LMemo.Caret.Pos.Y;
    end;
  end
  else
    FCaretPos := TPointF.Zero;
end;

procedure TVertScrollBox.IdleMessageHandler(const Sender: TObject; const M: TMessage);
begin
  // TIdleMessage is being used to check if the focused control has changed, or a caret position has changed. This may happen without the VK hiding/showing
  if not FVKRect.IsEmpty and (HasCaretPosChanged or not IsFocusedObject) then
  begin
    MoveControls;
    FFocusChanged := True;
  end
  else
    FFocusChanged := False;
end;

function TVertScrollBox.IsFocusedObject: Boolean;
begin
  Result := (Root <> nil) and (Root.Focused <> nil) and (Root.Focused.GetObject = FFocusedControl);
end;

procedure TVertScrollBox.MoveControls;
var
  LOffset: Single;
  LControlBottom: Single;
  LControlPosition: TPointF;
  LMemo: TCustomMemo;
begin
  FFocusedControl := nil;
  if (FControlsLayout = nil) or (Root = nil) or (Root.Focused = nil) or not (Root.Focused.GetObject is TControl) then
    Exit; // <======
  if FStoredHeight = 0 then
    FStoredHeight := FControlsLayout.Height;
  FControlsLayout.Height := Height + FVKRect.Height + ViewportPosition.Y;
  FFocusedControl := TControl(Root.Focused.GetObject);
  // Find control position relative to the layout
  LControlPosition := FFocusedControl.LocalToAbsolute(PointF(0,0));
  LControlPosition.Y := LControlPosition.Y + ViewportPosition.Y;
  // Find the "bottom" of the control
  LControlBottom := 0;
  // For TCustomMemo controls, get the caret position
  if FFocusedControl is TCustomEdit then
    LControlBottom := LControlPosition.Y + FFocusedControl.AbsoluteHeight
  else if FFocusedControl is TCustomMemo then
  begin
    LMemo := TCustomMemo(FFocusedControl);
    LControlBottom := LControlPosition.Y + (LMemo.Caret.Pos.Y - LMemo.ViewportPosition.Y) + LMemo.Caret.size.Height + 4;
  end;
  // + 2 = to give a tiny bit of clearance between the control "bottom" and the VK
  LOffset := (LControlBottom + 2 + GetStatusBarHeight - FVKRect.Top) / Scale.Y;
  if LOffset > 0 then
    ViewportPosition := PointF(0, LOffset);
end;

procedure TVertScrollBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (AComponent = FControlsLayout) and (Operation = TOperation.opRemove) then
    FControlsLayout := nil;
end;

procedure TVertScrollBox.OrientationChangedMessageHandler(const Sender: TObject; const M: TMessage);
begin
  Restore(True);
  if not TVirtualKeyboard.GetBounds.IsEmpty then
  begin
    FVKRect := TVirtualKeyboard.GetBounds;
    MoveControls;
  end;
end;

procedure TVertScrollBox.RestoreControls;
begin
  FVKRect := TRect.Empty;
  if (FControlsLayout = nil) or FFocusChanged then
    Exit; // <======
  Restore(False);
end;

procedure TVertScrollBox.Restore(const AIgnoreRestoreViewport: Boolean);
begin
  if FStoredHeight > 0 then
    FControlsLayout.Height := FStoredHeight;
  FStoredHeight := 0;
  if FRestoreViewport or AIgnoreRestoreViewport then
    ViewportPosition := PointF(0, 0);
end;

end.
