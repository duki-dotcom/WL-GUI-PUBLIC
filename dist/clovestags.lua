-- CONFIG

local userSettings = {
    etrixcielle = {
        EnableTags = true,
        TagValue = "TOP O",
        TagColor = Color3.fromRGB(230, 230, 230)
    },
    hexcias = {
        EnableTags = false,
        TagValue = "HEX",
        TagColor = Color3.fromRGB(160, 0, 0)
    },
    nyxises = {
        EnableTags = true,
        TagValue = "TOP O",
        TagColor = Color3.fromRGB(230, 230, 230)
    },
    nyxcielle = {
        EnableTags = true,
        TagValue = "TOP O",
        TagColor = Color3.fromRGB(169, 227, 223)
    },
    kleenbeans = {
        EnableTags = true,
        TagValue = "  BEANS",
        TagColor = Color3.fromRGB(255, 229, 102)
    },
    DukiDokii = {
        EnableTags = true,
        TagValue = "TOP I",
        TagColor = Color3.fromRGB(230, 230, 230)
    }
}

local nameFont = "rbxasset://fonts/families/MERRIWEATHER.json"
local bioFont = "rbxasset://fonts/families/MERRIWEATHER.json"
local vipFont = "rbxasset://fonts/families/RomanAntique.json"
local tagFont = "rbxasset://fonts/families/RomanAntique.json"

local nameColor = Color3.new(1, 1, 1)
local bioColor = Color3.new(1, 1, 1)
local vipColor = Color3.fromRGB(50, 50, 50)
local vipStroke = Color3.fromRGB(0, 0, 0)
local teamStroke = Color3.fromRGB(0, 0, 0)

local nameYOffset = -0.1

---------------------------------------------------------------

local function applyCustomizations(player)
    local settings = userSettings[player.Name]
    if not settings then return end

    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")

    local billboard
    repeat
        billboard = head:FindFirstChild("BillboardGui")
        task.wait(0.25)
    until billboard

    -- Apply name + bio changes
    for _, labelName in ipairs({"TextLabel", "desc"}) do
        local label = billboard:FindFirstChild(labelName)
        if label then
            label.Position = label.Position + UDim2.new(0, 0, nameYOffset, 0)
            local fontToUse = (labelName == "TextLabel") and nameFont or bioFont
            local colorToUse = (labelName == "TextLabel") and nameColor or bioColor

            label.FontFace = Font.new(fontToUse, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            label.TextColor3 = colorToUse
        end
    end

    if settings.EnableTags then
        local frame
        repeat
            local gui = billboard
            frame = gui and gui:FindFirstChild("Frame")
            task.wait(5)
        until frame

        local vip = frame:FindFirstChild("VIP")
        if vip then
            vip.TextColor3 = vipColor
            vip.TextStrokeColor3 = vipStroke
            vip.FontFace = Font.new(vipFont, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end

        local team = frame:FindFirstChild("Team")
        if team then
            team.TextColor3 = settings.TagColor
            team.TextStrokeColor3 = teamStroke
            team.FontFace = Font.new(tagFont, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            team.Text = settings.TagValue
        end
    end
end

---------------------------------------------------------------

for _, player in ipairs(game.Players:GetPlayers()) do
    task.defer(applyCustomizations, player)
    player.CharacterAdded:Connect(function()
        task.wait(10)
        applyCustomizations(player)
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(10)
        applyCustomizations(player)
    end)
end)