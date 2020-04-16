# TankPoints 2.0 - A benchmark for survivability gear.

🔥 CurseForge: https://www.curseforge.com/wow/addons/tank-points

🔥 WoWInterface: https://www.wowinterface.com/downloads/info6419-TankPoints.html

## The physical meaning of a TankPoint

TankPoints is designed as a dynamic points system, optimized on the fly using well known game dynamics, unlike most other wow item benchmarks, there is a physical meaning of a TankPoint.

TankPoints values are not static and is custom for your current gear and stat. TankPoints may state that 1 Stamina is worth more points then 1 Defense Rating for one player, but for another player that has a too much Stamina it will tell you that 1 Defense Rating is worth more then 1 Stamina.

TankPoints is directly proportional to how long a given opponent takes to kill you, also known as survivability or time to live (TTL) in some articles.

The more TankPoints you have means how much longer you can stay alive without getting heals. To the healer this is directly related to how easy it is to heal you, double the TankPoints means double the time you give the healers between heals.

Some people think that having high TankPoints doesn't necessarily help healers save mana, only high damage reduction will help save healers mana. But thats not true, having high TankPoints can help healers regen mana, because the more time your healers have between heals the more mana they can regen.

## About TankPoints

TankPoints was created to help compare different pieces of tanking gear, because it was difficult to decided at a glance like whether +12 defense is better then +1 dodge.

TankPoints can be seen as how much raw damage you can take before damage reduction, it considers your max health, armor, defense, dodge, parry, block, block value, resilience, crushing blow chance, miss, crit reduction, talents, buffs, stance/forms, and more.

Keep in mind though, that higher TankPoints does not make a better tank, it is only a benchmark for survivability gear but does not calculate threat.

It can not decide for you what you should wear for what boss, but it can provide you with a wealth of information what will hopefully be useful for choosing gear.


## About TankPoints 2.0

TankPoints 2.0 is a complete rewrite of my original TankPoints for WoW 2.0+ using the Ace2 framework.

It calculates how many points each stat is worth according to your current gear setup, it does so to help you obtain the best balance between all "defensive stats".

It has a much improved TankPoints algorithm, integrates nicely into the character stats dropdown menu, and shows a lot more information then the original TankPoints.

2.0 introduced a new combat ratings system which made it even harder to compare gear, in order to code combat rating support for TankPoints, the exact rating to percentage formula is required which Blizzard didn't give us.

Luckily, I have successfully reverse engineered the rating formula for all levels and coded an addon called "Rating Buster" that converts ratings on item tooltips into percentages, you can try it out here.

Rating Buster: 
* http://wow.curse-gaming.com/en/files/details/4991/rating-buster/
* http://www.wowinterface.com/downloads/fileinfo.php?s=&id=5819


## The value of Block

The value is Shield Block Value and Block Rating is highly dependent on what you are tanking.

Its very good for mobs that don't hit very hard like in heroics, but is worth much less on hard hitting bosses in 25 man raids.

At level 80, TankPoints' default mob damage is tuned to 25 man raids, with a value of 24365 damage before mitigation.

You can change this value to match what you plan on tanking by using the `/tp mob damage` command in game.

A mob damage of 10505 for example is a good value for level 80 heroics.

TankPoints also calculates the value of Shield Block for Warriors, and Holy Shield for Paladins.

You can use the `/tp player sbfreq` command to set a shield block frequency that matches your rotation (in how many seconds AFTER cooldown finishes).

For most tankadins rotations, you will have a 100% Holy Shield uptime, using `/tp player sbfreq 1` will tell TankPoints that you will use Holy Shield 1 second after cooldown finishes (every 9 secs).


# Features

In addition to the original formula, the Improved TankPoints 2.0 formula now has:
- support for all combat ratings including the new resilience stat
- support for block% and block value
- support for various class specific talents and buffs
- support for crushing blows
- support for combat table and correctly caps off at a total of 100%
  using Hit < Crushing < Crit < Block < Parry < Dodge < Miss
