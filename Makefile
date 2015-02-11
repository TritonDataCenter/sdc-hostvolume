#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2015, Joyent, Inc.
#

NAME:=hostvolume

include ./tools/mk/Makefile.defs


VERSION=$(shell json -f $(TOP)/package.json version)
COMMIT=$(shell git describe --all --long  | awk -F'-g' '{print $$NF}')

RELEASE_TARBALL:=$(NAME)-pkg-$(STAMP).tar.bz2
RELSTAGEDIR:=/tmp/$(STAMP)


#
# Targets
#
.PHONY: all
all: $(SMF_MANIFESTS) | sdc-scripts

sdc-scripts: deps/sdc-scripts/.git

.PHONY: test
test:
	true

.PHONY: git-hooks
git-hooks:
	[[ -e .git/hooks/pre-commit ]] || ln -s ../../tools/pre-commit.sh .git/hooks/pre-commit


#
# Packaging targets
#

.PHONY: release
release: all
	@echo "Building $(RELEASE_TARBALL)"
	# boot
	mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -R $(TOP)/deps/sdc-scripts/* $(RELSTAGEDIR)/root/opt/smartdc/boot/
	cp -R $(TOP)/boot/* $(RELSTAGEDIR)/root/opt/smartdc/boot/
	# other bits
	mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/$(NAME)/
	cp -r \
		$(TOP)/package.json \
		$(RELSTAGEDIR)/root/opt/smartdc/$(NAME)
	# Tar
	(cd $(RELSTAGEDIR) && $(TAR) -jcf $(TOP)/$(RELEASE_TARBALL) root)
	@rm -rf $(RELSTAGEDIR)

.PHONY: publish
publish: release
	@if [[ -z "$(BITS_DIR)" ]]; then \
		@echo "error: 'BITS_DIR' must be set for 'publish' target"; \
		exit 1; \
	fi
	mkdir -p $(BITS_DIR)/$(NAME)
	cp $(TOP)/$(RELEASE_TARBALL) $(BITS_DIR)/$(NAME)/$(RELEASE_TARBALL)


include ./tools/mk/Makefile.deps
include ./tools/mk/Makefile.targ
