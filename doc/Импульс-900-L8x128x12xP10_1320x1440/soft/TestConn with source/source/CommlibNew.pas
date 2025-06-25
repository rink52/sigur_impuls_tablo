unit commlibNew;

interface
uses Windows, Classes, SysUtils, WinSock, ConnTypes;

const
      cSpeedsCount=9;
      UDPTimeOut=200;

      cSpeedTable:array[0..cSpeedsCount-1] of integer=(
      1200, 2400, 4800, 9600,
      19200, 28800, 38400, 57600, 115200
      );

     IsWinNT:boolean=false;
     cDefBaudRate=57600;

     cTextBuffMask=8191;
     cModemBadAnswCount=5;
     ModemBadAnswer:array[0..cModemBadAnswCount-1] of string=(
      'ERROR',
      'NO CARRIER',
      'NO DIAL TONE',
      'BUSY',
      'NO ANSWER'
      );
      
     ModemBadAnswerRus:array[0..cModemBadAnswCount-1] of string=(
      '','','','',''
      );

type
     TDataProc=procedure(Data:pointer;DataCount:integer) of object;
     TConnectProcessProc=procedure(const CurrMess, CurState:string; Status, Reserved:integer; var UserMode:integer) of object;

     PBoolean=^Boolean;
     
     TComPort=class;
     TTmThread=class(TThread)
                PS, PB:PBoolean;
                constructor Create(TS, TP:PBoolean);
                procedure Execute;override;
                end;

  TSimpleProc=procedure of object;
  
  TWaitTimer=class
             private
             FStartTime:int64;
             FTmOut:int64;
             public
             procedure SetTimeOut(Time:integer);
             function TimeOut:boolean;
             end;

  TRecThread=class;

  TBuffer=class
          private
          FRC:TRecThread;
          FBlockReady:boolean;
          FRecPacket:TLevel2Pack;
          RecData:array[0..RecBuffSizeByte*2-1] of byte;
          FBlockSize:integer;
          FCrSect:TRTLCriticalSection;
          RecStage, RecPtr, InLen:integer;
//          PrevCmd, PrevId:byte;
          procedure PutData(dt:byte);
          public
          procedure   Clear;
          constructor Create;
          Destructor Destroy;override;
          function ReadBuff(var Buff; BuffSize:integer; var ReadCount:integer):boolean;
          function ReadBuffNoCritical(var Buff; BuffSize:integer; var ReadCount:integer):boolean;
          end;

  TRecThread=class(TThread)
             private
             FBuff:TBuffer;
             FPort:TComPort;
             FEnab, FExec:boolean;
             FProc:TSimpleProc;
             FActiveProc,stopped:boolean;
             SkipCount:integer;
             protected
             procedure Execute;override;
             function CheckInput:boolean;
             public
             constructor Create;
             Destructor Destroy;override;
             property Buffer:TBuffer read FBuff;
             end;

  TComPort=class
           private
           FDTR,FRTS:boolean;
           FErrorCode:integer;
           FProc:TSimpleProc;
           FCC:_COMMCONFIG;
//           FComList:TStringList;
//           FFreeList:TStringList;
           FPortHandle:THandle;
           WSAOpened, SockOpened:boolean;
           FSocket:TSocket;
           FPortOpened:boolean;

           FUDPMode:boolean;
           UDPAddr: TSockAddrIn;

           FError:boolean;
           FErrorString:string;
           FComName:string;
           FEventVar:cardinal;
           FRecThread:TRecThread;
           FWaitTimer:TWaitTimer;
           FDefDTR, FDefRTS:boolean;
           FTBSect:TRTLCriticalSection;
           TextBuff:array[0..cTextBuffMask] of byte;
           TextBuffPtr, TextBuffSize:integer;
           DataProc:TDataProc;
           EnableConnectInfo:boolean;
           ConnectInfoProc:TConnectProcessProc;
           ExecFlag:boolean;
           CTO:TCOMMTIMEOUTS;
           PrevCommand, PrevPackId:byte;
           procedure NewRecThread;
           procedure FreeRecThread;
           procedure SetComPort(const ComName:string);
           procedure SetComPortComMode(const ComName:string);
           procedure SetIPPortTCP(IPAddr:AnsiString; PNo:integer);
           procedure SetIPPortUDP(IPAddr:AnsiString; PNo:integer);
           procedure ClosePort;
           function GetParity:byte;
           procedure SetParity(N:byte);
           function GetStop:byte;
           procedure SetStop(N:byte);
           function GetByteSize:byte;
           procedure SetByteSize(N:byte);
           function GetBaudRate:DWORD;
           procedure SetBaudRate(N:DWORD);
           function GetFlags:longint;
           procedure SetFlags(F:LongInt);
           function GetActiveIdle:boolean;
           procedure SetActiveIdle(A:boolean);
           procedure SetDTRPin(State:boolean);
           procedure SetRTSPin(State:boolean);
           function SetCommConfig(hCommDev: THandle; const lpCC: TCommConfig; dwSize: DWORD): BOOL;
           function GetConfigString:string;
           procedure SetConfigString(const s:string);
           procedure SetPortConfig(const Value: _COMMCONFIG);
           procedure DefaultDataProc(Data:pointer;DataCount:integer);
           procedure SetTimeOuts;
           function ReadDeviceData(var Buff; sz:integer):integer;
           procedure SetUDPMode(const Value: boolean);
           function OpenUDPList(bc: boolean): boolean;
           function StartUDPListening(bc: boolean): boolean;
           procedure CloseSockWSA;
          function ReadUDPAnswer(var clientaddr: SOCKADDR_IN; Buff: pointer; BuffSz: integer; var rsz: integer; TmOut_ms: integer): boolean;

           public

{$IFDEF DEBUG_MODE}
           LastSendSize:integer;
           LastSend:array[0..4095] of byte;
           LastRecSize:integer;
           LastRec:array[0..4095] of byte;
{$ENDIF}
           NoWaitAnswer:boolean;
           NoCheckID:boolean;
           Transit:boolean;
           WaitTimeOut:integer;
           TryCount:integer;
           PacketId:byte;

           property WaitTimer:TWaitTimer read FWaitTimer;
           property ErrorCode:integer read FErrorCode write FErrorCode;
           property Error:boolean read FError;
           property ErrorString:string read FErrorString;
           property PortName:string read FComName write SetComPort;
