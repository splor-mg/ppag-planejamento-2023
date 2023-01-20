.PHONY: infer ingest

RESOURCES := $(basename $(notdir $(wildcard data/staging/*.txt)))
INGEST_FILES := $(addsuffix .txt,$(addprefix data/raw/,$(RESOURCES)))
TABLESCHEMA_RAW := $(addsuffix .yaml,$(addprefix schemas/raw/,$(RESOURCES)))

ingest: $(INGEST_FILES) ## Ingest raw files (data/raw/) from staging area (data/staging/)

$(INGEST_FILES): data/raw/%.txt: data/staging/%.txt
	rsync --itemize-changes --checksum data/staging/* data/raw/

infer: $(TABLESCHEMA_RAW) ingest ## Infer table schema for files in data/raw/ and store under schemas/raw/

$(TABLESCHEMA_RAW): schemas/raw/%.yaml: data/raw/%.txt
	frictionless describe --dialect '{"delimiter": "|"}'  --format csv --type schema --yaml $< > $@

clean:
	rm -f schemas/raw/* data/raw/*

print: 
	@echo $(TABLESCHEMA_RAW)
