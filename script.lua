-- ╔══════════════════════════════════════════════════════╗
-- ║        AIMBOT HUB  •  MOBILE  (FIXED)               ║
-- ║  Speed • Jump • Fly • Aimbot • FOV • ESP • Noclip   ║
-- ╚══════════════════════════════════════════════════════╝

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local LP         = Players.LocalPlayer
local Cam        = workspace.CurrentCamera

local function getChar() return LP.Character end
local function getRoot() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ════════════════════════════════════════
-- ESTADO
-- ════════════════════════════════════════
local S = {
    speed=false,  speedVal=40,
    jump=false,
    fly=false,    flySpeed=60,
    aimbot=false, fov=120,  smooth=0.15,
    esp=false,
    noclip=false,
}

local _flyUp, _flyDown = false, false

-- ════════════════════════════════════════
-- FLY
-- ════════════════════════════════════════
local flyConn, flyCharConn, flyAP, flyAtt

local function stopFly()
    S.fly=false; _flyUp=false; _flyDown=false
    if flyConn     then flyConn:Disconnect();     flyConn=nil     end
    if flyCharConn then flyCharConn:Disconnect(); flyCharConn=nil end
    pcall(function() if flyAP  then flyAP:Destroy()  end end)
    pcall(function() if flyAtt then flyAtt:Destroy() end end)
    flyAP=nil; flyAtt=nil
    local h=getHum(); if h then h.PlatformStand=false end
end

local function startFly()
    stopFly(); S.fly=true
    local r=getRoot(); local h=getHum()
    if not r or not h then S.fly=false; return end
    h.PlatformStand=true
    flyAtt=Instance.new("Attachment",r)
    flyAP=Instance.new("AlignPosition",r)
    flyAP.Attachment0=flyAtt; flyAP.Position=r.Position
    flyAP.MaxForce=1e5; flyAP.MaxVelocity=math.huge; flyAP.Responsiveness=50
    flyAP.ApplyAtCenterOfMass=true
    local tp=r.Position
    flyConn=RunService.RenderStepped:Connect(function(dt)
        if not S.fly then stopFly(); return end
        local r2=getRoot(); if not r2 then stopFly(); return end
        local cf=Cam.CFrame
        local mv=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W)         then mv=mv+cf.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then mv=mv-cf.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then mv=mv-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then mv=mv+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv=mv+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv=mv-Vector3.new(0,1,0) end
        if _flyUp   then mv=mv+Vector3.new(0,1,0) end
        if _flyDown then mv=mv-Vector3.new(0,1,0) end
        if mv.Magnitude>0 then mv=mv.Unit end
        tp=tp+mv*(S.flySpeed*dt); flyAP.Position=tp
    end)
    flyCharConn=LP.CharacterAdded:Connect(function()
        task.wait(0.6); if S.fly then startFly() end
    end)
end

-- ════════════════════════════════════════
-- LOOPS
-- ════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local h=getHum(); if not h then return end
    h.WalkSpeed = S.speed and S.speedVal or 16
end)

UIS.JumpRequest:Connect(function()
    if not S.jump then return end
    local h=getHum()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

RunService.Stepped:Connect(function()
    if not S.noclip then return end
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- ════════════════════════════════════════
-- FOV CIRCLE — fixo no CENTRO da tela
-- ════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides  = 64
fovCircle.Color     = Color3.fromRGB(255, 50, 50)
fovCircle.Filled    = false
fovCircle.Visible   = false

-- Atualiza centro e raio a cada frame
-- NÃO usa GetMouseLocation() — usa ViewportSize/2 = centro fixo
RunService.RenderStepped:Connect(function()
    local vp = Cam.ViewportSize
    fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)  -- CENTRO FIXO
    fovCircle.Radius   = S.fov
    fovCircle.Visible  = S.aimbot
end)

-- ════════════════════════════════════════
-- AIMBOT — mira no alvo mais próximo do CENTRO
-- ════════════════════════════════════════
local function getTarget()
    local vp  = Cam.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)  -- centro, não mouse
    local best, bestDist = nil, S.fov
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local pos, onscreen = Cam:WorldToViewportPoint(head.Position)
                if onscreen then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < bestDist then bestDist=d; best=plr end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not S.aimbot then return end
    local target = getTarget()
    if not (target and target.Character) then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    local goal = CFrame.new(Cam.CFrame.Position, head.Position)
    Cam.CFrame  = Cam.CFrame:Lerp(goal, math.clamp(S.smooth, 0.01, 1))
end)

-- ════════════════════════════════════════
-- ESP — conexão única, sem leak
-- ════════════════════════════════════════
local espData = {}  -- [player] = {line, box}

