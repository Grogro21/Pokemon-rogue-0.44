def pbCanUseMove(item)
  if item[:use_in_debug]
    return true if $DEBUG
  end
  if pbCheckForBadge(item[:needed_badge]) && pbCheckForSwitch(item[:needed_switches])
    return true
  end
  return false
end

#===============================================================================
# Whirlpool Field Move
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if !Item_Whirlpool[:active]

  EventHandlers.add(:on_player_interact, :whirlpool,
    proc {
      if $game_player.pbFacingTerrainTag.whirlpool && $PokemonGlobal.surfing
        fmWhirlpool
      end
    }
  )

  def fmWhirlpool
    move = :WHIRLPOOL
    movefinder = $player.get_pokemon_with_move(move)
    if !pbCanUseMove(Item_Whirlpool) || (!movefinder)
      pbMessage(_INTL("It's a huge swirl of water use a move to cross it"))
      return false
    end
    if pbConfirmMessage(_INTL("It's a huge swirl of water.\nWould you like to use {1}?", GameData::Move.get(move).name))
      speciesname = (movefinder) ? movefinder.name : $player.name
      pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
      pbHiddenMoveAnimation(movefinder)
      terrain = $game_player.pbFacingTerrainTag
      return if !terrain.whirlpool
      $stats.whirlpool_cross_count += 1
      oldthrough   = $game_player.through
      $game_player.through = true
      $game_player.move_speed_real = 6.4
      case  $game_player.direction
      when 2, 8
        $game_player.always_on_top = true
      end
      pbWait(4)
      loop do
        case  $game_player.direction
        when 2 #[Player Looking Down]
          if $game_player.pbFacingTerrainTag.whirlpool
            $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_down_id],$game_player.x,$game_player.y,true,1)
          end
          $game_player.move_forward
        when 4 #[Player Looking Left]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_left_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        when 6 #[Player Looking Right]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_right_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        when 8 #[Player Lookin Up]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_up_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        end
        terrain = $game_player.pbTerrainTag
        break if !terrain.whirlpool
        while $game_player.moving?
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
      pbWait(36)
      $game_player.through    = oldthrough
      $game_player.move_speed_real = 25.6
      $game_player.always_on_top = false
      $game_player.check_event_trigger_here([1, 2])
    end
  end

  HiddenMoveHandlers::CanUseMove.add(:WHIRLPOOL, proc { |move, pkmn, showmsg|
    next false if !pbCanUseMove(Item_Whirlpool)
    if !$game_player.pbFacingTerrainTag.whirlpool && !$PokemonGlobal.surfing
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
    next true
    })

  HiddenMoveHandlers::UseMove.add(:WHIRLPOOL, proc { |move, pokemon|
    fmWhirlpool
    next true
    })
end

#===============================================================================
# Rock Field Move
#===============================================================================
if !Item_RockClimb[:active]

  def fmAscendRock
    return if $game_player.direction != 8   # Can't ascend if not facing up
    terrain = $game_player.pbFacingTerrainTag
    return if !terrain.can_climb
    $stats.rockclimb_ascend_count += 1
    oldthrough   = $game_player.through
    oldmovespeed = $game_player.move_speed
    $game_player.through    = true
    $game_player.move_speed = 4
    pbJumpToward
    pbCancelVehicles
    $PokemonEncounters.reset_step_count
    $PokemonGlobal.rockclimbing = true
    pbUpdateVehicle
    loop do
      $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:move_up_id],$game_player.x,$game_player.y,true,1)
      $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:debris_id],$game_player.x,$game_player.y,true,1)
      $game_player.move_up
      terrain = $game_player.pbTerrainTag
      break if !terrain.can_climb
      while $game_player.moving?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    $PokemonGlobal.rockclimbing = false
    pbJumpToward(0)
    pbWait(16)
    $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:dust_id],$game_player.x,$game_player.y,true,1)
    pbWait(4)
    $game_player.through    = oldthrough
    $game_player.move_speed = oldmovespeed
    $game_player.increase_steps
    $game_player.check_event_trigger_here([1, 2])
  end

  def fmDescendRock
    return if $game_player.direction != 2   # Can't descend if not facing down
    terrain = $game_player.pbFacingTerrainTag
    return if !terrain.can_climb
    $stats.rockclimb_descend_count += 1
    oldthrough   = $game_player.through
    oldmovespeed = $game_player.move_speed
    old_always_on_top = $game_player.always_on_top
    $game_player.through = true
    $game_player.move_speed = 4
    $game_player.always_on_top = true
    pbJumpToward
    pbCancelVehicles
    $PokemonEncounters.reset_step_count
    $PokemonGlobal.rockclimbing = true
    pbUpdateVehicle
    loop do
      if $game_player.pbFacingTerrainTag.rockclimb
        $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:move_down_id],$game_player.x,$game_player.y,true,1)
        $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:debris_id],$game_player.x,$game_player.y,true,1)
      end
      $game_player.move_down
      terrain = $game_player.pbTerrainTag
      break if !terrain.can_climb
      while $game_player.moving?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    $PokemonGlobal.rockclimbing = false
    pbJumpToward(0)
    pbWait(16)
    $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:dust_id],$game_player.x,$game_player.y,true,1)
    pbWait(8)
    $game_player.through = oldthrough
    $game_player.move_speed = oldmovespeed
    $game_player.always_on_top = old_always_on_top
    $game_player.increase_steps
    $game_player.check_event_trigger_here([1, 2])
  end

  def fmRockClimb
    move = :ROCKCLIMB
    movefinder = $player.get_pokemon_with_move(move)
    if !pbCanUseMove(Item_RockClimb) || (!movefinder)
      pbMessage(_INTL("The wall is very rocky. Could be climbed with the right move"))
      return false
    end
    if pbConfirmMessage(_INTL("The wall is very rocky.\nWould you like to use the {1}", GameData::Move.get(move).name))
      speciesname = (movefinder) ? movefinder.name : $player.name
      pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
      pbHiddenMoveAnimation(movefinder)
      case $game_player.direction
      when 8 # Looking up
        fmAscendRock
      when 2 # Looking down
        fmDescendRock
      end
      return true
    end
    return false
    pbWait(16)
  end

  EventHandlers.add(:on_player_interact, :rockclimb,
    proc {
      terrain = $game_player.pbFacingTerrainTag
      if terrain.rockclimb
        fmRockClimb
      end
    }
  )

  EventHandlers.add(:on_player_interact, :rockclimb_crest,
    proc {
      terrain = $game_player.pbFacingTerrainTag
      if terrain.rockclimb_crest
        fmRockClimb
      end
    }
  )

  HiddenMoveHandlers::CanUseMove.add(:ROCKCLIMB, proc { |move, pkmn, showmsg|
    next false if !pbCanUseMove(Item_RockClimb)
    if !$game_player.pbFacingTerrainTag.can_climb
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
    next true
    })

  HiddenMoveHandlers::UseMove.add(:ROCKCLIMB, proc { |move, pokemon|
    fmRockClimb
    next true
    })
