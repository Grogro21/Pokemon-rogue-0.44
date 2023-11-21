#===============================================================================
# SOS Battles - By Vendily [v19]
#===============================================================================
# This script adds in SOS Battles, the added mechanic from Alola, where
#  Pokémon have a chance of calling for aid while in battle.
# This version of the script does not implement special weather based encounters
#  but does have a method that can be edited to do so.
# The script also defines the manually used effect of the Adrenaline Orb item.
#===============================================================================
# To use it, you must add species that are able to SOS call in the SOS_WHITELIST_RATES
#  hash. The key is the species symbol, and the value is the rate in percentage
#  the mon will call at.
#   AKA. :BULBASAUR=>100 is a valid entry
#
# Optionally, you may add species to SOS_CALL_MONS, the species that
#  the mon will call for. Add more entries of the same species to make them more
#  likely. The Key is the species symbol, and the value is an array of species.
#   AKA. :BULBASAUR=>[:BULBASAUR,:BULBASAUR,:BULBASAUR,:IVYSAUR,:IVYSAUR,:VENUSAUR]
#   is a valid entry.
# If you don't have an entry for a calling species, it will call another mon of
#  the same species as itself.
#
# To implement the doubled EV points in an SOS battle, there is an aditional
#  edit to "def pbGainEVsOne" in PokeBattle_Battle
#  under:
#    # Double EV gain because of Pokérus
#    if pkmn.pokerusStage>=1   # Infected or cured
#      evYield.collect! { |a| a*2 }
#    end
#  put:
#    if @sosbattle
#      evYield.collect! { |a| a*2 }
#    end
#
# If you wish to implement special called allies, edit the array returned by
#  pbSpecialSOSMons. By default, it just passes through the regular array used.
# The method also takes the calling battler, if you wish to check its properties.
#===============================================================================



# * Switch id to enable/disable SOS battles. Set to <1 to not check.
  NO_SOS_BATTLES = 73
# * Setting to Toggle between Whitelist or Blacklist, if WHITELIST = True, only Pokemon in SOS_WHITELIST_RATES will appear.
# * If WHITELIST = False, it will check the SOS_BLACKLIST to see if a Pokemon is banned from calling. If Whitelist is false, a SOS_RATE must be defined.
  
  WHITELIST = true 
# * Hash containing base species call rates
  SOS_WHITELIST_RATES={:JIRACHI=>100, :REGIGIGAS=>100} 
# * Hash containing blacklisted Pokemon.
  SOS_BLACKLIST=[]
