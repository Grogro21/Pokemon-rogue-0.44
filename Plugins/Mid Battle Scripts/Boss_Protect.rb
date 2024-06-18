####Boss Protection effect####

class Battle::Move::UserTargetSwapItems < Battle::Move

    def pbFailsAgainstTarget?(user, target, show_message)
        if (!user.item && !target.item) || target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if target.unlosableItem?(target.item) ||
            target.unlosableItem?(user.item) ||
            user.unlosableItem?(user.item) ||
            user.unlosableItem?(target.item)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
            if show_message
                @battle.pbShowAbilitySplash(target)
                if Battle::Scene::USE_ABILITY_SPLASH
                    @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
                else
                    @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                            target.pbThis(true), target.abilityName))
                end
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        return false
    end
end

#===============================================================================
# User gives its item to the target. The item remains given after wild battles.
# (Bestow)
#===============================================================================
class Battle::Move::TargetTakesUserItem < Battle::Move

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.item || target.unlosableItem?(user.item) || target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# User and target swap abilities. (Skill Swap)
#===============================================================================
class Battle::Move::UserTargetSwapAbilities < Battle::Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.ability ||
            (user.ability == target.ability && Settings::MECHANICS_GENERATION <= 5)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if target.unstoppableAbility? || target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if target.ungainableAbility? || target.ability == :WONDERGUARD
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Averages the user's and target's Attack.
# Averages the user's and target's Special Attack. (Power Split)
#===============================================================================
class Battle::Move::UserTargetAverageBaseAtkSpAtk < Battle::Move
    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            newatk = ((user.attack + target.attack) / 2).floor
            newspatk = ((user.spatk + target.spatk) / 2).floor
            user.attack = target.attack = newatk
            user.spatk = target.spatk = newspatk
            @battle.pbDisplay(_INTL("{1} shared its power with the target!", user.pbThis))
        end
    end
end

#===============================================================================
# Averages the user's and target's Defense.
# Averages the user's and target's Special Defense. (Guard Split)
#===============================================================================
class Battle::Move::UserTargetAverageBaseDefSpDef < Battle::Move
    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            newdef = ((user.defense + target.defense) / 2).floor
            newspdef = ((user.spdef + target.spdef) / 2).floor
            user.defense = target.defense = newdef
            user.spdef = target.spdef = newspdef
            @battle.pbDisplay(_INTL("{1} shared its guard with the target!", user.pbThis))
        end
    end
end

#===============================================================================
# User and target swap their Attack and Special Attack stat stages. (Power Swap)
#===============================================================================
class Battle::Move::UserTargetSwapAtkSpAtkStages < Battle::Move
    def ignoresSubstitute?(user)
        ; return true;
    end

    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            [:ATTACK, :SPECIAL_ATTACK].each do |s|
                if user.stages[s] > target.stages[s]
                    user.statsLoweredThisRound = true
                    user.statsDropped = true
                    target.statsRaisedThisRound = true
                elsif user.stages[s] < target.stages[s]
                    user.statsRaisedThisRound = true
                    target.statsLoweredThisRound = true
                    target.statsDropped = true
                end
                user.stages[s], target.stages[s] = target.stages[s], user.stages[s]
            end
            @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!", user.pbThis))
        end
    end
end

#===============================================================================
# User and target swap their Defense and Special Defense stat stages. (Guard Swap)
#===============================================================================
class Battle::Move::UserTargetSwapDefSpDefStages < Battle::Move
    def ignoresSubstitute?(user)
        ; return true;
    end

    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            [:DEFENSE, :SPECIAL_DEFENSE].each do |s|
                if user.stages[s] > target.stages[s]
                    user.statsLoweredThisRound = true
                    user.statsDropped = true
                    target.statsRaisedThisRound = true
                elsif user.stages[s] < target.stages[s]
                    user.statsRaisedThisRound = true
                    target.statsLoweredThisRound = true
                    target.statsDropped = true
                end
                user.stages[s], target.stages[s] = target.stages[s], user.stages[s]
            end
            @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!", user.pbThis))
        end
    end
end

#===============================================================================
# User and target swap all their stat stages. (Heart Swap)
#===============================================================================
class Battle::Move::UserTargetSwapStatStages < Battle::Move

    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            GameData::Stat.each_battle do |s|
                if user.stages[s.id] > target.stages[s.id]
                    user.statsLoweredThisRound = true
                    user.statsDropped = true
                    target.statsRaisedThisRound = true
                elsif user.stages[s.id] < target.stages[s.id]
                    user.statsRaisedThisRound = true
                    target.statsLoweredThisRound = true
                    target.statsDropped = true
                end
                user.stages[s.id], target.stages[s.id] = target.stages[s.id], user.stages[s.id]
            end
            @battle.pbDisplay(_INTL("{1} switched stat changes with the target!", user.pbThis))
        end
    end
