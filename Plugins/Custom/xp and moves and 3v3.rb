class Battle
  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    # Main Exp calculation
    exp = 0
    return if exp <= 0
  end

  def pbGainMoney
    return if !@internalBattle || !@moneyGain
    # Money rewarded from opposing trainers
    if trainerBattle?
      tMoney = 0
      oldMoney = pbPlayer.money
      pbPlayer.money += tMoney
      moneyGained = pbPlayer.money - oldMoney
      if moneyGained > 0
        $stats.battle_money_gained += moneyGained
        pbDisplayPaused(_INTL("You got ${1} for winning!", moneyGained.to_s_formatted))
      end
    end
    # Pick up money scattered by Pay Day
    if @field.effects[PBEffects::PayDay] > 0
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::AmuletCoin]
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::HappyHour]
      oldMoney = pbPlayer.money
      pbPlayer.money += @field.effects[PBEffects::PayDay]
      moneyGained = pbPlayer.money - oldMoney
      if moneyGained > 0
        $stats.battle_money_gained += moneyGained
        pbDisplayPaused(_INTL("You picked up ${1}!", moneyGained.to_s_formatted))
      end
    end
  end
  
  def nearBattlers?(idxBattler1, idxBattler2)
    return false if idxBattler1 == idxBattler2
    return true if (pbSideSize(0) <= 2 && pbSideSize(1) <= 2) || $game_switches[74] #disables 3v3 special targeting ?
    # Get all pairs of battler positions that are not close to each other
    pairsArray = [[0, 4], [1, 5]]   # Covers 3v1 and 1v3
    case pbSideSize(0)
    when 3
      case pbSideSize(1)
      when 3   # 3v3 (triple)
        pairsArray.push([0, 1])
        pairsArray.push([4, 5])
      when 2   # 3v2
        pairsArray.push([0, 1])
        pairsArray.push([3, 4])
      end
    when 2       # 2v3
      pairsArray.push([0, 1])
      pairsArray.push([2, 5])
    end
    # See if any pair matches the two battlers being assessed
    pairsArray.each do |pair|
      return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
    end
    return true
  end
end


