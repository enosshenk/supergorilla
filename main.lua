--
--	Super Gorilla
-- 	by Enos Shenk
--

--
-- Var time up in here
--

-- Libraries
gameState = require "gamestate"
timer = require "timer"
SGParticles = require "SGParticles"

-- Game state init
local gTitle = {}
local gMenu = {}
local g1PMenu = {}
local g2PMenu = {}
local gRound = {}
local gGameOver = {}

-- Declare some variables
cityGrid = {}				-- Describes the cityscape for drawing and collision
gameMode = 0				-- In-round Game mode. -1=AI process, 0=startup, 1=angle input, 2=power input, 3=firing, 4=resolving, 5=game over
turn = 1					-- Who's turn it is to shoot
gameRounds = 3				-- Rounds to be played before the game ends
gameRoundsElapsed = 0		-- Rounds played elapsed
roundEnding = false			-- True if a round is finishing up, used for delaying the gamestate switch
player1 = true				-- True if player1 is alive, false if his gorilla has been blown up
player2 = true
player1Name = ""			-- Player names
player2Name = ""
player1Wins = 0				-- Elapsed rounds won per player
player2Wins = 0
wind = 0					-- Wind to affect shots, randomly set per round
sunWasHit = false			-- If true, sun displays o-face sprite

-- AI vars
AIDifficulty = "2"			-- Difficulty for AI. 1=easy 5=hard
useAI = false				-- True if the round will use AI for player2
AIThinkMin = 2				-- Min/max values for AI think time
AIThinkMax = 6
AIThinkElapsed = 0
AILastAngle = 0				-- Last angle setting for AI shot
AILastPower = 0				-- Last power settings for AI shot
AILastMoron = false			-- True when our last shot hit building adjacent to us
AIMinAngle = 0				-- Minimum angle to clear adjacent buildings
AILastDistance = 0			-- Distance from impact to target on last AI shot
AILastOverUnder = ""		-- "Over" if last shot overshot the target, "Under" if last shot landed short

-- Player location variables
player1Location = {}
player1Location.x = 0		-- Player1 sprite draw location, set after city generation
player1Location.y = 0
player2Location = {}
player2Location.x = 0
player2Location.y = 0
player1FireLocation = {}
player1FireLocation.x = 0	-- Player 1 fire location. Screen coordinates projectile is spawned at
player1FireLocation.y = 0
player2FireLocation = {}
player2FireLocation.x = 0
player2FireLocation.y = 0

-- String variables
player1AngleIn = ""		-- Strings for player input
player1PowerIn = ""
player2AngleIn = ""	
player2PowerIn = ""
mainMenuIn = ""
inputCursor = ""		-- Flashy fake cursor
cursorOn = false
cursorTime = 0

-- Random AI names
AINames = { "Larry", "Curly", "Moe", "Levi", "Chloe", "Blastron", "xezton", "poemdexter", "InternetJanitor", "Forer", "Jon93", "jusion", "Supernorn", "Unormal", "Shalinor" }
	
-- Bannana vars
bannana = {}
bannana.location = {}
bannana.impactLocation = {}
bannana.velocity = {}
bannana.location.x = 0
bannana.location.y = 0
bannana.impactLocation.x = 0
bannana.impactLocation.y = 0
bannana.velocity.x = 0
bannana.velocity.y = 0
bannana.rotation = 0
bannanaRotationRate = 10		-- How fast bannana rotates per second, in degrees
playDown = true					-- To ensure falling sound only plays once per shot

-- Temp explosion vars
explosionRadius = 32			-- Radius of circle drawn for bannana/building explosion
explosionFade = 2
gorillaExplosionRadius = 128	-- Radius of circle drawn for gorilla death explosion
gorillaExplosionFade = 2

-- Clouds!
clouds = {}						-- A table to hold cloud settings

-- Title screen timing	
titleFadeIn = 2.1				-- Alpha per second for initial titlescreen fade in
titleFadeOut = 2.1				-- Alpha per second for fade out
titleFadeAlpha = 0				-- Current alpha for title screen
titleIsFadeIn = true			-- True if currently fading in
titleIsShow = false
titleIsFadeOut = false
titleShowTime = 5				-- Time titlescreen holds before going to fade out
titleShowTimeElapsed = 0

-- Menu screen vars
menuMode = 0				-- 0 = Entering player 1 name, 1 = Entering player 2 name, 2 = Select rounds

--
-- Main load
--

