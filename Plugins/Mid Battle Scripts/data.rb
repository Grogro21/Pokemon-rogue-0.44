#DON'T DELETE THIS LINE
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
  Init= Proc.new{|battle|
      battle.battlers[1].effects[PBEffects::BossProtect] = true
	  pbMessage("The opponent is immune to status moves and stat drop.")
      }
      
  Midlife= Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} is starting to get mad!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
      }
  
  Quartlife=Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} is in pain!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:ATTACK,2,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,2,battle.battlers[1])
      battle.battlers[0].pbLowerStatStage(:SPECIAL_ATTACK,2,battle.battlers[0])
      battle.battlers[0].pbLowerStatStage(:ATTACK,2,battle.battlers[0])
      }

  Enrage=Proc.new{|battle|
      battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
      pbMessage(_INTL("{1} rages!",battle.battlers[1].name))
      battle.battlers[0].pbResetStatStages
      battle.battlers[1].pbResetStatStages
      battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:ATTACK,6,battle.battlers[1])
      battle.battlers[1].pbRaiseStatStage(:SPEED,6,battle.battlers[1])
      }

######################Rattata########################
	Startrat=Proc.new{|battle|
		battle.scene.appearBar
		battle.scene.pbShowOpponent(0)
		pbMessage("\\bFear my top percentage Rattata!")
		battle.scene.pbHideOpponent
		battle.scene.disappearBar
		battle.pbAnimation(:FOCUSENERGY,battle.battlers[1],battle.battlers[0])
		battle.battlers[1].effects[PBEffects::FocusEnergy] = 99
		battle.battlers[1].effects[PBEffects::BossProtect] = true
		pbMessage("The opponent is immune to status and boosted their critical rate!")
		}
		
	Throtein=Proc.new{|battle|
		battle.scene.appearBar
		battle.scene.pbShowOpponent(0)
		pbMessage("\\bRattata, eat this Protein!")
		battle.scene.pbHideOpponent
		battle.scene.disappearBar
		if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
			battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
		end
		}
	
	Superdrug=Proc.new{|battle|
		battle.scene.appearBar
		battle.scene.pbShowOpponent(0)
		pbMessage("\\bYou force me to use my secret trick. Let's go, Super Drug!")
		battle.scene.pbHideOpponent
		battle.scene.disappearBar
		battle.battlers[1].pbRaiseStatStage(:ATTACK,2,battle.battlers[1]) if battle.battlers[1].pbCanRaiseStatStage?(:ATTACK)
		BattleScripting.set("turnStart#{battle.turnCount+2}",Proc.new{|battle|
			pbMessage("Joey gave too much Proteins to his perfect Rattata!")
			battle.battlers[1].pbConfuse(_INTL("{1} became confused due to the overdose!", battle.battlers[1].name))
			battle.battlers[1].pbLowerStatStage(:ATTACK,3,battle.battlers[1])
			}
		)}
		
##############Steal the Kecleons#######################
				
	Startkek=Proc.new{|battle|
		battle.scene.appearBar
		pbMessage("\\bGive it back immediately!")
		battle.scene.disappearBar
		pbMessage("The opponents are immune to status moves and stat drop.")
		battle.battlers[1].effects[PBEffects::BossProtect] = true
		battle.battlers[3].effects[PBEffects::BossProtect] = true
		battle.battlers[1].pbRaiseStatStage(:SPEED,2,battle.battlers[1])
		battle.battlers[3].pbRaiseStatStage(:SPEED,2,battle.battlers[3])
		for i in 0...25
			BattleScripting.set("turnStart#{battle.turnCount+i}",Proc.new{|battle|
				battle.scene.appearBar
				if battle.turnCount.remainder(2)==0
					if !battle.battlers[0].fainted?
					    if !battle.battlers[1].fainted?
							pbMessage("\\bTake this, thief!")
							battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
							choice=throwitem(battle.battlers[0])
							pbMessage(_INTL("Kecleon threw a {1} at your {2}!",battle.battlers[0].item.name,battle.battlers[0].name))
							battle.scene.disappearBar
						end
						if battle.battlers[0].fainted? 
							pbMessage("\\bTake this, thief!")
							battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[2])
							choice=throwitem(battle.battlers[2])
							pbMessage(_INTL("Kecleon threw a {1} at your {2}!",battle.battlers[2].item.name,battle.battlers[2].name))
							battle.scene.disappearBar
						end
					else
						pbMessage("\\bYou will pay!")
						battle.scene.disappearBar
						battle.battlers[3].pbRaiseStatStage(:ATTACK,3,battle.battlers[3])
						battle.battlers[3].pbRaiseStatStage(:SPECIAL_ATTACK,3,battle.battlers[3])
						battle.battlers[3].pbRaiseStatStage(:SPEED,3,battle.battlers[3])
					end
				else
					if !battle.battlers[3].fainted?
						if !battle.battlers[2].fainted? 
						pbMessage("\\bTake this, thief!")
						battle.pbAnimation(:FLING,battle.battlers[3],battle.battlers[2])
						choice=throwitem(battle.battlers[2])
						pbMessage(_INTL("Kecleon threw a {1} at your {2}!",battle.battlers[2].item.name,battle.battlers[2].name))
						battle.scene.disappearBar
						end
						if battle.battlers[2].fainted? 
							pbMessage("\\bTake this, thief!")
							battle.pbAnimation(:FLING,battle.battlers[3],battle.battlers[0])
							choice=throwitem(battle.battlers[0])
							pbMessage(_INTL("Kecleon threw a {1} at your {2}!",battle.battlers[0].item.name,battle.battlers[0].name))
							battle.scene.disappearBar
						end
					else
						pbMessage("\\bYou will pay!")
						battle.scene.disappearBar
						battle.battlers[1].pbRaiseStatStage(:ATTACK,3,battle.battlers[3])
						battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,3,battle.battlers[3])
						battle.battlers[1].pbRaiseStatStage(:SPEED,3,battle.battlers[3])
					end
				end	
			})
		end
		}
		
	Ragekek=Proc.new{|battle|
		battle.battlers[0].pbResetStatStages
		battle.battlers[2].pbResetStatStages
		if !battle.battlers[1].fainted?
			battle.pbAnimation(:HOWL,battle.battlers[1],battle.battlers[0])
			pbMessage(_INTL("{1} rages!",battle.battlers[1].name))
			battle.battlers[1].pbResetStatStages
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:ATTACK,6,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPEED,6,battle.battlers[1])
		end
		if !battle.battlers[3].fainted?
			battle.pbAnimation(:HOWL,battle.battlers[3],battle.battlers[0])
			pbMessage(_INTL("{1} rages!",battle.battlers[3].name))
			battle.battlers[3].pbResetStatStages
			battle.battlers[3].pbRaiseStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
			battle.battlers[3].pbRaiseStatStage(:ATTACK,6,battle.battlers[1])
			battle.battlers[3].pbRaiseStatStage(:SPEED,6,battle.battlers[1])
		end
        }
