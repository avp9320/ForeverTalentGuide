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

local function step(tree, talent, rank, level, inferred)
    return { tree = tree, talent = talent, rank = rank, level = level, inferred = inferred or false }
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

-- Icy Veins Fury leveling milestones, Nov 3 2026.
-- Levels explicitly discussed in the Icy Veins article are exact milestones.
-- All fills between those milestones are flagged inferred, not attributed to
-- the site's interactive talent slider, whose full values are not public text.
local leveling = {}
append(leveling, ranks("Fury", "Cruelty", 1, 5, 10))
append(leveling, ranks("Fury", "Unbridled Wrath", 1, 5, 15))
append(leveling, ranks("Fury", "Furious Precision", 1, 3, 20))
leveling[#leveling + 1] = step("Fury", "Piercing Howl", 1, 23, true)
leveling[#leveling + 1] = step("Fury", "Lingering Rage", 1, 24, true)
append(leveling, ranks("Fury", "Dual Wield Specialization", 1, 5, 25))
leveling[#leveling + 1] = step("Fury", "Death Wish", 1, 30)
leveling[#leveling + 1] = step("Fury", "Reckless Swings", 1, 31)
append(leveling, ranks("Fury", "Improved Berserker Rage", 1, 2, 32))
leveling[#leveling + 1] = step("Fury", "Gore Drinker", 1, 34, true)
append(leveling, ranks("Fury", "Improved Whirlwind", 1, 2, 35))
append(leveling, ranks("Fury", "Flurry", 1, 3, 37))
leveling[#leveling + 1] = step("Fury", "Bloodthirst", 1, 40)
-- The later Icy Veins article names Improved Tactical Mastery at 50-52,
-- but not the complete rank order 41-49 or 53-60.
append(leveling, {
    step("Arms", "Improved Rend", 1, 41, true),
    step("Arms", "Improved Rend", 2, 42, true),
    step("Arms", "Improved Rend", 3, 43, true),
    step("Arms", "Improved Heroic Strike", 1, 44, true),
    step("Arms", "Improved Heroic Strike", 2, 45, true),
    step("Arms", "Improved Overpower", 1, 46, true),
    step("Arms", "Improved Overpower", 2, 47, true),
    step("Arms", "Improved Tactical Mastery", 1, 48, true),
    step("Arms", "Improved Tactical Mastery", 2, 49, true),
    step("Arms", "Improved Tactical Mastery", 3, 50),
    step("Arms", "Improved Tactical Mastery", 4, 51),
    step("Arms", "Improved Tactical Mastery", 5, 52),
    step("Arms", "Anger Management", 1, 53, true),
    step("Arms", "Deep Wounds", 1, 54, true),
    step("Arms", "Deep Wounds", 2, 55, true),
    step("Arms", "Deep Wounds", 3, 56, true),
    step("Arms", "Impale", 1, 57, true),
    step("Arms", "Impale", 2, 58, true),
    step("Arms", "Improved Heroic Strike", 3, 59, true),
    step("Arms", "Deflection", 1, 60, true),
})

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

-- Arms leveling is based on Icy Veins' Nov 3 Warrior leveling guide.
-- The guide confirms the named milestones but its interactive slider does
-- not publish every intermediate point as readable text. Those particular
-- in-between ranks are transparently tagged as inferred. Never confuse an
-- inferred level order with a verbatim Icy Veins recommendation.
local armsLeveling = {
    step("Arms", "Improved Rend", 1, 10),
    step("Arms", "Improved Rend", 2, 11),
    step("Arms", "Improved Rend", 3, 12),
    step("Arms", "Improved Heroic Strike", 1, 13, true),
    step("Arms", "Improved Heroic Strike", 2, 14, true),
    step("Arms", "Improved Overpower", 1, 15),
    step("Arms", "Improved Overpower", 2, 16),
    step("Arms", "Improved Charge", 1, 17),
    step("Arms", "Improved Charge", 2, 18),
    step("Arms", "Improved Tactical Mastery", 1, 19),
    step("Arms", "Improved Tactical Mastery", 2, 20),
    step("Arms", "Improved Tactical Mastery", 3, 21),
    step("Arms", "Anger Management", 1, 22),
    step("Arms", "Deep Wounds", 1, 23, true),
    step("Arms", "Deep Wounds", 2, 24, true),
    step("Arms", "Spearing Strike", 1, 25),
    step("Arms", "Deep Wounds", 3, 26, true),
    step("Arms", "Two-Handed Weapon Specialization", 1, 27, true),
    step("Arms", "Two-Handed Weapon Specialization", 2, 28, true),
    step("Arms", "Two-Handed Weapon Specialization", 3, 29, true),
    step("Arms", "Sweeping Strikes", 1, 30),
    step("Arms", "Bloodthrill", 1, 31),
    step("Arms", "Bloodthrill", 2, 32),
    step("Arms", "Weaponmaster", 1, 33),
    step("Arms", "Weaponmaster", 2, 34),
    step("Arms", "Improved Slam", 1, 35),
    step("Arms", "Improved Slam", 2, 36),
    step("Arms", "Weaponmaster", 3, 37),
    step("Arms", "Weaponmaster", 4, 38),
    step("Arms", "Weaponmaster", 5, 39),
    step("Arms", "Mortal Strike", 1, 40),
    step("Fury", "Cruelty", 1, 41, true),
    step("Fury", "Cruelty", 2, 42, true),
    step("Fury", "Cruelty", 3, 43, true),
    step("Fury", "Cruelty", 4, 44, true),
    step("Fury", "Cruelty", 5, 45, true),
    step("Fury", "Lingering Rage", 1, 46),
    step("Fury", "Lingering Rage", 2, 47),
    step("Fury", "Lingering Rage", 3, 48),
    step("Fury", "Lingering Rage", 4, 49),
    step("Fury", "Lingering Rage", 5, 50),
    step("Fury", "Unbridled Wrath", 1, 51, true),
    step("Fury", "Unbridled Wrath", 2, 52, true),
    step("Fury", "Unbridled Wrath", 3, 53, true),
    step("Fury", "Unbridled Wrath", 4, 54, true),
    step("Fury", "Unbridled Wrath", 5, 55, true),
    step("Fury", "Reckless Swings", 1, 56),
    step("Fury", "Improved Execute", 1, 57, true),
    step("Arms", "Improved Heroic Strike", 3, 58, true),
    step("Protection", "Improved Bloodrage", 1, 59, true),
    step("Protection", "Improved Bloodrage", 2, 60, true),
}

-- Icy Veins Nov 3 final 32/17/2 Mortal Strike PvE build. Exact final ranks;
-- ordered here into a legal, prerequisite-aware level-60 respec sequence.
local armsDPS60 = {
    step("Arms", "Improved Rend", 1),
    step("Arms", "Improved Rend", 2),
    step("Arms", "Improved Rend", 3),
    step("Arms", "Improved Heroic Strike", 1),
    step("Arms", "Improved Heroic Strike", 2),
    step("Arms", "Improved Overpower", 1),
    step("Arms", "Improved Overpower", 2),
    step("Arms", "Improved Tactical Mastery", 1),
    step("Arms", "Improved Tactical Mastery", 2),
    step("Arms", "Improved Tactical Mastery", 3),
    step("Arms", "Anger Management", 1),
    step("Arms", "Deep Wounds", 1),
    step("Arms", "Deep Wounds", 2),
    step("Arms", "Deep Wounds", 3),
    step("Arms", "Improved Heroic Strike", 3),
    step("Arms", "Spearing Strike", 1),
    step("Arms", "Two-Handed Weapon Specialization", 1),
    step("Arms", "Two-Handed Weapon Specialization", 2),
    step("Arms", "Two-Handed Weapon Specialization", 3),
    step("Arms", "Impale", 1),
    step("Arms", "Impale", 2),
    step("Arms", "Sweeping Strikes", 1),
    step("Arms", "Bloodthrill", 1),
    step("Arms", "Bloodthrill", 2),
    step("Arms", "Weaponmaster", 1),
    step("Arms", "Weaponmaster", 2),
    step("Arms", "Weaponmaster", 3),
    step("Arms", "Weaponmaster", 4),
    step("Arms", "Weaponmaster", 5),
    step("Arms", "Improved Slam", 1),
    step("Arms", "Improved Slam", 2),
    step("Arms", "Mortal Strike", 1),
    step("Fury", "Cruelty", 1),
    step("Fury", "Cruelty", 2),
    step("Fury", "Cruelty", 3),
    step("Fury", "Cruelty", 4),
    step("Fury", "Cruelty", 5),
    step("Fury", "Unbridled Wrath", 1),
    step("Fury", "Unbridled Wrath", 2),
    step("Fury", "Unbridled Wrath", 3),
    step("Fury", "Unbridled Wrath", 4),
    step("Fury", "Unbridled Wrath", 5),
    step("Fury", "Enrage", 1),
    step("Fury", "Enrage", 2),
    step("Fury", "Enrage", 3),
    step("Fury", "Enrage", 4),
    step("Fury", "Enrage", 5),
    step("Fury", "Reckless Swings", 1),
    step("Fury", "Improved Execute", 1),
    step("Protection", "Improved Bloodrage", 1),
    step("Protection", "Improved Bloodrage", 2),
}

FTG.Builds.WARRIOR = {
    arms_leveling = {
        key = "arms_leveling",
        name = "Leveling - Arms",
        shortName = "Arms Leveling",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/arms-warrior-leveling",
        sourceLastUpdated = "2026-11-03",
        reviewed = "2026-11-04",
        coverage = "Levels 10-60",
        maxLevelCovered = 60,
        split = "32/17/2 (leveling path)",
        steps = armsLeveling,
        note = "Icy Veins-confirmed key milestones. Inferred steps between confirmed levels are marked in the UI.",
    },
    arms_dps = {
        key = "arms_dps",
        name = "Level 60 DPS - Arms",
        shortName = "Arms DPS 60",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/arms-warrior-melee-dps-pve-spec-builds-talents",
        sourceLastUpdated = "2026-11-03",
        reviewed = "2026-11-04",
        coverage = "Level 60",
        requiredLevel = 60,
        split = "32/17/2",
        steps = armsDPS60,
        note = "Exact Icy Veins Mortal Strike two-handed PvE allocation. Ordered for a respec at 60.",
    },
    leveling = {
        key = "leveling",
        name = "Leveling - Fury",
        shortName = "Fury Leveling",
        source = "Icy Veins",
        sourceURL = "https://www.icy-veins.com/wow-forever/fury-warrior-leveling",
        sourceLastUpdated = "2026-11-03",
        reviewed = "2026-11-04",
        coverage = "Levels 10-60 (inferred points marked)",
        maxLevelCovered = 60,
        split = "20/31/0 (estimated leveling path)",
        steps = leveling,
        note = "Icy Veins-confirmed 10-40 and 50-52 milestones; unlisted ranks 23-24, 34, 41-49 and 53-60 are proposed fills, visibly flagged inferred.",
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
    dataVersion = 2,
    editorialSource = "Icy Veins",
    reviewed = "2026-11-04",
    updateCadence = "Tuesday",
}
