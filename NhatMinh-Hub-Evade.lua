-- Tải WindUI
local WindUI = loadstring(game:HttpGet(
"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Tạo cửa sổ chính
local Window = WindUI:CreateWindow({
Title = "KOMAT UNITY HUB",
Icon = "rbxassetid://7733658504",
Author = "Nhật Minh", -- Đã cập nhật thành Nhật Minh
Folder = "NhatMinhHub",
Size = UDim2.fromOffset(420, 320),
Transparent = true,
Theme = "Dark",
SideBarWidth = 180,
})

local SettingsTab = Window:Tab({
    Title = "Cài đặt",
    Icon = "settings"
})

-- =========================
-- DANH MỤC CHÍNH
-- =========================
local MainMenu = Window:Tab({
Title = "Menu Chính",
Icon = "home"
})

local EmoteTab = Window:Tab({
    Title = "Hành động",
    Icon = "smile"
})

-- =========================
-- DANH MỤC KHÁC
-- =========================
local ExtraTab = Window:Tab({
    Title = "Khác",
    Icon = "box"
})

-- =========================
-- TAB FARM
-- =========================
local FarmTab = Window:Tab({
    Title = "Tự động Farm",
    Icon = "coins"
})

-- =========================
-- TAB HIỂN THỊ (ESP/VIEW)
-- =========================
local ViewTab = Window:Tab({
    Title = "Hiển thị",
    Icon = "eye"
})
 
-- =========================
-- TAB SỰ KIỆN (WINDUI)
-- =========================
local EventTab = Window:Tab({
    Title = "Sự kiện",
    Icon = "zap"
})

-- =========================
-- DỊCH VỤ HỆ THỐNG
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- =========================
-- TỰ ĐỘNG NHẢY (BUNNY HOP PRO)
-- =========================
local autoJump = false
local autoJumpConnection = nil

local function startAutoJump()
if autoJumpConnection then return end

autoJumpConnection = RunService.Heartbeat:Connect(function()  
    if not autoJump then return end  

    local char = player.Character  
    if not char then return end  

    local hum = char:FindFirstChild("Humanoid")  
    local hrp = char:FindFirstChild("HumanoidRootPart")  
    if not hum or not hrp then return end  

    -- Raycast xuống mặt đất  
    local rayOrigin = hrp.Position  
    local rayDirection = Vector3.new(0, -6, 0)  

    local rayParams = RaycastParams.new()  
    rayParams.FilterDescendantsInstances = {char}  
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist  

    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)  

    if result then  
        local distance = (rayOrigin - result.Position).Magnitude  

        -- Gần chạm đất sẽ tự động bật lên ngay lập tức  
        if distance <= 4 then  
            hum:ChangeState(Enum.HumanoidStateType.Jumping)  
        end  
    end  
end)

end

local function stopAutoJump()
if autoJumpConnection then
autoJumpConnection:Disconnect()
autoJumpConnection = nil
end
end

-- =========================
-- GIAO DIỆN NÚT NỔI (FLOATING GUI)
-- =========================
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "FloatingBounceGui"
FloatingGui.Parent = game.CoreGui

local floatingBounceButton = nil

function createBounceFloatingButton()
if floatingBounceButton then return end

local btn = Instance.new("TextButton")  
floatingBounceButton = btn  

btn.Size = UDim2.new(0,140,0,52)  
btn.Position = UDim2.new(0.5,-70,0.85,0)  
btn.AnchorPoint = Vector2.new(0.5,0)  
btn.BackgroundColor3 = Color3.fromRGB(180,220,255)  
btn.BackgroundTransparency = 0.35  
btn.TextColor3 = Color3.fromRGB(0,70,150)  
btn.Text = autoJump and "Tự Động Nhảy: BẬT" or "Tự Động Nhảy: TẮT"  
btn.Font = Enum.Font.GothamBold  
btn.TextSize = 14  
btn.Parent = FloatingGui  
btn.Active = true  
btn.Draggable = true  

local corner = Instance.new("UICorner", btn)  
corner.CornerRadius = UDim.new(0,18)  

local stroke = Instance.new("UIStroke", btn)  
stroke.Thickness = 2.5  
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border  
stroke.Color = Color3.fromRGB(0,120,255)  

-- Hiệu ứng đổi màu viền mượt mà  
task.spawn(function()  
    while btn.Parent do  
        TweenService:Create(stroke, TweenInfo.new(0.8), {  
            Color = Color3.fromRGB(0,80,255)  
        }):Play()  
        task.wait(0.8)  

        TweenService:Create(stroke, TweenInfo.new(0.8), {  
            Color = Color3.fromRGB(160,230,255)  
        }):Play()  
        task.wait(0.8)  
    end  
end)  

btn.MouseButton1Click:Connect(function()  
    autoJump = not autoJump  

    if autoJump then  
        startAutoJump()  
    else  
        stopAutoJump()  
    end  

    btn.Text = autoJump and "Tự Động Nhảy: BẬT" or "Tự Động Nhảy: TẮT"  
end)

end

function removeBounceFloatingButton()
if floatingBounceButton then
floatingBounceButton:Destroy()
floatingBounceButton = nil
end
end

-- =========================
-- CÁC NÚT BẬT/TẮT TRÊN GIAO DIỆN
-- =========================
MainMenu:Toggle({
Title = "Tự động nhảy",
Desc = "Tự động thực hiện bước nhảy (Bhop)",
Default = false,
Callback = function(state)
autoJump = state
if state then
startAutoJump()
else
stopAutoJump()
end
end
})

MainMenu:Toggle({
Title = "Tự động nhảy (Nút nổi)",
Desc = "Hiển thị nút bật/tắt nhanh trên màn hình",
Default = false,
Callback = function(state)
if state then
createBounceFloatingButton()
else
removeBounceFloatingButton()
end
end
})

-- =========================
-- HỆ THỐNG TRƯỢT VÔ HẠN (INFINITY SLIDE SYSTEM PRO)
-- =========================
local infiniteSlideEnabled = false
local cachedTables = nil
local plrModel = nil
local slideConnection = nil
local floatingSlideButton = nil

local slideFrictionValue = -8

-- =========================
-- CẤU HÌNH TRƯỢT
-- =========================
local keys = {
"Friction","AirStrafeAcceleration","JumpHeight","RunDeaccel",
"JumpSpeedMultiplier","JumpCap","SprintCap","WalkSpeedMultiplier",
"BhopEnabled","Speed","AirAcceleration","RunAccel","SprintAcceleration"
}

local function hasAll(tbl)
if type(tbl) ~= "table" then return false end
for _, k in ipairs(keys) do
if rawget(tbl, k) == nil then return false end
end
return true
end

local function setFriction(value)
if not cachedTables then return end
for _, t in ipairs(cachedTables) do
pcall(function()
t.Friction = value
end)
end
end

local function updatePlayerModel()
local GameFolder = workspace:FindFirstChild("Game")
local PlayersFolder = GameFolder and GameFolder:FindFirstChild("Players")
if PlayersFolder then
plrModel = PlayersFolder:FindFirstChild(player.Name)
else
plrModel = nil
end
end

local function onHeartbeat()
if not plrModel then
setFriction(5)
return
end

local success, currentState = pcall(function()  
    return plrModel:GetAttribute("State")  
end)  

if success and currentState then  
    if currentState == "Slide" then  
        pcall(function()  
            plrModel:SetAttribute("State", "EmotingSlide")  
        end)  
    elseif currentState == "EmotingSlide" then  
        setFriction(slideFrictionValue)  
    else  
        setFriction(5)  
    end  
else  
    setFriction(5)  
end

end

-- =========================
-- KÍCH HOẠT TRƯỢT VÔ HẠN
-- =========================
local function setInfiniteSlide(state)
infiniteSlideEnabled = state

if slideConnection then  
    slideConnection:Disconnect()  
    slideConnection = nil  
end  

if state then  
    cachedTables = {}  

    for _, obj in ipairs(getgc(true)) do  
        local success, result = pcall(function()  
            if hasAll(obj) then return obj end  
        end)  
        if success and result then  
            table.insert(cachedTables, result)  
        end  
    end  

    updatePlayerModel()  

    slideConnection = RunService.Heartbeat:Connect(onHeartbeat)  

    player.CharacterAdded:Connect(function()  
        task.wait(0.1)  
        updatePlayerModel()  
    end)  

else  
    cachedTables = nil  
    plrModel = nil  
    setFriction(5)
end  

-- Đồng bộ trạng thái nút nổi  
if floatingSlideButton then  
    floatingSlideButton.BackgroundColor3 =  
        state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)  

    floatingSlideButton.Text =  
        state and "Trượt Vô Hạn: BẬT" or "Trượt Vô Hạn: TẮT"  
