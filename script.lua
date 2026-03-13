-- ╔════════════════════════════════════════════════╗
-- ║        MOBILE AIMBOT HUB • SPEED • ESP         ║
-- ║ Speed • Infinite Jump • Aimbot • FOV • ESP     ║
-- ╚════════════════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function char() return LP.Character end
local function hum() local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end

-- STATE
local S={
	speed=false,
	speedVal=40,
	jump=false,
	jumpVal=100,
	aimbot=false,
	fov=120,
	esp=false
}

-- GUI
local Gui=Instance.new("ScreenGui",LP.PlayerGui)
Gui.Name="AimbotHub"
Gui.ResetOnSpawn=false

-- PANEL
local Panel=Instance.new("Frame",Gui)
Panel.Size=UDim2.new(0,300,0,400)
Panel.Position=UDim2.new(0.5,-150,0.2,0)
Panel.BackgroundColor3=Color3.fromRGB(20,25,30)
Panel.Visible=false
Instance.new("UICorner",Panel)

local layout=Instance.new("UIListLayout",Panel)
layout.Padding=UDim.new(0,6)

local pad=Instance.new("UIPadding",Panel)
pad.PaddingLeft=UDim.new(0,10)
pad.PaddingRight=UDim.new(0,10)
pad.PaddingTop=UDim.new(0,10)

-- FAB
local FAB=Instance.new("TextButton",Gui)
FAB.Size=UDim2.new(0,60,0,60)
FAB.Position=UDim2.new(0,12,0,12)
FAB.Text="🎯"
FAB.TextSize=26
FAB.BackgroundColor3=Color3.fromRGB(0,150,120)
FAB.TextColor3=Color3.new(1,1,1)
Instance.new("UICorner",FAB)

FAB.Activated:Connect(function()
	Panel.Visible=not Panel.Visible
end)

-- BUTTON
local function button(text,func)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,0,0,40)
	b.BackgroundColor3=Color3.fromRGB(40,45,50)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=16
	b.Text=text
	b.Parent=Panel
	Instance.new("UICorner",b)
	b.Activated:Connect(func)
end

-- SLIDER
local function slider(text,min,max,default,callback)

	local frame=Instance.new("Frame")
	frame.Size=UDim2.new(1,0,0,50)
	frame.BackgroundTransparency=1
	frame.Parent=Panel

	local label=Instance.new("TextLabel")
	label.Size=UDim2.new(1,0,0,20)
	label.Text=text..": "..default
	label.TextColor3=Color3.new(1,1,1)
	label.BackgroundTransparency=1
	label.Font=Enum.Font.GothamBold
	label.TextSize=14
	label.Parent=frame

	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(1,0,0,10)
	bar.Position=UDim2.new(0,0,0,30)
	bar.BackgroundColor3=Color3.fromRGB(60,60,60)
	bar.Parent=frame
	Instance.new("UICorner",bar)

	local fill=Instance.new("Frame")
	fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(0,170,255)
	fill.Parent=bar
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

slider("Speed",16,120,40,function(v)
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

-- JUMP
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

-- AIMBOT
button("🎯 Aimbot",function()
	S.aimbot=not S.aimbot
end)

slider("FOV",50,300,120,function(v)
	S.fov=v
end)

-- FOV CIRCLE
local circle=Drawing.new("Circle")
circle.Thickness=2
circle.NumSides=50
circle.Radius=S.fov
circle.Color=Color3.fromRGB(255,0,0)
circle.Filled=false
circle.Visible=true

RunService.RenderStepped:Connect(function()

	local mouse=UIS:GetMouseLocation()
	circle.Position=mouse
	circle.Radius=S.fov

	if not S.aimbot then return end

	local closest=nil
	local dist=S.fov

	for _,plr in pairs(Players:GetPlayers()) do

		if plr~=LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

			local pos,onscreen=Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)

			if onscreen then

				local mag=(Vector2.new(pos.X,pos.Y)-mouse).Magnitude

				if mag<dist then
					dist=mag
					closest=plr
				end

			end

		end

	end

	if closest and closest.Character then

		local target=closest.Character:FindFirstChild("Head")

		if target then
			Camera.CFrame=CFrame.new(Camera.CFrame.Position,target.Position)
		end

	end

end)

-- ESP
local espObjects={}

button("👁 ESP Player",function()

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