end

#===============================================================================
# User copies the target's stat stages. (Psych Up)
#===============================================================================
class Battle::Move::UserCopyTargetStatStages < Battle::Move

    def pbEffectAgainstTarget(user, target)
        if target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!"))
        else
            GameData::Stat.each_battle do |s|
                if user.stages[s.id] > target.stages[s.id]
                    user.statsLoweredThisRound = true
                    user.statsDropped = true
                elsif user.stages[s.id] < target.stages[s.id]
                    user.statsRaisedThisRound = true
                end
                user.stages[s.id] = target.stages[s.id]
            end
            if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
                user.effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
                user.effects[PBEffects::LaserFocus] = target.effects[PBEffects::LaserFocus]
            end
            @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!", user.pbThis, target.pbThis(true)))
        end
    end
end

#===============================================================================
# User gains stat stages equal to each of the target's positive stat stages,
# and target's positive stat stages become 0, before damage calculation.
# (Spectral Thief)
#===============================================================================
class Battle::Move::UserStealTargetPositiveStatStages < Battle::Move

    def pbCalcDamage(user, target, numTargets = 1)
        if target.hasRaisedStatStages? && !target.effects[PBEffects::BossProtect]
            pbShowAnimation(@id, user, target, 1) # Stat stage-draining animation
            @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!", user.pbThis))
            showAnim = true
            GameData::Stat.each_battle do |s|
                next if target.stages[s.id] <= 0
                if user.pbCanRaiseStatStage?(s.id, user, self)
                    showAnim = false if user.pbRaiseStatStage(s.id, target.stages[s.id], user, showAnim)
                end
                target.statsLoweredThisRound = true
                target.statsDropped = true
                target.stages[s.id] = 0
            end
        end
        super
    end
end

#===============================================================================
# Reverses all stat changes of the target. (Topsy-Turvy)
#===============================================================================
class Battle::Move::InvertTargetStatStages < Battle::Move

    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.hasAlteredStatStages? || target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Resets all target's stat stages to 0. (Clear Smog)
#===============================================================================
class Battle::Move::ResetTargetStatStages < Battle::Move
    def pbEffectAgainstTarget(user, target)
        if target.damageState.calcDamage > 0 && !target.damageState.substitute &&
            target.hasAlteredStatStages? && !target.effects[PBEffects::BossProtect]
            target.pbResetStatStages
            @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", target.pbThis))
        end
    end
end

#===============================================================================
# Resets all stat stages for all battlers to 0. (Haze)
#===============================================================================
class Battle::Move::ResetAllBattlersStatStages < Battle::Move
    def pbMoveFailed?(user, targets)
        if @battle.allBattlers.none? { |b| b.hasAlteredStatStages? }
            @battle.pbDisplay(_INTL("But it failed!"))
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.allBattlers.each { |b| b.pbResetStatStages if !b.effects[PBEffects::BossProtect] }
        @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    end
end

class Battle::Move::OHKO < Battle::Move::FixedDamageMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.level > user.level || target.effects[PBEffects::BossProtect] # OHKO fails against boss
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
            if show_message
                @battle.pbShowAbilitySplash(target)
                if Battle::Scene::USE_ABILITY_SPLASH
                    @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
                else
                    @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                            target.pbThis(true), target.abilityName))
                end
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        return false
    end
end

class Battle::Move::LowerTargetHPToUserHP < Battle::Move::FixedDamageMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if user.hp >= target.hp || target.effects[PBEffects::BossProtect] # boss
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

class Battle::Move::TransformUserIntoTarget < Battle::Move

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effects[PBEffects::Transform] ||
            target.effects[PBEffects::Illusion] || target.effects[PBEffects::BossProtect] # boss
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Averages the user's and target's current HP. (Pain Split)
#===============================================================================
class Battle::Move::UserTargetAverageHP < Battle::Move
    def pbEffectAgainstTarget(user, target)
        @battle.pbDisplay(_INTL("The boss is immune!")) if target.effects[PBEffects::BossProtect]
        return if target.effects[PBEffects::BossProtect]
        newHP = (user.hp + target.hp) / 2
        if user.hp > newHP
            user.pbReduceHP(user.hp - newHP, false, false)
        elsif user.hp < newHP
            user.pbRecoverHP(newHP - user.hp, false)
        end
        if target.hp > newHP
            target.pbReduceHP(target.hp - newHP, false, false)
        elsif target.hp < newHP
            target.pbRecoverHP(newHP - target.hp, false)
        end
        @battle.pbDisplay(_INTL("The battlers shared their pain!"))
        user.pbItemHPHealCheck
        target.pbItemHPHealCheck
    end
