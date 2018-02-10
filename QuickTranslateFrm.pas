unit QuickTranslateFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, PascalStrings,
  BaiduTranslateClient, CoreClasses, UnicodeMixedLib;

type
  TQuickTranslateForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    SourMemo: TMemo;
    Dest1Memo: TMemo;
    SourComboBox: TComboBox;
    Dest1ComboBox: TComboBox;
    Label3: TLabel;
    Dest2Memo: TMemo;
    Dest2ComboBox: TComboBox;
    Label4: TLabel;
    Dest3Memo: TMemo;
    Dest3ComboBox: TComboBox;
    Dest1Label: TLabel;
    Dest2Label: TLabel;
    Dest3Label: TLabel;
    UsedSourButton: TButton;
    UsedDest1Button: TButton;
    UsedDest2Button: TButton;
    UsedDest3Button: TButton;
    UsedCacheWithZDBCheckBox: TCheckBox;
    FixedDest1Button: TButton;
    FixedDest2Button: TButton;
    FixedDest3Button: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoComboBoxClick(Sender: TObject);
    procedure UsedSourButtonClick(Sender: TObject);
    procedure UsedDest1ButtonClick(Sender: TObject);
    procedure UsedDest2ButtonClick(Sender: TObject);
    procedure UsedDest3ButtonClick(Sender: TObject);
    procedure FixedDest1ButtonClick(Sender: TObject);
    procedure FixedDest2ButtonClick(Sender: TObject);
    procedure FixedDest3ButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Translate;
  end;

var
  QuickTranslateForm: TQuickTranslateForm;

implementation

{$R *.dfm}


uses StrippedContextFrm;

procedure TQuickTranslateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TQuickTranslateForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_Escape: close;
    VK_F1: StrippedContextForm.UsesSourAction.Execute;
    VK_F2: StrippedContextForm.UsesDest1Action.Execute;
    VK_F3: StrippedContextForm.UsesDest2Action.Execute;
    VK_F4: StrippedContextForm.UsesDest3Action.Execute;
  end;
end;

procedure TQuickTranslateForm.DoComboBoxClick(Sender: TObject);
begin
  Translate;
end;

procedure TQuickTranslateForm.UsedSourButtonClick(Sender: TObject);
begin
  StrippedContextForm.SetCurrentTranslate(SourMemo.Text);
  close;
end;

procedure TQuickTranslateForm.UsedDest1ButtonClick(Sender: TObject);
begin
  StrippedContextForm.SetCurrentTranslate(Dest1Memo.Text);
  close;
end;

procedure TQuickTranslateForm.UsedDest2ButtonClick(Sender: TObject);
begin
  StrippedContextForm.SetCurrentTranslate(Dest2Memo.Text);
  close;
end;

procedure TQuickTranslateForm.UsedDest3ButtonClick(Sender: TObject);
begin
  StrippedContextForm.SetCurrentTranslate(Dest3Memo.Text);
  close;
end;

procedure TQuickTranslateForm.FixedDest1ButtonClick(Sender: TObject);
var
  sour, dest: TPascalString;
begin
  sour := SourMemo.Text;
  while (sour.Len > 0) and (CharIn(sour.Last, [#13, #10])) do
      sour.DeleteLast;

  dest := Dest1Memo.Text;
  while (dest.Len > 0) and (CharIn(dest.Last, [#13, #10])) do
      dest.DeleteLast;

  UpdateTranslate(SourComboBox.ItemIndex, Dest1ComboBox.ItemIndex, sour, dest);
end;

procedure TQuickTranslateForm.FixedDest2ButtonClick(Sender: TObject);
var
  sour, dest: TPascalString;
begin
  sour := SourMemo.Text;
  while (sour.Len > 0) and (CharIn(sour.Last, [#13, #10])) do
      sour.DeleteLast;

  dest := Dest2Memo.Text;
  while (dest.Len > 0) and (CharIn(dest.Last, [#13, #10])) do
      dest.DeleteLast;

  UpdateTranslate(SourComboBox.ItemIndex, Dest2ComboBox.ItemIndex, sour, dest);
end;

procedure TQuickTranslateForm.FixedDest3ButtonClick(Sender: TObject);
var
  sour, dest: TPascalString;
begin
  sour := SourMemo.Text;
  while (sour.Len > 0) and (CharIn(sour.Last, [#13, #10])) do
      sour.DeleteLast;

  dest := Dest3Memo.Text;
  while (dest.Len > 0) and (CharIn(dest.Last, [#13, #10])) do
      dest.DeleteLast;

  UpdateTranslate(SourComboBox.ItemIndex, Dest3ComboBox.ItemIndex, sour, dest);
end;

procedure TQuickTranslateForm.Translate;
begin
  Dest1Label.Font.Color := clRed;
  Dest1Label.Caption := 'Processing...';

  Dest2Label.Font.Color := clRed;
  Dest2Label.Caption := 'Processing...';

  Dest3Label.Font.Color := clRed;
  Dest3Label.Caption := 'Processing...';

  BaiduTranslate(UsedCacheWithZDBCheckBox.Checked, SourComboBox.ItemIndex, Dest1ComboBox.ItemIndex,
    SourMemo.Text, nil, procedure(UserData: Pointer; Success, Cached: Boolean; TranslateTime: TTimeTick; sour, dest: TPascalString)
    begin
      if Success then
          Dest1Memo.Text := dest
      else
          Dest1Memo.Text := '!error!';

      Dest1Label.Font.Color := clGreen;
      Dest1Label.Caption := 'Finished...';

      if Dest2ComboBox.ItemIndex = Dest1ComboBox.ItemIndex then
        begin
          Dest2Memo.Text := Dest1Memo.Text;
          Dest2Label.Font.Color := clGreen;
          Dest2Label.Caption := 'Finished...';
        end
      else
          BaiduTranslate(UsedCacheWithZDBCheckBox.Checked, SourComboBox.ItemIndex, Dest2ComboBox.ItemIndex,
          SourMemo.Text, nil, procedure(UserData: Pointer; Success, Cached: Boolean; TranslateTime: TTimeTick; sour, dest: TPascalString)
          begin
            if Success then
                Dest2Memo.Text := dest
            else
                Dest2Memo.Text := '!error!';

            Dest2Label.Font.Color := clGreen;
            Dest2Label.Caption := 'Finished...';
          end);

      if Dest3ComboBox.ItemIndex = Dest1ComboBox.ItemIndex then
        begin
          Dest3Memo.Text := Dest1Memo.Text;
          Dest3Label.Font.Color := clGreen;
          Dest3Label.Caption := 'Finished...';
        end
      else if Dest3ComboBox.ItemIndex = Dest2ComboBox.ItemIndex then
        begin
          Dest3Memo.Text := Dest2Memo.Text;
          Dest3Label.Font.Color := clGreen;
          Dest3Label.Caption := 'Finished...';
        end
      else
          BaiduTranslate(UsedCacheWithZDBCheckBox.Checked, SourComboBox.ItemIndex, Dest3ComboBox.ItemIndex,
          SourMemo.Text, nil, procedure(UserData: Pointer; Success, Cached: Boolean; TranslateTime: TTimeTick; sour, dest: TPascalString)
          begin
            if Success then
                Dest3Memo.Text := dest
            else
                Dest3Memo.Text := '!error!';
            Dest3Label.Font.Color := clGreen;
            Dest3Label.Caption := 'Finished...';
          end);
    end);
end;

end.
