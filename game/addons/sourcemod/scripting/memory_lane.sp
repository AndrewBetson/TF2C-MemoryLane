// SPDX-FileCopyrightText: © Andrew Betson
// SPDX-License-Identifier: AGPL-3.0-or-later

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>

#include <sourcescramble>

#if !defined PLUGIN_VERSION
#define PLUGIN_VERSION "0.0.6"
#endif // !defined PLUGIN_VERSION

public Plugin myinfo = {
	name		= "[TF2C] Memory Lane",
	description	= "Recreates behaviors from 2012 TF2.",
	author		= "Andrew Betson",
	version		= PLUGIN_VERSION,
	url			= "https://www.github.com/AndrewBetson/TF2C-MemoryLane/"
}

ConVar ml_rollback_sandman_stun;
ConVar ml_rollback_eat_own_thrown_sandvich;
ConVar ml_rollback_caber_nerf;
ConVar ml_rollback_reserve_shooter_airblast_nerf;
ConVar ml_rollback_sword_deploy_penalty;
ConVar ml_rollback_quick_redisguise;
ConVar ml_rollback_soda_popper_hype_condition;
ConVar ml_rollback_weapon_deploy_speed;

public void OnPluginStart() {
	GameData game_data = LoadGameConfigFile( "memory_lane.games" );
	if ( game_data == INVALID_HANDLE ) {
		ThrowNativeError( SP_ERROR_NOT_FOUND, "Failed to load game config file." );
	}

	ml_rollback_sandman_stun = CreateConVar( "ml_rollback_sandman_stun", "1", "Revert the sandman's stun effects." );
	ml_rollback_eat_own_thrown_sandvich = CreateConVar( "ml_rollback_eat_own_thrown_sandvich", "1", "Enable eating own thrown sandvich." );
	ml_rollback_caber_nerf = CreateConVar( "ml_rollback_caber_nerf", "1", "Enable old caber base damage/falloff." );
	ml_rollback_reserve_shooter_airblast_nerf = CreateConVar( "ml_rollback_reserve_shooter_airblast_nerf", "1", "Enable reserve shooter minicrit on airblast." );
	ml_rollback_sword_deploy_penalty = CreateConVar( "ml_rollback_sword_deploy_penalty", "1", "Disable sword deploy/holster penalty." );
	ml_rollback_quick_redisguise = CreateConVar( "ml_rollback_quick_redisguise", "1", "Disable disguising while already disguised being faster." );
	ml_rollback_soda_popper_hype_condition = CreateConVar( "ml_rollback_soda_popper_hype_condition", "1", "Enable old soda popper hype condition." );
	ml_rollback_weapon_deploy_speed = CreateConVar( "ml_rollback_weapon_deploy_speed", "1", "Enable old weapon deploy speed." );

	AutoExecConfig( true, "memory_lane" );

	AddFileToDownloadsTable( "scripts/items/custom_items_game.txt" );

	// Sandman stun

	if ( ml_rollback_sandman_stun.BoolValue ) {
		MemoryPatch old_weak_stun_patch = MemoryPatch.CreateFromConf( game_data, "CTFStunBall::ApplyBallImpactEffectOnVictim::OldWeakStun" );
		if ( !old_weak_stun_patch.Validate() ) {
			ThrowError( "Failed to validate CTFStunBall::ApplyBallImpactEffectOnVictim::OldWeakStun memory patch." );
		} else if ( !old_weak_stun_patch.Enable() ) {
			ThrowError( "Failed to enable CTFStunBall::ApplyBallImpactEffectOnVictim::OldWeakStun memory patch." );
		}

		MemoryPatch old_homerun_stun_patch = MemoryPatch.CreateFromConf( game_data, "CTFStunBall::ApplyBallImpactEffectOnVictim::OldHomerunStun" );
		if ( !old_homerun_stun_patch.Validate() ) {
			ThrowError( "Failed to validate CTFStunBall::ApplyBallImpactEffectOnVictim::OldHomerunStun memory patch." );
		} else if ( !old_homerun_stun_patch.Enable() ) {
			ThrowError( "Failed to enable CTFStunBall::ApplyBallImpactEffectOnVictim::OldHomerunStun memory patch." );
		}
	}

	// Eat own dropped sandvich

	if ( ml_rollback_eat_own_thrown_sandvich.BoolValue ) {
		MemoryPatch eat_own_dropped_sandvich_patch = MemoryPatch.CreateFromConf( game_data, "CHealthKit::MyTouch::EatOwnDroppedSandvich" );
		if ( !eat_own_dropped_sandvich_patch.Validate() ) {
			ThrowError( "Failed to validate CHealthKit::MyTouch::EatOwnDroppedSandvich memory patch." );
		} else if ( !eat_own_dropped_sandvich_patch.Enable() ) {
			ThrowError( "Failed to enable CHealthKit::MyTouch::EatOwnDroppedSandvich memory patch." );
		}
	}

	// Old caber behavior

	if ( ml_rollback_caber_nerf.BoolValue ) {
		MemoryPatch old_caber_base_damage_patch = MemoryPatch.CreateFromConf( game_data, "CTFStickBomb::Smack::OldBaseDamage" );
		if ( !old_caber_base_damage_patch.Validate() ) {
			ThrowError( "Failed to validate CTFStickBomb::Smack::OldBaseDamage memory patch." );
		} else if ( !old_caber_base_damage_patch.Enable() ) {
			ThrowError( "Failed to enable CTFStickBomb::Smack::OldBaseDamage memory patch." );
		}
	}

	if ( ml_rollback_caber_nerf.BoolValue ) {
		MemoryPatch old_caber_no_damage_falloff_patch = MemoryPatch.CreateFromConf( game_data, "CTFStickBomb::Smack::NoDamageFalloff" );
		if ( !old_caber_no_damage_falloff_patch.Validate() ) {
			ThrowError( "Failed to validate CTFStickBomb::Smack::NoDamageFalloff memory patch." );
		} else if ( !old_caber_no_damage_falloff_patch.Enable() ) {
			ThrowError( "Failed to enable CTFStickBomb::Smack::NoDamageFalloff memory patch." );
		}
	}

	// Old eyelander behavior

	if ( ml_rollback_sword_deploy_penalty.BoolValue ) {
		MemoryPatch old_eyelander_deploy_speed = MemoryPatch.CreateFromConf( game_data, "CTFWeaponBase::Deploy::NoHolsterPenalty" );
		if ( !old_eyelander_deploy_speed.Validate() ) {
			ThrowError( "Failed to validate CTFWeaponBase::Deploy::NoHolsterPenalty memory patch." );
		} else if ( !old_eyelander_deploy_speed.Enable() ) {
			ThrowError( "Failed to enable CTFWeaponBase::Deploy::NoHolsterPenalty memory patch." );
		}
	}

	// No quick re-disguise

	if ( ml_rollback_quick_redisguise.BoolValue ) {
		MemoryPatch no_quick_redisguise_patch = MemoryPatch.CreateFromConf( game_data, "CTFPlayerShared::Disguise::NoQuickReDisguise" );
		if ( !no_quick_redisguise_patch.Validate() ) {
			ThrowError( "Failed to validate CTFPlayerShared::Disguise::NoQuickReDisguise memory patch." );
		} else if ( !no_quick_redisguise_patch.Enable() ) {
			ThrowError( "Failed to enable CTFPlayerShared::Disguise::NoQuickReDisguise memory patch." );
		}
	}

	// Old soda popper hype condition

	if ( ml_rollback_soda_popper_hype_condition.BoolValue ) {
		MemoryPatch check_old_hype_condition_patch = MemoryPatch.CreateFromConf( game_data, "CTFSodaPopper::SecondaryAttack::CheckOldHypeCondition" );
		if ( !check_old_hype_condition_patch.Validate() ) {
			ThrowError( "Failed to validate CTFSodaPopper::SecondaryAttack::CheckOldHypeCondition memory patch." );
		} else if ( !check_old_hype_condition_patch.Enable() ) {
			ThrowError( "Failed to enable CTFSodaPopper::SecondaryAttack::CheckOldHypeCondition memory patch." );
		}

		MemoryPatch old_hype_condition_patch = MemoryPatch.CreateFromConf( game_data, "CTFSodaPopper::SecondaryAttack::OldHypeCondition" );
		if ( !old_hype_condition_patch.Validate() ) {
			ThrowError( "Failed to validate CTFSodaPopper::SecondaryAttack::OldHypeCondition memory patch." );
		} else if ( !old_hype_condition_patch.Enable() ) {
			ThrowError( "Failed to enable CTFSodaPopper::SecondaryAttack::OldHypeCondition memory patch." );
		}
	}

	// Reserve shooter airblast minicrits

	if ( ml_rollback_reserve_shooter_airblast_nerf.BoolValue ) {
		MemoryPatch reserve_shooter_airblast_minicrits_patch = MemoryPatch.CreateFromConf( game_data, "CTFGameRules::ApplyOnDamageModifyRules::ReserveShooterAirblastMinicrits" );
		if ( !reserve_shooter_airblast_minicrits_patch.Validate() ) {
			ThrowError( "Failed to validate CTFGameRules::ApplyOnDamageModifyRules::ReserveShooterAirblastMinicrits memory patch." );
		} else if ( !reserve_shooter_airblast_minicrits_patch.Enable() ) {
			ThrowError( "Failed to enable CTFGameRules::ApplyOnDamageModifyRules::ReserveShooterAirblastMinicrits memory patch." );
		}
	}

	// Old weapon deploy speed

	if ( ml_rollback_weapon_deploy_speed.BoolValue ) {
		MemoryPatch old_weapon_deploy_speed_patch = MemoryPatch.CreateFromConf( game_data, "CTFWeaponBase::Deploy::OldDeploySpeed" );
		if ( !old_weapon_deploy_speed_patch.Validate() ) {
			ThrowError( "Failed to validate CTFWeaponBase::Deploy::OldDeploySpeed memory patch." );
		} else if ( !old_weapon_deploy_speed_patch.Enable() ) {
			ThrowError( "Failed to enable CTFWeaponBase::Deploy::OldDeploySpeed memory patch." );
		}
	}
}
