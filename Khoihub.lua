local Players, RunService, CoreGui = game:GetService("Players"), game:GetService("RunService"), game:GetService("CoreGui")
local ProximityPromptService, Lighting, UserInputService = game:GetService("ProximityPromptService"), game:GetService("Lighting"), game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local parentGui
local success, _ = pcall(function() return CoreGui.Name end)
if success then
	parentGui = (gethui and gethui()) or CoreGui
else
	parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

if parentGui:FindFirstChild("ESPMenuGui") then parentGui.ESPMenuGui:Destroy() end

local HIGHLIGHT_COLOR, TEXT_COLOR = Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255)
local FRUIT_COLOR = Color3.fromRGB(0, 255, 127)
local espEnabled, instantPromptEnabled, fixLagEnabled, infiniteJumpEnabled, noclipEnabled, speedEnabled, fruitEspEnabled = false, false, false, false, false, false, false
local customSpeed, trackedPlayers, trackedFruits, originalHoldDurations, originalLightingSettings, removedEffects, originalMaterialState = 16, {}, {}, {}, {}, {}, {}
local promptConnection, renderConnection, noclipConnection, timeConnection, fruitConnection

local startTime = os.time()

local function formatTime(seconds)
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner", parent)
	corner.CornerRadius = UDim.new(0, radius or 6)
	return corner
end

local toggleIconButton = Instance.new("ImageButton", screenGui)
toggleIconButton.Name = "ToggleIconButton"
toggleIconButton.Size = UDim2.new(0, 55, 0, 55)
toggleIconButton.Position = UDim2.new(0, 20, 0, 20)
toggleIconButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggleIconButton.Active, toggleIconButton.Draggable = true, true
toggleIconButton.Image = "rbxassetid://6835268482"
toggleIconButton.ScaleType = Enum.ScaleType.Crop
createCorner(toggleIconButton, 28)

local uiStroke = Instance.new("UIStroke", toggleIconButton)
uiStroke.Color = Color3.fromRGB(255, 215, 0)
uiStroke.Thickness = 2.5

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size, mainFrame.Position = UDim2.new(0, 315, 0, 320), UDim2.new(0, 85, 0, 20)
mainFrame.BackgroundColor3, mainFrame.Active, mainFrame.Draggable, mainFrame.ClipsDescendants = Color3.fromRGB(25, 25, 25), true, true, true
createCorner(mainFrame, 8)

local bloxFruitFrame = Instance.new("Frame", screenGui)
bloxFruitFrame.Size, bloxFruitFrame.Position = UDim2.new(0, 200, 0, 150), UDim2.new(0, 410, 0, 20)
bloxFruitFrame.BackgroundColor3, bloxFruitFrame.Active, bloxFruitFrame.Draggable, bloxFruitFrame.ClipsDescendants = Color3.fromRGB(25, 25, 25), true, true, true
bloxFruitFrame.Visible = false
createCorner(bloxFruitFrame, 8)

local bfTitle = Instance.new("TextLabel", bloxFruitFrame)
bfTitle.Size, bfTitle.Position, bfTitle.BackgroundTransparency = UDim2.new(1, -30, 0, 30), UDim2.new(0, 10, 0, 5), 1
bfTitle.TextColor3, bfTitle.TextSize, bfTitle.Font, bfTitle.Text = Color3.fromRGB(255, 215, 0), 14, Enum.Font.SourceSansBold, "BLOX FRUIT MENU"

local bfCloseButton = Instance.new("TextButton", bloxFruitFrame)
bfCloseButton.Size, bfCloseButton.Position = UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0, 5)
bfCloseButton.BackgroundColor3, bfCloseButton.TextColor3, bfCloseButton.TextSize, bfCloseButton.Font, bfCloseButton.Text = Color3.fromRGB(200, 50, 50), TEXT_COLOR, 12, Enum.Font.SourceSansBold, "X"
createCorner(bfCloseButton, 4)

bfCloseButton.MouseButton1Click:Connect(function() bloxFruitFrame.Visible = false end)

local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size, closeButton.Position = UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3, closeButton.TextColor3, closeButton.TextSize, closeButton.Font, closeButton.Text = Color3.fromRGB(200, 50, 50), TEXT_COLOR, 12, Enum.Font.SourceSansBold, "X"
createCorner(closeButton, 4)

local separator = Instance.new("Frame", mainFrame)
separator.Size, separator.Position, separator.BackgroundColor3, separator.BorderSizePixel = UDim2.new(0, 2, 0, 250), UDim2.new(0, 156, 0, 10), Color3.fromRGB(50, 50, 50), 0

