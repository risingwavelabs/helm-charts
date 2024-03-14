HELM_CHARTS=$(shell ls charts)

helm-dependency-update:
	@$(foreach chart,$(HELM_CHARTS),helm dependency update charts/$(chart);)

lint:
	# for each in $(HELM_CHARTS), do helm lint
	@$(foreach chart,$(HELM_CHARTS),helm lint --strict --set tags.bundle=true charts/$(chart);)
	#$(foreach chart,$(INCUBATING_HELM_CHARTS),helm lint incubating/charts/$(chart);)

test:
	# for each in $(HELM_CHARTS), do helm unittest
	@$(foreach chart,$(HELM_CHARTS),helm unittest --strict -f 'tests/**/*_test.yaml' charts/$(chart);)

define test-uncommitted-for-chart
	$(eval uncommitted_files := $(shell git diff --name-status head -- charts/$(1)/tests | grep -v '^D' | awk '{print $$NF}' | sed -e "s/charts\/$(1)\///g"))
	if [ "$(uncommitted_files)" != "" ]; then \
		helm unittest --strict $(addprefix -f ,$(uncommitted_files)) charts/$(1); \
	fi
endef

.PHONY: test-uncommitted
test-uncommitted: $(UNCOMMITTED_TEST_FILES)
	@$(foreach chart,$(HELM_CHARTS),$(call test-uncommitted-for-chart,$(chart)))

sync-crds:
	./scripts/sync-crds.sh charts/risingwave-operator/crds

sanitize:
	@./scripts/sanitize.sh

# A literal space.
space :=
space +=

# Joins elements of the list in arg 2 with the given separator.
#   1. Element separator.
#   2. The list.
join-with = $(subst $(space),$1,$(strip $2))
strip-prefix = $(subst $2,,$1)
