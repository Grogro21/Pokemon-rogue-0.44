def changeNature(pkmn)
    commands = []
    ids = []
    GameData::Nature.each do |nature|
        if nature.stat_changes.length == 0
            commands.push(_INTL("{1} (---)", nature.real_name))
        else
            plus_text = ""
            minus_text = ""
            nature.stat_changes.each do |change|
                if change[1] > 0
                    plus_text += "/" if !plus_text.empty?
                    plus_text += GameData::Stat.get(change[0]).name_brief
                elsif change[1] < 0
                    minus_text += "/" if !minus_text.empty?
                    minus_text += GameData::Stat.get(change[0]).name_brief
                end
            end
            commands.push(_INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text))
        end
        ids.push(nature.id)
    end
    cmd = 0
    cmd = pbMessage("Which nature do yo want for your Pokémon?", commands, 0, nil, 0)
    pkmn.nature = ids[cmd]
    pbMessage(_INTL("Nature changed to {1}.", pkmn.nature.real_name))
end

def setabil(pkmn)
    abils = pkmn.getAbilityList
    ability_commands = []
    for i in abils
        ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
    end
    cmd = pbMessage("Which ability do yo want for your Pokémon?", ability_commands, 0, nil, 0)
    pkmn.ability = abils[cmd][0]
end

def setabilhack(pkmn)
    new_ability = pbChooseAbilityList(pkmn.ability_id)
    if new_ability && new_ability != pkmn.ability_id
        pkmn.ability = new_ability
    end

end

def pbChooseFromGameDataList(game_data, default = nil)
    if !GameData.const_defined?(game_data.to_sym)
        raise _INTL("Couldn't find class {1} in module GameData.", game_data.to_s)
    end
    game_data_module = GameData.const_get(game_data.to_sym)
    commands = []
    game_data_module.each do |data|
        name = data.real_name
        name = yield(data) if block_given?
        next if !name
        unless BANABILS.include?(data.id)
            commands.push([commands.length + 1, name, data.id])
        end

    end
    return pbChooseList(commands, default, nil, -1)
end

def deleteitem
    for i in 0...$Trainer.party_count
        pkmn = $Trainer.pokemon_party[i]
        pkmn.item = nil
    end
end

def saveitem
    itemlist = [nil, nil, nil, nil, nil, nil]
    for i in 0...$Trainer.party_count
        pkmn = $Trainer.pokemon_party[i]
        if pkmn.item != nil
            itemlist[i] = pkmn.item_id
        end
    end
    $game_variables[33] = itemlist
end

def restoreitem
    itemlist = $game_variables[33]
    for i in 0...$Trainer.party_count
        pkmn = $Trainer.pokemon_party[i]
        pkmn.item = itemlist[i]
    end
end
