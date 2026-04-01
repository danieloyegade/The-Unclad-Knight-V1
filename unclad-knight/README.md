# The Unclad Knight

The Unclad Knight is an early Roblox Studio + Luau project built as a clean Rojo-based foundation for a small, atmospheric game. The codebase is intentionally light right now. The goal is to support a restrained, nocturnal, urban-myth tone without locking the project into oversized systems too early.

## Current baseline

- Rojo sync is configured in [default.project.json](default.project.json).
- Client code boots from `StarterPlayerScripts/Client`.
- Server code boots from `ServerScriptService/Server`.
- Shared code lives in `ReplicatedStorage/Shared`.
- A `ReplicatedStorage/Remotes` folder is reserved for network objects.
- `Lighting`, `SoundService`, and `StarterGui` are mapped so authored atmosphere, ambience, and UI can move into source control as the first real content appears.

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

## Working notes

- Keep systems small and readable. Add new services or controllers only when they own a clear responsibility.
- Add remotes only when a real interaction, objective, or UI flow requires them.
- Treat atmosphere as part of design, not late polish. Lighting, ambience, and world composition should arrive early in the first playable slice.
- Avoid turning `Shared/Util` into a dumping ground. Prefer domain modules once the game has real systems.

## Suggested next slice

Build one tiny playable district at night:

- one spawn point
- one short route through a small urban space
- one interaction or objective
- one clear end point

That is enough to start testing movement, scale, lighting, ambience, pacing, and tone without pretending the full game design is settled.
