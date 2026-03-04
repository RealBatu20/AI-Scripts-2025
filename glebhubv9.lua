-- Original by gleb8282822
-- GUI by Botakkkkk (Gleb Hub V9)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

if _G.GlebHubLoaded then
    print("GLEB HUB already loaded - preventing duplicate")
    return
end
_G.GlebHubLoaded = true

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, name in ipairs({"GlebHubModern", "GlebHubMinimized", "GlebHubModal", "GlebHubAddScript", "GlebHubLangSelect", "GlebHubCloseConfirm"}) do
    local existing = playerGui:FindFirstChild(name)
    if existing then existing:Destroy() end
end

local THEMES = {
    dark = {
        bg = Color3.fromRGB(30, 30, 35),
        surface = Color3.fromRGB(40, 40, 48),
        elevated = Color3.fromRGB(55, 55, 65),
        hover = Color3.fromRGB(70, 70, 80),
        text = Color3.fromRGB(240, 240, 245),
        textMuted = Color3.fromRGB(140, 140, 150),
        border = Color3.fromRGB(70, 70, 80),
        accent = Color3.fromRGB(88, 101, 242),
        success = Color3.fromRGB(59, 165, 93),
        danger = Color3.fromRGB(220, 60, 60),
        warning = Color3.fromRGB(220, 160, 40)
    },
    light = {
        bg = Color3.fromRGB(245, 245, 250),
        surface = Color3.fromRGB(235, 235, 240),
        elevated = Color3.fromRGB(220, 220, 230),
        hover = Color3.fromRGB(200, 200, 210),
        text = Color3.fromRGB(30, 30, 40),
        textMuted = Color3.fromRGB(100, 100, 115),
        border = Color3.fromRGB(200, 200, 210),
        accent = Color3.fromRGB(88, 101, 242),
        success = Color3.fromRGB(40, 150, 70),
        danger = Color3.fromRGB(200, 50, 50),
        warning = Color3.fromRGB(200, 140, 20)
    }
}

local CONFIG = {
    ITEMS_PER_PAGE = 10,
    COLUMNS = 2,
    CARD_HEIGHT = 48,
    CARD_PADDING = 6,
    HEADER_HEIGHT = 42,
    FOOTER_HEIGHT = 32,
    ADD_BUTTON_HEIGHT = 44,
    PADDING = 8,
    WIDTH = 400
}

local I18N = {
    en = {
        title = "GLEB HUB",
        addScript = "+ Add Script",
        prev = "<",
        next = ">",
        page = "Page",
        sortRelevance = "Sort: Relevance",
        sortAZ = "Sort: A-Z",
        sortZA = "Sort: Z-A",
        sortNewest = "Sort: Newest",
        sortOldest = "Sort: Oldest",
        close = "x",
        minimize = "-",
        deleteConfirm = "Delete Script?",
        deleteWarning = "This cannot be undone.",
        cancel = "Cancel",
        delete = "Delete",
        added = "Added",
        dragHint = "Drag",
        scriptName = "Script Name",
        scriptCode = "Script Code",
        addScriptTitle = "New Script",
        confirmAdd = "Continue",
        selectLang = "Select Language",
        langENG = "ENG",
        langRU = "RU",
        themeDark = "Dark",
        themeLight = "Light",
        closeConfirm = "Close without saving?",
        closeWarning = "Your changes will be lost.",
        discard = "Discard",
        save = "Save"
    },
    ru = {
        title = "ГЛЕБ ХАБ",
        addScript = "+ Добавить скрипт",
        prev = "<",
        next = ">",
        page = "Страница",
        sortRelevance = "Сорт: Релевантность",
        sortAZ = "Сорт: А-Я",
        sortZA = "Сорт: Я-А",
        sortNewest = "Сорт: Новые",
        sortOldest = "Сорт: Старые",
        close = "x",
        minimize = "-",
        deleteConfirm = "Удалить скрипт?",
        deleteWarning = "Это действие нельзя отменить.",
        cancel = "Отмена",
        delete = "Удалить",
        added = "Добавлен",
        dragHint = "Перетащить",
        scriptName = "Название скрипта",
        scriptCode = "Код скрипта",
        addScriptTitle = "Новый скрипт",
        confirmAdd = "Продолжить",
        selectLang = "Выберите язык",
        langENG = "ENG",
        langRU = "RU",
        themeDark = "Темный",
        themeLight = "Светлый",
        closeConfirm = "Закрыть без сохранения?",
        closeWarning = "Изменения будут потеряны.",
        discard = "Отменить",
        save = "Сохранить"
    }
}

local State = {
    currentLang = "en",
    currentPage = 1,
    currentSort = "relevance",
    isMinimized = false,
    isDark = true,
    scripts = {}
}

local sortCycle = {"relevance", "az", "za", "newest", "oldest"}
local currentTheme = THEMES.dark
local buttonRefs = {}