//           property PortList:TStringList read FComList;
//           property FreePortList:TStringList read FFreeList;
           property Parity:byte read GetParity write SetParity;
           property StopBits:byte read GetStop write SetStop;
           property ByteSize:byte read GetByteSize write SetByteSize;
           property BaudRate:DWORD read GetBaudRate write SetBaudRate;
           property Flags:LongInt read GetFlags write SetFlags;
           constructor Create(DRTS, DDTR:boolean);
           Destructor Destroy;override;
           function ConfigPort(hWnd:THandle):boolean;
           function SendBytes(const Buff; Cnt:cardinal):boolean;
           function SendString(const s:string; SendCR:boolean):boolean;
           procedure ClearPort;
           property PortHandle:THandle read FPortHandle;
           function SendBlock(B:PLevel2Pack; NoEcho:boolean=false):boolean;
           function ReadBlock(B:PLevel2Pack; BuffSize:integer):integer;
           function WaitBlock(B:PLevel2Pack; BuffSize:integer; TimeOut:integer):boolean;
           procedure SetIdleProc(P:TSimpleProc);
           property  ActiveIdle:boolean read GetActiveIdle write SetActiveIdle;
           property  RTS:boolean read FRTS write SetRTSPin;
           property  DTR:boolean read FDTR write SetDTRPin;
           function CTS:boolean;
           function DSR:boolean;
           function RING:boolean;
           function RLSD:boolean;
           property Opened:boolean read FPortOpened;
           procedure SetSpeedIndex(N:integer);
           procedure DefaultRTSDTR;
           property ConfigString:string read GetConfigString write SetConfigString;
           property PortConfig:_COMMCONFIG read FCC write SetPortConfig;
           procedure CheckConnectStatus;
           procedure AssignDefaultDataProc(State:boolean);
           procedure ClearTextBuff;
           function  ReadStringFromTextBuff(var S:string):boolean;
           function FindStringInTextBuff(S:string):boolean;
           function FindBadAnswer:integer;
           procedure AssignDataProc(DP:TDataProc);
           procedure AssignConnectionInfo(proc:TConnectProcessProc);
           procedure SetCommEvent;
           function ReadNonEmptyStringFromTextBuff(var S: string; DelString: boolean): boolean;
{$IFDEF DEBUG_MODE}
           function LastSendHex:string;
           function LastRecHex: string;
{$ENDIF}
           function LANConnection:boolean;
           property UDPMode:boolean read FUDPMode write SetUDPMode;

           end;

procedure MakeDelay(us:integer);
function StringToPortName(s:string):string;
function ParsePortName(s:string; var ip:string; var PNo:integer; var IsIP:boolean):string;

implementation

uses CRCUnit;

const
      cMeasTm=1000;
      cPriorClass=REALTIME_PRIORITY_CLASS;
      cPrior=THREAD_PRIORITY_TIME_CRITICAL;
      cDelayConst:int64=1;

{$WARNINGS OFF}
function StrToIntNoCheck(S:string):integer;
 var i:integer;
  begin
  S:=trim(S);
  Val(S,Result,i);
  end;

function HexToInt(const S:string):longword;
 var l,i:integer;
     c:integer;
     n,k:longword;
  begin
  Result:=0;
  n:=1;
  l:=length(S);
  for i:=l downto 1 do
    begin
    c:=ord(Upcase(S[i]));
    if c>=$30 then k:=c-$30
              else k:=0;
    if k>9 then if k>16 then k:=k-7
                        else k:=0;
    if k>15 then k:=0;
    Result:=Result+int64(k)*n;
    if n<$10000000 then n:=n*16;
    end;
  end;

 function HexToData(const S:string; var Data; BuffLen:integer):integer;
   var P:PByte;
       i:integer;
       s2:string;
    begin
    P:=@Data;
    s2:='';
    for i:=1 to Length(S) do if s[i] in ['0'..'9','A'..'F','a'..'f'] then s2:=s2+s[i];
    Result:=Length(s2) div 2;
    if Result>BuffLen then Result:=BuffLen;
    for i:=0 to Result-1 do
      begin
      P^:=HexToInt(copy(s2,i*2+1,2));
      cardinal(P):=cardinal(P)+1;
      end;
    end;

 function DataToHex(const Data; DataLen:integer; spacer:string=''; pref:string=''):string;
   var P:PByte;
       i, k, m,pl:integer;
       s:string;
       spcount:integer;
    begin
    P:=@Data;
    pl:=Length(pref);
    spcount:=length(spacer);
    SetLength(Result, DataLen*2+pl*DataLen+spcount*(DataLen-1));
    k:=1;
    for i:=0 to DataLen-1 do
      begin
      if (i<>0) and (spcount>0)
                then begin
                     for m:=1 to spcount do begin
                                            Result[k]:=spacer[m];
                                            inc(k);
                                            end;
                     end;
      for m:=1 to pl do
        begin
        Result[k]:=pref[m];
        inc(k);
        end;
      s:=IntToHex(P^,2);
      Result[k]:=s[1];
      inc(k);
      Result[k]:=s[2];
      inc(k);
      cardinal(P):=cardinal(P)+1;
      end;
    end;

function ValidRangeInteger(const S:string;Min, Max:integer):boolean;
 var k,l,cd:integer;
  begin
  l:=length(S);
  val(S,k,cd);
  Result:=(cd=0) and (k>=Min) and (k<=Max);
  k:=1;
  while Result and (k<=l) do begin
                             result:=S[k] in ['0'..'9'];
                             inc(k);
                             end;
  end;

function StringToPortNameSimple(s:string):string;
var i:integer;
 begin
 for i:=1 to Length(s) do
    begin
    if (s[i]=',') then s[i]:='.';
    end;
 s:=AnsiUpperCase(trim(s));
 if ValidRangeInteger(s,1,256)
   then Result:='COM'+s
   else begin
        Result:=s;
        end;
 end;

