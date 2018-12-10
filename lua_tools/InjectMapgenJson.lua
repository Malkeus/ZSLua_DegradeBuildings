-- script to verify CDDA JSON(verifies all mods)
-- run this script with: lua lua/json_verifier.lua
--
-- requires luafilesystem to scan for files, installation instructions:
--  arch linux:   pacman -S lua-filesystem
--  debian linux: aptitude install liblua5.1-filesystem0
--  other linux distributions: search for "lua file system" in the
--                             package manager of your choice

local json = require("dkjson")
local lfs = require("lfs")

local exit_code = 0

-- function to read a file completely into a string
function read_file(filename)
    local f = io.open(filename, "r")
    local content = f:read("*all")
    f:close()
    return content
end

decode_cache = {}

-- parse the JSON of an entire cataclysm file
function parse_cata_json(filename, handler)
  print ("Parsing "..filename)
    local root, pos, err
    if not decode_cache[filename] then
        local content = read_file(filename)

        root, pos, err = json.decode(content, 1, nil)
        decode_cache[filename] = root
    else
        root = decode_cache[filename]
    end

    if err then
        print("Error in ", filename ,":", err)
        os.exit(1)
    else
        -- top level should be a json array
        if type(root) ~= "table" then
            print("Wrong root element to JSON file ", filename, " :", type(root))
        end

        for _, entry in ipairs(root) do
            if not entry.type then
                print("Invalid entry type in ", filename, ": ", entry.type)
            end
            if handler[entry.type] then
                handler[entry.type](entry, filename)
            end
        end
    end
end

--[[
local definitions = {}
local material_definitions = {}
function load_item_definition(entry, filename)
    -- store that this item was defined
    definitions[entry.id] = true
end

-- define load_definition handlers
local load_definition = {}
local item_types = { "BOOK", "TOOL", "GUN", "GUNMOD", "TOOL_ARMOR", "ARMOR", "BIONIC_ITEM", "GENERIC", "AMMO", "CONTAINER", "COMESTIBLE", "VAR_VEH_PART" }
for _, item_type in ipairs(item_types) do
    load_definition[item_type] = load_item_definition
end

-- load definition handler for materials
function load_material_definition(entry, filename)
    -- store that this material was defined
    material_definitions[entry.ident] = true
end
load_definition.material = load_material_definition

local verify_handler = {}

function ensure_definition(id, filename, parent_id)
    if not definitions[id] then
        -- signify that something went wrong
        exit_code = 1

        print("Trying to access non-existent item id ", id, " in ", filename, "(", parent_id, ")")
    end
end

function ensure_material_definition(id, filename, parent_id)
    if not material_definitions[id] then
        -- signify that something went wrong
        exit_code = 1

        print("Trying to access non-existent material id ", id, " in ", filename, "(", parent_id, ")")
    end
end

verify_handler.recipe = function(entry, filename)
    ensure_definition(entry.result, filename, entry.result)
    for _, alternatives in ipairs(entry.components) do
        for _, item in ipairs(alternatives) do
            ensure_definition(item[1], filename, entry.result)
        end
    end
    if entry.tools then
        for _, alternatives in ipairs(entry.tools) do
            for _, item in ipairs(alternatives) do
                ensure_definition(item[1], filename, entry.result)
            end
        end
    end
end

function verify_item_definition(entry, filename)
    local materials
    if not entry.material or entry.material == "" then
        return
    elseif type(entry.material) == "string" then
        materials = { entry.material }
    elseif type(entry.material == "table") then
        materials = entry.material
    else
        exit_code = 1
        print("Invalid material for ", entry.id, " in ", filename)
    end

    for _, material in ipairs(materials) do
        ensure_material_definition(material, filename, entry.id)
    end
end

for _, item_type in ipairs(item_types) do
    verify_handler[item_type] = verify_item_definition
end
]]

function string.endswith(mystr, myend)
   return myend=="" or string.sub(mystr,string.len(mystr)-string.len(myend)+1)==myend
end


function load_all_jsons_recursive(path, handler)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file

            local attr = lfs.attributes(f)
            if attr.mode == "directory" then
                load_all_jsons_recursive(f, handler)
            elseif attr.mode == "file" and string.endswith(f, ".json") then
                parse_cata_json(f, handler)
            end
        end
    end
