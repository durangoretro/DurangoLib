BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/vectors.o ../../bin/durango.lib  ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: double_buffer.bin double_buffer_16k.bin

double_buffer.bin: $(BUILD_DIR)/ $(BUILD_DIR)/double_buffer.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/double_buffer.o $(LINKER_LIBS) -o double_buffer.bin 

double_buffer_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/double_buffer.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/double_buffer.o $(LINKER_LIBS) -o double_buffer_16k.bin

$(BUILD_DIR)/double_buffer.o: $(BUILD_DIR)/double_buffer.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/double_buffer.s -o $(BUILD_DIR)/double_buffer.o

$(BUILD_DIR)/double_buffer.s: $(SOURCE_DIR)/double_buffer.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/double_buffer.s $(SOURCE_DIR)/double_buffer.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ double_buffer.bin double_buffer_16k.bin