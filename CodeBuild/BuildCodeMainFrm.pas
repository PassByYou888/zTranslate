unit BuildCodeMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.FileCtrl,

  System.IOUtils,

  TextTable, TextDataEngine, CoreClasses, UnicodeMixedLib, TextParsing,
  MemoryStream64, DoStatusIO, PascalStrings,
  Vcl.ComCtrls, SynHighlighterPas, SynEditHighlighter, SynHighlighterCpp,
  SynEdit, BaiduTranslateClient;

type
  TBuildCodeMainForm = class(TForm)
    PageControl: TPageControl;
    FileProjectTabSheet: TTabSheet;
    AddButton: TButton;
    BrowsePathButton: TButton;
    BuildButton: TButton;
    ClearButton: TButton;
    FileListBox: TListBox;
    ImportButton: TButton;
    Label1: TLabel;
    OpenCTDialog: TOpenDialog;
    OpenDialog: TOpenDialog;
    OutPathEdit: TLabeledEdit;
    SaveCTDialog: TSaveDialog;
    CodeTabSheet: TTabSheet;
    CodeToolPanel: TPanel;
    PascalcodeForTextStripedToolButton: TButton;
    CodeEdit: TSynEdit;
    CodeStyleRadioGroup: TRadioGroup;
    Cstyle_RadioButton: TRadioButton;
    Pascalstyle_RadioButton: TRadioButton;
    SynCppSyn: TSynCppSyn;
    SynPasSyn: TSynPasSyn;
    BotPanel: TPanel;
    IncludePascalCommentCheckBox: TCheckBox;
    IncludeCCommentCheckBox: TCheckBox;
    IgnorePascalDirectivesCheckBox: TCheckBox;
    IgnoreCDirectivesCheckBox: TCheckBox;
    StripedToolButton: TButton;
    OptionsTabSheet: TTabSheet;
    BaiduTSAddrEdit: TLabeledEdit;
    BaiduTSPortEdit: TLabeledEdit;
    OpenBaiduTSButton: TButton;
    CloseBaiduTSButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddButtonClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    procedure BrowsePathButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure PascalcodeForTextStripedToolButtonClick(Sender: TObject);
    procedure Cstyle_RadioButtonClick(Sender: TObject);
    procedure Pascalstyle_RadioButtonClick(Sender: TObject);
    procedure StripedToolButtonClick(Sender: TObject);
    procedure OpenBaiduTSButtonClick(Sender: TObject);
    procedure CloseBaiduTSButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Table : TTextTable;
    Config: TSectionTextData;

    function GetPascalUnitInfo(t: TTextParsing; const initPos: integer; var outPos: TTextPos): Boolean;

    procedure BuildPascalSource2CT(unitName: string; tp: TTextParsing; tb: TTextTable); overload;
    procedure BuildPascalSource2CT(fn: string; tb: TTextTable); overload;

    procedure BuildC_Source2CT(unitName: string; tp: TTextParsing; tb: TTextTable); overload;
    procedure BuildC_Source2CT(fn: string; tb: TTextTable); overload;

    procedure TranslateCT2_Pascal(code: TStrings; tb: TTextTable);
    procedure TranslateCT2_C(code: TStrings; tb: TTextTable);

    procedure CTEditorReturn_Pascal(tb: TTextTable);
    procedure CTEditorReturn_C(tb: TTextTable);
    procedure CTEditorReturn_BuildCode(tb: TTextTable);
  end;

var
  BuildCodeMainForm: TBuildCodeMainForm;

implementation

{$R *.dfm}


uses StrippedContextFrm, LogFrm;

procedure TBuildCodeMainForm.FormCreate(Sender: TObject);
var
  fn, pn: string;
