#===============================================================================
# UseFromBag handlers
# Return values: 0 = not used
#                1 = used
#                2 = close the Bag to use
# If there is no UseFromBag handler for an item being used from the Bag (not on
# a Pokémon), calls the UseInField handler for it instead.
#===============================================================================

#===============================================================================
# Utility
#===============================================================================

class MoveHandlerHash
  def delete(sym)
    @hash.delete(sym) if sym && @hash[sym]
  end
end

def pbCheckForBadge(badge)
  return true if badge - 1 < 0
  return true if $Trainer.badges[badge - 1]
  return false
end

def pbCheckForSwitch(switches)
  return true if switches.length <= 0
  switches.each { |switch|
    if !$game_switches[switch]
      return false
    end
  }
  return true
end

def pbCanUseItem(item)
  if item[:use_in_debug]
    return true if $DEBUG
  end
  if $bag.has?(item[:internal_name]) && pbCheckForBadge(item[:needed_badge]) && pbCheckForSwitch(item[:needed_switches])
    return true
  end
  return false
end
#Obstacle Smash
Item_RockSmash      = AdvancedItemsFieldMoves::ROCKSMASH_CONFIG
Item_Cut            = AdvancedItemsFieldMoves::CUT_CONFIG
Item_IceBarriere    = AdvancedItemsFieldMoves::ICEBARRIERE_CONFIG
#Enocunters
Item_Headbutt       = AdvancedItemsFieldMoves::HEADBUTT_CONFIG
Item_SweetScent     = AdvancedItemsFieldMoves::SWEETSCENT_CONFIG
#Environment Interactions
Item_Strength       = AdvancedItemsFieldMoves::STRENGTH_CONFIG
Item_Flash          = AdvancedItemsFieldMoves::FLASH_CONFIG
Item_Defog          = AdvancedItemsFieldMoves::DEFOG_CONFIG
Item_WeatherGadget  = AdvancedItemsFieldMoves::WEATHERGADGET_CONFIG
Item_Camouflage     = AdvancedItemsFieldMoves::CAMOUFLAGE_CONFIG

#Water Movement
Item_Surf           = AdvancedItemsFieldMoves::SURF_CONFIG
if Item_Surf[:merge]
  Item_Dive         = Item_Surf
  Item_Waterfall    = Item_Surf
  Item_Whirlpool    = Item_Surf
else
  Item_Dive         = AdvancedItemsFieldMoves::DIVE_CONFIG
  Item_Waterfall    = AdvancedItemsFieldMoves::WATERFALL_CONFIG
  Item_Whirlpool    = AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG
end
#Other Movement
Item_Fly            = AdvancedItemsFieldMoves::FLY_CONFIG
Item_Dig            = AdvancedItemsFieldMoves::DIG_CONFIG
Item_Teleport       = AdvancedItemsFieldMoves::TELEPORT_CONFIG
Item_RockClimb      = AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG


#===============================================================================
# Rock Smash
#===============================================================================
# This Game $stats handle by this plugin [Overwrites the defualt essentials]

