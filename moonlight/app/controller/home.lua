-- +----------------------------------------------------------------------
-- | MoonLight
-- +----------------------------------------------------------------------
-- | Copyright (c) 2015
-- +----------------------------------------------------------------------
-- | Licensed CC BY-NC-ND
-- +----------------------------------------------------------------------
-- | Author: Richen <ric3000(at)163.com>
-- +----------------------------------------------------------------------

module("home", package.seeall);
local JSON = require("cjson")

function index(req, resp)
	-- local x = moon_util.get_config('config')
	-- resp.headers['Content-Type'] = 'application/json'
	-- resp:writeln(JSON.encode(package.path))
	resp:writeln(JSON.encode({"Hello MoonLight!","A simple and lightweight web framework based on OpenResty"}))
	local x = req.uri_args;
	resp:writeln(JSON.encode(x))
	-- resp:ltp("home_index.html", {v={x.project,x.object,x.action}})
end

function testmysql(req, resp)
	local Mysql = app.library("mysql")
	local res = Mysql.query("select id,parentid,name from enlink_navcat")
	resp:writeln("mysql")
	resp:writeln(JSON.encode(res))
end

function testredis(req,resp)
	local Redis = app.library("redis")
	Redis.set("aa","22222222",36000)
    local res = Redis.get("aa")
    resp:writeln("redis")
    resp:writeln(res)
end

function testrsa(req,resp)
	local RSA_PUBLIC_KEY = [[
	-----BEGIN RSA PUBLIC KEY-----
	MIGJAoGBAJavb+2Rr6n6+aSu0RwEeuSO2REOphLoM8TBG1pCLSqfZu3ZK6qkrGWe
	fgrRdnDm2oLcnZ9JmzOWhHok9kdO/kmDFPOWwE8CSiW5pmvybnR7SfYRJ0gM7Kfo
	soChxEOmStIP02wm0MKp3BD5EdzpPjLOt7CmYg+2c5/7VFUdvtX7AgMBAAE=
	-----END RSA PUBLIC KEY-----
	]]
	local RSA_PRIV_KEY = [[
	-----BEGIN RSA PRIVATE KEY-----
	MIICWwIBAAKBgQCWr2/tka+p+vmkrtEcBHrkjtkRDqYS6DPEwRtaQi0qn2bt2Suq
	pKxlnn4K0XZw5tqC3J2fSZszloR6JPZHTv5JgxTzlsBPAkoluaZr8m50e0n2ESdI
	DOyn6LKAocRDpkrSD9NsJtDCqdwQ+RHc6T4yzrewpmIPtnOf+1RVHb7V+wIDAQAB
	AoGAXQqCX/w+rQQstQTEVTpm701Mtn2HCdGadXiO/RIzdUfrdB1OGxWG5VARn3hq
	W5gPgBHcuYfnbtkXf5vm/WzHEYT/OXm7RfSklZrIpYcAWKBvTM7QLZl7ct9klQVn
	VYJmFlyUOWbL+RB28hAyjHai/O9nIM3IDUiX+XyPDCm/g3ECQQDbKMGwf2w2FJn2
	NUwUyj2p/1jrJqJ9uvxv9nzk7eS0qOqdeyxPffc8v6XpteOo0pKX6W8C8gA+inWP
	KY4KG+EFAkEAsAP90LbI6TfY31Od3NHhNIN6u5AJNp6EknxlDIIv92rPU5ucp3Mv
	qEZFCB48yKEMPU8IgZYtC8yOxFO3hYmK/wJATJ5zGMFzk3SgXvNDJgGOjWA4Nf3L
	0SkOGBaUk3SYAJENdQEa/K+NQC/AUXTFor/7gCCcLutsKnE9qE9e2SnmAQJATsy6
	qOHr+F0EPpcUqXNcu0HRhH7rYQR+nYYLRxpRlxa+UtPrwhuTTmaHKSdAVyGidSAY
	0ssEx6+Aiuxf0OzOyQJAKwdxVRp/OxXCnvKpio6TJf3QqhePijRhgHeMTGjCC0U+
	FSyYL4IklqJ4KvefQgSwIJR+oeJOzQXMFOtmOOrQ1w==
	-----END RSA PRIVATE KEY-----
	]]
	local Rsa = app.library("rsa_encrypt")
	local uri = JSON.encode(req.uri_args);
	resp:writeln("uri :" .. uri);
	local encrypt = Rsa:encrypt(RSA_PUBLIC_KEY,uri)
	resp:writeln("encrypt :" .. encrypt);
	local decrypt = Rsa:decrypt(RSA_PRIV_KEY,encrypt)
	resp:writeln("decrypt :" .. decrypt);
end