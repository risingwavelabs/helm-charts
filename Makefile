HELM_CHARTS=$(shell ls charts)
#INCUBATING_HELM_CHARTS=$(shell ls incubating/charts)

lint:
	# for each in $(HELM_CHARTS) and $(INCUBATING_HELM_CHARTS), do helm lint
	$(foreach chart,$(HELM_CHARTS),helm lint charts/$(chart);)
	#$(foreach chart,$(INCUBATING_HELM_CHARTS),helm lint incubating/charts/$(chart);)

test:
	$(foreach chart,$(HELM_CHARTS),helm unittest charts/$(chart);)

sync-crds:
	./scripts/sync-crds.sh charts/risingwave-operator/crds

sanitize:
	@./scripts/sanitize.sh
