local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- 1. ล้างของเก่าทิ้งให้สะอาด
if getgenv().ZpConnection then
    pcall(function() getgenv().ZpConnection:Disconnect() end)
    getgenv().ZpConnection = nil
end

pcall(function()
    if playerGui:FindFirstChild("ZpProjectUI") then playerGui.ZpProjectUI:Destroy() end
    if playerGui:FindFirstChild("DoorTopTrackerUI") then playerGui.DoorTopTrackerUI:Destroy() end
end)

-- 2. ระบบ Save / Load Config
local configFileName = "ZpProject_Config.json"
local defaultToggles = {
    AutoFlyFarm = false,
    FastPrompt = false,
    ESP = false
}

local function saveConfig()
    pcall(function()
        if writefile and HttpService then
            local jsonStr = HttpService:JSONEncode(getgenv().ZpToggles)
            writefile(configFileName, jsonStr)
        end
    end)
end

local function loadConfig()
    local success, result = pcall(function()
        if readfile and isfile and isfile(configFileName) then
            local jsonStr = readfile(configFileName)
            return HttpService:JSONDecode(jsonStr)
        end
    end)
    if success and type(result) == "table" then
        return result
    else
        return defaultToggles
    end
end

getgenv().ZpToggles = loadConfig()

-- 3. UI ด้านบนบอกสถานะประตูและสถานะการบิน
local topGui = Instance.new("ScreenGui", playerGui)
topGui.Name = "DoorTopTrackerUI"
topGui.ResetOnSpawn = false

local topLabel = Instance.new("TextLabel", topGui)
topLabel.Size = UDim2.new(0, 300, 0, 38)
topLabel.Position = UDim2.new(0.5, -150, 0, 15)
topLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
topLabel.BackgroundTransparency = 0.25
topLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
topLabel.TextSize = 12
topLabel.Font = Enum.Font.GothamBold
topLabel.Text = "State: Idle | Doors: 0"

Instance.new("UICorner", topLabel).CornerRadius = UDim.new(0, 10)
local stroke1 = Instance.new("UIStroke", topLabel)
stroke1.Color = Color3.fromRGB(255, 105, 180)
stroke1.Thickness = 1.5

-- 4. UI เมนูหลัก zp project (beta)
local mainGui = Instance.new("ScreenGui", playerGui)
mainGui.Name = "ZpProjectUI"
mainGui.ResetOnSpawn = false

local frame = Instance.new("Frame", mainGui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.5, -110, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.ClipsDescendants = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke2 = Instance.new("UIStroke", frame)
stroke2.Color = Color3.fromRGB(255, 105, 180)
stroke2.Thickness = 1.5

-- หัวข้อ
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "zp project (beta)"
title.TextColor3 = Color3.fromRGB(255, 105, 180)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มย่อ (-)
local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 3)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold

-- ตัวอักษร Z ตอนย่อ
local miniZ = Instance.new("TextLabel", frame)
miniZ.Size = UDim2.new(1, 0, 1, 0)
miniZ.BackgroundTransparency = 1
miniZ.Text = "Z"
miniZ.TextColor3 = Color3.fromRGB(255, 105, 180)
miniZ.TextSize = 22
miniZ.Font = Enum.Font.GothamBold
miniZ.Visible = false

-- ฟังก์ชันสร้างปุ่ม Toggle
local function createButton(name, key, yPos)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function updateVisual()
        local state = getgenv().ZpToggles[key]
        if state then
            btn.Text = "  " .. name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 105, 180)
        else
            btn.Text = "  " .. name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end

    updateVisual()

    btn.MouseButton1Click:Connect(function()
        getgenv().ZpToggles[key] = not getgenv().ZpToggles[key]
        updateVisual()
        saveConfig()
    end)
end

-- สร้างปุ่มใช้งาน
createButton("Auto High Fly", "AutoFlyFarm", 45)
createButton("Fast Door Prompt", "FastPrompt", 88)
createButton("ESP & Distance", "ESP", 131)

-- ย่อ/ขยาย
local allToggleButtons = {}
for _, child in ipairs(frame:GetChildren()) do
    if child:IsA("TextButton") and child ~= minBtn then
        table.insert(allToggleButtons, child)
    end
end

minBtn.MouseButton1Click:Connect(function()
    for _, b in ipairs(allToggleButtons) do b.Visible = false end
    title.Visible = false
    minBtn.Visible = false
    miniZ.Visible = true
    frame.Size = UDim2.new(0, 45, 0, 45)
end)

miniZ.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        for _, b in ipairs(allToggleButtons) do b.Visible = true end
        title.Visible = true
        minBtn.Visible = true
        miniZ.Visible = false
        frame.Size = UDim2.new(0, 220, 0, 180)
    end
end)