end

Battle::AbilityEffects::OnSwitchIn.add(:IMPOSTER,
                                       proc { |ability, battler, battle, switch_in|
                                           next if !switch_in || battler.effects[PBEffects::Transform] || target.effects[PBEffects::BossProtect] # boss
                                           choice = battler.pbDirectOpposing
                                           next if choice.fainted?
                                           next if choice.effects[PBEffects::Transform] ||
                                               choice.effects[PBEffects::Illusion] ||
                                               choice.effects[PBEffects::Substitute] > 0 ||
                                               choice.effects[PBEffects::SkyDrop] >= 0 ||
                                               choice.semiInvulnerable?
                                           battle.pbShowAbilitySplash(battler, true)
                                           battle.pbHideAbilitySplash(battler)
                                           battle.pbAnimation(:TRANSFORM, battler, choice)
                                           battle.scene.pbChangePokemon(battler, choice.pokemon)
                                           battler.pbTransform(choice)
                                       }
)

class Battle::Move::StartLeechSeedTarget < Battle::Move

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effects[PBEffects::LeechSeed] >= 0
            @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis)) if show_message
            return true
        end
        if target.pbHasType?(:GRASS) || target.effects[PBEffects::BossProtect] # boss
            @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
            return true
        end
        return false
    end
end

class Battle::Move::BindTarget < Battle::Move
    def pbEffectAgainstTarget(user, target)
        return if target.fainted? || target.damageState.substitute || target.effects[PBEffects::BossProtect] # boss
        return if target.effects[PBEffects::Trapping] > 0
        # Set trapping effect duration and info
        if user.hasActiveItem?(:GRIPCLAW)
            target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
        else
            target.effects[PBEffects::Trapping] = 5 + @battle.pbRandom(2)
        end
        target.effects[PBEffects::TrappingMove] = @id
        target.effects[PBEffects::TrappingUser] = user.index
        # Message
        msg = _INTL("{1} was trapped in the vortex!", target.pbThis)
        case @id
        when :BIND
            msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
        when :CLAMP
            msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
        when :FIRESPIN
            msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
        when :INFESTATION
            msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
        when :MAGMASTORM
            msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
        when :SANDTOMB
            msg = _INTL("{1} became trapped by Sand Tomb!", target.pbThis)
        when :WHIRLPOOL
            msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
        when :WRAP
            msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
        end
        @battle.pbDisplay(msg)
    end
end

class Battle::Move::AttackerFaintsIfUserFaints < Battle::Move # destiny bond
    def pbMoveFailed?(user, targets)
        if (Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]) || targets.effects[PBEffects::BossProtect] # boss
            @battle.pbDisplay(_INTL("But it failed!"))
            return true
        end
        return false
    end
end

#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#===============================================================================
class Battle::Move::CurseTargetOrLowerUserSpd1RaiseUserAtkDef1 < Battle::Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if (user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse]) || target.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# The target's ally loses 1/16 of its max HP. (Flame Burst)
#===============================================================================
class Battle::Move::DamageTargetAlly < Battle::Move
    def pbEffectWhenDealingDamage(user, target)
        hitAlly = []
        target.allAllies.each do |b|
            next if !b.near?(target.index)
            next if !b.takesIndirectDamage?
            hitAlly.push([b.index, b.hp])
            if target.effects[PBEffects::BossProtect]
                b.pbReduceHP(b.totalhp / 32, false)
            else
                b.pbReduceHP(b.totalhp / 16, false)
            end
        end
        if hitAlly.length == 2
            @battle.pbDisplay(_INTL("The bursting flame hit {1} and {2}!",
                                    @battle.battlers[hitAlly[0][0]].pbThis(true),
                                    @battle.battlers[hitAlly[1][0]].pbThis(true)))
        elsif hitAlly.length > 0
            hitAlly.each do |b|
                @battle.pbDisplay(_INTL("The bursting flame hit {1}!",
                                        @battle.battlers[b[0]].pbThis(true)))
            end
        end
        hitAlly.each { |b| @battle.battlers[b[0]].pbItemHPHealCheck }
    end
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class Battle::Move::StartPerishCountsForAllBattlers < Battle::Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return target.effects[PBEffects::PerishSong] > 0 || target.effects[PBEffects::BossProtect] # Heard it before
    end
end

class Battle::Move::FixedDamageHalfTargetHP < Battle::Move::FixedDamageMove
    def pbFixedDamage(user, target)
        if target.effects[PBEffects::BossProtect]
            return (target.hp / 20.0).round
        else
            return (target.hp / 2.0).round
        end
    end
end

#####boss protection (mist+safeguard)#######

