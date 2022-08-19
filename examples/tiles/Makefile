BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/dlib.o ../../bin/8x8.o ../../bin/conio.o ../../bin/interrupt.o ../../bin/wait.o ../../bin/vectors.o ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg 
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: tiles.bin

tiles.bin: $(BUILD_DIR)/ $(BUILD_DIR)/tiles.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/tiles.o $(LINKER_LIBS) -o tiles.bin 

tiles_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/tiles.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/tiles.o $(LINKER_LIBS) -o tiles_16k.bin

$(BUILD_DIR)/tiles.o: $(BUILD_DIR)/tiles.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/tiles.s -o $(BUILD_DIR)/tiles.o

$(BUILD_DIR)/tiles.s: $(SOURCE_DIR)/tiles.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/tiles.s $(SOURCE_DIR)/tiles.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ tiles.bin tiles_16k.bin
