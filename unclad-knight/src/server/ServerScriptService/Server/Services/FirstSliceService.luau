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

local GameConfig = require(gameConfigModule)
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
  SpawnCFrame: CFrame,
  PickupPrompt: ProximityPrompt,
  DropoffPrompt: ProximityPrompt,
}

local WORLD_MODEL_NAME = "FirstSliceDistrict"

local palette = {
  Void = Color3.fromRGB(10, 12, 15),
  Road = Color3.fromRGB(28, 30, 36),
  Pavement = Color3.fromRGB(56, 58, 64),
  Concrete = Color3.fromRGB(89, 94, 102),
  Estate = Color3.fromRGB(71, 77, 86),
  Takeaway = Color3.fromRGB(112, 63, 48),
  Civic = Color3.fromRGB(67, 72, 79),
  WindowWarm = Color3.fromRGB(255, 204, 134),
  LampWarm = Color3.fromRGB(255, 196, 129),
  Neon = Color3.fromRGB(242, 184, 93),
  Rail = Color3.fromRGB(124, 132, 145),
  Watcher = Color3.fromRGB(147, 153, 165),
  Fence = Color3.fromRGB(84, 88, 96),
}

local started = false
local sliceWorld: SliceWorld? = nil
local playerPhases: { [Player]: string } = {}

local slicePhaseChangedRemote: RemoteEvent? = nil
local getSlicePhaseFunction: RemoteFunction? = nil

local function createPart(
  parent: Instance,
  name: string,
  size: Vector3,
  cframe: CFrame,
  color: Color3,
  material: Enum.Material
): Part
  local part = Instance.new("Part")
  part.Name = name
  part.Anchored = true
  part.CanCollide = true
  part.Material = material
  part.Color = color
  part.Size = size
  part.CFrame = cframe
  part.TopSurface = Enum.SurfaceType.Smooth
  part.BottomSurface = Enum.SurfaceType.Smooth
  part.Parent = parent

  return part
end

local function createTextSign(parent: BasePart, name: string, face: Enum.NormalId, text: string)
  local surfaceGui = Instance.new("SurfaceGui")
  surfaceGui.Name = name
  surfaceGui.Face = face
  surfaceGui.LightInfluence = 0
  surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
  surfaceGui.PixelsPerStud = 40
  surfaceGui.Parent = parent

  local textLabel = Instance.new("TextLabel")
  textLabel.BackgroundTransparency = 1
  textLabel.Font = Enum.Font.Code
  textLabel.Size = UDim2.fromScale(1, 1)
  textLabel.Text = text
  textLabel.TextColor3 = palette.WindowWarm
  textLabel.TextScaled = true
  textLabel.Parent = surfaceGui
end

local function createPointLight(parent: Instance, color: Color3, brightness: number, range: number)
  local light = Instance.new("PointLight")
  light.Color = color
  light.Brightness = brightness
  light.Range = range
  light.Shadows = true
  light.Parent = parent

  return light
end

local function createStreetLight(parent: Instance, basePosition: Vector3)
  local pole = createPart(
    parent,
    "StreetLightPole",
    Vector3.new(0.8, 11, 0.8),
    CFrame.new(basePosition + Vector3.new(0, 5.5, 0)),
    Color3.fromRGB(88, 92, 102),
    Enum.Material.Metal
  )

  local arm = createPart(
    parent,
    "StreetLightArm",
    Vector3.new(3.2, 0.25, 0.25),
    CFrame.new(basePosition + Vector3.new(1.4, 10.2, 0)),
    Color3.fromRGB(96, 100, 110),
    Enum.Material.Metal
  )
  arm.CanCollide = false

  local lamp = createPart(
    parent,
    "StreetLightLamp",
    Vector3.new(0.8, 0.4, 1.2),
    CFrame.new(basePosition + Vector3.new(2.7, 9.8, 0)),
    palette.LampWarm,
    Enum.Material.Neon
  )
  lamp.CanCollide = false

  createPointLight(lamp, palette.LampWarm, 2.3, 26)

  return pole
end

