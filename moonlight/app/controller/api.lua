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
	local project = nil
    local object = nil
    local action = nil
    local apiuri = nil

	project = req:get_args("project");
	object = req:get_args("object");
	action = req:get_args("action");

	apiuri = string.format("Api-%s-%s-%s", project, object, action);

	local urls = Redis.get(apiuri)
    
	if moon_util.empty(urls) then
		Redis.set(apiuri,'')
		ngx.exit(404)
	end

	if ngx.var.args then
   		urls = urls .. '?' .. ngx.var.args
	end


	local hc = resty_http:new()
	local ok, code, headers, status, body  = hc:proxy_pass {
                url = urls,
                --- proxy = "http://127.0.0.1:8888",
                --- timeout = 3000,
                --- scheme = 'https',
                method = "POST", -- POST or GET
                headers = {["Content-Type"] = "application/x-www-form-urlencoded" },
                body = ngx.var.request_body,
            }
    
	if not ok and not ngx.headers_sent then
	    ngx.exit(502) -- 出错了哦? 这里只是简单遵循了nginx在后端报错时的响应,你完全可以实现自己的逻辑,进行错误处理
	else
	    ngx.eof()
	end
end