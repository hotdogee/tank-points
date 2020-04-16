-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
	Name: TankPoints esES locale
	Revision: $Revision: 105 $
Translated by: 
- shiftos
]]

local L = LibStub("AceLocale-3.0"):NewLocale("TankPoints", "esES")
if not L then return end

-- To translate AceLocale strings, replace true with the translation string
-- Before: ["Show Item ID"] = true
-- After:  ["Show Item ID"] = "顯示物品編號"

-- Global Strings that don't need translations
--[[
PLAYERSTAT_MELEE_COMBAT = "Melee"
SPELL_SCHOOL0_CAP = "Physical"
SPELL_SCHOOL0_NAME = "physical"
SPELL_SCHOOL1_CAP = "Holy"
SPELL_SCHOOL1_NAME = "holy"
SPELL_SCHOOL2_CAP = "Fire"
SPELL_SCHOOL2_NAME = "fire"
SPELL_SCHOOL3_CAP = "Nature"
SPELL_SCHOOL3_NAME = "nature"
SPELL_SCHOOL4_CAP = "Frost"
SPELL_SCHOOL4_NAME = "frost"
SPELL_SCHOOL5_CAP = "Shadow"
SPELL_SCHOOL5_NAME = "shadow"
SPELL_SCHOOL6_CAP = "Arcane"
SPELL_SCHOOL6_NAME = "arcane"
SPELL_STAT1_NAME = "Strength"
SPELL_STAT2_NAME = "Agility"
SPELL_STAT3_NAME = "Stamina"
SPELL_STAT4_NAME = "Intellect"
SPELL_STAT5_NAME = "Spirit"
COMBAT_RATING_NAME1 = "Weapon Skill"
COMBAT_RATING_NAME2 = "Defense Rating"
COMBAT_RATING_NAME3 = "Dodge Rating"
COMBAT_RATING_NAME4 = "Parry Rating"
COMBAT_RATING_NAME5 = "Block Rating"
COMBAT_RATING_NAME6 = "Hit Rating"
COMBAT_RATING_NAME7 = "Hit Rating" -- Ranged hit rating
COMBAT_RATING_NAME8 = "Hit Rating" -- Spell hit rating
COMBAT_RATING_NAME9 = "Crit Rating" -- Melee crit rating
COMBAT_RATING_NAME10 = "Crit Rating" -- Ranged crit rating
COMBAT_RATING_NAME11 = "Crit Rating" -- Spell Crit Rating
COMBAT_RATING_NAME15 = "Resilience"
ARMOR = "Armor"
DEFENSE = "Defense"
DODGE = "Dodge"
PARRY = "Parry"
BLOCK = "Block"
--]]

TP_STR = 1
TP_AGI = 2
TP_STA = 3
TP_HEALTH = 4
TP_ARMOR = 5
TP_DEFENSE = 6
TP_DODGE = 7
TP_PARRY = 8
TP_BLOCK = 9
TP_BLOCKVALUE = 10
TP_RESILIENCE = 11

-------------
-- General --
-------------
	L["TankPoints"] = "Puntos de Tanque"
	L["Block Value"] = "Valor de Bloqueo"

--------------------
-- Character Info --
--------------------
-- Stats
	L[" TP"] = " PdT" -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	L[" DR"] = " RaD" -- concatenated after a school name for Damage Reductions, ex: "Nature DR"

-- TankPoints Stat Tooltip
	L["In "] = "En "  -- concatenated before stance name, ex: "In Battle Stance"
	L["Mob Stats"] = "Estadísticas del Enemigo" 
	L["Mob Level"] = "Nivel del Enemigo" 
	L["Mob Damage"] = "Daño del Enemigo" 
	L["Mob Crit"] = "Crítico del Enemigo" 
	L["Mob Miss"] = "Fallo del Enemigo" 
	L["Per StatValue"] = "Por Valor de Estadística" 
	L["Per Stat"] = "Por Estadística" 
        -- ["Click: show Per StatValue TankPoints"] = "" 
        -- ["Click: show Per Stat TankPoints"] = "" 

