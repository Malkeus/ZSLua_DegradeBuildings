local BASE_PATH = "./data/mods/ZSLua_DegradeBuildings/lua/"

require(BASE_PATH.."Functions")

--ProFi = require(BASE_PATH.."ProFi")
--Log = require(BASE_PATH.."Log")

MapGen = require(BASE_PATH.."MapGen")

local function DegradeBuilding()

	--Log.Message("ZSLua_DegradeBuildings: mapgen_degrade_building.lua: DegradeBuilding()")

	for x = 0, MapGen.SEEX * 2, 1 do
		for y = 0, MapGen.SEEY * 2, 1 do
			--Log.Message(x.."/"..y)

			local t = MapGen.GetTerrainName(x, y)
			local point = tripoint(MapGen.BaseX + x, MapGen.BaseY + y, MapGen.BaseZ)

			if (t ~= "nothing") then
				--Log.Message("made rubble")
				if string.match(t, "floor") or string.match(t, "tile") then
					if MapGen.OneIn(125) then
						MapGen.PointGraffiti(x, y)
					elseif MapGen.OneIn(256) then
						map:destroy(point, true)
					else
						MapGen.MakeRubble(x, y, 20)
					end
				elseif string.match(t, "window") then
					if not string.match(t, "bars") and not string.match(t, "boarded") then
						if MapGen.OneIn(16) then
							map:destroy(point, true)
						elseif MapGen.OneIn(4) then
							MapGen.PointTerrain("t_window_frame", x, y)
						end
					end
				elseif string.match(t, "door") and not string.match(t, "metal") then
					if MapGen.OneIn(36) then
						map:destroy(point, true)
					elseif MapGen.OneIn(6) then
						MapGen.PointTerrain("t_door_b", x, y)
					end
				elseif string.match(t, "wall") then
					if string.match(t, "glass") and MapGen.OneIn(16) then map:destroy(point, true)
					elseif string.match(t, "brick") and MapGen.OneIn(125) then map:destroy(point, true)
					elseif string.match(t, "concrete") and MapGen.OneIn(256) then map:destroy(point, true)
					elseif not string.match(t, "metal") and MapGen.OneIn(96) then map:destroy(point, true)
					end
				end
			end
		end
	end
end

--ProFi:start()

DegradeBuilding()

--ProFi:stop()

--ProFi:writeReport(BASE_PATH.."mapgen_degrade_building.report")

--      "lua": "dofile('./data/mods/ZSLua_DegradeBuildings/lua/mapgen_downgrade_building.lua')"