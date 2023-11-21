# Before using this script, make sure to start a new save file when testing.
# Since it adds new stored data, the script will probably throw errors when used
# with saves where the script wasn't present before. In addition, if you decide
# to release your game in segments, it is important to have this script
# installed in the very first version itself, so as not to cause any problems to
# the player.
# 
#-------------------------------------------------------------------------------
# SCRIPT USAGE
#-------------------------------------------------------------------------------
# This script offers two types of permadeath modes: SOFT and NUZLOCKE. In SOFT
# mode, any Pokemon that faint are sent to the Pokemon Storage after the battle,
# while in NUZLOCKE mode, they are lost forever (except for their held items).
# To switch between permadeath modes, call "pbSetPermadeath(mode)" at the start
# of your game (it is set to NORMAL by default at the beginning), replacing
# "mode" with one of three modes: :NORMAL, :SOFT, or :NUZLOCKE. For example,
# to enable the standard permadeath mode, use:
# 
# pbSetPermadeath(:NUZLOCKE)
# 
# and to disable it, use:
# 
# pbSetPermadeath(:NORMAL)
# 
# These can be called at anytime throughout your game, so for example, you can
# change modes for specific event battles. To find out if the current permadeath
# mode is either SOFT or NUZLOCKE use the function "pbPermadeathActive?". To
# find out if a specific mode is enabled, use the function
# "pbPermadeathModeIs?(mode)", replacing "mode" with what you're checking for.
# 
# The constant "DELETE_SAVE_IN_NUZLOCKE" can be set to "true" if you want the game
# to delete the player's save if the player is defeated in Nuzlocke mode.
# 
# I highly suggest reading the "Additional Notes" section below for more
# information on what the script does.
# 
#-------------------------------------------------------------------------------
# ADDITIONAL NOTES
#-------------------------------------------------------------------------------
# - On the outside, every time a Pokemon faints in SOFT or NUZLOCKE mode, it
#   LOOKS like it's been removed from the party immediately. However, what
#   happens internally is that all fainted Pokemon are hidden from the player's
#   view until the end of the round (so technically, they are still part of the
#   player's party). Then, at the end of each round, the player's party is
#   swept for fainted Pokemon, and they are removed and placed into another
#   list called "@faintedlist" (defined in PokeBattle_Battle below). Think of
#   this list as a sort of "purgatory", meaning that the Pokemon here still
#   exist as long as the battle is active, just not in the main party.
# - At the very end of the battle in SOFT mode, @faintedlist is swept and all
#   Pokemon in it are stored in the Pokemon Storage (unless the storage is full,
#   in which case they are simply lost like NUZLOCKE mode).
# - Any battles marked as "can lose", meaning that the game will continue
#   even if the player loses the battle, automatically have NORMAL mode on.
# - When a Pokemon dies in NUZLOCKE mode, it drops its held item into the
#   player's bag.
# - Pokemon can die from fainting in field due to poison if both NUZLOCKE and
#   POISON_IN_FIELD are enabled. For SOFT mode, the Pokemon get stored in the
#   Pokemon Storage.
# - When the player loses a battle in NUZLOCKE mode, meaning that the trainer's
#   entire party is dead, the game simply returns to the title screen with a
#   "GAME OVER" screen, going back to the player's last save.
# 
#-------------------------------------------------------------------------------
# I hope you enjoy this script!
# - NettoHikari
################################################################################
# Enables/disables save deletion if the player is defeated in Nuzlocke mode
DELETE_SAVE_IN_NUZLOCKE = false

