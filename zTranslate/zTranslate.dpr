program zTranslate;

uses
  Vcl.Forms,
  BatchTransOptFrm in 'BatchTransOptFrm.pas' {BatchTransOptForm},
  zTranslateMainFrm in 'zTranslateMainFrm.pas' {BuildCodeMainForm},
  VCLLogFrm in 'VCLLogFrm.pas' {LogForm},
  QuickTranslateFrm in 'QuickTranslateFrm.pas' {QuickTranslateForm},
  StrippedContextFrm in 'StrippedContextFrm.pas' {StrippedContextForm},
  BaiduTranslateClient in '..\zTranslateBaiduService\Client.Lib\BaiduTranslateClient.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.Title := 'zTranslate';
  Application.CreateForm(TBuildCodeMainForm, BuildCodeMainForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TBatchTransOptForm, BatchTransOptForm);
  Application.CreateForm(TQuickTranslateForm, QuickTranslateForm);
  Application.CreateForm(TStrippedContextForm, StrippedContextForm);
  Application.Run;
end.
