
all: modules docs samples

modules:
	bmk makemods maxb3d
	
docs: $(wildcard *.mod/doc/*.bmx)

*.mod/doc/*.bmx: .PHONY
	bmk makeapp -r -o doc/function-$(basename $(notdir $@)) $@

samples: $(wildcard doc/samples/*/*.bmx)

doc/samples/*/*.bmx: .PHONY
	bmk makeapp -r -o doc/sample-$(basename $(notdir $@)) $@

.PHONY: true

