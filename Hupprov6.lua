local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- =========================================
-- ⚙️ CẤU HÌNH HỆ THỐNG
-- =========================================
local CONFIG = {
	HitboxSize = 25,
	AuraColor = Color3.fromRGB(160, 32, 240),
	TargetColor = Color3.fromRGB(255, 20, 20),
	FovRadius = 150,
	WalkSpeed = 35,
	JumpPower = 70,
	KillAuraRange = 30,
	SmoothAim = 0.2, -- Độ mượt của Aimbot (0.1 đến 1)
	SecretCode = "123codevip"
}

local flags = {
	Aimbot = false,
	Hitbox = false,
	FOVVisible = false,
	ESPAura = false,
	ESPText = false, -- Tính năng mới
	Speed = false,
	Jump = false,
	InfJump = false,
	-- TÍNH NĂNG VIP
	Fullbright = false, 
	Spinbot = false,
	Noclip = false,
	KillAura = false,
	Fly = false -- Tính năng VIP mới
}

local currentTarget = nil
local noclipConnection = nil
local flyBodyVelocity = nil

-- =========================================
-- 🎨 XÂY DỰNG GIAO DIỆN V6 ULTIMATE
-- =========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProHubV6_Ultimate"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- HỆ THỐNG THÔNG BÁO (NOTIFICATIONS)
local notifContainer = Instance.new("Frame", screenGui)
notifContainer.Size = UDim2.new(0, 250, 1, -20)
notifContainer.Position = UDim2.new(1, -260, 0, 10)
notifContainer.BackgroundTransparency = 1
local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 10)

local function sendNotification(text, color)
	local notif = Instance.new("Frame", notifContainer)
	notif.Size = UDim2.new(1, 50, 0, 40) -- Bắt đầu từ bên ngoài
	notif.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	notif.BackgroundTransparency = 0.1
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", notif).Color = color or Color3.fromRGB(0, 255, 150)
	
	local label = Instance.new("TextLabel", notif)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left

	-- Hiệu ứng trượt vào
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
	
	task.delay(3, function()
		-- Hiệu ứng mờ dần và xóa
		local fade = TweenService:Create(notif, TweenInfo.new(0.5), {BackgroundTransparency = 1})
		TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		Instance.new("UIStroke", notif) -- Xóa viền
		for _, v in ipairs(notif:GetChildren()) do if v:IsA("UIStroke") then v:Destroy() end end
		fade:Play()
		fade.Completed:Wait()
		notif:Destroy()
	end)
end

-- VÒNG TÂM (FOV)
local fovCircle = Instance.new("Frame", screenGui)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, CONFIG.FovRadius * 2, 0, CONFIG.FovRadius * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = flags.FOVVisible
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5

-- NÚT MỞ MENU
local iconBtn = Instance.new("ImageButton", screenGui)
iconBtn.Size = UDim2.new(0, 45, 0, 45)
iconBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
iconBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
iconBtn.Image = "rbxassetid://10888331510" 
iconBtn.Draggable = true
Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", iconBtn).Color = Color3.fromRGB(0, 255, 255)

-- KHUNG MENU CHÍNH
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 290)
mainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Size = UDim2.new(0, 420, 0, 0) -- Ẩn ban đầu
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local menuOpen = false
iconBtn.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	if menuOpen then
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 290)}):Play()
	else
		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 420, 0, 0)}):Play()
	end
end)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "  🚀 PRO HUB V6 - ULTIMATE"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

-- TABS
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(0, 120, 1, -30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)
Instance.new("UIListLayout", tabContainer).Padding = UDim.new(0, 2)

local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Size = UDim2.new(1, -125, 1, -30)
contentContainer.Position = UDim2.new(0, 125, 0, 30)
contentContainer.BackgroundTransparency = 1

local function createTab(tabName, icon)
	local tabBtn = Instance.new("TextButton", tabContainer)
	tabBtn.Size = UDim2.new(1, 0, 0, 35)
	tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	tabBtn.BorderSizePixel = 0
	tabBtn.Text = icon .. " " .. tabName
	tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.TextSize = 12

	local page = Instance.new("ScrollingFrame", contentContainer)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ScrollBarThickness = 2
	Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)

	tabBtn.MouseButton1Click:Connect(function()
		for _, child in ipairs(contentContainer:GetChildren()) do child.Visible = false end
		for _, child in ipairs(tabContainer:GetChildren()) do 
			if child:IsA("TextButton") then child.TextColor3 = Color3.fromRGB(200, 200, 200) end
		end
		page.Visible = true
		tabBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
	end)
	return page
end

