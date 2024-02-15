#
#
# Copyright (C) IoAire Inc, All rights Reserved. [brees@ioaire.com]
#
#

packageName = newracom-evk
packageVersion = 1.5.nrc7292
packageArch = arm
BUILD_DIR = ${packageName}-${packageVersion}
DEB = ${packageName}_${packageVersion}_all.deb
.PHONY: install all

all:
	@echo "use the isntall target instead."

install:
	mkdir -p ${BUILD_DIR}
	cp -a debian ${BUILD_DIR}

build:
	cd ${BUILD_DIR} && dpkg-buildpackage -b

clean:
	@[ ! -f ${DEB} ] || rm -f $$(ar -t ${DEB})
	@[ ! -f ${BUILD_DIR}/debian/files ] || rm -f $$(awk '{print $$1}' ${BUILD_DIR}/debian/files)
	@rm -rf ${BUILD_DIR} ; rm -f  *.changes *.deb
