### constants

PRODUCT12=$(PRODUCT_SYMBOL12)-$(PRODUCT_VERSION12).exe
VPATH=..\src
FILES=$(foreach dir,$(subst ;, ,$(VPATH)),$(shell cmd /c dir /B $(dir)))
NSIS=C:\Progra~1\NSIS\makensis.exe

### rules

all: $(PRODUCT12)

clean:
	cmd /c del $(PRODUCT12)

files:
	@echo $(FILES)

$(PRODUCT12): setup12.nsi $(FILES)
	$(NSIS) /DPRODUCT=$(PRODUCT12) /DPRODUCT_NAME=$(PRODUCT_NAME12) /DPRODUCT_SYMBOL=$(PRODUCT_SYMBOL12) /DPRODUCT_VERSION=$(PRODUCT_VERSION12) $<

install12:
	$(PRODUCT12)
