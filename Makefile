
ALGOLIA_APP_ID ?= FILL_ALGOLIA_APP_ID
ALGOLIA_API_KEY ?= FILL_ALGOLIA_API_KEY
ALGOLIA_ADMIN_API_KEY ?= FILL_ALGOLIA_ADMIN_API_KEY

.PHONY: build
build: antora-ui/build/ui-bundle.zip
	@bash -c "trap 'docker-compose -p antora-in-action-plantuml-server -f antora-plantuml/server.yml down || true;' EXIT; $(MAKE) .build"

.PHONY: .build
.build:
	@mkdir -p docs/_images; rm -r docs/_images
	@touch docs/.nojekyll
	docker-compose -p antora-in-action-plantuml-server -f antora-plantuml/server.yml up -d
	PLANTUML_SERVER_PORT=`docker-compose -p antora-in-action-plantuml-server -f antora-plantuml/server.yml port plantuml-server 8080 | cut -f2 -d':'` ; \
		docker run \
			--network="host" \
			-v $(shell pwd):/antora \
			-e ALGOLIA_APP_ID="$(ALGOLIA_APP_ID)" \
			-e ALGOLIA_API_KEY="$(ALGOLIA_API_KEY)" \
			-e ALGOLIA_INDEX_NAME="antora-in-action" \
			--rm \
			rlespinasse/antora-plantuml \
				--pull \
				--stacktrace site.yml \
				--attribute plantuml-server-url=http://localhost:$$PLANTUML_SERVER_PORT
	find docs/_images/* -name "*.png" | sed "s/docs\///" | while read -r img; do echo "move $$img"; file=$$(grep -nr $$img . | sed 's/:.*//;s/^\.\///');folder=$$(dirname "$$file"); mkdir -p $$folder/_images; mv docs/$$img $$folder/_images/; echo "  to $$folder/_images"; done
	rm -rf docs/_images
	
antora-ui/build/ui-bundle.zip:
	cd antora-ui/; bash ./pack-zip.sh

.PHONY: launch
launch:
	open docs/index.html

.PHONY: full
full-build: clean antora-plantuml build

.PHONY: clean
clean:
	rm -f antora-ui/build/ui-bundle.zip
	rm -rf docs

.PHONY: antora-ui-deps
antora-ui-deps:
	cd antora-ui/; bash ./install-deps.sh

.PHONY: antora-plantuml
antora-plantuml:
	docker build --pull -t rlespinasse/antora-plantuml antora-plantuml

.PHONY: scrap-documentation
scrap-documentation:
	docker run \
		-e APPLICATION_ID="$(ALGOLIA_APP_ID)" \
		-e API_KEY="$(ALGOLIA_ADMIN_API_KEY)" \
		-e CONFIG="`cat config.json`" \
		-t --rm algolia/documentation-scrapper \
		/root/run

