--!strict

export type SlicePhase = "ApproachTakeaway" | "CarryToCouncil" | "DeniedByCouncil"

export type SliceState = {
  AccentColor: Color3,
  Subtitle: string,
  ObjectiveLabel: string,
  ObjectiveText: string,
  StatusLabel: string,
  StatusText: string,
}

export type OpeningBrief = {
  DistrictLabel: string,
  Title: string,
  InitialPhase: SlicePhase,
  States: { [string]: SliceState },
}

local states: { [string]: SliceState } = {
  ApproachTakeaway = table.freeze({
    AccentColor = Color3.fromRGB(221, 169, 90),
    Subtitle = "The district is small enough to cross and strange enough to mistake for destiny.",
    ObjectiveLabel = "CURRENT CHARGE",
    ObjectiveText = "Make for the lit takeaway window and claim the order.",
    StatusLabel = "ROUTE",
    StatusText = "Pass the bus stop. Keep to the warm lights. The app calls it work. Cele calls it oath.",
  }),
  CarryToCouncil = table.freeze({
    AccentColor = Color3.fromRGB(242, 190, 104),
    Subtitle = "The parcel weighs almost nothing. The obligation does not.",
    ObjectiveLabel = "CURRENT CHARGE",
    ObjectiveText = "Carry the order across the tram line to the Arts Council entrance.",
    StatusLabel = "ROUTE",
    StatusText = "Cut through the service lane, then climb the lit steps to the civic frontage.",
  }),
  DeniedByCouncil = table.freeze({
    AccentColor = Color3.fromRGB(181, 99, 92),
    Subtitle = "The door remains shut. Nothing noble is waiting on the other side.",
    ObjectiveLabel = "END BEAT",
    ObjectiveText = "The institution accepts delivery without granting meaning, victory, or combat.",
    StatusLabel = "OMEN",
    StatusText = "Direct violence would only flatter the system. Another instrument will be needed later: denunciation.",
  }),
}

local OpeningBrief: OpeningBrief = table.freeze({
  DistrictLabel = "COMPRESSED MANCHESTER",
  Title = "THE UNCLAD KNIGHT",
  InitialPhase = "ApproachTakeaway",
  States = table.freeze(states),
})

return OpeningBrief
