PlayerVar.Add("ToolTrust", {Default = TOOLTRUST_BANNED,  Persist = true, DataType = TINYINT()})
PlayerVar.Add("PhysTrust", {Default = PHYSTRUST_ENABLED, Persist = true, DataType = TINYINT()})
PlayerVar.Add("PropTrust", {Default = PROPTRUST_ENABLED, Persist = true, DataType = TINYINT()})

EntityVar.Add("PropCreator",     {Default = ""})
EntityVar.Add("PropSteamID",     {Default = ""})
EntityVar.Add("PropDescription", {Default = ""})
EntityVar.Add("PropSaved",       {Default = false})
EntityVar.Add("FakePlayer",      {Default = NULL})
