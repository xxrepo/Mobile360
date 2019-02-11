unit DW.OSDevice.Android;

{*******************************************************}
{                                                       }
{                    Kastri Free                        }
{                                                       }
{          DelphiWorlds Cross-Platform Library          }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

type
  /// <remarks>
  ///   DO NOT ADD ANY FMX UNITS TO THESE FUNCTIONS
  /// </remarks>
  TPlatformOSDevice = record
  public
    class function CheckPermission(const APermission: string): Boolean; static;
    class function GetDeviceName: string; static;
    class function GetPackageID: string; static;
    class function GetPackageVersion: string; static;
    class function GetUniqueDeviceID: string; static;
    class function IsTouchDevice: Boolean; static;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Android
  Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Provider, Androidapi.JNI.Os,  Androidapi.JNI.GraphicsContentViewText;

{ TPlatformOSDevice }

class function TPlatformOSDevice.CheckPermission(const APermission: string): Boolean;
begin
  if TJBuild_VERSION.JavaClass.SDK_INT >= 23 then
    Result := TAndroidHelper.Context.checkSelfPermission(StringToJString(APermission)) = TJPackageManager.JavaClass.PERMISSION_GRANTED
  else
    Result := True;
end;

class function TPlatformOSDevice.GetDeviceName: string;
begin
  Result := JStringToString(TJBuild.JavaClass.MODEL);
  if Result.IsEmpty then
    Result := Format('%s %s', [JStringToString(TJBuild.JavaClass.MANUFACTURER), JStringToString(TJBuild.JavaClass.PRODUCT)]);
end;

class function TPlatformOSDevice.GetPackageID: string;
begin
  Result := JStringToString(TAndroidHelper.Context.getPackageName);
end;

class function TPlatformOSDevice.GetPackageVersion: string;
var
  LPackageInfo: JPackageInfo;
begin
  LPackageInfo := TAndroidHelper.Context.getPackageManager.getPackageInfo(TAndroidHelper.Context.getPackageName, 0);
  Result := JStringToString(LPackageInfo.versionName);
end;

// **** NOTE: Use this value with care, as it is reset if the device is rooted, or wiped
class function TPlatformOSDevice.GetUniqueDeviceID: string;
var
  LName: JString;
begin
  LName := TJSettings_Secure.JavaClass.ANDROID_ID;
  Result := JStringToString(TJSettings_Secure.JavaClass.getString(TAndroidHelper.ContentResolver, LName));
end;

// **** NOTE: Use this value with care, as devices that do not have touch support, but are connected to another screen, will report True
class function TPlatformOSDevice.IsTouchDevice: Boolean;
begin
  Result := TAndroidHelper.Context.getPackageManager.hasSystemFeature(StringToJString('android.hardware.touchscreen'));
end;

end.



