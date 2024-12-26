local delay = 1
local running = false
local sentMessage = false
local player = game.Players.LocalPlayer
local SuperSpeed = false
local cooldown = false
local opGun = false
local invis_on = false
local previousPosition = nil
local kauraActive = false
local radius = 50
local SuperSpeed = false
local commandsList = {
	".killall - Enable / Disable kill all",
	".speed (number) - Set kill all speed (1-1000)",
	".superspeed - Enable superspeed",  
	".quit - Unload this script",
	".to (username) - Teleport to the specified player",
	".up - Put the player up in the air above map barrier",
	".down - put the player down under the map barrier",
	".platform - Put the player up in the air with a platform below them",
	".map - put the player inside the current map in the game",
	".lobby - put the player in the currently lobby in the game",
	".copyposition - copy the position vector of your character",
	".godmodeon - Makes you immune to taking damage against zombies (makes you invisible to other players)",
	".godmodeoff - Disables god mode",
	".killaura - Kill aura that kills zombies in a 50 stud radius",
	".bringall - Loop teleport all zombies in front of your character",
	".opgun - Gives you a gun that is rapid fire, no cooldown, and no spread",
	".cmds - Show this list of commands"
}

local zka
local unloadAll
local DeadFunc
local zkaWhile
local NotifyUser

NotifyUser = function(theMessage)
	game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = theMessage;
		Color = Color3.new(255, 215, 0);    
	})
end

DeadFunc = function() end

local enableSuperSpeed = function()
	SuperSpeed = true
	NotifyUser("SUPERSPEED ENABLED")
end

local disableSuperSpeed = function()
	SuperSpeed = false
	NotifyUser("SUPERSPEED DISABLED")
end

