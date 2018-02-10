unit BaiduTranslateClient;

interface

{ �ٶȷ���ͻ���֧���ֻ���fmx����֧��fpc }

uses Classes, CoreClasses,
  PascalStrings, UnicodeMixedLib, DoStatusIO, DataFrameEngine, NotifyObjectBase,
  CommunicationFramework;

var
  // ������ַ֧��ipv6
  BaiduTranslateServiceHost: string = '127.0.0.1';
  BaiduTranslateServicePort: Word   = 59813;

type
  TBaiduL = (
    L_auto, // �Զ�
    L_zh,   // ����
    L_en,   // Ӣ��
    L_yue,  // ����
    L_wyw,  // ������
    L_jp,   // ����
    L_kor,  // ����
    L_fra,  // ����
    L_spa,  // ��������
    L_th,   // ̩��
    L_ara,  // ��������
    L_ru,   // ����
    L_pt,   // ��������
    L_de,   // ����
    L_it,   // �������
    L_el,   // ϣ����
    L_nl,   // ������
    L_pl,   // ������
    L_bul,  // ����������
    L_est,  // ��ɳ������
    L_dan,  // ������
    L_fin,  // ������
    L_cs,   // �ݿ���
    L_rom,  // ����������
    L_slo,  // ˹����������
    L_swe,  // �����
    L_hu,   // ��������
    L_cht,  // ��������
    L_vie); // Խ����

  TBaiduTranslate_CompleteProc = reference to procedure(UserData: Pointer; Success, Cached: Boolean; TranslateTime: TTimeTick; sour, dest: TPascalString);

  // ����api
procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: TBaiduL; text: TPascalString;
  UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;
procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: Byte; text: TPascalString;
  UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;