local function initScripts()
    local scriptData = {
        {name = "Mobile Fly V5", url = "https://rawscripts.net/raw/Universal-Script-Gleb-Hub-V5-Mobile-Fly-Joystick-Up-Down-110267 ", date = os.time() - 86400 * 30},
        {name = "Endless Jump", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-endless-jumping-Russia-110337 ", date = os.time() - 86400 * 28},
        {name = "Cool Music", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-Cool-music-110555 ", date = os.time() - 86400 * 25},
        {name = "Copy Name", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-copy-player-name-ru-110574 ", date = os.time() - 86400 * 20},
        {name = "FE Flags", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-fe-flagi-ru-110986 ", date = os.time() - 86400 * 18},
        {name = "ESC GUI", url = "https://rawscripts.net/raw/Universal-Script-ESC-GUI-ru-RU-112817 ", date = os.time() - 86400 * 15},
        {name = "Sword Script", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-sword-script-127007 ", date = os.time() - 86400 * 10},
        {name = "Sword V2", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-sword-v2-Large-hitboxes-127497 ", date = os.time() - 86400 * 8},
        {name = "Laser Gun", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-laser-gun-beta-127500 ", date = os.time() - 86400 * 5},
        {name = "Bomb Script", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-Bomb-127636 ", date = os.time() - 86400 * 3},
        {name = "Time Stop", url = "https://rawscripts.net/raw/UP-Just-a-baseplate.-Stopping-time-and-bomb-128246 ", date = os.time() - 86400 * 1}
    }
    
    for _, data in ipairs(scriptData) do
        data.id = HttpService:GenerateGUID(false)
        data.addedAt = data.date or os.time()
        table.insert(State.scripts, data)
    end
end

initScripts()

local function formatDate(timestamp)
    local date = os.date("*t", timestamp)
    return string.format("%02d.%02d.%d", date.day, date.month, date.year)
end

local function getText(key)
    return I18N[State.currentLang][key] or I18N.en[key] or key
end

local function getSortText(sortType)
    if sortType == "az" then
        return getText("sortAZ")
    elseif sortType == "za" then
        return getText("sortZA")
    else
        return getText("sort" .. sortType:gsub("^%l", string.upper))
    end
end

local function tween(obj, props, duration)
    local info = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or currentTheme.border
    s.Thickness = 0.5
    s.Parent = parent
    return s
end

local function calculateGuiSize()
    local gridHeight = (CONFIG.CARD_HEIGHT + CONFIG.CARD_PADDING) * 5
    local totalHeight = CONFIG.HEADER_HEIGHT + gridHeight + CONFIG.ADD_BUTTON_HEIGHT + CONFIG.FOOTER_HEIGHT + (CONFIG.PADDING * 4)
    return CONFIG.WIDTH, totalHeight
end

local GUI_WIDTH, GUI_HEIGHT = calculateGuiSize()

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "GlebHubModern"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.DisplayOrder = 100
mainGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
mainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
mainFrame.BackgroundColor3 = currentTheme.bg
mainFrame.BorderSizePixel = 0
corner(mainFrame, 8)
mainFrame.Parent = mainGui

local titleBarFrame = Instance.new("Frame")
titleBarFrame.Name = "TitleBarFrame"
titleBarFrame.Size = UDim2.new(1, 0, 0, CONFIG.HEADER_HEIGHT)
titleBarFrame.BackgroundColor3 = currentTheme.surface
titleBarFrame.BorderSizePixel = 0
corner(titleBarFrame, 8)
titleBarFrame.Parent = mainFrame

local titleBarFix = Instance.new("Frame")
titleBarFix.Size = UDim2.new(1, 0, 0, 10)
titleBarFix.Position = UDim2.new(0, 0, 1, -10)
titleBarFix.BackgroundColor3 = currentTheme.surface
titleBarFix.BorderSizePixel = 0
titleBarFix.Parent = titleBarFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 90, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = getText("title")
titleLabel.TextColor3 = currentTheme.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBarFrame

local middleContainer = Instance.new("Frame")
middleContainer.Name = "MiddleContainer"
middleContainer.Size = UDim2.new(0, 220, 0, 26)
middleContainer.Position = UDim2.new(0.5, -110, 0.5, -13)
middleContainer.BackgroundTransparency = 1
middleContainer.Parent = titleBarFrame

local themeBtn = Instance.new("TextButton")
themeBtn.Name = "ThemeBtn"
themeBtn.Size = UDim2.new(0, 60, 1, 0)
themeBtn.Position = UDim2.new(0, 0, 0, 0)
themeBtn.BackgroundColor3 = currentTheme.elevated
themeBtn.Text = getText("themeDark")
themeBtn.TextColor3 = currentTheme.text
themeBtn.Font = Enum.Font.GothamMedium
themeBtn.TextSize = 10
themeBtn.AutoButtonColor = false
corner(themeBtn, 4)
stroke(themeBtn)
themeBtn.Parent = middleContainer
buttonRefs.themeBtn = themeBtn

local sortBtn = Instance.new("TextButton")
sortBtn.Name = "SortBtn"
sortBtn.Size = UDim2.new(0, 100, 1, 0)
sortBtn.Position = UDim2.new(0, 66, 0, 0)
sortBtn.BackgroundColor3 = currentTheme.elevated
sortBtn.Text = getSortText(State.currentSort)
sortBtn.TextColor3 = currentTheme.text
sortBtn.Font = Enum.Font.GothamMedium
sortBtn.TextSize = 10
sortBtn.AutoButtonColor = false
corner(sortBtn, 4)
stroke(sortBtn)
sortBtn.Parent = middleContainer
buttonRefs.sortBtn = sortBtn

local langBtn = Instance.new("TextButton")
langBtn.Name = "LangBtn"
langBtn.Size = UDim2.new(0, 44, 1, 0)
langBtn.Position = UDim2.new(0, 172, 0, 0)
langBtn.BackgroundColor3 = currentTheme.elevated
langBtn.Text = getText("langENG")
langBtn.TextColor3 = currentTheme.accent
langBtn.Font = Enum.Font.GothamMedium
langBtn.TextSize = 10
langBtn.AutoButtonColor = false
corner(langBtn, 4)
stroke(langBtn, currentTheme.accent)
langBtn.Parent = middleContainer
buttonRefs.langBtn = langBtn

local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 28, 0, 24)
minBtn.Position = UDim2.new(1, -64, 0.5, -12)
minBtn.BackgroundColor3 = currentTheme.warning
minBtn.Text = getText("minimize")
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.AutoButtonColor = false
corner(minBtn, 4)
minBtn.Parent = titleBarFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0.5, -12)
closeBtn.BackgroundColor3 = currentTheme.danger
closeBtn.Text = getText("close")
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = false
corner(closeBtn, 4)
closeBtn.Parent = titleBarFrame

local contentTop = CONFIG.HEADER_HEIGHT + CONFIG.PADDING

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Grid"
scroll.Size = UDim2.new(1, -16, 0, (CONFIG.CARD_HEIGHT + CONFIG.CARD_PADDING) * 5)
scroll.Position = UDim2.new(0, 8, 0, contentTop)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = currentTheme.border
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -3, 0, CONFIG.CARD_HEIGHT)
grid.CellPadding = UDim2.new(0, CONFIG.CARD_PADDING, 0, CONFIG.CARD_PADDING)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = scroll

local addBtnTop = contentTop + scroll.Size.Y.Offset + CONFIG.PADDING
local addBtn = Instance.new("TextButton")
addBtn.Name = "AddBtn"
addBtn.Size = UDim2.new(1, -16, 0, CONFIG.ADD_BUTTON_HEIGHT)
addBtn.Position = UDim2.new(0, 8, 0, addBtnTop)
addBtn.BackgroundColor3 = currentTheme.success
addBtn.Text = getText("addScript")
addBtn.TextColor3 = Color3.new(1, 1, 1)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 12
addBtn.AutoButtonColor = false
corner(addBtn, 6)
addBtn.Parent = mainFrame
buttonRefs.addBtn = addBtn

local pageBarTop = addBtnTop + CONFIG.ADD_BUTTON_HEIGHT + CONFIG.PADDING
local pageBar = Instance.new("Frame")
pageBar.Name = "PageBar"
pageBar.Size = UDim2.new(1, -16, 0, CONFIG.FOOTER_HEIGHT)
pageBar.Position = UDim2.new(0, 8, 0, pageBarTop)
pageBar.BackgroundTransparency = 1
pageBar.Parent = mainFrame

local prevBtn = Instance.new("TextButton")
prevBtn.Name = "PrevBtn"
prevBtn.Size = UDim2.new(0, 28, 0, 28)
prevBtn.Position = UDim2.new(0, 0, 0.5, -14)
prevBtn.BackgroundColor3 = currentTheme.elevated
prevBtn.Text = getText("prev")
prevBtn.TextColor3 = currentTheme.text
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = 12
prevBtn.AutoButtonColor = false
corner(prevBtn, 4)
stroke(prevBtn)
prevBtn.Parent = pageBar
buttonRefs.prevBtn = prevBtn

local pageLabel = Instance.new("TextLabel")
pageLabel.Name = "PageLabel"
pageLabel.Size = UDim2.new(0, 80, 1, 0)
pageLabel.Position = UDim2.new(0.5, -40, 0, 0)
pageLabel.BackgroundTransparency = 1
pageLabel.Text = "1 / 1"
pageLabel.TextColor3 = currentTheme.textMuted
pageLabel.Font = Enum.Font.GothamMedium
pageLabel.TextSize = 12
pageLabel.Parent = pageBar

local nextBtn = Instance.new("TextButton")
nextBtn.Name = "NextBtn"
nextBtn.Size = UDim2.new(0, 28, 0, 28)
nextBtn.Position = UDim2.new(1, -28, 0.5, -14)
nextBtn.BackgroundColor3 = currentTheme.elevated
nextBtn.Text = getText("next")
nextBtn.TextColor3 = currentTheme.text
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = 12
nextBtn.AutoButtonColor = false
corner(nextBtn, 4)
stroke(nextBtn)
nextBtn.Parent = pageBar
buttonRefs.nextBtn = nextBtn

local miniGui = Instance.new("ScreenGui")
miniGui.Name = "GlebHubMinimized"
miniGui.ResetOnSpawn = false
miniGui.Enabled = false
miniGui.Parent = playerGui

local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MiniBtn"
miniBtn.Size = UDim2.new(0, 60, 0, 32)
miniBtn.Position = UDim2.new(0, 20, 0.5, -16)
miniBtn.BackgroundColor3 = currentTheme.accent
miniBtn.Text = "GLEB"
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 12
miniBtn.AutoButtonColor = false
corner(miniBtn, 4)
miniBtn.Parent = miniGui

local delGui = Instance.new("ScreenGui")
delGui.Name = "GlebHubModal"
delGui.ResetOnSpawn = false
delGui.Enabled = false
delGui.DisplayOrder = 100
delGui.Parent = playerGui

local delOverlay = Instance.new("Frame")
delOverlay.Size = UDim2.new(1, 0, 1, 0)
delOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
delOverlay.BackgroundTransparency = 0.5
delOverlay.Parent = delGui

local delFrame = Instance.new("Frame")
delFrame.Size = UDim2.new(0, 280, 0, 120)
delFrame.Position = UDim2.new(0.5, -140, 0.5, -60)
delFrame.BackgroundColor3 = currentTheme.bg
delFrame.BorderSizePixel = 0
corner(delFrame, 8)
delFrame.Parent = delOverlay

local delTitle = Instance.new("TextLabel")
delTitle.Size = UDim2.new(1, -20, 0, 24)
delTitle.Position = UDim2.new(0, 10, 0, 10)
delTitle.BackgroundTransparency = 1
delTitle.Text = getText("deleteConfirm")
delTitle.TextColor3 = currentTheme.danger
delTitle.Font = Enum.Font.GothamBold
delTitle.TextSize = 16
delTitle.Parent = delFrame

local delWarn = Instance.new("TextLabel")
delWarn.Size = UDim2.new(1, -20, 0, 30)
delWarn.Position = UDim2.new(0, 10, 0, 34)
delWarn.BackgroundTransparency = 1
delWarn.Text = getText("deleteWarning")
delWarn.TextColor3 = currentTheme.textMuted
delWarn.Font = Enum.Font.Gotham
delWarn.TextSize = 12
delWarn.TextWrapped = true
delWarn.Parent = delFrame

local delCancel = Instance.new("TextButton")
delCancel.Size = UDim2.new(0, 120, 0, 32)
delCancel.Position = UDim2.new(0, 10, 1, -42)
delCancel.BackgroundColor3 = currentTheme.elevated
delCancel.Text = getText("cancel")
delCancel.TextColor3 = currentTheme.text
delCancel.Font = Enum.Font.GothamMedium
delCancel.TextSize = 12
delCancel.AutoButtonColor = false
corner(delCancel, 6)
delCancel.Parent = delFrame

local delConfirm = Instance.new("TextButton")
delConfirm.Size = UDim2.new(0, 120, 0, 32)
delConfirm.Position = UDim2.new(1, -130, 1, -42)
delConfirm.BackgroundColor3 = currentTheme.danger
delConfirm.Text = getText("delete")
delConfirm.TextColor3 = Color3.new(1, 1, 1)
delConfirm.Font = Enum.Font.GothamMedium
delConfirm.TextSize = 12
delConfirm.AutoButtonColor = false
corner(delConfirm, 6)
delConfirm.Parent = delFrame

local addGui = Instance.new("ScreenGui")
addGui.Name = "GlebHubAddScript"
addGui.ResetOnSpawn = false
addGui.Enabled = false
addGui.DisplayOrder = 200
addGui.Parent = playerGui

local addFrame = Instance.new("Frame")
addFrame.Size = UDim2.new(0, 340, 0, 400)
addFrame.Position = UDim2.new(0.5, -170, 0.5, -200)
addFrame.BackgroundColor3 = currentTheme.bg
addFrame.BorderSizePixel = 0
corner(addFrame, 8)
addFrame.Parent = addGui

local addTitleBar = Instance.new("Frame")
addTitleBar.Size = UDim2.new(1, 0, 0, 36)
addTitleBar.BackgroundColor3 = currentTheme.surface
addTitleBar.BorderSizePixel = 0
corner(addTitleBar, 8)
addTitleBar.Parent = addFrame

local addTitleFix = Instance.new("Frame")
addTitleFix.Size = UDim2.new(1, 0, 0, 10)
addTitleFix.Position = UDim2.new(0, 0, 1, -10)
addTitleFix.BackgroundColor3 = currentTheme.surface
addTitleFix.BorderSizePixel = 0
addTitleFix.Parent = addTitleBar

local addTitle = Instance.new("TextLabel")
addTitle.Size = UDim2.new(1, -40, 1, 0)
addTitle.Position = UDim2.new(0, 12, 0, 0)
addTitle.BackgroundTransparency = 1
addTitle.Text = getText("addScriptTitle")
addTitle.TextColor3 = currentTheme.success
addTitle.Font = Enum.Font.GothamBold
addTitle.TextSize = 16
addTitle.TextXAlignment = Enum.TextXAlignment.Left
addTitle.Parent = addTitleBar

local addCloseBtn = Instance.new("TextButton")
addCloseBtn.Name = "AddCloseBtn"
addCloseBtn.Size = UDim2.new(0, 24, 0, 24)
addCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
addCloseBtn.BackgroundColor3 = currentTheme.danger
addCloseBtn.Text = "x"
addCloseBtn.TextColor3 = Color3.new(1, 1, 1)
addCloseBtn.Font = Enum.Font.GothamBold
addCloseBtn.TextSize = 12
addCloseBtn.AutoButtonColor = false
corner(addCloseBtn, 4)
addCloseBtn.Parent = addTitleBar

local addContent = Instance.new("Frame")
addContent.Size = UDim2.new(1, -20, 1, -48)
addContent.Position = UDim2.new(0, 10, 0, 42)
addContent.BackgroundTransparency = 1
addContent.Parent = addFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 18)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = getText("scriptName")
nameLabel.TextColor3 = currentTheme.textMuted
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 11
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = addContent

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, 0, 0, 32)
nameBox.Position = UDim2.new(0, 0, 0, 20)
nameBox.BackgroundColor3 = currentTheme.surface
nameBox.Text = ""
nameBox.PlaceholderText = "Enter script name..."
nameBox.TextColor3 = currentTheme.text
nameBox.PlaceholderColor3 = currentTheme.textMuted
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 12
nameBox.ClearTextOnFocus = false
corner(nameBox, 4)
stroke(nameBox)
nameBox.Parent = addContent

local codeLabel = Instance.new("TextLabel")
codeLabel.Size = UDim2.new(1, 0, 0, 18)
codeLabel.Position = UDim2.new(0, 0, 0, 62)
codeLabel.BackgroundTransparency = 1
codeLabel.Text = getText("scriptCode")
codeLabel.TextColor3 = currentTheme.textMuted
codeLabel.Font = Enum.Font.Gotham
codeLabel.TextSize = 11
codeLabel.TextXAlignment = Enum.TextXAlignment.Left
codeLabel.Parent = addContent

local codeContainer = Instance.new("Frame")
codeContainer.Size = UDim2.new(1, 0, 0, 180)
codeContainer.Position = UDim2.new(0, 0, 0, 82)
codeContainer.BackgroundColor3 = currentTheme.surface
codeContainer.BorderSizePixel = 0
corner(codeContainer, 4)
stroke(codeContainer)
codeContainer.Parent = addContent

local codeScroll = Instance.new("ScrollingFrame")
codeScroll.Size = UDim2.new(1, -8, 1, -8)
codeScroll.Position = UDim2.new(0, 4, 0, 4)
codeScroll.BackgroundTransparency = 1
codeScroll.ScrollBarThickness = 3
codeScroll.ScrollBarImageColor3 = currentTheme.border
codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
codeScroll.Parent = codeContainer

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -4, 1, 0)
codeBox.Position = UDim2.new(0, 2, 0, 0)
codeBox.BackgroundTransparency = 1
codeBox.Text = ""
codeBox.PlaceholderText = "-- Paste your Lua script here..."
codeBox.TextColor3 = currentTheme.text
codeBox.PlaceholderColor3 = currentTheme.textMuted
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 11
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.TextWrapped = false
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.Parent = codeScroll

codeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local textSize = codeBox.TextBounds
    codeScroll.CanvasSize = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 20)
end)