end

end

-- =========================
-- NÚT NỔI TRƯỢT VÔ HẠN
-- =========================
local function createSlideButton()
if floatingSlideButton then return end

local btn = Instance.new("TextButton")  
floatingSlideButton = btn  

btn.Size = UDim2.new(0,140,0,52)  
btn.Position = UDim2.new(0.5,-70,0.85,0)  
btn.AnchorPoint = Vector2.new(0.5,0)  
btn.BackgroundColor3 = Color3.fromRGB(180,220,255)  
btn.BackgroundTransparency = 0.35  
btn.TextColor3 = Color3.fromRGB(0,70,150)  
btn.Text = infiniteSlideEnabled and "Trượt Vô Hạn: BẬT" or "Trượt Vô Hạn: TẮT"  
btn.Font = Enum.Font.GothamBold  
btn.TextSize = 14  
btn.Parent = FloatingGui  
btn.Active = true  
btn.Draggable = true  

-- Bo góc  
local corner = Instance.new("UICorner", btn)  
corner.CornerRadius = UDim.new(0,18)  

-- Viền  
local stroke = Instance.new("UIStroke", btn)  
stroke.Thickness = 2.5  
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border  
stroke.Color = Color3.fromRGB(0,120,255)  

-- Hiệu ứng đổi màu viền  
task.spawn(function()  
    while btn.Parent do  
        TweenService:Create(  
            stroke,  
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),  
            {Color = Color3.fromRGB(0,80,255)}  
        ):Play()  
        task.wait(0.8)  

        TweenService:Create(  
            stroke,  
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),  
            {Color = Color3.fromRGB(160,230,255)}  
        ):Play()  
        task.wait(0.8)  
    end  
