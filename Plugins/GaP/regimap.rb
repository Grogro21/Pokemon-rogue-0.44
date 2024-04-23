def movement(choice,coord)
	if choice=="Up"
		coord[0]-=1
	elsif choice=="Down"
		coord[0]+=1
	elsif choice=="Left"
		coord[1]-=1
	elsif choice=="Right"
		coord[1]+=1
	else
		echoln("invalid choice")
	end
	return coord
end

def camefrom(movemap,choice,coord)
		if choice=="Up" && !movemap[coord[0]][coord[1]].include?("Down")
			movemap[coord[0]][coord[1]].push("Down")
		elsif choice=="Down" && !movemap[coord[0]][coord[1]].include?("Up")
			movemap[coord[0]][coord[1]].push("Up")
		elsif choice=="Left" && !movemap[coord[0]][coord[1]].include?("Right")
			movemap[coord[0]][coord[1]].push("Right")
		elsif choice=="Right" && !movemap[coord[0]][coord[1]].include?("Left")
			movemap[coord[0]][coord[1]].push("Left")
		end
	return movemap
end

def chosedir(map,coord,movemap)
	for dir in map[coord[0]][coord[1]]
		if !movemap[coord[0]][coord[1]].include?(dir)
			movemap[coord[0]][coord[1]].push(dir)
			return dir
		end
	end
	return(map[coord[0]][coord[1]].sample)
end

def basemap(size)
	map=[]
	for i in 0...size
		map.push([])
		for j in 0...size
			map[i].push(["Right","Left","Down","Up"])
			if i==0
				map[i][j].delete("Up")
			end
			if i==size-1
				map[i][j].delete("Down")
			end
			if j==0
				map[i][j].delete("Left")
			end
			if j==size-1
				map[i][j].delete("Right") 
			end			
		end
	end
	bosscoord=[rand(size),rand(size)]
	return([map,bosscoord])
end

def genexit(map,bosscoord)
	size=map.length
	exitcoord=[rand(size),rand(size)] #exit shouldn't be too close to the boss
	while (((bosscoord[0]-exitcoord[0]).abs+(bosscoord[1]-exitcoord[1]).abs)<3)
		exitcoord=[rand(size),rand(size)]		
	end
	return exitcoord
end

def regimap(size,percentage)
	b=basemap(size)
	echoln("basemap done")
	map=b[0]
	bosscoord=b[1]
	exit=genexit(map,bosscoord)
	echoln("exit done")
	vmap=createlabyrinth(map,bosscoord,exit,percentage)
	echoln("labyrinth done")
	return([vmap,bosscoord,exit])
	#créer la basemap
	#générer la sortie
	#créer le labyrinthe
	#check si ça marche
	#et c'est parti
end

def createlabyrinth(basemap,bosscoord,exit,percentage)
	size=basemap.length
	valid=false	
	while valid==false
		map=[]
		for i in 0...size
			map.push([])
			for j in 0...size
				map[i].push(["Right","Left","Down","Up"])
				if i==0
					map[i][j].delete("Up")
				end
				if i==size-1
					map[i][j].delete("Down")
				end
				if j==0
					map[i][j].delete("Left")
				end
				if j==size-1
					map[i][j].delete("Right") 
				end			
			end
		end	
		for i in 0...size
			for j in 0...size
				for k in 0...map[i][j].length
					if ((bosscoord[0]-i).abs+(bosscoord[1]-j).abs)>1
						if rand(100)<percentage
							if map[i][j][-1-k]=="Right"
								map[i][j+1].delete("Left")
							elsif map[i][j][-1-k]=="Left"
								map[i][j-1].delete("Right")
							elsif map[i][j][-1-k]=="Up"
								map[i-1][j].delete("Down")
							elsif map[i][j][-1-k]=="Down"
								map[i+1][j].delete("Up")
							end
						map[i][j].delete_at((-1-k))
						end
					end
				end
			end
		end
		valid=validlab(map,bosscoord,250,exit)
	end
	return(map)
end

