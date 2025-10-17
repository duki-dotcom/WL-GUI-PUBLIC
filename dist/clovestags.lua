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
    },
    qalvez = {
        EnableTags = true,
        TagValue = "TOP I",
        TagColor = Color3.fromRGB(230, 230, 230)
    },
    fawoz = {
        EnableTags = true,
        TagValue = "TOP I",
        TagColor = Color3.fromRGB(230, 230, 230)
    },
    ix_pandina = {
        EnableTags = true,
        TagValue = "TOP II",
        TagColor = Color3.fromRGB(136, 8, 8)
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


local TextChatService = game:GetService("TextChatService")

local boldFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local black = Color3.fromRGB(0, 0, 0)

local function applyProps(target, props)
    for key, value in pairs(props) do
        target[key] = value
    end
end

local window = TextChatService:FindFirstChild("ChatWindowConfiguration")
if window then
    applyProps(window, {
        BackgroundColor3 = Color3.fromRGB(25, 27, 29),
        BackgroundTransparency = 0.5,
        FontFace = boldFont,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        TextStrokeColor3 = black,
        TextStrokeTransparency = 0.5,
    })
end

local inputBar = TextChatService:FindFirstChild("ChatInputBarConfiguration")
if inputBar then
    applyProps(inputBar, {
        BackgroundColor3 = Color3.fromRGB(181, 181, 181),
        BackgroundTransparency = 0.5,
        FontFace = boldFont,
        PlaceholderColor3 = Color3.fromRGB(52, 52, 52),
        TextColor3 = Color3.fromRGB(52, 52, 52),
        TextSize = 18,
        TextStrokeColor3 = black,
        TextStrokeTransparency = 1,
    })
end

-- shaders
game.Lighting.Ambient = Color3.fromRGB(60, 63, 69)
game.Lighting.OutdoorAmbient = Color3.fromRGB(143, 143, 143)
game.Lighting.Brightness = 0
game.Lighting.EnvironmentDiffuseScale = .5
game.Lighting.EnvironmentSpecularScale = .3
game.Lighting.ShadowSoftness = 0
game.Lighting.FogColor.Color3.fromRGB(231, 238, 255)

game.Lighting.Sky.CelestialBodiesShown = true

local CC = game.Lighting.ColorCorrection
CC.Brightness = .03
CC.Contrast = .1
CC.Saturation = .1
CC.TintColor = Color3.fromRGB(255, 244, 241)

local BLOOM = game.Lighting.Bloom
BLOOM.Intensity = .2
BLOOM.Size = 30
BLOOM.Threshold = .7

Instance.new("SunRaysEffect", game.Lighting).Enabled = true
local RAYS = game.Lighting.SunRays
RAYS.Intensity = .5
RAYS.Spread = 10
