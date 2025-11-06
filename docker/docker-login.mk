github-login:
	@echo -n "Enter your GitHub login: "
	@read -r LOGIN; echo $$LOGIN > $@

github-token:
	@echo -e $(call color,$(CYAN),You need a GitHub personal access token (classic).)
	@echo "See https://github.com/settings/tokens."
	@echo "Select write:packages permission/scope when creating the token"
	@echo -n "Enter your personal access token: "
	@read -r TOKEN; echo $$TOKEN > $@

.PHONY: login
login: github-login github-token
	${Q}docker login -u $$(cat $<) --password-stdin $(DOCKER_REGISTRY) < github-token

.PHONY: logout
logout:
	$(Q)docker logout $(DOCKER_REGISTRY)

.PHONY: clean-token
clean-token:
	$(Q)rm -f gitlab-token gitlab-login
