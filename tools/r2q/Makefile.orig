Q=/home/niall/q/l64
INCLUDES=-I. -I/usr/share/R/include
LIBS=${Q}/c.o -lpthread -L/usr/lib/R/lib/ -lR

CC=gcc
CFLAGS=-g -O -fPIC -m64 -shared

SRC=r2q.c
TARGET=r2q.so

all:
	${CC} ${CFLAGS} ${INCLUDES} ${SRC} ${LIBS} -o ${TARGET}

install:
	cp ${TARGET} ${Q}

