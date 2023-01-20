.PHONY: infer

RESOURCES := $(basename $(notdir $(wildcard data/raw/*.txt)))
TABLESCHEMA_RAW := $(addsuffix .yaml,$(addprefix schemas/raw/,$(RESOURCES)))

infer: $(TABLESCHEMA_RAW) ## Infer table schema for files in data/raw/ and store under schemas/raw/

$(TABLESCHEMA_RAW): schemas/raw/%.yaml: data/raw/%.txt
	frictionless describe --dialect '{"delimiter": "|"}'  --format csv --type schema --yaml $< > $@

clean:
	rm schemas/raw/*

print: 
	@echo $(TABLESCHEMA_RAW)