def genmap(size)	
	map=[]
	for i in 0...size
		map.push([])
		for j in 0...size
			map[i].push(["Right","Left","Down","Up"])
			if i==0
				map[i][j].delete("Up")
			elsif i==size-1
				map[i][j].delete("Down")
			elsif j==0
				map[i][j].delete("Left")
			elsif j==size-1
				map[i][j].delete("Right") 
			end			
		end
	end
	for i in 0...size
		for j in 0...size
			for k in 0...map[i][j].length
				if rand(100)<25
					if map[i][j][length-1-k]=="Right"
						map[i][j+1].delete("Left")
					elsif map[i][j][length-1-k]=="Left"
						map[i][j-1].delete("Right")
					elsif map[i][j][length-1-k]=="Up"
						map[i-1][j+1].delete("Down")
					else
						map[i+1][j+1].delete("Up")
					end
					map[i][j].delete_at(map[i][j][length-1-k])
				end
			end
		end
	end
	bosscoord=[rand(size),rand(size)]
	map[bosscoord[0]][bosscoord[1]]=["Right","Left","Down","Up"]
	if bosscoord[0]==0
		map[bosscoord[0]][bosscoord[1]].delete("Up")
	elsif bosscoord[0]==size-1
		map[bosscoord[0]][bosscoord[1]].delete("Down")
	elsif bosscoord[1]==0
		map[bosscoord[0]][bosscoord[1]].delete("Left")
	elsif bosscoord[1]==size-1
		map[bosscoord[0]][bosscoord[1]].delete("Right") 
	end	
	return map
end
		
def validlab(map,startpoint,consigne,exitcoord)
	movemap=[]
	for i in 0...map.length
		movemap.push([])
		for j in 0...map[0].length
			movemap[i].push([])
		end
	end
	coord=startpoint.clone
	i=0
	while (i<=consigne && coord!=exitcoord)
		choice=chosedir(map,coord,movemap)
		if !movemap[coord[0]][coord[1]].include?(choice)
			movemap[coord[0]][coord[1]].push(choice)
		end
		coord=movement(choice,coord)
		movemap=camefrom(movemap,choice,coord)
		i+=1
	end	
	return i<consigne
end


def gen_reward(miniboss=false,coord=nil) #génère le type de salle et leur récompense
	t=rand(100)
	if t<5  #event
			type="event"
	elsif t<20 #rare 
			type="rare"
	else #common
			type="normal"
	end
	if rand(100)<50
		trainer=true
	else
		trainer=false
	end
	reward=genreward(type)
	return([type,trainer,reward])
end

def lootmapregi(size,bosscoord,exit)
	map=[]
	for i in 0...size
		map.push([])
		for j in 0...size
			map[i].push(gen_reward())
			vmap=pbGet(63)[0]
			if vmap[i,j]==[]
				map[i].push("secret")
			end
			if [i,j]==bosscoord
				map[i][j]=["boss",:REGIGIGAS]
			end
			if [i,j]==exit
				map[i][j]=["boss","exit"]
			end					
		end
	end
	regilist=[:REGIROCK,:REGICE,:REGISTEEL,:REGIDRAGO,:REGIELEKI]
	for pkmn in regilist
		regi=bosscoord
		while map[regi[0]][regi[1]].include?("boss")
			regi=[rand(size),rand(size)]
		end
		map[regi[0]][regi[1]]=["boss",pkmn]
	end
	return map
end

def adjacent_rewards(lootmap,coord)
	loots=[]
	#Up,right,down,left
	if coord[0]!=0
		loots.push(lootmap[coord[0]-1][coord[1]])
	else
		loots.push(["nothing"])
	end
	if coord[1]!=lootmap.length-1
		loots.push(lootmap[coord[0]][coord[1]+1])
	else
		loots.push(["nothing"])
	end
	if coord[0]!=lootmap.length-1
		loots.push(lootmap[coord[0]+1][coord[1]])
	else
		loots.push(["nothing"])
	end
	if coord[1]!=0
		loots.push(lootmap[coord[0]][coord[1]-1])
	else
		loots.push(["nothing"])
	end
	return(loots)
end

def visited_maps(size)
	map=[]
	for i in 0...size
		map.push([])
		for j in 0...size
			map[i].push([])				
		end
	end
	return map