##############Face  the Unknown#######################
  Initghost= Proc.new{|battle|
	   pbMessage("The Ghost is immune to basic attacks. Find another ways to damage it!")
	   for i in 0...25
			BattleScripting.set("turnStart#{battle.turnCount+i}",Proc.new{|battle|
				if battle.battlers[1].item==:RINGTARGET && battle.battlers[1].ability==:WONDERGUARD
					pbMessage("The ghost is vulnerable!")
					battle.battlers[1].ability=:CURSEDBODY
				end
			})
	   end
      }
	  
	Gpoison=Proc.new{|battle|
		battle.scene.appearBar
		pbMessage("The ghost poisoned your Pokémon!")
		if battle.battlers[0].pbCanPoison?(battle.battlers[1],false)
			battle.battlers[0].pbPoison
			battle.scene.disappearBar
		else 
			pbMessage("It's too much...")
			battle.scene.disappearBar
			battle.pbLowerHP(battle.battlers[0],1)
		end	
		}
		
	Gsteal=Proc.new{|battle|
		battle.scene.appearBar
		pbMessage("\\rGive me all your items!")
		battle.pbAnimation(:KNOCKOFF,battle.battlers[1],battle.battlers[0])
		battle.battlers[1].item=battle.battlers[0].item
		battle.battlers[0].item=nil
		battle.scene.disappearBar
		}  
	Genrage=Proc.new{|battle|
		battle.scene.appearBar
		pbMessage("\\rENOUGH!")
		battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
		battle.pbLowerHP(battle.battlers[0],1)
		pbMessage("You are out of Pokémon!")
		battle.scene.disappearBar
		battle.decision=2
		} 
		
