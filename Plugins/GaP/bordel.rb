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
    $game_screen.start_tone_change(Tone.new(-255, -255, -255, 1), 1)
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

def pbMoveTutorAnnotations(move, movelist = nil)
    ret = []
    $player.party.each_with_index do |pkmn, i|
        if pkmn.egg?
            ret[i] = _INTL("NOT ABLE")
        elsif pkmn.hasMove?(move)
            ret[i] = _INTL("LEARNED")
        else
            species = pkmn.species
            if movelist&.any? { |j| j == species }
                # Checked data from movelist given in parameter
                ret[i] = _INTL("ABLE")
            elsif pkmn.compatible_with_move?(move)
                # Checked data from Pokémon's tutor moves in pokemon.txt
                ret[i] = _INTL("ABLE")
            elsif $game_variables[45] >= 6
                ret[i] = _INTL("ABLE")
            else
                ret[i] = _INTL("NOT ABLE")
            end
        end
    end
    return ret
end

def pbMoveTutorChoose(move, movelist = nil, bymachine = false, oneusemachine = false)
    ret = false
    move = GameData::Move.get(move).id
    if movelist.is_a?(Array)
        movelist.map! { |m| GameData::Move.get(m).id }
    end
    pbFadeOutIn do
        movename = GameData::Move.get(move).name
        annot = pbMoveTutorAnnotations(move, movelist)
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $player.party)
        screen.pbStartScene(_INTL("Teach which Pokémon?"), false, annot)
        loop do
            chosen = screen.pbChoosePokemon
            break if chosen < 0
            pokemon = $player.party[chosen]
            if pokemon.egg?
                pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
            elsif pokemon.shadowPokemon?
                pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
            elsif movelist && movelist.none? { |j| j == pokemon.species } && $game_variables[45] < 6
                pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
            elsif !pokemon.compatible_with_move?(move) && $game_variables[45] < 6
                pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
            elsif pbLearnMove(pokemon, move, false, bymachine) { screen.pbUpdate }
                $stats.moves_taught_by_item += 1 if bymachine
                $stats.moves_taught_by_tutor += 1 if !bymachine
                pokemon.add_first_move(move) if oneusemachine
                ret = true
                break
            end
        end
        screen.pbEndScene
    end
    return ret # Returns whether the move was learned by a Pokemon
end

def pbGlitchFogOpacity()
    $game_map.fog_opacity = 30 + ((29 - $game_player.y) * 6)
end

def pbPablo()
    Thread.new do
        loop do
            pbGlitchFogOpacity
            Thread.pass
            if $game_switches[91]
                Thread.exit
            end
        end
    end
    Thread.new do
        loop do
            (1...25).each do |i|
                sleep(0.075)
                $game_map.fog_hue = i * 10
                $game_map.refresh
            end
            (1...25).each do |i|
                sleep(0.075)
                $game_map.fog_hue = (25 - i) * 10
                $game_map.refresh
            end
            Thread.pass
            if $game_switches[91]
                Thread.exit
            end
        end
    end
end

class Pokemon
    # Sets this Pokémon's level. The given level must be between 1 and the
    # maximum level (defined in {GameData::GrowthRate}).
    # @param value [Integer] new level (between 1 and the maximum level)
    def level=(value)
        if value < 1
            raise ArgumentError.new(_INTL("The level number ({1}) is invalid.", value))
        end
        @exp = growth_rate.minimum_exp_for_level(value)
        @level = value
    end
end

def fill_with_boss() end

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
