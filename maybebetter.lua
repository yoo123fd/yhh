local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Values = ReplicatedStorage:WaitForChild("Values")

local Mags = {}
local SpeedBoost = {}
local JumpBoost = {}
local AutoDive = {}
local AutoJump = {}

do
    local old; old = hookmetamethod(game, "__index", newcclosure(function(b, c)
        if b == workspace:FindFirstChild("Football") then
            if string.lower(c) == "position" then
                return Vector3.new()
            elseif string.lower(c) == "randomly" then
                return old(b, "Position")
            end
        end
    
        return old(b, c)
    end))   
        
    local cached = {}

    function hookconnections(obj, connection, _function)
        local connection = obj[connection]
        for i,v in pairs(getconnections(connection)) do
            v:Disable()
            local old = v.Function
            connection:Connect(_function, old)
        end
    end 

    
    game:GetService("RunService").RenderStepped:Connect(function()
        for _, Football in pairs(workspace:GetChildren()) do
            if not cached[Football] then
                cached[Football] = {} 
                hookconnections(Football, "AncestryChanged", function()
                    return nil 
                end)
            end
        end
    end)
      

    task.spawn(function()
        while true do
            if game:GetService("Players").LocalPlayer:FindFirstChildOfClass("Vector3Value") then
                game:GetService("Players").LocalPlayer:FindFirstChildOfClass("Vector3Value").Value = Vector3.new()
            end

            task.wait() 
        end
    end)
end

do
    Mags.Enabled = false  
    Mags.Using = false 

    Mags.Distance = 11
    Mags.DistanceOffGround = 15
    Mags.Power = 1


    function Mags:Validated()
        return Values:WaitForChild("Status").Value == "InPlay" and Values:WaitForChild("Fumble").Value ~= true 
    end

    function Mags:GetParams()
        local g = {}

        for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
            if Player.Character then
                table.insert(g, Player.Character)
            end
        end

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Blacklist
        Params.FilterDescendantsInstances = g 
        return Params
    end 

    function Mags:Rope(Football)
        if self.Using then return end 
        self.Using = true 

        local Connections = {}
        local Starting = tick() 

        local Character = Client.Character 
        local CatchRight = Character and Character:FindFirstChild("CatchRight") 
        local CatchLeft = Character and Character:FindFirstChild("CatchLeft")

        local CatchRightDis, CatchLeftDis = CatchRight and (CatchRight.Position - Football["randomly"]).Magnitude or 0, CatchLeft and (CatchLeft.Position - Football["randomly"]).Magnitude or 0   
        local Distance = CatchRightDis <= CatchLeftDis and CatchRightDis or CatchLeftDis <= CatchRightDis and CatchLeftDis or 0 
        local Using = CatchRightDis <= CatchLeftDis and CatchRight or CatchLeftDis <= CatchRightDis and CatchLeft

        if not CatchRight or not CatchLeft then self.Using = false return end 
        if not self:Validated() then self.Using = false return end     

        local function StopLoop()
            Starting = nil  
            for _, Connection in pairs(Connections) do
                Connection:Disconnect() 
            end
            table.clear(Connections) 
            self.Using = false 
        end 

        local function BallUpdate()
            if Starting == nil then return end 
            local Now = tick()
            
            if (Now - Starting) > 5 then
                StopLoop() 
                return 
            end

            if not self:Validated() then
                StopLoop()
                return
            end

            if Football and Football.Parent then 
                local Ms = (Now - Starting)
                local X_Value = (Ms / 10) * math.pi 
                
                Football.CFrame = Using.CFrame * CFrame.Angles(X_Value, X_Value, X_Value)
                Football.CanCollide = false
            else 
                StopLoop()
            end
        end 
        
        for i = 1, (10 * self.Power) do
            table.insert(Connections, game:GetService("RunService").RenderStepped:Connect(BallUpdate)) 
            table.insert(Connections, game:GetService("RunService").Stepped:Connect(BallUpdate)) 
            table.insert(Connections, game:GetService("RunService").Heartbeat:Connect(BallUpdate)) 
        end
    end

    function Mags:Activate()
        local ClosestDistance = math.huge 
        local ClosestFootball = nil 

        for _,v in pairs(workspace:GetChildren()) do
            if v.Name == "Football" then
                local RootPart = Client.Character and Client.Character.PrimaryPart 
                local Distance = RootPart and (RootPart.Position - v["randomly"]).Magnitude or 0 
                local Raycast = workspace:Raycast(v["randomly"], Vector3.new(0, -self.DistanceOffGround, 0), self:GetParams())

                if Distance < ClosestDistance and Distance < self.Distance then
                    if Raycast and Raycast.Instance then
                        ClosestFootball = v 
                        ClosestDistance = Distance 
                    end
                end
            end
        end

        if ClosestFootball then
            self:Rope(ClosestFootball)
        end
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        if Mags.Enabled then
            Mags:Activate()
        end
    end)
end