begin
  Table := TTextTable.Create;
  Config := TSectionTextData.Create;
  fn := umlCombineFileName(TPath.GetDocumentsPath, 'BuildCode.cfg');
  if TFile.Exists(fn) then
    begin
      Config.LoadFromFile(fn);
    end;
  FileListBox.Items.Assign(Config.Names['Files']);

  pn := umlCombinePath(umlGetFilePath(Application.ExeName), 'Output');
  umlCreateDirectory(pn);

  OutPathEdit.Text := Config.GetDefaultValue('main', 'output', pn);
  IncludePascalCommentCheckBox.Checked := Config.GetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  IgnorePascalDirectivesCheckBox.Checked := Config.GetDefaultValue('main', 'IgnorePascalDirectives', IgnorePascalDirectivesCheckBox.Checked);
  IncludeCCommentCheckBox.Checked := Config.GetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
  IgnoreCDirectivesCheckBox.Checked := Config.GetDefaultValue('main', 'IgnoreCDirectives', IgnoreCDirectivesCheckBox.Checked);

  BaiduTSAddrEdit.Text := Config.GetDefaultValue('main', 'BaiduTSAddr', BaiduTSAddrEdit.Text);
  BaiduTSPortEdit.Text := Config.GetDefaultValue('main', 'BaiduTSPort', BaiduTSPortEdit.Text);
end;

procedure TBuildCodeMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn: string;
begin
  fn := umlCombineFileName(TPath.GetDocumentsPath, 'BuildCode.cfg');
  Config.Names['Files'].Assign(FileListBox.Items);

  Config.SetDefaultValue('main', 'output', OutPathEdit.Text);
  Config.SetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  Config.SetDefaultValue('main', 'IgnorePascalDirectives', IgnorePascalDirectivesCheckBox.Checked);
  Config.SetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
  Config.SetDefaultValue('main', 'IgnoreCDirectives', IgnoreCDirectivesCheckBox.Checked);

  Config.SetDefaultValue('main', 'BaiduTSAddr', BaiduTSAddrEdit.Text);
  Config.SetDefaultValue('main', 'BaiduTSPort', BaiduTSPortEdit.Text);
  Config.SaveToFile(fn);

  Action := caFree;

  DisposeObject(Config);
  DisposeObject(Table);
end;

procedure TBuildCodeMainForm.AddButtonClick(Sender: TObject);
var
  i: integer;
begin
  if not OpenDialog.Execute then
      exit;
  for i := 0 to OpenDialog.Files.Count - 1 do
    begin
      umlAddNewStrTo(OpenDialog.Files[i], FileListBox.Items);
    end;
end;

procedure TBuildCodeMainForm.BuildButtonClick(Sender: TObject);
var
  i : integer;
  ms: TMemoryStream64;
begin

  for i := 0 to FileListBox.Items.Count - 1 do
    if not TFile.Exists(FileListBox.Items[i]) then
      begin
        MessageDlg(Format('file "%s" no exists', [FileListBox.Items[i]]), mtError, [mbYes], 0);
        exit;
      end;

  Table.Clear;
  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      if umlMultipleMatch(['*.pas', '*.inc', '*.dpj'], FileListBox.Items[i]) then
          BuildPascalSource2CT(FileListBox.Items[i], Table)
      else if umlMultipleMatch(['*.c', '*.cpp', '*.cs', '*.h', '*.hpp'], FileListBox.Items[i]) then
          BuildC_Source2CT(FileListBox.Items[i], Table);
    end;

  ms := TMemoryStream64.Create;
  Table.SaveToStream(ms);
  ms.Position := 0;
  StrippedContextForm.OnReturnProc := CTEditorReturn_BuildCode;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.LoadNewCTFromStream(ms);
  StrippedContextForm.Show;
  DisposeObject(ms);

  OpenBaiduTSButtonClick(nil);
end;

procedure TBuildCodeMainForm.BrowsePathButtonClick(Sender: TObject);
var
  d: string;
begin
  d := OutPathEdit.Text;
  if Vcl.FileCtrl.SelectDirectory('output directory', '', d) then
      OutPathEdit.Text := d;
end;

procedure TBuildCodeMainForm.ImportButtonClick(Sender: TObject);
var
  ms  : TMemoryStream64;
  i, j: integer;
  ns  : TCoreClassStringList;
