

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
CONFIG_TEMPLATES  = config.zeus1.zeus
CONFIG_TEMPLATES += config.zeus1.sim
CONFIG_TEMPLATES += config.zeus2.zeus
CONFIG_TEMPLATES += config.zeus2.sim

help:
	@echo ""
	@echo "\tMake a self-installing shell script for test building"
	@echo "\tthe fast code."
	@echo ""
	@echo "\tmake mkfast\" will create a shell script based on mkfast"
	@echo "\tthat contains a tar file of config.zeus* appended to it."
	@echo ""
	@echo ""


mkfast: mkfast.sh mkfast.tgz
	@cp $@.sh $@ && chmod +x $@
	@cat $@.tgz >> $@

mkfast.tgz: $(CONFIG_TEMPLATES)
	@tar -zcvf $@ $(CONFIG_TEMPLATES)

