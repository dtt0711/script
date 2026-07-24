-- Khởi tạo Dịch vụ
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local RemoteFolder = ReplicatedStorage:WaitForChild("Remote", 5)
local FoodStoreRE = RemoteFolder and RemoteFolder:WaitForChild("FoodStoreRE", 5)

-- Danh sách các loại Food
local foods = {
    "Pear", "Pineapple", "DragonFruit", "GoldMango", "BloodstoneCycad",
    "ColossalPinecone", "VoltGinkgo", "DeepseaPearlFruit", "CandyCorn", "Durian",
    "Pumpkin", "FrankenKiwi", "Acorn", "Cranberry", "Gingerbread",
    "Candycane", "Cherry", "YogurtIceCream", "MintJelly", "Macaron"
}

-- Trạng thái chọn món và trạng thái Auto tổng
local selectedFoods = {}
for _, f in ipairs(foods) do selectedFoods[f] = false end

local isRunning = true
local isAutoOn = false

-- --- XOÁ UI CŨ TRÁNH BỊ LỖI ---
local uiName = "AutoFoodStoreUI_MultiSelect"
pcall(function()
    if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
    if Players.LocalPlayer.PlayerGui:FindFirstChild(uiName) then Players.LocalPlayer.PlayerGui[uiName]:Destroy() end
end)

-- --- TẠO GIAO DIỆN (UI) ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = uiName
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

-- Khung chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 360)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "  Multi-Select Food Auto"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Nút Xóa (Close Button)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    isRunning = false
    isAutoOn = false
    ScreenGui:Destroy()
end)

-- --- DANH SÁCH TÍCH CHỌN MÓN ---
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -100) -- Chừa khoảng trống bên dưới cho nút Master
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
end)

for _, foodName in ipairs(foods) do
    local OptionBtn = Instance.new("TextButton")
    OptionBtn.Size = UDim2.new(1, -10, 0, 30)
    OptionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    OptionBtn.Text = "[ ] " .. foodName
    OptionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    OptionBtn.Font = Enum.Font.SourceSansBold
    OptionBtn.TextSize = 14
    OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
    OptionBtn.Parent = ScrollingFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = OptionBtn

    -- Padding chữ
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.Parent = OptionBtn

    -- Bấm để Tích chọn/Bỏ chọn món
    OptionBtn.MouseButton1Click:Connect(function()
        selectedFoods[foodName] = not selectedFoods[foodName]
        
        if selectedFoods[foodName] then
            OptionBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180) -- Xanh dương khi chọn
            OptionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionBtn.Text = "[X] " .. foodName
        else
            OptionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            OptionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptionBtn.Text = "[ ] " .. foodName
        end
    end)
end

-- --- NÚT MASTER AUTO (Bật tắt cho các món đã chọn) ---
local MasterAutoBtn = Instance.new("TextButton")
MasterAutoBtn.Size = UDim2.new(1, -10, 0, 45)
MasterAutoBtn.Position = UDim2.new(0, 5, 1, -50)
MasterAutoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MasterAutoBtn.Text = "START AUTO BUY"
MasterAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MasterAutoBtn.Font = Enum.Font.SourceSansBold
MasterAutoBtn.TextSize = 16
MasterAutoBtn.Parent = MainFrame

local MasterCorner = Instance.new("UICorner")
MasterCorner.CornerRadius = UDim.new(0, 6)
MasterCorner.Parent = MasterAutoBtn

MasterAutoBtn.MouseButton1Click:Connect(function()
    isAutoOn = not isAutoOn
    
    if isAutoOn then
        MasterAutoBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Đổi sang xanh lá
        MasterAutoBtn.Text = "AUTO: ON (Dừng Lại)"
        
        -- 1. Mua ngay lập tức 1 lần cho TẤT CẢ các món ĐÃ CHỌN
        for food, isSelected in pairs(selectedFoods) do
            if isSelected and FoodStoreRE then
                pcall(function() FoodStoreRE:FireServer(food) end)
            end
        end

        -- 2. Vòng lặp ngầm 30s
        task.spawn(function()
            while isAutoOn and isRunning do
                task.wait(30)
                if not isAutoOn or not isRunning then break end
                
                for food, isSelected in pairs(selectedFoods) do
                    if isSelected and FoodStoreRE then
                        pcall(function() FoodStoreRE:FireServer(food) end)
                    end
                end
            end
        end)
    else
        MasterAutoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        MasterAutoBtn.Text = "START AUTO BUY"
    end
end)
