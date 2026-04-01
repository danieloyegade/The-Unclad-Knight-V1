--!strict

local Network = table.freeze({
  RemotesFolderName = "Remotes",
})

local FirstDistrict = table.freeze({
  RootName = "FirstDistrictBlockout",
  SpawnMarkerName = "SliceSpawn",
  InteractionMarkerName = "OrderPickup",
  InteractionPromptName = "PickupPrompt",
  InteractionActionText = "Claim Order",
  InteractionObjectText = "Takeaway Window",
  EndpointMarkerName = "RouteEndpoint",
  EndpointPromptName = "EndpointPrompt",
  EndpointActionText = "Present Order",
  EndpointObjectText = "Arts Council Door",
})

local GameConfig = table.freeze({
  ProjectName = "The Unclad Knight",
  LogPrefix = "[unclad-knight]",
  Network = Network,
  FirstDistrict = FirstDistrict,
})

return GameConfig