class Battle::Battler
    def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
        return false if fainted?
        selfInflicted = (user && user.index == @index)
        # Already have that status problem
        if self.status == newStatus && !ignoreStatus
            if showMessages
                msg = ""
                case self.status
                when :SLEEP then msg = _INTL("{1} is already asleep!", pbThis)
                when :POISON then msg = _INTL("{1} is already poisoned!", pbThis)
                when :BURN then msg = _INTL("{1} already has a burn!", pbThis)
                when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
                when :FROZEN then msg = _INTL("{1} is already frozen solid!", pbThis)
                end
                @battle.pbDisplay(msg)
            end
            return false
        end
        # Trying to replace a status problem with another one
        if self.status != :NONE && !ignoreStatus && !selfInflicted
            @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
            return false
        end
        # Trying to inflict a status problem on a Pokémon behind a substitute
        if @effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) &&
            !selfInflicted
            @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
            return false
        end
        # Weather immunity
        if newStatus == :FROZEN && [:Sun, :HarshSun].include?(effectiveWeather)
            @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
            return false
        end
        # Terrains immunity
        if affectedByTerrain?
            case @battle.field.terrain
            when :Electric
                if newStatus == :SLEEP
                    if showMessages
                        @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!", pbThis(true)))
                    end
                    return false
                end
            when :Misty
                @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!", pbThis(true))) if showMessages
                return false
            end
        end
        # Uproar immunity
        if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
            @battle.allBattlers.each do |b|
                next if b.effects[PBEffects::Uproar] == 0
                @battle.pbDisplay(_INTL("But the uproar kept {1} awake!", pbThis(true))) if showMessages
                return false
            end
        end
        # Type immunities
        hasImmuneType = false
        case newStatus
        when :SLEEP
            # No type is immune to sleep
        when :POISON
            if !(user && user.hasActiveAbility?(:CORROSION))
                hasImmuneType |= pbHasType?(:POISON)
                hasImmuneType |= pbHasType?(:STEEL)
            end
        when :BURN
            hasImmuneType |= pbHasType?(:FIRE)
        when :PARALYSIS
            hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
        when :FROZEN
            hasImmuneType |= pbHasType?(:ICE)
        end
        if hasImmuneType
            @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true))) if showMessages
            return false
        end
        # Ability immunity
        immuneByAbility = false
        immAlly = nil
        if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, newStatus)
            immuneByAbility = true
        elsif selfInflicted || !@battle.moldBreaker
            if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
                immuneByAbility = true
            else
                allAllies.each do |b|
                    next if !b.abilityActive?
                    next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, newStatus)
                    immuneByAbility = true
                    immAlly = b
                    break
                end
            end
        end
        if immuneByAbility
            if showMessages
                @battle.pbShowAbilitySplash(immAlly || self)
                msg = ""
                if Battle::Scene::USE_ABILITY_SPLASH
                    case newStatus
                    when :SLEEP then msg = _INTL("{1} stays awake!", pbThis)
                    when :POISON then msg = _INTL("{1} cannot be poisoned!", pbThis)
                    when :BURN then msg = _INTL("{1} cannot be burned!", pbThis)
                    when :PARALYSIS then msg = _INTL("{1} cannot be paralyzed!", pbThis)
                    when :FROZEN then msg = _INTL("{1} cannot be frozen solid!", pbThis)
                    end
                elsif immAlly
                    case newStatus
                    when :SLEEP
                        msg = _INTL("{1} stays awake because of {2}'s {3}!",
                                    pbThis, immAlly.pbThis(true), immAlly.abilityName)
                    when :POISON
                        msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
                                    pbThis, immAlly.pbThis(true), immAlly.abilityName)
                    when :BURN
                        msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
                                    pbThis, immAlly.pbThis(true), immAlly.abilityName)
                    when :PARALYSIS
                        msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
                                    pbThis, immAlly.pbThis(true), immAlly.abilityName)
                    when :FROZEN
                        msg = _INTL("{1} cannot be frozen solid because of {2}'s {3}!",
                                    pbThis, immAlly.pbThis(true), immAlly.abilityName)
                    end
                else
                    case newStatus
                    when :SLEEP then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
                    when :POISON then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
                    when :BURN then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
                    when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
                    when :FROZEN then msg = _INTL("{1}'s {2} prevents freezing!", pbThis, abilityName)
                    end
                end
                @battle.pbDisplay(msg)
                @battle.pbHideAbilitySplash(immAlly || self)
            end
            return false
        end
        # Safeguard immunity
        if (pbOwnSide.effects[PBEffects::Safeguard] > 0 || self.effects[PBEffects::BossProtect]) && !selfInflicted && move &&
            !(user && user.hasActiveAbility?(:INFILTRATOR))
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanSynchronizeStatus?(newStatus, target)
        return false if fainted?
        # Trying to replace a status problem with another one
        return false if self.status != :NONE
        # Terrain immunity
        return false if @battle.field.terrain == :Misty && affectedByTerrain?
        # Type immunities
        hasImmuneType = false
        case newStatus
        when :POISON
            # NOTE: target will have Synchronize, so it can't have Corrosion.
            if !(target && target.hasActiveAbility?(:CORROSION))
                hasImmuneType |= pbHasType?(:POISON)
                hasImmuneType |= pbHasType?(:STEEL)
            end
        when :BURN
            hasImmuneType |= pbHasType?(:FIRE)
        when :PARALYSIS
            hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
        end
        return false if hasImmuneType
        # Ability immunity
        if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, newStatus)
            return false
        end
        if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
            return false
        end
        allAllies.each do |b|
            next if !b.abilityActive?
            next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, newStatus)
            return false
        end
        # Safeguard immunity
        if (pbOwnSide.effects[PBEffects::Safeguard] > 0 || self.effects[PBEffects::BossProtect]) &&
            !(self && self.hasActiveAbility?(:INFILTRATOR))
            return false
        end
        return true
    end

    def pbCanSleepYawn?
        return false if self.status != :NONE
        if affectedByTerrain? && [:Electric, :Misty].include?(@battle.field.terrain)
            return false
        end
        if !hasActiveAbility?(:SOUNDPROOF) && @battle.allBattlers.any? { |b| b.effects[PBEffects::Uproar] > 0 }
            return false
        end
        if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, :SLEEP)
            return false
        end
        # NOTE: Bulbapedia claims that Flower Veil shouldn't prevent sleep due to
        #       drowsiness, but I disagree because that makes no sense. Also, the
        #       comparable Sweet Veil does prevent sleep due to drowsiness.
        if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, :SLEEP)
            return false
        end
        allAllies.each do |b|
            next if !b.abilityActive?
            next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, :SLEEP)
            return false
        end
        # NOTE: Bulbapedia claims that Safeguard shouldn't prevent sleep due to
        #       drowsiness. I disagree with this too. Compare with the other sided
        #       effects Misty/Electric Terrain, which do prevent it.
        return false if (pbOwnSide.effects[PBEffects::Safeguard] > 0 || pbOwnSide.effects[PBEffects::BossProtect])
        return true
    end

    def pbCanConfuse?(user = nil, showMessages = true, move = nil, selfInflicted = false)
        return false if fainted?
        if @effects[PBEffects::Confusion] > 0
            @battle.pbDisplay(_INTL("{1} is already confused.", pbThis)) if showMessages
            return false
        end
        if @effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) &&
            !selfInflicted
            @battle.pbDisplay(_INTL("But it failed!")) if showMessages
            return false
        end
        # Terrains immunity
        if affectedByTerrain? && @battle.field.terrain == :Misty && Settings::MECHANICS_GENERATION >= 7
            @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!", pbThis(true))) if showMessages
            return false
        end
        if (selfInflicted || !@battle.moldBreaker) && hasActiveAbility?(:OWNTEMPO)
            if showMessages
                @battle.pbShowAbilitySplash(self)
                if Battle::Scene::USE_ABILITY_SPLASH
                    @battle.pbDisplay(_INTL("{1} doesn't become confused!", pbThis))
                else
                    @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!", pbThis, abilityName))
                end
                @battle.pbHideAbilitySplash(self)
            end
            return false
        end
        if (pbOwnSide.effects[PBEffects::Safeguard] > 0 || self.effects[PBEffects::BossProtect]) && !selfInflicted &&
            !(user && user.hasActiveAbility?(:INFILTRATOR))
            @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!", pbThis)) if showMessages
            return false
        end
        return true
    end

    def pbCanLowerStatStage?(stat, user = nil, move = nil, showFailMsg = false,
                             ignoreContrary = false, ignoreMirrorArmor = false)
        return false if fainted?
        if !@battle.moldBreaker
            # Contrary
            if hasActiveAbility?(:CONTRARY) && !ignoreContrary
                return pbCanRaiseStatStage?(stat, user, move, showFailMsg, true)
            end
            # Mirror Armor
            if hasActiveAbility?(:MIRRORARMOR) && !ignoreMirrorArmor &&
                user && user.index != @index && !statStageAtMin?(stat)
                return true
            end
        end
        if !user || user.index != @index # Not self-inflicted
            if @effects[PBEffects::Substitute] > 0 &&
                (ignoreMirrorArmor || !(move && move.ignoresSubstitute?(user)))
                @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis)) if showFailMsg
                return false
            end
            if (pbOwnSide.effects[PBEffects::Mist] > 0 || self.effects[PBEffects::BossProtect]) &&
                !(user && user.hasActiveAbility?(:INFILTRATOR))
                @battle.pbDisplay(_INTL("{1} is protected by Mist!", pbThis)) if showFailMsg
                return false
            end
            if abilityActive?
                return false if !@battle.moldBreaker && Battle::AbilityEffects.triggerStatLossImmunity(
                    self.ability, self, stat, @battle, showFailMsg
                )
                return false if Battle::AbilityEffects.triggerStatLossImmunityNonIgnorable(
                    self.ability, self, stat, @battle, showFailMsg
                )
            end
            if !@battle.moldBreaker
                allAllies.each do |b|
                    next if !b.abilityActive?
                    return false if Battle::AbilityEffects.triggerStatLossImmunityFromAlly(
                        b.ability, b, self, stat, @battle, showFailMsg
                    )
                end
            end
        end
        # Check the stat stage
        if statStageAtMin?(stat)
            if showFailMsg
                @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
                                        pbThis, GameData::Stat.get(stat).name))
            end
            return false
        end
        return true
    end

    def pbLowerAttackStatStageIntimidate(user)
        return false if fainted?
        # NOTE: Substitute intentionally blocks Intimidate even if self has Contrary.
        if @effects[PBEffects::Substitute] > 0
            if Battle::Scene::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1} is protected by its substitute!", pbThis))
            else
                @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
                                        pbThis, user.pbThis(true), user.abilityName))
            end
            return false
        end
        if Settings::MECHANICS_GENERATION >= 8 && hasActiveAbility?([:OBLIVIOUS, :OWNTEMPO, :INNERFOCUS, :SCRAPPY])
            @battle.pbShowAbilitySplash(self)
            if Battle::Scene::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", pbThis, GameData::Stat.get(:ATTACK).name))
            else
                @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", pbThis, abilityName,
                                        GameData::Stat.get(:ATTACK).name))
            end
            @battle.pbHideAbilitySplash(self)
            return false
        end
        if Battle::Scene::USE_ABILITY_SPLASH
            return pbLowerStatStageByAbility(:ATTACK, 1, user, false)
        end
        # NOTE: These checks exist to ensure appropriate messages are shown if
        #       Intimidate is blocked somehow (i.e. the messages should mention the
        #       Intimidate ability by name).
        if !hasActiveAbility?(:CONTRARY)
            if (pbOwnSide.effects[PBEffects::Mist] > 0 || self.effects[PBEffects::BossProtect])
                @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
                                        pbThis, user.pbThis(true), user.abilityName))
                return false
            end
            if abilityActive? &&
                (Battle::AbilityEffects.triggerStatLossImmunity(self.ability, self, :ATTACK, @battle, false) ||
                    Battle::AbilityEffects.triggerStatLossImmunityNonIgnorable(self.ability, self, :ATTACK, @battle, false))
                @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
                                        pbThis, abilityName, user.pbThis(true), user.abilityName))
                return false
            end
            allAllies.each do |b|
                next if !b.abilityActive?
                if Battle::AbilityEffects.triggerStatLossImmunityFromAlly(b.ability, b, self, :ATTACK, @battle, false)
                    @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
                                            pbThis, user.pbThis(true), user.abilityName, b.pbThis(true), b.abilityName))
                    return false
                end
            end
        end
        return false if !pbCanLowerStatStage?(:ATTACK, user)
        return pbLowerStatStageByCause(:ATTACK, 1, user, user.abilityName)
    end

    def takesSandstormDamage?
        return false if !takesIndirectDamage? || self.effects[PBEffects::BossProtect]
        return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
        return false if inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                         "TwoTurnAttackInvulnerableUnderwater")
        return false if hasActiveAbility?([:OVERCOAT, :SANDFORCE, :SANDRUSH, :SANDVEIL])
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return true
    end

    def takesHailDamage?
        return false if !takesIndirectDamage? || self.effects[PBEffects::BossProtect]
        return false if pbHasType?(:ICE)
        return false if inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                         "TwoTurnAttackInvulnerableUnderwater")
        return false if hasActiveAbility?([:OVERCOAT, :ICEBODY, :SNOWCLOAK])
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return true
    end

    def takesShadowSkyDamage?
        return false if fainted?
        return false if shadowPokemon? || self.effects[PBEffects::BossProtect]
        return true
    end
