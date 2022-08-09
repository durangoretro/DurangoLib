BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/vectors.o ../../bin/durango.lib  ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg 
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: console_log.bin console_log_16k.bin

console_log.bin: $(BUILD_DIR)/ $(BUILD_DIR)/console_log.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/console_log.o $(LINKER_LIBS) -o console_log.bin 

console_log_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/console_log.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/console_log.o $(LINKER_LIBS) -o console_log_16k.bin

$(BUILD_DIR)/console_log.o: $(BUILD_DIR)/console_log.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/console_log.s -o $(BUILD_DIR)/console_log.o

$(BUILD_DIR)/console_log.s: $(SOURCE_DIR)/console_log.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/console_log.s $(SOURCE_DIR)/console_log.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ console_log.bin console_log_16k.bin