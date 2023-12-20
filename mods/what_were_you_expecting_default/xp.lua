xp = {}
xphb = {}

function xp.set_xp_hud(player, num)
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

rising_boni = {}

function xp.xp_gain(player, amount)
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
  xp.set_xp_hud(player)
end

local d,t,t2

function xp.achieved(player, thing)
  return minetest.deserialize(player:get_meta():get_string("xpthings"))[thing] == 1
end
function xp.achieve(player, thing)
  if d then
    player:hud_remove(d)
    player:hud_remove(t)
    player:hud_remove(t2)
  end
  local things = minetest.deserialize(player:get_meta():get_string("xpthings")) or {}
  things[thing] = 1
  player:get_meta():set_string("xpthings", minetest.serialize(things))
  xp.xp_gain(player, math.random(20))
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
