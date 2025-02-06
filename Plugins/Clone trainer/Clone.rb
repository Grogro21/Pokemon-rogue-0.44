EventHandlers.add(:on_trainer_load, :clone,
                  proc { |trainer|
                      if trainer # An NPCTrainer object containing party/items/lose text, etc.
                          if trainer.trainer_type == :POKEMONTRAINER_Red # the clone trainer type
                              partytoload = $game_variables[77]
                              for i in 0...6
                                  if i < partytoload.length
                                      trainer.party[i] = partytoload[i].clone
                                      trainer.party[i].heal
                                  else
                                      # copy of the party
                                      trainer.party[i] = nil
                                  end
                              end
                          end
                      end
                  }
)