if Item_RockSmash[:active]

  HiddenMoveHandlers::CanUseMove.delete(:ROCKSMASH)
  HiddenMoveHandlers::UseMove.delete(:ROCKSMASH)

  def pbRockSmash
    if !pbCanUseItem(Item_RockSmash)
      item_name = GameData::Item.get(Item_RockSmash[:internal_name]).name
      pbMessage(_INTL("It's a rugged rock but a {1} may be able to smash it.",item_name))
      return false
    end
    item_name = GameData::Item.get(Item_RockSmash[:internal_name]).name
    if pbConfirmMessage(_INTL("This rock appears to be breakable.\nWould you like to use the {1}?", item_name))
      $stats.rock_smash_count += 1
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_RockSmash[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/smashrock/i]
      next 2
    end
    item_name = GameData::Item.get(Item_RockSmash[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_RockSmash[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/smashrock/i]
      $game_player.pbFacingEvent.start
      next 1
    end
    item_name = GameData::Item.get(Item_RockSmash[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)
end

#===============================================================================
# Cut
#===============================================================================
# This Game $stats handle by this plugin [Overwrites the defualt essentials]

if Item_Cut[:active]

  HiddenMoveHandlers::CanUseMove.delete(:CUT)
  HiddenMoveHandlers::UseMove.delete(:CUT)

  def pbCut
    if !pbCanUseItem(Item_Cut)
      pbMessage(_INTL("This tree looks like it can be cut down."))
      return false
    end
    item_name = GameData::Item.get(Item_Cut[:internal_name]).name
    if pbConfirmMessage(_INTL("This tree looks like it can be cut down!\nWould you like to use the {1}?", item_name))
      $stats.cut_count += 1
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Cut[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/cuttree/i]
      next 2
    end
    item_name = GameData::Item.get(Item_Cut[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_Cut[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/cuttree/i]
      $game_player.pbFacingEvent.start
      next 1
    end
    item_name = GameData::Item.get(Item_Cut[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)
end

#===============================================================================
# Ice Barriere
#===============================================================================
if Item_IceBarriere[:active]

  def pbIceSmash
    if !pbCanUseItem(Item_IceBarriere)
      pbMessage(_INTL("This ice looks like it can be broken down."))
      return false
    end
    item_name = GameData::Item.get(Item_IceBarriere[:internal_name]).name
    if pbConfirmMessage(_INTL("This ice looks like it can be broken down.!\nWould you like to use the {1}?", item_name))
      $stats.ice_smash_count += 1
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_IceBarriere[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/smashice/i]
      next 2
    end
    item_name = GameData::Item.get(Item_IceBarriere[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_IceBarriere[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/smashice/i]
      $game_player.pbFacingEvent.start
      next 1
    end
    item_name = GameData::Item.get(Item_IceBarriere[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)
end

#===============================================================================
# Headbutt
#===============================================================================
# This Game $stats handle by this plugin [Overwrites the defualt essentials]

if Item_Headbutt[:active]

  HiddenMoveHandlers::CanUseMove.delete(:HEADBUTT)
  HiddenMoveHandlers::UseMove.delete(:HEADBUTT)

  def pbHeadbutt(event=nil)
    if !pbCanUseItem(Item_Headbutt)
      pbMessage(_INTL("A Pokémon could be in this tree. Maybe something could shake it."))
      return false
    end
    item_name = GameData::Item.get(Item_Headbutt[:internal_name]).name
    if pbConfirmMessage(_INTL("A Pokémon could be in this tree. Would you like to use {1}?", item_name))
      $stats.headbutt_count += 1
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      pbHeadbuttEffect(event)
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Headbutt[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/headbutttree/i]
      next 2
    end
    item_name = GameData::Item.get(Item_Headbutt[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_Headbutt[:internal_name], proc do |item|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/headbutttree/i]
      $game_player.pbFacingEvent.start
      next 1
    end
    item_name = GameData::Item.get(Item_Headbutt[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
  end)
end

#===============================================================================
# Sweet Scent
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]

if Item_SweetScent[:active]

  HiddenMoveHandlers::CanUseMove.delete(:SWEETSCENT)
  HiddenMoveHandlers::UseMove.delete(:SWEETSCENT)

  def aiSweetScent
    if !pbCanUseItem(Item_SweetScent)
      pbMessage(_INTL("I can't use this now!"))
      return false
    end
    if $game_screen.weather_type != :None
      pbMessage(_INTL("The sweet scent faded for some reason..."))
      return
    end
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    count = 0
    viewport.color.red   = 255
    viewport.color.green = 0
    viewport.color.blue  = 0
    viewport.color.alpha -= 10
    alphaDiff = 12 * 20 / Graphics.frame_rate
    loop do
      if count == 0 && viewport.color.alpha < 128
        viewport.color.alpha += alphaDiff
      elsif count > Graphics.frame_rate / 4
        viewport.color.alpha -= alphaDiff
      else
        count += 1
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      $stats.sweetscent_count += 1
      break if viewport.color.alpha <= 0
    end
    viewport.dispose
    enctype = $PokemonEncounters.encounter_type
    if !enctype || !$PokemonEncounters.encounter_possible_here? ||
      !pbEncounter(enctype, false)
      pbMessage(_INTL("There appears to be nothing here..."))
    end
  end

  ItemHandlers::UseFromBag.add(Item_SweetScent[:internal_name], proc do |item|
    next 2
  end)

  ItemHandlers::UseInField.add(Item_SweetScent[:internal_name], proc do |item|
    item_name = GameData::Item.get(Item_SweetScent[:internal_name]).name
    if pbConfirmMessage(_INTL("Would you like to use the {1}?", item_name))
      if !pbHiddenMoveAnimation(nil)
        item_name = GameData::Item.get(Item_SweetScent[:internal_name]).name
        pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
      end
    end
    aiSweetScent
    next 1
  end)
end

#===============================================================================
# Strength
#===============================================================================
# This Game $stats handle by defualt essentials

if Item_Strength[:active]

  HiddenMoveHandlers::CanUseMove.delete(:STRENGTH)
  HiddenMoveHandlers::UseMove.delete(:STRENGTH)

  def pbStrength
    if !pbCanUseItem(Item_Strength)
      pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside."))
      return false
    end
    pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside."))
    item_name = GameData::Item.get(Item_Strength[:internal_name]).name
    if pbConfirmMessage(_INTL("Would you like to use the {1}?", item_name))
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      pbMessage(_INTL("The {1} made it possible to move boulders around!", item_name))
      $PokemonMap.strengthUsed = true
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Strength[:internal_name], proc do |item|
    if $PokemonMap.strengthUsed
      item_name = GameData::Item.get(Item_Strength[:internal_name]).name
      pbMessage(_INTL("The {1} were already used!", item_name))
      next 0
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/strengthboulder/i]
      next 2
    end
    item_name = GameData::Item.get(Item_Strength[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to flex by using the {1} now!", item_name))
    next 0
  end)

  ItemHandlers::UseInField.add(Item_Strength[:internal_name], proc do |item|
    if $PokemonMap.strengthUsed
      item_name = GameData::Item.get(Item_Strength[:internal_name]).name
      pbMessage(_INTL("The {1} were already used!", item_name))
      next 0
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/strengthboulder/i]
      pbStrength
      next 1
    end
    item_name = GameData::Item.get(Item_Strength[:internal_name]).name
    pbMessage(_INTL("There is no sensible reason why you would be trying to flex by using {1} now!", item_name))
    next 0
  end)
end

#===============================================================================
# Flash
#===============================================================================
# This Game $stats handle by this plugin [Overwrites the defualt essentials]

if Item_Flash[:active]

  HiddenMoveHandlers::CanUseMove.delete(:FLASH)
  HiddenMoveHandlers::UseMove.delete(:FLASH)

  def areaFlash
    if !pbCanUseItem(Item_Flash)
      item_name = GameData::Item.get(Item_Flash[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} yet.", item_name))
      return false
    end
    darkness = $game_temp.darkness_sprite
    return false if !darkness || darkness.disposed?
    item_name = GameData::Item.get(Item_Flash[:internal_name]).name
    pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
    $PokemonGlobal.flashUsed = true
    $stats.flash_count += 1
    radiusDiff = 8*20/Graphics.frame_rate
    while darkness.radius<darkness.radiusMax
      Graphics.update
      Input.update
      pbUpdateSceneMap
      darkness.radius += radiusDiff
      darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
    end
  end

  ItemHandlers::UseFromBag.add(Item_Flash[:internal_name], proc do |item|
    if !GameData::MapMetadata.exists?($game_map.map_id) ||
      !GameData::MapMetadata.get($game_map.map_id).dark_map
      pbMessage(_INTL("Can't use that here."))
      next 0
    end
    if $PokemonGlobal.flashUsed
      item_name = GameData::Item.get(Item_Flash[:internal_name]).name
      pbMessage(_INTL("The {1} was already used.", item_name))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Flash[:internal_name], proc do |item|
    if !GameData::MapMetadata.exists?($game_map.map_id) ||
      !GameData::MapMetadata.get($game_map.map_id).dark_map
      pbMessage(_INTL("Can't use that here."))
      next 0
    end
    if $PokemonGlobal.flashUsed
      item_name = GameData::Item.get(Item_Flash[:internal_name]).name
      pbMessage(_INTL("The {1} is already being used.", item_name))
      next 0
    end
    areaFlash
    next 1
  end)
end

#===============================================================================
# Defog
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if Item_Defog[:active]

  def aiDefog
    if !pbCanUseItem(Item_Defog)
      item_name = GameData::Item.get(Item_Flash[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} yet.", item_name))
      return false
    end
    if $game_screen.weather_type==:Fog
      item_name = GameData::Item.get(Item_Defog[:internal_name]).name
      if pbConfirmMessage(_INTL("This fog is very heavy.\nWould you like to use the {1}", item_name))
        pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
        $game_screen.weather(:None, 9, 20)
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $stats.defog_count += 1
        return true
      end
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Defog[:internal_name], proc do |item|
    if $game_screen.weather_type == :None
      item_name = GameData::Item.get(Item_Defog[:internal_name]).name
      pbMessage(_INTL("There are no fog to clear.", item_name))
      next 0
    end
    if $game_screen.weather_type != :Fog
      pbMessage(_INTL("Can't use that here."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Defog[:internal_name], proc do |item|
    item_name = GameData::Item.get(Item_Defog[:internal_name]).name
    if $game_screen.weather_type == :None
      pbMessage(_INTL("There is no fog to clear.", item_name))
      next 0
    end
    if $game_screen.weather_type != :Fog
      pbMessage(_INTL("Can't use that here."))
      next 0
    end
    aiDefog
    next 1
  end)

end
#===============================================================================
# Weather Machine
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if Item_WeatherGadget[:active]

  def toggleClearSkyWG
    $stats.wg_none = !$stats.wg_none
  end

  def toggleSunnyWG
    $stats.wg_sunny = !$stats.wg_sunny
  end

  def toggleRainWG
    $stats.wg_rain = !$stats.wg_rain
  end

  def toggleHailWG
    $stats.wg_hail = !$stats.wg_hail
  end

  def toggleSandstormWG
    $stats.wg_sandstorm = !$stats.wg_sandstorm
  end

  def toggleFogWG
    $stats.wg_fog = !$stats.wg_fog
  end

  def toggleAllWG
    toggleClearSkyWG
    toggleSunnyWG
    toggleRainWG
    toggleHailWG
    toggleSandstormWG
    toggleFogWG
  end

  ItemHandlers::UseFromBag.add(Item_WeatherGadget[:internal_name], proc do |item|
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    item_name = GameData::Item.get(Item_WeatherGadget[:internal_name]).name
    if !map_metadata || !map_metadata.outdoor_map
      pbMessage(_INTL("Can't use the {1} indoors.", item_name))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_WeatherGadget[:internal_name], proc do |item|
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    item_name = GameData::Item.get(Item_WeatherGadget[:internal_name]).name
    if !map_metadata || !map_metadata.outdoor_map
      pbMessage(_INTL("Can't use the {1} indoors.", item_name))
      next 0
    end
    aiMenuWG
    next 1
  end)

  EventHandlers.add(:on_leave_map, :end_weather,
  proc { |new_map_id, new_map|
    next if new_map_id == 0
    old_map_metadata = $game_map.metadata
    #next if !old_map_metadata || !old_map_metadata.weather
    map_infos = pbLoadMapInfos
    if $game_map.name == map_infos[new_map_id].name
      new_map_metadata = GameData::MapMetadata.try_get(new_map_id)
      next if new_map_metadata&.weather
    end
    $game_screen.weather(:None, 0, 0)
    }
  )

end

#===============================================================================
# Camouflage
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
def aifmVanish
  if !Item_Camouflage[:orignal_effect]
    if $game_player.camouflage == false
      if PluginManager.findDirectory("Following Pokemon EX")
        pbMoveRoute(FollowingPkmn.get_event,[
          PBMoveRoute::Opacity,229, #90%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,204, #80%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,178, #70%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,153, #60%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,127, #50%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,102, #40%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,76,  #30%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,51   #20%
          ])
      end
      pbMoveRoute($game_player,[
        PBMoveRoute::Opacity,229, #90%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,204, #80%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,178, #70%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,153, #60%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,127, #50%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,102, #40%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,76,  #30%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,51   #20%
        ])
      $game_player.camouflage = true
      $stats.camouflage_count  += 1
    else
      if PluginManager.findDirectory("Following Pokemon EX")
        pbMoveRoute(FollowingPkmn.get_event,[
          PBMoveRoute::Opacity,76,  #30%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,102, #40%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,127, #50%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,153, #60%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,178, #70%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,204, #80%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,229, #90%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,255  #100%
          ])
      end
      pbMoveRoute($game_player,[
        PBMoveRoute::Opacity,76,  #30%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,102, #40%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,127, #50%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,153, #60%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,178, #70%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,204, #80%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,229, #90%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,255  #100%
        ])
      $game_player.camouflage = false
    end
  else # Orignal_effect choice
    if $game_player.camouflage == false
      if PluginManager.findDirectory("Following Pokemon EX")
        pbMoveRoute(FollowingPkmn.get_event,[
          PBMoveRoute::Opacity,229, #90%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,204, #80%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,178, #70%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,153, #60%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,127, #50%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,102, #40%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,76,  #30%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,51,  #20%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,25,  #10%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,0    #0%
          ])
      end
      pbMoveRoute($game_player,[
        PBMoveRoute::Opacity,229, #90%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,204, #80%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,178, #70%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,153, #60%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,127, #50%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,102, #40%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,76,  #30%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,51,  #20%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,25,  #10%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,0    #0%
        ])
      $game_player.camouflage = true
      $stats.camouflage_count  += 1
    else
      if PluginManager.findDirectory("Following Pokemon EX")
        pbMoveRoute(FollowingPkmn.get_event,[
          PBMoveRoute::Opacity,25,  #10%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,51,  #20%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,76,  #30%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,102, #40%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,127, #50%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,153, #60%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,178, #70%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,204, #80%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,229, #90%
          PBMoveRoute::Wait,2,
          PBMoveRoute::Opacity,255  #100%
          ])
      end
      pbMoveRoute($game_player,[
        PBMoveRoute::Opacity,25,  #10%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,51,  #20%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,76,  #30%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,102, #40%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,127, #50%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,153, #60%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,178, #70%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,204, #80%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,229, #90%
        PBMoveRoute::Wait,2,
        PBMoveRoute::Opacity,255  #100%
        ])
      $game_player.camouflage = false
    end
  end
end

def checkVanish
  if $game_player.camouflage == true
    aifmVanish
    pbMessage(_INTL("{1} broke the camouflage and turned visible!",$Trainer.name))
  end
end

if Item_Camouflage[:active]

  ItemHandlers::UseFromBag.add(Item_Camouflage[:internal_name], proc do |item|
    if !$game_player.can_ride_vehicle_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Camouflage[:internal_name], proc do |item|
    if !$game_player.can_ride_vehicle_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    if $game_player.camouflage == true
        if pbConfirmMessage(_INTL("Camouflage is already being used. Reappear?"))
          else
          next false
        end
    end
    aifmVanish
    if $game_player.camouflage == true
      item_name = GameData::Item.get(Item_Camouflage[:internal_name]).name
      pbMessage(_INTL("{1} used {2} to turn invisible!",$Trainer.name ,item_name))
    else
      pbMessage(_INTL("{1} used {2} to turn visible!",$Trainer.name ,item_name))
    end
    next 1
  end)

end

#===============================================================================
# Surf
#===============================================================================
# This Game $stats handle by defualt essentials

if Item_Surf[:active]

  HiddenMoveHandlers::CanUseMove.delete(:SURF)
  HiddenMoveHandlers::UseMove.delete(:SURF)

  def pbSurf
    return false if $game_player.pbFacingEvent
    return false if !$game_player.can_ride_vehicle_with_follower?
    if !pbCanUseItem(Item_Surf)
      item_name = GameData::Item.get(Item_Surf[:internal_name]).name
      pbMessage(_INTL("You can't the {1} yet.", item_name))
      return false
    end
    if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
      item_name = GameData::Item.get(Item_Surf[:internal_name]).name
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      pbCancelVehicles
      surfbgm = GameData::Metadata.get.surf_BGM
      pbCueBGM(surfbgm, 0.5) if surfbgm
      pbStartSurfing
      return true
    end
    return false
  end

  ItemHandlers::UseFromBag.add(Item_Surf[:internal_name], proc do |item|
    if $PokemonGlobal.surfing
      pbMessage(_INTL("You're already surfing."))
      next 0
    end
    if !$game_player.can_ride_vehicle_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    if GameData::MapMetadata.exists?($game_map.map_id) &&
      GameData::MapMetadata.get($game_map.map_id).always_bicycle
      pbMessage(_INTL("Let's enjoy cycling!"))
      next 0
    end
    if !$game_player.pbFacingTerrainTag.can_surf_freely ||
      !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
      item_name = GameData::Item.get(Item_Surf[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} here!", item_name))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Surf[:internal_name], proc do |item|
    if $PokemonGlobal.surfing
      pbMessage(_INTL("You're already surfing."))
      next 0
    end
    if !$game_player.can_ride_vehicle_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    if GameData::MapMetadata.exists?($game_map.map_id) &&
      GameData::MapMetadata.get($game_map.map_id).always_bicycle
      pbMessage(_INTL("Let's enjoy cycling!"))
      next 0
      endif !$game_player.pbFacingTerrainTag.can_surf_freely ||
      !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
      item_name = GameData::Item.get(Item_Surf[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} here!", item_name))
      next 0
    end
    pbSurf
    next 1
  end)
end

#===============================================================================
# Dive
#===============================================================================
# This Game $stats.dive handle by defualt essentials
# This Game $stats.dive_ascend by this plugin [New from this Plugin]
if Item_Dive[:active]

  HiddenMoveHandlers::CanUseMove.delete(:DIVE)
  HiddenMoveHandlers::UseMove.delete(:DIVE)

  def pbDive
    return false if $game_player.pbFacingEvent
    map_metadata = $game_map.metadata
    return false if !map_metadata || !map_metadata.dive_map_id
    if !pbCanUseItem(Item_Dive)
      pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
      return false
    end
    if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
      item_name = GameData::Item.get(Item_Dive[:internal_name]).name
      pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
      pbHiddenMoveAnimation(nil)
      pbFadeOutIn {
        $game_temp.player_new_map_id    = map_metadata.dive_map_id
        $game_temp.player_new_x         = $game_player.x
        $game_temp.player_new_y         = $game_player.y
        $game_temp.player_new_direction = $game_player.direction
        $PokemonGlobal.surfing = false
        $PokemonGlobal.diving  = true
        $stats.dive_count += 1
        pbUpdateVehicle
        $scene.transfer_player(false)
        $game_map.autoplay
        $game_map.refresh
      }
      return true
    end
    return false
  end

  def pbSurfacing
    return if !$PokemonGlobal.diving
    return false if $game_player.pbFacingEvent
    surface_map_id = nil
    GameData::MapMetadata.each do |map_data|
      next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
      surface_map_id = map_data.id
      break
    end
    return if !surface_map_id
    if !pbCanUseItem(Item_Dive)
      pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
      return false
    end
    if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
      item_name = GameData::Item.get(Item_Dive[:internal_name]).name
      pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
      pbHiddenMoveAnimation(nil)
      pbFadeOutIn {
        $game_temp.player_new_map_id    = surface_map_id
        $game_temp.player_new_x         = $game_player.x
        $game_temp.player_new_y         = $game_player.y
        $game_temp.player_new_direction = $game_player.direction
        $PokemonGlobal.surfing = true
        $PokemonGlobal.diving  = false
        $stats.dive_ascend_count += 1
        pbUpdateVehicle
        $scene.transfer_player(false)
        surfbgm = GameData::Metadata.get.surf_BGM
        (surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
        $game_map.refresh
      }
      return true
    end
    return false
  end

  # @deprecated This method is slated to be removed in v21.
  def pbTransferUnderwater(mapid, x, y, direction = $game_player.direction)
    Deprecation.warn_method("pbTransferUnderwater", "v21", '"Transfer Player" event command')
    pbFadeOutIn {
      $game_temp.player_new_map_id    = mapid
      $game_temp.player_new_x         = x
      $game_temp.player_new_y         = y
      $game_temp.player_new_direction = direction
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    }
  end

  EventHandlers.add(:on_player_interact, :diving,
    proc {
      aiDive
    }
  )

  def aiDive
    if $PokemonGlobal.diving
      surface_map_id = nil
      GameData::MapMetadata.each do |map_data|
        next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
        surface_map_id = map_data.id
        break
      end
      if surface_map_id &&
        $map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
        pbSurfacing
      end
    elsif $game_player.terrain_tag.can_dive
      pbDive
    end
  end

  ItemHandlers::UseFromBag.add(Item_Dive[:internal_name], proc do |item|
    if $PokemonGlobal.diving
      surface_map_id = nil
      GameData::MapMetadata.each do |map_data|
        next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
        surface_map_id = map_data.id
        break
      end
      if !surface_map_id ||
        !$map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
    else
      if !$game_map.metadata&.dive_map_id
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
      if !$game_player.terrain_tag.can_dive
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Dive[:internal_name], proc do |item|
    if $PokemonGlobal.diving
      surface_map_id = nil
      GameData::MapMetadata.each do |map_data|
        next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
        surface_map_id = map_data.id
        break
      end
      if !surface_map_id ||
        !$map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
    else
      if !$game_map.metadata&.dive_map_id
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
      if !$game_player.terrain_tag.can_dive
        pbMessage(_INTL("You can't use that here."))
        next 0
      end
    end
    aiDive
    next 1
  end)
end

#===============================================================================
# Waterfall
#===============================================================================
# This Game $stats handle by defualt essentials

if Item_Waterfall[:active]

  HiddenMoveHandlers::CanUseMove.delete(:WATERFALL)
  HiddenMoveHandlers::UseMove.delete(:WATERFALL)

  def pbWaterfall
    if !pbCanUseItem(Item_Waterfall)
      pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
      return false
    end
    if pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
      if !pbHiddenMoveAnimation(nil)
        item_name = GameData::Item.get(Item_Waterfall[:internal_name]).name
        pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
        pbHiddenMoveAnimation(nil)
        pbAscendWaterfall
      end
      return true
    end
    return false
  end

  EventHandlers.add(:on_player_interact, :waterfall,
    proc {
      terrain = $game_player.pbFacingTerrainTag
      if terrain.waterfall && $PokemonGlobal.surfing
        pbWaterfall
      elsif terrain.waterfall_crest
        pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
      end
    }
  )

  ItemHandlers::UseFromBag.add(Item_Waterfall[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.waterfall && !$PokemonGlobal.surfing
      pbMessage(_INTL("You are not facing a waterfall."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Waterfall[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.waterfall && !$PokemonGlobal.surfing
      pbMessage(_INTL("You are not facing a waterfall."))
      next 0
    end
    pbAscendWaterfall
    next 1
  end)
end

#===============================================================================
# Whirlpool
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if Item_Whirlpool[:active]

  EventHandlers.add(:on_player_interact, :whirlpool,
    proc {
      if $game_player.pbFacingTerrainTag.whirlpool && $PokemonGlobal.surfing
        pbWhirlpool
      end
    }
  )

  def pbWhirlpool
    if !pbCanUseItem(Item_Whirlpool)
      pbMessage(_INTL("It's a huge swirl of water use an item to cross it"))
      return false
    end
    item_name = GameData::Item.get(Item_Whirlpool[:internal_name]).name
    if pbConfirmMessage(_INTL("It's a huge swirl of water.\nWould you like to use the {1}?", item_name))
      pbMessage(_INTL("{1} used the {2}!", $Trainer.name, item_name))
      terrain = $game_player.pbFacingTerrainTag
      return if !terrain.whirlpool
      $stats.whirlpool_cross_count += 1
      oldthrough   = $game_player.through
      $game_player.through = true
      $game_player.move_speed_real = 6.4
      case  $game_player.direction
      when 2, 8
        $game_player.always_on_top = true
      end
      pbWait(4)
      loop do
        case  $game_player.direction
        when 2 #[Player Looking Down]
          if $game_player.pbFacingTerrainTag.whirlpool
            $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_down_id],$game_player.x,$game_player.y,true,1)
          end
          $game_player.move_forward
        when 4 #[Player Looking Left]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_left_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        when 6 #[Player Looking Right]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_right_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        when 8 #[Player Lookin Up]
          $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG[:move_up_id],$game_player.x,$game_player.y,true,1)
          $game_player.move_forward
        end
        terrain = $game_player.pbTerrainTag
        break if !terrain.whirlpool
        while $game_player.moving?
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
      pbWait(36)
      $game_player.through    = oldthrough
      $game_player.move_speed_real = 25.6
      $game_player.always_on_top = false
      $game_player.check_event_trigger_here([1, 2])
    end
  end

  ItemHandlers::UseFromBag.add(Item_Whirlpool[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.whirlpool && !$PokemonGlobal.surfing
      item_name = GameData::Item.get(Item_Whirlpool[:internal_name]).name
      pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Whirlpool[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.whirlpool && !$PokemonGlobal.surfing
      item_name = GameData::Item.get(Item_Whirlpool[:internal_name]).name
      pbMessage(_INTL("There is no sensible reason why you would be trying to use the {1} now!", item_name))
      next 0
    end
    pbWhirlpool
    next 1
  end)

end

#===============================================================================
# Fly
#===============================================================================
# This Game $stats handle by this plugin [Overwrites the defualt essentials]

if Item_Fly[:active]

  HiddenMoveHandlers::CanUseMove.delete(:FLY)
  HiddenMoveHandlers::UseMove.delete(:FLY)

  def aiFly
    if !pbCanUseItem(Item_Fly)
      item_name = GameData::Item.get(Item_Fly[:internal_name]).name
      pbMessage(_INTL("You can't the {1} yet.", item_name))
      return false
    end
    ret = nil
    pbFadeOutIn(99999) {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartFlyScreen
    }
    if ret
      $game_temp.fly_destination = ret
      $game_temp.in_menu = false
    end
    return false if $game_temp.fly_destination.nil?
    if !pbHiddenMoveAnimation(nil)
      item_name = GameData::Item.get(Item_Fly[:internal_name]).name
      pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
    end
    $stats.fly_count += 1
    pbFadeOutIn {
      pbSEPlay("Fly")
      $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
      $game_temp.player_new_x         = $game_temp.fly_destination[1]
      $game_temp.player_new_y         = $game_temp.fly_destination[2]
      $game_temp.player_new_direction = 2
      $game_temp.fly_destination = nil
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
      pbWait(Graphics.frame_rate / 4)
    }
    pbEraseEscapePoint
  end

  ItemHandlers::UseFromBag.add(Item_Fly[:internal_name], proc do |item|
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    if !$game_map.metadata&.outdoor_map
      item_name = GameData::Item.get(Item_Fly[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} when you are inside.", item_name))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Fly[:internal_name], proc do |item|
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    if !$game_map.metadata&.outdoor_map
      item_name = GameData::Item.get(Item_Fly[:internal_name]).name
      pbMessage(_INTL("You can't use the {1} when you are inside.", item_name))
      next 0
    end
    aiFly
    next 1
  end)
end

#===============================================================================
# Dig
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]
if Item_Dig[:active]

  HiddenMoveHandlers::CanUseMove.delete(:DIG)
  HiddenMoveHandlers::UseMove.delete(:DIG)

  def aiDig
    if !pbCanUseItem(Item_Dig)
      item_name = GameData::Item.get(Item_Dig[:internal_name]).name
      pbMessage(_INTL("You can't the {1} yet.", item_name))
      return false
    end
    mapname = pbGetMapNameFromId(escape[0])
    if pbConfirmMessage(_INTL("Want to escape from here and return to {1}?", mapname))
      if escape
        if !pbHiddenMoveAnimation(nil)
          item_name = GameData::Item.get(Item_Dig[:internal_name]).name
          pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
          $stats.dig_count += 1
          pbFadeOutIn {
            $game_temp.player_new_map_id    = escape[0]
            $game_temp.player_new_x         = escape[1]
            $game_temp.player_new_y         = escape[2]
            $game_temp.player_new_direction = escape[3]
            $scene.transfer_player
            $game_map.autoplay
            $game_map.refresh
          }
          pbEraseEscapePoint
        end
      end
    end
  end

  ItemHandlers::UseFromBag.add(Item_Dig[:internal_name], proc do |item|
    escape = ($PokemonGlobal.escapePoint rescue nil)
    if !escape || escape == []
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Dig[:internal_name], proc do |item|
    escape = ($PokemonGlobal.escapePoint rescue nil)
    if !escape || escape == []
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    next 1
  end)
end


#===============================================================================
# Teleport
#===============================================================================
# This Game $stats handle by this plugin [New from this Plugin]

if Item_Teleport[:active]

  HiddenMoveHandlers::CanUseMove.delete(:TELEPORT)
  HiddenMoveHandlers::UseMove.delete(:TELEPORT)

  def aiTeleport
    if !pbCanUseItem(Item_Teleport)
      item_name = GameData::Item.get(Item_Teleport[:internal_name]).name
      pbMessage(_INTL("You can't the {1} yet.", item_name))
      return false
    end
    healing = $PokemonGlobal.healingSpot
    healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
    healing = GameData::Metadata.get.home if !healing   # Home
    mapname = pbGetMapNameFromId(healing[0])
    if pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?", mapname))
      if !pbHiddenMoveAnimation(nil)
        item_name = GameData::Item.get(Item_Teleport[:internal_name]).name
        pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
        $stats.teleport_count += 1
        pbFadeOutIn {
          $game_temp.player_new_map_id    = healing[0]
          $game_temp.player_new_x         = healing[1]
          $game_temp.player_new_y         = healing[2]
          $game_temp.player_new_direction = 2
          $scene.transfer_player
          $game_map.autoplay
          $game_map.refresh
        }
        pbEraseEscapePoint
      end
    end
  end

  ItemHandlers::UseFromBag.add(Item_Teleport[:internal_name], proc do |item|
    if !$game_map.metadata&.outdoor_map
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    healing = $PokemonGlobal.healingSpot
    healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
    healing = GameData::Metadata.get.home if !healing   # Home
    if !healing
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_Teleport[:internal_name], proc do |item|
    if !$game_map.metadata&.outdoor_map
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    healing = $PokemonGlobal.healingSpot
    healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
    healing = GameData::Metadata.get.home if !healing   # Home
    if !healing
      pbMessage(_INTL("You can't use that here."))
      next 0
    end
    if !$game_player.can_map_transfer_with_follower?
      pbMessage(_INTL("It can't be used when you have someone with you."))
      next 0
    end
    aiTeleport
    next 1
  end)
end

#===============================================================================
# Rock Climb
#===============================================================================
if Item_RockClimb[:active]

  def pbAscendRock
    return if $game_player.direction != 8   # Can't ascend if not facing up
    terrain = $game_player.pbFacingTerrainTag
    return if !terrain.can_climb
    $stats.rockclimb_ascend_count += 1
    oldthrough   = $game_player.through
    oldmovespeed = $game_player.move_speed
    $game_player.through    = true
    $game_player.move_speed = 4
    pbJumpToward
    pbCancelVehicles
    $PokemonEncounters.reset_step_count
    $PokemonGlobal.rockclimbing = true
    pbUpdateVehicle
    loop do
      $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:move_up_id],$game_player.x,$game_player.y,true,1)
      $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:debris_id],$game_player.x,$game_player.y,true,1)
      $game_player.move_up
      terrain = $game_player.pbTerrainTag
      break if !terrain.can_climb
      while $game_player.moving?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    $PokemonGlobal.rockclimbing = false
    pbJumpToward(0)
    pbWait(16)
    $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:dust_id],$game_player.x,$game_player.y,true,1)
    pbWait(4)
    $game_player.increase_steps
    $game_player.check_event_trigger_here([1, 2])
    $game_player.through    = oldthrough
    $game_player.move_speed = oldmovespeed
  end

  def pbDescendRock
    return if $game_player.direction != 2   # Can't descend if not facing down
    terrain = $game_player.pbFacingTerrainTag
    return if !terrain.can_climb
    $stats.rockclimb_descend_count += 1
    oldthrough   = $game_player.through
    oldmovespeed = $game_player.move_speed
    old_always_on_top = $game_player.always_on_top
    $game_player.through = true
    $game_player.move_speed = 4
    $game_player.always_on_top = true
    pbJumpToward
    pbCancelVehicles
    $PokemonEncounters.reset_step_count
    $PokemonGlobal.rockclimbing = true
    pbUpdateVehicle
    loop do
      if $game_player.pbFacingTerrainTag.rockclimb
        $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:move_down_id],$game_player.x,$game_player.y,true,1)
        $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:debris_id],$game_player.x,$game_player.y,true,1)
      end
      $game_player.move_down
      terrain = $game_player.pbTerrainTag
      break if !terrain.can_climb
      while $game_player.moving?
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    $PokemonGlobal.rockclimbing = false
    pbJumpToward(0)
    pbWait(16)
    $scene.spriteset.addUserAnimation(AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG[:dust_id],$game_player.x,$game_player.y,true,1)
    pbWait(8)
    $game_player.through = oldthrough
    $game_player.move_speed = oldmovespeed
    $game_player.always_on_top = old_always_on_top
    $game_player.increase_steps
    $game_player.check_event_trigger_here([1, 2])
  end

  def aiRockClimb
    if !pbCanUseItem(Item_RockClimb)
      pbMessage(_INTL("The wall is very rocky. Could be climbed with the right equipment"))
      return false
    end
    item_name = GameData::Item.get(Item_RockClimb[:internal_name]).name
    if pbConfirmMessage(_INTL("The wall is very rocky.\nWould you like to use the {1}?", item_name))
      pbMessage(_INTL("{1} used {2}!", $Trainer.name, item_name))
      pbHiddenMoveAnimation(nil)
      case $game_player.direction
      when 8 # Looking up
        pbAscendRock
      when 2 # Looking down
        pbDescendRock
      end
      return true
    end
    return false
  end


  EventHandlers.add(:on_player_interact, :rockclimb,
    proc {
      terrain = $game_player.pbFacingTerrainTag
      if terrain.rockclimb
        aiRockClimb
      end
    }
  )

  EventHandlers.add(:on_player_interact, :rockclimb_crest,
    proc {
      terrain = $game_player.pbFacingTerrainTag
      if terrain.rockclimb_crest
        aiRockClimb
      end
    }
  )

  ItemHandlers::UseFromBag.add(Item_RockClimb[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.can_climb
      pbMessage(_INTL("You are not facing a rock wall."))
      next 0
    end
    next 2
  end)

  ItemHandlers::UseInField.add(Item_RockClimb[:internal_name], proc do |item|
    if !$game_player.pbFacingTerrainTag.can_climb
      pbMessage(_INTL("You are not facing a rock wall."))
      next 0
    end
    aiRockClimb
    next 1
  end)
end
