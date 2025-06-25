unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TDemoForm = class(TForm)
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    SpinEdit2: TSpinEdit;
    Memo1: TMemo;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    SpinEdit3: TSpinEdit;
    Button4: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    SpinEdit4: TSpinEdit;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    SpinEdit5: TSpinEdit;
    Label4: TLabel;
    ComboBox1: TComboBox;
    Label5: TLabel;
    SpinEdit6: TSpinEdit;
    Label6: TLabel;
    Edit2: TEdit;
    Button5: TButton;
    GroupBox3: TGroupBox;
    SpinEdit7: TSpinEdit;
    Button6: TButton;
    CheckBox2: TCheckBox;
    GroupBox4: TGroupBox;
    Button1: TButton;
    CheckBox3: TCheckBox;
    Label7: TLabel;
    SpinEdit8: TSpinEdit;
    Label8: TLabel;
    SpinEdit10: TSpinEdit;
    Label9: TLabel;
    SpinEdit11: TSpinEdit;
    CheckBox4: TCheckBox;
    Label10: TLabel;
    SpinEdit9: TSpinEdit;
    GroupBox5: TGroupBox;
    Label11: TLabel;
    SpinEdit12: TSpinEdit;
    Label12: TLabel;
    SpinEdit13: TSpinEdit;
    CheckBox6: TCheckBox;
    SpinEdit14: TSpinEdit;
    SpinEdit15: TSpinEdit;
    Label13: TLabel;
    SpinEdit16: TSpinEdit;
    Label14: TLabel;
    SpinEdit17: TSpinEdit;
    SpinEdit18: TSpinEdit;
    Label15: TLabel;
    SpinEdit19: TSpinEdit;
    Label16: TLabel;
    SpinEdit20: TSpinEdit;
    Button7: TButton;
    CheckBox5: TCheckBox;
    CheckBox7: TCheckBox;
    Label17: TLabel;
    SpinEdit21: TSpinEdit;
    Label18: TLabel;
    SpinEdit22: TSpinEdit;
    SpinEdit23: TSpinEdit;
    Label19: TLabel;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    RadioButton3: TRadioButton;
    Edit3: TEdit;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    GroupBox6: TGroupBox;
    SpinEdit24: TSpinEdit;
    Label20: TLabel;
    SpinEdit25: TSpinEdit;
    Button11: TButton;
    GroupBox7: TGroupBox;
    SpinEdit26: TSpinEdit;
    Edit4: TEdit;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    GroupBox8: TGroupBox;
    Label21: TLabel;
    SpinEdit27: TSpinEdit;
    Label22: TLabel;
    SpinEdit28: TSpinEdit;
    Button17: TButton;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
  private
    Cycled:boolean;
    PackCount, ErrCount:dword;

    procedure AddPortData;
    procedure AddSendPortData;
    procedure ShowPortData;
    procedure ShowSendPortData;
    procedure AddUserText(s:string);
    { Private declarations }
  public
    { Public declarations }
  function CheckOpenPort:boolean;
  end;

var
  DemoForm: TDemoForm;

  aaa:dword;

implementation

uses DevTransp, GlbDecls, IniUnit, CommlibNew, AddFuncts;

{$R *.dfm}

{ TTestForm }

var WorkPortName:string;

function TDemoForm.CheckOpenPort: boolean;
begin
DestAddr:=SpinEdit2.Value;
if RadioButton1.Checked then WorkPortName:=StringToPortName('COM'+IntToStr(SpinEdit1.Value))
                        else begin
                             if RadioButton2.Checked then WorkPortName:=StringToPortName(Edit1.Text)
                                                     else WorkPortName:=StringToPortName(Edit3.Text);
//                             OpenPortExt( WorkPortName, RadioButton3.Checked, false, false, CheckBox8.Checked);
//                             WorkPort.UDPMode:=RadioButton3.Checked;
                             end;
//Result:=OpenPort;
Result:=OpenPortExt( WorkPortName, RadioButton3.Checked, false, false, CheckBox8.Checked);
if not Result then ErrMess('Ошибка открытия порта');
end;

procedure TDemoForm.Button10Click(Sender: TObject);
var ec:integer;
    E:TExtTabTunes;
begin
if not CheckOpenPort then Exit;
ec:=ctrlGetExtConfig(@E);
ShowPortData;
if ec=0 then AddUserText('Считано: '+IntToStr(E.Tunes.ClockType));
end;

