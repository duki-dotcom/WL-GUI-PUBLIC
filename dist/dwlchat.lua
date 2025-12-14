DUKI.PrivateChat = DUKI.PrivateChat or {}

DUKI.PrivateChat.Send = DUKI.PrivateChat.Send or function()
    warn("[DWL PrivateChat] Send() called before init")
end


DUKI.PrivateChat.Server = "http://51.222.102.71:8046"
DUKI.PrivateChat.Conversations = DUKI.PrivateChat.Conversations or {}
DUKI.PrivateChat.Active = DUKI.PrivateChat.Active or nil
DUKI.PrivateChat.UI = DUKI.PrivateChat.UI or {}

function DUKI.PrivateChat.Send(targetUserId, text)
    if not text or text == "" then return end

    local Http = DUKI.Services.HttpService
    local req = request or http_request or (syn and syn.request)
    if not req then return end

    -- local history
    DUKI.PrivateChat.Conversations[targetUserId] =
        DUKI.PrivateChat.Conversations[targetUserId] or { messages = {} }

    table.insert(
        DUKI.PrivateChat.Conversations[targetUserId].messages,
        { from = "me", text = text, ts = os.time() }
    )

    req({
        Url = DUKI.PrivateChat.Server .. "/send",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = Http:JSONEncode({
            from = game.Players.LocalPlayer.UserId,
            to = targetUserId,
            payload = text
        })
    })
end

local PrivateChat = DUKI.PrivateChat

task.spawn(function()
    local Http = DUKI.Services.HttpService
    local req = request or http_request or (syn and syn.request)
    local LP = game.Players.LocalPlayer

    if not req then return end

    while true do
        local res = req({
            Url = DUKI.PrivateChat.Server .. "/poll?uid=" .. LP.UserId,
            Method = "GET"
        })

        if res and res.Body then
            local msgs = Http:JSONDecode(res.Body)
            for _, m in ipairs(msgs) do
                local uid = tostring(m.from)
                DUKI.PrivateChat.Conversations[uid] =
                    DUKI.PrivateChat.Conversations[uid] or { messages = {} }

                table.insert(
                    DUKI.PrivateChat.Conversations[uid].messages,
                    { from = "them", text = m.payload, ts = os.time() }
                )

                if DUKI.PrivateChat._OnReceive then
    				DUKI.PrivateChat._OnReceive(uid)
				end

            end
        end

        task.wait(1)
    end
end)

