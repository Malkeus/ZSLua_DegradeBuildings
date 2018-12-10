local BASE_PATH = "./data/mods/ZSLua_DegradeBuildings/lua/"

require(BASE_PATH.."Functions")

local Log = {}

Log.Path = BASE_PATH.."ZSLua_DegradeBuildings.log"

function Log.Message (logmessage, logtogame)
	logtogame = logtogame or false
	local logfile = io.open (Log.Path, "a")
	io.output(logfile)
	io.write(tostring(logmessage).."\n")
	io.close(logfile)
	if (logtogame and game.add_msg) then
		game.add_msg(logmessage)
	end
end

function Log.Start()
	local logfile = io.open (Log.Path, "a")
	io.output(logfile)
	io.close(logfile)
	Log.Message("\n".."started writing to "..Log.Path.." on "..os.time().."\n")
end

function Log.End()
	Log.Message("\n".."finished writing to "..Log.Path.." on "..os.time())
end

return Log