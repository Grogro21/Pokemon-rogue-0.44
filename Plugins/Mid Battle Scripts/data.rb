# DON'T DELETE THIS LINE
module DialogueModule

    # Format to add new stuff here
    # Name = data
    #
    # To set in a script command
    # BattleScripting.setInScript("condition",:Name)
    # The ":" is important

    #  Joey_TurnStart0 = {"text"=>"Hello","bar"=>true}
    #  BattleScripting.set("turnStart0",:Joey_TurnStart0)

    ##############Custom#########################################################################################
    ##############General########################################################################################
    Init = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("The opponent is immune to status moves and stat drop.")
    }

    Midlife = Proc.new { |battle|
        battle.pbAnimation(:HOWL, battle.battlers[1], battle.battlers[0])
        pbMessage(_INTL("{1} is starting to get mad!", battle.battlers[1].name))
        battle.battlers[0].pbResetStatStages
        battle.battlers[1].pbResetStatStages
        battle.battlers[1].pbRaiseStatStage(:ATTACK, 1, battle.battlers[1])
        battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[1])
    }

    Quartlife = Proc.new { |battle|
        battle.pbAnimation(:HOWL, battle.battlers[1], battle.battlers[0])
        pbMessage(_INTL("{1} is in pain!", battle.battlers[1].name))
        battle.battlers[0].pbResetStatStages
        battle.battlers[1].pbResetStatStages
        battle.battlers[1].pbRaiseStatStage(:ATTACK, 2, battle.battlers[1])
        battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 2, battle.battlers[1])
        battle.battlers[0].pbLowerStatStage(:SPECIAL_ATTACK, 2, battle.battlers[0])
        battle.battlers[0].pbLowerStatStage(:ATTACK, 2, battle.battlers[0])
    }

    Enrage = Proc.new { |battle|
        battle.pbAnimation(:HOWL, battle.battlers[1], battle.battlers[0])
        pbMessage(_INTL("{1} rages!", battle.battlers[1].name))
        battle.battlers[0].pbResetStatStages
        battle.battlers[1].pbResetStatStages
        battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 6, battle.battlers[1])
        battle.battlers[1].pbRaiseStatStage(:ATTACK, 6, battle.battlers[1])
        battle.battlers[1].pbRaiseStatStage(:SPEED, 6, battle.battlers[1])
    }

    ######################Rattata########################
    Startrat = Proc.new { |battle|
        battle.scene.appearBar
        battle.scene.pbShowOpponent(0)
        pbMessage("\\bFear my top percentage Rattata!")
        battle.scene.pbHideOpponent
        battle.scene.disappearBar
        battle.pbAnimation(:FOCUSENERGY, battle.battlers[1], battle.battlers[0])
        battle.battlers[1].effects[PBEffects::FocusEnergy] = 99
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("The opponent is immune to status and boosted their critical rate!")
    }

    Throtein = Proc.new { |battle|
        battle.scene.appearBar
        battle.scene.pbShowOpponent(0)
        pbMessage("\\bRattata, eat this Protein!")
        battle.scene.pbHideOpponent
        battle.scene.disappearBar
        if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
            battle.battlers[1].pbRaiseStatStage(:ATTACK, 1, battle.battlers[1])
        end
    }

    Superdrug = Proc.new { |battle|
        battle.scene.appearBar
        battle.scene.pbShowOpponent(0)
        pbMessage("\\bYou force me to use my secret trick. Let's go, Super Drug!")
        battle.scene.pbHideOpponent
        battle.scene.disappearBar
        battle.battlers[1].pbRaiseStatStage(:ATTACK, 2, battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
        BattleScripting.set("turnStart#{battle.turnCount + 2}", Proc.new { |battle|
            pbMessage("Joey gave too much Proteins to his perfect Rattata!")
            battle.battlers[1].pbConfuse(_INTL("{1} became confused due to the overdose!", battle.battlers[1].name))
            battle.battlers[1].pbLowerStatStage(:ATTACK, 3, battle.battlers[1])
        }
        ) }

    ##############Steal the Kecleons#######################

    Startkek = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bGive it back immediately!")
        battle.scene.disappearBar
        pbMessage("The opponents are immune to status moves and stat drop.")
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        battle.battlers[3].effects[PBEffects::BossProtect] = true
        battle.battlers[1].pbRaiseStatStage(:SPEED, 2, battle.battlers[1])
        battle.battlers[3].pbRaiseStatStage(:SPEED, 2, battle.battlers[3])
        for i in 0...25
            BattleScripting.set("turnStart#{battle.turnCount + i}", Proc.new { |battle|
                battle.scene.appearBar
                if battle.turnCount.remainder(2) == 0
                    if !battle.battlers[0].fainted?
                        if !battle.battlers[1].fainted?
                            pbMessage("\\bTake this, thief!")
                            battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                            choice = battle.throwitem(battle.battlers[0])
                            pbMessage(_INTL("Kecleon threw a {1} at your {2}!", battle.battlers[0].item.name, battle.battlers[0].name))
                            battle.scene.disappearBar
                        else
                            pbMessage("\\bTake this, thief!")
                            battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[2])
                            choice = battle.throwitem(battle.battlers[2])
                            pbMessage(_INTL("Kecleon threw a {1} at your {2}!", battle.battlers[2].item.name, battle.battlers[2].name))
                            battle.scene.disappearBar
                        end
                    else
                        pbMessage("\\bYou will pay!")
                        battle.scene.disappearBar
                        battle.battlers[3].pbRaiseStatStage(:ATTACK, 3, battle.battlers[3])
                        battle.battlers[3].pbRaiseStatStage(:SPECIAL_ATTACK, 3, battle.battlers[3])
                        battle.battlers[3].pbRaiseStatStage(:SPEED, 3, battle.battlers[3])
                    end
                else
                    if !battle.battlers[3].fainted?
                        if !battle.battlers[2].fainted?
                            pbMessage("\\bTake this, thief!")
                            battle.pbAnimation(:FLING, battle.battlers[3], battle.battlers[2])
                            choice = battle.throwitem(battle.battlers[2])
                            pbMessage(_INTL("Kecleon threw a {1} at your {2}!", battle.battlers[2].item.name, battle.battlers[2].name))
                            battle.scene.disappearBar
                        else
                            pbMessage("\\bTake this, thief!")
                            battle.pbAnimation(:FLING, battle.battlers[3], battle.battlers[0])
                            choice = battle.throwitem(battle.battlers[0])
                            pbMessage(_INTL("Kecleon threw a {1} at your {2}!", battle.battlers[0].item.name, battle.battlers[0].name))
                            battle.scene.disappearBar
                        end
                    else
                        pbMessage("\\bYou will pay!")
                        battle.scene.disappearBar
                        battle.battlers[1].pbRaiseStatStage(:ATTACK, 3, battle.battlers[3])
                        battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 3, battle.battlers[3])
                        battle.battlers[1].pbRaiseStatStage(:SPEED, 3, battle.battlers[3])
                    end
                end
            })
        end
    }

    Ragekek = Proc.new { |battle|
        battle.battlers[0].pbResetStatStages
        battle.battlers[2].pbResetStatStages
        if !battle.battlers[1].fainted?
            battle.pbAnimation(:HOWL, battle.battlers[1], battle.battlers[0])
            pbMessage(_INTL("{1} rages!", battle.battlers[1].name))
            battle.battlers[1].pbResetStatStages
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPEED, 6, battle.battlers[1])
        end
        if !battle.battlers[3].fainted?
            battle.pbAnimation(:HOWL, battle.battlers[3], battle.battlers[0])
            pbMessage(_INTL("{1} rages!", battle.battlers[3].name))
            battle.battlers[3].pbResetStatStages
            battle.battlers[3].pbRaiseStatStage(:SPECIAL_ATTACK, 6, battle.battlers[1])
            battle.battlers[3].pbRaiseStatStage(:ATTACK, 6, battle.battlers[1])
            battle.battlers[3].pbRaiseStatStage(:SPEED, 6, battle.battlers[1])
        end
    }
    ##############Face  the Unknown#######################
    Initghost = Proc.new { |battle|
        pbMessage("The Ghost is immune to basic attacks. Find another ways to damage it!")
        for i in 0...25
            BattleScripting.set("turnStart#{battle.turnCount + i}", Proc.new { |battle|
                if battle.battlers[1].item == :RINGTARGET && battle.battlers[1].ability == :WONDERGUARD
                    pbMessage("The ghost is vulnerable!")
                    battle.battlers[1].ability = :CURSEDBODY
                end
            })
        end
    }

    Gpoison = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("The ghost poisoned your Pokémon!")
        if battle.battlers[0].pbCanPoison?(battle.battlers[1], false)
            battle.battlers[0].pbPoison
            battle.scene.disappearBar
        else
            pbMessage("It's too much...")
            battle.scene.disappearBar
            battle.pbLowerHP(battle.battlers[0], 1)
        end
    }

    Gsteal = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\rGive me all your items!")
        battle.pbAnimation(:KNOCKOFF, battle.battlers[1], battle.battlers[0])
        battle.battlers[1].item = battle.battlers[0].item
        battle.battlers[0].item = nil
        battle.scene.disappearBar
    }
    Genrage = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\rENOUGH!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[0], 1)
        pbMessage("You are out of Pokémon!")
        battle.scene.disappearBar
        battle.decision = 2
    }

    ##############Jirachi the Wishmaker#######################
    #$game_variables[46]=["More power!","Money!","Some new friends!","Good Items!","Learning cool moves!"]
    Jinit = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        battle.battlers[1].effects[PBEffects::Highhp] = true
        battle.scene.disappearDatabox
        battle.scene.appearBar
        pbMessage("\\c[9]I can grant you a first wish!")
        battle.scene.disappearBar
        battle.scene.appearDatabox
        cmd = battle.pbShowCommands("Tell me what you want!", $game_variables[46])
        wish1 = $game_variables[46][cmd]
        $game_variables[47].push(wish1)
        wish2 = ""
        wish3 = ""
        $game_variables[46].delete_at(cmd) if cmd != 0
        battle.pbAnimation(:WISH, battle.battlers[1], battle.battlers[0])
        if wish1 == "Some new friends!"
            pbMessage("\\c[9]Come, my friend!")
            battle.pbCallForHelp(battle.battlers[1])
            $PokemonTemp.excludedialogue = [2, 3, 4]
        end
        if wish1 == "More power!"
            $player.badges[0] = true
            pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
            battle.battlers[1].pbRaiseStatStage(:ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPEED, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:DEFENSE, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battle.battlers[1])
        end
        if wish1 == "Money!"
            $player.money += 3000
            pbMessage("\\c[9]Yeah, money!")
        end
        if wish1 == "Good Items!"
            pbMessage("\\c[9]Fly, my items!")
        end
        if wish1 == "Learning cool moves!"
            battler = battle.battlers[1]
            pkmn = battler.pokemon
            pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE) # Replaces current/total PP
            battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
            pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT) # Replaces current/total PP
            battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
            pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET) # Replaces current/total PP
            battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
            pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE) # Replaces current/total PP
            battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
            battle.scene.disappearDatabox
            battle.scene.appearBar
            battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
            pbMessage("\\c[9]Yeah! Cool moves!")
            battle.scene.disappearBar
            battle.scene.appearDatabox
        end
        for i in 0...20
            BattleScripting.set("turnStart#{battle.turnCount + i}", Proc.new { |battle|
                if battle.battlers[1].fainted?
                    battle.decision = 1
                end
                if $game_variables[47].include?("Money!") && !battle.battlers[1].fainted?
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    pbMessage("\\c[9]It's raining gold!")
                    battle.pbAnimation(:PAYDAY, battle.battlers[1], battle.battlers[0])
                    battle.field.effects[PBEffects::PayDay] += 1000
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.pbLowerHP(battle.battlers[0], 12)
                    battle.pbDisplay(_INTL("Coins were scattered everywhere!"))

                end
                if $game_variables[47].include?("Good Items!") && !battle.battlers[1].fainted?
                    list = ["Sharp Beak", "Black Sludge", "Flame Orb", "Light Ball", "Nevermelt Ice", "Bright Powder", "Smoke Ball", "King's Rock"]
                    item = list.sample
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    if item == "Sharp Beak"
                        pbMessage("\\c[9]Oh! A Beak!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        battle.pbLowerHP(battle.battlers[0], 16)
                        pbMessage("The opposing Jirachi threw a Sharp Beak at you.")
                    elsif item == "Black Sludge"
                        pbMessage("\\c[9]Eek! Poison!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw some Black Sludge at you.")
                        if battle.battlers[0].pbCanPoison?(battle.battlers[1], false) && rand(100) < 50
                            battle.battlers[0].pbPoison
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "Flame Orb"
                        pbMessage("\\c[9]Be careful! Hot potatoe!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw a Flame Orb at you.")
                        if battle.battlers[0].pbCanBurn?(battle.battlers[1], false) && rand(100) < 50
                            battle.battlers[0].pbBurn
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "Light Ball"
                        pbMessage("\\c[9]Flashbang!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw a Light Ball at you.")
                        if battle.battlers[0].pbCanParalyze?(battle.battlers[1], false) && rand(100) < 50
                            battle.battlers[0].pbParalyze
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "Nevermelt Ice"
                        pbMessage("\\c[9]Winter is coming!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw some Nevermeltice at you.")
                        if battle.battlers[0].pbCanFreeze?(battle.battlers[1], false) && rand(100) < 15
                            battle.battlers[0].pbFreeze
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "Bright Powder"
                        pbMessage("\\c[9]Rest in peace!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw some Bright Powder at you.")
                        if battle.battlers[0].pbCanSleep?(battle.battlers[1], false) && rand(100) < 30
                            battle.battlers[0].pbInflictStatus(:SLEEP, pbSleepDuration(1), nil)
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "Smoke Ball"
                        pbMessage("\\c[9]Ninja!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        pbMessage("The opposing Jirachi threw a Smoke Ball at you.")
                        if battle.battlers[0].pbCanConfuse?(battle.battlers[1], false) && rand(100) < 50
                            battle.battlers[0].pbConfuse
                        else
                            battle.pbLowerHP(battle.battlers[0], 8)
                        end
                    elsif item == "King's Rock"
                        pbMessage("\\c[9]Make way for the king!")
                        battle.pbAnimation(:FLING, battle.battlers[1], battle.battlers[0])
                        battle.scene.disappearBar
                        battle.scene.appearDatabox
                        battle.pbLowerHP(battle.battlers[0], 4)
                        pbMessage("The opposing Jirachi threw a King's Rock at you.")
                    else
                        echoln item
                    end

                end
            })
        end
    }

    Jhigh = Proc.new { |battle|
        BattleScripting.setInScript("turnEnd#{battle.turnCount}", :J2)
    }
    #######################################################
    J2 = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::Highhp] = false
        battle.battlers[1].effects[PBEffects::Midhp] = true
        battle.scene.disappearDatabox
        battle.scene.appearBar
        pbMessage("\\c[9]I can grant you a second wish!")
        battle.scene.disappearBar
        battle.scene.appearDatabox
        cmd = battle.pbShowCommands("Tell me what you want!", $game_variables[46])
        wish2 = $game_variables[46][cmd]
        $game_variables[47].push(wish2)
        $game_variables[46].delete_at(cmd) if cmd != 0
        battle.pbAnimation(:WISH, battle.battlers[1], battle.battlers[0])
        if wish2 == "Money!"
            pbMessage("\\c[9]Yeah, money!")
            $player.money += 2000
        end
        if wish2 == "Good Items!"
            pbMessage("\\c[9]Fly, my items!")
        end
        if wish2 == "Some new friends!"
            pbMessage("\\c[9]Come, my friend!")
            battle.pbCallForHelp(battle.battlers[1])
        end
        if wish2 == "More power!"
            $player.badges[1] = true
            pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
            battle.battlers[1].pbRaiseStatStage(:ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPEED, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:DEFENSE, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battle.battlers[1])
        end
        if wish2 == "Learning cool moves!"
            battler = battle.battlers[1]
            pkmn = battler.pokemon
            pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE) # Replaces current/total PP
            battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
            pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT) # Replaces current/total PP
            battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
            pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET) # Replaces current/total PP
            battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
            pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE) # Replaces current/total PP
            battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
            battle.scene.disappearDatabox
            battle.scene.appearBar
            battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
            pbMessage("\\c[9]Yeah! Cool moves!")
            battle.scene.disappearBar
            battle.scene.appearDatabox
        end
    }

    Jmid = Proc.new { |battle|
        BattleScripting.setInScript("turnEnd#{battle.turnCount}", :J3)
    }
    ###############################################
    J3 = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::Midhp] = false
        battle.battlers[1].effects[PBEffects::Lowhp] = true
        battle.scene.disappearDatabox
        battle.scene.appearBar
        pbMessage("\\c[9]I can grant you a third wish!")
        battle.scene.disappearBar
        battle.scene.appearDatabox
        cmd = battle.pbShowCommands("Tell me what you want!", $game_variables[46])
        wish3 = $game_variables[46][cmd]
        $game_variables[47].push(wish3)
        $game_variables[46].delete_at(cmd) if cmd != 0
        battle.pbAnimation(:WISH, battle.battlers[1], battle.battlers[0])
        if wish3 == "Money!"
            pbMessage("\\c[9]Yeah, money!")
            $player.money += 1000
        end
        if wish3 == "Good Items!"
            pbMessage("\\c[9]Fly, my items!")
        end
        if wish3 == "Some new friends!"
            pbMessage("\\c[9]Come, my friend!")
            battle.pbCallForHelp(battle.battlers[1])
        end
        if wish3 == "More power!"
            $player.badges[2] = true
            pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
            battle.battlers[1].pbRaiseStatStage(:ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPEED, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:DEFENSE, 1, battle.battlers[1])
            battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battle.battlers[1])
        end
        if wish3 == "Learning cool moves!"
            battler = battle.battlers[1]
            pkmn = battler.pokemon
            pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE) # Replaces current/total PP
            battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
            pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT) # Replaces current/total PP
            battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
            pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET) # Replaces current/total PP
            battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
            pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE) # Replaces current/total PP
            battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
            battle.scene.disappearDatabox
            battle.scene.appearBar
            battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
            pbMessage("\\c[9]Yeah! Cool moves!")
            battle.scene.disappearBar
            battle.scene.appearDatabox
        end
    }
    ####################################################
    Jlow = Proc.new { |battle|
        BattleScripting.setInScript("turnEnd#{battle.turnCount}", :J4)
    }

    J4 = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::Lowhp] = false
        battle.scene.disappearDatabox
        battle.scene.appearBar
        pbMessage("\\c[9]A last wish?")
        cmd = battle.pbShowCommands("Tell me what you want!", ["I want you!", "Nothing, thanks."])
        if cmd == 0
            battle.pbAnimation(:WISH, battle.battlers[1], battle.battlers[0])
            pbMessage("\\c[9]Yeahhhh!")
            pbWait(1)
            pbMessage("\\c[9]Wait... No no no no no!")
            battle.scene.disappearBar
            battle.scene.appearDatabox
            battle.battlers[1].pbLowerStatStage(:ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPECIAL_DEFENSE, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPEED, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:DEFENSE, 6, battle.battlers[1])
        elsif cmd == 1
            pbMessage("\\c[9]But! You have to make a wish! Please...")
            battle.scene.disappearBar
            battle.scene.appearDatabox
            battle.battlers[1].pbLowerStatStage(:ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPECIAL_DEFENSE, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:SPEED, 6, battle.battlers[1])
            battle.battlers[1].pbLowerStatStage(:DEFENSE, 6, battle.battlers[1])
        end
        $game_variables[48] = cmd

    }

    ####################### Birds##################################################
    Binit = Proc.new { |battle|
        zapdos = battle.battlers[1]
        moltres = battle.battlers[3]
        articuno = battle.battlers[5]
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        battle.battlers[3].effects[PBEffects::BossProtect] = true
        battle.battlers[5].effects[PBEffects::BossProtect] = true
        battle.battlers[1].effects[PBEffects::Lowhp] = true
        battle.battlers[3].effects[PBEffects::Lowhp] = true
        battle.battlers[5].effects[PBEffects::Lowhp] = true
        for i in 0...50
            BattleScripting.setInScript("turnStart#{i + 1}", :Bstart)
        end
    }

    Bfaint = Proc.new { |battle|
        battle.scene.appearBar
        zapdos = battle.battlers[1]
        moltres = battle.battlers[3]
        articuno = battle.battlers[5]
        zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
        articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
        moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
        battle.scene.disappearBar
        BattleScripting.setInScript("lowHPOpp", :Blow)
    }

    Blow = Proc.new { |battle|
        battle.scene.appearBar
        BattleScripting.setInScript("faintedOpp", :Bfaint)
        $PokemonTemp.dialogueDone["faintedOpp"] = 2
        zapdos = battle.battlers[1]
        moltres = battle.battlers[3]
        articuno = battle.battlers[5]
        if !zapdos.fainted?
            if moltres.fainted? && articuno.fainted?
                zapdos.effects[PBEffects::Lowhp] = false
            elsif zapdos.hp <= zapdos.totalhp / 4 + 1 && zapdos.effects[PBEffects::Lowhp] == true &&
                ((!moltres.fainted? && moltres.effects[PBEffects::Lowhp] == true) || moltres.fainted?) &&
                ((!articuno.fainted? && articuno.effects[PBEffects::Lowhp] == true) || articuno.fainted?)
                zapdos.effects[PBEffects::Lowhp] = false
                pbMessage("Zapdos is in pain!")
                articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
                moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
            end
        end
        if !articuno.fainted?
            if moltres.fainted? && zapdos.fainted? # articuno low hp
                articuno.effects[PBEffects::Lowhp] = false
            elsif articuno.hp <= articuno.totalhp / 4 + 1 && articuno.effects[PBEffects::Lowhp] == true && ((!moltres.fainted? && moltres.effects[PBEffects::Lowhp] == true) || moltres.fainted?) &&
                ((!zapdos.fainted? && zapdos.effects[PBEffects::Lowhp] == true) || zapdos.fainted?)
                articuno.effects[PBEffects::Lowhp] = false
                pbMessage("Articuno is in pain!")
                zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
                moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
            end
        end
        if !moltres.fainted?
            if articuno.fainted? && zapdos.fainted? # moltres low hp
                moltres.effects[PBEffects::Lowhp] = false
            elsif moltres.hp <= moltres.totalhp / 4 + 1 && moltres.effects[PBEffects::Lowhp] == true &&
                ((!articuno.fainted? && articuno.effects[PBEffects::Lowhp] == true) || articuno.fainted?) &&
                ((!zapdos.fainted? && zapdos.effects[PBEffects::Lowhp] == true) || zapdos.fainted?)
                moltres.effects[PBEffects::Lowhp] = false
                pbMessage("Moltres is in pain!")
                zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
                articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
            end
        end
        battle.scene.disappearBar
    }
    Bstart = Proc.new { |battle|
        battle.scene.appearBar
        zapdos = battle.battlers[1]
        moltres = battle.battlers[3]
        articuno = battle.battlers[5]
        allies = [0, 2, 4]
        if !zapdos.fainted? # if zapdos low hp
            if battle.turnCount.remainder(3) == 0 && !(moltres.fainted? && articuno.fainted?) # Zapdos basic ability
                pbMessage("A storm approaches.")
                battle.pbStartWeather(zapdos, :Rain)
                battle.pbAnimation(:RAINDANCE, zapdos, battle.battlers[2])
                pbMessage("A lightning bolt strikes!")
                battle.pbAnimation(:THUNDER, zapdos, battle.battlers[2])
                battle.pbStartTerrain(zapdos, :Electric)
                for i in allies
                    if !battle.battlers[i].fainted?
                        if rand(100) < 30
                            battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos, false) # struck by the thunder
                            battle.pbLowerHP(battle.battlers[i], 8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                    "TwoTurnAttackInvulnerableUnderwater")
                        else
                            # not struck directly
                            battle.pbLowerHP(battle.battlers[i], 16) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                     "TwoTurnAttackInvulnerableUnderwater")
                        end
                    end
                end
            elsif moltres.fainted? && articuno.fainted? # zapdos ult
                battle.pbStartTerrain(zapdos, :Electric)
                battle.pbAnimation(:THUNDER, zapdos, battle.battlers[2])
                for i in allies
                    if !battle.battlers[i].fainted?
                        if battle.battlers[i].status == :PARALYSIS
                            battle.pbLowerHP(battle.battlers[i], 8)
                            zapdos.pbRecoverHP(battle.battlers[i].totalhp / 8) # zapdos drain 1/8th of the paralysed battler
                        else
                            if rand(100) < 50
                                battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos, false) # struck by the thunder
                                battle.pbLowerHP(battle.battlers[i], 4) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                        "TwoTurnAttackInvulnerableUnderwater")
                            else
                                # not struck directly
                                battle.pbLowerHP(battle.battlers[i], 12) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                         "TwoTurnAttackInvulnerableUnderwater")
                            end
                        end
                    end
                end
            end
            if moltres.fainted? && !articuno.fainted? # combo ice electric
                if battle.turnCount.remainder(3) == 2
                    battle.pbStartWeather(articuno, :Hail)
                    battle.pbAnimation(:HAIL, articuno, battle.battlers[2])
                    for i in allies
                        if !battle.battlers[i].fainted?
                            if battle.battlers[i].status == :BURN
                                battle.battlers[i].pbFreeze
                            end
                        end
                    end
                    pbMessage("The storm is powerful!")
                    battle.pbAnimation(:THUNDER, zapdos, battle.battlers[2])
                    for i in allies
                        if !battle.battlers[i].fainted?
                            if rand(100) < 10
                                if battle.battlers[i].status == :FROZEN
                                    battle.pbLowerHP(battle.battlers[i], 4)
                                else
                                    battle.battlers[i].pbFreeze if battle.battlers[i].pbCanFreeze?(articuno, false) # struck by the thunder
                                    battle.pbLowerHP(battle.battlers[i], 8) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                            "TwoTurnAttackInvulnerableUnderwater")
                                end
                            elsif rand(100) < 30 # not struck directly
                                battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos, false)
                                battle.pbLowerHP(battle.battlers[i], 8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                        "TwoTurnAttackInvulnerableUnderwater")
                            else
                                battle.pbLowerHP(battle.battlers[i], 12) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                         "TwoTurnAttackInvulnerableUnderwater")
                            end
                        end
                    end
                end
            elsif !moltres.fainted? && articuno.fainted? # combo fire electric
                if battle.turnCount.remainder(3) == 1
                    battle.pbStartWeather(moltres, :Sun)
                    battle.pbAnimation(:SUNNYDAY, moltres, battle.battlers[2])
                    for i in allies
                        if !battle.battlers[i].fainted?
                            if battle.battlers[i].status == :FROZEN
                                battle.battlers[i].pbBurn
                            end
                        end
                    end
                    battle.pbAnimation(:THUNDER, zapdos, battle.battlers[2])
                    pbMessage("The thunder strikes!")
                    for i in allies
                        if !battle.battlers[i].fainted?
                            if rand(100) < 50
                                battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos, false) # struck by the thunder
                                battle.pbLowerHP(battle.battlers[i], 8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                        "TwoTurnAttackInvulnerableUnderwater")
                            else
                                # not struck directly
                                battle.pbLowerHP(battle.battlers[i], 16) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                         "TwoTurnAttackInvulnerableUnderwater")
                            end
                        end
                    end
                end
            end
        end
        if !articuno.fainted?
            if battle.turnCount.remainder(3) == 1 && !(moltres.fainted? && zapdos.fainted?) # Articuno basic ability
                battle.pbStartWeather(articuno, :Hail)
                battle.pbAnimation(:BLIZZARD, articuno, battle.battlers[2])
                pbMessage("You are freezing to death!")
                for i in allies
                    if !battle.battlers[i].fainted?
                        if rand(100) < 10
                            if battle.battlers[i].status == :FROZEN
                                battle.pbLowerHP(battle.battlers[i], 4) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                        "TwoTurnAttackInvulnerableUnderwater")
                            else
                                battle.battlers[i].pbFreeze if battle.battlers[i].pbCanFreeze?(articuno, false)
                            end
                        else
                            battle.pbLowerHP(battle.battlers[i], 10) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                     "TwoTurnAttackInvulnerableUnderwater")
                        end
                    end
                end
            elsif moltres.fainted? && zapdos.fainted? # ulti articuno
                battle.pbStartWeather(articuno, :Hail)
                pbMessage("It's so cold... Your Pokémons are weakened.")
                articuno.pbOwnSide.effects[PBEffects::Rainbow] = 0
                battle.pbStartTerrain(articuno, :None)
                for i in allies
                    if !battle.battlers[i].fainted?
                        battle.battlers[i].pbLowerStatStage(:ATTACK, 1, battle.battlers[i]) if articuno.pbCanLowerStatStage?(:ATTACK) && !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                                      "TwoTurnAttackInvulnerableUnderwater")
                        battle.battlers[i].pbLowerStatStage(:SPECIAL_ATTACK, 1, battle.battlers[i]) if articuno.pbCanLowerStatStage?(:SPECIAL_ATTACK) && !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                                                      "TwoTurnAttackInvulnerableUnderwater")
                    end
                end
            end
            if !moltres.fainted? && zapdos.fainted? # combo ice fire
                if battle.turnCount.remainder(3) == 0
                    pbMessage("Oh! A rainbow!")
                    articuno.pbOwnSide.effects[PBEffects::Rainbow] = 3
                    battle.pbAnimation(:HEATWAVE, moltres, battle.battlers[2])
                    pbMessage("Such temperature changes hurt your Pokémons!")
                    for i in allies
                        if !battle.battlers[i].fainted?
                            battle.battlers[i].effects[PBEffects::ThroatChop] = 3
                            if battle.battlers[i].status == :FROZEN
                                battle.battlers[i].status == :None
                                battle.pbLowerHP(battle.battlers[i], 2)
                            else
                                battle.pbLowerHP(battle.battlers[i], 10) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                          "TwoTurnAttackInvulnerableUnderwater")
                            end
                        end
                    end
                end
            end
        end
        if !moltres.fainted?
            if battle.turnCount.remainder(3) == 2 && !(articuno.fainted? && zapdos.fainted?) # Moltres basic ability
                battle.pbStartWeather(moltres, :Sun)
                battle.pbAnimation(:HEATWAVE, moltres, battle.battlers[2])
                pbMessage("The sun shines bright!")
                for i in allies
                    if !battle.battlers[i].fainted?
                        if battle.battlers[i].status == :FROZEN
                            battle.battlers[i].status == :None
                            battle.pbLowerHP(battle.battlers[i], 4)
                        end
                    end
                    if !battle.battlers[i].fainted?
                        if rand(100) < 10
                            if battle.battlers[i].status == :BURN
                                battle.pbLowerHP(battle.battlers[i], 4) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                         "TwoTurnAttackInvulnerableUnderwater")
                            else
                                battle.battlers[i].pbBurn if battle.battlers[i].pbCanBurn?(battle.battlers[1], false)
                            end
                        else
                            battle.pbLowerHP(battle.battlers[i], 10) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                      "TwoTurnAttackInvulnerableUnderwater")
                        end
                    end
                end
            end
            if articuno.fainted? && zapdos.fainted? # moltres ulti
                battle.pbStartWeather(moltres, :Sun)
                moltres.pbOwnSide.effects[PBEffects::Rainbow] = 3
                battle.pbAnimation(:HEATWAVE, moltres, battle.battlers[2])
                pbMessage("It's too hot here!")
                for i in allies
                    if !battle.battlers[i].fainted?
                        if battle.battlers[i].status == :FROZEN
                            battle.battlers[i].status == :None
                            battle.pbLowerHP(battle.battlers[i], 4)
                        else
                            battle.battlers[i].pbBurn if battle.battlers[i].pbCanBurn?(battle.battlers[1], false)
                            battle.battlers[i].pbLowerStatStage(:SPECIAL_DEFENSE, 2, battle.battlers[i]) if moltres.pbCanLowerStatStage?(:SPECIAL_DEFENSE) && !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                                                                                                                                                                                                                            "TwoTurnAttackInvulnerableUnderwater")
                        end
                    end
                end
            end
        end
        battle.scene.disappearBar
    }

    ####################Regi battle##########################################################
    ####################Regice battle##########################################################
    Regicinit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
        pbWait(1)
        pbSEPlay("Battle damage normal")
        pbMessage("The doors have just closed!")
        battle.pbAnimation(:BLIZZARD, battle.battlers[1], battle.battlers[0])
        pbMessage("The temperature drops!")
        battle.pbStartWeather(battle.battlers[1], :Hail)
        battle.scene.disappearBar
    }

    Regicexplode1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bCRITICAL FAILURE!")
        pbWait(1)
        pbMessage("\\bSTARTING SAFETY PROCESS!")
        battle.scene.disappearBar
    }

    Regicexplode2 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("BOOOM!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 1)
        battle.pbLowerHP(battle.battlers[0], 1)
        battle.decision = 1
        battle.scene.disappearBar
    }

    ####################Regirock battle##########################################################
    Regirockinit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
        pbWait(1)
        pbSEPlay("Battle damage normal")
        pbMessage("The doors have just closed!")
        battle.pbAnimation(:STEALTHROCK, battle.battlers[1], battle.battlers[0])
        battle.battlers[1].pbOpposingSide.effects[PBEffects::StealthRock] = true
        pbMessage("Pointed rocks are scattered everywhere!")
        battle.scene.disappearBar
    }

    Regirockexplode1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bCRITICAL FAILURE!")
        pbWait(1)
        pbMessage("\\bSTARTING SAFETY PROCESS!")
        battle.scene.disappearBar
    }

    Regirockexplode2 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("BOOOM!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 1)
        battle.pbLowerHP(battle.battlers[0], 1)
        battle.decision = 1
        battle.scene.disappearBar
    }

    ####################Registeel battle##########################################################
    Registeelinit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
        pbWait(1)
        pbSEPlay("Battle damage normal")
        pbMessage("The doors have just closed!")
        battle.pbAnimation(:IRONDEFENSE, battle.battlers[1], battle.battlers[0])
        battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battle.battlers[1])
        battle.scene.disappearBar
    }

    Registeelexplode1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bCRITICAL FAILURE!")
        pbWait(1)
        pbMessage("\\bSTARTING SAFETY PROCESS!")
        battle.scene.disappearBar
    }

    Registeelexplode2 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("BOOOM!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 1)
        battle.pbLowerHP(battle.battlers[0], 1)
        battle.decision = 1
        battle.scene.disappearBar
    }

    ####################Regieleki battle##########################################################
    Regielekinit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("\\bINTRUDER DETECTED! STARTING ERADICATION PROTOCOL!")
        pbWait(1)
        pbSEPlay("Battle damage normal")
        pbMessage("The doors have just closed!")
        battle.pbStartTerrain(battle.battlers[1], :Electric)
        battle.scene.disappearBar
    }

    Regielekexplode1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bCRITICAL FAILURE!")
        pbWait(1)
        pbMessage("\\bSTARTING SAFETY PROCESS!")
        battle.scene.disappearBar
    }

    Regielekexplode2 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("BOOOM!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 1)
        battle.pbLowerHP(battle.battlers[0], 1)
        battle.decision = 1
        battle.scene.disappearBar
    }

    ####################Regidrago battle##########################################################
    Regidragoinit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        pbMessage("\\bINTRUDER DETECTED! STARTING ERADICATION PROTOCOL!")
        pbWait(1)
        pbSEPlay("Battle damage normal")
        pbMessage("The doors have just closed!")
        battle.battlers[1].pbRaiseStatStage(:SPEED, 1, battle.battlers[1])
        battle.scene.disappearBar
    }

    Regidragoexplode1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("\\bCRITICAL FAILURE!")
        pbWait(1)
        pbMessage("\\bSTARTING SAFETY PROCESS!")
        battle.scene.disappearBar
    }

    Regidragoexplode2 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("BOOOM!")
        battle.pbAnimation(:EXPLOSION, battle.battlers[1], battle.battlers[0])
        battle.pbLowerHP(battle.battlers[1], 1)
        battle.pbLowerHP(battle.battlers[0], 1)
        battle.decision = 1
        battle.scene.disappearBar
    }
    ####################Regigigas battle##########################################################
    Reginit = Proc.new { |battle|
        battle.scene.appearBar
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        battle.battlers[1].effects[PBEffects::Lowhp] = true
        pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
        battle.pbAnimation(:EARTHQUAKE, battle.battlers[1], battle.battlers[0])
        battle.pbAnimation(:STEALTHROCK, battle.battlers[1], battle.battlers[0])
        battle.battlers[1].pbOpposingSide.effects[PBEffects::StealthRock] = true
        pbMessage("Pointed rocks are scattered everywhere!")
        pbWait(1)
        pbMessage("\\rThe guardian looks too strong for you... You better run! If you can remember where the exit is...")
        $game_variables[57] = nil
        $PokemonTemp.excludedialogue = [3] # exclude summoned mons from lowlife dialogues
        for i in 0...50
            BattleScripting.setInScript("turnStart#{i + 1}", :Regturn)
            BattleScripting.setInScript("turnEnd#{i}", :Choiceroom)
        end
        battle.scene.disappearBar
    }

    Regturn = Proc.new { |battle|
        battle.scene.appearBar
        if rand(100) < 50
            pbMessage("Regigigas picked up a big rock!")
            $game_switches[77] = true
        else
            $game_switches[77] = false
        end
        regilist = pbGet(71)
        if battle.turnCount.remainder(3) == 1
            pbMessage("\\bCALLING REINFORCEMENTS!")
            if regilist != []
                species = regilist.sample()
                regilist.delete(species)
                battle.pbCallally(battle.battlers[1], species, 60)
            else
                pbMessage("\\bFIRING MY LASER!")
                battle.pbAnimation(:HYPERBEAM, battle.battlers[1], battle.battlers[0])
                battle.pbLowerHP(battle.battlers[0], 4)
                battle.pbLowerHP(battle.battlers[2], 4)
            end
        end
        playerIdx = MathUtils.calcIdx(pbGet(63).size, pbGet(69))
        room = pbGet(63).rooms[playerIdx]
        ex = room.getImage()[1]
        if ex == "exit"
            battle.scene.pbRecall(0)
            battle.scene.pbRecall(2)
            pbMessage("\\rYou reached the exit! Well played!")
            battle.decision = 3
        end
        battle.scene.disappearBar

    }

    Choiceroom = Proc.new { |battle|
        playerIdx = MathUtils.calcIdx(pbGet(63).size, pbGet(69))
        room = pbGet(63).rooms[playerIdx]
        directions = room.doors
        b = room.getImage()
        base = b[0]
        ex = b[1]
        imageleft = !directions.include?("left") ? "left" : "void"
        imageup = !directions.include?("up") ? "up" : "void"
        imageright = !directions.include?("right") ? "right" : "void"
        imagedown = !directions.include?("down") ? "down" : "void"

        battle.scene.appearsprite([base, imageup, imageright, imagedown, imageleft, ex])
        cmd = battle.pbShowCommands("Which direction are you chosing?", directions)
        move = directions[cmd] # direction chosen
        battle.scene.disappearsprite([base, imageup, imageright, imagedown, imageleft, ex])
        battle.scene.appearBar
        $game_variables[69] = movement(move, $game_variables[69]) # changing coord
        pbSEPlay("Door exit")
        if $game_switches[77]
            pbMessage("Regigigas is throwing his rock!")
            if move == $game_variables[57]
                battle.pbAnimation(:ROCKTHROW, battle.battlers[3], battle.battlers[0])
                battle.pbLowerHP(battle.battlers[0], 2)
                battle.pbLowerHP(battle.battlers[2], 2)
            else
                pbMessage("But it missed!")
            end
            $game_switches[77] = false
        end
        $game_variables[57] = move
        if battle.battlers[3] != nil
            if !battle.battlers[3].fainted?
                if battle.turnCount.remainder(3) == 0 && !battle.battlers[3].fainted?
                    pbMessage("\\bINITIATING SELF-DESTRUCT PROTOCOL!")
                    battle.pbAnimation(:EXPLOSION, battle.battlers[3], battle.battlers[0])
                    battle.pbLowerHP(battle.battlers[3], 1)
                    battle.pbLowerHP(battle.battlers[2], 1.5)
                    battle.pbLowerHP(battle.battlers[0], 1.5)
                end
            end
        end
        battle.scene.disappearBar
    }

    ###############Mewtwo############################################################
    Mewtwoinit = Proc.new { |battle|
        battle.battlers[0].effects[PBEffects::BossProtect] = true
        battle.battlers[0].effects[PBEffects::Midhp] = true
        battle.battlers[0].effects[PBEffects::MagnetRise] = 50
        pbMessage("You are levitating!")
        for i in 0...50
            if rand(100) < 20
                BattleScripting.setInScript("turnEnd#{i}", :MewtwoRockthrow)
            else
                BattleScripting.setInScript("turnEnd#{i}", :MewtwoPsywave)
            end
        end
    }

    MewtwoPsywave = Proc.new { |battle|
        battle.scene.appearBar
        battle.pbAnimation(:PSYWAVE, battle.battlers[0], battle.battlers[1])
        pbMessage("You radiate psychic energy!")
        dmg = rand(3, 11)
        battle.pbLowerHP(battle.battlers[1], dmg) if !battle.battlers[1].fainted?
        battle.pbLowerHP(battle.battlers[3], dmg) if !battle.battlers[3].fainted?
        if rand(100) < 10 && !battle.battlers[1].fainted? && pbCanConfuse?(battle.battlers[1], false)
            battle.battlers[1].pbConfuse
        end
        if rand(100) < 10 && !battle.battlers[3].fainted? && pbCanConfuse?(battle.battlers[3], false)
            battle.battlers[3].pbConfuse
        end
        battle.scene.disappearBar
    }

    MewtwoRockthrow = Proc.new { |battle|
        battle.scene.appearBar
        battle.pbAnimation(:FUTURESIGHT, battle.battlers[0], battle.battlers[1])
        battle.pbAnimation(:ROCKTHROW, battle.battlers[0], battle.battlers[1])
        battle.pbLowerHP(battle.battlers[1], 4)
        if rand(100) < 20
            battle.battlers[1].pbParalyze if pbCanParalyze?(battle.battlers[1], false)
        end
        battle.scene.disappearBar
    }
    Mewtwomid = Proc.new { |battle|
        battle.scene.appearBar
        battle.pbAnimation(:GROWL, battle.battlers[0], battle.battlers[1])
        battle.battlers[0].effects[PBEffects::MagnetRise] = 0
        pbMessage("You can't keep levitating.")
        battle.pbStartTerrain(battle.battlers[0], :Psychic)
        battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[0])
        battle.battlers[0].effects[PBEffects::Midhp] = false
        battle.battlers[0].effects[PBEffects::Lowhp] = true
        battle.scene.disappearBar
    }

    Mewtwolow = Proc.new { |battle|
        battle.scene.appearBar
        battle.pbAnimation(:GROWL, battle.battlers[0], battle.battlers[1])
        pbMessage("Your pain is so high!")
        battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK, 1, battle.battlers[0])
        battle.battlers[0].effects[PBEffects::Lowhp] = false
        battle.battlers[0].effects[PBEffects::FocusEnergy] = 99
        battle.battlers[0].pbLowerStatStage(:DEFENSE, 2, battle.battlers[0])
        battle.battlers[0].pbLowerStatStage(:SPECIAL_DEFENSE, 2, battle.battlers[0])
        battle.scene.disappearBar

    }

    ##################ARCEUSE##########################################
    ArceusInit = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::BossProtect] = true
        BattleScripting.setInScript("turnEnd#{0}", :ArceusJ1)
    }

    ArceusJ1 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("Day 1, Arceus created the Earth.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battle.battlers[0].item = :EARTHPLATE
        battle.battlers[0].pbChangeForm(21, "")
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        pkmn.moves[1] = Pokemon::Move.new(:EARTHPOWER) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Ground, Rock and Steel types!")
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{1}", :ArceusJ2)
    }
    ArceusJ2 = Proc.new { |battle|
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        battle.scene.appearBar
        battle.pbStartWeather(battler, :Sun)
        pbMessage("At Day 2 came the light.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battler.item = :PIXIEPLATE
        battler.pbChangeForm(22, "")
        pkmn.moves[1] = Pokemon::Move.new(:MOONBLAST) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Fairy, Electric, Fire types!")
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{2}", :ArceusJ3)
    }

    ArceusJ3 = Proc.new { |battle|
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        battle.scene.appearBar
        battle.pbStartWeather(battler, :Rain)
        pbMessage("Day 3, too much water.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battler.item = :SPLASHPLATE
        battler.pbChangeForm(23, "")

        pkmn.moves[1] = Pokemon::Move.new(:HYDROPUMP) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Water and Ice types!")
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{3}", :ArceusJ4)

    }

    ArceusJ4 = Proc.new { |battle|
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        battle.scene.appearBar
        battle.pbStartTerrain(battler, :Grassy)
        pbMessage("Day 4, Arceus created life.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battler.item = :MEADOWPLATE
        battler.pbChangeForm(24, "")
        pkmn.moves[1] = Pokemon::Move.new(:ENERGYBALL) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Grass, Bug and Flying types!")
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{4}", :ArceusJ5)
    }

    ArceusJ5 = Proc.new { |battle|
        battle.scene.appearBar
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        battle.pbStartTerrain(battler, :Psychic)
        pbMessage("Day 5, Arceus added mind to matter.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battler.item = :MINDPLATE
        battler.pbChangeForm(25, "")
        pkmn.moves[1] = Pokemon::Move.new(:FUTURESIGHT) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Psychic, Fighting and Poison types!")
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{5}", :ArceusJ6)
    }

    ArceusJ6 = Proc.new { |battle|
        battle.scene.appearBar
        pbMessage("Humans are stupid so, at Day 6, Arceus created Death.")
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battle.battlers[0].item = :DREADPLATE
        battle.battlers[0].pbChangeForm(26, "")
        battler = battle.battlers[0]
        pkmn = battler.pokemon
        pkmn.moves[1] = Pokemon::Move.new(:BRUTALSWING) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained Dark and Ghost types!")
        battle.battler[0].effects[PBEffects::Curse] = true
        battle.pbAnimation(:CURSE, battle.battlers[1], battle.battlers[0])
        battle.scene.disappearBar
        BattleScripting.setInScript("turnEnd#{6}", :ArceusJ7)
    }

    ArceusJ7 = Proc.new { |battle|
        battler = battle.battlers[0]
        battle.scene.appearBar
        pbMessage("Then he slept during Day 7.")
        battler.pbSleepSelf(nil, 2)
        battle.field.terrain = :None
        pbMessage("The psychic energy vanished.")
        battle.scene.disappearBar
        battler.pbRecoverHP(battler.totalhp)
        BattleScripting.setInScript("turnEnd#{7}", :ArceusP2)
    }

    ArceusP2 = Proc.new { |battle|
        battle.scene.appearBar
        GameData::Species.play_cry_from_species(:GIRATINA)
        pbMessage("But Giratina betrayed them!")
        battler = battle.battlers[0]
        battler.item = :DRACOPLATE
        battler.pbChangeForm(19, "")
        pkmn = battler.pokemon
        pkmn.moves[1] = Pokemon::Move.new(:DRAGONCLAW) # Replaces current/total PP
        battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
        battle.scene.pbRefresh
        pbMessage("Arceus gained the Dragon Type. They reached their final form.")
        battle.scene.disappearBar

        BattleScripting.setInScript("turnEnd#{8}", :ArceusP2Buff)
    }

    ArceusP2Buff = Proc.new { |battle|
        battler = battle.battlers[0]

        case rand(100)
        when 0..30
            if battler.pbCanRaiseStatStage?(:SPEED)
                battler.pbRaiseStatStage(:SPEED, 2, battler)
            end
        when 31..40
        when 41..60
        when 61..80
        else
            # NOTHING
        end

        BattleScripting.setInScript("turnEnd#{battle.turnCount + 1}", :ArceusP2Buff)
    }
    ##############Test######################################################
    Lmusic = Proc.new { |battle|
        pbBGMPlay("Surfing")
    }
    Tlast = Proc.new { |battle|
        pbMessage("Last poke!")
    }
    Trand = Proc.new { |battle|
        pbMessage("Random!")
    }
    Tinit = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::Midhp] = true
    }
    Tlow = Proc.new { |battle|
        battle.battlers[1].effects[PBEffects::Midhp] = false
        pbMessage("Vulnerable!")
    }
    Tdamage = Proc.new { |battle|
        pbMessage("Bim!")
        battle.pbLowerHP(battle.battlers[0], 4)
    }
    Tform = Proc.new { |battle|
        pbBGMPlay("Surfing")
        battle.scene.appearBar
        battle.pbCommonAnimation("MegaEvolution", battle.battlers[1], nil)
        battle.battlers[1].pbChangeForm(1, "idc")
        battle.battlers[1].name = "BIG BOY" # if you need to change their name, you can
        pbMessage("The boss reached their final form!")
        battle.scene.pbRefresh
        battle.scene.disappearBar
    }
    Tcall = Proc.new { |battle|
        battle.pbCallForHelp(battle.battlers[1])
    }

    Nmove = Proc.new { |battle|
        $PokemonTemp.nextturnmoves = [nil, nil, nil, [1, 0], nil, nil, 0]
    }
    Faint2 = Proc.new { |battle|
        pbMessage("Shloubidouf!")
    }
    # DONT DELETE THIS END
end
