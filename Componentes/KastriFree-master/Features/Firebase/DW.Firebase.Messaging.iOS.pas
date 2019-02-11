unit DW.Firebase.Messaging.iOS;

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
  System.TypInfo, System.Messaging,
  // Mac
  Macapi.ObjectiveC,
  // iOS
  iOSapi.Foundation,
  // DW
  DW.Firebase.Messaging, DW.iOSapi.UserNotifications, DW.iOSapi.Firebase, DW.Notifications;

type
  TPlatformFirebaseMessaging = class;

  TFIRMessagingDelegate = class(TOCLocal, FIRMessagingDelegate)
  private
    FFirebaseMessaging: TPlatformFirebaseMessaging;
    procedure ReceivedMessage(remoteMessage: FIRMessagingRemoteMessage);
  public
    constructor Create(const AFirebaseMessaging: TPlatformFirebaseMessaging);
    procedure applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage); cdecl;
    [MethodName('messaging:didReceiveMessage:')]
    procedure didReceiveMessage(messaging: FIRMessaging; remoteMessage: FIRMessagingRemoteMessage); cdecl;
    [MethodName('messaging:didRefreshRegistrationToken:')]
    procedure didRefreshRegistrationToken(messaging: FIRMessaging; fcmToken: NSString); cdecl;
    [MethodName('messaging:didReceiveRegistrationToken:')]
    procedure didReceiveRegistrationToken(messaging: FIRMessaging; fcmToken: NSString); cdecl;
  end;

  TPlatformFirebaseMessaging = class(TCustomPlatformFirebaseMessaging)
  private
    FAuthOptions: UNAuthorizationOptions;
    FFIRMessagingDelegate: TFIRMessagingDelegate;
    procedure CheckNotificationsAuthorizationHandler(settings: UNNotificationSettings);
    procedure FIRMessagingConnectCompletionHandler(error: NSError);
    function GetUserDefaultsTokenKey: NSString;
    function Messaging: FIRMessaging;
    procedure PushDeviceTokenMessageHandler(const Sender: TObject; const M: TMessage);
    procedure PushStartupNotificationMessageMessageHandler(const Sender: TObject; const M: TMessage);
    procedure RegisterRemoteNotificationsIOS10OrLater;
    procedure RegisterRemoteNotificationsIOS7OrEarlier;
    procedure RegisterRemoteNotificationsIOS8OrLater;
    procedure RequestAuthorizationWithOptionsCompletionHandler(granted: Boolean; error: NSError);
  protected
    procedure Connect; override;
    procedure Disconnect; override;
    procedure DoApplicationBecameActive; override;
    procedure DoApplicationEnteredBackground; override;
    function GetDeviceToken: string; override;
    procedure MessageReceived(const AJSON: string);
    procedure TokenReceived(const AToken: string);
    procedure RequestAuthorization; override;
    procedure SubscribeToTopic(const ATopicName: string); override;
    function Start: Boolean; override;
    procedure UnsubscribeFromTopic(const ATopicName: string); override;
  public
    constructor Create(const AFirebaseMessaging: TFirebaseMessaging); override;
    destructor Destroy; override;
  end;

implementation

uses
  // RTL
  System.SysUtils, System.Classes,
  // Mac
  Macapi.Helpers, Macapi.ObjCRuntime,
  // iOS
  iOSapi.Helpers, iOSapi.UIKit,
  // FMX
  FMX.Platform,
  // DW
  DW.OSLog, DW.Macapi.ObjCRuntime, DW.iOSapi.Helpers, DW.Notifications.iOS;

function StringToNSData(const AString: string): NSData;
begin
  Result := StrToNSStr(AString).dataUsingEncoding(NSUTF8StringEncoding);
end;

{ TFIRMessagingDelegate }

constructor TFIRMessagingDelegate.Create(const AFirebaseMessaging: TPlatformFirebaseMessaging);
begin
  inherited Create;
  FFirebaseMessaging := AFirebaseMessaging;
