#===============================================================================
# => Weather Gadget
#===============================================================================

def aiMenuWG
  item_name = GameData::Item.get(Item_WeatherGadget[:internal_name]).name
  pbMessage(_INTL("\\se[PC open]{1} booted up the {2}.", $player.name, item_name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:weather_choice) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("Choose one to alter the weather!"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
  pbSEPlay("PC close")
end

MenuHandlers.add(:weather_choice, :clear, {
  "name"      => _INTL("Clear sky"),
  "order"     => 10,
  "condition" => proc { next $stats.wg_none == true && !($game_screen.weather_type == :None)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be Clear sky?"))
      if ($stats.wg_sunny == true && $game_screen.weather_type == :Sun) ||
         ($stats.wg_rain == true && $game_screen.weather_type == :Rain || $game_screen.weather_type == :HeavyRain) ||
         ($stats.wg_hail == true && $game_screen.weather_type == :Snow || $game_screen.weather_type==:Blizzard) ||
         ($stats.wg_sandstorm == true && $game_screen.weather_type == :Sandstorm) ||
         ($stats.wg_fog == true && $game_screen.weather_type == :Fog)
        pbMessage(_INTL("The Weather have alter!\nIt started to clear up!"))
        $game_screen.weather(:None, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_clear_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter this weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :sunny, {
  "name"      => _INTL("Sunny"),
  "order"     => 20,
  "condition" => proc { next $stats.wg_sunny == true && !($game_screen.weather_type==:Sun) && !(PBDayNight.isNight?)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be Sunny?"))
      if ($stats.wg_none == true && $game_screen.weather_type == :None) ||
         ($stats.wg_rain == true && $game_screen.weather_type == :Rain || $game_screen.weather_type == :HeavyRain) ||
         ($stats.wg_hail == true && $game_screen.weather_type == :Snow || $game_screen.weather_type==:Blizzard) ||
         ($stats.wg_sandstorm == true && $game_screen.weather_type == :Sandstorm) ||
         ($stats.wg_fog == true && $game_screen.weather_type == :Fog)
        pbMessage(_INTL("The Weather have alter!\nThe sun is starting to shine brigther!"))
        $game_screen.weather(:Sun, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_sunny_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter this weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :rain, {
  "name"      => _INTL("Rain"),
  "order"     => 30,
  "condition" => proc { next $stats.wg_rain == true && !($game_screen.weather_type == :Rain || $game_screen.weather_type == :HeavyRain)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be Rain?"))
      if ($stats.wg_none == true && $game_screen.weather_type == :None) ||
         ($stats.wg_sunny == true && $game_screen.weather_type == :Sun) ||
         ($stats.wg_hail == true && $game_screen.weather_type == :Snow || $game_screen.weather_type==:Blizzard) ||
         ($stats.wg_sandstorm == true && $game_screen.weather_type == :Sandstorm) ||
         ($stats.wg_fog == true && $game_screen.weather_type == :Fog)
        pbMessage(_INTL("The Weather have alter!\nIt started to Rain!"))
        $game_screen.weather(:Rain, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_rain_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter this weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :hail, {
  "name"      => _INTL("Hail"),
  "order"     => 40,
  "condition" => proc { next $stats.wg_hail == true && !($game_screen.weather_type==:Snow || $game_screen.weather_type==:Blizzard)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be Snowy?"))
      if ($stats.wg_none == true && $game_screen.weather_type == :None) ||
         ($stats.wg_sunny == true && $game_screen.weather_type == :Sun) ||
         ($stats.wg_rain == true && $game_screen.weather_type == :Rain || $game_screen.weather_type==:HeavyRain) ||
         ($stats.wg_sandstorm == true && $game_screen.weather_type == :Sandstorm) ||
         ($stats.wg_fog == true && $game_screen.weather_type == :Fog)
        pbMessage(_INTL("The Weather have alter!\nIt started to Snow!"))
        $game_screen.weather(:Snow, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_hail_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter this weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :sandstorm, {
  "name"      => _INTL("Sandstorm"),
  "order"     => 50,
  "condition" => proc { next $stats.wg_sandstorm == true && !($game_screen.weather_type==:Sandstorm)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be a Sandstorm?"))
      if ($stats.wg_none == true && $game_screen.weather_type == :None) ||
         ($stats.wg_sunny == true && $game_screen.weather_type == :Sun) ||
         ($stats.wg_rain == true && $game_screen.weather_type == :Rain || $game_screen.weather_type==:HeavyRain) ||
         ($stats.wg_hail == true && $game_screen.weather_type==:Snow || $game_screen.weather_type==:Blizzard) ||
         ($stats.wg_fog == true && $game_screen.weather_type == :Fog)
        pbMessage(_INTL("The Weather have alter!\nA Sandstorm have started!"))
        $game_screen.weather(:Sandstorm, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_sandstorm_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter this weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :fog, {
  "name"      => _INTL("Fog"),
  "order"     => 60,
  "condition" => proc { next $stats.wg_fog == true && !($game_screen.weather_type == :Fog)},
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    if pbConfirmMessage(_INTL("Would you alter the weather to be Foggy?"))
      if ($stats.wg_none == true && $game_screen.weather_type == :None) ||
         ($stats.wg_sunny == true && $game_screen.weather_type == :Sun) ||
         ($stats.wg_rain == true && $game_screen.weather_type == :Rain || $game_screen.weather_type==:HeavyRain) ||
         ($stats.wg_hail == true && $game_screen.weather_type==:Snow || $game_screen.weather_type==:Blizzard) ||
         ($stats.wg_sandstorm == true && $game_screen.weather_type == :Sandstorm)
        pbMessage(_INTL("The Weather have alter!\nA heavy fog is starting to show!"))
        $game_screen.weather(:Fog, 9, 20)
          Graphics.update
          Input.update
          pbUpdateSceneMap
          $stats.wg_fog_count += 1
          $stats.wg_count += 1
        next true
      end
      pbMessage(_INTL("You don't have permission to alter the current weather yet!"))
    end
    next true
  }
})

MenuHandlers.add(:weather_choice, :close, {
  "name"      => _INTL("Shutdown"),
  "order"     => 100,
  "effect"    => proc { |menu|
    next true
  }
})

#===============================================================================
# => Quick Menu Camouflage
#===============================================================================

if Item_Camouflage[:menu]
  if !Item_Camouflage[:active]
    def pbUseKeyItem
      moves = [:CAMOUFLAGE, :CUT, :DEFOG, :DIG, :DIVE, :FLASH, :FLY, :HEADBUTT, :ROCKCLIMB,
        :ROCKSMASH, :SECRETPOWER, :STRENGTH, :SURF, :SWEETSCENT, :TELEPORT,
        :WATERFALL, :WHIRLPOOL]
        real_moves = []
        moves.each do |move|
          $player.party.each_with_index do |pkmn, i|
            next if pkmn.egg? || !pkmn.hasMove?(move)
            real_moves.push([move, i]) if pbCanUseHiddenMove?(pkmn, move, false)
          end
        end
        real_items = []
        $bag.registered_items.each do |i|
          itm = GameData::Item.get(i).id
          real_items.push(itm) if $bag.has?(itm)
        end
        if real_items.length == 0 && real_moves.length == 0
          pbMessage(_INTL("An item in the Bag can be registered to this key for instant use."))
        else
          $game_temp.in_menu = true
          $game_map.update
          sscene = PokemonReadyMenu_Scene.new
          sscreen = PokemonReadyMenu.new(sscene)
          sscreen.pbStartReadyMenu(real_moves, real_items)
          $game_temp.in_menu = false
        end
    end
  end
end
