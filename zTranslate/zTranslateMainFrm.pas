unit zTranslateMainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.FileCtrl, Vcl.ComCtrls,

  Vcl.Clipbrd, System.IOUtils, Vcl.Imaging.pngimage,

  TextTable, TextDataEngine, CoreClasses, UnicodeMixedLib, TextParsing,
  MemoryStream64, DoStatusIO, PascalStrings, BaiduTranslateClient,
  CommunicationFramework;

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
    CodeTabSheet: TTabSheet;
    CodeToolPanel: TPanel;
    PascalcodeForTextStripedToolButton: TButton;
    CodeStyleRadioGroup: TRadioGroup;
    Cstyle_RadioButton: TRadioButton;
    Pascalstyle_RadioButton: TRadioButton;
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
    CodeEdit: TMemo;
    AboutTabSheet: TTabSheet;
    Image1: TImage;
    GplMemo: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    DFMstyle_RadioButton: TRadioButton;
    UsedOriginOutputDirectoryCheckBox: TCheckBox;
    PasteCodeButton: TButton;
    copyCodeButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddButtonClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    procedure UsedOriginOutputDirectoryCheckBoxClick(Sender: TObject);
    procedure BrowsePathButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure PascalcodeForTextStripedToolButtonClick(Sender: TObject);
    procedure StripedToolButtonClick(Sender: TObject);
    procedure OpenBaiduTSButtonClick(Sender: TObject);
    procedure CloseBaiduTSButtonClick(Sender: TObject);
    procedure PasteCodeButtonClick(Sender: TObject);
    procedure copyCodeButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    config: TSectionTextData;

    function GetPascalUnitInfo(T: TTextParsing; const initPos: Integer; var OutPos: TTextPos): Boolean;

    procedure BuildPascalSource2CT(unitName: string; tp: TTextParsing; TB: TTextTable); overload;
    procedure BuildPascalSource2CT(fn: string; TB: TTextTable); overload;

    procedure BuildC_Source2CT(unitName: string; tp: TTextParsing; TB: TTextTable); overload;
    procedure BuildC_Source2CT(fn: string; TB: TTextTable); overload;

    procedure BuildDFMSource2CT(unitName: string; tp: TTextParsing; TB: TTextTable); overload;
    procedure BuildDFMSource2CT(fn: string; TB: TTextTable); overload;

    procedure TranslateCT2_Pascal(Code: TStrings; TB: TTextTable);
    procedure TranslateCT2_C(Code: TStrings; TB: TTextTable);
    procedure TranslateCT2_DFM(Code: TStrings; TB: TTextTable);

    procedure CTEditorReturn_Pascal(TB: TTextTable);
    procedure CTEditorReturn_C(TB: TTextTable);
    procedure CTEditorReturn_DFM(TB: TTextTable);
    procedure CTEditorReturn_BuildCode(TB: TTextTable);
  end;

var
  BuildCodeMainForm: TBuildCodeMainForm;

implementation

{$R *.dfm}


uses StrippedContextFrm, LogFrm;

procedure GlobalProgressBackgroundProc;
begin
  Application.ProcessMessages;
end;

procedure TBuildCodeMainForm.FormCreate(Sender: TObject);
var
  fn, pn: string;
