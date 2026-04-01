--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local servicesFolder = script.Parent:WaitForChild("Services") :: Folder
local serviceRegistryModule = servicesFolder:WaitForChild("ServiceRegistry") :: ModuleScript

local Logger = require(loggerModule)
local ServiceRegistry = require(serviceRegistryModule)

Logger.info("server", "Booting server composition root")
ServiceRegistry.start()
Logger.info("server", "Server ready")
