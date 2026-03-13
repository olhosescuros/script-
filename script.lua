-- ╔══════════════════════════════════════╗
-- ║      ANIME SCRIPT  •  MOBILE v5      ║
-- ║  Speed • Fly • Noclip • HP • TP     ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenSvc = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

local function getChar() return LP.Character end
local function getRoot() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- STATE
local S = {
	speed=false, speedVal=40,
	fly=false, flySpeed=60,
	noclip=false,
	infHP=false,
	infJump=false
}

-- CONNECTIONS
local conns={}
local function dc(k) if conns[k] then conns[k]:Disconnect() conns[k]=nil end end

-- FLY BUTTON STATE
local _flyUp=false
local _flyDown=false

-- ═════════════════════════════
-- FLY SYSTEM (AlignPosition)
-- ═════════════════════════════
local flyConn, flyCharConn
local flyAP, flyAtt
local flyTarget

local function stopFly()
	S.fly=false
	_flyUp=false
	_flyDown=false
	
	if flyConn then flyConn:Disconnect() flyConn=nil end
	if flyCharConn then flyCharConn:Disconnect() flyCharConn=nil end
	
	if flyAP then flyAP:Destroy() flyAP=nil end
	if flyAtt then flyAtt:Destroy() flyAtt=nil end
	
	local h=getHum()
	if h then h.PlatformStand=false end
end

local function startFly()
	stopFly()
	S.fly=true
	
	local r=getRoot()
	local h=getHum()
	if not r or not h then return end
	
	h.PlatformStand=true
	
	flyAtt=Instance.new("Attachment",r)
	flyAP=Instance.new("AlignPosition",r)
	
	flyAP.Attachment0=flyAtt
	flyAP.MaxForce=1e6
	flyAP.Responsiveness=60
	flyAP.MaxVelocity=math.huge
	flyAP.ApplyAtCenterOfMass=true
	
	flyTarget=r.Position
	flyAP.Position=flyTarget
	
	flyConn=RunService.RenderStepped:Connect(function(dt)
		if not S.fly then stopFly() return end
		
		local r2=getRoot()
		if not r2 then stopFly() return end
		
		local cam=workspace.CurrentCamera
		local cf=cam.CFrame
		
		local move=Vector3.zero
		
		if UIS:IsKeyDown(Enum.KeyCode.W) then move+=cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move-=cf.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move-=cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move+=cf.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move-=Vector3.new(0,1,0) end
		
		if _flyUp then move+=Vector3.new(0,1,0) end
		if _flyDown then move-=Vector3.new(0,1,0) end
		
		if move.Magnitude>0 then move=move.Unit end
		
		flyTarget+=move*(S.flySpeed*dt)
		flyAP.Position=flyTarget
	end)
	
	flyCharConn=LP.CharacterAdded:Connect(function()
		task.wait(0.6)
		if S.fly then startFly() end
	end)
end

-- ═════════════════════════════
-- FEATURES
-- ═════════════════════════════

dc("speed")
conns.speed=RunService.Heartbeat:Connect(function()
	local h=getHum()
	if not h then return end
	h.WalkSpeed = S.speed and S.speedVal or 16
end)

dc("hp")
conns.hp=RunService.Heartbeat:Connect(function()
	if not S.infHP then return end
	local h=getHum()
	if h then h.Health=h.MaxHealth end
end)