-- Melee Reduction Tooltip
	L[" Damage Reduction"] = " (Reducción a Daño)"  -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	L["Player Level"] = "Nivel del Jugador" 
	L["Combat Table"] = "Tabla de Combate" 
	L["Crit"] = "Crítico" 
	L["Crushing"] = "Aplastamiento" 
	L["Hit"] = "Golpear" 

-- Block Value Tooltip
	L["Mob Damage before DR"] = "Daño del Enemigo antes de RaD" 
	L["Mob Damage after DR"] = "Daño del Enemigo después de RaD" 
	L["Blocked Percentage"] = "Porcentaje Bloqueado" 
	L["Equivalent Block Mitigation"] = "Mitigación de Bloqueo Equivalente" 
	L["Shield Block Up Time"] = "Tiempo de Bloqueo con Escudo" 

-- Spell TankPoints Tooltip
	L["Melee/Spell Damage Ratio"] = "Proporción de Daño Cuerpo a Cuerpo/Hechizo" 
	L["Left click: Show next school"] = "Clic Izquierdo: Mostrar escuela siguiente" 
	L["Right click: Show strongest school"] = "Clic Derecho: Mostrar escuela más fuerte" 


-- Spell Reduction Tooltip
-- Toggle Calculator
	L["Open Calculator"] = "Abrir Calculadora" 
	L["Close Calculator"] = "Cerrar Calculadora" 
	---------------------------
	-- Slash Command Options --
	---------------------------
-- /tp calc
	L["TankPoints Calculator"] = "Calculadora de Puntos de Tanque" 
	L["Shows the TankPoints Calculator"] = "Muestra la Calculadora de Puntos de Tanque" 
-- /tp tooltip
	L["Tooltip Options"] = "Opciones de Tooltip" 
	L["TankPoints tooltip options"] = "Opciones para el tooltip de Tankpoints" 
-- /tp tooltip diff
	L["Show TankPoints Difference"] = "Mostrar Diferencia en Tooltips" 
	L["Show TankPoints difference in item tooltips"] = "Muestra la diferencia de Puntos de Tanque en los tooltip de objeto" 
-- /tp tooltip total
	L["Show TankPoints Total"] = "Mostrar Total en Tooltip" 
	L["Show TankPoints total in item tooltips"] = "Muestra el total de Puntos de Tanque en los tooltip de objeto" 
-- /tp tooltip drdiff
-- /tp tooltip drtotal
-- /tp tooltip ehdiff
-- /tp tooltip ehtotal
-- /tp tooltip ehbdiff
-- /tp tooltip ehbtotal
-- /tp player
	L["Player Stats"] = "Estadísticas del Jugador" 
	L["Change default player stats"] = "Cambia las estadísticas del jugador por defecto" 
-- /tp player sbfreq
	--L["Shield Block Key Press Delay"] = "Frecuencia de pulsación de tecla de Bloqueo con Escudo" 
	--L["Sets the time in seconds after Shield Block finishes cooldown"] = "Establece el tiempo, en segundos, entre cada presión de tecla de Bloqueo con Escudo" 
-- /tp mob
	L["Mob Stats"] = "Estadísticas del Enemigo" 
	L["Change default mob stats"] = "Cambia las estadísticas del enemigo por defecto" 
-- /tp mob level
	L["Mob Level"] = "Nivel del Enemigo" 
	L["Sets the level difference between the mob and you"] = "Establece la diferencia de nivel entre el enemigo y tu" 
-- /tp mob damage
-- /tp mob drdamage
	L["Mob Damage"] = "Daño del Enemigo" 

	L["Sets mob's damage before damage reduction"] = "Establece el daño del enemigo antes de la reducción del daño" 
-- /tp mob speed
	L["Mob Attack Speed"] = "Vel. Ataque Enemigo" 
	L["Sets mob's attack speed"] = "Establece la velocidad de ataque del enemigo" 
-- /tp mob default
	L["Restore Default"] = "Reestablecer valores por defecto" 
	L["Restores default mob stats"] = "Reestablece las estadísticas por defecto del enemigo" 
	L["Restored Mob Stats Defaults"] = "Los valores por defecto para las estadísticas del enemigo han sido reestablecidos"  -- command feedback
-- /tp mob advanced
	L["Mob Stats Advanced Settings"] = "Ajustes Avanzados de Estadísticas del Enemigo" 
	L["Change advanced mob stats"] = "Cambia las estadísticas avanzadas del enemigo" 