end)  

-- Sự kiện nhấn nút  
btn.MouseButton1Click:Connect(function()  
    setInfiniteSlide(not infiniteSlideEnabled)  
end)

end

local function removeSlideButton()
if floatingSlideButton then
floatingSlideButton:Destroy()
floatingSlideButton = nil
end
end

-- =========================
-- NÚT TRƯỢT VÔ HẠN TRÊN MENU
-- =========================
MainMenu:Toggle({
Title = "Trượt vô hạn",
Desc = "Giữ trạng thái trượt không giới hạn",
Default = false,
Callback = function(state)
setInfiniteSlide(state)
end
})

MainMenu:Toggle({
Title = "Trượt vô hạn (Nút nổi)",
Desc = "Hiển thị nút trượt nhanh trên màn hình",
Default = false,
Callback = function(state)
if state then
createSlideButton()
else
removeSlideButton()
setInfiniteSlide(false)
end
end
})

-- =========================
-- HỆ THỐNG TỰ ĐỘNG CHỐNG NGÃ / NẢY (AUTO TRIP PRO)
-- =========================
local autoTrip = false
local autoTripConnection = nil

local bounceHeight = 100
local bounceDistance = 6

local floatingTripButton = nil

-- =========================
-- RAYCAST ĐA ĐIỂM
-- =========================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isNearGround(hrp, char)
rayParams.FilterDescendantsInstances = {char}

local offsets = {  
    Vector3.new(0, -bounceDistance, 0),  
    Vector3.new(2, -bounceDistance, 0),  
    Vector3.new(-2, -bounceDistance, 0),  
    Vector3.new(0, -bounceDistance, 2),  
    Vector3.new(0, -bounceDistance, -2)  
}  

