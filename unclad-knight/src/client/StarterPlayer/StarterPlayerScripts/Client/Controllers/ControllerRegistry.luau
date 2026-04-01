--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local appControllerModule = script.Parent:WaitForChild("AppController") :: ModuleScript

local Logger = require(loggerModule)
local AppController = require(appControllerModule)

type Startable = {
  name: string,
  start: () -> (),
}

local controllers: { Startable } = {
  AppController,
}

local ControllerRegistry = {}

function ControllerRegistry.start()
  for _, controller in controllers do
    Logger.info("client", string.format("Starting %s", controller.name))
    controller.start()
  end
end

return ControllerRegistry
