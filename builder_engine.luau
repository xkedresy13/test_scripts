-- [[ xkedresy13 GITHUB PLACEMENT ENGINE - TOP-DOWN GRID EDITION ]]
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")

local PreviewObject = nil
local Connection = nil
local GridSize = 4 

-- Store original camera settings to restore them later
local OriginalCameraType = Camera.CameraType

local function Snap(n)
    return math.round(n / GridSize) * GridSize
end

local function cleanup()
    if PreviewObject then PreviewObject:Destroy() end
    if Connection then Connection:Disconnect() end
    -- Restore Camera
    Camera.CameraType = Enum.CameraType.Custom
end

if _G.PlacementActive then
    local target = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == _G.SelectedObject then target = v break end
    end
    
    if not target then return end

    PreviewObject = target:Clone()
    for _, v in pairs(PreviewObject:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false v.Transparency = 0.5 end
    end
    PreviewObject.Parent = workspace

    -- START ENGINE LOOP
    Connection = RunService.RenderStepped:Connect(function()
        if not _G.PlacementActive then cleanup() return end
        
        -- 1. TOP-DOWN CAMERA LOGIC (Kuş Bakışı)
        local playerPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
        if playerPos then
            -- Position camera high above the player looking straight down
            local cameraOffset = Vector3.new(0, 50, 0) -- Adjust 50 to go higher or lower
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(playerPos + cameraOffset, playerPos)
        end

        -- 2. GRID PLACEMENT LOGIC
        if PreviewObject then
            local pos = Mouse.Hit.Position
            local snappedPos = Vector3.new(Snap(pos.X), Snap(pos.Y + 2), Snap(pos.Z))
            
            if PreviewObject:IsA("Model") then
                PreviewObject:PivotTo(CFrame.new(snappedPos))
            else
                PreviewObject.CFrame = CFrame.new(snappedPos)
            end
        end
    end)

    -- 3. CLICK TO PLACE
    local ClickConn
    ClickConn = Mouse.Button1Down:Connect(function()
        if not _G.PlacementActive then ClickConn:Disconnect() return end
        if PreviewObject then
            local NewPlacement = target:Clone()
            local finalCFrame = PreviewObject:IsA("Model") and PreviewObject:GetPivot() or PreviewObject.CFrame
            if NewPlacement:IsA("Model") then NewPlacement:PivotTo(finalCFrame) else NewPlacement.CFrame = finalCFrame end
            NewPlacement.Parent = workspace
            NewPlacement:SetAttribute("Owner", Player.Name)
        end
    end)
else
    cleanup()
end
