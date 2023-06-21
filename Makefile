.PHONY: all extract transform

RESOURCES := $(shell yq e '.resources[].name' datapackage.yaml)
EXTRACT_LOG_FILES := $(addsuffix .txt,$(addprefix logs/data/raw/,$(RESOURCES)))
DATA_FILES := $(addsuffix .csv,$(addprefix data/,$(RESOURCES)))

all: extract transform ## Run the complete data pipeline

extract: $(EXTRACT_LOG_FILES) ## Extract raw files from source system over network and stores locally in data/raw/

$(EXTRACT_LOG_FILES): logs/data/raw/%.txt:
	python scripts/extract.py $* 2>&1 | tee $@

transform: $(DATA_FILES) ## Transform raw data from data/raw and save under data/

$(DATA_FILES): data/%.csv: data/raw/%.txt schemas/%.yaml scripts/transform.py datapackage.yaml
	python scripts/transform.py $*

check: checks-python

checks-python:
	python -m pytest checks/python/