end

#===============================================================================
# Defog Field Move
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if !Item_Defog[:active]

  def fmDefog
    move = :DEFOG
    movefinder = $player.get_pokemon_with_move(move)
    if !pbCanUseMove(Item_Defog)  || (!movefinder)
      pbMessage(_INTL("You can't use the {1} yet.", GameData::Move.get(move).name))
      return false
    end
    if $game_screen.weather_type==:Fog
      if !pbCanUseMove(Item_Defog) || (!movefinder)
        pbMessage(_INTL("This fog is very heavy. Could be defog with the right move"))
        return false
      end
      if pbConfirmMessage(_INTL("This fog is very heavy.\nWould you like to use the {1}", GameData::Move.get(move).name))
        speciesname = (movefinder) ? movefinder.name : $player.name
        pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
        pbHiddenMoveAnimation(movefinder)
        $game_screen.weather(:None, 9, 20)
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $stats.defog_count += 1
        return true
      end
      return false
    end
  end

  HiddenMoveHandlers::CanUseMove.add(:DEFOG, proc { |move, pkmn, showmsg|
    next false if !pbCanUseMove(Item_Defog)
    move = :DEFOG
    if $game_screen.weather_type == :None
      pbMessage(_INTL("There is no fog to clear.")) if showmsg
      next false
    end
    if $game_screen.weather_type != :Fog
      pbMessage(_INTL("Can't use that here.")) if showmsg
      next false
    end
    next true
    })

  HiddenMoveHandlers::UseMove.add(:DEFOG, proc { |move, pokemon|
    fmDefog
    next true
    })

end

#===============================================================================
# Camouflage, by TechSkylander1518
#===============================================================================

if !Item_Camouflage[:active]

  HiddenMoveHandlers::CanUseMove.add(:CAMOUFLAGE, proc { |move, pkmn, showmsg|
    next false if !pbCanUseMove(Item_Camouflage)
    if !$game_player.can_ride_vehicle_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
      next false
    end
    if Item_Camouflage[:use_pp]
      for i in 0...pkmn.moves.length
        if pkmn.moves[i].id==:CAMOUFLAGE
          moveno = i
        end
      end
      if pkmn.moves[moveno].pp==0
        pbMessage(_INTL("Not enough PP...")) if showmsg
        next false
      end
    end
    next true
  })

  HiddenMoveHandlers::UseMove.add(:CAMOUFLAGE, proc { |move, pokemon|
    move = :CAMOUFLAGE
    movefinder = $player.get_pokemon_with_move(move)
    speciesname = (movefinder) ? movefinder.name : $player.name
      if !$game_player.can_ride_vehicle_with_follower?
        pbMessage(_INTL("It can't be used when you have someone with you."))
        next 0
      end
      if $game_player.camouflage == true
        if pbConfirmMessage(_INTL("Camouflage is already being used. Reappear?"))
          else
          next false
        end
      end
      if Item_Camouflage[:use_pp]
        for i in 0...pokemon.moves.length
          if pokemon.moves[i].id==:CAMOUFLAGE
            pokemon.moves[i].pp -= 1
          end
        end
      end
      aifmVanish
      if $game_player.camouflage == true
        pbMessage(_INTL("{1} helped {2} turn invisible!", speciesname, $Trainer.name))
      else
        pbMessage(_INTL("{1} helped {2} turn visible!", speciesname, $Trainer.name))
      end
      next 1
  })

end
