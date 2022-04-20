@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

TITLE %0 %*

SET DIR=%~dp0

CALL :GETTIMEINFRACSECONDS BEGSECONDSTOTAL

SET NMAXDEFAULT=1000000
SET NMAX=!NMAXDEFAULT!

CALL :GETARGS %*

SET PRIMECOUNTS=4,25,168,1229,9592,78498,664579,5761455

SET TEMPDIR=.

IF /I "!VHD!" EQU "Y" (
   SET VHDFILE=!DIR!PRIMES.VHD
   SET VHDSIZE=768
   SET VHDDRIV=
   SET VHDFSYS=NTFS
   SET VHDLABEL=PRIMESVHD
   CALL :DELETEVDISK
   CALL :CREATEVDISK
   CALL :FINDVHDDRIV
   IF NOT DEFINED VHDDRIV ECHO Couldn't find VHD drive & PAUSE & EXIT 1
   SET TEMPDIR=!VHDDRIV!:
   )
CALL :CREATEFOLDERS
CALL :DELETEFILES
CALL :GETSQRT
CALL :SIEVE
CALL :COUNTPRIMES
IF /I "!VHD!" EQU "Y" (
   CALL :DELETEVDISK
   ) ELSE (
   CALL :DELETEFILES PARALLEL
   )
CALL :GETELAPSED BEGSECONDSTOTAL
ECHO PrimeFiles-bt2585;1;!WHOLES!.!MILLIS!;1;algorithm=base,faithful=yes,bits=unknown
GOTO :END

:SIEVE
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   BREAK>!TEMPDIR!\PRIMES\2
   BREAK>!TEMPDIR!\PRIMES\3
   FOR /L %%V IN (9,6,!NMAX!) DO BREAK>!TEMPDIR!\COMPS\%%V
   FOR /L %%L IN (5,2,!SQRT!) DO (
      IF NOT EXIST !TEMPDIR!\COMPS\%%L (
         BREAK>!TEMPDIR!\PRIMES\%%L
         SET /A START=%%L * %%L
         SET /A STEP=%%L * 2
         FOR /L %%V IN (!START!,!STEP!,!NMAX!) DO IF NOT EXIST !TEMPDIR!\COMPS\%%V BREAK>!TEMPDIR!\COMPS\%%V
         )
      )
   SET /A SQRT+=2
   FOR /L %%L IN (!SQRT!,2,!NMAX!) DO IF NOT EXIST !TEMPDIR!\COMPS\%%L BREAK>!TEMPDIR!\PRIMES\%%L
   CALL :GETELAPSED
   GOTO :EOF

:COUNTPRIMES
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   SET PRIMECOUNT=0
   FOR /F "TOKENS=1" %%Z IN ('DIR !TEMPDIR!\PRIMES ^| FIND "File(s)"') DO SET PRIMECOUNT=%%Z
   ECHO PRIMECOUNT=!PRIMECOUNT!
   CALL :GETELAPSED
   GOTO :EOF

:GETARGS
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   :GETARGSLOOP
   SET ARG=%1
   SET VAL=%2
   SHIFT
   SHIFT
   IF DEFINED ARG (
      IF /I "!ARG!" EQU "NMAX" (
         SET NMAX=!VAL!
         IF NOT DEFINED NMAX ECHO NMAX=n must be provided. Defaulting to !NMAXDEFAULT! & SET NMAX=!NMAXDEFAULT!
         FOR /F "TOKENS=* DELIMS=0123456789" %%A IN ("!NMAX!") DO (
            SET NONNUMBER=%%A
            )
         IF DEFINED NONNUMBER ECHO NMAX=n must be numeric. Defaulting to !NMAXDEFAULT! & SET NMAX=!NMAXDEFAULT!
         )
      IF /I "!ARG!" EQU "VHD" (
         SET VHD=!VAL!
         IF NOT DEFINED VHD SET VHD=N
         ECHO "!VHD!" | FIND /I "YT1" >NUL && SET VHD=Y
         )
      GOTO :GETARGSLOOP
      )
   CALL :GETELAPSED
   GOTO :EOF

:CREATEFOLDERS
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   MD !TEMPDIR!\COMPS  >NUL 2>NUL
   MD !TEMPDIR!\PRIMES >NUL 2>NUL
   CALL :GETELAPSED
   GOTO :EOF

