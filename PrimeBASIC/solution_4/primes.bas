10 REMARKABLE BASIC SIEVE BY DAVEPL
20 DIM A%(1000)
30 N = 1000
40 NSQ% = INT(SQR(N))
50 FOR I = 2 TO N
60     A%(I) = 1
70 NEXT I
80 FOR I = 2 TO NSQ%
90     IF A%(I) = 0 THEN GOTO 130
100    FOR J = I * 2 TO N STEP I
110        A%(J) = 0
120    NEXT J
130 NEXT I
140 END
