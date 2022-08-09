BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/vectors.o ../../bin/durango.lib  ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg 
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: fill_screen.bin fill_screen_16k.bin

fill_screen.bin: $(BUILD_DIR)/ $(BUILD_DIR)/fill_screen.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/fill_screen.o $(LINKER_LIBS) -o fill_screen.bin 

fill_screen_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/fill_screen.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/fill_screen.o $(LINKER_LIBS) -o fill_screen.bin

$(BUILD_DIR)/fill_screen.o: $(BUILD_DIR)/fill_screen.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/fill_screen.s -o $(BUILD_DIR)/fill_screen.o

$(BUILD_DIR)/fill_screen.s: $(SOURCE_DIR)/fill_screen.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/fill_screen.s $(SOURCE_DIR)/fill_screen.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ fill_screen.bin fill_screen_16k.bin