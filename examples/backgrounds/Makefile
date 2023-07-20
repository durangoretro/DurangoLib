DDK?=../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar
BUILD_DIR=bin
SOURCE_DIR=src
INC_DIR=inc
RES_DIR=res
COMPILER_OPT= -I $(DDK)/inc -I $(RES_DIR) --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib


all: backgrounds.dux

backgrounds.dux: backgrounds.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t backgrounds -d "draw backgrounds" -i backgrounds.bin -o backgrounds.dux

backgrounds.bin: $(BUILD_DIR)/ $(BUILD_DIR)/backgrounds.o 
	ld65 $(LINKER_OPT) $(BUILD_DIR)/backgrounds.o $(LINKER_LIBS) -o backgrounds.bin

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)/

$(BUILD_DIR)/backgrounds.o: $(BUILD_DIR)/backgrounds.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/backgrounds.s -o $(BUILD_DIR)/backgrounds.o
$(BUILD_DIR)/backgrounds.s: $(SOURCE_DIR)/main.c $(RES_DIR)/background.h
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/backgrounds.s $(SOURCE_DIR)/main.c
$(RES_DIR)/background.h: $(RES_DIR)/durangobackground.png
	java -jar ${RESCOMP} -n back1 -m BACKGROUND -i $(RES_DIR)/durangobackground.png -o $(RES_DIR)/background.h

clean:
	rm -R $(BUILD_DIR)
	rm $(RES_DIR)/background.h
	rm backgrounds.bin
	rm backgrounds.dux