for _, offset in pairs(offsets) do  
    local result = workspace:Raycast(hrp.Position, offset, rayParams)  
    if result and result.Instance and result.Instance.CanCollide then  
        return true  
    end  
end  

return false

end

-- =========================
-- KÍCH HOẠT AUTO TRIP
-- =========================
local function startAutoTrip()
if autoTripConnection then return end

autoTripConnection = RunService.Heartbeat:Connect(function()  
    if not autoTrip then return end  

    local char = player.Character  
    if not char then return end  

    local hrp = char:FindFirstChild("HumanoidRootPart")  
    if not hrp then return end  

    local vel = hrp.Velocity  

    -- Điều kiện: Đang rơi tự do mạnh + Gần mặt đất  
    if vel.Y < -35 and isNearGround(hrp, char) then  
        hrp.Velocity = Vector3.new(vel.X, bounceHeight, vel.Z)  
    end
end)

end

local function stopAutoTrip()
if autoTripConnection then
autoTripConnection:Disconnect()
autoTripConnection = nil
end
end

-- =========================
-- NÚT NỔI AUTO TRIP
-- =========================
local function createTripButton()
if floatingTripButton then return end

local btn = Instance.new("TextButton")  
floatingTripButton = btn  

btn.Size = UDim2.new(0,140,0,52)  
btn.Position = UDim2.new(0.5,-70,0.75,0)  
btn.AnchorPoint = Vector2.new(0.5,0)  
btn.BackgroundColor3 = Color3.fromRGB(180,220,255)  
btn.BackgroundTransparency = 0.35  
btn.TextColor3 = Color3.fromRGB(0,70,150)  
btn.Text = autoTrip and "Auto Trip: BẬT" or "Auto Trip: TẮT"  
btn.Font = Enum.Font.GothamBold  
btn.TextSize = 14  
btn.Parent = FloatingGui  
btn.Active = true  
btn.Draggable = true  

local corner = Instance.new("UICorner", btn)  
corner.CornerRadius = UDim.new(0,18)  

local stroke = Instance.new("UIStroke", btn)  
stroke.Thickness = 2.5  
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border  
stroke.Color = Color3.fromRGB(0,120,255)  

task.spawn(function()  
    while btn.Parent do  
        TweenService:Create(stroke, TweenInfo.new(0.8), {  
            Color = Color3.fromRGB(0,80,255)  
        }):Play()  
        task.wait(0.8)  

        TweenService:Create(stroke, TweenInfo.new(0.8), {  
            Color = Color3.fromRGB(160,230,255)  
        }):Play()  
        task.wait(0.8)  
    end  
end)  

btn.MouseButton1Click:Connect(function()  
    autoTrip = not autoTrip  

    if autoTrip then  
        startAutoTrip()  
    else  
        stopAutoTrip()  
    end  

    btn.Text = autoTrip and "Auto Trip: BẬT" or "Auto Trip: TẮT"  
end)

end

local function removeTripButton()
if floatingTripButton then
floatingTripButton:Destroy()
floatingTripButton = nil
end
end

-- =========================
-- THIẾT LẬP AUTO TRIP TRÊN MENU
-- =========================
MainMenu:Toggle({
Title = "Tự động chống ngã (Auto Trip)",
Desc = "Tự động nẩy lên khi rơi mạnh gần đất",
Default = false,
Callback = function(state)
autoTrip = state
if state then
startAutoTrip()
else
stopAutoTrip()
end
end
})

MainMenu:Toggle({
Title = "Tự động chống ngã (Nút nổi)",
Desc = "Hiển thị nút nẩy nhanh chống ngã",
Default = false,
Callback = function(state)
if state then
createTripButton()
else
removeTripButton()
autoTrip = false
stopAutoTrip()
end
end
})

-- Thanh trượt chỉnh độ cao nẩy
MainMenu:Slider({
Title = "Độ cao lực nẩy",
Desc = "Tùy chỉnh khoảng cách bật nhảy lên",
Value = {
Min = 50,
Max = 200,
Default = 100
},
Callback = function(val)
bounceHeight = val
end
})

