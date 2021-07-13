### constants

PRODUCT=$(PRODUCT_SYMBOL)-$(PRODUCT_VERSION).exe
VPATH=..\src
FILES=$(foreach dir,$(subst ;, ,$(VPATH)),$(shell cmd /c dir /B $(dir)))
NSIS=C:\Progra~1\NSIS\makensis.exe

### rules

all: $(PRODUCT)

clean:
	cmd /c del $(PRODUCT)

files:
	@echo $(FILES)

$(PRODUCT): setup.nsi $(FILES)
	$(NSIS) /DPRODUCT=$(PRODUCT) /DPRODUCT_NAME=$(PRODUCT_NAME) /DPRODUCT_SYMBOL=$(PRODUCT_SYMBOL) /DPRODUCT_VERSION=$(PRODUCT_VERSION) $<
