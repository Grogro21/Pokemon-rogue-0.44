MenuHandlers.add(:party_menu, :rename, {
    "name" => _INTL("Rename"),
    "order" => 11,
    "effect" => proc { |screen, party, party_idx|
        pkmn = party[party_idx]
        species = pkmn.speciesName
        pbTextEntry("#{species}'s nickname?", 0, Pokemon::MAX_NAME_SIZE, 5)
        nickname = pbGet(5)
        unless nickname == ""
            pkmn.name = nickname
        end
    }
})
