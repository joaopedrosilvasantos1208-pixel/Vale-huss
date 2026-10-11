local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local plr = Players.LocalPlayer

local State = {
    AutoDodge = false, FastDodge = false,
    DodgeDistance = 8,        -- AGORA: só esquiva quando o inimigo está MUITO perto
    ReactionSpeed = 0.3,      -- AGORA: cooldown maior, sem spam
    DodgeDir = 2, DodgeStrength = 45,
    AutoEscape = false, EscapeRange = 40,
    Sprint = false, SprintValue = 22,
    ShowChaser = false, ShowRunners = false, ShowDistances = false,
    AntiAFK = false, NoClip = false, PerfMode = false, TrainingMode = false,
    EffectsOn = true, MovementIndicator = true,
    AutoJump = false,
}

local gui = Instance.new("ScreenGui")
gui.Name = "ValeHussUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = plr:WaitForChild("PlayerGui")

local NEON = Color3.fromRGB(0, 255, 130)
local NEON_DIM = Color3.fromRGB(0, 150, 80)
local BG = Color3.fromRGB(10, 10, 10)
local BG2 = Color3.fromRGB(18, 18, 18)
local TXT = Color3.fromRGB(230, 255, 240)
local TXT_DIM = Color3.fromRGB(150, 200, 170)
local DANGER = Color3.fromRGB(255, 70, 70)

local PANEL_W = 250
local PANEL_H = 340
local MIN_H = 38

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

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
root.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
root.BackgroundColor3 = BG
root.BackgroundTransparency = 0.1
root.BorderSizePixel = 0
root.Active = true
root.ZIndex = 2
root.Parent = gui
corner(root, UDim.new(0, 12))
stroke(root, NEON, 2, 0.15)

local rootGrad = Instance.new("UIGradient")
rootGrad.Rotation = 90
rootGrad.Color = ColorSequence.new(BG, BG2)
rootGrad.Parent = root

local uiscale = Instance.new("UIScale")
uiscale.Scale = 1
uiscale.Parent = root

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, MIN_H)
topBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
topBar.BackgroundTransparency = 0.05
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.ZIndex = 3
topBar.Parent = root
corner(topBar, UDim.new(0, 12))
stroke(topBar, NEON, 1, 0.3)

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -108, 1, 0)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 4
dragArea.Parent = topBar

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(8, 8)
dot.Position = UDim2.new(0, 10, 0.5, -4)
dot.BackgroundColor3 = NEON
dot.BorderSizePixel = 0
dot.ZIndex = 5
dot.Parent = topBar
corner(dot, UDim.new(1, 0))

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 24, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VALE HUSS"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = NEON
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 5
title.Parent = topBar

local function topBtn(txt, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30, 30)
    b.Position = UDim2.new(1, xOff, 0.5, -15)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.BorderSizePixel = 0
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = color or NEON
    b.AutoButtonColor = false
    b.ZIndex = 200000
    b.Parent = topBar
    corner(b, UDim.new(0, 8))
    stroke(b, color or NEON, 1, 0.3)
    return b
end

local btnMin = topBtn("—", -100)
local btnClose = topBtn("✕", -36, DANGER)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -12, 0, 30)
tabBar.Position = UDim2.new(0, 6, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 3
tabBar.Parent = root

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 3)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local tabs = {}
local tabNames = {
    { key = "Runner",   label = "🏃" },
    { key = "Visual",   label = "👁" },
    { key = "Utility",  label = "🛠" },
    { key = "Settings", label = "⚙" },
}

for i, info in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25, -3, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    b.BorderSizePixel = 0
    b.Text = info.label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = TXT_DIM
    b.AutoButtonColor = false
    b.LayoutOrder = i
    b.ZIndex = 4
    b.Parent = tabBar
    corner(b, UDim.new(0, 8))
    local s = stroke(b, NEON_DIM, 1, 0.6)
    tabs[info.key] = { btn = b, stroke = s }
end

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -12, 1, -108)
content.Position = UDim2.new(0, 6, 0, 76)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex = 3
content.Parent = root

local pages = {}
for _, info in ipairs(tabNames) do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = NEON_DIM
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 4
    page.Parent = content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 3)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 3)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)
    pad.Parent = page
    pages[info.key] = page
