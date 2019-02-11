unit DW.Notifications.Android;

// ***************** NOTE **************************
//      THIS UNIT IS CURRENTLY EXPERIMENTAL
//           USE AT YOUR OWN RISK!
//
// It may or may not be removed from the Kastri Free library

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
  Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText,
  // DW
  DW.Notifications, DW.MultiReceiver.Android, DW.Androidapi.JNI.App, DW.Androidapi.JNI.Support;

type
  TNotificationReceiver = class(TMultiReceiver)
  private
    FNotifications: TNotifications;
  protected
    procedure Receive(context: JContext; intent: JIntent); override;
    procedure ConfigureActions; override;
  public
    constructor Create(const ANotifications: TNotifications);
  end;

  TPlatformNotifications = class(TCustomPlatformNotifications)
  private
    FNotificationChannel: JNotificationChannel;
    FNotificationManager: JNotificationManager;
    FNotificationReceiver: TNotificationReceiver;
    FNotificationStore: JSharedPreferences;
    function GetNativeNotification(const ANotification: TNotification): JNotification;
    function GetNotificationPendingIntent(const ANotification: TNotification; const AID: Integer): JPendingIntent;
    function GetUniqueID: Integer;
    function GetNotificationIntent(const ANotification: TNotification): JPendingIntent;
    procedure StoreNotification(const ANotification: TNotification; const AID: Integer);
  protected
    procedure CancelAll; override;
    procedure CancelNotification(const AName: string); override;
    procedure PresentNotification(const ANotification: TNotification); override;
    procedure ScheduleNotification(const ANotification: TNotification); override;
  public
    constructor Create(const ANotifications: TNotifications); override;
    destructor Destroy; override;
  end;

implementation

uses
  // RTL
  System.SysUtils, System.DateUtils, System.TimeSpan,
  // Android
  Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNIBridge, Androidapi.JNI.Net, Androidapi.JNI.Os, Androidapi.JNI.Embarcadero,
  // DW
  DW.OSLog,
  DW.Androidapi.JNI.DWMultiBroadcastReceiver, DW.Android.Helpers;

type
  TOpenNotifications = class(TNotifications);

function DateTimeLocalToUnixMSecGMT(const ADateTime: TDateTime): Int64;
begin
  Result := DateTimeToUnix(ADateTime) * MSecsPerSec - Round(TTimeZone.Local.UtcOffset.TotalMilliseconds);
end;

{ TNotificationReceiver }

constructor TNotificationReceiver.Create(const ANotifications: TNotifications);
begin
  inherited Create(True);
  FNotifications := ANotifications;
end;

procedure TNotificationReceiver.ConfigureActions;
begin
  inherited;
  IntentFilter.addAction(TJDWMultiBroadcastReceiver.JavaClass.ACTION_NOTIFICATION);
end;

procedure TNotificationReceiver.Receive(context: JContext; intent: JIntent);
var
  LNativeNotification: JNotification;
  LNotification: TNotification;
begin
  LNativeNotification := TJNotification.Wrap(intent.getParcelableExtra(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION));
  LNotification.Name := JStringToString(LNativeNotification.extras.getString(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION_NAME));
  LNotification.Title := JCharSequenceToStr(LNativeNotification.extras.getCharSequence(TJNotification.JavaClass.EXTRA_TITLE));
  LNotification.AlertBody := JCharSequenceToStr(LNativeNotification.extras.getCharSequence(TJNotification.JavaClass.EXTRA_TEXT));
  LNotification.Number := LNativeNotification.number;
  LNotification.FireDate := Now;
  LNotification.RepeatInterval := TRepeatInterval(intent.getIntExtra(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION_REPEATINTERVAL, 0));
  TOpenNotifications(FNotifications).DoNotificationReceived(LNotification);
end;

{ TPlatformNotifications }

constructor TPlatformNotifications.Create(const ANotifications: TNotifications);
var
  LService: JObject;
