BAL := $(abspath $(shell ls -d downloads/ballerina-*/bin/bal 2>/dev/null | sort -V | tail -1))
ifeq ($(BAL),)
  $(error bal not found in ./downloads)
endif

include make/deps.mk

.PHONY: env-native icp bi mi

run-env-native: .stamps/icp .stamps/bi .stamps/mi
	@make/logged-run.sh opensearch \
	  "docker compose -f icp/icp_server/docker-compose.observability.yml up -d --quiet-pull opensearch"

icp: .stamps/icp
bi:  .stamps/bi
mi:  .stamps/mi

.stamps/icp: $(ICP_SRCS)
.stamps/bi:  $(BI_SRCS)
.stamps/mi:  $(MI_SRCS)

.stamps/icp: CMD = cd icp && PATH='$(dir $(BAL)):$$PATH' ./gradlew clean build
.stamps/bi:  CMD = cd bi/app && $(BAL) build
.stamps/mi:  CMD = cd mi && mvn clean install -DskipTests

.stamps:
	@mkdir -p $@

.stamps/%: | .stamps
	@make/logged-run.sh $* "$(CMD)"
	@touch $@
