unit DevTransp;

interface
uses Windows, CommlibNew, ConnTypes;

//var ErrorsOfConn:dword;

const WorkPort:TComPort=Nil;
//      WorkPortName:string='';

      sizeof_TDigiCounters = (256+128);

      MAX_DOMAIN_LEN=32;
      EXCH_EE_PG_SIZE=64;
      EEPROM_FULL_SIZE=65536;
      ANY_DEV_ADDR = $FFFF;

      MAX_TEMP_SENSOR_COUNT = 4;
      SNS_CTRL_COUNT = 4;
      USED_SENSOR_COUNT = 11;
      EXT_SNS_CORR_CNT = 11;

      DISPLAY_TYPE_SEGMENT = $80;
      DISPLAY_TYPE_TEXT = $40;

      DAY_COUNTER_COUNT = 16;
      DC_ACT_ON = $01;
      DC_ACT_BACK = $02;
      DC_ACT_GO = $04;

      DC_EXT_COLOR = $80;

      SEG_SET_OPT_EDITABLE  = $01;
      SEG_SET_OPT_EDITCELL  = $02;

      CELL_NUM_ABSOLUTE     = $01;
      CELL_NUM_CHECK_RANGE  = $40;
      CELL_FLAG_SAVE        = $80;


(*
      ADD_SIGN=100;
      ConfigSign=$13E2539B+ADD_SIGN;
      TextSign = $06A9F272+ADD_SIGN;
      SegmentSign = $A620E914+ADD_SIGN;
      SegDescrSign =$349A7641+ADD_SIGN;
*)

      MAX_PARAM_COUNT=16;
      MAX_SEG_DISP_COUNT=64;
      MAX_TEXT_DESCR_COUNT=32;
      MAX_DESCR_LEN=4;
      MAX_SYMB_DISP_COUNT=32;
      MAX_SYMB_TEXT_SIZE=512;

      CTRL_TEMP_SAVE = $01;
      CTRL_TEMP_RESET = $02;
      CTRL_TEMP_COPY_ALL = $04;

      DZ_FLAG_SAVE = $01;
      DZ_FLAG_APPLY = $02;
      DZ_FLAG_CLR_TEXT = $04;
      DZ_FLAG_CLR_SCREEN = $08;
      DZ_FLAG_CLR_ALL_TEXT = $10;
      DZ_FLAG_SAVE_TEXT = $20;
      DZ_FLAG_OUT_ALL_TEXT = $80;

      EXT_FUN_SET_USE_SYM = $01;
      EXT_FUN_CLR_USE_SYM = $02;
      EXT_FUN_CLR_ALL_SYM_TEXT = $04;
      EXT_FUN_WRITE_SYM_DAT = $40;
      EXT_FUN_WRITE_SYM_CFG = $80;
      EXT_FUN_APPLY_DISP_CFG = $100;
      EXT_FUN_APPLY_SYM_CFG = $200;
      EXT_FUN_OUT_ALL_TEXT = $400;
      EXT_FUN_OUT_ALL_SYM = $800;
      EXT_FUN_WRITE_TEXTS = $1000;

      S_BAD_VALUE = -32768;


      USER_KEY_COUNT = 48;
      USER_KEY_OPT_ACTIVE = $01;
      USER_KEY_OPT_LONG   = $02;


      SHED_FMT_ACTIVE    =  $01;
      SHED_FMT_SECONDS   =  $02;
      SHED_FMT_SHOW      =  $04;
      SHED_FMT_SHOW_BACK =  $08;

      MAX_SHED_ITEM_CNT  = 32;
      MAX_SHED_DATA_CNT  = 10;

      DISP_TIMER_COUNT  =  8;
      DISP_UNION_COUNT  =  4;


      MAX_DIGICOUNT_CNT =  12;

      DCNT_OPT_ACTIVE   =  $01;
      DCNT_OPT_INC_OVL  =  $02;
      DCNT_OPT_DEC_OVL  =  $04;
      DCNT_OPT_PERCNT   =  $08;
      DCNT_OPT_UPD_SAVE =  $10;
      DCNT_OPT_KEY_MSK  =  $20;

      HWDisplayCount=2;
      cMaxPictureSize=1024;

      SendPacketStatus:byte=$80;

      SrcAddr=0;
//      TryCount:integer=3;

      DestAddr:word=ANY_DEV_ADDR;

      DefLanTCPTimeOut=3000;
      LanTCPTimeOut:integer=DefLanTCPTimeOut;

      LanUDPTimeOut=1000;
      RS485TimeOut=200;

//      WaitTimeOut:integer=RS485TimeOut;


      ecOK=$00;
      ecBadCommand=$01;
      ecParamError=$02;
      ecExecuteError=$03;
      ecBadAnswer=$04;
      ecConnectError=$05;
      ecInvalidDataSize=$06;

type

  TLoadProgressProc=procedure(N:integer) of object;

  TMACAddress=packed array[0..5] of byte;

TMainTime=packed record
          Sec, Min, Hour,
          Date, Month, Year:byte;
          end;

PMainTime=^TMainTime;

TIntTime=packed record
          Sec, Min, Hour, Day,
          Date, Month, Year:byte;
          end;

PIntTime=^TIntTime;

TTabConfigA=packed record
  Signature:dword;
  IP, SubMask, Gate:dword;
  PortTCP:word;
  DevID:word;
  MAC:TMACAddress;
  uid:word;
  Options:byte;
  PortUDP:word;
  end;

TTabConfig=packed record
  Conf:TTabConfigA ;
  reserv:array [1..32-sizeof(TTabConfigA)] of byte;
  end;

PTabConfig=^TTabConfig;

TSimpleTextOutParams=packed record
  DispNo:byte;
  Font,
  Align,
  Opt,
  Speed,
  Color:byte;
  EffNo:byte;
  EffCount:byte;
  EffTime:byte;
  end;

PSimpleTextOutParams=^TSimpleTextOutParams;

TExtParams=packed record
 DisplayCount,
 ChannelCount:byte;
 SizeX,
 SizeY:word;
 SizeYBytes:byte;
 MaxEffCount:byte;
 DefTextLength:word;
 TranspBuffSize:word;
 ParamDispCount:byte;
 DefTextDisplay:byte;
 DispStart:array [0..HWDisplayCount-1] of word;
 DispSize:array [0..HWDisplayCount-1] of word;
 DispTypes:array [0..HWDisplayCount-1] of byte;
 DispFlags:array [0..HWDisplayCount-1] of byte;
 HWDispCount:byte;
 LibPicMaxCount:byte;
 LibPicCount:byte;
 LibPicMaxSize:word;
 MaxFullSymbLen:word;
 MaxSymbDispCount:byte;
 SysTextColor:byte;
 SysTextFont:byte;
 SysUseSegment:byte;
 EepromSize:dword;
 EepromPageSize: word;
 UARTBuffSize:word;
 FullSizeInBlocks:byte;
 Bright:byte;
 ExtKeyModCount:byte;
// reserv:array[1..1] of byte;
 end;

PExtParams=^TExtParams;

TTextZoneDescr=packed record
  Active:byte;
  HeightB:byte;
  OffsetY:byte;
  CanBeRun:byte;
  OrgX, OrgY:word;
  XSize, YSize:word;
  SizeInBlocks:byte;
  reserv:array[1..7] of byte;
  end;

PTextZoneDescr=^TTextZoneDescr;

TMainDispConfig=packed record
   SizeX, SizeY:word;
   ChannelCount:byte;
   DefTextDisplay:byte;
   DispStart:array [0..HWDisplayCount-1] of word;
   DispSize:array [0..HWDisplayCount-1] of word;
   DispTypes:array [0..HWDisplayCount-1] of byte;
   DispFlags:array [0..HWDisplayCount-1] of byte;
   SysTextColor:byte;
   SysTextFont:byte;
   SysUseSegment:byte;
   ExtKeyModCount:byte;
   res:array[1..2] of byte;
   reserv:array [1..2] of dword;
   end;

PMainDispConfig=^TMainDispConfig;

TParamsSets=packed record
 Active:byte;
 pDispNo:byte;
 Align:byte;
 reserv2:byte;
 ParamTimes:array[0..MAX_PARAM_COUNT-1] of word;
 ParamFonts:array[0..MAX_PARAM_COUNT-1] of byte;
 ParamColors:array[0..MAX_PARAM_COUNT-1] of byte;
 end;

PParamsSets=^TParamsSets;

TEffParams=packed record
 EffNo,
 EffSpeed,
 EffCount,
 EffPause,
 EffOpt:byte;
 end;

PEffParams=^TEffParams;

TTextHeader=packed record
  Signature:dword;
  Font:byte;
  Align:byte;
  Opt:byte;
  Speed:byte;
  Color:byte;
  EffMask:dword;
  Pars:array[0..63] of TEffParams;
//  TextLen:word;
//byte Text[1023];
  end;

