TMP=tmp
PS_VERSION=6.1.0
POSH_GIT_VERSION=v1.0.0-beta3

.PHONY: clean clean-test test

test: $(TMP)/powershell/pwsh $(TMP)/posh-git/README.md
	./git-prompt-test.sh

clean:
	rm -rf $(TMP)

clean-test:
	rm -rf $(TMP)/test-scratch

$(TMP):
	mkdir -p $@

$(TMP)/powershell.tar.gz: | $(TMP)
	curl -L -o $@ https://github.com/PowerShell/PowerShell/releases/download/v$(PS_VERSION)/powershell-$(PS_VERSION)-linux-x64.tar.gz

$(TMP)/powershell:
	mkdir -p $@

$(TMP)/powershell/pwsh: $(TMP)/powershell.tar.gz | $(TMP)/powershell
	tar zxf $(TMP)/powershell.tar.gz -C $(TMP)/powershell/
	touch $@

$(TMP)/posh-git:
	mkdir -p $@

$(TMP)/posh-git/README.md: | $(TMP)/posh-git
	[ -e $@ ] || git clone --branch $(POSH_GIT_VERSION) https://github.com/dahlbyk/posh-git $(dir $@)
	touch $@
