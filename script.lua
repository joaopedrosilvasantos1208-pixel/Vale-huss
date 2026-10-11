local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer

local State = {
    AutoDodge = false, FastDodge = false, DodgeDistance = 16, ReactionSpeed = 0.05,
    AutoStop = false, AutoVault = false, AutoSlide = false, DodgeDir = 2,
    AutoEscape = false, AutoGem = false, Sprint = false, SprintValue = 24,
    AutoCatch = false, CatchRange = 25, AimAssist = false, AimSmooth = 0.35,
    AutoAttack = false, AttackRange = 10, KillAura = false, KillAuraRange = 12,
    ShowChaser = false, ShowRunners = false, ShowDistances = false,
    AntiAFK = false, NoClip = false, PerfMode = false, TrainingMode = false,
    EffectsOn = true, MovementIndicator = true,
}

local gui = Instance.new("ScreenGui")
gui.Name = "ValeHussUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr:WaitForChild("PlayerGui")

local NEON = Color3.fromRGB(0, 255, 130)
local NEON_DIM = Color3.fromRGB(0, 150, 80)
local BG = Color3.fromRGB(10, 10, 10)
local BG2 = Color3.fromRGB(18, 18, 18)
local TXT = Color3.fromRGB(230, 255, 240)
local TXT_DIM = Color3.fromRGB(150, 200, 170)
local DANGER = Color3.fromRGB(255, 70, 70)

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 10)
    c.Parent = p
    return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or NEON
    s.Thickness = thick or 1.5
    s.Transparency = trans or 0.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- ==================== BOTÃO FLUTUANTE (ABRIR) ====================
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.fromOffset(52, 52)
openBtn.Position = UDim2.new(0, 15, 0.5, -26)
openBtn.BackgroundColor3 = BG
openBtn.BorderSizePixel = 0
openBtn.Text = "☰"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 22
openBtn.TextColor3 = NEON
openBtn.AutoButtonColor = false
openBtn.Visible = false
openBtn.Parent = gui
corner(openBtn, UDim.new(0, 14))
stroke(openBtn, NEON, 2, 0.15)

local openGlow = Instance.new("UIGradient")
openGlow.Rotation = 90
openGlow.Color = ColorSequence.new(BG, BG2)
openGlow.Parent = openBtn

local openDot = Instance.new("Frame")
openDot.Size = UDim2.fromOffset(6, 6)
openDot.Position = UDim2.new(1, -12, 1, -12)
openDot.BackgroundColor3 = NEON
openDot.BorderSizePixel = 0
openDot.Parent = openBtn
corner(openDot, UDim.new(1, 0))

-- ==================== JANELA PRINCIPAL ====================
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(340, 480)
root.Position = UDim2.new(0.5, -170, 0.5, -240)
root.BackgroundColor3 = BG
root.BackgroundTransparency = 0.1
root.BorderSizePixel = 0
root.Active = true
root.Parent = gui
corner(root, UDim.new(0, 14))
stroke(root, NEON, 2, 0.15)

local rootGrad = Instance.new("UIGradient")
rootGrad.Rotation = 90
rootGrad.Color = ColorSequence.new(BG, BG2)
rootGrad.Parent = root