begin
  if not TDirectory.Exists(OutPathEdit.Text) then
    begin
      MessageDlg(Format('directory "%s" no exists', [OutPathEdit.Text]), mtError, [mbYes], 0);
      exit;
    end;

  if not OpenCTDialog.Execute then
      exit;

  ms := TMemoryStream64.Create;
  ms.LoadFromFile(OpenCTDialog.FileName);
  ms.Position := 0;
  Table.LoadFromStream(ms);
  DisposeObject(ms);

  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      ns := TCoreClassStringList.Create;
      ns.LoadFromFile(FileListBox.Items[i]);

      if umlMultipleMatch(['*.pas', '*.inc'], FileListBox.Items[i]) then
        begin
          TranslateCT2_Pascal(ns, Table);
          ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end
      else if umlMultipleMatch(['*.c', '*.cpp', '*.cc', '*.h', '*.hpp'], FileListBox.Items[i]) then
        begin
          TranslateCT2_C(ns, Table);
          ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end;
      DisposeObject(ns);
    end;

  DoStatus('all merge finished!', []);
end;

procedure TBuildCodeMainForm.OpenBaiduTSButtonClick(Sender: TObject);
begin
  BaiduTranslateServiceHost := BaiduTSAddrEdit.Text;
  BaiduTranslateServicePort := umlStrToInt(BaiduTSPortEdit.Text, 0);
  OpenBaiduTranslate;
end;

procedure TBuildCodeMainForm.PascalcodeForTextStripedToolButtonClick(Sender: TObject);
var
  t    : TTextParsing;
  ms   : TMemoryStream64;
  rProc: TEditorReturnProc;
begin
  Table.Clear;

  if Cstyle_RadioButton.Checked then
    begin
      t := TTextParsing.Create(CodeEdit.Text, tsC);
      BuildC_Source2CT('utility.c', t, Table);
      rProc := CTEditorReturn_C;
    end
  else if Pascalstyle_RadioButton.Checked then
    begin
      t := TTextParsing.Create(CodeEdit.Text, tsPascal);
      BuildPascalSource2CT('utility.pas', t, Table);
      rProc := CTEditorReturn_Pascal;
    end
  else
      exit;

  DisposeObject(t);

  ms := TMemoryStream64.Create;
  Table.SaveToStream(ms);
  ms.Position := 0;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.LoadNewCTFromStream(ms);
  StrippedContextForm.OnReturnProc := rProc;
  StrippedContextForm.Show;
  DisposeObject(ms);

  OpenBaiduTSButtonClick(nil);
end;

procedure TBuildCodeMainForm.Pascalstyle_RadioButtonClick(Sender: TObject);
begin
  CodeEdit.Highlighter := SynPasSyn;
end;

procedure TBuildCodeMainForm.StripedToolButtonClick(Sender: TObject);
begin
  StrippedContextForm.OnReturnProc := nil;
  StrippedContextForm.NewCT;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.Show;

  OpenBaiduTSButtonClick(nil);
end;

procedure TBuildCodeMainForm.ClearButtonClick(Sender: TObject);
begin
  FileListBox.Clear;
end;

procedure TBuildCodeMainForm.CloseBaiduTSButtonClick(Sender: TObject);
begin
  CloseBaiduTranslate;
end;

procedure TBuildCodeMainForm.Cstyle_RadioButtonClick(Sender: TObject);
begin
  CodeEdit.Highlighter := SynCppSyn;
end;

function TBuildCodeMainForm.GetPascalUnitInfo(t: TTextParsing; const initPos: integer; var outPos: TTextPos): Boolean;
var
  cp        : integer;
  ePos      : integer;
  InitedUnit: Boolean;
  s         : umlString;
begin
  Result := False;
  InitedUnit := False;

  cp := initPos;

  while cp <= t.ParsingData.Len do
    begin
      if t.IsTextDecl(cp) then
        begin
          cp := t.GetTextDeclEndPos(cp);
        end
      else if t.IsComment(cp) then
        begin
          cp := t.GetCommentEndPos(cp);
        end
      else if t.IsNumber(cp) then
        begin
          cp := t.GetNumberEndPos(cp);
        end
      else if t.IsSymbol(cp) then
        begin
          if InitedUnit then
            if t.GetChar(cp) = ';' then
              begin
                outPos.ePos := cp + 1;
                Result := True;
                break;
              end;
          ePos := t.GetSymbolEndPos(cp);
          cp := ePos;
        end
      else if t.IsAscii(cp) then
        begin
          ePos := t.GetAsciiEndPos(cp);
          if not InitedUnit then
            begin
              s := t.GetStr(cp, ePos);
              if (s.Same('unit')) or (s.Same('program')) then
                begin
                  InitedUnit := True;
                  outPos.bPos := cp;
                end;
            end;
          cp := ePos;
        end
      else
          inc(cp);
    end;