class Battle::Scene
    def pbPartyScreen(idxBattler, canCancel = false, mode = 0)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene, modParty)
    msg = _INTL("Choose a Pokémon.")
    msg = _INTL("Send which Pokémon to Boxes?") if mode == 1
    switchScreen.pbStartScene(msg, @battle.pbNumPositions(0, 0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(msg)
      idxParty = switchScreen.pbChoosePokemon
      if idxParty < 0
        next if !canCancel
        break
      end
      # Choose a command for the selected Pokémon
      cmdSwitch  = -1
      cmdBoxes   = -1
      cmdSummary = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if mode == 0 && modParty[idxParty].able?
      commands[cmdBoxes   = commands.length] = _INTL("Send to Boxes") if mode == 1
      commands[cmdSummary = commands.length] = _INTL("Summary")
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?", modParty[idxParty].name), commands)
      if (cmdSwitch >= 0 && command == cmdSwitch) ||   # Switch In
         (cmdBoxes >= 0 && command == cmdBoxes)        # Send to Boxes
        idxPartyRet = -1
        partyPos.each_with_index do |pos, i|
          next if pos != idxParty + partyStart
          idxPartyRet = i
          break
        end
		if @battle
          idxPartyRet = @battle.permadeath_fixPartyIndex(idxPartyRet, idxParty)
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary >= 0 && command == cmdSummary   # Summary
        scene.pbSummary(idxParty, true)
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites, visibleSprites)
  end
  
    def pbItemMenu(idxBattler, _firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $bag.last_viewed_pocket
    oldChoices    = $bag.last_pocket_selections.clone
    if @bagLastPocket
      $bag.last_viewed_pocket     = @bagLastPocket
      $bag.last_pocket_selections = @bagChoices
    else
      $bag.reset_last_selections
    end
    # Start Bag screen
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($bag, true,
                           proc { |item|
                             useType = GameData::Item.get(item).battle_use
                             next useType && useType > 0
                           }, false)
    # Loop while in Bag screen
    wasTargeting = false
    loop do
      # Select an item
      item = itemScene.pbChooseItem
      break if !item
      # Choose a command for the selected item
      item = GameData::Item.get(item)
      itemName = item.name
      useType = item.battle_use
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
      commands[commands.length]          = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.", itemName), commands)
      next unless cmdUse >= 0 && command == cmdUse   # Use
      # Use types:
      # 0 = not usable in battle
      # 1 = use on Pokémon (lots of items, Blue Flute)
      # 2 = use on Pokémon's move (Ethers)
      # 3 = use on battler (X items, Persim Berry, Red/Yellow Flutes)
      # 4 = use on opposing battler (Poké Balls)
      # 5 = use no target (Poké Doll, Guard Spec., Poké Flute, Launcher items)
      case useType
      when 1, 2, 3   # Use on Pokémon/Pokémon's move/battler
        # Auto-choose the Pokémon/battler whose action is being decided if they
        # are the only available Pokémon/battler to use the item on
        case useType
        when 1   # Use on Pokémon
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3   # Use on battler
          if @battle.pbPlayerBattlerCount == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        # Fade out and hide Bag screen
        itemScene.pbFadeOutScene
        # Get player's party
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start party screen
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene, modParty)
        pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"), @battle.pbNumPositions(0, 0))
        idxParty = -1
        # Loop while in party screen
        loop do
          # Select a Pokémon
          pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          idxParty = pkmnScreen.pbChoosePokemon
          break if idxParty < 0
          idxPartyRet = -1
          partyPos.each_with_index do |pos, i|
            next if pos != idxParty + partyStart
            idxPartyRet = i
            break
          end
		  if @battle
			idxPartyRet = @battle.permadeath_fixPartyIndex(idxPartyRet, idxParty)
		  end
          next if idxPartyRet < 0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType == 2   # Use on Pokémon's move
            idxMove = pkmnScreen.pbChooseMove(pkmn, _INTL("Restore which move?"))
            next if idxMove < 0
          end
          break if yield item.id, useType, idxPartyRet, idxMove, pkmnScene
        end
        pkmnScene.pbEndScene
        break if idxParty >= 0
        # Cancelled choosing a Pokémon; show the Bag screen again
        itemScene.pbFadeInScene
      when 4   # Use on opposing battler (Poké Balls)
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler) == 1
          @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
          break if yield item.id, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          # Fade out and hide Bag screen
          itemScene.pbFadeOutScene
          # Fade in and show the battle screen, choosing a target
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), tempVisibleSprites)
          if idxTarget >= 0
            break if yield item.id, useType, idxTarget, -1, self
          end
          # Target invalid/cancelled choosing a target; show the Bag screen again
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          itemScene.pbFadeInScene
        end
      when 5   # Use with no target
        break if yield item.id, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $bag.last_viewed_pocket
    @bagChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = oldLastPocket
    $bag.last_pocket_selections = oldChoices
    # Close Bag screen
    itemScene.pbEndScene
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end
end
  