local uiscale = Instance.new("UIScale")
uiscale.Scale = 1
uiscale.Parent = root

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
topBar.BackgroundTransparency = 0.05
topBar.BorderSizePixel = 0
topBar.Parent = root
corner(topBar, UDim.new(0, 12))
stroke(topBar, NEON, 1, 0.3)

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(10, 10)
dot.Position = UDim2.new(0, 12, 0.5, -5)
dot.BackgroundColor3 = NEON
dot.BorderSizePixel = 0
dot.Parent = topBar
corner(dot, UDim.new(1, 0))

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -150, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VALE HUSS"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = NEON
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local function topBtn(txt, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(26, 26)
    b.Position = UDim2.new(1, xOff, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.BorderSizePixel = 0
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = color or NEON
    b.AutoButtonColor = false
    b.Parent = topBar
    corner(b, UDim.new(0, 8))
    stroke(b, color or NEON, 1, 0.4)
    return b
end

local btnMin = topBtn("—", -94)
local btnHide = topBtn("▢", -62)
local btnClose = topBtn("✕", -30, DANGER)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 34)
tabBar.Position = UDim2.new(0, 10, 0, 50)
tabBar.BackgroundTransparency = 1
tabBar.Parent = root

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local tabs = {}
local tabNames = {
    { key = "Runner",   label = "🏃" },
    { key = "Chaser",   label = "🔪" },
    { key = "Visual",   label = "👁" },
    { key = "Utility",  label = "🛠" },
    { key = "Settings", label = "⚙" },
}

for i, info in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.2, -4, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.BorderSizePixel = 0
    b.Text = info.label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = TXT_DIM
    b.AutoButtonColor = false
    b.LayoutOrder = i
    b.Parent = tabBar
    corner(b, UDim.new(0, 8))
    local s = stroke(b, NEON_DIM, 1, 0.6)
    tabs[info.key] = { btn = b, stroke = s }
end

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -150)
content.Position = UDim2.new(0, 10, 0, 92)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.Parent = root

local pages = {}
for _, info in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = NEON_DIM
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 3)
    pad.Parent = page
    pages[info.key] = page
