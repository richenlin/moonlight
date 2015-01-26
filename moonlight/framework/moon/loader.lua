-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

module('moon.loader',package.seeall);

local filehelper = require ("library.file");

local setmetatable = setmetatable;
local pcall = pcall;
local assert = assert;
local loadfile = loadfile;
local type = type;
local setfenv = setfenv;
local concat = table.concat;
local fexists = filehelper.exists;
local fread_all = filehelper.read_all;

local _G = _G;

local cache_module = {};

local function _get_cache(module)
    local appname = APP_NAME;
    return cache_module[appname] and cache_module[appname][module];
end

local function _set_cache(name, val)
    local appname = APP_NAME;
    if not cache_module[appname] then
        cache_module[appname] = {};
    end
    cache_module[appname][name] = val;
end

local function _load_module(dir, name)
    local pathname = MOON_APP_PATH .. dir .. '/';
    package.path = pathname .. '?.lua;'.. package.path;

    local filename = _get_cache(name);
    
    if filename == nil then
        filename = pathname .. name .. ".lua";
        _set_cache(name, filename);
    end
    if fexists(filename) then
        return require (name);
    end
end

function moon(filename)
    return _load_module("framework/moon", filename);
end

function controller(filename)
    return _load_module("app/controller", filename);
end

function model(mod, ...)
    local m = _load_module("app/model", mod)
    return m and type(m.new) == "function" and m:new(...) or m;
end

function config(conf)
    return _load_module("app/config", conf);
end

function library(lib)
    return _load_module("framework/library", lib);
end

return _M;
