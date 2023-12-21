class PokemonPartyScreen 
  def pbPokemonScreen
    can_access_storage = false
    if ($player.has_box_link || $bag.has?(:POKEMONBOXLINK)) &&
       !$game_switches[Settings::DISABLE_BOX_LINK_SWITCH] &&
       !$game_map.metadata&.has_flag?("DisableBoxLink")
      can_access_storage = true
    end
    @scene.pbStartScene(@party,
                        (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),
                        nil, false, can_access_storage)
    # Main loop
    loop do
      # Choose a Pokémon or cancel or press Action to quick switch
      @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      party_idx = @scene.pbChoosePokemon(false, -1, 1)
      break if (party_idx.is_a?(Numeric) && party_idx < 0) || (party_idx.is_a?(Array) && party_idx[1] < 0)
      # Quick switch
      if party_idx.is_a?(Array) && party_idx[0] == 1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        old_party_idx = party_idx[1]
        party_idx = @scene.pbChoosePokemon(true, -1, 2)
        pbSwitch(old_party_idx, party_idx) if party_idx >= 0 && party_idx != old_party_idx
        next
      end
      # Chose a Pokémon
      pkmn = @party[party_idx]
      # Get all commands
      command_list = []
      commands = []
      MenuHandlers.each_available(:party_menu, self, @party, party_idx) do |option, hash, name|
        command_list.push(name)
        commands.push(hash)
      end
      command_list.push(_INTL("Cancel"))
      # Add field move commands
      if !pkmn.egg?
        insert_index = ($DEBUG) ? 2 : 1
        pkmn.moves.each_with_index do |move, i|
          next if !HiddenMoveHandlers.hasHandler(move.id) &&
                  ![:MILKDRINK, :SOFTBOILED, :SELFDESTRUCT, :EXPLOSION].include?(move.id)
          command_list.insert(insert_index, [move.name, 1])
          commands.insert(insert_index, i)
          insert_index += 1
        end
      end
      # Choose a menu option
      choice = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), command_list)
      next if choice < 0 || choice >= commands.length
      # Effect of chosen menu option
      case commands[choice]
      when Hash   # Option defined via a MenuHandler below
        commands[choice]["effect"].call(self, @party, party_idx)
      when Integer   # Hidden move's index
        move = pkmn.moves[commands[choice]]
        if [:MILKDRINK, :SOFTBOILED].include?(move.id)
          amt = [(pkmn.totalhp / 5).floor, 1].max
          if pkmn.hp <= amt
            pbDisplay(_INTL("Not enough HP..."))
            next
          end
          @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          old_party_idx = party_idx
          loop do
            @scene.pbPreSelect(old_party_idx)
            party_idx = @scene.pbChoosePokemon(true, party_idx)
            break if party_idx < 0
            newpkmn = @party[party_idx]
            movename = move.name
            if party_idx == old_party_idx
              pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
            elsif newpkmn.egg?
              pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
            elsif newpkmn.fainted? || newpkmn.hp == newpkmn.totalhp
              pbDisplay(_INTL("{1} can't be used on that Pokémon.", movename))
            else
              pkmn.hp -= amt
              hpgain = pbItemRestoreHP(newpkmn, amt)
              @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", newpkmn.name, hpgain))
              pbRefresh
            end
            break if pkmn.hp <= amt
          end
          @scene.pbSelect(old_party_idx)
          pbRefresh
		elsif [:SELFDESTRUCT, :EXPLOSION].include?(move.id)
      if $game_switches[81]
		    $game_variables[MOVELIST]=[:EXPLOSION]
		    pbMapInterpreter.pbSetSelfSwitch(1, "A", false)
		    pbMapInterpreter.pbSetSelfSwitch(5, "A", false)
		    pbMapInterpreter.pbSetSelfSwitch(6, "A", false)
		    pbMapInterpreter.pbSetSelfSwitch(7, "A", false)
			  movename = move.name
			  pbDisplay(_INTL("{1} used {2}!", pkmn.name, movename))
			  for pkmn in @party
				  amt = [(pkmn.totalhp / 4).floor, 1].max
				  pkmn.hp -= amt
			  end
			  secretmap(pbGet(63)[0],pbGet(55))
			  directions=pbGet(63)[0][pbGet(55)[0]][pbGet(55)[1]]
			  if !directions.include?("Left")
			  	pbMapInterpreter.pbSetSelfSwitch(1, "A", true)
			  end
			  if !directions.include?("Up")
				  pbMapInterpreter.pbSetSelfSwitch(5, "A", true)
			  end
			  if !directions.include?("Right")
				  pbMapInterpreter.pbSetSelfSwitch(6, "A", true)
			  end
			  if !directions.include?("Down")
				  pbMapInterpreter.pbSetSelfSwitch(7, "A", true)
			  end
			  $game_map.refresh
			  Graphics.update
		  else
			pbDisplay("You can't explode here.")
		  end
      elsif pbCanUseHiddenMove?(pkmn, move.id)
          if pbConfirmUseHiddenMove(pkmn, move.id)
            @scene.pbEndScene
            if move.id == :FLY
              scene = PokemonRegionMap_Scene.new(-1, false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartFlyScreen
              if ret
                $game_temp.fly_destination = ret
                return [pkmn, move.id]
              end
              @scene.pbStartScene(
                @party, (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel.")
              )
              next
            end
            return [pkmn, move.id]
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end


def pbboom
  if $game_switches[81]
		  pbMapInterpreter.pbSetSelfSwitch(1, "A", false)
		  pbMapInterpreter.pbSetSelfSwitch(5, "A", false)
		  pbMapInterpreter.pbSetSelfSwitch(6, "A", false)
		  pbMapInterpreter.pbSetSelfSwitch(7, "A", false)
		  
			secretmap(pbGet(63)[0],pbGet(55))
			directions=pbGet(63)[0][pbGet(55)[0]][pbGet(55)[1]]
			if !directions.include?("Left")
				pbMapInterpreter.pbSetSelfSwitch(1, "A", true)
			end
			if !directions.include?("Up")
				pbMapInterpreter.pbSetSelfSwitch(5, "A", true)
			end
			if !directions.include?("Right")
				pbMapInterpreter.pbSetSelfSwitch(6, "A", true)
			end
			if !directions.include?("Down")
				pbMapInterpreter.pbSetSelfSwitch(7, "A", true)
			end
			$game_map.refresh
			Graphics.update
	else
			pbDisplay("You can't explode here.")
	end
end

ItemHandlers::UseInField.add(:BOMB, proc { |item|  
  if $game_switches[81]
	  pbboom
	else
		pbMessage("You can't use a bomb here!")
	end
})