PTextHeader=^TTextHeader;


TTextHeaderA=packed record
  Signature:dword;
  Font:byte;
  Align:byte;
  Options:byte;
  Speed:byte;
  Color:byte;
  EffMask:dword;
  end;

PTextHeaderA=^TTextHeaderA;

TShortTextHeader=packed record
  Signature:dword;
  Font:byte;
  Align:byte;
  Options:byte;
  Speed:byte;
  Color:byte;
  end;

PShortTextHeader=^TShortTextHeader;

TSegmentSetsA=packed record
  Signature:dword;
  FunDispStart:byte;
  FunDispLen:byte;
  ParDisplayLens:array[0..MAX_PARAM_COUNT-1] of byte;
  ParDisplayMasks:array[0..MAX_PARAM_COUNT-1] of word;
  ParamTimes:array[0..MAX_PARAM_COUNT-1] of byte;
  DataDispLens:array[0..MAX_SEG_DISP_COUNT-1] of byte;
  UseDefault:byte;
  RowCount, ColCount, ByColumn:byte;
  ClockPointMask, DatePointMask:byte;
  options:byte;
  defHideParamMask:word;
  clearParamMask:word;
  MinusMask, PlusMask:byte;
  end;

TSegmentSets=packed record
   Sets:TSegmentSetsA ;
   reserv:array [1..256-sizeof(TSegmentSetsA)] of byte;
   end;

PSegmentSets=^TSegmentSets;

TSegmentDescrA=packed record
  Signature:dword;
  Font,
  Align,
  DispNo,
  ShowDescr,
  Color,
  ItemSize:byte;
  DataText:array [0..MAX_TEXT_DESCR_COUNT-1, 0..MAX_DESCR_LEN-1] of AnsiChar;
  DataTextCount:byte;
  end;

TSegmentDescr=packed record
   Sets:TSegmentDescrA;
   reserv:array [1..256-sizeof(TSegmentDescrA)] of byte;
   end;

PSegmentDescr=^TSegmentDescr;

TExtTabTunesA=packed record
  Signature:dword;
  ClockType:byte;
  NtpStatus:byte;
  NtpQueryTime:word;
  NtpServerIP:dword;
  NtpServerPort:word;
  NtpClientPort:word;
  UTCAdd:integer;
  MaxNtpDelay:dword;

  DNS1, DNS2:dword;
  DNSClientPort:word;
  DNSTimeOut:word;
  DHCPOpt:dword;

  NtpName:array [0..MAX_DOMAIN_LEN-1] of AnsiChar;
  DS3Wire:byte; //DS1820 connect 3 wire
  gps_PPS_Type:byte;
  gps_Period:byte;
  end;

TExtTabTunes=packed record
   Tunes:TExtTabTunesA;
   reserv:array  [1..128-sizeof(TExtTabTunesA)] of byte;
   end;

PExtTabTunes=^TExtTabTunes;

TUserTunesA=packed record
  Signature:dword;
  reserv:shortint;
  AddPress:shortint;
  AutoBrightOn:byte;
  MinBright:byte;
  DarkVal, LightVal:word;
  UseGamma:byte;
  TempSerial:array[0..MAX_TEMP_SENSOR_COUNT-1] of int64;
  AddTemp:array[0..MAX_TEMP_SENSOR_COUNT-1] of shortint;
  HumADC5V:word;
  HumK0, HumK100:single;
  HumTempCorr:byte;
  ImpPeruR:word;
  KmV:single;
  AddmV:shortint;
  AddAnaTemp:shortint;
  ManualTemp:array[0..MAX_TEMP_SENSOR_COUNT-1] of shortint;
  //at this point free space 56 bytes
  SnsCtrlDefState:byte;
  SnsCtrlInversion:byte;
  SnsCtrl_Type_No:array [0..SNS_CTRL_COUNT-1] of byte;
  SnsCtrlOutNo:array [0..SNS_CTRL_COUNT-1] of byte;
  SnsCtrlHiVal:array [0..SNS_CTRL_COUNT-1] of smallint;
  SnsCtrlLoVal:array [0..SNS_CTRL_COUNT-1] of smallint;
  BrightCoeff:word;
  StartBrightPause:word;
  BrgCoeffA, BrgCoeffB, BrgCoeffC:word;

  windCoeff:single;
  windMeasTime:word;
  windAvrCount:byte;
  manualAnaTemp:shortint;
  AddExtSensors:array [0..EXT_SNS_CORR_CNT-1] of shortint;
  end;

TUserTunes=packed record
   Sets:TUserTunesA;
   reserv:array  [1..128-sizeof(TUserTunesA)] of byte;
   end;

PUserTunes=^TUserTunes;

TExtFuncData=packed record
  Password,
  FNo,
  FVal:dword;
  Reserv:dword;
  end;

PExtFuncData=^TExtFuncData;

TSegDataExtA=packed record
  Signature:dword;
  CourseCount:byte;
  CourseTime:byte;
  CourseBlink:byte;
  LogoFont:byte;
  LogoSize:byte;
  LogoCount:byte;
  LogoOpt:byte;
  Logos:array [0..MAX_TEXT_DESCR_COUNT-1] of byte;
  end;

TSegDataExt=packed record
   Sets:TSegDataExtA;
   reserv:array [1..128-sizeof(TSegDataExtA)] of byte;
   end;

PSegDataExt=^TSegDataExt;

TPicItemHead=packed record
  XSize:word;
  YSizeByte:byte;
  ColorCount:byte;
  end;


TPicItem=packed record
  Head:TPicItemHead;
  ImgData:array [0..cMaxPictureSize-1] of byte;
  end;

PPicItem=^TPicItem;
PPicItemHead=^TPicItemHead;

TExtCommand=packed record
      Command:dword;
      Params:array [0..6] of dword;
      end;

PExtCommand=^TExtCommand;

TSymbDispConfigA=packed record
   Signature:dword;
   LogoSizeX,
   LogoFont,
   LogoAlign,
   LogoColor,
   UseSymbDisp,
   RowCount,
   ColCount,
   ByColumn:byte;
   SymbFontCount:byte;
   DispLogoSym:array [0..MAX_SYMB_DISP_COUNT-1] of byte;
   DispTextZone:array [0..MAX_SYMB_DISP_COUNT-1] of byte;
   DispTextFont:array [0..MAX_SYMB_DISP_COUNT-1] of byte;
   DispTextAlignColor:array [0..MAX_SYMB_DISP_COUNT-1] of byte;
   DispSizeSym:array [0..MAX_SYMB_DISP_COUNT-1] of byte;
   DispSizePix:array [0..MAX_SYMB_DISP_COUNT-1] of word;
   EditMask:int64;
   tCourseCount:byte;
   tCourseTime:byte;
   end;

TSymbDispConfig=packed record
  Sets:TSymbDispConfigA ;
  reserv:array[1..256-sizeof(TSymbDispConfigA)] of byte;
  end;

PSymbDispConfig=^TSymbDispConfig;

TEEDataBlockHeader=packed record
   PageNo:word;
   PageCount,
   ReadPageCount:byte;
   end;

PEEDataBlockHeader=^TEEDataBlockHeader;

TAddrSetCommand=packed record
 Password:dword;
 DevID:dword;
 Opts:byte;
 res:byte;
 NewAddr:word;
 end;

PAddrSetCommand=^TAddrSetCommand;

TTempCtrlRec=packed record
 t1:byte;
 t2:byte;
 Opts:dword;
 end;

PTempCtrlRec=^TTempCtrlRec;

TBrightParams=packed record
   CurBright:byte;
   AutoBrightOn:byte;
  end;
PBrightParams=^TBrightParams;

TDayCounterSets=packed record
  ActiveMode:byte;
  CountFrom24H:byte;
  Format:word;
  TimeStamp:dword;
  InitialValue:dword;
  DayField:byte;
  HourField:byte;
  MinuteField:byte;
  SecondField:byte;
  resetKey:byte;
  max_record:byte;
  MarkValue:dword;
  extColors:byte;
  reserv:array [1..5] of byte;
  end;

PDayCounterSets=^TDayCounterSets;

TDayCounterValue=packed record
  totalValue:dword;
  ValueSecond:dword;
  ValueMinute:dword;
  ValueHours:dword;
  ValueDays:dword;
  ready:byte;
  res:array [1..3] of byte;
  end;

TRecSensor=packed record
  index,
  flags:byte;
  value:smallint;
  end;

PRecSensor=^TRecSensor;


TMiscSetsA=packed record
  Signature:dword;
  user_Keys:array [0..USER_KEY_COUNT-1] of byte;
  user_Functs:array [0..USER_KEY_COUNT-1] of byte;
  user_Opts:array [0..USER_KEY_COUNT-1] of byte;
  user_funcIndex:array [0..USER_KEY_COUNT-1] of shortint;
  end;

TMiscSets=packed record
   Sets:TMiscSetsA;
   reserv:array[1..256-sizeof(TMiscSetsA)] of byte;
   end;

