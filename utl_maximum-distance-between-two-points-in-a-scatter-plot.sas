Maximum distance between two points in a scatter plot

INPUT
=====

Algorithm

  1. Select all the points than make a convex hull
     This like an envelop of outer points of the scatter plot
  2. Give the 'envelop points' do a catesion join of the
     envelop with itself. You will always get two results
     (X1,Y1) to (X2,Y2) and  (X2,Y2) to (X1,Y1). They
     are the same, select one of them.

 The data for this analysis

 SD1.HAVE total obs=59

    X      Y

   0.0    0.0
   0.0    9.9
   9.8    0.1
   9.8    9.7
   0.0    0.2
   9.6    0.2
   0.3    9.5
 ...


 SD1.HAVE total obs=59


   Y |
10.0 + +
     |   +                                                 + +
     |       +    +     +                          +
     |
     |       +    +                                +     +
 7.5 +
     |                                  +                +
     |
     |            +                           +
     |
 5.0 +                       +          +     +
     |
     | +                     +
     |
     | +     +          +          +    +     +    +
 2.5 +
     |       +          +          +    +          +     +
     |
     | +                     +                +
     |
 0.0 + +          +                     +                   ++
     --+----------+----------+----------+----------+----------+-
       0          2          4          6          8         10

                                  X



PROCESS
=======

   * get record numbers that form the convex hull;

   %utl_submit_wps64('
   libname sd1 "d:/sd1";
   options set=R_HOME "C:/Program Files/R/R-3.3.1";
   libname wrk sas7bdat "%sysfunc(pathname(work))";
   proc r;
   submit;
   source("C:/Program Files/R/R-3.3.1/etc/Rprofile.site", echo=T);
   library(haven);
   have<-read_sas("d:/sd1/have.sas7bdat");
   want<-chull(have$X,have$Y);
   endsubmit;
   import r=want  data=wrk.want;
   run;quit;
   ');

   /* the record numbers (_n_) that form the envelop

   WORK.WANT  total obs=5

      Obs    WANT    X      Y

       1       3    0.0    0.0
       2      56    0.0    9.9
       3       1    9.8    0.1
       4       2    9.8    9.7
       5       4    6.0    0.0

   */

   * use the record number from R to get envelop (X,Y) coordinates;
   data havHul;
     if _n_=0 then do;
       %let rc=%sysfunc(dosubl('
         proc sql noprint;
           select
             want
           into
             :hul separated by ","
           from
             want
         ;quit;
       '));
     end;
     set sd1.have;
     if _n_ in (&hul);
   run;quit;

   * compute all possible combinations and select the maximum distance;
   proc sql;
     create
       table fin as

     select
       r.x as rx
      ,r.y as ry
      ,l.x as lx
      ,l.y as ly
      ,sqrt((r.x-l.x)**2 + (r.y-l.y)**2) as dist
     from
       havHul as r full outer join havHul as l
     on
       1=1
     having
       dist=max(dist)
   ;quit;

   /*
  WORK.FIN total obs=2

      RX     RY     LX     LY      DIST

     0.0    9.9    9.8    0.1    13.8593
     9.8    0.1    0.0    9.9    13.8593
   */


OUTPUT
======

  WORK.FIN total obs=2

      RY     RX     LX     LY      DIST

     0.0    9.9    9.8    0.1    13.8593
     9.8    0.1    0.0    9.9    13.8593



   +--------------------------------------------------------+
10 +  +                                                 +   +
   |  \                                                     |
   |   \+                                                   |
   |    \                                                   |
   |     \                                                  |
 9 +      \ +    +     +                          +         +
   |       \                                                |
   |        \                                               |
   |         \                                              |
   |          \                                             |
 8 +        +  \ +                                +     +   +
   |            \                                           |
   |             \                                          |
   |              \                                         |
   |               \                                        |
 7 +                \                  +                +   +
   |                 \                                      |
   |                  \                                     |
   |                   \                                    |
   |                    \                                   |
 6 +             +       \                   +              +
   |                      \                                 |
   |                       \        Max Distance 13.9 unit  |
   |                        \                               |
   |                         \                              |
 5 +                        + \        +     +              +
   |                           \                            |
   |                            \                           |
   |                             \                          |
   |                              \                         |
 4 +  +                     +      \                        +
   |                                \                       |
   |                                 \                      |
   |                                  \                     |
   |                                   \                    |
 3 +  +     +          +          +    +\    +    +         +
   |                                     \                  |
   |                                      \                 |
   |                                       \                |
   |                                        \               |
 2 +        +          +          +    +     \    +     +   +
   |                                          \             |
   |                                           \            |
   |                                            \           |
   |                                             \          |
 1 +  +                     +                +    \         +
   |                                               \        |
   |                                                \       |
   |                                                 \      |
   |                                                  \
 0 +  +          +                     +               +    +
   ---+----------+----------+----------+----------+-------+--
      0          2          4          6          8         10
                                 X
 ...

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

%symdel hul / nowarn;
proc datasets lib=work kill;
run;quit;


data sd1.have(drop=rec);
  call streaminit(5731);
    x=0;
    y=0;
    output;
    y=9.9;
    output;
    x= 9.8;
    y=0.1;
    output;
    y=9.7;
    output;
    y=0.2;
    x=0;
    output;
    x=9.6;
    output;
    y=9.5;
    x=0.3;
    output;
    x=9.4;
    output;
  do rec=0 to 50;
    x=int(10*rand('uniform'));
    y=int(10*rand('uniform'));
    output;
  end;
stop;
run;quit;

options ls=64 ps=32;
proc plot data=sd1.have;
plot y*x='+';
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


* get record numbers that form the convex hull;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.1";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.1/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
want<-chull(have$X,have$Y);
endsubmit;
import r=want  data=wrk.want;
run;quit;
');

/* the record numbers (_n_) that form the envelop

WORK.WANT  total obs=5

   Obs    WANT    X      Y

    1       3    0.0    0.0
    2      56    0.0    9.9
    3       1    9.8    0.1
    4       2    9.8    9.7
    5       4    6.0    0.0

*/

* use the record number from R to get envelop (X,Y) coordinates;
data havHul;
  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
      proc sql noprint;
        select
          want
        into
          :hul separated by ","
        from
          want
      ;quit;
    '));
  end;
  set sd1.have;
  if _n_ in (&hul);
run;quit;

* compute all possible combinations and select the maximum distance;
proc sql;
  create
    table fin as

  select
    r.x as rx
   ,r.y as ry
   ,l.x as lx
   ,l.y as ly
   ,sqrt((r.x-l.x)**2 + (r.y-l.y)**2) as dist
  from
    havHul as r full outer join havHul as l
  on
    1=1
  having
    dist=max(dist)
;quit;

/*
WORK.FIN total obs=2

   RX     RY     LX     LY      DIST

  0.0    9.9    9.8    0.1    13.8593
  9.8    0.1    0.0    9.9    13.8593
*/

