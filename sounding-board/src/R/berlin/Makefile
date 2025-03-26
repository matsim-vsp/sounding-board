# Makefile - kreuschner-mar2025

BERLIN2035_PATH := $(HOME)/git/public-svn/shared/sounding-board/berlin-2035/
BERLIN2045_PATH := $(HOME)/git/public-svn/shared/sounding-board/berlin-2045/
SVN := /opt/homebrew/bin/svn

.PHONY: default current

default:
	@echo "Running Berlin 2035 pipeline..."
	-rm -f $(BERLIN2035_PATH)berlin-2035-dashboard-v1.0.csv
	Rscript --default-packages=tidyr --verbose berlin2035-dashboard-privaterPersonenverkehr-v1.0.R
	#mv berlin-2035-dashboard-v1.0.csv $(BERLIN2035_PATH)
	cd $(BERLIN2035_PATH) && $(SVN) update && $(SVN) commit -m "commit new version"

current:
	@echo "Running Berlin 2045 pipeline..."
	Rscript --default-packages=tidyr --verbose berlin2045-dashboard-privaterPersonenverkehr-v1.0.R
	-rm -f $(BERLIN2045_PATH)berlin-2045-dashboard-v1.0.csv
	mv berlin-2045-dashboard-v1.0.csv $(BERLIN2045_PATH)
	cd $(BERLIN2045_PATH) && $(SVN) update && $(SVN) commit -m "commit new version"