PMiscSets=^TMiscSets;

TSheduleData=packed record
   onSegMask:word;
   offSegMask:word;
   onTextMask:word; //not use now
   offTextMask:word; //not use now
   startBeepLen:byte;
   endBeepLen:byte;
   beepLine:byte;
   res: array [1..3] of byte;
  end;
PSheduleData=^TSheduleData;

TSheduleItem=packed record
   startTime:word;
   timeLen:word;
   shDataIndex:byte;
   format:byte;
   lineNo:byte;
   daily:byte;
   blinkValue:word;
   res: array [1..1] of byte;
   end;
PSheduleItem=^TSheduleItem;

TSheduleTableA=packed record
   signature:dword;
   items:array [0..MAX_SHED_ITEM_CNT-1] of TSheduleItem;
   data :array [0..MAX_SHED_DATA_CNT-1] of TSheduleData;
   end;

TSheduleTable=packed record
   table:TSheduleTableA;
   reserv:array[1..512-sizeof(TSheduleTableA)] of byte;
   end;

TDispTimer=packed record
  flags:byte;
  stringNo:byte;
  showCount:byte;
  showTime:byte;
  onMask:word;
  offMask:word;
  reserv:array [1..8] of byte;
  end;

TDispTimersA=packed record
  signature:dword;
  timers:array [0..DISP_TIMER_COUNT-1] of TDispTimer;
  tmrMask:array [0..DISP_UNION_COUNT-1] of word;
  startOffMask:word;
  end;
PDispTimer=^TDispTimer;

TDispTimers=packed record
  data:TDispTimersA;
  reserv:array [1..256-sizeof(TDispTimersA)] of byte;
  end;


TDigiCounterRec=packed record
  MaxValue:integer;
  MinValue:integer;
  Value:integer;
  opts:byte;
  dispNo:byte;
  dec:byte; //decimal digits
  incIR, decIR, resetIR:byte;
  incExt, decExt, resetExt:word;
  reserv:array[1..7] of byte;
  end;

PDigiCounterRec=^TDigiCounterRec;

TDigiCountersA=packed record
  signature:dword;
  items:array [0..MAX_DIGICOUNT_CNT-1] of TDigiCounterRec;
  end;

TDigiCounters=packed record
  data:TDigiCountersA;
  reserv:array [1..sizeof_TDigiCounters-sizeof(TDigiCountersA)] of byte;
  end;

TIntValueGet=packed record
  itemType:byte;
  itemIndex:byte;
  itemCount:byte;
  end;
PIntValueGet=^TIntValueGet;

TIntValueSet=packed record
  itemType:byte;
  itemIndex:byte;
  end;
PIntValueSet=^TIntValueSet;

function ExchangeCommandSimple(Cmd:byte; Data:pointer; DataSize:integer):integer;
function ExchangeCommandData(Cmd:byte; Data:pointer; DataSize:integer; OutBuff:pointer; NeedSz:integer; var OutSize:integer):integer;

function  OpenPortExt(pn:string; UDP, NoAnswer:boolean; NoChkID:boolean=false; Transt:boolean=false):boolean;
function  OpenPort(pn:string):boolean;
procedure ClosePort;

function CheckConnect:integer;
function CheckConnectInt:integer;
function ctrlReboot(Loader:boolean):integer;
function ctrlRebootEx(Mode:integer):integer;
function ctrlCheckConnByMask(Id, Mask:word; Sw:boolean):integer;
function ctrlGetConfByMask(Id, Mask:word; Sw:boolean; Conf:PTabConfig):integer;
function ctrlSetConfByMask(Id, Mask:word; Sw:boolean; Conf:PTabConfig):integer;
function ctrlRestoreDefault(RestoreNetSets:boolean=false):integer;
function ctrlSetBright(Br:integer):integer;
function ctrlSetBrightExt(Br:integer; Auto:boolean):integer;
function ctrlSetTime(T:TSystemTime):integer;
function ctrlGetTime(var T:TSystemTime):integer;

function ctrlSetMainTime(MT:PMainTime):integer;
function ctrlGetMainTime(MT:PMainTime):integer;

function ctrlSimpleTextOut(P:PSimpleTextOutParams; s:Ansistring):integer;
function ctrlSimpleDataOut(P:PSimpleTextOutParams; Data:pointer; DataLen:integer):integer;

function ctrlSetTestMode(Mask:word; Cycle:boolean):integer;
function ctrlExtTextOut(DispNo, Opt:dword; P:Pointer; HeadSize:integer; s:Ansistring):integer;
function ctrlExtDataOut(DispNo, Opt:dword; P:Pointer; HeadSize:integer; Data:pointer; DataLen:integer):integer;
function ctrlShowTabParameter(P:PSimpleTextOutParams):integer;
function ctrlSetNewDevAddress(NewAd:word; DevId:dword):integer;
function ctrlSetSystemTime(ST:PSystemTime):integer;

function ctrlGetExtParams(P:PExtParams):integer;
function ctrlGetDispConfig(P:PMainDispConfig):integer;
function ctrlSetDispConfig(P:PMainDispConfig; Flags:integer):integer;
function ctrlSetTextZoneDescr(n:integer; P:PTextZoneDescr; Flags:integer):integer;
function ctrlGetTextZoneDescr(n:integer; P:PTextZoneDescr):integer;
function ctrlGetParamSet(n:integer; P:PParamsSets):integer;
function ctrlSetParamSet(n:integer; P:PParamsSets; Flags:integer):integer;

function ctrlGetSegmConfig(P:PSegmentSets):integer;
function ctrlSetSegmConfig(P:PSegmentSets; Flags:integer):integer;
function ctrlGetExtConfig(P:PExtTabTunes):integer;
function ctrlSetExtConfig(P:PExtTabTunes; Flags:integer):integer;
function ctrlGetSegmentDescr(P:PSegmentDescr):integer;
function ctrlSetSegmentDescr(P:PSegmentDescr; Flags:integer):integer;

function ctrlGetUserTunes(P:PUserTunes):integer;
function ctrlSetUserTunes(P:PUserTunes; Flags:integer):integer;

function ctrlExecExtFunction(FNo, FVal:dword):integer;
function ctrlExecExtFunctionFull(FNo, FVal, Reserv:dword):integer;
function ctrlGetStatus(FNo:dword; var Status:dword):integer;
function ctrlGetStatusExt(FNo, pn:dword; var Status:dword):integer;

function ctrlGetSegDataExt(P:PSegDataExt):integer;
function ctrlSetSegDataExt(P:PSegDataExt; Flags:integer):integer;

function ctrlSetPicture(N:integer; P:PPicItem):integer;
function ctrlSetPictureCount(N:integer):integer;
function ExecExternalCommand(P:PExtCommand):integer;

function ctrlGetSymbDispConfig(P:PSymbDispConfig):integer;
function ctrlSetSymbDispConfig(P:PSymbDispConfig; Flags:integer):integer;


function ctrlSegTextRead(ColNo, RowNo:integer; var s:Ansistring; opt:integer=0):integer;
function ctrlSegTextOut(ColNo, RowNo, Align, BlinkCount:integer; Save:boolean; s:Ansistring):integer;

function ctrlReadSymbText(ColNo, RowNo:integer; AbsNo:boolean; var s:Ansistring):integer;
function ctrlSetSymbText(ColNo, RowNo:integer; AbsNo, Save:boolean; s:Ansistring):integer;
function ctrlSetSymbTextExt(ColNo, RowNo, Font, Color, Align:integer; AbsNo, Save:boolean; s:Ansistring):integer;
function ctrlSetTempSensorCommand(P:PTempCtrlRec):integer;

function ctrlReadEEPROM(H:PEEDataBlockHeader; Data:pointer):integer;
function ctrlWriteEEPROM(H:PEEDataBlockHeader; Data:pointer):integer;

function ctrlGetCellNoByRC(R,C:integer; var Cell:integer):integer;
function ctrlGetExtLogoNumber(n:integer; var No:integer):integer;
function ctrlSetExtLogoNumber(DispIndex:integer; LogoNo:integer; Save, UpdateExt:boolean):integer;
function ctrlSimpleTextOutSkip(P:PSimpleTextOutParams; s:Ansistring):integer;
function ctrlClearRunTextBuffer(DispNo:dword; save:boolean):integer;
function ctrlPlaceRunTextBuffer(DispNo, Address:dword; DataSize:dword; Data:pointer):integer;
function ctrlPlaceRunTextHeader(DispNo, TextLen:dword; H:PShortTextHeader; Save:boolean):integer;
function LoadTextData(DispNo, DataLen:dword; Data:pointer; Save:boolean; SH:PShortTextHeader; Progr:TLoadProgressProc):integer;
function ctrlRestoreSavedTextBuffer(DispNo:dword; res:pdword):integer;

function ctrlGetBrightParams(P:PBrightParams):integer;

