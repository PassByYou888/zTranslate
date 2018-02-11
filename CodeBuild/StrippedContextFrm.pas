unit StrippedContextFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList,
  Vcl.StdCtrls,

  System.Math,

  TextTable, DataFrameEngine, CoreClasses, ListEngine, DoStatusIO, MemoryStream64,
  UnicodeMixedLib, QuickTranslateFrm, TextParsing, SynHighlighterCpp,
  SynEditHighlighter, SynHighlighterPas, SynEdit, PascalStrings, LogFrm;

type
  TEditorReturnProc = procedure(tb: TTextTable) of object;

  TStrippedContextForm = class(TForm)
    ToolWindowMainMenu: TMainMenu;
    ContextListPopupMenu: TPopupMenu;
    CategoryPopupMenu: TPopupMenu;
    ActionList: TActionList;
    File1: TMenuItem;
    Edit1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    RefreshAction: TAction;
    SaveToFileAction: TAction;
    LoadFromFileAction: TAction;
    ImportTextAction: TAction;
    ExportTextAction: TAction;
    OpenTextDialog: TOpenDialog;
    SaveTextDialog: TSaveDialog;
    LoadfromFile1: TMenuItem;
    SavetoFile1: TMenuItem;
    N1: TMenuItem;
    ImportText1: TMenuItem;
    ExportText1: TMenuItem;
    Refresh1: TMenuItem;
    ExitAction: TAction;
    N2: TMenuItem;
    Exit1: TMenuItem;
    SelectAllAction: TAction;
    InvSelectedAction: TAction;
    Selectall1: TMenuItem;
    invselect1: TMenuItem;
    MarkPickedAction: TAction;
    MarkUnPickedAction: TAction;
    Picked1: TMenuItem;
    UnPicked1: TMenuItem;
    Refresh2: TMenuItem;
    Selectall2: TMenuItem;
    invselect2: TMenuItem;
    Picked2: TMenuItem;
    UnPicked2: TMenuItem;
    TestAction: TAction;
    Selectall3: TMenuItem;
    invselect3: TMenuItem;
    Picked3: TMenuItem;
    UnPicked3: TMenuItem;
    TopSplitter: TSplitter;
    ShowOriginContextAction: TAction;
    ShowOrigincontext1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ShowOrigincontext2: TMenuItem;
    RestoreTranslationOriginAction: TAction;
    RestoreTranslation1: TMenuItem;
    RestoreTranslation2: TMenuItem;
    TopPanel: TPanel;
    TopRightSplitter: TSplitter;
    topRightPanel: TPanel;
    topRightTopPanel: TPanel;
    Label1: TLabel;
    UndoButton: TButton;
    SaveTextButton: TButton;
    DefineMemo: TMemo;
    ClientPanel: TPanel;
    LeftSplitter: TSplitter;
    CategoryList: TListView;
    ContextPanel: TPanel;
    ContextList: TListView;
    ContextTopPanel: TPanel;
    OriginFilterEdit: TLabeledEdit;
    DefineFilterEdit: TLabeledEdit;
    ools1: TMenuItem;
    QuickTranslateAction: TAction;
    QuickTranslate1: TMenuItem;
    QuickTranslateButton: TButton;
    EditorReturnAction: TAction;
    ReturntoCodeBuild1: TMenuItem;
    CodeEdit: TSynEdit;
    SynPasSyn: TSynPasSyn;
    SynCppSyn: TSynCppSyn;
    UsesSourAction: TAction;
    UsesDest1Action: TAction;
    UsesDest2Action: TAction;
    UsesDest3Action: TAction;
    NoDialogBatchTranslateAction: TAction;
    UsedSourceF11: TMenuItem;
    UsesDest11: TMenuItem;
    UsesDest21: TMenuItem;
    UsesDest31: TMenuItem;
    Batchtranslate1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Batchtranslate2: TMenuItem;
    N7: TMenuItem;
    BatchTranslateAction: TAction;
    Batchtranslate3: TMenuItem;
    Batchtranslate4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefreshActionExecute(Sender: TObject);
    procedure SaveToFileActionExecute(Sender: TObject);
    procedure LoadFromFileActionExecute(Sender: TObject);
    procedure ImportTextActionExecute(Sender: TObject);
    procedure ExportTextActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure SelectAllActionExecute(Sender: TObject);
    procedure InvSelectedActionExecute(Sender: TObject);
    procedure MarkPickedActionExecute(Sender: TObject);
    procedure MarkUnPickedActionExecute(Sender: TObject);
    procedure ShowOriginContextActionExecute(Sender: TObject);
    procedure TestActionExecute(Sender: TObject);
    procedure ContextListColumnClick(Sender: TObject; Column: TListColumn);
    procedure ContextListItemChecked(Sender: TObject; Item: TListItem);
    procedure ContextListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure CategoryListItemChecked(Sender: TObject; Item: TListItem);
    procedure FilterEditChange(Sender: TObject);
    procedure RestoreTranslationOriginActionExecute(Sender: TObject);
    procedure QuickTranslateActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditorReturnActionExecute(Sender: TObject);
    procedure SaveTextButtonClick(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);
    procedure UsesSourActionExecute(Sender: TObject);
    procedure UsesDest1ActionExecute(Sender: TObject);
    procedure UsesDest2ActionExecute(Sender: TObject);
    procedure UsesDest3ActionExecute(Sender: TObject);
    procedure DefineMemoChange(Sender: TObject);
    procedure NoDialogBatchTranslateActionExecute(Sender: TObject);
    procedure BatchTranslateActionExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FTextData       : TTextTable;
    FOpenListItm    : TListItem;
    FOpenPtr        : PTextTableItem;
    FOpenPtrIsModify: Boolean;
    FOnReturnProc   : TEditorReturnProc;

    function GetOpenEditorOriginText(p: PTextTableItem): string;
    procedure OpenTextEditor(p: PTextTableItem; itm: TListItem);
    procedure SaveTextEditor;
    procedure SetOnReturnProc(const Value: TEditorReturnProc);
  public
    property OnReturnProc: TEditorReturnProc read FOnReturnProc write SetOnReturnProc;

    procedure LoadNewCTFromStream(m64: TMemoryStream64);
    procedure NewCT;

    function ExistsCategory(c: string): Boolean;
    function CategoryIsSelected(c: string): Boolean;
    procedure RefreshTextList(rebuild: Boolean);
    procedure Clear;
    property TextData: TTextTable read FTextData;

    procedure SetCurrentTranslate(Text: string);
  end;