local contBtn = Instance.new("TextButton")
contBtn.Size = UDim2.new(1, 0, 0, 40)
contBtn.Position = UDim2.new(0, 0, 1, -50)
contBtn.BackgroundColor3 = currentTheme.success
contBtn.Text = getText("confirmAdd")
contBtn.TextColor3 = Color3.new(1, 1, 1)
contBtn.Font = Enum.Font.GothamBold
contBtn.TextSize = 13
contBtn.AutoButtonColor = false
corner(contBtn, 6)
contBtn.Parent = addContent
buttonRefs.contBtn = contBtn

local closeConfirmGui = Instance.new("ScreenGui")
closeConfirmGui.Name = "GlebHubCloseConfirm"
closeConfirmGui.ResetOnSpawn = false
closeConfirmGui.Enabled = false
closeConfirmGui.DisplayOrder = 95
closeConfirmGui.Parent = playerGui

local closeOverlay = Instance.new("Frame")
closeOverlay.Size = UDim2.new(1, 0, 1, 0)
closeOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
closeOverlay.BackgroundTransparency = 0.5
closeOverlay.Parent = closeConfirmGui

local closeFrame = Instance.new("Frame")
closeFrame.Size = UDim2.new(0, 260, 0, 120)
closeFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
closeFrame.BackgroundColor3 = currentTheme.bg
closeFrame.BorderSizePixel = 0
corner(closeFrame, 8)
closeFrame.Parent = closeOverlay