procedure BaiduTranslate(sourLanguage, desLanguage: Byte; text: TPascalString;
  UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;

// ���·����������Cache
procedure UpdateTranslate(sourLanguage, desLanguage: TBaiduL; SourText, DestText: TPascalString); overload;
procedure UpdateTranslate(sourLanguage, desLanguage: Byte; SourText, DestText: TPascalString); overload;

implementation

{$IF Defined(IOS) or Defined(ANDROID) or Defined(OSX)}


uses CommunicationFramework_Client_Indy;

type
  TBaiduTranslateClientBase = TCommunicationFramework_Client_Indy;
{$ELSE}


uses CommunicationFramework_Client_CrossSocket;

type
  TBaiduTranslateClientBase = TCommunicationFramework_Client_CrossSocket;
  {$IFEND}

  TBaiduTranslateClient = class(TBaiduTranslateClientBase)
  public
    constructor Create; override;
    // ���������api
    procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: TBaiduL; text: TPascalString;
      UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;
    procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: Byte; text: TPascalString;
      UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;
    procedure BaiduTranslate(sourLanguage, desLanguage: Byte; text: TPascalString;
      UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc); overload;

    // ���·����������Cache
    procedure UpdateTranslate(sourLanguage, desLanguage: TBaiduL; SourText, DestText: TPascalString); overload;
    procedure UpdateTranslate(sourLanguage, desLanguage: Byte; SourText, DestText: TPascalString); overload;
  end;

constructor TBaiduTranslateClient.Create;
begin
  inherited Create;
  QuietMode := True;
  // ʹ����ǿ����ϵͳ��3�μ�DES�������ܽ��ECB
  SwitchMaxSafe;
end;

procedure TBaiduTranslateClient.BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: TBaiduL; text: TPascalString;
  UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
type
  PUserDef = ^TUserDef;

  TUserDef = record
    sourLanguage, desLanguage: TBaiduL;
    text: TPascalString;
    UserData: Pointer;
    OnResult: TBaiduTranslate_CompleteProc;
    LastTime: TTimeTick;
  end;
var
  p : PUserDef;
  de: TDataFrameEngine;
begin
  if not Connected then
    begin
      OnResult(UserData, False, False, 0, text, '!�������!');
      exit;
    end;

  new(p);
  p^.sourLanguage := sourLanguage;
  p^.desLanguage := desLanguage;
  p^.text := text;
  p^.UserData := UserData;
  p^.OnResult := OnResult;
  p^.LastTime := GetTimeTick;

  de := TDataFrameEngine.Create;
  de.WriteByte(Byte(sourLanguage));
  de.WriteByte(Byte(desLanguage));
  de.WriteString(umlTrimSpace(text));
  de.WriteBool(UsedCache);

  SendStreamCmd('BaiduTranslate', de, p, nil,
    procedure(Sender: TPeerIO; Param1: Pointer; Param2: TObject; InData, ResultData: TDataFrameEngine)
    var
      p2: PUserDef;
      n: TPascalString;
      Cached: Boolean;
    begin
      p2 := Param1;
      if ResultData.Reader.ReadBool then
        begin
          n := ResultData.Reader.ReadString;
          Cached := ResultData.Reader.ReadBool;
          p2^.OnResult(p2^.UserData, True, Cached, GetTimeTick - p2^.LastTime, p2^.text, n);
        end
      else
        begin
          n := '!�������!';
          p2^.OnResult(p2^.UserData, False, False, GetTimeTick - p2^.LastTime, p2^.text, n);
        end;
      dispose(p2);
    end);
end;

procedure TBaiduTranslateClient.BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: Byte; text: TPascalString;
UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
begin
  BaiduTranslate(UsedCache, TBaiduL(sourLanguage), TBaiduL(desLanguage), text, UserData, OnResult);
end;

procedure TBaiduTranslateClient.BaiduTranslate(sourLanguage, desLanguage: Byte; text: TPascalString;
UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
begin
  BaiduTranslate(True, TBaiduL(sourLanguage), TBaiduL(desLanguage), text, UserData, OnResult);
end;

procedure TBaiduTranslateClient.UpdateTranslate(sourLanguage, desLanguage: TBaiduL; SourText, DestText: TPascalString);
var
  de: TDataFrameEngine;
begin
  de := TDataFrameEngine.Create;
  de.WriteByte(Byte(sourLanguage));
  de.WriteByte(Byte(desLanguage));
  de.WriteString(umlTrimSpace(SourText));
  de.WriteString(umlTrimSpace(DestText));

  SendDirectStreamCmd('UpdateTranslate', de);

  disposeObject(de);
end;

procedure TBaiduTranslateClient.UpdateTranslate(sourLanguage, desLanguage: Byte; SourText, DestText: TPascalString);
begin
  UpdateTranslate(TBaiduL(sourLanguage), TBaiduL(desLanguage), SourText, DestText);
end;

type
  TTranslateClient_Th = class(TCoreClassThread)
  protected
    procedure Execute; override;
    procedure SyncCheck;
  end;

var
  tCliThProcessing     : Boolean;
  Client_Th            : TTranslateClient_Th;
  BaiduTranslate_Client: TBaiduTranslateClient;

procedure TTranslateClient_Th.SyncCheck;
begin
  BaiduTranslate_Client.ProgressBackground;

  if BaiduTranslate_Client.Connected then
    if BaiduTranslate_Client.ClientIO <> nil then
      if BaiduTranslate_Client.ClientIO.StopCommunicationTime > 5000 then
        begin
          BaiduTranslate_Client.Wait(2000, procedure(const cState: Boolean)
            begin
            end)
        end;
end;

procedure TTranslateClient_Th.Execute;
begin
  FreeOnTerminate := True;
  while tCliThProcessing do
    begin
      Sleep(10);
      try
          Synchronize(SyncCheck);
      except
      end;
    end;
  Client_Th := nil;
end;

procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: TBaiduL; text: TPascalString; UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
begin
  if not BaiduTranslate_Client.Connected then
    if not BaiduTranslate_Client.Connect(BaiduTranslateServiceHost, BaiduTranslateServicePort) then
      begin
        OnResult(UserData, False, False, 0, text, '!�������!');
        exit;
      end;
  BaiduTranslate_Client.BaiduTranslate(UsedCache, sourLanguage, desLanguage, text, UserData, OnResult);
end;

procedure BaiduTranslate(UsedCache: Boolean; sourLanguage, desLanguage: Byte; text: TPascalString; UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
begin
  BaiduTranslate(UsedCache, TBaiduL(sourLanguage), TBaiduL(desLanguage), text, UserData, OnResult);
end;

procedure BaiduTranslate(sourLanguage, desLanguage: Byte; text: TPascalString; UserData: Pointer; OnResult: TBaiduTranslate_CompleteProc);
begin
  BaiduTranslate(True, TBaiduL(sourLanguage), TBaiduL(desLanguage), text, UserData, OnResult);
end;

procedure UpdateTranslate(sourLanguage, desLanguage: TBaiduL; SourText, DestText: TPascalString);
begin
  if not BaiduTranslate_Client.Connected then
    if not BaiduTranslate_Client.Connect(BaiduTranslateServiceHost, BaiduTranslateServicePort) then
        exit;
  BaiduTranslate_Client.UpdateTranslate(sourLanguage, desLanguage, SourText, DestText);
end;

procedure UpdateTranslate(sourLanguage, desLanguage: Byte; SourText, DestText: TPascalString);
begin
  UpdateTranslate(TBaiduL(sourLanguage), TBaiduL(desLanguage), SourText, DestText);
end;

initialization

BaiduTranslate_Client := TBaiduTranslateClient.Create;
tCliThProcessing := True;
Client_Th := TTranslateClient_Th.Create(False);

finalization

tCliThProcessing := False;
while Client_Th <> nil do
    Classes.CheckSynchronize(1);
disposeObject(BaiduTranslate_Client);

end.
