BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/vectors.o ../../bin/durango.lib  ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg 
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: conio.bin conio_16k.bin

conio.bin: $(BUILD_DIR)/ $(BUILD_DIR)/conio.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/conio.o $(LINKER_LIBS) -o conio.bin 

conio_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/conio.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/conio.o $(LINKER_LIBS) -o conio_16k.bin

$(BUILD_DIR)/conio.o: $(BUILD_DIR)/conio.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/conio.s -o $(BUILD_DIR)/conio.o

$(BUILD_DIR)/conio.s: $(SOURCE_DIR)/conio.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/conio.s $(SOURCE_DIR)/conio.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ conio.bin conio_16k.bin
