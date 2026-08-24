local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")
local TitleLabel = Instance.new("TextLabel")

local PromptButton = Instance.new("TextButton")
local NPCButton = Instance.new("TextButton")
local ToolButton = Instance.new("TextButton")

ScreenGui.Name = "MultiESPHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 210)
MainFrame.Active = true
MainFrame.Draggable = true

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "ESP Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

PromptButton.Parent = MainFrame
PromptButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PromptButton.Position = UDim2.new(0.1, 0, 0, 45)
PromptButton.Size = UDim2.new(0, 144, 0, 40)
PromptButton.Font = Enum.Font.SourceSansBold
PromptButton.Text = "Prompt ESP: OFF"
PromptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptButton.TextSize = 14

NPCButton.Parent = MainFrame
NPCButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NPCButton.Position = UDim2.new(0.1, 0, 0, 95)
NPCButton.Size = UDim2.new(0, 144, 0, 40)
NPCButton.Font = Enum.Font.SourceSansBold
NPCButton.Text = "NPC ESP: OFF"
NPCButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NPCButton.TextSize = 14

ToolButton.Parent = MainFrame
ToolButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToolButton.Position = UDim2.new(0.1, 0, 0, 145)
ToolButton.Size = UDim2.new(0, 144, 0, 40)
ToolButton.Font = Enum.Font.SourceSansBold
ToolButton.Text = "Tool ESP: OFF"
ToolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToolButton.TextSize = 14

local promptEnabled = false
local npcEnabled = false
local toolEnabled = false

local trackedPrompts = {}
local trackedNPCs = {}
local trackedTools = {}

local function createPromptESP(prompt)
    if not prompt:FindFirstChild("PromptBillboard") and prompt:IsA("ProximityPrompt") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PromptBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = prompt.Parent

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 13
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Text = "[" .. prompt.ActionText .. "] " .. prompt.ObjectText
        textLabel.Parent = billboard

        billboard.Parent = prompt.Parent
        table.insert(trackedPrompts, billboard)
    end
end

local function createNPCESP(char)
    if not char:FindFirstChild("NPCHighlight") and char:FindFirstChild("Humanoid") then
        local isPlayer = false
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Character == char then
                isPlayer = true
                break
            end
        end
        
        if not isPlayer then
            local highlight = Instance.new("Highlight")
            highlight.Name = "NPCHighlight"
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 128, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            table.insert(trackedNPCs, highlight)
        end
    end
end

local function createToolESP(tool)
    if not tool:FindFirstChild("ToolHighlight") and tool:IsA("Tool") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ToolHighlight"
        highlight.Adornee = tool
        highlight.FillColor = Color3.fromRGB(0, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Parent = tool
        table.insert(trackedTools, highlight)
    end
end

PromptButton.MouseButton1Click:Connect(function()
    promptEnabled = not promptEnabled
    if promptEnabled then
        PromptButton.Text = "Prompt ESP: ON"
        PromptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                createPromptESP(obj)
            end
        end
    else
        PromptButton.Text = "Prompt ESP: OFF"
        PromptButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, b in ipairs(trackedPrompts) do
            if b then b:Destroy() end
        end
        trackedPrompts = {}
    end
end)

NPCButton.MouseButton1Click:Connect(function()
    npcEnabled = not npcEnabled
    if npcEnabled then
        NPCButton.Text = "NPC ESP: ON"
        NPCButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                createNPCESP(obj)
            end
        end
    else
        NPCButton.Text = "NPC ESP: OFF"
        NPCButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, h in ipairs(trackedNPCs) do
            if h then h:Destroy() end
        end
        trackedNPCs = {}
    end
end)

ToolButton.MouseButton1Click:Connect(function()
    toolEnabled = not toolEnabled
    if toolEnabled then
        ToolButton.Text = "Tool ESP: ON"
        ToolButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                createToolESP(obj)
            end
        end
    else
        ToolButton.Text = "Tool ESP: OFF"
        ToolButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, h in ipairs(trackedTools) do
            if h then h:Destroy() end
        end
        trackedTools = {}
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if promptEnabled and obj:IsA("ProximityPrompt") then
        createPromptESP(obj)
    elseif npcEnabled and obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
        task.wait(1)
        createNPCESP(obj)
    elseif toolEnabled and obj:IsA("Tool") then
        createToolESP(obj)
    end
end)