end

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 22)
statusBar.Position = UDim2.new(0, 10, 1, -28)
statusBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
statusBar.BackgroundTransparency = 0.2
statusBar.BorderSizePixel = 0
statusBar.Parent = root
corner(statusBar, UDim.new(0, 6))
stroke(statusBar, NEON_DIM, 1, 0.6)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -10, 1, 0)
statusLbl.Position = UDim2.new(0, 8, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "● Sistema pronto"
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextSize = 10
statusLbl.TextColor3 = NEON
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = statusBar

local function setStatus(t, c)
    statusLbl.Text = "● " .. t
    statusLbl.TextColor3 = c or NEON
end

local function selectTab(key)
    for k, data in pairs(tabs) do
        local active = (k == key)
        data.btn.TextColor3 = active and NEON or TXT_DIM
        data.btn.BackgroundColor3 = active and Color3.fromRGB(0, 30, 18) or Color3.fromRGB(22, 22, 22)
        data.stroke.Transparency = active and 0.1 or 0.6
        pages[k].Visible = active
    end
end

for k, data in pairs(tabs) do
    data.btn.MouseButton1Click:Connect(function()
        selectTab(k)
    end)
end

local function makeToggle(page, label, default, cb, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.Parent = page
    corner(row, UDim.new(0, 8))
    stroke(row, NEON_DIM, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -66, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(46, 20)
    btn.Position = UDim2.new(1, -54, 0.5, -10)
    btn.BackgroundColor3 = default and NEON or Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = default and Color3.fromRGB(0, 0, 0) or TXT_DIM
    btn.AutoButtonColor = false
    btn.Parent = row
    corner(btn, UDim.new(0, 10))
    stroke(btn, NEON, 1, default and 0 or 0.5)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and NEON or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = state and Color3.fromRGB(0, 0, 0) or TXT_DIM
        if cb then cb(state) end
    end)
    return { row = row, set = function(v)
        state = v
        btn.Text = v and "ON" or "OFF"
        btn.BackgroundColor3 = v and NEON or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = v and Color3.fromRGB(0,0,0) or TXT_DIM
    end }
end

local function makeSlider(page, label, min, max, default, cb, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.Parent = page
    corner(row, UDim.new(0, 8))
    stroke(row, NEON_DIM, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -66, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 56, 0, 16)
    valLbl.Position = UDim2.new(1, -62, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.1f", default)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = NEON
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 1, -18)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bar.BorderSizePixel = 0
    bar.Parent = row
    corner(bar, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = NEON
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, UDim.new(1, 0))

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local val = min + (max - min) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = string.format("%.1f", val)
        if cb then cb(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return { row = row, setVal = function(v)
        local rel = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = string.format("%.1f", v)
    end }
end

local function makeButton(page, label, cb, danger, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = danger and Color3.fromRGB(45, 12, 12) or Color3.fromRGB(18, 30, 24)
    b.BorderSizePixel = 0
    b.Text = label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.TextColor3 = danger and DANGER or NEON
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    b.Parent = page
    corner(b, UDim.new(0, 8))
    stroke(b, danger and DANGER or NEON, 1, 0.4)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

local function makeSection(page, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    f.Parent = page
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "▸ " .. text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = NEON
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function isChaserPlayer(p)
    local char = p.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("knife") or n:find("faca") or n:find("blade") then
                return true
            end
        end
    end
    local backpack = p:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            local n = item.Name:lower()
            if n:find("knife") or n:find("faca") or n:find("blade") then
                return true
            end
        end
    end
    return false
end

local function getCharacter()
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then return char, hrp, hum end
    return nil
end

-- ==================== RUNNER TAB ====================
makeSection(pages.Runner, "ESQUIVA", 1)
local tgAutoDodge = makeToggle(pages.Runner, "Auto Dodge", false, function(v)
    State.AutoDodge = v
    setStatus(v and "Auto Dodge ATIVO" or "Auto Dodge OFF")
end, 2)
local tgFastDodge = makeToggle(pages.Runner, "Fast Dodge", false, function(v)
    State.FastDodge = v
    if v and not State.AutoDodge then
        tgAutoDodge.set(true); State.AutoDodge = true
    end
    setStatus(v and "Fast Dodge ATIVO" or "Fast Dodge OFF")
end, 3)
makeSlider(pages.Runner, "Dodge Distance", 6, 40, 16, function(v) State.DodgeDistance = v end, 4)
makeSlider(pages.Runner, "Reaction Speed", 0.01, 0.3, 0.05, function(v) State.ReactionSpeed = v end, 5)
makeToggle(pages.Runner, "Auto Stop", false, function(v) State.AutoStop = v end, 6)
makeToggle(pages.Runner, "Auto Vault", false, function(v) State.AutoVault = v end, 7)
makeToggle(pages.Runner, "Auto Slide", false, function(v) State.AutoSlide = v end, 8)
makeSlider(pages.Runner, "Dodge Direction (0/1/2)", 0, 2, 2, function(v) State.DodgeDir = math.floor(v + 0.5) end, 9)

makeSection(pages.Runner, "SOBREVIVÊNCIA", 10)
makeToggle(pages.Runner, "Auto Escape", false, function(v) State.AutoEscape = v end, 11)
makeToggle(pages.Runner, "Auto Coletar Gems", false, function(v) State.AutoGem = v end, 12)
makeToggle(pages.Runner, "Sprint Boost", false, function(v)
    State.Sprint = v
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = v and State.SprintValue or 16 end
end, 13)
makeSlider(pages.Runner, "Sprint Speed", 16, 40, 24, function(v)
    State.SprintValue = v
    if State.Sprint then
        local _, _, hum = getCharacter()
        if hum then hum.WalkSpeed = v end
    end
end, 14)
makeToggle(pages.Runner, "Movement Indicator", true, function(v) State.MovementIndicator = v end, 15)
makeButton(pages.Runner, "↺ Reset Runner", function()
    State.AutoDodge = false; State.FastDodge = false; State.AutoStop = false
    State.AutoVault = false; State.AutoSlide = false; State.AutoEscape = false
    State.AutoGem = false; State.Sprint = false
    State.DodgeDistance = 16; State.ReactionSpeed = 0.05; State.DodgeDir = 2
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = 16 end
    tgAutoDodge.set(false); tgFastDodge.set(false)
    setStatus("Runner resetado")
end, false, 16)

-- ==================== CHASER TAB ====================
makeSection(pages.Chaser, "PERSEGUIÇÃO", 1)
makeToggle(pages.Chaser, "Auto Catch", false, function(v) State.AutoCatch = v end, 2)
makeSlider(pages.Chaser, "Catch Range", 10, 60, 25, function(v) State.CatchRange = v end, 3)
makeToggle(pages.Chaser, "Aim Assist", false, function(v) State.AimAssist = v end, 4)
makeSlider(pages.Chaser, "Aim Smoothness", 0.05, 1, 0.35, function(v) State.AimSmooth = v end, 5)
makeToggle(pages.Chaser, "Auto Attack", false, function(v) State.AutoAttack = v end, 6)
makeSlider(pages.Chaser, "Attack Range", 4, 20, 10, function(v) State.AttackRange = v end, 7)
makeToggle(pages.Chaser, "Kill Aura", false, function(v) State.KillAura = v end, 8)
makeSlider(pages.Chaser, "Kill Aura Range", 4, 30, 12, function(v) State.KillAuraRange = v end, 9)
makeButton(pages.Chaser, "↺ Reset Chaser", function()
    State.AutoCatch = false; State.AimAssist = false; State.AutoAttack = false
    State.KillAura = false
    State.CatchRange = 25; State.AimSmooth = 0.35; State.AttackRange = 10; State.KillAuraRange = 12
    setStatus("Chaser resetado")
end, false, 10)

-- ==================== VISUAL TAB ====================
local highlights = {}
local markers = {}

local function clearVisual()
    for i, h in pairs(highlights) do if h and h.Parent then h:Destroy() end end
    for i, m in pairs(markers) do if m.gui and m.gui.Parent then m.gui:Destroy() end end
    highlights = {}
    markers = {}
end

local function addHighlight(inst, color)
    if highlights[inst] then return end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0.15
    h.DepthMode = Enum.HighlightDepthMode.Occluded
    h.Adornee = inst
    h.Parent = inst
    highlights[inst] = h
end

local function addDistanceMarker(inst, color)
    if markers[inst] then return end
    local part = inst:IsA("BasePart") and inst or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(80, 18)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = color
    l.TextStrokeTransparency = 0.4
    l.Text = "-- m"
    l.Parent = bb
    markers[inst] = { gui = bb, label = l, part = part }
end

local function refreshVisual()
    clearVisual()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local char = p.Character
            if char then
                local chaser = isChaserPlayer(p)
                if State.ShowChaser and chaser then
                    addHighlight(char, DANGER)
                    if State.ShowDistances then addDistanceMarker(char, DANGER) end
                elseif State.ShowRunners and not chaser then
                    addHighlight(char, NEON)
                    if State.ShowDistances then addDistanceMarker(char, NEON) end
                end
            end
        end
    end
end

makeSection(pages.Visual, "VISUAL", 1)
makeToggle(pages.Visual, "Destacar Chaser", false, function(v) State.ShowChaser = v; refreshVisual() end, 2)
makeToggle(pages.Visual, "Destacar Runners", false, function(v) State.ShowRunners = v; refreshVisual() end, 3)
makeToggle(pages.Visual, "Mostrar Distâncias", false, function(v) State.ShowDistances = v; refreshVisual() end, 4)
makeButton(pages.Visual, "🔄 Atualizar", function() refreshVisual(); setStatus("Marcadores atualizados") end, false, 5)
makeButton(pages.Visual, "🧹 Limpar", function() clearVisual(); setStatus("Destaques limpos") end, false, 6)

-- ==================== UTILITY TAB ====================
makeSection(pages.Utility, "UTILIDADES", 1)
makeToggle(pages.Utility, "Anti-AFK", false, function(v) State.AntiAFK = v end, 2)
makeToggle(pages.Utility, "No-Clip", false, function(v) State.NoClip = v end, 3)
makeToggle(pages.Utility, "Modo Performance", false, function(v)
    State.PerfMode = v
    Lighting.GlobalShadows = not v
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") then e.Enabled = not v end
    end
    setStatus(v and "Performance ON" or "Performance OFF")
end, 4)
makeToggle(pages.Utility, "Modo Treinamento", false, function(v)
    State.TrainingMode = v
    if v then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 120, 100)
        setStatus("Treinamento ATIVO")
    else
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        setStatus("Treinamento OFF")
    end
end, 5)

makeSection(pages.Utility, "AÇÕES", 6)
makeButton(pages.Utility, "📍 Teleportar p/ Spawn", function()
    local _, hrp = getCharacter()
    if hrp then hrp.CFrame = CFrame.new(0, 5, 0) end
    setStatus("Teleportado")
end, false, 7)
makeButton(pages.Utility, "🎬 Centralizar Câmera", function()
    local _, hrp = getCharacter()
    local cam = Workspace.CurrentCamera
    if hrp and cam then
        cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 8, 12), hrp.Position)
    end
    setStatus("Câmera reposicionada")
end, false, 8)
makeButton(pages.Utility, "🔧 Restaurar Interface", function()
    root.Size = UDim2.fromOffset(340, 480)
    root.Position = UDim2.new(0.5, -170, 0.5, -240)
    uiscale.Scale = 1
    root.BackgroundTransparency = 0.1
    setStatus("Interface restaurada")
end, false, 9)
makeButton(pages.Utility, "♻ Redefinir Tudo", function()
    clearVisual()
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = 16 end
    setStatus("Tudo redefinido")
end, true, 10)

-- ==================== SETTINGS TAB ====================
makeSection(pages.Settings, "CONFIGURAÇÕES", 1)
makeSlider(pages.Settings, "Transparência", 0, 0.7, 0.1, function(v)
    root.BackgroundTransparency = v
end, 2)
makeSlider(pages.Settings, "Brilho Verde", 0.5, 1.5, 1.0, function(v)
    local c = Color3.new(
        math.clamp(NEON.R * v, 0, 1),
        math.clamp(NEON.G * v, 0, 1),
        math.clamp(NEON.B * v, 0, 1)
    )
    title.TextColor3 = c
    statusLbl.TextColor3 = c
end, 3)
makeSlider(pages.Settings, "Tamanho UI", 0.7, 1.4, 1.0, function(v)
    uiscale.Scale = v
end, 4)
makeToggle(pages.Settings, "Animações", true, function(v) State.EffectsOn = v end, 5)
makeButton(pages.Settings, "↺ Restaurar Padrões", function()
    uiscale.Scale = 1
    root.BackgroundTransparency = 0.1
    root.Size = UDim2.fromOffset(340, 480)
    root.Position = UDim2.new(0.5, -170, 0.5, -240)
    title.TextColor3 = NEON
    statusLbl.TextColor3 = NEON
    setStatus("Padrões restaurados")
end, true, 6)

-- ==================== DRAG ====================
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== MINIMIZAR / FECHAR / OCULTAR ====================
local minimized = false

local function applyMinimize(state)
    minimized = state
    TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = state and UDim2.fromOffset(340, 44) or UDim2.fromOffset(340, 480)
    }):Play()
    content.Visible = not state
    tabBar.Visible = not state
    statusBar.Visible = not state
    btnMin.Text = state and "▢" or "—"
end

btnMin.MouseButton1Click:Connect(function()
    applyMinimize(not minimized)
end)

btnHide.MouseButton1Click:Connect(function()
    root.Visible = false
    openBtn.Visible = true
    setStatus("Painel oculto")
end)

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

openBtn.MouseButton1Click:Connect(function()
    root.Visible = true
    openBtn.Visible = false
    if State.EffectsOn then
        root.Size = UDim2.fromOffset(20, 20)
        TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = minimized and UDim2.fromOffset(340, 44) or UDim2.fromOffset(340, 480)
        }):Play()
    else
        root.Size = minimized and UDim2.fromOffset(340, 44) or UDim2.fromOffset(340, 480)
    end
    setStatus("Painel aberto")
