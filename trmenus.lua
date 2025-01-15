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
        if Rayfield.Flags[flag] and Rayfield.Flags[flag].CurrentValue then
            connection(...)
        end
    end)
end


-- Functions 


local function SellAllInventory()
    Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local Capacity = Player.PlayerGui.Main.Core.Inventory.Disclaimer.Capacity

    local Inventory = RemoteFunctions.Player:InvokeServer({
        Command = "GetInventory"
    })

    local AnyObjects = false

    for _, Object in pairs(Inventory) do
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

    for _, v in ipairs(workspace.Map.Islands:GetDescendants()) do
        if v.Name ~= "Title" or not v:IsA("TextLabel") or v.Text ~= "Merchant" then
            continue
        end

        local Merchant = v.Parent.Parent

        local PreviousPosition = Player.Character:GetPivot()

        local PreviousText = Capacity.Text

        repeat
            Player.Character:PivotTo(Merchant:GetPivot())

            RemoteEvents.Merchant:FireServer({
                Command = "SellAllTreasures",
                Merchant = Merchant
            })

            task.wait(0.1)
        until Capacity.Text ~= PreviousText

        Player.Character:PivotTo(PreviousPosition)

        break
    end

    -- Notificação após vender tudo
    Rayfield:Notify({
        Title = "💰 • Sell ​​all your inventory",
        Content = "You sold all your items!",
        Duration = 6.5,
        Image = "message-circle-warning",
    })
end


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
    if Meteor.Name ~= "Meteor Island" or not Rayfield.Flags.Meteor.CurrentValue then
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
    if Lunar.Name ~= "Lunar Clouds" or not Rayfield.Flags.LunarClouds.CurrentValue then
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


-- Automação de mineração
local AutomationTab = Window:CreateTab("Automation", "repeat")
AutomationTab:CreateSection("🛠️ • Digging")

AutomationTab:CreateToggle({
    Name = "⛏️ • Auto Dig Close Piles (Faster)",
    CurrentValue = false,
    Flag = "Dig",
	Callback = function(Value)
		task.spawn(function()
			while Rayfield.Flags.Dig.CurrentValue and task.wait() do
				local DigMinigame = Player.PlayerGui.Main:FindFirstChild("DigMinigame")

				if not DigMinigame then
					continue
				end
				
				DigMinigame.Cursor.Position = DigMinigame.Area.Position
			end
		end)
		
		while Rayfield.Flags.Dig.CurrentValue and task.wait() do
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

AutomationTab:CreateSection("🤖 • Auto Click")

AutomationTab:CreateToggle({
    Name = "🕹️ • Auto Minigame | 100% Success",
    CurrentValue = false,
    Flag = "PileMinigame",
    Callback = function(Value)    
        while Rayfield.Flags.PileMinigame.CurrentValue and task.wait() do
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
        while Rayfield.Flags.CreatePiles.CurrentValue and task.wait() do    
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

AutomationTab:CreateSection("🎒 • Items")

AutomationTab:CreateToggle({
    Name = "💸 • Auto Open Magnet Boxes",
    CurrentValue = false,
    Flag = "OpenMagnet",
    Callback = function(Value)
        while Rayfield.Flags.OpenMagnet.CurrentValue and task.wait() do
            local count = 0
            for _, Tool in ipairs(Player.Backpack:GetChildren()) do
                if Tool.Name:find("Magnet Box") then
                    RemoteEvents.Treasure:FireServer({
                        Command = "RedeemContainer",
                        Container = Tool
                    })
                    count = count + 1
                    if count >= 5 then
                        break
                    end
                end
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
        while Rayfield.Flags.Salary.CurrentValue and task.wait() do
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

-- Inventory Section
local Inventory2 = Window:CreateTab("Inventory", "backpack")

Inventory2:CreateSection("💰 • Shop")

if not Rayfield.Flags.MagnetBoxes then
    Rayfield.Flags.MagnetBoxes = {CurrentValue = 1}
end

Inventory2:CreateButton({
    Name = "🧲 • Purchase Magnet Box(es)",
    Callback = function()
        local amount = Rayfield.Flags.MagnetBoxes.CurrentValue
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
    Callback = SellAllInventory 
})




Inventory2:CreateSection("🎒 • Inventory")

if not Player:GetAttribute("OriginalMaxInventorySize") then
    Player:SetAttribute("OriginalMaxInventorySize", Player:GetAttribute("MaxInventorySize"))
end

Inventory2:CreateToggle({
    Name = "♾ • Infinite Backpack Capacity",
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

-- PinMoles function and its handler
local function PinMoles(Tool: Tool)
    if not Rayfield.Flags.PinMoles.CurrentValue then
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
    Callback = SellAllInventory 

 })

SettingsTab:CreateSection("⚠️ • Info")

SettingsTab:CreateButton({
    Name = "🌐 Copy link Discord Server - TR Menus",
    Callback = function()
        setclipboard("https://discord.gg/rNAXhxN3hN")
        
    end,
})





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
