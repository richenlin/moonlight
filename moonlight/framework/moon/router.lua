-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

module('moon.router',package.seeall);

require 'moon.functional';
require 'moon.vars';
require 'moon.util';

local string_match = string.match;
local table_insert = table.insert;
local table_sort   = table.sort;

function route_sorter(luri, ruri)
    if #luri==#ruri then
        return luri < ruri;
    else
        return #luri > #ruri;
    end
end

function _map(route_table, route_order, uri, func_name)
    local mod_name, fn = string_match(func_name, '^(.+)%.([^.]+)$');

    local mod = app.controller(mod_name);

    local func = mod[fn]
    if func then
        route_table[uri] = func;
        table_insert(route_order, uri);
        -- table_sort(route_order, route_sorter) -- sort when merge!
    else
        local error_info = "MoonLight URL Mapping Error:[" .. uri .. "=>" .. func_name .. "] function or controller not found in module: " .. mod_name;
        ngx.status = 500;
        ngx.say(error_info);
        ngx.log(ngx.ERR, error_info);
    end
end

function map(route_table, route_order, uri, func_name)
    local ret, err = pcall(_map, route_table, route_order, uri, func_name);
    if not ret then
        local error_info = "MoonLight URL Mapping Error:[" .. uri .. "=>" .. func_name .. "] " .. err;
        ngx.status = 500;
        ngx.say(error_info);
        ngx.log(ngx.ERR, error_info);
    end
end

function setup()
    local app_name = getfenv(2).__CURRENT_APP_NAME__;
    local main_app = getfenv(2).__MAIN_APP_NAME__;
    if app_name ~= main_app then
        app_name = main_app .. ">" .. app_name;
    end
    if not moon.vars.get(app_name,"ROUTE_INFO") then
        moon.vars.set(app_name,"ROUTE_INFO",{});
    end
    if not moon.vars.get(app_name,"ROUTE_INFO")['ROUTE_MAP'] then
        moon.vars.get(app_name,"ROUTE_INFO")['ROUTE_MAP'] = {};
        moon.vars.get(app_name,"ROUTE_INFO")['ROUTE_ORDER'] = {};
    end
    moon.vars.get(app_name, "ROUTE_INFO")['map'] = moon.functional.curry(
        map,
        moon.vars.get(app_name,"ROUTE_INFO")['ROUTE_MAP'],
        moon.vars.get(app_name,"ROUTE_INFO")['ROUTE_ORDER']
    );

    moon.vars.get(app_name,"ROUTE_INFO")['get_config'] = moon.util.get_config;
        
    setfenv(2, moon.vars.get(app_name, "ROUTE_INFO"));
end

function merge_routings(main_app, subapps)
    local main_routings=moon.vars.get(main_app,"ROUTE_INFO")['ROUTE_MAP'];
    local main_routings_order=moon.vars.get(main_app,"ROUTE_INFO")['ROUTE_ORDER'];
    for k,_ in pairs(subapps) do
        local expanded_key = main_app .. ">" .. k;
        local sub_routings=moon.vars.get(expanded_key,"ROUTE_INFO")['ROUTE_MAP'];
        for sk,sv in pairs(sub_routings) do main_routings[sk]=sv end;
        local sub_routings_order=moon.vars.get(expanded_key,"ROUTE_INFO")['ROUTE_ORDER'];
        for _,sv in ipairs(sub_routings_order) do table_insert(main_routings_order,sv) end;
    end
    table_sort(main_routings_order, route_sorter);
end

