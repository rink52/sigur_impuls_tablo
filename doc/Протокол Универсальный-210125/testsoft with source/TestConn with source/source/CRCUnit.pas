unit CRCUnit;

interface

//function  CalcCRC16(Data:pointer; DataSize:integer):integer;
function  CalcCRC8(Data:pointer; Count:integer):byte;
procedure CountCSNewW(Data:pointer; Count:integer; var cs:word);
//procedure CountCSNew(Data:pointer; Count:integer; var cslo, cshi:byte);

function CalcCRC(Data:pointer; DataSize:integer):integer;

function CalcDowCRC16(var X; Sz:integer; inv:boolean=false):integer;

implementation
uses Windows, Protocol;

const crc16_tablo:array[0..255] of byte=
(
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$000, $0c1, $081, $040, $001, $0c0, $080, $041,
$001, $0c0, $080, $041, $000, $0c1, $081, $040
);

crc16_tabhi:array[0..255] of byte=
(
$000, $0c0, $0c1, $001, $0c3, $003, $002, $0c2,
$0c6, $006, $007, $0c7, $005, $0c5, $0c4, $004,
$0cc, $00c, $00d, $0cd, $00f, $0cf, $0ce, $00e,
$00a, $0ca, $0cb, $00b, $0c9, $009, $008, $0c8,
$0d8, $018, $019, $0d9, $01b, $0db, $0da, $01a,
$01e, $0de, $0df, $01f, $0dd, $01d, $01c, $0dc,
$014, $0d4, $0d5, $015, $0d7, $017, $016, $0d6,
$0d2, $012, $013, $0d3, $011, $0d1, $0d0, $010,
$0f0, $030, $031, $0f1, $033, $0f3, $0f2, $032,
$036, $0f6, $0f7, $037, $0f5, $035, $034, $0f4,
$03c, $0fc, $0fd, $03d, $0ff, $03f, $03e, $0fe,
$0fa, $03a, $03b, $0fb, $039, $0f9, $0f8, $038,
$028, $0e8, $0e9, $029, $0eb, $02b, $02a, $0ea,
$0ee, $02e, $02f, $0ef, $02d, $0ed, $0ec, $02c,
$0e4, $024, $025, $0e5, $027, $0e7, $0e6, $026,
$022, $0e2, $0e3, $023, $0e1, $021, $020, $0e0,
$0a0, $060, $061, $0a1, $063, $0a3, $0a2, $062,
$066, $0a6, $0a7, $067, $0a5, $065, $064, $0a4,
$06c, $0ac, $0ad, $06d, $0af, $06f, $06e, $0ae,
$0aa, $06a, $06b, $0ab, $069, $0a9, $0a8, $068,
$078, $0b8, $0b9, $079, $0bb, $07b, $07a, $0ba,
$0be, $07e, $07f, $0bf, $07d, $0bd, $0bc, $07c,
$0b4, $074, $075, $0b5, $077, $0b7, $0b6, $076,
$072, $0b2, $0b3, $073, $0b1, $071, $070, $0b0,
$050, $090, $091, $051, $093, $053, $052, $092,
$096, $056, $057, $097, $055, $095, $094, $054,
$09c, $05c, $05d, $09d, $05f, $09f, $09e, $05e,
$05a, $09a, $09b, $05b, $099, $059, $058, $098,
$088, $048, $049, $089, $04b, $08b, $08a, $04a,
$04e, $08e, $08f, $04f, $08d, $04d, $04c, $08c,
$044, $084, $085, $045, $087, $047, $046, $086,
$082, $042, $043, $083, $041, $081, $080, $040
);

function CalcDowCRC16(var X; Sz:integer; inv:boolean=false):integer;
 var i:integer;
     P:PByte;
     nrh, nrl, rh, rl,ind:integer;
  begin
  if (inv) then begin
                rh:=$FF;
                rl:=$FF;
                end
           else begin
                rh:=0;
                rl:=0;
                end;
  P:=@X;
  for i:=1 to Sz do begin
                    ind:=rl xor P^;
                    nrh:=crc16_tabhi[ind];
                    nrl:=crc16_tablo[ind] xor rh;
                    rh:=nrh;
                    rl:=nrl;
                    inc(P);
                    end;
  Result:=rh shl 8 +rl;
  end;

