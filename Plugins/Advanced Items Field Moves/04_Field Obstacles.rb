#===============================================================================
# Smash Event
#===============================================================================
#Overwrites Essentials Stuff
def pbSmashEvent(event)
  return if !event
  if event.name[/cuttree/i]
    pbSEPlay("Cut", 80)
  elsif event.name[/smashrock/i]
    pbSEPlay("Rock Smash", 80)
  elsif event.name[/smashice/i]
    pbSEPlay("Ice Smash", 80)
  end
  pbMoveRoute(event,[
    PBMoveRoute::Wait, 2,
    PBMoveRoute::TurnLeft,
    PBMoveRoute::Wait, 2,
    PBMoveRoute::TurnRight,
    PBMoveRoute::Wait, 2,
    PBMoveRoute::TurnUp,
    PBMoveRoute::Wait, 2])
    pbWait(Graphics.frame_rate * 5 / 10)  # Fixed so Strength Event can be push over Smash Event
    event.erase
    $PokemonMap&.addErasedEvent(event.id)
end

#===============================================================================
# Camouflage // Trainer Skip
#===============================================================================

class Game_Event < Game_Character
  def pbCheckEventTriggerAfterTurning
    return if $game_system.map_interpreter.running? || @starting
    return if !$game_player.camouflage==true
    return if @trigger != 2 # Event touch
    return if !@event.name[/(?:sight|trainer)\((\d+)\)/i]
    distance = $~[1].to_i
    return if !pbEventCanReachPlayer?(self, $game_player, distance)
    return if jumping? || over_trigger?
    start
  end
end

class Game_Player < Game_Character
  def pbTriggeredTrainerEvents(triggers, checkIfRunning = true, trainer_only = false)
    result = []
    # If event is running
    return result if checkIfRunning && $game_system.map_interpreter.running?
    # All event loops
    $game_map.events.each_value do |event|
      next if $game_player.camouflage==true
      next if !triggers.include?(event.trigger)
      next if !event.name[/trainer\((\d+)\)/i] && (trainer_only || !event.name[/sight\((\d+)\)/i])
      distance = $~[1].to_i
      next if !pbEventCanReachPlayer?(event, self, distance)
      next if event.jumping? || event.over_trigger?
      result.push(event)
    end
    return result
  end

  def check_event_trigger_touch(dir)
    result = false
    return result if $game_system.map_interpreter.running?
    # All event loops
    x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
    y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
    $game_map.events.each_value do |event|
      next if ![1, 2].include?(event.trigger) # Player touch, event touch
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(@x + x_offset, @y + y_offset)
      if event.name[/(?:sight|trainer)\((\d+)\)/i] && !$game_player.camouflage==true
        distance = $~[1].to_i
        next if !pbEventCanReachPlayer?(event, self, distance)
      elsif event.name[/counter\((\d+)\)/i] && !$game_player.camouflage==true
        distance = $~[1].to_i
        next if !pbEventFacesPlayer?(event, self, distance)
      end
      # If starting determinant is front event (other than jumping)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true
    end
    return result
  end
end