begin
  ProgressBackgroundProc := GlobalProgressBackgroundProc;

  config := TSectionTextData.Create;
  fn := umlCombineFileName(TPath.GetDocumentsPath, 'zTranslate.cfg');
  if TFile.Exists(fn) then
    begin
      config.LoadFromFile(fn);
    end;
  FileListBox.Items.Assign(config.Names['Files']);

  pn := umlCombinePath(umlGetFilePath(Application.Exename), 'Output');
  OutPathEdit.Text := config.GetDefaultValue('main', 'output', pn);
  umlCreateDirectory(OutPathEdit.Text);

  UsedOriginOutputDirectoryCheckBox.Checked := config.GetDefaultValue('main', 'UsedOriginDirectory', UsedOriginOutputDirectoryCheckBox.Checked);
  UsedOriginOutputDirectoryCheckBoxClick(UsedOriginOutputDirectoryCheckBox);

  IncludePascalCommentCheckBox.Checked := config.GetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  IgnorePascalDirectivesCheckBox.Checked := config.GetDefaultValue('main', 'IgnorePascalDirectives', IgnorePascalDirectivesCheckBox.Checked);
  IncludeCCommentCheckBox.Checked := config.GetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
  IgnoreCDirectivesCheckBox.Checked := config.GetDefaultValue('main', 'IgnoreCDirectives', IgnoreCDirectivesCheckBox.Checked);

  Cstyle_RadioButton.Checked := config.GetDefaultValue('main', 'cStyle', Cstyle_RadioButton.Checked);
  Pascalstyle_RadioButton.Checked := config.GetDefaultValue('main', 'pascalStyle', Pascalstyle_RadioButton.Checked);
  DFMstyle_RadioButton.Checked := config.GetDefaultValue('main', 'dfmStyle', DFMstyle_RadioButton.Checked);
  CodeEdit.Text := config.GetDefaultValue('main', 'code', CodeEdit.Text);

  BaiduTSAddrEdit.Text := config.GetDefaultValue('main', 'BaiduTSAddr', BaiduTSAddrEdit.Text);
  BaiduTSPortEdit.Text := config.GetDefaultValue('main', 'BaiduTSPort', BaiduTSPortEdit.Text);
end;

procedure TBuildCodeMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn: string;
  en: U_String;
begin
  fn := umlCombineFileName(TPath.GetDocumentsPath, 'zTranslate.cfg');
  config.Names['Files'].Assign(FileListBox.Items);

  config.SetDefaultValue('main', 'UsedOriginDirectory', UsedOriginOutputDirectoryCheckBox.Checked);

  config.SetDefaultValue('main', 'output', OutPathEdit.Text);
  config.SetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  config.SetDefaultValue('main', 'IgnorePascalDirectives', IgnorePascalDirectivesCheckBox.Checked);
  config.SetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
  config.SetDefaultValue('main', 'IgnoreCDirectives', IgnoreCDirectivesCheckBox.Checked);

  config.SetDefaultValue('main', 'cStyle', Cstyle_RadioButton.Checked);
  config.SetDefaultValue('main', 'pascalStyle', Pascalstyle_RadioButton.Checked);
  config.SetDefaultValue('main', 'dfmStyle', DFMstyle_RadioButton.Checked);
  config.SetDefaultValue('main', 'code', CodeEdit.Text);

  config.SetDefaultValue('main', 'BaiduTSAddr', BaiduTSAddrEdit.Text);
  config.SetDefaultValue('main', 'BaiduTSPort', BaiduTSPortEdit.Text);
  config.SaveToFile(fn);

  Action := caFree;

  DisposeObject(config);
end;

procedure TBuildCodeMainForm.AddButtonClick(Sender: TObject);
var
  i: Integer;
begin
  if not OpenDialog.Execute then
      Exit;
  for i := 0 to OpenDialog.Files.Count - 1 do
    begin
      umlAddNewStrTo(OpenDialog.Files[i], FileListBox.Items);
    end;
end;

procedure TBuildCodeMainForm.BuildButtonClick(Sender: TObject);
var
  i: Integer;
  m64: TMemoryStream64;
  TB: TTextTable;
begin
  for i := 0 to FileListBox.Items.Count - 1 do
    if not TFile.Exists(FileListBox.Items[i]) then
      begin
        MessageDlg(Format('file "%s" no exists', [FileListBox.Items[i]]), mtError, [mbYes], 0);
        Exit;
      end;

  TB := TTextTable.Create;
  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      if umlMultipleMatch(['*.pas', '*.inc', '*.dpr'], FileListBox.Items[i]) then
          BuildPascalSource2CT(FileListBox.Items[i], TB)
      else if umlMultipleMatch(['*.c', '*.cpp', '*.c', '*.cs', '*.h', '*.hpp'], FileListBox.Items[i]) then
          BuildC_Source2CT(FileListBox.Items[i], TB)
      else if umlMultipleMatch(['*.dfm', '*.fmx', '*.lfm'], FileListBox.Items[i]) then
          BuildDFMSource2CT(FileListBox.Items[i], TB);
    end;

  m64 := TMemoryStream64.Create;
  TB.SaveToStream(m64);
  m64.Position := 0;
  StrippedContextForm.OnReturnProc := CTEditorReturn_BuildCode;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.LoadNewCTFromStream(m64);
  StrippedContextForm.show;
  DisposeObject(m64);

  DisposeObject(TB);
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
  m64: TMemoryStream64;
  TB: TTextTable;
