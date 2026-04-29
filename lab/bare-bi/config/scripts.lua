function process_bal_logs(tag, timestamp, record)
    record["product"] = "ballerina integrator"

    -- Extract app name from path: .../myapp/app.log -> "myapp"
    if record["log_file_path"] then
        record["app_name"] = string.match(record["log_file_path"], "([^/]+)/app%.log$") or "unknown"
    else
        record["app_name"] = "unknown"
    end

    if record["module"] then
        record["app_module"] = string.match(record["module"], "^([^/]+)")
    end

    local deployment = record["app_name"]
    local moduleName = record["src.module"] or record["module"]
    if moduleName then
        record["app"] = deployment .. " - " .. moduleName
    else
        record["app"] = deployment
    end
    record["deployment"] = deployment

    return 1, timestamp, record
end

function extract_bal_metrics_data(tag, timestamp, record)
    if record["logger"] ~= "metrics" then
        return 1, timestamp, record
    end

    local transport = record["protocol"] or "Unknown"
    local integration = record["src.object.name"] or "Unknown"

    if record["src.main"] == "true" then
        integration = "main"
    end

    local sublevel = record["entrypoint.function.name"] or ""
    local method = record["http.method"] or ""
    local response_time = record["response_time_seconds"] or 0
    local status = "successful"

    if record["http.status_code_group"] == "4xx" or record["http.status_code_group"] == "5xx" then
        status = "failed"
    end

    response_time = response_time * 1000
    response_time = math.floor(response_time + 0.5)

    record["response_time"] = response_time
    record["status"] = status
    record["protocol"] = transport
    record["integration"] = integration
    record["sublevel"] = sublevel
    record["method"] = method
    record["url"] = record["http.url"] or ""
    record["status_code_group"] = record["http.status_code_group"] or ""

    return 1, timestamp, record
end

function simple_hash(str)
    local hash1 = 0
    for i = 1, #str do
        hash1 = (hash1 * 31 + string.byte(str, i)) % 2147483647
    end

    local hash2 = 5381
    for i = 1, #str do
        hash2 = (hash2 * 37 + string.byte(str, i)) % 2147483647
    end

    return string.format("%08x%08x", hash1, hash2)
end

function generate_document_id(tag, timestamp, record)
    local timestamp_str
    if record["time"] then
        timestamp_str = tostring(record["time"])
    elseif type(timestamp) == "table" then
        timestamp_str = string.format("%d.%09d", timestamp.sec or timestamp[1] or 0, timestamp.nsec or timestamp[2] or 0)
    else
        timestamp_str = tostring(timestamp)
    end

    local message = record["message"] or ""
    local level = record["level"] or ""
    local log_file_path = record["log_file_path"] or ""

    local delimiter = string.char(31)
    local composite = timestamp_str .. delimiter .. message .. delimiter .. level .. delimiter .. log_file_path

    record["doc_id"] = simple_hash(composite)
    return 1, timestamp, record
end
