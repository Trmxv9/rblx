local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TR Menus - Dig It v1 - Beta",
    Icon = "shovel",
    LoadingTitle = "🌟 TR Menus • Dig It v1 • Beta 🚀",
    LoadingSubtitle = "All rights reserved © TR Menus 2025.",
    Theme = "DarkBlue",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Big Hub"
    },

    Discord = {
        Enabled = true,
        Invite = "https://discord.gg/rNAXhxN3hN",
        RememberJoins = true
    },

    KeySystem = false
})

Rayfield:Notify({
        Title = "💰 • Welcome to TR Menus",
        Content = "Enter our Discord!",
        Duration = 6.5,
        Image = "message-circle-warning",})


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Player = game:GetService("Players").LocalPlayer

local Network = ReplicatedStorage:WaitForChild("Source"):WaitForChild("Network")
local RemoteFunctions = Network:WaitForChild("RemoteFunctions")
local RemoteEvents = Network:WaitForChild("RemoteEvents")

local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local getgenv = getfenv().getgenv

local Flags: {[string]: {["CurrentValue"]: any}} = Rayfield.Flags

-- Função de teleporte
local function teleport(position)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    else
        warn("Personagem ou HumanoidRootPart não encontrado!")
    end
end

-- Função de manuseio de conexões de eventos
local function HandleConnection(connection, flag)
    connection:Connect(function(...)
        if Flags[flag] and Flags[flag].CurrentValue then
            connection(...)
        end
    end)
end


-- Functions 

local function SellInventory()
	local SellEnabled = Flags.Sell.CurrentValue
	Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

	local Capacity: TextLabel = Player.PlayerGui.Main.Core.Inventory.Disclaimer.Capacity

	local Inventory: {[string]: {["Attributes"]: {["Weight"]: number}}} = RemoteFunctions.Player:InvokeServer({
		Command = "GetInventory"
	})

	local AnyObjects = false

	for _, Object in Inventory do
		if not Object.Attributes.Weight then
			continue
		end

		AnyObjects = true
		break
	end

	if not AnyObjects then
		task.wait(5)
		return
	end

	for i,v: TextLabel in workspace.Map.Islands:GetDescendants() do
		if v.Name ~= "Title" or not v:IsA("TextLabel") or v.Text ~= "Merchant" then
			continue
		end

		local Merchant: Model = v.Parent.Parent

		local PreviousPosition = Player.Character:GetPivot()

		local PreviousText = Capacity.Text

		repeat
			Player.Character:PivotTo(Merchant:GetPivot())

			RemoteEvents.Merchant:FireServer({
				Command = "SellAllTreasures",
				Merchant = Merchant
			})

			task.wait(0.1)
		until Capacity.Text ~= PreviousText or Flags.Sell.CurrentValue ~= SellEnabled

		Player.Character:PivotTo(PreviousPosition)

		break
	end
    Rayfield:Notify({
        Title = "💰 • Sell ​​all your inventory",
        Content = "You sold all your items!",
        Duration = 6.5,
        Image = "message-circle-warning",
    })
end


local activeMarkers = {} 