-- PRIV CHAT
-- Toggle key: [


do
    local UIS = DUKI.Services.UserInputService
    local Players = DUKI.Services.Players
    local LP = Players.LocalPlayer
    local pg = LP:WaitForChild("PlayerGui")

    local PC = DUKI.PrivateChat
    PC.UI = PC.UI or {}

    -- ===== Destroy old UI if reloaded
    if pg:FindFirstChild("DWL_PrivateChat") then
        pg.DWL_PrivateChat:Destroy()
    end

    -- ===== ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "DWL_PrivateChat"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = pg
    PC.UI.Gui = gui

    -- ===== Main Frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 520, 0, 320)
    main.Position = UDim2.new(0.5, -260, 0.5, -160)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- ===== Title
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "DWL Private Chat"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

	-- ===== Start DM Input (Option B)
	local startDM = Instance.new("TextBox", main)
	startDM.Size = UDim2.new(0, 150, 0, 28)
	startDM.Position = UDim2.new(0, 5, 0, 40)
	startDM.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	startDM.TextColor3 = Color3.fromRGB(255, 255, 255)
	startDM.Text = ""
	startDM.PlaceholderText = "username or userId"
	startDM.ClearTextOnFocus = false
	startDM.Font = Enum.Font.Gotham
	startDM.TextSize = 14
	startDM.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", startDM).CornerRadius = UDim.new(0, 6)


    -- ===== Conversation List
    local convoFrame = Instance.new("Frame", main)
    convoFrame.Position = UDim2.new(0, 5, 0, 75)
	convoFrame.Size = UDim2.new(0, 150, 1, -80)
    convoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    convoFrame.BorderSizePixel = 0
    Instance.new("UICorner", convoFrame).CornerRadius = UDim.new(0, 8)

    local convoList = Instance.new("UIListLayout", convoFrame)
    convoList.Padding = UDim.new(0, 4)

    -- ===== Message Area
    local msgFrame = Instance.new("ScrollingFrame", main)
	msgFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	msgFrame.ScrollBarImageTransparency = 0.5
	msgFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    msgFrame.Size = UDim2.new(1, -165, 1, -85)
    msgFrame.Position = UDim2.new(0, 160, 0, 40)
    msgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    msgFrame.BorderSizePixel = 0
    Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 8)

    local msgList = Instance.new("UIListLayout", msgFrame)
    msgList.Padding = UDim.new(0, 6)

    -- ===== Input Box
    local input = Instance.new("TextBox", main)
    input.Size = UDim2.new(1, -170, 0, 30)
    input.Position = UDim2.new(0, 160, 1, -35)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.Text = ""
    input.PlaceholderText = "Type message and press Enter..."
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

  
-- UI LOGIC

    local function clearMessages()
        for _, c in ipairs(msgFrame:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
    end

	local function loadConversation(uid)
	    clearMessages()
	    PC.Active = uid
	    local convo = PC.Conversations[uid]
	    if not convo then return end
	
	    for _, m in ipairs(convo.messages) do
	        local lbl = Instance.new("TextLabel")
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
	            lbl.Text = uid .. ": " .. m.text
	        end
	
	        lbl.Parent = msgFrame
	    end
	
	    -- scroll AFTER layout finishes
	    task.delay(0.05, function()
	        msgFrame.CanvasPosition = Vector2.new(
	            0,
	            math.max(0, msgFrame.CanvasSize.Y.Offset - msgFrame.AbsoluteWindowSize.Y)
	        )
	    end)
	end


    local function rebuildConversationList()
        for _, c in ipairs(convoFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end

        for uid in pairs(PC.Conversations) do
            local btn = Instance.new("TextButton", convoFrame)
            btn.Size = UDim2.new(1, -6, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = uid
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			local display = uid
			pcall(function()
    			display = Players:GetNameFromUserIdAsync(tonumber(uid))
			end)
			btn.Text = display


            btn.MouseButton1Click:Connect(function()
                loadConversation(uid)
            end)
        end
    end

    input.FocusLost:Connect(function(enter)
        if not enter then return end
        if PC.Active and input.Text ~= "" then
            PrivateChat.Send(tonumber(PC.Active), input.Text)
            loadConversation(PC.Active)
            input.Text = ""
            rebuildConversationList()
        end
    end)

	local function startConversation(input)
	    if not input or input == "" then return end
	
	    local uid = input
	
	    -- Try username → UserId
	    if not tonumber(uid) then
	        local ok, id = pcall(function()
	            return Players:GetUserIdFromNameAsync(input)
	        end)
	        if ok then
	            uid = tostring(id)
	        else
	            return
	        end
	    else
	        uid = tostring(uid)
	    end
	
	    -- Create conversation if missing
	    PC.Conversations[uid] = PC.Conversations[uid] or { messages = {} }
	
	    PC.Active = uid
	    rebuildConversationList()
	    loadConversation(uid)
	end

	startDM.FocusLost:Connect(function(enter)
	    if not enter then return end
	
	    startConversation(startDM.Text)
	    startDM.Text = ""
	end)

    -- 🔔 NEW MESSAGE BANNER


    local banner = Instance.new("TextLabel", gui)
    banner.Size = UDim2.new(0, 400, 0, 30)
    banner.Position = UDim2.new(0.5, -200, 0, 20)
    banner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    banner.TextColor3 = Color3.fromRGB(255, 255, 255)
    banner.Font = Enum.Font.GothamBold
    banner.TextSize = 14
    banner.Visible = false
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)

    function PC.UI.Notify(from)
        if gui.Enabled then return end
        local display = from
		pcall(function()
    		display = Players:GetNameFromUserIdAsync(tonumber(from))
		end)
		banner.Text = "New Message from " .. display .. "!"

        banner.Visible = true
        task.delay(3, function()
            banner.Visible = false
        end)
    end

    -- TOGGLE KEY: [

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if UIS:GetFocusedTextBox() then return end
        if i.KeyCode == Enum.KeyCode.LeftBracket then
            gui.Enabled = not gui.Enabled
            if gui.Enabled then
                rebuildConversationList()
            end
        end
    end)

    PC._OnReceive = function(uid)
        rebuildConversationList()
        PC.UI.Notify(uid)
    end
end
