--// ╔══════════════════════════════════════════════════════════════╗
--// ║                 MOBILE AIMBOT HUB V2 (FULL)                  ║
--// ║  Speed • Infinite Jump • Aimbot • FOV • ESP • Hitbox • UI    ║
--// ║  100% Mobile Friendly (Touch Support)                        ║
--// ╚══════════════════════════════════════════════════════════════╝

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SHORTCUTS
local function char() return LP.Character end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end

-- STATES
local S = {
	speed=false,
	speedVal=40,
	jump=false,
	fly=false,
	flySpeed=60,
	aimbot=false,
	fov=120,
	smooth=0.15,
	esp=false,
	hitbox=false,
	hitboxSize=5
}

-- GUI
local Gui = Instance.new("ScreenGui", LP.PlayerGui)
Gui.Name = "AimbotHubV2"
Gui.ResetOnSpawn = false

-- FAB
local FAB = Instance.new("TextButton")
FAB.Parent = Gui
FAB.Size = UDim2.new(0,60,0,60)
FAB.Position = UDim2.new(0,10,0,10)
FAB.BackgroundColor3 = Color3.fromRGB(0,170,120)
FAB.Text = "🎯"
FAB.TextSize = 26
FAB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",FAB)

-- PANEL
local Panel = Instance.new("Frame",Gui)
Panel.Size = UDim2.new(0,320,0,420)
Panel.Position = UDim2.new(0.5,-160,0.2,0)
Panel.BackgroundColor3 = Color3.fromRGB(20,25,30)
Panel.Visible=false
Instance.new("UICorner",Panel)

-- SCROLL
local Scroll = Instance.new("ScrollingFrame",Panel)
Scroll.Size = UDim2.new(1,0,1,0)
Scroll.CanvasSize = UDim2.new(0,0,0,800)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout",Scroll)
layout.Padding = UDim.new(0,6)

local pad = Instance.new("UIPadding",Scroll)
pad.PaddingTop = UDim.new(0,10)
pad.PaddingLeft = UDim.new(0,10)
pad.PaddingRight = UDim.new(0,10)

FAB.Activated:Connect(function()
	Panel.Visible = not Panel.Visible
end)

-- DRAG PANEL (TOUCH)
do
	local dragging=false
	local dragStart, startPos
	
	Panel.InputBegan:Connect(function(input)
		if input.UserInputType.Name:find("Touch") or input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true
			dragStart=input.Position
			startPos=Panel.Position
		end
	end)
	
	Panel.InputEnded:Connect(function()
		dragging=false
	end)
	
	UIS.InputChanged:Connect(function(input)
		if dragging then
			local delta=input.Position-dragStart
			Panel.Position=UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset+delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset+delta.Y
			)
		end
	end)
end

-- BUTTON
local function button(text,func)
	local b=Instance.new("TextButton")
	b.Parent=Scroll
	b.Size=UDim2.new(1,0,0,40)
	b.BackgroundColor3=Color3.fromRGB(40,45,50)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=15
	b.Text=text
	Instance.new("UICorner",b)
	b.Activated:Connect(func)
end

-- SLIDER
local function slider(text,min,max,default,callback)

	local frame=Instance.new("Frame",Scroll)
	frame.Size=UDim2.new(1,0,0,50)
	frame.BackgroundTransparency=1

	local label=Instance.new("TextLabel",frame)
	label.Size=UDim2.new(1,0,0,20)
	label.Text=text..": "..default
	label.TextColor3=Color3.new(1,1,1)
	label.Font=Enum.Font.GothamBold
	label.TextSize=14
	label.BackgroundTransparency=1

	local bar=Instance.new("Frame",frame)
	bar.Size=UDim2.new(1,0,0,10)
	bar.Position=UDim2.new(0,0,0,30)
	bar.BackgroundColor3=Color3.fromRGB(60,60,60)
	Instance.new("UICorner",bar)

	local fill=Instance.new("Frame",bar)
	fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(0,170,255)
	Instance.new("UICorner",fill)

	local dragging=false

	bar.InputBegan:Connect(function(i)
		if i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true
		end
	end)

	bar.InputEnded:Connect(function()
		dragging=false
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType.Name:find("Touch") or i.UserInputType==Enum.UserInputType.MouseMovement) then

			local pos=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
			pos=math.clamp(pos,0,1)

			fill.Size=UDim2.new(pos,0,1,0)

			local val=math.floor(min+(max-min)*pos)

			label.Text=text..": "..val
			callback(val)

		end
	end)
end