begin
  inherited;
  FNotificationStore := TAndroidHelper.Context.getSharedPreferences(StringToJString(ClassName), TJContext.JavaClass.MODE_PRIVATE);
  LService := TAndroidHelper.Context.getSystemService(TJContext.JavaClass.NOTIFICATION_SERVICE);
  FNotificationManager := TJNotificationManager.Wrap((LService as ILocalObject).GetObjectID);
  if TAndroidHelperEx.CheckBuildAndTarget(TAndroidHelperEx.OREO) then
  begin
    FNotificationChannel := TJNotificationChannel.JavaClass.init(TAndroidHelper.Context.getPackageName, StrToJCharSequence('default'), 4);
    FNotificationChannel.enableLights(True);
    FNotificationChannel.enableVibration(True);
    FNotificationChannel.setLightColor(TJColor.JavaClass.GREEN);
    FNotificationChannel.setLockscreenVisibility(TJNotification.JavaClass.VISIBILITY_PRIVATE);
    FNotificationManager.createNotificationChannel(FNotificationChannel);
  end;
  FNotificationReceiver := TNotificationReceiver.Create(ANotifications);
end;

destructor TPlatformNotifications.Destroy;
begin
  FNotificationStore := nil;
  FNotificationChannel := nil;
  FNotificationManager := nil;
  FNotificationReceiver.Free;
  inherited;
end;

function TPlatformNotifications.GetUniqueID: Integer;
begin
  Result := TJCalendar.JavaClass.getInstance.getTimeInMillis;
end;

function TPlatformNotifications.GetNotificationIntent(const ANotification: TNotification): JPendingIntent;
var
  LIntent: JIntent;
begin
  LIntent := TAndroidHelper.Context.getPackageManager().getLaunchIntentForPackage(TAndroidHelper.Context.getPackageName());
  LIntent.setFlags(TJIntent.JavaClass.FLAG_ACTIVITY_SINGLE_TOP or TJIntent.JavaClass.FLAG_ACTIVITY_CLEAR_TOP);
  Result := TJPendingIntent.JavaClass.getActivity(TAndroidHelper.Context, GetUniqueID, LIntent, TJPendingIntent.JavaClass.FLAG_UPDATE_CURRENT);
end;

function TPlatformNotifications.GetNotificationPendingIntent(const ANotification: TNotification; const AID: Integer): JPendingIntent;
var
  LIntent: JIntent;
  LNotification: JNotification;
begin
  LNotification := GetNativeNotification(ANotification);
  LNotification.extras.putInt(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION_ID, AID);
  LNotification.extras.putString(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION_NAME, StringToJString(ANotification.Name));
  LNotification.extras.putInt(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION_REPEATINTERVAL, Integer(Ord(ANotification.RepeatInterval)));
  LIntent := TJIntent.Create;
  LIntent.setClass(TAndroidHelper.Context, TJDWMultiBroadcastReceiver.getClass);
  LIntent.setAction(TJDWMultiBroadcastReceiver.JavaClass.ACTION_NOTIFICATION);
  LIntent.putExtra(TJDWMultiBroadcastReceiver.JavaClass.EXTRA_NOTIFICATION, TJParcelable.Wrap((LNotification as ILocalObject).GetObjectID));
  Result := TJPendingIntent.JavaClass.getBroadcast(TAndroidHelper.Context, AID, LIntent, TJPendingIntent.JavaClass.FLAG_UPDATE_CURRENT);
end;

function TPlatformNotifications.GetNativeNotification(const ANotification: TNotification): JNotification;
var
  LBuilder: JNotificationCompat_Builder;
