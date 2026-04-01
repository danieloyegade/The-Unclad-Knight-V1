--!strict

local openingOverlayModule = script.Parent:WaitForChild("OpeningOverlay") :: ModuleScript
local OpeningOverlay = require(openingOverlayModule)

local UIRoot = {}

local ROOT_NAME = "UncladKnightUI"

function UIRoot.mount(player: Player): ScreenGui
  local playerGuiInstance = player:WaitForChild("PlayerGui")

  if not playerGuiInstance:IsA("PlayerGui") then
    error("PlayerGui was unavailable when creating the UI root")
  end

  local existingRoot = playerGuiInstance:FindFirstChild(ROOT_NAME)

  if existingRoot ~= nil then
    if not existingRoot:IsA("ScreenGui") then
      error(string.format("%s already exists but is a %s", ROOT_NAME, existingRoot.ClassName))
    end

    OpeningOverlay.mount(existingRoot)

    return existingRoot
  end

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = ROOT_NAME
  screenGui.DisplayOrder = 1
  screenGui.IgnoreGuiInset = true
  screenGui.ResetOnSpawn = false
  screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  screenGui.Parent = playerGuiInstance

  OpeningOverlay.mount(screenGui)

  return screenGui
end

function UIRoot.renderPhase(screenGui: ScreenGui, phase: string)
  local overlay = OpeningOverlay.mount(screenGui)
  OpeningOverlay.render(overlay, phase)
end

return UIRoot
