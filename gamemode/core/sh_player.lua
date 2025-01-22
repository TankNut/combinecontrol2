local meta = FindMetaTable("Player")

PlayerVar.Add("ScoreboardTitle", {Default = "", Persist = true, DataType = VARCHAR(64)})
PlayerVar.Add("ScoreboardTitleC", {Default = Vector(255, 255, 255), Persist = true, DataType = BLOB()})
PlayerVar.Add("ScoreboardBadges", {Default = 0, Persist = true, DataType = INT()})

PlayerVar.Add("DonatorActive", {Default = false})
PlayerVar.Add("Appearance", {Default = {}})

PlayerVar.Add("OOCMuted", {Default = 0, Persist = true, DataType = TINYINT()})