function ctrlGetStructure(structType, StructIndex:word; Buff:pointer; StructSize:integer; ItemCount:integer=1):integer;
function ctrlSetStructure(structType, StructIndex:word; Buff:pointer; StructSize:integer; Save:boolean):integer;
function ctrlSetStructureEx(structType, StructIndex:word; Buff:pointer; StructSize:integer; Flags:byte):integer;

function ctrlSetDayTimerByDate(index:byte; T:TSystemTime):integer;

function ctrlGetSensorValues(Index, Count:integer; Visible:boolean; buff:PSmallInt):integer;

function ctrlSetIntValues(itemType, itemIndex, itemCount:byte; Data:PInteger):integer;
function ctrlGetIntValues(itemType, itemIndex, itemCount:byte; DataBuff:PInteger):integer;

function ctrlSegmentBinDataWrite(Col, Row, DataLen:integer; Data:pointer; AbsNo, CheckRange, Save:boolean):integer;
function ctrlSegmentBinDataRead(Col, Row:integer; AbsNo, CheckRange:boolean; Data:pointer; var DataSize:integer):integer;

implementation

uses SysUtils;

const
      PACK_FLAG_NOANSWER  =  $01;
      PACK_FLAG_NOCHECKID =  $02;
      PACK_FLAG_RESEND    =  $04;

      cmdCheckConnect=1;
      cmdSetBright=2;
      cmdSetTime=3;
      cmdGetTime=4;
      cmdOutText=5;
      cmdExtOutText=6;

      cmdSetSymbText=8;
      cmdReadSymbText=9;
      cmdSetTestMode=10;
      cmdOutTextSkip=11;

      cmdSegmentBinDataWrite=13;
      cmdSegmentBinDataRead=14;

      cmdSegTextOut=15;
      cmdSegTextRead=16;
      cmdSetPicture=17;
      cmdSetPictureCount=18;
      cmdExecExternalCommand=19;
      cmdGetExtLogoNumber=20;
      cmdSetExtLogoNumber=21;
      cmdGetCellNoByRC=22;
      cmdShowTabParameter=23;
      cmdSetNewDevAddress=24;
      cmdSetSystemTime=25;

      cmdSetSymbTextExt=27;
      cmdSwapTempSensors=28;
      cmdClearRunTextBuffer=29;
      cmdPlaceRunTextBuffer=30;
      cmdPlaceRunTextHeader=31;
      cmdRestoreSavedTextBuffer=32;
      cmdSetBrightExt=33;
      cmdGetBrightParams=34;

      cmdSetRemoteSensors=40;
      cmdStartDayTimerByDate=41;
      cmdGetSensorValues=42;

      cmdGetSportConsts=50;
      cmdGetCommonSportTunes=51;
      cmdGetSportView=52;
      cmdGetSportTimer=53;
      cmdSetCommonSportTunes=54;
      cmdSetSportView=55;
      cmdSetSportTimer=56;
      cmdExecSportCommand=57;
      cmdGetTimerPresets=58;
      cmdSetTimerPresets=59;
      cmdGetSnapShots=60;
      cmdSetSnapShots=61;

      cmdExecPduCommand=70;

      cmdGetStructure=80;
      cmdSetStructure=81;
      cmdGetIntValues=82;
      cmdSetIntValues=83;

      cmdGetEEPROM=198;
      cmdSetEEPROM=199;

      cmdGetSymbDispConfig=200;
      cmdSetSymbDispConfig=201;

      cmdGetUserTunes=202;
      cmdSetUserTunes=203;

      cmdGetDispConfig=206;
      cmdGetTextZone=207;
      cmdSetDispConfig=208;
      cmdSetZoneDescr=209;
      cmdGetExtParams=211;

      cmdGetParamSet=212;
      cmdSetParamSet=213;

      cmdGetSegmConfig=214;
      cmdSetSegmConfig=215;
      cmdGetExtConfig=216;
      cmdSetExtConfig=217;
      cmdGetSegmentDescr=218;
      cmdSetSegmentDescr=219;
      cmdGetSegDataExt=220;
      cmdSetSegDataExt=221;


//222 - 229 - for loader
      cmdGetLoaderVersion=222;
      cmdGetFontInfo=223;
      cmdReboot=224;
      cmdExecFlashCommand=225;
      cmdCheckConnByMask=226;
      cmdGetConfByMask=227;
      cmdSetConfByMask=228;
      cmdRestoreDef=229;
      cmdExecExtFunction=230;
      cmdGetStatus=231;

//      NoWaitAnswer:boolean=false;
//      NoCheckID:boolean=false;
//      Transit:boolean=false;

function OpenPortExt(pn:string; UDP, NoAnswer:boolean; NoChkID:boolean=false; Transt:boolean=false):boolean;
   begin
//   WorkPortName:=StringToPortName(pn);
   WorkPort.UDPMode:=UDP;
   WorkPort.NoWaitAnswer:=NoAnswer;
   WorkPort.NoCheckID:=NoChkID;
   WorkPort.Transit:=Transt;
   Result:=OpenPort(StringToPortName(pn));
   end;

function OpenPort(pn:string):boolean;
  begin
  if WorkPort.PortName<>pn
                   then begin
                        WorkPort.PortName:=pn;
                        end;
  Result:=WorkPort.Opened;
//  WorkPortName:=WorkPort.PortName;
  if Result then begin
                 if WorkPort.LANConnection then begin
                                                if WorkPort.UDPMode then begin
                                                                         WorkPort.WaitTimeOut:=LanUDPTimeOut;
                                                                         WorkPort.TryCount:=3;
                                                                         end
                                                                    else begin
                                                                         WorkPort.WaitTimeOut:=LanTCPTimeOut;
                                                                         WorkPort.TryCount:=1;
                                                                         end;
                                                end
                                           else begin
                                                WorkPort.WaitTimeOut:=RS485TimeOut;
                                                WorkPort.TryCount:=1;
                                                end
                 end;
  end;

procedure ClosePort;
  begin
  WorkPort.PortName:='';
  end;

function ExchangeDataPacket(SP, DP:PLevel2Pack; TimeOut:integer):boolean;
  begin
  Result:=WorkPort.SendBlock(SP);
  if not Result then Exit;
  if WorkPort.NoWaitAnswer then Exit;
  repeat
  Result:=WorkPort.WaitBlock(DP, sizeof(TLevel2Pack), TimeOut)
  until (not Result) or ((DP^.PId=SP^.PId) and (DP^.Cmd=SP^.Cmd) and (DP^.DstAddr=SrcAddr) and (DP^.Status and $C0=0));
  end;

function SendCommandWithDataInt(DstAddr:word; Cmd:byte; Data:pointer; DataSize:integer; DB:PLevel2Pack; TimeOut:integer):integer;
 var SB, RB:TLevel2Pack;
  begin
  if (DataSize>RecBuffSizeByte) or (DataSize<0)
                              then begin
                                   Result:=ecInvalidDataSize;
                                   Exit;
                                   end;
  WorkPort.PacketId:=(integer(WorkPort.PacketId)+1) and $7F;
  SB.SrcAddr:=SrcAddr;
  SB.DstAddr:=DstAddr;
  SB.PId:=WorkPort.PacketId;
  SB.Cmd:=Cmd;
  SB.Flags:=0;
  if WorkPort.NoWaitAnswer then SB.Flags:=SB.Flags or PACK_FLAG_NOANSWER;
  if WorkPort.NoCheckID then SB.Flags:=SB.Flags or PACK_FLAG_NOCHECKID;
  if WorkPort.Transit then SB.Flags:=SB.Flags or PACK_FLAG_RESEND;

//  SB.Flags:=SB.Flags or $02; // skip check packet id
  SB.Status:=SendPacketStatus;
  SB.DataLen:=DataSize;
  if (DataSize>0) then Move(Data^, SB.Data, DataSize);
  if not ExchangeDataPacket(@SB, @RB, TimeOut)
     then begin
          Result:=ecConnectError;
          Exit;
          end;
  if WorkPort.NoWaitAnswer then begin
                       Result:=ecOK;
                       Exit;
                       end;
  Result:=RB.Status;
  if (DB<>Nil) then Move(RB, DB^, RB.DataLen+sizeof(TLevel2Head));
  end;

function SendCommandWithData(DstAddr:word; Cmd:byte; Data:pointer; DataSize:integer; DB:PLevel2Pack; TimeOut:integer):integer;
 var n:integer;
  begin
  n:=0;
  repeat
  Result:=SendCommandWithDataInt(DstAddr, Cmd, Data, DataSize, DB, TimeOut);
  inc(n);
//  if Result=ecConnectError then inc(ErrorsOfConn);
  until (Result<>ecConnectError) or (n>=WorkPort.TryCount);
  end;

