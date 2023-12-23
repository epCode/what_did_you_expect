minetest.register_on_player_receive_fields(function(player, formname, fields)
  if fields.info_help then
    default.show_info_form(player, "help")
  end
end)
