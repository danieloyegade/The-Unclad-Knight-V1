--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local configFolder = sharedFolder:WaitForChild("Config") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder

local gameConfigModule = configFolder:WaitForChild("GameConfig") :: ModuleScript
local remoteDefinitionsModule = gameFolder:WaitForChild("RemoteDefinitions") :: ModuleScript
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local GameConfig = require(gameConfigModule)
local Logger = require(loggerModule)
local RemoteDefinitions = require(remoteDefinitionsModule) :: {
  Events: { { name: string, kind: "RemoteEvent" } },
  Functions: { { name: string, kind: "RemoteFunction" } }
}

local RemoteService = {
  name = "RemoteService",
}

local started = false

local function getOrCreateRemotesFolder(): Folder
  local existingFolder = ReplicatedStorage:FindFirstChild(GameConfig.Network.RemotesFolderName)

  if existingFolder == nil then
    local folder = Instance.new("Folder")
    folder.Name = GameConfig.Network.RemotesFolderName
    folder.Parent = ReplicatedStorage
    return folder
  end

  if not existingFolder:IsA("Folder") then
    error(
      string.format(
        "%s must be a Folder, received %s",
        GameConfig.Network.RemotesFolderName,
        existingFolder.ClassName
      )
    )
  end

  return existingFolder
end

local function ensureRemote(parent: Folder, definition: { name: string, kind: "RemoteEvent" | "RemoteFunction" }): Instance
  local existingRemote = parent:FindFirstChild(definition.name)

  if existingRemote ~= nil then
    if existingRemote.ClassName ~= definition.kind then
      error(
        string.format(
          "Remote %s already exists as %s, expected %s",
          definition.name,
          existingRemote.ClassName,
          definition.kind
        )
      )
    end

    return existingRemote
  end

  local remote = Instance.new(definition.kind)
  remote.Name = definition.name
  remote.Parent = parent

  return remote
end

function RemoteService.start()
  if started then
    return
  end

  started = true

  local remotesFolder = getOrCreateRemotesFolder()

  for _, definition in RemoteDefinitions.Events do
    ensureRemote(remotesFolder, definition)
  end

  for _, definition in RemoteDefinitions.Functions do
    ensureRemote(remotesFolder, definition)
  end

  Logger.info(
    "server/network",
    string.format(
      "Remote folder ready at ReplicatedStorage.%s (%d definitions)",
      GameConfig.Network.RemotesFolderName,
      #RemoteDefinitions.Events + #RemoteDefinitions.Functions
    )
  )
end

return RemoteService
