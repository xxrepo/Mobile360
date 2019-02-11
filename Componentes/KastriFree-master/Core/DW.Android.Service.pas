unit DW.Android.Service;

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
  // RTL/Android
  System.Android.Service;

type
  TLocalServiceConnection = class(System.Android.Service.TLocalServiceConnection)
  public
    class procedure StartForegroundService(const AServiceName: string); static;
  end;

implementation

uses
  System.SysUtils,
  Androidapi.Helpers, AndroidApi.JNI.GraphicsContentViewText,
  DW.Androidapi.JNI.ContextWrapper;

{ TLocalServiceConnection }

class procedure TLocalServiceConnection.StartForegroundService(const AServiceName: string);
var
  LIntent: JIntent;
  LService: string;
begin
  if TOSVersion.Check(8) then
  begin
    LIntent := TJIntent.Create;
    LService := AServiceName;
    if not LService.StartsWith('com.embarcadero.services.') then
      LService := 'com.embarcadero.services.' + LService;
    LIntent.setClassName(TAndroidHelper.Context.getPackageName(), TAndroidHelper.StringToJString(LService));
    TJContextWrapper.Wrap(System.JavaContext).startForegroundService(LIntent);
  end
  else
    StartService(AServiceName);
end;

end.
