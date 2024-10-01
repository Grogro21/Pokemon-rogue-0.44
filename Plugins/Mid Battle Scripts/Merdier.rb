class PokemonBag
    def randomize_bag
        reset_last_selections
        @registered_items = []
        @ready_menu_selection = [0, 0, 1] # Used by the Ready Menu to remember cursor positions

        @pockets.each do |pocket|
            pocket.each do |item|
                replace_item(item[0], get_random_item().id)
            end
        end
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
end

def get_random_move
    movelist = []
    GameData::Move.each do |i|
        movelist.push(i)
    end

    return movelist.sample
end
