--[[
    VodkaHub - Ultimate FPS Combat & Visuals Suite
    Pixel-perfect reproduction of VodkaHub UI
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera", 5) or Workspace.CurrentCamera

-- Clean up any existing instances
if _G.VodkaHubCleanup and type(_G.VodkaHubCleanup) == "function" then
    pcall(_G.VodkaHubCleanup)
end

-- Global State with Independent Sections
local S = {
    -- Section 1: AIMBOT (Independent)
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Mode = "Hold", -- "Hold", "Target", "Always"
        Type = "Camera", -- "Camera", "Mouse"
        TargetPart = "Head", -- "Head", "UpperTorso", "HumanoidRootPart", "Closest", "Random"
        StickyAim = false,
        HealthCheck = true,
        TeamCheck = false,
        WallCheck = false,
        FOVCircle = false,
        LockFOVToCenter = false,
        MaxDistance = 1500,
        FOVRadius = 100,
        Smoothness = 0.15,
    },

    -- Section 2: SILENT AIM (Independent)
    SilentAim = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Mode = "Hold", -- "Hold", "Always", "Toggle"
        TargetPart = "Head", -- "Head", "UpperTorso", "HumanoidRootPart", "Closest", "Random"
        StickyAim = false,
        HealthCheck = true,
        TeamCheck = false,
        WallCheck = false,
        FOVCircle = false,
        LockFOVToCenter = false,
        MaxDistance = 1500,
        FOVRadius = 120,
        HitChance = 100,
    },

    -- Section 3: TRIGGERBOT (New Category)
    TriggerBot = {
        Enabled = false,
        Key = Enum.KeyCode.F,
        VisibleCheck = true,
        TeamCheck = true,
        Delay = 25,
        MaxDistance = 1000,
    },

    -- Section 4: AIMBOT TARGET / HITBOX (Independent)
    AimbotTarget = {
        HitboxExpander = false,
        TargetPart = "HitboxHead",
        TeamCheck = false,
        WallCheck = false,
        FOVCircle = false,
        LockFOVToCenter = false,
        FOVRadius = 150,
        HitboxSize = 10,
        HitboxTransparency = 0.4,
    },

    -- Visuals: Main ESP Settings
    ESP = {
        Enabled = false,
        Key = nil,
        TeamCheck = false,
        VisibleCheck = false,
        TeamBasedColor = false,
        TextGradient = true,
        TextBackground = false,
        Outline = true,
        Glow = false,
        SelfESP = false,
        SizingType = "Bounding", -- "Bounding", "Corner", "Dynamic"
        RenderDistance = 3000,
        VisibleColor = Color3.fromRGB(100, 180, 255),
        HiddenColor = Color3.fromRGB(255, 40, 40),
    },

    -- Visuals: Box ESP
    BoxESP = {
        Enabled = false,
        FillBox = false,
        BoxType = "2D", -- "2D", "3D", "Corner"
        Outline = true,
        TeamColors = false,
        Color = Color3.fromRGB(255, 255, 255),
        FillColor = Color3.fromRGB(123, 97, 255),
    },

    -- Visuals: Name
    NameESP = {
        Enabled = false,
        Type = "Name", -- "Name", "Display Name", "Both"
        Outline = true,
        TeamColors = false,
        Color = Color3.fromRGB(255, 255, 255),
        HealthBar = false,
        Distance = false,
    },

    -- Visuals: Indicators (Subtabs: Indicators | OOF Arrow | Radar)
    Indicators = {
        Distance = false,
        DistanceColor = Color3.fromRGB(255, 255, 255),
        EquippedItem = false,
        EquippedColor = Color3.fromRGB(255, 255, 255),
        Skeleton = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        HeadDot = false,
        HeadDotColor = Color3.fromRGB(255, 255, 255),
        HeadDotGlow = false,
        ProfilePicture = false,
        -- OOF Arrow
        OOFArrow = false,
        OOFRadius = 150,
        OOFSize = 14,
        -- Radar
        Radar = false,
        RadarRange = 250,
        RadarSize = 120,
    },

    -- Visuals: Health
    Health = {
        HealthBar = false,
        HealthBased = true,
        HealthText = false,
        TextPos = "Above Name", -- "Above Name", "Below Name", "Side"
        Color = Color3.fromRGB(0, 255, 40),
    },

    -- Visuals: Chams & Glow
    Chams = {
        Mode = "Default", -- "Default", "Wireframe", "Ghost", "Pulsing"
        Enabled = false,
        Filled = true,
        Glow = true,
        Outline = true,
        SelfESP = false,
        TeamColors = false,
        RenderingType = "Static", -- "Static", "AlwaysOnTop", "Occluded"
        Color = Color3.fromRGB(80, 80, 100),
        VisibleColor = Color3.fromRGB(255, 255, 255),
    },

    -- Visuals: Tracers
    Tracers = {
        Enabled = false,
        TracersOrigin = "Top", -- "Top", "Center", "Bottom", "Mouse"
        TeamColors = false,
        MaxDistance = 3000,
        Color = Color3.fromRGB(255, 255, 255),
    },

    -- Player tab
    WalkSpeedToggle = false,
    WalkSpeed = 16,
    JumpPowerToggle = false,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 60,

    -- UI Settings tab
    ToggleKey = Enum.KeyCode.RightControl,
    Visible = true
}
_G.VodkaState = S

-- Independent Drawing API FOV Circles
local aimbotFovDrawing = nil
local silentFovDrawing = nil
local targetFovDrawing = nil

pcall(function()
    if Drawing and type(Drawing.new) == "function" then
        -- Aimbot FOV (Purple)
        aimbotFovDrawing = Drawing.new("Circle")
        aimbotFovDrawing.Thickness = 1.2
        aimbotFovDrawing.NumSides = 64
        aimbotFovDrawing.Color = Color3.fromRGB(123, 97, 255)
        aimbotFovDrawing.Transparency = 0.85
        aimbotFovDrawing.Filled = false
        aimbotFovDrawing.Visible = false

        -- Silent Aim FOV (Cyan)
        silentFovDrawing = Drawing.new("Circle")
        silentFovDrawing.Thickness = 1.2
        silentFovDrawing.NumSides = 64
        silentFovDrawing.Color = Color3.fromRGB(0, 225, 255)
        silentFovDrawing.Transparency = 0.85
        silentFovDrawing.Filled = false
        silentFovDrawing.Visible = false

        -- Aimbot Target / Hitbox FOV (Coral / Red)
        targetFovDrawing = Drawing.new("Circle")
        targetFovDrawing.Thickness = 1.2
        targetFovDrawing.NumSides = 64
        targetFovDrawing.Color = Color3.fromRGB(255, 95, 80)
        targetFovDrawing.Transparency = 0.85
        targetFovDrawing.Filled = false
        targetFovDrawing.Visible = false
    end
end)

---------------------------------------------------------------------
-- UI CREATION
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VodkaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = CoreGui:FindFirstChild("RobloxGui") or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 500)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 7)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.2
mainStroke.Color = Color3.fromRGB(32, 32, 38)
mainStroke.Parent = MainFrame

-- Loading Splash Notification
local LoadFrame = Instance.new("Frame")
LoadFrame.Name = "VodkaLoading"
LoadFrame.Size = UDim2.new(0, 320, 0, 85)
LoadFrame.Position = UDim2.new(0.5, -160, 0.45, -42)
LoadFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
LoadFrame.BorderSizePixel = 0
LoadFrame.ZIndex = 100
LoadFrame.Parent = ScreenGui

local loadCorner = Instance.new("UICorner")
loadCorner.CornerRadius = UDim.new(0, 8)
loadCorner.Parent = LoadFrame

local loadStroke = Instance.new("UIStroke")
loadStroke.Thickness = 1.2
loadStroke.Color = Color3.fromRGB(123, 97, 255)
loadStroke.Parent = LoadFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -20, 0, 22)
titleLbl.Position = UDim2.new(0, 14, 0, 10)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.Text = "VodkaHub • Initializing Suite"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 101
titleLbl.Parent = LoadFrame

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -20, 0, 18)
statusLbl.Position = UDim2.new(0, 14, 0, 34)
statusLbl.BackgroundTransparency = 1
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.Text = "Synchronizing combat suite..."
statusLbl.TextColor3 = Color3.fromRGB(160, 160, 180)
statusLbl.TextSize = 11
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 101
statusLbl.Parent = LoadFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -28, 0, 5)
barBg.Position = UDim2.new(0, 14, 0, 60)
barBg.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
barBg.BorderSizePixel = 0
barBg.ZIndex = 101
barBg.Parent = LoadFrame

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
barFill.BorderSizePixel = 0
barFill.ZIndex = 102
barFill.Parent = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

task.spawn(function()
    statusLbl.Text = "Verifying game services & character..."
    TweenService:Create(barFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = UDim2.new(0.35, 0, 1, 0) }):Play()
    task.wait(0.6)

    statusLbl.Text = "Initializing Drawing engine & ESP structures..."
    TweenService:Create(barFill, TweenInfo.new(0.7, Enum.EasingStyle.Quad), { Size = UDim2.new(0.75, 0, 1, 0) }):Play()
    task.wait(0.7)

    statusLbl.Text = "Stabilizing combat hooks & visual caches..."
    TweenService:Create(barFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = UDim2.new(1, 0, 1, 0) }):Play()
    task.wait(0.6)

    statusLbl.Text = "Loaded successfully!"
    task.wait(0.25)

    TweenService:Create(LoadFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(titleLbl, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(statusLbl, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(barBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(loadStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
    task.wait(0.3)
    pcall(function() LoadFrame:Destroy() end)

    MainFrame.Visible = true
end)

---------------------------------------------------------------------
-- TOP BAR (Header)
---------------------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

-- Top Left: Logo & Title
local LogoIcon = Instance.new("TextLabel")
LogoIcon.Name = "LogoIcon"
LogoIcon.Size = UDim2.new(0, 24, 0, 24)
LogoIcon.Position = UDim2.new(0, 14, 0.5, -12)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "🎨"
LogoIcon.TextSize = 16
LogoIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 100, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "VodkaHub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Top Middle: Search Bar
local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchContainer"
SearchContainer.Size = UDim2.new(0, 360, 0, 28)
SearchContainer.Position = UDim2.new(0.5, -180, 0.5, -14)
SearchContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = TopBar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = SearchContainer

local searchStroke = Instance.new("UIStroke")
searchStroke.Thickness = 1
searchStroke.Color = Color3.fromRGB(34, 34, 40)
searchStroke.Parent = SearchContainer

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "SearchIcon"
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://6031154871"
SearchIcon.ImageColor3 = Color3.fromRGB(110, 110, 125)
SearchIcon.Parent = SearchContainer

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -36, 1, 0)
SearchBox.Position = UDim2.new(0, 30, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.PlaceholderText = "Search"
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 240)
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchContainer

-- Top Right: Drag / Move icon
local MoveIcon = Instance.new("ImageLabel")
MoveIcon.Name = "MoveIcon"
MoveIcon.Size = UDim2.new(0, 18, 0, 18)
MoveIcon.Position = UDim2.new(1, -32, 0.5, -9)
MoveIcon.BackgroundTransparency = 1
MoveIcon.Image = "rbxassetid://6035047391"
MoveIcon.ImageColor3 = Color3.fromRGB(90, 90, 105)
MoveIcon.Parent = TopBar

-- Horizontal Divider under TopBar
local TopDivider = Instance.new("Frame")
TopDivider.Name = "TopDivider"
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.Position = UDim2.new(0, 0, 0, 44)
TopDivider.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TopDivider.BorderSizePixel = 0
TopDivider.Parent = MainFrame

---------------------------------------------------------------------
-- FOOTER
---------------------------------------------------------------------
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterText = Instance.new("TextLabel")
FooterText.Name = "FooterText"
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.BackgroundTransparency = 1
FooterText.Font = Enum.Font.GothamMedium
FooterText.Text = "discord.gg/dJJ3psbAxw"
FooterText.TextColor3 = Color3.fromRGB(85, 85, 98)
FooterText.TextSize = 11
FooterText.Parent = Footer

local ResizeGrip = Instance.new("ImageLabel")
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Size = UDim2.new(0, 10, 0, 10)
ResizeGrip.Position = UDim2.new(1, -14, 1, -14)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Image = "rbxassetid://6031302932"
ResizeGrip.ImageColor3 = Color3.fromRGB(80, 80, 95)
ResizeGrip.Parent = Footer

---------------------------------------------------------------------
-- BODY (Sidebar + Content)
---------------------------------------------------------------------
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, 0, 1, -69) -- 480 - 45 (top) - 24 (footer) = 411
Body.Position = UDim2.new(0, 0, 0, 45)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 135, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 3)
sideLayout.Parent = Sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 10)
sidePad.PaddingLeft = UDim.new(0, 10)
sidePad.PaddingRight = UDim.new(0, 10)
sidePad.Parent = Sidebar

-- Vertical Divider between Sidebar and Content
local VertDivider = Instance.new("Frame")
VertDivider.Name = "VertDivider"
VertDivider.Size = UDim2.new(0, 1, 1, 0)
VertDivider.Position = UDim2.new(0, 135, 0, 0)
VertDivider.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
VertDivider.BorderSizePixel = 0
VertDivider.Parent = Body

-- Content Container
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -145, 1, -10)
Content.Position = UDim2.new(0, 142, 0, 5)
Content.BackgroundTransparency = 1
Content.Parent = Body

---------------------------------------------------------------------
-- TAB SWITCHING & BUILDER HELPERS
---------------------------------------------------------------------
local TabButtons = {}
local TabPages = {}
local activeTab = nil

local function switchTab(tabName)
    activeTab = tabName
    for name, btn in pairs(TabButtons) do
        local isTarget = (name == tabName)
        local icon = btn:FindFirstChild("Icon")
        local title = btn:FindFirstChild("Title")

        if isTarget then
            btn.BackgroundTransparency = 0.88
            btn.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
            if icon then icon.ImageColor3 = Color3.fromRGB(138, 115, 255) end
            if title then title.TextColor3 = Color3.fromRGB(255, 255, 255) end
        else
            btn.BackgroundTransparency = 1
            if icon then icon.ImageColor3 = Color3.fromRGB(110, 110, 125) end
            if title then title.TextColor3 = Color3.fromRGB(135, 135, 150) end
        end
    end

    for name, page in pairs(TabPages) do
        page.Visible = (name == tabName)
    end
end

