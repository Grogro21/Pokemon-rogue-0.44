EventHandlers.add(:on_trainer_load, :clone,
  proc { |trainer|
   if trainer   # An NPCTrainer object containing party/items/lose text, etc.  
     if (trainer.trainer_type==:GHOST || $game_switches[63]) #the clone trainer type
       partytoload=$player.party
       for i in 0...6
         if i<$player.party_count && !partytoload[i].egg?
           trainer.party[i]=partytoload[i].clone
           trainer.party[i].heal     #remove this to make a not perfect
         else                            #copy of the party
           trainer.party.pop()
        end
       end
     end
   end
  }
)