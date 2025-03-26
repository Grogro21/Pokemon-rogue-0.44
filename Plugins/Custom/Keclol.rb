def audinite_gift
    pbMessage("Do you like Audino? It's my favorite Pokémon.")

    unless $bag.quantity(:AUDINITE) == 9990
        return
    end

    pbMessage("Oh, you have 10 stacks of Audinites! Take this!")
    pbItemBall(:LGBTSPRAY, 1)
    $bag.remove(:AUDINITE, 9990)

end