local closeTitle = Instance.new("TextLabel")
closeTitle.Size = UDim2.new(1, -20, 0, 24)
closeTitle.Position = UDim2.new(0, 10, 0, 10)
closeTitle.BackgroundTransparency = 1
closeTitle.Text = getText("closeConfirm")
closeTitle.TextColor3 = currentTheme.warning
closeTitle.Font = Enum.Font.GothamBold
closeTitle.TextSize = 16
closeTitle.Parent = closeFrame

local closeWarn = Instance.new("TextLabel")
closeWarn.Size = UDim2.new(1, -20, 0, 30)
closeWarn.Position = UDim2.new(0, 10, 0, 38)
closeWarn.BackgroundTransparency = 1
closeWarn.Text = getText("closeWarning")
closeWarn.TextColor3 = currentTheme.textMuted
closeWarn.Font = Enum.Font.Gotham
closeWarn.TextSize = 12
closeWarn.TextWrapped = true
closeWarn.Parent = closeFrame

local closeDiscard = Instance.new("TextButton")
closeDiscard.Size = UDim2.new(0, 110, 0, 32)
closeDiscard.Position = UDim2.new(0, 10, 1, -42)
closeDiscard.BackgroundColor3 = currentTheme.elevated
closeDiscard.Text = getText("discard")
closeDiscard.TextColor3 = currentTheme.text
closeDiscard.Font = Enum.Font.GothamMedium
closeDiscard.TextSize = 12
closeDiscard.AutoButtonColor = false
corner(closeDiscard, 6)
closeDiscard.Parent = closeFrame
buttonRefs.closeDiscard = closeDiscard

