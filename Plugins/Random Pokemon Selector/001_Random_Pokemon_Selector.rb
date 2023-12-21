def pbChooseRandomPokemon(whiteList=nil, blackList=nil, addList=nil,
                          base_only=true, choose_gen=nil)

  # If blackList is set to "suggested", then set to mythical and legendary Pokémon
  if blackList == "suggested"
    blackList = getLegendOrMythic
  end

  # Option for a second black list, useful if suggested black list is requested and the user wants to add into that array rather than rewrite it
  # addList is ignored if blackList is not specified
  if addList && blackList
    blackList += addList
  end

  # Set blackList to empty array if it doesn't exist by this point
  blackList = [] if !blackList

  # Set choose_gen to array of values from 1 to 8 if it doesn't exist
  choose_gen = (1..8).to_a if !choose_gen

  # Blank array to be filled
  arr = []

  # If whiteList is given, push into above blank array
  # If base_only is true, then only pick species from whiteList if they are the base form
  # Exclude any species on the black list
  # If whiteList is not defined, then start from all species
  # Restrict to species from generations specified in choose_gen array
  # Repeated from above wrt black list and base forms
  if whiteList
    whiteList.each_with_index do |s, i|
      whiteList[i] = GameData::Species.try_get(s)
    end
    if base_only
      whiteList.each { |s| arr.push(s.id) if !blackList.include?(s.id) && s.id == s.get_baby_species }
    else
      whiteList.each { |s| arr.push(s.id) if !blackList.include?(s.id) }
    end
  else
    if base_only
      GameData::Species.each do |s|
        arr.push(s.id) if choose_gen.include?(s.generation) && !blackList.include?(s.id) && s.id == s.get_baby_species && s.form == 0
      end
    else
      GameData::Species.each do |s|
        arr.push(s.id) if choose_gen.include?(s.generation) && !blackList.include?(s.id) && s.form == 0
      end
    end
  end

  # Pull random entry from array
  pkmn = arr.sample
  return pkmn

end

# Returns array of mythical and legendary Pokémon
def getLegendOrMythic
  arr = [:ARTICUNO, :ZAPDOS, :MOLTRES,
  :RAIKOU, :ENTEI, :SUICUNE,
  :REGIROCK, :REGICE, :REGISTEEL,
  :LATIAS, :LATIOS,
  :UXIE, :MESPRIT, :AZELF,
  :HEATRAN, :REGIGIGAS, :CRESSELIA,
  :COBALION, :TERRAKION, :VIRIZION,
  :TORNADUS, :THUNDURUS, :LANDORUS,
  :TYPENULL, :SILVALLY,
  :TAPUKOKO, :TAPULELE, :TAPUBULU, :TAPUFINI,
  :NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE,
  :CELESTEELA, :KARTANA, :GUZZLORD, :POIPOLE,
  :NAGANADEL, :STAKATAKA, :BLACEPHALON,
  :KUBFU, :URSHIFU,
  :REGIELEKI, :REGIDRAGO,
  :GLASTRIER, :SPECTRIER, :ENAMORUS, 
  :MEWTWO, :LUGIA, :HOOH,
  :KYOGRE, :GROUDON, :RAYQUAZA,
  :DIALGA, :PALKIA, :GIRATINA,
  :RESHIRAM, :ZEKROM, :KYUREM,
  :XERNEAS, :YVELTAL, :ZYGARDE,
  :COSMOG, :COSMOEM,
  :SOLGALEO, :LUNALA, :NECROZMA,
  :ZACIAN, :ZAMAZENTA,
  :ETERNATUS, :CALYREX,
  :MEW, :CELEBI, :JIRACHI,
  :DEOXYS, :PHIONE, :MANAPHY,
  :DARKRAI, :SHAYMIN, :ARCEUS,
  :VICTINI, :KELDEO, :MELOETTA, :GENESECT,
  :DIANCIE, :HOOPA, :VOLCANION,
  :MAGEARNA, :MARSHADOW, :ZERAORA,
  :MELTAN, :MELMETAL, :ZARUDE, :GHOST]
  return arr
end

# Unused utility method that returns the base stat total (BST) for given Pokémon
def getBaseStatTotal(pokemon)
  baseTotal = 0
  GameData::Stat.each_main do |s|
    baseTotal += pokemon.base_stats[s.id]
  end
  return baseTotal
end

