unit ConnTypes;

interface

const
     RecBuffSizeByte=1024;

type

TLevel2Pack=packed record
  SrcAddr:word; //source address
  DstAddr:word; //receiver address
  PId:byte;     //Packet id
  Cmd:byte;   // Command code
  Flags:byte;  //options
  Status:byte; //command status
  DataLen:word; //length of data
  Data:array[0..RecBuffSizeByte-1] of byte;  //data
  end;

PLevel2Pack=^TLevel2Pack;

TLevel2Head=packed record
  SrcAddr:word; //source address
  DstAddr:word; //receiver address
  PId:byte;     //Packet id
  Cmd:byte;   // Command code
  Flags:byte;  //options
  Status:byte; //command status
  DataLen:word; //length of data
  end;
PLevel2Head=^TLevel2Head;

TFullPacket=packed record
  bSTX:byte;
  LenLo:byte;
  LenHi:byte;
  Data:array[0..RecBuffSizeByte*2-1+32] of byte;
  end;
  
PFullPacket=^TFullPacket;

function MakeFullPacket(Src:PLevel2Pack; Dst:Pointer):integer;
function EncodeWord(v:word):word;

implementation

uses CRCUnit;

function CS2word(cslo, cshi:byte):word;
var b:PByte;
begin
Result:=0;
b:=@Result;
b^:=cslo or $80;
inc(b);
b^:=$80 or ((cslo shr 7) and $01) or ((cshi and $3F) shl 1);
end;

function EncodeWord(v:word):word;
begin
Result:=((v and $3F80) shl 1) or (v and $7F) or $8080;
end;

function DecodeWord(v:word):word;
begin
Result:=((v and $7F00) shr 1) or (v and $7F);
end;

function EncodeDataForComm(Src, Dst:Pointer; SrcSize:integer):integer;
 var PS, PD:PByte;
     i:integer;
     b:byte;
  begin
  PS:=Src;
  PD:=Dst;
  Result:=0;
  for i:=1 to SrcSize do
    begin
    b:=PS^ xor $80;
    if (b<$20) or (b=$7F)
       then begin
            PD^:=$7F;
            inc(PD);
            PD^:=b or $80;
            inc(Result);
            end
       else PD^:=b;
    inc(PS);
    inc(PD);
    inc(Result);
    end;
  end;

function MakeFullPacket(Src:PLevel2Pack; Dst:Pointer):integer;
var cs:word;
    PB:PByte;
    F:PFullPacket;
    PackLen:word;
    PackSize:integer;
  begin
  PB:=Dst;
  F:=Dst;
  cs:=0;
  PackLen:=word(Src^.DataLen+sizeof(TLevel2Head));
  CountCSNewW(Src, PackLen, cs);
  F^.bSTX:=$02;
  PWord(@F^.LenLo)^:=EncodeWord(PackLen);
  inc(PB, 3);// add bSTX, LenLo, LenHi
  PackSize:=EncodeDataForComm(Src, PB, PackLen);
  inc(PB, PackSize);
  PWord(PB)^:=EncodeWord(cs);
  inc(PB, 2); // add CsLo, CsHi
  PB^:=$03;
  Result:=PackSize+6;
  end;

end.
