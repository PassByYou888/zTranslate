program zTranslate;

uses
  Vcl.Forms,
  BatchTransOptFrm in 'BatchTransOptFrm.pas' {BatchTransOptForm},
  zTranslateMainFrm in 'zTranslateMainFrm.pas' {BuildCodeMainForm},
  LogFrm in 'LogFrm.pas' {LogForm},
  QuickTranslateFrm in 'QuickTranslateFrm.pas' {QuickTranslateForm},
  StrippedContextFrm in 'StrippedContextFrm.pas' {StrippedContextForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TBuildCodeMainForm, BuildCodeMainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TBatchTransOptForm, BatchTransOptForm);
  Application.CreateForm(TQuickTranslateForm, QuickTranslateForm);
  Application.CreateForm(TStrippedContextForm, StrippedContextForm);
  Application.Run;
end.