end

local previous_filename = ""
local last_filename = ""
function load_all_jsons(handler)
    load_all_jsons_recursive("../json/mapgen", handler)
end

local definitions = {}
local load_definition = {}

local mapgen_definitions = {}
-- load definition handler for mapgen
function load_mapgen_definition(entry, filename)
    -- store that this mapgen was defined and store lua string
    mapgen_definitions[entry] = entry.object.lua
end
load_definition.mapgen = load_mapgen_definition

-- function to write string completely into a file
function write_file(filename, s)
    local filemode
    if (filename == previous_filename) then
      filemode = "a"
      s = ","..s
    else
      if (previous_filename ~= "") then
        local previous_f = io.open(previous_filename, "a")
        io.output(previous_f)
        io.write("]")
        previous_f:close()
      end
  
      filemode = "w+"
      s = "["..s
      previous_filename = filename
    end
    local f = io.open(filename, filemode)
    io.output(f)
    io.write(s)
    f:close()
end

local process_handler = {}

local mapgen_filename_blacklist = {
    --"../json/mapgen/",
    "../json/mapgen/antique_store.json",
    "../json/mapgen/arcade.json",
    "../json/mapgen/bowling_alley.json",
    "../json/mapgen/boxing.json",
    "../json/mapgen/dojo.json",
    "../json/mapgen/fire_station.json",
    "../json/mapgen/gardening_store.json",
    "../json/mapgen/gym.json",
    "../json/mapgen/homeimprovement.json",
    "../json/mapgen/jewel_store.json",
    "../json/mapgen/laundromat.json",
    "../json/mapgen/mortuary.json",
    "../json/mapgen/museum.json",  
    "../json/mapgen/road_4way.json",
    "../json/mapgen/veterinarian.json"
    --"../json/mapgen/"
}
function is_blacklisted (filename)
  
  if (mapgen_filename_blacklist[filename]) then
    print ("blacklisted: "..filename)
    return true
  else
    return false
  end

end

function lua_mapgen_handler(entry, filename)

  if (entry.object.lua == nil and not(is_blacklisted(filename))) then
    print ("adding lua to mapgen in file: ", filename, ", previous filename:", previous_filename)
    entry.object.lua = "dofile('./data/mods/ZSLua_DegradeBuildings/lua/mapgen_degrade_building.lua')"
    local state = {
        indent = true,
        keyorder = {
          "type",
          "method",
          "om_terrain",
          "weight",
          "object",
          "fill_ter",
          "rotation",
          "rows",
          "palettes",
          "set",
          "mapping",
          "terrain",
          "place_terrain",
          "furniture",
          "place_furniture",
          "traps",
          "place_traps",
          "fields",
          "place_fields",
          "rubble",
          "place_rubble",
          "signs",
          "place_signs",
          "vendingmachines",
          "place_vendingmachines",
          "toilets",
          "place_toilets",
          "gaspumps",
          "place_gaspumps",
          "liquids",
          "place_liquids",
          "add",
          "place_add",
          "item",
          "place_item",
          "items",
          "place_items",
          "loot",
          "place_loot",
          "npcs",
          "place_npcs",
          "monster",
          "place_monster",
          "monsters",
          "place_monsters",
          "vehicles",
          "place_vehicles",
          "lua"
        }
    }
    local js = json.encode(entry, state)
    write_file(filename, js)
    last_filename = filename
  else
    print ("file blacklisted or lua is already exists in json: ", filename, ", previous filename:", previous_filename)
  end

end

process_handler.mapgen = lua_mapgen_handler


-- first load all item definitions
--load_all_jsons(load_definition)

-- some hardcoded item definitions
--definitions["cvd_machine"] = true
--definitions["corpse"] = true
--definitions["apparatus"] = true
--definitions["toolset"] = true
--definitions["fire"] = true

-- then verify recipes
--&load_all_jsons(verify_handler)

--check and insert lua-mapgen
load_all_jsons(process_handler)

if (last_filename ~= "") then
  local last_f = io.open(last_filename, "a")
  io.output(last_f)
  io.write("]")
  last_f:close()
end
      
os.exit(exit_code)