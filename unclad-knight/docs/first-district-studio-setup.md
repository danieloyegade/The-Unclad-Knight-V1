# First District Studio Setup

The current code expects the first playable area to be built manually in Roblox Studio rather than generated in Lua.

## Required Workspace hierarchy

Create this structure in Studio:

```text
Workspace
  FirstDistrictBlockout (Model or Folder)
    SliceSpawn (Part)
    OrderPickup (Part)
    RouteEndpoint (Part)
```

The names must match exactly.

## What each marker does

- `SliceSpawn`
  - where the player is placed when the slice starts
  - face this part toward the route
- `OrderPickup`
  - the first interaction point
  - place this at the takeaway window, counter, hatch, or pickup threshold
- `RouteEndpoint`
  - the route destination
  - place this at the Arts Council door, intercom, or institutional threshold

The server will automatically add `ProximityPrompt`s named `PickupPrompt` and `EndpointPrompt` if they are missing.

## Marker setup

For all three marker parts:

- `Anchored = true`
- `CanCollide = false`
- `Transparency = 1`
- size them large enough to be easy to select while building

## What to block out around the markers

Build only enough district to support the first loop:

- one spawn edge
- one short main street
- one takeaway threshold
- one alley or service lane
- one route endpoint at an institutional frontage
- one dead zone or side pocket if you want room for the later sword event

## Minimum playable test

When the blockout is in place, the loop should be:

1. player spawns at `SliceSpawn`
2. player walks to `OrderPickup`
3. player triggers pickup
4. UI updates to the carry phase
5. player walks to `RouteEndpoint`
6. player triggers delivery
7. UI updates to the denial beat

## Recommended first pass

Do not build detailed props first.

Start with:

- road planes
- pavements
- 4 to 6 building masses
- one bus stop
- one takeaway frontage
- one civic frontage
- basic lighting anchors

Then test the route, scale, and screenshots before adding more detail.