begin
  if not OpenCTDialog.Execute then
      Exit;

  m64 := TMemoryStream64.Create;
  m64.LoadFromFile(OpenCTDialog.FileName);
  m64.Position := 0;
  TB := TTextTable.Create;
  TB.LoadFromStream(m64);
  DisposeObject(m64);

  CTEditorReturn_BuildCode(TB);

  DisposeObject(TB);
end;

procedure TBuildCodeMainForm.OpenBaiduTSButtonClick(Sender: TObject);
begin
  BaiduTranslateServiceHost := BaiduTSAddrEdit.Text;
  BaiduTranslateServicePort := umlStrToInt(BaiduTSPortEdit.Text, 0);
  OpenBaiduTranslate;
end;

procedure TBuildCodeMainForm.PascalcodeForTextStripedToolButtonClick(Sender: TObject);
var
  T: TTextParsing;
  m64: TMemoryStream64;
  rProc: TEditorReturnProc;
  TB: TTextTable;
begin
  TB := TTextTable.Create;

  if Cstyle_RadioButton.Checked then
    begin
      T := TTextParsing.Create(CodeEdit.Text, tsC, nil);
      BuildC_Source2CT('utility.c', T, TB);
      rProc := CTEditorReturn_C;
    end
  else if Pascalstyle_RadioButton.Checked then
    begin
      T := TTextParsing.Create(CodeEdit.Text, tsPascal, nil);
      BuildPascalSource2CT('utility.pas', T, TB);
      rProc := CTEditorReturn_Pascal;
    end
  else if DFMstyle_RadioButton.Checked then
    begin
      T := TTextParsing.Create(CodeEdit.Text, tsPascal, nil);
      BuildDFMSource2CT('utility.DFM', T, TB);
      rProc := CTEditorReturn_DFM;
    end
  else
      Exit;

  DisposeObject(T);

  m64 := TMemoryStream64.Create;
  TB.SaveToStream(m64);
  DisposeObject(TB);
  m64.Position := 0;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.LoadNewCTFromStream(m64);
  StrippedContextForm.OnReturnProc := rProc;
  StrippedContextForm.show;
  DisposeObject(m64);

  OpenBaiduTSButtonClick(nil);
end;

procedure TBuildCodeMainForm.PasteCodeButtonClick(Sender: TObject);
var
  T: U_String;
  n: U_String;
  C: SystemChar;
  i: Integer;
begin
  CodeEdit.Clear;
  CodeEdit.Lines.BeginUpdate;
  T := Clipboard.AsText;
  n := '';
  i := 1;
  while i < T.Len do
    begin
      C := T[i];
      Inc(i);
      if C <> #13 then
          n.Append(C);

      if C = #10 then
        begin
          CodeEdit.Lines.Add(n.Text);
          n := '';
        end;
    end;
  CodeEdit.Lines.EndUpdate;
end;

procedure TBuildCodeMainForm.StripedToolButtonClick(Sender: TObject);
begin
  StrippedContextForm.OnReturnProc := nil;
  StrippedContextForm.NewCT;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.show;

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

procedure TBuildCodeMainForm.copyCodeButtonClick(Sender: TObject);
var
  n: U_String;