procedure TDemoForm.Button11Click(Sender: TObject);
var C:TExtCommand;
    ok:boolean;
begin
if not CheckOpenPort then Exit;

FillChar(C, sizeof(C), 0);
C.Command:=1;
C.Params[0]:=SpinEdit25.Value;
C.Params[1]:=SpinEdit24.Value;
C.Params[2]:=2;

if CheckBox10.Checked then C.Params[2]:=C.Params[2] or $01;

ok:=ExecExternalCommand(@C)=ecOK;

//ok:=ctrlSetExtLogoNumber(SpinEdit25.Value,SpinEdit24.Value, true, true)=ecOK;
ShowPortData;
end;

procedure TDemoForm.Button12Click(Sender: TObject);
var ok:boolean;
    s:AnsiString;
begin
if not CheckOpenPort then Exit;
s:=Edit4.Text;
ok:=ctrlSetSymbText(SpinEdit26.Value, 0, true, true, s) =ecOK;
ShowPortData;
if not ok then ConnErrMess;
end;

procedure TDemoForm.Button13Click(Sender: TObject);
var ok:boolean;
    s:AnsiString;
begin
if not CheckOpenPort then Exit;
ok:=ctrlReadSymbText(SpinEdit26.Value,0, true,s) =ecOK;
if ok then Edit4.Text:=s;
ShowPortData;
if not ok then ConnErrMess;
end;

procedure TDemoForm.Button14Click(Sender: TObject);
var C:TExtCommand;
    ok:boolean;
begin
if not CheckOpenPort then Exit;
FillChar(C, sizeof(C), 0);
C.Command:=3;
C.Params[0]:=SpinEdit26.Value;
C.Params[1]:=2;
C.Params[2]:=10;
C.Params[3]:=250;
C.Params[4]:=0;
ok:=ExecExternalCommand(@C)=ecOK;
ShowPortData;
end;

procedure TDemoForm.Button15Click(Sender: TObject);
var C:TExtCommand;
    ok:boolean;
begin
if not CheckOpenPort then Exit;
FillChar(C, sizeof(C), 0);
C.Command:=3;
C.Params[0]:=SpinEdit26.Value;
C.Params[1]:=2;
C.Params[2]:=0;
C.Params[3]:=250;
C.Params[4]:=0;
ok:=ExecExternalCommand(@C)=ecOK;
ShowPortData;
end;

procedure TDemoForm.Button16Click(Sender: TObject);
var P:TSimpleTextOutParams;
    s:Ansistring;
    sz, aaa:integer;
begin
//text out
if not CheckOpenPort then Exit;
FillChar(P, sizeof(P), 0);
P.DispNo:=SpinEdit4.Value;
if RadioButton5.Checked then P.DispNo:=P.DispNo or $80
                        else if RadioButton6.Checked then P.DispNo:=P.DispNo or $40;
P.Font:=SpinEdit5.Value;
P.Color:=SpinEdit8.Value;
if CheckBox1.Checked then P.Opt:=P.Opt or $80;
if CheckBox4.Checked then P.Opt:=P.Opt or $01;
P.Align:=ComboBox1.ItemIndex;
P.Speed:=SpinEdit6.Value;
if CheckBox9.Checked then P.Speed:=P.Speed or $80;
P.EffNo:=SpinEdit9.Value;
s:=Edit2.Text;
aaa:=ctrlSimpleTextOutSkip(@P, s);
ShowPortData;
end;

procedure TDemoForm.Button17Click(Sender: TObject);
var ok:boolean;
begin
if not CheckOpenPort then Exit;
aaa:=ctrlSetNewDevAddress(SpinEdit27.Value, dword(SpinEdit28.Value));
ShowPortData;
end;

procedure TDemoForm.Button1Click(Sender: TObject);
var ok, cycl:boolean;
    s:string;
begin
if not CheckOpenPort then Exit;
PackCount:=0;
ErrCount:=0;
cycl:=Cycled;
if cycl then Button1.Visible:=false;
repeat
ok:=CheckConnect=ecOK;
if Cycled then begin
               if (PackCount<dword(MaxInt)) then inc(PackCount);
               if not ok  and (ErrCount<dword(MaxInt)) then inc(ErrCount);
               s:='Пакетов: '+IntToStr(PackCount)+#13#10+
                  'Ошибок: '+IntToStr(ErrCount)+#13#10;
               Memo1.Text:=s;   
               Application.ProcessMessages
               end;