do
    AutoDive.Enabled = false 
    AutoDive.Distance = 9 

    function AutoDive:Yes() 
        if not self.Enabled then return end 

        local Character = Client.Character 
        local RootPart = Character and Character.PrimaryPart

        if RootPart then
            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Blacklist
            Params.FilterDescendantsInstances = {Character}

            local Raycast = workspace:Raycast(RootPart.Position, Vector3.new(0, -10, 0), Params)
            if Raycast and Raycast.Instance then
                local Yea = (Raycast.Position.Y - RootPart.Position.Y)  
                --print(math.abs(Yea))
                if math.abs(Yea) >= self.Distance then
                    return true
                end
            end
        end
    end 

    game:GetService("RunService").RenderStepped:Connect(function()
        if AutoDive.Enabled then
            if AutoDive:Yes() then 
                --print("again?")
                keypress(0x45)
                task.wait()
                keyrelease(0x45)
            end
        end
    end)
end

do 
    AutoJump.Enabled = false 
    AutoJump.Distance = 22  

    function AutoJump:Yes() 
        if not self.Enabled then return end 
        local Ball = workspace:FindFirstChild("Football")
        local RootPart = Character and Character.PrimaryPart

        if Ball and RootPart then
            local Params = Mags:GetParams()

            local Raycast = workspace:Raycast(Ball["randomly"], Vector3.new(0, -self.Distance, 0), Params)
            if Raycast and Raycast.Instance and (RootPart.Position - Ball["randomly"]).Magnitude < 20 then
                return true 
            end
        end
    end 

    game:GetService("RunService").RenderStepped:Connect(function()
        if AutoJump.Enabled then
            if AutoJump:Yes() then
                local Humanoid = Client.Character and Client.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
--                    print("pls?")
                    Humanoid.Jump = true 
                end
            end
        end
    end)
end     

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/mzYxYFaK"))()
local Window = Library:CreateWindow({
	Title = "Football Fusion 2",
	Center = true, 
	AutoShow = true 
})

local Tabs = {
	Catching = Window:AddTab("Catching"),
    Physics = Window:AddTab("Physics")
}

local GroupBoxes = {
    Catching = {
        Mags = Tabs.Catching:AddLeftGroupbox("Mags"),
        AutoDive = Tabs.Catching:AddRightGroupbox("AutoDive"),
        --AutoJump = Tabs.Catching:AddRightGroupbox("AutoJump")
    },

    Physics = {
        Properties = Tabs.Physics:AddLeftGroupbox("Properties")
    }
}


-- // 
GroupBoxes.Catching.Mags:AddToggle("MagsEnabled", {
    Text = "Enabled",
    Default = Mags.Enabled,
    Tooltip = "Enable mags"
})

Toggles.MagsEnabled:OnChanged(function()
    Mags.Enabled = Toggles.MagsEnabled.Value 
end)
--// 
GroupBoxes.Catching.Mags:AddSlider("MagsDistance", {
    Text = "Distance",
    Default = Mags.Distance,
    Min = 1,
    Max = 40,
    Rounding = 1,
    Compact = false 
})

Options.MagsDistance:OnChanged(function()
    Mags.Distance = Options.MagsDistance.Value 
end)
--// 
GroupBoxes.Catching.Mags:AddSlider("MagsDistanceOFG", {
    Text = "Distance off ground",
    Default = Mags.DistanceOffGround,
    Min = 1,
    Max = 40,
    Rounding = 1,
    Compact = false 
})

Options.MagsDistanceOFG:OnChanged(function()
    Mags.DistanceOffGround = Options.MagsDistanceOFG.Value 
end)
--// 
GroupBoxes.Catching.Mags:AddSlider("MagsPower", {
    Text = "Power",
    Default = Mags.Power,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false 
})

Options.MagsPower:OnChanged(function()
    Mags.Power = Options.MagsPower.Value 
end)

--//
GroupBoxes.Catching.AutoDive:AddToggle("AutoDiveEnabled", {
    Text = "Enabled",
    Default = AutoDive.Enabled,
    Tooltip = "Enable autodive"
})

Toggles.AutoDiveEnabled:OnChanged(function()
    AutoDive.Enabled = Toggles.AutoDiveEnabled.Value 
end)
--// 
GroupBoxes.Catching.AutoDive:AddSlider("AutoDiveOFG", {
    Text = "Peak",
    Default = AutoDive.Distance,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = false 
})

Options.AutoDiveOFG:OnChanged(function()
    AutoDive.Distance = Options.AutoDiveOFG.Value 
end)
--//
--[[
GroupBoxes.Catching.AutoJump:AddToggle("AutoJumpEnabled", {
    Text = "Enabled",
    Default = AutoJump.Enabled,
    Tooltip = "Enable autojump"
})

Toggles.AutoJumpEnabled:OnChanged(function()
    AutoJump.Enabled = Toggles.AutoJumpEnabled.Value 
end)
--//
GroupBoxes.Catching.AutoJump:AddSlider("AutoJumpOFG", {
    Text = "Distance off ground",
    Default = AutoJump.Distance,
    Min = 1,
    Max = 40,
    Rounding = 1,
    Compact = false 
})

Options.AutoJumpOFG:OnChanged(function()
    AutoJump.Distance = Options.AutoJumpOFG.Value 
end)
--]]
