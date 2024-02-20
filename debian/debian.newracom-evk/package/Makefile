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
RM = rm -f
MKDIR = mkdir -p
DIRS_LIST = /lib/firmware ${KDIR}/extra /usr/bin /boot/overlays

.PHONY: install all

all:
	@echo "use the isntall target instead."

dirs:
	@for dir in $(addprefix ${BUILD_DIR}, ${DIRS_LIST}) ; do ${MKDIR} $${dir}; done

install: dirs dtb
	cp -a debian ${BUILD_DIR}
	cp ${evk_bindir}/nrc7292_bd.dat ${evk_bindir}/nrc7292_cspi.bin ${BUILD_DIR}/lib/firmware
	cp ${evk_bindir}/cli_app ${BUILD_DIR}/usr/bin

build:
	cd ${BUILD_DIR} && dpkg-buildpackage -b

clean: clean_dtb
	@[ ! -f ${DEB} ] || ${RM} $$(ar -t ${DEB})
	@[ ! -f ${BUILD_DIR}/debian/files ] || ${RM} $$(awk '{print $$1}' ${BUILD_DIR}/debian/files)
	@${RM} -r ${BUILD_DIR} ; ${RM} *.changes *.deb
# VERSION-SDK

nrc: dirs
	@make -C src/nrc KDIR=${KDIR} && cp src/nrc/nrc.ko ${BUILD_DIR}${KDIR}

boot_dir:
	@${MKDIR} ${BUILD_DIR}/boot/overlays

clean_dtb:
	@${RM} *.dtb

dtb: TARGET_DIR=${BUILD_DIR}/boot/overlays
dtb: boot_dir
	dtc -I dts -O dtb ../dts/newracom_for_5.16_or_later.dts -o ${TARGET_DIR}/newracom_overlay.dtb
