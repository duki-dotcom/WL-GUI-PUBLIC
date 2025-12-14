-- duki wl chat sys

_G.DWLCHAT = _G.DWLCHAT or {}
local PC = _G.DWLCHAT
if PC._RUNNING then return end
PC._RUNNING = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
if not LP then return end

PC.Server = "http://51.222.102.71:8046"
PC.Conversations = PC.Conversations or {}
PC.Active = PC.Active or nil
PC.UI = PC.UI or {}

-- =========================
-- NAME CACHE
-- =========================
local NameCache = {}

local function getName(uid)
    uid = tostring(uid)
    if NameCache[uid] then
        return NameCache[uid]
    end
    local name = uid
    pcall(function()
        name = Players:GetNameFromUserIdAsync(tonumber(uid))
    end)
    NameCache[uid] = name
    return name
end

-- =========================
-- SEND
-- =========================
function PC.Send(targetUserId, text)
    if not targetUserId or not text or text == "" then return end
    local req = request or http_request or (syn and syn.request)
    if not req then return end

    targetUserId = tostring(targetUserId)
    PC.Conversations[targetUserId] = PC.Conversations[targetUserId] or { messages = {} }

    table.insert(PC.Conversations[targetUserId].messages, {
        from = "me",
        text = text,
        ts = os.time()
    })

    req({
        Url = PC.Server .. "/send",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            from = LP.UserId,
            to = targetUserId,
            payload = text
        })
    })
end

-- =========================
-- POLLER (1s)
-- =========================
task.spawn(function()
    local req = request or http_request or (syn and syn.request)
    if not req then return end

    while true do
        local res = req({
            Url = PC.Server .. "/poll?uid=" .. LP.UserId,
            Method = "GET"
        })

        if res and res.Body then
            local ok, msgs = pcall(HttpService.JSONDecode, HttpService, res.Body)
            if ok and type(msgs) == "table" then
                for _, m in ipairs(msgs) do
                    local uid = tostring(m.from)
                    PC.Conversations[uid] = PC.Conversations[uid] or { messages = {} }

                    table.insert(PC.Conversations[uid].messages, {
                        from = "them",
                        text = m.payload,
                        ts = os.time()
                    })

                    if PC._OnReceive then
                        PC._OnReceive(uid)
                    end
                end
            end
        end

        task.wait(1)
    end
end)

-- =========================
-- UI
-- =========================
do
    local pg = LP:WaitForChild("PlayerGui")
    if pg:FindFirstChild("DWL_PrivateChat") then
        pg.DWL_PrivateChat:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DWL_PrivateChat"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = pg
    PC.UI.Gui = gui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 520, 0, 320)
    main.Position = UDim2.new(0.5, -260, 0.5, -160)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "DWL Private Chat"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local startDM = Instance.new("TextBox", main)
    startDM.Size = UDim2.new(0, 150, 0, 28)
    startDM.Position = UDim2.new(0, 5, 0, 40)
    startDM.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    startDM.TextColor3 = Color3.fromRGB(255, 255, 255)
    startDM.PlaceholderText = "username or userId"
    startDM.Font = Enum.Font.Gotham
    startDM.TextSize = 14
    Instance.new("UICorner", startDM).CornerRadius = UDim.new(0, 6)

    local convoFrame = Instance.new("Frame", main)
    convoFrame.Position = UDim2.new(0, 5, 0, 75)
    convoFrame.Size = UDim2.new(0, 150, 1, -80)
    convoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    convoFrame.BorderSizePixel = 0
    Instance.new("UICorner", convoFrame).CornerRadius = UDim.new(0, 8)

    local convoLayout = Instance.new("UIListLayout", convoFrame)
    convoLayout.Padding = UDim.new(0, 4)

    local msgFrame = Instance.new("ScrollingFrame", main)
    msgFrame.Size = UDim2.new(1, -165, 1, -85)
    msgFrame.Position = UDim2.new(0, 160, 0, 40)
    msgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    msgFrame.BorderSizePixel = 0
    msgFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    msgFrame.ScrollBarImageTransparency = 0.5
    Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 8)

    local msgLayout = Instance.new("UIListLayout", msgFrame)
    msgLayout.Padding = UDim.new(0, 6)

    local input = Instance.new("TextBox", main)
    input.Size = UDim2.new(1, -170, 0, 30)
    input.Position = UDim2.new(0, 160, 1, -35)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Type message and press Enter..."
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    -- lock game input while typing
    input.Focused:Connect(function()
        UIS.ModalEnabled = true
    end)
    input.FocusLost:Connect(function()
        UIS.ModalEnabled = false
    end)

    -- =========================
    -- HELPERS
    -- =========================
    local function scrollToBottom()
        task.delay(0.03, function()
            msgFrame.CanvasPosition = Vector2.new(
                0,
                math.max(0, msgFrame.CanvasSize.Y.Offset - msgFrame.AbsoluteWindowSize.Y)
            )
        end)
    end

    local function clearMessages()
        for _, c in ipairs(msgFrame:GetChildren()) do
            if c:IsA("TextLabel") then
                c:Destroy()
            end
        end
    end

    local function loadConversation(uid)
        clearMessages()
        PC.Active = uid

        local convo = PC.Conversations[uid]
        if not convo then return end

        for _, m in ipairs(convo.messages) do
            local lbl = Instance.new("TextLabel", msgFrame)
            lbl.Size = UDim2.new(1, -10, 0, 20)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.BackgroundTransparency = 1
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14

            if m.from == "me" then
                lbl.TextColor3 = Color3.fromRGB(180, 220, 255)
                lbl.Text = "you: " .. m.text
            else
                lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
                lbl.Text = getName(uid) .. ": " .. m.text
            end
        end

        scrollToBottom()
    end

    local function rebuildConversationList()
        for _, c in ipairs(convoFrame:GetChildren()) do
            if c:IsA("TextButton") then
                c:Destroy()
            end
        end

        for uid in pairs(PC.Conversations) do
            local btn = Instance.new("TextButton", convoFrame)
            btn.Size = UDim2.new(1, -6, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = getName(uid)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                loadConversation(uid)
            end)
        end
    end

    -- =========================
    -- INPUTS
    -- =========================
    input.FocusLost:Connect(function(enter)
        if enter and PC.Active and input.Text ~= "" then
            PC.Send(PC.Active, input.Text)
            input.Text = ""
            loadConversation(PC.Active)
            rebuildConversationList()
        end
    end)

    startDM.FocusLost:Connect(function(enter)
        if not enter then return end

        local text = startDM.Text
        startDM.Text = ""

        local uid = tonumber(text)
        if not uid then
            local ok, id = pcall(function()
                return Players:GetUserIdFromNameAsync(text)
            end)
            if not ok then return end
            uid = id
        end

        uid = tostring(uid)
        PC.Conversations[uid] = PC.Conversations[uid] or { messages = {} }
        rebuildConversationList()
        loadConversation(uid)
    end)

    UIS.InputBegan:Connect(function(i, gp)
        if gp or UIS:GetFocusedTextBox() then return end
        if i.KeyCode == Enum.KeyCode.LeftBracket then
            gui.Enabled = not gui.Enabled
            if gui.Enabled then
                rebuildConversationList()
            end
        end
    end)

    -- =========================
    -- LIVE UPDATE HOOK
    -- =========================
    PC._OnReceive = function(uid)
        rebuildConversationList()

        if PC.Active == uid and gui.Enabled then
            loadConversation(uid)
        end
    end
end