- support for mob stats:
  - mob level - defaults player level +3
  - mob damage
  - mob melee crit chance
  - mob melee crit bonus
  - mob melee miss chance
  - mob spell crit chance
  - mob spell crit bonus
  - mob spell miss chance

Improved TankPoints Calculator

TankPoints User Interface(See Screenshots):
- Integrated in to the Character stats dropdown menu
- When TankPoints is selected it displays:
  - TankPoints
  - Melee Damage Reduction
  - Block Value
  - Spell TankPoints
  - Spell Damage Reduction
- TankPoints tooltip:
  - Your stance
  - Mob Stats
    - Mob Level
    - Mob Damage (after damage reduction)
    - Mob Crit Chance
    - Mob Miss Chance
  - TankPoints per StatValue - Shows how much TankPoints you gain for each stats with equal item values, because the values below are equal in the item value formula, you can use this data to see what gives the most bang for the buck in terms of item budgets.
    - 1 Agility = 
    - 1.5 Stamina = 
    - 10 Armor = 
    - 1 Resilience = 
    - 1 Defense Rating = 
    - 1 Dodge Rating = 
    - 1 Parry Rating = 
    - 1 Block Rating = 
    - 1.54 Block Value
  - Option to hold down ALT key will show how much TankPoints you gain for each stat point
    - 1 Agility
    - 1 Stamina
    - 1 Armor
    - 1 Resilience
    - 1% Defense
    - 1% Dodge
    - 1% Parry
    - 1% Block
    - 1 Block Value
- Melee Damage Reduction tooltip:
  - Armor Damage Reduction against mob level - Useful because the default armor tooltip only shows the reduction for the same level
  - Mob Level, Player Level
  - Combat Table - Hit < Crushing < Crit < Block < Parry < Dodge < Miss
    The total of these chances must be capped at 100%, if you exceed 100% then lower priority values will be pushed off the table. 
    For example, when you press shield block (+75% block chance), hit, crush and crit will all be pushed off and will be 0, your real block chance will also be capped at (100% - Parry% - Dodge% - Miss%)
- Block Value tooltip - Block Value should have been included in the default UI, but they didn't so I coded my own function that does it, strength, items, talents(warrior, paladin, shaman) are all considered in the algorithm.
  - Mob Damage before Damage Reduction (armor and stance effects)
  - Mob Damage after Damage Reduction
  - Blocked percentage = Block Value / Mob Damage after DR
  - Block Chance
  - Equivalent Block Mitigation = Block Chance * Blocked percentage
    This can be seen equal with the same amount of dodge or parry.
- Spell TankPoints Tooltip - Shows your strongest school by default
  - Your stance
  - TankPoints at the following Melee/Spell Damage Ratio
    - 25% Melee Damage + 75% school damage
    - 50% Melee Damage + 50% school damage
    - 75% Melee Damage + 25% school damage
  - Can manually cycle through all schools by left clicking the stat
  - Reset back to showing the strongest school by right click the stat
- Spell Damage Reduction - Shows your strongest school by default
  - Shows damage reductions for all schools
  - Same click functions as the Spell TankPoints Tooltip


- Warrior: Improved Defensive Stance, Shield Mastery, Shield Wall - Buff, Death Wish - Buff, Recklessness - Buff, Toughness, Vitality
- Druid: Survival of the Fittest, Natural Perfection, Thick Hide, Balance of Power, Heart of the Wild
- Paladin: Shield Specialization, Divine Purpose, Blessed Life, Ardent Defender, Spell Warding, Improved Righteous Fury, Divine Strength, Toughness
- Shaman: Shield Specialization, Elemental Shields, Elemental Warding, Toughness
- Rogue: Sleight of Hand, Heightened Senses, Deadened Nerves, Vitality, Sinister Calling, Cloak of Shadows - Buff
- Hunter: Survival Instincts, Thick Hide, Combat Experience, Lightning Reflexes
- Priest: Shadow Resilience, Spell Warding, Pain Suppression - Buff, Enlightenment
- Hunter: Survivalist, Endurance Training
- Warlock: Demonic Resilience, Master Demonologist, Soul Link - Buff, Demonic Embrace, Fel Stamina
- Mage: Arctic Winds, Prismatic Cloak, Playing with Fire, Frozen Core


