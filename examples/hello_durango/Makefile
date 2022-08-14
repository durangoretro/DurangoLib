BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_LIBS= ../../bin/dlib.o ../../bin/8x8.o ../../bin/conio.o ../../bin/interrupt.o ../../bin/wait.o ../../bin/vectors.o ../../bin/sbc.lib
LINKER_OPT= -C ../../cfg/durango.cfg 
LINKER_OPT_16= -C ../../cfg/durango16k.cfg

all: hello_durango.bin hello_durango_16k.bin

hello_durango.bin: $(BUILD_DIR)/ $(BUILD_DIR)/hello_durango.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/hello_durango.o $(LINKER_LIBS) -o hello_durango.bin 

hello_durango_16k.bin: $(BUILD_DIR)/ $(BUILD_DIR)/hello_durango.o
	ld65 $(LINKER_OPT_16) $(BUILD_DIR)/hello_durango.o $(LINKER_LIBS) -o hello_durango_16k.bin

$(BUILD_DIR)/hello_durango.o: $(BUILD_DIR)/hello_durango.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/hello_durango.s -o $(BUILD_DIR)/hello_durango.o

$(BUILD_DIR)/hello_durango.s: $(SOURCE_DIR)/hello_durango.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/hello_durango.s $(SOURCE_DIR)/hello_durango.c

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ hello_durango.bin hello_durango_16k.bin
