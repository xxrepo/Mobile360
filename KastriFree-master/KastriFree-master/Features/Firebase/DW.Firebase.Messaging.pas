unit DW.Firebase.Messaging;

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
  System.Classes, System.Messaging, System.SysUtils;

type
  TFirebaseMessageReceivedEvent = procedure(Sender: TObject; const APayload: TStrings) of object;
  TFirebaseTokenReceivedEvent = procedure(Sender: TObject; const AToken: string) of object;

  TFirebaseMessaging = class;

  TCustomPlatformFirebaseMessaging = class(TObject)
  private
    FFirebaseMessaging: TFirebaseMessaging;
    FIsConnected: Boolean;
    FIsForeground: Boolean;
    FWasConnected: Boolean;
  protected
    procedure ApplicationBecameActive;
    procedure ApplicationEnteredBackground;
    procedure Connect; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure DoApplicationBecameActive; virtual;
    procedure DoApplicationEnteredBackground; virtual;
    procedure DoAuthorizationResult(const AGranted: Boolean);
    procedure DoException(const AException: Exception);
    procedure DoMessageReceived(const APayload: TStrings);
    procedure DoTokenReceived(const AToken: string);
    function GetDeviceToken: string; virtual;
    procedure RequestAuthorization; virtual; abstract;
    procedure SubscribeToTopic(const ATopicName: string); virtual; abstract;
    function Start: Boolean; virtual;
    procedure UnsubscribeFromTopic(const ATopicName: string); virtual; abstract;
    property IsConnected: Boolean read FIsConnected write FIsConnected;
    property IsForeground: Boolean read FIsForeground write FIsForeground;
  public
    constructor Create(const AFirebaseMessaging: TFirebaseMessaging); virtual;
    destructor Destroy; override;
  end;

  TAuthorizationResultEvent = procedure(Sender: TObject; const Granted: Boolean) of object;

  TFirebaseMessaging = class(TObject)
  private
    FIsActive: Boolean;
    FPlatformFirebaseMessaging: TCustomPlatformFirebaseMessaging;
    FToken: string;
    FOnAuthorizationResult: TAuthorizationResultEvent;
    FOnMessageReceived: TFirebaseMessageReceivedEvent;
    FOnTokenReceived: TFirebaseTokenReceivedEvent;
    procedure ApplicationEventMessageHandler(const Sender: TObject; const M: TMessage);
    function GetDeviceToken: string;
    function GetIsConnected: Boolean;
    procedure PushFailToRegisterMessageHandler(const Sender: TObject; const M: TMessage);
    procedure PushRemoteNotificationMessageHandler(const Sender: TObject; const M: TMessage);
  protected
    procedure DoAuthorizationResult(const AGranted: Boolean);
    procedure DoMessageReceived(const APayload: TStrings);
    procedure DoTokenReceived(const AToken: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    procedure RequestAuthorization;
    procedure SubscribeToTopic(const ATopicName: string);
    function Start: Boolean;
    procedure UnsubscribeFromTopic(const ATopicName: string);
    property DeviceToken: string read GetDeviceToken;
    property IsActive: Boolean read FIsActive;
    property IsConnected: Boolean read GetIsConnected;
    property Token: string read FToken;
    property OnAuthorizationResult: TAuthorizationResultEvent read FOnAuthorizationResult write FOnAuthorizationResult;
    property OnMessageReceived: TFirebaseMessageReceivedEvent read FOnMessageReceived write FOnMessageReceived;
    property OnTokenReceived: TFirebaseTokenReceivedEvent read FOnTokenReceived write FOnTokenReceived;
  end;

implementation

uses
  // FMX
  FMX.Platform,
  DW.OSLog,
  {$IF Defined(IOS)}
  DW.Firebase.Messaging.iOS;
  {$ELSEIF Defined(ANDROID)}
  DW.Firebase.Messaging.Android;
  {$ELSE}
  DW.Firebase.Default;
  {$ENDIF}

{ TCustomPlatformFirebaseMessaging }

constructor TCustomPlatformFirebaseMessaging.Create(const AFirebaseMessaging: TFirebaseMessaging);
begin
  inherited Create;
  FFirebaseMessaging := AFirebaseMessaging;
end;

destructor TCustomPlatformFirebaseMessaging.Destroy;
begin
  //
  inherited;
end;

procedure TCustomPlatformFirebaseMessaging.DoException(const AException: Exception);
begin
  //
end;

procedure TCustomPlatformFirebaseMessaging.ApplicationBecameActive;
begin
  FIsForeground := True;
  if FWasConnected then
    Connect;
  DoApplicationBecameActive;
end;

procedure TCustomPlatformFirebaseMessaging.ApplicationEnteredBackground;
begin
  FIsForeground := False;
  FWasConnected := IsConnected;
  Disconnect;
end;

procedure TCustomPlatformFirebaseMessaging.DoApplicationBecameActive;
begin
  //
end;

procedure TCustomPlatformFirebaseMessaging.DoApplicationEnteredBackground;
begin
  //
end;

procedure TCustomPlatformFirebaseMessaging.DoAuthorizationResult(const AGranted: Boolean);
begin
  FFirebaseMessaging.DoAuthorizationResult(AGranted);
end;

procedure TCustomPlatformFirebaseMessaging.DoMessageReceived(const APayload: TStrings);
begin
  FFirebaseMessaging.DoMessageReceived(APayload);
end;

procedure TCustomPlatformFirebaseMessaging.DoTokenReceived(const AToken: string);
begin
  FFirebaseMessaging.DoTokenReceived(AToken);
end;

function TCustomPlatformFirebaseMessaging.GetDeviceToken: string;
begin
  Result := '';
end;

function TCustomPlatformFirebaseMessaging.Start: Boolean;
begin
  Result := False;
end;

{ TFirebaseMessaging }

constructor TFirebaseMessaging.Create;
begin
  inherited;
  FPlatformFirebaseMessaging := TPlatformFirebaseMessaging.Create(Self);
  TMessageManager.DefaultManager.SubscribeToMessage(TApplicationEventMessage, ApplicationEventMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TPushFailToRegisterMessage, PushFailToRegisterMessageHandler);
  TMessageManager.DefaultManager.SubscribeToMessage(TPushRemoteNotificationMessage, PushRemoteNotificationMessageHandler);
end;

destructor TFirebaseMessaging.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TApplicationEventMessage, ApplicationEventMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TPushFailToRegisterMessage, PushFailToRegisterMessageHandler);
  TMessageManager.DefaultManager.Unsubscribe(TPushRemoteNotificationMessage, PushRemoteNotificationMessageHandler);
  FPlatformFirebaseMessaging.Free;
  inherited;
