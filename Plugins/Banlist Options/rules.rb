def doubleOU(max)
  ret = PokemonSelection::Parameters.new
  ret.minPokemon = 2
  ret.maxPokemon = max
  ret.canCancel  = false
  ret.baseChallenge = PokemonChallengeRules.new 
  ret.baseChallenge.addTeamRule(SpeciesClause.new)
  ret.baseChallenge.addTeamRule(ItemClause.new)
  ret.baseChallenge.addBattleRule(SleepClause.new)
  ret.baseChallenge.addPokemonRule(AblePokemonRestriction.new)
  ret.baseChallenge.addPokemonRule(BannedSpeciesRestriction.new(:DIALGA,:ETERNATUS,:GIRATINA,:GROUDON,
      :HOOH,:JIRACHI,:KYOGRE,:LUGIA,:LUNALA,:MAGEARNA,
      :MARSHADOW,:MELMETAL,:MEWTWO,:PALKIA,:RAYQUAZA,:RESHIRAM,:SOLGALEO,
      :XERNEAS,:YVELTAL,:ZACIAN,:ZAMAZENTA,:ZEKROM,:ARCEUS))
      
  ret.baseChallenge.addPokemonRule(BannedFormRestriction.new([:CALYREX,1],[:CALYREX,2],
      [:KYUREM,1],[:NECROZMA,1],[:NECROZMA,2],
      [:SHAYMIN,1],[:URSHIFU,0]))
      
  ret.baseChallenge.addPokemonRule(AbilityRestriction.new(:POWERCONSTRUCT,:SHADOWTAG))
      
  ret.baseChallenge.addPokemonRule(MoveRestriction.new(:BATONPASS,:SWAGGER,:MINIMIZE,
      :DOUBLETEAM,:FISSURE,:HORNDRILL,:SHEERCOLD,:GUILLOTINE,:DARKVOID))
      
  ret.baseChallenge.addPokemonRule(BannedItemRestriction.new(:ALAKAZITE,:BLASTOISINITE,:GENGARITE,
      :ENIGMABERRY,:KANGASKHANITE))
  if $game_switches[Challenge]  
	ret.baseChallenge.addPokemonRule(DeadPkmn.new)
  end
  ret.baseChallenge.addBattleRule(OHKOClause.new)
  ret.baseChallenge.addPokemonRule(Legalmon.new)
  return ret
end


def natdexban(max)
  ret = PokemonSelection::Parameters.new
  ret.minPokemon = 1
  ret.maxPokemon = max
  ret.canCancel  = true
  ret.baseChallenge = PokemonChallengeRules.new 
  ret.baseChallenge.addTeamRule(SpeciesClause.new)
  ret.baseChallenge.addTeamRule(ItemClause.new)
  ret.baseChallenge.addBattleRule(SleepClause.new)
  ret.baseChallenge.addPokemonRule(BannedSpeciesRestriction.new(:DIALGA,:ETERNATUS,:GIRATINA,:GROUDON,
      :HOOH,:JIRACHI,:KYOGRE,:LUGIA,:LUNALA,:MAGEARNA,
      :MARSHADOW,:MELMETAL,:MEWTWO,:PALKIA,:RAYQUAZA,:RESHIRAM,:SOLGALEO,
      :XERNEAS,:YVELTAL,:ZACIAN,:ZAMAZENTA,:ZEKROM,:ARCEUS))
      
  ret.baseChallenge.addPokemonRule(BannedFormRestriction.new([:CALYREX,1],[:CALYREX,2],
      [:KYUREM,1],[:NECROZMA,1],[:NECROZMA,2],
      [:SHAYMIN,1],[:URSHIFU,0]))
      
  ret.baseChallenge.addPokemonRule(AbilityRestriction.new(:POWERCONSTRUCT,:SHADOWTAG))
      
  ret.baseChallenge.addPokemonRule(MoveRestriction.new(:BATONPASS,:SWAGGER,:MINIMIZE,
      :DOUBLETEAM,:FISSURE,:HORNDRILL,:SHEERCOLD,:GUILLOTINE,:DARKVOID))
      
  ret.baseChallenge.addPokemonRule(BannedItemRestriction.new(:ALAKAZITE,:BLASTOISINITE,:GENGARITE,
      :ENIGMABERRY,:KANGASKHANITE))
  if $game_switches[61] #Boss Battle clause
      ret.baseChallenge.addPokemonRule(MoveRestriction.new(:TRANSFORM,:LEECHSEED,:PERISHSONG,:ENDEAVOR))
	  ret.baseChallenge.addPokemonRule(AbilityRestriction.new(:IMPOSTER))
  end
  if $game_switches[Challenge]  
	ret.baseChallenge.addPokemonRule(DeadPkmn.new)
  end
  ret.baseChallenge.addPokemonRule(Legalmon.new)
  return ret
end

def stabmon(max)
  ret = PokemonSelection::Parameters.new
  ret.minPokemon = 1
  ret.maxPokemon = max
  ret.canCancel  = true
  ret.baseChallenge = PokemonChallengeRules.new 
  ret.baseChallenge.addPokemonRule(Stabmon.new)
  if $game_switches[Challenge]  
	ret.baseChallenge.addPokemonRule(DeadPkmn.new)
  end
  return ret
end

def gymrules(min,max,level)
  ret = PokemonSelection::Parameters.new
  ret.minPokemon = min
  ret.maxPokemon = max
  ret.canCancel  = true
  ret.baseChallenge = PokemonChallengeRules.new 
  ret.baseChallenge.addPokemonRule(Stabmon.new)
  ret.baseChallenge.addPokemonRule(MaximumLevelRestriction.new(level))
  return ret
end