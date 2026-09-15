BAL := $(abspath $(shell ls -d downloads/ballerina-*/bin/bal 2>/dev/null | sort -V | tail -1))
ifeq ($(BAL),)
  ifeq ($(filter setup,$(MAKECMDGOALS)),)
    $(error bal not found in ./downloads — run 'make setup')
  endif
endif

include make/deps.mk

.PHONY: setup icp icp-no-test bridge workflow mi start stop reset

setup:
	@make/setup.sh

start stop reset:
	@./make/lifecycle.sh $@ $(word 2,$(MAKECMDGOALS))

ifneq ($(filter start stop reset,$(MAKECMDGOALS)),)
%:
	@:
endif

icp:      .stamps/icp
bridge:   .stamps/bridge
workflow: .stamps/workflow
mi:       .stamps/mi

# Dist only, no tests (~25s vs ~2.5min). Never stamps, so `make icp` still runs the tested build.
icp-no-test: | dist
	@make/logged-run.sh icp-no-test "make/build-icp.sh $(BAL) 'clean packageICP'"

.stamps/icp:      $(ICP_SRCS)
.stamps/bridge:   $(BRIDGE_SRCS)
.stamps/workflow: $(WORKFLOW_SRCS)
.stamps/mi:       $(MI_SRCS)

.stamps/icp:      CMD = make/build-icp.sh $(BAL)
.stamps/bridge:   CMD = make/build-bridge.sh $(BAL)
.stamps/workflow: CMD = make/build-workflow.sh $(BAL)
.stamps/mi:       CMD = cd mi && mvn clean install -DskipTests && mv distribution/target/wso2mi-*.zip ../dist/

.stamps dist:
	@mkdir -p $@

.stamps/%: | .stamps dist
	@make/logged-run.sh $* "$(CMD)"
	@touch $@
