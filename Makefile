.PHONY: all extract transform check publish

RESOURCE_NAMES := $(shell yq e '.resources[].name' datapackage.yaml)
DATA_FILES := $(addsuffix .csv,$(addprefix data/,$(RESOURCE_NAMES)))

all: extract transform check publish

extract: 
	$(foreach resource_name, $(RESOURCE_NAMES), python scripts/extract.py $(resource_name);)

transform: $(DATA_FILES)

$(DATA_FILES): data/%.csv: data/raw/%.txt schemas/%.yaml scripts/transform.py datapackage.yaml
	python scripts/transform.py $*

check: checks-python

checks-python:
	python -m pytest checks/python/

publish: 
	git add -Af data/*.csv
	git commit --author="Automated <actions@users.noreply.github.com>" -m "Update data package" || exit 0
	git push