module PBPermadeath
  NORMAL   = 0 # Standard mode
  SOFT     = 1 # "Soft" nuzlocke (fainted Pokemon get transferred to Pokemon Storage)
  NUZLOCKE = 2 # "Hard" nuzlocke (fainted Pokemon get deleted at the end of battle)
end
 
class PokemonGlobalMetadata
  # Sets battles to NORMAL, SOFT, or NUZLOCKE
  attr_accessor :permadeathmode
  
  alias permadeath_initialize initialize
  def initialize
    permadeath_initialize
    @permadeathmode = PBPermadeath::NORMAL
  end
end
 
def pbSetPermadeath(mode)
  if mode.is_a?(Symbol)
    mode = getConst(PBPermadeath, mode)
  end
  return if mode < 0 || mode > 2
  $PokemonGlobal.permadeathmode = mode
end
 
def pbPermadeathModeIs?(mode)
  if mode.is_a?(Symbol)
    mode = getConst(PBPermadeath, mode)
  end
  return $PokemonGlobal.permadeathmode == mode
end
 
def pbPermadeathActive?
  return !pbPermadeathModeIs?(:NORMAL)
end
 
class Battle
  # Stores fainted Pokemon until end of battle (like a "purgatory")
  attr_accessor :faintedlist
  
  alias permadeath_pbStartBattle pbStartBattle
  def pbStartBattle
    @faintedlist = []
    permadeath_pbStartBattle
  end
  
  alias permadeath_pbReplace pbReplace
  def pbReplace(idxBattler,idxParty,batonPass=false)
    idxPartyOld = @battlers[idxBattler].pokemonIndex
    partyOrder = pbPartyOrder(idxBattler)
    permadeath_pbReplace(idxBattler,idxParty,batonPass)
    # Party order is already changed in original pbReplace, so undo party order change here
    if pbPermadeathBattle? && pbOwnedByPlayer?(idxBattler) &&
          idxPartyOld < $player.party.length && $player.party[idxPartyOld].fainted?
      partyOrder[idxParty],partyOrder[idxPartyOld] = partyOrder[idxPartyOld],partyOrder[idxParty]
    end
  end
  
  alias permadeath_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    # Cancel effect of Future Sight from dead Pokemon
    if pbPermadeathBattle?
      @positions.each_with_index do |pos,idxPos|
        next if !pos || !@battlers[idxPos] || @battlers[idxPos].fainted?
        next if pos.effects[PBEffects::FutureSightUserIndex] < 0
        next if @battlers[pos.effects[PBEffects::FutureSightUserIndex]].opposes?
        attacker = @party1[pos.effects[PBEffects::FutureSightUserPartyIndex]]
        if attacker.fainted?
          pos.effects[PBEffects::FutureSightCounter]        = 0
          pos.effects[PBEffects::FutureSightMove]           = 0
          pos.effects[PBEffects::FutureSightUserIndex]      = -1
          pos.effects[PBEffects::FutureSightUserPartyIndex] = -1
        end
      end
    end
    permadeath_pbEndOfRoundPhase
    pbRemoveFainted
  end
  
  alias permadeath_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    pbRemoveFainted
    permadeath_pbEndOfBattle
    if pbPermadeathBattle? && pbPermadeathModeIs?(:SOFT)
      for i in @faintedlist
        storedbox = $PokemonStorage.pbStoreCaught(i)
      end
    end
  end
  
  def pbPermadeathBattle?
    return pbPermadeathActive? && !@canLose
  end
  
  def pbRemoveFainted
    return if !pbPermadeathBattle?
    pokeindex = 0
    # Loop through Trainer's party
    loop do
      break if pokeindex >= $player.party.length
      if @party1[pokeindex] && @party1[pokeindex].fainted?
        break if $player.party.length == 1 && pbPermadeathModeIs?(:SOFT)
        # Begin by deleting Pokemon from party entirely
        @faintedlist.push($player.party[pokeindex])
        $player.party.delete_at(pokeindex)
        @initialItems[0].delete_at(pokeindex)
        @recycleItems[0].delete_at(pokeindex)
        @belch[0].delete_at(pokeindex)
        @battleBond[0].delete_at(pokeindex)
        @usedInBattle[0].delete_at(pokeindex)
        # Remove from double battle party as well
        if @party1 != $player.party
          @party1.delete_at(pokeindex)
        end
        # Fix party order
        @party1order.delete(pokeindex)
        for i in 0...$player.party.length
          if @party1order[i] > pokeindex
            @party1order[i] -= 1
          end
        end
        # Fix party starts
        for i in 1...@party1starts.length
          @party1starts[i] -= 1
        end
        # Fix party positions of current battlers
        eachSameSideBattler do |b|
          next if !b
          if b.pokemonIndex == pokeindex
            b.pokemonIndex = $player.party.length
          elsif b.pokemonIndex > pokeindex
            b.pokemonIndex -= 1
          end
        end
        # Fix participants for exp gains
        eachOtherSideBattler do |b|
          next if !b
          participants = b.participants
          for j in 0...participants.length
            next if !participants[j]
            participants[j] -= 1 if participants[j] > pokeindex
          end
        end
        pokeindex -= 1
      end
      pokeindex += 1
    end
    # End battle if player's entire party is gone
    @decision = 2 if $player.able_pokemon_count == 0
  end
  
  alias permadeath_pbPlayerDisplayParty pbPlayerDisplayParty
  def pbPlayerDisplayParty(idxBattler=0)
    if pbPermadeathBattle? && pbOwnedByPlayer?(idxBattler)
      partyOrders = pbPartyOrder(idxBattler)
      idxStart, idxEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
      ret = []
      eachInTeamFromBattlerIndex(idxBattler) { |pkmn,i|
        ret[partyOrders[i]-idxStart] = pkmn if partyOrders[i] && pkmn && !pkmn.fainted?
      }
      ret.compact!
      return ret
    else
      return permadeath_pbPlayerDisplayParty(idxBattler)
    end
  end
  
  def permadeath_fixPartyIndex(idxPartyRet, idxParty)
    if pbPermadeathBattle?
      modParty = pbPlayerDisplayParty
      idxPartyRet = @party1.index(modParty[idxParty])
    end
    return idxPartyRet
  end
