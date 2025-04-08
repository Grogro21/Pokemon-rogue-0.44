def remove_items
    $bag.clear
    $player.party.each do |pkmn|
        pkmn.item = nil
    end
end

class PokemonBag
    def initialize_clone(source)
        @pockets = []
        source.pockets.each do |pocket|
            # de la merde et ça marche
            @pockets.push(pocket.clone)
        end

        self
    end

    def randomize_bag
        $game_switches[90] = true
        reset_last_selections
        @registered_items = []
        @ready_menu_selection = [0, 0, 1] # Used by the Ready Menu to remember cursor positions

        @pockets.each do |pocket|
            pocket.each do |item|
                new_item = get_random_item()
                replace_item(item[0], new_item.id)
            end
        end
    end

    alias orig_remove remove

    def remove(item, qty = 1)
        if $game_switches[90]
            return true
        end

        return orig_remove(item, qty)
    end

    def get_random_item
        itemlist = []
        GameData::Item.each do |i|
            itemlist.push(i)
        end

        return itemlist.sample
    end
end

class Battle::Battler

    def pbObedienceCheck?(choice)
        return true;
    end

    def pbChangeMove(slot_id, move)
        @pokemon.moves[slot_id] = Pokemon::Move.new(move) # Replaces current/total PP
        @moves[slot_id] = Battle::Move.from_pokemon_move(@battle, @pokemon.moves[slot_id])
        @battle.scene.pbRefresh
    end

    def pbRandomizeStats(limit = 3)
        prevStages = @stages.clone

        @stages[:ATTACK] = rand(-limit..limit)
        if @stages[:ATTACK] > prevStages[:ATTACK]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("ATTACK Up!")
        elsif @stages[:ATTACK] < prevStages[:ATTACK]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("ATTACK Down!")
        end

        @stages[:SPECIAL_ATTACK] = rand(-limit..limit)
        if @stages[:SPECIAL_ATTACK] > prevStages[:SPECIAL_ATTACK]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPECIAL_ATTACK Up!")
        elsif @stages[:SPECIAL_ATTACK] < prevStages[:SPECIAL_ATTACK]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPECIAL_ATTACK Down!")
        end

        @stages[:DEFENSE] = rand(-limit..limit)
        if @stages[:DEFENSE] > prevStages[:DEFENSE]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("DEFENSE Up!")
        elsif @stages[:DEFENSE] < prevStages[:DEFENSE]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("DEFENSE Down!")
        end

        @stages[:SPECIAL_DEFENSE] = rand(-limit..limit)
        if @stages[:SPECIAL_DEFENSE] > prevStages[:SPECIAL_DEFENSE]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPECIAL_DEFENSE Up!")
        elsif @stages[:SPECIAL_DEFENSE] < prevStages[:SPECIAL_DEFENSE]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPECIAL_DEFENSE Down!")
        end

        @stages[:SPEED] = rand(-limit..limit)
        if @stages[:SPEED] > prevStages[:SPEED]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("SPEED Up!")
        elsif @stages[:SPEED] < prevStages[:SPEED]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("SPEED Down!")
        end

        @stages[:ACCURACY] = rand(-limit..limit)
        if @stages[:ACCURACY] > prevStages[:ACCURACY]
            @battle.pbCommonAnimation("StatUp", self, nil)

            @battle.pbMessage("ACCURACY Up!")
        elsif @stages[:ACCURACY] < prevStages[:ACCURACY]
            @battle.pbCommonAnimation("StatDown", self, nil)

            @battle.pbMessage("ACCURACY Down!")
        end

    end

    def get_random_move
        movelist = []
        GameData::Move.each do |i|
            movelist.push(i)
        end

        return movelist.sample
    end

    alias orig pbSuccessCheckAgainstTarget

    def pbSuccessCheckAgainstTarget(move, user, target, targets)
        return true if target.hasActiveAbility?(:GODPOWER)
        return orig(move, user, target, targets)
    end

end

def pbChangeBattlerSpecies(pkmn, battler, battle)

    speciesTab = []
    GameData::Species.each do |s|
        speciesTab.push(s)
    end
    specie = speciesTab.sample().id

    if specie != pkmn.species
        pkmn.species = specie
        battler.species = specie
        battler&.pbUpdate(true)
        battler.name = pkmn.name
    end
end

class Battle::Move
    def pbCalcDamage(user, target, numTargets = 1)
        return if statusMove?
        if target.damageState.disguise || target.damageState.iceFace
            target.damageState.calcDamage = 1
            return
        end
        max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
        stageMul = Battle::Battler::STAT_STAGE_MULTIPLIERS
        stageDiv = Battle::Battler::STAT_STAGE_DIVISORS
        # Get the move's type
        type = @calcType # nil is treated as physical
        # Calculate whether this hit deals critical damage
        target.damageState.critical = pbIsCritical?(user, target)
        # Calcuate base power of move
        baseDmg = pbBaseDamage(@power, user, target)
        # Calculate user's attack stat
        atk, atkStage = pbGetAttackStats(user, target)
        if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
            atkStage = max_stage if target.damageState.critical && atkStage < max_stage
            atk = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
        end
        # Calculate target's defense stat
        defense, defStage = pbGetDefenseStats(user, target)
        if !user.hasActiveAbility?(:UNAWARE)
            defStage = max_stage if target.damageState.critical && defStage > max_stage
            defense = (defense.to_f * stageMul[defStage] / stageDiv[defStage]).floor
        end
        # Calculate all multiplier effects
        multipliers = {
            :power_multiplier => 1.0,
            :attack_multiplier => 1.0,
            :defense_multiplier => 1.0,
            :final_damage_multiplier => 1.0
        }
        pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
        # Main damage calculation
        if target.hasActiveAbility?(:GODPOWER)
            multipliers = {
                :power_multiplier => 1.0,
                :attack_multiplier => 1.0,
                :defense_multiplier => 1.0,
                :final_damage_multiplier => 0.5
            }

        end

        baseDmg = [(baseDmg * multipliers[:power_multiplier]).round, 1].max
        atk = [(atk * multipliers[:attack_multiplier]).round, 1].max
        defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
        damage = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
        damage = [(damage * multipliers[:final_damage_multiplier]).round, 1].max

        target.damageState.calcDamage = damage

    end

end

def pbReducePkmnHP(pkmn, amt)
    amt = amt.round
    amt = pkmn.hp - 1 if amt >= pkmn.hp
    amt = 1 if amt < 1 && !fainted?
    pkmn.hp -= amt
end

Battle::AbilityEffects::OnBeingHit.add(:GODPOWER,
                                       proc { |ability, user, target, move, battle|
                                           battle.pbShowAbilitySplash(target)
                                           battle.pbDisplay("Nothing is effective on God.")
                                           battle.pbHideAbilitySplash(target)
                                       })

Battle::AbilityEffects::OnBeingHit.add(:GODSHIELD,
                                       proc { |ability, user, target, move, battle|

                                           battle.pbShowAbilitySplash(target)
                                           battle.pbDisplay("#{target.pbThis(true)}'s shield reduced your damages!")
                                           battle.pbHideAbilitySplash(target)
                                       })