-- /tp mob advanced crit
	L["Mob Melee Crit"] = "Crítico Cuerpo a Cuerpo del Enemigo" 
	L["Sets mob's melee crit chance"] = "Establece las posibilidades de conseguir un crítico cuerpo a cuerpo del enemigo" 
-- /tp mob advanced critbonus
	L["Mob Melee Crit Bonus"] = "Bonificación a Crítico Cuerpo a Cuerpo del Enemigo" 
	L["Sets mob's melee crit bonus"] = "Establece la bonificación a crítico cuerpo a cuerpo del enemigo" 
-- /tp mob advanced miss
	L["Mob Melee Miss"] = "Fallo Cuerpo a Cuerpo del Enemigo" 
	L["Sets mob's melee miss chance"] = "Establece las posibilidades de fallo cuerpo a cuerpo del enemigo" 
-- /tp mob advanced spellcrit
	L["Mob Spell Crit"] = "Crítico con Hechizos del Enemigo" 
	L["Sets mob's spell crit chance"] = "Establece la posibilidad de conseguir un crítico con hechizos del enemigo" 
-- /tp mob advanced spellcritbonus
	L["Mob Spell Crit Bonus"] = "Bonificación a Crítico con Hechizos del Enemigo" 
	L["Sets mob's spell crit bonus"] = "Establece la bonificación a crítico con hechizos del enemigo" 
-- /tp mob advanced spellmiss
	L["Mob Spell Miss"] = "Fallo con Hechizos del Enemigo" 
	L["Sets mob's spell miss chance"] = "Establece las posibilidades de fallo con hechizos del enemigo" 

----------------------
-- GetDodgePerAgi() --
----------------------
	L["Cat Form"] = "Forma de gato" 

---------------------------
-- GetTalantBuffEffect() --
---------------------------
	L["Soul Link"] = "Enlace de alma" 
	L["Voidwalker"] = "Abisario" 
	L["Righteous Fury"] = "Furia justa" 
	L["Pain Suppression"] = "Supresión de dolor" 
	L["Shield Wall"] = "Muro de escudo" 
	L["Death Wish"] = "Deseo de la Muerte" 
	L["Recklessness"] = "Temeridad" 
	L["Cloak of Shadows"] = "Capa de las Sombras" 

----------------------
-- AlterSourceData() --
----------------------
	L["Bear Form"] = "Forma de oso" 
	L["Dire Bear Form"] = "Forma de oso temible" 
	L["Moonkin Form"] = "Forma de lechúcico lunar" 

-----------------------
-- PlayerHasShield() --
-----------------------
	L["Shields"] = "Escudos" 

---------------------
-- GetBlockValue() --
---------------------
	L["^(%d+) Block$"] = "^(%d+) bloqueo$" 

------------------------
-- Item Scan Patterns --
------------------------
	L["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Aumenta el valor de bloqueo de tu escudo en (%d+)"},
			{"%+(%d+) valor de bloqueo"},        -- check  - índice /valor
		}
	}

---------------------------
-- TankPoints Calculator --
---------------------------
-- Title
	L["TankPoints Calculator"] = "Calculadora de Puntos de Tanque" 
	L["Left click to drag\nRight click to reset position"] = "Clic Izquierdo para arrastrar\nClic Derecho para reestablecer la posición" 

-- Buttons
	L["Reset"] = "Reestablecer" 
	L["Close"] = "Cerrar" 

-- Option frame box title
	L["Results"] = "Resultados" 
	L["Player Stats"] = "Estadísticas del Jugador" 
	L["Total Reduction"] = "Reducción Total" 
	L["(%)"] = "(%)" 
	L["Max Health"] = "Salud Máxima" 
	L["Items"] = "Objetos" 

-------------------------
-- TankPoints Tooltips --
-------------------------
	L[" (Top/Bottom):"] = " (Arriba/Abajo):" 
	L[" (Main/Off):"] = " (Derecha/Izquierda):" 
	L[" (Main+Off):"] = " (Derecha+Izquierda):" 
	L["Gems"] = "Gemas" 

---------------
-- Waterfall --
---------------

-------------------------
-- Calculator tooltips --
-------------------------
