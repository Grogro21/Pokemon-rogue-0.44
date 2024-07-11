def gen_reward(miniboss = false, coord = nil)
    # génère le type de salle et leur récompense
    t = rand(100)
    if t < 5 # event
        type = "event"
    elsif t < 20 # rare
        type = "rare"
    else
        # common
        type = "normal"
    end
    if rand(100) < 50
        trainer = true
    else
        trainer = false
    end
    reward = genreward(type)
    return([type, trainer, reward])
end

def baseimage1(coord)
    image = "encounter"
    if self[0] == "boss"
        for pkmn in [:REGIROCK, :REGICE, :REGISTEEL, :REGIDRAGO, :REGIELEKI, :REGIGIGAS]
            if self[1] == pkmn
                image = pkmn.to_s
                break
            end
        end
    end
    ex = "void"
    if self[1] == "exit"
        ex = "exit"
    end

    return([image, ex])
end

def isdoors(map = pbGet(63)[0], coord = pbGet(55))
    directions = map[coord[0]][coord[1]]
    if !directions.include?("Left")
        directions.push("void")
    end
    if !directions.include?("Up")
        directions.push("void")
    end
    if !directions.include?("Right")
        directions.push("void")
    end
    if !directions.include?("Down")
        directions.push("void")
    end
    return directions
end

module NpcType
    NOTHING = 0
    HEAL = 1
    PKMN_SHOP = 2
    TM_SHOP = 3
    MOVE_TUTOR = 4
    IV_UP = 5
    TERACLOPE = 6
end

module LootType
    COMMON = "normal"
    RARE = "rare"
    SECRET = "secret"
end

module FuckYouType
    COOLDUDE = 0
    PAPYBOB = 1
end

class Event
    def fire
    end
end

class BossEvent < Event
    attr_accessor :regiName

    def initialize(regiName)
        @regiName = regiName
    end
end

class NpcEvent < Event
    attr_accessor :type

    def initialize(type)
        @type = type
    end

    def fire
        # Display Npc here
        $game_variables[44] = @type

        if @type == NpcType::TM_SHOP
            $game_variables[49] = [:ABILITYCAPSULE, :ABILITYPATCH,
                                   getrandomtm, getrandomtm, getrandomtm, getrandomtm, getrandomtm,
                                   getrandomtm, getrandomtm, getrandomtm, getrandomtm, getrandomtm]
        end
    end
end

class LootEvent < Event
    def fire
        # Display Pokeball here
        $game_switches[84] = true
    end
end

class FuckYouEvent < Event
    attr_accessor :type

    def initialize(type)
        @type = type
    end

    def fire
        # Trigger Battle here
        $game_switches[85] = true
        $game_variables[72] = @type
    end
end

class ExitEvent < Event
    def fire
        # get Pokemon here
        playerIdx = MathUtils.calcIdx(pbGet(63).size, pbGet(69))
        getreward(*pbGet(63).rooms[playerIdx].loot)
    end
end

class Room
    attr_accessor :event
    attr_accessor :isVisited
    attr_accessor :loot
    attr_accessor :doors

    def initialize
        @event = nil
        @isVisited = false
        @loot = nil
        @doors = ["up", "right", "left", "down"]
    end

    def setVisited
        @isVisited = true
    end

    def onBeforeEnter
        $game_variables[100] = 101

        if @event.instance_of? BossEvent
            case @event.regiName
            when :REGICE
                $game_variables[100] = 98
            when :REGISTEEL
                $game_variables[100] = 97
            when :REGIROCK
                $game_variables[100] = 95
            when :REGIELEKI
                $game_variables[100] = 94
            when :REGIDRAGO
                $game_variables[100] = 93
            when :REGIGIGAS
                $game_variables[100] = 100
            end
        end

        case pbGet(75)
        when 'r'
            $game_variables[98] = 14
            $game_variables[99] = 8
        when 'l'
            $game_variables[98] = 4
            $game_variables[99] = 8
        when 'u'
            $game_variables[98] = 9
            $game_variables[99] = 12
        when 'd'
            $game_variables[98] = 9
            $game_variables[99] = 4
        end
    end

    def onEnter
        if @event.instance_of? ExitEvent
            pbMapInterpreter.pbSetSelfSwitch(8, "A", true)
        end
        unless @isVisited
            @event.fire()
            unless @event.instance_of? ExitEvent
                $player.party.each do |pkmn|
                    if pkmn.level < pbGet(67)
                        lvlup(pkmn, 1)
                    end
                end
            end
        end
    end

    def onExit
        if @event.instance_of? ExitEvent
            pbMapInterpreter.pbSetSelfSwitch(8, "A", false)
        end
        $game_variables[44] = NpcType::NOTHING
        self.setVisited()
    end

    def getImage()
        image = "encounter"
        if @event.instance_of? BossEvent
            for pkmn in [:REGIROCK, :REGICE, :REGISTEEL, :REGIDRAGO, :REGIELEKI, :REGIGIGAS]
                if @event.regiName == pkmn
                    image = pkmn.to_s
                    break
                end
            end
        end

        ex = "void"
        if @event.instance_of? ExitEvent
            ex = "exit"
        end

        return([image, ex])
    end
