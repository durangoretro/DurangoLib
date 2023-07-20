DDK?=../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar
BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib

all: print.dux

print.dux: print.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t PRINT -d "Print On Screen" -i print.bin -o print.dux

print.bin: $(BUILD_DIR)/ $(BUILD_DIR)/print.o 
	ld65 $(LINKER_OPT) $(BUILD_DIR)/print.o $(LINKER_LIBS) -o print.bin

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)/

$(BUILD_DIR)/print.o: $(BUILD_DIR)/print.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/print.s -o $(BUILD_DIR)/print.o
$(BUILD_DIR)/print.s: $(SOURCE_DIR)/main.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/print.s $(SOURCE_DIR)/main.c
clean:
	rm -Rf $(BUILD_DIR)/ print.bin print.dux