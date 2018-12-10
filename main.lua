local BASE_PATH = "./data/mods/ZSLua_DegradeBuildings/lua/"

require(BASE_PATH.."Functions")

--ProFi = require(BASE_PATH.."ProFi")
--Log = require(BASE_PATH.."Log")
MapGen = require(BASE_PATH.."MapGen")

local MOD = {}

mods["ZSLua_DegradeBuildings"] = MOD

function MOD.on_new_player_created()
    --Log.Message("ZSLua_DegradeBuildings: main.lua: callback: on_new_player_created", true)
end

function MOD.on_skill_increased()
    --Log.Message("ZSLua_DegradeBuildings: main.lua: callback: on_skill_increased", true)
end

function MOD.on_minute_passed()
    --Log.Message("ZSLua_DegradeBuildings: main.lua: callback: on_minute_passed", true)
end

function MOD.on_day_passed()
    --Log.Message("ZSLua_DegradeBuildings: main.lua: callback: on_day_passed", true)
end

