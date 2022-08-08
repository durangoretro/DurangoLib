BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango.cfg ../../bin/durango.lib ../../bin/vectors.o ../../bin/sbc.lib
LINKER_OPT_16= -C ../../cfg/durango16k.cfg ../../bin/durango.lib ../../bin/vectors.o ../../bib/sbc.lib


all: fill_screen.bin fill_screen_16k.bin

fill_screen.bin: $(BUILD_DIR)/ $(BUILD_DIR)/fill_screen.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/fill_screen.o -o fill_screen.bin 

fill_screen_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/fill_screen.o
	ld65 $(LINKER_OPT_16k) $(BUILD_DIR)/fill_screen.o -o fill_screen.bin

$(BUILD_DIR)/fill_screen.o: $(BUILD_DIR)/fill_screen.s
	ca65 $(ASM_OPT) -o $(BUILD_DIR)/fill_screen.o $(BUILD_DIR)/fill_screen.s

$(BUILD_DIR)/fill_screen.s: $(SOURCE_DIR)/fill_screen.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/fill_screen.s $(SOURCE_DIR)/fill_screen.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -RF $(BUILD_DIR)/ fill_screen.bin fill_screen_16k.bin