begin
  n := CodeEdit.Text;
  n := umlDeleteChar(n, [#10]);
  Clipboard.AsText := n.Text;
end;

function TBuildCodeMainForm.GetPascalUnitInfo(T: TTextParsing; const initPos: Integer; var OutPos: TTextPos): Boolean;
var
  cp: Integer;
  ePos: Integer;
  InitedUnit: Boolean;
  s: U_String;
begin
  Result := False;
  InitedUnit := False;

  cp := initPos;

  while cp <= T.ParsingData.Len do
    begin
      if T.isTextDecl(cp) then
        begin
          cp := T.GetTextDeclEndPos(cp);
        end
      else if T.isComment(cp) then
        begin
          cp := T.GetCommentEndPos(cp);
        end
      else if T.isNumber(cp) then
        begin
          cp := T.GetNumberEndPos(cp);
        end
      else if T.isSymbol(cp) then
        begin
          if InitedUnit then
            if T.GetChar(cp) = ';' then
              begin
                OutPos.ePos := cp + 1;
                Result := True;
                Break;
              end;
          ePos := T.GetSymbolEndPos(cp);
          cp := ePos;
        end
      else if T.isAscii(cp) then
        begin
          ePos := T.GetAsciiEndPos(cp);
          if not InitedUnit then
            begin
              s := T.GetStr(cp, ePos);
              if (s.Same('unit')) or (s.Same('program')) then
                begin
                  InitedUnit := True;
                  OutPos.bPos := cp;
                end;
            end;
          cp := ePos;
        end
      else
          Inc(cp);
    end;
end;

procedure TBuildCodeMainForm.BuildPascalSource2CT(unitName: string; tp: TTextParsing; TB: TTextTable);
var
  J: Integer;
  tPos: TTextPos;
  uName: string;
  pPos: PTextPos;

  sc, CC: Integer;
begin
  uName := unitName;

  sc := 0;
  CC := 0;

  for J := 0 to tp.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := tp.ParsingData.Cache.TextDecls[J];
      TB.AddPascalText(pPos^.Text, uName, False);
      Inc(sc);
    end;

  if IncludePascalCommentCheckBox.Checked then
    for J := 0 to tp.ParsingData.Cache.CommentDecls.Count - 1 do
      begin
        pPos := tp.ParsingData.Cache.CommentDecls[J];
        if not IgnorePascalDirectivesCheckBox.Checked then
          begin
            TB.AddPascalComment(pPos^.Text, uName, False);
            Inc(CC);
          end
        else if not pPos^.Text.Exists('$') then
          begin
            TB.AddPascalComment(pPos^.Text, uName, False);
            Inc(CC);
          end;
      end;
  DoStatus('Build ct with Pascal "%s" string:%d comment:%d', [unitName, sc, CC]);
end;

procedure TBuildCodeMainForm.BuildPascalSource2CT(fn: string; TB: TTextTable);
var
  ns: TCoreClassStringList;
  T: TTextParsing;
begin
  ns := TCoreClassStringList.Create;
  try
      ns.LoadFromFile(fn, TEncoding.UTF8);
  except
      ns.LoadFromFile(fn);
  end;
  T := TTextParsing.Create(ns.Text, tsPascal, nil);

  BuildPascalSource2CT(umlGetFileName(fn), T, TB);

  DisposeObject(T);
  DisposeObject(ns);
end;

procedure TBuildCodeMainForm.BuildC_Source2CT(unitName: string; tp: TTextParsing; TB: TTextTable);
var
  J: Integer;
  tPos: TTextPos;
  uName: string;
  pPos: PTextPos;

  sc, CC: Integer;
begin
  uName := unitName;

  sc := 0;
  CC := 0;

  for J := 0 to tp.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := tp.ParsingData.Cache.TextDecls[J];
      TB.AddCText(pPos^.Text, uName, False);
      Inc(sc);
    end;

  if IncludeCCommentCheckBox.Checked then
    for J := 0 to tp.ParsingData.Cache.CommentDecls.Count - 1 do
      begin
        pPos := tp.ParsingData.Cache.CommentDecls[J];
        if not IgnoreCDirectivesCheckBox.Checked then
          begin
            TB.AddCComment(pPos^.Text, uName, False);
            Inc(CC);
          end
        else if not pPos^.Text.Exists('#') then
          begin
            TB.AddCComment(pPos^.Text, uName, False);
            Inc(CC);
          end;
      end;
  DoStatus('Build ct with C "%s" string:%d comment:%d', [unitName, sc, CC]);
end;

procedure TBuildCodeMainForm.BuildC_Source2CT(fn: string; TB: TTextTable);
var
  ns: TCoreClassStringList;
  T: TTextParsing;
begin
  ns := TCoreClassStringList.Create;
  try
      ns.LoadFromFile(fn, TEncoding.UTF8);
  except
      ns.LoadFromFile(fn);
  end;
  T := TTextParsing.Create(ns.Text, tsC, nil);

  BuildC_Source2CT(umlGetFileName(fn), T, TB);

  DisposeObject(T);
  DisposeObject(ns);
end;

procedure TBuildCodeMainForm.BuildDFMSource2CT(unitName: string; tp: TTextParsing; TB: TTextTable);
var
  J: Integer;
  tPos: TTextPos;
  uName: string;
  pPos: PTextPos;

  sc: Integer;
begin
  uName := unitName;

  sc := 0;

  for J := 0 to tp.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := tp.ParsingData.Cache.TextDecls[J];
      if umlTrimSpace(TTextParsing.TranslatePascalDeclToText(pPos^.Text)).Len > 0 then
        begin
          TB.AddDelphiFormText(pPos^.Text, uName, False);
          Inc(sc);
        end;
    end;
  DoStatus('Build ct with delphi Form "%s" string:%d', [unitName, sc]);
end;

procedure TBuildCodeMainForm.BuildDFMSource2CT(fn: string; TB: TTextTable);
var
  ns: TCoreClassStringList;
  T: TTextParsing;
begin
  ns := TCoreClassStringList.Create;
  try
      ns.LoadFromFile(fn, TEncoding.UTF8);
  except
      ns.LoadFromFile(fn);
  end;
  T := TTextParsing.Create(ns.Text, tsPascal, nil);

  BuildDFMSource2CT(umlGetFileName(fn), T, TB);

  DisposeObject(T);
  DisposeObject(ns);
end;

procedure TBuildCodeMainForm.TranslateCT2_Pascal(Code: TStrings; TB: TTextTable);
var
  i, J: Integer;
  T: TTextParsing;
  pPos: PTextPos;
  p: PTextTableItem;
begin
  T := TTextParsing.Create(Code.Text, tsPascal, nil);

  for J := 0 to T.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := T.ParsingData.Cache.TextDecls[J];
      p := TB.Search(pPos^.Text);
      if p <> nil then
        begin
          pPos^.Text := p^.DefineText;
          DoStatus('Translate Pascal String ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
        end;
    end;

  if IncludePascalCommentCheckBox.Checked then
    for J := 0 to T.ParsingData.Cache.CommentDecls.Count - 1 do
      begin
        pPos := T.ParsingData.Cache.CommentDecls[J];
        if not IgnorePascalDirectivesCheckBox.Checked then
          begin
            p := TB.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate Pascal Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end
        else if not pPos^.Text.Exists('$') then
          begin
            p := TB.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate Pascal Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end;
      end;

  T.RebuildText;
  Code.Text := T.ParsingData.Text;

  DisposeObject(T);
end;

procedure TBuildCodeMainForm.UsedOriginOutputDirectoryCheckBoxClick(Sender: TObject);
begin
  OutPathEdit.Enabled := not UsedOriginOutputDirectoryCheckBox.Checked;
end;

procedure TBuildCodeMainForm.TranslateCT2_C(Code: TStrings; TB: TTextTable);
var
  i, J: Integer;
  T: TTextParsing;
  pPos: PTextPos;
  p: PTextTableItem;
begin
  T := TTextParsing.Create(CodeEdit.Text, tsC, nil);

  for J := 0 to T.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := T.ParsingData.Cache.TextDecls[J];
      p := TB.Search(pPos^.Text);
      if p <> nil then
        begin
          pPos^.Text := p^.DefineText;
          DoStatus('Translate C String ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
        end;
    end;

  if IncludeCCommentCheckBox.Checked then
    for J := 0 to T.ParsingData.Cache.CommentDecls.Count - 1 do
      begin
        pPos := T.ParsingData.Cache.CommentDecls[J];
        if not IgnoreCDirectivesCheckBox.Checked then
          begin
            p := TB.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate C Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end
        else if not pPos^.Text.Exists('#') then
          begin
            p := TB.Search(pPos^.Text);
            if p <> nil then
              begin
                pPos^.Text := p^.DefineText;
                DoStatus('Translate C Comment ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
              end;
          end;
      end;

  T.RebuildText;
  CodeEdit.Text := T.ParsingData.Text;

  DisposeObject(T);
end;

procedure TBuildCodeMainForm.TranslateCT2_DFM(Code: TStrings; TB: TTextTable);
var
  i, J: Integer;
  T: TTextParsing;
  pPos: PTextPos;
  p: PTextTableItem;
begin
  T := TTextParsing.Create(Code.Text, tsPascal, nil);

  for J := 0 to T.ParsingData.Cache.TextDecls.Count - 1 do
    begin
      pPos := T.ParsingData.Cache.TextDecls[J];
      if umlTrimSpace(TTextParsing.TranslatePascalDeclToText(pPos^.Text)).Len > 0 then
        begin
          p := TB.Search(pPos^.Text);
          if p <> nil then
            begin
              pPos^.Text := p^.DefineText;
              DoStatus('Translate DFM String ' + #13#10 + '%s' + #13#10 + ' as ' + #13#10 + '%s' + #13#10, [p^.OriginText, p^.DefineText]);
            end;
        end;
    end;

  T.RebuildText;
  Code.Text := T.ParsingData.Text;

  DisposeObject(T);
end;

procedure TBuildCodeMainForm.CTEditorReturn_Pascal(TB: TTextTable);
var
  pt: TPoint;
begin
  pt := CodeEdit.CaretPos;
  TranslateCT2_Pascal(CodeEdit.Lines, TB);
  CodeEdit.CaretPos := pt;
end;

procedure TBuildCodeMainForm.CTEditorReturn_C(TB: TTextTable);
var
  pt: TPoint;
begin
  pt := CodeEdit.CaretPos;
  TranslateCT2_C(CodeEdit.Lines, TB);
  CodeEdit.CaretPos := pt;
end;

procedure TBuildCodeMainForm.CTEditorReturn_DFM(TB: TTextTable);
var
  pt: TPoint;
begin
  pt := CodeEdit.CaretPos;
  TranslateCT2_DFM(CodeEdit.Lines, TB);
  CodeEdit.CaretPos := pt;
end;

procedure TBuildCodeMainForm.CTEditorReturn_BuildCode(TB: TTextTable);
var
  i, J: Integer;
  ns: TCoreClassStringList;
begin
  if MessageDlg('so now,Translate all code?', mtInformation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

  if (not UsedOriginOutputDirectoryCheckBox.Checked) and (not TDirectory.Exists(OutPathEdit.Text)) then
    begin
      MessageDlg(Format('directory "%s" no exists', [OutPathEdit.Text]), mtError, [mbYes], 0);
      Exit;
    end;

  for i := 0 to FileListBox.Items.Count - 1 do
    begin
      ns := TCoreClassStringList.Create;
      try
          ns.LoadFromFile(FileListBox.Items[i], TEncoding.UTF8);
      except
          ns.LoadFromFile(FileListBox.Items[i]);
      end;

      if umlMultipleMatch(['*.pas', '*.inc', '*.dpr'], FileListBox.Items[i]) then
        begin
          TranslateCT2_Pascal(ns, TB);
          if UsedOriginOutputDirectoryCheckBox.Checked then
              ns.SaveToFile(FileListBox.Items[i], TEncoding.UTF8)
          else
              ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end
      else if umlMultipleMatch(['*.c', '*.cpp', '*.cc', '*.cs', '*.h', '*.hpp'], FileListBox.Items[i]) then
        begin
          TranslateCT2_C(ns, TB);
          if UsedOriginOutputDirectoryCheckBox.Checked then
              ns.SaveToFile(FileListBox.Items[i], TEncoding.UTF8)
          else
              ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end
      else if umlMultipleMatch(['*.dfm', '*.fmx', '*.lfm'], FileListBox.Items[i]) then
        begin
          TranslateCT2_DFM(ns, TB);
          if UsedOriginOutputDirectoryCheckBox.Checked then
              ns.SaveToFile(FileListBox.Items[i], TEncoding.UTF8)
          else
              ns.SaveToFile(umlCombineFileName(OutPathEdit.Text, umlGetFileName(FileListBox.Items[i])), TEncoding.UTF8);
        end;
      DisposeObject(ns);
    end;

  DoStatus('all merge finished!', []);
end;

end. 
