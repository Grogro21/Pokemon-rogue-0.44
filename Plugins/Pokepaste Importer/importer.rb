def cutfile(file, pknum)
    # cut the file into a list for every pkmn
    text = File.open(file)
    team = []
    prov = []
    for i in 0...pknum
        team.push([])
    end
    text.each do |line|
        words = line.split
        prov.push words
    end
    k = 0
    for list in prov
        if list != [] && team[k] != nil
            team[k].push(list)
        else
            k += 1
        end
    end
    c = 0
    for i in 0...pknum
        if team[i] == []
            c += 1
        end
    end
    for i in 0...c
        team.pop()
    end

    return team
end

def nametospecies(name)
    # make the pkmn name something the game can read
    if name == "Nidoran-M" # nidoran being weird in pbs files
        return :NIDORANmA
    end
    if name == "Nidoran-F"
        return :NIDORANfE
    end
    if name == "Farfetch’d"
        return :FARFETCHD
    end
    if name == "Sirfetch’d"
        return :SIRFETCHD
    end
    GameData::Species.each_species do |species|
        if species.real_name == name
            return species.id
        end
    end
    if name != nil
        n = name.split("-")
        GameData::Species.each_species do |species|
            if species.real_name == n[0]
                return species.id
            end
        end
    end

    return nil
end

def nametoitem(pkmn, iname)
    # make the item name something the game can read
    name = ""
    if iname != nil
        for j in 0...iname.length
            if j == 0
                name << iname[j]
            else
                name << " "
                name << iname[j]
            end
        end
        GameData::Item.each do |i|
            if i.real_name == name
                pkmn.item = i
            end
        end
    end
end

def nametoabil(pkmn, name)
    # make the ability name something the game can read
    aname = ""
    if name != nil
        for j in 0...name.length
            if j == 0
                aname << name[j]
            else
                aname << " "
                aname << name[j]
            end
        end
        GameData::Ability.each do |abil|
            if abil.real_name == aname
                pkmn.ability = abil
            end
        end
    end
end

def findform(name, pkmn)
    # make the form name something the game can read
    specie = pkmn.species
    if name != nil
        n = name.split("-")
        if n.length > 1
            exspecie = [:ARCEUS, :GENESECT, :ZACIAN, :SILVALLY, :ZAMAZENTA]
            if n[1] != "Mega" && n[1] != "Primal" && !exspecie.include?(specie) && n[1] != "Complete"
                formcmds = []
                GameData::Species.each do |sp|
                    next if sp.species != specie
                    form_name = sp.form_name
                    form_name = _INTL("Unnamed form") if !form_name || form_name.empty?
                    formcmds.push(form_name)
                end
                for i in 0...formcmds.length # exceptions: pkmn that learn move when changing form
                    if formcmds[i].include?(n[1])
                        if specie == :CALYREX && i == 2
                            pkmn.learn_move(:ASTRALBARRAGE)
                        end
                        if specie == :CALYREX && i == 1
                            pkmn.learn_move(:GLACIALLANCE)
                        end
                        if specie == :NECROZMA && i == 1
                            pkmn.learn_move(:SUNSTEELSTRIKE)
                        end
                        if specie == :NECROZMA && i == 2
                            pkmn.learn_move(:MOONGEISTBEAM)
                        end
                        if specie == :KYUREM && i == 1
                            pkmn.learn_move(:ICEBURN)
                            pkmn.learn_move(:FUSIONFLARE)
                        end
                        if specie == :KYUREM && i == 2
                            pkmn.learn_move(:FREEZESHOCK)
                            pkmn.learn_move(:FUSIONBOLT)
                        end
                        if specie == :ROTOM
                            pkmn.learn_move(:OVERHEAT) if i == 1
                            pkmn.learn_move(:HYDROPUMP) if i == 2
                            pkmn.learn_move(:BLIZZARD) if i == 3
                            pkmn.learn_move(:AIRSLASH) if i == 4
                            pkmn.learn_move(:LEAFSTORM) if i == 5
                        end

                        return(i)
                    end
                end
            end
            if specie == :GRENINJA
                if n[1] == "Ash"
                    return(1)
                end
            end
        end
    end
    return 0
end

def giveev(pkmn, value, evname)
    # obvious
    if evname == "Atk"
        stat = :ATTACK
    elsif evname == "SpA"
        stat = :SPECIAL_ATTACK
    elsif evname == "Spe"
        stat = :SPEED
    elsif evname == "HP"
        stat = :HP
    elsif evname == "Def"
        stat = :DEFENSE
    else
        stat = :SPECIAL_DEFENSE
    end
    pkmn.ev[stat] = value
end

def giveiv(pkmn, value, ivname)
    stat = false
    if ivname == "Atk"
        stat = :ATTACK
    elsif ivname == "SpA"
        stat = :SPECIAL_ATTACK
    elsif ivname == "Spe"
        stat = :SPEED
    elsif ivname == "HP"
        stat = :HP
    elsif ivname == "Def"
        stat = :DEFENSE
    elsif ivname == "SpD"
        stat = :SPECIAL_DEFENSE
    else
        echoln(ivname)
    end
    pkmn.iv[stat] = value