-- =========================
-- HỆ THỐNG LÀM NGẮT KẾT NỐI TẠM THỜI (LAG SWITCH)
-- =========================
local floatingLagButton = nil

local function lagSwitch(duration)
local start = tick()
while tick() - start < duration do
for i = 1, 200000 do 
local _ = math.random()
end
end
end

-- Nút bấm trên Menu chính
MainMenu:Button({
Title = "Kích hoạt Lag tạm thời",
Desc = "Gây lag đứng hình trong 0.5 giây",
Callback = function()
lagSwitch(0.5)
end
})

-- Tạo nút nổi cho tính năng Lag Switch
local function createLagFloatingButton()
if floatingLagButton then return end

local btn = Instance.new("TextButton")  
floatingLagButton = btn  

btn.Size = UDim2.new(0,140,0,52)  
btn.Position = UDim2.new(0.5,-70,0.65,0)  
btn.AnchorPoint = Vector2.new(0.5,0)  
btn.BackgroundColor3 = Color3.fromRGB(180,220,255)  
btn.BackgroundTransparency = 0.35  
btn.TextColor3 = Color3.fromRGB(0,70,150)  
btn.Text = "Kích Hoạt Lag"  
btn.Font = Enum.Font.GothamBold  
btn.TextSize = 14  
btn.Parent = FloatingGui  
btn.Active = true  
btn.Draggable = true  

local corner = Instance.new("UICorner", btn)  
corner.CornerRadius = UDim.new(0,18)  

local stroke = Instance.new("UIStroke", btn)  
stroke.Thickness = 2.5  
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border  
stroke.Color = Color3.fromRGB(0,120,255)  

task.spawn(function()  
    while btn.Parent do  
        TweenService:Create(  
            stroke,  
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),  
            {Color = Color3.fromRGB(0,80,255)}  
        ):Play()  
        task.wait(0.8)  

        TweenService:Create(  
            stroke,  
            TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),  
            {Color = Color3.fromRGB(160,230,255)}  
        ):Play()  
        task.wait(0.8)  
    end  
end)  

btn.MouseButton1Click:Connect(function()  
    lagSwitch(0.5)  
end)

end

local function removeLagFloatingButton()
if floatingLagButton then
floatingLagButton:Destroy()
floatingLagButton = nil
end
end

MainMenu:Toggle({
Title = "Lag Switch (Nút nổi)",
Desc = "Bật/Tắt nút làm lag nhanh trên màn hình",
Default = false,
Callback = function(state)
if state then
createLagFloatingButton()
else
removeLagFloatingButton()
end
end
})


-- =========================
-- HỆ THỐNG TỰ ĐỘNG BẾ/VÁC (AUTO CARRY)
-- =========================
local autoCarry = false
local autoCarryConnection = nil
local floatingCarryButton = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function startAutoCarry()
    if autoCarryConnection then return end

    autoCarryConnection = RunService.Heartbeat:Connect(function()
        if not autoCarry then return end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local otherHRP = plr.Character.HumanoidRootPart
                local dist = (hrp.Position - otherHRP.Position).Magnitude

                if dist <= 20 then
                    pcall(function()
                        ReplicatedStorage:WaitForChild("Events")
                            :WaitForChild("Character")
                            :WaitForChild("Interact")
                            :FireServer("Carry", nil, plr.Name)
                    end)
                    task.wait(0.05)
                end
            end
        end
    end)
end

local function stopAutoCarry()
    if autoCarryConnection then
        autoCarryConnection:Disconnect()
        autoCarryConnection = nil
    end
end

MainMenu:Toggle({
    Title = "Tự động bế/vác",
    Desc = "Tự động vác người chơi khác khi ở gần",
    Default = false,
    Callback = function(state)
        autoCarry = state
        if state then
            startAutoCarry()
        else
            stopAutoCarry()
        end
    end
})

