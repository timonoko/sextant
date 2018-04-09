
{$P256}

program sextant(input,output);
 type cube = array[0..11,0..14,0..1] of integer;
      regpack =  record
                  AX,BX,CX,DX,BP,DI,SI,DS,ES,Flags:integer;
                  end;
      filename=string[20];
      longstr = string[200];

 const
  numerot:cube =
  (((0,1),(1,0),(4,0),(5,1),(5,4),(4,5),(1,5),(0,4),(0,1),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((2,1),(3,0),(3,5),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((0,1),(1,0),(4,0),(5,1),(5,2),(0,5),(5,5),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((1,0),(5,0),(3,2),(5,3),(5,4),(4,5),(1,5),(0,4),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((4,5),(4,0),(0,4),(5,4),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((5,0),(1,0),(0,2),(4,2),(5,3),(5,4),(4,5),(1,5),(0,4),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
(*6*)
   ((3,0),(1,0),(0,1),(0,3),(1,2),(4,2),(5,3),(5,4),(4,5),(1,5),
    (0,4),(0,3),(8,8),(8,8),(8,8)),
   ((0,0),(5,0),(1,5),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((1,2),(1,1),(2,0),(3,0),(4,1),(4,2),(1,2),(0,3),(0,4),(1,5),
    (4,5),(5,4),(5,3),(4,2),(8,8)),
 (*9*)
   ((5,2),(4,3),(1,3),(0,2),(0,1),(1,0),(4,0),(5,1),(5,4),(4,5),
    (2,5),(8,8),(8,8),(8,8),(8,8)),
   ((0,3),(4,3),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)),
   ((1,4),(2,4),(2,5),(1,5),(1,4),(8,8),(8,8),(8,8),(8,8),(8,8),
    (8,8),(8,8),(8,8),(8,8),(8,8)));

   var x,i,code:integer; ch:char;
       Lat_0,Long_0,Lat_w,Long_w:real;
       impossibile:boolean;
       color:integer;
  table_month,table_year:integer;
  GHA,DEC,SEMI,h_of_eye,Long,Lat,aZimuth:real;
  last_x:integer; 
  a:array[0..5] of real;
  b:array[0..5] of real;
  c:array[0..1] of real;
  regs:regpack;
  Day_NOW,Year_NOW,Month_NOW,
  hour_NOW,min_NOW,sec_NOW,tick_NOW:integer;
  thankyou:longstr;
  sec_prev,min_prev,hour_prev:integer;
        napa_x,napa_y:integer;
  f_correction:real;   

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

procedure grmode;
begin
 with regs do begin
   AX:=$0004;
   intr($10,regs);
 end;
end;

procedure txtmode;
begin
 with regs do begin
   AX:=$0003;
   intr($10,regs);
 end;
end;

function fint(x:real):integer;
 begin
   if x>32000 then fint:=32000
   else if x<-32000 then fint:=-32000
   else fint:=trunc(x)
  end;

procedure draw_digit(x,y,size,num:integer);
 var x1,y1,x2,y2,i:integer;
 function scaled(xy:integer):integer;
  begin scaled:=size*numerot[num,i,xy] end;
 begin
  i:=0; x1:=x+scaled(0);y1:=y+scaled(1);
  i:=1;
  repeat
   x2:=x+scaled(0);y2:=y+scaled(1);
   draw(x1,y1,x2,y2,color);
   x1:=x2;y1:=y2;
   i:=i+1;
  until (numerot[num,i,0]=8);
 end;

function about(num:real):real;
begin
 if num<0 then about:=-about(-num)
   else about:=int(1000*(num+0.0005))/1000;
end;

procedure draw_num(x,y,size:integer;num:real);
 var i,n:integer;
 begin
  if num=0 then begin draw_digit(x,y,size,0);last_x:=x+6 end
  else if num<0 then begin
     draw_digit(x,y,size,10);
     draw_num(x+size*7,y,size,-num) end
  else begin
    num:=about(num);
    i:=10000;
    n:=fint(num);
    while n<i do i:=i div 10;
    while i>0 do begin
     draw_digit(x,y,size,n div i);
     n:=n mod i;
     x:=x+6*size;
     i:=i div 10;
     end;
    if 0<frac(num) then begin
     draw_digit(x,y,size,11);
     x:=x+4*size;
     n:=round(1000*frac(num));
     i:=100;
     while n>0 do begin
      draw_digit(x,y,size,n div i);
      n:=n mod i;
      x:=x+6*size;
      i:=i div 10;
      end;
     end;
    last_x:=x;
    end;
  end;

procedure draw_deg(x,y:integer;num:real);
begin
  draw_num(x,y,1,int(num));
  num:=abs(num);
  draw(last_x+1,y,last_x+1,y,color);
  draw_num(last_x+3,y,1,int(frac(num)*60));
  draw(last_x+1,y,last_x+1,y+1,color);
  draw_num(last_x+3,y,1,int(frac(frac(num)*60)*60));
  draw(last_x+1,y,last_x+1,y+1,color);
  draw(last_x+3,y,last_x+3,y+1,color);
end;
(*
procedure test_numerot;
 var r:real;
 begin
  for x:=1 to 10 do begin time;writeln(hour_NOW,' ',min_NOW,' ',sec_NOW) end;
  readln(r);
  grmode;
  for x:=0 to 9 do begin draw_digit(20*x,1,3,x); end;
  for x:=0 to 9 do draw_deg(20,20+x*7,x*-1.235);
  draw_num(100,30,1,r);
  draw_deg(100,50,r);
  time;draw_num(100,70,1,hour_NOW);
  draw_num(100,80,1,min_NOW);
  draw_num(100,90,1,sec_NOW);
  read(kbd,ch);
  txtmode;
 end;

*)

procedure load_coef(month,year:integer);
 var  f:text;
    m,y:real;
    i:integer;
    sum:real;
begin
 if (month<>table_month) or (year<>table_year) then begin
   table_month:=month;table_year:=year;
   assign(f,'table1.dat');
   {$I-} reset(f); {$I+}
   if IOresult<>0 then assign(f,'a:\dos\table1.dat');
   reset(f);
   repeat readln(f,m,y);
   until ((m=month)and(y=year)) or eof(f);
   if eof(f) then begin
       txtmode;
       writeln('TABLE1.DAT-file non-existent or insufficient')
       end
   else begin
     sum:=0;
     readln(f,a[0],a[1],a[2],a[3],a[4],a[5]);
     for i:=0 to 4 do sum:=sum+a[i];
     if abs(sum-a[5])>0.00001 then writeln('TABLE1.DAT corrupted (1)',sum);
     sum:=0;
     readln(f,b[0],b[1],b[2],b[3],b[4],b[5]);
     for i:=0 to 4 do sum:=sum+b[i];
     if abs(sum-b[5])>0.00001 then writeln('TABLE1.DAT corrupted (2)',sum);
     readln(f,c[0],c[1]);
    end;
   close(f);
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

procedure GHADECSEMI(year,month,day,hour,min,sec:integer);
 var x,b0,gmt,bb:real;
begin
 load_coef(month,year);
 gmt:=hour+min/60+sec/3600;
 x:=(day+GMT/24)/32;
 b0:=(((a[4]*x + a[3])*x + a[2])*x + a[1])*x + a[0];
 GHA:=mod360(15*(b0+GMT));
 DEC:=(((b[4]*x + b[3])*x + b[2])*x + b[1])*x + b[0];
 SEMI:=c[0]+c[1]*x;
end;

function tan(x:real):real;
 begin tan:=sin(x)/cos(x) end;

function arcsin(x:real):real;
 begin
  arcsin:=arctan(x/sqrt(1-x*x))
 end;

function arccos(x:real):real;
 begin
  arccos:=arctan(sqrt(1-x*x)/x)
 end;

function Ho(Hs:real):real;
 var Dh,H,R,PA:real;
 begin
    Dh := 0.0293*sqrt(abs(h_of_eye));
    H:=Hs - Dh;
    R:=0.0167/tan(rad(H+7.31/(H+4.4))) * f_correction;
    PA:=0.0024*cos(rad(H));
    H:=H-R+PA;
    if h_of_eye<0 then Ho:=H
    else Ho:=H+SEMI;
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
  H_calcu:=Hc;
 end;

function sign_of(x:real):integer;
 begin
  sign_of:=round(x/abs(x));
 end;

function latitude(lat,lat_z,DEC,GHA,long,H:real):real;
 var iik:real;paska,merk:integer;
 begin
  paska:=0;
  iik:=H_calcu(GHA,DEC,Lat,long);
  if iik>H then merk:=+1 else merk:=-1;
  repeat
   iik:=H_calcu(GHA,DEC,Lat,long);
   if iik<>H then lat:=mod360(lat+merk*(iik-H));
   paska:=paska+1;
  until (abs(iik-H)<0.001) or (paska>10) or (lat>lat_z) ;
 (*  writeln('lat=',lat:8:4,'long=',long:8:4,'H=',H:8:4,'iik=',iik:8:4); *)
  latitude:=lat
 end;

 function x_screen(long:real):integer;
 begin
    x_screen:=fint((long-long_0)*240/long_w);
 end;

 function y_screen(lat:real):integer;
 begin
    y_screen:=56-fint((lat-lat_0)*56/lat_w);
 end;

procedure load_map(fname:filename);
 var f:text;ch:char;i:integer;
     lat2,long2,lat1,long1:real;
 function onech:char;begin read(f,ch); onech:=ch end;
 begin
    assign(f,fname);
    reset(f);
    lat2:=-100;
    repeat
     lat1:=lat2;long1:=long2;
     while ((onech='N') or (ch='S') or (ch='+') or (ch='-'))
             and not eof(f) do begin
       read(f,i);lat2:=i;
       read(f,i);lat2:=lat2+i/60;
       read(f,i);lat2:=lat2+i/3600;
       if ch='S' then lat2:=-lat2
       else if ch='-' then lat2:=lat1-lat2
       else if ch='+' then lat2:=lat1+lat2;
       repeat until ord(onech)>$20;
       read(f,i);long2:=i;
       read(f,i);long2:=long2+i/60;
       read(f,i);long2:=long2+i/3600;
       if ch='W' then long2:=-long2
       else if ch='-' then long2:=long1-long2
       else if ch='+' then long2:=long1+long2;
       if lat1=-100 then begin lat1:=lat2;long1:=long2 end;
       draw(x_screen(long1),y_screen(lat1),x_screen(long2),y_screen(lat2),1);
      end;
     if ch=';' then begin readln(f); lat2:=-100; end;
    until eof(f);
   close(f);
  end;

function intfrac(x:real):real;
 begin
   x:=about(x);
  if frac(x)=0 then intfrac:=int(x)
               else intfrac:=frac(x)
 end;

 procedure Reset_screen(lat,long,h:real);
   var d,a:real;i,x:integer;
  begin
    lat_0:=lat;long_0:=long;
    lat_w:=h;
    long_w:=240/56*lat_w/cos(rad(abs(lat_0)));
    grmode;
    graphwindow(0,0,240,64);
    draw_num(0,52,1,lat_0);
    draw_num(0,26,1,intfrac(lat_0+lat_w/2));
    draw_num(0,0,1,intfrac(lat_0+lat_w));
    d:= 10.;
    while (d>long_w/2) do d:=d/10.;
    if long_w/10>d then d:=d*2;
    a:=int(long_0/d)*d;
    while x_screen(a)<40 do a:=a+d;
    repeat
     x:=x_screen(a);
     draw_num(x+1,58,1,intfrac(a));
     draw(x-1,56,x+1,56,color);
     draw(x-1,28,x+1,28,color);
     draw(x-1,0,x+1,0,color);
     draw(x,55,x,57,color);
     draw(x,27,x,29,color);
     draw(x,0,x,1,color);
     a:=a+d;
    until a>(long_0+long_w);
    time;
    draw_num(200,10,1,10000/90*(lat_w/2));
  end;

procedure cursor(lat,long:real);
  var x,y:integer;
  begin
   draw_deg(190,40,lat);
   draw_deg(190,48,long);
   x:=x_screen(long);
   y:=y_screen(lat);
   draw(0,y,x-5,y,$81);
   draw(x,y+5,x,64,$81);
   draw(x+5,y,x+10,y,$81);
   draw(x,y-5,x,y-10,$81);
  end;

function between(e1,x,e2:real):boolean;
 begin
   between:= ((e1<x) and (x<e2)) or
             ((e2<x) and (x<e1))
 end;

procedure draw_curve(year,month,day,hour,min,sec:integer;h:real);
 var long,lat,long_delta:real;
     x1,y1,x2,y2,i:integer; done,below,above:boolean;
     d1,d2:real;
 begin
  draw_num(200,3,1,hour+min/100);
  GHADECSEMI(year,month,day,hour,min,sec);
  long:=long_0;
  lat:=lat_0;
  long_delta:=long_w/20;
  below:=false;above:=false;
  repeat
     x2:=x_screen(long);
     draw(x2,0,x2,10,$81);
     d1:=H_calcu(GHA,DEC,Lat,Long);
     d2:=H_calcu(GHA,DEC,Lat+lat_w,Long);
     draw(x2,0,x2,10,$81);
     long:=long+long_delta;
     if between(H,d1,d2) then below:=true;
     if between(d1,d2,H) then above:=true;
  until between(d1,H,d2) or  (long>long_0+long_w) or keypressed
        or (below and above);
  if between(d1,H,d2) or (below and above) then begin
    long:=long-2*long_delta;
    long_delta:=long_w/240;
    done:=false;
    repeat
     draw(x2,0,x2,10,$81);
     lat:=latitude(lat_0,lat_0+lat_w,DEC,GHA,long,H);
     draw(x2,0,x2,10,$81);
     x1:=x2;y1:=y2;
     x2:=x_screen(long);
     y2:=y_screen(lat);
     if (y1>0) and (y1<56) and (y2>0) and (y2<56) then
        begin if done then begin
                draw(x1,y1,x2,y2,color);
	        long_delta:=long_delta+long_w/240 end;
        done:=true end
     else  if done then long:=long+long_w;
     long:=long+long_delta;
    until (long>long_0+long_w+long_delta) or keypressed;
    end;
  color:=0;
  draw_num(200,3,1,hour+min/100);
  color:=1;
 end;

procedure draw_picture(lat,long,h:real;fname,map:filename);
 var  f:text;
      year,month,day,hour,min,sec:integer;
      Hsex:real;
      speed:integer;
begin
   repeat
    txtmode;
    reset_screen(lat,long,h);
    if map<>'' then load_map(map);
    assign(f,fname);
    reset(f);
    repeat readln(f,year,month,day,hour,min,sec,h_of_eye,f_correction,Hsex);
      draw_curve(year,month,day,hour,min,sec,Ho(Hsex));
    until eof(f) or keypressed;
    close(f);
    speed:=1;
    repeat
     cursor(lat,long);
     repeat ch:=getkey until ord( cH)>0;
     color:=0;
     cursor(lat,long);
     color:=1;
     case ch of
     '+': h:=h/2;
     '-': h:=h*2;
     'K':long:=long-long_w/120*speed;
     'M':long:=long+long_w/120*speed;
     'H':lat:=lat+lat_w/32*speed;
     'P':lat:=lat-lat_w/32*speed
     end;
     speed:=1;
     while keypressed do begin 
          speed:= 10;
          code:=ord(getkey) end;
    until (ch='+')or(ch='-')or(ord(ch)=13)or(ch='q');
   until ch='q';
   txtmode;
  end;


procedure where_is(year,month,day,hour,min,sec:integer;lat,long:real);
 begin
   GHADECSEMI(year,month,day,hour,min,sec);
   writeln('GHA=',GHA:8:4,' DEC=',DEC:8:4,' SEMI=',SEMI:8:4);
   writeln('Hc=',H_calcu(GHA,DEC,Lat,Long):8:4,' Azi=',azimuth:8:4);
 end;

procedure where_NOW;
 var timezone:integer;lat,long,iik:real;
 begin
   write('timezone lat long:');
   readln(timezone,lat,long);
  repeat
   date;time;
   GHADECSEMI(year_NOW,month_NOW,day_NOW,hour_NOW-timezone,min_NOW,sec_NOW);
   iik:=(H_calcu(GHA,DEC,Lat,Long)-semi);
  writeln('Hc-SEMI=',INT(IIK):2:0,':',abs(IIK-INT(iik))*60:4:2,
             ' Azi=',azimuth:8:4);
  until keypressed
 end;

procedure doit;
 var  lat,long,h:real;
      fname,map:filename;
      parpoi:integer;
  function valpar:real;
   var r:real;
   begin
    valpar:=0;
    if parpoi<=paramcount then begin
       val(paramstr(parpoi),r,code);
       if code=0 then valpar:=r end;
    parpoi:=parpoi+1;
   end;
  function strpar:filename;
  begin
   strpar:='';
   if parpoi<=paramcount then
       strpar:=paramstr(parpoi);
   parpoi:=parpoi+1;
  end;
  function intpar:integer;
   begin
   intpar:=trunc(valpar)
   end;

procedure viisari(x,y,size,radians:real);
 begin
   draw(trunc(x),trunc(y),
     trunc(x+size*cos(radians)),
   trunc(y-size*sin(radians)),color);
 end;

procedure taulu(x,y,size:integer);
 var i:integer;
 begin
  for i := 1 to 12 do
  draw(trunc(x+size*cos(i*pi/6)),
       trunc(y-size*sin(i*pi/6)),
       trunc(x+(size+7)*cos(i*pi/6)),
       trunc(y-(size+7)*sin(i*pi/6)),
       1); 
  end;

procedure secs(x,y,size,sec:integer);
 begin
  viisari(x,y,size,(75-sec)*2*pi/60);
 end;

procedure hrsmins(x,y,size,hrs,min,sec:integer);
 begin
  viisari(x,y,size*2/3,
        +((15-hrs) mod 12)*2*pi/12-min*2*pi/60/12);
  viisari(x,y,size,(75-min)*2*pi/60);
 end;

procedure kello(timezone:integer);
 var x,y,size:integer;
begin
  x:=80;
  y:=30;
  size:=25;
  graphmode;
   date;
   draw_num(3,5,2,year_NOW);
   draw_num(3,20,2,month_NOW);
   draw_num(3,35,2,day_NOW);
   taulu(x,y,size);
   repeat
     color:=$81;
     time;
     secs(x,y,size,sec_NOW);
     if min_prev<>min_now then begin
      draw_num(120,2,2,hour_NOW+timezone);
      draw_num(120,15,3,hour_NOW+min_NOW/100);
      hrsmins(x,y,size,hour_NOW,min_NOW,sec_NOW);
     end;
     draw_num(120,40,3,sec_NOW);
     sec_prev:=sec_now;
     min_prev:=min_now;
     hour_prev:=hour_now;
     repeat
      time;
     until sec_Now<>sec_prev;
     if min_prev<>min_now then begin
      draw_num(120,2,2,hour_prev+timezone);
      draw_num(120,15,3,hour_prev+min_prev/100);
      hrsmins(x,y,size,hour_prev,min_prev,sec_prev);
     write(trm,chr(7));
     end;
     draw_num(120,40,3,sec_prev);
     secs(x,y,size,sec_prev);
   until keypressed;
  textmode;
end;

procedure observe(timezone,height:integer;f_cor:real);
  var deg:integer;
      min,err,deci:real;
      c:char;
  begin
   kello(timezone);read(kbd,c);
   hour_now:=hour_now-timezone;
   if hour_now>24 then begin
     day_now:=day_now+1;
     hour_now:=hour_now-24;
     end;
   if hour_now<0 then begin
     day_now:=day_now-1;
     hour_now:=hour_now+24;
     end;
  Writeln(trm,'Timezone=',Timezone,' Height=',height,' Pres/temp=',F_cor:3:2);
  Writeln(trm,'GMT= ',year_NOW,'.',month_NOW,'.',day_now,'  ',
  		      hour_now,':',min_Now,':',sec_NOW);
   if height<0 then write(trm,'Puurokupista!: ');
   write(trm,'Deg Min Err:');
   readln(deg,min,err);
   deci:=deg+(min-err)/60;
   if height<0 then deci:=deci/2;
   if Deg<>0 then
   writeln(year_NOW,' ',month_NOW,' ',day_now,'  ',
      hour_now,' ',min_Now,' ',sec_NOW,'  ',
       height,' ',f_cor:6:3,'	',deci:6:3)
   else writeln;
  end;

 procedure degminsec(x:real);
  begin
  x:=abs(x);
  write(trunc(x),' ',trunc(frac(x)*60),' ',trunc(frac(frac(x)*60)*60));
  end;

 procedure make_map(lat,long,woflat,woflong:real);
   var la,lo:real;
   begin
    repeat
     txtmode;
     writeln(trm,lat:8:3,' ',long:8:3,':');
     readln(la,lo);
     if la<>0 then begin
      la:=lat+la/woflat;
      if la>0 then write('N ') else write('S ');
      degminsec(la);
      write('	');
      lo:=long+lo/woflong;
      if lo>0 then write('E ') else write('W ');
      degminsec(lo);
      writeln;
     end
    until la=0;
end;

begin
  SEMI:=0.268;
  parpoi:=1;
  i:=intpar;
  case i of
    1: draw_picture(valpar,valpar,valpar,strpar,strpar);
    2: where_is(intpar,intpar,intpar,intpar,intpar,intpar,valpar,valpar);
    3: begin kello(intpar);
        writeln(year_NOW,'.',month_NOW,'.',day_now,'  ',
        hour_now,':',min_Now,':',sec_NOW) end;
    4: observe(intpar,intpar,valpar);
    5: where_NOW;
    6: make_map(valpar,valpar,valpar,valpar);
    else begin
      txtmode;
      writeln(trm,'1: draw_picture (lat lon hei sexf map');
      writeln(trm,'2: where_is(year,month,day,hour,min,sec,lat,long); ?');
      writeln(trm,'3: kello');
      writeln(trm,'4: observe (timezone hei pres/temp)');
      writeln(trm,'5: Where NOW?');
      writeln(trm,'6: Make map (lat long width-of-lat width-of-long)');
     end
    end;
end;

begin
  f_correction:=1;
  color:=1;
  doit;
end.