end
 
class Battle::Battler
  alias permadeath_pbFaint pbFaint
  def pbFaint(showMessage=true)
    return true if @fainted || !fainted?
    ret = permadeath_pbFaint(showMessage)
	if !opposes?
      TrainerDialogue.display("fainted",@battle,@battle.scene)
    else
      TrainerDialogue.display("faintedOpp",@battle,@battle.scene)
    end
    if @battle.pbPermadeathBattle? && pbOwnedByPlayer?
      if showMessage && pbPermadeathModeIs?(:NUZLOCKE)
        if @pokemon.hasItem?
          # Informs player that fainted's held item was transferred to bag
          @battle.pbDisplayPaused(_INTL("{1} is dead! You picked up its {2}.",
              pbThis, @pokemon.item.real_name))
        else
          @battle.pbDisplayPaused(_INTL("{1} is dead!",pbThis))
        end
      end
      # Remove fainted from opposing participants arrays
      indices = @battle.pbGetOpposingIndicesInOrder(@index)
      for i in indices
        @battle.battlers[i].participants.delete(@pokemonIndex)
      end
      # Add held item to bag
      if @pokemon.hasItem? && pbPermadeathModeIs?(:NUZLOCKE)
        $bag.add(@pokemon.item)
      end
    end
    return ret
  end
end
