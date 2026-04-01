--!strict

export type RemoteKind = "RemoteEvent" | "RemoteFunction"
export type RemoteEventDefinition = {
  name: string,
  kind: "RemoteEvent",
}
export type RemoteFunctionDefinition = {
  name: string,
  kind: "RemoteFunction",
}

local events: { RemoteEventDefinition } = {}
local functions: { RemoteFunctionDefinition } = {}

local RemoteDefinitions = table.freeze({
  Events = table.freeze(events),
  Functions = table.freeze(functions),
})

return RemoteDefinitions