local function createToggle(page, text, flagName, callback)
	local btn = Instance.new("TextButton", page)
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	btn.Text = text .. ": TẮT"
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		flags[flagName] = not flags[flagName]
		if flags[flagName] then
			btn.Text = text .. ": BẬT"
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 120), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			sendNotification("Đã BẬT: " .. text, Color3.fromRGB(0, 255, 100))
		else
			btn.Text = text .. ": TẮT"
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			sendNotification("Đã TẮT: " .. text, Color3.fromRGB(255, 100, 100))
		end
		if callback then callback(flags[flagName]) end
	end)
	return btn
end

-- =========================================
-- MENU TÍNH NĂNG
-- =========================================
local tabCombat = createTab("Chiến Đấu", "⚔️")
createToggle(tabCombat, "Ngắm Mượt (Smooth Aim)", "Aimbot")
createToggle(tabCombat, "Mở Rộng Hitbox", "Hitbox")

local tabVisuals = createTab("Nhìn Thấy", "👁️")
createToggle(tabVisuals, "Hiện Vòng Tâm", "FOVVisible")
createToggle(tabVisuals, "ESP Hào Quang", "ESPAura")
createToggle(tabVisuals, "ESP Tên & Máu (Mới)", "ESPText")

local tabPlayer = createTab("Nhân Vật", "🏃")
createToggle(tabPlayer, "Chạy Nhanh", "Speed")
createToggle(tabPlayer, "Nhảy Cao", "Jump")
createToggle(tabPlayer, "Nhảy Vô Hạn", "InfJump")

local tabCode = createTab("Khu Vực VIP", "👑")
local codeInput = Instance.new("TextBox", tabCode)
codeInput.Size = UDim2.new(1, -10, 0, 40)
codeInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
codeInput.PlaceholderText = "Nhập mã: 123codevip"
codeInput.Text = ""
codeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
codeInput.Font = Enum.Font.GothamSemibold
codeInput.TextSize = 13
Instance.new("UICorner", codeInput).CornerRadius = UDim.new(0, 6)

local codeBtn = Instance.new("TextButton", tabCode)
codeBtn.Size = UDim2.new(1, -10, 0, 35)
codeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
codeBtn.Text = "MỞ KHÓA VIP"
codeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
codeBtn.Font = Enum.Font.GothamBold
codeBtn.TextSize = 13
Instance.new("UICorner", codeBtn).CornerRadius = UDim.new(0, 6)

local vipFeaturesFrame = Instance.new("Frame", tabCode)
vipFeaturesFrame.Size = UDim2.new(1, 0, 0, 250)
vipFeaturesFrame.BackgroundTransparency = 1
vipFeaturesFrame.Visible = false
Instance.new("UIListLayout", vipFeaturesFrame).Padding = UDim.new(0, 5)

