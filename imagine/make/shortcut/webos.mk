include $(IMAGINE_PATH)/make/webos-metadata.mk
webOS_targetPath := target/webOS

# executables

ifndef config_webOS_noArmv6

webOS_armv6Exec := $(webOS_targetPath)/bin-debug/armv6
webos-armv6 :
	$(MAKE) -f webos-armv6.mk
$(webOS_armv6Exec) : webos-armv6

webOS_armv6ReleaseExec := $(webOS_targetPath)/bin-release/armv6
webos-armv6-release :
	$(MAKE) -f webos-armv6-release.mk
$(webOS_armv6ReleaseExec) : webos-armv6-release

endif

ifndef config_webOS_noArmv7

webOS_armv7Exec := $(webOS_targetPath)/bin-debug/armv7
webos-armv7 :
	$(MAKE) -f webos-armv7.mk
$(webOS_armv7Exec) : webos-armv7

webOS_armv7ReleaseExec := $(webOS_targetPath)/bin-release/armv7
webos-armv7-release :
	$(MAKE) -f webos-armv7-release.mk
$(webOS_armv7ReleaseExec) : webos-armv7-release

endif

webos-build : $(webOS_armv6Exec) $(webOS_armv7Exec)
webos-release : $(webOS_armv6ReleaseExec) $(webOS_armv7ReleaseExec)

# metadata

webOS_appInfoJson := $(webOS_targetPath)/app/appinfo.json
$(webOS_appInfoJson) : metadata/conf.mk $(metadata_confDeps)
	@mkdir -p $(@D)
	bash $(IMAGINE_PATH)/tools/genWebOSMeta.sh $(webOS_gen_metadata_args) $@
webos-metadata : $(webOS_appInfoJson)

# IPKs

webOS_ipk := $(webOS_targetPath)/ipk-debug/$(webOS_metadata_id)_$(webOS_metadata_version)_all.ipk
$(webOS_ipk) : $(webOS_appInfoJson) $(webOS_armv7Exec) $(webOS_armv6Exec) $(webOS_targetPath)/bin-debug
	cp $(webOS_armv7Exec) $(webOS_armv6Exec) $(webOS_targetPath)/app
	@mkdir -p $(webOS_targetPath)/ipk-debug
	palm-package -o $(webOS_targetPath)/ipk-debug $(webOS_targetPath)/app
webos-ipk : $(webOS_ipk)

webOS_ipkRelease := $(webOS_targetPath)/ipk-release/$(webOS_metadata_id)_$(webOS_metadata_version)_all.ipk
$(webOS_ipkRelease) : $(webOS_appInfoJson) $(webOS_armv7ReleaseExec) $(webOS_armv6ReleaseExec) $(webOS_targetPath)/bin-release
	cp $(webOS_armv7ReleaseExec) $(webOS_armv6ReleaseExec) $(webOS_targetPath)/app
	@mkdir -p $(webOS_targetPath)/ipk-release
	palm-package -o $(webOS_targetPath)/ipk-release $(webOS_targetPath)/app
webos-release-ipk : $(webOS_ipkRelease)

webos-install : $(webOS_ipk)
	palm-install $<

webos-release-install : $(webOS_ipkRelease)
	palm-install $<

webos-release-ready : 
	cp $(webOS_ipkRelease) ../releases-bin/webOS/

.PHONY: webos-metadata webos-armv6 webos-armv7 webos-armv6-release webos-armv7-release webos-release webos-ipk webos-release-ipk webos-release-install webos-install webos-release-ready
