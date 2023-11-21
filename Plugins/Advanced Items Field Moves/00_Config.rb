#===============================================================================
# Configuration
#===============================================================================

# :internal_name    -> has to be an unique name, the name you define for the item in the PBS file
# :active           -> defines if this item should be used, if set to false you do not have to add an item to the PBS  file (example: if you want an item for Rock Smash but not for Cut set active for Cut to false)
#                      if the item is active you will no longer be able to use the corresponding HM Move outside of battle
# :needed_badge     -> the id of the badge required in order to use the item (0 means no badge required)
# :needed_switches  -> the switches that needs to be active in order to use the item (leave the brackets empty for no switch requirement. example: [4,22,77] would mean that the switches 4, 22 and 77 must be active)
# :use_in_debug     -> when true this item can be used in debug regardless of the requirements
# :number_terrain   -> has the number for the giving Terrain Tag

module AdvancedItemsFieldMoves

#===============================================================================
# Obstacle Smash
#===============================================================================

  ROCKSMASH_CONFIG = {
    :internal_name      => :ROCKSMASHITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false,             # Default: false

  }

  CUT_CONFIG = {
    :internal_name      => :CUTITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  ICEBARRIERE_CONFIG = {
    :internal_name      => :ICEBARRIEREITEM,  # Default: ICEBARRIEREITEM
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

#===============================================================================
# Enocunters
#===============================================================================

  HEADBUTT_CONFIG = {
    :internal_name      => :HEADBUTTITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  SWEETSCENT_CONFIG = {
    :internal_name      => :SWEETSCENTITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

#===============================================================================
# Environment Interactions
#===============================================================================

  STRENGTH_CONFIG = {
    :internal_name      => :STRENGTHITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  FLASH_CONFIG = {
    :internal_name      => :FLASHITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  DEFOG_CONFIG = {
    :internal_name      => :DEFOGITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  WEATHERGADGET_CONFIG = {
    :internal_name      => :WEATHERGADGETITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

# Use codes below to enable the weather gadget functions to be able to change the weather
# You can control what functions (weather) the player i able to use/get and you can remove them as well
# => toggleClearSkyWG  = Swtich between having the the effect to use [Clear Sky] on the device
# => toggleSunnyWG     = Swtich between having the the effect to use [Sun] on the device
# => toggleRainWG      = Swtich between having the the effect to use [Rain] on the device
# => toggleHailWG      = Swtich between having the the effect to use [Snow] sky on the device
# => toggleSandstormWG = Swtich between having the the effect to use [Sandstorm] on the device
# => toggleFogWG       = Swtich between having the the effect to use [Fog] on the device
#
# => toggleddAllWG
#
# Look at https://essentialsdocs.fandom.com/wiki/Weather for more weather info

CAMOUFLAGE_CONFIG = {
  :internal_name      => :CAMOUFLAGEITEM,
  :active             => true,               # Default: true
  :needed_badge       => 0,                  # Default: 0
  :needed_switches    => [],                 # Default: []
  :use_in_debug       => false,              # Default: false
  :orignal_effect     => false,              # Default: false
  # If set to true you become fully transparent like in TechSkylander1518 Script
  # If set to false you will become 20% transparent
  :use_pp             => false,              # Default: false
  :menu               => false               # Default: false
}

# => Using Camouflage by TechSkylander1518
# => Events triggered by player touch will still be affected, so there's no need to worry about those becoming broken! However
#    it will look a bit awkward for NPCs to chat with the invisible player- I'd suggest running an event with this check:
#
#    if $game_player.camouflage==true
#    aifmVanish

#===============================================================================
# Water Movement
#===============================================================================

  SURF_CONFIG = {
    :internal_name      => :SURFITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false,             # Default: false
    #Merge Combines the Water Movement items into the Surf item
    :merge              => false              # Default: false
  }

  DIVE_CONFIG = {
    :internal_name      => :DIVEITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  WATERFALL_CONFIG = {
    :internal_name      => :WATERFALLITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  WHIRLPOOL_CONFIG = {
    :internal_name      => :WHIRLPOOLITEM,    # Default: WHIRLPOOLITEM
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false,             # Default: false
    #TerrainTagNumber
    :number_whirlpool   => 20,                # Default: 20
    #Animation Number
    :move_up_id         => 25,                 # Default: 25
    :move_left_id       => 26,                 # Default: 26
    :move_right_id      => 27,                 # Default: 27
    :move_down_id       => 28                  # Default: 28
  }
#===============================================================================
# Other Movement
#===============================================================================

  FLY_CONFIG = {
    :internal_name      => :FLYITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  DIG_CONFIG = {
    :internal_name      => :DIGITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  TELEPORT_CONFIG = {
    :internal_name      => :TELEPORTITEM,
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false              # Default: false
  }

  ROCKCLIMB_CONFIG = {
    :internal_name      => :ROCKCLIMBITEM,    # Default: ROCKCLIMBITEM
    :active             => true,              # Default: true
    :needed_badge       => 0,                 # Default: 0
    :needed_switches    => [],                # Default: []
    :use_in_debug       => false,             # Default: false
    #TerrainTagNumber
    :number_rockclimb   => 18,                # Default: 18
    :number_rockcrest   => 19,                # Default: 19
    #Animation Number
    :debris_id          => 19,                # Default: 19
    :move_up_id         => 20,                # Default: 20
#    :move_left_id       => 21,                # Default: 21
#    :move_right_id      => 22,                # Default: 22
    :move_down_id       => 23,                # Default: 23
    :dust_id            => 24,                # Default: 24
    :base_rockclimb     => false              # Default: false
  }
end