end

class Battle
    def pbEORSeaOfFireDamage(priority)
        2.times do |side|
            next if sides[side].effects[PBEffects::SeaOfFire] == 0
            pbCommonAnimation("SeaOfFire") if side == 0
            pbCommonAnimation("SeaOfFireOpp") if side == 1
            priority.each do |battler|
                next if battler.opposes?(side)
                next if !battler.takesIndirectDamage? || battler.pbHasType?(:FIRE) || self.effects[PBEffects::BossProtect]
                @scene.pbDamageAnimation(battler)
                battler.pbTakeEffectDamage(battler.totalhp / 8, false) { |hp_lost|
                    pbDisplay(_INTL("{1} is hurt by the sea of fire!", battler.pbThis))
                }
            end
        end
    end

end

class Battle::Move::TargetNextFireMoveDamagesTarget < Battle::Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effects[PBEffects::Powder] || self.effects[PBEffects::BossProtect]
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end
end

class Battle::Battler
    #=============================================================================
    # Effect per hit
    #=============================================================================
    def pbEffectsOnMakingHit(move, user, target)
        if target.damageState.calcDamage > 0 && !target.damageState.substitute && !target.effects[PBEffects::BossProtect]
            # Target's ability
            if target.abilityActive?(true)
                oldHP = user.hp
                Battle::AbilityEffects.triggerOnBeingHit(target.ability, user, target, move, @battle)
                user.pbItemHPHealCheck if user.hp < oldHP
            end
            # Cramorant - Gulp Missile
            if target.isSpecies?(:CRAMORANT) && target.ability == :GULPMISSILE &&
                target.form > 0 && !target.effects[PBEffects::Transform]
                oldHP = user.hp
                # NOTE: Strictly speaking, an attack animation should be shown (the
                #       target Cramorant attacking the user) and the ability splash
                #       shouldn't be shown.
                @battle.pbShowAbilitySplash(target)
                if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
                    @battle.scene.pbDamageAnimation(user)
                    if !target.effects[PBEffects::BossProtect]
                        user.pbReduceHP(user.totalhp / 4, false)
                    else
                        user.pbReduceHP(user.totalhp / 10, false)
                    end
                end
                case target.form
                when 1 # Gulping Form
                    user.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
                when 2 # Gorging Form
                    target.pbParalyze(user) if target.pbCanParalyze?(user, false)
                end
                @battle.pbHideAbilitySplash(target)
                user.pbItemHPHealCheck if user.hp < oldHP
            end
            # User's ability
            if user.abilityActive?(true)
                Battle::AbilityEffects.triggerOnDealingHit(user.ability, user, target, move, @battle)
                user.pbItemHPHealCheck
            end
            # Target's item
            if target.itemActive?(true)
                oldHP = user.hp
                Battle::ItemEffects.triggerOnBeingHit(target.item, user, target, move, @battle)
                user.pbItemHPHealCheck if user.hp < oldHP
            end
        end
        if target.opposes?(user)
            # Rage
            if target.effects[PBEffects::Rage] && !target.fainted? &&
                target.pbCanRaiseStatStage?(:ATTACK, target)
                @battle.pbDisplay(_INTL("{1}'s rage is building!", target.pbThis))
                target.pbRaiseStatStage(:ATTACK, 1, target)
            end
            # Beak Blast
            if target.effects[PBEffects::BeakBlast]
                PBDebug.log("[Lingering effect] #{target.pbThis}'s Beak Blast")
                if move.pbContactMove?(user) && user.affectedByContactEffect? &&
                    target.pbCanBurn?(user, false, self)
                    target.pbBurn(user)
                end
            end
            # Shell Trap (make the trapper move next if the trap was triggered)
            if target.effects[PBEffects::ShellTrap] && move.physicalMove? &&
                @battle.choices[target.index][0] == :UseMove && !target.movedThisRound? &&
                target.damageState.hpLost > 0 && !target.damageState.substitute
                target.tookPhysicalHit = true
                target.effects[PBEffects::MoveNext] = true
                target.effects[PBEffects::Quash] = 0
            end
            # Grudge
            if target.effects[PBEffects::Grudge] && target.fainted? && !target.effects[PBEffects::BossProtect]
                user.pbSetPP(move, 0)
                @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
                                        user.pbThis, move.name))
            end
            # Destiny Bond (recording that it should apply)
            if target.effects[PBEffects::DestinyBond] && target.fainted? &&
                user.effects[PBEffects::DestinyBondTarget] < 0
                user.effects[PBEffects::DestinyBondTarget] = target.index
            end
        end
    end

    def pbFlinch(_user = nil)
        return if hasActiveAbility?(:INNERFOCUS) && !@battle.moldBreaker && !@effects[PBEffects::BossProtect]
        @effects[PBEffects::Flinch] = true
    end
