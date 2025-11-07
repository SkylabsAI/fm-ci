run-fm-%: fm-% FORCE
	@echo "[DOCKER] Running $<"
	$(Q)docker run -i -t $(DOCKER_REPO):$<

push-fm-%: fm-% FORCE
	@echo "[DOCKER] Pushing $<"
ifeq ($(I_KNOW_WHAT_I_AM_DOING),yes)
	@echo "(Let's hope you did not mess anything up...)"
	$(Q)docker push $(DOCKER_REPO):$<
else
	@echo "The command that would run would be:"
	@echo "  docker push $(DOCKER_REPO):$<"
	@echo -e $(call color,$(CYAN),Use I_KNOW_WHAT_I_AM_DOING=yes to actually run it)
endif
