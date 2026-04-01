--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local configFolder = sharedFolder:WaitForChild("Config") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder

local gameConfigModule = configFolder:WaitForChild("GameConfig") :: ModuleScript
local openingBriefModule = gameFolder:WaitForChild("OpeningBrief") :: ModuleScript
local remoteDefinitionsModule = gameFolder:WaitForChild("RemoteDefinitions") :: ModuleScript
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript
local uiFolder = script.Parent.Parent:WaitForChild("UI") :: Folder
local uiRootModule = uiFolder:WaitForChild("UIRoot") :: ModuleScript

local GameConfig = require(gameConfigModule)
local OpeningBrief = require(openingBriefModule) :: {
  InitialPhase: string,
}
local Logger = require(loggerModule)
local RemoteDefinitions = require(remoteDefinitionsModule) :: {
  Names: {
    SlicePhaseChanged: string,
    GetSlicePhase: string,
  },
  Events: { { name: string, kind: "RemoteEvent" } },
  Functions: { { name: string, kind: "RemoteFunction" } }
}
local UIRoot = require(uiRootModule)

local AppController = {
  name = "AppController",
}

local started = false

function AppController.start()
  if started then
    return
  end

  started = true

  local remotesFolder = ReplicatedStorage:WaitForChild(GameConfig.Network.RemotesFolderName)

  local localPlayer = Players.LocalPlayer

  if localPlayer == nil then
    error("LocalPlayer was unavailable during client boot")
  end

  if not remotesFolder:IsA("Folder") then
    error(string.format("%s must resolve to a Folder", GameConfig.Network.RemotesFolderName))
  end

  local slicePhaseChangedRemote = remotesFolder:WaitForChild(RemoteDefinitions.Names.SlicePhaseChanged)
  local getSlicePhaseFunction = remotesFolder:WaitForChild(RemoteDefinitions.Names.GetSlicePhase)

  if not slicePhaseChangedRemote:IsA("RemoteEvent") then
    error(string.format("%s must be a RemoteEvent", RemoteDefinitions.Names.SlicePhaseChanged))
  end

  if not getSlicePhaseFunction:IsA("RemoteFunction") then
    error(string.format("%s must be a RemoteFunction", RemoteDefinitions.Names.GetSlicePhase))
  end

  local screenGui = UIRoot.mount(localPlayer)

  UIRoot.renderPhase(screenGui, OpeningBrief.InitialPhase)

  slicePhaseChangedRemote.OnClientEvent:Connect(function(phase: string)
    UIRoot.renderPhase(screenGui, phase)
  end)

  local ok, phase = pcall(function()
    return getSlicePhaseFunction:InvokeServer()
  end)

  if ok and type(phase) == "string" then
    UIRoot.renderPhase(screenGui, phase)
  else
    Logger.warn("client/app", "Unable to fetch initial slice phase; falling back to the default overlay")
  end

  Logger.info(
    "client/app",
    string.format(
      "Client mount ready (%d remotes defined)",
      #RemoteDefinitions.Events + #RemoteDefinitions.Functions
    )
  )
end

return AppController
