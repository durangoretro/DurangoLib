ASM_DIR=asm
RES_DIR=res
BUILD_DIR=bin
INC_DIR=inc
DDK?=/durango
RESCOMP ?= $(DDK)/rescomp/rescomp.jar

all: $(BUILD_DIR)/durango.lib $(BUILD_DIR)/system.lib $(INC_DIR)/font.h $(BUILD_DIR)/qgraph.lib $(BUILD_DIR)/psv.lib $(BUILD_DIR)/sprites.lib $(BUILD_DIR)/geometrics.lib $(BUILD_DIR)/conio.lib $(BUILD_DIR)/glyph.lib

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/crt0.o: $(ASM_DIR)/crt0.s $(BUILD_DIR)
	cp $(ASM_DIR)/crt0.s $(BUILD_DIR)/crt0.s && java -jar ${RESCOMP} -m STAMP -n DCLIB -o $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -i $(BUILD_DIR)/crt0.s && ca65 -t none $(BUILD_DIR)/crt0.s -o $(BUILD_DIR)/crt0.o
	
$(BUILD_DIR)/durango.lib: $(BUILD_DIR)/crt0.o $(BUILD_DIR)
	cp /usr/share/cc65/lib/supervision.lib $(BUILD_DIR)/durango.lib && ar65 a $(BUILD_DIR)/durango.lib $(BUILD_DIR)/crt0.o

$(BUILD_DIR)/common.o: $(ASM_DIR)/common.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/common.s -o $(BUILD_DIR)/common.o

$(INC_DIR)/font.h: ${RES_DIR}/font.png
	java -jar ${RESCOMP} -n font -m FONT -i ${RES_DIR}/font.png -h 8 -w 5 -o $(INC_DIR)/font.h

$(BUILD_DIR)/qgraph.o: $(ASM_DIR)/qgraph.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/qgraph.s -o $(BUILD_DIR)/qgraph.o
$(BUILD_DIR)/qgraph.lib: $(BUILD_DIR)/qgraph.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/qgraph.lib $(BUILD_DIR)/qgraph.o

$(BUILD_DIR)/psv.o: $(ASM_DIR)/psv.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/psv.s -o $(BUILD_DIR)/psv.o
$(BUILD_DIR)/psv.lib: $(BUILD_DIR)/psv.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/psv.lib $(BUILD_DIR)/psv.o
	
	
$(BUILD_DIR)/system.o: $(ASM_DIR)/system.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/system.s -o $(BUILD_DIR)/system.o
$(BUILD_DIR)/system.lib: $(BUILD_DIR)/system.o $(BUILD_DIR)/common.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/system.lib $(BUILD_DIR)/system.o $(BUILD_DIR)/common.o


$(BUILD_DIR)/sprites.o: $(ASM_DIR)/sprites.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/sprites.s -o $(BUILD_DIR)/sprites.o
$(BUILD_DIR)/sprites.lib: $(BUILD_DIR)/sprites.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/sprites.lib $(BUILD_DIR)/sprites.o $(BUILD_DIR)/common.o
	
$(BUILD_DIR)/geometrics.o: $(ASM_DIR)/geometrics.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/geometrics.s -o $(BUILD_DIR)/geometrics.o
$(BUILD_DIR)/geometrics.lib: $(BUILD_DIR)/geometrics.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/geometrics.lib $(BUILD_DIR)/geometrics.o
	
$(BUILD_DIR)/conio.o: $(ASM_DIR)/conio.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/conio.s -o $(BUILD_DIR)/conio.o
$(BUILD_DIR)/conio.lib: $(BUILD_DIR)/conio.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/conio.lib $(BUILD_DIR)/conio.o

$(BUILD_DIR)/glyph.o: $(ASM_DIR)/glyph.s $(BUILD_DIR)
	ca65 -t none $(ASM_DIR)/glyph.s -o $(BUILD_DIR)/glyph.o
$(BUILD_DIR)/glyph.lib: $(BUILD_DIR)/glyph.o $(BUILD_DIR)
	ar65 r $(BUILD_DIR)/glyph.lib $(BUILD_DIR)/glyph.o

clean:
	rm -Rf $(BUILD_DIR) $(INC_DIR)/font.h