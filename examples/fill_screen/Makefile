BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango16k.cfg
LINKER_LIBS=  ../../bin/durango.lib
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: fill_screen.dux

$(BUILD_DIR)/fill_screen.s: $(SOURCE_DIR)/fill_screen.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/fill_screen.s $(SOURCE_DIR)/fill_screen.c
$(BUILD_DIR)/fill_screen.o: $(BUILD_DIR)/fill_screen.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/fill_screen.s -o $(BUILD_DIR)/fill_screen.o
fill_screen.bin: $(BUILD_DIR)/ $(BUILD_DIR)/fill_screen.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/fill_screen.o $(LINKER_LIBS) -o fill_screen.bin
fill_screen.dux: fill_screen.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t FILL -d "Fill Screen" -i fill_screen.bin -o fill_screen.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ fill_screen.bin fill_screen_16k.bin