end;

procedure TBuildCodeMainForm.BuildPascalSource2CT(unitName: string; tp: TTextParsing; tb: TTextTable);
var
  j    : integer;
  tPos : TTextPos;
  uName: string;
  pPos : PTextPos;

  sc, cc: integer;
begin
  uName := unitName;

  sc := 0;
  cc := 0;

  if GetPascalUnitInfo(tp, 1, tPos) then
      uName := umlDeleteFirstStr(tp.GetStr(tPos), #32#10#13#9 + tp.SymbolTable).Text;

  for j := 0 to tp.ParsingData.Cache.TextData.Count - 1 do
    begin
      pPos := tp.ParsingData.Cache.TextData[j];
      tb.AddPascalText(pPos^.Text, uName, False);
      inc(sc);
    end;

  if IncludePascalCommentCheckBox.Checked then
    for j := 0 to tp.ParsingData.Cache.CommentData.Count - 1 do
      begin
        pPos := tp.ParsingData.Cache.CommentData[j];
        if not IgnorePascalDirectivesCheckBox.Checked then
          begin
            tb.AddPascalComment(pPos^.Text, uName, False);
            inc(cc);
          end
        else if not pPos^.Text.Exists('$') then
          begin
            tb.AddPascalComment(pPos^.Text, uName, False);
            inc(cc);
          end;
      end;
  DoStatus('Build ct with Pascal Style "%s" string:%d comment:%d', [unitName, sc, cc]);
end;

procedure TBuildCodeMainForm.BuildPascalSource2CT(fn: string; tb: TTextTable);
var
  ns: TCoreClassStringList;
  t : TTextParsing;
begin
  ns := TCoreClassStringList.Create;
  ns.LoadFromFile(fn);
  t := TTextParsing.Create(ns.Text, tsPascal);

  BuildPascalSource2CT(umlGetFileName(fn), t, tb);

  DisposeObject(t);
  DisposeObject(ns);
end;

procedure TBuildCodeMainForm.BuildC_Source2CT(unitName: string; tp: TTextParsing; tb: TTextTable);
var
  j    : integer;
  tPos : TTextPos;
  uName: string;
  pPos : PTextPos;

  sc, cc: integer;
begin
  uName := unitName;

  sc := 0;
  cc := 0;

  for j := 0 to tp.ParsingData.Cache.TextData.Count - 1 do
    begin
      pPos := tp.ParsingData.Cache.TextData[j];
      tb.AddCText(pPos^.Text, uName, False);
      inc(sc);
    end;

  if IncludeCCommentCheckBox.Checked then
    for j := 0 to tp.ParsingData.Cache.CommentData.Count - 1 do
      begin
        pPos := tp.ParsingData.Cache.CommentData[j];
        if not IgnoreCDirectivesCheckBox.Checked then
          begin
            tb.AddCComment(pPos^.Text, uName, False);
            inc(cc);
          end
        else if not pPos^.Text.Exists('#') then
          begin
            tb.AddCComment(pPos^.Text, uName, False);
            inc(cc);
          end;
      end;
  DoStatus('Build ct with C Style "%s" string:%d comment:%d', [unitName, sc, cc]);
end;

procedure TBuildCodeMainForm.BuildC_Source2CT(fn: string; tb: TTextTable);
var
  ns: TCoreClassStringList;
  t : TTextParsing;
begin
  ns := TCoreClassStringList.Create;
  ns.LoadFromFile(fn);
  t := TTextParsing.Create(ns.Text, tsC);

  BuildC_Source2CT(umlGetFileName(fn), t, tb);

  DisposeObject(t);
  DisposeObject(ns);
end;

procedure TBuildCodeMainForm.TranslateCT2_Pascal(code: TStrings; tb: TTextTable);
var
  i, j: integer;
  t   : TTextParsing;
  pPos: PTextPos;
  p   : PTextTableItem;
begin
  t := TTextParsing.Create(code.Text, tsPascal);

  for j := 0 to t.ParsingData.Cache.TextData.Count - 1 do
    begin
      pPos := t.ParsingData.Cache.TextData[j];
      p := tb.Search(pPos^.Text);
      if p <> nil then
        begin
          pPos^.Text := p^.DefineText;
          DoStatus('Translate Pascal String ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
        end;
    end;

  if IncludePascalCommentCheckBox.Checked then
    for j := 0 to t.ParsingData.Cache.CommentData.Count - 1 do
      begin
        pPos := t.ParsingData.Cache.CommentData[j];
        if not IgnorePascalDirectivesCheckBox.Checked then
          begin
            p := tb.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate Pascal Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end
        else if not pPos^.Text.Exists('$') then
          begin
            p := tb.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate Pascal Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end;
      end;

  t.RebuildText;
  code.Text := t.TextData.Text;

  DisposeObject(t);
end;

procedure TBuildCodeMainForm.TranslateCT2_C(code: TStrings; tb: TTextTable);
var
  i, j: integer;
  t   : TTextParsing;
  pPos: PTextPos;
  p   : PTextTableItem;
begin
  t := TTextParsing.Create(CodeEdit.Text, tsC);

  for j := 0 to t.ParsingData.Cache.TextData.Count - 1 do
    begin
      pPos := t.ParsingData.Cache.TextData[j];
      p := tb.Search(pPos^.Text);
      if p <> nil then
        begin
          pPos^.Text := p^.DefineText;
          DoStatus('Translate C String ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
        end;
    end;

  if IncludeCCommentCheckBox.Checked then
    for j := 0 to t.ParsingData.Cache.CommentData.Count - 1 do
      begin
        pPos := t.ParsingData.Cache.CommentData[j];
        if not IgnoreCDirectivesCheckBox.Checked then
          begin
            p := tb.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate C Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end
        else if not pPos^.Text.Exists('#') then
          begin
            p := tb.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate C Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end;
      end;

  t.RebuildText;
  CodeEdit.Text := t.TextData.Text;

  DisposeObject(t);
end;

procedure TBuildCodeMainForm.CTEditorReturn_Pascal(tb: TTextTable);
var
  tl: integer;
begin
  tl := CodeEdit.TopLine;
  TranslateCT2_Pascal(CodeEdit.Lines, tb);
  CodeEdit.TopLine := tl;
end;

procedure TBuildCodeMainForm.CTEditorReturn_C(tb: TTextTable);
var
  tl: integer;
begin
  tl := CodeEdit.TopLine;
  TranslateCT2_C(CodeEdit.Lines, tb);
  CodeEdit.TopLine := tl;
end;

procedure TBuildCodeMainForm.CTEditorReturn_BuildCode(tb: TTextTable);
var
  i, j: integer;
  ns  : TCoreClassStringList;
  m64 : TMemoryStream64;
begin
  Table.Clear;
  if MessageDlg('so now,Translate all code?', mtInformation, [mbYes, mbNo], 0) <> mrYes then
    begin
      m64 := TMemoryStream64.Create;
      tb.SaveToStream(m64);
      m64.Position := 0;
      Table.LoadFromStream(m64);
      DisposeObject(m64);
      exit;
    end;
  if not TDirectory.Exists(OutPathEdit.Text) then
    begin
      MessageDlg(Format('directory "%s" no exists', [OutPathEdit.Text]), mtError, [mbYes], 0);
      exit;
    end;

  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      ns := TCoreClassStringList.Create;
      ns.LoadFromFile(FileListBox.Items[i]);

      if umlMultipleMatch(['*.pas', '*.inc'], FileListBox.Items[i]) then
        begin
          TranslateCT2_Pascal(ns, tb);
          ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end
      else if umlMultipleMatch(['*.c', '*.cpp', '*.cc', '*.h', '*.hpp'], FileListBox.Items[i]) then
        begin
          TranslateCT2_C(ns, tb);
          ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end;
      DisposeObject(ns);
    end;

  DoStatus('all merge finished!', []);
end;

end.
