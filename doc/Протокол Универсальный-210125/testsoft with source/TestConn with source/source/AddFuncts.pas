unit AddFuncts;

interface
uses Windows, classes, SysUtils;

const
//      RelPath='%PROGPATH%';
      Path:string='';
      WindowsDirectory:string='';
      SystemDirectory:string='';
      ExeFileName:string='';

type
{$WARNINGS OFF}
     TypeCharSet=set of char;
{$WARNINGS ON}
     TypeByteSet=set of byte;

     PSearchRec=^TSearchRec;

     TTimeRecord=record
                 Hour,Min,Sec:integer;
                 end;

        TDBFDate=record
                 Day,Month,Year:integer;
                 end;
 TBCDTime=packed record
          bcdSec, bcdMin, bcdHour, bcdDay, bcdDate, bcdMonth, bcdYear:byte;
          end;

function TimeStampString(ST:TSystemTime; ShowSec:boolean):string;
function IntToStrN(v:integer; N:integer):string;
function RectToString(R:TRect):string;
function StringToRect(const S:string):TRect;
function PosFromPos(const substr : string; s : string ;StPos:integer) : Integer;

procedure CorrectDir(var Dir:string);
function FileNameWithNewExt(Fn,Ext:string):string;

function SimpleSplitStringDiv(S:string;Dv:string):TStringList;
function StringToNumber(const S:string; Osn:cardinal):cardinal;

function  MessBox(const Capt, Mess:string;Opt:integer):integer;
procedure ConnErrMess;
procedure ErrMess(const S:string);
procedure InfoMess(const S:string);

implementation
uses Forms;

function TimeStampString(ST:TSystemTime; ShowSec:boolean):string;
var tm:string;
  begin
  Result:=IntToStr(ST.wDay)+'.'+IntToStrN(ST.wMonth,2)+'.'+IntToStrN(ST.wYear,4);
  tm:=IntToStr(ST.wHour)+':'+IntToStrN(ST.wMinute,2);
  if ShowSec then tm:=tm+':'+IntToStrN(ST.wSecond,2);
  Result:=Result+'   '+tm;
  end;

function IntToStrN(v:integer; N:integer):string;
  begin
  Result:=Format('%.'+IntToStr(n)+'d', [v]);
  end;

function RectToString(R:TRect):string;
  begin
  Result:=IntToStr(R.Left)+','+IntToStr(R.Top)+','+IntToStr(R.Right)+','+IntToStr(R.Bottom);
  end;

function SimpleSplitStringDiv(S:string;Dv:string):TStringList;
 var p,ld:integer;
  begin
  S:=trim(S);
  Result:=TStringList.Create;
  if S='' then Exit;
  Result.Sorted:=false;
  ld:=Length(dv);
  if ld=0 then Exit;
  repeat
  p:=Pos(Dv,S);
  if p=0 then begin
              Result.Add(trim(S))
              end
         else begin
              Result.Add(trim(copy(S,1,p-1)));
              S:=copy(S,p+ld,Length(S)-p-ld+1);
              end;
  until p=0;
  end;


type TInt4=array[0..3] of integer;
     PInt4=^TInt4;

function StringToRect(const S:string):TRect;
 var SL:TStringList;
     i,k,cd,n:integer;
     P:PInt4;
  begin
  SL:=SimpleSplitStringDiv(S,',');
  FillChar(Result,SizeOf(Result),0);
  n:=SL.Count;
  if n>4 then n:=4;
  P:=@Result;
  for i:=0 to n-1 do
    begin
    Val(trim(SL[i]),k,cd);
    P^[i]:=k;
    end;
  SL.Free;
  end;

procedure CorrectDir(var Dir:string);
 var l:integer;
  begin
  l:=Length(Dir);
  if (l>0) and (Dir[l]<>'\') then Dir:=Dir+'\';
  end;

procedure GetPath;
 var i:integer;
  begin
  Path:=Paramstr(0);
  i:=Length(Path);
  while (i>0) and (Path[i]<>'\') do dec(i);
  ExeFileName:=copy(Path,i+1,Length(Path)-i);
  if i<>0 then Path:=copy(Path,1,i);
  end;

procedure GetWinSysDirs;
const l=2048;
var a:array[0..l] of Char;
  begin
  FillChar(a,SizeOf(a),0);
  GetWindowsDirectory(a,l-1);
  WindowsDirectory:=a;
  CorrectDir(WindowsDirectory);
  FillChar(a,SizeOf(a),0);
  GetSystemDirectory(a,l);
  SystemDirectory:=a;
  CorrectDir(SystemDirectory);
  end;

function FileNameWithNewExt(Fn,Ext:string):string;
 var i,l:integer;
  begin
  result:='';
  i:=Length(Fn);
  if i=0 then Exit;
  l:=i;
  while (i>0) and (Fn[i]<>'\') and (Fn[i]<>'.')do dec(i);
  if (i>0) and (Fn[i]='.') then Delete(Fn,i,l-i+1);
  FileNameWithNewExt:=Fn+Ext;
  end;

function  PosFromPos(const substr : string; s : string ;StPos:integer) : Integer;
 var sublen, len:integer;
     PC:PChar;
  begin
  len:=Length(s);
  sublen:=length(substr);
  if (StPos+sublen-1)>len then begin
                               Result:=0;
                               Exit;
                               end;
  PC:=Pointer(s);
  inc(PC, StPos-1);
  Result:=Pos(substr, PC);
  if Result>0 then Result:=Result+StPos-1;
  end;

function StringToNumber(const S:string; Osn:cardinal):cardinal;
 var i:integer;
     c,m:cardinal;
     ch:char;
     k:integer;
  begin
  Result:=0;
  try
  c:=1;
  for i:=Length(S) downto 1 do
    begin
    ch:=Upcase(S[i]);
    if ch in ['0'..'9'] then k:=ord(ch)-48
                        else k:=ord(ch)-55;
    if (k>=0) and (k<integer(Osn)) then begin
                                        m:=int64(k)*int64(c);
                                        Result:=result+m;
                                        end;
    if i>1 then c:=int64(c)*int64(Osn);
    end;
  except
  Result:=0;
  end;
  end;
function MessBox(const Capt, Mess:string;Opt:integer):integer;
  begin
  Result:=Application.MessageBox(PChar(Mess), PChar(Capt), Opt);
  end;

procedure InfoMess(const S:string);
  begin
  MessBox('Информация',S,MB_TASKMODAL+MB_ICONINFORMATION);
  end;

procedure ErrMess(const S:string);
  begin
  MessBox('Ошибка',S,MB_TASKMODAL+MB_ICONERROR);
  end;

procedure ConnErrMess;
  begin
  ErrMess('Ошибка соединения!');
  end;

{$WARNINGS ON}
begin
GetPath;
GetWinSysDirs;

end.