var
  StrippedContextForm: TStrippedContextForm;

implementation

{$R *.dfm}


uses BatchTransOptFrm, BaiduTranslateClient, BuildCodeMainFrm;

procedure TStrippedContextForm.FormCreate(Sender: TObject);
begin
  FTextData := TTextTable.Create;
  FOnReturnProc := nil;
end;

procedure TStrippedContextForm.FormDestroy(Sender: TObject);
begin
  DisposeObject(FTextData);
end;

procedure TStrippedContextForm.FormShow(Sender: TObject);
begin
  LogForm.PopupParent := Self;
end;

procedure TStrippedContextForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseBaiduTranslate;
  FTextData.Clear;
  RefreshTextList(True);
  Action := caHide;
  LogForm.PopupParent := BuildCodeMainForm;
end;

procedure TStrippedContextForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if QuickTranslateForm.Visible then
      QuickTranslateForm.Close;
end;

procedure TStrippedContextForm.RefreshActionExecute(Sender: TObject);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.SaveToFileActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not SaveDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  FTextData.SaveToStream(ms);
  ms.SaveToFile(SaveDialog.FileName);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.LoadFromFileActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not OpenDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenDialog.FileName);
  ms.Position := 0;
  FTextData.LoadFromStream(ms);
  DisposeObject(ms);

  RefreshTextList(True);