local function createSidebarTab(tabName, iconAsset, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tabName
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = layoutOrder
    btn.Parent = Sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 10, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconAsset
    icon.ImageColor3 = Color3.fromRGB(110, 110, 125)
    icon.Parent = btn

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -36, 1, 0)
    title.Position = UDim2.new(0, 34, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamMedium
    title.Text = tabName
    title.TextColor3 = Color3.fromRGB(135, 135, 150)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = btn

    TabButtons[tabName] = btn

    btn.Activated:Connect(function()
        switchTab(tabName)
    end)

    -- Create matching Page Frame
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. tabName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content

    local grid = Instance.new("UIListLayout")
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Padding = UDim.new(0, 10)
    grid.Parent = page

    TabPages[tabName] = page
    return page
end

---------------------------------------------------------------------
-- CARDS & CONTROL GENERATORS
---------------------------------------------------------------------
local function createCard(page, title, widthScale, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title
    card.Size = UDim2.new(widthScale or 0.49, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder or 1
    card.Parent = page

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = card

    local cs = Instance.new("UIStroke")
    cs.Thickness = 1
    cs.Color = Color3.fromRGB(28, 28, 34)
    cs.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 8)
    cardLayout.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 10)
    cardPad.PaddingBottom = UDim.new(0, 12)
    cardPad.PaddingLeft = UDim.new(0, 10)
    cardPad.PaddingRight = UDim.new(0, 10)
    cardPad.Parent = card

    -- Header Title
    local head = Instance.new("TextLabel")
    head.Name = "CardHeader"
    head.Size = UDim2.new(1, 0, 0, 20)
    head.BackgroundTransparency = 1
    head.Font = Enum.Font.GothamBold
    head.Text = title
    head.TextColor3 = Color3.fromRGB(225, 225, 235)
    head.TextSize = 13
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.LayoutOrder = 0
    head.Parent = card

    return card
end

-- Card with Subtabs Bar across the top (Matching Reference Style: e.g. Aimbot | Prediction | Smoothness | FOV)
local function createCardWithSubtabs(page, tabsList, defaultTab, widthScale, layoutOrder)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. tabsList[1]
    card.Size = UDim2.new(widthScale or 0.49, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder or 1
    card.Parent = page

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = card

    local cs = Instance.new("UIStroke")
    cs.Thickness = 1
    cs.Color = Color3.fromRGB(28, 28, 34)
    cs.Parent = card

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 8)
    cardLayout.Parent = card

    local cardPad = Instance.new("UIPadding")
    cardPad.PaddingTop = UDim.new(0, 10)
    cardPad.PaddingBottom = UDim.new(0, 12)
    cardPad.PaddingLeft = UDim.new(0, 10)
    cardPad.PaddingRight = UDim.new(0, 10)
    cardPad.Parent = card

    -- Sub-tabs Bar across top of card (like reference image)
    local tabHeader = Instance.new("Frame")
    tabHeader.Name = "SubtabHeader"
    tabHeader.Size = UDim2.new(1, 0, 0, 24)
    tabHeader.BackgroundTransparency = 1
    tabHeader.LayoutOrder = 0
    tabHeader.Parent = card

    local thLayout = Instance.new("UIListLayout")
    thLayout.FillDirection = Enum.FillDirection.Horizontal
    thLayout.SortOrder = Enum.SortOrder.LayoutOrder
    thLayout.Padding = UDim.new(0, 10)
    thLayout.Parent = tabHeader

    local subtabButtons = {}
    local subtabContainers = {}
    local currentSubtab = defaultTab or tabsList[1]

    local function switchSubtab(tName)
        currentSubtab = tName
        for name, btn in pairs(subtabButtons) do
            local isSel = (name == tName)
            btn.TextColor3 = isSel and Color3.fromRGB(195, 130, 255) or Color3.fromRGB(120, 120, 135)
            btn.Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium
        end
        for name, cont in pairs(subtabContainers) do
            cont.Visible = (name == tName)
        end
    end

    for i, tName in ipairs(tabsList) do
        local btn = Instance.new("TextButton")
        btn.Name = "TabBtn_" .. tName
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.Size = UDim2.new(0, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Font = (tName == currentSubtab) and Enum.Font.GothamBold or Enum.Font.GothamMedium
        btn.Text = tName
        btn.TextColor3 = (tName == currentSubtab) and Color3.fromRGB(195, 130, 255) or Color3.fromRGB(120, 120, 135)
        btn.TextSize = 12
        btn.LayoutOrder = i
        btn.Parent = tabHeader

        btn.MouseEnter:Connect(function()
            if tName ~= currentSubtab then
                btn.TextColor3 = Color3.fromRGB(170, 170, 185)
            end
        end)
        btn.MouseLeave:Connect(function()
            if tName ~= currentSubtab then
                btn.TextColor3 = Color3.fromRGB(120, 120, 135)
            end
        end)

        btn.Activated:Connect(function()
            switchSubtab(tName)
        end)

        subtabButtons[tName] = btn

        local cont = Instance.new("Frame")
        cont.Name = "TabContent_" .. tName
        cont.Size = UDim2.new(1, 0, 0, 0)
        cont.AutomaticSize = Enum.AutomaticSize.Y
        cont.BackgroundTransparency = 1
        cont.Visible = (tName == currentSubtab)
        cont.LayoutOrder = 1
        cont.Parent = card

        local cLayout = Instance.new("UIListLayout")
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cLayout.Padding = UDim.new(0, 8)
        cLayout.Parent = cont

        subtabContainers[tName] = cont
    end

    return card, subtabContainers
end

local function getKeyName(key)
    if not key then return "none" end
    if typeof(key) == "string" then
        if key == "MB4" or key == "MouseBackButton" then return "MB4" end
        if key == "MB5" then return "MB5" end
        return key
    end
    if typeof(key) == "EnumItem" then
        if key == Enum.UserInputType.MouseButton1 then return "LMB" end
        if key == Enum.UserInputType.MouseButton2 then return "RMB" end
        if key == Enum.UserInputType.MouseButton3 then return "MMB" end
        if key == Enum.KeyCode.MouseBackButton then return "MB4" end
        if key.EnumType == Enum.KeyCode then
            local str = key.Name
            if str == "MouseBackButton" then return "MB4" end
            str = str:gsub("LeftShift", "LShift"):gsub("RightShift", "RShift")
            str = str:gsub("LeftControl", "LCtrl"):gsub("RightControl", "RCtrl")
            str = str:gsub("LeftAlt", "LAlt"):gsub("RightAlt", "RAlt")
            return str
        end
        return key.Name
    end
    return tostring(key)
end

local switchControllers = {}

-- Pill Switch Toggle with customizable Keybind Picker & Accordion Push-down
local function createSwitchWithKeybind(card, title, defaultVal, defaultKey, onToggle, onKeybind, layoutOrder)
    local closedHeight = 24
    local popupHeight = 142
    local openHeight = closedHeight + popupHeight + 6 -- 172

    local row = Instance.new("Frame")
    row.Name = "SwitchKeybind_" .. title
    row.Size = UDim2.new(1, 0, 0, closedHeight)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.ClipsDescendants = false
    row.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -104, 0, 24)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Keybind Selector Button (fixed Y = 2)
    local currentKey = defaultKey
    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "KeybindBtn"
    keyBtn.Size = UDim2.new(0, 56, 0, 20)
    keyBtn.Position = UDim2.new(1, -98, 0, 2)
    keyBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    keyBtn.BorderSizePixel = 0
    keyBtn.Font = Enum.Font.GothamMedium
    keyBtn.Text = getKeyName(currentKey)
    keyBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    keyBtn.TextSize = 11
    keyBtn.ZIndex = 6
    keyBtn.Parent = row

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(0, 4)
    kc.Parent = keyBtn

    local ks = Instance.new("UIStroke")
    ks.Thickness = 1
    ks.Color = Color3.fromRGB(38, 38, 48)
    ks.Parent = keyBtn

    -- Pill Toggle Switch (fixed Y = 3)
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 36, 0, 18)
    pill.Position = UDim2.new(1, -36, 0, 3)
    pill.BackgroundColor3 = defaultVal and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -104, 0, 24)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 5
    toggleBtn.Parent = row

    local pillBtn = Instance.new("TextButton")
    pillBtn.Size = UDim2.new(0, 36, 0, 18)
    pillBtn.Position = UDim2.new(1, -36, 0, 3)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text = ""
    pillBtn.ZIndex = 5
    pillBtn.Parent = row

    local state = defaultVal or false
    local lastToggle = 0

    local function applyState(newVal, skipCallback)
        state = newVal and true or false
        local targetColor = state and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

        TweenService:Create(pill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = targetColor }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Position = targetPos }):Play()

        if not skipCallback and onToggle then
            onToggle(state)
        end
    end

    local function toggle()
        if os.clock() - lastToggle < 0.08 then return end
        lastToggle = os.clock()
        applyState(not state, false)
    end

    toggleBtn.Activated:Connect(toggle)
    pillBtn.Activated:Connect(toggle)

    local ctrl = {
        Frame = row,
        SetState = applyState,
        GetState = function() return state end
    }
    switchControllers[row] = ctrl

    -- Keybind Selector Accordion List (Spans full row width, pushes down controls below!)
    local popup = Instance.new("Frame")
    popup.Name = "KeybindPopup"
    popup.Size = UDim2.new(1, 0, 0, popupHeight)
    popup.Position = UDim2.new(0, 0, 0, 26)
    popup.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    popup.BorderSizePixel = 0
    popup.ZIndex = 30
    popup.Visible = false
    popup.ClipsDescendants = true
    popup.Parent = row

    local pfc = Instance.new("UICorner")
    pfc.CornerRadius = UDim.new(0, 5)
    pfc.Parent = popup

    local pfs = Instance.new("UIStroke")
    pfs.Thickness = 1
    pfs.Color = Color3.fromRGB(55, 45, 90)
    pfs.Parent = popup

    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 3)
    pLayout.Parent = popup

    local pPad = Instance.new("UIPadding")
    pPad.PaddingTop = UDim.new(0, 4)
    pPad.PaddingBottom = UDim.new(0, 4)
    pPad.PaddingLeft = UDim.new(0, 4)
    pPad.PaddingRight = UDim.new(0, 4)
    pPad.Parent = popup

    local isOpen = false
    local currentTween = nil
    local isBinding = false
    local bindConn = nil

    local function setBindingState(active)
        isBinding = active
        if active then
            keyBtn.Size = UDim2.new(0, 102, 0, 20)
            keyBtn.Position = UDim2.new(1, -144, 0, 2)
            keyBtn.Text = "Presiona tecla..."
            keyBtn.TextColor3 = Color3.fromRGB(160, 130, 255)
            ks.Color = Color3.fromRGB(123, 97, 255)
        else
            keyBtn.Size = UDim2.new(0, 56, 0, 20)
            keyBtn.Position = UDim2.new(1, -98, 0, 2)
            keyBtn.Text = getKeyName(currentKey)
            keyBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
            ks.Color = isOpen and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(38, 38, 48)
            if bindConn then bindConn:Disconnect(); bindConn = nil end
        end
    end

    local function setOpen(val)
        isOpen = val
        if currentTween then currentTween:Cancel() end

        local targetHeight = isOpen and openHeight or closedHeight
        if isOpen then
            popup.Visible = true
            ks.Color = Color3.fromRGB(123, 97, 255)
        else
            ks.Color = Color3.fromRGB(38, 38, 48)
        end

        currentTween = TweenService:Create(row, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        })
        currentTween:Play()

        if not isOpen then
            task.delay(0.18, function()
                if not isOpen then
                    popup.Visible = false
                end
            end)
        end
    end

    local function applyKey(chosen)
        currentKey = chosen
        setBindingState(false)
        setOpen(false)
        if onKeybind then onKeybind(currentKey) end
    end

    -- Option to listen to physical keypress / click
    local listenBtn = Instance.new("TextButton")
    listenBtn.Name = "Opt_Listen"
    listenBtn.Size = UDim2.new(1, 0, 0, 24)
    listenBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 54)
    listenBtn.BorderSizePixel = 0
    listenBtn.Font = Enum.Font.GothamBold
    listenBtn.Text = "  ⌨ Presionar tecla o click..."
    listenBtn.TextColor3 = Color3.fromRGB(190, 170, 255)
    listenBtn.TextSize = 11
    listenBtn.TextXAlignment = Enum.TextXAlignment.Left
    listenBtn.LayoutOrder = 1
    listenBtn.ZIndex = 31
    listenBtn.Parent = popup

    local lbCor = Instance.new("UICorner")
    lbCor.CornerRadius = UDim.new(0, 4)
    lbCor.Parent = listenBtn

    listenBtn.MouseEnter:Connect(function()
        listenBtn.BackgroundColor3 = Color3.fromRGB(52, 42, 78)
    end)
    listenBtn.MouseLeave:Connect(function()
        listenBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 54)
    end)

    listenBtn.Activated:Connect(function()
        setOpen(false)
        if isBinding then return end
        setBindingState(true)

        task.delay(0.12, function()
            bindConn = UserInputService.InputBegan:Connect(function(input, gpe)
                local chosen = nil
                if input.KeyCode == Enum.KeyCode.MouseBackButton then
                    chosen = Enum.KeyCode.MouseBackButton
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    chosen = Enum.UserInputType.MouseButton2
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    chosen = Enum.UserInputType.MouseButton3
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    chosen = Enum.UserInputType.MouseButton1
                elseif input.KeyCode == Enum.KeyCode.Escape then
                    chosen = currentKey
                elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                    chosen = input.KeyCode
                end

                if chosen then
                    applyKey(chosen)
                end
            end)
        end)
    end)

    -- Scrollable Container for Presets
    local scrollList = Instance.new("ScrollingFrame")
    scrollList.Name = "ScrollList"
    scrollList.Size = UDim2.new(1, 0, 0, 108)
    scrollList.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    scrollList.BorderSizePixel = 0
    scrollList.ScrollBarThickness = 3
    scrollList.ScrollBarImageColor3 = Color3.fromRGB(123, 97, 255)
    scrollList.LayoutOrder = 2
    scrollList.ZIndex = 31
    scrollList.Parent = popup

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 4)
    sCor.Parent = scrollList

    local sLayout = Instance.new("UIListLayout")
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Padding = UDim.new(0, 2)
    sLayout.Parent = scrollList

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 2)
    sPad.PaddingBottom = UDim.new(0, 2)
    sPad.PaddingLeft = UDim.new(0, 2)
    sPad.PaddingRight = UDim.new(0, 4)
    sPad.Parent = scrollList

    local function addOption(name, bindVal, order)
        local btn = Instance.new("TextButton")
        btn.Name = "Opt_" .. name
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "  " .. name
        btn.TextColor3 = Color3.fromRGB(205, 200, 230)
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = order
        btn.ZIndex = 32
        btn.Parent = scrollList

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 3)
        bCor.Parent = btn

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            btn.TextColor3 = Color3.fromRGB(205, 200, 230)
        end)

        btn.Activated:Connect(function()
            applyKey(bindVal)
        end)
    end

    addOption("RMB (Click Derecho)", Enum.UserInputType.MouseButton2, 1)
    addOption("MMB (Rueda Mouse)", Enum.UserInputType.MouseButton3, 2)
    addOption("LMB (Click Izquierdo)", Enum.UserInputType.MouseButton1, 3)
    addOption("X", Enum.KeyCode.X, 4)
    addOption("C", Enum.KeyCode.C, 5)
    addOption("V", Enum.KeyCode.V, 6)
    addOption("E", Enum.KeyCode.E, 7)
    addOption("Q", Enum.KeyCode.Q, 8)
    addOption("F", Enum.KeyCode.F, 9)
    addOption("LShift", Enum.KeyCode.LeftShift, 10)
    addOption("LCtrl", Enum.KeyCode.LeftControl, 11)

    scrollList.CanvasSize = UDim2.new(0, 0, 0, 11 * 24 + 4)

    keyBtn.Activated:Connect(function()
        if isBinding then
            setBindingState(false)
            return
        end
        setOpen(not isOpen)
    end)

    return row, ctrl
