#
#	PDP-10 XPL compiler port
#
#	nexcom.xpl - PDP-10 XPL compiler port source
#

XPLDIR=/Users/linda/xpl

CFLAGS= -I $(XPLDIR) -Wno-parentheses-equality
XPL=$(XPLDIR)/xpl
LIBXPL=$(XPLDIR)/libxpl.a

TARGETS= xpl

%.c:	%.xpl
	$(XPL) -I $< -o $@

all:	$(TARGETS)

xpl:	nexcom.xpl
	$(XPL) nexcom.xpl
	$(CC) $(CFLAGS) nexcom.c $(LIBXPL) -o xpl

list:	xpl
	./xpl ../original/ulxcom.xpl -SD > zzl.lst

hello.rel: xpl hello.xpl
	./xpl hello.xpl -KOBEA

xcom.rel: xpl ../source/xcom.xpl
	./xpl ../source/xcom.xpl -AK

dump:	dump.xpl hello.rel xcom.rel
	$(XPL) dump.xpl
	$(CC) $(CFLAGS) dump.c $(LIBXPL) -o dump
	./dump hello.rel

clean:
	rm -f *.o *.c *.xh *.tmp *.rel *.mac $(TARGETS) dump

