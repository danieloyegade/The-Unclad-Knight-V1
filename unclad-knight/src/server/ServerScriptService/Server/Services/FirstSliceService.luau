--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared") :: Folder
local configFolder = sharedFolder:WaitForChild("Config") :: Folder
local gameFolder = sharedFolder:WaitForChild("Game") :: Folder
local utilFolder = sharedFolder:WaitForChild("Util") :: Folder

local gameConfigModule = configFolder:WaitForChild("GameConfig") :: ModuleScript
local openingBriefModule = gameFolder:WaitForChild("OpeningBrief") :: ModuleScript
local remoteDefinitionsModule = gameFolder:WaitForChild("RemoteDefinitions") :: ModuleScript
local loggerModule = utilFolder:WaitForChild("Logger") :: ModuleScript

local GameConfig = require(gameConfigModule) :: {
  Network: {
    RemotesFolderName: string,
  },
  FirstDistrict: {
    RootName: string,
    SpawnMarkerName: string,
    InteractionMarkerName: string,
    InteractionPromptName: string,
    InteractionActionText: string,
    InteractionObjectText: string,
    EndpointMarkerName: string,
    EndpointPromptName: string,
    EndpointActionText: string,
    EndpointObjectText: string,
  },
}
local OpeningBrief = require(openingBriefModule) :: {
  InitialPhase: string,
}
local RemoteDefinitions = require(remoteDefinitionsModule) :: {
  Names: {
    SlicePhaseChanged: string,
    GetSlicePhase: string,
  },
}
local Logger = require(loggerModule)

local FirstSliceService = {
  name = "FirstSliceService",
}

type SliceWorld = {
  Root: Instance,
  SpawnMarker: BasePart,
  InteractionPrompt: ProximityPrompt,
  EndpointPrompt: ProximityPrompt,
}

local started = false
local sliceWorld: SliceWorld? = nil
local playerPhases: { [Player]: string } = {}

local slicePhaseChangedRemote: RemoteEvent? = nil
local getSlicePhaseFunction: RemoteFunction? = nil

local function createPrompt(parent: BasePart, name: string, actionText: string, objectText: string): ProximityPrompt
  local prompt = Instance.new("ProximityPrompt")
  prompt.Name = name
  prompt.ActionText = actionText
  prompt.ObjectText = objectText
  prompt.HoldDuration = 0.15
  prompt.KeyboardKeyCode = Enum.KeyCode.E
  prompt.MaxActivationDistance = 10
  prompt.RequiresLineOfSight = false
  prompt.Style = Enum.ProximityPromptStyle.Default
  prompt.Parent = parent

  return prompt
end

local function ensureAtmosphere(): Atmosphere
  local existing = Lighting:FindFirstChild("NightAtmosphere")

  if existing == nil then
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = "NightAtmosphere"
    atmosphere.Parent = Lighting
    return atmosphere
  end

  if not existing:IsA("Atmosphere") then
    error("Lighting.NightAtmosphere must be an Atmosphere")
  end

  return existing
end

local function ensureBloom(): BloomEffect
  local existing = Lighting:FindFirstChild("NightBloom")

  if existing == nil then
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "NightBloom"
    bloom.Parent = Lighting
    return bloom
  end

  if not existing:IsA("BloomEffect") then
    error("Lighting.NightBloom must be a BloomEffect")
  end

  return existing
end

local function ensureColorCorrection(): ColorCorrectionEffect
  local existing = Lighting:FindFirstChild("NightGrade")

  if existing == nil then
    local effect = Instance.new("ColorCorrectionEffect")
    effect.Name = "NightGrade"
    effect.Parent = Lighting
    return effect
  end

  if not existing:IsA("ColorCorrectionEffect") then
    error("Lighting.NightGrade must be a ColorCorrectionEffect")
  end

  return existing
end

local function ensureDepthOfField(): DepthOfFieldEffect
  local existing = Lighting:FindFirstChild("NightDepth")

  if existing == nil then
    local effect = Instance.new("DepthOfFieldEffect")
    effect.Name = "NightDepth"
    effect.Parent = Lighting
    return effect
  end

  if not existing:IsA("DepthOfFieldEffect") then
    error("Lighting.NightDepth must be a DepthOfFieldEffect")
  end

  return existing
end

local function ensureSoundGroup(name: string, volume: number): SoundGroup
  local existing = SoundService:FindFirstChild(name)

  if existing == nil then
    local soundGroup = Instance.new("SoundGroup")
    soundGroup.Name = name
    soundGroup.Volume = volume
    soundGroup.Parent = SoundService
    return soundGroup
  end

  if not existing:IsA("SoundGroup") then
    error(string.format("SoundService.%s must be a SoundGroup", name))
  end

  existing.Volume = volume

  return existing
