#
#
# Copyright (C) IoAire Inc, All rights Reserved. [brees@ioaire.com]
#
#

KDIR ?= /lib/modules/$(shell uname -r)/build
packageName = newracom-evk
packageVersion = 1.5.nrc7292
packageArch = arm
evk_bindir = evk/binary
BUILD_DIR = ${packageName}-${packageVersion}
DEB = ${packageName}_${packageVersion}_all.deb

.PHONY: install all

all:
	@echo "use the isntall target instead."

install:
	mkdir -p ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}/lib/firmware
	mkdir -p ${BUILD_DIR}${KDIR}/extra
	mkdir -p  ${BUILD_DIR}/usr/bin
	cp ${evk_bindir}/nrc.ko ${BUILD_DIR}${KDIR}/extra
	cp -a debian ${BUILD_DIR}
	cp ${evk_bindir}/nrc7292_bd.dat ${BUILD_DIR}/lib/firmware
	cp ${evk_bindir}/nrc7292_cspi.bin ${BUILD_DIR}/lib/firmware
	cp ${evk_bindir}/cli_app ${BUILD_DIR}/usr/bin

build:
	cd ${BUILD_DIR} && dpkg-buildpackage -b

clean:
	@[ ! -f ${DEB} ] || rm -f $$(ar -t ${DEB})
	@[ ! -f ${BUILD_DIR}/debian/files ] || rm -f $$(awk '{print $$1}' ${BUILD_DIR}/debian/files)
	@rm -rf ${BUILD_DIR} ; rm -f  *.changes *.deb
# VERSION-SDK
