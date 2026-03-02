-- ===============================
-- Web-Safe Main.lua
-- ===============================

function love.load()
    -- Detect Web build
    if love.system.getOS() == "Web" then
        print("Running in Web mode")
        WEB_BUILD = true
    else
        WEB_BUILD = false
    end

    if G and G.init then
        G:init()
    end
end


-- ===============================
-- WEB-SAFE ERROR HANDLER
-- ===============================

function love.errhand(msg)

    msg = tostring(msg)

    -- 🔒 Disable crash-report HTTP system entirely for Web
    if love.system.getOS() ~= "Web" then
        if G and G.SETTINGS and G.SETTINGS.crashreports and _RELEASE_MODE and G.F_CRASH_REPORTS then
            local http_thread = love.thread.newThread([[
                local https = require('https')
                CHANNEL = love.thread.getChannel("http_channel")
                while true do
                    local request = CHANNEL:demand()
                    if request then
                        https.request(request)
                    end
                end
            ]])
            local http_channel = love.thread.getChannel('http_channel')
            http_thread:start()
        end
    else
        print("Web error:", msg)
    end

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success = pcall(function()
            love.window.setMode(800, 600)
        end)
        if not success then return end
    end

    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
    end

    if love.audio then
        love.audio.stop()
    end

    love.graphics.reset()
    local font = love.graphics.newFont(20)
    love.graphics.setFont(font)

    love.graphics.clear(0, 0, 0)
    love.graphics.origin()

    local message = "Oops! Something went wrong:\n\n" .. msg

    local function draw()
        love.graphics.clear(0, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(message, 40, 40, love.graphics.getWidth() - 80)
        love.graphics.present()
    end

    while true do
        love.event.pump()
        for e, a in love.event.poll() do
            if e == "quit" then return end
            if e == "keypressed" and a == "escape" then return end
        end
        draw()
        if love.timer then love.timer.sleep(0.1) end
    end
end