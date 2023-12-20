local texthud = {
  to_print = {},
  printed = {},
  id = {},
  delay = {},
  scale = {},
}
local indexin = 1
local button_pressed = {}
local player_in_end = {}
local xphb = {}
-- Yes, I know my formating is amazing.. I had only like a day and a half to make this.

dofile(minetest.get_modpath("default").."/torch.lua")

dialoge = { -- I can't spell
  {"You win!!", 0.02, 7, "winning"}, -- {string_to_print, average_delay_in_seconds_between_each_char_typed, text scale}
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
  {"...", 0.1, 3},
  {"Seriously?", 0.02, 3},
  {"Why? Arent you bored already?", 0.02, 3},
  {"Well I'm tired, leave me alone, please.", 0.02, 3},
  {":|", 0.02, 4},
  {"I have a poem for you;", 0.02, 3},
  {"Roses are red,", 0.02, 3},
  {"Violets are blue,", 0.02, 3},
  {"..", 0.1, 3},
  {"._.", 0.02, 3},
  {"That it, thats the whole peom..", 0.02, 3},
  {"My own composition I might add.", 0.02, 3},
  {"What's that? I didn't finish it?", 0.02, 3},
  {"So you expected then for me to-", 0.02, 3},
  {"nevermind.", 0.02, 3},
  {"Listen, can you please just go check out another game entry?", 0.02, 3},
  {"I hear Jordan is doing something interesting.", 0.02, 3},
  {"Perhaps Wuzzy will win again, if he's entering.", 0.02, 3},
  {"...", 0.1, 3},
  {"....", 0.1, 3},
  {"Boo!", 0.02, 10},
  {"Go Away.", 1, 3},
  {"Ok, you asked for it...", 0.05, 5},
  {"You actually lose!", 0.05, 8, "lose"},
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




local function set_xp_hud(player, num)
  num = num or 0
  local meta = player:get_meta()
  if meta:get_string("xp") == "" then -- first time player? give them 0 xp
    meta:set_string("xp", tostring(num))
  else
    meta:set_string("xp", meta:get_string("xp")+num)
  end
  local xp = (tonumber(meta:get_string("xp"))/100)%10
  if xphb[player] then -- make sure old hud is gone
    for i=1, 5 do
      player:hud_remove(xphb[player][i])
    end
  else
    xphb[player] = {}
  end
  xphb[player][1]=player:hud_add({
    hud_elem_type = "image",
    text = "xpbar_under.png",
    position = {x=0.5,y=0},
    offset = {x=0,y=30},
    scale = {x=10, y=10},
    z_index = 9,
  })

  xphb[player][2]=player:hud_add({
    hud_elem_type = "image",
    text = "xpbar_inside.png",
    position = {x=0.5,y=0},
    offset = {x=-293+(xp*29),y=30},
    scale = {x=xp, y=10},
    z_index = 10,
  })
  xphb[player][3]=player:hud_add({
    hud_elem_type = "image",
    text = "xpbar.png",
    position = {x=0.5,y=0},
    offset = {x=0,y=30},
    scale = {x=10, y=10},
    z_index = 11,
  })
  xphb[player][4]=player:hud_add({
    hud_elem_type = "image",
    text = "xpshine.png",
    position = {x=0.5,y=0},
    offset = {x=-293+(xp*29*2),y=30},
    scale = {x=10, y=10},
    z_index = 12,
  })
  xphb[player][5]=player:hud_add({
    hud_elem_type = "text",
    text = math.floor((tonumber(meta:get_string("xp"))/100)/10)+1,
    number = 120948349565,
    position = {x=0.5,y=0},
    offset = {x=300,y=30},
    scale = {x=10, y=10},
    size = {x=2, y=2},
    z_index = 12,
  })
end

minetest.register_on_newplayer(function(player)
  local xpthings = {jumped=0, placed_first=0, dug_first=0, looked_up=0, looked_down=0, chat_message=0, winning=0, lose=0}
  player:get_meta():set_string("xpthings", minetest.serialize(xpthings))
end)

local achieve_messages = {
  jumped = "Good job! You have made your first jump.",
  placed_first = "First item to be placed..",
  dug_first = "And you picked it back up.",
  looked_up = "Yup, that's the ceiling..",
  looked_down = "That's the floor..",
  chat_message = "Yay! you texted.. nobody.",
  winning = "You Won!!!",
  lose = "You lost!",
}

local rising_boni = {}

local function xp_gain(player, amount)
  minetest.sound_play("xpding", {
      to_player = player:get_player_name(),
      gain = 0.1})
  amount = amount or 1
  amount = amount * 20
  local meta = player:get_meta()
  if meta:get_string("xp") == "" then -- first time player? give them 0 xp
    meta:set_string("xp", tostring(amount))
  else
    meta:set_string("xp", meta:get_string("xp")+amount)
  end

  rising_boni[player] = rising_boni[player] or {}

  table.insert(rising_boni[player], {
    progress = 0,
    amount = amount/20
  })
  set_xp_hud(player)
end

local d,t,t2

local function free(player)
  if player_in_end[player] then
    return false
  end
  return true
end

local function achieved(player, thing)
  return minetest.deserialize(player:get_meta():get_string("xpthings"))[thing] == 1
end
local function achieve(player, thing)
  if d then
    player:hud_remove(d)
    player:hud_remove(t)
    player:hud_remove(t2)
  end
  local things = minetest.deserialize(player:get_meta():get_string("xpthings")) or {}
  things[thing] = 1
  player:get_meta():set_string("xpthings", minetest.serialize(things))
  xp_gain(player, math.random(20))
  d = player:hud_add({
    hud_elem_type = "image",
    text = "gui_formbg.png",
    position = {x=0.5,y=0},
    offset = {x=0,y=150},
    scale = {x=6, y=6},
    z_index = 111,
  })
  local title = "Achievement!"
  if thing == "lose" then
    title = "Rare Achievement!"
  end
  t = player:hud_add({
    hud_elem_type = "text",
    text = title,
    number = 120941238349565,
    position = {x=0.5,y=0},
    offset = {x=0,y=90},
    scale = {x=10, y=10},
    size = {x=2, y=2},
    z_index = 123,
  })
  t2 = player:hud_add({
    hud_elem_type = "text",
    text = achieve_messages[thing],
    number = 10000000,
    position = {x=0.5,y=0},
    offset = {x=0,y=120},
    scale = {x=10, y=10},
    size = {x=1, y=1},
    z_index = 123,
  })
  minetest.after(3, function()
    if d then
      player:hud_remove(d)
      player:hud_remove(t)
      player:hud_remove(t2)
      d=nil
      t=nil
      t2=nil
    end
  end)
end

local function printf(player, text, delay, scale, func)
  texthud.to_print[player] = text
  texthud.printed[player] = ""
  texthud.delay[player] = delay
  texthud.scale[player] = scale
  if func and not achieved(player, func) then
    achieve(player, func)
  end
end

local function finished_typing(player)
  if texthud.printed[player] and texthud.to_print[player] and #texthud.printed[player] < #texthud.to_print[player] then
    return false
  else
    return true
  end
end


minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
  if not achieved(placer, "placed_first") and free(player) then
    achieve(placer, "placed_first")
  end
end)
minetest.register_on_dignode(function(pos, oldnode, digger)
  if not achieved(digger, "dug_first") and free(player) then
    achieve(digger, "dug_first")
  end
end)

