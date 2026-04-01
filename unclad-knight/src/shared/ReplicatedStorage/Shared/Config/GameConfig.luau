--!strict

local Network = table.freeze({
  RemotesFolderName = "Remotes",
})

local GameConfig = table.freeze({
  ProjectName = "The Unclad Knight",
  LogPrefix = "[unclad-knight]",
  Network = Network,
})

return GameConfig