Whitelistroute=[:BULBASAUR,:CHARMANDER,:SQUIRTLE,:RATTATA,:PIDGEY,:SPEAROW,
:EKANS,:NIDORANfE,:NIDORANmA,:ODDISH,:MEOWTH,:PSYDUCK,:GROWLITHE,:POLIWAG,:ABRA,
:BELLSPROUT,:PONYTA,:FARFETCHD,:DODUO,:EXEGGCUTE,:GOLDEEN,:TAUROS,:MAGIKARP,:EEVEE,
:MUNCHLAX,:CHIKORITA,:CYNDAQUIL,:TOTODILE,:SENTRET,:HOOTHOOT,:LEDYBA,:TOGEPI,:MAREEP,
:MARILL,:SUDOWOODO,:HOPPIP,:AIPOM,:SUNKERN,:YANMA,:WOOPER,:MURKROW,:GIRAFARIG,
:SNUBBULL,:SKARMORY,:PHANPY,:STANTLER,:MILTANK,:TREECKO,:TORCHIC,:MUDKIP,:POOCHYENA,
:ZIGZAGOON,:LOTAD,:SEEDOT,:TAILLOW,:WINGULL,:RALTS,:SURSKIT,:NINCADA,:SKITTY,
:ELECTRIKE,:PLUSLE,:MINUN,:VOLBEAT,:ROSELIA,:GULPIN,:SPOINK,:SPINDA,:ZANGOOSE,
:SEVIPER,:BARBOACH,:CORPHISH,:FEEBAS,:KECLEON,:SHUPPET,:DUSKULL,:CHIMECHO,:WYNAUT,
:TURTWIG,:CHIMCHAR,:PIPLUP,:STARLY,:BIDOOF,:KRICKETOT,:SHINX,:BURMY,:COMBEE,:PACHIRISU,
:BUIZEL,:CHERUBI,:SHELLOS,:DRIFLOON,:BUNEARY,:GLAMEOW,:STUNKY,:CHATOT,:SPIRITOMB,
:RIOLU,:FINNEON,:SNIVY,:TEPIG,:OSHAWOTT,:PATRAT,:LILLIPUP,:PURRLOIN,:PANSAGE,
:PANSEAR,:PANPOUR,:MUNNA,:PIDOVE,:BLITZLE,:TIMBURR,:TYMPOLE,:SEWADDLE,:COTTONEE,
:PETILIL,:BASCULIN,:ZORUA,:MINCCINO,:GOTHITA,:DUCKLETT,:VANILLITE,:DEERLING,
:EMOLGA,:FOONGUS,:KARRABLAST,:AXEW,:SHELMET,:PAWNIARD,:BOUFFALANT,:RUFFLET,
:VULLABY,:DURANT,:HEATMOR,:CHESPIN,:FENNEKIN,:FROAKIE,:BUNNELBY,:FLETCHLING,
:SCATTERBUG,:LITLEO,:FLABEBE,:SKIDDO,:PANCHAM,:ESPURR,:FURFROU,:HONEDGE,:SPRITZEE,
:SWIRLIX,:INKAY,:BINACLE,:HELIOPTILE,:HAWLUCHA,:DEDENNE,:GOOMY,:KLEFKI,:PUMPKABOO,
:ROWLET,:LITTEN,:POPPLIO,:PIKIPEK,:YUNGOOS,:BRUBBIN,:CRABRAWLER,:ORICORIO,
:CUTIEFLY,:ROCKRUFF,:WISHIWASHI,:MUDBRAY,:DEWPIDER,:FOMANTIS,:SALANDIT,:STUFFUL,
:BOUNSWEET,:COMFEY,:ORANGURU,:PASSIMIAN,:WIMPOD,:TOGEDEMARU,:MIMIKYU,:GROOKEY,
:SCORBUNNY,:SOBBLE,:SKWOVET,:ROOKIDEE,:BLIPBUG,:NICKIT,:GOSSIFLEUR,:WOOLOO,
:CHEWTLE,:YAMPER,:APPLIN,:CRAMORANT,:TOXEL,:SIZZLIPEDE,:HATENNA,:FALINKS,
:SNOM,:INDEEDEE,:MORPEKO,:CUFANT,:DREEPY]

Whitelistforet=[:BULBASAUR,:CATERPIE,:WEEDLE,:PIKACHU,:ODDISH,:PARAS,:VENONAT,:MANKEY,
:POLIWAG,:ABRA,:BELLSPROUT,:FARFETCHD,:CHANSEY,:TANGELA,:SCYTHER,:PINSIR,:CHIKORITA,
:SPINARAK,:SUDOWOODO,:YANMA,:PINECO,:TREECKO,:WURMPLE,:LOTAD,:SEEDOT,:TAILLOW,
:SURSKIT,:SHROOMISH,:SLAKOTH,:ILLUMISE,:SEVIPER,:ZANGOOSE,:BARBOACH,:KECLEON,:SHUPPET,:DUSKULL,:TROPIUS,
:ABSOL,:TURTWIG,:CHIMCHAR,:STARLY,:BURMY,:COMBEE,:PACHIRISU,:CHERUBI,:SNIVY,:PANSAGE,:PANPOUR,:PANSEAR,
:SEWADDLE,:VENIPEDE,:COTTONEE,:PETILIL,:DEERLING,:EMOLGA,:KARRABLAST,:FOONGUS,:FERROSEED,:SHELMET,:HEATMOR,
:DURANT,:CHESPIN,:FENNEKIN,:FROAKIE,:SCATTERBUG,:FLABEBE,:PANCHAM,:HONEDGE,:SPRITZEE,:SWIRLIX,
:INKAY,:SYLVEON,:LEAFEON,:DEDENNE,:CARBINK,:GOOMY,:KLEFKI,:PHANTUMP,:PUMPKABOO,:ROWLET,:PIKIPEK,
:GRUBBIN,:CUTIEFLY,:FOMANTIS,:MORELULL,:STUFFUL,:BOUNSWEET,:COMFEY,:ORANGURU,:PASSIMIAN,:WIMPOD,
:KOMALA,:TOGEDEMARU,:MIMIKYU,:BRUXISH,:DRAMPA,:DHELMISE,:GROOKEY,:SKWOVET,:BLIPBUG,:NICKIT,
:APPLIN,:SIZZLIPEDE,:HATENNA,:IMPIDIMP,:INDEEDEE,:MORPEKO,:CUFANT]