end

-- Pill Switch Toggle
local function createSwitch(card, title, defaultVal, callback, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "Switch_" .. title
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -44, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 36, 0, 18)
    pill.Position = UDim2.new(1, -36, 0.5, -9)
    pill.BackgroundColor3 = defaultVal and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5
    btn.Parent = row

    local state = defaultVal or false
    local lastToggle = 0

    local function applyState(newVal, skipCallback)
        state = newVal and true or false
        local targetColor = state and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

        TweenService:Create(pill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = targetColor }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Position = targetPos }):Play()

        if not skipCallback and callback then
            callback(state)
        end
    end

    local function toggle()
        if os.clock() - lastToggle < 0.08 then return end
        lastToggle = os.clock()
        applyState(not state, false)
    end

    btn.Activated:Connect(toggle)
    local ctrl = {
        Frame = row,
        SetState = applyState,
        GetState = function() return state end
    }
    switchControllers[row] = ctrl
    return row, ctrl
end

-- Pill Switch Toggle with Color Preview/Picker boxes (Matching reference layout)
local function createSwitchWithColors(card, title, defaultVal, colors, onToggle, onColorClick, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "SwitchColor_" .. title
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.LayoutOrder = layoutOrder or 1
    row.Parent = card

    local numColors = colors and #colors or 0
    local rightOffset = 44 + (numColors * 22)

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -rightOffset, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Color Boxes
    if colors then
        for i, col in ipairs(colors) do
            local xOffset = 38 + ((numColors - i + 1) * 20)
            local cBox = Instance.new("TextButton")
            cBox.Name = "ColorBox_" .. i
            cBox.Size = UDim2.new(0, 16, 0, 16)
            cBox.Position = UDim2.new(1, -xOffset, 0.5, -8)
            cBox.BackgroundColor3 = col
            cBox.BorderSizePixel = 0
            cBox.Text = ""
            cBox.ZIndex = 12
            cBox.AutoButtonColor = false
            cBox.Parent = row

            local cbc = Instance.new("UICorner")
            cbc.CornerRadius = UDim.new(0, 3)
            cbc.Parent = cBox

            local cbs = Instance.new("UIStroke")
            cbs.Thickness = 1
            cbs.Color = Color3.fromRGB(50, 50, 62)
            cbs.Parent = cBox

            local colorPalette = {
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(123, 97, 255),
                Color3.fromRGB(100, 180, 255),
                Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(255, 215, 0),
                Color3.fromRGB(255, 40, 40),
                Color3.fromRGB(255, 100, 180),
                Color3.fromRGB(80, 80, 100)
            }
            local colorIdx = 1
            cBox.Activated:Connect(function()
                colorIdx = (colorIdx % #colorPalette) + 1
                local newCol = colorPalette[colorIdx]
                cBox.BackgroundColor3 = newCol
                if onColorClick then
                    onColorClick(i, newCol)
                end
            end)
        end
    end

    -- Pill Toggle Switch
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 36, 0, 18)
    pill.Position = UDim2.new(1, -36, 0.5, -9)
    pill.BackgroundColor3 = defaultVal and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
    pill.BorderSizePixel = 0
    pill.Parent = row

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = pill

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5
    btn.Parent = row

    local state = defaultVal or false
    local lastToggle = 0

    local function applyState(newVal, skipCallback)
        state = newVal and true or false
        local targetColor = state and Color3.fromRGB(123, 97, 255) or Color3.fromRGB(34, 34, 42)
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

        TweenService:Create(pill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = targetColor }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Position = targetPos }):Play()

        if not skipCallback and onToggle then
            onToggle(state)
        end
    end

    local function toggle()
        if os.clock() - lastToggle < 0.08 then return end
        lastToggle = os.clock()
        applyState(not state, false)
    end

    btn.Activated:Connect(toggle)
    local ctrl = {
        Frame = row,
        SetState = applyState,
        GetState = function() return state end
    }
    switchControllers[row] = ctrl
    return row, ctrl
end

-- Slider Control (shows bar with purple fill, value label e.g. 10/50)
local function createSlider(card, title, minVal, maxVal, defaultVal, isFloat, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. title
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.Parent = card

    -- Label and Value Text
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Title"
    lbl.Size = UDim2.new(0.65, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Name = "Value"
    valLbl.Size = UDim2.new(0.35, 0, 0, 16)
    valLbl.Position = UDim2.new(0.65, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamMedium
    local initStr = isFloat and string.format("%.2f/%d", defaultVal, maxVal) or string.format("%d/%d", defaultVal, maxVal)
    valLbl.Text = initStr
    valLbl.TextColor3 = Color3.fromRGB(145, 145, 160)
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    -- Slider Track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 14)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    track.BorderSizePixel = 0
    track.Parent = container

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 3)
    tc.Parent = track

    local ts = Instance.new("UIStroke")
    ts.Thickness = 1
    ts.Color = Color3.fromRGB(36, 36, 44)
    ts.Parent = track

    local fillPct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(fillPct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 3)
    fc.Parent = fill

    local dragging = false
    local function updateFromInput(input)
        local posX = input.Position.X - track.AbsolutePosition.X
        local pct = math.clamp(posX / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)

        local currentVal = minVal + (maxVal - minVal) * pct
        if isFloat then
            currentVal = math.floor(currentVal * 100) / 100
            valLbl.Text = string.format("%.2f/%d", currentVal, maxVal)
        else
            currentVal = math.floor(currentVal)
            valLbl.Text = string.format("%d/%d", currentVal, maxVal)
        end

        if callback then
            callback(currentVal)
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    return container
end

-- Dropdown Control (Accordion dynamic push-down)
local function createDropdown(card, title, options, defaultOption, callback, layoutOrder)
    local closedHeight = 52
    local listHeight = #options * 26 + 6
    local openHeight = closedHeight + listHeight + 6

    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. title
    container.Size = UDim2.new(1, 0, 0, closedHeight)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 1
    container.ClipsDescendants = false
    container.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Title"
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(1, 0, 0, 28)
    box.Position = UDim2.new(0, 0, 0, 20)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    box.BorderSizePixel = 0
    box.ClipsDescendants = false
    box.Parent = container

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = box

    local bs = Instance.new("UIStroke")
    bs.Thickness = 1
    bs.Color = Color3.fromRGB(36, 36, 44)
    bs.Parent = box

    local selText = Instance.new("TextLabel")
    selText.Name = "SelectedText"
    selText.Size = UDim2.new(1, -30, 1, 0)
    selText.Position = UDim2.new(0, 10, 0, 0)
    selText.BackgroundTransparency = 1
    selText.Font = Enum.Font.GothamMedium
    selText.Text = defaultOption or options[1]
    selText.TextColor3 = Color3.fromRGB(230, 230, 240)
    selText.TextSize = 12
    selText.TextXAlignment = Enum.TextXAlignment.Left
    selText.Parent = box

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "v"
    arrow.TextColor3 = Color3.fromRGB(130, 130, 145)
    arrow.TextSize = 11
    arrow.Parent = box

    -- Options List (Pop-up inside accordion container)
    local listFrame = Instance.new("Frame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(1, 0, 0, listHeight)
    listFrame.Position = UDim2.new(0, 0, 1, 4)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ZIndex = 25
    listFrame.Visible = false
    listFrame.ClipsDescendants = true
    listFrame.Parent = box

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 5)
    lc.Parent = listFrame

    local ls = Instance.new("UIStroke")
    ls.Thickness = 1
    ls.Color = Color3.fromRGB(38, 38, 48)
    ls.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 2)
    listPad.PaddingBottom = UDim.new(0, 2)
    listPad.PaddingLeft = UDim.new(0, 2)
    listPad.PaddingRight = UDim.new(0, 2)
    listPad.Parent = listFrame

    local isOpen = false
    local currentTween = nil

    local function setOpen(val)
        isOpen = val
        arrow.Text = isOpen and "^" or "v"

        if currentTween then
            currentTween:Cancel()
        end

        local targetHeight = isOpen and openHeight or closedHeight
        if isOpen then
            listFrame.Visible = true
        end

        currentTween = TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        })
        currentTween:Play()

        if not isOpen then
            task.delay(0.18, function()
                if not isOpen then
                    listFrame.Visible = false
                end
            end)
        end
    end

    local triggerBtn = Instance.new("TextButton")
    triggerBtn.Size = UDim2.new(1, 0, 1, 0)
    triggerBtn.BackgroundTransparency = 1
    triggerBtn.Text = ""
    triggerBtn.ZIndex = 5
    triggerBtn.Parent = box

    triggerBtn.Activated:Connect(function()
        setOpen(not isOpen)
    end)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name = "Option_" .. opt
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        optBtn.BackgroundTransparency = 1
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
        optBtn.TextSize = 12
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 26
        optBtn.Parent = listFrame

        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 3)
        oc.Parent = optBtn

        optBtn.MouseEnter:Connect(function() optBtn.BackgroundTransparency = 0.5 end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)

        optBtn.Activated:Connect(function()
            selText.Text = opt
            setOpen(false)
            if callback then callback(opt) end
        end)
    end

    return container
end

---------------------------------------------------------------------
-- BUILD PAGES & CONTROLS
---------------------------------------------------------------------
-- TAB 1: MAIN (Divided Sections: AIMBOT, AIMBOT TARGET, SILENT AIM)
local pMain = createSidebarTab("Main", "rbxassetid://6031225882", 1)

-- Two Column Frame Containers for neat vertical stacking
local colLeft = Instance.new("Frame")
colLeft.Name = "Col_Left"
colLeft.Size = UDim2.new(0.49, 0, 0, 0)
colLeft.AutomaticSize = Enum.AutomaticSize.Y
colLeft.BackgroundTransparency = 1
colLeft.LayoutOrder = 1
colLeft.Parent = pMain

local colLeftLayout = Instance.new("UIListLayout")
colLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
colLeftLayout.Padding = UDim.new(0, 10)
colLeftLayout.Parent = colLeft

local colRight = Instance.new("Frame")
colRight.Name = "Col_Right"
colRight.Size = UDim2.new(0.49, 0, 0, 0)
colRight.AutomaticSize = Enum.AutomaticSize.Y
colRight.BackgroundTransparency = 1
colRight.LayoutOrder = 2
colRight.Parent = pMain

local colRightLayout = Instance.new("UIListLayout")
colRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
colRightLayout.Padding = UDim.new(0, 10)
colRightLayout.Parent = colRight

-- 1. AIMBOT CARD (With Subtabs Header: Aimbot | Prediction | Smoothness | FOV)
local cAimbot, cAimbotTabs = createCardWithSubtabs(colLeft, { "Aimbot", "Prediction", "Smoothness", "FOV" }, "Aimbot", 1, 1)

-- Subtab: Aimbot
createSwitchWithKeybind(cAimbotTabs["Aimbot"], "Aimbot", S.Aimbot.Enabled, S.Aimbot.Key, function(v)
    S.Aimbot.Enabled = v
    if not v then
        currentLockedTarget = nil
        currentLockedPart = nil
    end
end, function(newKey)
    S.Aimbot.Key = newKey
end, 1)

createDropdown(cAimbotTabs["Aimbot"], "Aimbot Mode", { "Hold", "Target", "Always" }, S.Aimbot.Mode, function(v)
    S.Aimbot.Mode = v
    currentLockedTarget = nil
    currentLockedPart = nil
end, 2)

createDropdown(cAimbotTabs["Aimbot"], "Aimbot Type", { "Camera", "Mouse" }, S.Aimbot.Type, function(v)
    S.Aimbot.Type = v
end, 3)

createDropdown(cAimbotTabs["Aimbot"], "Look (Hit Parts)", { "Head", "UpperTorso", "HumanoidRootPart", "Closest", "Random" }, S.Aimbot.TargetPart, function(v)
    S.Aimbot.TargetPart = v
end, 4)

createSwitch(cAimbotTabs["Aimbot"], "Sticky Aim", S.Aimbot.StickyAim, function(v) S.Aimbot.StickyAim = v end, 5)
createSwitch(cAimbotTabs["Aimbot"], "Health Check", S.Aimbot.HealthCheck, function(v) S.Aimbot.HealthCheck = v end, 6)
createSwitch(cAimbotTabs["Aimbot"], "Team Check", S.Aimbot.TeamCheck, function(v) S.Aimbot.TeamCheck = v end, 7)
createSwitch(cAimbotTabs["Aimbot"], "Wall Check", S.Aimbot.WallCheck, function(v) S.Aimbot.WallCheck = v end, 8)
createSlider(cAimbotTabs["Aimbot"], "Max Distance", 50, 2500, S.Aimbot.MaxDistance, false, function(v) S.Aimbot.MaxDistance = v end, 9)

-- Subtab: Prediction
createSlider(cAimbotTabs["Prediction"], "Hit Chance", 1, 100, S.SilentAim.HitChance or 100, false, function(v) S.SilentAim.HitChance = v end, 1)
createSlider(cAimbotTabs["Prediction"], "Max Distance", 50, 2500, S.Aimbot.MaxDistance, false, function(v) S.Aimbot.MaxDistance = v end, 2)

-- Subtab: Smoothness
createSlider(cAimbotTabs["Smoothness"], "Smoothness", 0, 1, S.Aimbot.Smoothness, true, function(v) S.Aimbot.Smoothness = v end, 1)

