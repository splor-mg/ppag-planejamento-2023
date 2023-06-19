.PHONY: infer extract validate-raw transform validate build all clean print

RESOURCES := $(shell yq e '.resources[].name' datapackage.yaml)
EXTRACT_LOG_FILES := $(addsuffix .txt,$(addprefix logs/data/raw/,$(RESOURCES)))
REPORTS_RAW := $(addsuffix .json,$(addprefix reports/raw/,$(RESOURCES)))
REPORTS := $(addsuffix .json,$(addprefix reports/,$(RESOURCES)))
DATA_FILES := $(addsuffix .csv,$(addprefix data/,$(RESOURCES)))

all: extract ingest validate-raw transform validate ## Run the complete data pipeline

extract: $(EXTRACT_LOG_FILES) ## Extract raw files from source system over network and stores locally in data/raw/

$(EXTRACT_LOG_FILES): logs/data/raw/%.txt:
	python scripts/extract.py $* 2>&1 | tee $@

infer:  ## Infer table schema for files in data/raw/ and store under schemas/raw/
	python scripts/infer.py

validate-raw: $(REPORTS_RAW)

$(REPORTS_RAW): reports/raw/%.json: data/raw/%.txt schemas/raw/%.yaml
	frictionless validate --dialect '{"delimiter": "|"}' --format csv --json --schema schemas/raw/$*.yaml data/raw/$*.txt > $@

transform: $(DATA_FILES) ## Transform raw data from data/raw and save under data/

$(DATA_FILES): data/%.csv: data/raw/%.txt reports/raw/%.json schemas/%.yaml scripts/transform.py datapackage.yaml
	python scripts/transform.py $*

validate: $(REPORTS)

$(REPORTS): reports/%.json: data/%.csv schemas/%.yaml
	frictionless validate --json --resource-name $* datapackage.yaml > $@

build: build/ppag2023-dadosmg.zip

build/ppag2023-dadosmg.zip: datapackage.yaml $(DATA_FILES) scripts/build.py
	python scripts/build.py $< $@

clean:
	find reports -type f -name "*.json" | xargs rm
	find data -type f -name "*.csv" | xargs rm

print: 
	@echo $(TABLESCHEMA_RAW)