function ParsePortName(s:string; var ip:string; var PNo:integer; var IsIP:boolean):string;
var p:integer;
    pn:string;
  begin
  isIp:=false;
  PNo:=0;
  ip:='';
  s:=StringToPortNameSimple(s);
  Result:=s;
  if s='' then Exit;
  p:=pos('.', s);
  if p=0 then Exit;
  p:=pos(':', s);
  if p=0 then begin
              p:=length(s)+1;
              pn:='0';
              end
         else begin
              pn:=trim(copy(s,p+1, length(s)-1));
              end;
  ip:=trim(copy(s,1, p-1));
  PNo:=StrToIntNoCheck(pn);
  isIp:=true;
  Result:=ip+':'+IntToStr(Pno);
  end;

function StringToPortName(s:string):string;
var ip:string;
    pno:integer;
    isip:boolean;
  begin
  Result:=ParsePortName(s, ip, pno, isip);
  end;

{ TComPort }

procedure MakeDelay(us:integer);
 var i,k:int64;
     FTmOut:boolean;
  begin
  FTmOut:=false;
  i:=1;
  k:=us*cDelayConst;
  while (i<k) and not FTmOut
    do begin
           asm
           nop
           end;
       i:=i+1;
       end;
  end;

procedure HighPrior;
var c1:cardinal;
begin
  c1:=OpenProcess(PROCESS_ALL_ACCESS,false,GetCurrentProcessId);
  SetPriorityClass(c1,cPriorClass);
  closeHandle(c1);
  SetThreadPriority(GetCurrentThread,cPrior);
end;

procedure NormalPrior;
var c1:cardinal;
begin
  c1:=OpenProcess(PROCESS_ALL_ACCESS,false,GetCurrentProcessId);
  SetPriorityClass(c1,Normal_PRIORITY_CLASS);
  closeHandle(c1);
  SetThreadPriority(GetCurrentThread,THREAD_PRIORITY_NORMAL);
end;

procedure DefineDelay;
 var i:int64;
     TT:TTmThread;
     FTStart, FTmOut:boolean;
  begin
  FTmOut:=false;
  i:=1;
  HighPrior;
  TT:=TTmThread.Create(@FTStart, @FTmOut);
  repeat
  sleep(1);
  until FTStart;
  while (i<=9223372036854775000) and not FTmOut
    do begin
           asm
           nop
           end;
       i:=i+1;
       if i and $FFFFF=0 then Sleep(1);
       end;
  TT.Free;
  try
  cDelayConst:=Round(i/(cMeasTm*1000));
  except
  cDelayConst:=0;
  end;
  NormalPrior;
  FTmOut:=false;
  end;

procedure TComPort.ClearPort;
begin
if FPortHandle<>0 then PurgeComm(FPortHandle,PURGE_RXABORT+PURGE_TXABORT+PURGE_TXCLEAR+PURGE_RXCLEAR);
if FRecThread<>Nil then begin
                        FRecThread.SkipCount:=0;
                        FRecThread.FBuff.Clear;
                        end;
end;

procedure TComPort.CloseSockWSA;
  begin
if WSAOpened
          then begin
               if SockOpened
                 then begin
                      shutdown(FSocket,  SD_BOTH );
                      closesocket(FSocket);
                      FillChar(FSocket, sizeof(FSocket),0);
                      SockOpened:=false;
                      end;
               WSACleanup;
               end;
  end;

procedure TComPort.ClosePort;
begin
ClearPort;
if FPortHandle<>0 then CloseHandle(FPortHandle);
FPortHandle:=0;
CloseSockWSA;
FError:=false;
FErrorCode:=0;
FErrorString:='';               
FPortOpened:=false;
FreeRecThread;
FComName:='';
SetLastError(0);
SockOpened:=false;
WSAOpened:=false;
end;

function TComPort.ConfigPort(hWnd:THandle):boolean;
begin
Result:=CommConfigDialog(PChar(FComName),hWnd,FCC);
if Result then begin
               Result:=SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
               end;
end;

constructor TComPort.Create(DRTS, DDTR:boolean);
begin
InitializeCriticalSection(FTBSect);
FDefRTS:=DRTS;
FDefDTR:=DDTR;
FWaitTimer:=TWaitTimer.Create;
SetLastError(0);
end;

function TComPort.CTS: boolean;
var Stat:cardinal;
    ok:boolean;
begin
Result:=false;
if FPortHandle=0 then Exit;
ok:=GetCommModemStatus(FPortHandle,Stat);
Result:=ok and (Stat and MS_CTS_ON<>0);
end;

destructor TComPort.Destroy;
begin
FreeRecThread;
if FPortHandle<>0 then PurgeComm(FPortHandle,PURGE_RXABORT+PURGE_TXABORT+PURGE_TXCLEAR+PURGE_RXCLEAR);
ClosePort;
//FComList.Free;
//FFreeList.Free;
WaitTimer.Free;
DeleteCriticalSection(FTBSect);
inherited Destroy;
end;

function TComPort.DSR: boolean;
var Stat:cardinal;
    ok:boolean;
begin
Result:=false;
if FPortHandle=0 then Exit;
ok:=GetCommModemStatus(FPortHandle,Stat);
Result:=ok and (Stat and MS_DSR_ON<>0);
end;

procedure TComPort.FreeRecThread;
var n:integer;
begin
if FRecThread=Nil then Exit;
FRecThread.FEnab:=false;
FRecThread.Terminate;
n:=0;
repeat
SetCommEvent;
sleep(20);
inc(n);
until FRecThread.Stopped or (n>=100);
if not FRecThread.Stopped  then TerminateThread(FRecThread.Handle,0);
FRecThread.Free;
FRecThread:=Nil;
end;

function TComPort.GetActiveIdle: boolean;
begin
Result:=FRecThread.FActiveProc;
end;

function TComPort.GetBaudRate: DWORD;
begin
Result:=FCC.dcb.BaudRate;
end;

function TComPort.GetByteSize: byte;
begin
Result:=FCC.dcb.ByteSize;
end;

function TComPort.GetFlags: longint;
begin
Result:=FCC.dcb.Flags;
end;

function TComPort.GetParity: byte;
begin
Result:=FCC.dcb.Parity;
end;

function TComPort.GetStop: byte;
begin
Result:=FCC.dcb.StopBits;
end;

procedure TComPort.NewRecThread;
begin
FreeRecThread;
FRecThread:=TRecThread.Create;
FRecThread.FPort:=Self;
FRecThread.Resume;
FRecThread.FEnab:=true;
EnterCriticalSection(FRecthread.FBuff.FCrSect);
FRecthread.FProc:=FProc;
LeaveCriticalSection(FRecthread.FBuff.FCrSect);
end;