end

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -12, 0, 18)
statusBar.Position = UDim2.new(0, 6, 1, -22)
statusBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
statusBar.BackgroundTransparency = 0.2
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 3
statusBar.Parent = root
corner(statusBar, UDim.new(0, 6))
stroke(statusBar, NEON_DIM, 1, 0.6)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -8, 1, 0)
statusLbl.Position = UDim2.new(0, 6, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "● Pronto"
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextSize = 9
statusLbl.TextColor3 = NEON
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextTruncate = Enum.TextTruncate.AtEnd
statusLbl.ZIndex = 4
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
    data.btn.MouseButton1Click:Connect(function() selectTab(k) end)
end

local function makeToggle(page, label, default, cb, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.ZIndex = 5
    row.Parent = page
    corner(row, UDim.new(0, 7))
    stroke(row, NEON_DIM, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -58, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 6
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(42, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = default and NEON or Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = default and Color3.fromRGB(0, 0, 0) or TXT_DIM
    btn.AutoButtonColor = false
    btn.ZIndex = 7
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
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.ZIndex = 5
    row.Parent = page
    corner(row, UDim.new(0, 7))
    stroke(row, NEON_DIM, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 0, 15)
    lbl.Position = UDim2.new(0, 8, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 6
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 48, 0, 15)
    valLbl.Position = UDim2.new(1, -52, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.1f", default)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 10
    valLbl.TextColor3 = NEON
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 6
    valLbl.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 8)
    bar.Position = UDim2.new(0, 8, 1, -16)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bar.BorderSizePixel = 0
    bar.ZIndex = 6
    bar.Parent = row
    corner(bar, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = NEON
    fill.BorderSizePixel = 0
    fill.ZIndex = 7
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
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = danger and Color3.fromRGB(45, 12, 12) or Color3.fromRGB(18, 30, 24)
    b.BorderSizePixel = 0
    b.Text = label
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.TextColor3 = danger and DANGER or NEON
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    b.ZIndex = 5
    b.Parent = page
    corner(b, UDim.new(0, 7))
    stroke(b, danger and DANGER or NEON, 1, 0.4)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

local function makeSection(page, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    f.ZIndex = 5
    f.Parent = page
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "▸ " .. text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextColor3 = NEON
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 6
    l.Parent = f
    return f
end

-- ==================== DETECÇÃO DE AMEAÇA (ATUALIZADA) ====================
-- Só considera ameaça quem está:
--  1. MUITO perto (dentro de DodgeDistance, padrão 8 studs)
--  2. VINDO na sua direção OU parado colado (prestes a atacar)
-- Isso imita o momento de ataque — não fica disparando longe.
local function getAttackThreat(hrp)
    local best = nil
    local bestDist = State.DodgeDistance
    local myPos = hrp.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local cChar = p.Character
            if cChar then
                local cHrp = cChar:FindFirstChild("HumanoidRootPart")
                local cHum = cChar:FindFirstChildOfClass("Humanoid")
                if cHrp and cHum and cHum.Health > 0 then
                    local delta = cHrp.Position - myPos
                    local dist = delta.Magnitude
                    if dist <= bestDist then
                        local otherVel = cHrp.AssemblyLinearVelocity
                        local dirToMe = delta.Unit
                        local velDir = otherVel.Magnitude > 1 and otherVel.Unit or Vector3.zero
                        -- Aproximando OU parado muito perto (< 5 studs)
                        local approaching = otherVel.Magnitude > 1 and velDir:Dot(dirToMe) < -0.2
                        local veryClose = dist < 5
                        if approaching or veryClose then
                            best = { hrp = cHrp, dist = dist, dir = dirToMe }
                            bestDist = dist
                        end
                    end
                end
            end
        end
    end
    return best
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
makeSection(pages.Runner, "ESQUIVA AUTOMÁTICA", 1)
local tgAutoDodge = makeToggle(pages.Runner, "Auto Dodge", false, function(v)
    State.AutoDodge = v
    setStatus(v and "Auto Dodge LIGADO" or "Auto Dodge desligado")
end, 2)
local tgFastDodge = makeToggle(pages.Runner, "Fast Dodge", false, function(v)
    State.FastDodge = v
    if v and not State.AutoDodge then
        tgAutoDodge.set(true); State.AutoDodge = true
    end
end, 3)
makeSlider(pages.Runner, "Distância (menor=mais preciso)", 5, 15, 8, function(v) State.DodgeDistance = v end, 4)
makeSlider(pages.Runner, "Cooldown entre esquivas", 0.15, 0.6, 0.3, function(v) State.ReactionSpeed = v end, 5)
makeSlider(pages.Runner, "Força do Dodge", 20, 70, 45, function(v) State.DodgeStrength = v end, 6)
makeSlider(pages.Runner, "Direção (0=Esq 1=Dir 2=Auto)", 0, 2, 2, function(v) State.DodgeDir = math.floor(v + 0.5) end, 7)

makeSection(pages.Runner, "MOVIMENTO", 8)
makeToggle(pages.Runner, "Auto Jump", false, function(v) State.AutoJump = v end, 9)
makeToggle(pages.Runner, "Auto Sprint", false, function(v)
    State.Sprint = v
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = v and State.SprintValue or 16 end
end, 10)
makeSlider(pages.Runner, "Sprint Speed", 16, 30, 22, function(v)
    State.SprintValue = v
    if State.Sprint then
        local _, _, hum = getCharacter()
        if hum then hum.WalkSpeed = v end
    end
end, 11)
makeToggle(pages.Runner, "Auto Escape (fugir)", false, function(v) State.AutoEscape = v end, 12)
makeSlider(pages.Runner, "Escape Range", 20, 80, 40, function(v) State.EscapeRange = v end, 13)
makeToggle(pages.Runner, "Mov Indicator", true, function(v) State.MovementIndicator = v end, 14)
makeButton(pages.Runner, "↺ Reset Runner", function()
    State.AutoDodge = false; State.FastDodge = false; State.AutoJump = false
    State.Sprint = false; State.AutoEscape = false
    State.DodgeDistance = 8; State.ReactionSpeed = 0.3; State.DodgeStrength = 45; State.DodgeDir = 2
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = 16 end
    tgAutoDodge.set(false); tgFastDodge.set(false)
    setStatus("Runner resetado")
end, false, 15)

-- ==================== VISUAL TAB ====================
local highlights = {}
local markers = {}

local function clearVisual()
    for _, h in pairs(highlights) do if h and h.Parent then h:Destroy() end end
    for _, m in pairs(markers) do if m.gui and m.gui.Parent then m.gui:Destroy() end end
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
            local cChar = p.Character
            if cChar and cChar:FindFirstChild("HumanoidRootPart") then
                if State.ShowChaser then
                    addHighlight(cChar, DANGER)
                    if State.ShowDistances then addDistanceMarker(cChar, DANGER) end
                end
                if State.ShowRunners and not State.ShowChaser then
                    addHighlight(cChar, NEON)
                    if State.ShowDistances then addDistanceMarker(cChar, NEON) end
                end
            end
        end
    end
end

makeSection(pages.Visual, "VISUAL", 1)
makeToggle(pages.Visual, "Destacar Jogadores (vermelho)", false, function(v) State.ShowChaser = v; refreshVisual() end, 2)
makeToggle(pages.Visual, "Destacar (verde)", false, function(v) State.ShowRunners = v; refreshVisual() end, 3)
makeToggle(pages.Visual, "Mostrar Distâncias", false, function(v) State.ShowDistances = v; refreshVisual() end, 4)
makeButton(pages.Visual, "🔄 Atualizar", function() refreshVisual(); setStatus("Atualizado") end, false, 5)
makeButton(pages.Visual, "🧹 Limpar", function() clearVisual(); setStatus("Limpo") end, false, 6)

-- ==================== UTILITY TAB ====================
makeSection(pages.Utility, "UTILIDADES", 1)
makeToggle(pages.Utility, "Anti-AFK", false, function(v) State.AntiAFK = v end, 2)
makeToggle(pages.Utility, "No-Clip", false, function(v) State.NoClip = v end, 3)
makeToggle(pages.Utility, "Performance", false, function(v)
    State.PerfMode = v
    Lighting.GlobalShadows = not v
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") then e.Enabled = not v end
    end
end, 4)
makeToggle(pages.Utility, "Treinamento", false, function(v)
    State.TrainingMode = v
    if v then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 120, 100)
    else
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end, 5)

makeSection(pages.Utility, "AÇÕES", 6)
makeButton(pages.Utility, "🎬 Centralizar Câmera", function()
    local _, hrp = getCharacter()
    local cam = Workspace.CurrentCamera
    if hrp and cam then
        cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 8, 12), hrp.Position)
    end
    setStatus("Câmera ok")
end, false, 7)
makeButton(pages.Utility, "🔧 Restaurar UI", function()
    root.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
    root.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
    uiscale.Scale = 1
    root.BackgroundTransparency = 0.1
    setStatus("UI ok")
end, false, 8)
makeButton(pages.Utility, "♻ Redefinir Tudo", function()
    clearVisual()
    local _, _, hum = getCharacter()
    if hum then hum.WalkSpeed = 16 end
    setStatus("Redefinido")
end, true, 9)

-- ==================== SETTINGS TAB ====================
makeSection(pages.Settings, "CONFIGURAÇÕES", 1)
makeSlider(pages.Settings, "Transparência", 0, 0.7, 0.1, function(v)
    root.BackgroundTransparency = v
end, 2)
makeSlider(pages.Settings, "Tamanho UI", 0.7, 1.4, 1.0, function(v)
    uiscale.Scale = v
end, 3)
makeButton(pages.Settings, "↺ Restaurar Padrões", function()
    uiscale.Scale = 1
    root.BackgroundTransparency = 0.1
    root.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
    root.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
    setStatus("Padrões ok")
end, true, 4)

-- ==================== DRAG ====================
local dragging = false
local dragStart, startPos

dragArea.InputBegan:Connect(function(input)
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

-- ==================== MINIMIZAR ====================
local minimized = false

local function applyMinimize(state)
    minimized = state
    TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = state and UDim2.fromOffset(PANEL_W, MIN_H) or UDim2.fromOffset(PANEL_W, PANEL_H)
    }):Play()
    content.Visible = not state
    tabBar.Visible = not state
    statusBar.Visible = not state
    btnMin.Text = state and "▢" or "—"
end

btnMin.MouseButton1Click:Connect(function()
    applyMinimize(not minimized)
    setStatus(minimized and "Minimizado" or "Restaurado")
end)

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ==================== MOVIMENTO / AUTO DODGE (SEM TREMEDEIRA) ====================
local lastDodge = 0
local dodgeActive = false
local dodgeEndTime = 0
local moveIndicator = nil

local function attachMoveIndicator(char)
    local head = char:FindFirstChild("Head")
    if not head then return end
    if moveIndicator then moveIndicator:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(100, 18)
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

    if State.AutoJump and hum and hum.MoveDirection.Magnitude > 0.1 then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = { char }
        local result = Workspace:Raycast(hrp.Position, hum.MoveDirection * 3 + Vector3.new(0, -2, 0), rayParams)
        if result and result.Distance < 3 then
            hum.Jump = true
        end
    end

    -- ============ AUTO DODGE SEM TREMEDEIRA ============
    -- Só dispara quando o inimigo está COLADO (≤ 8 studs por padrão).
    -- Usa BodyVelocity curto (0.12s) e cooldown de 0.3s.
    -- Fora disso, NÃO mexe em nada — seu movimento fica 100% livre.
    if State.AutoDodge then
        local now = tick()
        local threat = nil

        -- Só procura ameaça se NÃO estiver dodgeando agora
        if not (dodgeActive and now < dodgeEndTime) then
            threat = getAttackThreat(hrp)
        end

        if threat and (now - lastDodge >= State.ReactionSpeed) then
            lastDodge = now
            dodgeActive = true
            dodgeEndTime = now + 0.12

            local dir = -threat.dir
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

                local d = options[1]
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.Velocity = Vector3.new(d.X * State.DodgeStrength, 0, d.Z * State.DodgeStrength)
                bv.Parent = hrp
                task.delay(0.12, function()
                    if bv and bv.Parent then bv:Destroy() end
                end)
            end

            if moveIndicator then
                local l = moveIndicator:FindFirstChildOfClass("TextLabel")
                if l then
                    l.Text = "MOV: DODGE (" .. math.floor(threat.dist) .. "m)"
                    l.TextColor3 = DANGER
                end
            end
        elseif not (dodgeActive and now < dodgeEndTime) then
            dodgeActive = false
            if moveIndicator then
                local l = moveIndicator:FindFirstChildOfClass("TextLabel")
                if l then
                    l.Text = "MOV: ON"
                    l.TextColor3 = NEON
                end
            end
        end
    else
        if moveIndicator then
            local l = moveIndicator:FindFirstChildOfClass("TextLabel")
            if l then
                l.Text = "MOV: OFF"
                l.TextColor3 = NEON_DIM
            end
        end
    end

    -- Auto Escape
    if State.AutoEscape and hum then
        local threat = getAttackThreat(hrp)
        if threat and threat.dist <= State.EscapeRange then
            local escapeDir = -threat.dir
            escapeDir = Vector3.new(escapeDir.X, 0, escapeDir.Z)
            if escapeDir.Magnitude > 0.1 then
                hum:Move(escapeDir.Unit, false)
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
