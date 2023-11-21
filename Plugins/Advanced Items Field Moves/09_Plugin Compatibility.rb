if PluginManager.findDirectory("Following Pokemon EX")
  class Game_FollowingPkmn < Game_Follower
    def location_passable?(x, y, direction)
      this_map = self.map
      return false if !this_map || !this_map.valid?(x, y)
      return true if @through
      passed_tile_checks = false
      bit = (1 << ((direction / 2) - 1)) & 0x0f
      # Check all events for ones using tiles as graphics, and see if they're passable
      this_map.events.values.each do |event|
        next if event.tile_id < 0 || event.through || !event.at_coordinate?(x, y)
        tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[event.tile_id])
        next if tile_data.ignore_passability
        next if tile_data.bridge && $PokemonGlobal.bridge == 0
        return false if tile_data.ledge
        # Allow Folllowers to surf freely
        return true if tile_data.can_surf
        passage = this_map.passages[event.tile_id] || 0
        return true if tile_data.can_climb
        passage = this_map.passages[event.tile_id] || 0
        return false if passage & bit != 0
        passed_tile_checks = true if (tile_data.bridge && $PokemonGlobal.bridge > 0) ||
        (this_map.priorities[event.tile_id] || -1) == 0
        break if passed_tile_checks
      end
      # Check if tiles at (x, y) allow passage for followe
      if !passed_tile_checks
        [2, 1, 0].each do |i|
          tile_id = this_map.data[x, y, i] || 0
          next if tile_id == 0
          tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[tile_id])
          next if tile_data.ignore_passability
          next if tile_data.bridge && $PokemonGlobal.bridge == 0
          return false if tile_data.ledge
          # Allow Folllowers to surf freely
          return true if tile_data.can_surf
          passage = this_map.passages[tile_id] || 0
          return true if tile_data.can_climb
          passage = this_map.passages[tile_id] || 0
          return false if passage & bit != 0
          break if tile_data.bridge && $PokemonGlobal.bridge > 0
          break if (this_map.priorities[tile_id] || -1) == 0
        end
      end
      # Check all events on the map to see if any are in the way
      this_map.events.values.each do |event|
        next if !event.at_coordinate?(x, y)
        return false if !event.through && event.character_name != ""
      end
      return true
    end
  end

  if !Item_RockClimb[:active]
    alias __followingpkmn__fmRockClimb fmRockClimb unless defined?(__followingpkmn__fmRockClimb)
    def fmRockClimb(*args)
      $game_temp.no_follower_field_move = true
      pkmn = $player.get_pokemon_with_move(:ROCKCLIMB)
      ret = __followingpkmn__fmRockClimb(*args)
      $game_temp.no_follower_field_move = false
      return ret
    end
  end

  if !Item_Camouflage[:active]
    alias __followingpkmn__aifmVanish aifmVanish unless defined?(__followingpkmn__aifmVanish)
    def aifmVanish(*args)
      $game_temp.no_follower_field_move = true
      pkmn = $player.get_pokemon_with_move(:CAMOUFLAGE)
      ret = __followingpkmn__aifmVanish(*args)
      $game_temp.no_follower_field_move = false
      return ret
    end
  end
end

if PluginManager.findDirectory("Following Pokemon EX")
  module FollowingPkmn
    def self.remove_sprite
      FollowingPkmn.get_event&.character_name = ""
      FollowingPkmn.get_data&.character_name  = ""
      FollowingPkmn.get_event&.character_hue  = 0
      FollowingPkmn.get_data&.character_hue   = 0
      if !Item_Camouflage[:orignal_effect]
        if $game_player.camouflage == true
          pbMoveRoute(FollowingPkmn.get_event,[
            PBMoveRoute::Opacity,51  #20%
            ])
        end
      else
        if $game_player.camouflage == true
          pbMoveRoute(FollowingPkmn.get_event,[
            PBMoveRoute::Opacity,0  #0%
            ])
        end
      end
    end
  end
end