zka = function()
	local zombies = game.Workspace['Zombie Storage']:GetChildren();
	for i, zombie in pairs(game.Workspace['Zombie Storage']:GetChildren()) do
		if not SuperSpeed then 
			zombie = zombies[math.random(#zombies)] 
		end
		local weaponName = player.EquipStorage.Primary.Value
		local weapon
		if player.Backpack:FindFirstChild(weaponName) then
			weapon = player.Backpack:FindFirstChild(weaponName)
		elseif player.Character:FindFirstChild(weaponName) then
			weapon = player.Character:FindFirstChild(weaponName)
		else
			weapon = nil
		end
		if weapon then
			local humanoid = zombie:FindFirstChild('Humanoid')
			if humanoid then
				spawn(function()
					for i = 1, 10 do
						weapon.GunController.RemoteFunction:InvokeServer({['Name'] = weapon.Name, ['HumanoidTables'] = {{['HeadHits'] = 1, ['THumanoid'] = humanoid, ['BodyHits'] = 0}}})
					end
				end)
			end
		end
		if not SuperSpeed then 
			return 
		end
	end
end

zkaWhile = function()
	while running do
		pcall(zka)
		if SuperSpeed then
			wait(0.00001)
		else
			wait(math.floor(delay * 100) / 100)
		end
	end
end

unloadAll = function()
	running = false
	zka = DeadFunc
	unloadAll = DeadFunc
	NotifyUser("ZKA unloaded")
	NotifyUser = DeadFunc
end

local function toggleSelfCommands(message, speaker)
	if message:lower() == "!enableselfcommands" and speaker == player.Name then
		selfCommandsEnabled = true
		NotifyUser("Self-commands have been enabled.")
	elseif message:lower() == "!disableselfcommands" and speaker == player.Name then
		selfCommandsEnabled = false
		NotifyUser("Self-commands have been disabled.")
	end
end


local teleportToPlayer = function(partialName)
	local lowerPartialName = partialName:lower()
	local target
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Name:lower():find(lowerPartialName) then
			target = p
			break
		end
	end
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetPosition = target.Character.HumanoidRootPart.Position
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
			NotifyUser("Teleported to " .. target.Name)
		else
			NotifyUser("Failed to teleport: Your character is missing")
		end
	else
		NotifyUser("Failed to teleport: Target player not found or invalid")
	end
end

local function createPlatform()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		previousPosition = character.HumanoidRootPart.Position

		local platform = Instance.new("Part")
		platform.Size = Vector3.new(10, 1, 10)
		platform.Position = character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
		platform.Anchored = true
		platform.BrickColor = BrickColor.new("Bright blue")
		platform.Parent = game.Workspace
		platform.Transparency = 1

		character.HumanoidRootPart.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
		NotifyUser("Teleported onto the platform")
	else
		NotifyUser("Failed to create platform: Character is missing HumanoidRootPart")
	end
end

local function resetCharacter()
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
			NotifyUser("Character reset.")
		else
			NotifyUser("Failed to reset: No Humanoid found in your character.")
		end
	else
		NotifyUser("Failed to reset: Character not found.")
	end
end

local function teleportToLobby()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		previousPosition = character.HumanoidRootPart.Position

		character.HumanoidRootPart.CFrame = CFrame.new(228, 3, 562)
		NotifyUser("Teleported to the lobby position (228, 3, 562).")
	else
		NotifyUser("Failed to teleport to the lobby: Character is missing HumanoidRootPart.")
	end
end

local function teleportBack()
	if previousPosition then
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(previousPosition)
			NotifyUser("Teleported back to your previous position.")
		else
			NotifyUser("Failed to teleport back: Character is missing HumanoidRootPart.")
		end
	else
		NotifyUser("No previous position found. Use .platform or .lobby first to set a position.")
	end
end

local function copyPosition()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local position = character.HumanoidRootPart.Position
		print("Current Position: " .. tostring(position))
		NotifyUser("Your current position has been copied to the console.")
	else
		NotifyUser("Failed to copy position: Character is missing HumanoidRootPart")
	end
end

local function teleportUp()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character.HumanoidRootPart
		local newPosition = rootPart.Position + Vector3.new(0, 100, 0)
		rootPart.CFrame = CFrame.new(newPosition)
		NotifyUser("Teleported up")
	else
		NotifyUser("Failed to teleport: Character is missing HumanoidRootPart")
	end
end

local function findSpawnPart()
	for _, object in pairs(workspace:GetDescendants()) do
		if object:IsA("Part") and object.Name == "Spawn" then
			return object
		end
	end
	return nil
end

local function teleportToMap()
	local character = player.Character
	local spawnPart = findSpawnPart()

	if spawnPart then
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(spawnPart.Position)
			NotifyUser("Teleported to the spawn part.")
		else
			NotifyUser("Failed to teleport: Character is missing HumanoidRootPart.")
		end
	else
		NotifyUser("No part named 'spawn' found in the workspace.")
	end
end

local function teleportDown()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character.HumanoidRootPart
		local newPosition = rootPart.Position - Vector3.new(0, 15, 0)
		rootPart.CFrame = CFrame.new(newPosition)
		NotifyUser("Teleported down")
	else
		NotifyUser("Failed to teleport: Character is missing HumanoidRootPart")
	end
end

function tpZombiesToPlayer()
	local ztable = game.Workspace["Zombie Storage"]:GetChildren()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		local lookDirection = hrp.CFrame.LookVector

		for i, v in pairs(ztable) do
			if v:FindFirstChild("Head") then
				local targetPosition = hrp.Position + lookDirection * 10
				v.Head.CFrame = CFrame.new(targetPosition)
				v.Head.Anchored = true
			end
			if v:IsA("Part") then
				if v.CanCollide then
					v.CanCollide = false
				end
			end
		end
	end    
end

function findNearestZombie()
	local nearestZombie = nil
	local shortestDistance = math.huge
	local ztable = game.Workspace["Zombie Storage"]:GetChildren()

	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		for _, zombie in pairs(ztable) do
			if zombie:FindFirstChild("HumanoidRootPart") then
				local distance = (hrp.Position - zombie.HumanoidRootPart.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					nearestZombie = zombie
				end
			end
		end
	end
	return nearestZombie
end

local function createCmdsUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CmdsGui"
	screenGui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 600, 0, 300)
	frame.Position = UDim2.new(0.5, 350, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.5
	frame.Parent = screenGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = table.concat(commandsList, "\n")
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = frame
end


local function hideCmdsUI()
	local screenGui = player.PlayerGui:FindFirstChild("CmdsGui")
	if screenGui then
		local frame = screenGui:FindFirstChild("Frame")
		if frame then
			screenGui:Destroy()
		end
	end
end

local function handleCmdsCommand()
	local screenGui = player.PlayerGui:FindFirstChild("CmdsGui")
	if screenGui then
		hideCmdsUI()
	else
		createCmdsUI()
	end
end

function opWeapon(tool)
	if isGun(tool) then
		local con = tool.Configuration
		if con.Range.Value ~= 9999 then
			con.Range.Value = 9999
			con.FullAuto.Value = true
			con.Spread.Value = 0
			con.Firerate.Value = 100
			con.Damage.Value = 99999
			tool.GunController.Disabled = true
			tool.GunController.Disabled = false
		end
	end
end

function isGun(tool)
	local returnValue = false
	if tool then
		if tool.ClassName == "Tool" and tool:FindFirstChild("Configuration") and tool:FindFirstChild("GunController") then
			returnValue = true
		end
	end
	return returnValue
end

function godMode(enable)
	if enable then
		if not invis_on then
			invis_on = true
			local savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
			wait()
			game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
			wait(0.15)
			local Seat = Instance.new('Seat', game.Workspace)
			Seat.Anchored = false
			Seat.CanCollide = false
			Seat.Name = 'invischair'
			Seat.Transparency = 1
			Seat.Position = Vector3.new(-25.95, 84, 3537.55)
			local Weld = Instance.new("Weld", Seat)
			Weld.Part0 = Seat
			Weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character.UpperTorso
			wait()
			Seat.CFrame = savedpos
			game.StarterGui:SetCore("SendNotification", {
				Title = "Invis On";
				Duration = 1;
				Text = "";
			})
		else
			game.StarterGui:SetCore("SendNotification", {
				Title = "Already Invisible";
				Duration = 1;
				Text = "";
			})
		end
	else
		if invis_on then
			invis_on = false
			local chair = workspace:FindFirstChild('invischair')
			if chair then
				chair:Destroy()
			end
			game.StarterGui:SetCore("SendNotification", {
				Title = "Invis Off";
				Duration = 1;
				Text = "";
			})
		else
			game.StarterGui:SetCore("SendNotification", {
				Title = "Not Invisible";
				Duration = 1;
				Text = "";
			})
		end
	end
end

local function kaura()
	while kauraActive do
		local zombies = game.Workspace['Zombie Storage']:GetChildren()
		for _, zombie in pairs(zombies) do
			if zombie and zombie:FindFirstChild("Humanoid") then
				local humanoid = zombie:FindFirstChild("Humanoid")
				local distance = (zombie.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if distance <= radius then
					local weaponName = game.Players.LocalPlayer.EquipStorage.Primary.Value
					local weapon
					if game.Players.LocalPlayer.Backpack:FindFirstChild(weaponName) then
						weapon = game.Players.LocalPlayer.Backpack:FindFirstChild(weaponName)
					elseif game.Players.LocalPlayer.Character:FindFirstChild(weaponName) then
						weapon = game.Players.LocalPlayer.Character:FindFirstChild(weaponName)
					end

					if weapon and humanoid then
						spawn(function()
							for i = 1, 10 do
								weapon.GunController.RemoteFunction:InvokeServer({['Name'] = weapon.Name, ['HumanoidTables'] = {{['HeadHits'] = 1, ['THumanoid'] = humanoid, ['BodyHits'] = 0}}})
							end
						end)
					end
				end
			end
		end
		wait(0.1)
	end
end

local function startKaura()
	if not kauraActive then
		kauraActive = true
		kaura()
		print("Killaura turned on.")
	else
		print("Killaura is already active.")
	end
end

local function stopKaura()
	if kauraActive then
		kauraActive = false
		print("Killaura turned off.")
	else
		print("Killaura is not active.")
	end
end

local function mainLoop()
	while true do
		local humanoid = player.Character:WaitForChild("Humanoid")

		if opGun then
			local tool = player.Character:FindFirstChildWhichIsA("Tool")
			if tool then
				if isGun(tool) then
					opWeapon(tool)
				end
			end
		end
		wait(0)
	end
end

local function zombieloop()
	while true do
		if bringAll then
			tpZombiesToPlayer()
		else
			break
		end
		wait(0)
	end
end

firstRun = false
spawn(mainLoop)

player.Chatted:Connect(function(message)
	local command, arg = message:match("^(%S+)%s*(%S*)$")
	if command == ".killall" then
		running = not running
		if running then
			NotifyUser("Kill all has been enabled")
			zkaWhile()
		else
			NotifyUser("Kill all has been disabled")
		end
	elseif command == ".speed" then
		local speed = tonumber(arg)
		if speed and speed >= 1 and speed <= 1000 then
			delay = 1 / speed
			NotifyUser("Kill speed set to " .. speed .. " kills per second")
		else
			NotifyUser("Invalid speed. Please enter a number between 1 and 1000.")
		end
	elseif command == ".superspeed" then
		enableSuperSpeed()
	elseif command == ".quit" then
		pcall(unloadAll)
	elseif command == ".to" then
		if arg and arg ~= "" then
			teleportToPlayer(arg)
		else
			NotifyUser("Please provide a valid username to teleport.")
		end
	elseif command == ".up" then
		teleportUp()
	elseif command == ".down" then
		teleportDown()
	elseif command == ".platform" then
		createPlatform()
	elseif command == ".back" then
		teleportBack()
	elseif command == ".copyposition" then
		copyPosition()
	elseif command == ".lobby" then
		teleportToLobby()
	elseif command == ".map" then
		teleportToMap()
	elseif command == ".cmds" then
		handleCmdsCommand()
	elseif command == ".killaura" then
		if kauraActive then
			kauraActive = false
			NotifyUser("Kill aura is now OFF")
		else
			kauraActive = true
			NotifyUser("Kill aura is now ON")
			spawn(function()
				kaura()
			end)
		end
	elseif command == ".opgun" then
		opGun = not opGun
		if opGun then
			NotifyUser("Opgun has been enabled")
		else
			NotifyUser("Opgun has been disabled, wait until next round")
		end
	elseif command == ".bringall" then
		bringAll = not bringAll
		if bringAll then
			NotifyUser("BringAll enabled: Zombies are being brought to you")
			spawn(zombieloop)
		else
			NotifyUser("BringAll disabled: Zombies are no longer being brought to you")
		end
	elseif command == ".godmodeon" then
		godMode(true)
	elseif command == ".godmodeoff" then
		godMode(false)
	end
end)

NotifyUser("Hello " .. player.Name .. ", ZKA has loaded successfully")
print("Version 1.6.1")
