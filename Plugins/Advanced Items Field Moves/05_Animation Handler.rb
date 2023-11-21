#===============================================================================
#                     Adds Rock Climbing to $PokemonGlobal
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :rockclimbing

  alias advanceditemsfieldmoves_init initialize
  def initialize
    advanceditemsfieldmoves_init
    @rockclimbing = false
  end
end

class Game_Character
  attr_accessor :always_on_top
end

def onoff?
  if $PokemonGlobal&.rockclimbing
    pbMessage(_INTL("surfing is ON!"))
    return false
  else
    pbMessage(_INTL("surfing is OFF!"))
  end
end

#===============================================================================
#  Can Run? Rockclimb added to it
#===============================================================================
if PluginManager.findDirectory("v20.1 Hotfixes")
class Game_Player < Game_Character
  def can_run?
    return @move_speed > 3 if @move_route_forcing
    return false if $game_temp.in_menu || $game_temp.in_battle ||
    $game_temp.message_window_showing || pbMapInterpreterRunning?
    return false if !$player.has_running_shoes && !$PokemonGlobal.diving &&
    !$PokemonGlobal.surfing && !$PokemonGlobal.bicycle || $PokemonGlobal.rockclimbing
    return false if jumping?
    return false if pbTerrainTag.must_walk
    return ($PokemonSystem.runstyle == 1) ^ Input.press?(Input::BACK)
  end

  def set_movement_type(type)
    meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
    new_charset = nil
    case type
    when :fishing
      new_charset = pbGetPlayerCharset(meta.fish_charset)
    when :surf_fishing
      new_charset = pbGetPlayerCharset(meta.surf_fish_charset)
    when :diving, :diving_fast, :diving_jumping, :diving_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.dive_charset)
    when :surfing, :surfing_fast, :surfing_jumping, :surfing_stopped
      if !@move_route_forcing
        self.move_speed = (type == :surfing_jumping) ? 3 : 4
      end
      new_charset = pbGetPlayerCharset(meta.surf_charset)
    when :rockclimbing, :rockclimbing_fast, :rockclimbing_jumping, :rockclimbing_stopped
      if !@move_route_forcing
        self.move_speed = 5
      end
      new_charset = pbGetPlayerCharset(meta.dive_charset)
    when :cycling, :cycling_fast, :cycling_jumping, :cycling_stopped
      if !@move_route_forcing
        self.move_speed = (type == :cycling_jumping) ? 3 : 5
      end
      new_charset = pbGetPlayerCharset(meta.cycle_charset)
    when :running
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.run_charset)
    when :ice_sliding
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    else   # :walking, :jumping, :walking_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    end
    @character_name = new_charset if new_charset
  end

  def update_move
    if !@moved_last_frame || @stopped_last_frame   # Started a new step
      if pbTerrainTag.ice
        set_movement_type(:ice_sliding)
      else#if !@move_route_forcing
        faster = can_run?
        if $PokemonGlobal&.diving
          set_movement_type((faster) ? :diving_fast : :diving)
        elsif $PokemonGlobal&.surfing
          set_movement_type((faster) ? :surfing_fast : :surfing)
        elsif $PokemonGlobal&.rockclimbing
          set_movement_type((faster) ? :rockclimbing_fast : :rockclimbing)
        elsif $PokemonGlobal&.bicycle
          set_movement_type((faster) ? :cycling_fast : :cycling)
        else
          set_movement_type((faster) ? :running : :walking)
        end
      end
      if jumping?
        if $PokemonGlobal&.diving
          set_movement_type(:diving_jumping)
        elsif $PokemonGlobal&.surfing
          set_movement_type(:surfing_jumping)
        elsif $PokemonGlobal&.rockclimbing
          set_movement_type(:rockclimbing_jumping)
        elsif $PokemonGlobal&.bicycle
          set_movement_type(:cycling_jumping)
        else
          set_movement_type(:jumping)   # Walking speed/charset while jumping
        end
      end
    end
    super
  end

  def update_stop
    if @stopped_last_frame
      if $PokemonGlobal&.diving
        set_movement_type(:diving_stopped)
      elsif $PokemonGlobal&.surfing
        set_movement_type(:surfing_stopped)
      elsif $PokemonGlobal&.rockclimbing
        set_movement_type(:rockclimbing_stopped)
      elsif $PokemonGlobal&.bicycle
        set_movement_type(:cycling_stopped)
      else
        set_movement_type(:walking_stopped)
      end
    end
    super
  end

  def pbUpdateVehicle
    if $PokemonGlobal&.diving
      $game_player.set_movement_type(:diving)
    elsif $PokemonGlobal&.surfing
      $game_player.set_movement_type(:surfing)
    elsif $PokemonGlobal&.rockclimbing
      $game_player.set_movement_type(:rockclimbing)
    elsif $PokemonGlobal&.bicycle
      $game_player.set_movement_type(:cycling)
    else
      $game_player.set_movement_type(:walking)
    end
  end
end
end
