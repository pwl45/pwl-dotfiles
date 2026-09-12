hs.window.animationDuration = 0
hs.autoLaunch(true)

local modifiers = { "alt" }
local sendToDisplayModifiers = { "alt", "shift" }

local function withFocusedWindow(action)
    return function()
        local window = hs.window.focusedWindow()
        if window then
            action(window)
        end
    end
end

local moveLeft = withFocusedWindow(function(window)
    window:moveToUnit({ x = 0, y = 0, w = 0.5, h = 1 }, 0)
end)

local moveRight = withFocusedWindow(function(window)
    window:moveToUnit({ x = 0.5, y = 0, w = 0.5, h = 1 }, 0)
end)

local minimize = withFocusedWindow(function(window)
    window:minimize()
end)

local fillDesktop = withFocusedWindow(function(window)
    window:maximize(0)
end)

local function moveToNearestCorner(y)
    return withFocusedWindow(function(window)
        local windowFrame = window:frame()
        local screenFrame = window:screen():frame()
        local windowCenterX = windowFrame.x + windowFrame.w / 2
        local screenCenterX = screenFrame.x + screenFrame.w / 2
        local x = windowCenterX < screenCenterX and 0 or 0.5

        window:moveToUnit({ x = x, y = y, w = 0.5, h = 0.5 }, 0)
    end)
end

local moveToNearestTopCorner = moveToNearestCorner(0)
local moveToNearestBottomCorner = moveToNearestCorner(0.5)

local function screensLeftToRight()
    local screens = hs.screen.allScreens()

    table.sort(screens, function(left, right)
        local leftFrame = left:frame()
        local rightFrame = right:frame()

        if leftFrame.x == rightFrame.x then
            return leftFrame.y < rightFrame.y
        end

        return leftFrame.x < rightFrame.x
    end)

    return screens
end

local function focusDisplay(index)
    return function()
        local screen = screensLeftToRight()[index]

        if not screen then
            hs.alert.show("Display " .. index .. " is not connected")
            return
        end

        for _, window in ipairs(hs.window.orderedWindows()) do
            local windowScreen = window:screen()

            if window:isVisible() and windowScreen and windowScreen:id() == screen:id() then
                window:focus()
                return
            end
        end

        hs.alert.show("No visible window on display " .. index)
    end
end

local function moveWindowToDisplay(index)
    return withFocusedWindow(function(window)
        local screen = screensLeftToRight()[index]

        if not screen then
            hs.alert.show("Display " .. index .. " is not connected")
            return
        end

        window:moveToScreen(screen, false, true, 0)
    end)
end

for _, key in ipairs({ "h", "left" }) do
    hs.hotkey.bind(modifiers, key, moveLeft)
end

for _, key in ipairs({ "l", "right" }) do
    hs.hotkey.bind(modifiers, key, moveRight)
end

hs.hotkey.bind(modifiers, "down", minimize)
hs.hotkey.bind(modifiers, "up", fillDesktop)

hs.hotkey.bind(modifiers, "u", fillDesktop)
hs.hotkey.bind(modifiers, "n", minimize)
-- hs.hotkey.bind(modifiers, "j", moveToNearestBottomCorner)
-- hs.hotkey.bind(modifiers, "k", moveToNearestTopCorner)

for index, key in ipairs({ "w", "e", "r" }) do
    hs.hotkey.bind(modifiers, key, focusDisplay(index))
    hs.hotkey.bind(sendToDisplayModifiers, key, moveWindowToDisplay(index))
end
