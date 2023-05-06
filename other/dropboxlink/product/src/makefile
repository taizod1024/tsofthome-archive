### constants

PRODUCT=$(PRODUCT_SYMBOL).exe
NSIS=C:\Progra~1\NSIS\makensis.exe
FILES=\
	dropboxlink.nsi\
	dropboxlink_register1.ini\
	dropboxlink_register2.ini\
	dropboxlink_unregister1.ini\
	dropboxlink_unregister2.ini\
	Japanese_dropboxlink.nlf\
	Japanese_dropboxlink.nsh\
	MoveFileFolder.nsh\
	dropbox.ico\
	finish.bmp\

### rules

all: $(PRODUCT)

clean:
	cmd /c del $(PRODUCT)

files:
	@echo FILES: $(FILES)

$(PRODUCT): $(FILES)
	cmd /c copy Japanese_dropboxlink.nlf C:\Progra~1\NSIS\Contrib\Langua~1\Japanese_dropboxlink.nlf
	cmd /c copy Japanese_dropboxlink.nsh C:\Progra~1\NSIS\Contrib\Langua~1\Japanese_dropboxlink.nsh
	$(NSIS) /DPRODUCT=$(PRODUCT) /DPRODUCT_NAME=$(PRODUCT_NAME) /DPRODUCT_SYMBOL=$(PRODUCT_SYMBOL) /DPRODUCT_VERSION=$(PRODUCT_VERSION) $<

install:
	$(PRODUCT)
