--!strict

export type CopySection = {
  Label: string,
  Text: string,
}

export type OpeningBrief = {
  DistrictLabel: string,
  Title: string,
  Subtitle: string,
  Vow: CopySection,
  Omen: CopySection,
}

local vow = table.freeze({
  Label = "TONIGHT'S OATH",
  Text = "Answer the app. Carry the order. Keep your dignity.",
})

local omen = table.freeze({
  Label = "DISTANT ENDPOINT",
  Text = "Somewhere near the Arts Council, effort stops looking like victory.",
})

local OpeningBrief: OpeningBrief = table.freeze({
  DistrictLabel = "COMPRESSED MANCHESTER",
  Title = "THE UNCLAD KNIGHT",
  Subtitle = "Cele rides night deliveries through a city he mistakes for a kingdom.",
  Vow = vow,
  Omen = omen,
})

return OpeningBrief
