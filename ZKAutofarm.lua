--[[
clownedbyzee's Zombie Rush
This script is intended to help you level up.
GET 1000 KILLS EVERY 3 MINUTES!!!!!
This is designed to be used with a shotgun btu who cares :weary:
As you progress, turn the speed up to kill off zombies more quickly

Commands:
.killall - Enable / Disable
.killall - Disable kill all
.s (number) - Set kill all speed (1-1000)
.superspeed - Enable superspeed
.superspeed - Disable superspeed
.forcequit - Unload this script
.tp (username) - Teleport to the specified player
.up - Put the player 150 studs in the air with a platform below them
]]--

local delay = 1
local running = false
local sentMessage = false
local player = game.Players.LocalPlayer
local SuperSpeed = false
local previousPosition = nil
local commandsList = {
    ".ka - Enable / Disable kill all",
    ".s (number) - Set kill all speed (1-1000)",
    ".ss - Enable superspeed",  
    ".fq - Unload this script",
    ".to (username) - Teleport to the specified player",
    ".up - Put the player up in the air",
    ".down - put the player down under the map barrier",
    ".platform - Put the player up in the air with a platform below them",
    ".map - put the player inside the current map in the game",
    ".lobby - put the player in the currently lobby in the game",
    ".copyposition - copy the position vector of your character",
    ".cmds - Show this list of commands"
}

-- Preloading the function names because there were some nil issues
local zka
local unloadAll
local DeadFunc
local zkaWhile
local NotifyUser

NotifyUser = function(theMessage)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = theMessage;
        Color = Color3.new(0, 0, 1);    
    })
end

DeadFunc = function() end

-- SuperSpeed logic updated to use chat commands
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

-- Function to teleport the player to another player (non case-sensitive and partial name matching)
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

local function preventFling()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local currentPosition = rootPart.Position

        if AntiFlingEnabled and not isTeleporting then  -- Ignore if teleporting
            -- Calculate the change in position
            if previousPosition and (currentPosition - previousPosition).Magnitude > 50 then
                -- If the character moved too quickly, reset the position
                rootPart.CFrame = CFrame.new(previousPosition)
                NotifyUser("Anti-fling activated: Position reset to prevent fling.")
            end
            previousPosition = currentPosition  -- Update the previous position
        else
            previousPosition = currentPosition  -- Update the previous position when anti-fling is off
        end
    end
end

-- Function to toggle anti-fling
local function toggleAntiFling()
    AntiFlingEnabled = not AntiFlingEnabled
    if AntiFlingEnabled then
        NotifyUser("ANTI-FLING ENABLED")
    else
        NotifyUser("ANTI-FLING DISABLED")
    end
end
local function createPlatform()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Store the previous position before teleporting
        previousPosition = character.HumanoidRootPart.Position
        
        -- Create a platform
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(10, 1, 10)  -- Platform size
        platform.Position = character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)  -- Position above the player
        platform.Anchored = true
        platform.BrickColor = BrickColor.new("Bright blue")
        platform.Parent = game.Workspace
        platform.Transparency = 1  -- Make the platform transparent (so it's invisible)

        -- Teleport the player onto the platform
        character.HumanoidRootPart.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))  -- Teleport slightly above the platform
        NotifyUser("Teleported onto the platform")
    else
        NotifyUser("Failed to create platform: Character is missing HumanoidRootPart")
    end
end

local function teleportToLobby()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Store the current position before teleporting to the lobby
        previousPosition = character.HumanoidRootPart.Position
        
        -- Teleport the player to the specific lobby position
        character.HumanoidRootPart.CFrame = CFrame.new(228, 3, 562)
        NotifyUser("Teleported to the lobby position (228, 3, 562).")
    else
        NotifyUser("Failed to teleport to the lobby: Character is missing HumanoidRootPart.")
    end
end

-- Function to teleport back to the previous position
local function teleportBack()
    if previousPosition then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleport the player back to the previous position
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
        print("Current Position: " .. tostring(position))  -- Print the position in the console
        NotifyUser("Your current position has been copied to the console.")
    else
        NotifyUser("Failed to copy position: Character is missing HumanoidRootPart")
    end
end