:CREATEVDISK
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   SET DPSCRIPT=CREATEVDISK.TXT
   ECHO CREATE VDISK FILE=!VHDFILE! MAXIMUM=!VHDSIZE!>!DPSCRIPT!
   ECHO SELECT VDISK FILE=!VHDFILE!>>!DPSCRIPT!
   ECHO ATTACH VDISK>>!DPSCRIPT!
   ECHO DETAIL VDISK>>!DPSCRIPT!
   ECHO CONVERT MBR>>!DPSCRIPT!
   ECHO CREATE PARTITION PRIMARY>>!DPSCRIPT!
   ECHO FORMAT FS=!VHDFSYS! UNIT=4K LABEL=!VHDLABEL! QUICK>>!DPSCRIPT!
   ECHO ASSIGN>>!DPSCRIPT!
   DISKPART /S !DPSCRIPT! >NUL 2>NUL
   DEL !DPSCRIPT! >NUL 2>NUL
   CALL :GETELAPSED
   GOTO :EOF

:FINDVHDDRIV
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   FOR %%Z IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
      VOL %%Z: 2>NUL | FIND "!VHDLABEL!" >NUL && SET VHDDRIV=%%Z
      )
   CALL :GETELAPSED
   GOTO :EOF

:DELETEVDISK
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   SET DPSCRIPT=DELETEVDISK.TXT
   ECHO SELECT VDISK FILE=!VHDFILE!>!DPSCRIPT!
   ECHO DETACH VDISK>>!DPSCRIPT!
   DISKPART /S !DPSCRIPT! >NUL 2>NUL
   DEL !DPSCRIPT! >NUL 2>NUL
   DEL !VHDFILE! >NUL 2>NUL
   CALL :GETELAPSED
   GOTO :EOF

:DELETEFILES
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   IF "%1" EQU "PARALLEL" (
      FOR /F "TOKENS=*" %%A IN ('DIR COMPS /B /ON /AD') DO START "!TEMPDIR!\COMPS\%%A" /MIN CMD /C DEL /Q !TEMPDIR!\COMPS\%%A\*
      ) ELSE (
      DEL /Q /S !TEMPDIR!\COMPS\* >NUL 2>NUL
      )
   DEL /Q /S !TEMPDIR!\PRIMES\* >NUL 2>NUL
   CALL :GETELAPSED
   GOTO :EOF

:GETTIMEINFRACSECONDS
   SET T=!TIME!
   SET OUTVARNAME=%1
   SET T=!T::0=:!
   SET T=!T:.0=.!
   FOR /F "TOKENS=1-4 DELIMS=:." %%W IN ("!T!") DO (
      SET /A %1=%%W * 360000 + %%X * 6000 + %%Y * 100 + %%Z
      )
   GOTO :EOF

:GETELAPSED
   CALL :GETTIMEINFRACSECONDS ENDSECONDS
   SET ARG1=%1
   IF DEFINED ARG1 SET BEGSECONDS=!%1!
   SET /A ELAPSED=ENDSECONDS - BEGSECONDS
   SET /A WHOLES=ELAPSED / 100
   SET MILLIS=!ELAPSED:~-2!0
   IF "!ELAPSED!" LSS "0" (
      SET /A ELAPSED=ELAPSED + (24 * 360000)
      )
   SET /A ELAPSEDH=ELAPSED / 360000
   SET /A ELAPSED=ELAPSED - (ELAPSEDH * 360000)
   SET /A ELAPSEDM=ELAPSED / 6000
   SET /A ELAPSED=ELAPSED - (ELAPSEDM * 6000)
   SET /A ELAPSEDS=ELAPSED / 100
   SET /A ELAPSED=ELAPSED - (ELAPSEDS * 100)
   SET /A ELAPSEDF=ELAPSED
   SET /A ELAPSEDH+=100
   SET /A ELAPSEDM+=100
   SET /A ELAPSEDS+=100
   SET /A ELAPSEDF+=100
   SET ELAPSEDH=!ELAPSEDH:~1!
   SET ELAPSEDM=!ELAPSEDM:~1!
   SET ELAPSEDS=!ELAPSEDS:~1!
   SET ELAPSEDF=!ELAPSEDF:~1!
   GOTO :EOF

:GETSQRT
   CALL :GETTIMEINFRACSECONDS BEGSECONDS
   ECHO %0
   SET SQRT=1
   SET SQR=1
   SET SQRTFOUND=
   FOR /L %%L IN (1,1,46340) DO (
      IF NOT DEFINED SQRTFOUND (
         SET /A SQR=%%L * %%L
         IF !SQR! GTR !NMAX! (
            SET SQRTFOUND=1
            SET /A SQRT-=1
            ) ELSE (
            SET /A SQRT+=1
            )
         )
      )
   ECHO !SQRT:~-1! | FINDSTR "0 2 4 6 8" >NUL && SET /A SQRT-=1
   CALL :GETELAPSED
   GOTO :EOF

:END
