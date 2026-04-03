BAL := $(abspath $(shell ls -d downloads/ballerina-*/bin/bal 2>/dev/null | sort -V | tail -1))
ifeq ($(BAL),)
  $(error bal not found in ./downloads)
endif

include make/deps.mk

.PHONY: icp bi mi start stop reset

start stop reset:
	@./make/lifecycle.sh $@ $(word 2,$(MAKECMDGOALS))

# swallow the env name passed as second arg to start/stop/reset
ifneq ($(filter start stop reset,$(MAKECMDGOALS)),)
%:
	@:
endif

icp: .stamps/icp
bi:  .stamps/bi
mi:  .stamps/mi

.stamps/icp: $(ICP_SRCS)
.stamps/bi:  $(BI_SRCS)
.stamps/mi:  $(MI_SRCS)

.stamps/icp: CMD = cd icp && PATH='$(dir $(BAL)):$$PATH' ./gradlew clean build && mv build/distribution/wso2-integration-control-plane-*.zip ../dist/
.stamps/bi:  CMD = cd bi/app && $(BAL) build && mv target/bin/icp.jar ../../dist/
.stamps/mi:  CMD = cd mi && mvn clean install -DskipTests && mv distribution/target/wso2mi-*.zip ../dist/

.stamps dist:
	@mkdir -p $@

.stamps/%: | .stamps dist
	@make/logged-run.sh $* "$(CMD)"
	@touch $@
