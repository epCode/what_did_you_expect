local function character_set_form(player)

  local traits = minetest.deserialize(player:get_meta():get_string("traits"))
  local trait_changers = ""
  local ticker = 1
  for trait,value in pairs(traits) do
    trait_changers = trait_changers..default.button({
      pos={x=3.5, y=1+ticker},
      size={x=1.2, y=1.2},
      tex="gui_8_button_left.png",
      tex2="gui_8_button_left.png",
      name=trait.."_left",
    })..
    trait_changers..default.button({
      pos={x=4.8, y=1+ticker},
      size={x=1.2, y=1.2},
      tex="gui_8_button_right.png",
      tex2="gui_8_button_right.png",
      name=trait.."_right",
    })..
    "style_type[label;font_size=30]"..
    "image[2,"..(1.15+ticker)..";2,0.84;text_"..trait..".png]"..
    "label[4.52,"..(1.3+ticker)..";1]"
    ticker = ticker + 1
  end

  local formspec = ""..
  "size[17.5,10.5]"..
  trait_changers

  minetest.show_formspec(player:get_player_name(), "character_api:trait_screen", formspec)
end


minetest.register_on_joinplayer(function(player)
  local traits = {strength=0, dexterity=0, constitution=0, wisdom=0, intelligence=0, charisma=0}
  player:get_meta():set_string("traits", minetest.serialize(traits))
  character_set_form(player)
end)
