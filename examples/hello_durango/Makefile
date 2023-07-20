DDK?=../../
BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: hello_durango.dux

$(BUILD_DIR)/hello_durango.s: $(SOURCE_DIR)/hello_durango.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/hello_durango.s $(SOURCE_DIR)/hello_durango.c
$(BUILD_DIR)/hello_durango.o: $(BUILD_DIR)/hello_durango.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/hello_durango.s -o $(BUILD_DIR)/hello_durango.o
hello_durango.bin: $(BUILD_DIR)/ $(BUILD_DIR)/hello_durango.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/hello_durango.o $(LINKER_LIBS) -o hello_durango.bin
hello_durango.dux: hello_durango.bin
	java -jar ${RESCOMP} -m SIGNER -n hello -t HELLO -d "HELLO DURANGO" -i hello_durango.bin -o hello_durango.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ hello_durango.bin hello_durango.dux
