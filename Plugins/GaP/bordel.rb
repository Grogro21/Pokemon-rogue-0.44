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

def pbDawa()
    if $game_switches[86]
        return
    end
    pbChangePlayer(4)
    $player.name = "RÊ¨Y8+45bËRr0Rj77Zx0c"
    $stats.play_time = 2399997600
    $game_map.fog_name = "glitch"
    $game_map.fog_hue = 0
    $game_map.fog_opacity = 127
    $game_map.fog_blend_type = 0
    $game_map.fog_zoom = 100
    $game_map.fog_sx = 0
    $game_map.fog_sy = 0

    (1...3).each do |_|
        pbGlitchFog
    end

    $game_switches[86] = true
    Game.save

    exit(0)
end

def pbGlitchFog()
    (1...25).each do |i|
        pbWait(0.01)
        $game_map.fog_hue = i * 10
        $game_map.refresh
    end
    (1...25).each do |i|
        pbWait(0.01)
        $game_map.fog_hue = (25 - i) * 10
        $game_map.refresh
    end
end

# class Game_Player
#     alias origUpdate update
#     alias origCtor initialize
#     attr_accessor :is_disable_movement
#
#     def initialize(*arg)
#         @is_disable_movement = false
#
#         origCtor(arg)
#     end
#
#     def togglePlayerMove()
#         @is_disable_movement = !@is_disable_movement
#     end
#
#     def update
#         if @is_disable_movement
#             return
#         end
#
#         origUpdate
#     end
# end
