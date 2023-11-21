  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
def pbStorePokemonadd(pkmn)
    # Store the Pokémon
    if $player.party_full?
      cmds = [_INTL("Add to your party"),
              _INTL("Send to a Box"),
              _INTL("See {1}'s summary", pkmn.name)]
      loop do
        cmd= pbMessage(_INTL("Where do you want to send {1} to?", pkmn.name),cmds,2,nil,0)
        case cmd
        when 0   # Add to your party
          party_index = -1
		    pbFadeOutIn {
			scene = PokemonParty_Scene.new
			screen = PokemonPartyScreen.new(scene, $player.party)
			screen.pbStartScene(_INTL("Choose a Pokémon to move in the PC."), false)
			party_index = screen.pbChoosePokemon
			screen.pbEndScene
		  }
          next if party_index < 0   # Cancelled
          # Send chosen Pokémon to storage
          # NOTE: This doesn't work properly if you catch multiple Pokémon in
          #       the same battle, because the code below doesn't alter the
          #       contents of pbParty(0), only pbPlayer.party. This means that
          #       viewing the party in battle after replacing a party Pokémon
          #       with a caught one (which is possible if you've caught a second
          #       Pokémon) will not show the first caught Pokémon in the party
          #       but will still show the boxed Pokémon in the party. Correcting
          #       this would take a surprising amount of code, and it's very
          #       unlikely to be needed anyway, so I'm ignoring it for now.
          send_pkmn = $player.party[party_index]
          pbStorePokemon(send_pkmn)
          $player.party.delete_at(party_index)
          break
        when 1   # Send to a Box
          break
        when 2   # See X's summary
          pbFadeOutIn {
            summary_scene = PokemonSummary_Scene.new
            summary_screen = PokemonSummaryScreen.new(summary_scene, true)
            summary_screen.pbStartScreen([pkmn], 0)
          }
      end 
	end	
  end	# Store as normal (add to party if there's space, or send to a Box if not)
  pbStorePokemon(pkmn)
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  pbNickname(pkmn)
  pbStorePokemonadd(pkmn)
end

