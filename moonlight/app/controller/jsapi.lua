-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

module("jsapi", package.seeall);
local JSON = require("cjson")
local resty_http = require ("resty.http")
local resty_base64 = require ("resty.base64")
local Redis = app.library("redis")

function index(req, resp)
	local param = nil;
	local cache = nil;
	local result = nil;

	param = req:get_args("param")

	-- resp:writeln(resty_base64.base64_encode("http://op.juhe.cn/che300/query?key=bc56b7bf205a77e6a854c6e3bfb6e418&dtype=json&method=getBrandList"))
	-- aHR0cDovL29wLmp1aGUuY24vY2hlMzAwL3F1ZXJ5P2tleT1iYzU2YjdiZjIwNWE3N2U2YTg1NGM2ZTNiZmI2ZTQxOCZkdHlwZT1qc29uJm1ldGhvZD1nZXRCcmFuZExpc3Q=
	
	if moon_util.empty(param) then ngx.exit(404) end
	local redis_key = ngx.md5(param)

	param = resty_base64.base64_decode(param)
	cache = req:get_args("cache")

	if moon_util.empty(param) then ngx.exit(404) end

	if moon_util.empty(cache) then
		--无需缓存
		result = jsapi_proxy(param)
	else
		result = Redis.get(redis_key);
		if moon_util.empty(result) then
			result = jsapi_proxy(param)
			Redis.set(redis_key,result,36000)
		end
	end

	resp:writeln(result)

end

function jsapi_proxy(urls)
 	local hc = resty_http:new()
    local ok, code, headers, status, body  = hc:request({
        url = urls,
        --- proxy = "http://127.0.0.1:8888",
        --- timeout = 3000,
        headers = { UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36"}
    })
	return body
end

function jsapi_get(req, resp)
	local k = req:get_args("k")
	if moon_util.empty(k) then ngx.exit(404) end
	resp:writeln(Redis.get("JsApi-"..k))
end

function jsapi_put(req, resp)
	local k = req:get_args("k")
	local v = req:get_args("v")
	if moon_util.empty(k) then ngx.exit(403) end
	resp:writeln(Redis.set("JsApi-"..k,v,36000))
end