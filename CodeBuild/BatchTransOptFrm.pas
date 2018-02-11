unit BatchTransOptFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TBatchTransOptForm = class(TForm)
    Label1: TLabel;
    SourComboBox: TComboBox;
    Label2: TLabel;
    Dest1ComboBox: TComboBox;
    DoExecuteButton: TButton;
    UsedCacheWithZDBCheckBox: TCheckBox;
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchTransOptForm: TBatchTransOptForm;

implementation

{$R *.dfm}


procedure TBatchTransOptForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TBatchTransOptForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    close;
end;

end.
