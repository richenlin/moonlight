-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

module("api", package.seeall)
local JSON = require("cjson")
local resty_http = require ("resty.http")
local resty_base64 = require ("resty.base64")
local Redis = app.library("redis")

function index(req, resp)
	local cache = nil
	local project = nil
    local object = nil
    local action = nil
    local apiuri = nil

    cache = req:get_args("cache")
    project = req:get_args("project")
    object = req:get_args("object")
	action = req:get_args("action")

	apiuri = string.format("Api-%s-%s-%s", project, object, action);
	local urls = Redis.get(apiuri)

	--resp:writeln(urls)
	--return
	if moon_util.empty(urls) then
		ngx.status = 404
		return
	end

	local hc = resty_http:new()
	local ok, code, headers, status, body  = hc:proxy_pass {
	    url = urls,
	    fetch_size = 1024, -- 分段大小
	    max_body_size = 100*1024*1024 ,  --响应体的最大大小.
	    headers = ngx.req.get_headers(), -- 传递客户端的参数,可以根据需要进行修改哦.
	    method = ngx.var.request_method, -- 真实还原客户端的请求方法,当然,你可以改!!
	}
	if not ok and not ngx.headers_sent then
	    ngx.exit(502) -- 出错了哦? 这里只是简单遵循了nginx在后端报错时的响应,你完全可以实现自己的逻辑,进行错误处理
	else
	    ngx.eof()
	end
end