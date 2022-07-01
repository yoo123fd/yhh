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




local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Values = ReplicatedStorage:WaitForChild("Values")

local Mags = {}
local SpeedBoost = {}
local JumpBoost = {}
local AutoDive = {}
local AutoJump = {}
local DynamicJump = {}
local KickerAimbot = {}

do
    Mags.Enabled = false  
    Mags.Using = false 

    Mags.Distance = 11
    Mags.DistanceOffGround = 15
    Mags.Power = 1


    function Mags:Validated()
        return Values:WaitForChild("Fumble").Value ~= true 
        --return Values:WaitForChild("Status").Value == "InPlay" and Values:WaitForChild("Fumble").Value ~= true 
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
                
                Football.CanCollide = false
                firetouchinterest(Character["Left Arm"], Football, 0)
                firetouchinterest(Character["Right Arm"], Football, 0)
                task.wait()
                firetouchinterest(Character["Left Arm"], Football, 1)
                firetouchinterest(Character["Right Arm"], Football, 1)
                --Football.CFrame = Using.CFrame * CFrame.Angles(X_Value, X_Value, X_Value)
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

do
    DynamicJump.Enabled = false 
    DynamicJump.Max = 60
    DynamicJump.Bypassed = false 

    local function BypassAnti()
        if DynamicJump.Bypassed == false then 
            DynamicJump.Bypassed = true
            for i,v in pairs(getgc(true)) do
                if type(v) == "function" and islclosure(v) and not is_synapse_function(v) then
                    for k, x in pairs(debug.getconstants(v)) do
                        if x and tonumber(x) and tonumber(x) > 49 and tonumber(x) < 51 then
                            debug.setconstant(v, k, 120)
                        end
                    end
                end
            end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        if DynamicJump.Enabled then
            BypassAnti()
            if workspace:FindFirstChild("Football") then 
                local C = Client.Character
                local H = C and C:WaitForChild("Humanoid")
                local F = C and C:WaitForChild("Head")
                if H and F then 
                    local H2 = math.abs((F.Position.Y - workspace:FindFirstChild("Football").randomly.Y))
                    local Yurr = workspace:CalculateJumpPower(workspace.Gravity, H2)
                    Yurr = math.clamp(Yurr, 50, DynamicJump.Max)
                    H.JumpPower = Yurr
                end
            end
        end
    end)
end

do
    KickerAimbot.Enabled = false
    KickerAimbot.Accuracy = 100
    KickerAimbot.InThread = false

    function KickerAimbot:GetAccuracyArrow(Arrows)
        local Y = 0 
        local Arrow1 = nil 

        for _, Arrow in ipairs(Arrows) do
            if Arrow.Position.Y.Scale > Y then
                Y = Arrow.Position.Y.Scale
                Arrow1 = Arrow 
            end
       end 

       return Arrow1 
    end

    Client.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "KickerGui" then
            local KickerGui = child 
            local Meter = KickerGui:FindFirstChild("Meter")
            local Cursor = Meter:FindFirstChild("Cursor")
            local Arrows = {} 
            
            for i,v in pairs(Meter:GetChildren()) do
                if string.find(v.Name:lower(), "arrow") then
                    table.insert(Arrows, v)
                end
            end
            

            repeat task.wait() until Cursor.Position.Y.Scale < 0.02
            mouse1click()
            print((.03 / (KickerAimbot.Accuracy / 100)))
            repeat task.wait() until Cursor.Position.Y.Scale >= KickerAimbot:GetAccuracyArrow(Arrows).Position.Y.Scale + (.03 / (KickerAimbot.Accuracy / 100))
            mouse1click()
            print("clicking")
        end
    end)
end

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/CED5PfJS"))()
local Window = Library:CreateWindow({
	Title = "Football Fusion 2",
	Center = true, 
	AutoShow = true 
})

local Tabs = {
	Catching = Window:AddTab("Catching"),
    Kicking = Window:AddTab("Kicking"),
    Physics = Window:AddTab("Physics")
}

local GroupBoxes = {
    Catching = {
        Mags = Tabs.Catching:AddLeftGroupbox("Mags"),
        AutoDive = Tabs.Catching:AddRightGroupbox("AutoDive"),
        --AutoJump = Tabs.Catching:AddRightGroupbox("AutoJump")
    },

    Kicking = {
        Aimbot = Tabs.Kicking:AddLeftGroupbox("Aimbot")
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


GroupBoxes.Physics.Properties:AddToggle("DynamicJump", {
    Text = "Dynamic Jump",
    Default = DynamicJump.Enabled
})

GroupBoxes.Physics.Properties:AddSlider("DynamicJumpSlid", {
    Text = "Maximum",
    Default = DynamicJump.Max,
    Min = 50,
    Max = 100,
    Rounding = 0,
    Compact = false 
})

Toggles.DynamicJump:OnChanged(function()
    DynamicJump.Enabled = Toggles.DynamicJump.Value
end)

Options.DynamicJumpSlid:OnChanged(function()
    DynamicJump.Max = Options.DynamicJumpSlid.Value
end)


GroupBoxes.Kicking.Aimbot:AddToggle("KickerAimbotEnabled", {
    Text = "Enabled",
    Default = KickerAimbot.Enabled
})

GroupBoxes.Kicking.Aimbot:AddSlider("KickerAimbotAcc", {
    Text = "Accuracy",
    Default = KickerAimbot.Accuracy,
    Min = 80,
    Max = 100,
    Rounding = 0,
    Compact = false
})

Toggles.KickerAimbotEnabled:OnChanged(function()
    KickerAimbot.Enabled = Toggles.KickerAimbotEnabled.Value
end)

Options.KickerAimbotAcc:OnChanged(function()
    KickerAimbot.Accuracy = Options.KickerAimbotAcc.Value
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