local function ToggleSubZonesMarkers(toggleState)
    local SubZones = workspace.Map:WaitForChild("Subzones")
    local markersFolder = workspace:FindFirstChild("ZoneMarkers") or Instance.new("Folder", workspace)

    if not markersFolder then
        markersFolder = Instance.new("Folder", workspace)
        markersFolder.Name = "ZoneMarkers"
    end

    if toggleState then
        Rayfield:Notify({
            Title = "🤳 • Treasure Scanner",
            Content = "Activated Treasure Scanner!",
            Duration = 6.5,
            Image = "message-circle-warning",
        })

        for _, zone in ipairs(SubZones:GetChildren()) do
            if zone:IsA("BasePart") then
                if activeMarkers[zone.Name] then
                    continue
                end

                local digZone = Instance.new("Part")
                digZone.Name = zone.Name .. "_DigZone"
                digZone.Size = zone.Size
                digZone.CFrame = zone.CFrame
                digZone.Color = zone.Color or Color3.new(1, 1, 1)
                digZone.Transparency = 0.5
                digZone.Anchored = true
                digZone.CanCollide = false
                digZone.Parent = markersFolder

                local fillPart = Instance.new("Part")
                fillPart.Name = zone.Name .. "_FillPart"
                fillPart.Shape = Enum.PartType.Cylinder
                fillPart.Size = Vector3.new(zone.Size.X, 0.1, zone.Size.Z)
                fillPart.CFrame = zone.CFrame * CFrame.Angles(math.rad(90), 0, 0)
                fillPart.Color = zone.Color or Color3.new(1, 1, 1)
                fillPart.Anchored = true
                fillPart.CanCollide = false
                fillPart.Parent = markersFolder

                activeMarkers[zone.Name] = {digZone, fillPart}

                local overhead = zone:FindFirstChild("Overhead")
                if overhead and overhead:FindFirstChild("Text") then
                    local overheadText = overhead:FindFirstChild("Text").Text

                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Name = zone.Name .. "_OverheadText"
                    billboardGui.Size = UDim2.new(0, 150, 0, 40)
                    billboardGui.StudsOffset = Vector3.new(0, 5, 0)
                    billboardGui.AlwaysOnTop = true
                    billboardGui.Enabled = true
                    billboardGui.Parent = zone

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Text = overheadText
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextScaled = true
                    textLabel.TextColor3 = zone.Color or Color3.new(1, 1, 1)
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = billboardGui

                    task.spawn(function()
                        while toggleState do
                            local player = game.Players.LocalPlayer
                            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local playerPosition = player.Character.HumanoidRootPart.Position
                                local zonePosition = zone.Position
                                local distance = (playerPosition - zonePosition).Magnitude

                                local maxDistance = 50
                                billboardGui.Enabled = distance <= maxDistance
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        end
    else

        Rayfield:Notify({
            Title = "🤳 • Treasure Scanner",
            Content = "Disabled Treasure Scanner!",
            Duration = 6.5,
            Image = "message-circle-warning",
        })

        for _, markers in pairs(activeMarkers) do
            for _, marker in ipairs(markers) do
                marker:Destroy()
            end
        end

        activeMarkers = {}

        for _, zone in ipairs(SubZones:GetChildren()) do
            local billboardGui = zone:FindFirstChild(zone.Name .. "_OverheadText")
            if billboardGui then
                billboardGui:Destroy()
            end
        end
    end
end



-- End Functions

local IslandsTab = Window:CreateTab("Ilhas", "tree-palm")


IslandsTab:CreateSection("🏝️ • Islands")

local Islands = {}

for i,v in workspace.Map.Islands:GetChildren() do
	table.insert(Islands, v.Name)
end

for i,v in ReplicatedStorage.Assets.Sounds.Soundtrack.Locations:GetChildren() do
	if v.Name == "Ocean" then
		continue
	end

	if not table.find(Islands, v.Name) then
		table.insert(Islands, v.Name)
	end
end

table.sort(Islands)

local TeleporttoIsland

TeleporttoIsland = IslandsTab:CreateDropdown({
	Name = "🏝 • Teleport to Island",
	Options = Islands,
	CurrentOption = "",
	MultipleOptions = false,
	--Flag = "Flag",
	Callback = function(CurrentOption)
		CurrentOption = CurrentOption[1]

		if CurrentOption == "" then
			return
		end

		local Island: Folder = workspace.Map.Islands:FindFirstChild(CurrentOption)

		if not Island then
			return Notify("Error", "That island doesn't currently exist.")
		end

		if Island:FindFirstChild("LocationSpawn") then
			Player.Character:PivotTo(Island.LocationSpawn.CFrame)
		else
			Player.Character:PivotTo(Island:GetAttribute("Pivot") + Vector3.yAxis * Island:GetAttribute("Size") / 2)
		end

		TeleporttoIsland:Set({""})
	end,
})


IslandsTab:CreateSection("🌠 • Meteor Island Teleport")

local PreviousLocation

local function MeteorIslandTeleport(Meteor: Model?)
    if Meteor.Name ~= "Meteor Island" or not Flags.Meteor.CurrentValue then
        return
    end
    
    local Character = Player.Character
    PreviousLocation = Character:GetPivot()
    Character:PivotTo(Meteor:GetPivot() + Vector3.yAxis * Meteor:GetExtentsSize().Y / 2)
end

IslandsTab:CreateToggle({
    Name = "🌠 • Auto Teleport to Meteor Islands",
    CurrentValue = false,
    Flag = "Meteor",
    Callback = function(Value)
        if Value then
            for _, v in workspace.Map.Temporary:GetChildren() do
                MeteorIslandTeleport(v)
            end
        elseif PreviousLocation then
            Player.Character:PivotTo(PreviousLocation)
        end
    end,
})

-- Seção para Lunar Clouds
IslandsTab:CreateSection("✨ • Lunar Clouds Teleport")

local function LunarCloudsTeleport(Lunar: Model?)
    if Lunar.Name ~= "Lunar Clouds" or not Flags.LunarClouds.CurrentValue then
        return
    end

    local Character = Player.Character
    PreviousLocation = Character:GetPivot()
    Character:PivotTo(Lunar:GetPivot() + Vector3.yAxis * Lunar:GetExtentsSize().Y / 2)
end

IslandsTab:CreateToggle({
    Name = "✨ • Auto Teleport to Lunar Clouds",
    CurrentValue = false,
    Flag = "LunarClouds",
    Callback = function(Value)
        if Value then
            for _, v in workspace.Map.Islands:GetChildren() do
                LunarCloudsTeleport(v)
            end
        elseif PreviousLocation then
            Player.Character:PivotTo(PreviousLocation)
        end
    end,
})

-- Criar aba e toggle pra marcar SubZones
IslandsTab:CreateSection("📍 • Treasure Scanner")

IslandsTab:CreateToggle({
    Name = "📍 • Treasure Scanner",
    CurrentValue = false,
    Flag = "SubZonesMarkers",
    Callback = function(Value)
        ToggleSubZonesMarkers(Value)
    end,
})


-- Automação de mineração
local AutomationTab = Window:CreateTab("Automation", "repeat")
AutomationTab:CreateSection("🛠️ • Digging")

AutomationTab:CreateToggle({
    Name = "⛏️ • Auto Dig Close Piles (Faster)",
    CurrentValue = false,
    Flag = "Dig",
	Callback = function(Value)
		task.spawn(function()
			while Flags.Dig.CurrentValue and task.wait() do
				local DigMinigame = Player.PlayerGui.Main:FindFirstChild("DigMinigame")

				if not DigMinigame then
					continue
				end
				
				DigMinigame.Cursor.Position = DigMinigame.Area.Position
			end
		end)
		
		while Flags.Dig.CurrentValue and task.wait() do
			if not Player.Character:FindFirstChildOfClass("Tool") then
				continue
			end
			
			local Adornee = Player.Character.Shovel.Highlight.Adornee
			
			if not Adornee or Adornee.Parent ~= workspace.Map.TreasurePiles then
				continue
			end
			
			RemoteFunctions.Digging:InvokeServer({
				Command = "DigPile",
				TargetPileIndex = Adornee:GetAttribute("PileIndex")
			})
		end
	end,
})

AutomationTab:CreateSection("🤖 • Auto Farm")

AutomationTab:CreateToggle({
    Name = "🕹️ • Auto Minigame | 100% Success",
    CurrentValue = false,
    Flag = "PileMinigame",
    Callback = function(Value)    
        while Flags.PileMinigame.CurrentValue and task.wait() do
            if not Player.Character:FindFirstChildOfClass("Tool") then
                continue
            end
            
            local Adornee: Model = Player.Character.Shovel.Highlight.Adornee
            if not Adornee or Adornee:GetAttribute("Completed") or Adornee:GetAttribute("Destroying") or Adornee:GetAttribute("Progress") >= Adornee:GetAttribute("MaxProgress") then
                continue
            end
            
            if Adornee.Parent ~= workspace.Map.TreasurePiles then
                continue
            end
            
            if Player.PlayerGui.Main:FindFirstChild("DigMinigame") then
                continue
            end

            Adornee:GetAttributeChangedSignal("Progress"):Wait()
            
            local Success = RemoteFunctions.Digging:InvokeServer({
                Command = "DigPile",
                TargetPileIndex = Adornee:GetAttribute("PileIndex")
            })
            
            if Success then
                local X, Y = 0, 0
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(X, Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(X, Y, 0, false, game, 1)
                VirtualInputManager:WaitForInputEventsProcessed()
            end
        end
    end,
})

AutomationTab:CreateToggle({
    Name = "🕳️ • Auto Create Piles (Any Terrain)",
    CurrentValue = false,
    Flag = "CreatePiles",
    Callback = function(Value)    
        while Flags.CreatePiles.CurrentValue and task.wait() do    
            if Player:GetAttribute("PileCount") ~= 0 then
                continue
            end
            
            local PileInfo: {["PileIndex"]: number, ["Success"]: boolean} = RemoteFunctions.Digging:InvokeServer({
                Command = "CreatePile"
            })
            
            if PileInfo.Success then
                RemoteEvents.Digging:FireServer({
                    Command = "DigIntoSandSound"
                })
            end
        end
    end,
})

local function RandomVector(Size: Vector3, Position: Vector3)

	local X = Position.X + math.random(-Size.X / 2, Size.X / 2)
	local Z = Position.Z + math.random(-Size.Z / 2, Size.Z / 2)

	return Vector3.new(X, Position.Y, Z)
end

local CanWalk = true

AutomationTab:CreateToggle({
	Name = "🔄 • Auto Walk After Dig",
	CurrentValue = false,
	Flag = "DigWalk",
	Callback = function(Value)
		local Visualizer = workspace:FindFirstChild("FrostByteVisualizer")
		
		while Flags.DigWalk.CurrentValue and task.wait() do	
			if Player:GetAttribute("IsDigging") then
				continue
			end
			
			local Character = Player.Character
			
			local WalkZoneSizeFlag = Flags.ZoneSize.CurrentValue
			
			local ZoneSize = Vector3.new(WalkZoneSizeFlag, 1, WalkZoneSizeFlag)
			
			local Visualizer = workspace:FindFirstChild("FrostByteVisualizer")
			
			if not Visualizer then
				Visualizer = Instance.new("Part")
				Visualizer.Size = ZoneSize
				Visualizer.Position = Character:GetPivot().Position - Vector3.yAxis * Character:GetExtentsSize().Y / 1.05
				Visualizer.Anchored = true
				Visualizer.Color = Color3.fromRGB(75, 255, 75)
				Visualizer.CanCollide = false
				Visualizer.CanQuery = false
				Visualizer.Material = Enum.Material.SmoothPlastic
				Visualizer.Transparency = 0.4
				Visualizer.CastShadow = false
				Visualizer.Name = "FrostByteVisualizer"
				Visualizer.Parent = workspace
			end
			
			local Humanoid: Humanoid = Character.Humanoid
			
			local FoundPile = false

			for _, Pile: Model in workspace.Map.TreasurePiles:GetChildren() do
				if Pile:GetAttribute("Owner") ~= Player.UserId then
					continue
				end
				
				FoundPile = true
				
				for _, Descendant: BasePart in Pile:GetDescendants() do
					if not Descendant:IsA("BasePart") then
						continue
					end
					
					Descendant.CanCollide = false
				end

				Humanoid:MoveTo(Pile:GetPivot().Position)
				break
			end
			
			if FoundPile then
				continue
			end
			
			if CanWalk then
				Humanoid:MoveTo(RandomVector(ZoneSize, Visualizer.Position))
				CanWalk = false

				Humanoid.MoveToFinished:Once(function()
					CanWalk = true
				end)
			end
		end
		
		local Visualizer = workspace:FindFirstChild("FrostByteVisualizer")
		
		if Visualizer then
			Visualizer:Destroy()
		end
	end,
})

AutomationTab:CreateSlider({
	Name = "🟩 • Auto Walk Zone Size",
	Range = {5, 100},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = 20,
	Flag = "ZoneSize",
	Callback = function()end,
})

AutomationTab:CreateSection("⭐ • XP")

AutomationTab:CreateToggle({
	Name = "🆙 • Auto EXP Dupe",
	CurrentValue = false,
	Flag = "EXPDupe",
	Callback = function(Value)
		while Flags.EXPDupe.CurrentValue and task.wait() do
			RemoteFunctions.Shop:InvokeServer({
				Command = "Buy",
				Type = "Item",
				Product = "Biodegradable Shovel",
				Amount = 5
			})
		end
	end,
})


AutomationTab:CreateSection("🎒 • Items")

AutomationTab:CreateToggle({
    Name = "💸 • Auto Open Specific Boxes",
    CurrentValue = false,
    Flag = "OpenBoxes",
    Callback = function(Value)
        local allowedBoxes = { "Magnet Box", "Frozen Container", "Sparkle Flask", "Crate", "Benson's Present", "Benson's Box", "Benson's Safe", "Chest" } 
        while Flags.OpenBoxes.CurrentValue do
            local count = 0
            for _, Tool in ipairs(Player.Backpack:GetChildren()) do
                for _, boxName in ipairs(allowedBoxes) do
                    if Tool.Name:find(boxName) then
                        RemoteEvents.Treasure:FireServer({
                            Command = "RedeemContainer",
                            Container = Tool
                        })
                        count = count + 1
                        break
                    end
                end
                if count >= 5 then
                    break
                end
            end
            if count == 0 then
                task.wait(1) -- Espera 1 segundo se não encontrar containers, para evitar loop excessivo
            else
                task.wait(0.1) -- Delay menor se encontrar containers
            end
        end
    end,
})



local CollectedRewards = {}

AutomationTab:CreateToggle({
    Name = "📦 • Auto Collect Salary Rewards (Will Appear Unclaimed)",
    CurrentValue = false,
    Flag = "Salary",
    Callback = function(Value)
        while Flags.Salary.CurrentValue and task.wait() do
            local TierTimers = RemoteFunctions.TimeRewards:InvokeServer({
                Command = "GetSessionTimers"
            })
            
            for Tier, Timer in TierTimers do
                if Timer ~= 0 then
                    CollectedRewards[Tier] = false
                    continue
                end
                
                if CollectedRewards[Tier] then
                    continue
                end
                
                RemoteFunctions.TimeRewards:InvokeServer({
                    Command = "RedeemTier",
                    Tier = Tier
                })
                
                CollectedRewards[Tier] = true
            end
            
            task.wait(5)
        end
    end,
})


AutomationTab:CreateToggle({
	Name = "💰 • Auto Sell Inventory at Max Capacity",
	CurrentValue = false,
	Flag = "Sell",
	Callback = function(Value)	
		while Flags.Sell.CurrentValue and task.wait() do
			local Capacity: TextLabel = Player.PlayerGui.Main.Core.Inventory.Disclaimer.Capacity
			local Current = tonumber(Capacity.Text:split("(")[2]:split("/")[1])
			local Max = tonumber(Capacity.Text:split(")")[1]:split("/")[2])

			if Current < Max then
				continue
			end
			
			SellInventory()
		end
	end,
})



-- Inventory Section
local Inventory2 = Window:CreateTab("Inventory", "backpack")

Inventory2:CreateSection("💰 • Shop")

if not Flags.MagnetBoxes then
    Flags.MagnetBoxes = {CurrentValue = 1}
end

Inventory2:CreateButton({
    Name = "🧲 • Purchase Magnet Box(es)",
    Callback = function()
        local amount = Flags.MagnetBoxes.CurrentValue
        RemoteFunctions.Shop:InvokeServer({
            Command = "Buy",
            Type = "Item",
            Product = "Magnet Box",
            Amount = amount
        })
    end,
})

Inventory2:CreateSlider({
    Name = "🗃 • Amount of Magnet Boxes to Purchase",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Magnet Box(es)",
    CurrentValue = 1,
    Flag = "MagnetBoxes", 
    Callback = function(value)
    end,
})

Inventory2:CreateButton({
    Name = "💰 • Sell ​​all your inventory",
    Callback = SellInventory 
})

Inventory2:CreateSection("🎒 • Inventory")

if not Player:GetAttribute("OriginalMaxInventorySize") then
    Player:SetAttribute("OriginalMaxInventorySize", Player:GetAttribute("MaxInventorySize"))
end

Inventory2:CreateToggle({
    Name = "♾ • Infinite Backpack Capacity (PATCHED)",
    CurrentValue = false,
    Flag = "InfiniteCap",
    Callback = function(Value)
        if Value then
            Player:SetAttribute("MaxInventorySize", 1e5)
        else
            Player:SetAttribute("MaxInventorySize", Player:GetAttribute("OriginalMaxInventorySize"))
        end
    end,
})

local function PinMoles(Tool: Tool)
	if not Flags.PinMoles.CurrentValue then
		return
	end
	
	if not Tool.Name:find("Mole") then
		return
	end
	
	if Tool:GetAttribute("Pinned") then
		return
	end

	RemoteFunctions.Inventory:InvokeServer({
		Command = "ToggleSlotPin",
		UID = Tool:GetAttribute("ID")
	})
end

Inventory2:CreateToggle({
	Name = "📌 • Auto Pin Moles",
	CurrentValue = false,
	Flag = "PinMoles",
	Callback = function(Value)
		if Value then
			for _, Tool: Tool in Player.Backpack:GetChildren() do
				PinMoles(Tool)
			end
		end
	end,
})

-- Seção Settings

local SettingsTab = Window:CreateTab("Settings", "settings")


SettingsTab:CreateSection("🎮 • Keybinds (BETA)")

local SellAllItemsBind = SettingsTab:CreateKeybind({
    Name = "💰 • Sell ​​all your inventory",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Flag = "Keybind1",
    Callback = SellInventory 

 })

SettingsTab:CreateSection("⚠️ • Info")

SettingsTab:CreateButton({
    Name = "🌐 Copy link Discord Server - TR Menus",
    Callback = function()
        setclipboard("https://discord.gg/rNAXhxN3hN")
        
    end,
})

SettingsTab:CreateSection("AFK")


SettingsTab:CreateToggle({
		Name = "🔒 • Anti AFK Disconnection",
		CurrentValue = true,
		Flag = "AntiAFK",
		Callback = function(Value)
		end,
	})

	if getgenv().IdledConnection then
		getgenv().IdledConnection:Disconnect()
	end

	getgenv().IdledConnection = Player.Idled:Connect(function()
		if not Flags.AntiAFK.CurrentValue then
			return
		end

		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.zero)
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightMeta, false, game)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightMeta, false, game)
	end)


-- HandleConnection

HandleConnection(workspace.Map.Temporary.ChildAdded:Connect(MeteorIslandTeleport), "Meteor")
HandleConnection(workspace.Map.Temporary.ChildRemoved:Connect(function(Child: Model?)
    if Child.Name == "Meteor Island" and PreviousLocation then
        Player.Character:PivotTo(PreviousLocation)
    end
end), "MeteorRemoved")

HandleConnection(workspace.Map.Islands.ChildAdded:Connect(LunarCloudsTeleport), "LunarClouds")
HandleConnection(workspace.Map.Islands.ChildRemoved:Connect(function(Child: Model)
    if Child.Name == "Lunar Clouds" and PreviousLocation then
        Player.Character:PivotTo(PreviousLocation)
    end
end), "LunarCloudsRemoved")


HandleConnection(Player.Backpack.ChildAdded:Connect(function(child)
    PinMoles(child)
end), "PinMoles")