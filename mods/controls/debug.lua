controls.register_on_press(function(player, key)
	local name = player:get_player_name()
	minetest.chat_send_player(name, name .. " pressed " .. key)
end)

controls.register_on_hold(function(player, key, length)
	local name = player:get_player_name()
	minetest.chat_send_player(name, name .. " held " .. key .. " for " .. length .. " seconds")
end)

controls.register_on_release(function(player, key, length)
	local name = player:get_player_name()
	minetest.chat_send_player(name, name .. " released " .. key .. " after " .. length .. " seconds")
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	minetest.chat_send_player(name, #controls.registered_on_press .. " registered_on_press callbacks")
	minetest.chat_send_player(name, #controls.registered_on_hold .. " registered_on_hold callbacks")
	minetest.chat_send_player(name, #controls.registered_on_release .. " registered_on_release callbacks")
end)