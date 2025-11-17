$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call image-target,stage2,$(llvm))))
