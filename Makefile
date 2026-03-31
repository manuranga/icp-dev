BAL := $(abspath $(shell ls -d downloads/ballerina-*/bin/bal 2>/dev/null | sort -V | tail -1))

include make/deps.mk

.PHONY: env-native build-icp build-bi build-mi

env-native: .stamps/icp .stamps/bi .stamps/mi
	docker compose -f icp/icp_server/docker-compose.observability.yml up -d opensearch

build-icp: .stamps/icp
build-bi:  .stamps/bi
build-mi:  .stamps/mi

.stamps/icp: $(ICP_SRCS)
	make/logged-run.sh icp "cd icp && PATH='$(dir $(BAL)):$$PATH' ./gradlew clean build"
	@mkdir -p .stamps && touch $@

.stamps/bi: $(BI_SRCS)
	make/logged-run.sh bi "cd bi/app && $(BAL) build"
	@mkdir -p .stamps && touch $@

.stamps/mi: $(MI_SRCS)
	make/logged-run.sh mi "cd mi && mvn clean install -DskipTests"
	@mkdir -p .stamps && touch $@