-- Subtab: FOV
createSwitch(cAimbotTabs["FOV"], "FOV Circle", S.Aimbot.FOVCircle, function(v)
    S.Aimbot.FOVCircle = v
    if aimbotFovDrawing then aimbotFovDrawing.Visible = v end
end, 1)
createSwitch(cAimbotTabs["FOV"], "Lock FOV To Center", S.Aimbot.LockFOVToCenter, function(v) S.Aimbot.LockFOVToCenter = v end, 2)
createSlider(cAimbotTabs["FOV"], "FOV Radius", 30, 400, S.Aimbot.FOVRadius, false, function(v)
    S.Aimbot.FOVRadius = v
    if aimbotFovDrawing then aimbotFovDrawing.Radius = v end
end, 3)

-- 2. AIMBOT TARGET / HITBOX CARD (Left Column Bottom)
local cAimbotTarget = createCard(colLeft, "AIMBOT TARGET / HITBOX", 1, 2)
createSwitch(cAimbotTarget, "Hitbox Expander", S.AimbotTarget.HitboxExpander, function(v)
    S.AimbotTarget.HitboxExpander = v
    if not v and originalHitboxes then
        for part, orig in pairs(originalHitboxes) do
            if part and part.Parent then
                pcall(function()
                    part.Size = orig.Size
                    part.Transparency = orig.Transparency
                    part.CanCollide = orig.CanCollide
                end)
            end
        end
        table.clear(originalHitboxes)
    end
end, 1)

createDropdown(cAimbotTarget, "Look (Target Part)", { "HitboxHead", "Head", "HumanoidRootPart", "All" }, S.AimbotTarget.TargetPart, function(v)
    S.AimbotTarget.TargetPart = v
end, 2)

createSwitch(cAimbotTarget, "Team Check", S.AimbotTarget.TeamCheck, function(v) S.AimbotTarget.TeamCheck = v end, 3)
createSwitch(cAimbotTarget, "Wall Check", S.AimbotTarget.WallCheck, function(v) S.AimbotTarget.WallCheck = v end, 4)
createSwitch(cAimbotTarget, "FOV Circle", S.AimbotTarget.FOVCircle, function(v)
    S.AimbotTarget.FOVCircle = v
    if targetFovDrawing then targetFovDrawing.Visible = v end
end, 5)
createSwitch(cAimbotTarget, "Lock FOV To Center", S.AimbotTarget.LockFOVToCenter, function(v) S.AimbotTarget.LockFOVToCenter = v end, 6)
createSlider(cAimbotTarget, "FOV Radius", 30, 400, S.AimbotTarget.FOVRadius, false, function(v)
    S.AimbotTarget.FOVRadius = v
    if targetFovDrawing then targetFovDrawing.Radius = v end
end, 7)
createSlider(cAimbotTarget, "Hitbox Size", 5, 50, S.AimbotTarget.HitboxSize, false, function(v) S.AimbotTarget.HitboxSize = v end, 8)
createSlider(cAimbotTarget, "Hitbox Transparency", 0, 1, S.AimbotTarget.HitboxTransparency, true, function(v) S.AimbotTarget.HitboxTransparency = v end, 9)

-- 3. SILENT AIM CARD (With Subtabs Header: Silent Aim | Prediction | FOV)
local cSilentAim, cSilentTabs = createCardWithSubtabs(colRight, { "Silent Aim", "Prediction", "FOV" }, "Silent Aim", 1, 1)

-- Subtab: Silent Aim
createSwitchWithKeybind(cSilentTabs["Silent Aim"], "Silent Aim", S.SilentAim.Enabled, S.SilentAim.Key, function(v)
    S.SilentAim.Enabled = v
    if v then isSilentToggleActive = true end
end, function(newKey)
    S.SilentAim.Key = newKey
end, 1)

createDropdown(cSilentTabs["Silent Aim"], "Silent Aim Mode", { "Hold", "Always", "Toggle" }, S.SilentAim.Mode, function(v)
    S.SilentAim.Mode = v
end, 2)

createDropdown(cSilentTabs["Silent Aim"], "Look (Hit Parts)", { "Head", "UpperTorso", "HumanoidRootPart", "Closest", "Random" }, S.SilentAim.TargetPart, function(v)
    S.SilentAim.TargetPart = v
end, 3)

createSwitch(cSilentTabs["Silent Aim"], "Sticky Aim", S.SilentAim.StickyAim, function(v) S.SilentAim.StickyAim = v end, 4)
createSwitch(cSilentTabs["Silent Aim"], "Health Check", S.SilentAim.HealthCheck, function(v) S.SilentAim.HealthCheck = v end, 5)
createSwitch(cSilentTabs["Silent Aim"], "Team Check", S.SilentAim.TeamCheck, function(v) S.SilentAim.TeamCheck = v end, 6)
createSwitch(cSilentTabs["Silent Aim"], "Wall Check", S.SilentAim.WallCheck, function(v) S.SilentAim.WallCheck = v end, 7)
createSlider(cSilentTabs["Silent Aim"], "Hit Chance", 1, 100, S.SilentAim.HitChance, false, function(v) S.SilentAim.HitChance = v end, 8)

-- Subtab: Prediction
createSlider(cSilentTabs["Prediction"], "Max Distance", 50, 2500, S.SilentAim.MaxDistance, false, function(v) S.SilentAim.MaxDistance = v end, 1)

-- Subtab: FOV
createSwitch(cSilentTabs["FOV"], "FOV Circle", S.SilentAim.FOVCircle, function(v)
    S.SilentAim.FOVCircle = v
    if silentFovDrawing then silentFovDrawing.Visible = v end
end, 1)
createSwitch(cSilentTabs["FOV"], "Lock FOV To Center", S.SilentAim.LockFOVToCenter, function(v) S.SilentAim.LockFOVToCenter = v end, 2)
createSlider(cSilentTabs["FOV"], "FOV Radius", 30, 400, S.SilentAim.FOVRadius, false, function(v)
    S.SilentAim.FOVRadius = v
    if silentFovDrawing then silentFovDrawing.Radius = v end
end, 3)

-- 4. TRIGGERBOT CARD (Right Column Bottom - Matches Reference Style)
local cTrigger = createCard(colRight, "TRIGGER BOT", 1, 2)
createSwitchWithKeybind(cTrigger, "TriggerBot", S.TriggerBot.Enabled, S.TriggerBot.Key, function(v)
    S.TriggerBot.Enabled = v
end, function(newKey)
    S.TriggerBot.Key = newKey
end, 1)

createSwitch(cTrigger, "Visible Check", S.TriggerBot.VisibleCheck, function(v) S.TriggerBot.VisibleCheck = v end, 2)
createSwitch(cTrigger, "Team Check", S.TriggerBot.TeamCheck, function(v) S.TriggerBot.TeamCheck = v end, 3)
createSlider(cTrigger, "Trigger Delay (ms)", 0, 300, S.TriggerBot.Delay, false, function(v) S.TriggerBot.Delay = v end, 4)
createSlider(cTrigger, "Max Distance", 50, 2500, S.TriggerBot.MaxDistance, false, function(v) S.TriggerBot.MaxDistance = v end, 5)

-- TAB 2: VISUALS (ESP Engine Divided into Categories)
local pVisuals = createSidebarTab("Visuals", "rbxassetid://6031075931", 2)

local colVisLeft = Instance.new("Frame")
colVisLeft.Name = "Col_VisLeft"
colVisLeft.Size = UDim2.new(0.49, 0, 0, 0)
colVisLeft.AutomaticSize = Enum.AutomaticSize.Y
colVisLeft.BackgroundTransparency = 1
colVisLeft.LayoutOrder = 1
colVisLeft.Parent = pVisuals

local colVisLeftLayout = Instance.new("UIListLayout")
colVisLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
colVisLeftLayout.Padding = UDim.new(0, 10)
colVisLeftLayout.Parent = colVisLeft

local colVisRight = Instance.new("Frame")
colVisRight.Name = "Col_VisRight"
colVisRight.Size = UDim2.new(0.49, 0, 0, 0)
colVisRight.AutomaticSize = Enum.AutomaticSize.Y
colVisRight.BackgroundTransparency = 1
colVisRight.LayoutOrder = 2
colVisRight.Parent = pVisuals

local colVisRightLayout = Instance.new("UIListLayout")
colVisRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
colVisRightLayout.Padding = UDim.new(0, 10)
colVisRightLayout.Parent = colVisRight

-- Table to hold Visuals switch controllers for cross-card synchronization
local visualSwitches = {}

-- ---------------------------------------------------------------------
-- LEFT COLUMN: CARD 1: ESP (Subtabs: ESP | Crosshair | Misc | Flags)
-- ---------------------------------------------------------------------
local cESP, cESPTabs = createCardWithSubtabs(colVisLeft, { "ESP", "Crosshair", "Misc", "Flags" }, "ESP", 1, 1)

-- Subtab: ESP
local _, swMasterESP = createSwitchWithKeybind(cESPTabs["ESP"], "Enabled", S.ESP.Enabled, S.ESP.Key, function(v)
    S.ESP.Enabled = v
    if v then
        -- Auto activate default visuals if none are active
        if not S.BoxESP.Enabled and not S.NameESP.Enabled and not S.Chams.Enabled and not S.Tracers.Enabled then
            if visualSwitches["Box_Enabled"] then visualSwitches["Box_Enabled"].SetState(true) else S.BoxESP.Enabled = true end
            if visualSwitches["Name_Enabled"] then visualSwitches["Name_Enabled"].SetState(true) else S.NameESP.Enabled = true end
            if visualSwitches["Chams_Enabled"] then visualSwitches["Chams_Enabled"].SetState(true) else S.Chams.Enabled = true end
            if visualSwitches["Ind_Distance"] then visualSwitches["Ind_Distance"].SetState(true) else S.Indicators.Distance = true end
            if visualSwitches["Health_Bar"] then visualSwitches["Health_Bar"].SetState(true) else S.Health.HealthBar = true end
        end
    end
end, function(newKey)
    S.ESP.Key = newKey
end, 1)
visualSwitches["Master_ESP"] = swMasterESP

createSwitch(cESPTabs["ESP"], "Team Check", S.ESP.TeamCheck, function(v)
    S.ESP.TeamCheck = v
end, 2)

createSwitchWithColors(cESPTabs["ESP"], "Visible Check", S.ESP.VisibleCheck, { S.ESP.VisibleColor, S.ESP.HiddenColor }, function(v)
    S.ESP.VisibleCheck = v
end, function(idx, newCol)
    if idx == 1 then S.ESP.VisibleColor = newCol else S.ESP.HiddenColor = newCol end
end, 3)

createSwitch(cESPTabs["ESP"], "Team Based Color", S.ESP.TeamBasedColor, function(v)
    S.ESP.TeamBasedColor = v
    S.BoxESP.TeamColors = v
    S.NameESP.TeamColors = v
    S.Tracers.TeamColors = v
    S.Chams.TeamColors = v
end, 4)

createSwitch(cESPTabs["ESP"], "Text Gradient", S.ESP.TextGradient, function(v)
    S.ESP.TextGradient = v
end, 5)

createSwitch(cESPTabs["ESP"], "Text Background", S.ESP.TextBackground, function(v)
    S.ESP.TextBackground = v
end, 6)

createSwitch(cESPTabs["ESP"], "Outline", S.ESP.Outline, function(v)
    S.ESP.Outline = v
    S.BoxESP.Outline = v
    S.NameESP.Outline = v
    S.Chams.Outline = v
end, 7)

createSwitch(cESPTabs["ESP"], "Glow", S.ESP.Glow, function(v)
    S.ESP.Glow = v
    S.Chams.Glow = v
end, 8)

createSwitch(cESPTabs["ESP"], "Self ESP", S.ESP.SelfESP, function(v)
    S.ESP.SelfESP = v
    S.Chams.SelfESP = v
end, 9)

createDropdown(cESPTabs["ESP"], "Sizing Type", { "Bounding", "Corner", "Dynamic" }, S.ESP.SizingType, function(v)
    S.ESP.SizingType = v
end, 10)

createSlider(cESPTabs["ESP"], "Render Distance", 100, 5000, S.ESP.RenderDistance, false, function(v)
    S.ESP.RenderDistance = v
    S.Tracers.MaxDistance = v
end, 11)

-- Subtab: Crosshair
createSwitch(cESPTabs["Crosshair"], "Enabled", false, nil, 1)
createSlider(cESPTabs["Crosshair"], "Size", 2, 50, 10, false, nil, 2)
createSlider(cESPTabs["Crosshair"], "Gap", 0, 25, 4, false, nil, 3)
createSlider(cESPTabs["Crosshair"], "Thickness", 1, 10, 1, false, nil, 4)

-- Subtab: Misc
createSwitch(cESPTabs["Misc"], "Third Person", false, nil, 1)
createSlider(cESPTabs["Misc"], "Field of View", 70, 120, 90, false, nil, 2)

-- Subtab: Flags
createSwitch(cESPTabs["Flags"], "Show Health", true, nil, 1)
createSwitch(cESPTabs["Flags"], "Show Distance", true, nil, 2)
createSwitch(cESPTabs["Flags"], "Show Weapon", false, nil, 3)

-- ---------------------------------------------------------------------
-- LEFT COLUMN: CARD 2: Box
-- ---------------------------------------------------------------------
local cBox = createCard(colVisLeft, "Box", 1, 2)
local _, swBox = createSwitchWithColors(cBox, "Enabled", S.BoxESP.Enabled, { S.BoxESP.Color, S.BoxESP.FillColor }, function(v)
    S.BoxESP.Enabled = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    if idx == 1 then S.BoxESP.Color = newCol else S.BoxESP.FillColor = newCol end
end, 1)
visualSwitches["Box_Enabled"] = swBox

createSwitch(cBox, "Fill Box", S.BoxESP.FillBox, function(v)
    S.BoxESP.FillBox = v
end, 2)

createDropdown(cBox, "Box Type", { "2D", "3D", "Corner" }, S.BoxESP.BoxType, function(v)
    S.BoxESP.BoxType = v
end, 3)

-- ---------------------------------------------------------------------
-- LEFT COLUMN: CARD 3: Name
-- ---------------------------------------------------------------------
local cName = createCard(colVisLeft, "Name", 1, 3)
local _, swName = createSwitchWithColors(cName, "Enabled", S.NameESP.Enabled, { S.NameESP.Color }, function(v)
    S.NameESP.Enabled = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.NameESP.Color = newCol
end, 1)
visualSwitches["Name_Enabled"] = swName