-- ระบบลากหน้าต่าง
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 5. ระบบสแกนประตู
local cachedDoors = {}
task.spawn(function()
    while task.wait(1) do
        local found = {}
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("halloweendoor") then
                    table.insert(found, obj)
                end
            end
        end)
        cachedDoors = found
    end
end)

-- 6. ลูปหลักจัดการระบบบิน (บินสูง 220 studs, จอดหน้าประตู 5 studs, หน่วงเวลารอเปิด)
local flyHeight = 220
local flightState = "UP"
local actionTimer = 0

getgenv().ZpConnection = RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = localPlayer.Character
        local closestDist = nil
        local closestDoor = nil
        local toggles = getgenv().ZpToggles

        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart

            for _, door in ipairs(cachedDoors) do
                if door and door.Parent then
                    local doorPos = door:IsA("Model") and door:GetPivot().Position or door.Position
                    if doorPos then
                        local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(doorPos.X, 0, doorPos.Z)).Magnitude
                        if not closestDist or dist < closestDist then
                            closestDist = dist
                            closestDoor = door
                        end
                    end
                end
            end
        end

        if toggles.FastPrompt then
            for _, door in ipairs(cachedDoors) do
                if door and door.Parent then
                    for _, desc in ipairs(door:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            desc.HoldDuration = 0.15
                        end
                    end
                end
            end
        end

        for _, door in ipairs(cachedDoors) do
            if door and door.Parent then
                local hl = door:FindFirstChild("ZpHighlight")
                if toggles.ESP then
                    if not hl then
                        hl = Instance.new("Highlight", door)
                        hl.Name = "ZpHighlight"
                        hl.FillColor = Color3.fromRGB(255, 105, 180)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    hl.Enabled = true
                elseif hl then
                    hl.Enabled = false
                end
            end
        end

        -- Update สถานะบนจอ
        local doorCount = #cachedDoors
        if doorCount > 0 then
            local dText = closestDist and (math.floor(closestDist) .. " studs") or "N/A"
            local stateText = toggles.AutoFlyFarm and ("[" .. flightState .. "]") or "[OFF]"
            topLabel.Text = string.format("State: %s | Doors: %d | Dist: %s", stateText, doorCount, dText)
        else
            topLabel.Text = "Status: Scanning Doors... (0)"
        end

        -- ระบบ Auto High Fly
        if toggles.AutoFlyFarm and closestDoor and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local doorCF = closestDoor:IsA("Model") and closestDoor:GetPivot() or CFrame.new(closestDoor.Position)
            local doorPos = doorCF.Position
            
            -- คำนวณจุดยืนหน้าประตู ถอยห่าง 5 studs จากด้านหน้า
            local standoffPos = doorPos - (doorCF.LookVector * 5)
            local targetLandPos = Vector3.new(standoffPos.X, doorPos.Y, standoffPos.Z)

            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            local currentPos = hrp.Position
            local horizontalDist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetLandPos.X, 0, targetLandPos.Z)).Magnitude

            if flightState == "UP" then
                local upTarget = Vector3.new(currentPos.X, doorPos.Y + flyHeight, currentPos.Z)
                if math.abs(currentPos.Y - (doorPos.Y + flyHeight)) > 4 then
                    hrp.CFrame = CFrame.new(currentPos:Lerp(upTarget, 0.25))
                else
                    flightState = "CRUISE"
                end

            elseif flightState == "CRUISE" then
                local cruiseTarget = Vector3.new(targetLandPos.X, doorPos.Y + flyHeight, targetLandPos.Z)
                if horizontalDist > 6 then
                    local nextPos = Vector3.new(currentPos.X, doorPos.Y + flyHeight, currentPos.Z):Lerp(cruiseTarget, 0.2)
                    hrp.CFrame = CFrame.new(nextPos)
                else
                    flightState = "DOWN"
                end

            elseif flightState == "DOWN" then
                local landTarget = Vector3.new(targetLandPos.X, doorPos.Y, targetLandPos.Z)
                if math.abs(currentPos.Y - landTarget.Y) > 4 then
                    hrp.CFrame = CFrame.new(currentPos:Lerp(landTarget, 0.25))
                else
                    hrp.CFrame = CFrame.new(landTarget, doorPos)

                    -- ยืนรอนิ่งๆ 0.3 วิให้จอดสนิทก่อนค่อยเปิด
                    if actionTimer == 0 then
                        actionTimer = tick()
                    elseif (tick() - actionTimer) >= 0.3 then
                        for _, desc in ipairs(closestDoor:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                if fireproximityprompt then
                                    fireproximityprompt(desc)
                                else
                                    desc:InputHoldBegin()
                                    task.wait(0.05)
                                    desc:InputHoldEnd()
                                end
                                break
                            end
                        end
                        actionTimer = 0
                        flightState = "UP"
                    end
                end
            end
        else
            flightState = "UP"
            actionTimer = 0
        end
    end)
end)

print("zp project (beta) [Stable Flight Mode Restored] loaded successfully!")
