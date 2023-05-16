BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango16k.cfg
LINKER_LIBS=  ../../bin/durango.lib
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: square.dux

$(BUILD_DIR)/square.s: $(SOURCE_DIR)/square.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/square.s $(SOURCE_DIR)/square.c
$(BUILD_DIR)/square.o: $(BUILD_DIR)/square.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/square.s -o $(BUILD_DIR)/square.o
square.bin: $(BUILD_DIR)/ $(BUILD_DIR)/square.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/square.o $(LINKER_LIBS) -o square.bin
square.dux: square.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t HELLO -d "HELLO DURANGO" -i square.bin -o square.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ square.bin square_16k.bin
