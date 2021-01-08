
script.on_event(defines.events.on_player_created, function(event)
  game.get_player(event.player_index).toggle_map_editor()
end)
