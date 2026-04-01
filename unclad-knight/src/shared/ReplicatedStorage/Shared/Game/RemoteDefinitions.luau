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

local names = table.freeze({
  SlicePhaseChanged = "SlicePhaseChanged",
  GetSlicePhase = "GetSlicePhase",
})

local events: { RemoteEventDefinition } = {
  {
    name = names.SlicePhaseChanged,
    kind = "RemoteEvent",
  },
}

local functions: { RemoteFunctionDefinition } = {
  {
    name = names.GetSlicePhase,
    kind = "RemoteFunction",
  },
}

local RemoteDefinitions = table.freeze({
  Names = names,
  Events = table.freeze(events),
  Functions = table.freeze(functions),
})

return RemoteDefinitions