local closeSave = Instance.new("TextButton")
closeSave.Size = UDim2.new(0, 110, 0, 32)
closeSave.Position = UDim2.new(1, -120, 1, -42)
closeSave.BackgroundColor3 = currentTheme.success
closeSave.Text = getText("save")
closeSave.TextColor3 = Color3.new(1, 1, 1)
closeSave.Font = Enum.Font.GothamMedium
closeSave.TextSize = 12
closeSave.AutoButtonColor = false
corner(closeSave, 6)
closeSave.Parent = closeFrame
buttonRefs.closeSave = closeSave

local langGui = Instance.new("ScreenGui")
langGui.Name = "GlebHubLangSelect"
langGui.ResetOnSpawn = false
langGui.Enabled = false
langGui.DisplayOrder = 210
langGui.Parent = playerGui

local langOverlay = Instance.new("Frame")
langOverlay.Size = UDim2.new(1, 0, 1, 0)
langOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
langOverlay.BackgroundTransparency = 0.5
langOverlay.Parent = langGui

local langFrame = Instance.new("Frame")
langFrame.Size = UDim2.new(0, 240, 0, 140)
langFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
langFrame.BackgroundColor3 = currentTheme.bg
langFrame.BorderSizePixel = 0
corner(langFrame, 8)
langFrame.Parent = langOverlay

