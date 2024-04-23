def starter(lvl)
	pkmn1=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
	pkmn2=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
	pkmn3=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
	if pkmn1==pkmn2
		pkmn2=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
	end
	if pkmn3==pkmn2 || pkmn3==pkmn1
		pkmn3=pbChooseRandomPokemon(nil,"suggested",nil,true,nil)
	end
	pk1= Pokemon.new(pkmn1,lvl)
	pk2= Pokemon.new(pkmn2,lvl)
	pk3= Pokemon.new(pkmn3,lvl)
	setNewStage(pk1)
	pk1.reset_moves
	pk1.calc_stats
	setNewStage(pk2)
	pk2.reset_moves
	pk2.calc_stats
	setNewStage(pk3)
	pk3.reset_moves
	pk3.calc_stats
	pbRandomform(pk1) 
	pbRandomform(pk2) 
	pbRandomform(pk3) 
	cmd=0
	cmd= pbMessage("Which Pokémon do you want?",[pkmn1.name,pkmn2.name,pkmn3.name],0,nil,0)
	if cmd==0
		pbAddPokemon(pk1)
	end
	if cmd==1
		pbAddPokemon(pk2)
	end
	if cmd==2
		pbAddPokemon(pk3)
	end
end

def choixpkmn(blacklist=nil,whitelist=nil,rarity="normal")
	pkmns=[pbChooseRandomPokemon(whitelist,"suggested",blacklist,false,nil),pbChooseRandomPokemon(whitelist,"suggested",blacklist,false,nil),pbChooseRandomPokemon(nil,"suggested",whitelist,false,nil),pbChooseRandomPokemon(whitelist,"suggested",blacklist,false,nil),pbChooseRandomPokemon(whitelist,"suggested",blacklist,false,nil)]
	if rarity=="normal"
		pkmn=pkmns.sample()
		pk=Pokemon.new(pkmn,$player.party[0].level)
		pbRandomform(pk) 
		setNewStage(pk)
		pk.reset_moves
		pk.calc_stats
		pbAddPokemon(pk)
	else
		cmd=0
		cmd= pbMessage("Which Pokémon do you want?",[pkmns[0].name,pkmns[1].name,pkmns[2].name],0,nil,0)			
		if cmd==0
				pk1= Pokemon.new(pkmns[0],$player.party[0].level)
				pbRandomform(pk1) 
				setNewStage(pk1)
				pk1.reset_moves
				pk1.calc_stats
				pbAddPokemon(pk1)
		end
		if cmd==1
				pk2= Pokemon.new(pkmns[1],$player.party[0].level)
				pbRandomform(pk2) 
				setNewStage(pk2)
				pk2.reset_moves
				pk2.calc_stats
				pbAddPokemon(pk2)
		end
		if cmd==2
				pk3= Pokemon.new(pkmns[2],$player.party[0].level)
				pbRandomform(pk3) 
				setNewStage(pk3)
				pk3.reset_moves
				pk3.calc_stats
				pbAddPokemon(pk3)
		end
	end
end

def pbRandomform(pkmn) 
  forms = [0]
  namelist=["Alolan","Galarian","Female","10%","Cloak","Kyurem",
		"Size","Unbound","Style","Midnight","Dusk","Low Key","Rider"]
  GameData::Species.each do |sp|
	next if sp.species != pkmn.species
	for j in namelist
		if sp.form_name!=nil
		  if sp.form_name.include? j
			forms.push(sp.form)
		  end
		end
	end
  end
  form = forms.sample
  pkmn.form = form
end

def canInflictStatus?(newStatus, move = nil, ignoreStatus = false)
    return false if fainted?
    # Already have that status problem
    if self.status == newStatus && !ignoreStatus
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus
      return false
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      hasImmuneType |= pbHasType?(:POISON)
      hasImmuneType |= pbHasType?(:STEEL)
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      return false
    end
    # Ability immunity
    immuneByAbility = false
    if Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
       immuneByAbility = true
    end
    if immuneByAbility
      return false
    end
    return true