function ExchangeCommandData(Cmd:byte; Data:pointer; DataSize:integer; OutBuff:pointer; NeedSz:integer; var OutSize:integer):integer;
 var D:TLevel2Pack;
  begin
  OutSize:=0;
  Result:=SendCommandWithData(DestAddr, Cmd, Data, DataSize, @D, WorkPort.WaitTimeOut);
  if Result<>ecOK then Exit;
  if NeedSz>=0 then begin
                    if D.DataLen<>NeedSz then begin
                                              Result:=ecBadAnswer;
                                              Exit;
                                              end;
                    end;
  OutSize:=D.DataLen;
  if (OutSize>0) and (OutBuff<>Nil) then Move(D.Data, OutBuff^, OutSize);
  end;

function ExchangeCommandSimple(Cmd:byte; Data:pointer; DataSize:integer):integer;
  begin
  Result:=SendCommandWithData(DestAddr, Cmd, Data, DataSize, Nil, WorkPort.WaitTimeOut);
  end;

function CheckConnectInt:integer;
  begin
  Result:=ExchangeCommandSimple(cmdCheckConnect, Nil, 0);
  end;

function CheckConnect:integer;
 var n, cnt:integer;
  begin
  n:=0;
  if WorkPort.TryCount>1 then cnt:=2
                         else cnt:=3;
  repeat
  Result:=CheckConnectInt;
  inc(n);
  until (Result<>ecConnectError) or (n>=cnt);
  end;

function ctrlReboot(Loader:boolean):integer;
 var b:byte;
  begin
  if Loader then b:=$A2
            else b:=$7A;
  Result:=ExchangeCommandSimple(cmdReboot, @b, 1);
  end;

function ctrlRebootEx(Mode:integer):integer;
 var b:byte;
  begin
  case Mode of
  1: b:=$A2; //loader
  2: b:=$7A; //fast reboot
  else b:=$99; //reboot after 10 sec.
  end;
  Result:=ExchangeCommandSimple(cmdReboot, @b, 1);
  end;

type TReqDetails=packed record
  opts:byte;
  reserv:byte;
  Id:word;
  Mask:word;
  end;

function ctrlCheckConnByMask(Id, Mask:word; Sw:boolean):integer;
 var RD:TReqDetails;
  begin
  FillChar(RD, sizeof(RD), 0);
  if Sw then RD.opts:=1;
  RD.Id:=Id;
  RD.Mask:=Mask;
  Result:=ExchangeCommandSimple(cmdCheckConnByMask, @RD, sizeof(RD));
  end;

function ctrlGetConfByMask(Id, Mask:word; Sw:boolean; Conf:PTabConfig):integer;
 var sz:integer;
     RD:TReqDetails;
  begin
  FillChar(RD, sizeof(RD), 0);
  if Sw then RD.opts:=1;
  RD.Id:=Id;
  RD.Mask:=Mask;
  Result:=ExchangeCommandData(cmdGetConfByMask,  @RD, sizeof(RD), Conf, sizeof(TTabConfig), sz);
  end;

type TConfigWithDetails=packed record
  Passw:dword;
  D:TReqDetails;
  C:TTabConfig;
  end;

function ctrlSetConfByMask(Id, Mask:word; Sw:boolean; Conf:PTabConfig):integer;
 var CD:TConfigWithDetails;
  begin
  FillChar(CD, sizeof(CD), 0);
  if Sw then CD.D.opts:=1;
  CD.D.Id:=Id;
  CD.D.Mask:=Mask;
  CD.C:=Conf^;
  CD.Passw:=$7A129A71;
  Result:=ExchangeCommandSimple(cmdSetConfByMask, @CD, sizeof(CD));
  end;

function ctrlRestoreDefault(RestoreNetSets:boolean=false):integer;
 var pass:dword;
  begin
  if (RestoreNetSets) then pass:=$A32E87B1
                      else pass:=$81479EC4;
  Result:=ExchangeCommandSimple(cmdRestoreDef, @pass, sizeof(dword));
  end;

function ctrlSetBright(Br:integer):integer;
  begin
  Result:=ExchangeCommandSimple(cmdSetBright, @Br, 1);
  end;

function ctrlSetBrightExt(Br:integer; Auto:boolean):integer;
 var a:array[0..1] of byte;
  begin
  a[0]:=byte(br);
  a[1]:=byte(Auto);
  Result:=ExchangeCommandSimple(cmdSetBrightExt, @a, 2);
  end;


function WeekDayByDate(Day,Month,Year:integer):integer;
  begin
  try
  Result:=DayOfWeek(EncodeDate(Year,Month,Day));
  if Result=1 then Result:=7
              else Dec(Result);
  except
  Result:=1;
  end;
  end;

function ctrlSetMainTime(MT:PMainTime):integer;
  begin
  Result:=ExchangeCommandSimple(cmdSetTime, MT, sizeof(TMainTime));
  end;

function ctrlSetTime(T:TSystemTime):integer;
 var MT:TMainTime;
  begin
  MT.Sec:=T.wSecond;
  MT.Min:=T.wMinute;
  MT.Hour:=T.wHour;
  MT.Date:=T.wDay;
  MT.Month:=T.wMonth;
  MT.Year:=T.wYear mod 100;
  Result:=ExchangeCommandSimple(cmdSetTime, @MT, sizeof(MT));
  end;

function ctrlGetTime(var T:TSystemTime):integer;
 var MT:TMainTime;
     sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetTime,  Nil, 0, @MT, sizeof(MT), sz);
  if Result<>ecOK then Exit;
  FillChar(T, sizeof(T), 0);
  T.wSecond:=MT.Sec;
  T.wMinute:=MT.Min;
  T.wHour:=MT.Hour;
  T.wDay:=MT.Date;
  T.wMonth:=MT.Month;
  T.wYear:=2000+MT.Year;
  T.wDayOfWeek:=WeekDayByDate(T.wDay, T.wMonth, T.wYear);
  end;

function ctrlGetMainTime(MT:PMainTime):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetTime,  Nil, 0, MT, sizeof(TMainTime), sz);
  end;


function ctrlSimpleTextOut(P:PSimpleTextOutParams; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     n:integer;
  begin
  Move(P^, a, sizeof(TSimpleTextOutParams));
  n:=length(s);
  if (n=0) then begin
                s:=' ';
                n:=1;
                end;
  if (n>sizeof(a)-sizeof(TSimpleTextOutParams)) then n:=sizeof(a)-sizeof(TSimpleTextOutParams);
  Move(Pointer(s)^, a[sizeof(TSimpleTextOutParams)], n);
//  for i:=0 to n-1 do a[sizeof(TOutTextParams)+i]:=a[sizeof(TOutTextParams)+i] and $7F;
  n:=n+sizeof(TSimpleTextOutParams);
  Result:=ExchangeCommandSimple(cmdOutText, @a, n);
  end;

function ctrlSimpleDataOut(P:PSimpleTextOutParams; Data:pointer; DataLen:integer):integer;
 var a:array [0..4095] of byte;
  begin
  if (DataLen>sizeof(a)-sizeof(TSimpleTextOutParams)) then DataLen:=sizeof(a)-sizeof(TSimpleTextOutParams);
  Move(P^, a, sizeof(TSimpleTextOutParams));
  Move(Data^, a[sizeof(TSimpleTextOutParams)], DataLen);
//  for i:=0 to n-1 do a[sizeof(TOutTextParams)+i]:=a[sizeof(TOutTextParams)+i] and $7F;
  DataLen:=DataLen+sizeof(TSimpleTextOutParams);
  Result:=ExchangeCommandSimple(cmdOutText, @a, DataLen);
  end;

function ctrlSetTestMode(Mask:word; Cycle:boolean):integer;
  begin
  Mask:=Mask and $07;
  if Cycle and (Mask<>0) then Mask:=Mask or $8000;
  Result:=ExchangeCommandSimple(cmdSetTestMode, @Mask, sizeof(Mask));
  end;

function ctrlGetExtParams(P:PExtParams):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetExtParams,  Nil, 0, P, sizeof(TExtParams), sz);
  end;

function ctrlGetTextZoneDescr(n:integer; P:PTextZoneDescr):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetTextZone,  @n, 1, P, sizeof(TTextZoneDescr), sz);
  end;

function ctrlSetTextZoneDescr(n:integer; P:PTextZoneDescr; Flags:integer):integer;
var a:array [0..sizeof(TTextZoneDescr)+1] of byte;
  begin
  a[0]:=n;
  a[1]:=Flags;
  Move(P^, a[2], sizeof(TTextZoneDescr));
  Result:=ExchangeCommandSimple(cmdSetZoneDescr, @a, sizeof(TTextZoneDescr)+2);
  end;

function ctrlGetDispConfig(P:PMainDispConfig):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetDispConfig,  Nil, 0, P, sizeof(TMainDispConfig), sz);
  end;

