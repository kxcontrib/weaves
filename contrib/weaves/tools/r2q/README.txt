This is a proof of concept interface between R and kdb+. It supports
embedded R inside q as well as calling to a q instance from R.

1. Copy Rprofile to ~/.Rprofile

2. make all install

3. Test calling from R to q:

# First start a q instance in one shell that we'll access from R
niall@amandla:r2q$ q -p 5000
KDB+ 2.4 2007.12.30 Copyright (C) 1993-2007 Kx Systems
l64/ 4()core 3957MB niall amandla 127.0.1.1 EXPIRE 2012.01.01 niall@kx.com         

q)t:([]a:til 10; b:10?10)
q)

# Start R somewhere we can access kdbplus.R
# The open_connection defaults to localhost:5000

> source("kdbplus.R")
> c <- open_connection()

# Drag a copy of t from the remote kdb+ instance.
> execute(c, "select from t")
   a b
1  0 1
2  1 4
3  2 3
4  3 7
5  4 4
6  5 0
7  6 1
8  7 2
9  8 7
10 9 3

# Better- bind it to a local variable and then plot the table.
> t <- execute(c, "select from t")
> plot(t)


4. Test calling to q from R:
niall@amandla:~$ R_HOME=/usr/lib/R q
KDB+ 2.4 2007.12.30 Copyright (C) 1993-2007 Kx Systems
l64/ 4()core 3957MB niall amandla 127.0.1.1 EXPIRE 2012.01.01 niall@kx.com         

/ Try a simple R expression. Behind the scenes the R connection
/ is set up as this is the first R expression evaluated.
q)r)1+1
,2f

/ Create a variable in R.
q)r)x <- c(1,2,3,4)
1 2 3 4f

/ And use it.
q)r)x * 2
2 4 6 8f

/ Note its not available by default back in the q world.
q)x
'x

/ We can drag back a copy.
q)x:.r.find `x
q)x
1 2 3 4f

/ If we change it in the R world:
q).r.bind[`x;5 6 7 8]

/ We can see the 2 copies
q)x
1 2 3 4f
q)r)x
5 6 7 8
q)x:.r.find `x
q)x
5 6 7 8

/ Shutdown the embedded R instance.
q).r.shutdown[]
q)\\

Not all data types are handled in their full glory in either direction.
Given the late-night-hackness of it, there will be bugs (eg. leaks I imagine)
If it breaks you get to keep the pieces.