end

local function configureAtmosphere()
  Lighting.Technology = Enum.Technology.Future
  Lighting.GlobalShadows = true
  Lighting.ClockTime = 0.85
  Lighting.Brightness = 1.35
  Lighting.ExposureCompensation = -0.35
  Lighting.Ambient = Color3.fromRGB(16, 18, 22)
  Lighting.OutdoorAmbient = Color3.fromRGB(22, 24, 31)
  Lighting.EnvironmentDiffuseScale = 0.25
  Lighting.EnvironmentSpecularScale = 0.65
  Lighting.FogColor = Color3.fromRGB(22, 25, 31)
  Lighting.FogStart = 50
  Lighting.FogEnd = 260
  Lighting.ShadowSoftness = 0.35

  local atmosphere = ensureAtmosphere()
  atmosphere.Color = Color3.fromRGB(170, 186, 205)
  atmosphere.Decay = Color3.fromRGB(59, 66, 78)
  atmosphere.Density = 0.36
  atmosphere.Glare = 0.15
  atmosphere.Haze = 1.8

  local bloom = ensureBloom()
  bloom.Intensity = 0.32
  bloom.Size = 30
  bloom.Threshold = 1.55

  local colorCorrection = ensureColorCorrection()
  colorCorrection.Brightness = -0.03
  colorCorrection.Contrast = 0.12
  colorCorrection.Saturation = -0.18
  colorCorrection.TintColor = Color3.fromRGB(244, 236, 228)

  local depthOfField = ensureDepthOfField()
  depthOfField.FarIntensity = 0.1
  depthOfField.FocusDistance = 40
  depthOfField.InFocusRadius = 28
  depthOfField.NearIntensity = 0

  SoundService.AmbientReverb = Enum.ReverbType.City
  ensureSoundGroup("DistrictAmbience", 1)
  ensureSoundGroup("RouteFoley", 1)
  ensureSoundGroup("InstitutionTone", 0.85)
end

local function findRequiredBasePart(parent: Instance, name: string): BasePart
  local candidate = parent:FindFirstChild(name, true)

  if candidate == nil then
    error(string.format("%s is missing required marker %s", parent:GetFullName(), name))
  end

  if not candidate:IsA("BasePart") then
    error(string.format("%s must be a BasePart, received %s", candidate:GetFullName(), candidate.ClassName))
  end

  return candidate
end

local function ensurePrompt(parent: BasePart, name: string, actionText: string, objectText: string): ProximityPrompt
  local existingPrompt = parent:FindFirstChild(name)

  if existingPrompt ~= nil then
    if not existingPrompt:IsA("ProximityPrompt") then
      error(string.format("%s must be a ProximityPrompt, received %s", existingPrompt:GetFullName(), existingPrompt.ClassName))
    end

    existingPrompt.ActionText = actionText
    existingPrompt.ObjectText = objectText
    existingPrompt.HoldDuration = 0.15
    existingPrompt.KeyboardKeyCode = Enum.KeyCode.E
    existingPrompt.MaxActivationDistance = 10
    existingPrompt.RequiresLineOfSight = false

    return existingPrompt
  end

  return createPrompt(parent, name, actionText, objectText)
end

local function bindDistrictBlockout(): SliceWorld?
  local districtRoot = Workspace:FindFirstChild(GameConfig.FirstDistrict.RootName)

  if districtRoot == nil then
    Logger.warn(
      "server/slice",
      string.format(
        "Workspace.%s is missing. Create it in Studio with %s, %s, and %s markers to enable the first district blockout",
        GameConfig.FirstDistrict.RootName,
        GameConfig.FirstDistrict.SpawnMarkerName,
        GameConfig.FirstDistrict.InteractionMarkerName,
        GameConfig.FirstDistrict.EndpointMarkerName
      )
    )

    return nil
  end

  if not districtRoot:IsA("Model") and not districtRoot:IsA("Folder") then
    error(
      string.format(
        "Workspace.%s must be a Model or Folder, received %s",
        GameConfig.FirstDistrict.RootName,
        districtRoot.ClassName
      )
    )
  end

  local spawnMarker = findRequiredBasePart(districtRoot, GameConfig.FirstDistrict.SpawnMarkerName)
  local interactionMarker = findRequiredBasePart(districtRoot, GameConfig.FirstDistrict.InteractionMarkerName)
  local endpointMarker = findRequiredBasePart(districtRoot, GameConfig.FirstDistrict.EndpointMarkerName)

  local interactionPrompt = ensurePrompt(
    interactionMarker,
    GameConfig.FirstDistrict.InteractionPromptName,
    GameConfig.FirstDistrict.InteractionActionText,
    GameConfig.FirstDistrict.InteractionObjectText
  )
  local endpointPrompt = ensurePrompt(
    endpointMarker,
    GameConfig.FirstDistrict.EndpointPromptName,
    GameConfig.FirstDistrict.EndpointActionText,
    GameConfig.FirstDistrict.EndpointObjectText
  )

  return {
    Root = districtRoot,
    SpawnMarker = spawnMarker,
    InteractionPrompt = interactionPrompt,
    EndpointPrompt = endpointPrompt,
  }