end

def baseimage1(coord)
	loot=pbGet(64)[pbGet(55)[0]][pbGet(55)[1]]
	if loot[0]=="normal" || loot[0]=="rare" || loot[1]=="exit"
			image="encounter"
	elsif loot[0]=="boss"
		for pkmn in [:REGIROCK,:REGICE,:REGISTEEL,:REGIDRAGO,:REGIELEKI,:REGIGIGAS]
			if loot[1]==pkmn
				image=pkmn.to_s
			end
		end
	else
		image="encounter"
	end
	if loot[1]=="exit"
		ex="exit"
	else
		ex="void"
	end
	return([image,ex])
end

def secretmap(map,coord)
	if ($game_variables[MOVELIST].include?(:EXPLOSION) || $game_variables[MOVELIST].include?(:SELFDESTRUCT)) && $game_switches[81]		
		sizemap=map.length
		map[coord[0]][coord[1]].clear
		map[coord[0]][coord[1]].push("Right")
		map[coord[0]][coord[1]].push("Left")
		map[coord[0]][coord[1]].push("Down")
		map[coord[0]][coord[1]].push("Up")
		map[coord[0]][coord[1]]=map[coord[0]][coord[1]].uniq
		if coord[0]==0
			map[coord[0]][coord[1]].delete("Up")
		elsif coord[0]==sizemap-1
			map[coord[0]][coord[1]].delete("Down")
		elsif coord[1]==0
			map[coord[0]][coord[1]].delete("Left")
		elsif coord[1]==sizemap-1
			map[coord[0]][coord[1]].delete("Right") 
		end	
		size=map[coord[0]][coord[1]].length
		for k in 0...size
			if map[coord[0]][coord[1]][size-1-k]=="Right" && coord[1]!=sizemap-1
				map[coord[0]][coord[1]+1].push("Left")
				map[coord[0]][coord[1]+1]=map[coord[0]][coord[1]+1].uniq
			elsif map[coord[0]][coord[1]][size-1-k]=="Left" && coord[1]!=0
				map[coord[0]][coord[1]-1].push("Right")
				map[coord[0]][coord[1]-1]=map[coord[0]][coord[1]-1].uniq
			elsif map[coord[0]][coord[1]][size-1-k]=="Up" && coord[0]!=0
				map[coord[0]-1][coord[1]].push("Down")
				map[coord[0]-1][coord[1]]=map[coord[0]-1][coord[1]].uniq
			elsif map[coord[0]][coord[1]][size-1-k]=="Down" && coord[0]!=sizemap-1
				map[coord[0]+1][coord[1]].push("Up")
				map[coord[0]+1][coord[1]]=map[coord[0]+1][coord[1]].uniq
			end
		end		
	end
end

def roomtype(lootmap=pbGet(64),coord=pbGet(55))
	if lootmap[coord[0]][coord[1]].length==4
		return("exit")
	end
	if adjacent_rewards(lootmap,coord)[3][0]=="boss"
		pkmn=adjacent_rewards(lootmap,coord)[3][1].to_s
		return(pkmn.substring(1,pkmn.length))
	else
		return("base")
	end
end

def isdoors(map=pbGet(63)[0],coord=pbGet(55))
	directions=map[coord[0]][coord[1]]
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

	MAX = 7
end

module LootType
	COMMON = "normal"
	RARE = "rare"
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
end

class MiniBossEvent < Event
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
		#Display Npc here
		$game_variables[44] = @type
	end
end

class LootEvent < Event
	def fire
		#Display Pokeball here
		$game_switches[84] = true
	end
end

class FuckYouEvent < Event
	attr_accessor :type

	def initialize(type)
		@type = type
	end

	def fire
		#Trigger Battle here
		$game_switches[85] = true
		$game_variables[72] = @type
	end
end

class ExitEvent < Event
	def fire
		#get Pokemon here
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
	
	def onEnter
		if(!@isVisited)
			echoln(@event)
			@event.fire()
		end
		#TODO
	end
	
	def onExit
		#TODO
		$game_variables[44] = NpcType::NOTHING
		self.setVisited()
	end
end

