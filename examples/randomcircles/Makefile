DDK?=../../
RESCOMP?=$(DDK)/rescomp/rescomp.jar
BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I $(DDK)/inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C $(DDK)/cfg/durango.cfg
LINKER_LIBS=  $(DDK)/bin/durango.lib


all: random_circles.dux

$(BUILD_DIR)/random_circles.s: $(SOURCE_DIR)/main.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/random_circles.s $(SOURCE_DIR)/main.c
$(BUILD_DIR)/random_circles.o: $(BUILD_DIR)/random_circles.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/random_circles.s -o $(BUILD_DIR)/random_circles.o
random_circles.bin: $(BUILD_DIR)/ $(BUILD_DIR)/random_circles.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/random_circles.o $(LINKER_LIBS) -o random_circles.bin
random_circles.dux: random_circles.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t RCIRCLES -d "Random Circles" -i random_circles.bin -o random_circles.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ random_circles.bin random_circles.dux