end;

procedure TStrippedContextForm.ImportTextActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not OpenTextDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenTextDialog.FileName);
  ms.Position := 0;
  FTextData.ImportFromTextStream(ms);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.ExportTextActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  if not SaveTextDialog.Execute then
      exit;
  ms := TMemoryStream64.Create;
  FTextData.ExportToTextStream(ms);
  ms.SaveToFile(SaveTextDialog.FileName);
  DisposeObject(ms);
end;

procedure TStrippedContextForm.ExitActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TStrippedContextForm.SelectAllActionExecute(Sender: TObject);
begin
  if ActiveControl = CategoryList then
      CategoryList.SelectAll
  else
      ContextList.SelectAll;
end;

procedure TStrippedContextForm.SetCurrentTranslate(Text: string);
begin
  if FOpenPtr = nil then
      exit;
  DefineMemo.Text := Text;
  SaveTextEditor;
end;

procedure TStrippedContextForm.SetOnReturnProc(const Value: TEditorReturnProc);
begin
  FOnReturnProc := Value;
  EditorReturnAction.Visible := Assigned(FOnReturnProc);
end;

procedure TStrippedContextForm.InvSelectedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
              Selected := not Selected;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
              Selected := not Selected;
        end;
    end;

end;

procedure TStrippedContextForm.MarkPickedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
            if Selected then
                Checked := True;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
            if Selected then
                Checked := True;
        end;
    end;
end;

procedure TStrippedContextForm.MarkUnPickedActionExecute(Sender: TObject);
var
  i: Integer;
begin
  if ActiveControl = CategoryList then
    begin
      for i := 0 to CategoryList.Items.Count - 1 do
        begin
          with CategoryList.Items[i] do
            if Selected then
                Checked := False;
        end;
    end
  else
    begin
      for i := 0 to ContextList.Items.Count - 1 do
        begin
          with ContextList.Items[i] do
            if Selected then
                Checked := False;
        end;
    end;
end;

procedure TStrippedContextForm.ShowOriginContextActionExecute(Sender: TObject);
begin
  with TAction(Sender) do
      Checked := not Checked;
  RefreshTextList(False);
end;

procedure TStrippedContextForm.TestActionExecute(Sender: TObject);
var
  ms: TMemoryStream64;
begin
  ms := TMemoryStream64.Create;
  FTextData.ExportToTextStream(ms);
  ms.Position := 0;
  FTextData.ImportFromTextStream(ms);
  ms.free;
  RefreshTextList(True);
end;

procedure TStrippedContextForm.UndoButtonClick(Sender: TObject);
begin
  if FOpenPtr <> nil then
    begin
      FOpenPtr^.DefineText := FOpenPtr^.OriginText;
      FOpenPtr^.Picked := False;
      SaveTextEditor;
    end;
end;

procedure TStrippedContextForm.UsesDest1ActionExecute(Sender: TObject);
begin
  QuickTranslateForm.UsedDest1ButtonClick(nil);
end;

procedure TStrippedContextForm.UsesDest2ActionExecute(Sender: TObject);
begin
  QuickTranslateForm.UsedDest2ButtonClick(nil);
end;

procedure TStrippedContextForm.UsesDest3ActionExecute(Sender: TObject);
begin
  QuickTranslateForm.UsedDest3ButtonClick(nil);
end;

procedure TStrippedContextForm.UsesSourActionExecute(Sender: TObject);
begin
  QuickTranslateForm.UsedSourButtonClick(nil);
end;

