ICP_SRCS := $(shell find icp/icp_server -type f \( -name '*.bal' -o -name '*.toml' -o -name '*.graphql' \) 2>/dev/null) \
            $(shell find icp/frontend/src -type f 2>/dev/null)
BRIDGE_SRCS := $(shell find bridge/ballerina -type f \( -name '*.bal' -o -name '*.toml' \) 2>/dev/null) \
              $(shell find bridge/native/src -type f -name '*.java' 2>/dev/null)
MI_SRCS  := $(shell find mi/components mi/features -type f \( -name '*.java' -o -name '*.xml' \) 2>/dev/null)