-- Nút nổi của hệ thống tự động vác
local function createCarryButton()
    if floatingCarryButton then
        floatingCarryButton:Destroy()
        floatingCarryButton = nil
    end

    local btn = Instance.new("TextButton")
    floatingCarryButton = btn

    btn.Size = UDim2.new(0,140,0,52)
    btn.Position = UDim2.new(0.5,-70,0.55,0)
    btn.AnchorPoint = Vector2.new(0.5,0)
    btn.BackgroundColor3 = Color3.fromRGB(180,220,255)
    btn.BackgroundTransparency = 0.35
    btn.TextColor3 = Color3.fromRGB(0,70,150)
    btn.Text = autoCarry and "Tự Động Vác: BẬT" or "Tự Động Vác: TẮT"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = FloatingGui
    btn.Active = true
    btn.Draggable = true

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,18)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(0,120,255)

    task.spawn(function()
        while btn.Parent do
            TweenService:Create(
                stroke,
                TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Color = Color3.fromRGB(0,80,255)}
            ):Play()
            task.wait(0.8)

            TweenService:Create(
                stroke,
                TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Color = Color3.fromRGB(160,230,255)}
            ):Play()
            task.wait(0.8)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        autoCarry = not autoCarry

        if autoCarry then
            startAutoCarry()
        else
            stopAutoCarry()
        end

        btn.Text = autoCarry and "Tự Động Vác: BẬT" or "Tự Động Vác: TẮT"
    end)
end

local function removeCarryButton()
    if floatingCarryButton then
        floatingCarryButton:Destroy()
        floatingCarryButton = nil
    end
end

MainMenu:Toggle({
    Title = "Tự động bế/vác (Nút nổi)",
    Desc = "Hiển thị nút vác nhanh trên màn hình",
    Default = false,
    Callback = function(state)
        if state then
            createCarryButton()
        else
            removeCarryButton()
            autoCarry = false
            stopAutoCarry()
        end
    end
})

-- =========================
-- CÀI ĐẶT THÔNG SỐ NHÂN VẬT
-- =========================
local currentSettings = {
    Speed = 1500,
    JumpCap = 1,
    AirStrafeAcceleration = 187
}

getgenv().ApplyMode = "Chưa tối ưu"
getgenv().AutoApplySettings = true

-- Giới hạn tối đa để tránh lỗi game
local MAX_VALUE = 30000

local function safe(val)
    val = tonumber(val) or 0
    if val > MAX_VALUE then return MAX_VALUE end
    if val < 0 then return 0 end
    return val
end

-- Bộ kiểm tra bảng mục tiêu
local requiredFields = {
    Friction=true, AirStrafeAcceleration=true, JumpHeight=true, RunDeaccel=true,
    JumpSpeedMultiplier=true, JumpCap=true, SprintCap=true, WalkSpeedMultiplier=true,
    BhopEnabled=true, Speed=true, AirAcceleration=true, RunAccel=true, SprintAcceleration=true
}

local cachedTables
local lastScan = 0
local SCAN_COOLDOWN = 5

local function getMatchingTables()
    local now = tick()

    if cachedTables and (now - lastScan < SCAN_COOLDOWN) then
        return cachedTables
    end

    local result = {}

    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true

            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then
                    ok = false
                    break
                end
            end

            if ok then
                table.insert(result, obj)
            end
        end
    end

    cachedTables = result
    lastScan = now

    return result
end

-- Áp dụng thông số chỉnh sửa
local function applyToTables()
    local mode = getgenv().ApplyMode
    local tables = getMatchingTables()

    for _, tbl in ipairs(tables) do
        if typeof(tbl) == "table" then
            pcall(function()

                if mode == "Chưa tối ưu" then
                    tbl.Speed = currentSettings.Speed
                    tbl.JumpCap = currentSettings.JumpCap
                    tbl.AirStrafeAcceleration = currentSettings.AirStrafeAcceleration
                else
                    if tbl.Speed ~= currentSettings.Speed then
                        tbl.Speed = currentSettings.Speed
                    end
                    if tbl.JumpCap ~= currentSettings.JumpCap then
                        tbl.JumpCap = currentSettings.JumpCap
                    end
                    if tbl.AirStrafeAcceleration ~= currentSettings.AirStrafeAcceleration then
                        tbl.AirStrafeAcceleration = currentSettings.AirStrafeAcceleration
                    end
                end

            end)
        end
    end
