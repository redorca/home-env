

#
# The file name is in a format to specify what
# filename should this template be copied to,
# what zeus architecture the build is based on,
# and what build to run.
#
# config ==> .config
# zeus1  ==>  zeus1 arch zeus target
# zeus2  ==>  zeus2 arch zeus target
# sim    ==>  sim target for given zeus arch.
#
CONFIG_TEMPLATES = $(shell ls config.zeus*.* 2>/dev/null)

ifeq ($(CONFIG_TEMPLATES),)
$(error Empty config templates)
endif
PROG_NAME = mkfast

help:
	@echo ""
	@echo "\tTargets supported: $(PROG_NAME), clean, print."
	@echo ""
	@echo "\tMake a self-installing shell script for test building"
	@echo "\tthe fast code."
	@echo ""
	@echo "\tmake mkfast\" will create a shell script based on mkfast"
	@echo "\tthat contains a tar file of config.zeus* appended to it."
	@echo ""
	@echo ""


$(PROG_NAME): %:%.tgz
$(PROG_NAME): %:%.sh
	$(Q) cp $@.sh $@ && chmod +x $@
	$(Q) xxd $@.tgz >> $@
#	$(Q) cat $@.tgz >> $@

%.tgz: $(CONFIG_TEMPLATES)
	$(Q) tar -zcf $@ $(CONFIG_TEMPLATES)

print:
	@echo "Variables used by make:"
	@echo ""
	@echo "CONFIG_TEMPLATES\t$$(echo $(CONFIG_TEMPLATES) | sed -e 's/ /\\n\\t\\t\\t/g')"
	@echo ""
	@echo "PROG_NAME\t\t$(PROG_NAME)"
	@echo ""

clean:
	@$(RM) $(PROG_NAME) $(PROG_NAME:%=%.tgz)

