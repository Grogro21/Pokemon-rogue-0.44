Challenge=62

class AbilityRestriction
  def initialize(*abilitylist) 
    @abilitylist = abilitylist.clone
  end

  def isSpecies?(ability,abilitylist)
    return abilitylist.include?(ability)
  end

  def isValid?(pkmn)
    return !isSpecies?(pkmn.ability_id, @abilitylist)
  end
end	
#===============================================================================
#
#===============================================================================

class BannedFormRestriction
  def initialize(*formlist)
    @formlist = formlist.clone
  end

  def isSpecies?(form, formlist)
    return formlist.include?(form)
  end

  def isValid?(pkmn)
    return !isSpecies?([pkmn.species,pkmn.form], @formlist)
  end
end
#===============================================================================
#
#===============================================================================
class MoveRestriction
  def initialize(*movelist)
    @movelist = movelist.clone
  end

  def isSpecies?(move, movelist)
    return movelist.include?(move)
  end

  def isValid?(pkmn)
	check=true
    for i in 0...pkmn.moves.length
		if isSpecies?(pkmn.moves[i].id, @movelist)
			check=false
		end
	end
	return check
  end
end
	
#===============================================================================
#
#===============================================================================
class Alphabetmon
  def eggMoves(pkmn)
    babyspecies=pkmn.species
    babyspecies = GameData::Species.get(babyspecies).get_baby_species(false, nil, nil)
    eggmoves=GameData::Species.get_species_form(babyspecies, pkmn.form).egg_moves
    return eggmoves
  end
  
  def getMoveList
    return species_data.moves
  end
  
  def tutorMoves(pkmn)
    return pkmn.species_data.tutor_moves
  end
  
  def compare_names(move,pkmn)
    pk= pkmn.name[0]
	m= move.real_name[0]
	return (pk==m)	
  end
  
  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level
      moves.push(m[1]) if !moves.include?(m[1])
    end
    tmoves = []
    if pkmn.first_moves
      for i in pkmn.first_moves
        tmoves.push(i) if !moves.include?(i)
      end
    end
    moves = tmoves + moves  
	eggmoves=eggMoves(pkmn)
	for i in eggmoves
      moves.push(i) if !moves.include?(i)
    end
    tutormoves= tutorMoves(pkmn)
	for i in tutormoves
      moves.push(i) if !moves.include?(i)
	end
	smoves=[]
	GameData::Move.each { |i| smoves.push(i.id) if compare_names(i,pkmn) }	
	for i in smoves
		moves.push(i) if !moves.include?(i)  
	end
    moves.sort! { |a, b| a.downcase <=> b.downcase } #sort moves alphabetically
    return moves | []   # remove duplicates
  end
  def compare_names(move,pkmn)
    pk= pkmn.name[0]
	m= move.name[0]
	return (pk==m)	
  end
  
  def isValid?(pkmn)
  	r = pbGetRelearnableMoves(pkmn)
	for i in 0...pkmn.moves.length
      if !r.include?(pkmn.moves[i].id)
	    return false
	  end
	end
	return true
  end
end 
#===============================================================================
#
#===============================================================================  
class Stabmon
  def eggMoves(pkmn)
    babyspecies=pkmn.species
    babyspecies = GameData::Species.get(babyspecies).get_baby_species(false, nil, nil)
    eggmoves=GameData::Species.get_species_form(babyspecies, pkmn.form).egg_moves
    return eggmoves
  end
  
  def getMoveList
    return species_data.moves
  end
  
  def tutorMoves(pkmn)
    return pkmn.species_data.tutor_moves
  end
  
  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level
      moves.push(m[1]) if !moves.include?(m[1])
    end
    tmoves = []
    if pkmn.first_moves
      for i in pkmn.first_moves
        tmoves.push(i) if !moves.include?(i)
      end
    end
    moves = tmoves + moves  
	
    eggmoves=eggMoves(pkmn)
	for i in eggmoves
      moves.push(i) if !moves.include?(i)
    end
    tutormoves= tutorMoves(pkmn)
	for i in tutormoves
      moves.push(i) if !moves.include?(i)
    end
	smoves=[]
	GameData::Move.each { |i| smoves.push(i.id) if (i.type==pkmn.types[0] || i.type==pkmn.types[1]) }	
	for i in smoves
	  moves.push(i) if !moves.include?(i)  
	end	
    moves.sort! { |a, b| a.downcase <=> b.downcase } #sort moves alphabetically
    return moves | []   # remove duplicates
  end   

  
  def isValid?(pkmn)
  	r = pbGetRelearnableMoves(pkmn)
	for i in 0...pkmn.moves.length
      if !r.include?(pkmn.moves[i].id)
	    return false
	  end
	end
	return true
  end 