local langTitle = Instance.new("TextLabel")
langTitle.Size = UDim2.new(1, -20, 0, 28)
langTitle.Position = UDim2.new(0, 10, 0, 10)
langTitle.BackgroundTransparency = 1
langTitle.Text = getText("selectLang")
langTitle.TextColor3 = currentTheme.accent
langTitle.Font = Enum.Font.GothamBold
langTitle.TextSize = 16
langTitle.Parent = langFrame

local engBtn = Instance.new("TextButton")
engBtn.Size = UDim2.new(0, 100, 0, 44)
engBtn.Position = UDim2.new(0, 14, 0, 52)
engBtn.BackgroundColor3 = currentTheme.accent
engBtn.Text = getText("langENG")
engBtn.TextColor3 = Color3.new(1, 1, 1)
engBtn.Font = Enum.Font.GothamBold
engBtn.TextSize = 16
engBtn.AutoButtonColor = false
corner(engBtn, 6)
engBtn.Parent = langFrame

local ruBtn = Instance.new("TextButton")
ruBtn.Size = UDim2.new(0, 100, 0, 44)
ruBtn.Position = UDim2.new(1, -114, 0, 52)
ruBtn.BackgroundColor3 = currentTheme.elevated
ruBtn.Text = getText("langRU")
ruBtn.TextColor3 = currentTheme.text
ruBtn.Font = Enum.Font.GothamBold
ruBtn.TextSize = 16
ruBtn.AutoButtonColor = false
corner(ruBtn, 6)
stroke(ruBtn)
ruBtn.Parent = langFrame

local function setupHover(btn, isElevated, isSuccess, isAccent)
    btn.MouseEnter:Connect(function()
        if isSuccess then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(80, 200, 110)}, 0.15)
        elseif isAccent then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(120, 130, 255)}, 0.15)
        else
            tween(btn, {BackgroundColor3 = currentTheme.hover}, 0.15)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if isSuccess then
            tween(btn, {BackgroundColor3 = currentTheme.success}, 0.15)
        elseif isAccent then
            tween(btn, {BackgroundColor3 = currentTheme.accent}, 0.15)
        else
            tween(btn, {BackgroundColor3 = currentTheme.elevated}, 0.15)
        end
    end)
end

setupHover(themeBtn, true, false, false)
setupHover(sortBtn, true, false, false)
setupHover(langBtn, true, false, false)
setupHover(prevBtn, true, false, false)
setupHover(nextBtn, true, false, false)
setupHover(addBtn, false, true, false)
setupHover(contBtn, false, true, false)
setupHover(engBtn, false, false, true)
setupHover(ruBtn, true, false, false)
setupHover(closeSave, false, true, false)
setupHover(closeDiscard, true, false, false)

local function applyTheme()
    currentTheme = State.isDark and THEMES.dark or THEMES.light
    
    mainFrame.BackgroundColor3 = currentTheme.bg
    titleBarFrame.BackgroundColor3 = currentTheme.surface
    titleBarFix.BackgroundColor3 = currentTheme.surface
    titleLabel.TextColor3 = currentTheme.text
    
    themeBtn.BackgroundColor3 = currentTheme.elevated
    themeBtn.TextColor3 = currentTheme.text
    themeBtn.Text = State.isDark and getText("themeDark") or getText("themeLight")
    
    sortBtn.BackgroundColor3 = currentTheme.elevated
    sortBtn.TextColor3 = currentTheme.text
    
    langBtn.BackgroundColor3 = currentTheme.elevated
    langBtn.TextColor3 = currentTheme.accent
    
    for _, btn in ipairs({themeBtn, sortBtn, langBtn}) do
        local s = btn:FindFirstChildOfClass("UIStroke")
        if s then 
            if btn == langBtn then
                s.Color = currentTheme.accent
            else
                s.Color = currentTheme.border
            end
        end
    end
    
    minBtn.BackgroundColor3 = currentTheme.warning
    closeBtn.BackgroundColor3 = currentTheme.danger
    
    scroll.ScrollBarImageColor3 = currentTheme.border
    
    addBtn.BackgroundColor3 = currentTheme.success
    
    prevBtn.BackgroundColor3 = currentTheme.elevated
    prevBtn.TextColor3 = currentTheme.text
    nextBtn.BackgroundColor3 = currentTheme.elevated
    nextBtn.TextColor3 = currentTheme.text
    pageLabel.TextColor3 = currentTheme.textMuted
    
    miniBtn.BackgroundColor3 = currentTheme.accent
    
    delFrame.BackgroundColor3 = currentTheme.bg
    delTitle.TextColor3 = currentTheme.danger
    delWarn.TextColor3 = currentTheme.textMuted
    delCancel.BackgroundColor3 = currentTheme.elevated
    delCancel.TextColor3 = currentTheme.text
    
    addFrame.BackgroundColor3 = currentTheme.bg
    addTitleBar.BackgroundColor3 = currentTheme.surface
    addTitleFix.BackgroundColor3 = currentTheme.surface
    addTitle.TextColor3 = currentTheme.success
    nameBox.BackgroundColor3 = currentTheme.surface
    nameBox.TextColor3 = currentTheme.text
    nameBox.PlaceholderColor3 = currentTheme.textMuted
    codeContainer.BackgroundColor3 = currentTheme.surface
    codeBox.TextColor3 = currentTheme.text
    codeBox.PlaceholderColor3 = currentTheme.textMuted
    codeScroll.ScrollBarImageColor3 = currentTheme.border
    contBtn.BackgroundColor3 = currentTheme.success
    
    closeFrame.BackgroundColor3 = currentTheme.bg
    closeTitle.TextColor3 = currentTheme.warning
    closeWarn.TextColor3 = currentTheme.textMuted
    closeDiscard.BackgroundColor3 = currentTheme.elevated
    closeDiscard.TextColor3 = currentTheme.text
    
    langFrame.BackgroundColor3 = currentTheme.bg
    langTitle.TextColor3 = currentTheme.accent
    engBtn.BackgroundColor3 = currentTheme.accent
    ruBtn.BackgroundColor3 = currentTheme.elevated
    ruBtn.TextColor3 = currentTheme.text
    
    for _, obj in ipairs({prevBtn, nextBtn, nameBox, codeContainer, ruBtn, closeDiscard}) do
        local s = obj:FindFirstChildOfClass("UIStroke")
        if s then s.Color = currentTheme.border end
    end
    
    updateGrid()
