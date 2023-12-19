local texthud = {
  to_print = {},
  printed = {},
  id = {},
  delay = {},
  scale = {},
}
local indexin = 1
local button_pressed = {}
-- Yes, I know my formating is amazing.. I had only like a day and a half to make this.

dofile(minetest.get_modpath("default").."/torch.lua")

dialoge = { -- I can't spell
  {"You win!!", 0.02, 7}, -- {string_to_print, average_delay_in_seconds_between_each_char_typed, text scale}
  {"Yay!", 0.02, 5},
  {"...", 0.04, 3},
  {"Bye-bye now!", 0.02, 3},
  {"..", 0.04, 3},
  {"...", 0.04, 3},
  {"What?", 0.03, 3},
  {"Why are you still here?", 0.05, 3},
  {"You what?", 0.03, 3},
  {"You expected more, huh?", 0.02, 3},
  {"So let me get this straight...", 0.03, 3},
  {"You anticipated something other than what you got", 0.02, 3},
  {"Right?", 0.04, 3},
  {"You know, some would call that sort of thing...", 0.02, 3},
  {"...", 0.07, 3},
  {".....", 0.07, 3},
  {"........", 0.07, 3},
  {"Unexpected", 0.1, 4},
  {":)", 0.05, 3},
  {"..", 0.1, 3},
  {"..", 0.1, 3},
  {"Seriously?", 0.02, 3},
  {"Why? Arent you bored already?", 0.02, 3},
  {"Well I'm tired, leave me alone, please.", 0.02, 3},
  {":|", 0.02, 4},
  {"Roses are red,", 0.02, 3},
  {"Violets are blue,", 0.02, 3},
  {"..", 0.1, 3},
  {"._.", 0.02, 3},
  {"That it, thats the whole thing.", 0.02, 3},
  {"My own composition I might add.", 0.02, 3},
  {"What's that? I didn't finish it?", 0.02, 3},
  {"So you expected then for me to-", 0.02, 3},
  {"nevermind.", 0.02, 3},
  {"Listen, can you please just go check out another game entry?", 0.02, 3},
  {"I hear Jordan is doing something interesting.", 0.02, 3},
  {"Perhaps Wuzzy will win again, if he's entering.", 0.02, 3},
  {"...", 0.1, 3},
  {"...", 0.1, 3},
  {"Boo!", 0.02, 10},
  {"Go Away.", 1, 3},
  {"Ok, you asked for it...", 0.05, 5},
  {"You actually lose!", 0.05, 8},
  {"Now you feel bad huh!?", 0.02, 6},
  {"Wait, y-you don't?", 0.02, 3},
  {"You don't care?", 0.2, 3},
  {"Oh.", 0.1, 1},
  {"That makes me..", 0.05, 2},
  {"sad", 0.16, 1},
  {"I think I might", 0.07, 2},
  {"cry :(", 0.07, 1},
  {"Thank you for at least talking to me.", 0.1, 3},
  {"I must begone, farewell. I guess I deserve this for such a disappointing surprise", 0.1, 3},
}

local function printf(player, text, delay, scale)
  texthud.to_print[player] = text
  texthud.printed[player] = ""
  texthud.delay[player] = delay
  texthud.scale[player] = scale
end

local function finished_typing(player)
  if texthud.printed[player] and texthud.to_print[player] and #texthud.printed[player] < #texthud.to_print[player] then
    return false
  else
    return true
  end
end

minetest.register_node("default:node", {
  tiles = {"brick.png"},
  sounds = {footstep = "footstep"},
})
minetest.register_node("default:lever", {
  tiles = {"lever.png"},
  drawtype = "mesh",
  mesh = "jeija_wall_lever_on.obj",
  paramtype2 = "wallmounted",
  selection_box = {
    type = "fixed",
    fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
  },
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    minetest.sound_play("flip", {
        to_player = clicker:get_player_name(),
        gain = 1})
    minetest.set_node(pos, {name="default:lever_off"})
    minetest.after(1, function()
      clicker:set_pos(vector.new(0,0,100))
      button_pressed[clicker] = true
      clicker:hud_add({
        hud_elem_type = "image",
        text = "black_top.png",
        position = {x=0.5,y=0},
        offset = {x=0,y=310},
        scale = {x=10, y=10},
        z_index = 100,
      })
      clicker:hud_add({
        hud_elem_type = "image",
        text = "black_bottom.png",
        position = {x=0.5,y=1},
        offset = {x=0,y=-310},
        scale = {x=10, y=10},
        z_index = 100,
      })
      clicker:hud_add({
        hud_elem_type = "text",
        text = "press any key to continue",
        number = 10000000,
        position = {x=0.5, y=0.5},
        offset = {x=0,y=80},
        size = {x=0.5,y=0.5},
        scale = {x=1, y=1},
        z_index = 101,
      })
    end)
  end,
})

