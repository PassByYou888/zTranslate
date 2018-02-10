unit BuildTextMainFrm;

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
  TPascal2CTMainForm = class(TForm)
    PageControl1: TPageControl;
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
  end;

var
  Pascal2CTMainForm: TPascal2CTMainForm;

implementation

{$R *.dfm}


uses StrippedContextFrm, LogFrm;

procedure TPascal2CTMainForm.FormCreate(Sender: TObject);
var
  fn: string;
begin
  Table := TTextTable.Create;
  Config := TSectionTextData.Create;
  fn := TPath.Combine(TPath.GetDocumentsPath, 'Pascal2CT.cfg');
  if TFile.Exists(fn) then
    begin
      Config.LoadFromFile(fn);
    end;
  FileListBox.Items.Assign(Config.Names['Files']);
  OutPathEdit.Text := Config.GetDefaultValue('main', 'output', TPath.GetDocumentsPath);
  IncludePascalCommentCheckBox.Checked := Config.GetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  IgnorePascalDirectivesCheckBox.Checked := Config.GetDefaultValue('main', 'Directives', IgnorePascalDirectivesCheckBox.Checked);
  IncludeCCommentCheckBox.Checked := Config.GetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
end;

procedure TPascal2CTMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn: string;
begin
  fn := TPath.Combine(TPath.GetDocumentsPath, 'Pascal2CT.cfg');
  Config.Names['Files'].Assign(FileListBox.Items);
  Config.SetDefaultValue('main', 'output', OutPathEdit.Text);
  Config.SetDefaultValue('main', 'PascalComment', IncludePascalCommentCheckBox.Checked);
  Config.SetDefaultValue('main', 'Directives', IgnorePascalDirectivesCheckBox.Checked);
  Config.SetDefaultValue('main', 'CComment', IncludeCCommentCheckBox.Checked);
  Config.SaveToFile(fn);

  Action := caFree;
  DisposeObject(Config);
  DisposeObject(Table);
end;

procedure TPascal2CTMainForm.AddButtonClick(Sender: TObject);
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

procedure TPascal2CTMainForm.BuildButtonClick(Sender: TObject);
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
  StrippedContextForm.OnReturnProc := nil;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.LoadNewCTFromStream(ms);
  StrippedContextForm.OnReturnProc := nil;
  StrippedContextForm.Show;
  DisposeObject(ms);
end;

procedure TPascal2CTMainForm.BrowsePathButtonClick(Sender: TObject);
var
  d: string;
begin
  d := OutPathEdit.Text;
  if Vcl.FileCtrl.SelectDirectory('output directory', '', d) then
      OutPathEdit.Text := d;
end;

procedure TPascal2CTMainForm.ImportButtonClick(Sender: TObject);
var
  ms  : TMemoryStream64;
  i, j: integer;
  ns  : TCoreClassStringList;
  t   : TTextParsing;
  pPos: PTextPos;
  p   : PTextTableItem;
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
          t := TTextParsing.Create(ns.Text, tsPascal);

          for j := 0 to t.ParsingData.Cache.TextData.Count - 1 do
            begin
              pPos := t.ParsingData.Cache.TextData[j];
              p := Table.Search(pPos^.Text);
              if p <> nil then
                  pPos^.Text := p^.DefineText;
            end;

          if IncludePascalCommentCheckBox.Checked then
            for j := 0 to t.ParsingData.Cache.CommentData.Count - 1 do
              begin
                pPos := t.ParsingData.Cache.CommentData[j];
                if IncludePascalCommentCheckBox.Checked then
                  begin
                    p := Table.Search(pPos^.Text);
                    if p <> nil then
                        pPos^.Text := p^.DefineText;
                  end
                else if not pPos^.Text.Exists('$') then
                  begin
                    p := Table.Search(pPos^.Text);
                    if p <> nil then
                        pPos^.Text := p^.DefineText;
                  end;
              end;

          t.RebuildText;
          ns.Text := t.TextData.Text;
          ns.SaveToFile(TPath.Combine(OutPathEdit.Text, TPath.GetFileName(FileListBox.Items[i])), TEncoding.UTF8);

          DisposeObject(t);
        end;
      DisposeObject(ns);
    end;

  MessageDlg(Format('finished!', []), mtInformation, [mbYes], 0);
end;

procedure TPascal2CTMainForm.PascalcodeForTextStripedToolButtonClick(Sender: TObject);
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
end;

procedure TPascal2CTMainForm.Pascalstyle_RadioButtonClick(Sender: TObject);
begin
  CodeEdit.Highlighter := SynPasSyn;
end;

procedure TPascal2CTMainForm.StripedToolButtonClick(Sender: TObject);
begin
  StrippedContextForm.OnReturnProc := nil;
  StrippedContextForm.NewCT;
  StrippedContextForm.PopupParent := Self;
  StrippedContextForm.Show;
end;

procedure TPascal2CTMainForm.ClearButtonClick(Sender: TObject);
begin
  FileListBox.Clear;
end;

procedure TPascal2CTMainForm.Cstyle_RadioButtonClick(Sender: TObject);
begin
  CodeEdit.Highlighter := SynCppSyn;
end;

function TPascal2CTMainForm.GetPascalUnitInfo(t: TTextParsing; const initPos: integer; var outPos: TTextPos): Boolean;
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

procedure TPascal2CTMainForm.BuildPascalSource2CT(unitName: string; tp: TTextParsing; tb: TTextTable);
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

procedure TPascal2CTMainForm.BuildPascalSource2CT(fn: string; tb: TTextTable);
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

procedure TPascal2CTMainForm.BuildC_Source2CT(unitName: string; tp: TTextParsing; tb: TTextTable);
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

procedure TPascal2CTMainForm.BuildC_Source2CT(fn: string; tb: TTextTable);
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

procedure TPascal2CTMainForm.TranslateCT2_Pascal(code: TStrings; tb: TTextTable);
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

procedure TPascal2CTMainForm.TranslateCT2_C(code: TStrings; tb: TTextTable);
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

procedure TPascal2CTMainForm.CTEditorReturn_Pascal(tb: TTextTable);
var
  tl: integer;
begin
  tl := CodeEdit.TopLine;
  TranslateCT2_Pascal(CodeEdit.Lines, tb);
  CodeEdit.TopLine := tl;
end;

procedure TPascal2CTMainForm.CTEditorReturn_C(tb: TTextTable);
var
  tl: integer;
begin
  tl := CodeEdit.TopLine;
  TranslateCT2_C(CodeEdit.Lines, tb);
  CodeEdit.TopLine := tl;
end;

end.
