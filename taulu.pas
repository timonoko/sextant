
{$P256}

program sextant(input,output);
 type regpack =  record
                  AX,BX,CX,DX,BP,DI,SI,DS,ES,Flags:integer;
                  end;
      filename=string[20];
      longstr = string[200];

var
  regs:regpack;
  Day_NOW,Year_NOW,Month_NOW,
  hour_NOW,min_NOW,sec_NOW,tick_NOW,sec_was,timezone:integer;
  d: integer;
  R0,R1,Dec0,Dec1,Dec2,Dec3,Dec4,E0,E1,E2,E3,E4,SD0,SD1 :real;
  R,Dec,E,SD,GHA_Aries,GHA_Sun,azimuth :real;

procedure txtmode;
begin
 with regs do begin
   AX:=$0003;
   intr($10,regs);
 end;
end;


procedure Time;
begin
 with regs do begin
   AX:=$2C00;
   msdos(regs);
   hour_NOW:=hi(CX);
   min_NOW:=lo(CX);
   sec_NOW:=hi(DX);
   tick_NOW:=lo(DX);
 end;
end;


procedure date;
begin
 with regs do begin
   AX:=$2A00;
   msdos(regs);
   day_NOW:=lo(DX);
   month_NOW:=hi(DX);
   year_NOW:=CX;
 end;
end;

function getkey:char;
begin
 with regs do begin
   AX:=$0600;
   DX:=$FF;
   msdos(regs);
   getkey:=chr(lo(AX));
 end;
end;


function rad(x:real):real;
  begin
    rad:=x/180*pi;
  end;

function degrees(x:real):real;
  begin
    degrees:=x*180/pi;
  end;

function mod360(x:real):real;
 begin
  if x<0 then mod360:=mod360(x+360)
  else if x>360 then mod360:=mod360(x-360)
  else mod360:=x
 end;

function expt (x:real;y:integer):real;
  begin
   if y=0 then expt:=1
   else  expt:=x*expt(x,y-1)
 end;

function arcsin(x:real):real;
 begin
  arcsin:=arctan(x/sqrt(1-x*x))
 end;

function arccos(x:real):real;
 begin
  arccos:=arctan(sqrt(1-x*x)/x)
 end;

procedure load_coef(month:integer);
 var  f:text; Month_Number:integer;
begin
   assign(f,'newdata.dat');
   reset(f);
   repeat
    readln(f,Month_number,R0,R1,Dec0,Dec1,Dec2,Dec3,Dec4,E0,E1,E2,E3,E4,SD0,SD1);
   until (Month_number=month) or eof(f);
   if eof(f) then begin
       writeln('datafile non-existent or insufficient')
       end;
   close(f);
end;

function H_calcu(GHA,DEC,Lat,Long:real):real;
 var Hc,LHA,S,C,X,A:real;
 begin
  LHA := mod360(GHA+Long);
  S := sin(rad(DEC));
  C := cos(rad(DEC)) * cos(rad(LHA));
  Hc := degrees(arcsin(S * sin(rad(Lat)) + C*cos(rad(Lat))));
  X := (S*cos(rad(Lat)) - C*sin(rad(Lat))) / cos(rad(Hc));
  if X>1 then X:=1
  else if X<-1 then X:=-1;
   A :=  degrees(arccos(X));
  if A>0 then A:=A-180;
  if LHA > 180 then azimuth := A else aZimuth:=-A;
 azimuth:=mod360(azimuth-180);
  H_calcu:=Hc;
 end;

procedure GHADECSEMI(month,day,hour,min,sec:integer);
var x,UT:real;
begin
 load_coef(month);
 UT:=hour+min/60+sec/3600;
		x := (day + UT/24)/32;
                R := R0   + R1*x;
              Dec := Dec0 + (Dec1 + (Dec2 + (Dec3 + Dec4*x)*x)*x)*x;
                E := E0 + (E1 + (E2 + (E3 + E4*x)*x)*x)*x;
               SD := SD0  + SD1*x;
             GHA_Aries := R + UT;
             GHA_Sun   := E + UT;
end;

procedure wrdecmin(x:real);
begin
 if x<0 then begin x:=-x;write('-') end;
 write(trunc(x),'ø',60*(x-trunc(x)):2:0,'ï');
end;

procedure Taulu(kk,pv1,pvm,ker:integer;lat,long:real);
 var pv,tn,t1:integer;
 begin
  writeln;  writeln;
  write('Auringon alareunan');
  if ker=2 then write(' 2-kertanen');
  write(' korkeus ',kk,'-kuussa  @ ');
   wrdecmin(lat);write('N ');wrdecmin(long);write('E ');
   writeln; writeln;
   write(' Kello:');
   for t1:= 3 to 10 do write('	  ',t1*2);
   writeln;
   Writeln('P„iv„');
   for pv:=pv1 to pv1+pvm do begin
    write('  ',pv,':');
        for t1:=3 to 10 do begin
         tn:=t1*2;
         GHADECSEMI(kk,pv,tn-timezone,0,0);
	 write('	');
             wrdecmin(ker*(H_calcu(GHA_sun*15,dec,lat,long)-SD));
        end;
    writeln
  end;
  end;

(*
procedure testeja;
begin
 repeat
 date; time; sec_was:=sec_now;
   repeat time until sec_Now<>sec_was;
   GHADECSEMI(month_NOW,day_NOW,hour_NOW-3,min_NOW,sec_NOW);
   Write(hour_now-3,':',min_NOW,':',sec_NOW,'               ');
    wrdecmin(H_calcu(GHA_sun*15,dec,60,25)); wrdecmin(azimuth);
   writeln;
  until keypressed
end;

procedure work;
 var lat,long,abba:real; f:text; ch:char;
begin
   assign(f,'this.fix');
   reset(f); readln(f,lat,long); close (f);
   if lat=0 then begin write('lat,long:');readln(lat,long) end;
   repeat
    date; time;
    GHADECSEMI(month_NOW,day_NOW,hour_NOW-3,min_NOW,sec_NOW);
    Write(hour_now,':',min_NOW,':',sec_NOW,' '); write(' ');
     wrdecmin(2*(H_calcu(GHA_sun*15,dec,lat,long)-SD)); write('   ');
     wrdecmin(lat); write(' ');  wrdecmin(long); write(' ');
     wrdecmin(azimuth); writeln;
    repeat ch:=getkey until ord( cH)>0;
    abba:=rad(azimuth);
    case ch of
     '+': begin lat:=lat+0.01*cos(abba); long:=long+0.01*sin(abba) end;
     '-':  begin lat:=lat-0.01*cos(abba); long:=long-0.01*sin(abba) end;
    end;
   until ch='q';
  rewrite(f);writeln(f,lat,long);close(f);
  end;
*)

procedure inputti;
 var lat,latmin,long,longmin:real;kk,pv,pvm,ker:integer;keino:char;
begin
 Write(trm,'Pohjosta Leveytt„ (esim: 60 11.5 )?:'); readln(lat,latmin);
 Write(trm,'It„ist„ Pituutta (esim: 24 50.3 )?:');
 readln(long,longmin);
 write(trm,'Aikavy”hyke (suomessa kes„ll„ +3 )?:');
 readln(timezone);
 write(trm,'Kuukausi P„iv„ Montakopv? (esim 12 1 31 )?:');
 readln(kk,pv,pvm);
 write(trm,'Asteluku kaksinkertaisena (keinohorisontti) k/e?:');
 readln(keino);
 if keino='k' then ker:=2 else ker:=1;
 taulu(kk,pv,pvm,ker,lat+latmin/60,long+longmin/60);

end;

begin inputti end.
