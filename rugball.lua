local Players = game:GetService("Players")
local Client = Players.LocalPlayer

local Character = Client.Character or Client.CharacterAdded:Wait()
local Mouse = Client:GetMouse()

local RunService = game:GetService("RunService")

local Ballistic = loadstring(game:HttpGet("https://pastebin.com/raw/VsehgxhC"))()
local Polynomial = loadstring(game:HttpGet("https://pastebin.com/raw/cJLiwfs9"))()

local UserInputService = game:GetService("UserInputService")
local Enabled = false

local enabledLabel = Drawing.new('Text')
enabledLabel.Visible = true
enabledLabel.Size = 30
enabledLabel.Color = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
enabledLabel.Transparency = 1
enabledLabel.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 50)
enabledLabel.Center = true
enabledLabel.Text = Enabled and "Enabled" or "Disabled"


UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.Q then
		Enabled = not Enabled
        enabledLabel.Color = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0) 
        enabledLabel.Text = Enabled and "Enabled" or "Disabled"
	end
end)


do
	Ballistic.Gravity = 28 
end

local Field = workspace:WaitForChild("Field")
local Goals = Field:WaitForChild("Goals")

local function GetClosestGoal()
	local ClosestDistance = math.huge 
	local ClosestGoal = nil 

	for _, Goal in ipairs(Goals:GetChildren()) do
		local Distance = (Character:WaitForChild("HumanoidRootPart").Position - Goal:FindFirstChild("Backline2").Position).Magnitude
		if Distance < ClosestDistance then
			ClosestDistance = Distance 
			ClosestGoal = Goal:FindFirstChild("Backline2")
		end
	end
	
	return ClosestGoal
end

local old; old = hookmetamethod(game, "__namecall", newcclosure(function (self, ...)
	local args = {...}
	
	if args[1] == "Throw" and getnamecallmethod() == "FireServer" and Enabled then
		local Goal = GetClosestGoal()
		local V = Ballistic.SolveStationary(Character.Head.Position, 100, Goal.Position, false) 
		args[2] = V
		return self.FireServer(self, table.unpack(args))
	end	

	return old(self, ...)
end))

Client.CharacterAdded:Connect(function(character)
	Character = character
end)
