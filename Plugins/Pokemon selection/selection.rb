#===============================================================================
# * Pokémon Selection - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a pokémon selection system
# similar to Stadium/Battle Tower, where you can choose a certain number and
# order of pokémon.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main OR convert into a plugin. 
#
#== HOW TO USE =================================================================
#
# Use the script command PokemonSelection.choose. This return if something is
# choosen, so it can be use on conditional branchs. You can give as argument the
# min/max pokémon number to select or a PokemonSelection::Parameters class.
#
# To restore the previous party, use 'PokemonSelection.restore'. This do nothing
# if there's no party to restore. Ths method returns if the party was restored.
#
# If you call PokemonSelection.choose and player have an invalid party (like
# putting the minimum pokémon number to 3 when player has only 2), the game
# raises an error. You can use 'PokemonSelection.hasValidTeam?' to check if the
# party is valid. This method has the same arguments as 'choose'.
#
#== EXAMPLES ===================================================================
#
# Remember to use 'PokemonSelection.hasValidTeam?' before, to check if player 
# has a possible valid team, and 'PokemonSelection.restore' after, to restore 
# the previous party after the battle/event.
#
# - 3vs3 battle:
#
#  PokemonSelection.choose(3,3)
#
# - Only Grass, Water and Fire pokémon. Ho-oh and Kyogre are banned:
#
#  pr = PokemonSelection::Parameters.new
#  pr.baseChallenge = PokemonChallengeRules.new 
#  pr.baseChallenge.addPokemonRule(TypeRestriction.new([:GRASS,:FIRE,:WATER]))
#  pr.baseChallenge.addPokemonRule(BannedSpeciesRestriction.new(:HOOH,:KYOGRE))
#  PokemonSelection.choose(pr)
#
# - Only one Pikachu. Can also choose fainted pokémon and eggs:
#
#  pr = PokemonSelection::Parameters.new
#  pr.minPokemon = 1
#  pr.maxPokemon = 1
#  pr.acceptFainted = true
#  pr.baseChallenge = PokemonChallengeRules.new 
#  pr.baseChallenge.addPokemonRule(SpeciesRestriction.new(:PIKACHU))
#  PokemonSelection.choose(pr)
#
#== NOTES ======================================================================
#
# If you try to choose a new party before restore the old one, the game raises
# an error. This won't occurs if the previous selection is only an order change. 
#
# To perform only an order change, use
# 'PokemonSelection.choose($Trainer,party.size,$Trainer,party.size)'.
#
# If you take a look in PokemonChallengeRules applications in scripts you can
# customize some others choice conditions like have a certain level or ban
# certain pokémon.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Pokémon Selection")
  PluginManager.register({                                                 
    :name    => "Pokémon Selection",                                        
    :version => "1.2",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=290931",             
    :credits => "FL"
  })
end

