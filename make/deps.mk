ICP_SRCS := $(shell find icp/icp_server -type f \( -name '*.bal' -o -name '*.toml' -o -name '*.graphql' \) 2>/dev/null) \
            $(shell find icp/frontend/src -type f 2>/dev/null)
BI_SRCS  := $(shell find bi/app -type f -name '*.bal')
MI_SRCS  := $(shell find mi/components mi/features -type f \( -name '*.java' -o -name '*.xml' \) 2>/dev/null)