end

class Labyrinth
    attr_accessor :size
    attr_accessor :rooms
    attr_accessor :exitPos
    attr_accessor :bossPos

    def initialize(size)
        $game_variables[MOVELIST] = []
        @size = size
        @exitPos = nil
        @bossPos = nil
        begin
            @rooms = self.createRooms(size)
            $game_variables[69] = @exitPos
        end until self.isValid?
    end

    def cameFrom(moveMap, choice, coord)
        case
        when choice == "up" && !moveMap[coord[0]][coord[1]].include?("down")
            moveMap[coord[0]][coord[1]].push("down")
        when choice == "down" && !moveMap[coord[0]][coord[1]].include?("up")
            moveMap[coord[0]][coord[1]].push("up")
        when choice == "left" && !moveMap[coord[0]][coord[1]].include?("right")
            moveMap[coord[0]][coord[1]].push("right")
        when choice == "right" && !moveMap[coord[0]][coord[1]].include?("left")
            moveMap[coord[0]][coord[1]].push("left")
        else
            echoln("mon uq!")
        end

        return moveMap
    end

    def choseDir(coord, moveMap)
        lineCoord = MathUtils.calcIdx(@size, coord)

        rooms[lineCoord].doors.each { |dir|
            if !moveMap[coord[0]][coord[1]].include?(dir)
                moveMap[coord[0]][coord[1]].push(dir)

                return dir
            end
        }

        return rooms[lineCoord].doors.sample
    end

    def isValid?()
        coord = @exitPos.dup
        boss = @bossPos.dup
        movemap = []
        (0...@size).each { |i|
            movemap.push([])
            (0...@size).each { |j|
                movemap[i].push([])
            }
        }

        i = 0
        maxMove = 50
        while i <= maxMove && coord[0] != boss[0] && coord[1] != boss[1]
            choice = choseDir(coord, movemap)
            unless movemap[coord[0]][coord[1]].include?(choice)
                movemap[coord[0]][coord[1]].push(choice)
            end
            coord = movement(choice, coord)
            movemap = cameFrom(movemap, choice, coord)
            i += 1
        end

        return i <= maxMove
    end

    def createRooms(size)
        rooms = Array.new(size ** 2) { |r| Room.new }

        bossRoomIdx = rand(0, size ** 2 - 1)
        @bossPos = MathUtils.calcCoords(size, bossRoomIdx)

        begin
            exitRoomIdx = rand(0, size ** 2 - 1)
            @exitPos = MathUtils.calcCoords(size, exitRoomIdx)
        end while ((@bossPos[0] - @exitPos[0]).abs + (@bossPos[1] - @exitPos[1]).abs < 3)

        rooms.each do |r|
            case rand(0, 100)
            when 0...10
                r.event = NpcEvent.new(rand(0, NpcType::TERACLOPE))
            when 11...60
                r.loot = (rand(0, 100) <= 10) ? genreward(LootType::RARE) : genreward(LootType::COMMON)
                r.event = LootEvent.new
            else
                r.loot = (rand(0, 100) <= 20) ? genreward(LootType::RARE) : genreward(LootType::COMMON)
                r.event = FuckYouEvent.new((rand(0, 100) <= 10) ? FuckYouType::PAPYBOB : FuckYouType::COOLDUDE)
            end
        end

        # LES PORTES MON GARS

        (0..size ** 2 - 1).each { |i|
            if MathUtils.isEdge(size, i)
                coords = MathUtils.calcCoords(size, i)
                if coords[0] == 0
                    rooms[i].doors -= ["left"]
                end
                if coords[1] == 0
                    rooms[i].doors -= ["down"]
                end
                if coords[0] == size - 1
                    rooms[i].doors -= ["right"]
                end
                if coords[1] == size - 1
                    rooms[i].doors -= ["up"]
                end
            end

            door = rand(0, 15)
            if door[0] == 1
                rooms[i].doors -= ["left"]
            end
            if door[1] == 1
                rooms[i].doors -= ["down"]
            end
            if door[2] == 1
                rooms[i].doors -= ["right"]
            end
            if door[3] == 1
                rooms[i].doors -= ["up"]
            end
        }

        (1..size ** 2 - 1).each { |i|
            coords = MathUtils.calcCoords(size, i)

            if coords[0] > 0 && rooms[MathUtils.calcIdx(size, [coords[0] - 1, coords[1]])].doors.include?("right") && !rooms[i].doors.include?("left")
                rooms[i].doors += ["left"]
            end
            if coords[0] < size - 1 && rooms[MathUtils.calcIdx(size, [coords[0] + 1, coords[1]])].doors.include?("left") && !rooms[i].doors.include?("right")
                rooms[i].doors += ["right"]
            end
            if coords[1] > 0 && rooms[MathUtils.calcIdx(size, [coords[0], coords[1] - 1])].doors.include?("up") && !rooms[i].doors.include?("down")
                rooms[i].doors += ["down"]
            end
            if coords[1] < size - 1 && rooms[MathUtils.calcIdx(size, [coords[0], coords[1] + 1])].doors.include?("down") && !rooms[i].doors.include?("up")
                rooms[i].doors += ["up"]
            end
        }

        (1..size ** 2 - 1).each { |i|
            if rooms[i].doors == []
                rooms[i].event = LootEvent.new
                rooms[i].loot = genreward(LootType::SECRET)
            end
        }

        rooms[bossRoomIdx].event = BossEvent.new(:REGIGIGAS)
        rooms[exitRoomIdx].event = ExitEvent.new
        rooms[exitRoomIdx].loot = ["pokemon", nil, -1]

        # regirock regice registeel regieleki regidrago

        begin
            regirockRoomIdx = rand(0, size ** 2 - 1)
        end while (regirockRoomIdx == bossRoomIdx || regirockRoomIdx == exitRoomIdx)
        rooms[regirockRoomIdx].event = BossEvent.new(:REGIROCK)

        begin
            regiceRoomIdx = rand(0, size ** 2 - 1)
        end while (regiceRoomIdx == bossRoomIdx || regiceRoomIdx == exitRoomIdx || regiceRoomIdx == regirockRoomIdx)
        rooms[regiceRoomIdx].event = BossEvent.new(:REGICE)

        begin
            registeelRoomIdx = rand(0, size ** 2 - 1)
        end while (registeelRoomIdx == bossRoomIdx || registeelRoomIdx == exitRoomIdx || registeelRoomIdx == regirockRoomIdx || registeelRoomIdx == regiceRoomIdx)
        rooms[registeelRoomIdx].event = BossEvent.new(:REGISTEEL)

        begin
            regielekiRoomIdx = rand(0, size ** 2 - 1)
        end while (regielekiRoomIdx == bossRoomIdx || regielekiRoomIdx == exitRoomIdx || regielekiRoomIdx == regirockRoomIdx || regielekiRoomIdx == regiceRoomIdx || regielekiRoomIdx == registeelRoomIdx)
        rooms[regielekiRoomIdx].event = BossEvent.new(:REGIELEKI)

        begin
            regidragoRoomIdx = rand(0, size ** 2 - 1)
        end while (regidragoRoomIdx == bossRoomIdx || regidragoRoomIdx == exitRoomIdx || regidragoRoomIdx == regirockRoomIdx || regidragoRoomIdx == regiceRoomIdx || regidragoRoomIdx == registeelRoomIdx || regidragoRoomIdx == regielekiRoomIdx)
        rooms[regidragoRoomIdx].event = BossEvent.new(:REGIDRAGO)

        return rooms
    end
end

class MathUtils
    def self.calcCoords(size, idx)
        return [idx % size, idx / size]
    end

    def self.calcIdx(size, coords)
        return coords[0] + coords[1] * size
    end

    def self.isEdge(size, idx)
        coords = MathUtils.calcCoords(size, idx)

        return coords.include?(0) || coords.include?(size - 1)
    end
end

def movement(choice, coord)
    case choice
    when "up"
        coord[1] += 1
    when "down"
        coord[1] -= 1
    when "left"
        coord[0] -= 1
    when "right"
        coord[0] += 1
    else
        echoln("invalid choice")
    end

    return coord
end
