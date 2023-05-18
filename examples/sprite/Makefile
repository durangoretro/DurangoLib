BUILD_DIR=bin
SOURCE_DIR=src
INC_DIR=inc
RES_DIR=res
COMPILER_OPT= -I ../../inc -I $(RES_DIR) --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango16k.cfg
LINKER_LIBS=  ../../bin/durango.lib
DDK?=../../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: sprites.dux

sprites.dux: sprites.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t sprites -d "draw sprites" -i sprites.bin -o sprites.dux

sprites.bin: $(BUILD_DIR)/ $(BUILD_DIR)/sprites.o 
	ld65 $(LINKER_OPT) $(BUILD_DIR)/sprites.o $(LINKER_LIBS) -o sprites.bin

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)/

$(BUILD_DIR)/sprites.o: $(BUILD_DIR)/sprites.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/sprites.s -o $(BUILD_DIR)/sprites.o
$(BUILD_DIR)/sprites.s: $(SOURCE_DIR)/main.c $(RES_DIR)/background.h $(RES_DIR)/sprite1.h $(RES_DIR)/sprite2.h $(RES_DIR)/sprite3.h
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/sprites.s $(SOURCE_DIR)/main.c
$(RES_DIR)/sprite1.h: $(RES_DIR)/sprite1.png 
	java -jar ${RESCOMP} -n sprite -m SPRITESHEET -w 10 -h 10 -i $(RES_DIR)/sprite1.png -o $(RES_DIR)/sprite1.h
$(RES_DIR)/sprite2.h: $(RES_DIR)/sprite2.png
	java -jar ${RESCOMP} -n sprite2 -m SPRITESHEET -w 10 -h 10 -i $(RES_DIR)/sprite2.png -o $(RES_DIR)/sprite2.h
$(RES_DIR)/sprite3.h: $(RES_DIR)/sprite3.png
	java -jar ${RESCOMP} -n sprite3 -m SPRITESHEET -w 10 -h 10 -i $(RES_DIR)/sprite3.png -o $(RES_DIR)/sprite3.h
$(RES_DIR)/background.h: $(RES_DIR)/background.png
	java -jar ${RESCOMP} -n back1 -m BACKGROUND -i $(RES_DIR)/background.png -o $(RES_DIR)/background.h

clean:
	rm -R $(BUILD_DIR)
	rm $(RES_DIR)/background.h
	rm $(RES_DIR)/sprite1.h
	rm $(RES_DIR)/sprite2.h
	rm sprites.bin
	rm sprites.dux