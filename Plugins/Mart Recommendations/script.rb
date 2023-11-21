#==============================================================================#
#                             Mart Recommendations                             #
#                                  by LuxDiablo                                #
#                                                                              #
#        This is my first script so please let me know if there are any        #
#                                 issues with it!                              #
#------------------------------------------------------------------------------#
WELCOME_MESSAGE = _INTL("Hiya! I'm taking suggestions for what to sell in my shop!")
DEFAULT_MART = [:POTION]
BLACKLIST = [:MASTERBALL]

def recMart
  $RecArray = DEFAULT_MART if !$RecArray
  commands = []
  cmdBuy  = -1
  cmdRecommend = -1
  cmdRemove = -1
  cmdQuit = -1
  commands[cmdBuy = commands.length] = _INTL("I'd like to buy.")
  commands[cmdRecommend = commands.length] = _INTL("I'd like to unlock an item.")
  commands[cmdQuit = commands.length] = _INTL("No, thank you!")
  cmd = pbMessage(WELCOME_MESSAGE, commands, cmdQuit + 1)
  loop do
    if cmdBuy >= 0 && cmd == cmdBuy
      if $RecArray == []
        pbMessage(_INTL("I don't know what to sell yet!"))
      else
        scene = PokemonMart_Scene.new
        screen = PokemonMartScreen.new(scene, $RecArray)
        screen.pbBuyScreen
      end
    elsif cmdRecommend >= 0 && cmd == cmdRecommend
	 if $game_variables[60]>=2
		pbMessage(_INTL("I can't invest right now."))
	 else
      pbMessage(_INTL("Okay! What would you like to unlock?"))
      recItem = pbChooseItem
      if recItem == nil
        pbMessage(_INTL("Come again!"))
	  else
		itemdata = GameData::Item.get(recItem)
		if itemdata.is_key_item? || itemdata.price == 0 || BLACKLIST.include?(recItem) || $RecArray.include?(recItem)
			pbMessage(_INTL("I'm sorry. I can't sell that item in my shop."))
		else
			pbMessage(_INTL("A {1}? Good choice! I'll add it to my list!", itemdata.name))
			$game_variables[60] += 1
			$RecArray.push(recItem)
		end
	  end
	 end
    else
      pbMessage(_INTL("Have a good day!"))
      break
    end
    cmd = pbMessage(_INTL("Is there anything else I can do for you?"), commands, cmdQuit + 1)
  end
end
