local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "TIEN HUB V5",
   LoadingTitle = "Loading",
   LoadingSubtitle = "Please wait",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TienHub",
      ConfigurationName = "20Locations"
   },
   KeySystem = false,
})

local Locations = {}
local LocationNames = {}

local TPTab = Window:CreateTab("TELEPORT 20 POINTS", 4483362458)

for i = 1,20 do
    TPTab:CreateInput({
        Name = "Set Name "..i,
        PlaceholderText = "Home, Shop, Boss...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            if Text == "" then 
                LocationNames[i] = "Position "..i 
            else
                LocationNames[i] = Text
            end
            Rayfield:Notify({Title="Name Set", Content=LocationNames[i], Duration=2})
        end,
    })

    TPTab:CreateButton({
        Name = "Save "..i,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Locations[i] = hrp.CFrame
                local name = LocationNames[i] or "Position "..i
                Rayfield:Notify({Title="Saved", Content=name, Duration=2})
            end
        end
    })

    TPTab:CreateButton({
        Name = "Teleport "..i,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if Locations[i] and hrp then
                hrp.CFrame = Locations[i]
                local name = LocationNames[i] or "Position "..i
                Rayfield:Notify({Title="Teleported", Content="To "..name, Duration=2})
            else
                Rayfield:Notify({Title="Error", Content="Not saved yet", Duration=2})
            end
        end
    })
    
    TPTab:CreateSection("")
end

local SettingTab = Window:CreateTab("SETTINGS", 4483362458)
SettingTab:CreateKeybind({
   Name = "Toggle Menu",
   CurrentKeybind = "K",
})
SettingTab:CreateButton({
   Name = "DESTROY",
   Callback = function()
       Rayfield:Destroy()
   end
})