end

def nametonature(name)
    GameData::Nature.each do |nature|
        if nature.real_name == name
            return nature.id
        end
    end
end

def nametomove(pkmn, name)
    aname = ""
    if name != nil
        for j in 0...name.length
            if j == 0
                aname << name[j]
            else
                aname << " "
                aname << name[j]
            end
        end
        if aname == "Behemoth Bash" || aname == "Behemoth Blade" # zacian and zamazenta
            pkmn.learn_move(:IRONHEAD)
        end
        GameData::Move.each do |move|
            if move.real_name == aname && aname != "Behemoth Bash" && aname != "Behemoth Blade"
                pkmn.learn_move(move)
            end
        end
    end
end

def nametotype(pkmn, name)
    GameData::Type.each do |type|
        if type.real_name == name
            return type.id
        end
    end
end

def nickname(name)
    if name.length > 1
        nick = ""
        for i in 0...name.length
            nick << name[i]
            nick << " "
        end
    else
        nick = name[0]
    end
    return(nick)
end

def caracpkmn(pktext)
    id = nil
    k = 0
    while id == nil && k < pktext[0].length # nickname check
        text = pktext[0][k].split("(")
        if text.length > 1
            text = text[1].split(")")
        end
        id = nametospecies(text[0])
        k += 1
    end
    k -= 1
    if id == nil # tapu check
        k = 0
        while id == nil && k < pktext[0].length
            text = pktext[0][k].split("(")
            if text.length > 1
                text = text[1].split(")")
            end
            if k + 1 < pktext[0].length
                t = pktext[0][k + 1].split("(")
                if t.length > 1
                    t = t[1].split(")")
                end
                tname = ""
                tname << text[0]
                tname << " "
                tname << t[0]
                id = nametospecies(tname)
            end
            k += 1
        end

    end
    if id == nil
        p ("pkmn name was not recognized.Generating Ditto instead.")
        id = :DITTO
    end
    pkmn = Pokemon.new(id, 100)
    pkmn.form = findform(pktext[0][k], pkmn)
    if pktext[0][1 + k] == "@"
        nametoitem(pkmn, pktext[0][2 + k...pktext[0].length])
    else
        nametoitem(pkmn, pktext[0][3 + k...pktext[0].length])
        if pktext[0][1 + k] == "(M)"
            pkmn.makeMale
        else
            pkmn.makeFemale
        end
    end
    nametoabil(pkmn, pktext[1][1...pktext[1].length])
    i = 2
    if i < pktext.length
        if pktext[i][0] == "Level:"
            pkmn.level = (pktext[i][1]).to_i
            pkmn.obtain_level = (pktext[i][1]).to_i
            i += 1
        end
    end
    if i < pktext.length
        if pktext[i][0] == "Shiny:"
            pkmn.shiny = true if pktext[i][1] == "Yes"
            i += 1
        end
    end
    if i < pktext.length
        if pktext[i][0] == "Happiness:"
            pkmn.happiness = (pktext[i][1]).to_i
            i += 1
        end
    end
    if i < pktext.length
        if pktext[i][0] == "Tera"
            if pkmn.respond_to?(:tera_type)
                tera = pktext[i][2] # optional tera check
                pkmn.tera_type = nametotype(pkmn, tera)
            end
            i += 1
        end
    end
    if i < pktext.length
        if pktext[i][0] == "EVs:"
            for j in 0...pktext[i].length / 3
                giveev(pkmn, (pktext[i][j * 3 + 1]).to_i, pktext[i][j * 3 + 2])
            end
            i += 1
        end
    end
    if i < pktext.length
        if pktext[i][1] == "Nature"
            pkmn.nature = nametonature(pktext[i][0])
            i += 1
        end
    end
    pkmn.iv[:SPECIAL_DEFENSE] = 31 # perfect ivs by default
    pkmn.iv[:DEFENSE] = 31
    pkmn.iv[:ATTACK] = 31
    pkmn.iv[:SPECIAL_ATTACK] = 31
    pkmn.iv[:HP] = 31
    pkmn.iv[:SPEED] = 31
    if i < pktext.length
        if pktext[i][0] == "IVs:"
            for j in 0...pktext[i].length / 3
                giveiv(pkmn, (pktext[i][j * 3 + 1]).to_i, pktext[i][j * 3 + 2])
            end
            i += 1
        end
    end
    for j in 0...4
        if i < pktext.length
            if pktext[i][0] == "-"
                nametomove(pkmn, pktext[i][1...pktext[i].length])
                i += 1
            end
        end
    end
    pkmn.calc_stats
    return(pkmn)
end

def genteam(file, inf, sup)
    # main script
    cut = cutfile(file, sup)
    if sup > cut.length
        sup = cut.length
    end
    for i in inf...sup
        pbAddPokemon(caracpkmn(cut[i]))
    end
end

def genrandpkmn(file)
    sup = 10000
    cut = cutfile(file, sup)
    if sup > cut.length
        sup = cut.length
    end
    r = rand(sup)
    return (caracpkmn(cut[r]))
end
