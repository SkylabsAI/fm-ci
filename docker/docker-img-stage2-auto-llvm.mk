$(foreach llvm,$(LLVM_VERSIONS),\
	$(eval $(call llvm-img-target,stage2,$(llvm))))
