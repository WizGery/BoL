--[[
	StonedSeries
	by WizGery
]]--

local version = 1
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/WizGery/BoL/master/StonedSeries.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local lastRG = 0
local lastICFJ = 0
local lastIDCF = 0
local lastICF = 0
local Target = nil
local UdyrLoaded, WWLoaded = false

function _AutoupdaterMsg(msg) print("<font color=\"#1C942A\">Stoned</font><font color =\"#DBD142\">Series</font> <font color=\"#FFFFFF\">"..msg..".</font>") end

require "AllClass"

if myHero.charName == "Udyr" then UdyrLoaded = true
elseif myHero.charName == "Warwick" then WWLoaded = true
else return end

function OnLoad()
	if not loaded then
		loaded = true
		Menu()
		if UdyrLoaded then
			PrintChat("Welcome to StonedSeries Udyr. GL & HF!")
		elseif WWLoaded then
			PrintChat("Welcome to StonedSeries Warwick. GL & HF!")
		end
		
		AddApplyBuffCallback(Buff_Add)
		AddRemoveBuffCallback(Buff_Rem)
		ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 800)

		if _G.Reborn_Initialised then
			orbwalkCheck()
		elseif _G.Reborn_Loaded then
			DelayAction(OnLoad, 1)
			return
		else
			orbwalkCheck()
		end
  end
