class PokemonBag
    def randomize_bag
        $game_switches[90] = true
        reset_last_selections
        @registered_items = []
        @ready_menu_selection = [0, 0, 1] # Used by the Ready Menu to remember cursor positions

        @pockets.each do |pocket|
            pocket.each do |item|
                new_item = get_random_item()
                replace_item(item[0], new_item.id)
            end
        end
    end

    alias orig_remove remove

    def remove(item, qty = 1)
        if $game_switches[90]
            return true
        end

        return orig_remove(item, qty)
    end

    def get_random_item
        itemlist = []
        GameData::Item.each do |i|
            itemlist.push(i)
        end

        return itemlist.sample
    end
end

class Battle::Battler
    def pbChangeMove(slot_id, move)
        @pokemon.moves[slot_id] = Pokemon::Move.new(move) # Replaces current/total PP
        @moves[slot_id] = Battle::Move.from_pokemon_move(@battle, @pokemon.moves[slot_id])
        @battle.scene.pbRefresh
    end

    def pbRandomizeStats(limit = 3)
        prevStages = @stages.clone

        @stages[:ATTACK] = rand(-limit..limit)
        if @stages[:ATTACK] > prevStages[:ATTACK]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("ATTACK Up!")
        elsif @stages[:ATTACK] < prevStages[:ATTACK]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("ATTACK Down!")
        end

        @stages[:SPECIAL_ATTACK] = rand(-limit..limit)
        if @stages[:SPECIAL_ATTACK] > prevStages[:SPECIAL_ATTACK]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPECIAL_ATTACK Up!")
        elsif @stages[:SPECIAL_ATTACK] < prevStages[:SPECIAL_ATTACK]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPECIAL_ATTACK Down!")
        end

        @stages[:DEFENSE] = rand(-limit..limit)
        if @stages[:DEFENSE] > prevStages[:DEFENSE]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("DEFENSE Up!")
        elsif @stages[:DEFENSE] < prevStages[:DEFENSE]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("DEFENSE Down!")
        end

        @stages[:SPECIAL_DEFENSE] = rand(-limit..limit)
        if @stages[:SPECIAL_DEFENSE] > prevStages[:SPECIAL_DEFENSE]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPECIAL_DEFENSE Up!")
        elsif @stages[:SPECIAL_DEFENSE] < prevStages[:SPECIAL_DEFENSE]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPECIAL_DEFENSE Down!")
        end

        @stages[:SPEED] = rand(-limit..limit)
        if @stages[:SPEED] > prevStages[:SPEED]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPEED Up!")
        elsif @stages[:SPEED] < prevStages[:SPEED]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPEED Down!")
        end

        @stages[:ACCURACY] = rand(-limit..limit)
        if @stages[:ACCURACY] > prevStages[:ACCURACY]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("ACCURACY Up!")
        elsif @stages[:ACCURACY] < prevStages[:ACCURACY]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("ACCURACY Down!")
        end

        echoln(@stages)
    end

    def get_random_move
        movelist = []
        GameData::Move.each do |i|
            movelist.push(i)
        end

        return movelist.sample
    end

end

def pbChangeBattlerSpecies(pkmn, battler, battle)

    speciesTab = []
    GameData::Species.each do |s|
        speciesTab.push(s)
    end
    specie = speciesTab.sample().id
    echoln(specie)
    echoln(pkmn.species)
    if specie != pkmn.species
        pkmn.species = specie
        battler.species = specie
        battler&.pbUpdate(true)
        battler.name = pkmn.name
    end
end