end

def inflictStatus(newStatus, newStatusCount = 0, msg = nil, user = nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
end
  
def pbHasType?(type)
    return false if !type
    activeTypes = [self.types[0],self.types[1]]
    return activeTypes.include?(GameData::Type.get(type).id)
end
  
def randomstatus
	r=rand(100)
	if r<35	#poison 35%
		for pkmn in $player.party do
			if pkmn.canInflictStatus?(:POISON)
				if rand(100)<35
					pkmn.inflictStatus(:POISON,1)
				end
			end
		end
		pbFlash(Color.new(204, 0, 255, 255), 20)
		pbSEPlay("PRSFX- Toxic1")
		# pbMessage("Dusclops used Toxic!")
	elsif r<60 #paralysis 25%
		for pkmn in $player.party do
			if pkmn.canInflictStatus?(:PARALYSIS)
				if rand(100)<35
					pkmn.inflictStatus(:PARALYSIS)
				end
			end
		end
		pbFlash(Color.new(255, 255, 0, 255), 20)
		pbSEPlay("PRSFX- Thunder Wave")
		# pbMessage("Dusclops used Thunder Wave!")
	elsif r<80 #burn 20%
		for pkmn in $player.party do
			if pkmn.canInflictStatus?(:BURN)
				if rand(100)<20
					pkmn.inflictStatus(:BURN)
				end
			end
		end
		pbFlash(Color.new(255, 0, 0, 255), 20)
		pbSEPlay("PRSFX- Will O Wisp2")
		# pbMessage("Dusclops used Will-o-Wisp!")
	elsif r<90 #Sleep 10%
		for pkmn in $player.party do
			if pkmn.canInflictStatus?(:SLEEP)
				if rand(100)<15
					pkmn.inflictStatus(:SLEEP)
					pkmn.statusCount=2
				end
			end
		end
		pbFlash(Color.new(255, 0, 255, 255), 20)
		pbSEPlay("PRSFX- Hypnosis")
		# pbMessage("Dusclops used Hypnosis!")
	else #Freeze 10%
		for pkmn in $player.party do
			if pkmn.canInflictStatus?(:FREEZE)
				if rand(100)<10
					pkmn.inflictStatus(:FREEZE)
				end
			end
		end
		pbFlash(Color.new(0, 204, 255, 255), 20)
		pbSEPlay("PRSFX- Ice Beam")
		# pbMessage("Dusclops used Ice Beam!")
	end
end

def gettmlist
	itemlist=[]
	GameData::Item.each do |i|
			if (i.is_TM?	&&	!bag.has?(i.id))|| i.is_TR?
				itemlist.push(i.id)
			end
	end	
	return(itemlist)
end

def getrandomtm(itemlist=gettmlist)	
	item=itemlist.sample
	return(item)
end

def get_hm
	hm=[:CUTITEM,:ROCKSMASHITEM,:STRENGTHITEM,:SURFITEM,:WATERFALLITEM,:DIVEITEM]
	for item in hm
		if !$bag.has?(item)
			return item
		end
	end
end

def genreward(type,exclude=nil) 
	if type=="normal"
		reward=["status","potions","gold","item","berries","randpokemon"]
		reward.delete(exclude) if exclude!=nil #if you want to get 2 different results
		r=reward.sample
		if r=="status"
			return(["status",:FULLHEAL,1])
		elsif r=="potions"
			if $game_variables[36]<10
				return(["potions",:POTION,1])
			elsif $game_variables[36]<20
				return(["potions",:SUPERPOTION,1])
			elsif $game_variables[36]<40
				return(["potions",:HYPERPOTION,1])
			else
				return(["potions",:MAXPOTION,1])
			end
		elsif r=="gold"
			return(["gold",nil,1000+$game_variables[36]*100])
		elsif r=="item"
			item=[:AIRBALLOON,:BRIGHTPOWDER,:EVIOLITE,:FLOATSTONE,:DESTINYKNOT,:ROCKYHELMET,
			:ASSAULTVEST,:SAFETYGOGGLES,:PROTECTIVEPADS,:HEAVYDUTYBOOTS,:UTILITYUMBRELLA,
			:EJECTBUTTON,:EJECTPACK,:REDCARD,:SHEDSHELL,:SMOKEBALL,
			:CLEANSETAG,:CHOICEBAND,:CHOICESPECS,:CHOICESCARF,:HEATROCK,:DAMPROCK,:ICYROCK,
			:SMOOTHROCK,:TERRAINEXTENDER,:LIGHTCLAY,:BIGROOT,:BLACKSLUDGE,:LEFTOVERS,:SHELLBELL,
			:WHITEHERB,:POWERHERB,:ABSORBBULB,:CELLBATTERY,:LUMINOUSMOSS,:SNOWBALL,:WEAKNESSPOLICY,
			:BLUNDERPOLICY,:THROATSPRAY,:ROOMSERVICE,:ELECTRICSEED,:GRASSYSEED,:MISTYSEED,
			:PSYCHICSEED,:LIFEORB,:EXPERTBELT,:METRONOME,:MUSCLEBAND,:WISEGLASSES,:RAZORCLAW,
			:SCOPELENS,:WIDELENS,:ZOOMLENS,:KINGSROCK,:RAZORFANG,:LAGGINGTAIL,:QUICKCLAW,
			:FOCUSBAND,:FOCUSSASH,:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,:RINGTARGET,
			:LAXINCENSE,:FULLINCENSE,:SEAINCENSE,:ROSEINCENSE,:ODDINCENSE,:ROCKINCENSE,
			:CHARCOAL,:MYSTICWATER,:MAGNET,:MIRACLESEED,:NEVERMELTICE,:BLACKBELT,:POISONBARB,
			:SOFTSAND,:SHARPBEAK,:TWISTEDSPOON,:SILVERPOWDER,:HARDSTONE,:SPELLTAG,:DRAGONFANG,
			:BLACKGLASSES,:METALCOAT,:SILKSCARF,:FLAMEPLATE,:SPLASHPLATE,:ZAPPLATE,:MEADOWPLATE,
			:ICICLEPLATE,:FISTPLATE,:TOXICPLATE,:EARTHPLATE,:SKYPLATE,:MINDPLATE,:INSECTPLATE,
			:STONEPLATE,:SPOOKYPLATE,:DRACOPLATE,:DREADPLATE,:IRONPLATE,:PIXIEPLATE,:FIREGEM,
			:WATERGEM,:ELECTRICGEM,:GRASSGEM,:ICEGEM,:FIGHTINGGEM,:POISONGEM,:GROUNDGEM,:FLYINGGEM,
			:PSYCHICGEM,:BUGGEM,:ROCKGEM,:GHOSTGEM,:DRAGONGEM,:DARKGEM,:STEELGEM,:FAIRYGEM,
			:NORMALGEM,:LIGHTBALL,:THICKCLUB,:LEEK,:SOULDEW,:DEEPSEATOOTH,:DEEPSEASCALE,
			:PRISMSCALE,:OVALSTONE,:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:ICESTONE,
			:SHINYSTONE,:DAWNSTONE,:DUSKSTONE,:SUNSTONE,:MOONSTONE]
			return(["item",item.sample,1])
		elsif r=="randpokemon"
			return(["randpokemon",nil,1])
		else
			return(["berries",nil,1])
		end
	end
	if type=="rare"
		reward=["pokemon","potions","item","gold","mint","ppmax","hm","tm","bomb"]
		reward.delete(exclude) if exclude!=nil #if you want to get 2 different results
		r=reward.sample
		if r=="pokemon"
			return(["pokemon",nil,1])
		elsif r=="potions"
			return(["item",:FULLRESTORE,1])
		elsif r=="bomb"
			return(["item",:BOMB,1])
		elsif r=="item"
			item=[:EVIOLITE,:ROCKYHELMET,:ASSAULTVEST,:HEAVYDUTYBOOTS,:CHOICEBAND,
			:CHOICESCARF,:CHOICESPECS,:LEFTOVERS,:LIFEORB,:EXPERTBELT,:FOCUSSASH]
			return(["item",item.sample,1])
		elsif r=="gold"
			return(["gold",nil,1000+$game_variables[36]*200])
		elsif r=="mint"
			return(["mint",nil,1])
		elsif r=="hm"
			return(["hm",get_hm,1])
		elsif r=="tm"
			return(["tm",getrandomtm,1])
		else
			return(["ppmax",:PPMAX,1])
		end
	end
	if type=="event"
		r=rand(10)
		return(["event",nil,r])
	end
	if type=="boss"
		return(["boss","nothing",1])
	end
	if type=="secret"
		return(["secret",nil,1])
	end
end

def getreward(type=nil,item=nil,qty=1)
	if (type=="item" || type=="tm" || type=="hm" || type=="potions" || type=="status" || type=="ppmax")
		pbItemBall(item,qty)
	elsif type=="gold"
		$player.money+=qty
		pbMessage(_INTL("You got {1}$!",qty))
	elsif type=="randpokemon"
		whitelist=nil
		if $game_variables[45]<1  #à compléter quand les whitelist suivantes seront faites
			whitelist=Whitelistroute
		elsif $game_variables[45]<2
			whitelist=Whitelistforet
		elsif $game_variables[45]<3
			whitelist=Whitelistgrotte
		elsif $game_variables[45]<4
			whitelist=Whitelistile
		elsif $game_variables[45]<5
			whitelist=Whitelistruines
		elsif $game_variables[45]<6
			whitelist=Whitelistlabo
		end
		choixpkmn(nil,whitelist,rarity="normal")
	elsif type=="pokemon"
		whitelist=nil
		if $game_variables[45]<1  #à compléter quand les whitelist suivantes seront faites
			whitelist=Whitelistroute
		elsif $game_variables[45]<2
			whitelist=Whitelistforet
		elsif $game_variables[45]<3
			whitelist=Whitelistgrotte
		elsif $game_variables[45]<4
			whitelist=Whitelistile
		elsif $game_variables[45]<5
			whitelist=Whitelistruines
		elsif $game_variables[45]<6
			whitelist=Whitelistlabo
		end
		choixpkmn(nil,whitelist,rarity="rare")
	elsif type=="berries"
		pbItemBall(:SITRUSBERRY,qty)
		pbItemBall(:LUMBERRY,qty)
	elsif type=="mint"
		mint=[:LONELYMINT,:ADAMANTMINT,:NAUGHTYMINT,:BRAVEMINT,
		:BOLDMINT,:IMPISHMINT,:LAXMINT,:RELAXEDMINT,:MODESTMINT,
		:MILDMINT,:RASHMINT,:QUIETMINT,:CALMMINT,:GENTLEMINT,
		:CAREFULMINT,:SASSYMINT,:TIMIDMINT,:HASTYMINT,
		:JOLLYMINT,:NAIVEMINT,:SERIOUSMINT]
		for i in 0...qty
			pbItemBall(mint.sample)
		end
	elsif type=="secret"
		if $game_variables[45]<=4
			tier=["PU","PU","NU","NU","RU","UU"]
			order=tier.shuffle()
		elsif $game_variables[45]==5
			tier=["NU","NU","NU","RU","RU","UU"]
			order=tier.shuffle()
		elsif $game_variables[45]==6
			tier=["RU","RU","RU","RU","UU","UU"]
			order=tier.shuffle()
		elsif $game_variables[45]==7
			tier=["RU","RU","RU","UU","UU","OU"]
			order=tier.shuffle()
		elsif $game_variables[45]==8
			tier=["RU","UU","UU","UU","OU","OU"]
			order=tier.shuffle()
		else $game_variables[45]==9
			tier=["UU","UU","UU","OU","OU","OU"]
			order=tier.shuffle()
		end
		pk=genrandpkmn("Data/Rand_trainer/"+order[0]+".txt")
		pk.level=$player.party[0].level
		pbAddPokemon(pk)
	else
		echoln(type)
		pbItemBall(:PPUP,qty)
	end
end

def gen_type_rooms
	if $game_variables[36].remainder(5)!=0
		t=rand(100)
		if t<5  #event
			type="event"
		elsif t<20 #rare 
			type="rare"
		else #common
			type="normal"
		end
	else
		if $game_variables[36].remainder(10)==0
			type="boss"
		else 
			type="event"
		end
	end
	if rand(100)<50
		trainer=true
	else
		trainer=false
	end
	return([type,trainer])
end

def display_next_room #bientot obsolete
	$game_variables[37]=$game_variables[38]
	#current room

	$game_variables[38]= gen_type_rooms
	#next room left
	nextroom=genreward($game_variables[38][0])
	$game_variables[40]=nextroom
	if nextroom!=nil
		if nextroom[0]=="item"
			$game_variables[42]=1
		elsif nextroom[0]=="tm"
			$game_variables[42]=2
		elsif nextroom[0]=="hm"
			$game_variables[42]=3
		elsif nextroom[0]=="potions"
			$game_variables[42]=4
		elsif nextroom[0]=="status"
			$game_variables[42]=5
		elsif nextroom[0]=="ppmax"
			$game_variables[42]=6
		elsif nextroom[0]=="gold"
			$game_variables[42]=7
		elsif nextroom[0]=="pokemon" || nextroom[0]=="randpokemon"
			$game_variables[42]=8
		elsif nextroom[0]=="berries"
			$game_variables[42]=9
		elsif nextroom[0]=="mint"
			$game_variables[42]=10
		elsif nextroom[0]=="event"
			$game_variables[42]=11
		else 
			$game_variables[42]=12 #boss
		end
	else 
		$game_variables[42]=12 #boss
	end
	#next room right
	if nextroom != nil
		nextroom=genreward($game_variables[38][0],nextroom[0])
	end
	$game_variables[41]=nextroom
	if nextroom!=nil
		if nextroom[0]=="item"
			$game_variables[43]=1
		elsif nextroom[0]=="tm"
			$game_variables[43]=2
		elsif nextroom[0]=="hm"
			$game_variables[43]=3
		elsif nextroom[0]=="potions"
			$game_variables[43]=4
		elsif nextroom[0]=="status"
			$game_variables[43]=5
		elsif nextroom[0]=="ppmax"
			$game_variables[43]=6
		elsif nextroom[0]=="gold"
			$game_variables[43]=7
		elsif nextroom[0]=="pokemon" || nextroom[0]=="randpokemon"
			$game_variables[43]=8
		elsif nextroom[0]=="berries"
			$game_variables[43]=9
		elsif nextroom[0]=="mint"
			$game_variables[43]=10
		elsif nextroom[0]=="event"
			$game_variables[43]=11
		else 
			$game_variables[43]=12 #boss
		end
	else 
		$game_variables[43]=12 #boss
	end
	Graphics.update
end

def pkmnmerchant
	cmd=10
	cmd= pbMessage("\\GDo you want to buy one of my Pokémons?",["Porygon 2000$","Dratini 10000$","Dreepy 7000$","Grookey 5000$","Honedge 5000$","Dracozolt 7000$","Hawlucha 5000$","Lucario 10000$","Beldum 5000$","Leave"],10,nil,0)
	if cmd==0
		if $player.money>=2000
			pbAddPokemon(:PORYGON,$player.party[0].level)
			$player.money-=2000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==1
		if $player.money>=10000
			pkmn = Pokemon.new(:DRATINI,$player.party[0].level)
			pkmn.ability_index=2
			$player.money-=10000
			pbAddPokemon(pkmn)
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==2
		if $player.money>=7000
			pbAddPokemon(:DREEPY,$player.party[0].level)
			$player.money-=7000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==3
		if $player.money>=5000
			pkmn = Pokemon.new(:GROOKEY, $player.party[0].level)
			pkmn.learn_move(:GRASSYGLIDE)
			pkmn.ability_index=2
			pbAddPokemon(pkmn)
			$player.money-=5000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==4
		if $player.money>=5000
			pbAddPokemon(:HONEDGE,$player.party[0].level)
			$player.money-=5000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==5
		if $player.money>=7000
			pbAddPokemon(:DRACOZOLT,$player.party[0].level)
			$player.money-=7000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==6
		if $player.money>=5000
			pkmn = Pokemon.new(:HAWLUCHA,$player.party[0].level)
			pkmn.ability_index=1
			pbAddPokemon(pkmn)
			$player.money-=5000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==7
		if $player.money>=10000
			pbAddPokemon(:LUCARIO,$player.party[0].level)
			$player.money-=10000
		else
			pbMessage("You don't have enough money.")
		end
	elsif cmd==8
		if $player.money>=5000
			pbAddPokemon(:BELDUM,$player.party[0].level)
			$player.money-=5000
		else
			pbMessage("You don't have enough money.")
		end
	else
		pbMessage("Come back if you want to buy a Pokémon")
	end
end


def pbChangeLevel(pkmn, new_level)
  if new_level > pkmn.level
    # DemICE edit
    evpool=80+pkmn.level*8
    evpool=(evpool.div(4))*4      
    evpool=512 if evpool>512    
    evcap=40+pkmn.level*4
    evcap=(evcap.div(4))*4
    evcap=252 if evcap>252
    increment=4*(new_level-pkmn.level)
    evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 	
		evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
    evarray=[]
    GameData::Stat.each_main do |s|
      evarray.push(pkmn.ev[s.id])
    end
    if evsum>0 && evpool>evsum && evarray.max<evcap && evarray.max_nth(2)<evcap
      GameData::Stat.each_main do |s|
        if pkmn.ev[s.id]==evarray.max
          pkmn.ev[s.id]+=increment
          pkmn.calc_stats
          pkmn.ev[s.id]+=increment if pkmn.ev[s.id]<evcap
          pkmn.calc_stats
        end
      end	
      evsum=pkmn.ev[:HP]+pkmn.ev[:ATTACK]+pkmn.ev[:DEFENSE]+pkmn.ev[:SPECIAL_DEFENSE]+pkmn.ev[:SPEED] 
      evsum+=pkmn.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
      evarray=[]
      GameData::Stat.each_main do |s|
        evarray.push(pkmn.ev[s.id])
      end
      if evpool>evsum
        GameData::Stat.each_main do |s|
          if pkmn.ev[s.id]==evarray.max_nth(2)
            pkmn.ev[s.id]+=increment
            pkmn.calc_stats
          end
        end	
      end														
    end		    
    # DemICE end
  elsif new_level < pkmn.level
    GameData::Stat.each_main do |s|
      if pkmn.ev[s.id]=0
        pkmn.calc_stats
      end
    end	    
  end
  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level == new_level
    return
  end
  old_level           = pkmn.level
  old_total_hp        = pkmn.totalhp
  old_attack          = pkmn.attack
  old_defense         = pkmn.defense
  old_special_attack  = pkmn.spatk
  old_special_defense = pkmn.spdef
  old_speed           = pkmn.speed
  pkmn.level = new_level
  pkmn.calc_stats
  if old_level > new_level
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
  else
    pkmn.changeHappiness("vitamin")
    total_hp_diff        = pkmn.totalhp - old_total_hp
    attack_diff          = pkmn.attack - old_attack
    defense_diff         = pkmn.defense - old_defense
    special_attack_diff  = pkmn.spatk - old_special_attack
    special_defense_diff = pkmn.spdef - old_special_defense
    speed_diff           = pkmn.speed - old_speed
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    movelist.each do |i|
      next if i[0] <= old_level || i[0] > pkmn.level
      pbLearnMove(pkmn, i[1], true)
    end
    # Check for evolution
    new_species = pkmn.check_evolution_on_level_up
    if new_species
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, new_species)
        evo.pbEvolution
        evo.pbEndScreen
      }
    end
  end
