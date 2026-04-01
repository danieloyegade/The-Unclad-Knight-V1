--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local openingBriefModule = gameFolder:WaitForChild("OpeningBrief") :: ModuleScript

local OpeningBrief = require(openingBriefModule) :: {
  DistrictLabel: string,
  Title: string,
  Subtitle: string,
  Vow: {
    Label: string,
    Text: string,
  },
  Omen: {
    Label: string,
    Text: string,
  },
}

local OpeningOverlay = {}

local OVERLAY_NAME = "OpeningOverlay"

local palette = {
  Panel = Color3.fromRGB(11, 14, 19),
  Border = Color3.fromRGB(69, 77, 92),
  Accent = Color3.fromRGB(220, 167, 86),
  PrimaryText = Color3.fromRGB(239, 235, 225),
  SecondaryText = Color3.fromRGB(181, 186, 195),
  MutedText = Color3.fromRGB(148, 154, 166),
}

local function applyTextStyle(label: TextLabel, font: Enum.Font, color: Color3, size: number)
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.Font = font
  label.TextColor3 = color
  label.TextSize = size
  label.TextWrapped = true
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextYAlignment = Enum.TextYAlignment.Top
end

local function createTextLabel(name: string, text: string, font: Enum.Font, color: Color3, size: number): TextLabel
  local label = Instance.new("TextLabel")
  label.Name = name
  label.AutomaticSize = Enum.AutomaticSize.Y
  label.Size = UDim2.new(1, 0, 0, 0)
  label.Text = text

  applyTextStyle(label, font, color, size)

  return label
end

function OpeningOverlay.mount(screenGui: ScreenGui): Frame
  local existingOverlay = screenGui:FindFirstChild(OVERLAY_NAME)

  if existingOverlay ~= nil then
    if not existingOverlay:IsA("Frame") then
      error(string.format("%s already exists but is a %s", OVERLAY_NAME, existingOverlay.ClassName))
    end

    return existingOverlay
  end

  local panel = Instance.new("Frame")
  panel.Name = OVERLAY_NAME
  panel.AnchorPoint = Vector2.new(0, 1)
  panel.AutomaticSize = Enum.AutomaticSize.Y
  panel.BackgroundColor3 = palette.Panel
  panel.BackgroundTransparency = 0.18
  panel.BorderSizePixel = 0
  panel.Position = UDim2.new(0, 20, 1, -20)
  panel.Size = UDim2.fromOffset(440, 0)

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = panel

  local stroke = Instance.new("UIStroke")
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  stroke.Color = palette.Border
  stroke.Transparency = 0.25
  stroke.Parent = panel

  local padding = Instance.new("UIPadding")
  padding.PaddingTop = UDim.new(0, 14)
  padding.PaddingBottom = UDim.new(0, 16)
  padding.PaddingLeft = UDim.new(0, 16)
  padding.PaddingRight = UDim.new(0, 16)
  padding.Parent = panel

  local layout = Instance.new("UIListLayout")
  layout.Padding = UDim.new(0, 8)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.Parent = panel

  local accent = Instance.new("Frame")
  accent.Name = "Accent"
  accent.BackgroundColor3 = palette.Accent
  accent.BorderSizePixel = 0
  accent.LayoutOrder = 1
  accent.Size = UDim2.new(1, 0, 0, 2)
  accent.Parent = panel

  local districtLabel = createTextLabel(
    "DistrictLabel",
    OpeningBrief.DistrictLabel,
    Enum.Font.Code,
    palette.Accent,
    14
  )
  districtLabel.LayoutOrder = 2
  districtLabel.Parent = panel

  local titleLabel = createTextLabel(
    "TitleLabel",
    OpeningBrief.Title,
    Enum.Font.GothamBold,
    palette.PrimaryText,
    24
  )
  titleLabel.LayoutOrder = 3
  titleLabel.Parent = panel

  local subtitleLabel = createTextLabel(
    "SubtitleLabel",
    OpeningBrief.Subtitle,
    Enum.Font.Gotham,
    palette.SecondaryText,
    16
  )
  subtitleLabel.LayoutOrder = 4
  subtitleLabel.Parent = panel

  local vowLabel = createTextLabel(
    "VowLabel",
    OpeningBrief.Vow.Label,
    Enum.Font.Code,
    palette.MutedText,
    13
  )
  vowLabel.LayoutOrder = 5
  vowLabel.Parent = panel

  local vowText = createTextLabel(
    "VowText",
    OpeningBrief.Vow.Text,
    Enum.Font.GothamMedium,
    palette.PrimaryText,
    16
  )
  vowText.LayoutOrder = 6
  vowText.Parent = panel

  local omenLabel = createTextLabel(
    "OmenLabel",
    OpeningBrief.Omen.Label,
    Enum.Font.Code,
    palette.MutedText,
    13
  )
  omenLabel.LayoutOrder = 7
  omenLabel.Parent = panel

  local omenText = createTextLabel(
    "OmenText",
    OpeningBrief.Omen.Text,
    Enum.Font.Gotham,
    palette.SecondaryText,
    15
  )
  omenText.LayoutOrder = 8
  omenText.Parent = panel

  panel.Parent = screenGui

  return panel
end

return OpeningOverlay