local function clearESP()
    for _,t in pairs(espData) do
        pcall(function() t.line:Remove() end)
        pcall(function() t.box:Remove()  end)
    end
    espData = {}
end

local function buildESP()
    clearESP()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local line = Drawing.new("Line")
            line.Color     = Color3.fromRGB(255,60,60)
            line.Thickness = 1.5

            local box = Drawing.new("Square")
            box.Color     = Color3.fromRGB(0,255,120)
            box.Thickness = 1.5
            box.Filled    = false

            espData[plr] = {line=line, box=box}
        end
    end
end

-- Uma única conexão pra todos os ESP (sem criar nova por player)
RunService.RenderStepped:Connect(function()
    for plr, t in pairs(espData) do
        if not S.esp then
            t.line.Visible=false; t.box.Visible=false
        elseif plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onscreen = Cam:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local vp = Cam.ViewportSize
                t.line.Visible = true
                t.line.From    = Vector2.new(vp.X/2, vp.Y)
                t.line.To      = Vector2.new(pos.X, pos.Y)

                t.box.Visible  = true
                t.box.Position = Vector2.new(pos.X-20, pos.Y-40)
                t.box.Size     = Vector2.new(40, 80)
            else
                t.line.Visible=false; t.box.Visible=false
            end
        else
            t.line.Visible=false; t.box.Visible=false
        end
    end
end)

-- Limpa ESP quando player sai
Players.PlayerRemoving:Connect(function(plr)
    if espData[plr] then
        pcall(function() espData[plr].line:Remove() end)
        pcall(function() espData[plr].box:Remove()  end)
        espData[plr]=nil
    end
end)

-- ════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════
pcall(function()
    local o=LP.PlayerGui:FindFirstChild("AimbotHub"); if o then o:Destroy() end
end)

local Gui=Instance.new("ScreenGui")
Gui.Name="AimbotHub"; Gui.ResetOnSpawn=false
Gui.IgnoreGuiInset=true; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.Parent=LP.PlayerGui

-- TOAST
local Toast=Instance.new("Frame",Gui)
Toast.Size=UDim2.new(0,270,0,44); Toast.Position=UDim2.new(0.5,-135,0,-60)
Toast.BackgroundColor3=Color3.fromRGB(14,14,20); Toast.BorderSizePixel=0
Toast.Visible=false; Toast.ZIndex=60
Instance.new("UICorner",Toast).CornerRadius=UDim.new(0,12)
local tStr=Instance.new("UIStroke",Toast); tStr.Thickness=1.5; tStr.Color=Color3.fromRGB(255,50,50)
local tLbl=Instance.new("TextLabel",Toast)
tLbl.Size=UDim2.new(1,-10,1,0); tLbl.Position=UDim2.new(0,5,0,0)
tLbl.BackgroundTransparency=1; tLbl.Font=Enum.Font.GothamBold
tLbl.TextSize=13; tLbl.TextColor3=Color3.fromRGB(220,235,240); tLbl.ZIndex=61

local tBusy=false; local tQ={}
local function toast(msg, col)
    table.insert(tQ,{msg=msg, col=col or Color3.fromRGB(255,50,50)})
    if tBusy then return end; tBusy=true
    task.spawn(function()
        while #tQ>0 do
            local t=table.remove(tQ,1)
            tLbl.Text=t.msg; tStr.Color=t.col
            Toast.Visible=true; Toast.Position=UDim2.new(0.5,-135,0,-60)
            TweenSvc:Create(Toast,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-135,0,10)}):Play()
            task.wait(2.2)
            TweenSvc:Create(Toast,TweenInfo.new(0.2),{Position=UDim2.new(0.5,-135,0,-60)}):Play()
            task.wait(0.22); Toast.Visible=false
        end
        tBusy=false
    end)
end

-- BOTÕES VOO
local FlyBtns=Instance.new("Frame",Gui)
FlyBtns.Size=UDim2.new(0,130,0,60); FlyBtns.Position=UDim2.new(0.5,-65,1,-150)
FlyBtns.BackgroundTransparency=1; FlyBtns.ZIndex=25; FlyBtns.Visible=false

local function mkFlyBtn(txt,col,xoff)
    local b=Instance.new("TextButton",FlyBtns)
    b.Size=UDim2.new(0,58,0,56); b.Position=UDim2.new(0,xoff,0,0)
    b.BackgroundColor3=col; b.Text=txt
    b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBold
    b.TextSize=26; b.BorderSizePixel=0; b.ZIndex=26
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,14)
    return b
