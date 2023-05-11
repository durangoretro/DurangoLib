BUILD_DIR=bin
SOURCE_DIR=src
COMPILER_OPT= -I ../../inc --cpu 6502
ASM_OPT = -t none
LINKER_OPT= -C ../../cfg/durango16k.cfg
LINKER_LIBS=  ../../bin/durango.lib
RESCOMP?=$(DDK)/rescomp/rescomp.jar

all: double_buffer.dux

$(BUILD_DIR)/double_buffer.s: $(SOURCE_DIR)/double_buffer.c
	cc65 $(COMPILER_OPT) -o $(BUILD_DIR)/double_buffer.s $(SOURCE_DIR)/double_buffer.c
$(BUILD_DIR)/double_buffer.o: $(BUILD_DIR)/double_buffer.s
	ca65 $(ASM_OPT) $(BUILD_DIR)/double_buffer.s -o $(BUILD_DIR)/double_buffer.o
double_buffer.bin: $(BUILD_DIR)/ $(BUILD_DIR)/double_buffer.o
	ld65 $(LINKER_OPT) $(BUILD_DIR)/double_buffer.o $(LINKER_LIBS) -o double_buffer.bin
double_buffer.dux: double_buffer.bin
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t HELLO -d "HELLO DURANGO" -i double_buffer.bin -o double_buffer.dux

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

clean:
	rm -Rf $(BUILD_DIR)/ double_buffer.bin double_buffer.dux