##############Jirachi the Wishmaker#######################
#$game_variables[46]=["More power!","Money!","Some new friends!","Good Items!","Learning cool moves!"]
	Jinit=Proc.new{|battle|
		battle.battlers[1].effects[PBEffects::BossProtect] = true
		battle.battlers[1].effects[PBEffects::Highhp] = true
		battle.scene.disappearDatabox
		battle.scene.appearBar
		pbMessage("\\c[9]I can grant you a first wish!")
		battle.scene.disappearBar
		battle.scene.appearDatabox
		cmd= battle.pbShowCommands("Tell me what you want!",$game_variables[46])
		wish1=$game_variables[46][cmd]
		$game_variables[47].push(wish1)
		wish2=""
		wish3=""
		$game_variables[46].delete_at(cmd) if cmd!=0
		battle.pbAnimation(:WISH,battle.battlers[1],battle.battlers[0])
		if wish1=="Some new friends!"
			pbMessage("\\c[9]Come, my friend!")
			battle.pbCallForHelp(battle.battlers[1])
			$PokemonTemp.excludedialogue=[2,3,4]
		end
		if wish1=="More power!"
			$player.badges[0] = true
			pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
			battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
		end
		if wish1=="Money!"
			$player.money+=3000
			pbMessage("\\c[9]Yeah, money!")
		end 
		if wish1=="Good Items!"
			pbMessage("\\c[9]Fly, my items!")
		end
		if wish1=="Learning cool moves!"
			battler=battle.battlers[1]
			pkmn=battler.pokemon
			pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE)   # Replaces current/total PP
			battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
			pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT)   # Replaces current/total PP
			battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
			pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET)   # Replaces current/total PP
			battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
			pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE)   # Replaces current/total PP
			battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
			battle.scene.disappearDatabox
			battle.scene.appearBar
			battle.pbCommonAnimation("MegaEvolution",battle.battlers[1],nil)
			pbMessage("\\c[9]Yeah! Cool moves!")
			battle.scene.disappearBar
			battle.scene.appearDatabox
		end
		for i in 0...20
			BattleScripting.set("turnStart#{battle.turnCount+i}",Proc.new{|battle|
				if battle.battlers[1].fainted?
					battle.decision=1
				end
				if $game_variables[47].include?("Money!") && !battle.battlers[1].fainted?
					battle.scene.disappearDatabox
					battle.scene.appearBar
					pbMessage("\\c[9]It's raining gold!")
					battle.pbAnimation(:PAYDAY,battle.battlers[1],battle.battlers[0])
					battle.field.effects[PBEffects::PayDay] += 1000
					battle.scene.disappearBar
					battle.scene.appearDatabox
					battle.pbLowerHP(battle.battlers[0],12)
					battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
					
				end
				if $game_variables[47].include?("Good Items!") && !battle.battlers[1].fainted?
					list=["Sharp Beak","Black Sludge","Flame Orb","Light Ball","Nevermelt Ice","Bright Powder","Smoke Ball","King's Rock"]
					item=list.sample
					battle.scene.disappearDatabox
					battle.scene.appearBar
					if item=="Sharp Beak"
						pbMessage("\\c[9]Oh! A Beak!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						battle.pbLowerHP(battle.battlers[0],16)
						pbMessage("The opposing Jirachi threw a Sharp Beak at you.")
					elsif item=="Black Sludge"
						pbMessage("\\c[9]Eek! Poison!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw some Black Sludge at you.")
						if battle.battlers[0].pbCanPoison?(battle.battlers[1],false) && rand(100)<50
							battle.battlers[0].pbPoison
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end						
					elsif item=="Flame Orb"
						pbMessage("\\c[9]Be careful! Hot potatoe!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw a Flame Orb at you.")
						if battle.battlers[0].pbCanBurn?(battle.battlers[1],false) && rand(100)<50
							battle.battlers[0].pbBurn
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end	
					elsif item=="Light Ball"
						pbMessage("\\c[9]Flashbang!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw a Light Ball at you.")
						if battle.battlers[0].pbCanParalyze?(battle.battlers[1],false) && rand(100)<50
							battle.battlers[0].pbParalyse
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end	
					elsif item=="Nevermelt Ice"
						pbMessage("\\c[9]Winter is coming!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw some Nevermeltice at you.")
						if battle.battlers[0].pbCanFreeze?(battle.battlers[1],false) && rand(100)<15
							battle.battlers[0].pbFreeze
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end	
					elsif item=="Bright Powder"
						pbMessage("\\c[9]Rest in peace!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw some Bright Powder at you.")
						if battle.battlers[0].pbCanSleep?(battle.battlers[1],false) && rand(100)<30
							battle.battlers[0].pbInflictStatus(:SLEEP, pbSleepDuration(1), nil)
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end	
					elsif item=="Smoke Ball"
						pbMessage("\\c[9]Ninja!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						pbMessage("The opposing Jirachi threw a Smoke Ball at you.")
						if battle.battlers[0].pbCanConfuse?(battle.battlers[1],false) && rand(100)<50
							battle.battlers[0].pbConfuse
						else 
							battle.pbLowerHP(battle.battlers[0],8)
						end	
					elsif item=="King's Rock"
						pbMessage("\\c[9]Make way for the king!")
						battle.pbAnimation(:FLING,battle.battlers[1],battle.battlers[0])
						battle.scene.disappearBar
						battle.scene.appearDatabox
						battle.pbLowerHP(battle.battlers[0],4)
						pbMessage("The opposing Jirachi threw a King's Rock at you.")
					else
						echoln item
					end
					
				end
			})
		end
		}
		
		Jhigh=Proc.new{|battle|
			BattleScripting.setInScript("turnEnd#{battle.turnCount}",:J2)
			}
		#######################################################
		J2=Proc.new{|battle|
		battle.battlers[1].effects[PBEffects::Highhp] = false
		battle.battlers[1].effects[PBEffects::Midhp] = true
		battle.scene.disappearDatabox
		battle.scene.appearBar
		pbMessage("\\c[9]I can grant you a second wish!")
		battle.scene.disappearBar
		battle.scene.appearDatabox
		cmd= battle.pbShowCommands("Tell me what you want!",$game_variables[46])
		wish2=$game_variables[46][cmd]
		$game_variables[47].push(wish2)
		$game_variables[46].delete_at(cmd) if cmd!=0
		battle.pbAnimation(:WISH,battle.battlers[1],battle.battlers[0])
		if wish2=="Money!"
			pbMessage("\\c[9]Yeah, money!")
			$player.money+=2000
		end
		if wish2=="Good Items!"
			pbMessage("\\c[9]Fly, my items!")
		end
		if wish2=="Some new friends!"
			pbMessage("\\c[9]Come, my friend!")
			battle.pbCallForHelp(battle.battlers[1])
		end
		if wish2=="More power!"
			$player.badges[1] = true
			pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
			battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
		end
		if wish2=="Learning cool moves!"
			battler=battle.battlers[1]
			pkmn=battler.pokemon
			pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE)   # Replaces current/total PP
			battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
			pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT)   # Replaces current/total PP
			battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
			pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET)   # Replaces current/total PP
			battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
			pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE)   # Replaces current/total PP
			battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
			battle.scene.disappearDatabox
			battle.scene.appearBar
			battle.pbCommonAnimation("MegaEvolution",battle.battlers[1],nil)
			pbMessage("\\c[9]Yeah! Cool moves!")
			battle.scene.disappearBar
			battle.scene.appearDatabox
		end
		}
		
		Jmid=Proc.new{|battle|
			BattleScripting.setInScript("turnEnd#{battle.turnCount}",:J3)
			}
		###############################################
		J3=Proc.new{|battle|
		battle.battlers[1].effects[PBEffects::Midhp] = false
		battle.battlers[1].effects[PBEffects::Lowhp] = true
		battle.scene.disappearDatabox
		battle.scene.appearBar
		pbMessage("\\c[9]I can grant you a third wish!")
		battle.scene.disappearBar
		battle.scene.appearDatabox
		cmd= battle.pbShowCommands("Tell me what you want!",$game_variables[46])
		wish3=$game_variables[46][cmd]
		$game_variables[47].push(wish3)
		$game_variables[46].delete_at(cmd) if cmd!=0
		battle.pbAnimation(:WISH,battle.battlers[1],battle.battlers[0])
		if wish3=="Money!"
			pbMessage("\\c[9]Yeah, money!")
			$player.money+=1000
		end
		if wish3=="Good Items!"
			pbMessage("\\c[9]Fly, my items!")
		end
		if wish3=="Some new friends!"
			pbMessage("\\c[9]Come, my friend!")
			battle.pbCallForHelp(battle.battlers[1])
		end
		if wish3=="More power!"
			$player.badges[2] = true
			pbMessage("\\c[9]A badge for you, a Stat Increase for me!")
			battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
			battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
		end
		if wish3=="Learning cool moves!"
			battler=battle.battlers[1]
			pkmn=battler.pokemon
			pkmn.moves[0] = Pokemon::Move.new(:DOOMESTDESIRE)   # Replaces current/total PP
			battler.moves[0] = Battle::Move.from_pokemon_move(battle, pkmn.moves[0])
			pkmn.moves[1] = Pokemon::Move.new(:PRESENTSIGHT)   # Replaces current/total PP
			battler.moves[1] = Battle::Move.from_pokemon_move(battle, pkmn.moves[1])
			pkmn.moves[2] = Pokemon::Move.new(:ENERGYROCKET)   # Replaces current/total PP
			battler.moves[2] = Battle::Move.from_pokemon_move(battle, pkmn.moves[2])
			pkmn.moves[3] = Pokemon::Move.new(:THUNDERSTRIKE)   # Replaces current/total PP
			battler.moves[3] = Battle::Move.from_pokemon_move(battle, pkmn.moves[3])
			battle.scene.disappearDatabox
			battle.scene.appearBar
			battle.pbCommonAnimation("MegaEvolution",battle.battlers[1],nil)
			pbMessage("\\c[9]Yeah! Cool moves!")
			battle.scene.disappearBar
			battle.scene.appearDatabox
		end
		}
