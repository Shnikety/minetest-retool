-- Retool init.lua
-- Copyright J.B. Groff (Shnikety), 2018
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)

-- register mirror recipes
-- TODO: this does not take into account symmetric recipes
function mirror(arg)
	local r = arg.recipe
	local new = function(arg) minetest.register_craft(arg) end

	local f = {}
	if r[3] then
		-- swap top & bottom for recipes three items high
		f[1] = function(r)
			r[1], r[3] = r[3], r[1]
		end
		if r[1][3] then
			-- swap left & right for recipes three items wide & three items high
			f[2], f[4] = function(r)
				r[1][1],r[1][3],r[2][1],r[2][3],r[3][1],r[3][3] = r[1][3],r[1][1],r[2][3],r[2][1],r[3][3],r[3][1]
			end
		elseif r[1][2] then
			-- swap left & right for recipes two items wide & three items high
			f[2], f[4] = function(r)
				r[1][1],r[1][2],r[2][1],r[2][2],r[3][1],r[3][2] = r[1][2],r[1][1],r[2][2],r[2][1],r[3][2],r[3][1]
			end
		end
	elseif r[2] then
		-- swap top & bottom for recipes two items high
		f[1] = function(r)
			r[1], r[2] = r[2], r[1]
		end
		if r[1][3] then
			-- swap left & right for recipes three items wide & two items high
			f[2] = function(r)
				r[1][1],r[1][3],r[2][1],r[2][3] = r[1][3],r[1][1],r[2][3],r[2][1]
			end
		elseif r[1][2] then
			-- swap left & right for recipes two items wide & two items high
			f[2] = function(r)
				r[1][1],r[1][2],r[2][1],r[2][2] = r[1][2],r[1][1],r[2][2],r[2][1]
			end
		end
	end
	 --this ensures that the recipe is arranged back to its original form
	f[3], f[4] = f[1], f[2]

	for i = 1, 4 do
		if f[i] then
			f[i](r)
			new(arg)
			--[[ debugging log
			minetest.log("action", 'register ' .. arg.output .. tostring(i))
			for a = 1, 3 do
			if r[a] then
				local recipe = ""
				for b = 1, 3 do
					if r[a][b] then recipe = recipe..'"'..r[a][b]..'"' end
					if r[a][b+1] then recipe = recipe..", " end
				end
				minetest.log("action", recipe)
			end
			end
			--]]
		end
	end
	-- note that the original item is the last to be registered
end

local variety = {
	blunt = {
		wood =    "group:wood",
		stone =   "group:stone",
		steel =   "default:steel_ingot",
		bronze =  "default:bronze_ingot",
		mese =    "default:mese",
		diamond = "default:diamond",
	},
	sharp = {
		stone =   "default:flint",
		stone =   "default:obsidian_shard ",
		bone =    "bones:bones",
		copper =  "default:copper_ingot",
		bronze =  "default:bronze_ingot",
		steel =   "default:steel_ingot",
		mese =    "default:mese_crystal_fragment ",
		diamond = "default:diamond",
	}
}

function register(arg)
	local r = arg.recipe
	local location = {}
	local tool_type
	local i = 0
	local name = arg.output
	for y = 1, 3 do
	if r[y] then
		for x = 1, 3 do
		if r[y][x] == "default:flint" then
			i = i + 1
			location[i] = {y, x}
			if not tool_type then tool_type = 'sharp'
			--elseif tool_type = 'blunt' then tool_type = 'composite'
			end
		elseif r[y][x] == "default:cobble" then
			i = i + 1
			location[i] = {y, x}
			if not tool_type then
				tool_type = 'blunt'
			--elseif tool_type = 'sharp' then tool_type = 'composite'
			end
		end
		end
	end
	end

	if #location > 0 then
		for postfix, v in pairs(variety[tool_type]) do
			arg.output = name.."_"..postfix
			for loc = 1, #location do
				r[location[loc][1]][location[loc][2]] = v
			end
			mirror(arg)
		end
	else mirror(arg)
	end
end

for _, kind in pairs({"wood", "stone", "steel", "bronze", "mese", "diamond"}) do
	minetest.clear_craft({output = "default:pick_"..kind})
	minetest.clear_craft({output = "default:shovel_"..kind})
	minetest.clear_craft({output = "default:axe_"..kind})
	minetest.clear_craft({output = "default:sword_"..kind})
	minetest.clear_craft({output = "farming:hoe_"..kind})
end
minetest.clear_craft({output = "screwdriver:screwdriver"})

local _____, BLUNT, SHARP, STICK = "", "default:cobble", "default:flint", "group:stick"
-- when registering doubles the last one should look similar to jpg
register({
	output = "default:axe",
	recipe = {
		{_____, STICK, BLUNT},
		{STICK, BLUNT, BLUNT}
	}
})
register({
	output = "default:axe",
	recipe = {
		{BLUNT, BLUNT},
		{BLUNT, STICK},
		{STICK, _____}
	}
})
register({
	output = "farming:hoe",
	recipe = {
		{_____, STICK, BLUNT},
		{STICK, _____, BLUNT}
	}
})
register({
	output = "farming:hoe",
	recipe = {
		{BLUNT, BLUNT},
		{_____, STICK},
		{STICK, _____}
	}
})
-- obviously this could be replaced by a recipe with four BLUNT instead of three
register({
	output = "default:pick",
	recipe = {
		{_____, BLUNT, _____},
		{_____, STICK, BLUNT},
		{STICK, _____, BLUNT}
	}
})
register({
	output = "default:pick",
	recipe = {
		{BLUNT, BLUNT, _____},
		{_____, STICK, BLUNT},
		{STICK, _____, _____}
	}
})
register({
	output = "default:shovel",
	recipe = {
		{_____, BLUNT, BLUNT},
		{_____, STICK, BLUNT},
		{STICK, _____, _____}
	}
})
register({
	output = "default:sword",
	recipe = {
		{_____, _____, BLUNT},
		{_____, BLUNT, _____},
		{STICK, _____, _____}
	}
})
register({
	output = "screwdriver:screwdriver",
	recipe = {
		{"default:steel_ingot", _____},
		{_____, STICK}
	}
})
--[[ just a few additional ideas here
register({
	output = "retool:hammer",
	recipe = {
		{_____, BLUNT, _____},
		{_____, STICK, BLUNT},
		{STICK, _____, _____}
	}
})
register({
	output = "retool:spear",
	recipe = {
		{_____, _____, SHARP},
		{_____, STICK, _____},
		{STICK, _____, _____}
	}
})
regiSTICKter({
	output = "retool:arrow",
	recipe = {
		{_____, _____, SHARP},
		{_____, STICK, _____},
		{"farming:feather", _____,  _____}
	}
})
register({
	output = "retool:mattock", --hmm... https://en.wikipedia.org/wiki/Pulaski_(tool)
	recipe = {
		{BLUNT, BLUNT, _____},
		{BLUNT, STICK, SHARP},
		{STICK, _____, SHARP}
	}
})
register({
	output = "retool:adz",
	recipe = {
		{SHARP, SHARP, SHARP},
		{_____, STICK, _____},
		{STICK, _____, _____}
	}
})
-- or perhaps...
register({
	output = "retool:adz",
	recipe = {
		{SHARP, SHARP},
		{STICK, _____}
	}
})
--]]