end

local function createCard(data)
    local card = Instance.new("Frame")
    card.Name = data.id
    card.Size = UDim2.new(1, 0, 0, CONFIG.CARD_HEIGHT)
    card.BackgroundColor3 = currentTheme.surface
    card.BorderSizePixel = 0
    corner(card, 6)
    stroke(card)
    
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -50, 0, 16)
    name.Position = UDim2.new(0, 10, 0, 6)
    name.BackgroundTransparency = 1
    name.Text = data.name
    name.TextColor3 = currentTheme.text
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = card
    
    local date = Instance.new("TextLabel")
    date.Size = UDim2.new(1, -50, 0, 14)
    date.Position = UDim2.new(0, 10, 0, 24)
    date.BackgroundTransparency = 1
    date.Text = getText("added") .. " " .. formatDate(data.addedAt)
    date.TextColor3 = currentTheme.textMuted
    date.Font = Enum.Font.Gotham
    date.TextSize = 9
    date.TextXAlignment = Enum.TextXAlignment.Left
    date.Parent = card
    
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, -36, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = card
    
    local del = Instance.new("TextButton")
    del.Size = UDim2.new(0, 20, 0, 20)
    del.Position = UDim2.new(1, -26, 0.5, -10)
    del.BackgroundColor3 = currentTheme.danger
    del.Text = "x"
    del.TextColor3 = Color3.new(1, 1, 1)
    del.Font = Enum.Font.GothamBold
    del.TextSize = 10
    del.AutoButtonColor = false
    corner(del, 4)
    del.Parent = card
    
    card.MouseEnter:Connect(function()
        tween(card, {BackgroundColor3 = currentTheme.elevated}, 0.15)
    end)
    card.MouseLeave:Connect(function()
        tween(card, {BackgroundColor3 = currentTheme.surface}, 0.15)
    end)
    
    click.MouseButton1Click:Connect(function()
        print("Executing: " .. data.name)
        local success, err = pcall(function()
            loadstring(game:HttpGet(data.url))()
        end)
        if not success then warn("Error: " .. tostring(err)) end
    end)
    
    del.MouseButton1Click:Connect(function()
        delGui.Enabled = true
        
        local c1, c2
        c1 = delCancel.MouseButton1Click:Connect(function()
            delGui.Enabled = false
            c1:Disconnect()
            if c2 then c2:Disconnect() end
        end)
        
        c2 = delConfirm.MouseButton1Click:Connect(function()
            for i, s in ipairs(State.scripts) do
                if s.id == data.id then
                    table.remove(State.scripts, i)
                    break
                end
            end
            updateGrid()
            delGui.Enabled = false
            c1:Disconnect()
            c2:Disconnect()
        end)
    end)
    
    return card
end

function updateGrid()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local sorted = {}
    for _, s in ipairs(State.scripts) do table.insert(sorted, s) end
    
    if State.currentSort == "az" then
        table.sort(sorted, function(a, b) return a.name < b.name end)
    elseif State.currentSort == "za" then
        table.sort(sorted, function(a, b) return a.name > b.name end)
    elseif State.currentSort == "newest" then
        table.sort(sorted, function(a, b) return a.addedAt > b.addedAt end)
    elseif State.currentSort == "oldest" then
        table.sort(sorted, function(a, b) return a.addedAt < b.addedAt end)
    end
    
    local total = #sorted
    local pages = math.max(1, math.ceil(total / CONFIG.ITEMS_PER_PAGE))
    
    if State.currentPage > pages then State.currentPage = pages end
    if State.currentPage < 1 then State.currentPage = 1 end
    
    local startIdx = (State.currentPage - 1) * CONFIG.ITEMS_PER_PAGE + 1
    local endIdx = math.min(startIdx + CONFIG.ITEMS_PER_PAGE - 1, total)
    
    for i = startIdx, endIdx do
        if sorted[i] then
            local card = createCard(sorted[i])
            card.Parent = scroll
        end
    end
    
    pageLabel.Text = State.currentPage .. " / " .. pages
    prevBtn.Visible = State.currentPage > 1
    nextBtn.Visible = State.currentPage < pages
    
    wait()
    local contentSize = grid.AbsoluteContentSize
    tween(scroll, {CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 6)}, 0.2)
end