####################################################
		Jlow=Proc.new{|battle|
			BattleScripting.setInScript("turnEnd#{battle.turnCount}",:J4)
			}
			
		J4=Proc.new{|battle|
			battle.battlers[1].effects[PBEffects::Lowhp] = false
			battle.scene.disappearDatabox
			battle.scene.appearBar
			pbMessage("\\c[9]A last wish?")
			cmd= battle.pbShowCommands("Tell me what you want!",["I want you!","Nothing, thanks."])
			if cmd==0
				battle.pbAnimation(:WISH,battle.battlers[1],battle.battlers[0])
				pbMessage("\\c[9]Yeahhhh!")
				pbWait(1)
				pbMessage("\\c[9]Wait... No no no no no!")
				battle.scene.disappearBar
				battle.scene.appearDatabox
				battle.battlers[1].pbLowerStatStage(:ATTACK,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPECIAL_DEFENSE,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPEED,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:DEFENSE,6,battle.battlers[1])
			elsif cmd==1
				pbMessage("\\c[9]But! You have to make a wish! Please...")
				battle.scene.disappearBar
				battle.scene.appearDatabox
				battle.battlers[1].pbLowerStatStage(:ATTACK,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPECIAL_ATTACK,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPECIAL_DEFENSE,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:SPEED,6,battle.battlers[1])
				battle.battlers[1].pbLowerStatStage(:DEFENSE,6,battle.battlers[1])
			end
			$game_variables[48]=cmd
			
			}

