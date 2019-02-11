unit DW.Toast.Android;

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
  // Android
  Androidapi.JNI.Os, Androidapi.JNI.JavaTypes, Androidapi.JNIBridge;

type
  TToast = class(TJavaLocal, JRunnable)
  private
    class var FToast: TToast;
    class destructor DestroyToast;
  private
    FHandler: JHandler;
    FMsg: string;
    FShort: Boolean;
  public
    { JRunnable }
    procedure run; cdecl;
  public
    /// <summary>
    ///   Convenience equivalent of MakeToast
    /// </summary>
    class procedure Make(const AMsg: string; const AShort: Boolean);
  public
    constructor Create;
    /// <summary>
    ///   Shows a toast with the message provided, for the length specified
    /// </summary>
    procedure MakeToast(const AMsg: string; const AShort: Boolean);
  end;

implementation

uses
  // Android
  Androidapi.Helpers,
  // DW
  DW.Androidapi.JNI.Toast;

{ TToast }

constructor TToast.Create;
begin
  inherited;
  FHandler := TJHandler.JavaClass.init(TJLooper.JavaClass.getMainLooper);
end;

class destructor TToast.DestroyToast;
begin
  FToast.Free;
end;

class procedure TToast.Make(const AMsg: string; const AShort: Boolean);
begin
  if FToast = nil then
    FToast := TToast.Create;
  FToast.MakeToast(AMsg, AShort);
end;

procedure TToast.MakeToast(const AMsg: string; const AShort: Boolean);
begin
  FMsg := AMsg;
  FShort := AShort;
  FHandler.post(Self);
end;

procedure TToast.run;
var
  LToastLength: Integer;
begin
  if FShort then
    LToastLength := TJToast.JavaClass.LENGTH_SHORT
  else
    LToastLength := TJToast.JavaClass.LENGTH_LONG;
  TJToast.JavaClass.makeText(TAndroidHelper.Context.getApplicationContext, StrToJCharSequence(FMsg), LToastLength).show;
end;

end.