createDropdown(cName, "Type", { "Name", "Display Name", "Both" }, S.NameESP.Type, function(v)
    S.NameESP.Type = v
end, 2)

-- ---------------------------------------------------------------------
-- RIGHT COLUMN: CARD 4: Indicators (Subtabs: Indicators | OOF Arrow | Radar)
-- ---------------------------------------------------------------------
local cInd, cIndTabs = createCardWithSubtabs(colVisRight, { "Indicators", "OOF Arrow", "Radar" }, "Indicators", 1, 1)

-- Subtab: Indicators
local _, swDist = createSwitchWithColors(cIndTabs["Indicators"], "Distance", S.Indicators.Distance, { S.Indicators.DistanceColor }, function(v)
    S.Indicators.Distance = v
    S.NameESP.Distance = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Indicators.DistanceColor = newCol
end, 1)
visualSwitches["Ind_Distance"] = swDist

createSwitchWithColors(cIndTabs["Indicators"], "Equipped Item", S.Indicators.EquippedItem, { S.Indicators.EquippedColor }, function(v)
    S.Indicators.EquippedItem = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Indicators.EquippedColor = newCol
end, 2)

createSwitchWithColors(cIndTabs["Indicators"], "Skeleton", S.Indicators.Skeleton, { S.Indicators.SkeletonColor }, function(v)
    S.Indicators.Skeleton = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Indicators.SkeletonColor = newCol
end, 3)

createSwitchWithColors(cIndTabs["Indicators"], "Head Dot", S.Indicators.HeadDot, { S.Indicators.HeadDotColor }, function(v)
    S.Indicators.HeadDot = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Indicators.HeadDotColor = newCol
end, 4)

createSwitch(cIndTabs["Indicators"], "Head Dot Glow", S.Indicators.HeadDotGlow, function(v)
    S.Indicators.HeadDotGlow = v
end, 5)

createSwitch(cIndTabs["Indicators"], "Profile Picture", S.Indicators.ProfilePicture, function(v)
    S.Indicators.ProfilePicture = v
end, 6)

-- Subtab: OOF Arrow
createSwitch(cIndTabs["OOF Arrow"], "Enabled", S.Indicators.OOFArrow, function(v)
    S.Indicators.OOFArrow = v
end, 1)
createSlider(cIndTabs["OOF Arrow"], "Radius", 50, 400, S.Indicators.OOFRadius, false, function(v)
    S.Indicators.OOFRadius = v
end, 2)
createSlider(cIndTabs["OOF Arrow"], "Arrow Size", 5, 30, S.Indicators.OOFSize, false, function(v)
    S.Indicators.OOFSize = v
end, 3)

-- Subtab: Radar
createSwitch(cIndTabs["Radar"], "Enabled", S.Indicators.Radar, function(v)
    S.Indicators.Radar = v
end, 1)
createSlider(cIndTabs["Radar"], "Range", 50, 1000, S.Indicators.RadarRange, false, function(v)
    S.Indicators.RadarRange = v
end, 2)
createSlider(cIndTabs["Radar"], "Radar Size", 80, 250, S.Indicators.RadarSize, false, function(v)
    S.Indicators.RadarSize = v
end, 3)

-- ---------------------------------------------------------------------
-- RIGHT COLUMN: CARD 5: Health
-- ---------------------------------------------------------------------
local cHealth = createCard(colVisRight, "Health", 1, 2)
local _, swHp = createSwitchWithColors(cHealth, "Health Bar", S.Health.HealthBar, { S.Health.Color }, function(v)
    S.Health.HealthBar = v
    S.NameESP.HealthBar = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Health.Color = newCol
end, 1)
visualSwitches["Health_Bar"] = swHp

createSwitch(cHealth, "Health Based", S.Health.HealthBased, function(v)
    S.Health.HealthBased = v
end, 2)

createSwitch(cHealth, "Health Text", S.Health.HealthText, function(v)
    S.Health.HealthText = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, 3)

createDropdown(cHealth, "Text Pos", { "Above Name", "Below Name", "Side" }, S.Health.TextPos, function(v)
    S.Health.TextPos = v
end, 4)

-- ---------------------------------------------------------------------
-- RIGHT COLUMN: CARD 6: Chams
-- ---------------------------------------------------------------------
local cChams = createCard(colVisRight, "Chams", 1, 3)
createDropdown(cChams, "Mode", { "Default", "Wireframe", "Ghost", "Pulsing" }, S.Chams.Mode, function(v)
    S.Chams.Mode = v
end, 1)

local _, swChams = createSwitchWithColors(cChams, "Enabled", S.Chams.Enabled, { S.Chams.Color, S.Chams.VisibleColor }, function(v)
    S.Chams.Enabled = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    if idx == 1 then S.Chams.Color = newCol else S.Chams.VisibleColor = newCol end
end, 2)
visualSwitches["Chams_Enabled"] = swChams

createSwitch(cChams, "Filled", S.Chams.Filled, function(v)
    S.Chams.Filled = v
end, 3)

createDropdown(cChams, "Rendering Type", { "Static", "AlwaysOnTop", "Occluded" }, S.Chams.RenderingType, function(v)
    S.Chams.RenderingType = v
end, 4)

-- ---------------------------------------------------------------------
-- RIGHT COLUMN: CARD 7: Tracer
-- ---------------------------------------------------------------------
local cTracer = createCard(colVisRight, "Tracer", 1, 4)
local _, swTracer = createSwitchWithColors(cTracer, "Enabled", S.Tracers.Enabled, { S.Tracers.Color }, function(v)
    S.Tracers.Enabled = v
    if v and not S.ESP.Enabled then
        if visualSwitches["Master_ESP"] then visualSwitches["Master_ESP"].SetState(true, true) end
        S.ESP.Enabled = true
    end
end, function(idx, newCol)
    S.Tracers.Color = newCol
end, 1)
visualSwitches["Tracer_Enabled"] = swTracer

createDropdown(cTracer, "Origin", { "Top", "Center", "Bottom", "Mouse" }, S.Tracers.TracersOrigin, function(v)
    S.Tracers.TracersOrigin = v
end, 2)

-- TAB 3: PLAYER (Movement & Utility)
local pPlayer = createSidebarTab("Player", "rbxassetid://6031075929", 3)
local cMove = createCard(pPlayer, "Movement", 0.49, 1)
createSwitch(cMove, "Enable WalkSpeed", S.WalkSpeedToggle, function(v)
    S.WalkSpeedToggle = v
    if not v and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end, 1)
createSlider(cMove, "WalkSpeed", 16, 200, S.WalkSpeed, false, function(v)
    S.WalkSpeed = v
    if S.WalkSpeedToggle and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end, 2)
createSwitch(cMove, "Enable JumpPower", S.JumpPowerToggle, function(v)
    S.JumpPowerToggle = v
    if not v and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 50 end
    end
end, 3)
createSlider(cMove, "JumpPower", 50, 300, S.JumpPower, false, function(v)
    S.JumpPower = v
    if S.JumpPowerToggle and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end, 4)
createSwitch(cMove, "Infinite Jump", S.InfiniteJump, function(v) S.InfiniteJump = v end, 5)
createSwitch(cMove, "NoClip", S.NoClip, function(v)
    S.NoClip = v
    if not v and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = true
            end
        end
    end
end, 6)

local cFly = createCard(pPlayer, "Fly & Physics", 0.49, 2)
createSwitch(cFly, "Enable Fly", S.Fly, function(v)
    S.Fly = v
    if not v and flyBV then
        flyBV:Destroy()
        flyBV = nil
    end
end, 1)
createSlider(cFly, "Fly Speed", 20, 200, S.FlySpeed, false, function(v) S.FlySpeed = v end, 2)

-- TAB 4: UI SETTINGS
local pSettings = createSidebarTab("UI Settings", "rbxassetid://6031280882", 4)
local cConf = createCard(pSettings, "Menu Settings", 0.49, 1)
createDropdown(cConf, "Menu Keybind", { "RightControl", "Insert", "RightShift" }, "RightControl", function(v)
    if v == "RightControl" then S.ToggleKey = Enum.KeyCode.RightControl
    elseif v == "Insert" then S.ToggleKey = Enum.KeyCode.Insert
    elseif v == "RightShift" then S.ToggleKey = Enum.KeyCode.RightShift end
end, 1)

local copyBtn = Instance.new("TextButton")
copyBtn.Name = "CopyDiscord"
copyBtn.Size = UDim2.new(1, 0, 0, 32)
copyBtn.BackgroundColor3 = Color3.fromRGB(123, 97, 255)
copyBtn.BorderSizePixel = 0
copyBtn.Font = Enum.Font.GothamBold
copyBtn.Text = "Copy Discord Link"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextSize = 12
copyBtn.LayoutOrder = 2
copyBtn.Parent = cConf

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 5)
cbc.Parent = copyBtn

copyBtn.Activated:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("discord.gg/dJJ3psbAxw")
        end
    end)
    copyBtn.Text = "Copied to Clipboard!"
    task.wait(1.5)
    copyBtn.Text = "Copy Discord Link"
end)

-- Default Tab
switchTab("Main")

---------------------------------------------------------------------
-- WINDOW DRAGGING SUPPORT
---------------------------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle UI Keybind
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == S.ToggleKey then
        S.Visible = not S.Visible
        MainFrame.Visible = S.Visible
    end
end)

---------------------------------------------------------------------
-- COMBAT & GAMEPLAY LOGIC (AIMBOT, SILENT AIM, AIMBOT TARGET)
---------------------------------------------------------------------
local isHoldingKey = false
local currentLockedTarget = nil
local currentLockedPart = nil

local function isInputMatchingBind(input, boundKey)
    if not boundKey then return false end
    if typeof(boundKey) == "string" then
        if boundKey == "MB4" or boundKey == "MouseBackButton" then
            return input.KeyCode == Enum.KeyCode.MouseBackButton
        elseif boundKey == "MB5" then
            return input.KeyCode == Enum.KeyCode.MouseBackButton
        elseif input.KeyCode and input.KeyCode.Name == boundKey then
            return true
        end
        return false
    end
    if typeof(boundKey) == "EnumItem" then
        if boundKey.EnumType == Enum.UserInputType then
            return input.UserInputType == boundKey
        elseif boundKey.EnumType == Enum.KeyCode then
            return input.KeyCode == boundKey
        end
    end
    return false
end

local GuiService = game:GetService("GuiService")

-- Viewport center calculation depending on LockFOVToCenter
local function getViewportCenter(lockToCenter)
    if lockToCenter or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        local mouse = UserInputService:GetMouseLocation()
        local inset, _ = GuiService:GetGuiInset()
        return Vector2.new(mouse.X, mouse.Y - inset.Y)
    end
end

-- Screen Drawing center calculation
local function getDrawingCenter(lockToCenter)
    if lockToCenter or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        return UserInputService:GetMouseLocation()
    end
end

-- Helper: resolve target part for a character with support for Closest and Random
local function getTargetPartForChar(char, preference, fromPos)
    if not char then return nil end
    if preference == "Head" then
        return char:FindFirstChild("HitboxHead") or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    elseif preference == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif preference == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    elseif preference == "Random" then
        local parts = {
            char:FindFirstChild("HitboxHead") or char:FindFirstChild("Head"),
            char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
            char:FindFirstChild("HumanoidRootPart")
        }
        local valid = {}
        for _, p in ipairs(parts) do if p then table.insert(valid, p) end end
        if #valid > 0 then
            return valid[math.random(1, #valid)]
        end
        return char:FindFirstChild("Head")
    elseif preference == "Closest" then
        local parts = {
            char:FindFirstChild("HitboxHead") or char:FindFirstChild("Head"),
            char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
            char:FindFirstChild("HumanoidRootPart")
        }
        local bestP = nil
        local bestD = math.huge
        local testPos = fromPos or Camera.CFrame.Position
        for _, p in ipairs(parts) do
            if p and p:IsA("BasePart") then
                local d = (p.Position - testPos).Magnitude
                if d < bestD then
                    bestD = d
                    bestP = p
                end
            end
        end
        return bestP or char:FindFirstChild("Head")
    end
    return char:FindFirstChild(preference) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- Helper: check if player is teammate
local function isTeammate(p)
    if not p or p == LocalPlayer then return true end
    if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
        return true
    end
    return false
end

-- Helper: check line of sight between camera and target part
local function checkWallVisibility(char, part)
    if not part then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, char }
    rayParams.IgnoreWater = true
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local result = Workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

-- Sticky Aim storage
local currentStickyAimbot = nil
local currentStickyAimbotPart = nil

local currentStickySilent = nil
local currentStickySilentPart = nil

-- 1. Independent Closest Target for AIMBOT
local function getClosestAimbotTarget()
    local cfg = S.Aimbot
    if not cfg.Enabled then return nil, nil end

    local center = getViewportCenter(cfg.LockFOVToCenter)

    -- Sticky Aim handling
    if cfg.StickyAim and currentStickyAimbot and currentStickyAimbot.Parent then
        local hum = currentStickyAimbot:FindFirstChildOfClass("Humanoid")
        local isAlive = hum and hum.Health > 0
        if cfg.HealthCheck and currentStickyAimbot:FindFirstChildOfClass("ForceField") then isAlive = false end

        if isAlive and currentStickyAimbotPart and currentStickyAimbotPart:IsDescendantOf(workspace) then
            local distFromCam = (Camera.CFrame.Position - currentStickyAimbotPart.Position).Magnitude
            if distFromCam <= cfg.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(currentStickyAimbotPart.Position)
                if onScreen and screenPos.Z > 0 then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - center).Magnitude
                    if dist <= cfg.FOVRadius * 1.5 then
                        if not cfg.WallCheck or checkWallVisibility(currentStickyAimbot, currentStickyAimbotPart) then
                            return currentStickyAimbot, currentStickyAimbotPart
                        end
                    end
                end
            end
        end
        currentStickyAimbot = nil
        currentStickyAimbotPart = nil
    end

    local bestTarget = nil
    local bestPart = nil
    local shortestDist = cfg.FOVRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not cfg.TeamCheck or not isTeammate(p) then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local isAlive = hum and hum.Health > 0
                if cfg.HealthCheck and char:FindFirstChildOfClass("ForceField") then isAlive = false end

                if isAlive then
                    local targetPart = getTargetPartForChar(char, cfg.TargetPart, Camera.CFrame.Position)
                    if targetPart then
                        local distFromCam = (Camera.CFrame.Position - targetPart.Position).Magnitude
                        if distFromCam <= cfg.MaxDistance then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen and screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local dist = (screenVec - center).Magnitude

                                if dist <= cfg.FOVRadius and dist <= shortestDist then
                                    if not cfg.WallCheck or checkWallVisibility(char, targetPart) then
                                        shortestDist = dist
                                        bestTarget = char
                                        bestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if bestTarget and cfg.StickyAim then
        currentStickyAimbot = bestTarget
        currentStickyAimbotPart = bestPart
    end

    return bestTarget, bestPart