function ctrlSetDispConfig(P:PMainDispConfig; Flags:integer):integer;
 var a:array [0..sizeof(TMainDispConfig)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TMainDispConfig));
  Result:=ExchangeCommandSimple(cmdSetDispConfig, @a, sizeof(TMainDispConfig)+1);
  end;

function ctrlExtTextOut(DispNo, Opt:dword; P:Pointer; HeadSize:integer; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     n:integer;
     PW:PWord;
  begin
  a[0]:=byte(DispNo);
  a[1]:=byte(Opt);
  Move(P^, a[2], HeadSize);
  n:=length(s);
  if (n>sizeof(a)-4-HeadSize) then n:=sizeof(a)-4-HeadSize;
  PW:=@a[HeadSize+2];
  PW^:=n;
  Move(Pointer(s)^, a[HeadSize+4], n);
//  for i:=0 to n-1 do a[sizeof(TOutTextParams)+i]:=a[sizeof(TOutTextParams)+i] and $7F;
  n:=n+HeadSize+4;
  Result:=ExchangeCommandSimple(cmdExtOutText, @a, n);
  end;

function ctrlExtDataOut(DispNo, Opt:dword; P:Pointer; HeadSize:integer; Data:pointer; DataLen:integer):integer;
 var a:array [0..4095] of byte;
     PW:PWord;
  begin
  a[0]:=byte(DispNo);
  a[1]:=byte(Opt);
  Move(P^, a[2], HeadSize);
  if (DataLen>sizeof(a)-4-HeadSize) then DataLen:=sizeof(a)-4-HeadSize;
  PW:=@a[HeadSize+2];
  PW^:=DataLen;
  Move(Data^, a[HeadSize+4], DataLen);
//  for i:=0 to n-1 do a[sizeof(TOutTextParams)+i]:=a[sizeof(TOutTextParams)+i] and $7F;
  DataLen:=DataLen+HeadSize+4;
  Result:=ExchangeCommandSimple(cmdExtOutText, @a, DataLen);
  end;

function ctrlGetParamSet(n:integer; P:PParamsSets):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetParamSet,  @n, 1, P, sizeof(TParamsSets), sz);
  end;

function ctrlSetParamSet(n:integer; P:PParamsSets; Flags:integer):integer;
var a:array [0..sizeof(TParamsSets)+1] of byte;
  begin
  a[0]:=n;
  a[1]:=Flags;
  Move(P^, a[2], sizeof(TParamsSets));
  Result:=ExchangeCommandSimple(cmdSetParamSet, @a, sizeof(TParamsSets)+2);
  end;

function ctrlGetSegmConfig(P:PSegmentSets):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetSegmConfig,  Nil, 0, P, sizeof(TSegmentSets), sz);
  end;

function ctrlSetSegmConfig(P:PSegmentSets; Flags:integer):integer;
 var a:array [0..sizeof(TSegmentSets)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TSegmentSets));
  Result:=ExchangeCommandSimple(cmdSetSegmConfig, @a, sizeof(TSegmentSets)+1);
  end;

function ctrlGetExtConfig(P:PExtTabTunes):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetExtConfig,  Nil, 0, P, sizeof(TExtTabTunes), sz);
  end;

function ctrlSetExtConfig(P:PExtTabTunes; Flags:integer):integer;
 var a:array [0..sizeof(TExtTabTunes)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TExtTabTunes));
  Result:=ExchangeCommandSimple(cmdSetExtConfig, @a, sizeof(TExtTabTunes)+1);
  end;

function ctrlExecExtFunction(FNo, FVal:dword):integer;
 var E:TExtFuncData;
  begin
  FillChar(E, sizeof(E), 0);
  E.FNo:=FNo;
  E.FVal:=FVal;
  E.Password:=$5C1E9A49;
  Result:=ExchangeCommandSimple(cmdExecExtFunction, @E, sizeof(TExtFuncData));
  end;

function ctrlExecExtFunctionFull(FNo, FVal, Reserv:dword):integer;
 var E:TExtFuncData;
  begin
  FillChar(E, sizeof(E), 0);
  E.FNo:=FNo;
  E.FVal:=FVal;
  E.Reserv:=Reserv;
  E.Password:=$5C1E9A49;
  Result:=ExchangeCommandSimple(cmdExecExtFunction, @E, sizeof(TExtFuncData));
  end;

function ctrlGetSegmentDescr(P:PSegmentDescr):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetSegmentDescr,  Nil, 0, P, sizeof(TSegmentDescr), sz);
  end;

function ctrlSetSegmentDescr(P:PSegmentDescr; Flags:integer):integer;
 var a:array [0..sizeof(TSegmentDescr)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TSegmentDescr));
  Result:=ExchangeCommandSimple(cmdSetSegmentDescr, @a, sizeof(TSegmentDescr)+1);
  end;

type

TExtStatusData=packed record
  Password:dword;
  FNo:byte;
  Pars:array[0..2] of byte;
  end;

function ctrlGetStatus(FNo:dword; var Status:dword):integer;
 var E:TExtStatusData;
     sz:integer;
  begin
  Status:=0;
  FillChar(E, sizeof(E), 0);
  E.FNo:=byte(FNo);
  E.Password:=$5C1E9A49;
  Result:=ExchangeCommandData(cmdGetStatus, @E, sizeof(TExtStatusData), @Status, sizeof(Status), sz);
  end;

function ctrlGetStatusExt(FNo, pn:dword; var Status:dword):integer;
 var E:TExtStatusData;
     sz:integer;
  begin
  Status:=0;
  FillChar(E, sizeof(E), 0);
  E.FNo:=byte(FNo);
  E.Pars[0]:=pn;
  E.Password:=$5C1E9A49;
  Result:=ExchangeCommandData(cmdGetStatus, @E, sizeof(TExtStatusData), @Status, sizeof(Status), sz);
  end;

function ctrlGetSegDataExt(P:PSegDataExt):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetSegDataExt,  Nil, 0, P, sizeof(TSegDataExt), sz);
  end;

function ctrlSetSegDataExt(P:PSegDataExt; Flags:integer):integer;
 var a:array [0..sizeof(TSegDataExt)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TSegDataExt));
  Result:=ExchangeCommandSimple(cmdSetSegDataExt, @a, sizeof(TSegDataExt)+1);
  end;

function ctrlSetPicture(N:integer; P:PPicItem):integer;
 var sz:integer;
     a:array [0..sizeof(TPicItemHead)+cMaxPictureSize] of byte;
  begin
  sz:=sizeof(TPicItemHead)+P^.Head.XSize*P^.Head.YSizeByte*P^.Head.ColorCount;
  if (sz>cMaxPictureSize)
    then begin
         Result:=ecParamError;
         Exit;
         end;
  a[0]:=byte(N);
  Move(P^, a[1], sz);
  Result:=ExchangeCommandSimple(cmdSetPicture, @a, sz+1);
  end;

function ctrlSetPictureCount(N:integer):integer;
  begin
  Result:=ExchangeCommandSimple(cmdSetPictureCount, @N, 1);
  end;

function ExecExternalCommand(P:PExtCommand):integer;
  begin
  Result:=ExchangeCommandSimple(cmdExecExternalCommand, P, sizeof(TExtCommand));
  end;

function ctrlGetSymbDispConfig(P:PSymbDispConfig):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetSymbDispConfig,  Nil, 0, P, sizeof(TSymbDispConfig), sz);
  end;

function ctrlSetSymbDispConfig(P:PSymbDispConfig; Flags:integer):integer;
 var a:array [0..sizeof(TSymbDispConfig)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TSymbDispConfig));
  Result:=ExchangeCommandSimple(cmdSetSymbDispConfig, @a, sizeof(TSymbDispConfig)+1);
  end;

