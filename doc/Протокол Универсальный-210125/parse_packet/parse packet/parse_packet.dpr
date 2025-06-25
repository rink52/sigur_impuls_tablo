program parse_packet;

uses
  Forms,
  main in 'main.pas' {MainInfoForm},
  IniUnit in 'IniUnit.pas',
  ConnTypes in 'ConnTypes.pas',
  AddUnit in 'AddUnit.pas',
  CRCUnit in 'CRCUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Parser';
  Application.CreateForm(TMainInfoForm, MainInfoForm);
  Application.Run;
end.