local function refreshAllText()
    titleLabel.Text = getText("title")
    themeBtn.Text = State.isDark and getText("themeDark") or getText("themeLight")
    sortBtn.Text = getSortText(State.currentSort)
    langBtn.Text = getText(State.currentLang == "en" and "langENG" or "langRU")
    minBtn.Text = getText("minimize")
    closeBtn.Text = getText("close")
    
    addBtn.Text = getText("addScript")
    prevBtn.Text = getText("prev")
    nextBtn.Text = getText("next")
    
    addTitle.Text = getText("addScriptTitle")
    nameLabel.Text = getText("scriptName")
    codeLabel.Text = getText("scriptCode")
    contBtn.Text = getText("confirmAdd")
    nameBox.PlaceholderText = State.currentLang == "en" and "Enter script name..." or "Введите название..."
    codeBox.PlaceholderText = State.currentLang == "en" and "-- Paste your Lua script here..." or "-- Вставьте Lua скрипт здесь..."
    
    delTitle.Text = getText("deleteConfirm")
    delWarn.Text = getText("deleteWarning")
    delCancel.Text = getText("cancel")
    delConfirm.Text = getText("delete")
    
    closeTitle.Text = getText("closeConfirm")
    closeWarn.Text = getText("closeWarning")
    closeDiscard.Text = getText("discard")
    closeSave.Text = getText("save")
    
    langTitle.Text = getText("selectLang")
    engBtn.Text = getText("langENG")
    ruBtn.Text = getText("langRU")
    
    updateGrid()
end

local dragging = false
local dragStart, startPos

titleBarFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBarFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local addDragging = false
local addDragStart, addStartPos

addTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        addDragging = true
        addDragStart = input.Position
        addStartPos = addFrame.Position
    end
end)

addTitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        addDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if addDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - addDragStart
        addFrame.Position = UDim2.new(addStartPos.X.Scale, addStartPos.X.Offset + delta.X, addStartPos.Y.Scale, addStartPos.Y.Offset + delta.Y)
    end
end)

local miniDragging = false

miniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        dragStart = input.Position
        startPos = miniBtn.Position
    end
end)

miniBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
        if (input.Position - dragStart).Magnitude < 5 then
            miniGui.Enabled = false
            mainGui.Enabled = true
            State.isMinimized = false
            tween(mainFrame, {Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT), Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)}, 0.3, Enum.EasingStyle.Back)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        miniBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function cleanup()
    _G.GlebHubLoaded = nil
end

closeBtn.MouseButton1Click:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
        cleanup()
        mainGui:Destroy()
        miniGui:Destroy()
        delGui:Destroy()
        addGui:Destroy()
        langGui:Destroy()
        closeConfirmGui:Destroy()
    end)
end)

minBtn.MouseButton1Click:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
        mainGui.Enabled = false
        miniGui.Enabled = true
    end)
end)

prevBtn.MouseButton1Click:Connect(function()
    if State.currentPage > 1 then
        State.currentPage = State.currentPage - 1
        updateGrid()
    end
end)

nextBtn.MouseButton1Click:Connect(function()
    local pages = math.ceil(#State.scripts / CONFIG.ITEMS_PER_PAGE)
    if State.currentPage < pages then
        State.currentPage = State.currentPage + 1
        updateGrid()
    end
end)

themeBtn.MouseButton1Click:Connect(function()
    State.isDark = not State.isDark
    applyTheme()
end)

langBtn.MouseButton1Click:Connect(function()
    State.currentLang = State.currentLang == "en" and "ru" or "en"
    refreshAllText()
end)

sortBtn.MouseButton1Click:Connect(function()
    local idx = 1
    for i, v in ipairs(sortCycle) do if v == State.currentSort then idx = i; break end end
    idx = idx % #sortCycle + 1
    State.currentSort = sortCycle[idx]
    State.currentPage = 1
    
    sortBtn.Text = getSortText(State.currentSort)
    updateGrid()
end)

addBtn.MouseButton1Click:Connect(function()
    nameBox.Text = ""
    codeBox.Text = ""
    codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    addGui.Enabled = true
end)

addCloseBtn.MouseButton1Click:Connect(function()
    if nameBox.Text ~= "" or codeBox.Text ~= "" then
        closeConfirmGui.Enabled = true
    else
        addGui.Enabled = false
    end
end)

closeDiscard.MouseButton1Click:Connect(function()
    closeConfirmGui.Enabled = false
    addGui.Enabled = false
    nameBox.Text = ""
    codeBox.Text = ""
end)

closeSave.MouseButton1Click:Connect(function()
    closeConfirmGui.Enabled = false
    if nameBox.Text ~= "" and codeBox.Text ~= "" then
        addGui.Enabled = false
        langGui.Enabled = true
    end
end)

contBtn.MouseButton1Click:Connect(function()
    if nameBox.Text == "" or codeBox.Text == "" then return end
    addGui.Enabled = false
    langGui.Enabled = true
end)

local function finalizeAdd(lang)
    local newScript = {
        id = HttpService:GenerateGUID(false),
        name = nameBox.Text,
        code = codeBox.Text,
        addedAt = os.time()
    }
    table.insert(State.scripts, newScript)
    
    State.currentLang = lang
    langGui.Enabled = false
    nameBox.Text = ""
    codeBox.Text = ""
    
    refreshAllText()
    updateGrid()
end

engBtn.MouseButton1Click:Connect(function() finalizeAdd("en") end)
ruBtn.MouseButton1Click:Connect(function() finalizeAdd("ru") end)

updateGrid()

mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
tween(mainFrame, {Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT), Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)}, 0.4, Enum.EasingStyle.Back)

print("GLEB HUB loaded")
