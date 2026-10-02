-- ==========================================
-- PRO HUB V7.EXE - SIÊU GIAO DIỆN & 10 CHỨC NĂNG
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Xóa Hub cũ nếu đang mở để tránh trùng lặp
if CoreGui:FindFirstChild("ProHubV7_EXE") then
    CoreGui.ProHubV7_EXE:Destroy()
end

-- ==========================================
-- 1. THIẾT KẾ GIAO DIỆN (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProHubV7_EXE"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 350)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Bo góc cho MainFrame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Hiệu ứng viền phát sáng (UIStroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 50, 50)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Khung chứa ảnh nhân vật (Bên trái)
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 200, 1, 0)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
AvatarFrame.Parent = MainFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.ScaleType = Enum.ScaleType.Crop
-- ========================================================
-- ĐIỀN ID ẢNH CỦA BẠN VÀO ĐÂY (Thay dãy số 0 bằng ID của bạn)
AvatarImage.Image = "rbxassetid://0" 
-- ========================================================
AvatarImage.Parent = AvatarFrame

-- Tiêu đề Hub
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -200, 0, 40)
Title.Position = UDim2.new(0, 200, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PRO HUB V7.EXE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
}
TitleGradient.Parent = Title

-- Khung cuộn chứa 10 Chức Năng (Bên phải)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -210, 1, -50)
ScrollFrame.Position = UDim2.new(0, 205, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = ScrollFrame

-- ==========================================
-- 2. HỆ THỐNG TẠO NÚT CÓ ANIMATION
-- ==========================================
local function CreateToggleButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Button.Text = name .. " [ TẮT ]"
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.AutoButtonColor = false
    Button.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(80, 80, 80)
    BtnStroke.Parent = Button

    local toggled = false

    -- Animation khi Hover (lướt chuột/chạm)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        if not toggled then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        else
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        end
    end)

    -- Xử lý Click
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.Text = name .. " [ BẬT ]"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            BtnStroke.Color = Color3.fromRGB(255, 50, 50)
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
        else
            Button.Text = name .. " [ TẮT ]"
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            BtnStroke.Color = Color3.fromRGB(80, 80, 80)
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        end
        callback(toggled)
    end)
end

-- ==========================================
-- 3. LOGIC 10 CHỨC NĂNG SIÊU VIỆT
-- ==========================================

-- Chức năng 1: Aimbot Lock
local aimbotActive = false
CreateToggleButton("1. Aimbot Tự Khóa Mục Tiêu", function(state)
    aimbotActive = state
    RunService.RenderStepped:Connect(function()
        if aimbotActive then
            local closest = nil
            local shortestDistance = math.huge
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                    local pos = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if magnitude < shortestDistance then
                        closest = v
                        shortestDistance = magnitude
                    end
                end
            end
            if closest then
                camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
            end
        end
    end)
end)

-- Chức năng 2: Hitbox Siêu To khổng lồ
local hitboxActive = false
CreateToggleButton("2. Hitbox Mở Rộng x25", function(state)
    hitboxActive = state
    RunService.RenderStepped:Connect(function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if hitboxActive then
                    v.Character.HumanoidRootPart.Size = Vector3.new(25, 25, 25)
                    v.Character.HumanoidRootPart.Transparency = 0.5
                    v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Bright red")
                    v.Character.HumanoidRootPart.CanCollide = false
                else
                    v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end)
end)

-- Chức năng 3: ESP Hiện Khung Tên (Đơn giản hóa)
local espActive = false
CreateToggleButton("3. ESP (Nhìn xuyên tường)", function(state)
    espActive = state
    while espActive do
        task.wait(1)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                if not v.Character.Head:FindFirstChild("ESP_V7") then
                    local bg = Instance.new("BillboardGui", v.Character.Head)
                    bg.Name = "ESP_V7"
                    bg.Size = UDim2.new(0, 100, 0, 40)
                    bg.AlwaysOnTop = true
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1,0,1,0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    tl.Text = v.Name
                    tl.TextStrokeTransparency = 0
                end
            end
        end
    end
    if not espActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("ESP_V7") then
                v.Character.Head.ESP_V7:Destroy()
            end
        end
    end
end)

-- Chức năng 4: Siêu Tốc Độ (WalkSpeed)
CreateToggleButton("4. Tốc Độ Ánh Sáng (Speed)", function(state)
    if state and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 100
    elseif not state and player.Character then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Chức năng 5: Nhảy Cao (JumpPower)
CreateToggleButton("5. Siêu Nhảy Cao (Jump)", function(state)
    if state and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = 150
    elseif not state and player.Character then
        player.Character.Humanoid.JumpPower = 50
    end
end)

-- Chức năng 6: Bay Lượn Khắp Bản Đồ (Fly / Noclip Y)
CreateToggleButton("6. Bật Chế Độ Bay", function(state)
    if state and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
        bv.Name = "FlyV7"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 50, 0) -- Tự bay lên một chút
    else
        if player.Character and player.Character.HumanoidRootPart:FindFirstChild("FlyV7") then
            player.Character.HumanoidRootPart.FlyV7:Destroy()
        end
    end
end)

-- Chức năng 7: Đi Xuyên Tường (Noclip)
local noclipActive = false
CreateToggleButton("7. Đi Xuyên Tường (Noclip)", function(state)
    noclipActive = state
    RunService.Stepped:Connect(function()
        if noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Chức năng 8: Mắt Cú Đêm (Sáng mọi ngóc ngách)
CreateToggleButton("8. Sáng Mọi Bản Đồ (Fullbright)", function(state)
    if state then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.TimeOfDay = "12:00:00"
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
    end
end)

-- Chức năng 9: Mở rộng Góc Nhìn (FOV 120)
CreateToggleButton("9. Mở Rộng Góc Nhìn (FOV)", function(state)
    if state then
        camera.FieldOfView = 120
    else
        camera.FieldOfView = 70
    end
end)

-- Chức năng 10: Nhảy Liên Tục Trêm Không (Infinite Jump)
local infJumpActive = false
CreateToggleButton("10. Nhảy Vô Hạn (Inf Jump)", function(state)
    infJumpActive = state
    UserInputService.JumpRequest:Connect(function()
        if infJumpActive and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- ==========================================
-- 4. HIỆU ỨNG MỞ BẢNG TỪ TỪ (TWEEN ANIMATION)
-- ==========================================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)})
openTween:Play()

-- ==========================================
-- 5. NÚT ĐÓNG/MỞ MENU NHANH ĐỂ KHÔNG CHE MÀN HÌNH
-- ==========================================
local isMenuOpen = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightControl then
        isMenuOpen = not isMenuOpen
        if isMenuOpen then
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        end
    end
end)