end

-- 2. Independent Closest Target for SILENT AIM
local function getClosestSilentAimTarget()
    local cfg = S.SilentAim
    if not cfg.Enabled then return nil, nil end

    local center = getViewportCenter(cfg.LockFOVToCenter)

    -- Sticky Aim handling for Silent Aim
    if cfg.StickyAim and currentStickySilent and currentStickySilent.Parent then
        local hum = currentStickySilent:FindFirstChildOfClass("Humanoid")
        local isAlive = hum and hum.Health > 0
        if cfg.HealthCheck and currentStickySilent:FindFirstChildOfClass("ForceField") then isAlive = false end

        if isAlive and currentStickySilentPart and currentStickySilentPart:IsDescendantOf(workspace) then
            local distFromCam = (Camera.CFrame.Position - currentStickySilentPart.Position).Magnitude
            if distFromCam <= cfg.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(currentStickySilentPart.Position)
                if onScreen and screenPos.Z > 0 then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - center).Magnitude
                    if dist <= cfg.FOVRadius * 1.5 then
                        if not cfg.WallCheck or checkWallVisibility(currentStickySilent, currentStickySilentPart) then
                            return currentStickySilent, currentStickySilentPart
                        end
                    end
                end
            end
        end
        currentStickySilent = nil
        currentStickySilentPart = nil
    end

    local bestTarget = nil
    local bestPart = nil
    local shortestDist = cfg.FOVRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if not cfg.TeamCheck or not isTeammate(p) then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local isAlive = hum and hum.Health > 0
                if cfg.HealthCheck and char:FindFirstChildOfClass("ForceField") then isAlive = false end

                if isAlive then
                    local targetPart = getTargetPartForChar(char, cfg.TargetPart, Camera.CFrame.Position)
                    if targetPart then
                        local distFromCam = (Camera.CFrame.Position - targetPart.Position).Magnitude
                        if distFromCam <= cfg.MaxDistance then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen and screenPos.Z > 0 then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local dist = (screenVec - center).Magnitude

                                if dist <= cfg.FOVRadius and dist <= shortestDist then
                                    if not cfg.WallCheck or checkWallVisibility(char, targetPart) then
                                        shortestDist = dist
                                        bestTarget = char
                                        bestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if bestTarget and cfg.StickyAim then
        currentStickySilent = bestTarget
        currentStickySilentPart = bestPart
    end

    return bestTarget, bestPart
end

-- Key Input Listeners for Aimbot
UserInputService.InputBegan:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.Aimbot.Key) then
        isHoldingKey = true

        if S.Aimbot.Enabled and S.Aimbot.Mode == "Target" then
            if currentLockedTarget then
                currentLockedTarget = nil
                currentLockedPart = nil
            else
                currentLockedTarget, currentLockedPart = getClosestAimbotTarget()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.Aimbot.Key) then
        isHoldingKey = false
    end
end)

-- Key Input Listeners for Silent Aim
local isSilentHoldingKey = false
local isSilentToggleActive = true

UserInputService.InputBegan:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.SilentAim.Key) then
        isSilentHoldingKey = true
        if S.SilentAim.Mode == "Toggle" then
            isSilentToggleActive = not isSilentToggleActive
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.SilentAim.Key) then
        isSilentHoldingKey = false
    end
end)

-- Key Input Listener for Master ESP
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and S.ESP.Key and isInputMatchingBind(input, S.ESP.Key) then
        local newV = not S.ESP.Enabled
        if visualSwitches and visualSwitches["Master_ESP"] then
            visualSwitches["Master_ESP"].SetState(newV)
        else
            S.ESP.Enabled = newV
        end
    end
end)

local function isSilentAimActive()
    if not S.SilentAim.Enabled then return false end
    if S.SilentAim.Mode == "Hold" then
        return isSilentHoldingKey
    elseif S.SilentAim.Mode == "Toggle" then
        return isSilentToggleActive
    else -- "Always"
        return true
    end
end

-- Render loop: Aimbot + Independent FOV Circles
RunService.RenderStepped:Connect(function()
    -- Aimbot FOV Circle
    if aimbotFovDrawing then
        if S.Aimbot.FOVCircle and S.Aimbot.Enabled then
            aimbotFovDrawing.Position = getDrawingCenter(S.Aimbot.LockFOVToCenter)
            aimbotFovDrawing.Radius = S.Aimbot.FOVRadius
            aimbotFovDrawing.Visible = true
        else
            aimbotFovDrawing.Visible = false
        end
    end

    -- Silent Aim FOV Circle
    if silentFovDrawing then
        if S.SilentAim.FOVCircle and S.SilentAim.Enabled then
            silentFovDrawing.Position = getDrawingCenter(S.SilentAim.LockFOVToCenter)
            silentFovDrawing.Radius = S.SilentAim.FOVRadius
            silentFovDrawing.Visible = true
        else
            silentFovDrawing.Visible = false
        end
    end

    -- Aimbot Target / Hitbox FOV Circle
    if targetFovDrawing then
        if S.AimbotTarget.FOVCircle and S.AimbotTarget.HitboxExpander then
            targetFovDrawing.Position = getDrawingCenter(S.AimbotTarget.LockFOVToCenter)
            targetFovDrawing.Radius = S.AimbotTarget.FOVRadius
            targetFovDrawing.Visible = true
        else
            targetFovDrawing.Visible = false
        end
    end

    -- Aimbot Execution
    if S.Aimbot.Enabled then
        local targetChar = nil
        local targetPart = nil
        local fovCenter = getViewportCenter(S.Aimbot.LockFOVToCenter)

        if S.Aimbot.Mode == "Always" then
            targetChar, targetPart = getClosestAimbotTarget()
        elseif S.Aimbot.Mode == "Hold" then
            if isHoldingKey then
                targetChar, targetPart = getClosestAimbotTarget()
            end
        elseif S.Aimbot.Mode == "Target" then
            if currentLockedTarget and currentLockedPart then
                local hum = currentLockedTarget:FindFirstChildOfClass("Humanoid")
                local isAlive = hum and hum.Health > 0
                if S.Aimbot.HealthCheck and currentLockedTarget:FindFirstChildOfClass("ForceField") then isAlive = false end

                if isAlive and currentLockedPart:IsDescendantOf(workspace) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(currentLockedPart.Position)
                    if onScreen and screenPos.Z > 0 then
                        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (screenVec - fovCenter).Magnitude

                        if dist <= S.Aimbot.FOVRadius then
                            local passWall = true
                            if S.Aimbot.WallCheck then
                                passWall = checkWallVisibility(currentLockedTarget, currentLockedPart)
                            end

                            if passWall then
                                targetChar = currentLockedTarget
                                targetPart = currentLockedPart
                            else
                                currentLockedTarget = nil
                                currentLockedPart = nil
                            end
                        else
                            currentLockedTarget = nil
                            currentLockedPart = nil
                        end
                    else
                        currentLockedTarget = nil
                        currentLockedPart = nil
                    end
                else
                    currentLockedTarget = nil
                    currentLockedPart = nil
                end
            end
        end

        if targetPart then
            local targetPos = targetPart.Position
            local alpha = math.clamp(1 - S.Aimbot.Smoothness, 0.05, 0.95)
            if S.Aimbot.Smoothness <= 0.05 then alpha = 1 end

            if S.Aimbot.Type == "Mouse" and mousemoverel then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local deltaX = (screenPos.X - mousePos.X) * alpha
                    local deltaY = (screenPos.Y - mousePos.Y) * alpha
                    mousemoverel(deltaX, deltaY)
                end
            else
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                if S.Aimbot.Smoothness <= 0.05 then
                    Camera.CFrame = targetCFrame
                else
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                end
            end
        end
    else
        currentLockedTarget = nil
        currentLockedPart = nil
    end
end)

---------------------------------------------------------------------
-- TRIGGERBOT ENGINE
---------------------------------------------------------------------
local isTriggerHolding = false
local isTriggerFiring = false

local function fireTriggerBot()
    if mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait(0.02)
        mouse1release()
    else
        local vim = game:GetService("VirtualInputManager")
        local mousePos = UserInputService:GetMouseLocation()
        vim:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
        task.wait(0.02)
        vim:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.TriggerBot.Key) then
        isTriggerHolding = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if isInputMatchingBind(input, S.TriggerBot.Key) then
        isTriggerHolding = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.TriggerBot.Enabled then return end
    if isTriggerFiring then return end

    -- Raycast directly through the camera center
    local origin = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector * S.TriggerBot.MaxDistance
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, rayParams)

    if result and result.Instance then
        local hitPart = result.Instance
        local hitChar = hitPart:FindFirstAncestorOfClass("Model")
        local hum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
        local player = hitChar and Players:GetPlayerFromCharacter(hitChar)

        if player and player ~= LocalPlayer and hum and hum.Health > 0 then
            if not S.TriggerBot.TeamCheck or not isTeammate(player) then
                if not S.TriggerBot.VisibleCheck or checkWallVisibility(hitChar, hitPart) then
                    isTriggerFiring = true
                    task.spawn(function()
                        if S.TriggerBot.Delay > 0 then
                            task.wait(S.TriggerBot.Delay / 1000)
                        end
                        if S.TriggerBot.Enabled then
                            fireTriggerBot()
                        end
                        task.wait(0.05)
                        isTriggerFiring = false
                    end)
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- SILENT AIM HOOKS (Independent)
---------------------------------------------------------------------
pcall(function()
    local oldRaycast
    oldRaycast = hookfunction(Workspace.Raycast, newcclosure(function(self, origin, direction, rayParams)
        if isSilentAimActive() and not checkcaller() then
            local chance = S.SilentAim.HitChance or 100
            if chance >= 100 or math.random(1, 100) <= chance then
                local _, targetPart = getClosestSilentAimTarget()
                if targetPart and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                    local camPos = Camera.CFrame.Position
                    if (origin - camPos).Magnitude < 40 then
                        local mag = direction.Magnitude
                        if mag < 1 then mag = 1000 end
                        local newDir = (targetPart.Position - origin).Unit * mag
                        return oldRaycast(self, origin, newDir, rayParams)
                    end
                end
            end
        end
        return oldRaycast(self, origin, direction, rayParams)
    end))

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if isSilentAimActive() and not checkcaller() then
            local chance = S.SilentAim.HitChance or 100
            if method == "Raycast" and self == Workspace then
                if chance >= 100 or math.random(1, 100) <= chance then
                    local origin = args[1]
                    local direction = args[2]
                    local _, targetPart = getClosestSilentAimTarget()
                    if targetPart and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                        local camPos = Camera.CFrame.Position
                        if (origin - camPos).Magnitude < 40 then
                            local mag = direction.Magnitude
                            if mag < 1 then mag = 1000 end
                            args[2] = (targetPart.Position - origin).Unit * mag
                            return oldNamecall(self, table.unpack(args))
                        end
                    end
                end
            elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") and self == Workspace then
                if chance >= 100 or math.random(1, 100) <= chance then
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        local _, targetPart = getClosestSilentAimTarget()
                        if targetPart then
                            local origin = ray.Origin
                            local camPos = Camera.CFrame.Position
                            if (origin - camPos).Magnitude < 40 then
                                local mag = ray.Direction.Magnitude
                                if mag < 1 then mag = 1000 end
                                local newDir = (targetPart.Position - origin).Unit * mag
                                args[1] = Ray.new(origin, newDir)
                                return oldNamecall(self, table.unpack(args))
                            end
                        end
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end))

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
        if isSilentAimActive() and not checkcaller() then
            if typeof(self) == "Instance" and self:IsA("Mouse") then
                local chance = S.SilentAim.HitChance or 100
                if chance >= 100 or math.random(1, 100) <= chance then
                    if idx == "Hit" then
                        local _, targetPart = getClosestSilentAimTarget()
                        if targetPart then
                            return CFrame.new(targetPart.Position)
                        end
                    elseif idx == "Target" then
                        local _, targetPart = getClosestSilentAimTarget()
                        if targetPart then
                            return targetPart
                        end
                    end
                end
            end
        end
        return oldIndex(self, idx)
    end))
end)

---------------------------------------------------------------------
-- AIMBOT TARGET / HITBOX EXPANDER (Independent)
---------------------------------------------------------------------
local originalHitboxes = {}