####################### Birds##################################################
	Binit=Proc.new{|battle|
		zapdos=battle.battlers[1]
		moltres=battle.battlers[3]
		articuno=battle.battlers[5]
		battle.battlers[1].effects[PBEffects::BossProtect] = true
		battle.battlers[3].effects[PBEffects::BossProtect] = true
		battle.battlers[5].effects[PBEffects::BossProtect] = true
		battle.battlers[1].effects[PBEffects::Lowhp] = true
		battle.battlers[3].effects[PBEffects::Lowhp] = true
		battle.battlers[5].effects[PBEffects::Lowhp] = true
		for i in 0...50
			BattleScripting.setInScript("turnStart#{i+1}",:Bstart)
		end
		}
	
	Bfaint=Proc.new{|battle|
		zapdos=battle.battlers[1]
		moltres=battle.battlers[3]
		articuno=battle.battlers[5]
		zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
		articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
		moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
		BattleScripting.setInScript("lowHPOpp",:Blow)
		} 
		
	
	Blow=Proc.new{|battle|
		BattleScripting.setInScript("faintedOpp",:Bfaint)
		$PokemonTemp.dialogueDone["faintedOpp"]=2
		zapdos=battle.battlers[1]
		moltres=battle.battlers[3]
		articuno=battle.battlers[5]
		if !zapdos.fainted?
			if moltres.fainted? && articuno.fainted?
				zapdos.effects[PBEffects::Lowhp] = false
			elsif zapdos.hp<=zapdos.totalhp/4+1 && zapdos.effects[PBEffects::Lowhp] == true && 
			((!moltres.fainted? && moltres.effects[PBEffects::Lowhp] == true) || moltres.fainted?) && 
			((!articuno.fainted? && articuno.effects[PBEffects::Lowhp] == true) || articuno.fainted?)
				zapdos.effects[PBEffects::Lowhp] = false
				pbMessage("Zapdos is in pain!")	
				articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
				moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
			end
		end
		if !articuno.fainted?
			if moltres.fainted? && zapdos.fainted?		#articuno low hp
				articuno.effects[PBEffects::Lowhp] = false
			elsif articuno.hp<=articuno.totalhp/4+1 && articuno.effects[PBEffects::Lowhp] == true && ((!moltres.fainted? && moltres.effects[PBEffects::Lowhp] == true) || moltres.fainted?) && 
			((!zapdos.fainted? && zapdos.effects[PBEffects::Lowhp] == true) || zapdos.fainted?)
				articuno.effects[PBEffects::Lowhp] = false
				pbMessage("Articuno is in pain!")	
				zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
				moltres.pbRecoverHP(moltres.totalhp) if !moltres.fainted?
			end
		end
		if !moltres.fainted?
			if articuno.fainted? && zapdos.fainted?		#moltres low hp
				moltres.effects[PBEffects::Lowhp] = false
			elsif moltres.hp<=moltres.totalhp/4+1 && moltres.effects[PBEffects::Lowhp] == true &&    
			((!articuno.fainted? && articuno.effects[PBEffects::Lowhp] == true) || articuno.fainted?) && 
			((!zapdos.fainted? && zapdos.effects[PBEffects::Lowhp] == true) || zapdos.fainted?)
				moltres.effects[PBEffects::Lowhp] = false
				pbMessage("Moltres is in pain!")	
				zapdos.pbRecoverHP(zapdos.totalhp) if !zapdos.fainted?
				articuno.pbRecoverHP(articuno.totalhp) if !articuno.fainted?
			end
		end
		}	
	Bstart=Proc.new{|battle|
		zapdos=battle.battlers[1]
		moltres=battle.battlers[3]
		articuno=battle.battlers[5]
		allies=[0,2,4]
		if !zapdos.fainted? #if zapdos low hp
			if battle.turnCount.remainder(3)==0 && !(moltres.fainted? && articuno.fainted?) #Zapdos basic ability
						pbMessage("A storm approaches.")	
						battle.pbStartWeather(zapdos,:Rain)
						battle.pbAnimation(:RAINDANCE,zapdos,battle.battlers[2])
						pbMessage("A lightning bolt strikes!")	
						battle.pbAnimation(:THUNDER,zapdos,battle.battlers[2])
						battle.pbStartTerrain(zapdos, :Electric)
						for i in allies
							if !battle.battlers[i].fainted?
								if rand(100)<30
									battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos,false)			#struck by the thunder
									battle.pbLowerHP(battle.battlers[i],8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
								else										#not struck directly
									battle.pbLowerHP(battle.battlers[i],16) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
								end
							end
						end
			elsif moltres.fainted? && articuno.fainted?	#zapdos ult
				battle.pbStartTerrain(zapdos, :Electric)
				battle.pbAnimation(:THUNDER,zapdos,battle.battlers[2])
				for i in allies
					if !battle.battlers[i].fainted?
						if battle.battlers[i].status==:PARALYSIS
							battle.pbLowerHP(battle.battlers[i],8)
							zapdos.pbRecoverHP(battle.battlers[i].totalhp/8) #zapdos drain 1/8th of the paralysed battler
						else
							if rand(100)<50
								battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos,false)			#struck by the thunder
								battle.pbLowerHP(battle.battlers[i],4) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							else										#not struck directly
								battle.pbLowerHP(battle.battlers[i],12) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							end	
						end
					end
				end
			end
			if moltres.fainted? && !articuno.fainted? #combo ice electric
				if battle.turnCount.remainder(3)==2
					battle.pbStartWeather(articuno,:Hail)
					battle.pbAnimation(:HAIL,articuno,battle.battlers[2])
					for i in allies	
						if !battle.battlers[i].fainted?
							if battle.battlers[i].status==:BURN
								battle.battlers[i].pbFreeze
							end
						end
					end
					pbMessage("The storm is powerful!")
					battle.pbAnimation(:THUNDER,zapdos,battle.battlers[2])
					for i in allies	
						if !battle.battlers[i].fainted?
							if rand(100)<10
								if battle.battlers[i].status==:FROZEN
									battle.pbLowerHP(battle.battlers[i],4)
								else
									battle.battlers[i].pbFreeze	if battle.battlers[i].pbCanFreeze?(articuno,false)		#struck by the thunder
									battle.pbLowerHP(battle.battlers[i],8) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
								end
							elsif rand(100)<30									#not struck directly
								battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos,false)
								battle.pbLowerHP(battle.battlers[i],8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							else
								battle.pbLowerHP(battle.battlers[i],12) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							end
						end
					end
				end
			elsif !moltres.fainted? && articuno.fainted? #combo fire electric
				if battle.turnCount.remainder(3)==1
					battle.pbStartWeather(moltres,:Sun)
					battle.pbAnimation(:SUNNYDAY,moltres,battle.battlers[2])
					for i in allies	
						if !battle.battlers[i].fainted?
							if battle.battlers[i].status==:FROZEN
								battle.battlers[i].pbBurn
							end
						end
					end
					battle.pbAnimation(:THUNDER,zapdos,battle.battlers[2])
					pbMessage("The thunder strikes!")
					for i in allies
						if !battle.battlers[i].fainted?
							if rand(100)<50
								battle.battlers[i].pbParalyze if battle.battlers[i].pbCanParalyze?(zapdos,false)			#struck by the thunder
								battle.pbLowerHP(battle.battlers[i],8) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							else										#not struck directly
								battle.pbLowerHP(battle.battlers[i],16) if !battle.battlers[i].pbHasType?(:ELECTRIC) && !battle.battlers[i].pbHasType?(:GROUND) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							end
						end
					end
				end
			end
		end
		if !articuno.fainted?
			if battle.turnCount.remainder(3)==1 && !(moltres.fainted? && zapdos.fainted?)  #Articuno basic ability
				battle.pbStartWeather(articuno,:Hail)
				battle.pbAnimation(:BLIZZARD,articuno,battle.battlers[2])
				pbMessage("You are freezing to death!")
				for i in allies
				    if !battle.battlers[i].fainted?
						if rand(100)<10
							if battle.battlers[i].status==:FROZEN
								battle.pbLowerHP(battle.battlers[i],4) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							else
								battle.battlers[i].pbFreeze	if battle.battlers[i].pbCanFreeze?(articuno,false)		
							end
						else
							battle.pbLowerHP(battle.battlers[i],10) if !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
						end
				    end
				end
			elsif moltres.fainted? && zapdos.fainted? #ulti articuno
				battle.pbStartWeather(articuno,:Hail)
				pbMessage("It's so cold... Your Pokémons are weakened.")
				articuno.pbOwnSide.effects[PBEffects::Rainbow] = 0
				battle.pbStartTerrain(articuno, :None)
				for i in allies
					if !battle.battlers[i].fainted?
						battle.battlers[i].pbLowerStatStage(:ATTACK,1,battle.battlers[i]) if articuno.pbCanLowerStatStage?(:ATTACK) && !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
						battle.battlers[i].pbLowerStatStage(:SPECIAL_ATTACK,1,battle.battlers[i]) if articuno.pbCanLowerStatStage?(:SPECIAL_ATTACK) && !battle.battlers[i].pbHasType?(:ICE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
					end
				end	
			end
			if !moltres.fainted? && zapdos.fainted? #combo ice fire
				if battle.turnCount.remainder(3)==0
					pbMessage("Oh! A rainbow!")
					articuno.pbOwnSide.effects[PBEffects::Rainbow] = 3
					battle.pbAnimation(:HEATWAVE,moltres,battle.battlers[2])
					pbMessage("Such temperature changes hurt your Pokémons!")
					for i in allies
						if !battle.battlers[i].fainted?
							battle.battlers[i].effects[PBEffects::ThroatChop] = 3
							if battle.battlers[i].status==:FROZEN
								battle.battlers[i].status==:None
								battle.pbLowerHP(battle.battlers[i],2)
							else
								battle.pbLowerHP(battle.battlers[i],10) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							end
						end
					end
				end		
			end 
		end
		if !moltres.fainted?		
			if battle.turnCount.remainder(3)==2 && !(articuno.fainted? && zapdos.fainted?)  #Moltres basic ability
				battle.pbStartWeather(moltres,:Sun)
				battle.pbAnimation(:HEATWAVE,moltres,battle.battlers[2])
				pbMessage("The sun shines bright!")
				for i in allies
				    if !battle.battlers[i].fainted?
							if battle.battlers[i].status==:FROZEN
								battle.battlers[i].status==:None
								battle.pbLowerHP(battle.battlers[i],4)
							end
				    end
				    if !battle.battlers[i].fainted?
						if rand(100)<10
							if battle.battlers[i].status==:BURN
								battle.pbLowerHP(battle.battlers[i],4) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
							else
								battle.battlers[i].pbBurn if battle.battlers[i].pbCanBurn?(battle.battlers[1],false)		
							end
						else
							battle.pbLowerHP(battle.battlers[i],10) if !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
						end
				    end
				end
			end
			if articuno.fainted? && zapdos.fainted?   #moltres ulti
				battle.pbStartWeather(moltres,:Sun)
				moltres.pbOwnSide.effects[PBEffects::Rainbow] = 3
				battle.pbAnimation(:HEATWAVE,moltres,battle.battlers[2])
				pbMessage("It's too hot here!")
				for i in allies
					if !battle.battlers[i].fainted?
						if battle.battlers[i].status==:FROZEN
							battle.battlers[i].status==:None
							battle.pbLowerHP(battle.battlers[i],4)
						else 
							battle.battlers[i].pbBurn if battle.battlers[i].pbCanBurn?(battle.battlers[1],false)
							battle.battlers[i].pbLowerStatStage(:SPECIAL_DEFENSE,2,battle.battlers[i]) if moltres.pbCanLowerStatStage?(:SPECIAL_DEFENSE) && !battle.battlers[i].pbHasType?(:FIRE) && !battle.battlers[i].inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
						end
					end							
				end
			end
		end
		}

####################Regi battle##########################################################
####################Regice battle##########################################################
Regicinit=Proc.new{|battle|
battle.battlers[1].effects[PBEffects::BossProtect] = true
pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
pbWait(1)
pbSEPlay("Battle damage normal")
pbMessage("The doors have just closed!")
battle.pbAnimation(:BLIZZARD,battle.battlers[1],battle.battlers[0])
pbMessage("The temperature drops!")
battle.pbStartWeather(battle.battlers[1],:Hail)
}

Regicexplode1=Proc.new{|battle|
pbMessage("\\bCRITICAL FAILURE!")
pbWait(1)
pbMessage("\\bSTARTING SAFETY PROCESS!")
}	

Regicexplode2=Proc.new{|battle|
pbMessage("\\bBOOOM!")
battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
battle.pbLowerHP(battle.battlers[0],1)
battle.pbLowerHP(battle.battlers[1],1)
}

####################Regirock battle##########################################################
Regirockinit=Proc.new{|battle|
battle.battlers[1].effects[PBEffects::BossProtect] = true
pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
pbWait(1)
pbSEPlay("Battle damage normal")
pbMessage("The doors have just closed!")
battle.pbAnimation(:STEALTHROCK,battle.battlers[1],battle.battlers[0])
battle.battlers[1].pbOpposingSide.effects[PBEffects::StealthRock]=true
pbMessage("Pointed rocks are scattered everywhere!")
}

Regirockexplode1=Proc.new{|battle|
pbMessage("\\bCRITICAL FAILURE!")
pbWait(1)
pbMessage("\\bSTARTING SAFETY PROCESS!")
}	

Regirockexplode2=Proc.new{|battle|
pbMessage("\\bBOOOM!")
battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
battle.pbLowerHP(battle.battlers[0],1)
battle.pbLowerHP(battle.battlers[1],1)
}

####################Registeel battle##########################################################
Registeelinit=Proc.new{|battle|
battle.battlers[1].effects[PBEffects::BossProtect] = true
pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
pbWait(1)
pbSEPlay("Battle damage normal")
pbMessage("The doors have just closed!")
battle.pbAnimation(:IRONDEFENSE,battle.battlers[1],battle.battlers[0])
battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1])
}

