--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local configFolder = sharedFolder:WaitForChild("Config") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder

local gameConfigModule = configFolder:WaitForChild("GameConfig") :: ModuleScript
local remoteDefinitionsModule = gameFolder:WaitForChild("RemoteDefinitions") :: ModuleScript
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript
local uiFolder = script.Parent.Parent:WaitForChild("UI") :: Folder
local uiRootModule = uiFolder:WaitForChild("UIRoot") :: ModuleScript

local GameConfig = require(gameConfigModule)
local Logger = require(loggerModule)
local RemoteDefinitions = require(remoteDefinitionsModule) :: {
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

  ReplicatedStorage:WaitForChild(GameConfig.Network.RemotesFolderName)

  local localPlayer = Players.LocalPlayer

  if localPlayer == nil then
    error("LocalPlayer was unavailable during client boot")
  end

  UIRoot.mount(localPlayer)

  Logger.info(
    "client/app",
    string.format(
      "Client mount ready (%d remotes defined)",
      #RemoteDefinitions.Events + #RemoteDefinitions.Functions
    )
  )
end

return AppController
