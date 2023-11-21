#===============================================================================
# Adds Rock Climb to TerrainTag
#===============================================================================

module GameData
  class TerrainTag
    attr_reader :rockclimb   # The main part only, not the crest
    attr_reader :rockclimb_crest
    attr_reader :can_climb
    attr_reader :whirlpool

    alias advanceditemsfieldmoves_init initialize
    def initialize(hash)
      advanceditemsfieldmoves_init(hash)
      @rockclimb              = hash[:rockclimb]              || false
      @rockclimb_crest        = hash[:rockclimb_crest]        || false
      @can_climb              = hash[:can_climb]              || false
      @whirlpool              = hash[:whirlpool]              || false

    end

    def can_surf_freely
      return @can_surf && !@waterfall && !@waterfall_crest && !@whirlpool
    end
  end
end
#===============================================================================
# More TerrainTag
#===============================================================================

GameData::TerrainTag.register({
  :id                     => :"Rock Climb",
  :id_number              => AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:number_rockclimb],
  :can_climb              => true,
  :rockclimb              => true
})

GameData::TerrainTag.register({
  :id                     => :"Rock Climb Crest",
  :id_number              => AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:number_rockcrest],
  :can_climb              => true,
  :rockclimb_crest        => true
})

GameData::TerrainTag.register({
  :id                     => :Whirlpool,
  :id_number              => AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:number_whirlpool],
  :can_surf               => true,
  :whirlpool              => true
})

#===============================================================================
#          Overwrites functions locally to add the Rock Climb section
#===============================================================================

class Game_Map
  def playerPassable?(x, y, d, self_event = nil)
    bit = (1 << ((d / 2) - 1)) & 0x0f
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      passage = @passages[tile_id]
      if terrain
        # Ignore bridge tiles if not on a bridge
        next if terrain.bridge && $PokemonGlobal.bridge == 0
        # Make water tiles passable if player is surfing
        return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall && !terrain.whirlpool 
        # Prevent cycling in really tall grass/on ice
        return false if $PokemonGlobal.bicycle && terrain.must_walk
        # Depend on passability of bridge tile if on bridge
        if terrain.bridge && $PokemonGlobal.bridge > 0
          return (passage & bit == 0 && passage & 0x0f != 0x0f)
        end
      end
      next if terrain&.ignore_passability
      # Regular passability checks
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[tile_id] == 0
    end
    return true
  end
end
