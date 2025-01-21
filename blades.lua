local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criando a janela principal do Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Blades & Buffoonery - Custom Menu",
    Icon = "shovel",
    LoadingTitle = "🌟 Blades & Buffoonery 🚀",
    LoadingSubtitle = "Todos os direitos reservados © Custom Menus 2025.",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "BladesBuffooneryMenus"
    },
    Discord = {
        Enabled = true,
        Invite = "rNAXhxN3hN",
        RememberJoins = true
    },
    KeySystem = false
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer

-- Funções Anti-Knockback e Imunidade
local function preventKnockback()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health > 0 then
            rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
        end
    end)

    character.HumanoidRootPart.Touched:Connect(function(hit)
        if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
            rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
        end
    end)
end

-- Make player invincible
local function makePlayerInvincible()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoid then
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        humanoid.BreakJointsOnDeath = false
    end
end

-- Apply both immunity and anti-knockback
local function applyImmunityAndAntiKnockback()
    makePlayerInvincible()
    preventKnockback()
end

-- Criando a aba "Funções"
local Inventarios = Window:CreateTab("Funções", "tree-palm")

Inventarios:CreateSection("🛠️ • Funções de Proteção")

-- Toggle para Anti-Knockback
Inventarios:CreateToggle({
    Name = "Anti-Knockback",
    CurrentValue = false,
    Callback = function(state)
        if state then
            applyImmunityAndAntiKnockback()
        else
            -- Lógica para desabilitar o Anti-Knockback
        end
    end
})

-- Toggle para Imunidade
Inventarios:CreateToggle({
    Name = "Imunidade ao Dano",
    CurrentValue = false,
    Callback = function(state)
        if state then
            makePlayerInvincible()
        else
            -- Lógica para desabilitar a Imunidade
        end
    end
})

-- Função para movimentar o jogador para baixo de outro
local function moveUnderPlayer(targetPlayer, humanoidRootPart)
    if targetPlayer and targetPlayer.Character then
        local targetCharacter = targetPlayer.Character
        local targetHumanoidRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
        local targetPosition = targetHumanoidRootPart.Position
        local newPosition = targetPosition - Vector3.new(0, targetHumanoidRootPart.Size.Y / 2 + humanoidRootPart.Size.Y / 2 + 1, 0)
        humanoidRootPart.CFrame = CFrame.new(newPosition)
    end
end

local function checkNearbyPlayers(humanoidRootPart)
    while true do
        local closestPlayer = nil
        local closestDistance = 10

        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= Player and player.Character then
                local targetCharacter = player.Character
                local targetHumanoidRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
                local distance = (humanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude

                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end

        if closestPlayer then
            moveUnderPlayer(closestPlayer, humanoidRootPart)
        end

        wait(0.1)
    end
end

-- Integrando Anti-Knockback e Imunidade
Player.CharacterAdded:Connect(applyImmunityAndAntiKnockback)
if Player.Character then
    applyImmunityAndAntiKnockback()
end

-- Começando a verificação de jogadores próximos
local character, humanoidRootPart = Player.Character or Player.CharacterAdded:Wait(), Player.Character:WaitForChild("HumanoidRootPart")
checkNearbyPlayers(humanoidRootPart)