end

Battle::ItemEffects::EndOfRoundHealing.add(:BLACKSLUDGE,
                                           proc { |item, battler, battle|
                                               if battler.pbHasType?(:POISON)
                                                   next if !battler.canHeal?
                                                   battle.pbCommonAnimation("UseItem", battler)
                                                   battler.pbRecoverHP(battler.totalhp / 16)
                                                   battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
                                                                          battler.pbThis, battler.itemName))
                                               elsif battler.takesIndirectDamage? || battler.effects[PBEffects::BossProtect]
                                                   battle.pbCommonAnimation("UseItem", battler)
                                                   battler.pbTakeEffectDamage(battler.totalhp / 8) { |hp_lost|
                                                       battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, battler.itemName))
                                                   }
                                               end
                                           }
)

Battle::ItemEffects::EndOfRoundEffect.add(:STICKYBARB,
                                          proc { |item, battler, battle|
                                              next if !battler.takesIndirectDamage? || battler.effects[PBEffects::BossProtect]
                                              battle.scene.pbDamageAnimation(battler)
                                              battler.pbTakeEffectDamage(battler.totalhp / 8, false) { |hp_lost|
                                                  battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, battler.itemName))
                                              }
                                          }
)

Battle::AbilityEffects::OnBeingHit.add(:AFTERMATH,
                                       proc { |ability, user, target, move, battle|
                                           next if !target.fainted?
                                           next if !move.pbContactMove?(user)
                                           battle.pbShowAbilitySplash(target)
                                           if !battle.moldBreaker
                                               dampBattler = battle.pbCheckGlobalAbility(:DAMP)
                                               if dampBattler
                                                   battle.pbShowAbilitySplash(dampBattler)
                                                   if Battle::Scene::USE_ABILITY_SPLASH
                                                       battle.pbDisplay(_INTL("{1} cannot use {2}!", target.pbThis, target.abilityName))
                                                   else
                                                       battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
                                                                              target.pbThis, target.abilityName, dampBattler.pbThis(true), dampBattler.abilityName))
                                                   end
                                                   battle.pbHideAbilitySplash(dampBattler)
                                                   battle.pbHideAbilitySplash(target)
                                                   next
                                               end
                                           end
                                           if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) && user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH) && !user.effects[PBEffects::BossProtect]
                                               battle.scene.pbDamageAnimation(user)
                                               user.pbReduceHP(user.totalhp / 4, false)
                                               battle.pbDisplay(_INTL("{1} was caught in the aftermath!", user.pbThis))
                                           end
                                           battle.pbHideAbilitySplash(target)
                                       }
)