minetest.register_node("default:lever_off", {
  tiles = {"lever.png"},
  drawtype = "mesh",
  mesh = "jeija_wall_lever_off.obj",
  paramtype2 = "wallmounted",
  selection_box = {
    type = "fixed",
    fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
  },
})



local function set_start_pos(player)

  local pos1 = vector.new(-3,-1,-3)
  local pos2 = vector.add(pos1, vector.new(6,4,6))
  local c_node = minetest.get_content_id("default:node")
  local c_lever = minetest.get_content_id("default:lever")

  -- Read data into LVM
  local vm = minetest.get_voxel_manip()
  local emin, emax = vm:read_from_map(pos1, pos2)
  local a = VoxelArea:new{
    MinEdge = emin,
    MaxEdge = emax
  }
  local data = vm:get_data()

  -- Modify data
  for z = pos1.z, pos2.z do
    for y = pos1.y, pos2.y do
      for x = pos1.x, pos2.x do
        local vi = a:index(x, y, z)
        if vector.equals(vector.new(0,1,2), vector.new(x,y,z)) then
          data[vi] = c_lever
        end
        if x == pos1.x or x == pos2.x or
        y == pos1.y or y == pos2.y or
        z == pos1.z or z == pos2.z
        then

          data[vi] = c_node
        end
      end
    end
  end

  -- Write data
  vm:set_data(data)
  vm:set_lighting(0, pos1, pos2)
  vm:write_to_map(true)
end


minetest.hud_replace_builtin("health",	{
	hud_elem_type = "statbar",
	position = {x=0,y=0},
	text = "blank.png",
	number = 0,
	direction = 0,
	offset = { x = 46, y = -123 },
})


minetest.register_on_joinplayer(function(player)
  player:get_inventory():set_size("main", 8)
  player:get_inventory():set_size("craft", 0)

  player:set_wielded_item(ItemStack("default:torch"))
  set_start_pos(player)
  player:set_pos(vector.zero())
  minetest.after(0.1, function()
    set_start_pos(player)
  end)
  --[[
  ]]
  player:hud_set_hotbar_image("gui_hotbar.png")
  player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)

controls.register_on_press(function(player)
  if button_pressed[player] then
    local thing_to_do = dialoge[indexin]
    if not thing_to_do then
      minetest.kick_player(player:get_player_name(), "My condolences, "..player:get_player_name().."; You finished the game with a loss. I'm sorry. Have a good day. Or a day anyway. -Seugy")
    end
    if not thing_to_do or not finished_typing(player) then return end
    indexin = indexin + 1
    printf(player, thing_to_do[1], thing_to_do[2], thing_to_do[3])
  end
end)


local timer = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  for _,player in pairs(minetest.get_connected_players()) do
    minetest.set_player_privs(player:get_player_name(), {fly=nil, fast = nil})

    if timer+(math.random(-100,100)/100) < (texthud.delay[player] or 0) or not texthud.to_print[player] or not texthud.printed[player] then
      break
    end
    timer = 0

    if not finished_typing(player) then
      if texthud.id[player] then
        player:hud_remove(texthud.id[player])
      end
      texthud.printed[player] = texthud.printed[player]..texthud.to_print[player]:sub(#texthud.printed[player]+1, #texthud.printed[player]+1)
      minetest.sound_play("typesound", {
          to_player = player:get_player_name(),
          gain = 0.1})
      texthud.id[player] = player:hud_add({
        hud_elem_type = "text",
        text = texthud.printed[player],
        size = {x=(texthud.scale[player] or 2)/1.5, y=(texthud.scale[player] or 2)/1.5},
        position = {x=0.5,y=0.5},
        scale = {x=1,y=1},
        --offset = {x=100+(#texthud.printed[player]*2 * (texthud.scale[player] or 2)),y=70},
        number = 12039809821354089,
        item = 0xFFFFFF,
        z_index = 101,
      })
    end
  end
end)