end

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/WizGery/BoL/master/Version/StonedBundle.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				_AutoupdaterMsg("New version available "..ServerVersion)
				_AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () _AutoupdaterMsg("Successfully updated. ("..version.." >= "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				_AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		_AutoupdaterMsg("Error downloading version info")
	end
end

function orbwalkCheck()
	if _G.AutoCarry then
		PrintChat("SA:C detected, support enabled.")
		SACLoaded = true
	elseif _G.MMA_Loaded then
		PrintChat("MMA detected, support enabled.")
		MMALoaded = true
	else
		PrintChat("SA:C/MMA not running, loading SxOrbWalk.")
		require("SxOrbWalk")
		SxMenu = scriptConfig("SxOrbWalk", "SxOrb")
		SxOrb:LoadToMenu(SxMenu)
		SACLoaded = false
	end
end

function GetTarget()
	ts:update()
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	return ts.target
end

function getHealthPercent(unit)
    local obj = unit or myHero
    return (obj.health / obj.maxHealth) * 100
end

function getManaPercent(unit)
    local obj = unit or myHero
    return (obj.mana / obj.maxMana) * 100
end

function AutoPotion()
if os.clock() - lastRG < 15 then return end
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == "RegenerationPotion"  then
			if myHero:CanUseSpell(SLOT) == READY and getHealthPercent() <= Config.PotionsSettings.lifeRG then
				CastSpell(SLOT)	
				lastRG = os.clock()				
			end
		end
	end

if os.clock() - lastICF < 12 then return end
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == "ItemCrystalFlask"  then
			if myHero:CanUseSpell(SLOT) == READY and getHealthPercent() <= Config.PotionsSettings.lifeICF then
				CastSpell(SLOT)	
				lastICF = os.clock()				
			end
		end
	end
if os.clock() - lastICFJ < 8 then return end
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle"  then
			if myHero:CanUseSpell(SLOT) == READY and getHealthPercent() <= Config.PotionsSettings.lifeICFJ then
				CastSpell(SLOT)	
				lastICFJ = os.clock()				
			end
		end
	end
if os.clock() - lastIDCF < 12 then return end
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask"  then
			if myHero:CanUseSpell(SLOT) == READY and getHealthPercent() <= Config.PotionsSettings.lifeIDCF then
				CastSpell(SLOT)	
				lastIDCF = os.clock()				
			end
		end
	end
end

function Menu()
	if UdyrLoaded then
		Config = scriptConfig("StonedUdyr", "stonedudyr")
		
		Config:addSubMenu("[Key Binding]", "KeySettings")
			Config.KeySettings:addParam("Combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("32"))
			Config.KeySettings:addParam("Harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("C"))
			Config.KeySettings:addParam("Clear", "Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("V"))
			Config.KeySettings:addParam("LastHit", "LastHit Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("X"))
		
		Config:addSubMenu("[Combo]", "ComboSettings")
			Config.ComboSettings:addParam("StyleCombo", "Style Combo", SCRIPT_PARAM_LIST, 1, {"Tiger", "Phoenix"})
			Config.ComboSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.ComboSettings:addParam("manaW", "% mana min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.ComboSettings:addParam("lifeW", "% life min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.ComboSettings:addParam("manaE", "% mana min for use E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.ComboSettings:addParam("manaR", "% mana min for use R", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
	
		Config:addSubMenu("[Harass]", "HarassSettings")
			Config.HarassSettings:addParam("UseQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSettings:addParam("UseW", "Use W in Harass", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSettings:addParam("UseE", "Use E in Harass", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSettings:addParam("UseR", "Use R in Harass", SCRIPT_PARAM_ONOFF, true)
	
		Config:addSubMenu("[Laneclear]", "LaneclearSettings")
			Config.LaneclearSettings:addParam("UseQ", "Use Q in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.LaneclearSettings:addParam("UseW", "Use W in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaW", "% mana min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.LaneclearSettings:addParam("UseE", "Use E in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaE", "% mana min for use E", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.LaneclearSettings:addParam("UseR", "Use R in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaR", "% mana min for use R", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		
		Config:addSubMenu("[Jungleclear]", "JungleclearSettings")
			Config.JungleclearSettings:addParam("StyleJC", "Style Jungleclear", SCRIPT_PARAM_LIST, 1, {"Tiger", "Phoenix"})
			Config.JungleclearSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.JungleclearSettings:addParam("manaW", "% mana min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.JungleclearSettings:addParam("manaR", "% mana min for use R", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		
		Config:addSubMenu("[Auto]", "AutoSettings")
			Config.AutoSettings:addParam("upgradeTB", "Buy Trinket Blue", SCRIPT_PARAM_ONOFF, true)
			Config.AutoSettings:addParam("autolevel","Auto level", SCRIPT_PARAM_ONOFF, false)
			Config.AutoSettings:addParam("levels","Select style", SCRIPT_PARAM_LIST, 1, {"Tiger","Phoenix"})
				
		Config:addSubMenu("[Auto Potions]", "PotionsSettings")
			Config.PotionsSettings:addParam("useRG", "Auto use Regeneration Potions", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeRG", "% life min for RG", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useICFJ", "Auto use Crystal Flask Junle", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeICFJ", "% life min for CFJ", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useIDCF", "Auto use Dark Crystal Flask", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeIDCF", "% life min for DCF", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useICF", "Auto use Crystal Flask", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeICF", "% life min for CF", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			
	elseif WWLoaded then
		Config = scriptConfig("StonedWarwick", "stonedww")
		
		Config:addSubMenu("[Key Binding]", "KeySettings")
			Config.KeySettings:addParam("Combo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("32"))
			Config.KeySettings:addParam("Harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("C"))
			Config.KeySettings:addParam("Clear", "Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("V"))
			Config.KeySettings:addParam("LastHit", "LastHit Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte ("X"))
		
		
		Config:addSubMenu("[Combo]", "ComboSettings")
			Config.ComboSettings:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSettings:addParam("useW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSettings:addParam("rangeW", "Use W if enemy in range", SCRIPT_PARAM_SLICE, 400, 50, 800, 0)
			Config.ComboSettings:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
			Config.ComboSettings:addParam("modeR", "R usage", SCRIPT_PARAM_LIST, 1, {"Always", "Killable", "Smart"}) 
	
		Config:addSubMenu("[Harass]", "HarassSettings")
			Config.HarassSettings:addParam("UseQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
			Config.HarassSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
				
		Config:addSubMenu("[Laneclear]", "LaneclearSettings")
			Config.LaneclearSettings:addParam("UseQ", "Use Q in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.LaneclearSettings:addParam("UseW", "Use W in Laneclear", SCRIPT_PARAM_ONOFF, true)
			Config.LaneclearSettings:addParam("manaW", "% mana min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		
		Config:addSubMenu("[Jungleclear]", "JungleclearSettings")
			Config.JungleclearSettings:addParam("UseQ", "Use Q in jungleclear", SCRIPT_PARAM_ONOFF, true)
			Config.JungleclearSettings:addParam("manaQ", "% mana min for use Q", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.JungleclearSettings:addParam("UseW", "Use W in jungleclear", SCRIPT_PARAM_ONOFF, true)
			Config.JungleclearSettings:addParam("manaW", "% mana min for use W", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
		
		Config:addSubMenu("[Killsteal]", "KS")
			Config.KS:addParam("ksQ", "Use Q to KS", SCRIPT_PARAM_ONOFF, true)
			Config.KS:addParam("ksR", "Use R to KS", SCRIPT_PARAM_ONOFF, true)
		
		Config:addSubMenu("[Draws]", "DrawsSettings")
			Config.DrawsSettings:addParam("DDraw", "Disable All Draws", SCRIPT_PARAM_ONOFF, false)
			Config.DrawsSettings:addParam("DrawQ", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
			Config.DrawsSettings:addParam("DrawR", "Draw R range", SCRIPT_PARAM_ONOFF, true)
			Config.DrawsSettings:addParam("DrawAA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
			Config.DrawsSettings:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
	
		Config:addSubMenu("[Auto]", "AutoSettings")
			Config.AutoSettings:addParam("upgradeTB", "Buy Trinket Blue", SCRIPT_PARAM_ONOFF, true)
			Config.AutoSettings:addParam("autolevel","Auto level", SCRIPT_PARAM_ONOFF, false)
		
		Config:addSubMenu("[Auto Potions]", "PotionsSettings")
			Config.PotionsSettings:addParam("useRG", "Auto use Regeneration Potions", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeRG", "% life min for RG", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useICFJ", "Auto use Crystal Flask Junle", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeICFJ", "% life min for CFJ", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useIDCF", "Auto use Dark Crystal Flask", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeIDCF", "% life min for DCF", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
			Config.PotionsSettings:addParam("useICF", "Auto use Crystal Flask", SCRIPT_PARAM_ONOFF, true)
			Config.PotionsSettings:addParam("lifeICF", "% life min for CF", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	end
end

function OnDraw()
	if myHero.dead then return end
		if UdyrLoaded then
			DrawCircle(myHero.x, myHero.y, myHero.z, 190, ARGB(255, 255, 0, 0))
			if Target ~= nil then 
				DrawHitBox(Target)
			end
		elseif WWLoaded then
			if not Config.DrawsSettings.DDraw then
			if Config.DrawsSettings.DrawQ and QREADY then
				DrawCircle(myHero.x, myHero.y, myHero.z, 400, ARGB(255, 255, 0, 0))
			end
			if Config.DrawsSettings.DrawR and RREADY then
				DrawCircle(myHero.x, myHero.y, myHero.z, 700, ARGB(255, 255, 0, 0))
			end
			if Config.DrawsSettings.DrawAA then
				DrawCircle(myHero.x, myHero.y, myHero.z, 190, ARGB(255, 255, 0, 0))
			end
			if Target ~= nil then 
				DrawHitBox(Target)
			end
		end
	end
end

function readyCheck()
	QREADY, WREADY, EREADY, RREADY = (myHero:CanUseSpell(_Q) == READY), (myHero:CanUseSpell(_W) == READY), (myHero:CanUseSpell(_E) == READY), (myHero:CanUseSpell(_R) == READY)
end

function OnTick()
	readyCheck()
	Target = GetTarget()
	if Config.KeySettings.Combo then Combo() end
	if Config.KeySettings.Clear then Laneclear() end
	if Config.KeySettings.Clear then Jungleclear() end
	if Config.KeySettings.Harass then Harass() end
	AutoPotion() 
	StunCheck()
	KillSteal()
	if VIP_USER and Config.AutoSettings.autolevel then
		if UdyrLoaded then
			local levelSequenceT = {nil,2,3,1,1,2,1,2,1,2,3,2,3,3,3,4,4,4}
			local levelSequenceP = {nil,2,3,4,4,2,4,2,4,2,3,2,3,3,3,1,1,1}
			if Config.AutoSettings.levels == 1 then
				autoLevelSetSequence(levelSequenceT)
			else