function love.load()
	-- Load images
	sky = love.graphics.newImage("/images/sky.png")
	background1 = love.graphics.newImage("/images/background1.tga")
	background2 = love.graphics.newImage("/images/background2.tga")
	cloud1Image = love.graphics.newImage("/images/cloud1.tga")
	cloud2Image = love.graphics.newImage("/images/cloud2.tga")
	bannanaImage = love.graphics.newImage("/images/bannana.tga")
	gorillaIdle = love.graphics.newImage("/images/gorilla_idle.tga")
	gorillaThrow = love.graphics.newImage("/images/gorilla_throw.tga")
	gorillaAngry = love.graphics.newImage("/images/gorilla_angry.tga")
	gorillaDead = love.graphics.newImage("/images/gorilla_dead.tga")
	titleScreen = love.graphics.newImage("/images/titlescreen.png")
	menuScreen = love.graphics.newImage("/images/menuscreen.png")
	
	-- Building images
	buildingMid = love.graphics.newImage("/images/building_mid.tga")
	buildingMidD1 = love.graphics.newImage("/images/building_mid_dam1.tga")
	buildingMidD2 = love.graphics.newImage("/images/building_mid_dam2.tga")
	buildingMidD3 = love.graphics.newImage("/images/building_mid_dam3.tga")
	buildingTop1 = love.graphics.newImage("/images/building_top1.tga")
	buildingTop1D1 = love.graphics.newImage("/images/building_top1_dam1.tga")
	buildingTop2 = love.graphics.newImage("/images/building_top2.tga")
	buildingTop2D1 = love.graphics.newImage("/images/building_top2_dam1.tga")
	buildingTop3 = love.graphics.newImage("/images/building_top3.tga")	
	buildingTop3D1 = love.graphics.newImage("/images/building_top3_dam1.tga")
	buildingTopD2 = love.graphics.newImage("/images/building_top_dam2.tga")
	buildingTopD3 = love.graphics.newImage("/images/building_top_dam3.tga")

	-- Sun images
	sunStraight = love.graphics.newImage("/images/sun_straight.tga")
	sunLeft = love.graphics.newImage("/images/sun_left.tga")
	sunRight = love.graphics.newImage("/images/sun_right.tga")
	sunOFace = love.graphics.newImage("/images/sun_oface.tga")	
	sun = nil
	
	-- Load some sounds
	sBannanaExplode = love.audio.newSource("/sounds/bannana_impact.ogg")
	sBannanaUp = love.audio.newSource("/sounds/bannana_up.ogg")
	sBannanaDown = love.audio.newSource("/sounds/bannana_down.ogg")
	sGorillaExplode = love.audio.newSource("/sounds/gorilla_die.ogg")
	sKeypress = love.audio.newSource("/sounds/keypress.ogg")
	sBackspace = love.audio.newSource("/sounds/backspace.ogg")
	sConfirm = love.audio.newSource("/sounds/confirm.ogg")
	
	-- Load font
	gorillaFont = love.graphics.newImageFont("/images/imagefont.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"\\@>")
	
	-- Random the seed all up in this bitch
	math.randomseed(os.time())
	
	gameState.registerEvents()
	gameState.switch(gTitle)
	print("Switching to gamestate Title")
end

--
-- Titlescreen gamestate
--

function gTitle:update(dt)
	if titleIsFadeIn == false and titleIsShow == true and titleIsFadeOut == false then
		titleShowTimeElapsed = titleShowTimeElapsed + dt
	end
end

function gTitle:draw()
	if titleIsFadeIn == true and titleIsShow == false and titleIsFadeOut == false then
		-- Fade in
		print("Fade in - Alpha: "..titleFadeAlpha)
		love.graphics.setColor(255, 255, 255, titleFadeAlpha)
		titleFadeAlpha = titleFadeAlpha + titleFadeIn
		if titleFadeAlpha >= 255 then
			titleIsFadeIn = false
			titleIsShow = true
		end
	elseif titleIsFadeIn == false and titleIsShow == true and titleIsFadeOut == false then
		-- Hold display
		print("Show screen - Time: "..titleShowTimeElapsed)
		love.graphics.setColor(255, 255, 255, 255)
		if titleShowTimeElapsed >= titleShowTime then
			titleIsShow = false
			titleIsFadeOut = true
		end
	elseif titleIsFadeIn == false and titleIsShow == false and titleIsFadeOut == true then
		-- Fade out
		print("Fade out - Alpha: "..titleFadeAlpha)
		love.graphics.setColor(255, 255, 255, titleFadeAlpha)
		titleFadeAlpha = titleFadeAlpha - titleFadeOut
		if titleFadeAlpha <= 0 then
			-- Go to menu
			print("Title finished, moving to menu")
			gameState.switch(gMenu)
		end	
	end
	-- Draw graphic
	love.graphics.draw(titleScreen, 0, 0)
end

function gTitle:keypressed(key, code)
	-- Go to next state
	print("Title aborted, moving to menu")
	gameState.switch(gMenu)
end

--
-- Game mode menu gamestate
--

function gMenu:enter()
	mainMenuIn = ""
end

function gMenu:update(dt)
	-- Update fake cursor
	cursorTime = cursorTime + dt
	if cursorTime > 0.2 then
		if cursorOn == true then
			cursorOn = false
			inputCursor = ""
			cursorTime = 0
		else
			cursorOn = true
			inputCursor = "."
			cursorTime = 0
		end
	end
end

function gMenu:keypressed(key, code)
	-- Enter player amount
	if key == "1" or key == "2" then
		if string.len(mainMenuIn) < 1 then
			-- Can fit more characters, append
			if string.len(key) < 3 then
				-- Play sound
				love.audio.play(sKeypress)
				mainMenuIn = mainMenuIn..key
			end
		end
	elseif key == "return" then
		-- Play sound
		love.audio.play(sConfirm)
		if mainMenuIn == "1" then
			-- Lock in players, change game state
			print("Player number locked in, moving to 1p menu gamestate")
			useAI = true
			gameState.switch(g1PMenu)
		elseif mainMenuIn == "2" then
			-- Lock in players, change game state
			print("Player number locked in, moving to 2p menu gamestate")	
			gameState.switch(g2PMenu)		
		end
	elseif key == "backspace" then
		-- Delete last character
		mainMenuIn = string.sub(mainMenuIn, 1, string.len(mainMenuIn) - 1)
		-- Play sound
		love.audio.play(sBackspace)			
	end			
end

function gMenu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(menuScreen, 0, 0)
	love.graphics.setFont(gorillaFont)

	love.graphics.printf("Do you want to play a one or two player game?", 128, 250, 512, "left")
	love.graphics.printf("Enter 1 or 2, or Escape to quit.", 128, 280, 512, "left")
	love.graphics.printf("C:\\GORILLA\\> "..mainMenuIn..inputCursor, 128, 310, 512, "left")	
end

--
--	1 Player Menu gamestate
--

function g1PMenu:enter()
	menuMode = 0
	AIDifficulty = "2"
	gameRounds = "3"
end

function g1PMenu:update(dt)
	-- Update fake cursor
	cursorTime = cursorTime + dt
	if cursorTime > 0.2 then
		if cursorOn == true then
			cursorOn = false
			inputCursor = ""
			cursorTime = 0
		else
			cursorOn = true
			inputCursor = "."
			cursorTime = 0
		end
	end
end

function g1PMenu:keypressed(key, code)
	if menuMode == 3 then
		-- Enter AI difficulty
		if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
			if string.len(AIDifficulty) < 1 then
				-- Can fit more characters, append
				if string.len(key) < 3 then
					-- Play sound
					love.audio.play(sKeypress)
					AIDifficulty = AIDifficulty..key
				end
			end
		elseif key == "return" then
			-- Lock in difficulty, change game state
			print("Rounds locked in, moving to round gamestate")
			-- Play sound
			love.audio.play(sConfirm)	
			AIDifficulty = tonumber(AIDifficulty)
			gameState.switch(gRound)
		elseif key == "backspace" then
			-- Delete last character
			AIDifficulty = string.sub(AIDifficulty, 1, string.len(AIDifficulty) - 1)
			-- Play sound
			love.audio.play(sBackspace)			
		end			
	end
	if menuMode == 2 then
		-- Enter round amount
		if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
			if string.len(gameRounds) < 2 then
				-- Can fit more characters, append
				if string.len(key) < 3 then
					-- Play sound
					love.audio.play(sKeypress)
					gameRounds = gameRounds..key
				end
			end
		elseif key == "return" then
			-- Lock in round amount, change game state
			print("Rounds locked in, moving to AI difficulty")
			gameRounds = tonumber(gameRounds)
			-- Play sound
			love.audio.play(sConfirm)	
			menuMode = 3
		elseif key == "backspace" then
			-- Delete last character
			gameRounds = string.sub(gameRounds, 1, string.len(gameRounds) - 1)
			-- Play sound
			love.audio.play(sBackspace)			
		end			
	end
	if menuMode == 1 then
		-- Enter player 2 name
		if key ~= "return" and key ~= "backspace" then
			if string.len(player2Name) < 20 then
				-- Can fit more characters, append
				if string.len(key) < 2 then
					-- Play sound
					love.audio.play(sKeypress)
					player2Name = player2Name..key
				end
			end
		elseif key == "return" then
			-- Lock in name
			print("Player 2 name locked in, moving to requesting rounds")
			-- Play sound
			love.audio.play(sConfirm)
			if player2Name ~= "" then
				player2Name = string.gsub(player2Name, "%a", string.upper, 1)
			else
				player2Name = "@"..AINames[math.random(#AINames)]
			end
			menuMode = 2
		elseif key == "backspace" then
			-- Delete last character
			player2Name = string.sub(player2Name, 1, string.len(player2Name) - 1)	
			-- Play sound
			love.audio.play(sBackspace)
		end	
	end
	if menuMode == 0 then
		-- Enter player 1 name
		if key ~= "return" and key ~= "backspace" then
			if string.len(player1Name) < 20 then
				-- Can fit more characters, append
				if string.len(key) < 3 then
					-- Play sound
					love.audio.play(sKeypress)
					player1Name = player1Name..key
				end
			end
		elseif key == "return" then
			-- Lock in name
			print("Player 1 name locked in, moving to requesting player 2 name")
			player1Name = string.gsub(player1Name, "%a", string.upper, 1)
			menuMode = 1
			-- Play sound
			love.audio.play(sConfirm)	
		elseif key == "backspace" then
			-- Delete last character
			player1Name = string.sub(player1Name, 1, string.len(player1Name) - 1)
			-- Play sound
			love.audio.play(sBackspace)			
		end
	end
end

function g1PMenu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(menuScreen, 0, 0)
	love.graphics.setFont(gorillaFont)
	
	if menuMode == 0 then
		love.graphics.printf("Enter Player 1 name.", 128, 250, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..player1Name..inputCursor, 128, 280, 512, "left")
	elseif menuMode == 1 then
		love.graphics.printf(player1Name, 128, 250, 512, "left")
		love.graphics.printf("Vs.", 128, 280, 512, "left")
		love.graphics.printf("Enter Player 2 name (Or leave blank for random.)", 128, 310, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..player2Name..inputCursor, 128, 340, 512, "left")
	elseif menuMode == 2 then
		love.graphics.printf(player1Name, 128, 250, 512, "left")
		love.graphics.printf("Vs.", 128, 280, 512, "left")
		love.graphics.printf(player2Name, 128, 310, 512, "left")	
		love.graphics.printf("Play how many rounds?", 128, 340, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..gameRounds..inputCursor, 128, 370, 512, "left")
	elseif menuMode == 3 then
		love.graphics.printf(player1Name, 128, 250, 512, "left")
		love.graphics.printf("Vs.", 128, 280, 512, "left")
		love.graphics.printf(player2Name, 128, 310, 512, "left")	
		love.graphics.printf("Rounds: "..gameRounds, 128, 340, 512, "left")
		love.graphics.printf("Enter AI difficulty (1 to 5)", 128, 370, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..AIDifficulty..inputCursor, 128, 400, 512, "left")	
	end
end

--
-- 2 Player Menu gamestate
--

function g2PMenu:enter()
	menuMode = 0
end

function g2PMenu:update(dt)
	-- Update fake cursor
	cursorTime = cursorTime + dt
	if cursorTime > 0.2 then
		if cursorOn == true then
			cursorOn = false
			inputCursor = ""
			cursorTime = 0
		else
			cursorOn = true
			inputCursor = "."
			cursorTime = 0
		end
	end
end

function g2PMenu:keypressed(key, code)
	if menuMode == 2 then
		-- Enter round amount
		if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
			if string.len(gameRounds) < 2 then
				-- Can fit more characters, append
				if string.len(key) < 3 then
					-- Play sound
					love.audio.play(sKeypress)
					gameRounds = gameRounds..key
				end
			end
		elseif key == "return" then
			-- Lock in round amount, change game state
			print("Rounds locked in, moving to round gamestate")
			-- Play sound
			love.audio.play(sConfirm)	
			gameRounds = tonumber(gameRounds)
			gameRoundsElapsed = 0
			gameState.switch(gRound)
		elseif key == "backspace" then
			-- Delete last character
			gameRounds = string.sub(gameRounds, 1, string.len(gameRounds) - 1)
			-- Play sound
			love.audio.play(sBackspace)			
		end			
	end
	if menuMode == 1 then
		-- Enter player 2 name
		if key ~= "return" and key ~= "backspace" then
			if string.len(player2Name) < 20 then
				-- Can fit more characters, append
				if string.len(key) < 2 then
					-- Play sound
					love.audio.play(sKeypress)
					player2Name = player2Name..key
				end
			end
		elseif key == "return" then
			-- Lock in name
			print("Player 2 name locked in, moving to requesting rounds")
			-- Play sound
			love.audio.play(sConfirm)	
			player2Name = string.gsub(player2Name, "%a", string.upper, 1)
			menuMode = 2
		elseif key == "backspace" then
			-- Delete last character
			player2Name = string.sub(player2Name, 1, string.len(player2Name) - 1)	
			-- Play sound
			love.audio.play(sBackspace)
		end	
	end
	if menuMode == 0 then
		-- Enter player 1 name
		if key ~= "return" and key ~= "backspace" then
			if string.len(player1Name) < 20 then
				-- Can fit more characters, append
				if string.len(key) < 3 then
					-- Play sound
					love.audio.play(sKeypress)
					player1Name = player1Name..key
				end
			end
		elseif key == "return" then
			-- Lock in name
			print("Player 1 name locked in, moving to requesting player 2 name")
			player1Name = string.gsub(player1Name, "%a", string.upper, 1)
			menuMode = 1
			-- Play sound
			love.audio.play(sConfirm)	
		elseif key == "backspace" then
			-- Delete last character
			player1Name = string.sub(player1Name, 1, string.len(player1Name) - 1)
			-- Play sound
			love.audio.play(sBackspace)			
		end
	end
end

function g2PMenu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(menuScreen, 0, 0)
	love.graphics.setFont(gorillaFont)
	
	if menuMode == 0 then
		love.graphics.printf("Enter Player 1 name.", 128, 250, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..player1Name..inputCursor, 128, 280, 512, "left")
	elseif menuMode == 1 then
		love.graphics.printf(player1Name, 128, 250, 512, "left")
		love.graphics.printf("Vs.", 128, 280, 512, "left")
		love.graphics.printf("Enter Player 2 name.", 128, 310, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..player2Name..inputCursor, 128, 340, 512, "left")
	elseif menuMode == 2 then
		love.graphics.printf(player1Name, 128, 250, 512, "left")
		love.graphics.printf("Vs.", 128, 280, 512, "left")
		love.graphics.printf(player2Name, 128, 310, 512, "left")	
		love.graphics.printf("Play how many rounds?", 128, 340, 512, "left")
		love.graphics.printf("C:\\GORILLA\\> "..gameRounds..inputCursor, 128, 370, 512, "left")
	end
end

--
-- Game Over gamestate
--

function gGameOver:keypressed(key, code)
	if key == "return" then
		-- Play again! Go back to main menu
		gameMode = 0
		turn = 1
		gameRounds = 3
		gameRoundsElapsed = 0
		player1 = true
		player2 = true
		player1Name = ""
		player2Name = ""
		player1Wins = 0
		player2Wins = 0
		gameState.switch(gMenu)
	elseif key == "escape" then
		-- Quit the game
		love.event.quit()
	end
end

function gGameOver:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(menuScreen, 0, 0)
	love.graphics.setFont(gorillaFont)
	
	if player1Wins > player2Wins then
		love.graphics.printf(player1Name.." wins the game!", 256, 250, 256, "center")
	elseif player2Wins > player1Wins then
		love.graphics.printf(player2Name.." wins the game!", 256, 250, 256, "center")
	elseif player1Wins == player2Wins then
		love.graphics.printf("A tie! Nobody wins!", 256, 250, 256, "center")	
	end
	
	love.graphics.printf("Press Enter to play again, or press Escape to quit.", 256, 350, 256, "center")	
end

--
-- In Match gamestate
--

function gRound:enter()
	newGame()
end

function newGame()
	-- Make sure game vars are reset
	turn = 1
	player1 = true
	player2 = true
	player1AngleIn = ""
	player2AngleIn = ""
	player1PowerIn = ""
	player2PowerIn = ""
	resetAI()
	
	-- Pick a background
	if math.random(4) > 2 then
		background = background1
	else
		background = background2
	end
	
	-- Generate initial cloud settings
	for i=1, 4 do
		clouds[i] = {}
		if math.random(4) > 2 then
			clouds[i]["tile"] = cloud1Image
		else
			clouds[i]["tile"] = cloud2Image
		end
		clouds[i]["x"] = math.random(0, 768)
		clouds[i]["y"] = math.random(-32, 192)
	end
	
	-- Generate the city grid
	for x=1, 12 do
		cityGrid[x] = {}
		-- Generate a column height and save it in the X column
		cityGrid[x]["height"] = 2 + math.random(6)
		-- Generate a randomized color tint for this column
		cityGrid[x]["color"] = {}
		cityGrid[x]["color"]["r"] = math.random(150, 255)
		cityGrid[x]["color"]["g"] = math.random(150, 255)
		cityGrid[x]["color"]["b"] = math.random(150, 255)
		for y=1, 8 do		
			cityGrid[x][y] = {}
			if y < cityGrid[x]["height"] then
				-- Above roof level, empty space
				cityGrid[x][y]["type"] = 0
			elseif y == cityGrid[x]["height"] then
				-- Roof level, pick a random roof tile
				cityGrid[x][y]["type"] = 1
				local chance = math.random(6)
				if chance == 1 then
					cityGrid[x][y]["tile"] = buildingTop1
				elseif chance > 1 and chance < 4 then
					cityGrid[x][y]["tile"] = buildingTop2
				else
					cityGrid[x][y]["tile"] = buildingTop3
				end
			elseif y > cityGrid[x]["height"] then
				-- Below roof level, building
				cityGrid[x][y]["type"] = 2
				cityGrid[x][y]["tile"] = buildingMid
			end
			-- Set up for tile damage
			cityGrid[x][y]["damage"] = 0
		end
	end
	
	-- Set up player sprite locations
	player1Location.x = 65
	player1Location.y = (cityGrid[2]["height"] - 1) * 64 - 32
	player2Location.x = 641
	player2Location.y = (cityGrid[11]["height"] - 1) * 64 - 32
	
	-- Set player bannana spawn locations
	player1FireLocation.x = 97										-- Loc is +32, half of gorilla sprite
	player1FireLocation.y = (cityGrid[2]["height"] - 1) * 64 - 32	-- y loc is same as sprite draw location
	player2FireLocation.x = 673
	player2FireLocation.y = (cityGrid[11]["height"] - 1) * 64 - 32
	
	-- Randomize wind
	wind = math.random(-10, 10)
	
	-- Move to game mode 1
	gameMode = 1
	print("Finished load, moving to game mode "..gameMode)
end

function endGame(victor)
	if victor == 1 then
		-- Player 1 wins
		player1Wins = player1Wins + 1
	elseif victor == 2 then
		-- Player 2 wins
		player2Wins = player2Wins + 1
	end
	-- Increment rounds counter
	gameRoundsElapsed = gameRoundsElapsed + 1
	-- Clear particle tables
	SGParticles.clearParticles()
	if gameRoundsElapsed > gameRounds then
		-- Game is over, go to victory screen
		gameState.switch(gGameOver)
	else
		-- Start a new game
		newGame()
	end
end

function gRound:update(dt)
	-- Toggle the inputCursor string on or off to give feedback
	if gameMode == 1 or gameMode == 2 then
		cursorTime = cursorTime + dt
		if cursorTime > 0.2 then
			if cursorOn == true then
				cursorOn = false
				inputCursor = ""
				cursorTime = 0
			else
				cursorOn = true
				inputCursor = "."
				cursorTime = 0
			end
		end
	end
	
	-- Firing game mode, process the bannana
	if gameMode == 3 then
		bannana.velocity.y = bannana.velocity.y + 0.1
		bannana.location.x = (bannana.location.x + bannana.velocity.x) + (wind / 10)
		bannana.location.y = bannana.location.y + bannana.velocity.y
		
		-- Update bannana rotation
		bannana.rotation = bannana.rotation + bannanaRotationRate
		if bannana.rotation > 360 then
			bannana.rotation = 0
		end	
		-- Update sound
		if bannana.velocity.y > 0 then
			love.audio.stop(sBannanaUp)
			if playDown == true then
				love.audio.play(sBannanaDown)
				playDown = false
			end
		end
		-- Check for off-screen conditions
		if bannana.location.x > 768 or bannana.location.x < 1 or bannana.location.y > 512 then
			-- Stop bannana flight sounds
			love.audio.stop(sBannanaUp)
			love.audio.stop(sBannanaDown)
			playDown = true
			-- Evaluate shot for AI
			if turn == 2 and useAI == true then
				if bannana.location.x > 768 then
					AIEvaluateShot(bannana.location.x, bannana.location.y, false, true)
				elseif bannana.location.x < 1 then
					AIEvaluateShot(bannana.location.x, bannana.location.y, true, false)
				end
			end
			-- End turn
			print("Bannana offscreen, ending turn")
			swapTurn()
		end
		-- Check if we hit the sun
		if bannana.location.x > 350 and bannana.location.x < 414 and bannana.location.y > 32 and bannana.location.y < 94 then
			sunWasHit = true
		end
		-- Check for gorilla collision
		if checkGorillaCollision(bannana.location.x, bannana.location.y) == true then
			if player1 == false then
				bannana.impactLocation.x = player1Location.x + 32
				bannana.impactLocation.y = player1Location.y + 32
			end
			if player2 == false then
				bannana.impactLocation.x = player2Location.x + 32
				bannana.impactLocation.y = player2Location.y + 32
			end
			-- Stop bannana flight sounds
			love.audio.stop(sBannanaUp)
			love.audio.stop(sBannanaDown)
			playDown = true
			-- Play sound
			love.audio.play(sGorillaExplode)
			-- End round things
			resetGorillaExplosion()
			print("Gorilla hit, ending turn")
			gameMode = 4
			
		end
		-- Check for building collision
		if checkCollision(bannana.location.x, bannana.location.y) == true then
			bannana.impactLocation.x = bannana.location.x
			bannana.impactLocation.y = bannana.location.y
			-- Evaluate shot for AI
			if turn == 2 and useAI == true then
				AIEvaluateShot(bannana.location.x, bannana.location.y)
			end
			-- Spawn explosion PS
			SGParticles.newExplosion(bannana.location.x, bannana.location.y)
			-- Spawn debris PS
			SGParticles.newDebris(bannana.location.x + math.random(8), bannana.location.y + math.random(8))
			-- Stop bannana flight sounds
			love.audio.stop(sBannanaUp)
			love.audio.stop(sBannanaDown)
			playDown = true
			-- Play sound
			love.audio.play(sBannanaExplode)
			resetExplosion()
			print("Building hit, ending turn")
			swapTurn()
			sunWasHit = false
		end
	end
	
	if gameMode == 5 and roundEnding == true then
		if player1 == false and player2 == true then
			-- Player 2 wins this round
			timer.add(5, function() endGame(2) end)
			roundEnding = false
		elseif player2 == false and player1 == true then
			-- Player 1 wins this round
			timer.add(5, function() endGame(1) end)		
			roundEnding = false
		end
	end
	
	-- Update the sun
	if gameMode == 3 then
		if sunWasHit == true then
			sun = sunOFace
		else
			if bannana.location.x > 0 and bannana.location.x <= 256 then
				sun = sunLeft
			elseif bannana.location.x > 256 and bannana.location.x < 512 then
				sun = sunStraight
			elseif bannana.location.x >= 512 and bannana.location.x < 768 then
				sun = sunRight
			end
		end
	else
		sun = sunStraight
	end
	
	-- Update extant particle systems in all game modes
	SGParticles.update(dt)
	
	-- Update cloud positions in all game modes
	for i=1, 3 do
		clouds[i]["x"] = clouds[i]["x"] + (wind / 15)
		-- Check for offscreen
		if clouds[i]["x"] > 1024 or clouds[i]["x"] < -256 then
			cloudOffscreen(i)
		end
	end
	
	timer.update(dt)
end

function gRound:keypressed(key, isRepeat)
	if turn == 1 then
		if gameMode == 2 then
			print("Accepting gamemode 2 keypress: "..key)
			if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" or key == "-"then
				-- Input is numeric keys
				if string.len(player1PowerIn) < 2 or (string.len(player1PowerIn) < 3 and string.sub(player1PowerIn, 1, 1) == "-")then
					-- Input string is not full, we can take more input. Concat input key to angleIn
					player1PowerIn = player1PowerIn..key
					-- Play sound
					love.audio.play(sKeypress)
				end
			elseif key == "backspace" then
				-- Remove last character of string
				player1PowerIn = string.sub(player1PowerIn, 1, string.len(player1PowerIn) - 1)
				-- Play sound
				love.audio.play(sBackspace)
			elseif key == "return" then
				print("Locking in power: "..player1PowerIn)
				-- Confirm angle in and proceed
				fireBannana(player1FireLocation.x, player1FireLocation.y, player1AngleIn, player1PowerIn)
			end
		end
		if gameMode == 1 then
			print("Accepting gamemode 1 keypress: "..key)
			if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
				-- Input is numeric keys
				if string.len(player1AngleIn) < 3 then
					-- Input string is not full, we can take more input. Concat input key to angleIn
					player1AngleIn = player1AngleIn..key
					-- Play sound
					love.audio.play(sKeypress)
				end
			elseif key == "backspace" then
				-- Remove last character of string
				player1AngleIn = string.sub(player1AngleIn, 1, string.len(player1AngleIn) - 1)
				-- Play sound
				love.audio.play(sBackspace)
			elseif key == "return" then
				print("Locking in angle: "..player1AngleIn)
				-- Confirm angle in and proceed
				gameMode = 2
				-- Play sound
				love.audio.play(sConfirm)
			end
		end
	else
		if gameMode == 2 then
			print("Accepting gamemode 2 keypress: "..key)
			if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" or key == "-"then
				-- Input is numeric keys
				if string.len(player2PowerIn) < 2 or (string.len(player2PowerIn) < 3 and string.sub(player2PowerIn, 1, 1) == "-")then
					-- Input string is not full, we can take more input. Concat input key to angleIn
					player2PowerIn = player2PowerIn..key
					-- Play sound
					love.audio.play(sKeypress)
				end
			elseif key == "backspace" then
				-- Remove last character of string
				player2PowerIn = string.sub(player2PowerIn, 1, string.len(player2PowerIn) - 1)
				-- Play sound
				love.audio.play(sBackspace)
			elseif key == "return" then
				print("Locking in power: "..player2PowerIn)
				-- Confirm angle in and proceed
				fireBannana(player2FireLocation.x, player2FireLocation.y, player2AngleIn, player2PowerIn)
			end
		end
		if gameMode == 1 then
			print("Accepting gamemode 1 keypress: "..key)
			if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" or key == "0" then
				-- Input is numeric keys
				if string.len(player2AngleIn) < 3 then
					-- Input string is not full, we can take more input. Concat input key to angleIn
					player2AngleIn = player2AngleIn..key
					-- Play sound
					love.audio.play(sKeypress)
				end
			elseif key == "backspace" then
				-- Remove last character of string
				player2AngleIn = string.sub(player2AngleIn, 1, string.len(player2AngleIn) - 1)
				-- Play sound
				love.audio.play(sBackspace)
			elseif key == "return" then
				print("Locking in angle: "..player2AngleIn)
				-- Confirm angle in and proceed
				gameMode = 2
				-- Play sound
				love.audio.play(sConfirm)
			end
		end	
	end
end

--
-- Match functions
--

function fireBannana(spawnX, spawnY, angle, power)
	-- Spawns a new bannana and sets it flying
	bannana.location.x = spawnX
	bannana.location.y = spawnY
	
	-- Invert in angle
	angle = angle * -1

	-- We want angle 0 to be directly right for player 1, directly left for player 2 so we invert our X adjustment
	if turn == 1 then
		bannana.velocity.x = math.sin(math.rad(angle + 90)) * (power / 5)
		bannana.velocity.y = (math.cos(math.rad(angle + 90)) * (power / 5)) * -1		
	else
		bannana.velocity.x = math.sin(math.rad(angle - 90)) * (power / 5)
		bannana.velocity.y = (math.cos(math.rad(angle + 90)) * (power / 5)) * -1		
	
	end
	-- Play sound
	love.audio.play(sBannanaUp)	
	print("Firing bannana! Velocity X:"..bannana.velocity.x.." Y:"..bannana.velocity.y)

	gameMode = 3
end

function checkCollision(x, y)
	-- Checks collision against the city grid, returns true if the bannana hit a building
	local gridX = math.ceil(x / 64)
	local gridY = math.ceil(y / 64)
	
	if bannana.location.y > 0 and bannana.location.x > 0 and bannana.location.x < 768 then
		if cityGrid[gridX][gridY]["type"] == 2 then
			-- Full building segment, bannana collides
			print("Bannana collision! X:"..x.." Y:"..y)
			-- Update building tile
			damageTile(gridX, gridY)
			return true
		elseif cityGrid[gridX][gridY]["type"] == 1 then
			-- Rooftop segment, find if we're hitting the 32 pixel bottom half
			if y > gridY * 64 - 32 then
				print("Bannana collision! X:"..x.." Y:"..y)
				-- Update tile
				damageTile(gridX, gridY)
				return true				
			end
		else
			-- Bannana is in empty space, no collision
			return false
		end
	end
end

function checkGorillaCollision(x, y)
	-- Checks bannana position against gorilla positions, returns true if the bannana destroyed a gorilla
	local gridX = math.ceil(x / 64)
	local gridY = math.ceil(y / 64)
	
	-- Check for collision with a gorilla
	if bannana.location.x > player1Location.x + 10 and bannana.location.x < player1Location.x + 55 then
		if bannana.location.y > player1Location.y + 10 and bannana.location.y < player1Location.y + 60 then
			player1 = false
			-- Damage nearby tiles
			for i=-1, 1 do
				for j=-1, 1 do
					if cityGrid[gridX - i][gridY - j]["type"] > 0 then
						damageTile(gridX - i, gridY - j)
					end
				end
			end
			return true
		end
	elseif bannana.location.x > player2Location.x + 10 and bannana.location.x < player2Location.x + 55 then
		if bannana.location.y > player2Location.y + 10 and bannana.location.y < player2Location.y + 60 then
			player2 = false
			-- Damage nearby tiles
			for i=-1, 1 do
				for j=-1, 1 do
					if cityGrid[gridX - i][gridY - j]["type"] > 0 then
						damageTile(gridX - i, gridY - j)
					end
				end
			end
			return true
		end
	else
		return false
	end
end

function damageTile(x, y)
	-- Reduces the health of the given X,Y tile location and updates the tile graphic
	cityGrid[x][y]["damage"] = cityGrid[x][y]["damage"] + 1
	if cityGrid[x][y]["type"] == 2 then
		if cityGrid[x][y]["damage"] == 1 then
			cityGrid[x][y]["tile"] = buildingMidD1
		elseif cityGrid[x][y]["damage"] == 2 then
			cityGrid[x][y]["tile"] = buildingMidD2
		elseif cityGrid[x][y]["damage"] == 3 then
			cityGrid[x][y]["tile"] = buildingMidD3
		end
	elseif cityGrid[x][y]["type"] == 1 then
		if cityGrid[x][y]["damage"] == 1 then
			if cityGrid[x][y]["tile"] == buildingTop1 then
				cityGrid[x][y]["tile"] = buildingTop1D1
			elseif cityGrid[x][y]["tile"] == buildingTop2 then
				cityGrid[x][y]["tile"] = buildingTop2D1
			else
				cityGrid[x][y]["tile"] = buildingTop3D1
			end
		elseif cityGrid[x][y]["damage"] == 2 then
			cityGrid[x][y]["tile"] = buildingTopD2
		elseif cityGrid[x][y]["damage"] == 3 then
			cityGrid[x][y]["tile"] = buildingTopD3
		end
	end
end

function resetExplosion()
	explosionRadius = 32
end

function resetGorillaExplosion()
	gorillaExplosionRadius = 32
end

function swapTurn()
	-- Handles swapping the current turn, as well as preparing the gamemode prior
	-- Also calls the AI start function if an AI game
	gameMode = 4
	if turn == 1 then
		turn = 2
		player2AngleIn = ""
		player2PowerIn = ""
		if useAI == true then
			timer.add(3, function() AIDoTurn() end)
		else
			timer.add(1, function() gameMode = 1 end)
		end
	else
		turn = 1
		player1AngleIn = ""
		player1PowerIn = ""
		timer.add(1, function() gameMode = 1 end)
	end
end

function cloudOffscreen(i)
	-- Triggered when a cloud has gone past the bounds of the screen. Reset it off-screen from the direction of travel
	if wind > 0 then
		if math.random(4) > 2 then
			clouds[i]["tile"] = cloud1Image
		else
			clouds[i]["tile"] = cloud2Image
		end
		clouds[i]["x"] = -256
		clouds[i]["y"] = math.random(-32, 192)	
	else
		if math.random(4) > 2 then
			clouds[i]["tile"] = cloud1Image
		else
			clouds[i]["tile"] = cloud2Image
		end
		clouds[i]["x"] = 1024
		clouds[i]["y"] = math.random(-32, 192)	
	end
end

--
-- AI Functions
--

function AIDoTurn()
	gameMode = -1
	
	-- Main AI start point
	local tryAngle = 0
	local tryPower = 0
	
	if AILastAngle == 0 and AILastPower == 0 then
		-- First shot of the round for AI
		local SourceHeight = cityGrid[11]["height"]
		local AdjHeight = cityGrid[10]["height"]
		local Adj2Height = cityGrid[9]["height"]
		
		-- Look at adjacent building height
		if SourceHeight - AdjHeight == 1 then
			-- Adjacent column is 1 higher than source
			tryAngle = math.random(30, 40)
			AIMinAngle = 32
			tryPower = math.random(30, 50)
		elseif SourceHeight - AdjHeight == 2 then
			-- Adjacent column is 2 higher than source
			tryAngle = math.random(65, 75)		
			AIMinAngle = 65
			tryPower = math.random(50, 60)
		elseif SourceHeight - AdjHeight >= 3 then
			-- Adjacent column is 3 higher than source
			tryAngle = math.random(80, 85)
			AIMinAngle = 80
			tryPower = math.random(50, 70)
		elseif SourceHeight - AdjHeight < 1 then
			-- Adjacent column is same height or less, don't worry about it.
			tryAngle = math.random(20, 50)
			AIMinAngle = 30
			tryPower = math.random(30, 45)
		end	

		-- Look at next to adjacent building height and adjust tryAngle
		if SourceHeight - Adj2Height == 1 then
			tryAngle = math.random(35, 45)
			AIMinAngle = 40
		elseif SourceHeight - Adj2Height == 2 then
			tryAngle = math.random(65, 75)	
			AIMinAngle = 70
		elseif SourceHeight - Adj2Height >= 3 then
			tryAngle = math.random(75, 85)
			AIMinAngle = 85
		elseif SourceHeight - Adj2Height < 1 then
			tryAngle = math.random(20, 50)
			AIMinAngle = 30
		end	
	else
		if AILastDistance < 40 then
			if AILastOverUnder == "Over" then
				tryAngle = AILastAngle
				tryPower = AILastPower + math.random(1,5)
			elseif AILastOverUnder == "Under" then
				tryAngle = AILastAngle
				tryPower = AILastPower - math.random(1,5)
			end
		else
			if AILastOverUnder == "Over" then
				tryPower = AILastPower - (AILastDistance / 15)
				tryAngle = AILastAngle
				if tryPower < 0 then
					tryPower = 40
					tryAngle = math.random(AIMinAngle, AIMinAngle + 10)
				end
			elseif AILastOverUnder == "Under" then
				tryPower = AILastPower + (AILastDistance / 15)
				tryAngle = AILastAngle
				if AILastMoron == true then
					AILastMoron = false
					AIMinAngle = AIMinAngle + 10
				end
				if tryPower > 80 then
					tryPower = math.random(30, 50)
					tryAngle = math.random(AIMinAngle, AIMinAngle + 10)
				end
			elseif AILastOverUnder == "OverOS" then
				tryPower = AILastPower - math.random(10, 20)
				tryAngle = AILastAngle + math.random(5, 15)
				if tryPower < 10 then
					tryPower = math.random(20, 30)
					tryAngle = math.random(AIMinAngle, AIMinAngle + 10)
				end
			elseif AILastOverUnder == "UnderOS" then
				tryPower = AILastPower + (AILastDistance / 10)
			end
			if tryAngle > 90 then
				tryAngle = math.random(85,88)
			end
		end
	end
	
	player2AngleIn = math.ceil(tryAngle)
	player2PowerIn = math.ceil(tryPower)
	
	fireBannana(player2FireLocation.x, player2FireLocation.y, tryAngle, tryPower)
	AILastAngle = tryAngle
	AILastPower = tryPower
end

function AIEvaluateShot(impactX, impactY, offscreenLeft, offscreenRight)
	local gridX = math.ceil(impactX / 64)
	
	AILastDistance = math.sqrt(math.pow(impactX, 2) + math.pow(impactY, 2))
	
	if impactX < player1FireLocation.x then
		if offscreenLeft == true then
			AILastOverUnder = "OverOS"
		else
			AILastOverUnder = "Over"
		end
	elseif impactX > player1FireLocation.x then
		if offscreenRight == true then
			AILastOverUnder = "UnderOS"
		else
			AILastOverUnder = "Under"
		end
	end
	
	if gridX == 10 then
		AILastMoron = true
	end
	print("Last Distance: "..AILastDistance.." - Over/Under: "..AILastOverUnder)
end

function resetAI()
	AIThinkElapsed = 0
	AILastAngle = 0	
	AILastPower = 0
	AIMinAngle = 0
	AILastDistance = 0
	AILastOverUnder = ""
end

--
-- Round Draw
--

function gRound:draw()
	-- Draw the sky
	love.graphics.draw(sky, 0, 0)
	
	-- Draw the sun
	love.graphics.draw(sun, 352, 30)
	
	-- Draw clouds
	for i=1, 3 do
		love.graphics.draw(clouds[i]["tile"], clouds[i]["x"], clouds[i]["y"])
	end
	
	-- Draw backdrop
	love.graphics.draw(background, 0, 0)
	
	-- Iterate building grid and draw tiles
	for x=1, 12 do
		for y=1, 8 do
			if cityGrid[x][y]["type"] ~= 0 then
				love.graphics.setColorMode("modulate")
				love.graphics.setColor(cityGrid[x]["color"]["r"], cityGrid[x]["color"]["g"], cityGrid[x]["color"]["b"], 255)
				love.graphics.draw(cityGrid[x][y]["tile"], (x - 1) * 64, (y - 1) * 64)
			end
		end
	end
	
	-- Reset color mode
	love.graphics.setColorMode("replace")
	love.graphics.setColor(255, 255, 255, 255)
	
	-- Draw the gorillas
	if player1 == true then
		-- Player is alive, draw his gorilla
		if gameMode == 1 or gameMode == 2 then
			love.graphics.draw(gorillaIdle, player1Location.x, player1Location.y)
		elseif gameMode == 3 and turn == 1 then
			love.graphics.draw(gorillaThrow, player1Location.x, player1Location.y)
		elseif gameMode == 4 then
			if player2 == true and turn == 2 then
				love.graphics.draw(gorillaAngry, player1Location.x, player1Location.y)
			else
				love.graphics.draw(gorillaIdle, player1Location.x, player1Location.y)
			end
		else
			love.graphics.draw(gorillaIdle, player1Location.x, player1Location.y)
		end
	else
		love.graphics.draw(gorillaDead, player1Location.x, player1Location.y)
	end
	if player2 == true then
		-- Player is alive, draw his gorilla
		if gameMode == 1 or gameMode == 2 then
			love.graphics.draw(gorillaIdle, player2Location.x, player2Location.y)
		elseif gameMode == 3 and turn == 2 then
			love.graphics.draw(gorillaThrow, player2Location.x, player2Location.y, 0, -1, 1, 64)
		elseif gameMode == 4 then
			if player1 == true and turn == 1 then
				love.graphics.draw(gorillaAngry, player2Location.x, player2Location.y)
			else
				love.graphics.draw(gorillaIdle, player2Location.x, player2Location.y)
			end
		else
			love.graphics.draw(gorillaIdle, player2Location.x, player2Location.y)
		end
	else
		love.graphics.draw(gorillaDead, player2Location.x, player2Location.y)
	end
	
	-- Draw the bannana
	if gameMode == 3 then
		love.graphics.draw(bannanaImage, bannana.location.x, bannana.location.y, math.rad(bannana.rotation), 1, 1, 8, 8)
	end
	
	-- Draw temp explosion
	if gameMode == 4 and player1 == true and player2 == true then
		-- Draw bannana explosion with building
		if explosionRadius > 0 then
			love.graphics.setColorMode("replace")
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.circle("fill", bannana.impactLocation.x, bannana.impactLocation.y, explosionRadius, 16)
			explosionRadius = explosionRadius - explosionFade
		else
			timer.add(1, function() gameMode = 1 end)
		end
	elseif gameMode == 4 and (player1 == false or player2 == false) then
		-- Draw gorilla explosion
		if gorillaExplosionRadius > 0 then
			love.graphics.setColorMode("replace")
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.circle("fill", bannana.impactLocation.x, bannana.impactLocation.y, gorillaExplosionRadius, 16)
			gorillaExplosionRadius = gorillaExplosionRadius - gorillaExplosionFade	
		else
			-- End the game
			print("Moving to game mode 5")
			roundEnding = true
			gameMode = 5
		end
	end
	
	-- Draw particle systems
	for index, system in ipairs(SGParticles.fireSystems) do
		love.graphics.draw(system, 0, 0)
	end
	for index, system in ipairs(SGParticles.sparkSystems) do
		love.graphics.draw(system, 0, 0)
	end
	for index, system in ipairs(SGParticles.debrisSystems) do
		love.graphics.draw(system, 0, 0)
	end	
	
	-- Draw player names
	love.graphics.setFont(gorillaFont)
	love.graphics.printf(player1Name, 30, 10, 128, "left")
	love.graphics.printf(player2Name, 610, 10, 128, "right")
	
	-- Draw angle and power text
	if turn == 1 then
		if gameMode == 1 then
			love.graphics.print("Angle: "..player1AngleIn..inputCursor, 30, 30)
			love.graphics.print("Power: "..player1PowerIn, 30, 60)
		elseif gameMode == 2 then
			love.graphics.print("Angle: "..player1AngleIn, 30, 30)
			love.graphics.print("Power: "..player1PowerIn..inputCursor, 30, 60)	
		else
			love.graphics.print("Angle: "..player1AngleIn, 30, 30)
			love.graphics.print("Power: "..player1PowerIn, 30, 60)	
		end
	else
		if gameMode == 1 then
			love.graphics.print("Angle: "..player2AngleIn..inputCursor, 600, 30)
			love.graphics.print("Power: "..player2PowerIn, 600, 60)
		elseif gameMode == 2 then
			love.graphics.print("Angle: "..player2AngleIn, 600, 30)
			love.graphics.print("Power: "..player2PowerIn..inputCursor, 600, 60)	
		else
			love.graphics.print("Angle: "..player2AngleIn, 600, 30)
			love.graphics.print("Power: "..player2PowerIn, 600, 60)	
		end	
	end
	
	if wind ~= 0 then
		-- Wind text
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Wind", 366, 480)
		-- Draw wind display, shadow first
		love.graphics.setColorMode("replace")
		love.graphics.setColor(0,0,0,255)
		
		-- Draw rectangle centered on X, at Y 502
		love.graphics.rectangle("fill", 386 - ((math.abs(wind) * 10) / 2), 502, math.abs(wind) * 10, 4)
		-- Set up base coordinates for the arrowhead
		local windArrowheadX = 0
		local windArrowheadY = 504
		if wind > 0 then
			windArrowheadX = 386 + ((math.abs(wind) * 10) / 2)
			shadowPoints = { windArrowheadX, windArrowheadY + 4, windArrowheadX + 4, windArrowheadY, windArrowheadX, windArrowheadY - 4}
		elseif wind < 0 then
			windArrowheadX = 386 - ((math.abs(wind) * 10) / 2)
			shadowPoints = { windArrowheadX, windArrowheadY + 4, windArrowheadX - 4, windArrowheadY, windArrowheadX, windArrowheadY - 4}
		end
		love.graphics.polygon("fill", shadowPoints)
		
		-- Color pass for wind arrow
		love.graphics.setColorMode("replace")
		love.graphics.setColor(255,255,255,255)
		-- Draw rectangle centered on X, at Y 502
		love.graphics.rectangle("fill", 384 - ((math.abs(wind) * 10) / 2), 500, math.abs(wind) * 10, 4)
		-- Set up base coordinates for the arrowhead
		windArrowheadX = 0
		windArrowheadY = 502
		if wind > 0 then
			windArrowheadX = 384 + ((math.abs(wind) * 10) / 2)
			arrowPoints = { windArrowheadX, windArrowheadY + 4, windArrowheadX + 4, windArrowheadY, windArrowheadX, windArrowheadY - 4}
		elseif wind < 0 then
			windArrowheadX = 384 - ((math.abs(wind) * 10) / 2)
			arrowPoints = { windArrowheadX, windArrowheadY + 4, windArrowheadX - 4, windArrowheadY, windArrowheadX, windArrowheadY - 4}
		end
		love.graphics.polygon("fill", arrowPoints)
	else
		-- Wind text
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Wind", 366, 480)
		love.graphics.print("None!", 364, 500)
	end
	
	-- Draw wins text
	if player1Wins > 0 then
		love.graphics.print("Victories: "..player1Wins, 30, 480)
	end
	if player2Wins > 0 then
		love.graphics.print("Victories: "..player2Wins, 635, 480)
	end	
	
	-- Debug
	love.graphics.print("GameMode: "..gameMode, 30, 460)
end