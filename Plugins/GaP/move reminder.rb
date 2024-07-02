MOVELIST = 51

class Battle
    def pbStartBattle
        $game_variables[MOVELIST] = []
        PBDebug.log("")
        PBDebug.log("================================================================")
        PBDebug.log("")
        logMsg = "[Started battle] "
        if @sideSizes[0] == 1 && @sideSizes[1] == 1
            logMsg += "Single "
        elsif @sideSizes[0] == 2 && @sideSizes[1] == 2
            logMsg += "Double "
        elsif @sideSizes[0] == 3 && @sideSizes[1] == 3
            logMsg += "Triple "
        else
            logMsg += "#{@sideSizes[0]}v#{@sideSizes[1]} "
        end
        logMsg += "wild " if wildBattle?
        logMsg += "trainer " if trainerBattle?
        logMsg += "battle (#{@player.length} trainer(s) vs. "
        logMsg += "#{pbParty(1).length} wild Pokémon)" if wildBattle?
        logMsg += "#{@opponent.length} trainer(s))" if trainerBattle?
        PBDebug.log(logMsg)
        pbEnsureParticipants
        pbParty(0).each { |pkmn| @peer.pbOnStartingBattle(self, pkmn, wildBattle?) if pkmn }
        pbParty(1).each { |pkmn| @peer.pbOnStartingBattle(self, pkmn, wildBattle?) if pkmn }
        begin
            pbStartBattleCore
        rescue BattleAbortedException
            @decision = 0
            # initialize variable
            @scene.pbEndBattle(@decision)
        end
        return @decision
    end
end

