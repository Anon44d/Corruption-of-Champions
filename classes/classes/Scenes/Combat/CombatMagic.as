/**
 * Coded by aimozg on 30.05.2017.
 */
package classes.Scenes.Combat {
import classes.GlobalFlags.kFLAGS;
import classes.GlobalFlags.kACHIEVEMENTS;
import classes.Items.HeadJewelryLib;
import classes.Items.JewelryLib;
import classes.Items.NecklaceLib;
import classes.Items.ShieldLib;
import classes.PerkLib;
import classes.MutationsLib;
import classes.Scenes.API.FnHelpers;
import classes.Scenes.Areas.GlacialRift.FrostGiant;
import classes.Scenes.Areas.Tundra.YoungFrostGiant;
import classes.Scenes.Dungeons.D3.Doppleganger;
import classes.Scenes.Dungeons.D3.JeanClaude;
import classes.Scenes.Dungeons.D3.Lethice;
import classes.Scenes.Dungeons.D3.LivingStatue;
import classes.Scenes.NPCs.Diva;
import classes.Scenes.NPCs.Holli;
import classes.Scenes.Places.TelAdre.UmasShop;
import classes.Scenes.Codex;
import classes.Scenes.SceneLib;
import classes.Stats.Buff;
import classes.EngineCore;
import classes.StatusEffects;
import classes.VaginaClass;

import coc.view.ButtonData;
import coc.view.ButtonDataList;

public class CombatMagic extends BaseCombatContent {
	public var codex:Codex = new Codex();
	public function CombatMagic() {}

	internal function applyAutocast():void {
		outputText("\n\n");
		if (player.hasPerk(PerkLib.Spellsword) && player.lust < getWhiteMagicLustCap() && player.mana >= (spellCostWhite(60) * spellChargeWeaponCostMultiplier()) && flags[kFLAGS.AUTO_CAST_CHARGE_WEAPON] == 0 && ((player.hasPerk(PerkLib.ImprovingNaturesBlueprintsNaturalWeapons) && player.weaponName == "fists") || player.weaponName != "fists")) {
			spellChargeWeapon(true);
			useMana((60 * spellChargeWeaponCostMultiplier()), 5);
			flags[kFLAGS.SPELLS_CAST]++;
			if (!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell, 0, 0, 0, 0);
			spellPerkUnlock();
			outputText("<b>Charge Weapon was autocasted successfully.</b>\n\n");
		}
		if (player.hasPerk(PerkLib.Spellarmor) && player.lust < getWhiteMagicLustCap() && player.mana >= (spellCostWhite(40) * spellChargeArmorCostMultiplier()) && flags[kFLAGS.AUTO_CAST_CHARGE_ARMOR] == 0 && ((player.hasPerk(PerkLib.ImprovingNaturesBlueprintsNaturalArmor) && player.haveNaturalArmor() && player.isNaked()) || !player.isNaked())) {
			spellChargeArmor(true);
			useMana((40 * spellChargeArmorCostMultiplier()), 5);
			flags[kFLAGS.SPELLS_CAST]++;
			if (!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell, 0, 0, 0, 0);
			spellPerkUnlock();
			outputText("<b>Charge Armor was autocasted successfully.</b>\n\n");
		}
		if (player.hasPerk(PerkLib.Battlemage) && ((player.hasPerk(PerkLib.GreyMage) && player.lust >= 30) || player.lust >= 50) && player.mana >= (spellCostBlack(50) * spellMightCostMultiplier()) && flags[kFLAGS.AUTO_CAST_MIGHT] == 0) {
			spellMight(true);
			useMana((50 * spellMightCostMultiplier()), 6);
			flags[kFLAGS.SPELLS_CAST]++;
			if (!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell, 0, 0, 0, 0);
			spellPerkUnlock();
			outputText("<b>Might was autocasted successfully.</b>\n\n");
		}
		if (player.hasPerk(PerkLib.Battleflash) && ((player.hasPerk(PerkLib.GreyMage) && player.lust >= 30) || player.lust >= 50) && player.mana >= (spellCostBlack(40) * spellBlinkCostMultiplier()) && flags[kFLAGS.AUTO_CAST_BLINK] == 0) {
			spellBlink(true);
			useMana((40 * spellBlinkCostMultiplier()), 6);
			flags[kFLAGS.SPELLS_CAST]++;
			if (!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell, 0, 0, 0, 0);
			spellPerkUnlock();
			outputText("<b>Blink was autocasted successfully.</b>\n\n");
		}
		if (player.hasPerk(PerkLib.Battleshield) && (player.lust >= 50 || player.lust < (player.maxLust() - 49)) && flags[kFLAGS.AUTO_CAST_MANA_SHIELD] == 0) {
			spellManaShield(true);
			flags[kFLAGS.SPELLS_CAST]++;
			if (!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell, 0, 0, 0, 0);
			spellPerkUnlock();
			outputText("<b>Mana Shield was autocasted successfully.</b>\n\n");
		}
	}

	internal function cleanupAfterCombatImpl():void {
		if (player.hasStatusEffect(StatusEffects.CounterRagingInferno)) player.removeStatusEffect(StatusEffects.CounterRagingInferno);
		if (player.hasStatusEffect(StatusEffects.CounterGlacialStorm)) player.removeStatusEffect(StatusEffects.CounterGlacialStorm);
		if (player.hasStatusEffect(StatusEffects.CounterHighVoltage)) player.removeStatusEffect(StatusEffects.CounterHighVoltage);
		if (player.hasStatusEffect(StatusEffects.CounterEclipsingShadow)) player.removeStatusEffect(StatusEffects.CounterEclipsingShadow);
	}

	internal function spellCostImpl(mod:Number):Number {
		//Addiditive mods
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (spellModImpl() > 1) costPercent += Math.round(spellModImpl() - 1) * 10;
		if (player.level >= 24 && player.inte >= 60) costPercent += 50;
		if (player.level >= 42 && player.inte >= 120) costPercent += 50;
		if (player.level >= 60 && player.inte >= 180) costPercent += 50;
		if (player.level >= 78 && player.inte >= 240) costPercent += 50;
		//Limiting it and multiplicative mods
		if (player.hasPerk(PerkLib.BloodMage) && costPercent < 50) costPercent = 50;
		mod *= costPercent / 100;
		if (player.hasPerk(PerkLib.BloodMage) && mod < 5) mod = 5;
		else if (mod < 2) mod = 2;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}
	
	internal function spellCostBloodImpl(mod:Number):Number {
		//Addiditive mods
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.hasPerk(PerkLib.HiddenJobBloodDemon)) costPercent -= 5;
		if (player.hasPerk(PerkLib.WayOfTheBlood)) costPercent -= 5;
		if (player.hasPerk(PerkLib.YourPainMyPower)) costPercent -= 5;
		if (player.hasPerk(PerkLib.MyBloodForBloodPuppies)) costPercent -= 5;
		if (player.hasPerk(PerkLib.BloodDemonToughness)) costPercent -= 5;
		//
		if (player.hasPerk(PerkLib.BloodDemonWisdom)) costPercent -= 5;
		//
		if (player.hasPerk(PerkLib.BloodDemonIntelligence)) costPercent -= 5;
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (spellModImpl() > 1) costPercent += Math.round(spellModImpl() - 1) * 10;
		if (player.level >= 24 && player.inte >= 60) costPercent += 50;
		if (player.level >= 42 && player.inte >= 120) costPercent += 50;
		if (player.level >= 60 && player.inte >= 180) costPercent += 50;
		if (player.level >= 78 && player.inte >= 240) costPercent += 50;
		//Limiting it and multiplicative mods
		if (costPercent < 5) costPercent = 5;
		mod *= costPercent / 100;
		if (mod < 2) mod = 2;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function healCostImpl(mod:Number):Number {
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.hasPerk(PerkLib.WisenedHealer)) {
			costPercent += 100;
			if (player.level >= 24 && player.wis >= 60) costPercent += 25;
			if (player.level >= 42 && player.wis >= 120) costPercent += 25;
			if (player.level >= 60 && player.wis >= 180) costPercent += 25;
			if (player.level >= 78 && player.wis >= 240) costPercent += 25;
		}
		if (player.level >= 24 && player.inte >= 60) costPercent += 25;
		if (player.level >= 42 && player.inte >= 120) costPercent += 25;
		if (player.level >= 60 && player.inte >= 180) costPercent += 25;
		if (player.level >= 78 && player.inte >= 240) costPercent += 25;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) costPercent -= 10;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) costPercent -= 15;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) costPercent -= 20;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) costPercent -= 25;
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (healModImpl() > 1) costPercent += Math.round(healModImpl() - 1) * 10;
		mod *= costPercent / 100;
		if (mod < 5) mod = 5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellCostWhiteImpl(mod:Number):Number {
		//Addiditive mods
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.Ambition)) costPercent -= (100 * player.perkv2(PerkLib.Ambition));
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.PURITAS || player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (spellModWhiteImpl() > 1) costPercent += Math.round(spellModWhiteImpl() - 1) * 10;
		if (player.level >= 24 && player.inte >= 60) costPercent += 50;
		if (player.level >= 42 && player.inte >= 120) costPercent += 50;
		if (player.level >= 60 && player.inte >= 180) costPercent += 50;
		if (player.level >= 78 && player.inte >= 240) costPercent += 50;
		//Limiting it and multiplicative mods
		if (player.hasPerk(PerkLib.BloodMage) && costPercent < 50) costPercent = 50;
		mod *= costPercent / 100;
		if (player.hasPerk(PerkLib.BloodMage) && mod < 5) mod = 5;
		else if (mod < 2) mod = 2;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function healCostWhiteImpl(mod:Number):Number {
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.Ambition)) costPercent -= (100 * player.perkv2(PerkLib.Ambition));
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.hasPerk(PerkLib.WisenedHealer)) {
			costPercent += 100;
			if (player.level >= 24 && player.wis >= 60) costPercent += 25;
			if (player.level >= 42 && player.wis >= 120) costPercent += 25;
			if (player.level >= 60 && player.wis >= 180) costPercent += 25;
			if (player.level >= 78 && player.wis >= 240) costPercent += 25;
		}
		if (player.level >= 24 && player.inte >= 60) costPercent += 25;
		if (player.level >= 42 && player.inte >= 120) costPercent += 25;
		if (player.level >= 60 && player.inte >= 180) costPercent += 25;
		if (player.level >= 78 && player.inte >= 240) costPercent += 25;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) costPercent -= 10;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) costPercent -= 15;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) costPercent -= 20;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) costPercent -= 25;
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.PURITAS || player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (healModWhiteImpl() > 1) costPercent += Math.round(healModWhiteImpl() - 1) * 10;
		mod *= costPercent / 100;
		if (mod < 5) mod = 5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellCostBlackImpl(mod:Number):Number {
		//Addiditive mods
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.Obsession)) costPercent -= (100 * player.perkv2(PerkLib.Obsession));
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.hasPerk(PerkLib.Necromancy)) costPercent -= 50;
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.DEPRAVA || player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (spellModBlackImpl() > 1) costPercent += Math.round(spellModBlackImpl() - 1) * 10;
		if (player.level >= 24 && player.inte >= 60) costPercent += 50;
		if (player.level >= 42 && player.inte >= 120) costPercent += 50;
		if (player.level >= 60 && player.inte >= 180) costPercent += 50;
		if (player.level >= 78 && player.inte >= 240) costPercent += 50;
		//Limiting it and multiplicative mods
		if (player.hasPerk(PerkLib.BloodMage) && costPercent < 50) costPercent = 50;
		mod *= costPercent / 100;
		if (player.hasPerk(PerkLib.BloodMage) && mod < 5) mod = 5;
		else if (mod < 2) mod = 2;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function healCostBlackImpl(mod:Number):Number {
		var costPercent:Number = 100;
		if (player.hasPerk(PerkLib.Obsession)) costPercent -= (100 * player.perkv2(PerkLib.Obsession));
		if (player.hasPerk(PerkLib.SeersInsight)) costPercent -= (100 * player.perkv1(PerkLib.SeersInsight));
		if (player.hasPerk(PerkLib.SpellcastingAffinity)) costPercent -= player.perkv1(PerkLib.SpellcastingAffinity);
		if (player.hasPerk(PerkLib.WizardsEnduranceAndSluttySeduction)) costPercent -= player.perkv1(PerkLib.WizardsEnduranceAndSluttySeduction);
		if (player.hasPerk(PerkLib.WizardsAndDaoistsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsAndDaoistsEndurance);
		if (player.hasPerk(PerkLib.WizardsEndurance)) costPercent -= player.perkv1(PerkLib.WizardsEndurance);
		if (player.hasPerk(PerkLib.WisenedHealer)) {
			costPercent += 100;
			if (player.level >= 24 && player.wis >= 60) costPercent += 25;
			if (player.level >= 42 && player.wis >= 120) costPercent += 25;
			if (player.level >= 60 && player.wis >= 180) costPercent += 25;
			if (player.level >= 78 && player.wis >= 240) costPercent += 25;
		}
		if (player.level >= 24 && player.inte >= 60) costPercent += 25;
		if (player.level >= 42 && player.inte >= 120) costPercent += 25;
		if (player.level >= 60 && player.inte >= 180) costPercent += 25;
		if (player.level >= 78 && player.inte >= 240) costPercent += 25;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) costPercent -= 10;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) costPercent -= 15;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) costPercent -= 20;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) costPercent -= 25;
		if (player.hasPerk(PerkLib.Necromancy)) costPercent -= 50;
		if (player.headjewelryName == "fox hairpin") costPercent -= 20;
		if (player.weapon == weapons.DEPRAVA || player.weapon == weapons.ASCENSU) costPercent -= 15;
		if (player.weapon == weapons.N_STAFF) costPercent += 200;
		if (healModBlackImpl() > 1) costPercent += Math.round(healModBlackImpl() - 1) * 10;
		mod *= costPercent / 100;
		if (mod < 5) mod = 5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellModImpl():Number {
		var mod:Number = 1;
		if (player.hasPerk(PerkLib.Archmage) && player.inte >= 100) mod += .3;
		if (player.hasPerk(PerkLib.Channeling) && player.inte >= 60) mod += .2;
		if (player.hasPerk(PerkLib.GrandArchmage) && player.inte >= 125) mod += .4;
		if (player.hasPerk(PerkLib.GrandArchmage2ndCircle) && player.inte >= 150) mod += .5;
		if (player.hasPerk(PerkLib.GrandArchmage3rdCircle) && player.inte >= 175) mod += .6;
		if (player.hasPerk(PerkLib.GrandMage) && player.inte >= 75) mod += .2;
		if (player.hasPerk(PerkLib.JobSorcerer) && player.inte >= 25) mod += .1;
		if (player.hasPerk(PerkLib.PrestigeJobGreySage)) mod += .2;
		if (player.hasPerk(PerkLib.Mage) && player.inte >= 50) mod += .1;
		if (player.hasPerk(PerkLib.Spellpower) && player.inte >= 50) mod += .1;
		if (player.hasPerk(PerkLib.TraditionalMageI) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageII) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageIII) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageIV) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageV) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageVI) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.Obsession)) {
			mod += player.perkv1(PerkLib.Obsession);
		}
		if (player.hasPerk(PerkLib.Ambition)) {
			mod += player.perkv1(PerkLib.Ambition);
		}
		if (player.hasPerk(PerkLib.WizardsFocus)) {
			mod += player.perkv1(PerkLib.WizardsFocus);
		}
		if (player.hasPerk(PerkLib.WizardsAndDaoistsFocus)) {
			mod += player.perkv1(PerkLib.WizardsAndDaoistsFocus);
		}
		if (player.hasPerk(PerkLib.SagesKnowledge)) {
			mod += player.perkv1(PerkLib.SagesKnowledge);
		}
		if (player.hasPerk(PerkLib.KnowledgeIsPower)) {
			if (player.hasPerk(PerkLib.RatatoskrSmartsFinalForm)) mod += (Math.round(codex.checkUnlocked() / 100) * 3);
			else mod += Math.round(codex.checkUnlocked() / 100);
		}
		if (player.hasPerk(PerkLib.ZenjisInfluence3)) mod += .3;
		if (player.hasPerk(PerkLib.ChiReflowMagic)) mod += UmasShop.NEEDLEWORK_MAGIC_SPELL_MULTI;
		if (player.hasPerk(PerkLib.TamamoNoMaeCursedKimono)) mod += (player.cor * .01)/2;
		if (player.jewelryEffectId == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId2 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId3 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId4 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.necklaceEffectId == NecklaceLib.MODIFIER_SPELL_POWER) mod += (player.necklaceEffectMagnitude / 100);
		if (player.countCockSocks("blue") > 0) mod += (player.countCockSocks("blue") * .05);
		if (player.hasPerk(PerkLib.AscensionMysticality)) mod *= 1 + (player.perkv1(PerkLib.AscensionMysticality) * 0.1);
		if (player.hasPerk(PerkLib.SeersInsight)) mod += player.perkv1(PerkLib.SeersInsight);
		if (player.shield == shields.SPI_FOC) mod += .2;
		if (player.shield == shields.MABRACE) mod += .5;
		if (player.weapon == weapons.N_STAFF) mod += player.cor * .01;
		if (player.weapon == weapons.U_STAFF) mod += (100 - player.cor) * .01;
		if (player.headJewelry == headjewelries.SPHINXAS) mod += .5;
		if (player.hasStatusEffect(StatusEffects.Maleficium)) {
			if (player.hasPerk(MutationsLib.ObsidianHeartPrimitive)) {
				if (player.hasPerk(MutationsLib.ObsidianHeartEvolved)) mod += 2.5;
				else mod += 1.25;
			} else mod += 1;
		}
		if (player.weapon == weapons.B_STAFF) {
			var mod1:Number = 0.4;
			mod1 -= player.cor / 10;
			if (mod1 < 0.1) mod1 = 0.1;
			mod += mod1;
		}
		if (player.hasPerk(PerkLib.InariBlessedKimono)){
			var mod2:Number = 0.5;
			mod2 -= player.cor / 10;
			if (mod1 < 0.1) mod2 = 0.1;
			mod += mod2;
		}
		if (player.weapon == weapons.PURITAS) mod *= 1.6;
		if (player.weapon == weapons.DEPRAVA) mod *= 1.6;
		if (player.weapon == weapons.ASCENSU) mod *= 2.5;
		if (player.hasStatusEffect(StatusEffects.DarkRitual)) mod *= 3;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}
	
	internal function spellModBloodImpl():Number {
		var mod:Number = 0;
		mod += spellModImpl();
		if (player.hasPerk(PerkLib.HiddenJobBloodDemon)) mod += .1;
		if (player.hasPerk(PerkLib.WayOfTheBlood)) mod += .1;
		if (player.hasPerk(PerkLib.YourPainMyPower)) mod += .1;
		if (player.hasPerk(PerkLib.MyBloodForBloodPuppies)) mod += .1;
		if (player.hasPerk(PerkLib.BloodDemonToughness)) mod += .1;
		//
		if (player.hasPerk(PerkLib.BloodDemonWisdom)) mod += .1;
		//
		if (player.hasPerk(PerkLib.BloodDemonIntelligence)) mod += .1;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellGreyCooldownImpl():Number {
		var mod:Number = 3;
		if (mod < 0) mod = 0;
		return mod;
	}

	internal function healModImpl():Number {
		var mod:Number = 1;
		if (player.hasPerk(PerkLib.SpellpowerHealing) && player.wis >= 50) mod += .2;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) mod += .3;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) mod += .4;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) mod += .5;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) mod += .6;
		if (player.hasPerk(PerkLib.Obsession)) {
			mod += player.perkv1(PerkLib.Obsession);
		}
		if (player.hasPerk(PerkLib.Ambition)) {
			mod += player.perkv1(PerkLib.Ambition);
		}
		if (player.hasPerk(PerkLib.WizardsFocus)) {
			mod += player.perkv1(PerkLib.WizardsFocus);
		}
		if (player.hasPerk(PerkLib.WizardsAndDaoistsFocus)) {
			mod += player.perkv1(PerkLib.WizardsAndDaoistsFocus);
		}
		if (player.hasPerk(PerkLib.SagesKnowledge)) {
			mod += player.perkv1(PerkLib.SagesKnowledge);
		}
		if (player.hasPerk(PerkLib.ChiReflowMagic)) mod += UmasShop.NEEDLEWORK_MAGIC_SPELL_MULTI;
		if (player.jewelryEffectId == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId2 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId3 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId4 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.necklaceEffectId == NecklaceLib.MODIFIER_SPELL_POWER) mod += (player.necklaceEffectMagnitude / 100);
		if (player.countCockSocks("blue") > 0) mod += (player.countCockSocks("blue") * .05);
		if (player.hasPerk(PerkLib.AscensionMysticality)) mod *= 1 + (player.perkv1(PerkLib.AscensionMysticality) * 0.1);
		if (player.hasPerk(PerkLib.SeersInsight)) mod += player.perkv1(PerkLib.SeersInsight);
		if (player.shield == shields.MABRACE) mod += .5;
		if (player.weapon == weapons.N_STAFF) mod += player.cor * .01;
		if (player.weapon == weapons.U_STAFF) mod += (100 - player.cor) * .01;
		if (player.weapon == weapons.B_STAFF) {
			var mod1:Number = 0.4;
			mod1 -= player.cor / 10;
			if (mod1 < 0.1) mod1 = 0.1;
			mod += mod1;
		}
		if (player.weapon == weapons.PURITAS) mod *= 1.6;
		if (player.weapon == weapons.DEPRAVA) mod *= 1.6;
		if (player.weapon == weapons.ASCENSU) mod *= 2.5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellModBase():Number {
		var mod:Number = 0;
		if (player.hasPerk(PerkLib.Archmage) && player.inte >= 100) mod += .3;
		if (player.hasPerk(PerkLib.Channeling) && player.inte >= 60) mod += .2;
		if (player.hasPerk(PerkLib.GrandArchmage) && player.inte >= 125) mod += .4;
		if (player.hasPerk(PerkLib.GrandArchmage2ndCircle) && player.inte >= 150) mod += .5;
		if (player.hasPerk(PerkLib.GrandArchmage3rdCircle) && player.inte >= 175) mod += .6;
		if (player.hasPerk(PerkLib.GrandMage) && player.inte >= 75) mod += .2;
		if (player.hasPerk(PerkLib.JobSorcerer) && player.inte >= 25) mod += .1;
		if (player.hasPerk(PerkLib.PrestigeJobGreySage)) mod += .2;
		if (player.hasPerk(PerkLib.Mage) && player.inte >= 50) mod += .1;
		if (player.hasPerk(PerkLib.Spellpower) && player.inte >= 50) mod += .1;
		if (player.hasPerk(PerkLib.TraditionalMageI) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageII) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageIII) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageIV) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageV) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.TraditionalMageVI) && player.isUsingStaff() && player.isUsingTome()) mod += 1;
		if (player.hasPerk(PerkLib.Ambition)) {
			mod += player.perkv2(PerkLib.Ambition);
		}
		if (player.hasPerk(PerkLib.WizardsFocus)) {
			mod += player.perkv1(PerkLib.WizardsFocus);
		}
		if (player.hasPerk(PerkLib.WizardsAndDaoistsFocus)) {
			mod += player.perkv1(PerkLib.WizardsAndDaoistsFocus);
		}
		if (player.hasPerk(PerkLib.SagesKnowledge)) {
			mod += player.perkv1(PerkLib.SagesKnowledge);
		}
		if (player.hasPerk(PerkLib.ChiReflowMagic)) mod += UmasShop.NEEDLEWORK_MAGIC_SPELL_MULTI;
		if (player.hasPerk(PerkLib.TamamoNoMaeCursedKimono)) mod += (player.cor * .01)/2;
		if (player.jewelryEffectId == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId2 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId3 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId4 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.necklaceEffectId == NecklaceLib.MODIFIER_SPELL_POWER) mod += (player.necklaceEffectMagnitude / 100);
		if (player.countCockSocks("blue") > 0) mod += (player.countCockSocks("blue") * .05);
		if (player.hasPerk(PerkLib.AscensionMysticality)) mod *= 1 + (player.perkv1(PerkLib.AscensionMysticality) * 0.1);
		if (player.hasPerk(PerkLib.SeersInsight)) mod += player.perkv1(PerkLib.SeersInsight);
		if (player.shield == shields.SPI_FOC) mod += .2;
		if (player.shield == shields.MABRACE) mod += .5;
		if (player.weapon == weapons.N_STAFF) mod += player.cor * .01;
		if (player.weapon == weapons.U_STAFF) mod += (100 - player.cor) * .01;
		if (player.headJewelry == headjewelries.SPHINXAS) mod += .5;
		if (player.headJewelry == headjewelries.DMONSKUL) mod += player.cor * .006;
		if (player.hasStatusEffect(StatusEffects.Maleficium)) {
			if (player.hasPerk(MutationsLib.ObsidianHeartPrimitive)) {
				if (player.hasPerk(MutationsLib.ObsidianHeartEvolved)) mod += 2.5;
				else mod += 1.25;
			} else mod += 1;
		}
		if (player.weapon == weapons.B_STAFF) {
			var mod1:Number = 0.4;
			mod1 -= player.cor / 10;
			if (mod1 < 0.1) mod1 = 0.1;
			mod += mod1;
		}
		if (player.hasPerk(PerkLib.InariBlessedKimono)){
			var mod2:Number = 0.5;
			mod2 -= player.cor / 10;
			if (mod1 < 0.1) mod2 = 0.1;
			mod += mod2;
		}
		if (player.weapon == weapons.ASCENSU) mod *= 2.5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}
	
	private function spellModGrey():Number {
		var mod:Number = 1;
		if (player.hasPerk(PerkLib.GreyMageApprentice) && player.inte >= 75) mod += .1;
		if (player.hasPerk(PerkLib.GreyMage) && player.inte >= 125) mod += .2;
		if (player.hasPerk(PerkLib.GreyArchmage) && player.inte >= 175) mod += .3;
		if (player.hasPerk(PerkLib.GrandGreyArchmage) && player.inte >= 225) mod += .4;
		return mod;
	}

	internal function spellModWhiteImpl():Number {
		var mod:Number = 1;
		mod += spellModBase();
		if (player.hasStatusEffect(StatusEffects.BlessingOfDivineMarae)) {
			mod += player.statusEffectv2(StatusEffects.BlessingOfDivineMarae);
		}
		if (player.hasPerk(PerkLib.AvatorOfPurity)) mod += .2;
		if (player.hasPerk(PerkLib.UnicornBlessing) && player.cor <= 20) mod += .2;
		if (player.hasPerk(PerkLib.PrestigeJobArchpriest)) mod += .2;
		if (player.hasPerk(PerkLib.PrestigeJobWarlock)) mod -= .4;
		if (player.hasKeyItem("Holy Symbol") >= 0) mod += .2;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellWhiteCooldownImpl():Number {
		var mod:Number = 3;
		if (player.hasPerk(PerkLib.AvatorOfPurity)) mod -= 1;
		if (mod < 0) mod = 0;
		return mod;
	}

	internal function spellWhiteTier2CooldownImpl():Number {
		var mod:Number = 6;
		if (player.hasPerk(PerkLib.AvatorOfPurity)) mod -= 1;
		if (mod < 0) mod = 0;
		return mod;
	}

	internal function healModWhiteImpl():Number {
		var mod:Number = 1;
		if (player.hasPerk(PerkLib.SpellpowerHealing) && player.wis >= 50) mod += .2;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) mod += .3;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) mod += .4;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) mod += .5;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) mod += .6;
		if (player.hasPerk(PerkLib.Ambition)) {
			mod += player.perkv2(PerkLib.Ambition);
		}
		if (player.hasStatusEffect(StatusEffects.BlessingOfDivineMarae)) {
			mod += player.statusEffectv2(StatusEffects.BlessingOfDivineMarae);
		}
		if (player.hasPerk(PerkLib.WizardsFocus)) {
			mod += player.perkv1(PerkLib.WizardsFocus);
		}
		if (player.hasPerk(PerkLib.WizardsAndDaoistsFocus)) {
			mod += player.perkv1(PerkLib.WizardsAndDaoistsFocus);
		}
		if (player.hasPerk(PerkLib.SagesKnowledge)) {
			mod += player.perkv1(PerkLib.SagesKnowledge);
		}
		if (player.hasPerk(PerkLib.ChiReflowMagic)) mod += UmasShop.NEEDLEWORK_MAGIC_SPELL_MULTI;
		if (player.hasPerk(PerkLib.AvatorOfPurity)) mod += .3;
		if (player.hasPerk(PerkLib.UnicornBlessing) && player.cor <= 20) mod += .2;
		if (player.hasKeyItem("Holy Symbol") >= 0) mod += .2;
		if (player.jewelryEffectId == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId2 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId3 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId4 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.necklaceEffectId == NecklaceLib.MODIFIER_SPELL_POWER) mod += (player.necklaceEffectMagnitude / 100);
		if (player.countCockSocks("blue") > 0) mod += (player.countCockSocks("blue") * .05);
		if (player.hasPerk(PerkLib.AscensionMysticality)) mod *= 1 + (player.perkv1(PerkLib.AscensionMysticality) * 0.1);
		if (player.hasPerk(PerkLib.SeersInsight)) mod += player.perkv1(PerkLib.SeersInsight);
		if (player.shield == shields.MABRACE) mod += .5;
		if (player.weapon == weapons.N_STAFF) mod += player.cor * .02;
		if (player.weapon == weapons.U_STAFF) mod += (100 - player.cor) * .017;
		if (player.weapon == weapons.B_STAFF) {
			var mod1:Number = 0.4;
			mod1 -= player.cor / 10;
			if (mod1 < 0.1) mod1 = 0.1;
			mod += mod1;
		}
		if (player.weapon == weapons.PURITAS) mod *= 1.6;
		if (player.weapon == weapons.ASCENSU) mod *= 2.5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellModBlackImpl():Number {
		var mod:Number = 1;
		mod += spellModBase();
		if (player.hasPerk(PerkLib.AvatorOfCorruption)) mod += .3;
		if (player.hasPerk(PerkLib.BicornBlessing) && player.cor >= 80) mod += .2;
		if (player.hasPerk(PerkLib.PrestigeJobArchpriest)) mod -= .4;
		if (player.hasPerk(PerkLib.PrestigeJobWarlock)) mod += .2;
		if (player.miscJewelry == miscjewelries.DMAGETO || player.miscJewelry2 == miscjewelries.DMAGETO) mod += 0.25;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	internal function spellBlackCooldownImpl():Number {
		var mod:Number = 3;
		if (player.hasPerk(PerkLib.AvatorOfCorruption)) mod -= 1;
		if (mod < 0) mod = 0;
		return mod;
	}

	internal function spellBlackTier2CooldownImpl():Number {
		var mod:Number = 6;
		if (player.hasPerk(PerkLib.AvatorOfCorruption)) mod -= 1;
		if (mod < 0) mod = 0;
		return mod;
	}

	internal function healModBlackImpl():Number {
		var mod:Number = 1;
		if (player.hasPerk(PerkLib.SpellpowerHealing) && player.wis >= 50) mod += .2;
		if (player.hasPerk(PerkLib.NaturalHealingMinor)) mod += .3;
		if (player.hasPerk(PerkLib.NaturalHealingMajor)) mod += .4;
		if (player.hasPerk(PerkLib.NaturalHealingEpic)) mod += .5;
		if (player.hasPerk(PerkLib.NaturalHealingLegendary)) mod += .6;
		if (player.hasPerk(PerkLib.Obsession)) {
			mod += player.perkv2(PerkLib.Obsession);
		}
		if (player.hasPerk(PerkLib.WizardsFocus)) {
			mod += player.perkv1(PerkLib.WizardsFocus);
		}
		if (player.hasPerk(PerkLib.WizardsAndDaoistsFocus)) {
			mod += player.perkv1(PerkLib.WizardsAndDaoistsFocus);
		}
		if (player.hasPerk(PerkLib.SagesKnowledge)) {
			mod += player.perkv1(PerkLib.SagesKnowledge);
		}
		if (player.hasPerk(PerkLib.ChiReflowMagic)) mod += UmasShop.NEEDLEWORK_MAGIC_SPELL_MULTI;
		if (player.hasPerk(PerkLib.AvatorOfCorruption)) mod += .3;
		if (player.hasPerk(PerkLib.BicornBlessing) && player.cor >= 80) mod += .2;
		if (player.jewelryEffectId == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId2 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId3 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.jewelryEffectId4 == JewelryLib.MODIFIER_SPELL_POWER) mod += (player.jewelryEffectMagnitude / 100);
		if (player.necklaceEffectId == NecklaceLib.MODIFIER_SPELL_POWER) mod += (player.necklaceEffectMagnitude / 100);
		if (player.countCockSocks("blue") > 0) mod += (player.countCockSocks("blue") * .05);
		if (player.hasPerk(PerkLib.AscensionMysticality)) mod *= 1 + (player.perkv1(PerkLib.AscensionMysticality) * 0.1);
		if (player.hasPerk(PerkLib.SeersInsight)) mod += player.perkv1(PerkLib.SeersInsight);
		if (player.shield == shields.MABRACE) mod += .5;
		if (player.weapon == weapons.N_STAFF) mod += player.cor * .01;
		if (player.weapon == weapons.U_STAFF) mod += (100 - player.cor) * .01;
		if (player.weapon == weapons.B_STAFF) {
			var mod1:Number = 0.4;
			mod1 -= player.cor / 10;
			if (mod1 < 0.1) mod1 = 0.1;
			mod += mod1;
		}
		if (player.weapon == weapons.DEPRAVA) mod *= 1.6;
		if (player.weapon == weapons.ASCENSU) mod *= 2.5;
		mod = Math.round(mod * 100) / 100;
		return mod;
	}

	public function spellMightCostMultiplier():Number {
		var spellMightMultiplier:Number = 1;
		if (player.hasPerk(PerkLib.EverLastingBuffs)) spellMightMultiplier *= 2;
		if (player.hasPerk(PerkLib.EternalyLastingBuffs)) spellMightMultiplier *= 2;
		return spellMightMultiplier;
	}

	public function spellBlinkCostMultiplier():Number {
		var spellBlinkMultiplier:Number = 1;
		if (player.hasPerk(PerkLib.EverLastingBuffs)) spellBlinkMultiplier *= 2;
		if (player.hasPerk(PerkLib.EternalyLastingBuffs)) spellBlinkMultiplier *= 2;
		return spellBlinkMultiplier;
	}

	public function spellChargeWeaponCostMultiplier():Number {
		var spellChargeWeaponMultiplier:Number = 1;
		spellChargeWeaponMultiplier *= spellChargeWeaponWeaponSizeManaCost();
		if (player.hasStatusEffect(StatusEffects.SiegweirdTraining)) spellChargeWeaponMultiplier *= 0.5;
		if (player.hasPerk(PerkLib.EverLastingBuffs)) spellChargeWeaponMultiplier *= 2;
		if (player.hasPerk(PerkLib.EternalyLastingBuffs)) spellChargeWeaponMultiplier *= 2;
		return spellChargeWeaponMultiplier;
	}

	public function spellChargeArmorCostMultiplier():Number {
		var spellChargeArmorMultiplier:Number = 1;
		spellChargeArmorMultiplier *= spellChargeArmorType();
		if (player.hasStatusEffect(StatusEffects.SiegweirdTraining)) spellChargeArmorMultiplier *= 0.5;
		if (player.hasPerk(PerkLib.EverLastingBuffs)) spellChargeArmorMultiplier *= 2;
		if (player.hasPerk(PerkLib.EternalyLastingBuffs)) spellChargeArmorMultiplier *= 2;
		return spellChargeArmorMultiplier;
	}

	public function getBlackMagicMinLust():Number {
		if (player.hasPerk(PerkLib.GreyMage)) return 30;
		return 50;
	}

	public function getWhiteMagicLustCap():Number {
		var whiteLustCap:int = player.maxLust() * 0.75;
		if (player.hasPerk(PerkLib.Enlightened) && player.cor < (10 + player.corruptionTolerance())) whiteLustCap += (player.maxLust() * 0.1);
		if (player.hasPerk(PerkLib.FocusedMind) && !player.hasPerk(PerkLib.GreyMage)) whiteLustCap += (player.maxLust() * 0.1);
		if (player.hasPerk(PerkLib.GreyMage)) {
			if (player.hasPerk(PerkLib.Enlightened) && player.cor < (10 + player.corruptionTolerance())) whiteLustCap = (player.maxLust() - 15);
			else whiteLustCap = (player.maxLust() - 45);
		}
		return whiteLustCap;
	}
	
	public function perkRelatedDurationBoosting():Number {
		var perkRelatedDB:Number = 0;
		if (player.hasPerk(PerkLib.LongerLastingBuffsI)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.LongerLastingBuffsII)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.LongerLastingBuffsIII)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.LongerLastingBuffsIV)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.LongerLastingBuffsV)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.LongerLastingBuffsVI)) perkRelatedDB += 1;
		if (player.hasPerk(PerkLib.EverLastingBuffs)) perkRelatedDB += 5;
		if (player.hasPerk(PerkLib.EternalyLastingBuffs)) perkRelatedDB += 5;
		return perkRelatedDB;
	}

	internal function calcInfernoModImpl(damage:Number):int {
		if (player.hasPerk(PerkLib.RagingInferno)) {
			if (player.hasStatusEffect(StatusEffects.CounterRagingInferno)) {
				var multiplier:Number = 1;
				if (player.statusEffectv1(StatusEffects.CounterRagingInferno) == 0) outputText("Unfortunately, traces of your previously used fire magic are too weak to be used.\n\n");
				else {
					outputText("Traces of your previously used fire magic are still here, and you use them to empower another spell!\n\n");
					multiplier += player.statusEffectv1(StatusEffects.CounterRagingInferno) * 0.05;
					damage = Math.round(damage * multiplier);
				}
				if (player.statusEffectv4(StatusEffects.CounterRagingInferno) == 0) {
					player.addStatusValue(StatusEffects.CounterRagingInferno, 4, 1);
					if (player.hasPerk(PerkLib.RagingInfernoEx)) player.addStatusValue(StatusEffects.CounterRagingInferno, 1, 6);
					else player.addStatusValue(StatusEffects.CounterRagingInferno, 1, 4);
				}
				player.addStatusValue(StatusEffects.CounterRagingInferno, 2, 1);
			}
			else {
				if (player.hasPerk(PerkLib.RagingInfernoEx)) player.createStatusEffect(StatusEffects.CounterRagingInferno,6,1,0,1);
				else player.createStatusEffect(StatusEffects.CounterRagingInferno,4,1,0,1);
			}
		}
		return damage;
	}

	internal function calcGlacialModImpl(damage:Number):int {
		if (player.hasPerk(PerkLib.GlacialStorm)) {
			if (player.hasStatusEffect(StatusEffects.CounterGlacialStorm)) {
				var multiplier:Number = 1;
				if (player.statusEffectv1(StatusEffects.CounterGlacialStorm) == 0) outputText("Unfortunately, traces of your previously used ice magic are too weak to be used.\n\n");
				else {
					outputText("Traces of your previously used ice magic are still here, and you use them to empower another spell!\n\n");
					multiplier += player.statusEffectv1(StatusEffects.CounterGlacialStorm) * 0.05;
					damage = Math.round(damage * multiplier);
				}
				if (player.statusEffectv4(StatusEffects.CounterGlacialStorm) == 0) {
					player.addStatusValue(StatusEffects.CounterGlacialStorm, 4, 1);
					if (player.hasPerk(PerkLib.GlacialStormEx)) player.addStatusValue(StatusEffects.CounterGlacialStorm, 1, 6);
					else player.addStatusValue(StatusEffects.CounterGlacialStorm, 1, 4);
				}
				player.addStatusValue(StatusEffects.CounterGlacialStorm, 2, 1);
			}
			else {
				if (player.hasPerk(PerkLib.GlacialStormEx)) player.createStatusEffect(StatusEffects.CounterGlacialStorm,6,1,0,1);
				else player.createStatusEffect(StatusEffects.CounterGlacialStorm,4,1,0,1);
			}
		}
		return damage;
	}

	internal function calcVoltageModImpl(damage:Number):int {
		if (player.hasPerk(PerkLib.HighVoltage)) {
			if (player.hasStatusEffect(StatusEffects.CounterHighVoltage)) {
				var multiplier:Number = 1;
				if (player.statusEffectv1(StatusEffects.CounterHighVoltage) == 0) outputText("Unfortunately, traces of your previously used lightning magic are too weak to be used.\n\n");
				else {
					outputText("Traces of your previously used lightning magic are still here, and you use them to empower another spell!\n\n");
					multiplier += player.statusEffectv1(StatusEffects.CounterHighVoltage) * 0.05;
					damage = Math.round(damage * multiplier);
				}
				if (player.statusEffectv4(StatusEffects.CounterHighVoltage) == 0) {
					player.addStatusValue(StatusEffects.CounterHighVoltage, 4, 1);
					if (player.hasPerk(PerkLib.HighVoltageEx)) player.addStatusValue(StatusEffects.CounterHighVoltage, 1, 6);
					else player.addStatusValue(StatusEffects.CounterHighVoltage, 1, 4);
				}
				player.addStatusValue(StatusEffects.CounterHighVoltage, 2, 1);
			}
			else {
				if (player.hasPerk(PerkLib.HighVoltageEx)) player.createStatusEffect(StatusEffects.CounterHighVoltage,6,1,0,1);
				else player.createStatusEffect(StatusEffects.CounterHighVoltage,4,1,0,1);
			}
		}
		return damage;
	}

	internal function calcEclypseModImpl(damage:Number):int {
		if (player.hasPerk(PerkLib.EclipsingShadow)) {
			if (player.hasStatusEffect(StatusEffects.CounterEclipsingShadow)) {
				var multiplier:Number = 1;
				if (player.statusEffectv1(StatusEffects.CounterEclipsingShadow) == 0) outputText("Unfortunately, traces of your previously used darkness magic are too weak to be used.\n\n");
				else {
					outputText("Traces of your previously used darkness magic are still here, and you use them to empower another spell!\n\n");
					multiplier += player.statusEffectv1(StatusEffects.CounterEclipsingShadow) * 0.05;
					damage = Math.round(damage * multiplier);
				}
				if (player.statusEffectv4(StatusEffects.CounterEclipsingShadow) == 0) {
					player.addStatusValue(StatusEffects.CounterEclipsingShadow, 4, 1);
					if (player.hasPerk(PerkLib.EclipsingShadowEx)) player.addStatusValue(StatusEffects.CounterEclipsingShadow, 1, 6);
					else player.addStatusValue(StatusEffects.CounterEclipsingShadow, 1, 4);
				}
				player.addStatusValue(StatusEffects.CounterEclipsingShadow, 2, 1);
			}
			else {
				if (player.hasPerk(PerkLib.EclipsingShadowEx)) player.createStatusEffect(StatusEffects.CounterEclipsingShadow,6,1,0,1);
				else player.createStatusEffect(StatusEffects.CounterEclipsingShadow,4,1,0,1);
			}
		}
		return damage;
	}

	public function buildWhiteMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var badLustForWhite:Boolean = player.lust >= getWhiteMagicLustCap();
		var bloodForBloodGod:Number = (player.HP - player.minHP());

		//WHITE SHITZ
		if (player.hasStatusEffect(StatusEffects.KnowsWhitefire)) {
			bd = buttons.add("Whitefire", spellWhitefire)
					.hint("Whitefire is a potent fire based attack that will burn your foe with flickering white flames, ignoring their physical toughness and most armors.  " +
							"\n\nMana Cost: " + spellCostWhite(40) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(40)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40) && player.HP < spellCostWhite(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellWhitefire)) {
				bd.disable("You need more time before you can cast Whitefire again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("Whitefire(Ex)", spellWhitefire2)
						.hint("Whitefire (Ex) is a potent wrath-empowered fire based attack that will burn your foe with flickering white flames, ignoring their physical toughness and most armors.  " +
								"\n\nMana Cost: " + spellCostWhite(40) + ", Wrath Cost: 100");
				if (badLustForWhite) {
					bd.disable("You are far too aroused to focus on white magic.");
				} else if (player.hasPerk(PerkLib.HexKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(40)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40) && player.HP < spellCostWhite(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellWhitefireEx)) {
					bd.disable("You need more time before you can cast Whitefire (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
					bd.disable("Your ability to use white magic was sealed.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsPyreBurst)) {
			bd = buttons.add("Pyre Burst", spellPyreBurst)
					.hint("Teach your foes a lesson with the strength of a firestorm.  \n\n<b>AoE Spell.</b>  " +
							"\n\nMana Cost: " + spellCostWhite(200) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200) && player.HP < spellCostWhite(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellPyreBurst)) {
				bd.disable("You need more time before you can cast Pyre Burst again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("Pyre Burst(Ex)", spellPyreBurst2)
						.hint("Teach your foes a lesson with the strength of a wrath-enpowered firestorm.  \n\n<b>AoE Spell.</b>  " +
								"\n\nMana Cost: " + spellCostWhite(200) + ", Wrath Cost: 100");
				if (badLustForWhite) {
					bd.disable("You are far too aroused to focus on white magic.");
				} else if (player.hasPerk(PerkLib.HexKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(200)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200) && player.HP < spellCostWhite(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellPyreBurstEx)) {
					bd.disable("You need more time before you can cast Pyre Burst (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
					bd.disable("Your ability to use white magic was sealed.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsLightningBolt)) {
			bd = buttons.add("LightningBolt", spellLightningBolt)
					.hint("Lightning Bolt is a basic lightning attack that will electrocute your foe with a single bolt of lightning.  " +
							"\n\nMana Cost: " + spellCostWhite(40) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(40)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40) && player.HP < spellCostWhite(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellLightningBolt)) {
				bd.disable("You need more time before you can cast Lightning Bolt again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("LightningBolt(Ex)", spellLightningBolt2)
						.hint("Lightning Bolt (Ex) is a basic wrath-enpowered lightning attack that will electrocute your foe with a single bolt of lightning.  " +
								"\n\nMana Cost: " + spellCostWhite(40) + ", Wrath Cost: 100");
				if (badLustForWhite) {
					bd.disable("You are far too aroused to focus on white magic.");
				} else if (player.hasPerk(PerkLib.HexKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(40)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40) && player.HP < spellCostWhite(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellLightningBoltEx)) {
					bd.disable("You need more time before you can cast Lightning Bolt (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
					bd.disable("Your ability to use white magic was sealed.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsChainLighting)) {
			bd = buttons.add("ChainLighting", spellChainLightning)
					.hint("Chain Lighting is a lightning attack that will electrocute your foes with a chain bolts of lightning.  \n\n<b>AoE Spell.</b>  " +
							"\n\nMana Cost: " + spellCostWhite(200) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200) && player.HP < spellCostWhite(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellChainLighting)) {
				bd.disable("You need more time before you can cast Chain Lighting again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("ChainLighting(Ex)", spellChainLightning2)
						.hint("Chain Lighting (Ex) is a wrath-enpowered lightning attack that will electrocute your foes with a chain bolts of lightning.  \n\n<b>AoE Spell.</b>  " +
								"\n\nMana Cost: " + spellCostWhite(200) + ", Wrath Cost: 100");
				if (badLustForWhite) {
					bd.disable("You are far too aroused to focus on white magic.");
				} else if (player.hasPerk(PerkLib.HexKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(200)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200) && player.HP < spellCostWhite(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellChainLightingEx)) {
					bd.disable("You need more time before you can cast Chain Lighting (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
					bd.disable("Your ability to use white magic was sealed.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBlind)) {
			bd = buttons.add("Blind", spellBlind)
					.hint("Blind is a fairly self-explanatory spell.  It will create a bright flash just in front of the victim's eyes, blinding them for a time.  However if they blink it will be wasted.  " +
							"\n\nMana Cost: " + spellCostWhite(30) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Blind)) {
				bd.disable(monster.capitalA + monster.short + " is already affected by blind.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(30)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(30) && player.HP < spellCostWhite(30)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(30)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsCharge)) {
			bd = buttons.add("Charge W.", spellChargeWeapon)
					.hint("The Charge Weapon spell will surround your weapons in electrical energy, causing them to do even more damage.  The effect lasts for a few combat turns.  " +
							"\n\nMana Cost: " + spellCostWhite(60) * spellChargeWeaponCostMultiplier() + "", "Charge Weapon");
			if (player.weaponName == "fists" && !player.hasPerk(PerkLib.ImprovingNaturesBlueprintsNaturalWeapons)) {
				bd.disable("Charge weapon can't be casted on your own fists.");
			} else if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasStatusEffect(StatusEffects.ChargeWeapon)){
				bd.disable("Charge weapon is already active and cannot be cast again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < (spellCostWhite(30) * spellChargeWeaponCostMultiplier())) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < (spellCostWhite(30) * spellChargeWeaponCostMultiplier()) && player.HP < (spellCostWhite(30) * spellChargeWeaponCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < (spellCostWhite(30) * spellChargeWeaponCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsChargeA)) {
			bd = buttons.add("Charge A.", spellChargeArmor)
					.hint("The Charge Armor spell will surround your armor with electrical energy, causing it to do provide additional protection.  The effect lasts for a few combat turns.  " +
							"\n\nMana Cost: " + spellCostWhite(40) * spellChargeArmorCostMultiplier() + "", "Charge Armor");
			if (player.isNaked() && (!player.haveNaturalArmor() || player.hasPerk(PerkLib.ImprovingNaturesBlueprintsNaturalArmor))) {
				bd.disable("Charge armor can't be casted without wearing any armor or even underwear.");
			} else if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasStatusEffect(StatusEffects.ChargeArmor)) {
				bd.disable("Charge armor is already active and cannot be cast again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < (spellCostWhite(40) * spellChargeArmorCostMultiplier())) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < (spellCostWhite(40) * spellChargeArmorCostMultiplier()) && player.HP < (spellCostWhite(40) * spellChargeArmorCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < (spellCostWhite(40) * spellChargeArmorCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsHeal)) {
			bd = buttons.add("Heal", spellHeal)
					.hint("Heal will attempt to use white magic to instnatly close your wounds and restore your body.  " +
							"\n\nMana Cost: " + healCostWhite(30) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if(player.mana < healCostWhite(30)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellHeal)) {
				bd.disable("You need more time before you can cast Heal again.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBlizzard)) {
			bd = buttons.add("Blizzard", spellBlizzard)
					.hint("Blizzard is a potent ice based defense spell that will reduce power of any fire based attack used against the user.  " +
							"\n\nMana Cost: " + spellCostWhite(50) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasStatusEffect(StatusEffects.Blizzard)) {
				bd.disable("Blizzard is already active and cannot be cast again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(50)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(50) && player.HP < spellCostWhite(50)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(50)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsMentalShield)) {
			bd = buttons.add("MentalShield", spellMentalShield)
					.hint("Protects against lust effects for 10 rounds, halving the damage.  " +
							"\n\nMana Cost: " + spellCostWhite(300) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasStatusEffect(StatusEffects.MentalShield)) {
				bd.disable("Mental Shield is already active and cannot be cast again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(300)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(300) && player.HP < spellCostWhite(300)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(300)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellMentalShield)) {
				bd.disable("You need more time before you can cast Mental Shield again.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsCure)) {
			bd = buttons.add("Cure", spellCure)
					.hint("Negate all status ailments. Restore stat damaged by poison.  " +
							"\n\nMana Cost: " + spellCostWhite(500) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(500)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500) && player.HP < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellCure)) {
				bd.disable("You need more time before you can cast Cure again.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsFireStorm)) {
			bd = buttons.add("Fire Storm", spellFireStorm).hint("Drawning your own force of the willpower to fuel radical change in the surrounding you can call forth an Fire Storm that will attack enemies in a wide area.  \n\n<b>AoE Spell.</b>  \n\nMana Cost: " + spellCostWhite(500) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(500)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500) && player.HP < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellFireStorm)) {
				bd.disable("You need more time before you can cast Fire Storm again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsMeteorShower)) {
			bd = buttons.add("Meteor Shower", spellMeteorShower)
					.hint("Call down a rain of meteors on your opponents, stunning them for 1 round and dealing area damage. Hits 12 times.  " +
							"\n\n<b>AoE Spell and req. 1 turn channeling. Cooldown: 12 turns</b>  \n\nMana Cost: " + spellCostWhite(1250) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on white magic.");
			} else if (inDungeon || player.hasStatusEffect(StatusEffects.InsideSmallSpace)) {
				bd.disable("You can't use this spell inside small spaces. Unless you want get killed along with your enemies.");
			} else if (player.hasStatusEffect(StatusEffects.UnderwaterCombatBoost)) {
				bd.disable("You can't use this spell underwater.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(1250)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.HexKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(1250) && player.HP < spellCostWhite(1250)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(1250)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellMeteorShower)) {
				bd.disable("You need more time before you can cast Meteor Shower again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Sealed) && player.statusEffectv2(StatusEffects.Sealed) == 10) {
				bd.disable("Your ability to use white magic was sealed.");
			}
		}
	}

	public function buildBlackMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var badLustForBlack:Boolean = player.lust < getBlackMagicMinLust();
		var bloodForBloodGod:Number = (player.HP - player.minHP());

		//BLACK MAGICSKS
		if (player.hasStatusEffect(StatusEffects.KnowsIceSpike)) {
			bd = buttons.add("Ice Spike", spellIceSpike)
					.hint("Drawning your own lust to concentrate it into chilling spike of ice that will attack your enemies.  " +
							"\n\nMana Cost: " + spellCostBlack(40) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(40)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40) && player.HP < spellCostBlack(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellIceSpike)) {
				bd.disable("You need more time before you can cast Ice Spike again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("Ice Spike", spellIceSpike2)
						.hint("Drawning your own lust and wrath to concentrate them into chilling spike of ice that will attack your enemies.  " +
								"\n\nMana Cost: " + spellCostBlack(40) + ", Wrath Cost: 100");
				if (badLustForBlack) {
					bd.disable("You aren't turned on enough to use any black magics.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(40)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40) && player.HP < spellCostBlack(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellIceSpikeEx)) {
					bd.disable("You need more time before you can cast Ice Spike (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsArcticGale)) {
			bd = buttons.add("Arctic Gale", spellArcticGale)
					.hint("Devastate the enemy ranks with a blast of icy wind sharper then steel blades.  \n\n<b>AoE Spell.</b>  " +
							"\n\nMana Cost: " + spellCostBlack(200) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200) && player.HP < spellCostBlack(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellArcticGale)) {
				bd.disable("You need more time before you can cast Arctic Gale again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("Arctic Gale(Ex)", spellArcticGale2)
						.hint("Devastate the enemy ranks with a blast of wrath-enpowered icy wind sharper then steel blades.  \n\n<b>AoE Spell.</b>  " +
								"\n\nMana Cost: " + spellCostBlack(200) + ", Wrath Cost: 100");
				if (badLustForBlack) {
					bd.disable("You aren't turned on enough to use any black magics.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(200)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200) && player.HP < spellCostBlack(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellArcticGaleEx)) {
					bd.disable("You need more time before you can cast Arctic Gale (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsDarknessShard)) {
			bd = buttons.add("DarknessShard", spellDarknessShard)
					.hint("Drawning your own lust to condense part of the the ambivalent darkness into a shard to attack your enemies.  " +
							"\n\nMana Cost: " + spellCostBlack(40) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(40)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40) && player.HP < spellCostBlack(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(40)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellDarknessShard)) {
				bd.disable("You need more time before you can cast Darkness Shard again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("DarknessShard(Ex)", spellDarknessShard2)
						.hint("Drawning your own lust and wrath to condense part of the the ambivalent darkness into a shard to attack your enemies.  " +
								"\n\nMana Cost: " + spellCostBlack(40) + ", Wrath Cost: 100");
				if (badLustForBlack) {
					bd.disable("You aren't turned on enough to use any black magics.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(40)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40) && player.HP < spellCostBlack(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(40)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellDarknessShardEx)) {
					bd.disable("You need more time before you can cast Darkness Shard (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsDuskWave)) {
			bd = buttons.add("Dusk Wave", spellDuskWave)
					.hint("Drawning your own lust to condense part of the the ambivalent darkness into a wave to attack your enemies.  \n\n<b>AoE Spell.</b>  " +
							"\n\nMana Cost: " + spellCostBlack(200) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200) && player.HP < spellCostBlack(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellDuskWave)) {
				bd.disable("You need more time before you can cast Dusk Wave again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
			if (player.hasPerk(PerkLib.MagesWrathEx)) {
				bd = buttons.add("Dusk Wave(Ex)", spellDuskWave2)
						.hint("Drawning your own lust and wrath to condense part of the the ambivalent darkness into a wave to attack your enemies.  \n\n<b>AoE Spell.</b>  " +
								"\n\nMana Cost: " + spellCostBlack(200) + "");
				if (badLustForBlack) {
					bd.disable("You aren't turned on enough to use any black magics.");
				} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(200)) {
					bd.disable("Your mana is too low to cast this spell.");
				} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
					bd.disable("Your chosen path of magic locked out this spell.");
				} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200) && player.HP < spellCostBlack(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(200)) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.wrath < 100) {
					bd.disable("Your wrath is too low to cast this spell.");
				} else if (player.hasStatusEffect(StatusEffects.CooldownSpellDuskWaveEx)) {
					bd.disable("You need more time before you can cast Dusk Wave (Ex) again.");
				} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
					bd.disable("You can only use buff magic while underground.");
				} else if (combat.isEnnemyInvisible) {
					bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsArouse)) {
			bd = buttons.add("Arouse", spellArouse)
					.hint("The arouse spell draws on your own inner lust in order to enflame the enemy's passions.  " +
							"\n\nMana Cost: " + spellCostBlack(20) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(20)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(20) && player.HP < spellCostBlack(20)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(20)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsWaveOfEcstasy)) {
			bd = buttons.add("WaveOfEcstasy", spellWaveOfEcstasy)
					.hint("The arouse spell draws on your own inner lust in order to enflame the enemies passions.  " +
							"\n\nMana Cost: " + spellCostBlack(100) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(100)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(100) && player.HP < spellCostBlack(100)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(100)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellWaveOfEcstasy)) {
				bd.disable("You need more time before you can cast Wave of Ecstasy again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsMight)) {
			bd = buttons.add("Might", spellMight)
					.hint("The Might spell draws upon your lust and uses it to fuel a temporary increase in muscle size and power.  It does carry the risk of backfiring and raising lust, like all black magic used on oneself.  " +
							"\n\nMana Cost: " + spellCostBlack(50) * spellMightCostMultiplier() + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (player.statStore.hasBuff("Might")) {
				bd.disable("You are already under the effects of Might and cannot cast it again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < (spellCostBlack(50) * spellMightCostMultiplier())) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < (spellCostBlack(50) * spellMightCostMultiplier()) && player.HP < (spellCostBlack(50) * spellMightCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < (spellCostBlack(50) * spellMightCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBlink)) {
			bd = buttons.add("Blink", spellBlink)
					.hint("The Blink spell draws upon your lust and uses it to fuel a temporary increase in moving speed and if it's needed teleport over short distances.  It does carry the risk of backfiring and raising lust, like all black magic used on oneself.  " +
							"\n\nMana Cost: " + spellCostBlack(40) * spellBlinkCostMultiplier() + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (player.statStore.hasBuff("Blink")) {
				bd.disable("You are already under the effects of Blink and cannot cast it again.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < (spellCostBlack(40) * spellBlinkCostMultiplier())) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < (spellCostBlack(40) * spellBlinkCostMultiplier()) && player.HP < (spellCostBlack(40) * spellBlinkCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < (spellCostBlack(40) * spellBlinkCostMultiplier())) {
				bd.disable("Your hp is too low to cast this spell.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsRegenerate)) {
			bd = buttons.add("Regenerate", spellRegenerate)
					.hint("Regenerate will attempt to trigger health recovery over time, however like all black magic used on yourself, it has a chance of backfiring and greatly arousing you.  " +
							"\n\nMana Cost: " + healCostBlack(50) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (player.hasStatusEffect(StatusEffects.PlayerRegenerate)) {
				bd.disable("You are already under the effects of Regenerate and cannot cast it again.");
			} else if (player.mana < healCostBlack(50)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellRegenerate)) {
				bd.disable("You need more time before you can cast Regenerate again.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsIceRain)) {
			bd = buttons.add("Ice Rain", spellIceRain).hint("Drawning your own lust to fuel radical change in the surrounding you can call forth an Ice Rain that will attack enemies in a wide area.  It carry the risk of backfiring and raising lust.  \n\n<b>AoE Spell.</b>  \n\nMana Cost: " + spellCostBlack(500) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if(!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(500)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if(player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(500) && player.HP < spellCostBlack(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellIceRain)) {
				bd.disable("You need more time before you can cast Ice Rain again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsNosferatu)) {
			bd = buttons.add("Nosferatu", spellNosferatu)
					.hint("Vampirise the health of your foe, dealing damage and healing you back for 100% of the damage done." +
							"\n\nMana Cost: " + healCostBlack(50) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if(player.mana < healCostBlack(50)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellNosferatu)) {
				bd.disable("You need more time before you can cast Nosferatu again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsPolarMidnight)) {
			bd = buttons.add("Polar Midnight", spellPolarMidnight)
					.hint("Cause a massive temperature drop which freezes the air solid in an area. Opponents caught in this spell take the cold damage and are stunned for 5 round.  " +
							"\n\n<b>AoE Spell and req. 1 turn channeling. Cooldown: 12 turns</b>  \n\nMana Cost: " + spellCostBlack(1250) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any black magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(1250)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.DivineKnowledge)) {
				bd.disable("Your chosen path of magic locked out this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(1250) && player.HP < spellCostBlack(1250)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(1250)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellPolarMidnight)) {
				bd.disable("You need more time before you can cast Polar Midnight again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
	}

	public function buildHexMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var badLustForBlack:Boolean = player.lust < getBlackMagicMinLust();
		var bloodForBloodGod:Number = (player.HP - player.minHP());

		//HEX MAGIC
		if (player.hasStatusEffect(StatusEffects.KnowsLifetap)) {
			bd = buttons.add("Lifetap", spellLifetap)
					.hint("Sacrifice a quarter of your hp to recover a quarter of your mana.");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any hex magics.");
			} else if(player.cor < 80) {
				bd.disable("Your corruption is too low to cast this spell.");
			} else if(player.HP < player.maxHP() * .25) {
				bd.disable("Your HP is too low to cast this spell.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsLifeSiphon)) {
			bd = buttons.add("Life siphon", spellLifeSiphon)
					.hint("Create a funnel between you and your target, forcefully stealing its vitality to recover your own.  " +
							"\n\nMana Cost: " + spellCostBlack(750) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any hex magics.");
			} else if(player.cor < 80) {
				bd.disable("Your corruption is too low to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(750)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(750) && player.HP < spellCostBlack(750)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(750)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.LifeSiphon)) {
				bd.disable("You're still linked to the enemy.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsConsumingDarkness)) {
			bd = buttons.add("Consuming darkness", spellConsumingDarkness)
					.hint("For the next 7 round the target is devoured by living shadow trying to tear its body apart deals good damage on each round.  \n\n<b>Cooldown: 15 turns</b>  " +
							"\n\nMana Cost: " + spellCostBlack(350) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any hex magics.");
			} else if(player.cor < 80) {
				bd.disable("Your corruption is too low to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(350)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(350) && player.HP < spellCostBlack(350)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(350)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellConsumingDarkness)) {
				bd.disable("You need more time before you can cast Consuming darkness again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsCurseOfDesire)) {
			bd = buttons.add("Curse of Desire", spellCurseOfDesire)
					.hint("Arouse yourself and curse the target with lewd thoughts, weakening its resistance to lust and forcing it to take low lust damage each round for 8 rounds.  \n\n<b>Cooldown: 15 turns</b>  " +
							"\n\nMana Cost: " + spellCostBlack(400) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any hex magics.");
			} else if(player.cor < 80) {
				bd.disable("Your corruption is too low to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(400)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(400) && player.HP < spellCostBlack(400)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostBlack(400)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellCurseOfDesire)) {
				bd.disable("You need more time before you can cast Curse of Desire again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsCurseOfWeeping)) {
			bd = buttons.add("Curse of Weeping", spellCurseOfWeeping)
					.hint("Draw your own blood and inflict on your target a terrible curse, dealing high damage for 6 rounds.  \n\n<b>Cooldown: 10 turns</b>  " +
							"\n\nMana Cost: " + spellCostBlack(300) + "");
			if (badLustForBlack) {
				bd.disable("You aren't turned on enough to use any hex magics.");
			} else if(player.cor < 80) {
				bd.disable("Your corruption is too low to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostBlack(300)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(300) && player.HP < (spellCostBlack(300) + player.maxHP() * .5)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < (spellCostBlack(300) + player.maxHP() * .5)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if(player.HP < player.maxHP() * .5) {
				bd.disable("Your HP is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellCurseOfWeeping)) {
				bd.disable("You need more time before you can cast Curse of Weeping again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
	}
	
	public function buildDivineMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var badLustForWhite:Boolean = player.lust >= getWhiteMagicLustCap();
		var bloodForBloodGod:Number = (player.HP - player.minHP());

		if (player.hasStatusEffect(StatusEffects.KnowsAegis)) {
			bd = buttons.add("Aegis", spellAegis)
					.hint("Increase block chance by 1 to 10%, tripled if using a staff and no shield. (Based on spell buff and intelligence)  " +
							"\n\nMana Cost: " + spellCostWhite(500) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on divine magic.");
			} else if(player.cor > 20) {
				bd.disable("Your corruption is too high to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(500)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500) && player.HP < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.Aegis)) {
				bd.disable("Your Aegis is still active.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsExorcise)) {
			bd = buttons.add("Exorcise", spellExorcise)
					.hint("Smite your opponent with your weapon, inflicting damage based on the weapon’s damage and your magical power. Highly effective against the corrupt.  " +
							"\n\nMana Cost: " + spellCostWhite(400) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on divine magic.");
			} else if(player.cor > 20) {
				bd.disable("Your corruption is too high to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(400)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(400) && player.HP < spellCostWhite(400)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(400)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellExorcise)) {
				bd.disable("You need more time before you can cast Exorcise again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsDivineShield)) {
			bd = buttons.add("DivineShield", spellDivineShield)
					.hint("Increase magic resistance by 40%.  " +
							"\n\nMana Cost: " + spellCostWhite(600) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on divine magic.");
			} else if(player.cor > 20) {
				bd.disable("Your corruption is too high to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(600)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(600) && player.HP < spellCostWhite(600)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(600)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.DivineShield)) {
				bd.disable("Your Divine Shield is still active.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsThunderstorm)) {
			bd = buttons.add("Thunderstorm", spellThunderstorm)
					.hint("Call upon the heavenly thunder, starting a lightning storm that will systematically zap your opponents every turn for up to 30 rounds.  " +
							"\n\nMana Cost: " + spellCostWhite(1200) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on divine magic.");
			} else if(player.cor > 20) {
				bd.disable("Your corruption is too high to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(1200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(1200) && player.HP < spellCostWhite(1200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(1200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.hasStatusEffect(StatusEffects.Thunderstorm)) {
				bd.disable("Can be casted only once per combat.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsTearsOfDenial)) {
			bd = buttons.add("TearsOfDenial", spellTearsOfDenial)
					.hint("When hit by an ability that would put you to min hit points or be filled with lust instead heal you to full health and wash your desire away.  " +
							"\n\nMana Cost: " + spellCostWhite(3000) + "");
			if (badLustForWhite) {
				bd.disable("You are far too aroused to focus on divine magic.");
			} else if(player.cor > 20) {
				bd.disable("Your corruption is too high to cast this spell.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCostWhite(3000)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(3000) && player.HP < spellCostWhite(3000)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCostWhite(3000)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.TearsOfDenial)) {
				bd.disable("Can be casted only once per combat.");
			}
		}
	}
	
	public function buildNecroMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		if (player.hasStatusEffect(StatusEffects.KnowsBoneSpirit)) {
			bd = buttons.add("Bone spirit", spellBoneSpirit)
					.hint("Turn an ordinary set of bones into a vengeance mad apparition that will charge at your target. Upon contact it will explode dealing massive true damage.  \n\nBones cost: 5");
			if (!player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 5) {
				bd.disable("You not have enough demon bones to use any this necromancer spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBoneArmor)) {
			bd = buttons.add("Bone armor", spellBoneArmor)
					.hint("Animate bones to create an impenetrable shield lasting 5 rounds and reducing all damage taken by 50%.  \n\n<b>Cooldown: 10 turns</b>  \n\nBones cost: 10");
			if (!player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 10) {
				bd.disable("You not have enough demon bones to use any this necromancer spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBoneArmor)) {
				bd.disable("You need more time before you can cast Bone armor again.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBoneshatter)) {
			bd = buttons.add("Boneshatter", spellBoneshatter)
					.hint("Strike at the target ossature causing it to explode from the inside and causing serious internal damage and weakening its blow. Single target only (does not work on boneless creatures, Monster take 20% strength drain from this effect which stacks).  \n\n<b>Cooldown: 3 turns</b>  \n\nBones cost: 5");
			if (!player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 5) {
				bd.disable("You not have enough demon bones to use any this necromancer spell.");
			} else if (monster.hasPerk(PerkLib.EnemyConstructType) || monster.hasPerk(PerkLib.EnemyElementalType) || monster.hasPerk(PerkLib.EnemyGhostType) || monster.hasPerk(PerkLib.EnemyGooType) || monster.hasPerk(PerkLib.EnemyPlantType)) {
				bd.disable("Your enemy lack bones.");
			} else if (monster.plural || monster.hasPerk(PerkLib.Enemy300Type) || monster.hasPerk(PerkLib.EnemyGroupType) || monster.hasPerk(PerkLib.EnemyLargeGroupType)) {
				bd.disable("You can only strike one target.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBoneshatter)) {
				bd.disable("You need more time before you can cast Boneshatter again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			}
		}
	}

	public function buildGreyMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var numb:Number = 50;
		if (player.hasPerk(PerkLib.GrandGreyArchmage)) numb -= 50;
		var badLustForGrey:Boolean = player.lust < numb || player.lust > (player.maxLust() - numb);
		var bloodForBloodGod:Number = (player.HP - player.minHP());
//perki z grey mage line dajace spell mod * x% wiecej (nie wplywa na sam spell mod anu spell mod white/black)
		// GRAY MAGIC
		if (player.hasStatusEffect(StatusEffects.KnowsManaShield)) {
			if (player.hasStatusEffect(StatusEffects.ManaShield)) {
				buttons.add("Deactiv MS", DeactivateManaShield).hint("Deactivate Mana Shield.");
			} else {
				bd = buttons.add("Mana Shield", spellManaShield)
						.hint("Drawning your own mana with help of lust and force of the willpower to form shield that can absorb attacks.  Despite been grey magic it still does carry the risk of backfiring and raising lust.  \n\nMana Cost: 1 mana point per 1 point of damage blocked");
				if (badLustForGrey) {
					bd.disable("You can't use any grey magics.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsEnergyDrain)) {
			bd = buttons.add("Energy Drain", spellEnergyDrain)
					.hint("Fatigue the target (-20% damage for 7 rounds) and recover mana by draining the target's mana (up to 4x of spell cost).  " +
							"\n\nMana Cost: " + spellCost(350) + "");
			if (badLustForGrey) {
				bd.disable("You can't use any grey magics.");
			} else if(!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCost(350)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if(player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(350) && player.HP < spellCost(350)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCost(350)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellEnergyDrain)) {
				bd.disable("You need more time before you can cast Energy Drain again.");
			} else if (monster.hasStatusEffect(StatusEffects.EnergyDrain)) {
				bd.disable("Energy Drain is still active.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsRestore)) {
			bd = buttons.add("Restore", spellRestore)
					.hint("Heal for a decent amount of health and regenerate a little over time.  " +
							"\n\nMana Cost: " + healCost(80) + "");
			if (badLustForGrey) {
				bd.disable("You can't use any grey magics.");
			} else if(player.mana < healCost(80)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellRestore)) {
				bd.disable("You need more time before you can cast Restore again.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBalanceOfLife)) {
			bd = buttons.add("BalanceOfLife", spellBalanceOfLife)
					.hint("Heals for 5% of your hp when dealing spell damage." +
							"\n\nMana Cost: " + spellCost(500) + "");
			if (badLustForGrey) {
				bd.disable("You can't use any grey magics.");
			} else if(!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCost(500)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if(player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(500) && player.HP < spellCost(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCost(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			}
		}
		//	if (player.hasStatusEffect(StatusEffects.KnowsWereBeast)) buttons.add("Were-beast",	were-beast spell goes here
		//	if (player.hasStatusEffect(StatusEffects.Knows)) buttons.add("	next spell (non-fire or non-ice based) goes here
		/*if (player.hasStatusEffect(StatusEffects.KnowsFireStorm)) {
			bd = buttons.add("Fire Storm", spell2FireStorm).hint("Drawning your own lust and force of the willpower to fuel radical change in the surrounding you can call forth an Fire Storm that will attack enemies in a wide area.  Despite been grey magic it still does carry the risk of backfiring and raising lust.  \n\n<b>AoE Spell.</b>  \n\nMana Cost: " + spellCost(200) + "");
			if (badLustForGrey) {
				bd.disable("You can't use any grey magics.");
			} else if (!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCost(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(200) && player.HP < spellCost(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCost(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}*/
		//	if (player.hasStatusEffect(StatusEffects.Knows)) buttons.add("	fire single target spell goes here
		/*if (player.hasStatusEffect(StatusEffects.KnowsIceRain)) {
			bd = buttons.add("Ice Rain", spell2IceRain).hint("Drawning your own lust and force of the willpower to fuel radical change in the surrounding you can call forth an Ice Rain that will attack enemies in a wide area.  Despite been grey magic it still does carry the risk of backfiring and raising lust.  \n\n<b>AoE Spell.</b>  \n\nMana Cost: " + spellCost(200) + "");
			if (badLustForGrey) {
				bd.disable("You can't use any grey magics.");
			} else if(!player.hasPerk(PerkLib.BloodMage) && !player.hasPerk(PerkLib.LastResort) && !player.hasStatusEffect(StatusEffects.BloodMage) && player.mana < spellCost(200)) {
				bd.disable("Your mana is too low to cast this spell.");
			} else if(player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(200) && player.HP < spellCost(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodMage) && (bloodForBloodGod - 1) < spellCost(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			}
		}*/
	}
	
	public function buildBloodMenu(buttons:ButtonDataList):void {
		var bd:ButtonData;
		var bloodForBloodGod:Number = (player.HP - player.minHP());
		if (player.hasStatusEffect(StatusEffects.KnowsBloodMissiles)) {
			bd = buttons.add("BloodMissiles", spellBloodMissiles)
					.hint("Blood Missiles will attack foe with five blood spheres.  " +
							"\n\nBlood Cost: " + spellCostBlood(50) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(50)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBloodMissiles)) {
				bd.disable("You need more time before you can cast this spell again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBloodShield)) {
			if (player.hasStatusEffect(StatusEffects.BloodShield)) {
				buttons.add("Deactiv BS", DeactivateBloodShield).hint("Deactivate Blood Shield.");
			}
			else {
				bd = buttons.add("BloodShield", spellBloodShield)
						.hint("Blood Shield will form blood shield to block enemy attacks.  " +
								"\n\nBlood Cost: " + spellCostBlood(spellBloodShieldCost()) + "");
				if ((bloodForBloodGod - 1) < spellCostBlood(spellBloodShieldCost())) {
					bd.disable("Your hp is too low to cast this spell.");
				} else if (player.isGargoyle()) {
					bd.disable("You cannot use blood spells if you not have blood at all.");
				}
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBloodExplosion)) {
			bd = buttons.add("BloodExplosion", spellBloodExplosion)
					.hint("Blood Explosion will attack foe with blood orb.  \n\n<b>AoE Spell.</b>  " +
							"\n\nBlood Cost: " + spellCostBlood(200) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(200)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBloodExplosion)) {
				bd.disable("You need more time before you can cast this spell again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBloodChains)) {
			bd = buttons.add("BloodChains", spellBloodChains)
					.hint("Blood Chains will immobilize foe briefly.  " +
							"\n\nBlood Cost: " + spellCostBlood(100) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(100)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBloodChains)) {
				bd.disable("You need more time before you can cast this spell again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBloodWave)) {//blood wave (deal more to larger groups of enemies than normal small groups)
			bd = buttons.add("BloodWave", spellBloodWave)
					.hint("Blood Shield will attack all surrounding foes with a wave of blood.  It would deal more damage when used against larger than averange sized group of enemies.  \n\n<b>AoE Spell.</b>  " +
							"\n\nBlood Cost: " + spellCostBlood(400) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(400)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.CooldownSpellBloodWave)) {
				bd.disable("You need more time before you can cast this spell again.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsLifestealEnchantment)) {
			bd = buttons.add("LifestealEnch", spellLifestealEnchantment)
					.hint("Lifesteal Enchantment will add lifesteal effect to your weapons.  " +
							"\n\nBlood Cost: " + spellCostBlood(500) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(500)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.LifestealEnchantment)) {
				bd.disable("You can recast this spell only after it duration ended.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
		if (player.hasStatusEffect(StatusEffects.KnowsBloodField)) {
			bd = buttons.add("BloodField", spellBloodField)
					.hint("Blood Field will form field on the ground that would slow down enemies, drain their health and heal the caster.  " +
							"\n\nBlood Cost: " + spellCostBlood(600) + "");
			if ((bloodForBloodGod - 1) < spellCostBlood(600)) {
				bd.disable("Your hp is too low to cast this spell.");
			} else if (player.hasStatusEffect(StatusEffects.BloodField)) {
				bd.disable("You can recast this spell only after it duration ended.");
			} else if (monster.hasStatusEffect(StatusEffects.Dig)) {
				bd.disable("You can only use buff magic while underground.");
			} else if (combat.isEnnemyInvisible) {
				bd.disable("You cannot use offensive spells against an opponent you cannot see or target.");
			} else if (player.isGargoyle()) {
				bd.disable("You cannot use blood spells if you not have blood at all.");
			}
		}
	}

	//THIS FEATURE GOVERS EVERY POST CAST EFFECT YOUR SPELLS MAY CAUSE
	public function MagicAddonEffect(numberOfProcs:Number = 1):void {
		if (player.hasStatusEffect(StatusEffects.Venomancy)) {
			if (player.tailVenom >= player.VenomWebCost()) {
				var injections:Number = 0;
				while (player.tailVenom >= player.VenomWebCost() && injections < numberOfProcs) {
					var damageB:Number = 35 + rand(player.lib / 10);
					var poisonScaling:Number = 1;
					var dam4Bab:Number = 1;
					if (player.hasPerk(PerkLib.ImprovedVenomGlandSu)) dam4Bab *= 2;
					poisonScaling += player.lib/100;
					poisonScaling += player.tou/100;
					if (player.level < 10) damageB += 20 + (player.level * 3);
					else if (player.level < 20) damageB += 50 + (player.level - 10) * 2;
					else if (player.level < 30) damageB += 70 + (player.level - 20) * 1;
					else damageB += 80;
					damageB *= 0.04;
					damageB *= dam4Bab;
					poisonScaling *= dam4Bab;
					damageB *= 1+(poisonScaling/10);
					monster.teased(monster.lustVuln * damageB, false);
					monster.statStore.addBuffObject({tou:-poisonScaling}, "Poison",{text:"Poison"});
					if (monster.hasStatusEffect(StatusEffects.NagaVenom)) {
							monster.addStatusValue(StatusEffects.NagaVenom, 3, 1);
					} else monster.createStatusEffect(StatusEffects.NagaVenom, 0, 0, 1, 0);
					player.tailVenom -= player.VenomWebCost();
					flags[kFLAGS.VENOM_TIMES_USED] += 0.2;
					injections++;
				}
				outputText(" Your venom is forcefully injected ");
				if (injections > 1) outputText(""+injections+" times");
				outputText(" in " + monster.a + monster.short + " through your magic!");
			}
		}
		if (player.hasStatusEffect(StatusEffects.BalanceOfLife)) HPChange((player.maxHP() * numberOfProcs * 0.05), false);
	}
	
	public function spellBloodMissiles():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		HPChange(-spellCostBlood(50), false);
		player.createStatusEffect(StatusEffects.CooldownSpellBloodMissiles,2,0,0,0);
		if(handleShell()){return;}
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, "+(player.HP < player.maxOverHP() ? "wounds":"skin pores")+". Around you form a few crimson spheres you aim at " + monster.a + monster.short + "!\n\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlood();
		if (damage < 10) damage = 10;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage * combat.bloodDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		doMagicDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		doMagicDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		doMagicDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		doMagicDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		doMagicDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		outputText(" damage.");
		MagicAddonEffect(5);
		outputText("\n\n");
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if (monster.HP <= monster.minHP()) doNext(endHpVictory);
		else {
			if (monster is Lethice && (monster as Lethice).fightPhase == 3) {
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	
	public function spellBloodShieldCost():Number {
		var shieldcost:Number = 0;
		shieldcost += (player.maxOverHP() * 0.2);
		return shieldcost;
	}
	public function spellBloodShield():void {
		clearOutput();
		HPChange(-spellCostBlood(spellBloodShieldCost()), false);
		player.createStatusEffect(StatusEffects.BloodShield,Math.round(spellBloodShieldCost() * spellModBlood()),0,0,0);
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather around you, coalescing into a semi transparent crimson "+(player.hasStatusEffect(StatusEffects.Flying)?"":"hemi")+"sphere.\n\n");
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		statScreenRefresh();
		enemyAI();
	}
	public function DeactivateBloodShield():void {
		clearOutput();
		outputText("Deciding you no longer need to maintain your blood shield, you stop maintaining it.\n\n");
		player.removeStatusEffect(StatusEffects.BloodShield);
		enemyAI();
	}
	
	public function spellBloodExplosion():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		HPChange(-spellCostBlood(200), false);
		player.createStatusEffect(StatusEffects.CooldownSpellBloodExplosion,3,0,0,0);
		if(handleShell()){return;}
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather above your hand, coalescing into a crimson sphere. ");
		outputText("It roils as you concentrate on it before aim the orb at " + monster.a + monster.short + ", it brusts and seeps into " + monster.pronoun2 + " on impact as " + monster.pronoun1 + "'" + (monster.plural ? "re":"s") + " afflicted by the magic.\n\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlood() * 4;
		if (damage < 10) damage = 10;
		if (monster.plural) damage *= 5;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage * combat.bloodDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		doMagicDamage(damage, true, true);
		outputText(" damage.");
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if (monster.HP <= monster.minHP()) doNext(endHpVictory);
		else {
			if (monster is Lethice && (monster as Lethice).fightPhase == 3) {
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	
	public function spellBloodChains():void {
		clearOutput();
		HPChange(-spellCostBlood(100), false);
		player.createStatusEffect(StatusEffects.CooldownSpellBloodChains,3,0,0,0);
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather before your chest, coalescing into a crimson sphere. ");
		outputText("The blood emitted by you splited into dozens of stems and surrounded " + monster.a + monster.short + ", bounding " + monster.pronoun2 + " tight enought to prevent any movements for some time.\n\n");
		monster.createStatusEffect(StatusEffects.Stunned,2,0,0,0);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		statScreenRefresh();
		enemyAI();
	}
	
	public function spellBloodWave():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		HPChange(-spellCostBlood(400), false);
		player.createStatusEffect(StatusEffects.CooldownSpellBloodWave,5,0,0,0);
		if(handleShell()){return;}
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather around you, coalescing into a crimson ring. ");
		outputText("It roils as you concentrate on it before you release it. It moves in all directions looking like a raging waves until it hits " + monster.a + monster.short + ".\n\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlood() * 4;
		if (damage < 10) damage = 10;
		if (monster.plural) damage *= 5;
		if (monster.hasPerk(PerkLib.EnemyLargeGroupType)) damage *= 5;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage * combat.bloodDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		doMagicDamage(damage, true, true);
		outputText(" damage.");
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if (monster.HP <= monster.minHP()) doNext(endHpVictory);
		else {
			if (monster is Lethice && (monster as Lethice).fightPhase == 3) {
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	
	public function spellLifestealEnchantment():void {
		clearOutput();
		HPChange(-spellCostBlood(500), false);
		player.createStatusEffect(StatusEffects.LifestealEnchantment,5,0,0,0);
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather around weapons, adding a crimson glow.\n\n");
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		statScreenRefresh();
		enemyAI();
	}
	
	public function spellBloodField():void {
		clearOutput();
		HPChange(-spellCostBlood(600), false);
		player.createStatusEffect(StatusEffects.BloodField,3,Math.round(player.maxOverHP() * 0.01),0,0);
		if(handleShell()){return;}
		outputText("You concentrate, focusing on the power of your blood before drawing it from your body, " + (player.HP < player.maxOverHP() ? "wounds":"skin pores") + ". Blood starts to gather before your chest, coalescing into a crimson sphere. ");
		outputText("It roils as you concentrate on it before aim the orb at the ground, it brusts and seeps into it causing to appear a crimson field beneath your feet that start spread around until it cover large area. Additionaly small blood thorns grows from it imparing your enem" + (monster.plural ? "es":"y") + " movements.\n\n");
		if (!monster.isFlying()) monster.buff("BloodThorns").addStats({spe:-20}).withText("Blood Thorns").combatTemporary(3);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		statScreenRefresh();
		enemyAI();
	}

	public function spellMagicBolt():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		useMana(40, 1);
		if(handleShell()){return;}
		spellMagicBolt2();
	}
	public function spellElementalBolt():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		useMana(80, 1);
		if(handleShell()){return;}
		spellMagicBolt2();
	}
	public function spellEdgyMagicBolt():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		useMana(40, 1);
		player.wrath -= 100;
		if(handleShell()){return;}
		spellMagicBolt2(true);
	}
	public function spellEdgyElementalBolt():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		useMana(80, 1);
		player.wrath -= 100;
		if(handleShell()){return;}
		spellMagicBolt2(true);
	}
	public function spellMagicBolt2(edgy:Boolean = false):void {
		outputText("You narrow your eyes, focusing your mind with deadly intent.  ");
		if (player.hasPerk(PerkLib.StaffChanneling) && player.weaponSpecials("Staff")) outputText("You point your staff and shots magic bolt toward " + monster.a + monster.short + "!\n\n");
		else outputText("You point your hand toward " + monster.a + monster.short + " and shots magic bolt!\n\n");
		var damage:Number = scalingBonusIntelligence() * spellMod() * 1.2;
		if (damage < 10) damage = 10;
		//weapon bonus
		if (player.hasPerk(PerkLib.StaffChanneling) && player.weaponSpecials("Staff")) {
			if (player.weaponAttack < 51) damage *= (1 + (player.weaponAttack * 0.04));
			else if (player.weaponAttack >= 51 && player.weaponAttack < 101) damage *= (3 + ((player.weaponAttack - 50) * 0.035));
			else if (player.weaponAttack >= 101 && player.weaponAttack < 151) damage *= (4.75 + ((player.weaponAttack - 100) * 0.03));
			else if (player.weaponAttack >= 151 && player.weaponAttack < 201) damage *= (6.25 + ((player.weaponAttack - 150) * 0.025));
			else damage *= (7.5 + ((player.weaponAttack - 200) * 0.02));
		}
		if (player.hasPerk(PerkLib.ElementalBolt)) damage *= 1.25;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage);
		outputText(monster.capitalA + monster.short + " takes ");
		doMagicDamage(damage, true, true);
		outputText(" damage.");
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		checkAchievementDamage(damage);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if (player.hasPerk(PerkLib.ElementalBolt)) {
			if (player.hasStatusEffect(StatusEffects.CounterEclipsingShadow)) {
				if (player.hasPerk(PerkLib.EclipsingShadowSu)) player.addStatusValue(StatusEffects.CounterEclipsingShadow, 1, 2);
				else if (player.hasPerk(PerkLib.EclipsingShadowEx)) player.addStatusValue(StatusEffects.CounterEclipsingShadow, 1, 3);
				player.addStatusValue(StatusEffects.CounterEclipsingShadow, 1, 4);
			}
			if (player.hasStatusEffect(StatusEffects.CounterGlacialStorm)) {
				if (player.hasPerk(PerkLib.GlacialStormSu)) player.addStatusValue(StatusEffects.CounterGlacialStorm, 1, 2);
				else if (player.hasPerk(PerkLib.GlacialStormEx)) player.addStatusValue(StatusEffects.CounterGlacialStorm, 1, 3);
				player.addStatusValue(StatusEffects.CounterGlacialStorm, 1, 4);
			}
			if (player.hasStatusEffect(StatusEffects.CounterHighVoltage)) {
				if (player.hasPerk(PerkLib.HighVoltageSu)) player.addStatusValue(StatusEffects.CounterHighVoltage, 1, 2);
				else if (player.hasPerk(PerkLib.HighVoltageEx)) player.addStatusValue(StatusEffects.CounterHighVoltage, 1, 3);
				player.addStatusValue(StatusEffects.CounterHighVoltage, 1, 4);
			}
			if (player.hasStatusEffect(StatusEffects.CounterRagingInferno)) {
				if (player.hasPerk(PerkLib.RagingInfernoSu)) player.addStatusValue(StatusEffects.CounterRagingInferno, 1, 2);
				else if (player.hasPerk(PerkLib.RagingInfernoEx)) player.addStatusValue(StatusEffects.CounterRagingInferno, 1, 3);
				player.addStatusValue(StatusEffects.CounterRagingInferno, 1, 4);
			}
		}
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else
		{
			if (monster is Lethice && (monster as Lethice).fightPhase == 3)
			{
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	
	public function spellArouse():void {
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(20)) player.HP -= spellCostBlack(20);
		else useMana(20,6);
		statScreenRefresh();
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		if(handleShell()){return;}
		outputText("You make a series of arcane gestures, drawing on your own lust to inflict it upon your foe!\n");
		//Worms be immune
		if(monster.short == "worms") {
			outputText("The worms appear to be unaffected by your magic!");
			outputText("\n\n");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			doNext(playerMenu);
			if(monster.lust >= monster.maxLust()) doNext(endLustVictory);
			else enemyAI();
			return;
		}
		if(monster.lustVuln == 0) {
			outputText("It has no effect!  Your foe clearly does not experience lust in the same way as you.\n\n");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			enemyAI();
			return;
		}
		var lustDmg:Number = monster.lustVuln * (player.inte / 5 * spellModBlack() + rand(monster.lib - monster.inte * 2 + monster.cor) / 5);
		if(player.hasPerk(PerkLib.ArcaneLash)) lustDmg *= 1.5;
		if(player.hasStatusEffect(StatusEffects.AlvinaTraining2)) lustDmg *= 1.2;
		if(player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) lustDmg = Math.round(lustDmg * 1.2);
		if(player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) lustDmg = Math.round(lustDmg * 1.0);
			else if (monster.cor >= 50) lustDmg = Math.round(lustDmg * 1.1);
			else if (monster.cor >= 25) lustDmg = Math.round(lustDmg * 1.2);
			else if (monster.cor >= 10) lustDmg = Math.round(lustDmg * 1.3);
			else lustDmg = Math.round(lustDmg * 1.4);
		}
		if(monster.lust < (monster.maxLust() * 0.3)) outputText(monster.capitalA + monster.short + " squirms as the magic affects " + monster.pronoun2 + ".  ");
		if(monster.lust >= (monster.maxLust() * 0.3) && monster.lust < (monster.maxLust() * 0.6)) {
			if(monster.plural) outputText(monster.capitalA + monster.short + " stagger, suddenly weak and having trouble focusing on staying upright.  ");
			else outputText(monster.capitalA + monster.short + " staggers, suddenly weak and having trouble focusing on staying upright.  ");
		}
		if(monster.lust >= (monster.maxLust() * 0.6)) {
			outputText(monster.capitalA + monster.short + "'");
			if(!monster.plural) outputText("s");
			outputText(" eyes glaze over with desire for a moment.  ");
		}
		if(monster.cocks.length > 0) {
			if(monster.lust >= (monster.maxLust() * 0.6) && monster.cocks.length > 0) outputText("You see " + monster.pronoun3 + " " + monster.multiCockDescriptLight() + " dribble pre-cum.  ");
			if(monster.lust >= (monster.maxLust() * 0.3) && monster.lust < (monster.maxLust() * 0.6) && monster.cocks.length == 1) outputText(monster.capitalA + monster.short + "'s " + monster.cockDescriptShort(0) + " hardens, distracting " + monster.pronoun2 + " further.  ");
			if(monster.lust >= (monster.maxLust() * 0.3) && monster.lust < (monster.maxLust() * 0.6) && monster.cocks.length > 1) outputText("You see " + monster.pronoun3 + " " + monster.multiCockDescriptLight() + " harden uncomfortably.  ");
		}
		if(monster.vaginas.length > 0) {
			if(monster.plural) {
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_NORMAL) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + "s dampen perceptibly.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_WET) outputText(monster.capitalA + monster.short + "'s crotches become sticky with girl-lust.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_SLICK) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + "s become sloppy and wet.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_DROOLING) outputText("Thick runners of girl-lube stream down the insides of " + monster.a + monster.short + "'s thighs.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_SLAVERING) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + "s instantly soak " + monster.pronoun2 + " groin.  ");
			}
			else {
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_NORMAL) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + " dampens perceptibly.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_WET) outputText(monster.capitalA + monster.short + "'s crotch becomes sticky with girl-lust.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_SLICK) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + " becomes sloppy and wet.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_DROOLING) outputText("Thick runners of girl-lube stream down the insides of " + monster.a + monster.short + "'s thighs.  ");
				if(monster.lust >= (monster.maxLust() * 0.6) && monster.vaginas[0].vaginalWetness == VaginaClass.WETNESS_SLAVERING) outputText(monster.capitalA + monster.short + "'s " + monster.vaginaDescript() + " instantly soaks her groin.  ");
			}
		}
		//Determine if critical tease!
		var crit:Boolean = false;
		var critChance:int = 5;
		if (player.hasPerk(PerkLib.CriticalPerformance)) {
			if (player.lib <= 100) critChance += player.lib / 5;
			if (player.lib > 100) critChance += 20;
		}
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			lustDmg *= 1.75;
		}
		lustDmg = Math.round(lustDmg);
		monster.teased(lustDmg, false);
		if (crit) outputText(" <b>Critical!</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.hasPerk(PerkLib.EromancyMaster)) combat.teaseXP(1 + combat.bonusExpAfterSuccesfullTease());
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		doNext(playerMenu);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(monster.lust >= monster.maxLust()) doNext(endLustVictory);
		else enemyAI();
	}
	public function spellRegenerate():void {
		clearOutput();
		doNext(combatMenu);
		useMana(50, 11);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You focus on your body and its desire to end pain, trying to draw on your arousal without enhancing it.");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText(" An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			if (player.hasStatusEffect(StatusEffects.PlayerRegenerate)) player.addStatusValue(StatusEffects.PlayerRegenerate,1,7);
			else player.createStatusEffect(StatusEffects.PlayerRegenerate,7,0,0,0);
			outputText(" This should hold up for about seven rounds.");
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	/**
	 * Generates from (x1,x2,x3,y1,y2) log-scale parameters (a,b,c) that will return:
	 * y1= 10 at x1=  10
	 * y2= 55 at x2= 100
	 * y3=100 at x3=1000
	 */
	private static const MightABC:Object = FnHelpers.FN.buildLogScaleABC(10,100,1000,10,100);
//(25) Might – increases strength/toughness by 5 * (Int / 10) * spellMod, up to a
//maximum of 15, allows it to exceed the maximum.  Chance of backfiring
//and increasing lust by 15.
	public function spellMight(silent:Boolean = false):void {
		var doEffect:Function = function():* {
			var MightBoostCap:Number = 1.5;
			MightBoostCap *= player.intStat.core.max;
			MightBoostCap = Math.round(MightBoostCap);
			var MightBoost:Number = player.intStat.core.value;
			//MightBoost += Math.round(player.intStat.max * 0.1); - może tylko jak bedzie mieć perk z prestige job: magus / warock / inny związany z spells
			if (MightBoost < 10) MightBoost = 10;
			if (player.hasPerk(PerkLib.JobEnchanter)) MightBoost *= 1.2;
			MightBoost *= spellModBlack();
			//MightBoost = FnHelpers.FN.logScale(MightBoost,MightABC,10);
			MightBoost = Math.round(MightBoost);
			if (MightBoost > MightBoostCap) MightBoost = MightBoostCap;
			var MightDuration:Number = 5;
			MightDuration += perkRelatedDurationBoosting();
			tempTou = MightBoost;
			if (player.hasStatusEffect(StatusEffects.FortressOfIntellect)) tempInt = Math.round(MightBoost * 1.25);
			else tempStr = MightBoost;
			var oldHPratio:Number = player.hp100/100;
			var buffValues:Object = {"tou.mult":tempTou/100};
			if (player.hasStatusEffect(StatusEffects.FortressOfIntellect)) {
				buffValues["int.mult"] = Math.min( tempInt/100, player.intStat.mult.value/2);
			} else {
				buffValues["str.mult"] = Math.min( tempStr/100, player.strStat.mult.value/2);
			}
			player.buff("Might").setStats(buffValues).combatTemporary(MightDuration);
			player.HP = oldHPratio*player.maxHP();
			statScreenRefresh();
		};
		if (silent)	{ // for Battlemage
			doEffect.call();
			return;
		}
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < (50 * spellMightCostMultiplier())) player.HP -= (50 * spellMightCostMultiplier());
		else useMana((50 * spellMightCostMultiplier()),6);
		var tempStr:Number = 0;
		var tempTou:Number = 0;
		var tempInt:Number = 0;
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You flush, drawing on your body's desires to empower your muscles and toughen you up.\n\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			outputText("The rush of success and power flows through your body.  You feel like you can do anything!");
			doEffect.call();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}

	/**
	 * Generates from (x1,x2,x3,y1,y2) log-scale parameters (a,b,c) that will return:
	 * y1= 10 at x1=  10
	 * y2= 55 at x2= 100
	 * y3=100 at x3=1000
	 */
	private static const BlinkABC:Object = FnHelpers.FN.buildLogScaleABC(10,100,1000,10,100);
//(25) Blink – increases speed by 5 * (Int / 10) * spellMod, up to a
//maximum of 15, allows it to exceed the maximum.  Chance of backfiring
//and increasing lust by 15.
	public function spellBlink(silent:Boolean = false):void {
		var doEffect:Function = function():* {
			var BlinkBoostCap:Number = 2;
			BlinkBoostCap *= player.intStat.core.max;
			var BlinkBoost:Number = player.intStat.core.value;
			//BlinkBoost += Math.round(player.intStat.max * 0.1); - może tylko jak bedzie mieć perk z prestige job: magus / warock / inny związany z spells
			if (BlinkBoost < 10) BlinkBoost = 10;
			BlinkBoost *= 1.2;
			if (player.hasPerk(PerkLib.JobEnchanter)) BlinkBoost *= 1.25;
			BlinkBoost *= spellModBlack();
			//BlinkBoost = FnHelpers.FN.logScale(BlinkBoost,BlinkABC,10);
			BlinkBoost = Math.round(BlinkBoost);
			if (BlinkBoost > BlinkBoostCap) BlinkBoost = BlinkBoostCap;
			var BlinkDuration:Number = 5;
			BlinkDuration += perkRelatedDurationBoosting();
			tempSpe = BlinkBoost;
			var oldHPratio:Number = player.hp100/100;
			//if(player.spe + temp > 100) tempSpe = 100 - player.spe;
			mainView.statsView.showStatUp('spe');
			// strUp.visible = true;
			// strDown.visible = false;
			player.buff("Blink").setStats({"spe.mult":tempSpe/100}).combatTemporary(BlinkDuration);
			player.HP = oldHPratio*player.maxHP();
			statScreenRefresh();
		};
		if (silent)	{ // for Battleflash
			doEffect.call();
			return;
		}
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < (40 * spellBlinkCostMultiplier())) player.HP -= (40 * spellBlinkCostMultiplier());
		else useMana((40 * spellBlinkCostMultiplier()),6);
		var tempSpe:Number = 0;
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You flush, drawing on your body's desires to empower your muscles and hasten you up.\n\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			outputText("The rush of success and power flows through your body.  You feel like you can do anything!");
			doEffect.call();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}

//(45) Ice Spike - ice version of whitefire
	public function spellIceSpike():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40)) player.HP -= spellCostBlack(40);
		else useMana(40, 6);
		player.createStatusEffect(StatusEffects.CooldownSpellIceSpike,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellIceSpike3();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellIceSpike2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40)) player.HP -= spellCostBlack(40);
		else useMana(40, 6);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellIceSpikeEx,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellIceSpike3(true);
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellIceSpike3(edgy:Boolean = false):void {
		outputText("You narrow your eyes, focusing your own lust with deadly intent.  At the palm of your hand form ice spike that shots toward " + monster.a + monster.short + " !\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 2;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcGlacialMod(damage);
		if (combat.wearingWinterScarf()) damage *= 1.2;
		if (player.armor == armors.BLIZZ_K) damage *= 1.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 1.3;
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) damage = Math.round(damage * 1.0);
			else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
			else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
			else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.iceDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
		}
		else doIceDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}

//(45) Darkness Shard
	public function spellDarknessShard():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40)) player.HP -= spellCostBlack(40);
		else useMana(40, 6);
		player.createStatusEffect(StatusEffects.CooldownSpellDarknessShard,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellDarknessShard3();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellDarknessShard2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(40)) player.HP -= spellCostBlack(40);
		else useMana(40, 6);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellDarknessShardEx,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellDarknessShard3(true);
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellDarknessShard3(edgy:Boolean = false):void {
		outputText("You narrow your eyes, focusing your own lust with deadly intent.  At the palm of your hand form a shard from pure darkness that shots toward " + monster.a + monster.short + " !\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 2;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcEclypseMod(damage);
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) damage = Math.round(damage * 1.0);
			else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
			else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
			else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.darknessDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doDarknessDamage(damage, true, true);
				doDarknessDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doDarknessDamage(damage, true, true);
				doDarknessDamage(damage, true, true);
			}
		}
		else doDarknessDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}
	
	public function spellWaveOfEcstasy():void {
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(100)) player.HP -= spellCostBlack(100);
		else useMana(100,6);
		statScreenRefresh();
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellWaveOfEcstasy,6,0,0,0);
		if(handleShell()){return;}
		outputText("You almost moan in pleasure as you draw on this spell, sending forth your lust like a shockwave. ");
		//Worms be immune
		if(monster.short == "worms") {
			outputText("\nThe worms appear to be unaffected by your magic!\n\n");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			doNext(playerMenu);
			if(monster.lust >= monster.maxLust()) doNext(endLustVictory);
			else enemyAI();
			return;
		}
		if (monster.short == "troll" || monster.short == "Zenji") {
			if (monster.short == "Zenji") {
				outputText("\nZenji shakes off the effects of the spell.\n\n");
				outputText("\n\"<i>Gonna have ta do more dan dat ta break me.</i>\"\n\n");
			}
			else if (flags[kFLAGS.ZENJI_PROGRESS] == 2) outputText("\nThe troll shakes off the effects of the spell, \"<i>I. Will. Not. Break.</i>\"\n\n");
			else {
				outputText("\nThe troll shakes off the effects of the spell.\n\n");
				outputText("\n\"<i>Gonna have ta do more dan dat ta break me.</i>\"\n\n");
			}
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			enemyAI();
			return;
		}
		if(monster.lustVuln == 0) {
			outputText("\nIt has no effect!  Your foe clearly does not experience lust in the same way as you.\n\n");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			enemyAI();
			return;
		}
		var lustDmg:Number = monster.lustVuln * 0.5 * (player.inte / 5 * spellModBlack() + rand(monster.lib - monster.inte * 2 + monster.cor) / 5);
		if(player.hasPerk(PerkLib.ArcaneLash)) lustDmg *= 1.5;
		if(player.hasStatusEffect(StatusEffects.AlvinaTraining2)) lustDmg *= 1.2;
		if(player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) lustDmg = Math.round(lustDmg * 1.2);
		if(player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) lustDmg = Math.round(lustDmg * 1.0);
			else if (monster.cor >= 50) lustDmg = Math.round(lustDmg * 1.1);
			else if (monster.cor >= 25) lustDmg = Math.round(lustDmg * 1.2);
			else if (monster.cor >= 10) lustDmg = Math.round(lustDmg * 1.3);
			else lustDmg = Math.round(lustDmg * 1.4);
		}
		if(monster.plural) {
			outputText("Arousal breaks in the eyes of your many opponents as pleasure strikes them");
			lustDmg *= 5;
		}
		else outputText("Unable to evade it " + monster.a + monster.short + " is struck squarely by the pleasure wave");
		outputText(" for ");
		//Determine if critical tease!
		var crit:Boolean = false;
		var critChance:int = 5;
		if (player.hasPerk(PerkLib.CriticalPerformance)) {
			if (player.lib <= 100) critChance += player.lib / 5;
			if (player.lib > 100) critChance += 20;
		}
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			lustDmg *= 1.75;
		}
		lustDmg = Math.round(lustDmg);
		monster.teased(lustDmg, false);
		outputText(" damage.");
		if (crit) outputText(" <b>Critical!</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (!monster.hasPerk(PerkLib.Resolute)) monster.createStatusEffect(StatusEffects.Stunned,2,0,0,0);
		if (player.hasPerk(PerkLib.EromancyMaster)) combat.teaseXP(1 + combat.bonusExpAfterSuccesfullTease());
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		doNext(playerMenu);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(monster.lust >= monster.maxLust()) doNext(endLustVictory);
		else enemyAI();
	}

//(50) Arctic Gale - AoE Ice spell
	public function spellArcticGale():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200)) player.HP -= spellCostBlack(200);
		else useMana(200,6);
		player.createStatusEffect(StatusEffects.CooldownSpellArcticGale,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellArcticGale3();
	}
	public function spellArcticGale2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200)) player.HP -= spellCostBlack(200);
		else useMana(200, 6);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellArcticGaleEx,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellArcticGale3(true);
	}
	public function spellArcticGale3(edgy:Boolean = false):void {
		clearOutput();
		outputText("You wave the signs with your hands and unleash an howling blast of cold magic upon " + monster.a + monster.short + ".  \n");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 2;
		if (monster.plural) damage *= 5;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcGlacialMod(damage);
		if (combat.wearingWinterScarf()) damage *= 1.2;
		if (player.armor == armors.BLIZZ_K) damage *= 1.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 1.3;
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) damage = Math.round(damage * 1.0);
			else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
			else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
			else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.iceDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
		}
		else doIceDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}

//(50) Dusk Wave - AoE Darkness spell
	public function spellDuskWave():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200)) player.HP -= spellCostBlack(200);
		else useMana(200,6);
		player.createStatusEffect(StatusEffects.CooldownSpellDuskWave,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellDuskWave3();
	}
	public function spellDuskWave2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(200)) player.HP -= spellCostBlack(200);
		else useMana(200, 6);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellDuskWaveEx,spellBlackCooldown(),0,0,0);
		if (handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellDuskWave3(true);
	}
	public function spellDuskWave3(edgy:Boolean = false):void {
		clearOutput();
		outputText("You wave the signs with your hands and all light fades as you call down to the primordial darkness to gnaw at " + monster.a + monster.short + ".  \n");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 2;
		if (monster.plural) damage *= 5;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcEclypseMod(damage);
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) damage = Math.round(damage * 1.0);
			else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
			else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
			else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.darknessDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			doDarknessDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doDarknessDamage(damage, true, true);
				doDarknessDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doDarknessDamage(damage, true, true);
				doDarknessDamage(damage, true, true);
			}
		}
		else doDarknessDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	
	public function spellBoneSpirit():void {
		clearOutput();
		doNext(combatMenu);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You wrap your soulforce around the bones and shape them into a horrifying bone wraith sending it flying and laughing madly toward " + monster.a + monster.short + ". The ghastly apparition explodes upon contact into a hundred sharp bone shards grievously wounding " + monster.a + monster.short + ". ");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 3;
		if (player.hasPerk(PerkLib.Necromancy)) damage * 1.5;
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 5) {
			var minus1:Number = player.perkv1(PerkLib.PrestigeJobNecromancer);
			player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, minus1);
			damage *= 0.5;
		}
		else player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, 5);
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) >= 50) {
			var plus1:Number = player.perkv1(PerkLib.PrestigeJobNecromancer) * 0.1;
			plus1 = Math.round(plus1 - 0.5);
			damage *= (1 + (0.1*plus1));
		}
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage);
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doTrueDamage(damage, true, true);
				doTrueDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doTrueDamage(damage, true, true);
				doTrueDamage(damage, true, true);
			}
		}
		else doTrueDamage(damage, true, true);
		MagicAddonEffect();
		outputText("\n\n");
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellBoneArmor():void {
		clearOutput();
		doNext(combatMenu);
		var dura:Number = 5;
		outputText("You animate a set of bones to fly around you, deflecting incoming attacks.\n\n");
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 10) {
			var minus2:Number = player.perkv1(PerkLib.PrestigeJobNecromancer);
			player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, minus2);
			dura -= 3;
		}
		else player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, 10);
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) >= 50) {
			var plus2:Number = player.perkv1(PerkLib.PrestigeJobNecromancer) * 0.1;
			plus2 = Math.round(plus2 - 0.5);
			dura += plus2;
		}
		player.createStatusEffect(StatusEffects.BoneArmor,dura,0,0,0);
		player.createStatusEffect(StatusEffects.CooldownSpellBoneArmor,10,0,0,0);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellBoneshatter():void {
		clearOutput();
		doNext(combatMenu);
		var shatterIt:Number = 0.2;
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 1.5;
		if (player.hasPerk(PerkLib.Necromancy)) damage * 1.5;
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) < 5) {
			var minus3:Number = player.perkv1(PerkLib.PrestigeJobNecromancer);
			player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, minus3);
			shatterIt *= 0.5;
			damage *= 0.5;
		}
		if (player.hasPerk(PerkLib.BoneSoul) && player.perkv1(PerkLib.PrestigeJobNecromancer) >= 50) {
			var plus3:Number = player.perkv1(PerkLib.PrestigeJobNecromancer) * 0.1;
			plus3 = Math.round(plus3 - 0.5);
			shatterIt *= (1 + (0.1*plus3));
			damage *= (1 + (0.1*plus3));
		}
		else player.addPerkValue(PerkLib.PrestigeJobNecromancer, 1, 5);
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			doTrueDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doTrueDamage(damage, true, true);
				doTrueDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doTrueDamage(damage, true, true);
				doTrueDamage(damage, true, true);
			}
		}
		else doTrueDamage(damage, true, true);
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage);
		outputText("You channel your powers in " + monster.a + monster.short + " bone structure stressing it and forcing the bones to snap. " + monster.capitalA + monster.short + " cough blood you wreck " + monster.pronoun3 + " from the inside. ");
		doTrueDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (monster.hasStatusEffect(StatusEffects.Boneshatter)) {
			if (monster.statusEffectv1(StatusEffects.Boneshatter) < 0.9) {
				if (monster.statusEffectv1(StatusEffects.Boneshatter) + shatterIt > 0.9) {
					var shatterIt2:Number = (monster.statusEffectv1(StatusEffects.Boneshatter) + shatterIt) - 0.9;
					shatterIt -= shatterIt2;
					monster.addStatusValue(StatusEffects.Boneshatter, 1, shatterIt);
					monster.buff("Boneshatter").addStats({str:-(Math.round(shatterIt * monster.str))}).withText("Boneshatter").combatPermanent();
				}
				else {
					monster.addStatusValue(StatusEffects.Boneshatter, 1, shatterIt);
					monster.buff("Boneshatter").addStats({str:-(Math.round(shatterIt * monster.str))}).withText("Boneshatter").combatPermanent();
				}
			}
		}
		else if (!monster.hasStatusEffect(StatusEffects.Boneshatter)) {
			monster.createStatusEffect(StatusEffects.Boneshatter, shatterIt, 0, 0, 0);
			monster.buff("Boneshatter").addStats({str:-(Math.round(shatterIt * monster.str))}).withText("Boneshatter").combatPermanent();
		}
		player.createStatusEffect(StatusEffects.CooldownSpellBoneshatter,3,0,0,0);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellLifetap():void {
		clearOutput();
		doNext(combatMenu);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var lifetap:Number = 0;
			lifetap += Math.round(player.maxHP() * .25);
			if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) lifetap = Math.round(lifetap * 1.2);
			if (player.hasPerk(PerkLib.CorruptMagic)) {
				if (monster.cor >= 66) lifetap = Math.round(lifetap * 1.0);
				else if (monster.cor >= 50) lifetap = Math.round(lifetap * 1.1);
				else if (monster.cor >= 25) lifetap = Math.round(lifetap * 1.2);
				else if (monster.cor >= 10) lifetap = Math.round(lifetap * 1.3);
				else lifetap = Math.round(lifetap * 1.4);
			}
			outputText("You proceed to cut your hand and draw a small pattern. You feel your magical reservoirs fill back up by a significant amount.");
			HPChange(-lifetap, false);
			EngineCore.ManaChange(lifetap, false);
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	
	public function spellLifeSiphon():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(750)) player.HP -= spellCostBlack(750);
		else useMana(750, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var lifesiphon:Number = 0;
			lifesiphon += player.inte;
			if (player.hasPerk(PerkLib.WisenedHealer)) lifesiphon += player.wis;
			if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) lifesiphon = Math.round(lifesiphon * 1.2);
			if (player.hasPerk(PerkLib.CorruptMagic)) {
				if (player.hasStatusEffect(StatusEffects.DarkRitual)) lifesiphon *= 2;
				if (monster.cor >= 66) lifesiphon = Math.round(lifesiphon * 1.0);
				else if (monster.cor >= 50) lifesiphon = Math.round(lifesiphon * 1.1);
				else if (monster.cor >= 25) lifesiphon = Math.round(lifesiphon * 1.2);
				else if (monster.cor >= 10) lifesiphon = Math.round(lifesiphon * 1.3);
				else lifesiphon = Math.round(lifesiphon * 1.4);
			}
			outputText("You wave a sign linking yourself to " + monster.a + monster.short + " as you begin to funnel its health and vitality to yourself.");
			monster.HP -= lifesiphon;
			if (player.hasStatusEffect(StatusEffects.DarkRitual)) HPChange((player.maxHP() * 0.15), false);
			else HPChange((player.maxHP() * 0.05), false);
			player.createStatusEffect(StatusEffects.LifeSiphon, 15, lifesiphon, 0, 0);
			MagicAddonEffect();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	
	public function spellConsumingDarkness():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(350)) player.HP -= spellCostBlack(350);
		else useMana(350, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellConsumingDarkness, 15, 0, 0, 0);
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var consumingdarkness:Number = scalingBonusIntelligence() * spellModBlack() * 2;
			if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) consumingdarkness = Math.round(consumingdarkness * 1.2);
			if (player.hasPerk(PerkLib.CorruptMagic)) {
				if (monster.cor >= 66) consumingdarkness = Math.round(consumingdarkness * 1.0);
				else if (monster.cor >= 50) consumingdarkness = Math.round(consumingdarkness * 1.1);
				else if (monster.cor >= 25) consumingdarkness = Math.round(consumingdarkness * 1.2);
				else if (monster.cor >= 10) consumingdarkness = Math.round(consumingdarkness * 1.3);
				else consumingdarkness = Math.round(consumingdarkness);
			}
			outputText("You call on the power of primordial darkness, which is all too happy to oblige your request of ripping your foe to shreds. The shadows all around you sprouting countless mouths and claws to do just that. " + monster.capitalA + monster.short + " can only scream in surprise, then in pain, at the sudden assault. ");
			consumingdarkness = Math.round(consumingdarkness * combat.darknessDamageBoostedByDao());
			monster.createStatusEffect(StatusEffects.ConsumingDarkness, 7, consumingdarkness, 0, 0);
			doDarknessDamage(consumingdarkness, true, true);
			MagicAddonEffect();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	
	public function spellCurseOfDesire():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(400)) player.HP -= spellCostBlack(400);
		else useMana(400, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellCurseOfDesire, 15, 0, 0, 0);
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var llr:Number = 0;
			if (monster.lustVuln != 0) {
				if (monster.lustVuln < 0.1) llr = monster.lustVuln;
				else llr = 0.1;
				monster.lustVuln -= llr;
			}
			var lustDmg:Number = monster.lustVuln * (player.inte / 5 * spellModBlack() + rand(monster.lib - monster.inte * 2 + monster.cor) / 5);
			outputText("You moan in pleasure as you curse your target with lewd thoughts. " + monster.capitalA + monster.short + " pants in arousal, unable to stop the encroaching fantasies you forced on " + monster.pronoun2 + " from having their desired effect. ");
			if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) lustDmg = Math.round(lustDmg * 1.2);
			lustDmg = Math.round(lustDmg);
			if (player.hasPerk(PerkLib.CorruptMagic)) {
				if (monster.cor >= 66) lustDmg = Math.round(lustDmg * 1.0);
				else if (monster.cor >= 50) lustDmg = Math.round(lustDmg * 1.1);
				else if (monster.cor >= 25) lustDmg = Math.round(lustDmg * 1.2);
				else if (monster.cor >= 10) lustDmg = Math.round(lustDmg * 1.3);
				else lustDmg = Math.round(lustDmg * 1.4);
			}
			monster.createStatusEffect(StatusEffects.CurseOfDesire, 8, lustDmg, llr, 0);
			if (lustDmg < 1) lustDmg = 1;
			monster.teased(lustDmg, false);
			dynStats("lus", 10);
			MagicAddonEffect();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	
	public function spellCurseOfWeeping():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(300)) player.HP -= spellCostBlack(300);
		else useMana(300, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellCurseOfWeeping, 10, 0, 0, 0);
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			outputText("You cut deep into your arm, drawing plenty of your blood and letting it flow in a large pattern on the ground as you hex your target with a powerful malediction, causing it to bleed from every orifice. " + monster.capitalA + monster.short + " screams in pain, unable to stop the blood flow. ");
			HPChange(-(Math.round(player.maxHP() * .5)), false);
		}
		var CurseOfWeepingMod:Number = scalingBonusIntelligence() * spellModBlack() * 2;
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.0);
			else if (monster.cor >= 50) CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.1);
			else if (monster.cor >= 25) CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.2);
			else if (monster.cor >= 10) CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.3);
			else CurseOfWeepingMod = Math.round(CurseOfWeepingMod * 1.4);
		}
		monster.createStatusEffect(StatusEffects.CurseOfWeeping, 6, CurseOfWeepingMod, 0, 0);
		doDamage(CurseOfWeepingMod, true, true);
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	
	public function spellAegis():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500)) player.HP -= spellCostWhite(500);
		else useMana(500,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You call on divine protection in order to shield yourself against attacks."+(player.shield == ShieldLib.NOTHING ? " On your off-hand manifests a shield made of pure light, which will help deflect blows.":" Your shield begins to glow with white protective light, strengthening it as benevolent powers guide your hands, increasing your ability to block.")+"\n\n");
		var AegisDuration:Number = 6;
		AegisDuration += perkRelatedDurationBoosting();
		var aegismagnitude:Number = 0;
		if (spellModWhite() > 5) aegismagnitude += 5;
		else aegismagnitude += spellModWhite();
		if (player.inte / 50 > 5) aegismagnitude += 5;
		else aegismagnitude += player.inte / 25;
		if (player.hasPerk(PerkLib.DefensiveStaffChanneling)) aegismagnitude *= 1.1;
		if (player.isUsingStaff() && player.isNotHavingShieldCuzPerksNotWorkingOtherwise()) aegismagnitude *= 3;
		player.createStatusEffect(StatusEffects.Aegis,Math.round(aegismagnitude),AegisDuration,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellExorcise():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(400)) player.HP -= spellCostWhite(400);
		else useMana(400,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 4;
		if (player.weaponAttack < 51) damage *= (1 + (player.weaponAttack * 0.03));
        else if (player.weaponAttack >= 51 && player.weaponAttack < 101) damage *= (2.5 + ((player.weaponAttack - 50) * 0.025));
        else if (player.weaponAttack >= 101 && player.weaponAttack < 151) damage *= (3.75 + ((player.weaponAttack - 100) * 0.02));
        else if (player.weaponAttack >= 151 && player.weaponAttack < 201) damage *= (4.75 + ((player.weaponAttack - 150) * 0.015));
        else damage *= (5.5 + ((player.weaponAttack - 200) * 0.01));
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.DivineArmament)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellExorcise,2,0,0,0);
		outputText("Your [weapon] begins to glow as you charge and deliver a mighty strike. As the mystical blow strikes your opponent"+(monster.plural ? "s":"")+", the magic explodes forward from your weapon in the shape of the sigil of the Marethian divine pantheon, damaging your foe"+(monster.plural ? "s":"")+" further and throwing "+monster.pronoun2+" back.");
		doMagicDamage(damage, true, true);
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellDivineShield():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(600)) player.HP -= spellCostWhite(600);
		else useMana(600,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You usher a prayer for protection from the dark spells cast by the heretics and a powerful bubble of raw energy encases you, deflecting most of the magical assaults away.\n\n");
		var DivineShieldDuration:Number = 6;
		DivineShieldDuration += perkRelatedDurationBoosting();
		player.createStatusEffect(StatusEffects.DivineShield,40,DivineShieldDuration,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellThunderstorm():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(1200)) player.HP -= spellCostWhite(1200);
		else useMana(1200,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		var damage:Number = scalingBonusIntelligence() * spellModWhite() * 2;
		if (player.hasPerk(PerkLib.ElectrifiedDesire)) damage *= (1 + (player.lust100 * 0.01));
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.DivineArmament)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage = Math.round(damage * combat.lightningDamageBoostedByDao());
		player.createStatusEffect(StatusEffects.Thunderstorm,damage,30,0,0);
		outputText("You call upon the anger of the gods to smite your foe and they gladly answer with thunder. Lightning begins to strike down upon your opponent"+(monster.plural ? "s":"")+" with perfect precision.");
		doLightingDamage(damage, true, true);
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	
	public function spellTearsOfDenial():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(3000)) player.HP -= spellCostWhite(3000);
		else useMana(3000,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You call on the power of mercy in order to deny defeat. A small aura of magic shields your heart as your spell takes effect, ready to safeguard your victory.\n\n");
		player.createStatusEffect(StatusEffects.TearsOfDenial,1,0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	/*public function spell2IceRain():void {
		if (rand(2) == 0) flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		else flags[kFLAGS.LAST_ATTACK_TYPE] = 3;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(200)) player.HP -= spellCost(200);
		else useMana(200,1);
		if(handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		outputText("You narrow your eyes, focusing on the force of your lust and willpower as you narrow your eyes with deadly intent. A dark cloud coalesces above you, stretching further until there is nothing but an eerie darkness above you. You narrow your gaze at  " + monster.a + monster.short + " as countless razor-like shards of ice rain upon your opponent.\n");
		var damage:Number = scalingBonusIntelligence() * spellMod() * spellModGrey();
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcGlacialMod(damage);
		if (combat.wearingWinterScarf()) damage *= 1.2;
		if (player.armor == armors.BLIZZ_K) damage *= 1.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 1.3;
		damage = Math.round(damage * combat.iceDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bedą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		if (monster.plural) damage *= 5;
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
		}
		else doIceDamage(damage, true, true);
		if (!monster.hasPerk(PerkLib.EnemyGroupType) && !monster.hasPerk(PerkLib.EnemyLargeGroupType) && player.hasPerk(PerkLib.Convergence)) {
			if (player.hasPerk(PerkLib.Omnicaster)) {
				if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
				else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
				else damage *= 0.2;
				damage = Math.round(damage);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
			}
			else doIceDamage(damage, true, true);
			if (player.hasPerk(PerkLib.Omnicaster)) {
				if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
				else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
				else damage *= 0.2;
				damage = Math.round(damage);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
			}
			else doIceDamage(damage, true, true);
		}
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (!monster.hasPerk(PerkLib.EnemyGroupType) && !monster.hasPerk(PerkLib.EnemyLargeGroupType) && player.hasPerk(PerkLib.Convergence)) damage *= 3;
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}*/

//(100) Ice Rain - AoE Ice spell
	public function spellIceRain():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(500)) player.HP -= spellCostBlack(500);
		else useMana(500,6);
		if(handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellIceRain, spellBlackTier2Cooldown(), 0, 0, 0);
		outputText("You narrow your eyes, focusing on the force of your lust as you narrow your eyes with deadly intent. A dark cloud coalesces above you, stretching further until there is nothing but an eerie darkness above you. You narrow your gaze at  " + monster.a + monster.short + " as countless razor-like shards of ice rain upon your opponent.\n");
		var damage:Number = scalingBonusIntelligence() * spellModBlack() * 3 * combat.iceDamageBoostedByDao();
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcGlacialMod(damage);
		if (combat.wearingWinterScarf()) damage *= 1.2;
		if (player.armor == armors.BLIZZ_K) damage *= 1.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 1.3;
		if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.CorruptMagic)) {
			if (monster.cor >= 66) damage = Math.round(damage * 1.0);
			else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
			else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
			else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage);
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bedą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		if (monster.plural) damage *= 5;
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			doIceDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
			}
		}
		else doIceDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	
	public function spellNosferatu():void {
		clearOutput();
		doNext(combatMenu);
		useMana(50, 11);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellNosferatu, 7, 0, 0, 0);
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var nosferatu:Number = 0;
			nosferatu += player.inte;
			nosferatu += scalingBonusIntelligence();
			if (player.hasPerk(PerkLib.WisenedHealer)) nosferatu += scalingBonusWisdom();
			nosferatu = Math.round(nosferatu * healMod() * spellModGrey());
			outputText(" You chant as your shadow suddenly takes on a life of its own, sprouting a multitude of mouths and tentacles which seek and tear into " + monster.a + monster.short + " shadow");
			if (monster.plural) outputText("s");
			outputText(", gorging on its owner’s life force to replenish your own. Soon enough the spell is over and your shadow returns to you, leaving you better for the wear. <b>(<font color=\"#800000\">" + nosferatu + "</font>)</b>");
			monster.HP -= nosferatu;
			HPChange(nosferatu,false);
			MagicAddonEffect();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}

	//(100) Polar Midnight - AoE Ice spell
	public function spellPolarMidnight():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		if (player.statusEffectv1(StatusEffects.ChanneledAttack) == 1) {
			player.removeStatusEffect(StatusEffects.ChanneledAttack);
			player.removeStatusEffect(StatusEffects.ChanneledAttackType);
			if (player.hasPerk(PerkLib.GlacialStormSu) && player.hasStatusEffect(StatusEffects.CounterGlacialStorm)) player.addStatusValue(StatusEffects.CounterGlacialStorm, 3, -1);
			outputText("You drain the heat out of the air around your foe, causing its temperature to plummet far below its freezing point in an instant, effectively flash freezing your enemy for \n");
			var damage:Number = scalingBonusIntelligence() * spellModBlack() * 24 * combat.iceDamageBoostedByDao();
			//Determine if critical hit!
			var crit:Boolean = false;
			var critChance:int = 5;
			critChance += combatMagicalCritical();
			if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
			if (rand(100) < critChance) {
				crit = true;
				damage *= 1.75;
			}
			//High damage to goes.
			damage = calcGlacialMod(damage);
			if (combat.wearingWinterScarf()) damage *= 1.2;
			if (player.armor == armors.BLIZZ_K) damage *= 1.5;
			if (player.headJewelry == headjewelries.SNOWFH) damage *= 1.3;
			if (player.hasPerk(PerkLib.HexKnowledge) && monster.cor < 34) damage = Math.round(damage * 1.2);
			if (player.hasPerk(PerkLib.CorruptMagic)) {
				if (monster.cor >= 66) damage = Math.round(damage * 1.0);
				else if (monster.cor >= 50) damage = Math.round(damage * 1.1);
				else if (monster.cor >= 25) damage = Math.round(damage * 1.2);
				else if (monster.cor >= 10) damage = Math.round(damage * 1.3);
				else damage = Math.round(damage * 1.4);
			}
			damage = Math.round(damage);
			//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bedą dostawać bonusowe obrażenia
			//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
			if (monster.plural) damage *= 5;
			if (player.hasPerk(PerkLib.Omnicaster)) {
				if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
				else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
				else damage *= 0.2;
				damage = Math.round(damage);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				doIceDamage(damage, true, true);
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
					doIceDamage(damage, true, true);
					doIceDamage(damage, true, true);
				}
			}
			else doIceDamage(damage, true, true);
			outputText(" damage!");
			//Using fire attacks on the goo]
			//if(monster.short == "goo-girl") {
			//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
			//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
			//}
			if (crit) outputText(" <b>*Critical Hit!*</b>");
			MagicAddonEffect();
			outputText("\n\n" + monster.a + monster.short + " is encased in a thick layer of ice.\n\n");
			if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
			monster.createStatusEffect(StatusEffects.FrozenSolid,5,0,0,0);
			checkAchievementDamage(damage);
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			combat.heroBaneProc(damage);
			statScreenRefresh();
			if(monster.HP <= monster.minHP()) doNext(endHpVictory);
			else enemyAI();
		}
		else {
			doNext(combatMenu);
			if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostBlack(1250)) player.HP -= spellCostBlack(1250);
			else useMana(1250,6);
			if(handleShell()){return;}
			//if (monster is Doppleganger)
			//{
			//(monster as Doppleganger).handleSpellResistance("whitefire");
			//flags[kFLAGS.SPELLS_CAST]++;
			//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			//spellPerkUnlock();
			//return;
			//}
			if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
				if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
				if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
				enemyAI();
				return;
			}
			clearOutput();
			outputText("You begin to channel magic, the air temperature dropping around you.");
			player.createStatusEffect(StatusEffects.ChanneledAttack, 1, 0, 0, 0);
			player.createStatusEffect(StatusEffects.ChanneledAttackType, 5, 0, 0, 0);
			player.createStatusEffect(StatusEffects.CooldownSpellPolarMidnight, 12, 0, 0, 0);
			if (player.hasPerk(PerkLib.GlacialStormSu)) player.addStatusValue(StatusEffects.CounterGlacialStorm, 3, 1);
			outputText("\n\n");
			enemyAI();
		}
	}
	/*public function spell2FireStorm():void {
		if (rand(2) == 0) flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		else flags[kFLAGS.LAST_ATTACK_TYPE] = 3;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(200)) player.HP -= spellCost(200);
		else useMana(200,1);
		if(handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		outputText("You narrow your eyes, focusing your own lust and willpower with a deadly intent. You cojure a small vortex of embers that expand into a vicious gout of flames.  With a single thought, you send a pillar of flames at " + monster.a + monster.short + ". You intend to leave nothing but ashes!\n");
		var damage:Number = scalingBonusIntelligence() * spellMod() * spellModGrey();
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcInfernoMod(damage);
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (monster.short == "goo-girl") damage = Math.round(damage * 1.5);
		if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2);
		if (monster.plural) damage *= 5;
		damage = Math.round(damage * combat.fireDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		if (!monster.hasPerk(PerkLib.EnemyGroupType) && !monster.hasPerk(PerkLib.EnemyLargeGroupType) && player.hasPerk(PerkLib.Convergence)) {
			if (player.hasPerk(PerkLib.Omnicaster)) {
				if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
				else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
				else damage *= 0.2;
				damage = Math.round(damage);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
				}
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
				}
			}
			else doFireDamage(damage, true, true);
			if (player.hasPerk(PerkLib.Omnicaster)) {
				if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
				else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
				else damage *= 0.2;
				damage = Math.round(damage);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
				}
				if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
				}
			}
			else doFireDamage(damage, true, true);
		}
		outputText(" damage.");
		//Using fire attacks on the goo]
		if(monster.short == "goo-girl") {
			outputText("  Your fire storm lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
			if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (!monster.hasPerk(PerkLib.EnemyGroupType) && !monster.hasPerk(PerkLib.EnemyLargeGroupType) && player.hasPerk(PerkLib.Convergence)) damage *= 3;
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}*/
	
	public function spellManaShield(silent:Boolean = false):void {
		if (silent) {
			if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
			player.createStatusEffect(StatusEffects.ManaShield,0,0,0,0);
			statScreenRefresh();
			return;
		}
		clearOutput();
		outputText("Deciding you need additional protection during current fight you spend a moment to concentrate and form a barrier made of mana around you.  It will block attacks as long as you have enough mana to sustain it.\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		player.createStatusEffect(StatusEffects.ManaShield,0,0,0,0);
		enemyAI();
	}

	public function DeactivateManaShield():void {
		clearOutput();
		outputText("Deciding you no longer need to maintain your mana shield, you concentrate on deactivating it.\n\n");
		player.removeStatusEffect(StatusEffects.ManaShield);
		enemyAI();
	}
	
	public function spellClearMind():void {
		clearOutput();
		doNext(combatMenu);
		useMana(100, 9);
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			outputText("As you incant the spell, you draw a small knife and cut your hand as the incantation ends, the jolt of pain clearing your mind and snapping you out of some of your lust.");
			HPChange(-(player.maxHP() * 0.01), false);
			if (player.hasStatusEffect(StatusEffects.IsabellaStunned)) player.removeStatusEffect(StatusEffects.IsabellaStunned);
			if (player.hasStatusEffect(StatusEffects.Stunned)) player.removeStatusEffect(StatusEffects.Stunned);
			if (player.hasStatusEffect(StatusEffects.Whispered)) player.removeStatusEffect(StatusEffects.Whispered);
			if (player.hasStatusEffect(StatusEffects.Confusion)) player.removeStatusEffect(StatusEffects.Confusion);
			if (player.hasStatusEffect(StatusEffects.Fear)) player.removeStatusEffect(StatusEffects.Fear);
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.HP <= player.minHP()) doNext(endHpLoss);
		else enemyAI();
	}/*
	
	public function spellNosferatu():void {
		clearOutput();
		doNext(combatMenu);
		useMana(50, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You focus on your magic, trying to draw on it without enhancing your own arousal.\n");
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText("An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			var nosferatu:Number = 0;
			nosferatu += player.inte;
			nosferatu += scalingBonusIntelligence();
			if (player.hasPerk(PerkLib.WisenedHealer)) nosferatu += scalingBonusWisdom();
			nosferatu = Math.round(nosferatu * healMod() * spellModGrey());
			outputText(" You chant as your shadow suddenly takes on a life of its own, sprouting a multitude of mouths and tentacles which seek and tear into " + monster.a + monster.short + " shadow");
			if (monster.plural) outputText("s");
			outputText(", gorging on its owner’s life force to replenish your own. Soon enough the spell is over and your shadow returns to you, leaving you better for the wear. <b>(<font color=\"#800000\">" + nosferatu + "</font>)</b>");
			monster.HP -= nosferatu;
			HPChange(nosferatu,false);
			MagicAddonEffect();
		}
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}*/
	
//(35) Energy Drain
	public function spellEnergyDrain():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(350)) player.HP -= spellCost(350);
		else useMana(350, 1);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText(" An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			outputText("You point at "+monster.a+monster.short+" and with a sharp pulling gesture you rip out some of their vigor for your own use. They won’t be hitting at full strength for a while.");
			monster.createStatusEffect(StatusEffects.EnergyDrain, 7, 0, 0, 0);
			var energydrain:Number = monster.maxMana() * 0.2;
			if (energydrain > spellCost(1400)) energydrain = spellCost(1400);
			EngineCore.ManaChange(Math.round(energydrain), false);
		}
		outputText("\n\n");
		player.createStatusEffect(StatusEffects.CooldownSpellEnergyDrain,7,0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}	
	
//(35) Restore
	public function spellRestore():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(350)) player.HP -= spellCost(80);
		else useMana(80, 9);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		//30% backfire!
		var backfire:int = 30;
		if (player.hasStatusEffect(StatusEffects.AlvinaTraining)) backfire -= 10;
		if (player.hasPerk(PerkLib.FocusedMind)) backfire -= 10;
		backfire -= (player.inte * 0.15);
		if (backfire < 5 && player.hasPerk(PerkLib.FocusedMind)) backfire = 5;
		else if (backfire < 15) backfire = 15;
		if(rand(100) < backfire) {
			outputText(" An errant sexual thought crosses your mind, and you lose control of the spell!  Your ");
			if(player.gender == 0) outputText(assholeDescript() + " tingles with a desire to be filled as your libido spins out of control.");
			if(player.gender == 1) {
				if(player.cockTotal() == 1) outputText(player.cockDescript(0) + " twitches obscenely and drips with pre-cum as your libido spins out of control.");
				else outputText(player.multiCockDescriptLight() + " twitch obscenely and drip with pre-cum as your libido spins out of control.");
			}
			if(player.gender == 2) outputText(vaginaDescript(0) + " becomes puffy, hot, and ready to be touched as the magic diverts into it.");
			if(player.gender == 3) outputText(vaginaDescript(0) + " and [cocks] overfill with blood, becoming puffy and incredibly sensitive as the magic focuses on them.");
			dynStats("lib", .25, "lus", 15);
		}
		else {
			if (player.hasStatusEffect(StatusEffects.PlayerRegenerate)) player.addStatusValue(StatusEffects.PlayerRegenerate,1,7);
			else player.createStatusEffect(StatusEffects.PlayerRegenerate,7,0,0,0);
			outputText(" As you incant the spell, your wounds begins to close as if they never existed and you feel rejuvenated ready from battle! ");
			spellHealEffect();
		}
		outputText("\n\n");
		player.createStatusEffect(StatusEffects.CooldownSpellRestore,8,0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}	

//(35) Balance of Life
	public function spellBalanceOfLife():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(500)) player.HP -= spellCost(500);
		else useMana(500,1);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		player.createStatusEffect(StatusEffects.CooldownSpellBalanceOfLife,8,0,0,0);
		outputText("A red aura envelop you as you begin converting some of your destructive magic to healing.\n\n");
		var durationBalanceOfLife:Number = 4;
		if (player.hasPerk(PerkLib.DefensiveStaffChanneling)) durationBalanceOfLife *= 1.1;
		player.createStatusEffect(StatusEffects.BalanceOfLife,Math.round(durationBalanceOfLife),0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}

//(100) Fire Storm - AoE Fire spell
	public function spellFireStorm():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500)) player.HP -= spellCostWhite(500);
		else useMana(500,5);
		if(handleShell()){return;}
		//if (monster is Doppleganger)
		//{
		//(monster as Doppleganger).handleSpellResistance("whitefire");
		//flags[kFLAGS.SPELLS_CAST]++;
		//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		//spellPerkUnlock();
		//return;
		//}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		player.createStatusEffect(StatusEffects.CooldownSpellFireStorm, spellWhiteTier2Cooldown(), 0, 0, 0);
		outputText("You narrow your eyes, focusing your own willpower with a deadly intent. You cojure a small vortex of embers that expand into a vicious gout of flames.  With a single thought, you send a pillar of flames at " + monster.a + monster.short + ". You intend to leave nothing but ashes!\n");
		var damage:Number = scalingBonusIntelligence() * spellModWhite() * 3 * combat.fireDamageBoostedByDao();
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcInfernoMod(damage);
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (monster.short == "goo-girl") damage = Math.round(damage * 1.5);
		if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		if (monster.plural) damage *= 5;
		damage = Math.round(damage);
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		if(monster.short == "goo-girl") {
			outputText("  Your fire storm lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
			if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}

//(100) Meteor Shower - AoE Fire spell
	public function spellMeteorShower():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		if (player.statusEffectv1(StatusEffects.ChanneledAttack) == 1) {
			player.removeStatusEffect(StatusEffects.ChanneledAttack);
			player.removeStatusEffect(StatusEffects.ChanneledAttackType);
			if (player.hasPerk(PerkLib.RagingInfernoSu) && player.hasStatusEffect(StatusEffects.CounterRagingInferno)) player.addStatusValue(StatusEffects.CounterRagingInferno, 3, -1);
			outputText("You call out to the celestial vault, knocking some rocks out of orbit and into a crash course towards your opponents.\n\n");
			var meteor:Number = 11;
			while (meteor-->0){
				var damage:Number = scalingBonusIntelligence() * spellModWhite() * 3 * combat.fireDamageBoostedByDao();
				//Determine if critical hit!
				//High damage to goes.
				damage = calcInfernoMod(damage);
				if (monster.short == "goo-girl") damage = Math.round(damage * 1.5);
				if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2);
				if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
				if (player.hasPerk(PerkLib.PureMagic)) {
					if (monster.cor < 33) damage = Math.round(damage * 1.0);
					else if (monster.cor < 50) damage = Math.round(damage * 1.1);
					else if (monster.cor < 75) damage = Math.round(damage * 1.2);
					else if (monster.cor < 90) damage = Math.round(damage * 1.3);
					else damage = Math.round(damage * 1.4);
				}
				if (monster.plural) damage *= 5;
				damage = Math.round(damage);
				var crit:Boolean = false;
				var critChance:int = 5;
				critChance += combatMagicalCritical();
				if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
				if (rand(100) < critChance) {
					crit = true;
					damage *= 1.75;
				}
				if (player.hasPerk(PerkLib.Omnicaster)) {
					if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
					else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
					else damage *= 0.2;
					damage = Math.round(damage);
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
					doFireDamage(damage, true, true);
					if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
						doFireDamage(damage, true, true);
						doFireDamage(damage, true, true);
					}
					if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
						doFireDamage(damage, true, true);
						doFireDamage(damage, true, true);
					}
				}
				else doFireDamage(damage, true, true);
			}
			outputText(" damage!");
			//Using fire attacks on the goo]
			if(monster.short == "goo-girl") {
				outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
				if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
			}
			if (crit) outputText(" <b>*Critical Hit!*</b>");
			outputText(" " + monster.capitalA + monster.short + " reels from the impact, trying to recover from this devastating assault as a meteor crash in the area.\n\n");
			MagicAddonEffect();
			if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
			damage *= 10;
			monster.createStatusEffect(StatusEffects.Stunned,1,0,0,0);
			checkAchievementDamage(damage);
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			combat.heroBaneProc(damage);
			statScreenRefresh();
			if(monster.HP <= monster.minHP()) doNext(endHpVictory);
			else enemyAI();
		}
		else {
			doNext(combatMenu);
			if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(1250)) player.HP -= spellCostWhite(1250);
			else useMana(1250,5);
			if(handleShell()){return;}
			//if (monster is Doppleganger)
			//{
			//(monster as Doppleganger).handleSpellResistance("whitefire");
			//flags[kFLAGS.SPELLS_CAST]++;
			//if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			//spellPerkUnlock();
			//return;
			//}
			if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
				if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
				if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
				enemyAI();
				return;
			}
			clearOutput();
			outputText("You begin to channel magic, the sky reddening above you.");
			player.createStatusEffect(StatusEffects.ChanneledAttack, 1, 0, 0, 0);
			player.createStatusEffect(StatusEffects.ChanneledAttackType, 6, 0, 0, 0);
			player.createStatusEffect(StatusEffects.CooldownSpellMeteorShower, 12, 0, 0, 0);
			if (player.hasPerk(PerkLib.RagingInfernoSu)) player.addStatusValue(StatusEffects.CounterRagingInferno, 3, 1);
			outputText("\n\n");
			enemyAI();
		}
	}

	/**
	 * Generates from (x1,x2,x3,y1,y2) log-scale parameters (a,b,c) that will return:
	 * y1= 10 at x1=  10
	 * y2= 55 at x2= 100
	 * y3=100 at x3=1000
	 */
	private static const ChargeWeaponABC:Object = FnHelpers.FN.buildLogScaleABC(10,100,1000,10,100);
//(15) Charge Weapon – boosts your weapon attack value by 5 + (player.inte/10) * SpellMod till the end of combat.
	public function spellChargeWeapon(silent:Boolean = false):void {
		var ChargeWeaponBoostCap:Number = 4;
		var ChargeWeaponBoost:Number = 5;
		ChargeWeaponBoostCap *= ChargeWeaponBoost;
		if (player.hasPerk(PerkLib.DivineArmament)) {
			ChargeWeaponBoostCap *= 2;
			ChargeWeaponBoost *= 2;
		}
		//ChargeWeaponBoost += Math.round(player.intStat.max * 0.1); - może tylko jak bedzie mieć perk z prestige job: magus/warock/inny związany z spells
		if (player.hasPerk(PerkLib.JobEnchanter)) ChargeWeaponBoost *= 1.2;
		ChargeWeaponBoost *= spellModWhite();
		//ChargeWeaponBoost = FnHelpers.FN.logScale(ChargeWeaponBoost,ChargeWeaponABC,10);
		if (ChargeWeaponBoost > ChargeWeaponBoostCap) ChargeWeaponBoost = ChargeWeaponBoostCap;
		ChargeWeaponBoost *= spellChargeWeaponWeaponSize();
		ChargeWeaponBoost = Math.round(ChargeWeaponBoost);
		var ChargeWeaponDuration:Number = 5;
		ChargeWeaponDuration += perkRelatedDurationBoosting();
		if (silent) {
			player.createStatusEffect(StatusEffects.ChargeWeapon,ChargeWeaponBoost,ChargeWeaponDuration,0,0);
			statScreenRefresh();
			return;
		}

		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < (60 * spellChargeWeaponCostMultiplier())) player.HP -= (60 * spellChargeWeaponCostMultiplier());
		else useMana((60 * spellChargeWeaponCostMultiplier()), 5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		outputText("You utter words of power, summoning an electrical charge around your [weapon].  It crackles loudly, ensuring you'll do more damage with it for the rest of the fight.\n\n");
		player.createStatusEffect(StatusEffects.ChargeWeapon, ChargeWeaponBoost, ChargeWeaponDuration, 0, 0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	public function spellChargeWeaponWeaponSize():Number {
		var ab12:Number = 1;
		if (player.weaponSpecials("") || player.weaponSpecials("Dual")) ab12 *= 2;
		if (player.weaponSpecials("Hybrid")) ab12 *= 2.5;
		if (player.weaponSpecials("Large") || player.weaponSpecials("Dual Large")) ab12 *= 3;
		if (player.weaponSpecials("Massive")) ab12 *= 4;
		return ab12;
	}
	public function spellChargeWeaponWeaponSizeManaCost():Number {
		var ba21:Number = 1;
		if (player.weaponSpecials("") || player.weaponSpecials("Dual Small")) ba21 *= 2;
		if (player.weaponSpecials("Hybrid")) ba21 *= 3;
		if (player.weaponSpecials("Large") || player.weaponSpecials("Dual")) ba21 *= 4;
		if (player.weaponSpecials("Massive") || player.weaponSpecials("Dual Large")) ba21 *= 8;
		return ba21;
	}

	/**
	 * Generates from (x1,x2,x3,y1,y2) log-scale parameters (a,b,c) that will return:
	 * y1= 10 at x1=  10
	 * y2= 55 at x2= 100
	 * y3=100 at x3=1000
	 */
	private static const ChargeArmorABC:Object = FnHelpers.FN.buildLogScaleABC(10,100,1000,10,100);
//(35) Charge Armor – boosts your armor value by 5 + (player.inte/10) * SpellMod till the end of combat.
	public function spellChargeArmor(silent:Boolean = false):void {
		var ChargeArmorBoostCap:Number = 4;
		var ChargeArmorBoost:Number = 5;
		ChargeArmorBoostCap *= ChargeArmorBoost;
		if (player.hasPerk(PerkLib.DivineArmament)) {
			ChargeArmorBoostCap *= 2;
			ChargeArmorBoost *= 2;
		}
		//ChargeArmorBoost += player.inte / 10;player.inte * 0.1 - może tylko jak bedzie mieć perk z prestige job: magus/warock/inny związany z spells
		if (player.hasPerk(PerkLib.JobEnchanter)) ChargeArmorBoost *= 1.2;
		ChargeArmorBoost *= spellModWhite();
		//ChargeArmorBoost = FnHelpers.FN.logScale(ChargeArmorBoost,ChargeArmorABC,10);
		if (ChargeArmorBoost > ChargeArmorBoostCap) ChargeArmorBoost = ChargeArmorBoostCap;
		ChargeArmorBoost *= spellChargeArmorType();
		ChargeArmorBoost = Math.round(ChargeArmorBoost);
		var ChargeArmorDuration:Number = 5;
		ChargeArmorDuration += perkRelatedDurationBoosting();
		if (silent) {
			player.createStatusEffect(StatusEffects.ChargeArmor,ChargeArmorBoost,ChargeArmorDuration,0,0);
			statScreenRefresh();
			return;
		}

		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < (40 * spellChargeArmorCostMultiplier())) player.HP -= (40 * spellChargeArmorCostMultiplier());
		else useMana((40 * spellChargeArmorCostMultiplier()), 5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		outputText("You utter words of power, summoning an electrical charge around your");
		if (player.isNaked() && player.haveNaturalArmor() && player.hasPerk(PerkLib.ImprovingNaturesBlueprintsNaturalArmor)) outputText(" natural armor.");
		else outputText(" [armor].");
		outputText("  It crackles loudly, ensuring you'll have more protection for the rest of the fight.\n\n");
		player.createStatusEffect(StatusEffects.ChargeArmor, ChargeArmorBoost, ChargeArmorDuration, 0, 0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}
	public function spellChargeArmorType():Number {
		var a12b:Number = 1;
		if (player.armorPerk == "Medium") a12b *= 2;
		if (player.armorPerk == "Heavy") a12b *= 3;
		if (player.armorPerk == "Light Ayo") a12b *= 4;
		if (player.armorPerk == "Heavy Ayo") a12b *= 5;
		if (player.armorPerk == "Ultra Heavy Ayo") a12b *= 7.5;
		return a12b;
	}
	
	public function spellHeal():void {
		clearOutput();
		doNext(combatMenu);
		useMana(30, 10);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		outputText("You chant a magical song of healing and recovery and your wounds start knitting themselves shut in response. ");
		spellHealEffect();
		outputText("\n\n");
		player.createStatusEffect(StatusEffects.CooldownSpellHeal,6,0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		if(player.lust >= player.maxLust()) doNext(endLustLoss);
		else enemyAI();
	}
	public function spellHealEffect():void {
		var heal:Number = 0;
		heal += scalingBonusIntelligence();
		if (player.hasPerk(PerkLib.WisenedHealer)) heal += scalingBonusWisdom();
		heal *= healModWhite();
		if (player.armorName == "skimpy nurse's outfit") heal *= 1.2;
		if (player.weaponName == "unicorn staff") heal *= 1.5;
		if (player.hasPerk(PerkLib.CloseToDeath) && player.HP < (player.maxHP() * 0.25)) {
			if (player.hasPerk(PerkLib.CheatDeath) && player.HP < (player.maxHP() * 0.1)) heal *= 2.5;
			else heal *= 1.5;
		}
		//Determine if critical heal!
		var crit:Boolean = false;
		var critHeal:int = 5;
		critHeal += combatMagicalCritical();
		if (rand(100) < critHeal) {
			crit = true;
			heal *= 1.75;
		}
		heal = Math.round(heal);
		outputText("<b>(<font color=\"#008000\">+" + heal + "</font>)</b>.");
		if (crit) outputText(" <b>*Critical Heal!*</b>");
		HPChange(heal,false);
	}
//(20) Blind – reduces your opponent's accuracy, giving an additional 50% miss chance to physical attacks.
	public function spellBlind():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(30)) player.HP -= spellCostWhite(30);
		else useMana(30,5);
		var successrate:int = 60;
		successrate -= (player.inte * 0.4);
		if (successrate > 20) successrate = 20;
		if (rand(100) > successrate) {
			if (monster.hasStatusEffect(StatusEffects.Shell)) {
				outputText("As soon as your magic touches the multicolored shell around " + monster.a + monster.short + ", it sizzles and fades to nothing.  Whatever that thing is, it completely blocks your magic!\n\n");
				flags[kFLAGS.SPELLS_CAST]++;
				if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
				spellPerkUnlock();
				enemyAI();
				return;
			}
			if (monster is JeanClaude)
			{
				outputText("Jean-Claude howls, reeling backwards before turning back to you, rage clenching his dragon-like face and enflaming his eyes. Your spell seemed to cause him physical pain, but did nothing to blind his lidless sight.");

				outputText("\n\n“<i>You think your hedge magic will work on me, intrus?</i>” he snarls. “<i>Here- let me show you how it’s really done.</i>” The light of anger in his eyes intensifies, burning a retina-frying white as it demands you stare into it...");

				if (rand(player.spe) >= 50 || rand(player.inte) >= 50)
				{
					outputText("\n\nThe light sears into your eyes, but with the discipline of conscious effort you escape the hypnotic pull before it can mesmerize you, before Jean-Claude can blind you.");

					outputText("\n\n“<i>You fight dirty,</i>” the monster snaps. He sounds genuinely outraged. “<i>I was told the interloper was a dangerous warrior, not a little [boy] who accepts duels of honour and then throws sand into his opponent’s eyes. Look into my eyes, little [boy]. Fair is fair.</i>”");

					monster.HP -= int(10+(player.inte/3 + rand(player.inte/2)) * spellModWhite());
				}
				else
				{
					outputText("\n\nThe light sears into your eyes and mind as you stare into it. It’s so powerful, so infinite, so exquisitely painful that you wonder why you’d ever want to look at anything else, at anything at- with a mighty effort, you tear yourself away from it, gasping. All you can see is the afterimages, blaring white and yellow across your vision. You swipe around you blindly as you hear Jean-Claude bark with laughter, trying to keep the monster at arm’s length.");

					outputText("\n\n“<i>The taste of your own medicine, it is not so nice, eh? I will show you much nicer things in there in time intrus, don’t worry. Once you have learnt your place.</i>”");

					if (!player.hasPerk(PerkLib.BlindImmunity)) player.createStatusEffect(StatusEffects.Blind, 2 + player.inte / 20, 0, 0, 0);
				}
				if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
					if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
					if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
					enemyAI();
					return;
				}
				flags[kFLAGS.SPELLS_CAST]++;
				if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
				spellPerkUnlock();
				if(monster.HP <= monster.minHP()) doNext(endHpVictory);
				else enemyAI();
				return;
			}
			else if (monster is Lethice && (monster as Lethice).fightPhase == 2)
			{
				outputText("You hold your [weapon] aloft and thrust your will forward, causing it to erupt in a blinding flash of light. The demons of the court scream and recoil from the radiant burst, clutching at their eyes and trampling over each other to get back.");

				outputText("\n\n<i>“Damn you, fight!”</i> Lethice screams, grabbing her whip and lashing out at the back-most demons, driving them forward -- and causing the middle bunch to be crushed between competing forces of retreating demons! <i>“Fight, or you'll be in the submission tanks for the rest of your miserable lives!”</i>");

				monster.createStatusEffect(StatusEffects.Blind, 5 * spellModWhite(), 0, 0, 0);
				outputText("\n\n");
				flags[kFLAGS.SPELLS_CAST]++;
				if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
				spellPerkUnlock();
				statScreenRefresh();
				enemyAI();
				return;
			}
			clearOutput();
			outputText("You glare at " + monster.a + monster.short + " and point at " + monster.pronoun2 + ".  A bright flash erupts before " + monster.pronoun2 + "!\n");
			if (monster is LivingStatue)
			{
				// noop
			}
			else if(rand(3) != 0) {
				outputText(" <b>" + monster.capitalA + monster.short + " ");
				if(monster.plural && monster.short != "imp horde") outputText("are blinded!</b>");
				else outputText("is blinded!</b>");
				monster.createStatusEffect(StatusEffects.Blind, 2 + player.inte / 20,0,0,0);
				MagicAddonEffect();
                if(monster is Diva){(monster as Diva).handlePlayerSpell("blind");}
				if(monster.short == "Isabella")
					if (SceneLib.isabellaFollowerScene.isabellaAccent()) outputText("\n\n\"<i>Nein! I cannot see!</i>\" cries Isabella.");
					else outputText("\n\n\"<i>No! I cannot see!</i>\" cries Isabella.");
				if(monster.short == "Kiha") outputText("\n\n\"<i>You think blindness will slow me down?  Attacks like that are only effective on those who don't know how to see with their other senses!</i>\" Kiha cries defiantly.");
				if(monster.short == "plain girl") {
					outputText("  Remarkably, it seems as if your spell has had no effect on her, and you nearly get clipped by a roundhouse as you stand, confused. The girl flashes a radiant smile at you, and the battle continues.");
					monster.removeStatusEffect(StatusEffects.Blind);
				}
			}
		}
		else outputText(monster.capitalA + monster.short + " blinked!");
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		statScreenRefresh();
		enemyAI();
	}
	//(30) Whitefire – burns the enemy for 10 + int/3 + rand(int/2) * spellMod.
	public function spellWhitefire():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40)) player.HP -= spellCostWhite(40);
		else useMana(40, 5);
		player.createStatusEffect(StatusEffects.CooldownSpellWhitefire,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if (monster is Doppleganger)
		{
			(monster as Doppleganger).handleSpellResistance("whitefire");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			return;
		}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		else if (monster is Lethice && (monster as Lethice).fightPhase == 2) spellWhitefire3();
		else spellWhitefire4();
		if (monster.HP <= monster.minHP())
		{
			doNext(endHpVictory);
		}
		else
		{
			if (monster is Lethice && (monster as Lethice).fightPhase == 3)
			{
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	public function spellWhitefire2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40)) player.HP -= spellCostWhite(40);
		else useMana(40, 5);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellWhitefireEx,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if (monster is Doppleganger)
		{
			(monster as Doppleganger).handleSpellResistance("whitefire");
			flags[kFLAGS.SPELLS_CAST]++;
			if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
			spellPerkUnlock();
			return;
		}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		else if (monster is Lethice && (monster as Lethice).fightPhase == 2) spellWhitefire3(true);
		else spellWhitefire4(true);
		if (monster.HP <= monster.minHP())
		{
			doNext(endHpVictory);
		}
		else
		{
			if (monster is Lethice && (monster as Lethice).fightPhase == 3)
			{
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	public function spellWhitefire3(edgy:Boolean = false):void {
		//Attack gains burn DoT for 2-3 turns.
		var damage:Number = 0;
		outputText("You let loose a roiling cone of flames that wash over the horde of demons like a tidal wave, scorching at their tainted flesh with vigor unlike anything you've seen before. Screams of terror as much as, maybe more than, pain fill the air as the mass of corrupted bodies try desperately to escape from you! Though more demons pile in over the affected front ranks, you've certainly put the fear of your magic into them!");
		monster.createStatusEffect(StatusEffects.OnFire, 2 + rand(2), 0, 0, 0);
		damage = scalingBonusIntelligence() * spellModWhite() * 2 * combat.fireDamageBoostedByDao();
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage *= 1.75;
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		if (monster.short == "Holli" && !monster.hasStatusEffect(StatusEffects.HolliBurning)) (monster as Holli).lightHolliOnFireMagically();
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}
	public function spellWhitefire4(edgy:Boolean = false):void {
		outputText("You narrow your eyes, focusing your mind with deadly intent.  You snap your fingers and " + monster.a + monster.short + " is enveloped in a flash of white flames!\n");
		if(monster is Diva){(monster as Diva).handlePlayerSpell("whitefire");}
		var damage:Number = scalingBonusIntelligence() * spellModWhite() * 2;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcInfernoMod(damage);
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (monster.short == "goo-girl") damage = Math.round(damage * 1.5);
		if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.fireDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		outputText(" damage.");
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		//Using fire attacks on the goo]
		if(monster.short == "goo-girl") {
			outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
			if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		}
		if(monster.short == "Holli" && !monster.hasStatusEffect(StatusEffects.HolliBurning)) (monster as Holli).lightHolliOnFireMagically();
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}

//(45) Lightning Bolt - base lighting spell
	public function spellLightningBolt():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40)) player.HP -= spellCostWhite(40);
		else useMana(40, 5);
		player.createStatusEffect(StatusEffects.CooldownSpellLightningBolt,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellLightningBolt3();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellLightningBolt2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(40)) player.HP -= spellCostWhite(40);
		else useMana(40, 5);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellLightningBoltEx,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		spellLightningBolt3(true);
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}
	public function spellLightningBolt3(edgy:Boolean = false):void {
		outputText("You charge out energy in your hand and fire it out in the form of a powerful bolt of lightning at " + monster.a + monster.short + " !\n");
		var damage:Number = scalingBonusIntelligence() * spellModWhite() * 2;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcVoltageMod(damage);
		if (player.hasPerk(PerkLib.ElectrifiedDesire)) damage *= (1 + (player.lust100 * 0.01));
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.lightningDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doLightingDamage(damage, true, true);
				doLightingDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doLightingDamage(damage, true, true);
				doLightingDamage(damage, true, true);
			}
		}
		else doLightingDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}
	
	//(50) Pyre Burst – aoe fire spell
	public function spellPyreBurst():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200)) player.HP -= spellCostWhite(200);
		else useMana(200, 5);
		player.createStatusEffect(StatusEffects.CooldownSpellPyreBurst,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		else if (monster is Lethice && (monster as Lethice).fightPhase == 2) spellPyreBurst3(true);
		else spellPyreBurst4(true);
		if (monster.HP <= monster.minHP())
		{
			doNext(endHpVictory);
		}
		else
		{
			if (monster is Lethice && (monster as Lethice).fightPhase == 3)
			{
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	public function spellPyreBurst2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200)) player.HP -= spellCostWhite(200);
		else useMana(200,5);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellPyreBurstEx,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		else if (monster is Lethice && (monster as Lethice).fightPhase == 2) spellPyreBurst3(true);
		else spellPyreBurst4(true);
		if (monster.HP <= monster.minHP())
		{
			doNext(endHpVictory);
		}
		else
		{
			if (monster is Lethice && (monster as Lethice).fightPhase == 3)
			{
				outputText("\n\n<i>“Ouch. Such arcane skills for one so uncouth,”</i> Lethice growls. With a snap of her fingers, a pearlescent dome surrounds her. <i>“How will you beat me without your magics?”</i>\n\n");
				monster.createStatusEffect(StatusEffects.Shell, 2, 0, 0, 0);
			}
			enemyAI();
		}
	}
	public function spellPyreBurst3(edgy:Boolean = false):void {
		var damage:Number = 0;
		//Attack gains burn DoT for 2-3 turns.
		outputText("You let loose a roiling cone of flames that wash over the horde of demons like a tidal wave, scorching at their tainted flesh with vigor unlike anything you've seen before. Screams of terror as much as, maybe more than, pain fill the air as the mass of corrupted bodies try desperately to escape from you! Though more demons pile in over the affected front ranks, you've certainly put the fear of your magic into them!");
		monster.createStatusEffect(StatusEffects.OnFire, 2 + rand(2), 0, 0, 0);
		damage = scalingBonusIntelligence() * spellModWhite() * 2 * combat.fireDamageBoostedByDao();
		if (monster.plural) damage *= 5;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		damage *= 1.75;
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		if(monster.short == "Holli" && !monster.hasStatusEffect(StatusEffects.HolliBurning)) (monster as Holli).lightHolliOnFireMagically();
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}
	public function spellPyreBurst4(edgy:Boolean = false):void {
		var damage:Number = 0;
		clearOutput();
		outputText("You wave the signs with your hands before striking the grounds causing an expending wave of flames to wash over " + monster.a + monster.short + ".\n");
		damage = scalingBonusIntelligence() * spellModWhite() * 2;
		if (monster.plural) damage *= 5;
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance2:int = 5;
		critChance2 += combatMagicalCritical();
		if (rand(100) < critChance2) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcInfernoMod(damage);
		if (player.armor == armors.BLIZZ_K) damage *= 0.5;
		if (player.headJewelry == headjewelries.SNOWFH) damage *= 0.7;
		if (monster.short == "goo-girl") damage = Math.round(damage * 1.5);
		if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.fireDamageBoostedByDao());
		outputText(monster.capitalA + monster.short + " takes ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			doFireDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doFireDamage(damage, true, true);
				doFireDamage(damage, true, true);
			}
		}
		else doFireDamage(damage, true, true);
		outputText(" damage.");
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		//Using fire attacks on the goo]
		if(monster.short == "goo-girl") {
			outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
			if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		}
		if(monster.short == "Holli" && !monster.hasStatusEffect(StatusEffects.HolliBurning)) (monster as Holli).lightHolliOnFireMagically();
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
	}

//(50) Chain Lightning - aoe lighting spell
	public function spellChainLightning():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200)) player.HP -= spellCostWhite(200);
		else useMana(200,5);
		player.createStatusEffect(StatusEffects.CooldownSpellChainLighting,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellChainLightning3();
	}
	public function spellChainLightning2():void {
		flags[kFLAGS.LAST_ATTACK_TYPE] = 2;
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(200)) player.HP -= spellCostWhite(200);
		else useMana(200, 5);
		player.wrath -= 100;
		player.createStatusEffect(StatusEffects.CooldownSpellChainLightingEx,spellWhiteCooldown(),0,0,0);
		if (handleShell()){return;}
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		spellChainLightning3(true);
	}
	public function spellChainLightning3(edgy:Boolean = false):void {
		clearOutput();
		outputText("You charge energy in your hand and fire it out in the form of a powerful bolt of lightning at " + monster.a + monster.short + " ");
		var damage:Number = scalingBonusIntelligence() * spellModWhite() * 2;
		if (monster.plural) {
			outputText("that jumps from one target to another ");
			damage *= 5;
		}
		if (edgy) damage *= 2;
		//Determine if critical hit!
		var crit:Boolean = false;
		var critChance:int = 5;
		critChance += combatMagicalCritical();
		if (monster.isImmuneToCrits() && !player.hasPerk(PerkLib.EnableCriticals)) critChance = 0;
		if (rand(100) < critChance) {
			crit = true;
			damage *= 1.75;
		}
		//High damage to goes.
		damage = calcVoltageMod(damage);
		if (player.hasPerk(PerkLib.ElectrifiedDesire)) damage *= (1 + (player.lust100 * 0.01));
		if (player.hasPerk(PerkLib.DivineKnowledge) && monster.cor > 65) damage = Math.round(damage * 1.2);
		if (player.hasPerk(PerkLib.PureMagic)) {
			if (monster.cor < 33) damage = Math.round(damage * 1.0);
			else if (monster.cor < 50) damage = Math.round(damage * 1.1);
			else if (monster.cor < 75) damage = Math.round(damage * 1.2);
			else if (monster.cor < 90) damage = Math.round(damage * 1.3);
			else damage = Math.round(damage * 1.4);
		}
		damage = Math.round(damage * combat.lightningDamageBoostedByDao());
		//if (monster.short == "goo-girl") damage = Math.round(damage * 1.5); - pomyśleć czy bdą dostawać bonusowe obrażenia
		//if (monster.short == "tentacle beast") damage = Math.round(damage * 1.2); - tak samo przemyśleć czy bedą dodatkowo ranione
		outputText("for ");
		if (player.hasPerk(PerkLib.Omnicaster)) {
			if (player.hasPerk(MutationsLib.GazerEyeEvolved)) damage *= 0.5;
			else if (player.hasPerk(MutationsLib.GazerEyePrimitive)) damage *= 0.3;
			else damage *= 0.2;
			damage = Math.round(damage);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			doLightingDamage(damage, true, true);
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 8) {
				doLightingDamage(damage, true, true);
				doLightingDamage(damage, true, true);
			}
			if (player.statusEffectv1(StatusEffects.GazerEyeStalksPlayer) >= 10) {
				doLightingDamage(damage, true, true);
				doLightingDamage(damage, true, true);
			}
		}
		else doLightingDamage(damage, true, true);
		outputText(" damage.");
		//Using fire attacks on the goo]
		//if(monster.short == "goo-girl") {
		//outputText("  Your flames lick the girl's body and she opens her mouth in pained protest as you evaporate much of her moisture. When the fire passes, she seems a bit smaller and her slimy " + monster.skinTone + " skin has lost some of its shimmer.");
		//if(!monster.hasPerk(PerkLib.Acid)) monster.createPerk(PerkLib.Acid,0,0,0,0);
		//}
		if (crit) outputText(" <b>*Critical Hit!*</b>");
		MagicAddonEffect();
		outputText("\n\n");
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		if (edgy) awardAchievement("Edgy Caster", kACHIEVEMENTS.COMBAT_EDGY_CASTER);
		checkAchievementDamage(damage);
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		combat.heroBaneProc(damage);
		statScreenRefresh();
		if(monster.HP <= monster.minHP()) doNext(endHpVictory);
		else enemyAI();
	}

//(35) Blizzard
	public function spellBlizzard():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(50)) player.HP -= spellCostWhite(50);
		else useMana(50,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		outputText("You utter words of power, summoning an ice storm.  It swirls arounds you, ensuring that you'll have more protection from the fire attacks for a few moments.\n\n");
		var blizzardmagnitude:Number = 0;
		if (player.hasPerk(PerkLib.ColdMastery) || player.hasPerk(PerkLib.ColdAffinity)) blizzardmagnitude += 2 + player.inte / 10;
		else blizzardmagnitude += 1 + player.inte / 25;
		if (player.hasPerk(PerkLib.DefensiveStaffChanneling)) blizzardmagnitude *= 1.1;
		player.createStatusEffect(StatusEffects.Blizzard,Math.round(blizzardmagnitude),0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}

//(35) Mental Shield
	public function spellMentalShield():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCost(300)) player.HP -= spellCost(300);
		else useMana(300,1);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		player.createStatusEffect(StatusEffects.CooldownSpellMentalShield,10,0,0,0);
		outputText("You draw on your inner calm, forcing it out in the form of a powerful magical ward to weaken the effect of your opponent’s depraved attacks on you.\n\n");
		var mentalshieldduration:Number = 10;
		if (player.hasPerk(PerkLib.DefensiveStaffChanneling)) mentalshieldduration *= 1.1;
		player.createStatusEffect(StatusEffects.MentalShield,Math.round(mentalshieldduration),0,0,0);
		if (player.weapon == weapons.DEMSCYT && player.cor < 90) dynStats("cor", 0.3);
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}

//(35) Cure
	public function spellCure():void {
		clearOutput();
		doNext(combatMenu);
		if (player.hasPerk(PerkLib.LastResort) && player.mana < spellCostWhite(500)) player.HP -= spellCostWhite(500);
		else useMana(500,5);
		if ((monster is FrostGiant || monster is YoungFrostGiant) && player.hasStatusEffect(StatusEffects.GiantBoulder)) {
			if (monster as FrostGiant) (monster as FrostGiant).giantBoulderHit(2);
			if (monster as YoungFrostGiant) (monster as YoungFrostGiant).youngGiantBoulderHit(2);
			enemyAI();
			return;
		}
		clearOutput();
		player.createStatusEffect(StatusEffects.CooldownSpellCure,7,0,0,0);
		outputText("You channel white magic to rid yourself of all negative effect affecting you.\n\n");
		if (player.hasStatusEffect(StatusEffects.BurnDoT)) player.removeStatusEffect(StatusEffects.BurnDoT);
		if (player.hasStatusEffect(StatusEffects.AcidSlap)) player.removeStatusEffect(StatusEffects.AcidSlap);
		if (player.hasStatusEffect(StatusEffects.DriderKiss)) player.removeStatusEffect(StatusEffects.DriderKiss);
		if (player.hasStatusEffect(StatusEffects.AikoLightningArrow)) {
			player.removeStatusEffect(StatusEffects.AikoLightningArrow);
            player.addCombatBuff('str', 6);
            player.addCombatBuff('spe', 6);
		}
		if (player.hasStatusEffect(StatusEffects.NagaVenom)) player.removeStatusEffect(StatusEffects.NagaVenom);
		if (player.hasStatusEffect(StatusEffects.MedusaVenom)) player.removeStatusEffect(StatusEffects.MedusaVenom);
		if (player.hasStatusEffect(StatusEffects.DriderIncubusVenom)) player.removeStatusEffect(StatusEffects.DriderIncubusVenom);
		if (player.hasStatusEffect(StatusEffects.Poison)) player.removeStatusEffect(StatusEffects.Poison);
		if (player.hasStatusEffect(StatusEffects.AcidDoT)) player.removeStatusEffect(StatusEffects.AcidDoT);
		if (player.hasStatusEffect(StatusEffects.FrostburnDoT)) player.removeStatusEffect(StatusEffects.FrostburnDoT);
		if (player.hasStatusEffect(StatusEffects.FrozenLung)) player.removeStatusEffect(StatusEffects.FrozenLung);
		if (player.statStore.hasBuff("Poison")) player.buff("Poison").remove();
		if (player.statStore.hasBuff("Weakened") || player.statStore.hasBuff("Drained")) {
			for each (var stat:String in ["str","spe","tou","int","wis","lib","sens"]) {
				player.removeCurse(stat, 6,1);
				player.removeCurse(stat, 3,2);
				if (stat != "sens") {
					player.removeCurse(stat+".mult", 0.06,1);
					player.removeCurse(stat+".mult", 0.03,2);
				}
			}
		}
		statScreenRefresh();
		flags[kFLAGS.SPELLS_CAST]++;
		if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
		spellPerkUnlock();
		enemyAI();
	}

	private function handleShell():Boolean{
        if(monster.hasStatusEffect(StatusEffects.Shell)) {
            outputText("As soon as your magic touches the multicolored shell around " + monster.a + monster.short + ", it sizzles and fades to nothing.  Whatever that thing is, it completely blocks your magic!\n\n");
            flags[kFLAGS.SPELLS_CAST]++;
            if(!player.hasStatusEffect(StatusEffects.CastedSpell)) player.createStatusEffect(StatusEffects.CastedSpell,0,0,0,0);
            spellPerkUnlock();
            enemyAI();
            return true;
        }
		return false;
	}
}
}