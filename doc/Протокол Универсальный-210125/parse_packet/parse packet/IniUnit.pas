unit IniUnit;

interface
uses Windows;

type
     TIniSet=record
             Data:string;
             end;

     PIniSet=^TIniSet;

var Ini:TIniSet;
const IniFileName:string='parse_packet.ini';

procedure WriteIniFile(const Ini:TIniSet);
procedure ReadIniFile(var Ini:TIniSet);

implementation
uses SysUtils, IniFiles;

const cIniParCount=1;
      RelPath='%PROGPATH%';
      cSect='Settings';
      cIniPars:array [1..cIniParCount] of PChar=(
      { 1 } 'Data'
      );

procedure ReadIniFile(var Ini:TIniSet);
 var M:TMemIniFile;
     err:boolean;
  begin
  try
  M:=TMemIniFile.Create(IniFileName);
  Ini.Data:=M.ReadString(cSect,cIniPars[1], '02  8A  80  80  80  7F  FF  7F  FF  81  84  80  7F  80  80  80  91  E7  03');
  M.Free;
  except
  end;
  end;


procedure WriteIniFile(const Ini:TIniSet);
 var M:TMemIniFile;
  begin
  M:=Nil;
  try
  M:=TMemIniFile.Create(IniFileName);
  M.WriteString(cSect, cIniPars[1], Ini.Data);
  M.UpdateFile;
  except
  end;
  M.Free;
  end;

end.

