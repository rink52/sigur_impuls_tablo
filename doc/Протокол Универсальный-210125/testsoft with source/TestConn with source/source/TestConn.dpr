program TestConn;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {DemoForm},
  GlbDecls in 'GlbDecls.pas',
  IniUnit in 'IniUnit.pas',
  AddFuncts in 'AddFuncts.pas',
  CommlibNew in 'CommlibNew.pas',
  ConnTypes in 'ConnTypes.pas',
  CRCUnit in 'CRCUnit.pas',
  DevTransp in 'DevTransp.pas',
  Protocol in 'Protocol.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.
