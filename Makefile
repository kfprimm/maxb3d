
.PHONY: all clean media *.mod/doc modules docs samples doc/samples/*/*.bmx *.mod/doc/*.bmx doc/samples/*

MEDIA_EXTS = bmp jpg md2 x b3d 3ds tga
B3DPATH = ~/.wine/dosdevices/c:/Program\ Files/Blitz3D

all: modules docs samples

clean:
	rm -f doc/function-* doc/sample-*
	rm -f *.mod/doc/media

media: doc/media
	cp -a $(B3DPATH)/help/commands/3d_examples/media doc
	for ext in $(MEDIA_EXTS); do cp -u $(B3DPATH)/samples/*/*/*.$$ext doc/media; cp -u $(B3DPATH)/samples/*/*/*/*.$$ext doc/media; done

doc/media:
	mkdir doc/media

symlinks: clean media $(wildcard *.mod/doc) $(wildcard doc/samples/*)

*.mod/doc:
	ln -s $(PWD)/doc/media $@/media 

doc/samples/*:
	ln -s $(PWD)/doc/media $@/media

modules:
	bmk makemods
	
docs: $(wildcard *.mod/doc/*.bmx)

*.mod/doc/*.bmx:
	bmk makeapp -d -o doc/function-$(basename $(notdir $@)) $@

samples: $(wildcard doc/samples/*/*.bmx)

doc/samples/*/*.bmx:
	bmk makeapp -r -o doc/sample-$(basename $(notdir $@)) $@
	
