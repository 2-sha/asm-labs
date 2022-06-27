CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = main.s
OBJS = $(SRCS:.s=.o)

EXE = main

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: default
default: asc

.PHONY: asc
asc:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

.PHONY: desc
desc:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS) --defsym reverse=1
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)
