DDK?=../../
BUILD_DIR=bin
RES_DIR=res
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango16k.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: music.dux

$(RES_DIR)/melody.h: $(RES_DIR)/melody.musicxml
	java -jar ${RESCOMP} -n melody -m MUSIC -i $(RES_DIR)/melody.musicxml -o $(RES_DIR)/melody.h
$(BUILD_DIR)/music.s: $(SOURCE_DIR)/music.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/music.s $(SOURCE_DIR)/music.c

$(BUILD_DIR)/music.o: $(BUILD_DIR)/music.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/music.s -o $(BUILD_DIR)/music.o
music.bin: $(BUILD_DIR)/ $(BUILD_DIR)/music.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/music.o $(LINKER_LIBS) -o music.bin
music.dux: music.bin
	java -jar ${RESCOMP} -m SIGNER -n music -t MUSCI -d "DURANGO MUSIC EXAMPLE" -i music.bin -o music.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ music.bin music.dux