procedure TStrippedContextForm.ContextListColumnClick(Sender: TObject; Column: TListColumn);

  function WasWide(t: PPascalString): Byte;
  var
    c: SystemChar;
  begin
    for c in t^.Buff do
      if Ord(c) > $FF then
          exit(1);
    Result := 0;
  end;

  function CompText(t1, t2: TPascalString): Integer; inline;
  begin
    Result := CompareValue(WasWide(@t1), WasWide(@t2));
    if Result = 0 then
      begin
        Result := CompareValue(Length(t1), Length(t2));
        if Result = 0 then
            Result := CompareText(t1, t2);
      end;
  end;

  function LV_Sort1(lParam1, lParam2, lParamSort: LPARAM): Integer; stdcall;
  var
    itm1, itm2: TListItem;
  begin
    itm1 := TListItem(lParam1);
    itm2 := TListItem(lParam2);
    if lParamSort = 0 then
        Result := CompareValue(StrToInt(itm1.Caption), StrToInt(itm2.Caption))
    else if lParamSort = 1 then
        Result := CompareValue(StrToInt(itm1.SubItems[lParamSort - 1]), StrToInt(itm2.SubItems[lParamSort - 1]))
    else
        Result := CompText(itm1.SubItems[lParamSort - 1], itm2.SubItems[lParamSort - 1]);
  end;

  function LV_Sort2(lParam2, lParam1, lParamSort: LPARAM): Integer; stdcall;
  var
    itm1, itm2: TListItem;
  begin
    itm1 := TListItem(lParam1);
    itm2 := TListItem(lParam2);
    if lParamSort = 0 then
        Result := CompareValue(StrToInt(itm1.Caption), StrToInt(itm2.Caption))
    else if lParamSort = 1 then
        Result := CompareValue(StrToInt(itm1.SubItems[lParamSort - 1]), StrToInt(itm2.SubItems[lParamSort - 1]))
    else
        Result := CompText(itm1.SubItems[lParamSort - 1], itm2.SubItems[lParamSort - 1]);
  end;

var
  i: Integer;
begin
  // reset other sort column
  for i := 0 to ContextList.Columns.Count - 1 do
    if ContextList.Columns[i] <> Column then
        ContextList.Columns[i].Tag := 0;

  // imp sort
  if Column.Tag = 0 then
    begin
      ContextList.CustomSort(@LV_Sort1, Column.Index);
      Column.Tag := 1;
    end
  else
    begin
      ContextList.CustomSort(@LV_Sort2, Column.Index);
      Column.Tag := 0;
    end;
end;

procedure TStrippedContextForm.ContextListItemChecked(Sender: TObject; Item: TListItem);
var
  p: PTextTableItem;
begin
  p := Item.Data;
  p^.Picked := Item.Checked;
end;

procedure TStrippedContextForm.ContextListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  p: PTextTableItem;
begin
  if (ContextList.SelCount = 1) and (Selected) then
    begin
      p := Item.Data;
      OpenTextEditor(p, Item);
    end;
end;

procedure TStrippedContextForm.DefineMemoChange(Sender: TObject);
begin
  FOpenPtrIsModify := True;
end;

procedure TStrippedContextForm.CategoryListItemChecked(Sender: TObject; Item: TListItem);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.FilterEditChange(Sender: TObject);
begin
  RefreshTextList(False);
end;

procedure TStrippedContextForm.RestoreTranslationOriginActionExecute(Sender: TObject);
var
  i: Integer;
  p: PTextTableItem;