end
#===============================================================================
#
#===============================================================================  
#===============================================================================
#
#===============================================================================
=begin
class Battle::Battler
  def pbFaint(showMessage = true)
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!", pbThis)) if showMessage
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    @battle.scene.pbFaintBattler(self)
    @battle.pbSetDefeated(self) if opposes?
    pbInitEffects(false)
    # Reset status
    self.status      = :NONE
    self.statusCount = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = @battle.allOtherSideBattlers(@index).any? { |b| b.level >= self.level + 30 }
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
	if pbOwnedByPlayer? && $game_switches[Challenge] #challenge mode
		$game_variables[Challenge].push([@pokemon.species,@pokemon.form]) if !$game_variables[Challenge].include?(@pokemon.species)
	end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle, @pokemon, @battle.usedInBattle[idxOwnSide][@index / 2])
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    if $game_temp.party_direct_damage_taken &&
       $game_temp.party_direct_damage_taken[@pokemonIndex] &&
       pbOwnedByPlayer?
      $game_temp.party_direct_damage_taken[@pokemonIndex] = 0
    end
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end
end
=end
class DeadPkmn
  def initialize
    @deadlist = $game_variables[Challenge]
  end

  def isSpecies?(form,deadlist)
    return deadlist.include?(form)
  end

  def isValid?(pkmn)
    return !isSpecies?([pkmn.species,pkmn.form], @deadlist)
  end
end	

#===============================================================================
#
#===============================================================================
class Legalmon
  def eggMoves(pkmn)
    babyspecies=pkmn.species
    babyspecies = GameData::Species.get(babyspecies).get_baby_species(false, nil, nil)
    eggmoves=GameData::Species.get_species_form(babyspecies, pkmn.form).egg_moves
    return eggmoves
  end
  
  def getMoveList
    return species_data.moves
  end
  
  def tutorMoves(pkmn)
    return pkmn.species_data.tutor_moves
  end
  
  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level
      moves.push(m[1]) if !moves.include?(m[1])
    end
    tmoves = []
    if pkmn.first_moves
      for i in pkmn.first_moves
        tmoves.push(i) if !moves.include?(i)
      end
    end
    moves = tmoves + moves  
	
    eggmoves=eggMoves(pkmn)
	for i in eggmoves
      moves.push(i) if !moves.include?(i)
    end
    tutormoves= tutorMoves(pkmn)
	for i in tutormoves
      moves.push(i) if !moves.include?(i)
    end
    moves.sort! { |a, b| a.downcase <=> b.downcase } #sort moves alphabetically
    return moves | []   # remove duplicates
  end   
  
  def abilist(pkmn)
	list=pkmn.getAbilityList
	l=[]
	for abil in list
		l.push(abil[0])
	end
	return l
  end
		
  
  
  def isValid?(pkmn)
  	r = pbGetRelearnableMoves(pkmn)
	for i in 0...pkmn.moves.length
      if !r.include?(pkmn.moves[i].id)
	    return false
	  end
	  if !abilist(pkmn).include?(pkmn.ability.id)
		return false
	  end
	end
	return true
  end 
end
#===============================================================================
#
#===============================================================================