local function createWatcher(parent: Instance, basePosition: Vector3, facing: number)
  local pole = createPart(
    parent,
    "WatcherPole",
    Vector3.new(0.7, 8, 0.7),
    CFrame.new(basePosition + Vector3.new(0, 4, 0)),
    palette.Watcher,
    Enum.Material.Metal
  )

  local camera = createPart(
    parent,
    "WatcherCamera",
    Vector3.new(1.2, 0.7, 0.7),
    CFrame.new(basePosition + Vector3.new(0.55, 7.4, 0)) * CFrame.Angles(0, math.rad(facing), 0),
    palette.Watcher,
    Enum.Material.Metal
  )
  camera.CanCollide = false

  local glare = Instance.new("SpotLight")
  glare.Angle = 42
  glare.Brightness = 1.4
  glare.Color = Color3.fromRGB(191, 208, 255)
  glare.Face = Enum.NormalId.Right
  glare.Range = 30
  glare.Shadows = true
  glare.Parent = camera

  return pole
end

local function createPrompt(parent: Instance, actionText: string, objectText: string): ProximityPrompt
  local prompt = Instance.new("ProximityPrompt")
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

local function buildWorld(): SliceWorld
  local existing = Workspace:FindFirstChild(WORLD_MODEL_NAME)

  if existing ~= nil then
    if existing:IsA("Model") then
      local pickupPrompt = existing:FindFirstChild("PickupPrompt", true)
      local dropoffPrompt = existing:FindFirstChild("DropoffPrompt", true)
      local spawnMarker = existing:FindFirstChild("SliceSpawn")

      if pickupPrompt ~= nil and dropoffPrompt ~= nil and spawnMarker ~= nil and pickupPrompt:IsA("ProximityPrompt")
        and dropoffPrompt:IsA("ProximityPrompt") and spawnMarker:IsA("BasePart")
      then
        return {
          SpawnCFrame = spawnMarker.CFrame + Vector3.new(0, 3, 0),
          PickupPrompt = pickupPrompt,
          DropoffPrompt = dropoffPrompt,
        }
      end
    else
      error(string.format("Workspace.%s must be a Model", WORLD_MODEL_NAME))
    end
  end

  local district = Instance.new("Model")
  district.Name = WORLD_MODEL_NAME
  district.Parent = Workspace

  local ground = createPart(
    district,
    "GroundPlane",
    Vector3.new(260, 1, 180),
    CFrame.new(42, -0.5, 5),
    palette.Void,
    Enum.Material.Asphalt
  )
  ground.Reflectance = 0.05

  local mainRoad = createPart(
    district,
    "MainRoad",
    Vector3.new(180, 1.2, 28),
    CFrame.new(36, 0, 0),
    palette.Road,
    Enum.Material.Asphalt
  )
  mainRoad.Reflectance = 0.09

  local northPavement = createPart(
    district,
    "NorthPavement",
    Vector3.new(180, 1.05, 10),
    CFrame.new(36, 0.05, 19),
    palette.Pavement,
    Enum.Material.Concrete
  )
  northPavement.Reflectance = 0.03

  local southPavement = createPart(
    district,
    "SouthPavement",
    Vector3.new(180, 1.05, 10),
    CFrame.new(36, 0.05, -19),
    palette.Pavement,
    Enum.Material.Concrete
  )
  southPavement.Reflectance = 0.03

  local serviceLane = createPart(
    district,
    "ServiceLane",
    Vector3.new(80, 1.05, 16),
    CFrame.new(94, 0.05, 30),
    Color3.fromRGB(32, 35, 41),
    Enum.Material.Asphalt
  )
  serviceLane.Reflectance = 0.08

  local estateA = createPart(
    district,
    "EstateBlockA",
    Vector3.new(42, 28, 26),
    CFrame.new(-46, 14, 48),
    palette.Estate,
    Enum.Material.Concrete
  )
  local estateB = createPart(
    district,
    "EstateBlockB",
    Vector3.new(32, 22, 18),
    CFrame.new(-2, 11, 44),
    palette.Estate,
    Enum.Material.Concrete
  )

  local yardWall = createPart(
    district,
    "EstateWall",
    Vector3.new(46, 7, 1.2),
    CFrame.new(-26, 3.5, 32),
    palette.Concrete,
    Enum.Material.Concrete
  )

  local spawnMarker = createPart(
    district,
    "SliceSpawn",
    Vector3.new(8, 1, 8),
    CFrame.new(-66, 0.55, 18),
    palette.Pavement,
    Enum.Material.Concrete
  )
  spawnMarker.Transparency = 0.15

  local busStopBack = createPart(
    district,
    "BusStopBack",
    Vector3.new(10, 4, 0.5),
    CFrame.new(-8, 2.4, 23.5),
    Color3.fromRGB(88, 94, 107),
    Enum.Material.Metal
  )
  local busStopRoof = createPart(
    district,
    "BusStopRoof",
    Vector3.new(10, 0.4, 4),
    CFrame.new(-8, 4.6, 21.7),
    Color3.fromRGB(77, 83, 95),
    Enum.Material.Metal
  )
  busStopRoof.CanCollide = false
  createTextSign(busStopBack, "BusStopSign", Enum.NormalId.Front, "BUS STOP")

  local takeaway = createPart(
    district,
    "TakeawayBuilding",
    Vector3.new(34, 16, 20),
    CFrame.new(40, 8, -28),
    palette.Takeaway,
    Enum.Material.Brick
  )
  local takeawayCounter = createPart(
    district,
    "TakeawayCounter",
    Vector3.new(12, 1.4, 2.6),
    CFrame.new(40, 2.2, -16.7),
    Color3.fromRGB(72, 47, 38),
    Enum.Material.WoodPlanks
  )
  local takeawaySign = createPart(
    district,
    "TakeawaySign",
    Vector3.new(16, 2, 0.4),
    CFrame.new(40, 9.8, -17.7),
    palette.Neon,
    Enum.Material.Neon
  )
  takeawaySign.CanCollide = false
  createTextSign(takeawaySign, "TakeawayText", Enum.NormalId.Front, "NIGHT TAKEAWAY")

  local takeawayGlow = createPart(
    district,
    "TakeawayGlow",
    Vector3.new(12, 3, 0.3),
    CFrame.new(40, 5.7, -17.4),
    palette.WindowWarm,
    Enum.Material.Neon
  )
  takeawayGlow.CanCollide = false
  createPointLight(takeawayGlow, palette.WindowWarm, 1.9, 18)

  local alleyWallNorth = createPart(
    district,
    "AlleyWallNorth",
    Vector3.new(46, 12, 1.6),
    CFrame.new(68, 6, 13.5),
    palette.Concrete,
    Enum.Material.Concrete
  )
  local alleyWallSouth = createPart(
    district,
    "AlleyWallSouth",
    Vector3.new(46, 12, 1.6),
    CFrame.new(68, 6, 4.5),
    palette.Concrete,
    Enum.Material.Concrete
  )
  local alleyLink = createPart(
    district,
    "AlleyLink",
    Vector3.new(12, 1.1, 9),
    CFrame.new(56, 0.08, 9),
    Color3.fromRGB(37, 40, 46),
    Enum.Material.Asphalt
  )
  alleyLink.Reflectance = 0.08

  local tramRailA = createPart(
    district,
    "TramRailA",
    Vector3.new(2, 0.3, 56),
    CFrame.new(88, 0.8, 8),
    palette.Rail,
    Enum.Material.Metal
  )
  local tramRailB = createPart(
    district,
    "TramRailB",
    Vector3.new(2, 0.3, 56),
    CFrame.new(92, 0.8, 8),
    palette.Rail,
    Enum.Material.Metal
  )

  local civicBuilding = createPart(
    district,
    "ArtsCouncilBuilding",
    Vector3.new(44, 24, 28),
    CFrame.new(146, 12, 28),
    palette.Civic,
    Enum.Material.Concrete
  )
  createTextSign(civicBuilding, "CouncilSign", Enum.NormalId.Left, "ARTS COUNCIL")

  local civicSteps = createPart(
    district,
    "CouncilSteps",
    Vector3.new(20, 1.4, 12),
    CFrame.new(123, 1, 28),
    palette.Concrete,
    Enum.Material.Concrete
  )
  local civicLanding = createPart(
    district,
    "CouncilLanding",
    Vector3.new(10, 1.4, 12),
    CFrame.new(132, 2.1, 28),
    palette.Concrete,
    Enum.Material.Concrete
  )
  local civicDoor = createPart(
    district,
    "CouncilDoor",
    Vector3.new(0.6, 10, 8),
    CFrame.new(124.2, 6.5, 28),
    Color3.fromRGB(38, 42, 48),
    Enum.Material.Metal
  )
  local intercom = createPart(
    district,
    "CouncilIntercom",
    Vector3.new(0.6, 2.4, 2.2),
    CFrame.new(123.7, 4, 20),
    Color3.fromRGB(125, 130, 138),
    Enum.Material.Metal
  )
  local civicLight = createPart(
    district,
    "CouncilLight",
    Vector3.new(0.5, 0.5, 6),
    CFrame.new(123.6, 9.5, 28),
    palette.WindowWarm,
    Enum.Material.Neon
  )
  civicLight.CanCollide = false
  createPointLight(civicLight, palette.WindowWarm, 2, 20)

  local deadZoneLot = createPart(
    district,
    "DeadZoneLot",
    Vector3.new(44, 1.05, 28),
    CFrame.new(104, 0.06, -36),
    Color3.fromRGB(24, 26, 29),
    Enum.Material.Concrete
  )
  deadZoneLot.Reflectance = 0.02
  local deadZoneFenceA = createPart(
    district,
    "DeadZoneFenceA",
    Vector3.new(44, 3, 0.4),
    CFrame.new(104, 1.5, -22),
    palette.Fence,
    Enum.Material.Metal
  )
  local deadZoneFenceB = createPart(
    district,
    "DeadZoneFenceB",
    Vector3.new(44, 3, 0.4),
    CFrame.new(104, 1.5, -50),
    palette.Fence,
    Enum.Material.Metal
  )

  local pickupPrompt = createPrompt(takeawayCounter, "Claim Order", "Takeaway Window")
  pickupPrompt.Name = "PickupPrompt"

  local dropoffPrompt = createPrompt(intercom, "Present Order", "Arts Council Door")
  dropoffPrompt.Name = "DropoffPrompt"

  createStreetLight(district, Vector3.new(-58, 0, 24))
  createStreetLight(district, Vector3.new(-10, 0, 24))
  createStreetLight(district, Vector3.new(32, 0, 18))
  createStreetLight(district, Vector3.new(72, 0, 14))
  createStreetLight(district, Vector3.new(110, 0, 32))
  createStreetLight(district, Vector3.new(130, 0, 18))

  createWatcher(district, Vector3.new(16, 0, 30), 180)
  createWatcher(district, Vector3.new(98, 0, 38), 180)

  estateA:SetAttribute("Landmark", "Estate")
  takeaway:SetAttribute("Landmark", "Takeaway")
  civicBuilding:SetAttribute("Landmark", "ArtsCouncil")

  return {
    SpawnCFrame = CFrame.new(-66, 4.5, 18) * CFrame.Angles(0, math.rad(90), 0),
    PickupPrompt = pickupPrompt,
    DropoffPrompt = dropoffPrompt,
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

  character:PivotTo(world.SpawnCFrame)
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
  sliceWorld = buildWorld()

  slicePhaseChangedRemote = getOrCreateRemoteEvent(RemoteDefinitions.Names.SlicePhaseChanged)
  getSlicePhaseFunction = getOrCreateRemoteFunction(RemoteDefinitions.Names.GetSlicePhase)
  getSlicePhaseFunction.OnServerInvoke = function(player: Player)
    return getPhase(player)
  end

  local world = sliceWorld

  if world == nil then
    error("First slice world failed to build")
  end

  world.PickupPrompt.Triggered:Connect(onPickupTriggered)
  world.DropoffPrompt.Triggered:Connect(onDropoffTriggered)

  for _, player in Players:GetPlayers() do
    bindPlayer(player)
  end

  Players.PlayerAdded:Connect(bindPlayer)
  Players.PlayerRemoving:Connect(function(player)
    playerPhases[player] = nil
  end)

  Logger.info("server/slice", "First playable slice ready: estate to takeaway to Arts Council denial")
end

return FirstSliceService