end)

-- ==================== MOVEMENT LOGIC ====================
local lastDodge = 0
local lastAttack = 0
local moveIndicator = nil

local function attachMoveIndicator(char)
    if moveIndicator then moveIndicator:Destroy() end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(90, 18)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = NEON
    l.TextStrokeTransparency = 0.4
    l.Text = "MOV: OFF"
    l.Parent = bb
    moveIndicator = bb
end

local function getClosestChaser(hrp)
    local closest, closestDist = nil, State.DodgeDistance
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and isChaserPlayer(p) then
            local cChar = p.Character
            local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
            if cHrp then
                local d = (hrp.Position - cHrp.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = cHrp
                end
            end
        end
    end
    return closest, closestDist
end

local function isSafeDirection(hrp, dir)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { plr.Character }
    local result = Workspace:Raycast(hrp.Position, dir * 6, params)
    return result == nil
end

RunService.Heartbeat:Connect(function()
    local char, hrp, hum = getCharacter()
    if not char then
        if moveIndicator then moveIndicator:Destroy(); moveIndicator = nil end
        return
    end

    if State.AntiAFK and hum then
        hum.Jump = true
        hum.Jump = false
    end

    if State.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if State.MovementIndicator and not moveIndicator then
        attachMoveIndicator(char)
    elseif not State.MovementIndicator and moveIndicator then
        moveIndicator:Destroy(); moveIndicator = nil
    end

    if State.AutoDodge then
        local chaserHrp = getClosestChaser(hrp)
        if chaserHrp then
            local now = tick()
            if now - lastDodge >= State.ReactionSpeed then
                lastDodge = now
                local dir = (hrp.Position - chaserHrp.Position)
                dir = Vector3.new(dir.X, 0, dir.Z)
                if dir.Magnitude > 0.1 then
                    dir = dir.Unit
                    local perp = Vector3.new(-dir.Z, 0, dir.X)
                    local options
                    if State.DodgeDir == 0 then options = { perp }
                    elseif State.DodgeDir == 1 then options = { -perp }
                    else
                        options = { perp, -perp }
                        if math.random() < 0.5 then options[1], options[2] = options[2], options[1] end
                    end

                    for _, d in ipairs(options) do
                        if isSafeDirection(hrp, d) then
                            local strength = State.FastDodge and 40 or 25
                            hrp.AssemblyLinearVelocity = Vector3.new(d.X * strength, hrp.AssemblyLinearVelocity.Y, d.Z * strength)
                            break
                        end
                    end
                end
            end
            if moveIndicator then
                local l = moveIndicator:FindFirstChildOfClass("TextLabel")
                if l then l.Text = "MOV: DODGE" end
            end
        else
            if moveIndicator then
                local l = moveIndicator:FindFirstChildOfClass("TextLabel")
                if l then l.Text = "MOV: ON" end
            end
        end
    else
        if moveIndicator then
            local l = moveIndicator:FindFirstChildOfClass("TextLabel")
            if l then l.Text = "MOV: OFF" end
        end
    end

    if State.AutoEscape and hum and not State.AutoCatch then
        local cam = Workspace.CurrentCamera
        local dir = cam and cam.CFrame.LookVector or Vector3.new(0,0,-1)
        hum:Move(Vector3.new(dir.X, 0, dir.Z), false)
    end

    if State.AutoCatch and hum then
        local closest, closestDist = nil, State.CatchRange
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and not isChaserPlayer(p) then
                local cChar = p.Character
                local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
                if cHrp then
                    local d = (hrp.Position - cHrp.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = cHrp
                    end
                end
            end
        end
        if closest then
            local dir = (closest.Position - hrp.Position)
            dir = Vector3.new(dir.X, 0, dir.Z)
            if dir.Magnitude > 0.1 then
                hum:Move(dir.Unit, false)
            end
        end
    end

    if State.AimAssist then
        local cam = Workspace.CurrentCamera
        if cam then
            local closest, closestDist = nil, State.CatchRange
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr and not isChaserPlayer(p) then
                    local cChar = p.Character
                    local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
                    if cHrp then
                        local d = (hrp.Position - cHrp.Position).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closest = cHrp
                        end
                    end
                end
            end
            if closest then
                local targetCF = CFrame.new(cam.CFrame.Position, closest.Position)
                cam.CFrame = cam.CFrame:Lerp(targetCF, State.AimSmooth)
            end
        end
    end

    if State.KillAura then
        local now = tick()
        if now - lastAttack >= 0.2 then
            lastAttack = now
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr and not isChaserPlayer(p) then
                    local cChar = p.Character
                    local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
                    if cHrp then
                        local d = (hrp.Position - cHrp.Position).Magnitude
                        if d <= State.KillAuraRange then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then pcall(function() tool:Activate() end) end
                        end
                    end
                end
            end
        end
    end

    for _, data in pairs(markers) do
        if data.part and data.part.Parent then
            local d = (data.part.Position - hrp.Position).Magnitude
            data.label.Text = string.format("%d m", math.floor(d))
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        if State.ShowChaser or State.ShowRunners or State.ShowDistances then
            refreshVisual()
        end
        task.wait(2)
    end
end)

selectTab("Runner")
setStatus("Vale Huss carregado ✓")
