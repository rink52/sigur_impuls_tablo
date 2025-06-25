unit AddUnit;

interface
uses Windows;

function DataToHex(const Data; DataLen:integer; spacer:string=''; pref:string=''):string;

implementation
uses SysUtils;

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

end.
