.PHONY: infer ingest validate-raw transform validate all clean print

RESOURCES := $(basename $(notdir $(wildcard data/staging/*.txt)))
INGEST_FILES := $(addsuffix .txt,$(addprefix data/raw/,$(RESOURCES)))
REPORTS_RAW := $(addsuffix .json,$(addprefix reports/raw/,$(RESOURCES)))
REPORTS := $(addsuffix .json,$(addprefix reports/,$(RESOURCES)))
DATA_FILES := $(addsuffix .csv,$(addprefix data/,$(RESOURCES)))

all: ingest validate-raw transform validate ## Run the complete data pipeline

ingest: $(INGEST_FILES) ## Ingest raw files (data/raw/) from staging area (data/staging/)

$(INGEST_FILES): data/raw/%.txt: data/staging/%.txt
	rsync --itemize-changes --checksum data/staging/* data/raw/

infer:  ## Infer table schema for files in data/staging/ and store under schemas/raw/
	python scripts/infer.py

validate-raw: $(REPORTS_RAW)

$(REPORTS_RAW): reports/raw/%.json: data/raw/%.txt schemas/raw/%.yaml
	frictionless validate --dialect '{"delimiter": "|"}' --format csv --json --schema schemas/raw/$*.yaml data/raw/$*.txt > $@

transform: $(DATA_FILES) ## Transform raw data from data/raw and save under data/

$(DATA_FILES): data/%.csv: data/raw/%.txt reports/raw/%.json
	Rscript scripts/transform.R $< $@

validate: $(REPORTS)

$(REPORTS): reports/%.json: data/%.csv schemas/%.yaml
	frictionless validate --json --resource-name $* datapackage.yaml > $@

clean:
	find reports -type f -name "*.json" | xargs rm
	find data -type f -name "*.csv" | xargs rm

print: 
	@echo $(TABLESCHEMA_RAW)
