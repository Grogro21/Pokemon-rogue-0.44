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
    if pbAbleCount(1)==0
      @decision=1 #win if the opponent has 0 pkmn left
    end
	end
end

def throwitem(pkmn)
	list=[:STICKYBARB,:IRONBALL,:CHOICEBAND,:CHOICESCARF,:CHOICESPECS,:BLACKSLUDGE,:EJECTBUTTON,:FLAMEORB,:TOXICORB,:FULLINCENSE,:LAGGINGTAIL,:MACHOBRACE,:RINGTARGET,:LEFTOVERS]	
	if list.include?(pkmn.item.id)
		battle.pbLowerHP(pkmn,8)
	end
	choice=list.sample
	pkmn.item=choice
	return choice
end


##########Battle pictures######################################

class Battle::Scene
  def appearsprite(spritenames)
    pbAddSprite("bob",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritename[0],@viewport)
	  pbAddSprite("bob2",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritename[1],@viewport)
	  pbAddSprite("bob3",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritename[2],@viewport)
	  pbAddSprite("bob4",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritename[3],@viewport)
	  pbAddSprite("bob5",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritename[4],@viewport)
    pbAddSprite("bob6",Graphics.width,0,"Graphics/Battle animations/pictures/"+spritenames[5],@viewport)
    unfadeAnim = SpriteAppearAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end
  
  def disappearsprite
    unfadeAnim = SpriteDisappearAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end
end

class SpriteAppearAnimation < Battle::Scene::Animation
  def initialize(sprites,viewport,battlers)
    @battlers = battlers
    super(sprites,viewport)
  end

  def createProcesses
    delay = 10
    boxes = []
    toMoveTop = [@sprites["bob"].bitmap.width,Graphics.width].max
    topBar = addSprite(@sprites["bob"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
    topBar.setOpacity(0,255)
    topBar.setXY(0,Graphics.width,0)
    topBar.moveXY(delay,10,(Graphics.width-toMoveTop),0)
	
	toMoveTop2 = [@sprites["bob2"].bitmap.width,Graphics.width].max
    topBar2 = addSprite(@sprites["bob2"],PictureOrigin::TOP_LEFT)
    topBar2.setZ(0,200)
    topBar2.setOpacity(0,255)
    topBar2.setXY(0,Graphics.width,0)
    topBar2.moveXY(delay,10,(Graphics.width-toMoveTop2),0)
	
	toMoveTop3 = [@sprites["bob3"].bitmap.width,Graphics.width].max
    topBar3 = addSprite(@sprites["bob3"],PictureOrigin::TOP_LEFT)
    topBar3.setZ(0,200)
    topBar3.setOpacity(0,255)
    topBar3.setXY(0,Graphics.width,0)
    topBar3.moveXY(delay,10,(Graphics.width-toMoveTop2),0)
	
	toMoveTop4 = [@sprites["bob4"].bitmap.width,Graphics.width].max
    topBar4 = addSprite(@sprites["bob4"],PictureOrigin::TOP_LEFT)
    topBar4.setZ(0,200)
    topBar4.setOpacity(0,255)
    topBar4.setXY(0,Graphics.width,0)
    topBar4.moveXY(delay,10,(Graphics.width-toMoveTop2),0)
	
	toMoveTop5 = [@sprites["bob5"].bitmap.width,Graphics.width].max
    topBar5 = addSprite(@sprites["bob5"],PictureOrigin::TOP_LEFT)
    topBar5.setZ(0,200)
    topBar5.setOpacity(0,255)
    topBar5.setXY(0,Graphics.width,0)
    topBar5.moveXY(delay,10,(Graphics.width-toMoveTop2),0)
	
  toMoveTop6 = [@sprites["bob6"].bitmap.width,Graphics.width].max
    topBar6 = addSprite(@sprites["bob6"],PictureOrigin::TOP_LEFT)
    topBar6.setZ(0,200)
    topBar6.setOpacity(0,255)
    topBar6.setXY(0,Graphics.width,0)
    topBar6.moveXY(delay,10,(Graphics.width-toMoveTop2),0)
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].moveOpacity(delay,5,0)
      end
    end
  end
end

class SpriteDisappearAnimation < Battle::Scene::Animation
  def initialize(sprites,viewport,battlers)
    @battlers = battlers
    super(sprites,viewport)
  end

  def createProcesses
    delay = 10
    boxes = []
    topBar = addSprite(@sprites["bob"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
    topBar = addSprite(@sprites["bob2"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
	  topBar = addSprite(@sprites["bob3"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
	  topBar = addSprite(@sprites["bob4"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
	  topBar = addSprite(@sprites["bob5"],PictureOrigin::TOP_LEFT)
    topBar.setZ(0,200)
    topBar.setZ(0,200)
    topBar = addSprite(@sprites["bob6"],PictureOrigin::TOP_LEFT)
    topBar.moveOpacity(delay,8,0)
    topBar.moveOpacity(delay,8,0)
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].setOpacity(0,0)
        boxes[i].moveOpacity(delay,5,255)
      end
    end
    topBar.setXY(delay+5,Graphics.width,0)
  end
end