end
local BtnUp=mkFlyBtn("▲",Color3.fromRGB(0,110,210),0)
local BtnDn=mkFlyBtn("▼",Color3.fromRGB(110,0,200),72)

for _,pair in ipairs({{BtnUp,true},{BtnDn,false}}) do
    local btn,up=pair[1],pair[2]
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            if up then _flyUp=true else _flyDown=true end
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            if up then _flyUp=false else _flyDown=false end
        end
    end)
end

-- FAB
local FAB=Instance.new("TextButton",Gui)
FAB.Size=UDim2.new(0,56,0,56); FAB.Position=UDim2.new(0,14,0,14)
FAB.BackgroundColor3=Color3.fromRGB(180,30,30); FAB.Text="🎯"
FAB.TextColor3=Color3.fromRGB(255,255,255); FAB.Font=Enum.Font.GothamBold
FAB.TextSize=24; FAB.BorderSizePixel=0; FAB.ZIndex=30
Instance.new("UICorner",FAB).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",FAB).Color=Color3.fromRGB(255,80,80)

do
    local drag=false; local si,sp
    FAB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; si=i.Position; sp=FAB.Position
        end
    end)
    FAB.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=i.Position-si
            FAB.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false
        end
    end)
end

-- PAINEL
local Panel=Instance.new("Frame",Gui)
Panel.Size=UDim2.new(0,306,0,460); Panel.Position=UDim2.new(0.5,-153,0.08,0)
Panel.BackgroundColor3=Color3.fromRGB(14,16,22); Panel.BorderSizePixel=0
Panel.Visible=false; Panel.ZIndex=10
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,14)
Instance.new("UIStroke",Panel).Color=Color3.fromRGB(180,30,30)

-- Header (drag só aqui)
local Hdr=Instance.new("Frame",Panel)
Hdr.Size=UDim2.new(1,0,0,46); Hdr.BackgroundColor3=Color3.fromRGB(22,10,10)
Hdr.BorderSizePixel=0; Hdr.ZIndex=11
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,14)
local hLine=Instance.new("Frame",Hdr)
hLine.Size=UDim2.new(1,0,0,2); hLine.Position=UDim2.new(0,0,1,-2)
hLine.BackgroundColor3=Color3.fromRGB(220,40,40); hLine.BorderSizePixel=0

local hTitle=Instance.new("TextLabel",Hdr)
hTitle.Size=UDim2.new(1,-52,1,0); hTitle.Position=UDim2.new(0,14,0,0)
hTitle.BackgroundTransparency=1; hTitle.Text="🎯  AIMBOT HUB"
hTitle.TextColor3=Color3.fromRGB(255,100,100); hTitle.Font=Enum.Font.GothamBold
hTitle.TextSize=16; hTitle.TextXAlignment=Enum.TextXAlignment.Left; hTitle.ZIndex=12

local XBtn=Instance.new("TextButton",Hdr)
XBtn.Size=UDim2.new(0,32,0,32); XBtn.Position=UDim2.new(1,-40,0.5,-16)
XBtn.BackgroundColor3=Color3.fromRGB(130,18,18); XBtn.Text="✕"
XBtn.TextColor3=Color3.fromRGB(255,180,180); XBtn.Font=Enum.Font.GothamBold
XBtn.TextSize=14; XBtn.BorderSizePixel=0; XBtn.ZIndex=13
Instance.new("UICorner",XBtn).CornerRadius=UDim.new(0,8)

do
    local drag=false; local si,sp
    Hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; si=i.Position; sp=Panel.Position
        end
    end)
    Hdr.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=i.Position-si
            Panel.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- Scroll
local Scroll=Instance.new("ScrollingFrame",Panel)
Scroll.Size=UDim2.new(1,0,1,-48); Scroll.Position=UDim2.new(0,0,0,48)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=Color3.fromRGB(220,40,40)
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y

local SBody=Instance.new("Frame",Scroll)
SBody.Size=UDim2.new(1,0,0,0); SBody.AutomaticSize=Enum.AutomaticSize.Y
SBody.BackgroundTransparency=1
local SL=Instance.new("UIListLayout",SBody)
SL.HorizontalAlignment=Enum.HorizontalAlignment.Center; SL.Padding=UDim.new(0,5)
local SP=Instance.new("UIPadding",SBody)
SP.PaddingTop=UDim.new(0,6); SP.PaddingBottom=UDim.new(0,14)
SP.PaddingLeft=UDim.new(0,7); SP.PaddingRight=UDim.new(0,7)