end;

procedure TFIRMessagingDelegate.applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage);
begin
  ReceivedMessage(remoteMessage);
end;

procedure TFIRMessagingDelegate.didReceiveMessage(messaging: FIRMessaging; remoteMessage: FIRMessagingRemoteMessage);
begin
  ReceivedMessage(remoteMessage);
end;

procedure TFIRMessagingDelegate.didReceiveRegistrationToken(messaging: FIRMessaging; fcmToken: NSString);
begin
  FFirebaseMessaging.TokenReceived(NSStrToStr(fcmToken));
end;

procedure TFIRMessagingDelegate.didRefreshRegistrationToken(messaging: FIRMessaging; fcmToken: NSString);
begin
  FFirebaseMessaging.TokenReceived(NSStrToStr(fcmToken));
end;

procedure TFIRMessagingDelegate.ReceivedMessage(remoteMessage: FIRMessagingRemoteMessage);
begin
  FFirebaseMessaging.MessageReceived(TiOSHelperEx.NSDictionaryToJSON(remoteMessage.appData));
end;

{ TPlatformFirebaseMessaging }

constructor TPlatformFirebaseMessaging.Create(const AFirebaseMessaging: TFirebaseMessaging);
begin
  inherited;
  TMessageManager.DefaultManager.SubscribeToMessage(TPushStartupNotificationMessage, PushStartupNotificationMessageMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TPushDeviceTokenMessage, PushDeviceTokenMessageHandler);
  FFIRMessagingDelegate := TFIRMessagingDelegate.Create(self);
  Messaging.setDelegate(FFIRMessagingDelegate.GetObjectID);
  Start;
end;

destructor TPlatformFirebaseMessaging.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TPushStartupNotificationMessage, PushStartupNotificationMessageMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TPushDeviceTokenMessage, PushDeviceTokenMessageHandler);
  inherited;
end;

function TPlatformFirebaseMessaging.Start: Boolean;
begin
  Result := False;
  try
    TFIRApp.OCClass.configure;
    Result := True;
  except
    on E: Exception do
      DoException(E);
  end;
end;

function TPlatformFirebaseMessaging.GetDeviceToken: string;
begin
  Result := NSStrToStr(TiOSHelperEx.StandardUserDefaults.stringForKey(GetUserDefaultsTokenKey));
end;

function TPlatformFirebaseMessaging.GetUserDefaultsTokenKey: NSString;
begin
  Result := StrToNSStr(NSStrToStr(TiOSHelper.MainBundle.bundleIdentifier) + '.DeviceToken');
end;

procedure TPlatformFirebaseMessaging.PushDeviceTokenMessageHandler(const Sender: TObject; const M: TMessage);
var
  LDeviceToken: string;
begin
  LDeviceToken := TPushDeviceTokenMessage(M).Value.Token;
  TOSLog.d('Received Device Token: %s', [LDeviceToken]);
  TiOSHelperEx.StandardUserDefaults.setObject(NSObjectToID(StrToNSStr(LDeviceToken)), GetUserDefaultsTokenKey);
end;

procedure TPlatformFirebaseMessaging.PushStartupNotificationMessageMessageHandler(const Sender: TObject; const M: TMessage);
begin
  MessageReceived(TPushStartupNotificationMessage(M).Value.Notification);
end;

procedure TPlatformFirebaseMessaging.Connect;
begin
  Disconnect;
  Messaging.connectWithCompletion(FIRMessagingConnectCompletionHandler);
end;

procedure TPlatformFirebaseMessaging.Disconnect;
begin
  Messaging.disconnect;
  IsConnected := False;
end;

procedure TPlatformFirebaseMessaging.DoApplicationBecameActive;
begin
  if TOSVersion.Check(10) then
    Messaging.setShouldEstablishDirectChannel(True);
end;

procedure TPlatformFirebaseMessaging.DoApplicationEnteredBackground;
begin
  if TOSVersion.Check(10) then
    Messaging.setShouldEstablishDirectChannel(False);