# * If using the Blacklist, all Pokemon have the same rate of being called.
  SOS_RATE=5
  # * Hash containing species called allies
  SOS_CALL_MONS={:JIRACHI=>[:CHANSEY,:CLEFABLE,:TOGEKISS,:UMBREON,:SLURPUFF,:SYLVEON,:XATU,:VAPOREON,:ESPEON,:ABSOL]}
  
  
  class Battle
    attr_accessor :adrenalineorb
    attr_accessor :lastturncalled
    attr_accessor :lastturnanswered
    attr_accessor :soschain
    attr_accessor :sosbattle
    
    def soschain
      return @soschain || 0
    end
    
    def pbSpecialSOSMons(caller,mons)
      return mons
    end
    
    def pbCallForHelp(caller,attackwhencoming=true)
      cspecies=caller.species
      rate=SOS_WHITELIST_RATES[cspecies] || SOS_RATE || 0
	  blacklistedmons = SOS_BLACKLIST
      for i in 0..blacklistedmons.length
	  return if blacklistedmons[i] == cspecies
      end
      return if rate==0 # should never trigger anyways but you never know.
      pbDisplay(_INTL("{1} called for help!", caller.pbThis))
      rate*=4 # base rate
      rate=rate.to_f # don't want to lose decimal points
      intimidate=false
      caller.eachOpposing{ |b|
        if b.hasActiveAbility?(:INTIMIDATE) ||
           b.hasActiveAbility?(:UNNERVE) ||
           b.hasActiveAbility?(:PRESSURE)
          intimidate=true
          break
        end
      }
      rate*=1.2 if intimidate
      if @lastturncalled==@turnCount-1
        rate*=1.5
      end
      if !@lastturnanswered
        rate*=3.0
      end
      rate=rate.round # rounding it off.
      pbDisplayPaused(_INTL("... ... ..."))
      idxOther = -1
      case pbSideSize(caller.index)
      when 1
        idxOther=3
        # change battle size
        @sideSizes[1]=2
      when 2
        idxOther = (caller.index+2)%4
      end
      if idxOther>=0 && pbRandom(100)<rate
        @lastturnanswered=true
        mons=SOS_CALL_MONS[cspecies] || [caller.species]
        mons=pbSpecialSOSMons(caller,mons)
        mon=mons[pbRandom(mons.length)]
        alevel=caller.level-1
        alevel=1 if alevel<1
        ally=pbGenerateSOSPokemon(GameData::Species.get(mon).species,alevel)
        if @battlers[idxOther].nil?
          pbCreateBattler(idxOther,ally,@party2.length)
        else
          @battlers[idxOther].pbInitialize(ally,@party2.length)
        end
        @scene.pbSOSJoin(idxOther,ally)
        pbDisplay(_INTL("{1} appeared!",@battlers[idxOther].pbThis))
        # prevent cheap shot
		if attackwhencoming==false
			@battlers[idxOther].lastRoundMoved=@turnCount
		end
        # required to gain exp and to do "switch in" effects, like Spikes
        pbOnBattlerEnteringBattle(@battlers[idxOther])
        @party2.push(ally)
        @party2order.push(@party2order.length)
		@battleAI.battlers[idxOther] = AI::AIBattler.new(@battleAI, idxOther)
		@battleAI.pbDefaultChooseEnemyCommand(idxOther)
      else
        @lastturnanswered=false
        pbDisplay(_INTL("Its help didn't appear!"))
      end
      @lastturncalled=@turnCount
    end
  
    def pbCallally(caller,species,level,attackwhencoming=true)
      pbDisplay(_INTL("{1} called for help!", caller.pbThis))
      intimidate=false
      caller.eachOpposing{ |b|
        if b.hasActiveAbility?(:INTIMIDATE) ||
           b.hasActiveAbility?(:UNNERVE) ||
           b.hasActiveAbility?(:PRESSURE)
          intimidate=true
          break
        end
      }
      pbDisplayPaused(_INTL("... ... ..."))
      idxOther = -1
      case pbSideSize(caller.index)
      when 1
        idxOther=3
        # change battle size
        @sideSizes[1]=2
      when 2
        idxOther = (caller.index+2)%4
      end
      if idxOther>=0
        @lastturnanswered=true
        mon=species
        ally=pbGenerateSOSPokemon(GameData::Species.get(mon).species,level)
        if @battlers[idxOther].nil?
          pbCreateBattler(idxOther,ally,@party2.length)
        else
          @battlers[idxOther].pbInitialize(ally,@party2.length)
        end
        @scene.pbSOSJoin(idxOther,ally)
        pbDisplay(_INTL("{1} appeared!",@battlers[idxOther].pbThis))
        # prevent cheap shot
		if attackwhencoming==false
			@battlers[idxOther].lastRoundMoved=@turnCount
		end
        # required to gain exp and to do "switch in" effects, like Spikes
        pbOnBattlerEnteringBattle(@battlers[idxOther])
        @party2.push(ally)
        @party2order.push(@party2order.length)
		@battleAI.battlers[idxOther] = AI::AIBattler.new(@battleAI, idxOther)
		@battleAI.pbDefaultChooseEnemyCommand(idxOther)
      else
        @lastturnanswered=false
        pbDisplay(_INTL("Its help didn't appear!"))
      end
      @lastturncalled=@turnCount
    end
	
    def pbGenerateSOSPokemon(species,level)
      genwildpoke = Pokemon.new(species,level,$Trainer)
      items = genwildpoke.wildHoldItems
      firstpoke = @battlers[0]
      chances = [50,5,1]
      chances = [60,20,5] if firstpoke.hasActiveAbility?(:COMPOUNDEYES)
      itemrnd = rand(100)
      if itemrnd<chances[0] || (items[0]==items[1] && items[1]==items[2])
        genwildpoke.item=(items[0].sample)
      elsif itemrnd<(chances[0]+chances[1])
        genwildpoke.item=(items[1].sample)
      elsif itemrnd<(chances[0]+chances[1]+chances[2])
        genwildpoke.item=(items[2].sample)
      end
      if firstpoke.hasActiveAbility?(:CUTECHARM) && !genwildpoke.singleGendered?
        if firstpoke.gender==0
          (rand(3)<2) ? genwildpoke.makeFemale : genwildpoke.makeMale
        elsif firstpoke.gender==1
          (rand(3)<2) ? genwildpoke.makeMale : genwildpoke.makeFemale
        end
      elsif firstpoke.hasActiveAbility?(:SYNCHRONIZE)
        genwildpoke.nature=firstpoke.nature if rand(10)<5
      end
      EventHandlers.trigger(:on_wild_pokemon_created, genwildpoke)
      return genwildpoke
    end
    
  end
   
  class Battle::Battler
    def pbCanCall?
      return false if NO_SOS_BATTLES>0 &&  $game_switches[NO_SOS_BATTLES]
      # only wild battles
      return false if @battle.trainerBattle?
      # only wild mons
      return false if !opposes?
      # can't call in triple+ battles (don't want to figure out where the battler needs to be)
      return false if @battle.pbSideSize(@index)>=3
      # can't call if partner already in
      allies=@battle.battlers.select {|b| b && !b.fainted? && !b.opposes?(@index) && b.index!=@index}
      return false if allies.length>0
      # just to be safe
      return false if self.fainted?
      # no call if status
      return false if self.pbHasAnyStatus?
      # no call if multiturn attack
      return false if usingMultiTurnAttack?
      cspecies=self.species
	  blacklistedmons = SOS_BLACKLIST
      for i in 0..blacklistedmons.length
	  return false if blacklistedmons[i] == cspecies
      end
      rate=SOS_WHITELIST_RATES[cspecies] || SOS_RATE || 0
      # not a species that calls
      rate*=3 if self.hp>(self.totalhp/4) && self.hp<=(self.totalhp/2)
      rate*=5 if self.hp<=(self.totalhp/4)
      rate*=2 if @battle.adrenalineorb
      return true
    end
