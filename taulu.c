


import java.util.*;
import java.awt.*;
import java.applet.*;
import java.text.*;


public class Taulu extends Applet implements Runnable {
    SimpleDateFormat formatter;  // Formats the date displayed

typedef Char filename[21];
typedef Char longstr[201];

long Day_NOW, Year_NOW, Month_NOW, hour_NOW, min_NOW, sec_NOW,
	    tick_NOW, sec_was, timezone, d;
double R0, R1, Dec0, Dec1, Dec2, Dec3, Dec4, E0, E1, E2, E3, E4, SD0,
	      SD1, R, Dec, E, SD, GHA_Aries, GHA_Sun, azimuth;

      


    public void time{
        currentDate = new Date();
        SimpleDateFormat formatter = new SimpleDateFormat
		("s",Locale.getDefault());
        try {
            sec_NOW = Integer.parseInt(formatter.format(currentDate));
        } catch (NumberFormatException n) {
            sec_NOW = 0;
        }
        formatter.applyPattern("m");
        try {
            min_NOW = Integer.parseInt(formatter.format(currentDate));
        } catch (NumberFormatException n) {
            min_NOW = 10;
        }    
        formatter.applyPattern("h");
        try {
            hour_NOW = Integer.parseInt(formatter.format(currentDate));
        } catch (NumberFormatException n) {
            hour_NOW = 10;
        }
}




Static double rad(x)
double x;
{
  return (x / 180 * M_PI);
}


Static double degrees(x)
double x;
{
  return (x * 180 / M_PI);
}


Static double mod360(x)
double x;
{
  if (x < 0)
    return (mod360(x + 360));
  else if (x > 360)
    return (mod360(x - 360));
  else
    return x;
}


Static double expt(x, y)
double x;
long y;
{
  if (y == 0)
    return 1.0;
  else
    return (x * expt(x, y - 1));
}


Static double arcsin_(x)
double x;
{
  return atan(x / sqrt(1 - x * x));
}


Static double arccos_(x)
double x;
{
  return atan(sqrt(1 - x * x) / x);
}


Static Void load_coef(month)
long month;
{
  FILE *f = NULL;
  long Month_Number;

/* p2c: taulu.pas, line 99: Warning:
 * Don't know how to ASSIGN to a non-explicit file variable [207] */
  assign(f, "newdata.dat");
  rewind(f);
  do {
    fscanf(f, "%ld%lg%lg%lg%lg%lg%lg%lg%lg%lg%lg%lg%lg%lg%lg%*[^\n]",
	   &Month_Number, &R0, &R1, &Dec0, &Dec1, &Dec2, &Dec3, &Dec4, &E0,
	   &E1, &E2, &E3, &E4, &SD0, &SD1);
    getc(f);
  } while (!((Month_Number == month) | P_eof(f)));
  if (P_eof(f))
    printf("datafile non-existent or insufficient\n");
  if (f != NULL)
    fclose(f);
  f = NULL;
}


Static double H_calcu(GHA, DEC, Lat, Long)
double GHA, DEC, Lat, Long;
{
  double Hc, LHA, S, C, X, A;

  LHA = mod360(GHA + Long);
  S = sin(rad(DEC));
  C = cos(rad(DEC)) * cos(rad(LHA));
  Hc = degrees(arcsin_(S * sin(rad(Lat)) + C * cos(rad(Lat))));
  X = (S * cos(rad(Lat)) - C * sin(rad(Lat))) / cos(rad(Hc));
  if (X > 1)
    X = 1.0;
  else if (X < -1)
    X = -1.0;
  A = degrees(arccos_(X));
  if (A > 0)
    A -= 180;
  if (LHA > 180)
    azimuth = A;
  else
    azimuth = -A;
  azimuth = mod360(azimuth - 180);
  return Hc;
}


Static Void GHADECSEMI(month, day, hour, min, sec)
long month, day, hour, min, sec;
{
  double x, UT;

  load_coef(month);
  UT = hour + min / 60.0 + sec / 3600.0;
  x = (day + UT / 24) / 32;
  R = R0 + R1 * x;
  Dec = Dec0 + (Dec1 + (Dec2 + (Dec3 + Dec4 * x) * x) * x) * x;
  E = E0 + (E1 + (E2 + (E3 + E4 * x) * x) * x) * x;
  SD = SD0 + SD1 * x;
  GHA_Aries = R + UT;
  GHA_Sun = E + UT;
}


Static Void wrdecmin(x)
double x;
{
  if (x < 0) {
    x = -x;
    putchar('-');
  }
/* p2c: taulu.pas, line 144: Note: Character >= 128 encountered [281] */
/* p2c: taulu.pas, line 144: Note: Character >= 128 encountered [281] */
  printf("%12ld\370%2.0f\357", (long)x, 60 * (x - (long)x));
}


Static Void Taulu(kk, pv1, pvm, ker, lat, long_)
long kk, pv1, pvm, ker;
double lat, long_;
{
  long pv, tn, t1;

  printf("\n\nAuringon alareunan");
  if (ker == 2)
    printf(" 2-kertanen");
  printf(" korkeus %12ld-kuussa  @ ", kk);
  wrdecmin(lat);
  printf("N ");
  wrdecmin(long_);
  printf("E \n\n");
  printf(" Kello:");
  for (t1 = 3; t1 <= 10; t1++)
    printf("\t  %12ld", t1 * 2);
  printf("\nP\204iv\204\n");
/* p2c: taulu.pas, line 159: Note: Characters >= 128 encountered [281] */
/* p2c: taulu.pas, line 159:
 * Note: WRITE statement contains color/attribute characters [203] */
  for (pv = pv1; pv <= pv1 + pvm; pv++) {
    printf("  %12ld:", pv);
    for (t1 = 3; t1 <= 10; t1++) {
      tn = t1 * 2;
      GHADECSEMI(kk, pv, tn - timezone, 0L, 0L);
      putchar('\t');
      wrdecmin(ker * (H_calcu(GHA_Sun * 15, Dec, lat, long_) - SD));
    }
    putchar('\n');
  }
}


/*
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
*/

Static Void inputti()
{
  double lat, latmin, long_, longmin;
  long kk, pv, pvm, ker;
  Char keino;

/* p2c: taulu.pas, line 212: Note: Character >= 128 encountered [281] */
/* p2c: taulu.pas, line 212:
 * Note: WRITE statement contains color/attribute characters [203] */
  printf("Pohjosta Leveytt\204 (esim: 60 11.5 )?:");
  scanf("%lg%lg%*[^\n]", &lat, &latmin);
  getchar();
/* p2c: taulu.pas, line 213: Note: Characters >= 128 encountered [281] */
/* p2c: taulu.pas, line 213:
 * Note: WRITE statement contains color/attribute characters [203] */
  printf("It\204ist\204 Pituutta (esim: 24 50.3 )?:");
  scanf("%lg%lg%*[^\n]", &long_, &longmin);
  getchar();
/* p2c: taulu.pas, line 215: Note: Characters >= 128 encountered [281] */
/* p2c: taulu.pas, line 215:
 * Note: WRITE statement contains color/attribute characters [203] */
  printf("Aikavy\224hyke (suomessa kes\204ll\204 +3 )?:");
  scanf("%ld%*[^\n]", &timezone);
  getchar();
/* p2c: taulu.pas, line 217: Note: Characters >= 128 encountered [281] */
/* p2c: taulu.pas, line 217:
 * Note: WRITE statement contains color/attribute characters [203] */
  printf("Kuukausi P\204iv\204 Montakopv? (esim 12 1 31 )?:");
  scanf("%ld%ld%ld%*[^\n]", &kk, &pv, &pvm);
  getchar();
  printf("Asteluku kaksinkertaisena (keinohorisontti) k/e?:");
  scanf("%c%*[^\n]", &keino);
  getchar();
  if (keino == '\n')
    keino = ' ';
  if (keino == 'k')
    ker = 2;
  else
    ker = 1;
  Taulu(kk, pv, pvm, ker, lat + latmin / 60, long_ + longmin / 60);

}


main(argc, argv)
int argc;
Char *argv[];
{
  PASCAL_MAIN(argc, argv);
  inputti();
  exit(EXIT_SUCCESS);
}




/* End. */
