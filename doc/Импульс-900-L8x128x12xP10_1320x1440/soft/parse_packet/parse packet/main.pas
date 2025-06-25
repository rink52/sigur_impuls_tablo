unit main;

{$DEFINE FOR_CLIENTS}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ConnTypes;

const RecBuffSizeByte=2048;


type

  TMainInfoForm = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

  Data:array[0..RecBuffSizeByte-1] of byte;
  DataLen:integer;
  RecStage, InLen, RecPtr:integer;
  BlockSize:integer;

  RecData:array[0..RecBuffSizeByte-1] of byte;
  BlockReady:boolean;
  RecPacket:TLevel2Pack;

  NeedCS, OrgCS:word;

  procedure PutData(dt: byte);

  public
    { Public declarations }
  end;

var MainInfoForm: TMainInfoForm;

implementation

uses IniUnit, CRCUnit, AddUnit;

{$R *.DFM}

procedure TMainInfoForm.FormCreate(Sender: TObject);
begin
ReadIniFile(Ini);
Edit1.Text:=Ini.Data;
end;

procedure TMainInfoForm.FormDestroy(Sender: TObject);
begin
WriteIniFile(Ini);
end;

procedure TMainInfoForm.FormHide(Sender: TObject);
begin
Ini.Data:=trim(Edit1.Text);
end;

procedure TMainInfoForm.Button1Click(Sender: TObject);
var lb, ok:boolean;
    i, n, v:integer;
    s:string;
    c:char;
begin
lb:=false;
DataLen:=0;
v:=0;
s:=AnsiUpperCase(Edit1.Text);
n:=length(s);
FillChar(Data, sizeof(Data), 0);
for i:=1 to n do
  begin
  c:=s[i];
  if (c>='0') and (c<='9')
     then begin
          ok:=true;
          v:=ord(c)-ord('0');
          end
     else if (c>='A') and (c<='F')
            then begin
                 ok:=true;
                 v:=ord(c)-ord('A')+10;
                 end
          else ok:=false;
  if ok then begin
             if lb then begin
                        Data[Datalen]:=Data[Datalen] or (v and $0F);
                        inc(Datalen);
                        end
                   else begin
                        Data[Datalen]:=Data[Datalen] or ((v*16) and $F0);
                        end;
             lb:=not lb;
             end;
  end;
//Memo1.Text:=DataToHex(Data, DataLen,' ');
RecStage:=0;
RecPtr:=0;
BlockReady:=false;
BlockSize:=0;
for i:=0 to Datalen-1 do
  begin
  PutData(Data[i]);
  end;
Memo1.Lines.Add('---------------------------------');
if BlockReady
 then begin
Memo1.Lines.Add('sender addr = 0x'+IntToHex(RecPacket.SrcAddr, 4));
Memo1.Lines.Add('receiver addr = 0x'+IntToHex(RecPacket.DstAddr, 4));
Memo1.Lines.Add('id = 0x'+IntToHex(RecPacket.PId, 2));
Memo1.Lines.Add('cmd = 0x'+IntToHex(RecPacket.Cmd, 2));
Memo1.Lines.Add('flags = 0x'+IntToHex(RecPacket.Flags, 2));
Memo1.Lines.Add('status = 0x'+IntToHex(RecPacket.Status, 2));
Memo1.Lines.Add('datalen = '+IntToStr(RecPacket.DataLen));
if RecPacket.DataLen>0
  then begin
       s:=DataToHex(RecPacket.Data, RecPacket.DataLen,' ', '0x');
       Memo1.Lines.Add('data['+IntToStr(RecPacket.DataLen)+'] = '+s);
       end;
     end
 else begin
      Memo1.Lines.Add('Packet error');
      Memo1.Lines.Add('Waiting length of L2 packed '+IntToStr(InLen));
      Memo1.Lines.Add('Received length of L2 packed '+IntToStr(RecPtr-2));

      Memo1.Lines.Add('Wait cs = 0x'+IntToHex(NeedCS, 4));
      Memo1.Lines.Add('cs in packet = 0x'+IntToHex(OrgCS, 4));
      end;
end;

procedure TMainInfoForm.Button2Click(Sender: TObject);
begin
Memo1.Text:='';
end;

procedure TMainInfoForm.PutData(dt: byte);
var P:PByte;
    cs:word;
begin
if (dt=$02) then begin
                  RecStage:=1;
                  RecPtr:=0;
                  Exit;
                  end;
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
                    NeedCS:=cs;
                    OrgCS:=Pword(P)^;
                    if (Pword(P)^=cs) then begin
//                                           if (PLevel2Head(@RecData)^.Status = $80)
//                                             then begin
                                                  BlockSize:=InLen;
                                                  Move(RecData, RecPacket, BlockSize);
                                                  BlockReady:=true;
//                                                  PrevCmd:=PLevel2Head(@RecData)^.Cmd;
//                                                  PrevId:=PLevel2Head(@RecData)^.PId;
//                                                  end;
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
end;

end.