local function makeBtn(parent, name, text, pos, size)
	local btn = Instance.new("TextButton", parent)
	btn.Name, btn.Size, btn.Position = name, size or UDim2.new(0, 140, 0, 32), pos
	btn.BackgroundColor3, btn.TextColor3, btn.TextSize, btn.Font, btn.Text = Color3.fromRGB(40, 40, 40), TEXT_COLOR, 14, Enum.Font.SourceSansBold, text
	createCorner(btn, 6)
	return btn
end

local function setBtnState(btn, state, label)
	btn.Text = label .. ": " .. (state and "ON" or "OFF")
	btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
end

local espButton = makeBtn(mainFrame, "ESPButton", "ESP: OFF", UDim2.new(0, 10, 0, 30))
local promptButton = makeBtn(mainFrame, "PromptButton", "Instant Prompt: OFF", UDim2.new(0, 10, 0, 68))
local lagButton = makeBtn(mainFrame, "LagButton", "Fix Lag: OFF", UDim2.new(0, 10, 0, 106))
local infJumpButton = makeBtn(mainFrame, "InfJumpButton", "Inf Jump: OFF", UDim2.new(0, 10, 0, 144))
local noclipButton = makeBtn(mainFrame, "NoclipButton", "Noclip: OFF", UDim2.new(0, 10, 0, 182))

local bloxFruitMenuBtn = makeBtn(mainFrame, "BloxFruitMenuBtn", "Blox Fruit Menu", UDim2.new(0, 10, 0, 220))
bloxFruitMenuBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

bloxFruitMenuBtn.MouseButton1Click:Connect(function()
	bloxFruitFrame.Visible = not bloxFruitFrame.Visible
end)

local fruitEspBtn = makeBtn(bloxFruitFrame, "FruitEspBtn", "Fruit ESP: OFF", UDim2.new(0, 15, 0, 50), UDim2.new(0, 170, 0, 35))

local speedTitle = Instance.new("TextLabel", mainFrame)
speedTitle.Size, speedTitle.Position, speedTitle.BackgroundTransparency = UDim2.new(0, 140, 0, 20), UDim2.new(0, 165, 0, 30), 1
speedTitle.TextColor3, speedTitle.TextSize, speedTitle.Font, speedTitle.Text = Color3.fromRGB(200, 200, 200), 13, Enum.Font.SourceSansBold, "SPEED CONTROL"

local speedButton = makeBtn(mainFrame, "SpeedButton", "Speed: OFF", UDim2.new(0, 165, 0, 55))
local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size, speedInput.Position = UDim2.new(0, 140, 0, 32), UDim2.new(0, 165, 0, 93)
speedInput.BackgroundColor3, speedInput.TextColor3, speedInput.TextSize, speedInput.Font = Color3.fromRGB(35, 35, 35), TEXT_COLOR, 14, Enum.Font.SourceSansBold
speedInput.PlaceholderText, speedInput.Text = "Set Speed (e.g. 50)", ""
createCorner(speedInput, 6)

local timeFrame = Instance.new("Frame", mainFrame)
timeFrame.Size, timeFrame.Position = UDim2.new(1, -20, 0, 42), UDim2.new(0, 10, 0, 265)
timeFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
createCorner(timeFrame, 6)

local timeHeader = Instance.new("TextLabel", timeFrame)
timeHeader.Size, timeHeader.Position, timeHeader.BackgroundTransparency = UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 0, 2), 1
timeHeader.TextColor3, timeHeader.TextSize, timeHeader.Font, timeHeader.Text = Color3.fromRGB(255, 215, 0), 12, Enum.Font.SourceSansBold, "SERVER TIME"

local userTimeLabel = Instance.new("TextLabel", timeFrame)
userTimeLabel.Size, userTimeLabel.Position, userTimeLabel.BackgroundTransparency = UDim2.new(1, -10, 0, 18), UDim2.new(0, 10, 0, 20), 1
userTimeLabel.TextColor3, userTimeLabel.TextSize, userTimeLabel.Font, userTimeLabel.TextXAlignment = Color3.fromRGB(0, 230, 255), 11, Enum.Font.SourceSansBold, Enum.TextXAlignment.Left
userTimeLabel.Text = "You Joined: 00:00:00"

local lastTimeCheck = 0
timeConnection = RunService.Heartbeat:Connect(function()
	if os.clock() - lastTimeCheck >= 1 then
		lastTimeCheck = os.clock()
		local userSeconds = os.time() - startTime
		userTimeLabel.Text = "You Joined: " .. formatTime(userSeconds)
	end
end)

toggleIconButton.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

local function removeESP(player)
	if trackedPlayers[player] then
		if trackedPlayers[player].Highlight then trackedPlayers[player].Highlight:Destroy() end
		if trackedPlayers[player].Billboard then trackedPlayers[player].Billboard:Destroy() end
		trackedPlayers[player] = nil
	end
