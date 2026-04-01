# The Unclad Knight

The Unclad Knight is a Roblox Studio + Luau project for a small, authored city fragment set in a compressed mythic Manchester. It is not a generic fantasy game and it is not a literal open-world recreation of the city. V1 should feel urban, nocturnal, low-poly, lonely, restrained, and cinematic.

The player is Cele, a delivery rider who believes himself to be a knight. The game works only if that contradiction stays intact:

- Cele is noble.
- Cele is deluded.

The tone should sit between documentary realism and theatrical stage logic. Labour is reframed as oath. The app behaves like an invisible lord. Dignity matters as much as progression.

## Direction docs

- [Creative direction](docs/creative-direction.md)
- [MVP vertical slice](docs/mvp-vertical-slice.md)

## Current baseline

- Rojo sync is configured in [default.project.json](default.project.json).
- Client code boots from `StarterPlayerScripts/Client`.
- Server code boots from `ServerScriptService/Server`.
- Shared code lives in `ReplicatedStorage/Shared`.
- A `ReplicatedStorage/Remotes` folder is reserved for network objects.
- `Lighting`, `SoundService`, and `StarterGui` are mapped so atmosphere, ambience, and UI can move into source control as soon as the first playable slice needs them.

## Source layout

```text
src/
  client/StarterPlayer/StarterPlayerScripts/Client/
    Controllers/
    UI/
    Main.client.luau
  server/ServerScriptService/Server/
    Services/
    Main.server.luau
  shared/ReplicatedStorage/
    Remotes/
    Shared/
      Config/
      Game/
      Types/
      Util/
  lighting/Lighting/
  sound/SoundService/
  ui/StarterGui/
```

## Working rules

- Keep systems small, readable, and tied to a real slice of play.
- Do not introduce oversized combat, inventory, lore, or open-world frameworks unless the design explicitly needs them.
- Treat atmosphere as core design work, not late polish.
- Prefer dense, memorable spaces over large empty maps.
- Use shared modules for domain concepts once they are real; keep utility code narrow.

## Immediate target

Build one tiny district at night:

- one spawn point
- one short route
- one delivery framed as an oath
- one institutional endpoint that frustrates direct heroic resolution

That is enough to test movement, scale, mood, lighting, pacing, and the project's narrative stance without pretending the whole mythology is already systematised.
