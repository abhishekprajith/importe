********************************************
BrainFuck Prime Sieve 
by aquarel 7/23/21

This file only contains the core function
of the prime sieve
Which is equivalent to the "runSieve"
method in other implementations
The setup code and printing results is
handled by PrimeBrainFuck*cpp
********************************************


PART #1 = "int q = (int) sqrt(sieveSize);"
Aka a sad excuse for a square root function
It just needs to approximate above the real
value to not miss any number

Using the newton iteration as follows:
Use x as a first guess; y0 = x
y1 = (y0 add x / y0) / 2
y2 = (y1 add x / y1) / 2
y3 = (y3 add x / y3) / 2
and so on for 12 times
y12 = (y11 add x / y11) / 2
y12 add 1 = sqrt(x)

Every "cell" or memory address used for one
iteration is listed below
Each cell is has a tag at the start:
"set" = an input value
"out" = an output value
"use" = value reserved to use when run
"ign" = ignored/unused value

memory layout = 
{
set 0   x = 1'000'000
set 1   dividend = x
out 2   remainder = x % y0
set 3   divisor = y0
out 4   quotient = x / y0
use 5   first_zero = 0
use 6   last_zero = 0
ign 7

set 8   add = y0 plus quotient
set 9   dividend = add
out 10  remainder = add % 2
set 11  divisor = 2
out 12  y1 = add / 2
use 13  first_zero = 0
use 14  last_zero = 0
set 15  copy_of_y1
}

iteration #1
    set x = (1'000'000)
        ++ ++ ++ ++ ++ start with (10) at 0
         [>++ ++ ++ ++ ++<-] mul by (10) with result at 1
        >[>++ ++ ++ ++ ++<-] mul by (10) with result at 2
        >[>++ ++ ++ ++ ++<-] mul by (10) with result at 3
        >[>++ ++ ++ ++ ++<-] mul by (10) with result at 4
        >[>++ ++ ++ ++ ++<-] mul by (10) with result at 5
        >[ copy value of 5
            <<<<+<+>>>>> to 0 and 1 (x and dividend)
            >>>> >>>+<<< <<<< to 12 (y1)
        -]<<<<< go to 0

    copy y1 to divisor and copy_of_y1
        >>>> >>>> >>>>[ copy value of 12
            <<<< <<<< <+> >>>> >>>> to 3 (divisor)
            >>>+<<< to 15 (copy of y1)
        -]<<<< <<<< <<<< go to 0

    do first division (credit goes to u/danielcristofani)
    https://www*reddit*com/r/brainfuck/comments/dwdboo/division_in_brainfuck/
        >[ while dividend != 0
            >+ add remainder
            >- sub divisor

            [>>>] if divisor == 0: go to last_zero
            < go to remainder or to first_zero

            [ if at remainder: run the following code once
                [ while remainder != 0
                    >+ add divisor
                    <- sub remainder
                ]
                >>+ add quotient
                > go to first_zero
            ]
            <<<<- sub dividend
        ]<

    copy quotient and copy_of_y1 to add
    effectively adding quotient and copy_of_y1
        >>>>[ copy value of 4
            >>>>+<<<< to 8
        -]<<<< go to 0
        >>>> >>>> >>>> >>>[ copy value of 15
            <<<< <<<+>>> >>>> to 8
        -]<<< <<<< <<<< <<<< go to 0

    copy add to dividend
        >>>> >>>>[ copy value of 8
            >+< to 9
        -]<<<< <<<< go to 0

    set divisor to 2
        >>>> >>>> >>>++<<< <<<< <<<<

    do second division (credit goes to u/danielcristofani)
    https://www*reddit*com/r/brainfuck/comments/dwdboo/division_in_brainfuck/
        >>>> >>>> >[ go to 9 (second dividend)
            >+>-[>>>]<[[>+<-]>>+>]<<<< same as previous division
        -]< <<<< <<<< go to 0

iteration #2 (the same code without comments and with a couple changes)
    >>>> >>>> >>>> >>>> go to 16

    ++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-]>[>+++
    +++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<

    copy previous result to divisor and copy_of_y1
        <<<<[ copy value of previous 12
            >>>> >>>+ to 3 (divisor)
            >>>> >>>> >>>>+<<< <<<< <<<< <<<< to 15 (copy of y1)
            <<<< go to previous 12
        -]>>>> go to 0

    >[>+>-[>>>]<[[>+<-]>>+>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<
    <+>>>>>>>-]<<<<<<<[>+<-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
the following is a sin in programming
but I couldn't be bothered to write a loop
iteration #3
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #4
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #5
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #6
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #7
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #8
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #9
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #10
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #11
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
iteration #12
    >>>>>>>++++++++++[>++++++++++<-]>[>++++++++++<-]>[>++++++++++<-
    ]>[>++++++++++<-]>[>++++++++++<-]>[<<<<+<+>>>>>-]<<<<<<<<<[>>>>
    >>>+>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<-]>>>>>[>+>-[>>>]<[[>+<-]>>
    +>]<<<<-]>>>[>>>>+<<<<-]>>>>>>>>>>>[<<<<<<<+>>>>>>>-]<<<<<<<[>+
    <-]>>>++<<[>+>-[>>>]<[[>+<-]>>+>]<<<<-]
<<<<<<<<< go to 0

>>>> >>>> >>>> print result