end

local function createESP(player)
	if player == LocalPlayer then return end
	local function onCharacterAdded(char)
		removeESP(player)
		if not espEnabled then return end
		local hrp, head = char:WaitForChild("HumanoidRootPart", 5), char:WaitForChild("Head", 5)
		if not hrp or not head then return end

		local hl = Instance.new("Highlight", char)
		hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.DepthMode = HIGHLIGHT_COLOR, TEXT_COLOR, 0.5, Enum.HighlightDepthMode.AlwaysOnTop

		local gui = Instance.new("BillboardGui", char)
		gui.Adornee, gui.Size, gui.StudsOffset, gui.AlwaysOnTop = head, UDim2.new(0, 150, 0, 40), Vector3.new(0, 2.5, 0), true

		local lbl = Instance.new("TextLabel", gui)
		lbl.Size, lbl.BackgroundTransparency, lbl.TextColor3, lbl.TextStrokeTransparency, lbl.TextSize, lbl.Font = UDim2.new(1, 0, 1, 0), 1, TEXT_COLOR, 0, 14, Enum.Font.SourceSansBold

		trackedPlayers[player] = {Highlight = hl, Billboard = gui, TextLabel = lbl, HRP = hrp, Character = char}
	end
	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

espButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	setBtnState(espButton, espEnabled, "ESP")
	for _, p in ipairs(Players:GetPlayers()) do
		if espEnabled then createESP(p) else removeESP(p) end
	end
end)

local function removeFruitESP(obj)
	if trackedFruits[obj] then
		if trackedFruits[obj].Highlight then trackedFruits[obj].Highlight:Destroy() end
		if trackedFruits[obj].Billboard then trackedFruits[obj].Billboard:Destroy() end
		trackedFruits[obj] = nil
	end
end

local function createFruitESP(obj)
	if not fruitEspEnabled then return end
	if obj:IsA("Tool") or obj:IsA("Model") then
		if string.find(string.lower(obj.Name), "fruit") then
			local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
			if handle then
				removeFruitESP(obj)

				local hl = Instance.new("Highlight", obj)
				hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.DepthMode = FRUIT_COLOR, TEXT_COLOR, 0.4, Enum.HighlightDepthMode.AlwaysOnTop

				local gui = Instance.new("BillboardGui", obj)
				gui.Adornee, gui.Size, gui.StudsOffset, gui.AlwaysOnTop = handle, UDim2.new(0, 150, 0, 40), Vector3.new(0, 2, 0), true

				local lbl = Instance.new("TextLabel", gui)
				lbl.Size, lbl.BackgroundTransparency, lbl.TextColor3, lbl.TextStrokeTransparency, lbl.TextSize, lbl.Font = UDim2.new(1, 0, 1, 0), 1, FRUIT_COLOR, 0, 14, Enum.Font.SourceSansBold
				lbl.Text = obj.Name

				trackedFruits[obj] = {Highlight = hl, Billboard = gui, TextLabel = lbl, Handle = handle}
			end
		end
	end
end

local function updateFruitESP()
	if fruitEspEnabled then
		for _, v in ipairs(workspace:GetDescendants()) do
			createFruitESP(v)
		end
		fruitConnection = workspace.DescendantAdded:Connect(function(v)
			task.wait(0.1)
			createFruitESP(v)
		end)
	else
		if fruitConnection then fruitConnection:Disconnect() fruitConnection = nil end
		for obj, _ in pairs(trackedFruits) do
			removeFruitESP(obj)
		end
		table.clear(trackedFruits)
	end
end

fruitEspBtn.MouseButton1Click:Connect(function()
	fruitEspEnabled = not fruitEspEnabled
	setBtnState(fruitEspBtn, fruitEspEnabled, "Fruit ESP")
	updateFruitESP()
end)

promptButton.MouseButton1Click:Connect(function()
	instantPromptEnabled = not instantPromptEnabled
	setBtnState(promptButton, instantPromptEnabled, "Instant Prompt")
	if instantPromptEnabled then
		promptConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
			if not originalHoldDurations[prompt] then originalHoldDurations[prompt] = prompt.HoldDuration end
			prompt.HoldDuration = 0
		end)
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") then
				if not originalHoldDurations[obj] then originalHoldDurations[obj] = obj.HoldDuration end
				obj.HoldDuration = 0
			end
		end
	else
		if promptConnection then promptConnection:Disconnect() promptConnection = nil end
		for prompt, dur in pairs(originalHoldDurations) do
			if prompt and prompt.Parent then prompt.HoldDuration = dur end
		end
		table.clear(originalHoldDurations)
	end
