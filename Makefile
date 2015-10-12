include .knightos/variables.make

ALL_TARGETS:=$(BIN)kimp $(APPS)kimp.app $(SHARE)icons/kimp.img

$(BIN)kimp: *.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)kimp

$(APPS)kimp.app: config/kimp.app
	mkdir -p $(APPS)
	cp config/kimp.app $(APPS)

$(SHARE)icons/kimp.img: config/kimp.png
	mkdir -p $(SHARE)icons
	kimg -c config/kimp.png $(SHARE)icons/kimp.img

include .knightos/sdk.make