end
  class Battle::Scene
    def pbSOSJoin(battlerindex,pkmn)
      pbRefresh
      sendOutAnims=[]
      adjustAnims=[]
      setupbox=false
      if !@sprites["dataBox_#{battlerindex}"]
        @sprites["dataBox_#{battlerindex}"] = PokemonDataBox.new(@battle.battlers[battlerindex],
            @battle.pbSideSize(battlerindex),@viewport)
        setupbox=true
        @sprites["targetWindow"].dispose
        @sprites["targetWindow"] = TargetMenu.new(@viewport, 200, @battle.sideSizes)
        @sprites["targetWindow"].visible=false
        pbCreatePokemonSprite(battlerindex)
        @battle.battlers[battlerindex].eachAlly{|b|
          adjustAnims.push([Animation::DataBoxDisappear.new(@sprites,@viewport,b.index),b])
        }
      end
      pkmn = @battle.battlers[battlerindex].effects[PBEffects::Illusion] || pkmn
      pbChangePokemon(battlerindex,pkmn)
      sendOutAnim = SOSJoinAnimation.new(@sprites,@viewport,
          @battle.pbGetOwnerIndexFromBattlerIndex(battlerindex)+1,
          @battle.battlers[battlerindex])
      dataBoxAnim = Animation::DataBoxAppear.new(@sprites,@viewport,battlerindex)
      sendOutAnims.push([sendOutAnim,dataBoxAnim,false])
      # Play all animations
      loop do
        adjustAnims.each do |a|
          next if a[0].animDone?
          a[0].update
        end
        pbUpdate
        break if !adjustAnims.any? {|a| !a[0].animDone?}
      end
      # delete and remake sprites
      adjustAnims.each {|a|
        @sprites["dataBox_#{a[1].index}"].dispose
        @sprites["dataBox_#{a[1].index}"] = PokemonDataBox.new(a[1],
            @battle.pbSideSize(a[1].index),@viewport)
      }
      # have to remake here, because I have to destroy and remake the databox
      # and that breaks the reference link.
      if setupbox
        @battle.battlers[battlerindex].eachAlly{|b|
          sendanim=SOSAdjustAnimation.new(@sprites,@viewport,
            @battle.pbGetOwnerIndexFromBattlerIndex(b.index)+1,b)
          dataanim=Animation::DataBoxAppear.new(@sprites,@viewport,b.index)
          sendOutAnims.push([sendanim,dataanim,false,b])
        }
      end
    loop do
      sendOutAnims.each do |a|
        next if a[2]
        a[0].update
        a[1].update if a[0].animDone?
        a[2] = true if a[1].animDone?
      end
      pbUpdate
      if !inPartyAnimation? && sendOutAnims.none? { |a| !a[2] }
        break
      end
    end
      adjustAnims.each {|a| a[0].dispose}
      sendOutAnims.each { |a| a[0].dispose; a[1].dispose }
      # Play shininess animations for shiny Pokémon
      if @battle.showAnims && @battle.battlers[battlerindex].shiny?
        pbCommonAnimation("Shiny",@battle.battlers[battlerindex])
      end
    end
  end
   
  class SOSJoinAnimation < Battle::Scene::Animation
    include Battle::Scene::Animation::BallAnimationMixin
   
    def initialize(sprites,viewport,idxTrainer,battler)
      @idxTrainer     = idxTrainer
      @battler        = battler
      sprites["pokemon_#{battler.index}"].visible = false
      @shadowVisible = sprites["shadow_#{battler.index}"].visible
      sprites["shadow_#{battler.index}"].visible = false
      super(sprites,viewport)
    end
   
    def createProcesses
      batSprite = @sprites["pokemon_#{@battler.index}"]
      shaSprite = @sprites["shadow_#{@battler.index}"]
      # Calculate the Poké Ball graphic to use
      # Calculate the color to turn the battler sprite
      col = Tone.new(0,0,0,248)
      # Calculate start and end coordinates for battler sprite movement
      batSprite.src_rect.height=batSprite.bitmap.height
      battlerX = batSprite.x
      battlerY = batSprite.y
      delay = 0
      # Set up battler sprite
      battler = addSprite(batSprite,PictureOrigin::BOTTOM)
      battler.setXY(0,battlerX,battlerY)
      battler.setTone(0,col)
      # Battler animation
      battler.setVisible(delay,true)
      battler.setOpacity(delay,255)
      # NOTE: As soon as the battler sprite finishes zooming, and just as it
      #       starts changing its tone to normal, it plays its intro animation.
      col.gray = 0
      battler.moveTone(delay+5,10,col,[batSprite,:pbPlayIntroAnimation])
      if @shadowVisible
        # Set up shadow sprite
        shadow = addSprite(shaSprite,PictureOrigin::CENTER)
        shadow.setOpacity(0,0)
        # Shadow animation
        shadow.setVisible(delay,@shadowVisible)
        shadow.moveOpacity(delay+5,10,255)
      end
    end
  end
   
  class Battle::Scene::BattlerSprite < RPG::Sprite
    attr_accessor   :sideSize
  end
  class Battle::Scene::BattlerShadowSprite < RPG::Sprite
    attr_accessor   :sideSize
  end
   
  class SOSAdjustAnimation < Battle::Scene::Animation
    include Battle::Scene::Animation::BallAnimationMixin
   
    def initialize(sprites,viewport,idxTrainer,battler)
      @idxTrainer     = idxTrainer
      @battler        = battler
      @shadowVisible = sprites["shadow_#{battler.index}"].visible
      super(sprites,viewport)
    end
   
    def createProcesses
      batSprite = @sprites["pokemon_#{@battler.index}"]
      shaSprite = @sprites["shadow_#{@battler.index}"]
      batSprite.sideSize=@battler.battle.pbSideSize(@battler.index)
      shaSprite.sideSize=@battler.battle.pbSideSize(@battler.index)
      batSprite.pbSetPosition
      shaSprite.pbSetPosition if @shadowVisible
      battler = addSprite(batSprite,PictureOrigin::BOTTOM)
    end
  end
   
  ItemHandlers::CanUseInBattle.add(:ADRENALINEORB,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
    if battle.adrenalineorb
      scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
      next false
    end
    next true
  })
   
  ItemHandlers::UseInBattle.add(:ADRENALINEORB,proc { |item,battler,battle|
    battle.adrenalineorb=true
    battle.pbDisplayPaused(_INTL("The {1} makes the wild Pokémon nervous!",GameData::Item.get(item).name))
  })