begin
  LBuilder := TJNotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context)
    .setDefaults(TJNotification.JavaClass.DEFAULT_LIGHTS)
    .setSmallIcon(TAndroidHelperEx.GetDefaultIconID)
    .setContentTitle(StrToJCharSequence(ANotification.Title))
    .setContentText(StrToJCharSequence(ANotification.AlertBody))
    .setTicker(StrToJCharSequence(ANotification.AlertBody))
    .setContentIntent(GetNotificationIntent(ANotification))
    .setNumber(ANotification.Number)
    .setAutoCancel(True)
    .setWhen(TJDate.Create.getTime);
  if FNotificationChannel <> nil then
    LBuilder := LBuilder.setChannelId(FNotificationChannel.getId);
  if ANotification.EnableSound then
  begin
    if ANotification.SoundName.IsEmpty then
      LBuilder := LBuilder.setSound(TAndroidHelperEx.GetDefaultNotificationSound)
    else
      LBuilder := LBuilder.setSound(StrToJURI(ANotification.SoundName));
  end;
  Result := LBuilder.Build;
end;

procedure TPlatformNotifications.CancelAll;
var
  LIterator: JIterator;
  LKeyObject: JObject;
begin
  LIterator := FNotificationStore.getAll.keySet.iterator;
  while LIterator.hasNext do
  begin
    LKeyObject := LIterator.next;
    if LKeyObject = nil then
      Continue;
    CancelNotification(JStringToString(LKeyObject.toString));
  end;
end;

procedure TPlatformNotifications.CancelNotification(const AName: string);
var
  LID: Integer;
  LIntent: JIntent;
  LPendingIntent: JPendingIntent;
begin
  if not AName.IsEmpty then
  begin
    LID := FNotificationStore.getInt(StringToJString(AName), 0);
    if LID <> 0 then
    begin
      LIntent := TJIntent.Create;
      LIntent.setAction(TJDWMultiBroadcastReceiver.JavaClass.ACTION_NOTIFICATION);
      LPendingIntent := TJPendingIntent.JavaClass.getBroadcast(TAndroidHelper.Context, LID, LIntent, TJPendingIntent.JavaClass.FLAG_UPDATE_CURRENT);
      TAndroidHelper.AlarmManager.cancel(LPendingIntent);
    end;
  end;
end;

procedure TPlatformNotifications.PresentNotification(const ANotification: TNotification);
var
  LNotification: JNotification;
begin
  LNotification := GetNativeNotification(ANotification);
  if ANotification.Name.IsEmpty then
    FNotificationManager.notify(GetUniqueID, LNotification)
  else
    FNotificationManager.notify(StringToJString(ANotification.Name), 0, LNotification);
  LNotification := nil;
end;

procedure TPlatformNotifications.ScheduleNotification(const ANotification: TNotification);
var
  LNotification: JNotification;
  LTime: Int64;
  LPendingIntent: JPendingIntent;
  LID: Int64;
begin
  CancelNotification(ANotification.Name);
  LID := GetUniqueID;
  StoreNotification(ANotification, LID);
  LNotification := GetNativeNotification(ANotification);
  LPendingIntent := GetNotificationPendingIntent(ANotification, LID);
  LTime := DateTimeLocalToUnixMSecGMT(ANotification.FireDate);
  if TOSVersion.Check(6) then
    TAndroidHelper.AlarmManager.setExactAndAllowWhileIdle(TJAlarmManager.JavaClass.RTC_WAKEUP, LTime, LPendingIntent)
  else
    TAndroidHelper.AlarmManager.&set(TJAlarmManager.JavaClass.RTC_WAKEUP, LTime, LPendingIntent);
end;

procedure TPlatformNotifications.StoreNotification(const ANotification: TNotification; const AID: Integer);
var
  LEditor: JSharedPreferences_Editor;
  LName: string;
begin
  if ANotification.Name.IsEmpty then
    LName := AID.ToString
  else
    LName := ANotification.Name;
  LEditor := FNotificationStore.edit;
  try
    LEditor.putInt(StringToJString(LName), AID);
  finally
    LEditor.apply;
  end;
end;

end.