-- ════════════════════════════════════════
-- COMPONENTES
-- ════════════════════════════════════════
local RED   = Color3.fromRGB(200,30,30)
local GREEN = Color3.fromRGB(0,180,100)
local BLUE  = Color3.fromRGB(0,90,180)
local DARK  = Color3.fromRGB(14,16,22)

local function section(name)
    local f=Instance.new("Frame",SBody)
    f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1
    local ln=Instance.new("Frame",f)
    ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,0.5,0)
    ln.BackgroundColor3=Color3.fromRGB(50,10,10); ln.BorderSizePixel=0
    local lb=Instance.new("TextLabel",f)
    lb.AutomaticSize=Enum.AutomaticSize.X; lb.Size=UDim2.new(0,0,1,0)
    lb.BackgroundColor3=DARK
    lb.Text="  "..name.."  "; lb.TextColor3=Color3.fromRGB(220,60,60)
    lb.Font=Enum.Font.GothamBold; lb.TextSize=10; lb.BorderSizePixel=0
end

local function mkToggle(label, sub, default, cb)
    local on=default
    local card=Instance.new("Frame",SBody)
    card.Size=UDim2.new(1,0,0,sub and 62 or 52)
    card.BackgroundColor3=Color3.fromRGB(18,14,20); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,11)
    local cs=Instance.new("UIStroke",card); cs.Thickness=1.5
    cs.Color=on and RED or Color3.fromRGB(22,22,30)

    local bar=Instance.new("Frame",card)
    bar.Size=UDim2.new(0,4,1,-14); bar.Position=UDim2.new(0,0,0,7)
    bar.BackgroundColor3=on and RED or Color3.fromRGB(22,22,30)
    bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)

    local lb=Instance.new("TextLabel",card)
    lb.Size=UDim2.new(1,-78,0,22); lb.Position=UDim2.new(0,12,0,sub and 6 or 0)
    lb.BackgroundTransparency=1; lb.Text=label
    lb.TextColor3=Color3.fromRGB(230,220,220); lb.Font=Enum.Font.GothamBold
    lb.TextSize=15; lb.TextXAlignment=Enum.TextXAlignment.Left

    if sub then
        local s2=Instance.new("TextLabel",card)
        s2.Size=UDim2.new(1,-78,0,14); s2.Position=UDim2.new(0,12,0,30)
        s2.BackgroundTransparency=1; s2.Text=sub
        s2.TextColor3=Color3.fromRGB(80,44,44); s2.Font=Enum.Font.Gotham
        s2.TextSize=11; s2.TextXAlignment=Enum.TextXAlignment.Left
    end

    local sw=Instance.new("Frame",card)
    sw.Size=UDim2.new(0,50,0,26); sw.Position=UDim2.new(1,-58,0.5,-13)
    sw.BackgroundColor3=on and RED or Color3.fromRGB(22,22,30)
    sw.BorderSizePixel=0; Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",sw)
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local function setState(v)
        on=v
        TweenSvc:Create(sw,TweenInfo.new(0.16),{BackgroundColor3=v and RED or Color3.fromRGB(22,22,30)}):Play()
        TweenSvc:Create(knob,TweenInfo.new(0.16),{Position=v and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
        TweenSvc:Create(bar,TweenInfo.new(0.16),{BackgroundColor3=v and RED or Color3.fromRGB(22,22,30)}):Play()
        cs.Color=v and RED or Color3.fromRGB(22,22,30)
    end

    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5
    btn.InputBegan:Connect(function(i)
        if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
            on=not on; setState(on); cb(on)
        end
    end)
    return setState
end

local function mkSlider(label, mn, mx, def, suf, cb)
    local val=def
    local card=Instance.new("Frame",SBody)
    card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(18,14,20)
    card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,11)
    Instance.new("UIStroke",card).Color=Color3.fromRGB(22,22,30)

    local lb=Instance.new("TextLabel",card)
    lb.Size=UDim2.new(1,-90,0,20); lb.Position=UDim2.new(0,12,0,8)
    lb.BackgroundTransparency=1; lb.Text=label
    lb.TextColor3=Color3.fromRGB(230,220,220); lb.Font=Enum.Font.GothamBold
    lb.TextSize=14; lb.TextXAlignment=Enum.TextXAlignment.Left

    local vL=Instance.new("TextLabel",card)
    vL.Size=UDim2.new(0,82,0,20); vL.Position=UDim2.new(1,-90,0,8)
    vL.BackgroundTransparency=1; vL.Text=tostring(val)..(suf or "")
    vL.TextColor3=RED; vL.Font=Enum.Font.GothamBold
    vL.TextSize=14; vL.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",card)
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,40)
    track.BackgroundColor3=Color3.fromRGB(22,22,30); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=RED; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,20,0,20); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Positi