end

def lvlup(pkmn,qty)
  if pkmn.level >= GameData::GrowthRate.max_level
    new_species = pkmn.check_evolution_on_level_up
    if new_species
    # Check for evolution
    pbFadeOutInWithMusic {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn, new_species)
      evo.pbEvolution
      evo.pbEndScreen
    }
	end
  end
  # Level up
  pbChangeLevel(pkmn, pkmn.level + qty)
end

def sacreward(bossnumber)
	reward=[]
	
	rareitem=[:EVIOLITE,:ROCKYHELMET,:ASSAULTVEST,:HEAVYDUTYBOOTS,:CHOICEBAND,
			:CHOICESCARF,:CHOICESPECS,:LEFTOVERS,:LIFEORB,:EXPERTBELT,:FOCUSSASH,:LONELYMINT,:ADAMANTMINT,:NAUGHTYMINT,:BRAVEMINT,
			:BOLDMINT,:IMPISHMINT,:LAXMINT,:RELAXEDMINT,:MODESTMINT,
			:MILDMINT,:RASHMINT,:QUIETMINT,:CALMMINT,:GENTLEMINT,
			:CAREFULMINT,:SASSYMINT,:TIMIDMINT,:HASTYMINT,
			:JOLLYMINT,:NAIVEMINT,:SERIOUSMINT,:PPMAX,:NUGGET]
			
	commonitem=[:AIRBALLOON,:BRIGHTPOWDER,:EVIOLITE,:FLOATSTONE,:DESTINYKNOT,:ROCKYHELMET,
			:ASSAULTVEST,:SAFETYGOGGLES,:PROTECTIVEPADS,:HEAVYDUTYBOOTS,:UTILITYUMBRELLA,
			:EJECTBUTTON,:EJECTPACK,:REDCARD,:SHEDSHELL,:SMOKEBALL,
			:CLEANSETAG,:CHOICEBAND,:CHOICESPECS,:CHOICESCARF,:HEATROCK,:DAMPROCK,:ICYROCK,
			:SMOOTHROCK,:TERRAINEXTENDER,:LIGHTCLAY,:BIGROOT,:BLACKSLUDGE,:LEFTOVERS,:SHELLBELL,
			:WHITEHERB,:POWERHERB,:ABSORBBULB,:CELLBATTERY,:LUMINOUSMOSS,:SNOWBALL,:WEAKNESSPOLICY,
			:BLUNDERPOLICY,:THROATSPRAY,:ROOMSERVICE,:ELECTRICSEED,:GRASSYSEED,:MISTYSEED,
			:PSYCHICSEED,:LIFEORB,:EXPERTBELT,:METRONOME,:MUSCLEBAND,:WISEGLASSES,:RAZORCLAW,
			:SCOPELENS,:WIDELENS,:ZOOMLENS,:KINGSROCK,:RAZORFANG,:LAGGINGTAIL,:QUICKCLAW,
			:FOCUSBAND,:FOCUSSASH,:FLAMEORB,:TOXICORB,:STICKYBARB,:IRONBALL,:RINGTARGET,
			:LAXINCENSE,:FULLINCENSE,:SEAINCENSE,:ROSEINCENSE,:ODDINCENSE,:ROCKINCENSE,
			:CHARCOAL,:MYSTICWATER,:MAGNET,:MIRACLESEED,:NEVERMELTICE,:BLACKBELT,:POISONBARB,
			:SOFTSAND,:SHARPBEAK,:TWISTEDSPOON,:SILVERPOWDER,:HARDSTONE,:SPELLTAG,:DRAGONFANG,
			:BLACKGLASSES,:METALCOAT,:SILKSCARF,:FLAMEPLATE,:SPLASHPLATE,:ZAPPLATE,:MEADOWPLATE,
			:ICICLEPLATE,:FISTPLATE,:TOXICPLATE,:EARTHPLATE,:SKYPLATE,:MINDPLATE,:INSECTPLATE,
			:STONEPLATE,:SPOOKYPLATE,:DRACOPLATE,:DREADPLATE,:IRONPLATE,:PIXIEPLATE,:FIREGEM,
			:WATERGEM,:ELECTRICGEM,:GRASSGEM,:ICEGEM,:FIGHTINGGEM,:POISONGEM,:GROUNDGEM,:FLYINGGEM,
			:PSYCHICGEM,:BUGGEM,:ROCKGEM,:GHOSTGEM,:DRAGONGEM,:DARKGEM,:STEELGEM,:FAIRYGEM,
			:NORMALGEM,:LIGHTBALL,:THICKCLUB,:LEEK,:SOULDEW,:DEEPSEATOOTH,:DEEPSEASCALE,
			:PRISMSCALE,:OVALSTONE,:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:ICESTONE,
			:SHINYSTONE,:DAWNSTONE,:DUSKSTONE,:SUNSTONE,:MOONSTONE]
	if bossnumber==1
		r=rand(100)
		if r<5
			pkmn = Pokemon.new(:ZYGARDE, 20)
			pkmn.shiny = false
			pkmn.form=1
			pbAddPokemon(pkmn)
		elsif r<15
			pkmn = Pokemon.new(:SPIRITOMB, 20)
			pbAddPokemon(pkmn)
		elsif r<35
			$player.money+=10000
			pbMessage("You gained 10000$.")
		else
			reward=[:DREADPLATE,:TM79,:DUSKSTONE]
			pbItemBall(reward.sample,1)
		end
	elsif bossnumber==2	
		itemsymb=sacitem
		item=nil
	    GameData::Item.each do |i|
			if i.id==itemsymb			
				item=i
			end
		end	
		if item==nil
			pbMessage("No item, no fun!")
			return
		end
		$bag.remove(itemsymb)
		if rareitem.include?(item.id) 
			pbMessage("Oh, that's a nice item. You can take those TM's as a reward.")
			pbItemBall(getrandomtm,1)
			pbItemBall(getrandomtm,1)
			pbItemBall(getrandomtm,1)
		elsif item.is_TM? || item.is_TR?
			pbMessage("A TM? Hmm... Destruction tool it is!")
			pbItemBall(get_hm,1)
		elsif commonitem.include?(item.id)
			pbMessage("That's not what I wanted... I guess you can take this thing...")
			pbItemBall(rareitem.sample,1)
		else
			pbMessage("If I wanted this kind of item, I could just steal it from a shop!")
		end
	end