# Slash Commands

Use: `/tp` or `/tankpoints`

* `/tp` - Show help
* `/tp optionswin` - Opens the options window
* `/tp calc` - Toggle calculator
* `/tp mob` - Show mob stats help 
* `/tp mob level (-20 - +20)` - Sets the level difference between the mob and you
* `/tp mob damage (0 - 99999)` - Sets mob's damage before damage reduction
* `/tp mob default` - Restores default mob stats
* `/tp mob advanced` - Show advanced mob stats help
* `/tp mob advanced crit (0 - 100)` - Sets mob's melee crit chance
* `/tp mob advanced critbonus` - Sets mob's melee crit bonus
* `/tp mob advanced miss (0 - 100)` - Sets mob's melee miss chance
* `/tp mob advanced spellcrit (0 - 100)` - Sets mob's spell crit chance
* `/tp mob advanced spellcritbonus` - Sets mob's spell crit bonus
* `/tp mob advanced spellmiss (0 - 100)` - Sets mob's spell miss chance
* `/tp player sbfreq (0 - 1000)` - Sets the Shield Block press delay in seconds after Shield Block finishes cooldown


# TankPoints Formulas

## Armor Reduction
```
levelModifier = attackerLevel
if ( levelModifier > 59 ) then
  levelModifier = levelModifier + (4.5 * (levelModifier - 59))
end
armorReductionTemp = armor / ((85 * levelModifier) + 400)
armorReduction = armorReductionTemp / (armorReductionTemp + 1)
if armorReduction > 0.75 then
  armorReduction = 0.75
end
if armorReduction < 0 then
  armorReduction = 0
end
```
## Defense Effect
```
defenseEffect = (defense - attackerLevel * 5) * 0.04 * 0.01
```
## Block Value From Strength
```
blockValueFromStrength = floor(totalStr * 0.5 - 10)
```

## Block Value
```
blockValue = floor((floor(totalStr * 0.5 - 10) + blockValueFromItems + blockValueFromShield) * blockValueMod)
```

## Mob Damage (default formula)
```
mobDamage = (levelModifier * 55) * meleeTakenMod * (1 - armorReduction)
```

## Resilience Effect
```
resilienceEffect = ReverseRating(resilience, playerLevel) * 0.01
```

## Mob Crit Chance
```
mobCritChance = max(0, 0.05 - defenseEffect - resilienceEffect)
```

## Mob Crit Bonus
```
mobCritBonus = 1
```

## Mob Miss Chance
```
mobMissChance = max(0, 0.05 + defenseEffect)
```

## Mob Crush Chance (if mobLevel is +4 or more)
```
mobCrushChance = (mobLevel - playerLevel) * 0.1 - 0.15
```

## Mob Crit Damage Mod
```
mobCritDamageMod = max(0, 1 - resilienceEffect * 2)
```

## Blocked Mod
```
blockedMod = min(1, blockValue / mobDamage)
```

## Mob Spell Crit Chance
```
mobSpellCritChance = max(0, 0 - resilienceEffect)
```

## Mob Spell Crit Bonus
```
mobSpellCritBonus = 0.5
```

## Mob Spell Miss Chance
```
mobSpellMissChance = 0
```

## Mob Spell Crit Damage Mod
```
mobSpellCritDamageMod = max(0, 1 - resilienceEffect * 2)
```

## Resistance Reduction
```
schoolReduction[SCHOOL] = 0.75 * (resistance[SCHOOL] / (mobLevel * 5))
```