end;

procedure TPlatformFirebaseMessaging.FIRMessagingConnectCompletionHandler(error: NSError);
begin
  IsConnected := error = nil;
  if IsConnected then
    TOSLog.d('Connected')
  else
    TOSLog.d('Not Connected!!: %s', [NSStrToStr(error.localizedDescription)]);
end;

procedure TPlatformFirebaseMessaging.TokenReceived(const AToken: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      DoTokenReceived(AToken);
    end
  );
end;

procedure TPlatformFirebaseMessaging.MessageReceived(const AJSON: string);
begin
  TOSLog.d('Incoming Message: %s', [AJSON]);
  TMessageManager.DefaultManager.SendMessage(nil, TPushRemoteNotificationMessage.Create(TPushNotificationData.Create(AJSON)));
end;

procedure TPlatformFirebaseMessaging.RegisterRemoteNotificationsIOS10OrLater;
begin
  UserNotificationCenter.getNotificationSettingsWithCompletionHandler(CheckNotificationsAuthorizationHandler);
  if not TiOSHelperEx.SharedApplication.isRegisteredForRemoteNotifications then
    TiOSHelperEx.SharedApplication.registerForRemoteNotifications;
end;

procedure TPlatformFirebaseMessaging.CheckNotificationsAuthorizationHandler(settings: UNNotificationSettings);
begin
  UserNotificationCenter.requestAuthorizationWithOptions(FAuthOptions, RequestAuthorizationWithOptionsCompletionHandler);
end;

procedure TPlatformFirebaseMessaging.RegisterRemoteNotificationsIOS7OrEarlier;
begin
  TiOSHelper.SharedApplication.registerForRemoteNotificationTypes(Addr(FAuthOptions));
  DoAuthorizationResult(True);
end;

procedure TPlatformFirebaseMessaging.RegisterRemoteNotificationsIOS8OrLater;
var
  LSettings: UIUserNotificationSettings;
begin
  LSettings := TUIUserNotificationSettings.Wrap(TUIUserNotificationSettings.OCClass.settingsForTypes(FAuthOptions, nil));
  TiOSHelper.SharedApplication.registerUserNotificationSettings(LSettings);
  if not TiOSHelperEx.SharedApplication.isRegisteredForRemoteNotifications then
    TiOSHelper.SharedApplication.registerForRemoteNotifications;
  DoAuthorizationResult(True);
end;

procedure TPlatformFirebaseMessaging.RequestAuthorization;
begin
  FAuthOptions := UNAuthorizationOptionSound or UNAuthorizationOptionAlert or UNAuthorizationOptionBadge;
  if TOSVersion.Check(10) then
    RegisterRemoteNotificationsIOS10OrLater
  else if TOSVersion.Check(8) then
    RegisterRemoteNotificationsIOS8OrLater
  else
    RegisterRemoteNotificationsIOS7OrEarlier;
end;

procedure TPlatformFirebaseMessaging.RequestAuthorizationWithOptionsCompletionHandler(granted: Boolean; error: NSError);
begin
  if granted then
    TOSLog.d('Authorization GRANTED')
  else
    TOSLog.d('Authorization NOT GRANTED');
  TThread.Queue(nil,
    procedure
    begin
      DoAuthorizationResult(granted);
    end
  );
end;

function TPlatformFirebaseMessaging.Messaging: FIRMessaging;
begin
  Result := TFIRMessaging.Wrap(TFIRMessaging.OCClass.messaging);
end;

procedure TPlatformFirebaseMessaging.SubscribeToTopic(const ATopicName: string);
begin
  Messaging.subscribeToTopic(StrToNSStr(ATopicName));
end;

procedure TPlatformFirebaseMessaging.UnsubscribeFromTopic(const ATopicName: string);
begin
  Messaging.unsubscribeFromTopic(StrToNSStr(ATopicName));
end;

end.
