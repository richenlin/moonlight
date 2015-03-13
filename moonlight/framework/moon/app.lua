-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

local string_match   = string.match;
local package_loaded = package.loaded;

local _M = { _VERSION = '0.01'};

moon_vars = nil;
moon_debug = nil;
moon_util = nil;

function init()
	-- get/set the inited flag for app_name
    local r_G = _G;
    local mt = getmetatable(_G);
    if mt then
        r_G = rawget(mt, "__index");
    end

    r_G.APP_NAME = ngx.var.MOON_APP_NAME;

    r_G.MOON_APP_PATH = ngx.var.MOON_APP_PATH;
    r_G.MOON_PATH = MOON_APP_PATH .. 'framework/';

    r_G.APP_PATH = MOON_APP_PATH .. 'app/';

    package.path = MOON_PATH .. '/?.lua;'.. package.path;

    ngx.header.content_type = "text/plain";

    r_G.app = require('moon.loader');

end


function _M.run()
    -- 初始化
    init();

    moon_vars = require("moon.vars");
    moon_util = require("moon.util");

    local request=require("moon.request");
    local response=require("moon.response");

    -- 加载配置
    local config = moon_util.loadvars(APP_PATH .. 'config/conf.lua');
    if not config then config={} end;
    moon_vars.set(APP_NAME,"APP_CONFIG",config);

    -- 调试模式
    moon_debug = require("moon.debug");
    if config.debug and config.debug.on and moon_debug then
        debug.sethook(moon_debug.debug_hook, "cr");
    end

    -- 加载路由
    local env = setmetatable({__CURRENT_APP_NAME__ = APP_NAME,
                              __MAIN_APP_NAME__ = APP_NAME},
                             {__index = _G})
    setfenv(assert(loadfile(MOON_APP_PATH .. "/routing.lua")), env)();
    
    local uri         = ngx.var.REQUEST_URI;
    local ngx_ctx     = ngx.ctx
    local route_map   = moon_vars.get(APP_NAME, "ROUTE_INFO")['ROUTE_MAP'];
    local route_order = moon_vars.get(APP_NAME, "ROUTE_INFO")['ROUTE_ORDER'];
    local page_found  = false;

    -- 路由映射
    for _, k in ipairs(route_order) do
        local args = {string_match(uri, k)};
        if args and #args>0 then
            page_found = true;
            local v = route_map[k];

            local requ = request.Request:new();
            local resp = response.Response:new();
            ngx_ctx.request  = requ;
            ngx_ctx.response = resp;

            if type(v) == "function" then                
                if moon_debug then moon_debug.debug_clear() end;
                local ok, ret = pcall(v, requ, resp, unpack(args));
                if not ok then resp:error(ret) end;
                resp:finish();
                resp:do_defers();
                resp:do_last_func();
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args));
            else
                ngx.exit(500);
            end
            break;
        end
    end

    if not page_found then
        ngx.exit(404);
    end
end

return _M;