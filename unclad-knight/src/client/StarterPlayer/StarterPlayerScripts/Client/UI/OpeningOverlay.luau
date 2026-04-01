--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local openingBriefModule = gameFolder:WaitForChild("OpeningBrief") :: ModuleScript

local OpeningBrief = require(openingBriefModule) :: {
  DistrictLabel: string,
  Title: string,
  InitialPhase: string,
  States: {
    [string]: {
      AccentColor: Color3,
      Subtitle: string,
      ObjectiveLabel: string,
      ObjectiveText: string,
      StatusLabel: string,
      StatusText: string,
    },
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

local CHILD_NAMES = {
  Accent = "Accent",
  Stroke = "PanelStroke",
  DistrictLabel = "DistrictLabel",
  TitleLabel = "TitleLabel",
  SubtitleLabel = "SubtitleLabel",
  ObjectiveLabel = "ObjectiveLabel",
  ObjectiveText = "ObjectiveText",
  StatusLabel = "StatusLabel",
  StatusText = "StatusText",
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

local function findChild(parent: Instance, name: string): Instance
  local child = parent:FindFirstChild(name)

  if child == nil then
    error(string.format("%s is missing child %s", parent.Name, name))
  end

  return child
end

local function getState(phase: string)
  local state = OpeningBrief.States[phase]

  if state ~= nil then
    return state
  end

  return OpeningBrief.States[OpeningBrief.InitialPhase]
end

function OpeningOverlay.render(overlay: Frame, phase: string)
  local state = getState(phase)

  local accent = findChild(overlay, CHILD_NAMES.Accent)
  local stroke = findChild(overlay, CHILD_NAMES.Stroke)
  local districtLabel = findChild(overlay, CHILD_NAMES.DistrictLabel)
  local titleLabel = findChild(overlay, CHILD_NAMES.TitleLabel)
  local subtitleLabel = findChild(overlay, CHILD_NAMES.SubtitleLabel)
  local objectiveLabel = findChild(overlay, CHILD_NAMES.ObjectiveLabel)
  local objectiveText = findChild(overlay, CHILD_NAMES.ObjectiveText)
  local statusLabel = findChild(overlay, CHILD_NAMES.StatusLabel)
  local statusText = findChild(overlay, CHILD_NAMES.StatusText)

  if not accent:IsA("Frame") then
    error("Opening overlay accent must be a Frame")
  end

  if not stroke:IsA("UIStroke") then
    error("Opening overlay stroke must be a UIStroke")
  end

  if not districtLabel:IsA("TextLabel")
    or not titleLabel:IsA("TextLabel")
    or not subtitleLabel:IsA("TextLabel")
    or not objectiveLabel:IsA("TextLabel")
    or not objectiveText:IsA("TextLabel")
    or not statusLabel:IsA("TextLabel")
    or not statusText:IsA("TextLabel")
  then
    error("Opening overlay text nodes were not mounted correctly")
  end

  accent.BackgroundColor3 = state.AccentColor
  stroke.Color = state.AccentColor:Lerp(palette.Border, 0.45)
  districtLabel.Text = OpeningBrief.DistrictLabel
  districtLabel.TextColor3 = state.AccentColor
  titleLabel.Text = OpeningBrief.Title
  subtitleLabel.Text = state.Subtitle
  objectiveLabel.Text = state.ObjectiveLabel
  objectiveText.Text = state.ObjectiveText
  statusLabel.Text = state.StatusLabel
  statusText.Text = state.StatusText
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
  panel.Position = UDim2.new(0, 16, 1, -16)
  panel.Size = UDim2.new(0.6, 0, 0, 0)

  local sizeConstraint = Instance.new("UISizeConstraint")
  sizeConstraint.MinSize = Vector2.new(280, 0)
  sizeConstraint.MaxSize = Vector2.new(440, 1000)
  sizeConstraint.Parent = panel

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = panel

  local stroke = Instance.new("UIStroke")
  stroke.Name = CHILD_NAMES.Stroke
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
  accent.Name = CHILD_NAMES.Accent
  accent.BackgroundColor3 = palette.Accent
  accent.BorderSizePixel = 0
  accent.LayoutOrder = 1
  accent.Size = UDim2.new(1, 0, 0, 2)
  accent.Parent = panel

  local districtLabel = createTextLabel(
    CHILD_NAMES.DistrictLabel,
    OpeningBrief.DistrictLabel,
    Enum.Font.Code,
    palette.Accent,
    14
  )
  districtLabel.LayoutOrder = 2
  districtLabel.Parent = panel

  local titleLabel = createTextLabel(
    CHILD_NAMES.TitleLabel,
    OpeningBrief.Title,
    Enum.Font.GothamBold,
    palette.PrimaryText,
    24
  )
  titleLabel.LayoutOrder = 3
  titleLabel.Parent = panel

  local subtitleLabel = createTextLabel(
    CHILD_NAMES.SubtitleLabel,
    "",
    Enum.Font.Gotham,
    palette.SecondaryText,
    16
  )
  subtitleLabel.LayoutOrder = 4
  subtitleLabel.Parent = panel

  local objectiveLabel = createTextLabel(
    CHILD_NAMES.ObjectiveLabel,
    "",
    Enum.Font.Code,
    palette.MutedText,
    13
  )
  objectiveLabel.LayoutOrder = 5
  objectiveLabel.Parent = panel

  local objectiveText = createTextLabel(
    CHILD_NAMES.ObjectiveText,
    "",
    Enum.Font.GothamMedium,
    palette.PrimaryText,
    16
  )
  objectiveText.LayoutOrder = 6
  objectiveText.Parent = panel

  local statusLabel = createTextLabel(
    CHILD_NAMES.StatusLabel,
    "",
    Enum.Font.Code,
    palette.MutedText,
    13
  )
  statusLabel.LayoutOrder = 7
  statusLabel.Parent = panel

  local statusText = createTextLabel(
    CHILD_NAMES.StatusText,
    "",
    Enum.Font.Gotham,
    palette.SecondaryText,
    15
  )
  statusText.LayoutOrder = 8
  statusText.Parent = panel

  panel.Parent = screenGui

  OpeningOverlay.render(panel, OpeningBrief.InitialPhase)

  return panel
end

return OpeningOverlay
