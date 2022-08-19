BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/dlib.o ../../bin/8x8.o ../../bin/conio.o ../../bin/interrupt.o ../../bin/wait.o ../../bin/vectors.o ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: brick.bin brick_16k.bin

brick.bin: $(BUILD_DIR)/ $(BUILD_DIR)/brick.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/brick.o $(LINKER_LIBS) -o brick.bin 

brick_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/brick.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/brick.o $(LINKER_LIBS) -o brick_16k.bin

$(BUILD_DIR)/brick.o: $(BUILD_DIR)/brick.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/brick.s -o $(BUILD_DIR)/brick.o

$(BUILD_DIR)/brick.s: $(SOURCE_DIR)/brick.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/brick.s $(SOURCE_DIR)/brick.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ brick.bin brick_16k.bin