class Battle::Battler
    # adds the moves used to the list
    def pbUseMove(choice, specialUsage = false)
        # NOTE: This is intentionally determined before a multi-turn attack can
        #       set specialUsage to true.
        skipAccuracyCheck = (specialUsage && choice[2] != @battle.struggle)
        # Start using the move
        pbBeginTurn(choice)
        # Force the use of certain moves if they're already being used
        if !@battle.futureSight
            if usingMultiTurnAttack?
                choice[2] = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
                specialUsage = true
            elsif @effects[PBEffects::Encore] > 0 && choice[1] >= 0 &&
                @battle.pbCanShowCommands?(@index)
                idxEncoredMove = pbEncoredMoveIndex
                if idxEncoredMove >= 0 && choice[1] != idxEncoredMove &&
                    @battle.pbCanChooseMove?(@index, idxEncoredMove, false) # Change move if battler was Encored mid-round
                    choice[1] = idxEncoredMove
                    choice[2] = @moves[idxEncoredMove]
                    choice[3] = -1 # No target chosen
                end
            end
        end
        # Labels the move being used as "move"
        move = choice[2]
        return if !move # if move was not chosen somehow
        # Try to use the move (inc. disobedience)
        @lastMoveFailed = false
        if !pbTryUseMove(choice, move, specialUsage, skipAccuracyCheck)
            @lastMoveUsed = nil
            @lastMoveUsedType = nil
            if !specialUsage
                @lastRegularMoveUsed = nil
                @lastRegularMoveTarget = -1
            end
            @battle.pbGainExp # In case self is KO'd due to confusion
            pbCancelMoves
            pbEndTurn(choice)
            return
        end
        move = choice[2] # In case disobedience changed the move to be used
        return if !move # if move was not chosen somehow
        # Subtract PP
        if !specialUsage && !pbReducePP(move)
            @battle.pbDisplay(_INTL("{1} used {2}!", pbThis, move.name))
            @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
            @lastMoveUsed = nil
            @lastMoveUsedType = nil
            @lastRegularMoveUsed = nil
            @lastRegularMoveTarget = -1
            @lastMoveFailed = true
            pbCancelMoves
            pbEndTurn(choice)
            return
        end
        # Stance Change
        if isSpecies?(:AEGISLASH) && self.ability == :STANCECHANGE
            if move.damagingMove?
                pbChangeForm(1, _INTL("{1} changed to Blade Forme!", pbThis))
            elsif move.id == :KINGSSHIELD
                pbChangeForm(0, _INTL("{1} changed to Shield Forme!", pbThis))
            end
        end
        # Calculate the move's type during this usage
        move.calcType = move.pbCalcType(self)
        # Start effect of Mold Breaker
        @battle.moldBreaker = hasMoldBreaker?
        # Remember that user chose a two-turn move
        if move.pbIsChargingTurn?(self)
            # Beginning the use of a two-turn attack
            @effects[PBEffects::TwoTurnAttack] = move.id
            @currentMove = move.id
        else
            @effects[PBEffects::TwoTurnAttack] = nil # Cancel use of two-turn attack
        end
        # Add to counters for moves which increase them when used in succession
        move.pbChangeUsageCounters(self, specialUsage)
        # Charge up Metronome item
        if hasActiveItem?(:METRONOME) && !move.callsAnotherMove?
            if @lastMoveUsed && @lastMoveUsed == move.id && !@lastMoveFailed
                @effects[PBEffects::Metronome] += 1
            else
                @effects[PBEffects::Metronome] = 0
            end
        end
        # Record move as having been used
        $game_variables[MOVELIST].push(move.id)
        @lastMoveUsed = move.id
        @lastMoveUsedType = move.calcType # For Conversion 2
        if !specialUsage
            @lastRegularMoveUsed = move.id # For Disable, Encore, Instruct, Mimic, Mirror Move, Sketch, Spite
            @lastRegularMoveTarget = choice[3] # For Instruct (remembering original target is fine)
            @movesUsed.push(move.id) if !@movesUsed.include?(move.id) # For Last Resort
        end
        @battle.lastMoveUsed = move.id # For Copycat
        @battle.lastMoveUser = @index # For "self KO" battle clause to avoid draws
        @battle.successStates[@index].useState = 1 # Battle Arena - assume failure
        # Find the default user (self or Snatcher) and target(s)
        user = pbFindUser(choice, move)
        user = pbChangeUser(choice, move, user)
        targets = pbFindTargets(choice, move, user)
        targets = pbChangeTargets(move, user, targets)
        # Pressure
        if !specialUsage
            targets.each do |b|
                next unless b.opposes?(user) && b.hasActiveAbility?(:PRESSURE)
                PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
                user.pbReducePP(move)
            end
            if move.pbTarget(user).affects_foe_side
                @battle.allOtherSideBattlers(user).each do |b|
                    next unless b.hasActiveAbility?(:PRESSURE)
                    PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
                    user.pbReducePP(move)
                end
            end
        end
        # Dazzling/Queenly Majesty make the move fail here
        @battle.pbPriority(true).each do |b|
            next if !b || !b.abilityActive?
            if Battle::AbilityEffects.triggerMoveBlocking(b.ability, b, user, targets, move, @battle)
                @battle.pbDisplayBrief(_INTL("{1} used {2}!", user.pbThis, move.name))
                @battle.pbShowAbilitySplash(b)
                @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, move.name))
                @battle.pbHideAbilitySplash(b)
                user.lastMoveFailed = true
                pbCancelMoves
                pbEndTurn(choice)
                return
            end
        end
        # "X used Y!" message
        # Can be different for Bide, Fling, Focus Punch and Future Sight
        # NOTE: This intentionally passes self rather than user. The user is always
        #       self except if Snatched, but this message should state the original
        #       user (self) even if the move is Snatched.
        move.pbDisplayUseMessage(self)
        # Snatch's message (user is the new user, self is the original user)
        if move.snatched
            @lastMoveFailed = true # Intentionally applies to self, not user
            @battle.pbDisplay(_INTL("{1} snatched {2}'s move!", user.pbThis, pbThis(true)))
        end
        # "But it failed!" checks
        if move.pbMoveFailed?(user, targets)
            PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailed?", move.function_code))
            user.lastMoveFailed = true
            pbCancelMoves
            pbEndTurn(choice)
            return
        end
        # Perform set-up actions and display messages
        # Messages include Magnitude's number and Pledge moves' "it's a combo!"
        move.pbOnStartUse(user, targets)
        # Self-thawing due to the move
        if user.status == :FROZEN && move.thawsUser?
            user.pbCureStatus(false)
            @battle.pbDisplay(_INTL("{1} melted the ice!", user.pbThis))
        end
        # Powder
        if user.effects[PBEffects::Powder] && move.calcType == :FIRE
            @battle.pbCommonAnimation("Powder", user)
            @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
            user.lastMoveFailed = true
            if ![:Rain, :HeavyRain].include?(user.effectiveWeather) && user.takesIndirectDamage?
                user.pbTakeEffectDamage((user.totalhp / 4.0).round, false) do |hp_lost|
                    @battle.pbDisplay(_INTL("{1} is hurt by Powder!", user.pbThis))
                end
                @battle.pbGainExp # In case user is KO'd by this
            end
            pbCancelMoves
            pbEndTurn(choice)
            return
        end
        # Primordial Sea, Desolate Land
        if move.damagingMove?
            case @battle.pbWeather
            when :HeavyRain
                if move.calcType == :FIRE
                    @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
                    user.lastMoveFailed = true
                    pbCancelMoves
                    pbEndTurn(choice)
                    return
                end
            when :HarshSun
                if move.calcType == :WATER
                    @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
                    user.lastMoveFailed = true
                    pbCancelMoves
                    pbEndTurn(choice)
                    return
                end
            end
        end
        # Protean
        if user.hasActiveAbility?([:LIBERO, :PROTEAN]) &&
            !move.callsAnotherMove? && !move.snatched &&
            user.pbHasOtherType?(move.calcType) && !GameData::Type.get(move.calcType).pseudo_type
            @battle.pbShowAbilitySplash(user)
            user.pbChangeTypes(move.calcType)
            typeName = GameData::Type.get(move.calcType).name
            @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", user.pbThis, typeName))
            @battle.pbHideAbilitySplash(user)
            # NOTE: The GF games say that if Curse is used by a non-Ghost-type
            #       Pokémon which becomes Ghost-type because of Protean, it should
            #       target and curse itself. I think this is silly, so I'm making it
            #       choose a random opponent to curse instead.
            if move.function_code == "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" && targets.length == 0
                choice[3] = -1
                targets = pbFindTargets(choice, move, user)
            end
        end
        # For two-turn moves when they charge and attack in the same turn
        move.pbQuickChargingMove(user, targets)
        #---------------------------------------------------------------------------
        magicCoater = -1
        magicBouncer = -1
        if targets.length == 0 && move.pbTarget(user).num_targets > 0 && !move.worksWithNoTargets?
            # def pbFindTargets should have found a target(s), but it didn't because
            # they were all fainted
            # All target types except: None, User, UserSide, FoeSide, BothSides
            @battle.pbDisplay(_INTL("But there was no target..."))
            user.lastMoveFailed = true
        else
            # We have targets, or move doesn't use targets
            # Reset whole damage state, perform various success checks (not accuracy)
            @battle.allBattlers.each do |b|
                b.droppedBelowHalfHP = false
                b.statsDropped = false
            end
            targets.each do |b|
                b.damageState.reset
                next if pbSuccessCheckAgainstTarget(move, user, b, targets)
                b.damageState.unaffected = true
            end
            # Magic Coat/Magic Bounce checks (for moves which don't target Pokémon)
            if targets.length == 0 && move.statusMove? && move.canMagicCoat?
                @battle.pbPriority(true).each do |b|
                    next if b.fainted? || !b.opposes?(user)
                    next if b.semiInvulnerable?
                    if b.effects[PBEffects::MagicCoat]
                        magicCoater = b.index
                        b.effects[PBEffects::MagicCoat] = false
                        break
                    elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
                        !b.effects[PBEffects::MagicBounce]
                        magicBouncer = b.index
                        b.effects[PBEffects::MagicBounce] = true
                        break
                    end
                end
            end
            # Get the number of hits
            numHits = move.pbNumHits(user, targets)
            # Process each hit in turn
            realNumHits = 0
            numHits.times do |i|
                break if magicCoater >= 0 || magicBouncer >= 0
                success = pbProcessMoveHit(move, user, targets, i, skipAccuracyCheck)
                if !success
                    if i == 0 && targets.length > 0
                        hasFailed = false
                        targets.each do |t|
                            next if t.damageState.protected
                            hasFailed = t.damageState.unaffected
                            break if !t.damageState.unaffected
                        end
                        user.lastMoveFailed = hasFailed
                    end
                    break
                end
                realNumHits += 1
                break if user.fainted?
                break if [:SLEEP, :FROZEN].include?(user.status)
                # NOTE: If a multi-hit move becomes disabled partway through doing those
                #       hits (e.g. by Cursed Body), the rest of the hits continue as
                #       normal.
                break if targets.none? { |t| !t.fainted? } # All targets are fainted
            end
            # Battle Arena only - attack is successful
            @battle.successStates[user.index].useState = 2
            if targets.length > 0
                @battle.successStates[user.index].typeMod = 0
                targets.each do |b|
                    next if b.damageState.unaffected
                    @battle.successStates[user.index].typeMod += b.damageState.typeMod
                end
            end
            # Effectiveness message for multi-hit moves
            # NOTE: No move is both multi-hit and multi-target, and the messages below
            #       aren't quite right for such a hypothetical move.
            if numHits > 1
                if move.damagingMove?
                    targets.each do |b|
                        next if b.damageState.unaffected || b.damageState.substitute
                        move.pbEffectivenessMessage(user, b, targets.length)
                    end
                end
                if realNumHits == 1
                    @battle.pbDisplay(_INTL("Hit 1 time!"))
                elsif realNumHits > 1
                    @battle.pbDisplay(_INTL("Hit {1} times!", realNumHits))
                end
            end
            # Magic Coat's bouncing back (move has targets)
            targets.each do |b|
                next if b.fainted?
                next if !b.damageState.magicCoat && !b.damageState.magicBounce
                @battle.pbShowAbilitySplash(b) if b.damageState.magicBounce
                @battle.pbDisplay(_INTL("{1} bounced the {2} back!", b.pbThis, move.name))
                @battle.pbHideAbilitySplash(b) if b.damageState.magicBounce
                newChoice = choice.clone
                newChoice[3] = user.index
                newTargets = pbFindTargets(newChoice, move, b)
                newTargets = pbChangeTargets(move, b, newTargets)
                success = false
                if !move.pbMoveFailed?(b, newTargets)
                    newTargets.each_with_index do |newTarget, idx|
                        if pbSuccessCheckAgainstTarget(move, b, newTarget, newTargets)
                            success = true
                            next
                        end
                        newTargets[idx] = nil
                    end
                    newTargets.compact!
                end
                pbProcessMoveHit(move, b, newTargets, 0, false) if success
                b.lastMoveFailed = true if !success
                targets.each { |otherB| otherB.pbFaint if otherB&.fainted? }
                user.pbFaint if user.fainted?
            end
            # Magic Coat's bouncing back (move has no targets)
            if magicCoater >= 0 || magicBouncer >= 0
                mc = @battle.battlers[(magicCoater >= 0) ? magicCoater : magicBouncer]
                if !mc.fainted?
                    user.lastMoveFailed = true
                    @battle.pbShowAbilitySplash(mc) if magicBouncer >= 0
                    @battle.pbDisplay(_INTL("{1} bounced the {2} back!", mc.pbThis, move.name))
                    @battle.pbHideAbilitySplash(mc) if magicBouncer >= 0
                    success = false
                    if !move.pbMoveFailed?(mc, [])
                        success = pbProcessMoveHit(move, mc, [], 0, false)
                    end
                    mc.lastMoveFailed = true if !success
                    targets.each { |b| b.pbFaint if b&.fainted? }
                    user.pbFaint if user.fainted?
                end
            end
            # Move-specific effects after all hits
            targets.each { |b| move.pbEffectAfterAllHits(user, b) }
            # Faint if 0 HP
            targets.each { |b| b.pbFaint if b&.fainted? }
            user.pbFaint if user.fainted?
            # External/general effects after all hits. Eject Button, Shell Bell, etc.
            pbEffectsAfterMove(user, targets, move, realNumHits)
            @battle.allBattlers.each do |b|
                b.droppedBelowHalfHP = false
                b.statsDropped = false
            end
        end
        # End effect of Mold Breaker
        @battle.moldBreaker = false
        # Gain Exp
        @battle.pbGainExp
        # Battle Arena only - update skills
        @battle.allBattlers.each { |b| @battle.successStates[b.index].updateSkill }
        # Shadow Pokémon triggering Hyper Mode
        pbHyperMode if @battle.choices[@index][0] != :None # Not if self is replaced
        # End of move usage
        pbEndTurn(choice)
        # Instruct
        @battle.allBattlers.each do |b|
            next if !b.effects[PBEffects::Instruct] || !b.lastMoveUsed
            b.effects[PBEffects::Instruct] = false
            idxMove = -1
            b.eachMoveWithIndex { |m, i| idxMove = i if m.id == b.lastMoveUsed }
            next if idxMove < 0
            oldLastRoundMoved = b.lastRoundMoved
            @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!", b.pbThis, user.pbThis(true)))
            b.effects[PBEffects::Instructed] = true
            if b.pbCanChooseMove?(b.moves[idxMove], false)
                PBDebug.logonerr do
                    b.pbUseMoveSimple(b.lastMoveUsed, b.lastRegularMoveTarget, idxMove, false)
                end
                b.lastRoundMoved = oldLastRoundMoved
                @battle.pbJudge
                return if @battle.decision > 0
            end
            b.effects[PBEffects::Instructed] = false
        end
        # Dancer
        if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits > 0 &&
            !move.snatched && magicCoater < 0 && @battle.pbCheckGlobalAbility(:DANCER) &&
            move.danceMove?
            dancers = []
            @battle.pbPriority(true).each do |b|
                dancers.push(b) if b.index != user.index && b.hasActiveAbility?(:DANCER)
            end
            while dancers.length > 0
                nextUser = dancers.pop
                oldLastRoundMoved = nextUser.lastRoundMoved
                # NOTE: Petal Dance being used because of Dancer shouldn't lock the
                #       Dancer into using that move, and shouldn't contribute to its
                #       turn counter if it's already locked into Petal Dance.
                oldOutrage = nextUser.effects[PBEffects::Outrage]
                nextUser.effects[PBEffects::Outrage] += 1 if nextUser.effects[PBEffects::Outrage] > 0
                oldCurrentMove = nextUser.currentMove
                preTarget = choice[3]
                preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
                @battle.pbShowAbilitySplash(nextUser, true)
                @battle.pbHideAbilitySplash(nextUser)
                if !Battle::Scene::USE_ABILITY_SPLASH
                    @battle.pbDisplay(_INTL("{1} kept the dance going with {2}!",
                                            nextUser.pbThis, nextUser.abilityName))
                end
                nextUser.effects[PBEffects::Dancer] = true
                if nextUser.pbCanChooseMove?(move, false)
                    PBDebug.logonerr { nextUser.pbUseMoveSimple(move.id, preTarget) }
                    nextUser.lastRoundMoved = oldLastRoundMoved
                    nextUser.effects[PBEffects::Outrage] = oldOutrage
                    nextUser.currentMove = oldCurrentMove
                    @battle.pbJudge
                    return if @battle.decision > 0
                end
                nextUser.effects[PBEffects::Dancer] = false
            end
        end
    end
end
