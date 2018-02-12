unit LogFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, PascalStrings,
  DoStatusIO;

type
  TLogForm = class(TForm)
    LogMemo: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure DoStatusMethod(AText: SystemString; const ID: integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LogForm: TLogForm;

implementation

{$R *.dfm}


procedure TLogForm.DoStatusMethod(AText: SystemString; const ID: integer);
begin
  if not Visible then
      show;
  LogMemo.Lines.Add(AText);
  Application.ProcessMessages;
end;

procedure TLogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TLogForm.FormCreate(Sender: TObject);
begin
  AddDoStatusHook(Self, DoStatusMethod);
end;

procedure TLogForm.FormDestroy(Sender: TObject);
begin
  DeleteDoStatusHook(Self);
end;

end.
