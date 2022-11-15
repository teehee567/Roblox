
local ws

spawn(function()
    repeat wait() until game:IsLoaded()
    while wait(1) do
        pcall(function()
            ws = syn.websocket.connect("ws://localhost:33882/")

            ws:Send("auth:" .. game.Players.LocalPlayer.Name)
            ws.OnMessage:Connect(function(msg)
                local func, err = loadstring(msg)

                if err then
                    ws:Send("compile_err:" .. err)
                    return
                end

                func()
            end)

            ws.OnClose:Wait()
        end)
    end
end)

game:GetService("LogService").MessageOut:Connect(function(m)
    if ws then
        ws:Send("log:"..m)
    end
end)

game.ScriptContext.ErrorDetailed:Connect(function(message)
    if ws then
        ws:Send(message:sub(1, 1) .. utf8.char(8203) .. message:sub(2))
    end
end)
