#===============================================================================
# Additional Game Stats
#===============================================================================
class GameStats < GameStats
  attr_accessor :dig_count
  attr_accessor :dive_ascend_count
  attr_accessor :sweetscent_count
  attr_accessor :teleport_count
  attr_accessor :whirlpool_cross_count
  attr_accessor :rockclimb_ascend_count
  attr_accessor :rockclimb_descend_count
  attr_accessor :ice_smash_count
  attr_accessor :defog_count
  attr_accessor :wg_clear_count      #Clear Sky | None
  attr_accessor :wg_sunny_count      #Sunny
  attr_accessor :wg_rain_count       #Rain
  attr_accessor :wg_hail_count       #Hail
  attr_accessor :wg_sandstorm_count  #Sandstorm
  attr_accessor :wg_fog_count        #Fog
  attr_accessor :wg_count            #Count
  attr_accessor :camouflage_count
  attr_accessor :wg_none             #Clear Sky | None
  attr_accessor :wg_sunny            #Sunny
  attr_accessor :wg_rain             #Rain
  attr_accessor :wg_hail             #Snow
  attr_accessor :wg_sandstorm        #Sandstorm
  attr_accessor :wg_fog              #Fog
  attr_accessor :temp_count

  alias advanceditemsfieldmoves_init initialize
  def initialize
    advanceditemsfieldmoves_init
    @dig_count                     = 0
    @dive_ascend_count             = 0
    @sweetscent_count              = 0
    @teleport_count                = 0
    @whirlpool_cross_count         = 0
    @rockclimb_ascend_count        = 0
    @rockclimb_descend_count       = 0
    @ice_smash_count               = 0
    @defog_count                   = 0
    @wg_clear_count                = 0
    @wg_sunny_count                = 0
    @wg_rain_count                 = 0
    @wg_hail_count                 = 0
    @wg_sandstorm_count            = 0
    @wg_fog_count                  = 0
    @wg_count                      = 0
    @camouflage_count              = 0
    @wg_none                       = false
    @wg_sunny                      = false
    @wg_rain                       = false
    @wg_hail                       = false
    @wg_sandstorm                  = false
    @wg_fog                        = false
    @temp_count                    = 0
  end
end

def showStats
  id = "Camouflage"
  pbMessage(_INTL("{1} is set to {2}!", id, $stats.camouflage))
end

def aiTestPlus
  return false if $stats.temp_count  == -1
  $stats.temp_count  += 1
end

#===============================================================================
# Additional Character state
#===============================================================================

class Game_Player < Game_Character
    attr_accessor :camouflage

    alias camouflage_initialize initialize
    def initialize(*arg)
      camouflage_initialize
      @camouflage     = false
    end
end
