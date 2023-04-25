BUILD_DIR=bin
SOURCE_DIR=src
INCLUDE_DIRS=inc
CFG_DIR=cfg
ASM_DIR=asm
DOCS_DIR=docs
SAMPLES_DIR=examples
RESCOMP?=../rescomp.jar

COMPILE_OPTS = -c -I $(INCLUDE_DIRS) -Oir --cpu 65c02

all: $(BUILD_DIR)/durango.lib

$(BUILD_DIR)/crt0.o: $(BUILD_DIR) $(ASM_DIR)/crt0.s  
	ca65 -t none --cpu 65C02 $(ASM_DIR)/crt0.s -o $(BUILD_DIR)/crt0.o
$(BUILD_DIR)/system.o: $(BUILD_DIR) $(ASM_DIR)/system.s
	ca65 -t none --cpu 65C02 $(ASM_DIR)/system.s -o $(BUILD_DIR)/system.o
$(BUILD_DIR)/geometrics.o: $(BUILD_DIR) $(ASM_DIR)/geometrics.s
	ca65 -t none --cpu 65C02 $(ASM_DIR)/geometrics.s -o $(BUILD_DIR)/geometrics.o
$(BUILD_DIR)/conio.o: $(BUILD_DIR) $(ASM_DIR)/conio.s
	ca65 -t none --cpu 65C02 $(ASM_DIR)/conio.s -o $(BUILD_DIR)/conio.o
$(BUILD_DIR)/font.o: $(BUILD_DIR) $(ASM_DIR)/font.s
	ca65 -t none --cpu 65C02 $(ASM_DIR)/font.s -o $(BUILD_DIR)/font.o
	
	
$(BUILD_DIR)/debug.o: $(BUILD_DIR) $(ASM_DIR)/debug.s
	ca65 -t none --cpu 65C02 $(ASM_DIR)/debug.s -o $(BUILD_DIR)/debug.o

$(BUILD_DIR)/durango.lib: $(BUILD_DIR) $(BUILD_DIR)/crt0.o $(BUILD_DIR)/system.o $(BUILD_DIR)/geometrics.o $(BUILD_DIR)/conio.o $(BUILD_DIR)/font.o $(BUILD_DIR)/debug.o
	cp /usr/share/cc65/lib/supervision.lib $(BUILD_DIR)/durango.lib && ar65 a $(BUILD_DIR)/durango.lib $(BUILD_DIR)/crt0.o $(BUILD_DIR)/system.o $(BUILD_DIR)/geometrics.o $(BUILD_DIR)/conio.o $(BUILD_DIR)/font.o $(BUILD_DIR)/debug.o


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

makeziplib: $(BUILD_DIR)/durango.lib
	zip -r durangoLib.zip LICENSE $(DOCS_DIR)/ $(SAMPLES_DIR)/ $(BUILD_DIR)/durango.lib $(INCLUDE_DIRS)/durango.h $(CFG_DIR)/durango16k.cfg

clean:
	rm -Rf bin/ durangoLib.zip