Battle::AbilityEffects::OnBeingHit.add(:IRONBARBS,
                                       proc { |ability, user, target, move, battle|
                                           next if !move.pbContactMove?(user)
                                           battle.pbShowAbilitySplash(target)
                                           if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) && user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
                                               battle.scene.pbDamageAnimation(user)
                                               if user.effects[PBEffects::BossProtect]
                                                   user.pbReduceHP(user.totalhp / 24, false)
                                               else
                                                   user.pbReduceHP(user.totalhp / 8, false)
                                               end
                                               if Battle::Scene::USE_ABILITY_SPLASH
                                                   battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
                                               else
                                                   battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!", user.pbThis,
                                                                          target.pbThis(true), target.abilityName))
                                               end
                                           end
                                           battle.pbHideAbilitySplash(target)
                                       }
)

Battle::ItemEffects::OnBeingHit.add(:ROCKYHELMET,
                                    proc { |item, user, target, move, battle|
                                        next if !move.pbContactMove?(user) || !user.affectedByContactEffect?
                                        next if !user.takesIndirectDamage?
                                        battle.scene.pbDamageAnimation(user)
                                        if user.effects[PBEffects::BossProtect]
                                            user.pbReduceHP(user.totalhp / 18, false)
                                        else
                                            user.pbReduceHP(user.totalhp / 6, false)
                                        end
                                        battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, target.itemName))
                                    }
)

Battle::ItemEffects::AfterMoveUseFromUser.add(:LIFEORB,
                                              proc { |item, user, targets, move, numHits, battle|
                                                  next if !user.takesIndirectDamage?
                                                  next if !move.pbDamagingMove? || numHits == 0
                                                  hitBattler = false
                                                  targets.each do |b|
                                                      hitBattler = true if !b.damageState.unaffected && !b.damageState.substitute
                                                      break if hitBattler
                                                  end
                                                  next if !hitBattler
                                                  PBDebug.log("[Item triggered] #{user.pbThis}'s #{user.itemName} (recoil)")
                                                  if user.effects[PBEffects::BossProtect]
                                                      user.pbReduceHP(user.totalhp / 30, false)
                                                  else
                                                      user.pbReduceHP(user.totalhp / 10, false)
                                                  end
                                                  battle.pbDisplay(_INTL("{1} lost some of its HP!", user.pbThis))
                                                  user.pbItemHPHealCheck
                                                  user.pbFaint if user.fainted?
                                              }
)