-- SPEED
button("⚡ Speed Toggle",function()
	S.speed=not S.speed
end)

slider("Speed",16,200,40,function(v)
	S.speedVal=v
end)

RunService.Heartbeat:Connect(function()
	local h=hum()
	if not h then return end
	if S.speed then
		h.WalkSpeed=S.speedVal
	else
		h.WalkSpeed=16
	end
end)

-- INFINITE JUMP
button("🦘 Infinite Jump",function()
	S.jump=not S.jump
end)

UIS.JumpRequest:Connect(function()
	if not S.jump then return end
	local h=hum()
	if h then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- FLY
button("🕊 Fly",function()
	S.fly=not S.fly
end)

local BV

RunService.RenderStepped:Connect(function()

	if not S.fly then
		if BV then BV:Destroy() BV=nil end
		return
	end

	local r=root()
	if not r then return end

	if not BV then
		BV=Instance.new("BodyVelocity",r)
		BV.MaxForce=Vector3.new(1e5,1e5,1e5)
	end

	local dir=Camera.CFrame.LookVector
	BV.Velocity=dir*S.flySpeed

end)

slider("Fly Speed",20,200,60,function(v)
	S.flySpeed=v
end)

-- AIMBOT
button("🎯 Aimbot",function()
	S.aimbot=not S.aimbot
end)

slider("FOV",50,400,120,function(v)
	S.fov=v
end)

slider("Aim Smooth",1,50,15,function(v)
	S.smooth=v/100
end)

-- FOV CIRCLE
local circle=Drawing.new("Circle")
circle.Thickness=2
circle.NumSides=60
circle.Color=Color3.fromRGB(255,0,0)
circle.Filled=false
circle.Visible=true

-- TARGET
local function getTarget()

	local mouse=UIS:GetMouseLocation()
	local closest=nil
	local dist=S.fov

	for _,plr in pairs(Players:GetPlayers()) do
		if plr~=LP and plr.Character and plr.Character:FindFirstChild("Head") then

			local pos,onscreen=Camera:WorldToViewportPoint(plr.Character.Head.Position)

			if onscreen then

				local mag=(Vector2.new(pos.X,pos.Y)-mouse).Magnitude

				if mag<dist then
					dist=mag
					closest=plr
				end

			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()

	local mouse=UIS:GetMouseLocation()

	circle.Position=mouse
	circle.Radius=S.fov

	if not S.aimbot then return end

	local target=getTarget()

	if target and target.Character then

		local head=target.Character:FindFirstChild("Head")

		if head then

			local cf=CFrame.new(Camera.CFrame.Position,head.Position)

			Camera.CFrame=Camera.CFrame:Lerp(cf,S.smooth)

		end
	end
end)

-- ESP
local espObjects={}

button("👁 ESP Line + Box",function()

	S.esp=not S.esp

	for _,v in pairs(espObjects) do
		v:Remove()
	end

	espObjects={}

	if not S.esp then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr~=LP then

			local line=Drawing.new("Line")
			line.Color=Color3.fromRGB(255,0,0)
			line.Thickness=2

			local box=Drawing.new("Square")
			box.Color=Color3.fromRGB(0,255,0)
			box.Thickness=2
			box.Filled=false

			table.insert(espObjects,line)
			table.insert(espObjects,box)

			RunService.RenderStepped:Connect(function()

				if not S.esp then
					line.Visible=false
					box.Visible=false
					return
				end

				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

					local pos,onscreen=Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)

					if onscreen then

						line.Visible=true
						line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
						line.To=Vector2.new(pos.X,pos.Y)

						box.Visible=true
						box.Position=Vector2.new(pos.X-20,pos.Y-40)
						box.Size=Vector2.new(40,80)

					else
						line.Visible=false
						box.Visible=false
					end

				end

			end)

		end
	end
end)

-- HITBOX
button("📦 Hitbox Expand",function()

	S.hitbox=not S.hitbox

	for _,plr in pairs(Players:GetPlayers()) do

		if plr~=LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

			local hrp=plr.Character.HumanoidRootPart

			if S.hitbox then
				hrp.Size=Vector3.new(S.hitboxSize,S.hitboxSize,S.hitboxSize)
				hrp.Transparency=0.5
				hrp.BrickColor=BrickColor.new("Really red")
				hrp.CanCollide=false
			else
				hrp.Size=Vector3.new(2,2,1)
				hrp.Transparency=1
			end

		end
	end
end)

slider("Hitbox Size",2,15,5,function(v)
	S.hitboxSize=v
end)