function TComPort.ReadBlock(B:PLevel2Pack; BuffSize: integer): integer;
var ok:boolean;
    ReadCount:integer;
begin
Result:=0;
if FRecThread=Nil then begin
                       Exit;
                       end;
ok:=FRecThread.FBuff.ReadBuff(B^, BuffSize, ReadCount);
if not ok then Exit;
Result:=ReadCount;
end;

function TComPort.RING: boolean;
var Stat:cardinal;
    ok:boolean;
begin
Result:=false;
if FPortHandle=0 then Exit;
ok:=GetCommModemStatus(FPortHandle,Stat);
Result:=ok and (Stat and MS_RING_ON<>0);
end;

function TComPort.RLSD: boolean;
var Stat:cardinal;
    ok:boolean;
begin
Result:=false;
if FPortHandle=0 then Exit;
ok:=GetCommModemStatus(FPortHandle,Stat);
Result:=ok and (Stat and MS_RLSD_ON<>0);
end;

function TComPort.SendBlock(B:PLevel2Pack; NoEcho:boolean=false): boolean;
var wcnt, cnt, Len:cardinal;
    a:array [0..4095] of byte;
begin
if SockOpened
   then begin
//        Result:=true;
        end
   else begin
        Result:=(FPortHandle<>0);
        if not Result then Exit;
        if (NoEcho) then Sleep(20);
        end;
cnt:=MakeFullPacket(B, @a);
if FRecThread<>Nil then
     if NoEcho and not SockOpened
               then FRecThread.SkipCount:=cnt
               else FRecThread.SkipCount:=0;
if SockOpened
   then begin
        if UDPMode then begin
                        Len:=sizeof(UDPAddr);
                        Result:=sendto(FSocket, a, cnt, 0, UDPAddr, Len)<>SOCKET_ERROR;
                        end
                   else Result:=send(FSocket, a, cnt, 0)=integer(cnt);
        end
   else begin
        Result:=WriteFile(FPortHandle,a,Cnt,wcnt,Nil);
        Result:=Result and (Cnt=wCnt);
        end;
PrevCommand:=B.Cmd;
PrevPackId:=B.PId;
{$IFDEF DEBUG_MODE}
Move(a, LastSend, cnt);
LastSendSize:=cnt;
LastRecSize:=0;
{$ENDIF}
end;

function TComPort.SendBytes(const Buff; Cnt: cardinal): boolean;
var wCnt:cardinal;
    a:array [0..4095] of byte;
begin
if SockOpened
   then begin
        if cnt>4096 then cnt:=4096;
        Move(Buff, a, cnt);
        Result:=send(FSocket, a, cnt, 0)=integer(cnt);
        end
   else begin
        Result:=(FPortHandle<>0);
        if not Result then Exit;
        Result:=WriteFile(FPortHandle,Buff,Cnt,wcnt,Nil);
        Result:=Result and (Cnt=wCnt);
        end;
end;

procedure TComPort.SetActiveIdle(A: boolean);
begin
if FRecthread=Nil then Exit;
EnterCriticalSection(FRecthread.FBuff.FCrSect);
FRecthread.FActiveProc:=A;
LeaveCriticalSection(FRecthread.FBuff.FCrSect);
end;

procedure TComPort.SetBaudRate(N: DWORD);
begin
Fcc.dcb.BaudRate:=N;
SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

procedure TComPort.SetByteSize(N: byte);
begin
Fcc.dcb.ByteSize:=N;
SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

function TComPort.ReadNonEmptyStringFromTextBuff(var S: string;
  DelString: boolean): boolean;
begin
repeat
Result:=ReadStringFromTextBuff(s);
until not Result or (s<>'');
end;

const
cDTR_CONTROL_DISABLE=$0000;
cDTR_CONTROL_ENABLE=$0010;
cRTS_CONTROL_DISABLE=$0000;
cRTS_CONTROL_ENABLE=$1000;
cRTS_CONTROL_HANDSHAKE=$2000;
cOutxCtsFlow=$0004;

procedure TComPort.SetComPortComMode(const ComName: string);
 var c:cardinal;
     ok:boolean;
begin
SetLastError(0);
if ComName=''
  then begin
       FPortHandle:=0;
       FErrorString:='Port closed';
       FError:=true;
       Exit;
       end;