end

-- Tự động làm mới dữ liệu liên tục tránh bị mất chỉ số
RunService.Heartbeat:Connect(function()
    if getgenv().AutoApplySettings then
        applyToTables()
    end
end)

-- =========================
-- CÁC THANH TRƯỢT TRONG TAB CÀI ĐẶT
-- =========================

SettingsTab:Slider({
    Title = "Tốc độ di chuyển (Speed)",
    Value = {
        Min = 1450,
        Max = 30000,
        Default = currentSettings.Speed
    },
    Callback = function(val)
        currentSettings.Speed = safe(val)
        applyToTables()
    end
})

SettingsTab:Slider({
    Title = "Giới hạn nhảy (Jump Cap)",
    Value = {
        Min = 0.1,
        Max = 30000,
        Default = currentSettings.JumpCap
    },
    Callback = function(val)
        currentSettings.JumpCap = safe(val)
        applyToTables()
    end
})

SettingsTab:Slider({
    Title = "Gia tốc trên không (Strafe)",
    Value = {
        Min = 200,
        Max = 30000,
        Default = currentSettings.AirStrafeAcceleration
    },
    Callback = function(val)
        currentSettings.AirStrafeAcceleration = safe(val)
        applyToTables()
    end
})

-- Lựa chọn phương thức áp dụng cấu hình
SettingsTab:Dropdown({
    Title = "Phương thức áp dụng",
    Values = {"Chưa tối ưu", "Đã tối ưu"},
    Default = "Chưa tối ưu",
    Callback = function(option)
        getgenv().ApplyMode = option
        cachedTables = nil
        applyToTables()
    end
})

-- Sửa lỗi khi hồi sinh nhân vật
player.CharacterAdded:Connect(function()
    task.wait(1)
    cachedTables = nil
    applyToTables()
end)


-- =========================
-- HỆ THỐNG TỰ HỒI SINH GIẢ (FAKE REVIVE SYSTEM)
-- =========================
getgenv().AutoRespawnEnabled = false
local autoRespawnMethod = "Hồi Sinh Giả"

local lastSavedPosition = nil
local running = false

-- Vòng lặp liên tục theo dõi vị trí cũ của nhân vật
local function trackPosition(char)
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)

        while char and char.Parent do
            if hrp then
                lastSavedPosition = hrp.Position
            end
            task.wait(0.25)
        end
    end)
end

-- Core chính xử lý hồi sinh giả lập vị trí
local function fakeRevive()
    if running then return end
    running = true

    task.spawn(function()
        while getgenv().AutoRespawnEnabled do
            local char = player.Character
            if not char then
                task.wait(1)
                continue
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            local isDead = hum and hum.Health <= 0

            if isDead then
                task.wait(2)

                -- Gửi yêu cầu hồi sinh lên máy chủ
                pcall(function()
                    local ev = ReplicatedStorage:FindFirstChild("Events")
                    if ev then
                        local playerFolder = ev:FindFirstChild("Player")
                        local change = playerFolder and playerFolder:FindFirstChild("ChangePlayerMode")
                        if change then
                            change:FireServer(true)
                        end
                    end
                end)

                -- Chờ nhân vật mới tải xong
                local newChar
                repeat
                    newChar = player.Character
                    task.wait()
                until newChar and newChar:FindFirstChild("HumanoidRootPart")

                -- Đưa nhân vật quay trở lại vị trí trước khi chết
                if lastSavedPosition then
                    newChar.HumanoidRootPart.CFrame = CFrame.new(lastSavedPosition + Vector3.new(0,3,0))
                end
            end

            task.wait(1)
        end

        running = false
    end)
end

if player.Character then
    trackPosition(player.Character)
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    trackPosition(char)
end)

