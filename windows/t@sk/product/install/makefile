### constants

PRODUCT=$(PRODUCT_SYMBOL)-$(PRODUCT_VERSION).exe
NSIS=C:\Progra~1\NSIS\makensis.exe
FILES=\
	setup.nsi\
	../doc/readme.txt\
	../src/t@sk.cmd\

### rules

all: $(PRODUCT)

clean:
	cmd /c del $(PRODUCT)

files:
	@echo FILES: $(FILES)

$(PRODUCT): $(FILES)
	$(NSIS) /DPRODUCT=$(PRODUCT) /DPRODUCT_NAME=$(PRODUCT_NAME) /DPRODUCT_SYMBOL=$(PRODUCT_SYMBOL) /DPRODUCT_VERSION=$(PRODUCT_VERSION) $<

install:
	$(PRODUCT)