until not Cycled;
if not cycl then ShowPortData;
Button1.Visible:=true;
Button1.SetFocus;
end;

procedure TDemoForm.SpinEdit1Change(Sender: TObject);
begin
ClosePort;
end;

procedure TDemoForm.AddPortData;
var s:string;
begin
s:='Отправлено: '+WorkPort.LastSendHex+#13#10;
s:=s+'Получено:     '+WorkPort.LastRecHex+#13#10;
Memo1.Text:=Memo1.Text+s;
end;

procedure TDemoForm.AddSendPortData;
var s:string;
begin
s:='Отправлено: '+WorkPort.LastSendHex+#13#10;
Memo1.Text:=Memo1.Text+s;
end;

procedure TDemoForm.AddUserText(s: string);
begin
Memo1.Text:=Memo1.Text+#13#10+s;
end;

procedure TDemoForm.ShowPortData;
begin
 Memo1.Text:='';
 AddPortData;
end;

procedure TDemoForm.ShowSendPortData;
begin
 Memo1.Text:='';
 AddSendPortData;
end;


procedure TDemoForm.RadioButton1Click(Sender: TObject);
begin
ClosePort;
end;

procedure TDemoForm.FormCreate(Sender: TObject);
begin
ReadIniFile(Ini);
end;

procedure TDemoForm.FormDestroy(Sender: TObject);
begin
WriteIniFile(Ini);
end;

procedure TDemoForm.FormShow(Sender: TObject);
begin
Left:=Ini.Position.Left;
Top:=Ini.Position.Top;
RadioButton1.Checked:=Ini.Options=0;
RadioButton2.Checked:=Ini.Options=1;
RadioButton3.Checked:=Ini.Options=2;
SpinEdit1.Value:=Ini.PortNum;
Edit1.Text:=StringToPortName(Ini.TCPPort);
Edit3.Text:=StringToPortName(Ini.UDPPort);
Edit2.Text:=Ini.Data;
SpinEdit2.Value:=Ini.Id;
end;

procedure TDemoForm.FormHide(Sender: TObject);
begin
Ini.Position:=BoundsRect;
if RadioButton2.Checked then Ini.Options:=1
  else if RadioButton1.Checked then Ini.Options:=0
                        else Ini.Options:=2;
Ini.PortNum:=SpinEdit1.Value;
Ini.Id:=SpinEdit2.Value;
Ini.TCPPort:=StringToPortName(Edit1.Text);
Ini.UDPPort:=StringToPortName(Edit3.Text);
Ini.Data:=Edit2.Text;
end;

procedure TDemoForm.Button4Click(Sender: TObject);
begin
if not CheckOpenPort then Exit;
aaa:=ctrlSetBright(SpinEdit3.Value);
ShowPortData;
end;

procedure TDemoForm.Button2Click(Sender: TObject);
var ST:TSystemTime;
begin
if not CheckOpenPort then Exit;
GetLocalTime(ST);
aaa:=ctrlSetTime(ST);
ShowPortData;
end;

procedure TDemoForm.Button3Click(Sender: TObject);
var ST:TSystemTime;
    ec:integer;
begin
if not CheckOpenPort then Exit;
ec:=ctrlGetTime(ST);
ShowPortData;
if ec=0 then AddUserText('Считано: '+TimeStampString(ST, true));
end;

procedure TDemoForm.Button5Click(Sender: TObject);
var P:TSimpleTextOutParams;
    s:Ansistring;
//    DataBuff:pointer;
    sz:integer;
begin
//text out
if not CheckOpenPort then Exit;
FillChar(P, sizeof(P), 0);
P.DispNo:=SpinEdit4.Value;
if RadioButton5.Checked then P.DispNo:=P.DispNo or $80
                        else if RadioButton6.Checked then P.DispNo:=P.DispNo or $40;
P.Font:=SpinEdit5.Value;
P.Color:=SpinEdit8.Value;
if CheckBox1.Checked then P.Opt:=P.Opt or $80;
if CheckBox4.Checked then P.Opt:=P.Opt or $01;
P.Align:=ComboBox1.ItemIndex;
P.Speed:=SpinEdit6.Value;
if CheckBox9.Checked then P.Speed:=P.Speed or $80;
P.EffNo:=SpinEdit9.Value;
P.EffCount:=SpinEdit10.Value;
P.EffTime:=SpinEdit11.Value;
s:=Edit2.Text;
if s='' then s:=' ';
sz:=length(s);
aaa:=ctrlSimpleDataOut(@P, PAnsiChar(s), sz);
ShowPortData;
end;