## Melee Total Reduction
```
totalReduction[MELEE]
 = 1 - (1 - Avoidance) * (1 - Mitigation) * DamageTakenMod
 = 1 - (1 - blockChance * blockedMod - parryChance - dodgeChance - mobMissChance + (mobCritChance * mobCritBonus * mobCritDamageMod) + (mobCrushChance * 0.5)) * (1 - armorReduction) * meleeTakenMod
```

## Spell Total Reduction
```
totalReduction[SCHOOL] = 1 - ((mobSpellCritChance * (1 + mobSpellCritBonus) * mobSpellCritDamageMod) + (1 - mobSpellCritChance - mobSpellMissChance)) * (1 - schoolReduction[SCHOOL]) * spellTakenMod
```

## TankPoints
```
tankPoints = playerHealth / (1 - totalReduction)
```

## EffectiveHealth (EH)
```
effectiveHealth[MELEE] = playerHealth * 1 / (1 - (1 - armorReduction) * damageTakenMod)
```
```
effectiveHealth[SCHOOL] = playerHealth * 1 / (1 - damageTakenMod)
```
In other words: how much health you have times how much that health translates into raw damage when you're hit

## EffectiveHealthWithBlock (EHB)
```
For every swing of the mob (see mobAtkSpeed) until you are out of health
    if time to press the shield block button given timeBetweenPresses
       refresh charges on shield block
    if mobHitChance + mobCrushChance + mobCritChance == 0 or
      (charges left and mobHitChance + mobCrushChance + mobCritChance <= 75%)
       use a charge on shield block
       min(healthLeft, take raw damage from the monster per mobDamage - blockValue)
    else
       min(healthLeft, take raw damage from the monster per mobDamage)
    end
end
```

EHB is the sum of the raw damage before death.

The algorithm does not take chance into account - just the variables
you feed it in terms of the mobDamage, mobAtkSpeed, and
timeBetweenPresses.

Paladins are not calculated yet.


# Version History
2.8.6
- toc update for 3.3.0

2.8.5
- Paladin: Ardent Defender is now modeled as an increase of 0.35/(1-[7/13/20%])-0.35 in max health
- 3.2.2: Paladin: Ardent Defender: This talent now reduces damage taken below 35% health by 7/13/20% instead of 10/20/30%.
- 3.2.2: Warrior: Critical Block: This talent now grants a 20/40/60% chance to block double the normal amount instead of 10/20/30%.
- 3.2.2: Death Knight: Unbreakable Armor: Now grants 25% additional armor. The amount of strength granted has been reduced to 10%.
- 3.2.2: Death Knight: Glyph of Unbreakable Armor: Now increases the armor gained from Unbreakable Armor by 20%.
- 3.2.2: Death Knight: Frost Presence: The damage reduction granted by this ability has been increased from 5% to 8%.

2.8.4
- toc update
- Packaged with new libraries with 3.2.0 class support
- Block Value is now 2/0.65 per statpoint
- Paladin: Fixed Holy Shield talent location
- Default mob damage at level 83 is now 44165, up from 24365 to match current raid difficulty.
- Fixed TankPoints per Defense Rating calculation
- Fixed Effective Health with Block

2.8.3
- toc update
- Packaged with new libraries with 3.1.3 class support

