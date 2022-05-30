if getgenv().executed then return end 
getgenv().executed = true 
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/yoo123fd/yhh/main/ms.lua"))()