class Labyrinth
	attr_accessor :size
	attr_accessor :rooms
	attr_accessor :exitPos
	attr_accessor :bossPos
	
	def initialize(size)
		@size = size
		@exitPos = nil
		@bossPos = nil
		@rooms = self.createRooms(size)
	end

	def createRooms(size)
		rooms = Array.new(size ** 2) {|r| Room.new}

        bossRoomIdx = rand(0, size ** 2 - 1)
        @bossPos = MathUtils.calcCoords(size, bossRoomIdx)

		begin	
			exitRoomIdx = rand(0, size ** 2 - 1)
			@exitPos = MathUtils.calcCoords(size, exitRoomIdx)
		end while ((@bossPos[0] - @exitPos[0]).abs + (@bossPos[1] - @exitPos[1]).abs < 3)

        echoln(@bossPos)
        echoln(@exitPos)
        echoln("")

		rooms.each do |r|
			case rand(0, 100)
			when 0..10
				r.event = NpcEvent.new(rand(0, NpcType::MAX))
			when 11..60
				r.loot = (rand(0, 100) <= 10) ? genreward(LootType::RARE) : genreward(LootType::COMMON)
			  r.event = LootEvent.new
			else
				r.loot = (rand(0, 100) <= 20) ? genreward(LootType::RARE) : genreward(LootType::COMMON)
			r.event = FuckYouEvent.new((rand(0, 100) <= 10) ? FuckYouType::PAPYBOB : FuckYouType::COOLDUDE)
			end
		end

		rooms[bossRoomIdx].event = BossEvent.new
		rooms[exitRoomIdx].event = ExitEvent.new
		rooms[exitRoomIdx].loot = ["pokemon", nil, -1]

		# regirock regice registeel regieleki regidrago

		begin
			regirockRoomIdx = rand(0, size ** 2 - 1)
		end while (regirockRoomIdx == bossRoomIdx || regirockRoomIdx == exitRoomIdx)
		rooms[regirockRoomIdx].event = MiniBossEvent.new(:REGIROCK)
		echoln(MathUtils.calcCoords(size, regirockRoomIdx))

		begin
			regiceRoomIdx = rand(0, size ** 2 - 1)
		end while (regiceRoomIdx == bossRoomIdx || regiceRoomIdx == exitRoomIdx || regiceRoomIdx == regirockRoomIdx)
		rooms[regiceRoomIdx].event = MiniBossEvent.new(:REGICE)
		echoln(MathUtils.calcCoords(size, regiceRoomIdx))

		begin
			registeelRoomIdx = rand(0, size ** 2 - 1)
		end while (registeelRoomIdx == bossRoomIdx || registeelRoomIdx == exitRoomIdx || registeelRoomIdx == regirockRoomIdx || registeelRoomIdx == regiceRoomIdx)
		rooms[registeelRoomIdx].event = MiniBossEvent.new(:REGISTEEL)
		echoln(MathUtils.calcCoords(size, registeelRoomIdx))

		begin
			regielekiRoomIdx = rand(0, size ** 2 - 1)
		end while (regielekiRoomIdx == bossRoomIdx || regielekiRoomIdx == exitRoomIdx || regielekiRoomIdx == regirockRoomIdx || regielekiRoomIdx == regiceRoomIdx || regielekiRoomIdx == registeelRoomIdx)
		rooms[regielekiRoomIdx].event = MiniBossEvent.new(:REGIELEKI)
		echoln(MathUtils.calcCoords(size, regielekiRoomIdx))

		begin
			regidragoRoomIdx = rand(0, size ** 2 - 1)
		end while (regidragoRoomIdx == bossRoomIdx || regidragoRoomIdx == exitRoomIdx || regidragoRoomIdx == regirockRoomIdx || regidragoRoomIdx == regiceRoomIdx || regidragoRoomIdx == registeelRoomIdx || regidragoRoomIdx == regielekiRoomIdx)
		rooms[regidragoRoomIdx].event = MiniBossEvent.new(:REGIDRAGO)
		echoln(MathUtils.calcCoords(size, regidragoRoomIdx))

		echoln("")

		# LES PORTES MON GARS

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
end