createToggle(vipFeaturesFrame, "⚡ Kill Aura (Tự Đánh)", "KillAura")
createToggle(vipFeaturesFrame, "☀️ Sáng Vô Cực", "Fullbright")
createToggle(vipFeaturesFrame, "🌪️ Spinbot (Chống Aim)", "Spinbot")
createToggle(vipFeaturesFrame, "👻 Đi Xuyên Tường", "Noclip", function(state)
	if state then
		noclipConnection = RunService.Stepped:Connect(function()
			if player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide == true then v.CanCollide = false end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	end
end)
createToggle(vipFeaturesFrame, "🚁 Bay (Fly VIP)", "Fly", function(state)
	if state then
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			flyBodyVelocity = Instance.new("BodyVelocity")
			flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
			flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			flyBodyVelocity.Parent = player.Character.HumanoidRootPart
		end
	else
		if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	end
end)

codeBtn.MouseButton1Click:Connect(function()
	if codeInput.Text == CONFIG.SecretCode then
		sendNotification("KÍCH HOẠT VIP THÀNH CÔNG!", Color3.fromRGB(255, 215, 0))
		codeInput.Visible = false
		codeBtn.Visible = false
		vipFeaturesFrame.Visible = true
	else
		sendNotification("Sai mã Code!", Color3.fromRGB(255, 50, 50))
	end
end)

for _, child in ipairs(contentContainer:GetChildren()) do child.Visible = false end
contentContainer:GetChildren()[1].Visible = true
sendNotification("Đã tải Pro Hub V6!", Color3.fromRGB(0, 255, 255))

-- =========================================
-- 🧠 HỆ THỐNG LOGIC ĐỈNH CAO V6
-- =========================================

local function getClosestEnemyForKillAura()
	local closestChar, shortestDist = nil, CONFIG.KillAuraRange
	local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			local dist = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if dist <= shortestDist then
				shortestDist = dist
				closestChar = v.Character
			end
		end
	end
	return closestChar
end

local function getBestAimTarget()
	local targetPart, shortestDist = nil, CONFIG.FovRadius
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			for _, part in ipairs(v.Character:GetChildren()) do
				if part:IsA("BasePart") then
					local pos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if dist < shortestDist then
							shortestDist = dist
							targetPart = part
							currentTarget = v.Character
						end
					end
				end
			end
		end
	end
	return targetPart
end

UserInputService.JumpRequest:Connect(function()
	if flags.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

RunService.RenderStepped:Connect(function()
	fovCircle.Visible = flags.FOVVisible
	local aimPart = flags.Aimbot and getBestAimTarget() or nil

	if currentTarget and aimPart then
		fovStroke.Color = Color3.fromRGB(255, 50, 50)
	else
		currentTarget = nil
		fovStroke.Color = Color3.fromRGB(255, 255, 255)
	end

	-- AIMBOT SMOOTH (LERP)
	if flags.Aimbot and aimPart then
		local targetCFrame = CFrame.new(camera.CFrame.Position, aimPart.Position)
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, CONFIG.SmoothAim)
	end

	-- Speed, Jump, Spinbot, Fly
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local hum = player.Character.Humanoid
		hum.WalkSpeed = flags.Speed and CONFIG.WalkSpeed or 16
		hum.JumpPower = flags.Jump and CONFIG.JumpPower or 50
		
		if flags.Spinbot and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
		end
		
		if flags.Fly and flyBodyVelocity then
			if hum.MoveDirection.Magnitude > 0 then
				flyBodyVelocity.Velocity = camera.CFrame.LookVector * (flags.Speed and CONFIG.WalkSpeed or 50)
			else
				flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end

	-- KILL AURA
	if flags.KillAura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local targetEnemy = getClosestEnemyForKillAura()
		if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
			local myHRP = player.Character.HumanoidRootPart
			local enemyHRP = targetEnemy.HumanoidRootPart
			local tool = player.Character:FindFirstChildOfClass("Tool")
			
			myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(enemyHRP.Position.X, myHRP.Position.Y, enemyHRP.Position.Z))

			if tool then
				tool:Activate()
				local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
				if handle and firetouchinterest then
					firetouchinterest(handle, enemyHRP, 0)
					firetouchinterest(handle, enemyHRP, 1)
				end
			end
		end
	end

	-- Fullbright
	if flags.Fullbright then
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
		Lighting.ColorShift_Top = Color3.new(1, 1, 1)
		Lighting.ClockTime = 12
	end

	-- Hitbox & ESP (Aura + Text)
	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
			local hrp = v.Character.HumanoidRootPart
			local hum = v.Character.Humanoid
			
			-- Hitbox
			if flags.Hitbox then
				if hrp.Size.X ~= CONFIG.HitboxSize then
					hrp.Size = Vector3.new(CONFIG.HitboxSize, CONFIG.HitboxSize, CONFIG.HitboxSize)
					hrp.Transparency = 0.9
					hrp.CanCollide = false
				end
			else
				if hrp.Size.X ~= 2 then
					hrp.Size = Vector3.new(2, 2, 1)
					hrp.Transparency = 1
				end
			end

			-- ESP Aura
			local hl = v.Character:FindFirstChild("ClientAura")
			if flags.ESPAura then
				if not hl then hl = Instance.new("Highlight", v.Character) hl.Name = "ClientAura" end
				hl.FillColor = (v.Character == currentTarget) and CONFIG.TargetColor or CONFIG.AuraColor
				hl.FillTransparency = (v.Character == currentTarget) and 0.2 or 0.5
			elseif hl then hl:Destroy() end
			
			-- ESP Text (Name & Health)
			local espUI = v.Character:FindFirstChild("ESPTextUI")
			if flags.ESPText and hum.Health > 0 then
				if not espUI then
					espUI = Instance.new("BillboardGui", v.Character)
					espUI.Name = "ESPTextUI"
					espUI.Size = UDim2.new(0, 200, 0, 50)
					espUI.StudsOffset = Vector3.new(0, 3, 0)
					espUI.AlwaysOnTop = true
					
					local textLabel = Instance.new("TextLabel", espUI)
					textLabel.Size = UDim2.new(1, 0, 1, 0)
					textLabel.BackgroundTransparency = 1
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextSize = 12
					textLabel.TextStrokeTransparency = 0.2
					textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				espUI.TextLabel.Text = string.format("%s\n❤ %d/%d", v.DisplayName, math.floor(hum.Health), math.floor(hum.MaxHealth))
				espUI.TextLabel.TextColor3 = (v.Character == currentTarget) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)
			elseif espUI then
				espUI:Destroy()
			end
		end
	end
end)