minetest.register_on_chat_message(function(name, message)
  if not achieved(minetest.get_player_by_name(name), "chat_message") and free(player) then
    achieve(minetest.get_player_by_name(name), "chat_message")
  end
end)


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
      player_in_end[clicker] = true
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


theme_inv = [[
size[9,5]
style_type[label;font=bold;border=false]
list[current_player;main;0.5,2.1;8,1;]
label[2.75,3;]]..minetest.formspec_escape(minetest.colorize("#87433b", "It looks like you don't have much"))..[[]
label[2.9,3.3;]]..minetest.formspec_escape(minetest.colorize("#87433b", "Might want to get some more!"))..[[]

]]





minetest.register_on_joinplayer(function(player)
  player:set_inventory_formspec(theme_inv)
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

  local formspec = [[
			bgcolor[#080808BB;true]
			listcolors[#beba94;#5A5A5A;#beba94;#beba94;#beba94] ]]
	local name = player:get_player_name()
	local info = minetest.get_player_information(name)
	formspec = formspec .. "background[5,5;2,1;gui_formbg.png;true]"
	player:set_formspec_prepend(formspec)
  player:hud_set_hotbar_image("gui_hotbar.png")
  player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)


local morse_message = ". .--. .. -.-. / .... .. -.. -.. . -. / -- . ... ... .- --. . .-.-.- / .... . .-.. .-.. --- / -. . .-. -.. .-.-.-"

controls.register_on_press(function(player, key)
  if key == "jump" and not achieved(player, "jumped") and free(player) then
    achieve(player, "jumped")
  end
  if button_pressed[player] then
    local thing_to_do = dialoge[indexin]
    if not thing_to_do then
      if finished_typing(player) and texthud.printed[player] ~= morse_message then
        printf(player, morse_message, "fast", 1)
      end
    end
    if not thing_to_do or not finished_typing(player) then return end
    indexin = indexin + 1
    printf(player, thing_to_do[1], thing_to_do[2], thing_to_do[3], thing_to_do[4])
  end
end)


local timer = 0
local timer2 = 0
minetest.register_globalstep(function(dtime)
  timer = timer + dtime
  timer2 = timer2 + dtime
  for _,player in pairs(minetest.get_connected_players()) do

    local pitch = player:get_look_vertical()

    if pitch > 0.99 and not achieved(player, "looked_down") and free(player) then
      achieve(player, "looked_down")
    end
    if pitch < -0.99 and not achieved(player, "looked_up") and free(player) then
      achieve(player, "looked_up")
    end

    if timer2 > 0.5 then
      timer2 = 0
      set_xp_hud(player)
    end

    if rising_boni[player] then
      for _,rb in pairs(rising_boni[player]) do
        if rb.id then
          player:hud_remove(rb.id)
          if rb.progress > 30 then
            rising_boni[player][_] = nil
          end
        end
        if rb.progress and not (rb.progress > 30) then
          rising_boni[player][_].id = player:hud_add({
            hud_elem_type = "text",
            text = "+"..rb.amount,
            number = 12302984,
            position = {x=0.5,y=0},
            offset = {x=0,y=90-(rb.progress*3)},
            scale = {x=10, y=10},
            size = {x=2,y=2},
            z_index = 100,
          })
          rising_boni[player][_].progress = rising_boni[player][_].progress+1
        end
      end
    end

    minetest.set_player_privs(player:get_player_name(), {fly=nil, fast = nil})

    if texthud.printed[player] and texthud.printed[player] == morse_message then
      minetest.kick_player(player:get_player_name(), "My condolences, "..player:get_player_name().."; You finished the game with a loss. I'm sorry. Have a good day. Or a day anyway. -Seugy")
    end

    local delay = (texthud.delay[player] or 0.5)
    local double = 1

    if delay and delay == "fast" then
      delay = 0
      double = 10
    end

    if timer+(math.random(-100,100)/100) < delay or not texthud.to_print[player] or not texthud.printed[player] then
      break
    end
    timer = 0

    if not finished_typing(player) then
      if texthud.id[player] then
        player:hud_remove(texthud.id[player])
      end
      texthud.printed[player] = texthud.printed[player]..texthud.to_print[player]:sub(#texthud.printed[player]+1, #texthud.printed[player]+double)
      if double == 1 then
        minetest.sound_play("typesound", {
            to_player = player:get_player_name(),
            gain = 0.1})
      end
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
