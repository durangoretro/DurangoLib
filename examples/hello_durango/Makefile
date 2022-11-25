BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango16k.cfg
LINKER_LIBS= ../../bin/durango.lib

all: hello_durango.bin

$(BUILD_DIR)/hello_durango.s: $(SOURCE_DIR)/hello_durango.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/hello_durango.s $(SOURCE_DIR)/hello_durango.c
$(BUILD_DIR)/hello_durango.o: $(BUILD_DIR)/hello_durango.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/hello_durango.s -o $(BUILD_DIR)/hello_durango.o
hello_durango.bin: $(BUILD_DIR)/ $(BUILD_DIR)/hello_durango.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/hello_durango.o $(LINKER_LIBS) -o hello_durango.bin

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ hello_durango.bin hello_durango_16k.bin
