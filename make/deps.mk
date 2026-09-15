# Dependencies.toml is rewritten by every `bal build`; including it would make each build stale itself
ICP_SRCS := $(shell find icp/icp_server -type f \( -name '*.bal' -o -name '*.toml' -o -name '*.graphql' \) ! -name 'Dependencies.toml' 2>/dev/null) \
            $(shell find icp/frontend/src -type f 2>/dev/null)
BRIDGE_SRCS := $(shell find bridge/ballerina -type f \( -name '*.bal' -o -name '*.toml' \) ! -name 'Dependencies.toml' 2>/dev/null) \
              $(shell find bridge/native/src -type f -name '*.java' 2>/dev/null)
WORKFLOW_SRCS := $(shell find workflow/ballerina -type f \( -name '*.bal' -o -name '*.toml' \) ! -name 'Dependencies.toml' 2>/dev/null) \
                 $(shell find workflow/native/src workflow/compiler-plugin/src -type f -name '*.java' 2>/dev/null)
MI_SRCS  := $(shell find mi/components mi/features -type f \( -name '*.java' -o -name '*.xml' \) 2>/dev/null)