Registeelexplode1=Proc.new{|battle|
pbMessage("\\bCRITICAL FAILURE!")
pbWait(1)
pbMessage("\\bSTARTING SAFETY PROCESS!")
}	

Registeelexplode2=Proc.new{|battle|
pbMessage("\\bBOOOM!")
battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
battle.pbLowerHP(battle.battlers[0],1)
battle.pbLowerHP(battle.battlers[1],1)
}

####################Regieleki battle##########################################################
Regielekinit=Proc.new{|battle|
battle.battlers[1].effects[PBEffects::BossProtect] = true
pbMessage("\\bINTRUDER DETECTED! STARTING ERADICATION PROTOCOL!")
pbWait(1)
pbSEPlay("Battle damage normal")
pbMessage("The doors have just closed!")
battle.pbStartTerrain(battle.battlers[1], :Electric)
}

Regielekexplode1=Proc.new{|battle|
pbMessage("\\bCRITICAL FAILURE!")
pbWait(1)
pbMessage("\\bSTARTING SAFETY PROCESS!")
}	

Regielekexplode2=Proc.new{|battle|
pbMessage("\\bBOOOM!")
battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
battle.pbLowerHP(battle.battlers[0],1)
battle.pbLowerHP(battle.battlers[1],1)
}

####################Regidrago battle##########################################################
Regidragoinit=Proc.new{|battle|
battle.battlers[1].effects[PBEffects::BossProtect] = true
pbMessage("\\bINTRUDER DETECTED! STARTING ERADICATION PROTOCOL!")
pbWait(1)
pbSEPlay("Battle damage normal")
pbMessage("The doors have just closed!")
battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
}

