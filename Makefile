
MEDIA_EXTS = bmp jpg
B3DPATH = ~/.wine/dosdevices/c:/Program\ Files/Blitz3D

all: modules docs samples

clean:
	rm -f doc/function-* doc/sample-*
	rm -f *.mod/doc/media

media: doc/media
	cp -a $(B3DPATH)/help/commands/3d_examples/media doc
	for ext in $(MEDIA_EXTS); do cp -u $(B3DPATH)/samples/*/*/*.$$ext doc/media; done

doc/media:
	mkdir doc/media

symlinks: clean media $(wildcard *.mod/doc)

*.mod/doc: .PHONY
	ln -s $(PWD)/doc/media $@/media 

modules:
	bmk makemods maxb3d
	
docs: $(wildcard *.mod/doc/*.bmx)

*.mod/doc/*.bmx: .PHONY
	bmk makeapp -r -o doc/function-$(basename $(notdir $@)) $@

samples: $(wildcard doc/samples/*/*.bmx)

doc/samples/*/*.bmx: .PHONY
	bmk makeapp -r -o doc/sample-$(basename $(notdir $@)) $@

.PHONY: true

