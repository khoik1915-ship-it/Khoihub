local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "TIEN HUB V5",
   LoadingTitle = "Dang Tai",
   LoadingSubtitle = "Cho ti",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- BIEN LUU 20 VI TRI
local Vitri = {}

-- TAB 1: TELEPORT
local TPTab = Window:CreateTab("TELEPORT 20 DIEM", 4483362458)

for i = 1,20 do
    TPTab:CreateButton({
        Name = "Luu Vi Tri "..i,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Vitri[i] = hrp.CFrame
                Rayfield:Notify({Title="Da Luu", Content="Vi tri "..i, Duration=2})
            end
        end
    })
    TPTab:CreateButton({
        Name = "Tele "..i,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if Vitri[i] and hrp then
                hrp.CFrame = Vitri[i]
                Rayfield:Notify({Title="Da Tele", Content="Den vi tri "..i, Duration=2})
            end
        end
    })
end

-- TAB 2: CAI DAT
local SettingTab = Window:CreateTab("CAI DAT", 4483362458)
SettingTab:CreateKeybind({Name = "Phim An Menu", CurrentKeybind = "K"})
SettingTab:CreateButton({Name = "TAT SCRIPT", Callback = function() Rayfield:Destroy() end})
