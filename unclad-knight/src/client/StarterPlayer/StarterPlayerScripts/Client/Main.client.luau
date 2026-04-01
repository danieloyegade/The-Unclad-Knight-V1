--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local controllersFolder = script.Parent:WaitForChild("Controllers") :: Folder
local controllerRegistryModule = controllersFolder:WaitForChild("ControllerRegistry") :: ModuleScript

local Logger = require(loggerModule)
local ControllerRegistry = require(controllerRegistryModule)

Logger.info("client", "Booting client composition root")
ControllerRegistry.start()
Logger.info("client", "Client ready")