end)

lagButton.MouseButton1Click:Connect(function()
	fixLagEnabled = not fixLagEnabled
	setBtnState(lagButton, fixLagEnabled, "Fix Lag")
	if fixLagEnabled then
		originalLightingSettings = {GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd}
		Lighting.GlobalShadows, Lighting.FogEnd = false, 9e9

		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") then
				table.insert(removedEffects, {effect = effect, parent = effect.Parent})
				effect.Parent = nil
			end
		end
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v:IsA("Terrain") then
				originalMaterialState[v] = {Material = v.Material, Reflectance = v.Reflectance, CastShadow = v.CastShadow}
				v.Material, v.Reflectance, v.CastShadow = Enum.Material.SmoothPlastic, 0, false
			elseif v:IsA("Decal") or v:IsA("Texture") then
				originalMaterialState[v] = {Transparency = v.Transparency}
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
				originalMaterialState[v] = {Enabled = v.Enabled}
				v.Enabled = false
			end
		end
	else
		if originalLightingSettings.GlobalShadows ~= nil then
			Lighting.GlobalShadows, Lighting.FogEnd = originalLightingSettings.GlobalShadows, originalLightingSettings.FogEnd
		end
		for _, item in ipairs(removedEffects) do if item.effect then item.effect.Parent = item.parent end end
		table.clear(removedEffects)
		for obj, state in pairs(originalMaterialState) do
			if obj and obj.Parent then
				if obj:IsA("BasePart") then
					obj.Material, obj.Reflectance, obj.CastShadow = state.Material, state.Reflectance, state.CastShadow
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = state.Transparency
				else
					obj.Enabled = state.Enabled
				end
			end
		end
		table.clear(originalMaterialState)
	end
end)

infJumpButton.MouseButton1Click:Connect(function()
	infiniteJumpEnabled = not infiniteJumpEnabled
	setBtnState(infJumpButton, infiniteJumpEnabled, "Inf Jump")
end)

noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	setBtnState(noclipButton, noclipEnabled, "Noclip")
end)

speedButton.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	setBtnState(speedButton, speedEnabled, "Speed")
	if not speedEnabled and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
end)

speedInput.FocusLost:Connect(function()
	customSpeed = tonumber(speedInput.Text) or customSpeed
	speedInput.Text = tostring(customSpeed)
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

noclipConnection = RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
		end
	end
	if speedEnabled and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed ~= customSpeed then hum.WalkSpeed = customSpeed end
	end
end)

local lastUpdate = 0
renderConnection = RunService.RenderStepped:Connect(function()
	if os.clock() - lastUpdate < 0.05 then return end
	lastUpdate = os.clock()

	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position

	if espEnabled then
		for player, data in pairs(trackedPlayers) do
			if data.Character and data.Character:IsDescendantOf(workspace) and data.HRP then
				local dist = math.floor((data.HRP.Position - myPos).Magnitude)
				data.TextLabel.Text = string.format("%s\n[%d studs]", player.DisplayName, dist)
			else
				removeESP(player)
			end
		end
	end

	if fruitEspEnabled then
		for obj, data in pairs(trackedFruits) do
			if obj and obj:IsDescendantOf(workspace) and data.Handle then
				local dist = math.floor((data.Handle.Position - myPos).Magnitude)
				data.TextLabel.Text = string.format("%s\n[%d studs]", obj.Name, dist)
			else
				removeFruitESP(obj)
			end
		end
	end
end)

local function cleanupAll()
	if timeConnection then timeConnection:Disconnect() timeConnection = nil end
	if renderConnection then renderConnection:Disconnect() renderConnection = nil end
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if promptConnection then promptConnection:Disconnect() promptConnection = nil end
	if fruitConnection then fruitConnection:Disconnect() fruitConnection = nil end
end

closeButton.MouseButton1Click:Connect(function()
	if espEnabled then espButton.MouseButton1Click:Fire() end
	if fruitEspEnabled then fruitEspBtn.MouseButton1Click:Fire() end
	if instantPromptEnabled then promptButton.MouseButton1Click:Fire() end
	if fixLagEnabled then lagButton.MouseButton1Click:Fire() end
	if speedEnabled then speedButton.MouseButton1Click:Fire() end
	cleanupAll()
	screenGui:Destroy()
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() if espEnabled then task.wait(0.5) createESP(p) end end)
end)

Players.PlayerRemoving:Connect(function(p)
	if p == LocalPlayer then
		cleanupAll()
	else
		removeESP(p)
	end
end)

if LocalPlayer.OnTeleport then
	LocalPlayer.OnTeleport:Connect(function()
		cleanupAll()
	end)
end