RunService.Heartbeat:Connect(function()
    local cfg = S.AimbotTarget
    if not cfg.HitboxExpander then
        if next(originalHitboxes) ~= nil then
            for part, orig in pairs(originalHitboxes) do
                if part and part.Parent then
                    pcall(function()
                        part.Size = orig.Size
                        part.Transparency = orig.Transparency
                        part.CanCollide = orig.CanCollide
                    end)
                end
            end
            table.clear(originalHitboxes)
        end
        return
    end

    local center = getViewportCenter(cfg.LockFOVToCenter)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local isAlive = hum and hum.Health > 0

            local partsToExpand = {}
            if cfg.TargetPart == "All" then
                partsToExpand = {
                    char:FindFirstChild("HitboxHead") or char:FindFirstChild("Head"),
                    char:FindFirstChild("HumanoidRootPart")
                }
            elseif cfg.TargetPart == "HitboxHead" then
                partsToExpand = { char:FindFirstChild("HitboxHead") or char:FindFirstChild("Head") }
            elseif cfg.TargetPart == "Head" then
                partsToExpand = { char:FindFirstChild("Head") }
            else
                partsToExpand = { char:FindFirstChild(cfg.TargetPart) or char:FindFirstChild("HumanoidRootPart") }
            end

            local shouldExpand = cfg.HitboxExpander and isAlive

            if shouldExpand and cfg.TeamCheck and isTeammate(p) then
                shouldExpand = false
            end

            if shouldExpand and (cfg.FOVCircle or cfg.WallCheck) then
                local testPart = partsToExpand[1]
                if testPart then
                    if cfg.FOVCircle then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(testPart.Position)
                        if not onScreen or screenPos.Z <= 0 then
                            shouldExpand = false
                        else
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist > cfg.FOVRadius then
                                shouldExpand = false
                            end
                        end
                    end

                    if shouldExpand and cfg.WallCheck then
                        if not checkWallVisibility(char, testPart) then
                            shouldExpand = false
                        end
                    end
                end
            end

            for _, part in ipairs(partsToExpand) do
                if part and part:IsA("BasePart") then
                    if not originalHitboxes[part] then
                        originalHitboxes[part] = {
                            Size = part.Size,
                            Transparency = part.Transparency,
                            CanCollide = part.CanCollide
                        }
                    end

                    if shouldExpand then
                        part.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                        part.Transparency = cfg.HitboxTransparency
                        part.CanCollide = false
                    else
                        local orig = originalHitboxes[part]
                        if orig then
                            part.Size = orig.Size
                            part.Transparency = orig.Transparency
                            part.CanCollide = orig.CanCollide
                        end
                    end
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- VISUALS (ESP ENGINE: BOX 2D/3D, CHAMS/GLOW, NAMES, TRACERS)
---------------------------------------------------------------------
local espObjects = {}
local chamsObjects = {}
_G.VodkaESPObjects = espObjects
_G.VodkaChamsObjects = chamsObjects

local R15_JOINTS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local R6_JOINTS = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function createESPForPlayer(player)
    if not player then return end
    if espObjects[player] then return end

    local esp = {
        Box = Drawing and Drawing.new("Square"),
        BoxOutline = Drawing and Drawing.new("Square"),
        Lines3D = {},
        LinesCorner = {},
        SkeletonLines = {},
        Name = Drawing and Drawing.new("Text"),
        Distance = Drawing and Drawing.new("Text"),
        EquippedItem = Drawing and Drawing.new("Text"),
        HealthBar = Drawing and Drawing.new("Line"),
        HealthBarOutline = Drawing and Drawing.new("Line"),
        HealthText = Drawing and Drawing.new("Text"),
        HeadDot = Drawing and Drawing.new("Circle"),
        HeadDotGlow = Drawing and Drawing.new("Circle"),
        Tracer = Drawing and Drawing.new("Line")
    }

    if Drawing then
        -- 2D Box
        if esp.Box then
            esp.Box.Thickness = 1.4
            esp.Box.Filled = false
            esp.Box.Color = Color3.fromRGB(255, 255, 255)
            esp.Box.Visible = false
        end

        if esp.BoxOutline then
            esp.BoxOutline.Thickness = 3
            esp.BoxOutline.Filled = false
            esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            esp.BoxOutline.Visible = false
        end

        -- 3D Box (12 lines)
        for i = 1, 12 do
            local l = Drawing.new("Line")
            l.Thickness = 1.4
            l.Color = Color3.fromRGB(255, 255, 255)
            l.Visible = false
            table.insert(esp.Lines3D, l)
        end

        -- Corner Box (8 lines)
        for i = 1, 8 do
            local l = Drawing.new("Line")
            l.Thickness = 1.4
            l.Color = Color3.fromRGB(255, 255, 255)
            l.Visible = false
            table.insert(esp.LinesCorner, l)
        end

        -- Skeleton (14 lines for R15)
        for i = 1, 14 do
            local l = Drawing.new("Line")
            l.Thickness = 1.2
            l.Color = Color3.fromRGB(255, 255, 255)
            l.Visible = false
            table.insert(esp.SkeletonLines, l)
        end

        -- Name Text
        if esp.Name then
            esp.Name.Size = 13
            esp.Name.Center = true
            esp.Name.Outline = true
            esp.Name.Color = Color3.fromRGB(255, 255, 255)
            esp.Name.Visible = false
        end

        -- Distance Text
        if esp.Distance then
            esp.Distance.Size = 11
            esp.Distance.Center = true
            esp.Distance.Outline = true
            esp.Distance.Color = Color3.fromRGB(200, 200, 220)
            esp.Distance.Visible = false
        end

        -- Equipped Item Text
        if esp.EquippedItem then
            esp.EquippedItem.Size = 11
            esp.EquippedItem.Center = true
            esp.EquippedItem.Outline = true
            esp.EquippedItem.Color = Color3.fromRGB(255, 255, 255)
            esp.EquippedItem.Visible = false
        end

        -- Health Bar
        if esp.HealthBarOutline then
            esp.HealthBarOutline.Thickness = 4
            esp.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
            esp.HealthBarOutline.Visible = false
        end

        if esp.HealthBar then
            esp.HealthBar.Thickness = 2
            esp.HealthBar.Visible = false
        end

        -- Health Text
        if esp.HealthText then
            esp.HealthText.Size = 10
            esp.HealthText.Center = false
            esp.HealthText.Outline = true
            esp.HealthText.Color = Color3.fromRGB(255, 255, 255)
            esp.HealthText.Visible = false
        end

        -- Head Dot
        if esp.HeadDot then
            esp.HeadDot.Radius = 3
            esp.HeadDot.Filled = true
            esp.HeadDot.Color = Color3.fromRGB(255, 255, 255)
            esp.HeadDot.Visible = false
        end

        -- Head Dot Glow
        if esp.HeadDotGlow then
            esp.HeadDotGlow.Radius = 6
            esp.HeadDotGlow.Filled = false
            esp.HeadDotGlow.Thickness = 1.5
            esp.HeadDotGlow.Transparency = 0.5
            esp.HeadDotGlow.Color = Color3.fromRGB(255, 255, 255)
            esp.HeadDotGlow.Visible = false
        end

        -- Tracer
        if esp.Tracer then
            esp.Tracer.Thickness = 1.2
            esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
            esp.Tracer.Visible = false
        end
    end

    espObjects[player] = esp
end

for _, p in ipairs(Players:GetPlayers()) do
    createESPForPlayer(p)
end
Players.PlayerAdded:Connect(createESPForPlayer)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        for _, obj in pairs(espObjects[p]) do
            if type(obj) == "table" then
                for _, line in ipairs(obj) do pcall(function() line:Remove() end) end
            else
                pcall(function() obj:Remove() end)
            end
        end
        espObjects[p] = nil
    end
    if chamsObjects[p] then
        pcall(function() chamsObjects[p]:Destroy() end)
        chamsObjects[p] = nil
    end
end)

-- Chams Manager for a character
local function updatePlayerChams(p)
    local char = p.Character
    if not char then return end

    local isSelf = (p == LocalPlayer)
    if isSelf and not (S.ESP.Enabled and (S.Chams.SelfESP or S.ESP.SelfESP)) then
        if chamsObjects[p] then
            pcall(function() chamsObjects[p]:Destroy() end)
            chamsObjects[p] = nil
        end
        return
    end

    local chamsActive = S.ESP.Enabled and S.Chams.Enabled
    if not isSelf and not chamsActive then
        if chamsObjects[p] then
            pcall(function() chamsObjects[p]:Destroy() end)
            chamsObjects[p] = nil
        end
        return
    end

    if not isSelf and S.ESP.TeamCheck and isTeammate(p) then
        if chamsObjects[p] then
            pcall(function() chamsObjects[p]:Destroy() end)
            chamsObjects[p] = nil
        end
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        if chamsObjects[p] then
            pcall(function() chamsObjects[p]:Destroy() end)
            chamsObjects[p] = nil
        end
        return
    end

    local hl = chamsObjects[p]
    if not hl or hl.Parent ~= char then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.Name = "VodkaChams"
        hl.Adornee = char
        hl.Parent = char
        chamsObjects[p] = hl
    end

    if S.Chams.RenderingType == "Occluded" then
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
    else
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    local color = S.Chams.Color or Color3.fromRGB(80, 80, 100)
    if S.Chams.TeamColors or S.ESP.TeamBasedColor then
        color = (p.Team and p.Team.TeamColor.Color) or Color3.fromRGB(255, 60, 60)
    elseif S.ESP.VisibleCheck then
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        local isVis = head and checkWallVisibility(char, head)
        color = isVis and (S.ESP.VisibleColor or Color3.fromRGB(100, 180, 255))
            or (S.ESP.HiddenColor or Color3.fromRGB(255, 40, 40))
    end
    if isSelf then color = Color3.fromRGB(80, 255, 140) end

    hl.Enabled = true
    hl.FillColor = color

    if S.Chams.Mode == "Pulsing" then
        hl.FillTransparency = 0.35 + 0.35 * math.sin(tick() * 5)
        hl.OutlineTransparency = (S.Chams.Outline or S.ESP.Outline) and 0 or 1
    elseif S.Chams.Mode == "Ghost" then
        hl.FillTransparency = 0.8
        hl.OutlineTransparency = 0.3
    elseif S.Chams.Mode == "Wireframe" then
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
    else
        -- "Default"
        hl.FillTransparency = S.Chams.Filled and 0.45 or 1
        hl.OutlineTransparency = (S.Chams.Outline or S.ESP.Outline) and 0 or 1
    end

    hl.OutlineColor = (S.Chams.Glow or S.ESP.Glow) and Color3.fromRGB(255, 255, 255) or (S.Chams.VisibleColor or color)
end

