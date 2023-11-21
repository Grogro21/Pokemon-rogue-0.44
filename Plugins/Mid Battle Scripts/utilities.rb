module BaseStatsProperty
  def self.set(settingname, oldsetting)
    return oldsetting if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      properties[s.pbs_order] = [_INTL("Base {1}", s.name), NonzeroLimitProperty.new(999999999999),
                                 _INTL("Base {1} stat of the Pokémon.", s.name)]
      data[s.pbs_order] = oldsetting[s.id] || 10
      stat_ids[s.pbs_order] = s.id
    end
    if pbPropertyList(settingname, data, properties, true)
      ret = {}
      stat_ids.each_with_index { |s, i| ret[s] = data[i] || 10 }
      oldsetting = ret
    end
    return oldsetting
  end

  def self.defaultValue
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = 10 if s.pbs_order >= 0 }
    return ret
  end

  def self.format(value)
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(",")
  end
end
###########custom functions ###########################################
class Battle	
	def pbLowerHP(pkmn,value)
		pkmn.pbReduceHP(pkmn.totalhp/value)
		pkmn.pbItemHPHealCheck
		if pkmn.fainted? 
			pkmn.pbFaint 
			if pbAbleCount(0)>=pbSideSize(0)  
				newPkmn = pbGetReplacementPokemonIndex(pkmn.index)   # Owner chooses
				return false if newPkmn < 0  
				pbRecallAndReplace(pkmn.index, newPkmn)
				pbClearChoice(pkmn.index)   # Replacement Pokémon does nothing this round
				moldBreaker = false 
				pbOnBattlerEnteringBattle(pkmn.index)
			end
		end
		if pbAbleCount(0)==0
			@decision=2  #loss in 0 able pokémon
		end
	end
end

def throwitem(pkmn)
	list=[:STICKYBARB,:IRONBALL,:CHOICEBAND,:CHOICESCARF,:CHOICESPECS,:BLACKSLUDGE,:EJECTBUTTON,:FLAMEORB,:TOXICORB,:FULLINCENSE,:LAGGINGTAIL,:MACHOBRACE,:RINGTARGET,:LEFTOVERS]	
	if list.include?(pkmn.item)
		battle.pbLowerHP(pkmn,8)
	end
	choice=list.sample
	pkmn.item=choice
	return choice
end




