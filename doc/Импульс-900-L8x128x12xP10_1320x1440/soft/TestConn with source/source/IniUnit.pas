unit IniUnit;

interface
uses Windows;

type
     TIniSet=record
             Position:TRect;
             PortNum:integer;
             Options, Id:integer;
             TCPPort, UDPPort:string;
             Data:string;
             end;

     PIniSet=^TIniSet;

var Ini:TIniSet;
const IniFileName:string='sport.ini';

procedure WriteIniFile(const Ini:TIniSet);
procedure ReadIniFile(var Ini:TIniSet);

implementation
uses IniFiles, SysUtils, AddFuncts;

const cIniParCount=7;
      RelPath='%PROGPATH%';
      cSect='Settings';
      cIniPars:array [1..cIniParCount] of PChar=(
      { 1 } 'Position',
      { 2 } 'PortNum',
      { 3 } 'Options',
      { 4 } 'TCPPort',
      { 5 } 'ID',
      { 6 } 'UDPPort',
      { 7 } 'Data'
      );

procedure ReadIniFile(var Ini:TIniSet);
 var M:TMemIniFile;
//     err:boolean;
//     i:integer;
  begin
  try
  M:=TMemIniFile.Create(IniFileName);
  Ini.Position:=StringToRect(M.ReadString(cSect,cIniPars[1],''));
  Ini.PortNum:=M.ReadInteger(cSect, cIniPars[2], 1);
  Ini.Options:=M.ReadInteger(cSect, cIniPars[3],0);
  Ini.ID:=M.ReadInteger(cSect, cIniPars[5], $FFFF);
  Ini.TCPPort:=M.ReadString(cSect, cIniPars[4],'192.168.0.11:5000');
  Ini.UDPPort:=M.ReadString(cSect, cIniPars[6],'192.168.0.11:51234');
  Ini.Data:=M.ReadString(cSect, cIniPars[7],'1234');
  M.Free;
  except
  end;
  end;

procedure WriteIniFile(const Ini:TIniSet);
 var f:text;
//     i:integer;
  begin
  try
  assign(f,IniFileName);
  rewrite(f);
  writeln(f,'[',cSect,']');
  writeln(f,cIniPars[1],'=',RectToString(Ini.Position));
  writeln(f,cIniPars[2],'=',Ini.PortNum);
  writeln(f,cIniPars[3],'=',Ini.Options);
  writeln(f,cIniPars[5],'=',Ini.Id);
  writeln(f,cIniPars[4],'=',Ini.TCPPort);
  writeln(f,cIniPars[6],'=',Ini.UDPPort);
  writeln(f,cIniPars[7],'=',Ini.Data);
  close(f);
  except
  end;
  end;

initialization
IniFileName:=Path+FileNameWithnewExt(ExeFileName,'.ini');
end.

