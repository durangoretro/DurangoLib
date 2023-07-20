DDK?=../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar
BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib


all: figures.dux

figures.dux: figures.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t FIGURES -d "draw figures" -i figures.bin -o figures.dux

figures.bin: $(BUILD_DIR)/ $(BUILD_DIR)/figures.o 
	ld65 $(LINKER_OPT) $(BUILD_DIR)/figures.o $(LINKER_LIBS) -o figures.bin

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)/

$(BUILD_DIR)/figures.o: $(BUILD_DIR)/figures.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/figures.s -o $(BUILD_DIR)/figures.o
$(BUILD_DIR)/figures.s: $(SOURCE_DIR)/main.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/figures.s $(SOURCE_DIR)/main.c
clean:
	rm -R $(BUILD_DIR) figures.bin figures.dux