dc("jump")
UIS.JumpRequest:Connect(function()
	if not S.infJump then return end
	local h=getHum()
	if h then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

dc("noclip")
conns.noclip=RunService.Stepped:Connect(function()
	if not S.noclip then return end
	
	local c=getChar()
	if not c then return end
	
	for _,p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide=false
		end
	end
end)

-- ═════════════════════════════
-- GUI
-- ═════════════════════════════

pcall(function()
	local old=LP.PlayerGui:FindFirstChild("AnimeScript")
	if old then old:Destroy() end
end)

local Gui=Instance.new("ScreenGui")
Gui.Name="AnimeScript"
Gui.ResetOnSpawn=false
Gui.IgnoreGuiInset=true
Gui.Parent=LP.PlayerGui

-- ═════════════════════════════
-- TOAST
-- ═════════════════════════════

local ToastHolder=Instance.new("Frame",Gui)
ToastHolder.Size=UDim2.new(1,0,0,60)
ToastHolder.Position=UDim2.new(0,0,0,-60)
ToastHolder.BackgroundTransparency=1

local toastQueue={}
local toastBusy=false

local function toast(msg,col)
	table.insert(toastQueue,{msg=msg,col=col or Color3.fromRGB(0,200,140)})
	
	if toastBusy then return end
	toastBusy=true
	
	task.spawn(function()
		while #toastQueue>0 do
			
			local data=table.remove(toastQueue,1)
			
			local t=Instance.new("Frame")
			t.Size=UDim2.new(0,260,0,40)
			t.Position=UDim2.new(0.5,-130,0,0)
			t.BackgroundColor3=Color3.fromRGB(10,15,20)
			t.Parent=ToastHolder
			
			local corner=Instance.new("UICorner",t)
			corner.CornerRadius=UDim.new(0,10)
			
			local txt=Instance.new("TextLabel",t)
			txt.Size=UDim2.new(1,0,1,0)
			txt.BackgroundTransparency=1
			txt.Text=data.msg
			txt.TextColor3=data.col
			txt.Font=Enum.Font.GothamBold
			txt.TextSize=14
			
			TweenSvc:Create(
				ToastHolder,
				TweenInfo.new(0.25),
				{Position=UDim2.new(0,0,0,10)}
			):Play()
			
			task.wait(2)
			
			TweenSvc:Create(
				ToastHolder,
				TweenInfo.new(0.2),
				{Position=UDim2.new(0,0,0,-60)}
			):Play()
			
			task.wait(0.25)
			
			t:Destroy()
		end
		
		toastBusy=false
	end)
end

-- ═════════════════════════════
-- FLY BUTTONS
-- ═════════════════════════════

local FlyBtns=Instance.new("Frame",Gui)
FlyBtns.Size=UDim2.new(0,120,0,60)
FlyBtns.Position=UDim2.new(0.5,-60,1,-140)
FlyBtns.BackgroundTransparency=1
FlyBtns.Visible=false

local FlyUp=Instance.new("TextButton",FlyBtns)
FlyUp.Size=UDim2.new(0,54,0,54)
FlyUp.Position=UDim2.new(0,0,0,0)
FlyUp.Text="▲"
FlyUp.BackgroundColor3=Color3.fromRGB(0,120,200)
FlyUp.TextColor3=Color3.new(1,1,1)
FlyUp.Font=Enum.Font.GothamBold
FlyUp.TextSize=24
Instance.new("UICorner",FlyUp)

local FlyDn=Instance.new("TextButton",FlyBtns)
FlyDn.Size=UDim2.new(0,54,0,54)
FlyDn.Position=UDim2.new(1,-54,0,0)
FlyDn.Text="▼"
FlyDn.BackgroundColor3=Color3.fromRGB(100,0,200)
FlyDn.TextColor3=Color3.new(1,1,1)
FlyDn.Font=Enum.Font.GothamBold
FlyDn.TextSize=24
Instance.new("UICorner",FlyDn)

FlyUp.InputBegan:Connect(function(i)
	if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
		_flyUp=true
	end
end)

FlyUp.InputEnded:Connect(function(i)
	if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
		_flyUp=false
	end
end)

FlyDn.InputBegan:Connect(function(i)
	if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
		_flyDown=true
	end
end)

FlyDn.InputEnded:Connect(function(i)
	if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
		_flyDown=false
	end
end)

-- ═════════════════════════════
-- DRAG SYSTEM (MOBILE SAFE)
-- ═════════════════════════════

local function makeDrag(frame)

	local drag=false
	local start
	local startPos
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType.Name:find("Touch") or input.UserInputType==Enum.UserInputType.MouseButton1 then
			drag=true
			start=input.Position
			startPos=frame.Position
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if drag and (input.UserInputType.Name:find("Touch") or input.UserInputType==Enum.UserInputType.MouseMovement) then
			local delta=input.Position-start
			
			frame.Position=UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset+delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset+delta.Y
			)
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType.Name:find("Touch") or input.UserInputType==Enum.UserInputType.MouseButton1 then
			drag=false
		end
	end)
end

-- ═════════════════════════════
-- PANEL
-- ═════════════════════════════

local Panel=Instance.new("Frame",Gui)
Panel.Size=UDim2.new(0,300,0,420)
Panel.Position=UDim2.new(0.5,-150,0.15,0)
Panel.BackgroundColor3=Color3.fromRGB(10,15,20)
Panel.Visible=false
Instance.new("UICorner",Panel)

makeDrag(Panel)

-- ═════════════════════════════
-- FAB
-- ═════════════════════════════

local FAB=Instance.new("TextButton",Gui)
FAB.Size=UDim2.new(0,56,0,56)
FAB.Position=UDim2.new(0,12,0,12)
FAB.Text="⚔️"
FAB.BackgroundColor3=Color3.fromRGB(0,150,100)
FAB.TextColor3=Color3.new(1,1,1)
FAB.Font=Enum.Font.GothamBold
FAB.TextSize=24
Instance.new("UICorner",FAB)

makeDrag(FAB)

local menuOpen=false

local function toggleMenu(v)
	menuOpen=v~=nil and v or not menuOpen
	Panel.Visible=menuOpen
end

FAB.InputBegan:Connect(function(i)
	if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
		toggleMenu()
	end
end)

-- ═════════════════════════════
-- CONTROLS
-- ═════════════════════════════

toast("⚔️ Script carregado!",Color3.fromRGB(0,200,140))
