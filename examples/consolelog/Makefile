DDK?=../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar
BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib


all: console_log.dux

$(BUILD_DIR)/console_log.s: $(SOURCE_DIR)/main.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/console_log.s $(SOURCE_DIR)/main.c
$(BUILD_DIR)/console_log.o: $(BUILD_DIR)/console_log.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/console_log.s -o $(BUILD_DIR)/console_log.o
console_log.bin: $(BUILD_DIR)/ $(BUILD_DIR)/console_log.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/console_log.o $(LINKER_LIBS) -o console_log.bin
console_log.dux: console_log.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t CONSOLE_LOG -d "Console Log" -i console_log.bin -o console_log.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR) 

clean:
	rm -Rf $(BUILD_DIR)/ console_log.bin console_log.dux