local function teleportUp()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local newPosition = rootPart.Position + Vector3.new(0, 100, 0)  -- Move 150 studs up
        rootPart.CFrame = CFrame.new(newPosition)  -- Set the new position
        NotifyUser("Teleported up")
    else
        NotifyUser("Failed to teleport: Character is missing HumanoidRootPart")
    end
end

local function findSpawnPart()
    -- Recursively search through all objects in the workspace
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("Part") and object.Name == "Spawn" then
            return object  -- Return the part if found
        end
    end
    return nil  -- Return nil if no part is found
end

-- Function to teleport to the "spawn" part
local function teleportToMap()
    local character = player.Character
    local spawnPart = findSpawnPart()  -- Use the function to find the "spawn" part

    if spawnPart then
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleport the player to the spawn part
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
        local newPosition = rootPart.Position - Vector3.new(0, 5, 0)  -- Move 25 studs down
        rootPart.CFrame = CFrame.new(newPosition)  -- Set the new position
        NotifyUser("Teleported down")
    else
        NotifyUser("Failed to teleport: Character is missing HumanoidRootPart")
    end
end

local function createCmdsUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CmdsGui"
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 300)  -- Size of the frame
    frame.Position = UDim2.new(0.5, 350, 0, 50)  -- Position closer to the center
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = table.concat(commandsList, "\n")  -- Concatenate all commands into a single string
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = frame
end


-- Hide the UI with smooth sliding animation
local function hideCmdsUI()
    local screenGui = player.PlayerGui:FindFirstChild("CmdsGui")
    if screenGui then
        local frame = screenGui:FindFirstChild("Frame")
        if frame then
            -- Slide the frame out smoothly using TweenService
            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local goal = {Position = UDim2.new(1, 0, 0, 50)}  -- Move it off-screen to the right

            tweenService:Create(frame, tweenInfo, goal):Play()  -- Play the slide-out animation
            -- Wait for the animation to finish before destroying the UI
            wait(0.5)
            screenGui:Destroy()
        end
    end
end

-- Function to handle the .cmds command
local function handleCmdsCommand()
    local screenGui = player.PlayerGui:FindFirstChild("CmdsGui")
    if screenGui then
        hideCmdsUI()  -- If the UI is already visible, hide it
    else
        createCmdsUI()  -- Otherwise, create the UI
    end
end

-- Update the Chatted event to handle the .lobby, .back, .map, and other commands
player.Chatted:Connect(function(message)
    local command, arg = message:match("^(%S+)%s*(%S*)$")
    if command == ".ka" then
        running = not running
        if running then
            NotifyUser("ZKA Enabled")
            zkaWhile()
        else
            NotifyUser("ZKA Disabled")
        end
    elseif command == ".stop" then
        running = false
        NotifyUser("ZKA Disabled")
    elseif command == ".s" then
        local speed = tonumber(arg)
        if speed and speed >= 1 and speed <= 1000 then
            delay = 1 / speed
            NotifyUser("Kill speed set to " .. speed .. " kills per second")
        else
            NotifyUser("Invalid speed. Please enter a number between 1 and 1000.")
        end
    elseif command == ".ss" then
        enableSuperSpeed()
    elseif command == ".ss" then
        disableSuperSpeed()
    elseif command == ".fq" then
        pcall(unloadAll)
    elseif command == ".to" then
        if arg and arg ~= "" then
            teleportToPlayer(arg)
        else
            NotifyUser("Please provide a valid username to teleport.")
        end
    elseif command == ".up" then
        teleportUp()  -- Call the function to teleport up
    elseif command == ".down" then
        teleportDown()  -- Call the new function to teleport down
    elseif command == ".platform" then
        createPlatform()  -- Call the function to create the platform and teleport onto it
    elseif command == ".back" then
        teleportBack()  -- Call the function to teleport back to the previous position
    elseif command == ".copyposition" then
        copyPosition()  -- Call the function to copy and print the current position
    elseif command == ".lobby" then
        teleportToLobby()  -- Call the function to teleport to the lobby position
    elseif command == ".map" then
        teleportToMap()  -- Call the function to teleport to the spawn part
    elseif command ==".cmds" then
        handleCmdsCommand()    
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    preventFling()
end)

NotifyUser("Hello user, ZKA Has loaded successfully")