c:=SizeOf(FCC);
ok:=GetDefaultCommConfig(PChar(ComName),FCC,c);
if ok then FPortHandle:=CreateFile(PChar('\\.\'+ComName),GENERIC_READ+GENERIC_WRITE,0,Nil,
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL
                ,0);
if not ok or (FPortHandle=INVALID_HANDLE_VALUE) or (FPortHandle=0)
  then begin
       FPortHandle:=0;
       FErrorString:=SysErrorMessage(GetLastError);
       FError:=true;
       end
  else begin
       FErrorString:='';
       FError:=false;
       FCC.dcb.BaudRate:=cDefBaudRate;
       FCC.dcb.Flags:=1;
       if FDefDTR then FCC.dcb.Flags:=FCC.dcb.Flags or cDTR_CONTROL_ENABLE;
       if FDefRTS then FCC.dcb.Flags:=FCC.dcb.Flags or cRTS_CONTROL_ENABLE;
       FDTR:=FDefDTR;
       FRTS:=FDefRTS;
       FCC.dcb.StopBits:=0;//2;
       FCC.dcb.ByteSize:=8;
       FCC.dcb.Parity:=0;
       Windows.SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
       SetCommMask(FPortHandle,EV_RXCHAR+EV_TXEMPTY+EV_DSR);
       SetupComm(FPortHandle, 32768,32768);
       SetTimeOuts;
//       DTR:=true;
//       RTS:=false;
       NewRecThread;
       FComName:=ComName;
       FPortOpened:=true;
       end;
end;

procedure TComPort.SetDTRPin(State: boolean);
begin
if FPortHandle=0 then Exit;
FDTR:=State;
if State then EscapeCommFunction(FPortHandle,SETDTR)
         else EscapeCommFunction(FPortHandle,CLRDTR);
end;

procedure TComPort.SetRTSPin(State: boolean);
begin
if FPortHandle=0 then Exit;
FRTS:=State;
if State then EscapeCommFunction(FPortHandle,SETRTS)
         else EscapeCommFunction(FPortHandle,CLRRTS);
end;

procedure TComPort.SetFlags(F: Integer);
begin
Fcc.dcb.Flags:=F;
SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

procedure TComPort.SetIdleProc(P: TSimpleProc);
begin
FProc:=P;
end;

procedure TComPort.SetParity(N: byte);
begin
Fcc.dcb.Parity:=N;
SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

procedure TComPort.SetStop(N: byte);
begin
Fcc.dcb.StopBits:=N;
SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

function TComPort.WaitBlock(B:PLevel2Pack; BuffSize:integer; TimeOut:integer): boolean;
var n:integer;
begin
WaitTimer.SetTimeOut(TimeOut);
repeat
n:=ReadBlock(B, BuffSize);
Result:=n>0;
if not Result then Sleep(1);
until Result or WaitTimer.TimeOut;
end;

function TComPort.SetCommConfig(hCommDev: THandle; const lpCC: TCommConfig;
  dwSize: DWORD): BOOL;
begin
Result:=true;
if hCommDev=0 then Exit;
Result:=Windows.SetCommConfig(hCommDev,lpCC, dwSize);
//DTR:=FDTR;
//RTS:=FRTS;
end;

procedure TComPort.SetSpeedIndex(N: integer);
begin
if (n<0) or (N>=cSpeedsCount) then N:=cSpeedsCount-1;
BaudRate:=cSpeedTable[N];
end;

procedure TComPort.DefaultRTSDTR;
begin
RTS:=FDefRTS;
DTR:=FDefDTR;
end;

function TComPort.GetConfigString: string;
begin
Result:=DataToHex(FCC, sizeOf(FCC));
end;

procedure TComPort.SetConfigString(const s: string);
var a:array[0..8192] of byte;
    n:integer;
begin
FillChar(a, sizeof(a), 0);
n:=HexToData(s,a,sizeof(a));
if n>sizeof(FCC) then n:=sizeof(FCC);
if n>0 then begin
            move(a,FCC,n);
            SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
            end;
end;

const CRLF:packed array [0..1] of byte=(13,10);

function TComPort.SendString(const s: string; SendCR:boolean): boolean;
begin
Result:=SendBytes(pointer(S)^,length(s));
if Result and SendCR then Result:=SendBytes(CRLF,2);
end;

procedure TComPort.SetPortConfig(const Value: _COMMCONFIG);
begin
  FCC := Value;
  SetCommConfig(FPortHandle,FCC,SizeOf(FCC));
end;

procedure TComPort.DefaultDataProc(Data: pointer; DataCount: integer);
var i,k:integer;
    P:PByte;
begin
EnterCriticalSection(FTBSect);
if DataCount+TextBuffSize<sizeof(TextBuff)
  then begin
       P:=Data;
       k:=(TextBuffPtr+TextBuffSize) and cTextBuffMask;
       for i:=1 to DataCount do
         begin
         TextBuff[k]:=P^;
         inc(P);
         k:=(k+1) and cTextBuffMask;
         end;
       TextBuffSize:=TextBuffSize+DataCount;
       end;
LeaveCriticalSection(FTBSect);
end;

function TComPort.ReadStringFromTextBuff(var S: string): boolean;
var i, k, n:integer;
    a: array[0..cTextBuffMask] of byte;
    b:byte;
begin
Result:=false;
s:='';
EnterCriticalSection(FTBSect);
if TextBuffSize>0
  then begin
       k:=TextBuffPtr;
       n:=0;
       b:=0;
       for i:=1 to TextBuffSize do
         begin
         b:=TextBuff[k];
         if (b<>13)
               then begin
                    a[n]:=b;
                    inc(n);
                    end
               else break;
         k:=(k+1) and cTextBuffMask;
         end;
       if b=13 then
        begin
        if (n>0) and (b=13)
              then begin
                   SetLength(s,n);
                   move(a,pointer(s)^,n);
                   Result:=true;
                   end;
        while (b in [13,10]) and (n<TextBuffSize) do
                     begin
                     k:=(k+1) and cTextBuffMask;
                     b:=TextBuff[k];
                     inc(n);
                     end;
        TextBuffSize:=TextBuffSize-n;
        TextBuffPtr:=(TextBuffPtr+n) and cTextBuffMask;
        end;//if b=13
       end;
LeaveCriticalSection(FTBSect);
end;

procedure TComPort.AssignDefaultDataProc(State: boolean);
begin
if State then AssignDataProc(DefaultDataProc)
         else AssignDataProc(Nil);
end;

procedure TComPort.CheckConnectStatus;
var um, stat:integer;
begin
ExecFlag:=true;
if EnableConnectInfo and Assigned(ConnectInfoProc)
   then begin
        um:=0;
        if DSR then stat:=1
               else stat:=0;
        ConnectInfoProc('','',stat,0,um);
        if um and $01<>0 then DTR:=false; 
        end;
ExecFlag:=false;
end;

procedure TComPort.ClearTextBuff;
begin
EnterCriticalSection(FTBSect);
TextBuffPtr:=0;
TextBuffSize:=0;
FillChar(TextBuff, sizeof(TextBuff),0);
LeaveCriticalSection(FTBSect);
end;

function TComPort.FindStringInTextBuff(S: string): boolean;
var rs:string;
begin
Result:=false;
s:=AnsiUpperCase(trim(s));
while not Result do
 begin
 if not ReadStringFromTextBuff(rs) then break;
 Result:=AnsiUpperCase(trim(rs))=s;
 end;
end;

function TComPort.FindBadAnswer: integer;
var rs:string;
    i:integer;
begin
Result:=-1;
while ReadStringFromTextBuff(rs) do
  begin
  rs:=AnsiUpperCase(trim(rs));
  for i:=0 to cModemBadAnswCount-1 do
    begin
    if rs=ModemBadAnswer[i] then begin
                                 Result:=i;
                                 Exit;
                                 end;
    end;
  end;
end;

procedure TComPort.AssignConnectionInfo(proc: TConnectProcessProc);
begin
EnableConnectInfo:=false;
while ExecFlag do begin
                  SetCommEvent;
                  sleep(20);
                  end;
ConnectInfoProc:=proc;
EnableConnectInfo:=true;
end;

procedure TComPort.AssignDataProc(DP: TDataProc);
begin
if (FRecThread<>Nil) then
  begin
  FRecThread.FEnab:=false;
  while FRecThread.FExec do begin
                            SetCommEvent;
                            Sleep(20);
                            end;
  end;
DataProc:=DP;
if (FRecThread<>Nil) then FRecThread.FEnab:=true;
end;

procedure TComPort.SetCommEvent;
begin
if FPortHandle<>0 then SetCommMask(FPortHandle,EV_RXCHAR+EV_TXEMPTY);
end;

procedure TComPort.SetTimeOuts;
begin
GetCommTimeOuts(FPortHandle, CTO);
CTO.ReadIntervalTimeout:=50;
CTO.ReadTotalTimeoutMultiplier:=20;
CTO.ReadTotalTimeoutConstant:=0;
CTO.WriteTotalTimeoutMultiplier:=50;
CTO.WriteTotalTimeoutConstant:=10;
SetCommTimeOuts(FPortHandle, CTO);
end;

procedure TComPort.SetUDPMode(const Value: boolean);
begin
if FUDPMode = Value then Exit;
FUDPMode := Value;
if FPortHandle=0 then ClosePort; //only for Ethernet
end;

procedure TComPort.SetComPort(const ComName: string);
var pno:integer;
    s, ip:string;
    isip:boolean;
begin
ClosePort;
s:=ParsePortName(ComName, ip, pno, isip);
if s='' then Exit;
if IsIp
  then begin
       if UDPMode then SetIPPortUDP(ip, pno)
                  else SetIPPortTCP(ip, pno);
       end
  else SetComPortComMode(s);
end;

procedure TComPort.SetIPPortTCP(IPAddr: AnsiString; PNo: integer);
var   D:WSAData;
      A:TSockAddr;
      b:integer;
begin
  FillChar(A, sizeof(A),0);
  FillChar(D, sizeof(D),0);
   //нужна версия 1.1
  if WSAStartup($101,D)<>0 then
             begin
             FError:=true;
             FErrorCode:=-1;
             FErrorString:='Bad version Windows Sockets';
             Exit;
             end;
  WSAOpened:=true;           
  { Определяем тип семейства сокетов, и IP адрес для сканирования }
  A.sin_family:=AF_INET;
  A.sin_addr.S_addr:=inet_addr(PAnsiChar(IPAddr));
  { Создаем сокет }
  FSocket:=socket(AF_INET,SOCK_STREAM,0);
  { Если возвращено значение INVALID_SOCKET, выводим сообщение об ошибке }
  if FSocket=INVALID_SOCKET then begin
                           FError:=true;
                           FErrorCode:=-1;
                           FErrorString:='Socket error';
                           Exit;
                           end;
  { Определяем порт }
  A.sin_port:=htons(PNo);
  { Пытаемся подконнектиться, если удачно - выводим сообщение, что порт открыт,
  в другом случае - сообщение о том, что порт закрыт (или недоступен) }
  if connect(FSocket,A,sizeof(A))<>0
   then begin
        FError:=true;
        FErrorCode:=-1;
        FErrorString:='Не могу подсоединиться к сокету!';
        Exit;
        end;
  b:=0; //0 - блокирующее чтение, 1 - не блокирующее
  ioctlsocket(FSocket, FIONBIO, b);
  b:=1;
  ioctlsocket(FSocket,FIONREAD, b);
  SockOpened:=true;
  FComName:=IPAddr+':'+IntToStr(PNo);
  FPortOpened:=true;
  NewRecThread;
end;

function TComPort.StartUDPListening(bc:boolean):boolean;
 var BroadCast:integer;
//     pno, sz, len:integer;
//UDPserveraddr: SOCKADDR_IN;
begin
 Result:=false;

 if bc then BroadCast:=1
       else BroadCast:=0;
 FSocket := socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

 if(FSocket = -1)
     then begin
          WSACleanup;
          FError:=true;
          FErrorCode:=-2;
          FErrorString:='Error in creating socket';
          Exit;
          end;
 SockOpened:=true;

  if setsockopt (FSocket, SOL_SOCKET, SO_BROADCAST, PAnsiChar(@BroadCast), sizeof(boolean))=-1
    then begin
         CloseSockWSA;
         FErrorCode:=-3;
         FErrorString:='Error set socket option';
         Exit;
         end;


(*
   FillChar(UDPserveraddr, sizeof(UDPserveraddr), 0);
    UDPserveraddr.sin_family := AF_INET;
    UDPserveraddr.sin_port := htons(c_portno); //htons(0); - система сама выберет порт
    UDPserveraddr.sin_addr.s_addr := INADDR_ANY;

    if (bind(m_clientsocket, UDPserveraddr, sizeof(SOCKADDR_IN)) < 0)
         then begin
              closesock;
              FErrStr:='Error binding in the server socket';
              Exit;
              end;
*)
(*
  //узнаем номер порта
   FillChar(UDPserveraddr, sizeof(UDPserveraddr), $FF);
   len := sizeof(UDPserveraddr);
   sz:=getsockname(m_clientsocket, UDPserveraddr, len);
   pno:= ntohs(UDPserveraddr.sin_port);
*)

 Result:=true;
end;

function TComPort.OpenUDPList(bc:boolean): boolean;
var   D:WSAData;
begin
Result:=SockOpened;
if Result then Exit;

 FillChar(D, sizeof(D),0);
  if WSAStartup($101,D)<>0
    then begin
         FError:=true;
         FErrorCode:=-1;
         FErrorString:='Error start WSA!';
         Exit;
         end;
WSAOpened:=true;
if not StartUDPListening(bc) then Exit;
FPortOpened:=SockOpened;
Result:=SockOpened;
if Result then NewRecThread;
end;

procedure TComPort.SetIPPortUDP(IPAddr: AnsiString; PNo: integer);
begin
 UDPAddr.sin_family := AF_INET;
 if (IPAddr='') then  UDPAddr.sin_addr.s_addr := integer(INADDR_BROADCAST)
                else begin
                     UDPAddr.sin_addr.s_addr :=inet_addr(PAnsiChar(IPAddr));
                     if UDPAddr.sin_addr.s_addr=0 then UDPAddr.sin_addr.s_addr:=integer(INADDR_BROADCAST);
                     end;
 UDPAddr.sin_port := htons(PNo);
 if OpenUDPList(dword(UDPAddr.sin_addr.s_addr)=INADDR_BROADCAST)
   then FComName:=IPAddr+':'+IntToStr(PNo);
end;

{$WARNINGS ON}

function TComPort.ReadUDPAnswer(var clientaddr:SOCKADDR_IN; Buff:pointer; BuffSz:integer; var rsz:integer; TmOut_ms:integer):boolean;
var fds: TFDSet;
    timeout:TTimeVal;
    rc, len :integer;
begin

Result:=false;
rsz:=0;

    timeout.tv_sec := 0;
    timeout.tv_usec := TmOut_ms*1000;

    FD_ZERO(fds);

    FD_SET(FSocket, fds);


    rc := select(sizeof(fds)*8, @fds, Nil, Nil, @timeout);
//    rc := select(1, @fds, Nil, Nil, @timeout);

    if(rc > 0)
      then begin
        len := sizeof(clientaddr);

        rsz:=recvfrom(FSocket, Buff^, BuffSz, 0, clientaddr, len);
        Result:=true;
        end;
end;

function TComPort.ReadDeviceData(var Buff; sz: integer): integer;
 var c, n:cardinal;
     cnt:integer;
     Stat:TComStat;
     ok:boolean;
     client:TSockAddrIn;
begin
Result:=0;
if SockOpened then begin
                   if UDPMode then begin
                                   ReadUDPAnswer(client, @Buff, sz, cnt, UDPTimeOut);
                                   if (cnt>0) then Result:=cnt;
                                   end
                              else begin
                                   cnt:=recv(FSocket, Buff, sz, 0);
                                   if (cnt>0) then Result:=cnt;
                                   end;
                   Exit;
                   end;
//читаем COM-порт                   
if FPortHandle=0 then Exit;
ok:=ClearCommError(FPortHandle,c,@Stat);
if ok then begin
           c:=Stat.cbInQue;
           if c>0 then begin
                       ok:=ReadFile(FPortHandle, buff, c, n, Nil);
                       if ok then Result:=n;
                       end;
           end;
end;

{$IFDEF DEBUG_MODE}

function TComPort.LastSendHex: string;
begin
Result:=DataTohex(LastSend, LastSendSize, '  ');
end;

function TComPort.LastRecHex: string;
begin
Result:=DataTohex(LastRec, LastRecSize, '  ');
end;

{$ENDIF}

function TComPort.LANConnection: boolean;
begin
Result:=SockOpened;
end;

{ TRecThread }

function TRecThread.CheckInput:boolean;
var
    b:array [0..4095] of byte;
    n:integer;
    ok:boolean;
    i:integer;
begin
//Result:=false;
try
n:=FPort.ReadDeviceData(b, sizeof(b));
ok:=n>0;
Result:=ok;
            if ok then begin
                       if Assigned(FPort.DataProc)
                          then begin
                               FPort.DataProc(@b,n);
                               end
                       else begin
                            for i:=0 to n-1 do
                               begin
                                if SkipCount=0 then FBuff.PutData(b[i])
                                               else dec(SkipCount);
                               end; //for
                     end;//else if Assigned(DataProc)
            end; // if ok
            
except
Result:=false;
end;
end;

constructor TRecThread.Create;
begin
//FTimer:=TWaitTimer.Create;
FBuff:=TBuffer.Create;
FBuff.FRC:=Self;
inherited Create(true);
FreeOnTerminate:=false;
//Priority:=tpHigher;
Priority:=tpHighest;
//Priority:=tpNormal;
end;

destructor TRecThread.Destroy;
begin
Terminate;
FBuff.Free;
//FTimer.Free;
inherited Destroy;
end;

procedure TRecThread.Execute;
var ok:boolean;
    c:cardinal;
    Stat:TComStat;
begin
FPort.FEventVar:=0;
repeat
if FEnab then FExec:=true;

if FEnab
  then begin
       if FPort.SockOpened
              then begin
                   if not CheckInput then begin
                                          Sleep(1);
                                          end;
                   end
else begin
//-----------
if (FPort.FPortHandle<>0)
  then begin
       if isWinNT then
         begin
            ok:=ClearCommError(FPort.FPortHandle,c,@Stat);
            ok:=ok and (Stat.cbInQue>0);
            if ok //and (FPort.FEventVar and EV_RXCHAR<>0)
             then begin
                  CheckInput;
                  Sleep(1);
                  end
             else begin
                  Sleep(1);
                  end;
         end
       else begin
            ok:=WaitCommEvent(FPort.FPortHandle,FPort.FEventVar,Nil);
            ok:=ok and ClearCommError(FPort.FPortHandle,c,@Stat);
            ok:=ok and (Stat.cbInQue>0);
            if ok //and (FPort.FEventVar and EV_RXCHAR<>0)
             then begin
                  CheckInput;
                  end;
            end;
        end
    else begin
         Sleep(200);
         end;
//-----------
      end //else if FPort.SockOpened
       end //if fenab
  else begin
       Sleep(200);
       end;
FExec:=false;
FPort.CheckConnectStatus;
until Terminated;
Stopped:=true;
end;

{
procedure TRecThread.Execute;
var ok:boolean;
    c:cardinal;
    Stat:TComStat;
begin
ok:=false;
FPort.FEventVar:=0;
repeat
if FEnab and (FPort.FPortHandle<>0)
  then begin
//       ok:=WaitCommEvent(FPort.FPortHandle,FPort.FEventVar,Nil);
       ok:=ClearCommError(FPort.FPortHandle,c,@Stat);
       ok:=ok and (Stat.cbInQue>0);
       if ok //and (FPort.FEventVar and EV_RXCHAR<>0)
             then begin
                  CheckInput;
                  Sleep(1);
                  end
             else Sleep(30);
       end
  else begin
       Sleep(200);
       end;
until Terminated;
end;
}
{ TBuffer }

procedure TBuffer.Clear;
begin
EnterCriticalSection(FCrSect);
RecStage:=0;
RecPtr:=0;
FBlockSize:=0;
InLen:=0;
FBlockready:=false;
LeaveCriticalSection(FCrSect);
end;

constructor TBuffer.Create;
begin
InitializeCriticalSection(FCrSect);
end;

destructor TBuffer.Destroy;
begin
DeleteCriticalSection(FCrSect);
inherited Destroy;
end;

procedure TBuffer.PutData(dt: byte);
var P:PByte;
    cs:word;
begin
EnterCriticalSection(FCrSect);
if (dt=$02) then begin
                  RecStage:=1;
                  RecPtr:=0;
                  LeaveCriticalSection(FCrSect);
{$IFDEF DEBUG_MODE}
                  with FRC.FPort do
                    begin
                    LastRecSize:=1;
                    LastRec[0]:=dt;
                    end;
{$ENDIF}
                  Exit;
                  end;
{$IFDEF DEBUG_MODE}
if (RecStage<>0) then begin
                      with FRC.FPort do
                         begin
                         if (LastRecSize<sizeof(LastRec))
                            then begin
                                 LastRec[LastRecSize]:=dt;
                                 inc(LastRecSize);
                                 end;
                         end;
                      end;
{$ENDIF}
case RecStage of
1: begin
     if (dt and $80<>0)
       then begin
            RecData[0]:=dt and $7F;
            RecStage:=2;
            end
       else RecStage:=0;
   end;
2: begin
     if (dt and $80<>0)
       then begin
            InLen:=(word(dt and $7F)*128) or RecData[0];
            RecPtr:=0;
            if ((InLen>(RecBuffSizeByte-2)) or (InLen<sizeof(TLevel2Head)))
                        then RecStage:=0
                        else RecStage:=3;
            end
       else RecStage:=0;
   end;
3: begin
     if (dt=$03)
        then begin
             if (((InLen+2)=RecPtr) and (InLen=(PLevel2Head(@RecData)^.DataLen+sizeof(TLevel2Head))))
               then begin
                    P:=@RecData;
                    inc(P, InLen);
                    cs:=0;
                    CountCSNewW(@RecData, InLen, cs);
                    cs:=EncodeWord(cs);
                    if (Pword(P)^=cs) then begin
                                           if (not FBlockReady)
                                             and ((PLevel2Head(@RecData)^.Status and $F0)=0)
//                                             and ((PLevel2Head(@RecData)^.PId<>PrevId) or (PLevel2Head(@RecData)^.Cmd<>PrevCmd))
                                             and ((PLevel2Head(@RecData)^.PId=FRC.FPort.PrevPackId) and (PLevel2Head(@RecData)^.Cmd=FRC.FPort.PrevCommand))
                                             then begin
                                                  FBlockSize:=InLen;
                                                  Move(RecData, FRecPacket, FBlockSize);
                                                  FBlockReady:=true;
//                                                  PrevCmd:=PLevel2Head(@RecData)^.Cmd;
//                                                  PrevId:=PLevel2Head(@RecData)^.PId;
                                                  end;
                                           end;
                    end;
             RecStage:=0;
             end 
        else begin
             if (dt<$20) then RecStage:=0
                         else begin
                               if (RecPtr>=RecBuffSizeByte)
                                 then RecStage:=0
                                 else begin
                                      if (dt=$7F) then RecStage:=4
                                             else begin
                                                  if (RecPtr<InLen) then dt:=dt xor $80;
                                                  RecData[RecPtr]:=dt;
                                                  inc(RecPtr);
                                                  end;

                                       end;
                             end;
            end;
     end;//case 3
4: begin
   if (dt and $80)<>0
        then begin
             RecData[RecPtr]:=dt;
             inc(RecPtr);
             RecStage:=3;
             end
        else RecStage:=0;
   end;
else RecStage:=0;
end;//case
LeaveCriticalSection(FCrSect);
end;

function TBuffer.ReadBuff(var Buff; BuffSize: integer;  var ReadCount: integer): boolean;
begin
EnterCriticalSection(FCrSect);
Result:=FBlockReady;
if Result then begin
               FBlockReady:=false;
               ReadCount:=FBlockSize;
               FBlockSize:=0;
               if ReadCount>BuffSize then ReadCount:=BuffSize;
               Move(FRecPacket, Buff, ReadCount);
               end;
LeaveCriticalSection(FCrSect);
end;

function TBuffer.ReadBuffNoCritical(var Buff; BuffSize: integer;
  var ReadCount: integer): boolean;
begin
Result:=FBlockReady;
if Result then begin
               FBlockReady:=false;
               ReadCount:=FBlockSize;
               FBlockSize:=0;
               if ReadCount>BuffSize then ReadCount:=BuffSize;
               Move(FRecPacket, Buff, ReadCount);
               end;
end;

{ TWaitTimer }

procedure TWaitTimer.SetTimeOut(Time: integer);
begin
FTmOut:=Time;
FStartTime:=GetTickCount;
end;

function TWaitTimer.TimeOut: boolean;
var tc:int64;
begin
tc:=GetTickCount;
if tc<FStartTime then tc:=tc+100000000;
Result:=tc-FStartTime>=FTmOut;
end;

constructor TTmThread.Create(TS, TP:PBoolean);
  begin
  PB:=TP;
  PS:=TS;
  inherited Create(false);
  FreeOnTerminate:=false;
  SetThreadPriority(Handle,cPrior);
  end;

procedure TTmThread.Execute;
  begin
  PS^:=true;
  Sleep(cMeasTm);
  PB^:=true;
  end;

procedure GetWinVersion;
 var OS:TOSVERSIONINFO;
     ok:boolean;
  begin
  FillChar(OS, SizeOf(OS),0);
  OS.dwOSVersionInfoSize:=SizeOf(OS);
  ok:=GetVersionEx(OS);
  if ok then isWinNT:=OS.dwPlatformId=VER_PLATFORM_WIN32_NT;
  end;

procedure InitStrings;
 begin
 ModemBadAnswerRus[0]:='Ошибка';
 ModemBadAnswerRus[1]:='Нет несущей';
 ModemBadAnswerRus[2]:='Нет гудка';
 ModemBadAnswerRus[3]:='Занято';
 ModemBadAnswerRus[4]:='Нет ответа';
 end;

initialization
InitStrings;
GetWinVersion;
//DefineDelay;

end.
