def test()
    pbBattlePointShop([:MEGARING, :BOMB])
end

class PokemonPauseMenu

    alias orig pbStartPokemonMenu

    def pbStartPokemonMenu()
        $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 0)
        orig
    end
end

# class Game_Player
#     alias orig moveto
#     def disablePlayerMove()
#         self.moveto = () => {}
#     end
# end
