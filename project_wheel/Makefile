files = main.ml
options = -thread
dependencies = unix threads

uname = $(shell uname)

native_extension = $(if $(findstring CYGWIN,$(uname)),.exe,)

dependencies_with_extension = $(foreach dependency,$(dependencies),$(dependency).$(1))
native_dependencies = $(call dependencies_with_extension,cmxa)
byte_dependencies = $(call dependencies_with_extension,cma)

compile_command = $(1) $(options) $(2) $(files) -o $(3)

all: project_wheel

byte: project_wheel.byte

project_wheel: clean_native
	$(call compile_command,ocamlopt,$(native_dependencies),project_wheel$(native_extension))

project_wheel.byte: clean_byte
	$(call compile_command,ocamlc,$(byte_dependencies),project_wheel.byte)

clean: clean_native clean_byte

clean_native:
	rm -f *.cmi *.cmx *.o project_wheel$(native_extension)

clean_byte:
	rm -f *.cmi *.cmo *.byte
