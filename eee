
local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local GemESP = {}
local InfiniteStamina = {}
local StreetMessesESP = {}

do
    StreetMessesESP.Enabled = false 
    StreetMessesESP.StreetMessesESPAddedConnection = nil 
    StreetMessesESP.Cache = {}

    function StreetMessesESP:GetStreetMesses()
        return workspace:WaitForChild("Street Messes"):GetChildren()
    end 

    function StreetMessesESP:TagStreetMess(Mess)
        local DrawingText = Drawing.new("Text")
        DrawingText.Center = true
        DrawingText.Outline = true
        DrawingText.Font = 2
        DrawingText.Size = 13
        DrawingText.Color = Color3.fromRGB(0, 255, 0)

        local Con; Con = game:GetService("RunService").RenderStepped:Connect(function()
            if self.Enabled and Mess and Mess.Parent ~= nil and Mess ~= nil and Mess:IsDescendantOf(workspace:WaitForChild("Street Messes")) then
                local ScreenPosition, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Mess.Position)
                if ScreenPosition and OnScreen then
                    DrawingText.Text = "Street Mess"
                    DrawingText.Visible = true 
                    DrawingText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y) 
                else
                    DrawingText.Visible = false 
                end
            else
                DrawingText.Visible = false
                Con:Disconnect()
            end
        end) 
    end

    function StreetMessesESP:Draw()
        if self.Enabled then
            for _, Mess in ipairs(self:GetStreetMesses()) do
                self:TagStreetMess(Mess)
            end  

            self.StreetMessesESPAddedConnection = workspace:WaitForChild("Street Messes").ChildAdded:Connect(function(child)
                self:TagStreetMess(child)
            end)
        else
            if self.StreetMessesESPAddedConnection then
                self.StreetMessesESPAddedConnection:Disconnect()  
            end 

            for _, con in pairs(self.Cache) do
                con:Disconnect()
            end 

            table.clear(self.Cache)
        end 
    end
end

do
    GemESP.Enabled = false 
    GemESP.GemAddedConnection = nil 
    GemESP.Cache = {}

    function GemESP:GetGems()
        local G = {}

        for _, Gem in pairs(workspace:WaitForChild("MachineWorkspace"):WaitForChild("PrisonStuff"):WaitForChild("RockSpawn"):GetChildren()) do
            if Gem:FindFirstChild("Enabled") then
                if Gem:FindFirstChild("Enabled").Value then
                    if Gem.Transparency < 1 then
                        table.insert(G, Gem)
                    end
                end
            end
        end 

        return G 
    end 

    function GemESP:TagGem(Gem)
        local DrawingText = Drawing.new("Text")
        DrawingText.Center = true
        DrawingText.Outline = true
        DrawingText.Font = 2
        DrawingText.Size = 13
        DrawingText.Color = Color3.fromRGB(255, 0, 0)

        local Con; Con = game:GetService("RunService").RenderStepped:Connect(function()
            if self.Enabled and Gem and Gem.Parent ~= nil and Gem ~= nil and Gem:IsDescendantOf(workspace:WaitForChild("MachineWorkspace"):WaitForChild("PrisonStuff"):WaitForChild("RockSpawn")) and Gem:FindFirstChild("Enabled") and Gem:FindFirstChild("Enabled").Value and Gem.Transparency < 1 then
                local ScreenPosition, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Gem.Position)
                if ScreenPosition and OnScreen then
                    DrawingText.Text = "Gem"
                    DrawingText.Visible = true 
                    DrawingText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y) 
                else
                    DrawingText.Visible = false 
                end
            else
                DrawingText.Visible = false
                Con:Disconnect()
            end
        end) 

        table.insert(GemESP.Cache, Gem:GetPropertyChangedSignal("Transparency"):Connect(function()
            if Gem.Transparency < 1 then
                local Con; Con = game:GetService("RunService").RenderStepped:Connect(function()
                    if self.Enabled and Gem and Gem.Parent ~= nil and Gem ~= nil and Gem:IsDescendantOf(workspace:WaitForChild("MachineWorkspace"):WaitForChild("PrisonStuff"):WaitForChild("RockSpawn")) and Gem:FindFirstChild("Enabled") and Gem:FindFirstChild("Enabled").Value and Gem.Transparency < 1 then
                        local ScreenPosition, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Gem.Position)
                        if ScreenPosition and OnScreen then
                            DrawingText.Text = "Gem"
                            DrawingText.Visible = true 
                            DrawingText.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y) 
                        else
                            DrawingText.Visible = false 
                        end
                    else
                        DrawingText.Visible = false
                        Con:Disconnect()
                    end
                end) 
            end
        end))
    end

    function GemESP:Draw()
        if self.Enabled then
            for _, Gem in ipairs(self:GetGems()) do
                self:TagGem(Gem)
            end  

            self.GemAddedConnection = workspace:WaitForChild("MachineWorkspace"):WaitForChild("PrisonStuff"):WaitForChild("RockSpawn").ChildAdded:Connect(function(child)
                self:TagGem(child)
            end)
        else
            if self.GemAddedConnection then
                self.GemAddedConnection:Disconnect()  
            end 

            for _, con in pairs(GemESP.Cache) do
                con:Disconnect()
            end 

            table.clear(GemESP.Cache)
        end 
    end
end

do
    InfiniteStamina.Enabled = false 
 
	--[[
    do
		local old; old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local args = {...}
			
			if InfiniteStamina.Enabled and tostring(self) == "ReplicateStamina" and args[1] == true then 
				return nil 
			end
			
			return old(self, ...)
		end))
	end
	--]]
	
	function InfiniteStamina:Toggled()
		if self.Enabled then
			for i, v in pairs(getgc(true)) do
				if type(v) == "table" then
					for a, b in pairs(v) do
						if a == "Sprinting" then
							if b == 20 then
								for g,h in pairs(v) do
									v[h] = 0
								end
							end
						end
					end
				end  
			end
		end
	end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/BracketV3.lua"))()
local Window = Library:CreateWindow({
    WindowName = "tobiware",
    Color = Color3.fromRGB(255, 128, 64),
    Keybind = Enum.KeyCode.RightBracket
}, game:GetService("CoreGui"))


local GameWindow = Window:CreateTab("Game") 
local GameModifiers = GameWindow:CreateSection("Modifiers")
local VisualWindow = Window:CreateTab("Visuals")
local ObjectSection = VisualWindow:CreateSection("Objects")

ObjectSection:CreateToggle("Gem Visuals", false, function(value)
    GemESP.Enabled = value
    GemESP:Draw()
end)


ObjectSection:CreateToggle("Street Messes Visuals", false, function(value)
    StreetMessesESP.Enabled = value
    StreetMessesESP:Draw()
end)
 
--GameModifiers:CreateToggle("Infinite Stamina", false, function(value)
	--InfiniteStamina.Enabled = value  
	--InfiniteStamina:Toggled()
--end)

 
