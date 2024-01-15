################evo#############################################
def setNewStage(pokemon)
	regional_forms= [
    :RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE,
    :GRIMER, :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON,
    :DARUMAKA, :YAMASK, :STUNFISK, :SLOWPOKE, :ARTICUNO, :ZAPDOS,
    :MOLTRES, :PIKACHU, :EXEGGCUTE, :CUBONE, :KOFFING, :MIMEJR,
    :BURMY, :DEERLING, :MINIOR, :PUMPKABOO
  ]
	form = pokemon.form   # regional form
    pokemon.species = GameData::Species.get(pokemon.species)#.get_baby_species # revert to the first stage
    regionalForm = false
    for species in regional_forms do
      regionalForm = true if pokemon.isSpecies?(species)
    end

    2.times do |stage|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions(false)

      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      if !other_evolving_method && !regionalForm   # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
          pokemon.setForm(form) if regionalForm
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = stage == 0 ? Firstevo : Secondevo

        if pokemon.level >= level
          if evolutions.length == 1         # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
            pokemon.setForm(form) if regionalForm

          elsif evolutions.length > 1
            if regionalForm
              if form > evolutions.length  # regional form
                pokemon.species = evolutions[0][0]
                pokemon.setForm(form)
              else                          # regional evolution
                if !pokemon.isSpecies?(:MEOWTH)
                  pokemon.species = evolutions[form][0]

                else  # Meowth has two possible evolutions and a regional form depending on its origin region
				  
                  if form == 0 || form == 1
                    pokemon.species = evolutions[0][0]
                    pokemon.setForm(form)
                  else
                    pokemon.species = evolutions[1][0]
                  end
                end
              end

            else                            # Species with multiple possible evolutions
              pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
            end
          end
        
      end
    end
  end

end
#######Level Scaling#######################################

Firstevo=30
Secondevo=30
EventHandlers.add(:on_trainer_load, :simple_scaling,
  proc { |trainer|
   if trainer   
		if !$game_switches[64] && $game_variables[45]<4
			if $game_variables[36]<10
				trainer.party.pop()
				trainer.party.pop()
				trainer.party.pop()
			elsif $game_variables[36]<20
				trainer.party.pop()
				trainer.party.pop()
      else
				trainer.party.pop()
			end
			for pkmn in trainer.party
				pkmn.species=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
				pkmn.level=pbBalancedLevel($player.party)-6+rand(4)
				setNewStage(pkmn)
				pkmn.reset_moves
				pkmn.calc_stats
			end
		end
		if !$game_switches[64] && $game_variables[45]>=4
			if $game_variables[45]==4
				tier=["PU","PU","NU","NU","RU","UU"]
				order=tier.shuffle()
			elsif $game_variables[45]==5
				tier=["PU","NU","NU","RU","RU","UU"]
				order=tier.shuffle()
			elsif $game_variables[45]==6
				tier=["NU","NU","RU","RU","UU","UU"]
				order=tier.shuffle()
			elsif $game_variables[45]==7
				tier=["NU","RU","RU","UU","UU","OU"]
				order=tier.shuffle()
			elsif $game_variables[45]==8
				tier=["RU","UU","UU","UU","OU","OU"]
				order=tier.shuffle()
			else $game_variables[45]==9
				tier=["UU","UU","UU","OU","OU","OU"]
				order=tier.shuffle()
			end
			for i in 0...trainer.party.length
					pk=genrandpkmn("Data/Rand_trainer/"+order[i]+".txt")
					trainer.party[i]=pk
					trainer.party[i].level=pbBalancedLevel($player.party)-6+rand(4)
					trainer.party[i].calc_stats
			end
		end
   end
  }
)