2.8.2
- NEW: Avoidance diminishing returns calculations in Melee DR tooltip will show you how much avoidance you gain for +16 of each stat.
- Diminishing returns for chance to be missed now supported.
- Paladin: Combat table will now reflect the effects of Holy Shield if you set it at 100% uptime. To set 100% Holy Shield uptime, use a sqfreq lower then or equal to 2 secs, ex: /tp player sbfreq 2
- Fixed Block Value formula
- Can set shield block frequency from 0 secs to 1000 secs, set it to 1000 if you don't want TankPoints to calculate the shield block effect
- Defense isn't affected by DR (Defense Rating is)
- Fixed StatFrame data not updated correctly during stance/presence/form/aura change
- Uses LibStatLogic-1.1 and LibTipHooker-1.1 now
- Made the Calculator movable by dragging the sides
- Support for enchant statmods:
- Enchant: Rune of the Stoneskin Gargoyle: +2% Stamina
- Enchant: Rune of Spellshattering: Deflects 4% of all spell damage
- Enchant: Rune of Spellbreaking: Deflects 2% of all spell damage
- Support for meta gem statmods:
- Austere Earthsiege Diamond: 2% Increased Armor Value from Items
- MetaGem: Eternal Earthsiege Diamond:+5% Shield Block Value
- MetaGem: Eternal Earthstorm Diamond: +5% Shield Block Value
- MetaGem: Effulgent Skyflare Diamond: Reduce Spell Damage Taken by 2%
- Fixed Warrior talent detection: Vitality, Strength of Arms, Improved Defensive Stance
- Death Knight: Added Stance: Frost Presence detection fixed
- Death Knight: Added Buff: Bone Shield: Damage reduced by 40%.
- 3.0.8: Death Knight: Updated Stance: Frost Presence: The bonus armor has been increased from 60 to 80% and magic damage reduction increased from 5 to 15%.
- 3.0.8: Death Knight: Updated Buff: Bone Shield: Damage reduced by 20%.
- 3.0.8: Death Knight: Updated Buff: Will of the Necropolis: Reduce the damage of any attack that takes the DK below 35% health by 5%/10%/15% instead of boosting armor when wounded.
- 3.0.8: Druid: Updated Talent: Survival of the Fittest: This talent now grants 22/44/66% bonus armor in Bear Form and Dire Bear Form in addition to all of its previous effects. 
- 3.0.8: Shaman: Updated Talent: Elemental Warding: Now reduces all damage taken by 2/4/6%.
- Removed Endurance (Tauren racial)

2.8.1
- Support for Warrior talent: Critical Block
- Fixed Shield Block and Holy Shield calculations
- Default mob damage at level 83 is now 24365 instead of 10505
- Fixed a bug causing "ADD_CRIT_TAKEN" from talents to be capped at MobCritChance
- Paladin: Added Talent: Redoubt - Increases your block value by 10%/20%/30%
- Death Knight BaseDodge changed from 0.758% to 3.4636%.

2.8.0
- Avoidance diminishing returns support: Calculator, ItemTooltip, TankPoints Per Stat, TankPoints Per StatValue
- Supports Death Knight: Forceful Deflection - Increases your Parry Rating by 25% of your total Strength
- Added Str to TankPoints Per Stat, TankPoints Per StatValue
- Fixed EffectiveHealth, EffectiveHealthWithBlock
- Fixed Warrior Shield Block calculations
- Support for Paladin Holy Shield
- Crushing blows only happen when mob is +4 levels
- 1 Strength now gives 0.5 Block Value
- Removed Babble-Spell-2.2, Deformat-2.0, Gratuity-2.0
- Fixed immediate errors in 3.0.2
- Calculator: Fixed error
- Code cleanup and stability tweaks
- toc 30000

2.7.0 by Aliset
- NEW: You can specify pre-mitigation mob damage using /tp mob drdamage
- NEW: Ciderhelm's EffectiveHealth and a derived stat, EffectiveHealthWithBlock
- Moved to StatFrameLib-1.0 for paperdoll stat frames
- Alt events didn't seem to be working, so moved to clicks for per-stat/per-rating change
- Consolidated some aspects of TankPoints calculation
- Pretty print many of the large numbers shown (so 789956 shows up as 789,956)

2.6.8
- NEW: You can now open the options window using /tp optionswin
- Fixed: Error in TankPoints.lua:1286 and TankPoints.lua:947
- Updated Korean localizations by fenlis

2.6.7
- Updated Taiwan localization by Whitetooth
- Improved stat scanning
- Updated German localization

