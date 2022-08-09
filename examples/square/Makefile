BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/vectors.o ../../bin/durango.lib  ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: square.bin square_16k.bin

square.bin: $(BUILD_DIR)/ $(BUILD_DIR)/square.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/square.o $(LINKER_LIBS) -o square.bin 

square_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/square.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/square.o $(LINKER_LIBS) -o square_16k.bin

$(BUILD_DIR)/square.o: $(BUILD_DIR)/square.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/square.s -o $(BUILD_DIR)/square.o

$(BUILD_DIR)/square.s: $(SOURCE_DIR)/square.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/square.s $(SOURCE_DIR)/square.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ square.bin square_16k.bin