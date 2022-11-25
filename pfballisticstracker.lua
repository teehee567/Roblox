








bulletgravity = Vector3.new(0, -196.2, 0)
bulletspeed = 3200



local scriptpath = game:GetService("ReplicatedFirst").ClientModules.Rewrite.Weapon.Firearm.FirearmObject

for _,v in pairs(getgc(true)) do -- gets bullet speed for trajj calculation, probably another way but no way im looking thought that shit
    if type(v) == 'function' and getfenv(v).script == scriptpath then
        if table.find(getconstants(v),"aimspring") and table.find(getconstants(v),"zoommodspring") and table.find(getconstants(v),"standswayampmult") then
            local oldfunction
            oldfunction = hookfunction(v, function(...)
                local args = {...}
                pcall(function()
                    bulletspeed = args[1]._weaponData.bulletspeed
                end)
                return oldfunction(...)
            end)
        end
    end
end


local camint = require(game:GetService("ReplicatedFirst").ClientModules.Rewrite.Camera.CameraInterface).getActiveCamera("MainCamera") --main camera, bugs game dw about it





function main(v)
    local enemy_position = v.Head.Position
    local last_pos = enemy_position
    local BillboardGui = Instance.new("BillboardGui")
    local Frame = Instance.new("Frame")

    BillboardGui.Parent = game:GetService("CoreGui")
    BillboardGui.Adornee = v.Head
    BillboardGui.LightInfluence = 0
    BillboardGui.Size = UDim2.new(1, 0, 1, 0)
    BillboardGui.AlwaysOnTop = false -- make true if you wanna see through walls
    BillboardGui.StudsOffset = Vector3.new(0,3,0)
    BillboardGui.Brightness = 10 -- funni new roblox thingy

    Frame.Parent = BillboardGui
    Frame.BackgroundColor3 = Color3.fromRGB(239, 38, 245)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Rotation = 45

    local myconnection
    myconnection = game:GetService("RunService").RenderStepped:Connect(function(step)
        if not v:FindFirstChild("Head") then
            BillboardGui:Destroy()
            myconnection:Disconnect()
            return
        end

        enemy_position = v.Head.Position
        local distance = (camint:getCFrame().p - enemy_position).magnitude


        --vertical prediction
        local t = (bulletspeed * distance + 196.2 * distance) / bulletspeed ^ 2



        --horzontal prediction i fucking cant with this shit????? the fuckign velocity i get from this shit aint linear it some weird shit
        local enemyvelocity = (enemy_position - last_pos) / step
        local bull_time = distance/bulletspeed
        local horizontal_vector = enemyvelocity*bull_time



        BillboardGui.StudsOffset = Vector3.new(0,(((196.2 ^ t) / 2) - (t * 2)),0)

        last_pos = enemy_position
    end)
end


local team = tostring(game:GetService("Players").LocalPlayer.TeamColor)

workspace.Players.DescendantAdded:Connect(function(v)
    team = tostring(game:GetService("Players").LocalPlayer.TeamColor)
    if v.Parent.Name ~= team and v:IsA'Model' and v.Name == 'Player'then
        task.spawn(function()
            main(v)
        end)
        deleteshit(v)
    end
end)



for _,v in pairs(game:GetService("Workspace").Players:GetChildren()) do
    if v.Name ~= team then
        for _,v1 in pairs(v:GetChildren()) do
            task.spawn(function()
                main(v1)
            end)
            
            deleteshit(v1)
        end
    end
end

function deleteshit(thing)
    thing.Cosmetics:Destroy()
    thing.Head.Transparency = 1
end
