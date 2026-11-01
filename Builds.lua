local addonName, FTG = ...

FTG.Builds = FTG.Builds or {}

-- Build policy:
--   * Warrior only for v0.1.
--   * Icy Veins is the editorial source of truth.
--   * The leveling route is only populated as far as Icy Veins has actually
--     published/validated it. We do not invent post-beta leveling points.
--   * Endgame profiles are intended for allocating a level-60 respec.
--
-- Build data is deliberately separate from Core/UI so weekly guide updates can
-- replace this file without rewriting the addon.

local function step(tree, talent, rank, level)
    return { tree = tree, talent = talent, rank = rank, level = level }
end

local function ranks(tree, talent, firstRank, lastRank, firstLevel)
    local out = {}
    for rank = firstRank, lastRank do
        out[#out + 1] = step(tree, talent, rank, firstLevel and (firstLevel + rank - firstRank) or nil)
    end
    return out
end

local function append(dst, src)
    for _, value in ipairs(src) do
        dst[#dst + 1] = value
    end
end

-- Icy Veins Fury leveling route currently published through the level-30 beta.
local leveling = {}
append(leveling, ranks("Fury", "Cruelty", 1, 5, 10))
append(leveling, ranks("Fury", "Unbridled Wrath", 1, 5, 15))
append(leveling, ranks("Fury", "Furious Precision", 1, 3, 20))
leveling[#leveling + 1] = step("Fury", "Piercing Howl", 1, 23)
leveling[#leveling + 1] = step("Fury", "Lingering Rage", 1, 24)
append(leveling, ranks("Fury", "Dual Wield Specialization", 1, 5, 25))
leveling[#leveling + 1] = step("Fury", "Death Wish", 1, 30)

-- Level-60 Fury DPS 17/34/0. This is an allocation order for a respec, not a
-- claim that Icy Veins recommends leveling in this exact order.
local dps60 = {}
append(dps60, ranks("Fury", "Cruelty", 1, 5))
append(dps60, ranks("Fury", "Unbridled Wrath", 1, 5))
append(dps60, ranks("Fury", "Furious Precision", 1, 3))
append(dps60, ranks("Fury", "Booming Voice", 1, 2))
append(dps60, ranks("Fury", "Dual Wield Specialization", 1, 5))
dps60[#dps60 + 1] = step("Fury", "Death Wish", 1)
append(dps60, ranks("Fury", "Enrage", 1, 4))
append(dps60, ranks("Fury", "Improved Execute", 1, 2))
dps60[#dps60 + 1] = step("Fury", "Raging Blows", 1)
append(dps60, ranks("Fury", "Flurry", 1, 2))
dps60[#dps60 + 1] = step("Fury", "Bloodthirst", 1)
append(dps60, ranks("Fury", "Flurry", 3, 5))

append(dps60, ranks("Arms", "Improved Heroic Strike", 1, 3))
append(dps60, ranks("Arms", "Improved Rend", 1, 3))
append(dps60, ranks("Arms", "Improved Tactical Mastery", 1, 4))
append(dps60, ranks("Arms", "Deep Wounds", 1, 3))
dps60[#dps60 + 1] = step("Arms", "Improved Tactical Mastery", 5)
dps60[#dps60 + 1] = step("Arms", "Anger Management", 1)
append(dps60, ranks("Arms", "Impale", 1, 2))

-- Icy Veins level-60 Protection 0/20/31 default Shield Slam profile.
local tank60 = {}
append(tank60, ranks("Protection", "Shield Specialization", 1, 5))
append(tank60, ranks("Protection", "Improved Revenge", 1, 3))
append(tank60, ranks("Protection", "Improved Thunder Clap", 1, 2))
tank60[#tank60 + 1] = step("Protection", "Last Stand", 1)
append(tank60, ranks("Protection", "Master of Defense", 1, 2))
tank60[#tank60 + 1] = step("Protection", "Improved Thunder Clap", 3)
append(tank60, ranks("Protection", "Defiance", 1, 3))
append(tank60, ranks("Protection", "Improved Sunder Armor", 1, 2))
tank60[#tank60 + 1] = step("Protection", "Vanguard", 1)
tank60[#tank60 + 1] = step("Protection", "Improved Shield Wall", 1)
tank60[#tank60 + 1] = step("Protection", "Concussion Blow", 1)
append(tank60, ranks("Protection", "Focused Rage", 1, 3))
append(tank60, ranks("Protection", "Bastion", 1, 5))
tank60[#tank60 + 1] = step("Protection", "Shield Slam", 1)

append(tank60, ranks("Fury", "Cruelty", 1, 5))
append(tank60, ranks("Fury", "Unbridled Wrath", 1, 5))
append(tank60, ranks("Fury", "Blood Craze", 1, 3))
append(tank60, ranks("Fury", "Lingering Rage", 1, 2))
tank60[#tank60 + 1] = step("Fury", "Raging Blows", 1)
append(tank60, ranks("Fury", "Enrage", 1, 4))

FTG.Builds.WARRIOR = {
    leveling = {
        key = "leveling",
        name = "Leveling - Fury",
        shortName = "Leveling",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/fury-warrior-melee-dps-pve-guide",
        sourceLastUpdated = "2026-10-27",
        reviewed = "2026-11-01",
        coverage = "Levels 10-30",
        maxLevelCovered = 30,
        split = "0/21/0 at level 30",
        steps = leveling,
        note = "Icy Veins has not yet published the live 31-60 leveling route. Forever Talent Guide will not invent those points.",
    },

    dps = {
        key = "dps",
        name = "Level 60 DPS - Fury",
        shortName = "DPS 60",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/fury-warrior-melee-dps-pve-spec-builds-talents",
        sourceLastUpdated = "2026-10-31",
        reviewed = "2026-11-01",
        coverage = "Level 60",
        requiredLevel = 60,
        split = "17/34/0",
        steps = dps60,
        note = "Bloodthirst dual-wield PvE build. Allocation order is provided for a level-60 respec.",
    },

    tank = {
        key = "tank",
        name = "Level 60 Tank - Protection",
        shortName = "Tank 60",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/protection-warrior-tank-pve-spec-builds-talents",
        sourceLastUpdated = "2026-10-31",
        reviewed = "2026-11-01",
        coverage = "Level 60",
        requiredLevel = 60,
        split = "0/20/31",
        steps = tank60,
        note = "Shield Slam tank build. Allocation order is provided for a level-60 respec.",
    },
}

FTG.BuildMeta = {
    dataVersion = 1,
    editorialSource = "Icy Veins",
    reviewed = "2026-11-01",
    updateCadence = "Tuesday",
}