(*
function CalcCRC16(Data:pointer; DataSize:integer):integer;
 var P:PByte;
     i:integer;
     cs1, cs2:integer;
     pw:PWord;
  begin
  P:=Data;
  cs1:=0;
  for i:=1 to DataSize do
    begin
    cs1:=(cs1+P^) and $FFFF;
    inc(P);
    end;
  cs2:=CalcDowCRC16(Data^, DataSize);
  PW:=@Result;
  PW^:=cs2;
  inc(PW);
  PW^:=cs1;
  end;
*)

const CrcTable:array[0..255] of byte=(
        0,  94, 188, 226,  97,  63, 221, 131, 194, 156, 126,  32, 163, 253,  31,  65,
      157, 195,  33, 127, 252, 162,  64,  30,  95,   1, 227, 189,  62,  96, 130, 220,
       35, 125, 159, 193,  66,  28, 254, 160, 225, 191,  93,   3, 128, 222,  60,  98,
      190, 224,   2,  92, 223, 129,  99,  61, 124,  34, 192, 158,  29,  67, 161, 255,
       70,  24, 250, 164,  39, 121, 155, 197, 132, 218,  56, 102, 229, 187,  89,   7,
      219, 133, 103,  57, 186, 228,   6,  88,  25,  71, 165, 251, 120,  38, 196, 154,
      101,  59, 217, 135,   4,  90, 184, 230, 167, 249,  27,  69, 198, 152, 122,  36,
      248, 166,  68,  26, 153, 199,  37, 123,  58, 100, 134, 216,  91,   5, 231, 185,
      140, 210,  48, 110, 237, 179,  81,  15,  78,  16, 242, 172,  47, 113, 147, 205,
       17,  79, 173, 243, 112,  46, 204, 146, 211, 141, 111,  49, 178, 236,  14,  80,
      175, 241,  19,  77, 206, 144, 114,  44, 109,  51, 209, 143,  12,  82, 176, 238,
       50, 108, 142, 208,  83,  13, 239, 177, 240, 174,  76,  18, 145, 207,  45, 115,
      202, 148, 118,  40, 171, 245,  23,  73,   8,  86, 180, 234, 105,  55, 213, 139,
       87,   9, 235, 181,  54, 104, 138, 212, 149, 203,  41, 119, 244, 170,  72,  22,
      233, 183,  85,  11, 136, 214,  52, 106,  43, 117, 151, 201,  74,  20, 246, 168,
      116,  42, 200, 150,  21,  75, 169, 247, 182, 232,  10,  84, 215, 137, 107,  53
);

function CalcCRC8(Data:pointer; Count:integer):byte;
var i:integer;
    PB:PByte;
begin
Result:=0;
PB:=Data;
for i:=0 to Count-1 do
  begin
  Result:=CrcTable[Result xor PB^];
  inc(PB);
  end;
end;

procedure CountCSNew(Data:pointer; Count:integer; var cslo, cshi:byte);
var i, cs1, cs2:integer;
    PB:PByte;
begin
cs1:=cslo;
cs2:=cshi;
PB:=Data;
for i:=0 to Count-1 do
  begin
  cs1:=CrcTable[cs1 xor PB^];
  cs2:=(cs2 + not PB^) and $FF;
  inc(PB);
  end;
cslo:=cs1;  
cshi:=cs2;
end;

procedure CountCSNewW(Data:pointer; Count:integer; var cs:word);
var i, cs1, cs2:integer;
    PB:PByte;
begin
cs1:=0;//Lo(cs);
cs2:=0;//Hi(cs);
PB:=Data;
for i:=0 to Count-1 do
  begin
  cs1:=CrcTable[cs1 xor PB^];
  cs2:=(cs2 + not PB^) and $FF;
  inc(PB);
  end;
cs1:=cs1 xor CRC_XOR_LO;
cs2:=cs2 xor CRC_XOR_HI;
cs:=word(256*cs2+cs1);
end;

function CalcCRC(Data:pointer; DataSize:integer):integer;
 var P:PByte;
     i:integer;
     cs1, cs2:integer;
     pw:PWord;
  begin
  P:=Data;
  cs1:=0;
  for i:=1 to DataSize do
    begin
    cs1:=(cs1+P^) and $FFFF;
    inc(P);
    end;
  cs2:=CalcDowCRC16(Data^, DataSize);
  PW:=@Result;
  PW^:=cs2;
  inc(PW);
  PW^:=cs1;
  end;


end.