end

def sacrifice(bossnumber)
	party_index = -1
	pbFadeOutIn {
	scene = PokemonParty_Scene.new
	screen = PokemonPartyScreen.new(scene, $player.party)
	screen.pbStartScene(_INTL("Choose a Pokémon to give to Darkrai."), false)
	party_index = screen.pbChoosePokemon
	screen.pbEndScene
	}
	return if party_index < 0   # Cancelled
    $player.party.delete_at(party_index)
	sacreward(bossnumber)
end

def sacitem
  ret = nil
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene, $bag)
    ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).can_hold? })
  }
  return ret 
end

def itempc(var)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
	if $game_variables[var]<3
		cmd= pbMessage("What do you want to do?",["Nothing","Deposit items","Get an item"],1,nil,0)
	else
		cmd= pbMessage("What do you want to do?",["Nothing","Deposit items"],1,nil,0)
	end
	if cmd==0
		pbMessage("You close the PC.")
	elsif cmd==1
		pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        screen.pbDepositItemScreen
		}
	elsif cmd==2
		if !$PokemonGlobal.pcItemStorage.empty?
			$game_variables[var]+=1
			it=$PokemonGlobal.pcItemStorage.items.sample()
			item=it[0]
			$PokemonGlobal.pcItemStorage.remove(item,1)
			$bag.add(item,1)
			pbMessage(_INTL("You got one {1}.",item.name))			
		else
			pbMessage("Your PC is empty.")
		end
	end
end