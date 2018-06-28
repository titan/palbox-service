NAME = box-service
BUILDDIR=/dev/shm/${NAME}
TARGET = $(BUILDDIR)/box_service

SERVERSRC:=$(BUILDDIR)/src/box_service.nim
BUILDSRC:=$(BUILDDIR)/box_service.nimble
PROTOSRC:=$(BUILDDIR)/src/box_servicepkg/tightrope.nim

all: $(TARGET)

$(TARGET): $(SERVERSRC) $(BUILDSRC) $(PROTOSRC)
	cd $(BUILDDIR); nimble build; cd -

$(SERVERSRC): src/service.org | prebuild
	org-tangle $<
	#emacs $< --batch -f org-babel-tangle --kill

$(BUILDSRC): src/build.org | prebuild
	org-tangle $<
	#emacs $< --batch -f org-babel-tangle --kill

$(BUILDDIR)/src/proto.scm: src/proto.org | prebuild
	org-tangle $<
	#emacs $< --batch -f org-babel-tangle --kill

$(PROTOSRC): $(BUILDDIR)/src/proto.scm | prebuild
	tightrope -entity -serial -nim -d $(BUILDDIR)/src/box_servicepkg $<

sdk: $(BUILDDIR)/src/proto.scm | prebuild
	tightrope -entity -serial -clang -d $(BUILDDIR)/sdk $<

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)/src
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean prebuild sdk
