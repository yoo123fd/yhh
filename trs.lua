local Players = game.GetService(game, "Players")
local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded.Wait(Client)

local Reach = {}
do
    Reach.Enabled = true
    Reach.Distance = 5

    function Reach:GetClosestBall()
        local HumanoidRootPart = Character.WaitForChild(Character, "HumanoidRootPart")
        local Keywords = {"Catch", "Ground", "Save", "Sound", "Gravity", "IsHeld", "ReactDecline", "PB", "Owner"}

        local ClosestDistance = math.huge 
        local ClosestBall = nil 

        for i,v in pairs(workspace.GetChildren(workspace)) do
            local ItemsFound = 0 
            for a,b in pairs(Keywords) do
                if v.FindFirstChild(v, b) then
                    ItemsFound += 1
                end
            end

            if ItemsFound >= #Keywords then
                local Distance = (v.Position - HumanoidRootPart.Position).Magnitude
                
                if Distance <= ClosestDistance and Distance <= Reach.Distance then
                    ClosestDistance = Distance 
                    ClosestBall = v 
                end
            end
        end

        for i,v in pairs(workspace.TrainingBalls.GetChildren(workspace.TrainingBalls)) do
            local ItemsFound = 0 
            for a,b in pairs(Keywords) do
                if v.FindFirstChild(v, b) then
                    ItemsFound += 1
                end
            end
    
            if ItemsFound >= #Keywords then
                local Distance = (v.Position - HumanoidRootPart.Position).Magnitude
                
                if Distance <= ClosestDistance and Distance <= Reach.Distance then
                    ClosestDistance = Distance 
                    ClosestBall = v 
                end
            end
        end
        
        return ClosestBall
    end


    local old; old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if getnamecallmethod() == "GetTouchingParts" then
            if Reach.GetClosestBall(Reach) then
                if Reach.Enabled then
                    if self == Reach.GetClosestBall(Reach) then
                        return {Character.WaitForChild(Character, "Left Leg"), Character.WaitForChild(Character, "Right Leg")}
                    elseif self == Character.WaitForChild(Character, "Left Leg") then
                        return {Reach.GetClosestBall(Reach)}
                    end
                end
            end
        end

        return old(self, ...)
    end))


    game:GetService("RunService").RenderStepped:Connect(function()
        if Reach.Enabled and Reach:GetClosestBall() then
            firetouchinterest(Reach:GetClosestBall(), Character:WaitForChild("Left Leg"), 0)
            firetouchinterest(Reach:GetClosestBall(), Character:WaitForChild("Right Leg"), 0)
            task.wait()
            firetouchinterest(Reach:GetClosestBall(), Character:WaitForChild("Left Leg"), 1)
            firetouchinterest(Reach:GetClosestBall(), Character:WaitForChild("Right Leg"), 1)
        end
    end)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({
	Title = "TRS",
	Center = true, 
	AutoShow = true 
})

local Tabs = {
	Physics = Window:AddTab("Physics"),
}

local GroupBoxes = {
    Physics = {
        Reach = Tabs.Physics:AddLeftGroupbox("Reach"),
    },

}

GroupBoxes.Physics.Reach:AddToggle("ReachEnabled", {
    Text = "Enabled",
    Default = Reach.Enabled,
    Tooltip = "Enable Reach"
})

Toggles.ReachEnabled:OnChanged(function()
    Reach.Enabled = Toggles.ReachEnabled.Value 
end)


--// 
GroupBoxes.Physics.Reach:AddSlider("ReachDistance", {
    Text = "Distance",
    Default = Reach.Distance,
    Min = 1,
    Max = 40,
    Rounding = 1,
    Compact = false 
})

Options.ReachDistance:OnChanged(function()
    Reach.Distance = Options.ReachDistance.Value 
end)


Client.CharacterAdded:Connect(function(Character2)
    Character = Character2
end)
