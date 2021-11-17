package classes.Scenes.Combat.SpellsWhite {
import classes.Monster;
import classes.PerkLib;
import classes.Scenes.Combat.AbstractWhiteSpell;
import classes.Scenes.Combat.DamageType;
import classes.StatusEffects;

public class MeteorShowerSpell extends AbstractWhiteSpell{
	public function MeteorShowerSpell() {
		super(
				"Meteor Shower",
				"Call down a rain of meteors on your opponents, stunning them for 1 round and dealing area damage. Hits 12 times.\n<b>Req. 1 turn channeling. Cooldown: 12 turns.</b>",
				TARGET_ENEMY,
				TIMING_INSTANT,
				[TAG_DAMAGING,TAG_FIRE,TAG_AOE]
		);
		baseManaCost = 1250;
	}
	
	override public function get isKnown():Boolean {
		return player.hasStatusEffect(StatusEffects.KnowsMeteorShower);
	}
	
	override public function get currentCooldown():int {
		return player.statusEffectv1(StatusEffects.CooldownSpellMeteorShower)
	}
	
	override protected function usabilityCheck():String {
		var uc:String = super.usabilityCheck();
		if (uc) return uc;
		
		if (inDungeon || player.hasStatusEffect(StatusEffects.InsideSmallSpace)) {
			return "You can't use this spell inside small spaces. Unless you want get killed along with your enemies.";
		}
		if (player.hasStatusEffect(StatusEffects.UnderwaterCombatBoost)) {
			return "You can't use this spell underwater.";
		}
		
		return "";
	}
	
	override public function useResources():void {
		if (player.statusEffectv1(StatusEffects.ChanneledAttack) == 1) {
			super.useResources();
			player.createStatusEffect(StatusEffects.CooldownSpellMeteorShower, 12, 0, 0, 0);
		} else {
			/* we're channeling, don't use mana */
		}
	}
	
	override public function describeEffectVs(target:Monster):String {
		return "~" + calcDamage(target)+ "(x12) fire damage."
	}
	
	public function calcDamage(target:Monster):Number {
		return adjustSpellDamage(
				scalingBonusIntelligence()*3,
				DamageType.FIRE,
				CAT_SPELL_WHITE,
				target
		);
	}
	
	public function meteorShowerHit(display: Boolean = true):void {
		player.removeStatusEffect(StatusEffects.ChanneledAttack);
		player.removeStatusEffect(StatusEffects.ChanneledAttackType);
		if (player.hasPerk(PerkLib.RagingInfernoSu) && player.hasStatusEffect(StatusEffects.CounterRagingInferno)) player.addStatusValue(StatusEffects.CounterRagingInferno, 3, -1);
		if (display) {
			outputText("You call out to the celestial vault, knocking some rocks out of orbit and into a crash course towards your opponents.\n\n");
			outputText("[Monster a] [monster name] takes ")
		}
		var meteor:Number = 12;
		while (meteor-->0){
			var damage:Number = calcDamage(monster);
			critAndRepeatDamage(false, damage, DamageType.FIRE, true);
		}
		if (display) {
			outputText(" damage!");
			outputText(" " + monster.capitalA + monster.short + " reels from the impact, trying to recover from this devastating assault as a meteor crash in the area.\n\n");
		}
		damage *= 12;
		monster.createStatusEffect(StatusEffects.Stunned,1,0,0,0);
		checkAchievementDamage(damage);
		combat.heroBaneProc(damage);
	}
	
	public function meteorShowerChannel(display: Boolean = true):void {
		if (display) {
			outputText("You begin to channel magic, the sky reddening above you.\n\n");
		}
		player.createStatusEffect(StatusEffects.ChanneledAttack, 1, 0, 0, 0);
		player.createStatusEffect(StatusEffects.ChanneledAttackType, 6, 0, 0, 0);
		if (player.hasPerk(PerkLib.RagingInfernoSu)) player.addStatusValue(StatusEffects.CounterRagingInferno, 3, 1);
	}
	
	override protected function doSpellEffect(display:Boolean = true):void {
		if (player.statusEffectv1(StatusEffects.ChanneledAttack) == 1) {
			meteorShowerHit(display);
		} else {
			meteorShowerChannel(display);
		}
	}
}
}