function ctrlSegTextOut(ColNo, RowNo, Align, BlinkCount:integer; Save:boolean; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     P:PSimpleTextOutParams;
     n:integer;
  begin
  P:=@a;
  FillChar(a, sizeof(a), 0);
  P^.DispNo:=byte(RowNo);
  P^.Font:=byte(ColNo);
  if Save then P^.Opt:=$80;
  P^.Align:=byte(Align);
  if BlinkCount>0
    then begin
         P^.EffNo:=2;
         P^.EffCount:=BlinkCount;
         P^.EffTime:=250;
         end;
  n:=length(s);
  if (n<=0) then begin
                 s:=' ';
                 n:=1;
                 end;
  if (n>sizeof(a)-sizeof(TSimpleTextOutParams)) then n:=sizeof(a)-sizeof(TSimpleTextOutParams);
  Move(Pointer(s)^, a[sizeof(TSimpleTextOutParams)], n);
  n:=n+sizeof(TSimpleTextOutParams);
  Result:=ExchangeCommandSimple(cmdSegTextOut, @a, n);
  end;

function ctrlSegTextRead(ColNo, RowNo:integer; var s:Ansistring; opt:integer=0):integer;
  var b:array [0..4095] of AnsiChar;
      a:array[0..3] of byte;
      sz:integer;
     begin
     FillChar(a, sizeof(a), 0);
     FillChar(b, sizeof(b), 0);
     a[0]:=byte(RowNo);
     a[1]:=byte(ColNo);
     a[3]:=byte(opt);
     Result:=ExchangeCommandData(cmdSegTextRead, @a, sizeof(a), @b, -1, sz);
     s:=b;
     end;

type

TSymbCellHeader=packed record
  Row, Col:byte;
  Opt:byte;
  Flags:byte;
  end;

PSymbCellHeader=^TSymbCellHeader;

function ctrlReadSymbText(ColNo, RowNo:integer; AbsNo:boolean; var s:Ansistring):integer;
  var b:array [0..4095] of AnsiChar;
      CH:TSymbCellHeader;
      sz:integer;
     begin
     FillChar(CH, sizeof(CH), 0);
     FillChar(b, sizeof(b), 0);
     CH.Row:=byte(RowNo);
     CH.Col:=byte(ColNo);
     if (AbsNo) then CH.Opt:=$01;
     Result:=ExchangeCommandData(cmdReadSymbText, @CH, sizeof(TSymbCellHeader), @b, -1, sz);
     s:=b;
     end;

function ctrlSetSymbText(ColNo, RowNo:integer; AbsNo, Save:boolean; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     P:PSymbCellHeader;
     n:integer;
  begin
  P:=@a;
  FillChar(a, sizeof(a), 0);
  P^.Row:=byte(RowNo);
  P^.Col:=byte(ColNo);
  if (AbsNo) then P^.Opt:=$01;
  if (Save) then P^.Opt:=P^.Opt or $80;
  n:=length(s);
  if (n>sizeof(a)-sizeof(TSymbCellHeader)) then n:=sizeof(a)-sizeof(TSymbCellHeader);
  Move(Pointer(s)^, a[sizeof(TSymbCellHeader)], n);
  n:=n+sizeof(TSymbCellHeader);
  Result:=ExchangeCommandSimple(cmdSetSymbText, @a, n);
  end;

type
TSymbCellHeaderExt=packed record
  Row, Col:byte;
  Font, Color, Align:byte;
  Opt:byte;
  Flags:byte;
  end;

PSymbCellHeaderExt=^TSymbCellHeaderExt;

function ctrlSetSymbTextExt(ColNo, RowNo, Font, Color, Align:integer; AbsNo, Save:boolean; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     P:PSymbCellHeaderExt;
     n:integer;
  begin
  if s='' then s:=' ';
  P:=@a;
  FillChar(a, sizeof(a), 0);
  P^.Row:=byte(RowNo);
  P^.Col:=byte(ColNo);
  P^.Font:=byte(Font);
  P^.Color:=byte(Color);
  P^.Align:=byte(Align);
  if (AbsNo) then P^.Opt:=$01;
  if (Save) then P^.Opt:=P^.Opt or $80;
  n:=length(s);
  if (n>sizeof(a)-sizeof(TSymbCellHeaderExt)) then n:=sizeof(a)-sizeof(TSymbCellHeaderExt);
  Move(Pointer(s)^, a[sizeof(TSymbCellHeaderExt)], n);
  n:=n+sizeof(TSymbCellHeaderExt);
  Result:=ExchangeCommandSimple(cmdSetSymbTextExt, @a, n);
  end;

function ctrlReadEEPROM(H:PEEDataBlockHeader; Data:pointer):integer;
  var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetEEPROM, H, sizeof(TEEDataBlockHeader), Data, H.PageCount*EXCH_EE_PG_SIZE, sz);
  end;

function ctrlWriteEEPROM(H:PEEDataBlockHeader; Data:pointer):integer;
 var a:array [0..4095] of byte;
     n:integer;
  begin
  FillChar(a, sizeof(a), 0);
  Move(H^, a, sizeof(TEEDataBlockHeader));
  n:=H.PageCount*EXCH_EE_PG_SIZE;
  Move(Data^, a[sizeof(TEEDataBlockHeader)], n);
  n:=n+sizeof(TEEDataBlockHeader);
  Result:=ExchangeCommandSimple(cmdSetEEPROM, @a, n);
  end;

function ctrlGetCellNoByRC(R,C:integer; var Cell:integer):integer;
 var a:array [0..15] of byte;
     b:array[0..3] of dword;
     sz:integer;
 begin
 a[0]:=byte(R);
 a[1]:=byte(C);
 Result:=ExchangeCommandData(cmdGetCellNoByRC,  @a, 2, @b, sizeof(dword), sz);
 if Result=ecOK then Cell:=integer(b[0])
                else Cell:=-1;
 end;

function ctrlGetExtLogoNumber(n:integer; var No:integer):integer;
 var a:array [0..15] of byte;
     b:array[0..3] of byte;
     sz:integer;
  begin
  a[0]:=byte(n);
  Result:=ExchangeCommandData(cmdGetExtLogoNumber,  @a, 1, @b, 1, sz);
  if Result=ecOK then No:=b[0]
                 else No:=-1;
  end;

function ctrlSetExtLogoNumber(DispIndex:integer; LogoNo:integer; Save, UpdateExt:boolean):integer;
 var a:array [0..15] of byte;
  begin
  a[0]:=byte(DispIndex);
  a[1]:=0;
  a[2]:=byte(LogoNo);
  if Save then a[1]:=a[1] or $01;
  if UpdateExt then a[1]:=a[1] or $02;
  Result:=ExchangeCommandSimple(cmdSetExtLogoNumber, @a, 3);
  end;

function ctrlSimpleTextOutSkip(P:PSimpleTextOutParams; s:Ansistring):integer;
 var a:array [0..4095] of byte;
     n:integer;
  begin
  Move(P^, a, sizeof(TSimpleTextOutParams));
  n:=length(s);
  if (n>sizeof(a)-sizeof(TSimpleTextOutParams)) then n:=sizeof(a)-sizeof(TSimpleTextOutParams);
  Move(Pointer(s)^, a[sizeof(TSimpleTextOutParams)], n);
//  for i:=0 to n-1 do a[sizeof(TOutTextParams)+i]:=a[sizeof(TOutTextParams)+i] and $7F;
  n:=n+sizeof(TSimpleTextOutParams);
  Result:=ExchangeCommandSimple(cmdOutTextSkip, @a, n);
  end;

function ctrlShowTabParameter(P:PSimpleTextOutParams):integer;
  begin
  Result:=ExchangeCommandSimple(cmdShowTabParameter, P, sizeof(TSimpleTextOutParams));
  end;

function ctrlSetNewDevAddress(NewAd:word; DevId:dword):integer;
 var S:TAddrSetCommand;
  begin
  FillChar(S, sizeof(S), 0);
  S.Password:=$39A1E8B2;
  if (DevId<$FFFF)
    then begin
         S.DevID:=DevId;
         S.Opts:=1;
         end;
  S.NewAddr:=NewAd;
  Result:=ExchangeCommandSimple(cmdSetNewDevAddress, @S, sizeof(TAddrSetCommand));
  end;

function ctrlSetSystemTime(ST:PSystemTime):integer;
  begin
  Result:=ExchangeCommandSimple(cmdSetSystemTime, ST, sizeof(TSystemTime));
  end;

function ctrlGetUserTunes(P:PUserTunes):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetUserTunes,  Nil, 0, P, sizeof(TUserTunes), sz);
  end;

function ctrlSetUserTunes(P:PUserTunes; Flags:integer):integer;
 var a:array [0..sizeof(TUserTunes)] of byte;
  begin
  a[0]:=Flags;
  Move(P^, a[1], sizeof(TUserTunes));
  Result:=ExchangeCommandSimple(cmdSetUserTunes, @a, sizeof(TUserTunes)+1);
  end;

function ctrlSetTempSensorCommand(P:PTempCtrlRec):integer;
  begin
  Result:=ExchangeCommandSimple(cmdSwapTempSensors, P, sizeof(TTempCtrlRec));
  end;

function ctrlClearRunTextBuffer(DispNo:dword; save:boolean):integer;
 var a:array [0..4] of byte;
  begin
  FillChar(a, sizeof(a), 0);
  a[0]:=byte(DispNo);
  if save then a[1]:=1;
  Result:=ExchangeCommandSimple(cmdClearRunTextBuffer, @a, 2);
  end;

type TStoreRunTextHeader=packed record
       DispNo:byte;
       Address:word;
       end;
PStoreRunTextHeader=^TStoreRunTextHeader;

function ctrlPlaceRunTextBuffer(DispNo, Address:dword; DataSize:dword; Data:pointer):integer;
 var a:array [0..2047] of byte;
     P:PStoreRunTextHeader;
     PB:PByte;
   begin
   if (DataSize>RecBuffSizeByte) then begin
                                      Result:=ecInvalidDataSize;
                                      Exit;
                                      end;
   P:=@a;
   P^.DispNo:=byte(DispNo);
   P^.Address:=word(Address);
   PB:=@a;
   inc(PB, sizeof(TStoreRunTextHeader));
   Move(Data^, PB^, DataSize);
   Result:=ExchangeCommandSimple(cmdPlaceRunTextBuffer, @a, sizeof(TStoreRunTextHeader)+DataSize);
   end;

type

TExtShortTextHeader=packed record
  DispNo:byte;
  Opts:byte;
  TextLen:word;
  H:TShortTextHeader;
  end;

function ctrlPlaceRunTextHeader(DispNo, TextLen:dword; H:PShortTextHeader; Save:boolean):integer;
 var EH:TExtShortTextHeader;
  begin
  EH.DispNo:=DispNo;
  if Save then EH.Opts:=1
          else EH.Opts:=0;
  EH.TextLen:=TextLen;
  EH.H:=H^;
  Result:=ExchangeCommandSimple(cmdPlaceRunTextHeader, @EH, sizeof(TExtShortTextHeader));
  end;

const cTextBlockSize=256;

function LoadTextData(DispNo, DataLen:dword; Data:pointer; Save:boolean; SH:PShortTextHeader; Progr:TLoadProgressProc):integer;
 var n, cnt:integer;
     sz, bsz, ad:dword;
     PB:PByte;
  begin
  PB:=Data;
  Result:=ctrlClearRunTextBuffer(DispNo, false);
  if Result<>ecOK then Exit;
  sz:=DataLen;
  cnt:=(sz+(cTextBlockSize-1)) div cTextBlockSize;
  n:=0;
  if (Assigned(Progr)) then Progr(0);
  ad:=0;
  while (n<cnt) do
    begin
    bsz:=sz;
    if (bsz>cTextBlockSize) then bsz:=cTextBlockSize;
    Result:=ctrlPlaceRunTextBuffer(DispNo, ad, bsz, PB);
    if Result<>ecOK then Exit;
    inc(ad, bsz);
    inc(PB, bsz);
    dec(sz, bsz);
    inc(n);
    if (Assigned(Progr)) then Progr(trunc(n/cnt*100));
    end;
  Result:=ctrlPlaceRunTextHeader(DispNo, DataLen, SH, Save);
  end;

function ctrlRestoreSavedTextBuffer(DispNo:dword; res:pdword):integer;
 var st:dword;
     sz:integer;
  begin
  Result:=ExchangeCommandData(cmdRestoreSavedTextBuffer,  @DispNo, 1, @st, sizeof(dword), sz);
  if (Result=ecOK) and (res<>Nil) then res^:=st;
   end;

function ctrlGetBrightParams(P:PBrightParams):integer;
 var sz:integer;
  begin
  Result:=ExchangeCommandData(cmdGetBrightParams,  Nil, 0, P, sizeof(TBrightParams), sz);
  end;

type TGetStructData=packed record
        StructNo:word;
        SubStructNo:word;
        ItemCount:byte;
        reserv:array[1..3] of byte;
        end;

     TSetStructData=packed record
        StructNo:word;
        SubStructNo:word;
        Flags:byte;
        reserv:array[1..3] of byte;
        Data:array[0..2047] of byte;
        end;

     PSetStructData=^TSetStructData;

     TSetStructDataHeader=packed record
        StructNo:word;
        SubStructNo:word;
        Flags:byte;
        reserv:array[1..3] of byte;
        end;

function ctrlGetStructure(structType, StructIndex:word; Buff:pointer; StructSize:integer; ItemCount:integer=1):integer;
  var D:TGetStructData;
      sz:integer;
  begin
  FillChar(D, sizeof(D), 0);
  D.StructNo:=structType;
  D.SubStructNo:=StructIndex;
  if (ItemCount>255) then ItemCount:=255
      else if ItemCount=0 then ItemCount:=1;
  D.ItemCount:=ItemCount;
  Result:=ExchangeCommandData(cmdGetStructure,  @D, sizeof(TGetStructData), Buff, StructSize*ItemCount, sz);
  end;

function ctrlSetStructure(structType, StructIndex:word; Buff:pointer; StructSize:integer; Save:boolean):integer;
  var a:array[0..2047] of byte;
      P:PSetStructData;
      sz:integer;
  begin
  FillChar(a, sizeof(a), 0);
  P:=@a;
  P^.StructNo:=structType;
  P^.SubStructNo:=StructIndex;
  if (Save) then P^.Flags:=1;
  Move(Buff^, P^.Data, StructSize);
  Result:=ExchangeCommandData(cmdSetStructure,  P, StructSize+sizeof(TSetStructDataHeader), Buff, 0, sz);
  end;

function ctrlSetStructureEx(structType, StructIndex:word; Buff:pointer; StructSize:integer; Flags:byte):integer;
  var a:array[0..2047] of byte;
      P:PSetStructData;
      sz:integer;
  begin
  FillChar(a, sizeof(a), 0);
  P:=@a;
  P^.StructNo:=structType;
  P^.SubStructNo:=StructIndex;
  P^.Flags:=Flags;
  Move(Buff^, P^.Data, StructSize);
  Result:=ExchangeCommandData(cmdSetStructure,  P, StructSize+sizeof(TSetStructDataHeader), Buff, 0, sz);
  end;

type TTimerStartData=packed record
  index:byte;
  flags:byte;
  tm:TMainTime;
  end;

function ctrlSetDayTimerByDate(index:byte; T:TSystemTime):integer;
 var MT:TTimerStartData;
  begin
  FillChar(MT, sizeof(MT), 0);
  MT.index:=index;
  MT.tm.Sec:=T.wSecond;
  MT.tm.Min:=T.wMinute;
  MT.tm.Hour:=T.wHour;
  MT.tm.Date:=T.wDay;
  MT.tm.Month:=T.wMonth;
  MT.tm.Year:=T.wYear mod 100;
  Result:=ExchangeCommandSimple(cmdStartDayTimerByDate, @MT, sizeof(MT));
  end;

function ctrlGetSensorValues(Index, Count:integer; Visible:boolean; buff:PSmallInt):integer;
  var a:array[0..3] of byte;
      sz:integer;
     begin
     a[0]:=Index and $3F;
     if (Visible) then a[0]:=a[0] or $80;
     a[1]:=byte(Count);
     Result:=ExchangeCommandData(cmdGetSensorValues, @a, 2, buff, Count*sizeof(smallint), sz);
     end;

function ctrlSetIntValues(itemType, itemIndex, itemCount:byte; Data:PInteger):integer;
 var a:array[0..1023] of byte;
     P:PIntValueSet;
     sz:integer;
  begin
  if (itemCount>48) then itemCount:=48;
  P:=@a;
  P^.itemType:=itemType;
  P^.itemIndex:=itemIndex;
  move(Data^, a[sizeof(TIntValueSet)],itemCount*sizeof(integer));
  Result:=ExchangeCommandData(cmdSetIntValues, @a, sizeof(TIntValueSet)+itemCount*sizeof(integer), Nil, 0, sz);
  end;

function ctrlGetIntValues(itemType, itemIndex, itemCount:byte; DataBuff:PInteger):integer;
 var D:TIntValueGet;
     sz:integer;
  begin
  D.itemType:=itemType;
  D.itemIndex:=itemIndex;
  D.itemCount:=itemCount;
  Result:=ExchangeCommandData(cmdGetIntValues,  @D, sizeof(TIntValueGet), DataBuff, sizeof(integer)*itemCount, sz);
  end;

function ctrlSegmentBinDataWrite(Col, Row, DataLen:integer; Data:pointer; AbsNo, CheckRange, Save:boolean):integer;
 var a:array [0..1023] of byte;
  begin
  if (DataLen>512) then DataLen:=512;
  FillChar(a, sizeof(a), 0);
  a[0]:=byte(Col);
  a[1]:=byte(Row);
  if AbsNo then a[2]:=a[2] or CELL_NUM_ABSOLUTE;
  if CheckRange then a[2]:=a[2] or CELL_NUM_CHECK_RANGE;
  if save then a[2]:=a[2] or CELL_FLAG_SAVE;
  Move(Data^, a[3], DataLen);
  Result:=ExchangeCommandSimple(cmdSegmentBinDataWrite, @a, DataLen+3);
  end;

function ctrlSegmentBinDataRead(Col, Row:integer; AbsNo, CheckRange:boolean; Data:pointer; var DataSize:integer):integer;
 var a:array [0..7] of byte;
  begin
  FillChar(a, sizeof(a), 0);
  a[0]:=byte(Col);
  a[1]:=byte(Row);
  if AbsNo then a[2]:=a[2] or CELL_NUM_ABSOLUTE;
  if CheckRange then a[2]:=a[2] or CELL_NUM_CHECK_RANGE;
  Result:=ExchangeCommandData(cmdSegmentBinDataRead,  @a, 3, Data, -1, DataSize);
  end;

initialization
WorkPort:=TComPort.Create(true, true);

finalization

WorkPort.Free;

end.