begin
  if MessageDlg('After the operation cannot be recovered, do you continue?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
      exit;
  for i := 0 to FTextData.Count - 1 do
    begin
      p := FTextData[i];
      p^.DefineText := p^.OriginText;
    end;
  RefreshTextList(False);
end;

procedure TStrippedContextForm.QuickTranslateActionExecute(Sender: TObject);
begin
  if DefineMemo.Lines.Count > 0 then
    begin
      QuickTranslateForm.SourMemo.Text := GetOpenEditorOriginText(FOpenPtr);
      QuickTranslateForm.Translate;
    end;
  if not QuickTranslateForm.Visible then
    begin
      QuickTranslateForm.PopupParent := Self;
      QuickTranslateForm.Show;
    end;
  Activate;
end;

function TStrippedContextForm.GetOpenEditorOriginText(p: PTextTableItem): string;
var
  n: umlString;
begin
  case p^.TextStyle of
    tsPascalText: Result := TTextParsing.TranslatePascalDeclToText(p^.OriginText);
    tsPascalComment:
      begin
        n := p^.OriginText;
        n := umlTrimSpace(n);
        if umlMultipleMatch(False, '{*}', n) then
          begin
            n.DeleteFirst;
            n.DeleteLast;
            if umlMultipleMatch(False, '$*', umlTrimSpace(n)) then
                n := p^.OriginText;
          end
        else if umlMultipleMatch(False, '(*?*)', n, '?', '') then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteLast;
            n.DeleteLast;
          end
        else if umlMultipleMatch(False, '////*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '///*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '//*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
          end;
        Result := n.Text;
      end;
    tsCText: Result := TTextParsing.TranslateC_DeclToText(p^.OriginText);
    tsCComment:
      begin
        n := p^.OriginText;
        n := umlTrimSpace(n);
        if umlMultipleMatch(False, '#*', n) then
          begin
            n := p^.OriginText;
          end
        else if umlMultipleMatch(False, '/*?*/', n, '?', '') then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteLast;
            n.DeleteLast;
          end
        else if umlMultipleMatch(False, '////*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '///*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '//*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
          end;
        Result := n.Text;
      end;
    else
      Result := p^.OriginText;
  end;
end;

procedure TStrippedContextForm.OpenTextEditor(p: PTextTableItem; itm: TListItem);
var
  n: umlString;
begin
  if FOpenPtrIsModify and (FOpenPtr <> nil) then
    begin
      SaveTextEditor;
      FOpenPtrIsModify := False;
    end;

  FOpenPtr := p;
  FOpenListItm := itm;

  case FOpenPtr^.TextStyle of
    tsPascalText:
      begin
        DefineMemo.Text := TTextParsing.TranslatePascalDeclToText(FOpenPtr^.DefineText);
        CodeEdit.Highlighter := SynPasSyn;
      end;
    tsPascalComment:
      begin
        n := FOpenPtr^.DefineText;
        n := umlTrimSpace(n);
        if umlMultipleMatch(False, '{*}', n) then
          begin
            n.DeleteFirst;
            n.DeleteLast;
            if umlMultipleMatch(False, '$*', umlTrimSpace(n)) then
                n := FOpenPtr^.DefineText;
          end
        else if umlMultipleMatch(False, '(*?*)', n, '?', '') then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteLast;
            n.DeleteLast;
          end
        else if umlMultipleMatch(False, '////*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '///*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '//*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
          end;
        DefineMemo.Text := n.Text;
        CodeEdit.Highlighter := SynPasSyn;
      end;
    tsCText:
      begin
        DefineMemo.Text := TTextParsing.TranslateC_DeclToText(FOpenPtr^.DefineText);
        CodeEdit.Highlighter := SynCppSyn;
      end;
    tsCComment:
      begin
        n := FOpenPtr^.DefineText;
        n := umlTrimSpace(n);
        if umlMultipleMatch(False, '#*', n) then
          begin
            n := FOpenPtr^.OriginText;
          end
        else if umlMultipleMatch(False, '/*?*/', n, '?', '') then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteLast;
            n.DeleteLast;
          end
        else if umlMultipleMatch(False, '////*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '///*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
            n.DeleteFirst;
          end
        else if umlMultipleMatch(False, '//*', n) then
          begin
            n.DeleteFirst;
            n.DeleteFirst;
          end;
        DefineMemo.Text := n.Text;
        CodeEdit.Highlighter := SynCppSyn;
      end;
    else
      begin
        DefineMemo.Text := FOpenPtr^.DefineText;
        CodeEdit.Highlighter := nil;
      end;
  end;

  FOpenPtrIsModify := False;

  CodeEdit.Text := Format('//Origin:' + #13#10 + '%s' + #13#10#13#10 + '//Defined:' + #13#10 + '%s', [FOpenPtr^.OriginText, FOpenPtr^.DefineText]);
end;

procedure TStrippedContextForm.SaveTextButtonClick(Sender: TObject);
begin
  SaveTextEditor;
end;

procedure TStrippedContextForm.SaveTextEditor;
var
  n: umlString;
begin
  if FOpenPtr = nil then
      exit;

  case FOpenPtr^.TextStyle of
    tsPascalText: FOpenPtr^.DefineText := TTextParsing.TranslateTextToPascalDecl(DefineMemo.Text);
    tsPascalComment:
      begin
        if umlMultipleMatch(False, '{*}', umlTrimSpace(DefineMemo.Text)) then
            FOpenPtr^.DefineText := DefineMemo.Text
        else
            FOpenPtr^.DefineText := '{ ' + (DefineMemo.Text) + ' }';
      end;
    tsCText: FOpenPtr^.DefineText := TTextParsing.TranslateTextToC_Decl(DefineMemo.Text);
    tsCComment:
      begin
        if umlMultipleMatch(False, '#*', umlTrimSpace(FOpenPtr^.OriginText)) then
            FOpenPtr^.DefineText := DefineMemo.Text
        else
            FOpenPtr^.DefineText := '/* ' + (DefineMemo.Text) + ' */';
      end;
    else FOpenPtr^.DefineText := DefineMemo.Text;
  end;
  FOpenPtrIsModify := False;

  FOpenPtr.Picked := True;

  with FOpenListItm do
    begin
      Caption := Format('%d', [FOpenPtr^.Index]);
      SubItems.Clear;
      SubItems.Add(Format('%d', [FOpenPtr^.RepCount]));

      if ShowOriginContextAction.Checked then
          SubItems.Add(umlDeleteChar(FOpenPtr^.OriginText, #13#10))
      else
          SubItems.Add(umlDeleteChar(FOpenPtr^.DefineText, #13#10));

      Checked := FOpenPtr^.Picked;
    end;

  CodeEdit.Text := Format('//Origin:' + #13#10 + '%s' + #13#10#13#10 + '//Defined:' + #13#10 + '%s', [FOpenPtr^.OriginText, FOpenPtr^.DefineText]);
end;

procedure TStrippedContextForm.LoadNewCTFromStream(m64: TMemoryStream64);
begin
  FTextData.LoadFromStream(m64);
  RefreshTextList(True);
end;

procedure TStrippedContextForm.NewCT;
begin
  FTextData.Clear;
  RefreshTextList(True);
end;

procedure TStrippedContextForm.EditorReturnActionExecute(Sender: TObject);
var
  i : Integer;
  tb: TTextTable;
begin
  tb := TTextTable.Create;
  for i := 0 to FTextData.Count - 1 do
    if FTextData[i]^.Picked then
        tb.AddCopy(FTextData[i]^);

  if Assigned(FOnReturnProc) then
      FOnReturnProc(tb);

  DisposeObject(tb);
  Close;
end;

function TStrippedContextForm.ExistsCategory(c: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to CategoryList.Items.Count - 1 do
    if SameText(c, CategoryList.Items[i].Caption) then
        exit(True);
end;

procedure TStrippedContextForm.NoDialogBatchTranslateActionExecute(Sender: TObject);
type
  PtempRec = ^TtempRec;

  TtempRec = record
    p: PTextTableItem;
    itmIndex: Integer;
    Index: Integer;
  end;
var
  i : Integer;
  p1: PtempRec;
begin
  for i := 0 to ContextList.Items.Count - 1 do
    if ContextList.Items[i].Selected then
      begin
        new(p1);
        p1^.p := ContextList.Items[i].Data;
        p1^.itmIndex := ContextList.Items[i].Index;
        p1^.Index := p1^.p^.Index;

        BaiduTranslate(BatchTransOptForm.UsedCacheWithZDBCheckBox.Checked, BatchTransOptForm.SourComboBox.ItemIndex, BatchTransOptForm.Dest1ComboBox.ItemIndex,
          GetOpenEditorOriginText(p1^.p), p1,
          procedure(UserData: Pointer; Success, Cached: Boolean; TranslateTime: TTimeTick; sour, dest: TPascalString)
          var
            p2: PtempRec;
            itm: TListItem;
          begin
            p2 := UserData;
            if Success then
              begin
                if (FTextData.ExistsIndex(p2^.Index)) and (p2^.itmIndex < ContextList.Items.Count) and
                  (ContextList.Items[p2^.itmIndex].Data = p2^.p) then
                  begin
                    itm := ContextList.Items[p2^.itmIndex];
                    OpenTextEditor(p2^.p, itm);
                    SetCurrentTranslate(dest);
                    SaveTextEditor;
                    if itm.Selected then
                        itm.Selected := False;
                  end;
              end;
            dispose(p2);
          end);
      end;
end;

procedure TStrippedContextForm.BatchTranslateActionExecute(
  Sender: TObject);
begin
  if BatchTransOptForm.ShowModal = mrOk then
      NoDialogBatchTranslateAction.Execute;
end;

function TStrippedContextForm.CategoryIsSelected(c: string): Boolean;
var
  i: Integer;
begin
  for i := 0 to CategoryList.Items.Count - 1 do
    if SameText(c, CategoryList.Items[i].Caption) then
        exit(CategoryList.Items[i].Checked);
  Result := False;
end;

procedure TStrippedContextForm.RefreshTextList(rebuild: Boolean);
  function Match(s1, s2: umlString): Boolean;
  begin
    Result := (s1.Len = 0) or (s2.GetPos(s1) > 0) or (umlMultipleMatch(s1, s2));
  end;

var
  i   : Integer;
  p   : PTextTableItem;
  itm : TListItem;
  hlst: THashObjectList;
begin
  FOpenListItm := nil;
  FOpenPtr := nil;

  CodeEdit.Clear;
  DefineMemo.Clear;
  QuickTranslateForm.Close;

  ContextList.OnItemChecked := nil;
  CategoryList.OnItemChecked := nil;
  if rebuild then
      CategoryList.Items.BeginUpdate;

  ContextList.Items.BeginUpdate;

  hlst := THashObjectList.Create(False);

  if rebuild then
      CategoryList.Items.Clear;
  ContextList.Items.Clear;
  for i := 0 to FTextData.Count - 1 do
    begin
      p := FTextData[i];

      if rebuild then
        if not ExistsCategory(p^.Category) then
          begin
            with CategoryList.Items.Add do
              begin
                Caption := umlDeleteChar(p^.Category, #13#10);
                ImageIndex := -1;
                StateIndex := -1;
                Checked := True;
              end;
          end;

      if CategoryIsSelected(umlDeleteChar(p^.Category, #13#10)) then
        if not hlst.Exists(p^.OriginText) then
          if (Match(OriginFilterEdit.Text, p^.OriginText)) and (Match(DefineFilterEdit.Text, p^.DefineText)) then
            begin
              itm := ContextList.Items.Add;
              hlst.Add(p^.OriginText, itm);
              with itm do
                begin
                  Caption := Format('%d', [p^.Index]);
                  SubItems.Add(Format('%d', [p^.RepCount]));

                  if ShowOriginContextAction.Checked then
                      SubItems.Add(umlDeleteChar(p^.OriginText, #13#10))
                  else
                      SubItems.Add(umlDeleteChar(p^.DefineText, #13#10));

                  Checked := p^.Picked;

                  ImageIndex := -1;
                  StateIndex := -1;

                  Data := p;
                end;
            end;
    end;

  DisposeObject(hlst);

  ContextList.Items.EndUpdate;

  if rebuild then
      CategoryList.Items.EndUpdate;
  ContextList.OnItemChecked := ContextListItemChecked;
  CategoryList.OnItemChecked := CategoryListItemChecked;
end;

procedure TStrippedContextForm.Clear;
begin
  CategoryList.Clear;
  ContextList.Clear;
end;

end.