Regidragoexplode1=Proc.new{|battle|
pbMessage("\\bCRITICAL FAILURE!")
pbWait(1)
pbMessage("\\bSTARTING SAFETY PROCESS!")
}	

Regidragoexplode2=Proc.new{|battle|
pbMessage("\\bBOOOM!")
battle.pbAnimation(:EXPLOSION,battle.battlers[1],battle.battlers[0])
battle.pbLowerHP(battle.battlers[0],1)
battle.pbLowerHP(battle.battlers[1],1)
}
####################Regigigas battle##########################################################
	Reginit=Proc.new{|battle|
		battle.battlers[1].effects[PBEffects::BossProtect] = true
		battle.battlers[1].effects[PBEffects::Lowhp] = true
		pbMessage("\\bINTRUDER DETECTED! INITIATING CONTAINMENT PROTOCOL!")
		battle.pbAnimation(:EARTHQUAKE,battle.battlers[1],battle.battlers[0])
		battle.pbAnimation(:STEALTHROCK,battle.battlers[1],battle.battlers[0])
		battle.battlers[1].pbOpposingSide.effects[PBEffects::StealthRock]=true
		pbMessage("Pointed rocks are scattered everywhere!")
		pbWait(1)
		pbMessage("\\rThe guardian looks too strong for you... You better run!")
		$game_variables[56]=rand(3)   #layout version
		$game_variables[55]=[0,2]
		$game_variables[57]=nil
		$PokemonTemp.excludedialogue=[3]  #exclude summoned mons from lowlife dialogues
		for i in 0...50
			BattleScripting.setInScript("turnStart#{i+1}",:Regturn)
			BattleScripting.setInScript("turnEnd#{i}",:Choiceroom)
		end
		}
		
	Regturn=Proc.new{|battle|
		if rand(100)<50
			pbMessage("Regigigas picked up a big rock!")
			$game_switches[77]=true
		else
			$game_switches[77]=false
		end
		regilist=pbGet(71)
		if battle.turnCount.remainder(3)==1
			pbMessage("\\bCALLING REINFORCEMENTS!")
			if regilist!=[]
				species=regilist.sample()
				regilist.delete(species)
				battle.pbCallally(battle.battlers[1],species,60)
			else
				pbMessage("\\bFIRING MY LASER!")
				battle.pbAnimation(:HYPERBEAM,battle.battlers[1],battle.battlers[0])
				battle.pbLowerHP(battle.battlers[0],3)
				battle.pbLowerHP(battle.battlers[2],3)
			end
		end
	}
	
	Choiceroom=Proc.new{|battle|
	b=baseimage($game_variables[55])
	base=b[0]
	exit=b[1]
	if $game_variables[69].include?("Left")
		imageleft="left"
	else
		imageleft="void"
	end
	if $game_variables[69].include?("Up")
		imageup="up"
	else
		imageup="void"
	end
	if $game_variables[69].include?("Right")
		imageright="right"
	else
		imageright="void"
	end
	if $game_variables[69].include?("Down")
		imagedown="down"
	else
		imagedown="void"
	end
	if $game_variables[55].include?("exit") 
		exit="exit"
	else
		exit="void"
	end
	battle.scene.appearsprite([base,imageup,imageright,imagedown,imageleft,exit])
	#pbMessage("\\f"+$game_variables[55].to_s+"You are here.\\wt[60]")
		if $game_variables[55].include?("exit")
			battle.scene.pbRecall(0)
			battle.scene.pbRecall(2)
			pbMessage("\\rYou reached the exit! Well played!")
			battle.decision=3
		end
		pbMessage("\\f"+$game_variables[55].to_s+"You are here.\\wt[60]")			
		cmd= battle.pbShowCommands("Which direction are you chosing?",pbGet(69))
		battle.scene.disappearsprite
		move=pbGet(69)[cmd]	#direction chosen
		$game_variables[55]=movement(move,$game_variables[55])	#changing coord
		pbSEPlay("Door exit")
		if $game_switches[77]
			pbMessage("Regigigas is throwing his rock!")
			if move==$game_variables[57]
				battle.pbAnimation(:ROCKTHROW,battle.battlers[3],battle.battlers[0])
				battle.pbLowerHP(battle.battlers[0],2)
				battle.pbLowerHP(battle.battlers[2],2)
			else
			pbMessage("But it missed!")
			end
			$game_switches[77]=false
		end
		$game_variables[57]=move
		if battle.battlers[3]!=nil
		  if battle.turnCount.remainder(3)==0 && !battle.battlers[3].fainted?
			pbMessage("\\bINITIATING SELF-DESTRUCT PROTOCOL!")
			battle.pbAnimation(:EXPLOSION,battle.battlers[3],battle.battlers[0])
			battle.pbLowerHP(battle.battlers[3],1)
			battle.pbLowerHP(battle.battlers[2],1.5)
			battle.pbLowerHP(battle.battlers[0],1.5)
		  end
		end
	}

