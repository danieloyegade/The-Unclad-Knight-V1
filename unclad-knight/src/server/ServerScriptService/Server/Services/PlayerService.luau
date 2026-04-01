--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local Logger = require(loggerModule)

local PlayerService = {
  name = "PlayerService",
}

local started = false

local function onCharacterAdded(player: Player, character: Model)
  Logger.info("server/player", string.format("Character ready for %s (%s)", player.Name, character.Name))
end

local function bindPlayer(player: Player)
  Logger.info("server/player", string.format("Player joined: %s", player.Name))

  player.CharacterAdded:Connect(function(character)
    onCharacterAdded(player, character)
  end)

  if player.Character ~= nil then
    onCharacterAdded(player, player.Character)
  end
end

function PlayerService.start()
  if started then
    return
  end

  started = true

  for _, player in Players:GetPlayers() do
    bindPlayer(player)
  end

  Players.PlayerAdded:Connect(bindPlayer)
end

return PlayerService