-- Render loop for Visuals
RunService.RenderStepped:Connect(function()
    -- Update Chams for all players + Self ESP
    for _, p in ipairs(Players:GetPlayers()) do
        pcall(function() updatePlayerChams(p) end)
    end

    -- Master Active Check
    local masterOn = S.ESP.Enabled

    if not masterOn then
        for player, esp in pairs(espObjects) do
            if esp.Box then esp.Box.Visible = false end
            if esp.BoxOutline then esp.BoxOutline.Visible = false end
            if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end
            if esp.LinesCorner then for _, l in ipairs(esp.LinesCorner) do l.Visible = false end end
            if esp.SkeletonLines then for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end end
            if esp.Name then esp.Name.Visible = false end
            if esp.Distance then esp.Distance.Visible = false end
            if esp.EquippedItem then esp.EquippedItem.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
            if esp.HealthText then esp.HealthText.Visible = false end
            if esp.HeadDot then esp.HeadDot.Visible = false end
            if esp.HeadDotGlow then esp.HeadDotGlow.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
        end
        return
    end

    -- Update Drawing ESP
    for player, esp in pairs(espObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HitboxHead"))
        local isSelf = (player == LocalPlayer)

        local show = false
        if masterOn and hrp and hum and hum.Health > 0 and head then
            if not isSelf or S.ESP.SelfESP then
                if isSelf or not (S.ESP.TeamCheck and isTeammate(player)) then
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local maxDist = S.ESP.RenderDistance or 3000
                    if dist <= maxDist then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen and screenPos.Z > 0 then
                            show = true

                            local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.4, 0))
                            local btmPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                            local height = math.abs(topPos.Y - btmPos.Y)
                            local width = height * 0.65

                            if S.ESP.SizingType == "Dynamic" then
                                local minX, minY = math.huge, math.huge
                                local maxX, maxY = -math.huge, -math.huge
                                for _, part in ipairs(char:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        local pScreen, onS = Camera:WorldToViewportPoint(part.Position)
                                        if onS and pScreen.Z > 0 then
                                            minX = math.min(minX, pScreen.X)
                                            maxX = math.max(maxX, pScreen.X)
                                            minY = math.min(minY, pScreen.Y)
                                            maxY = math.max(maxY, pScreen.Y)
                                        end
                                    end
                                end
                                if minX < maxX and minY < maxY then
                                    local pad = 10
                                    width = math.clamp((maxX - minX) + pad * 2, 16, 400)
                                    height = math.clamp((maxY - minY) + pad * 2, 24, 600)
                                end
                            elseif S.ESP.SizingType == "Corner" then
                                width = height * 0.6
                            end

                            local isVis = checkWallVisibility(char, head)

                            -- Determine box and accent color
                            local boxColor = S.BoxESP.Color or Color3.fromRGB(255, 255, 255)
                            if S.ESP.VisibleCheck then
                                boxColor = isVis and S.ESP.VisibleColor or S.ESP.HiddenColor
                            elseif S.BoxESP.TeamColors or S.ESP.TeamBasedColor then
                                boxColor = (player.Team and player.Team.TeamColor.Color) or Color3.fromRGB(255, 60, 60)
                            end

                            -- 1. BOX ESP (2D, 3D, Corner)
                            local boxActive = S.BoxESP.Enabled
                            if boxActive then
                                if S.BoxESP.BoxType == "2D" then
                                    if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end
                                    if esp.LinesCorner then for _, l in ipairs(esp.LinesCorner) do l.Visible = false end end

                                    if esp.BoxOutline then
                                        esp.BoxOutline.Visible = (S.BoxESP.Outline or S.ESP.Outline) and not S.BoxESP.FillBox
                                        esp.BoxOutline.Size = Vector2.new(width + 2, height + 2)
                                        esp.BoxOutline.Position = Vector2.new(screenPos.X - width / 2 - 1, screenPos.Y - height / 2 - 1)
                                    end

                                    if esp.Box then
                                        esp.Box.Visible = true
                                        esp.Box.Size = Vector2.new(width, height)
                                        esp.Box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                                        esp.Box.Color = boxColor
                                        esp.Box.Filled = S.BoxESP.FillBox
                                        esp.Box.Transparency = S.BoxESP.FillBox and 0.35 or 1
                                    end
                                elseif S.BoxESP.BoxType == "Corner" then
                                    if esp.Box then esp.Box.Visible = false end
                                    if esp.BoxOutline then esp.BoxOutline.Visible = false end
                                    if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end

                                    local left = screenPos.X - width / 2
                                    local right = screenPos.X + width / 2
                                    local top = screenPos.Y - height / 2
                                    local bottom = screenPos.Y + height / 2
                                    local cornerLen = math.min(width, height) * 0.25

                                    if esp.LinesCorner and #esp.LinesCorner >= 8 then
                                        esp.LinesCorner[1].From = Vector2.new(left, top)
                                        esp.LinesCorner[1].To = Vector2.new(left + cornerLen, top)
                                        esp.LinesCorner[2].From = Vector2.new(left, top)
                                        esp.LinesCorner[2].To = Vector2.new(left, top + cornerLen)

                                        esp.LinesCorner[3].From = Vector2.new(right, top)
                                        esp.LinesCorner[3].To = Vector2.new(right - cornerLen, top)
                                        esp.LinesCorner[4].From = Vector2.new(right, top)
                                        esp.LinesCorner[4].To = Vector2.new(right, top + cornerLen)

                                        esp.LinesCorner[5].From = Vector2.new(left, bottom)
                                        esp.LinesCorner[5].To = Vector2.new(left + cornerLen, bottom)
                                        esp.LinesCorner[6].From = Vector2.new(left, bottom)
                                        esp.LinesCorner[6].To = Vector2.new(left, bottom - cornerLen)

                                        esp.LinesCorner[7].From = Vector2.new(right, bottom)
                                        esp.LinesCorner[7].To = Vector2.new(right - cornerLen, bottom)
                                        esp.LinesCorner[8].From = Vector2.new(right, bottom)
                                        esp.LinesCorner[8].To = Vector2.new(right, bottom - cornerLen)

                                        for _, l in ipairs(esp.LinesCorner) do
                                            l.Color = boxColor
                                            l.Visible = true
                                        end
                                    end
                                else
                                    -- 3D Box
                                    if esp.Box then esp.Box.Visible = false end
                                    if esp.BoxOutline then esp.BoxOutline.Visible = false end
                                    if esp.LinesCorner then for _, l in ipairs(esp.LinesCorner) do l.Visible = false end end

                                    local cf = hrp.CFrame
                                    local size = Vector3.new(3, 5, 2.5)
                                    local sx, sy, sz = size.X / 2, size.Y / 2, size.Z / 2
                                    local corners = {
                                        cf * Vector3.new(-sx, -sy, -sz),
                                        cf * Vector3.new(sx, -sy, -sz),
                                        cf * Vector3.new(sx, sy, -sz),
                                        cf * Vector3.new(-sx, sy, -sz),
                                        cf * Vector3.new(-sx, -sy, sz),
                                        cf * Vector3.new(sx, -sy, sz),
                                        cf * Vector3.new(sx, sy, sz),
                                        cf * Vector3.new(-sx, sy, sz)
                                    }

                                    local screenCorners = {}
                                    local allOnScreen = true
                                    for i, c in ipairs(corners) do
                                        local p2d, onS = Camera:WorldToViewportPoint(c)
                                        if not onS or p2d.Z <= 0 then allOnScreen = false break end
                                        screenCorners[i] = Vector2.new(p2d.X, p2d.Y)
                                    end

                                    if allOnScreen and esp.Lines3D and #esp.Lines3D >= 12 then
                                        local edges = {
                                            {1, 2}, {2, 3}, {3, 4}, {4, 1},
                                            {5, 6}, {6, 7}, {7, 8}, {8, 5},
                                            {1, 5}, {2, 6}, {3, 7}, {4, 8}
                                        }
                                        for i, edge in ipairs(edges) do
                                            local line = esp.Lines3D[i]
                                            if line then
                                                line.From = screenCorners[edge[1]]
                                                line.To = screenCorners[edge[2]]
                                                line.Color = boxColor
                                                line.Visible = true
                                            end
                                        end
                                    else
                                        if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end
                                    end
                                end
                            else
                                if esp.Box then esp.Box.Visible = false end
                                if esp.BoxOutline then esp.BoxOutline.Visible = false end
                                if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end
                                if esp.LinesCorner then for _, l in ipairs(esp.LinesCorner) do l.Visible = false end end
                            end

                            -- 2. SKELETON ESP
                            if esp.SkeletonLines then
                                local skelActive = S.Indicators.Skeleton
                                if skelActive then
                                    local skelColor = S.Indicators.SkeletonColor or Color3.fromRGB(255, 255, 255)
                                    if S.ESP.VisibleCheck then
                                        skelColor = isVis and S.ESP.VisibleColor or S.ESP.HiddenColor
                                    elseif S.ESP.TeamBasedColor then
                                        skelColor = (player.Team and player.Team.TeamColor.Color) or Color3.fromRGB(255, 60, 60)
                                    end

                                    local isR15 = hum.RigType == Enum.HumanoidRigType.R15 or char:FindFirstChild("UpperTorso") ~= nil
                                    local joints = isR15 and R15_JOINTS or R6_JOINTS

                                    for i, line in ipairs(esp.SkeletonLines) do
                                        local pair = joints[i]
                                        if pair then
                                            local p1 = char:FindFirstChild(pair[1])
                                            local p2 = char:FindFirstChild(pair[2])
                                            if p1 and p2 then
                                                local p1Screen, p1Vis = Camera:WorldToViewportPoint(p1.Position)
                                                local p2Screen, p2Vis = Camera:WorldToViewportPoint(p2.Position)
                                                if (p1Vis or p2Vis) and p1Screen.Z > 0 and p2Screen.Z > 0 then
                                                    line.From = Vector2.new(p1Screen.X, p1Screen.Y)
                                                    line.To = Vector2.new(p2Screen.X, p2Screen.Y)
                                                    line.Color = skelColor
                                                    line.Visible = true
                                                else
                                                    line.Visible = false
                                                end
                                            else
                                                line.Visible = false
                                            end
                                        else
                                            line.Visible = false
                                        end
                                    end
                                else
                                    for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                                end
                            end

                            -- 3. NAME ESP
                            local nameActive = S.NameESP.Enabled
                            if esp.Name then
                                esp.Name.Visible = nameActive
                                if nameActive then
                                    local nameText = player.Name
                                    if S.NameESP.Type == "Display Name" then
                                        nameText = player.DisplayName or player.Name
                                    elseif S.NameESP.Type == "Both" then
                                        nameText = (player.DisplayName or player.Name) .. " (@" .. player.Name .. ")"
                                    end
                                    esp.Name.Text = nameText
                                    esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - height / 2 - 15)
                                    esp.Name.Outline = S.NameESP.Outline or S.ESP.Outline
                                    if S.NameESP.TeamColors or S.ESP.TeamBasedColor then
                                        esp.Name.Color = (player.Team and player.Team.TeamColor.Color) or Color3.fromRGB(240, 240, 255)
                                    else
                                        esp.Name.Color = S.NameESP.Color or Color3.fromRGB(240, 240, 255)
                                    end
                                end
                            end

                            -- 4. DISTANCE ESP
                            local distActive = S.Indicators.Distance or S.NameESP.Distance
                            if esp.Distance then
                                esp.Distance.Visible = distActive
                                if distActive then
                                    esp.Distance.Text = math.floor(dist) .. " studs"
                                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + height / 2 + 3)
                                    esp.Distance.Outline = S.NameESP.Outline or S.ESP.Outline
                                    esp.Distance.Color = S.Indicators.DistanceColor or Color3.fromRGB(200, 200, 220)
                                end
                            end

                            -- 5. EQUIPPED ITEM ESP
                            if esp.EquippedItem then
                                esp.EquippedItem.Visible = S.Indicators.EquippedItem
                                if S.Indicators.EquippedItem then
                                    local tool = char:FindFirstChildOfClass("Tool")
                                    esp.EquippedItem.Text = tool and tool.Name or "Hands"
                                    local yOff = distActive and (height / 2 + 16) or (height / 2 + 3)
                                    esp.EquippedItem.Position = Vector2.new(screenPos.X, screenPos.Y + yOff)
                                    esp.EquippedItem.Outline = S.ESP.Outline
                                    esp.EquippedItem.Color = S.Indicators.EquippedColor or Color3.fromRGB(255, 255, 255)
                                end
                            end

                            -- 6. HEAD DOT & HEAD DOT GLOW
                            if esp.HeadDot then
                                local hdActive = S.Indicators.HeadDot
                                if hdActive then
                                    local headPos2D, hOnScreen = Camera:WorldToViewportPoint(head.Position)
                                    if hOnScreen and headPos2D.Z > 0 then
                                        local hdPos = Vector2.new(headPos2D.X, headPos2D.Y)
                                        local hdColor = S.Indicators.HeadDotColor or Color3.fromRGB(255, 255, 255)
                                        if S.ESP.VisibleCheck then
                                            hdColor = isVis and S.ESP.VisibleColor or S.ESP.HiddenColor
                                        end

                                        esp.HeadDot.Position = hdPos
                                        esp.HeadDot.Color = hdColor
                                        esp.HeadDot.Visible = true

                                        if esp.HeadDotGlow then
                                            if S.Indicators.HeadDotGlow then
                                                esp.HeadDotGlow.Position = hdPos
                                                esp.HeadDotGlow.Color = hdColor
                                                esp.HeadDotGlow.Visible = true
                                            else
                                                esp.HeadDotGlow.Visible = false
                                            end
                                        end
                                    else
                                        esp.HeadDot.Visible = false
                                        if esp.HeadDotGlow then esp.HeadDotGlow.Visible = false end
                                    end
                                else
                                    esp.HeadDot.Visible = false
                                    if esp.HeadDotGlow then esp.HeadDotGlow.Visible = false end
                                end
                            end

                            -- 7. HEALTH BAR & TEXT
                            local hpActive = S.Health.HealthBar or S.NameESP.HealthBar
                            local hpPct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                            local barX = screenPos.X - width / 2 - 6

                            if esp.HealthBarOutline then
                                esp.HealthBarOutline.Visible = hpActive and (S.NameESP.Outline or S.ESP.Outline)
                                esp.HealthBarOutline.From = Vector2.new(barX, screenPos.Y + height / 2 + 1)
                                esp.HealthBarOutline.To = Vector2.new(barX, screenPos.Y - height / 2 - 1)
                            end

                            if esp.HealthBar then
                                esp.HealthBar.Visible = hpActive
                                if hpActive then
                                    esp.HealthBar.From = Vector2.new(barX, screenPos.Y + height / 2)
                                    esp.HealthBar.To = Vector2.new(barX, screenPos.Y + height / 2 - (height * hpPct))
                                    if S.Health.HealthBased then
                                        esp.HealthBar.Color = Color3.fromHSV(hpPct * 0.33, 0.9, 1)
                                    else
                                        esp.HealthBar.Color = S.Health.Color or Color3.fromRGB(0, 255, 40)
                                    end
                                end
                            end

                            if esp.HealthText then
                                esp.HealthText.Visible = S.Health.HealthText
                                if S.Health.HealthText then
                                    esp.HealthText.Text = math.floor(hum.Health) .. " HP"
                                    esp.HealthText.Outline = S.ESP.Outline
                                    esp.HealthText.Color = S.Health.Color or Color3.fromRGB(0, 255, 40)
                                    if S.Health.TextPos == "Above Name" then
                                        esp.HealthText.Position = Vector2.new(screenPos.X, screenPos.Y - height / 2 - 28)
                                        esp.HealthText.Center = true
                                    elseif S.Health.TextPos == "Below Name" then
                                        esp.HealthText.Position = Vector2.new(screenPos.X, screenPos.Y - height / 2 - 3)
                                        esp.HealthText.Center = true
                                    else
                                        esp.HealthText.Position = Vector2.new(barX - 35, screenPos.Y + height / 2 - (height * hpPct) - 6)
                                        esp.HealthText.Center = false
                                    end
                                end
                            end

                            -- 8. TRACERS
                            if esp.Tracer then
                                esp.Tracer.Visible = S.Tracers.Enabled
                                if S.Tracers.Enabled then
                                    local origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                                    if S.Tracers.TracersOrigin == "Top" then
                                        origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                                    elseif S.Tracers.TracersOrigin == "Center" then
                                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                    elseif S.Tracers.TracersOrigin == "Bottom" then
                                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    elseif S.Tracers.TracersOrigin == "Mouse" then
                                        origin = UserInputService:GetMouseLocation()
                                    end
                                    esp.Tracer.From = origin
                                    esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y + height / 2)
                                    if S.Tracers.TeamColors or S.ESP.TeamBasedColor then
                                        esp.Tracer.Color = (player.Team and player.Team.TeamColor.Color) or Color3.fromRGB(255, 60, 60)
                                    elseif S.ESP.VisibleCheck then
                                        esp.Tracer.Color = isVis and S.ESP.VisibleColor or S.ESP.HiddenColor
                                    else
                                        esp.Tracer.Color = S.Tracers.Color or Color3.fromRGB(255, 255, 255)
                                    end
                                end
                            end
                        end -- end if onScreen and screenPos.Z > 0
                    end -- end if dist <= maxDist
                end -- end if isSelf or not (S.ESP.TeamCheck and isTeammate(player))
            end -- end if not isSelf or S.ESP.SelfESP
        end -- end if masterOn and hrp and hum and hum.Health > 0 and head

        if not show then
            if esp.Box then esp.Box.Visible = false end
            if esp.BoxOutline then esp.BoxOutline.Visible = false end
            if esp.Lines3D then for _, l in ipairs(esp.Lines3D) do l.Visible = false end end
            if esp.LinesCorner then for _, l in ipairs(esp.LinesCorner) do l.Visible = false end end
            if esp.SkeletonLines then for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end end
            if esp.Name then esp.Name.Visible = false end
            if esp.Distance then esp.Distance.Visible = false end
            if esp.EquippedItem then esp.EquippedItem.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
            if esp.HealthText then esp.HealthText.Visible = false end
            if esp.HeadDot then esp.HeadDot.Visible = false end
            if esp.HeadDotGlow then esp.HeadDotGlow.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
        end
    end -- end for player, esp in pairs(espObjects)
end)

---------------------------------------------------------------------
-- PLAYER ENHANCEMENTS (WALKSPEED, JUMPPOWER, FLY, NOCLIP)
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if S.WalkSpeedToggle then hum.WalkSpeed = S.WalkSpeed end
        if S.JumpPowerToggle then
            hum.UseJumpPower = true
            hum.JumpPower = S.JumpPower
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if S.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)

-- Fly
local flyBV = nil
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if S.Fly then
            if not flyBV or flyBV.Parent ~= hrp then
                if flyBV then flyBV:Destroy() end
                flyBV = Instance.new("BodyVelocity")
                flyBV.Name = "VodkaFlyBV"
                flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBV.Parent = hrp
            end

            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            flyBV.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * S.FlySpeed) or Vector3.zero
        elseif flyBV then
            flyBV:Destroy()
            flyBV = nil
        end
    end
end)

---------------------------------------------------------------------
-- TEARDOWN HANDLER
---------------------------------------------------------------------
_G.VodkaHubCleanup = function()
    pcall(function() ScreenGui:Destroy() end)
    pcall(function()
        if aimbotFovDrawing then aimbotFovDrawing:Remove(); aimbotFovDrawing = nil end
        if silentFovDrawing then silentFovDrawing:Remove(); silentFovDrawing = nil end
        if targetFovDrawing then targetFovDrawing:Remove(); targetFovDrawing = nil end
    end)
    for _, esp in pairs(espObjects) do
        for _, d in pairs(esp) do
            if type(d) == "table" then
                for _, line in ipairs(d) do pcall(function() line:Remove() end) end
            else
                pcall(function() d:Remove() end)
            end
        end
    end
    table.clear(espObjects)
    for _, hl in pairs(chamsObjects) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(chamsObjects)
    for part, orig in pairs(originalHitboxes) do
        if part and part.Parent then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
            end)
        end
    end
    table.clear(originalHitboxes)
    if flyBV then flyBV:Destroy(); flyBV = nil end
end

print("[VodkaHub] Loaded successfully!")
return true