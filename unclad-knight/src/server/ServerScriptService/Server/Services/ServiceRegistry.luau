--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local remoteServiceModule = script.Parent:WaitForChild("RemoteService") :: ModuleScript
local playerServiceModule = script.Parent:WaitForChild("PlayerService") :: ModuleScript

local Logger = require(loggerModule)
local RemoteService = require(remoteServiceModule)
local PlayerService = require(playerServiceModule)

type Startable = {
  name: string,
  start: () -> (),
}

local services: { Startable } = {
  RemoteService,
  PlayerService,
}

local ServiceRegistry = {}

function ServiceRegistry.start()
  for _, service in services do
    Logger.info("server", string.format("Starting %s", service.name))
    service.start()
  end
end

return ServiceRegistry
