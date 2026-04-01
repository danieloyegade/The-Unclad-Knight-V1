--!strict

local sharedFolder = script.Parent.Parent
local configFolder = sharedFolder:WaitForChild("Config") :: Folder
local gameConfigModule = configFolder:WaitForChild("GameConfig") :: ModuleScript
local GameConfig = require(gameConfigModule)

local Logger = {}

local function emit(level: "INFO" | "WARN", scope: string, message: string)
  local formattedMessage = string.format("%s [%s] [%s] %s", GameConfig.LogPrefix, level, scope, message)

  if level == "WARN" then
    warn(formattedMessage)
    return
  end

  print(formattedMessage)
end

function Logger.info(scope: string, message: string)
  emit("INFO", scope, message)
end

function Logger.warn(scope: string, message: string)
  emit("WARN", scope, message)
end

return Logger