###############Mewtwo############################################################
Mewtwoinit=Proc.new{|battle|
		battle.battlers[0].effects[PBEffects::BossProtect] = true
		battle.battlers[0].effects[PBEffects::Midhp] = true
		battle.battlers[0].effects[PBEffects::MagnetRise] = 50
		pbMessage("You are levitating!")
		for i in 0...50
			if rand(100)<20
				BattleScripting.setInScript("turnEnd#{i}",:MewtwoRockthrow)
			else
				BattleScripting.setInScript("turnEnd#{i}",:MewtwoPsywave)
			end
		end

		
	}

MewtwoPsywave=Proc.new{|battle|
		battle.pbAnimation(:PSYWAVE,battle.battlers[0],battle.battlers[1])
		pbMessage("You radiate psychic energy!")
		dmg=rand(3,11)
		battle.pbLowerHP(battle.battlers[1],dmg)
		if rand(100)<10
			battle.battlers[1].pbConfuse if pbCanConfuse?(battle.battlers[1],false)
		end
	}

MewtwoRockthrow=Proc.new{|battle|
	battle.pbAnimation(:FUTURESIGHT,battle.battlers[0],battle.battlers[1])
	battle.pbAnimation(:ROCKTHROW,battle.battlers[0],battle.battlers[1])
	battle.pbLowerHP(battle.battlers[1],4)
	}
Mewtwomid=Proc.new{|battle|
	battle.pbAnimation(:GROWL,battle.battlers[0],battle.battlers[1])
	battle.battlers[0].effects[PBEffects::MagnetRise] = 0
	pbMessage("You can't keep levitating.")
	battle.pbStartTerrain(battle.battlers[0], :Psychic)
	battle.battlers[0].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[0])
	battle.battlers[0].effects[PBEffects::Midhp] = false
	
	}
##############Test######################################################
	Lmusic=Proc.new{|battle|
		 pbBGMPlay("Surfing")
		}
	Tlast=Proc.new{|battle|
		 pbMessage("Last poke!")
		}
	Trand=Proc.new{|battle|
		 pbMessage("Random!")
		}
	Tinit=Proc.new{|battle|
		battle.battlers[1].effects[PBEffects::Midhp] = true
		}
	Tlow=Proc.new{|battle|
			battle.battlers[1].effects[PBEffects::Midhp] = false
			pbMessage("Vulnerable!")
		}
	Tdamage=Proc.new{|battle|
		pbMessage("Bim!")
		battle.pbLowerHP(battle.battlers[0],4) 
		}
	Tform=Proc.new{|battle|
		pbBGMPlay("Surfing")
		battle.scene.appearBar
		battle.pbCommonAnimation("MegaEvolution",battle.battlers[1],nil)
		battle.battlers[1].pbChangeForm(1,"idc")
		battle.battlers[1].name="BIG BOY" #if you need to change their name, you can
		pbMessage("The boss reached their final form!")
		battle.scene.pbRefresh
		battle.scene.disappearBar
		}
	Tcall=Proc.new{|battle|
		battle.pbCallForHelp(battle.battlers[1])
		}
		
	Nmove=Proc.new{|battle|
		$PokemonTemp.nextturnmoves=[nil,nil,nil,[1,0],nil,nil,0]
		}
	Faint2=Proc.new{|battle|
		pbMessage("Shloubidouf!")
		}
# DONT DELETE THIS END
end