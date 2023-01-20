.PHONY: infer ingest validate-raw all clean print

RESOURCES := $(basename $(notdir $(wildcard data/staging/*.txt)))
INGEST_FILES := $(addsuffix .txt,$(addprefix data/raw/,$(RESOURCES)))
TABLESCHEMA_RAW := $(addsuffix .yaml,$(addprefix schemas/raw/,$(RESOURCES)))
REPORTS_RAW := $(addsuffix .json,$(addprefix reports/raw/,$(RESOURCES)))

all: ingest validate-raw

ingest: $(INGEST_FILES) ## Ingest raw files (data/raw/) from staging area (data/staging/)

$(INGEST_FILES): data/raw/%.txt: data/staging/%.txt
	rsync --itemize-changes --checksum data/staging/* data/raw/

infer: $(TABLESCHEMA_RAW) ingest ## Infer table schema for files in data/raw/ and store under schemas/raw/

$(TABLESCHEMA_RAW): schemas/raw/%.yaml: data/raw/%.txt
	frictionless describe --dialect '{"delimiter": "|"}'  --format csv --type schema --yaml $< > $@

validate-raw: $(REPORTS_RAW)

$(REPORTS_RAW): reports/raw/%.json: data/raw/%.txt schemas/raw/%.yaml
	frictionless validate --dialect '{"delimiter": "|"}' --json --schema schemas/raw/$*.yaml data/raw/$*.txt > $@

clean:
	rm -f schemas/raw/* data/raw/* reports/raw/*

print: 
	@echo $(TABLESCHEMA_RAW)