//0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras
//0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras
//0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$$%&0qweras
procedure TDemoForm.Button6Click(Sender: TObject);
begin
if not CheckOpenPort then Exit;
aaa:=ctrlSetTestMode(SpinEdit7.Value, CheckBox2.Checked);
ShowPortData;
end;

function AddEffect(PE:PEffParams; EffNo, EffCount, EffSpeed,  EffPause:byte; EffOpt:byte):boolean;
   begin
   Result:=(EffNo>0);
   if Result then begin
                  PE^.EffNo:=EffNo;
                  PE^.EffSpeed:=EffSpeed;
                  PE^.EffCount:=EffCount;
                  PE^.EffPause:=EffPause;
                  PE^.EffOpt:=EffOpt;
                  end;
   end;

procedure TDemoForm.Button7Click(Sender: TObject);
var P:TExtParams;
    ecnt, HeadSize:integer;
    PH:PTextHeader;
    PE:PEffParams;
    s:ansistring;
    a:array[0..4095] of byte;
    opt:byte;
//    DataBuff:Pointer;
    sz:integer;
begin
//out text with several effects
if not CheckOpenPort then Exit;
if ctrlGetExtParams(@P)<>ecOk
   then begin
        ShowPortData;
        Exit;
        end;
FillChar(a, sizeof(a),0);
PH:=@a;
//PH^.Signature:=TextSign;
PH^.Font:=SpinEdit5.Value;
PH^.Color:=SpinEdit8.Value;
PH^.Align:=ComboBox1.ItemIndex;
PH^.Speed:=SpinEdit6.Value;
if CheckBox9.Checked then PH^.Speed:=PH^.Speed or $80;
if CheckBox1.Checked then PH^.Opt:=PH^.Opt or $80;
//if CheckBox4.Checked then PH^.Opt:=PH^.Opt or $01;
PE:=@PH^.Pars[0];
ecnt:=0;
if AddEffect(PE, SpinEdit14.Value, SpinEdit12.Value, SpinEdit13.Value, SpinEdit21.Value, byte(CheckBox6.Checked))
   then begin
        PH^.EffMask:=PH^.EffMask or (1 shl ecnt);
        inc(ecnt);
        inc(PE);
        end;
if AddEffect(PE, SpinEdit15.Value, SpinEdit16.Value, SpinEdit17.Value, SpinEdit22.Value, byte(CheckBox5.Checked))
   then begin
        PH^.EffMask:=PH^.EffMask or (1 shl ecnt);
        inc(ecnt);
        inc(PE);
        end;
if AddEffect(PE, SpinEdit18.Value, SpinEdit19.Value, SpinEdit20.Value, SpinEdit23.Value, byte(CheckBox7.Checked))
   then begin
        PH^.EffMask:=PH^.EffMask or (1 shl ecnt);
        inc(ecnt);
        inc(PE);
        end;
HeadSize:=sizeof(TTextHeaderA)+sizeof(TEffParams)*P.MaxEffCount;
s:=Edit2.Text;
if s='' then s:=' ';
sz:=Length(s);

opt:=0;
if CheckBox1.Checked then Opt:=Opt or $80;

aaa:=ctrlExtDataOut(SpinEdit4.Value, opt, PH, HeadSize, PAnsiChar(s), sz);
ShowPortData;
end;

procedure TDemoForm.Button8Click(Sender: TObject);
begin
//Edit2.Text:='{[Speed:1]}Медленно  {[Speed:5]}Быстро';
Edit2.Text:='{[a]}{[Eff:5,5,1,2]}AAA{[SP:0]}{[a]}{[Eff:5,5,1,2]}BBB';
end;

procedure TDemoForm.Button9Click(Sender: TObject);
//var P:TSimpleTextOutParams;
begin
//text out
if not CheckOpenPort then Exit;
aaa:=ctrlClearRunTextBuffer(SpinEdit4.Value, CheckBox1.Checked);
//aaa:=ctrlClearRunTextBuffer($FF, false);
ShowPortData;
end;

procedure TDemoForm.CheckBox3Click(Sender: TObject);
begin
Cycled:=CheckBox3.Checked;
end;

procedure TDemoForm.CheckBox8Click(Sender: TObject);
begin
ClosePort;
end;

end.
