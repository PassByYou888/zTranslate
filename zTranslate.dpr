program zTranslate;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  BatchTransOptFrm in 'BatchTransOptFrm.pas' {BatchTransOptForm},
  BuildTextMainFrm in 'BuildTextMainFrm.pas' {Pascal2CTMainForm},
  LogFrm in 'LogFrm.pas' {LogForm},
  QuickTranslateFrm in 'QuickTranslateFrm.pas' {QuickTranslateForm},
  StrippedContextFrm in 'StrippedContextFrm.pas' {StrippedContextForm},
  BaiduTranslateClient in 'BaiduTranslateClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPascal2CTMainForm, Pascal2CTMainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TBatchTransOptForm, BatchTransOptForm);
  Application.CreateForm(TPascal2CTMainForm, Pascal2CTMainForm);
  Application.CreateForm(TQuickTranslateForm, QuickTranslateForm);
  Application.CreateForm(TStrippedContextForm, StrippedContextForm);
  Application.Run;
end.