module PokemonSelection
  class Parameters
    attr_accessor :minPokemon
    attr_accessor :maxPokemon
    attr_accessor :canCancel
    attr_accessor :acceptFainted # and eggs
    attr_accessor :baseChallenge

    def initialize
      @minPokemon = 1
      @maxPokemon = 6
      @canCancel = false
      @acceptFainted = false
    end
  
    def challenge
      ret = @baseChallenge ? @baseChallenge.clone : PokemonChallengeRules.new 
      ret.setLevelAdjustment(OpenLevelAdjustment.new(PBExperience::MAXLEVEL))
      ret.addPokemonRule(AblePokemonRestriction.new) if !@acceptFainted
      ret.ruleset.setNumberRange(@minPokemon,@maxPokemon)
      return ret
    end

    def self.factory(*args)
      return args[0] if args.size>0 && args[0] && args[0].is_a?(Parameters)
      ret = Parameters.new
      ret.minPokemon = args[0] if args.size>=1
      ret.maxPokemon = args[1] if args.size>=2
      return ret
    end
  end
  
  def self.hasValidTeam?(*args)
    params = Parameters.factory(*args)
    pbBattleChallenge.setSimple(params.challenge)
    ret=pbHasEligible?
    pbBattleChallenge.pbCancel
    return ret
  end  

  def self.choose(*args)
    if $PokemonGlobal.pokemonSelectionOriginalParty
      raise "Can't choose a new party until restore the old one!"
    end
    params = Parameters.factory(*args)
    if !hasValidTeam?(params)
      raise "Player hasn't a valid team!"
    end
    validPartyChosen=false
    pbBattleChallenge.setSimple(params.challenge)
    loop do
      pbEntryScreen
      validPartyChosen = pbBattleChallenge.getParty!=nil
      break if (params.canCancel || pbBattleChallenge.getParty)
      Kernel.pbMessage(_INTL("Choose a Pokémon."))
    end
    if validPartyChosen
      # If the party size is the same, it is only an order change 
      if($Trainer.party.size != pbBattleChallenge.getParty.size)
        $PokemonGlobal.pokemonSelectionOriginalParty=$Trainer.party
      end 
      $Trainer.party=pbBattleChallenge.getParty
    end
    pbBattleChallenge.pbCancel
    return validPartyChosen
  end

  def self.restore
    if !$PokemonGlobal.pokemonSelectionOriginalParty
      echoln("Trying to restore a party without party stored.")
      return false
    end
    newPokemon = newPokemonOnParty
    $Trainer.party=$PokemonGlobal.pokemonSelectionOriginalParty
    $PokemonGlobal.pokemonSelectionOriginalParty=nil
    addPokemonOnArray(newPokemon)
    return true
  end  

  def self.newPokemonOnParty
    return $Trainer.party.find_all{|partyPokemon|
      !$PokemonGlobal.pokemonSelectionOriginalParty.find{|originalPartyPokemon| 
        originalPartyPokemon.personalID == partyPokemon.personalID
      }
    }
  end

  def self.addPokemonOnArray(pokemonArray)
    for pokemon in pokemonArray
      if $Trainer.party.length==6
        $PokemonStorage.pbStoreCaught(pokemon)
      else
        $Trainer.party.push(pokemon)
      end
    end
  end
end

# This class uses a type array that only allows the pokémon as valid if it
# has one of these types when bannedTypes=false or the reverse 
# when bannedTypes=true
class TypeRestriction
  def initialize(types, bannedTypes=false)
    @types=types
    @bannedTypes = bannedTypes
  end

  def isValid?(pokemon)
    ret=false
    for singleType in @types
      if pokemon.hasType?(singleType)
        ret = true
        break
      end
    end
    ret = !ret if @bannedTypes
    return ret
  end
end

class BattleChallenge
  def setSimple(rules)
    @id = "pokemonSelectionRules"
    @numRounds = 1
    @rules = rules
    register(@id, false, 3, 0, 0)
  end
end

class BattleChallenge; def getParty; return @bc.party; end; end

class PokemonGlobalMetadata; attr_accessor :pokemonSelectionOriginalParty; end

class PokemonRuleSet # Redefined to fix a bug
  def hasValidTeam?(team)
    if !team || team.length<self.minTeamLength
      return false
    end
    teamNumber=[self.maxLength,team.length].min
    validPokemon=[]
    for pokemon in team
      if isPokemonValid?(pokemon)
        validPokemon.push(pokemon)
      end
    end
    #if validPokemon.length<teamNumber # original
    if validPokemon.length<self.minLength # fixed
      return false
    end
    if @teamRules.length>0
      pbEachCombination(team,self.minLength){|comb|
         if isValid?(comb)
           return true
         end
      }
      return false
    end
    return true
  end
end  

# To work with Essentials v17, v18 and v19+
if !defined?(PBExperience::MAXLEVEL)
  if defined?(MAXIMUM_LEVEL)
    module PBExperience
      MAXLEVEL = MAXIMUM_LEVEL
    end
  else
    module PBExperience
      MAXLEVEL = Settings::MAXIMUM_LEVEL
    end
  end
end