end

local function getOrCreateRemoteEvent(name: string): RemoteEvent
  local remotesFolder = ReplicatedStorage:WaitForChild(GameConfig.Network.RemotesFolderName)

  if not remotesFolder:IsA("Folder") then
    error(string.format("%s must be a Folder", GameConfig.Network.RemotesFolderName))
  end

  local remote = remotesFolder:WaitForChild(name)

  if not remote:IsA("RemoteEvent") then
    error(string.format("%s must be a RemoteEvent", name))
  end

  return remote
end

local function getOrCreateRemoteFunction(name: string): RemoteFunction
  local remotesFolder = ReplicatedStorage:WaitForChild(GameConfig.Network.RemotesFolderName)

  if not remotesFolder:IsA("Folder") then
    error(string.format("%s must be a Folder", GameConfig.Network.RemotesFolderName))
  end

  local remote = remotesFolder:WaitForChild(name)

  if not remote:IsA("RemoteFunction") then
    error(string.format("%s must be a RemoteFunction", name))
  end

  return remote
end

local function getPhase(player: Player): string
  local currentPhase = playerPhases[player]

  if currentPhase ~= nil then
    return currentPhase
  end

  return OpeningBrief.InitialPhase
end

local function syncPhase(player: Player)
  if slicePhaseChangedRemote == nil then
    return
  end

  slicePhaseChangedRemote:FireClient(player, getPhase(player))
end

local function setPhase(player: Player, phase: string)
  playerPhases[player] = phase
  player:SetAttribute("SlicePhase", phase)
  syncPhase(player)
end

local function positionCharacter(character: Model)
  local world = sliceWorld

  if world == nil then
    return
  end

  local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

  if rootPart == nil or not rootPart:IsA("BasePart") then
    return
  end

  character:PivotTo(world.SpawnMarker.CFrame + Vector3.new(0, 3, 0))
end

local function bindPlayer(player: Player)
  if playerPhases[player] == nil then
    playerPhases[player] = OpeningBrief.InitialPhase
    player:SetAttribute("SlicePhase", OpeningBrief.InitialPhase)
  end

  player.CharacterAdded:Connect(function(character)
    task.defer(function()
      positionCharacter(character)
      syncPhase(player)
    end)
  end)

  if player.Character ~= nil then
    local currentCharacter = player.Character

    task.defer(function()
      if currentCharacter ~= nil then
        positionCharacter(currentCharacter)
      end

      syncPhase(player)
    end)
  else
    syncPhase(player)
  end
end

local function onPickupTriggered(player: Player)
  if getPhase(player) ~= "ApproachTakeaway" then
    return
  end

  setPhase(player, "CarryToCouncil")
  Logger.info("server/slice", string.format("%s claimed the order", player.Name))
end

local function onDropoffTriggered(player: Player)
  if getPhase(player) ~= "CarryToCouncil" then
    return
  end

  setPhase(player, "DeniedByCouncil")
  Logger.info("server/slice", string.format("%s reached the Arts Council denial beat", player.Name))
end

function FirstSliceService.start()
  if started then
    return
  end

  started = true

  configureAtmosphere()

  slicePhaseChangedRemote = getOrCreateRemoteEvent(RemoteDefinitions.Names.SlicePhaseChanged)
  getSlicePhaseFunction = getOrCreateRemoteFunction(RemoteDefinitions.Names.GetSlicePhase)
  getSlicePhaseFunction.OnServerInvoke = function(player: Player)
    return getPhase(player)
  end
  sliceWorld = bindDistrictBlockout()

  local world = sliceWorld

  if world ~= nil then
    world.InteractionPrompt.Triggered:Connect(onPickupTriggered)
    world.EndpointPrompt.Triggered:Connect(onDropoffTriggered)

    Logger.info(
      "server/slice",
      string.format("First district blockout bound at %s", world.Root:GetFullName())
    )
  end

  for _, player in Players:GetPlayers() do
    bindPlayer(player)
  end

  Players.PlayerAdded:Connect(bindPlayer)
  Players.PlayerRemoving:Connect(function(player)
    playerPhases[player] = nil
  end)

  Logger.info("server/slice", "First playable slice ready for a Studio-authored district blockout")
end

return FirstSliceService