MainMenu:Toggle({
    Title = "Tự động hồi sinh",
    Desc = "Hệ thống lưu vị trí cũ + tự động gửi yêu cầu hồi sinh khi chết",
    Default = false,
    Callback = function(state)
        getgenv().AutoRespawnEnabled = state

        if state then
            fakeRevive()
        end
    end
})

MainMenu:Dropdown({
    Title = "Chế độ hồi sinh",
    Desc = "Lựa chọn cách thức hồi sinh",
    Options = {"Hồi Sinh Giả", "Ngẫu Nhiên"},
    Default = "Hồi Sinh Giả",
    Callback = function(opt)
        autoRespawnMethod = opt
    end
})

-- =========================
-- HỆ THỐNG XOAY VÒNG (SPIN SYSTEM)
-- =========================
local spinEnabled = false
local spinConnection = nil

local function stopSpin()
    spinEnabled = false

    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end

    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end
end

local function startSpin()
    if spinConnection then return end

    spinConnection = RunService.Heartbeat:Connect(function()
        if not spinEnabled then return end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Xoay nhân vật quanh trục Y với tốc độ góc là 100
        hrp.AssemblyAngularVelocity = Vector3.new(0, 100, 0)
    end)
end

MainMenu:Toggle({
    Title = "Xoay nhân vật (Spin)",
    Desc = "Xoay tròn nhân vật liên tục bằng lực góc",
    Default = false,
    Callback = function(state)
        spinEnabled = state

        if state then
            startSpin()
        else
            stopSpin()
        end
    end
})

-- =========================
-- BOT TRỐN THÔNG MINH (WARP BOT SMART ESCAPE)
-- =========================
local warpBotActive = false
local warpBotConnection = nil
local Workspace = game:GetService("Workspace")

local savedCFrame = nil
local isEscaping = false

local function startWarpBot()
	if warpBotConnection then return end

	warpBotConnection = RunService.Heartbeat:Connect(function()
		if not warpBotActive then return end

		local char = player.Character
		if not char then return end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local folder = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
		if not folder then return end

		local nearBot = false

		for _, npc in ipairs(folder:GetChildren()) do
			if npc:GetAttribute("Team") == "Nextbot" then
				local npcPart = npc:FindFirstChild("Root") or npc:FindFirstChild("HumanoidRootPart")
				if npcPart and (npcPart.Position - root.Position).Magnitude <= 10 then
					nearBot = true
					break
				end
			end
		end

		-- Phát hiện Bot ở gần -> Bay lên trời trốn
		if nearBot and not isEscaping then
			savedCFrame = root.CFrame
			isEscaping = true

			root.CFrame = root.CFrame + Vector3.new(0, 120, 0)
		end

		-- Khi đang ở trên không -> Khóa cứng vị trí
		if isEscaping then
			root.AssemblyLinearVelocity = Vector3.new(0,0,0)

			local stillDanger = false

			for _, npc in ipairs(folder:GetChildren()) do
				if npc:GetAttribute("Team") == "Nextbot" then
					local npcPart = npc:FindFirstChild("Root") or npc:FindFirstChild("HumanoidRootPart")
					if npcPart and savedCFrame then
						if (npcPart.Position - savedCFrame.Position).Magnitude <= 12 then
							stillDanger = true
							break
						end
					end
				end
			end

			-- Nếu hết nguy hiểm -> Quay trở lại mặt đất
			if not stillDanger then
				isEscaping = false
				if savedCFrame then
					root.CFrame = savedCFrame
					savedCFrame = nil
				end
			end
		end
	end)
end

local function stopWarpBot()
	if warpBotConnection then
		warpBotConnection:Disconnect()
		warpBotConnection = nil
	end
	isEscaping = false
	savedCFrame = nil
end

MainMenu:Toggle({
	Title = "Né tránh Nextbot thông minh",
	Desc = "Tự động dịch chuyển lên không trung để trốn khi có Bot lại gần dưới 10m",
	Default = false,
	Callback = function(state)
		warpBotActive = state
		if state then
			startWarpBot()
		else
			stopWarpBot()
		end
	end
})