end;

procedure TFirebaseMessaging.Connect;
begin
  FPlatformFirebaseMessaging.Connect;
end;

procedure TFirebaseMessaging.Disconnect;
begin
  FPlatformFirebaseMessaging.Disconnect;
end;

procedure TFirebaseMessaging.DoAuthorizationResult(const AGranted: Boolean);
begin
  if Assigned(FOnAuthorizationResult) then
    FOnAuthorizationResult(Self, AGranted);
end;

procedure TFirebaseMessaging.DoMessageReceived(const APayload: TStrings);
begin
  if Assigned(FOnMessageReceived) then
    FOnMessageReceived(Self, APayload);
end;

procedure TFirebaseMessaging.DoTokenReceived(const AToken: string);
begin
  if not AToken.Equals(FToken) then
  begin
    FToken := AToken;
    TOSLog.d('FCM Token: %s', [FToken]);
    if Assigned(FOnTokenReceived) then
      FOnTokenReceived(Self, AToken);
  end;
end;

function TFirebaseMessaging.GetDeviceToken: string;
begin
  Result := FPlatformFirebaseMessaging.GetDeviceToken;
end;

function TFirebaseMessaging.GetIsConnected: Boolean;
begin
  Result := FPlatformFirebaseMessaging.IsConnected;
end;

procedure TFirebaseMessaging.ApplicationEventMessageHandler(const Sender: TObject; const M: TMessage);
begin
  case TApplicationEventMessage(M).Value.Event of
    TApplicationEvent.BecameActive:
      FPlatformFirebaseMessaging.ApplicationBecameActive;
    TApplicationEvent.EnteredBackground:
      FPlatformFirebaseMessaging.ApplicationEnteredBackground;
  end;
end;

procedure TFirebaseMessaging.PushFailToRegisterMessageHandler(const Sender: TObject; const M: TMessage);
begin

end;

procedure TFirebaseMessaging.PushRemoteNotificationMessageHandler(const Sender: TObject; const M: TMessage);
var
  LPayload: TStrings;
  LJSON: string;
begin
  LPayload := TStringList.Create;
  try
    if (M is TPushRemoteNotificationMessage) then
      LJSON := (M as TPushRemoteNotificationMessage).Value.Notification
    else if (M is TPushStartupNotificationMessage) then
      LJSON := (M as TPushStartupNotificationMessage).Value.Notification
    else
      LJSON := '';
    if LJSON <> '' then
    begin
      LPayload.Text := LJSON; // TODO: Formatting?
      DoMessageReceived(LPayload);
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TFirebaseMessaging.RequestAuthorization;
begin
  FPlatformFirebaseMessaging.RequestAuthorization;
end;

function TFirebaseMessaging.Start: Boolean;
begin
  Result := FIsActive;
  if not Result then
    Result := FPlatformFirebaseMessaging.Start;
  FIsActive := Result;
end;

procedure TFirebaseMessaging.SubscribeToTopic(const ATopicName: string);
begin
  FPlatformFirebaseMessaging.SubscribeToTopic(ATopicName);
end;

procedure TFirebaseMessaging.UnsubscribeFromTopic(const ATopicName: string);
begin
  FPlatformFirebaseMessaging.UnsubscribeFromTopic(ATopicName);
end;

end.