2.6.6
- Updated French localization by Tixu, TankPoints Tooltips now works with the French client
- Fixed a bug causing TankPoints tooltips not showing correctly for languages other then English
- Fixed Parry/SpellHaste rating calculations
- Updated libs

2.6.5
- Pre updated the TOC to 2.1.0
- Support for Shield Block skill, with options to set mobs attack speed(default 2.0) and average time between Shield Block key presses(default 8 sec)
- Fixed error when changing options with the Calculator open

2.6.0
- Calculator: Fixed MobLevel calculations
- Better talent and Buff support
- Improved Block Value calculation
- Code for smooth transition to 2.1.0
- Updated Libs

2.5.7
- Fixed incorrect tooltip values
- Fixed calculater rounding errors

2.5.6
- Fixed library error

2.5.5
- Added StatLogic deDE localizations by Gailly

2.5.4
- Fixed incorrect armor calculations in tooltips for Druilds
- Added Taiwan localizations by CuteMiyu

2.5.3
- Updated Korean localization by fenlis

2.5.2
- Fixed another StatLogic bug

2.5.1
- Fixed StatLogic bug
- Druid Bear Form formulas updated to 2.0.10 fixes
- Updated French localizations by Tixu
- Added Korean localization by fenlis

2.5.0
- Item tooltips will now show TankPoints (only works for English client until localized)
- Removed Compost
- Removed ReverseRating.lua
- Code cleanup and optimizations

2.4.1
- Fixed Calculator Block Value from Strength calculations

2.4.0
- May now input Armor from items and Armor from non items in the Calculator
- Really fixed Night Elf and Feral Swiftness dodge calculations
- Improved accuracy of calculator stat calculations
- Improved calculator support for Druid Forms
- Calculator support for Druid talent - Heart of the Wild, Balance of Power, 
- Calculator support for Rogue talent - Cloak of Shadows
- Calculator support for Paladin talent - Toughness
- Calculator support for Hunter talent - Survivalist, Endurance Training
- Calculator support for Warlock talent - Fel Stamina
- Calculator support for health mods
- Support for Death Wish, Recklessness

2.3.5
- Fixed Druid, Hunter and Night Elf dodge calculation bug
- Fixed Druid talent - Survival of the Fittest not being counted bug
- Fixed Paladin talent - Ardent Defender being always on bug

2.3.3
- Fixed Druid Dire Bear Form armor calculations

2.3.2
- Added support for new pally talents: Spell Warding, Improved Righteous Fury
- Updated Libs

2.3.1
- TOC 20003
- Updated Libs

2.3
- Greatly improved the Calculator algorithms
- Calculator: better support for talents that give bonus strength, agility, stamina, armor
- Calculator: better handling for Defense Rating
- Improved TP per StatValue/Stat calculations in TankPoints tooltips

2.2.3
- Fixed low level resistance calculations
- Fixed Druid Bear Form armor bonus
- Plays nice with other mods that may add to the character dropdown list

2.2.2
- Fixed Tauren health error

2.2.1
- Added German localization by AbbedieD
- Improved support for Druid armor bonuses in various forms
- Removed (%) from Defense in Calculator
- Partially updated French localizations
- Updated libs

2.2
- The improved TankPoints Calculator is now in
- Changed Soul Link formula 30% -> 20%

2.1.1
- Fixed TP per defense rating in tooltip again
- Updated French localizations by Tixu

2.1
- Support for various class specific talents and buffs
- Fixed TP per defense rating in tooltip
- PlayerHasShield() localized
- GetBlockValue() localized
- Fixed a couple slash command's option range
- Partial French localizations by Tixu

2.0.1
- Fixed ReverseRating error
- Updated Libs
- Fixed a display bug in TankPoints tooltips 
- Fixed Block Value algorithm not working with some shields
- Set Block% to zero if you don't have a shield on

2.0
- Complete rewrite for the 2.0 client using Ace2
