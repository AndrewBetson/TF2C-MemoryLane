// SPDX-FileCopyrightText: © Andrew Betson
// SPDX-License-Identifier: AGPL-3.0-or-later

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
//#include <dhooks>

#include <tf2>
#include <tf2_stocks>

#include <sourcescramble>

#if !defined PLUGIN_VERSION
#define PLUGIN_VERSION "0.0.1"
#endif // !defined PLUGIN_VERSION

public Plugin myinfo = {
	name		= "[TF2C] Memory Lane",
	description	= "Recreates behaviors from 2012 TF2.",
	author		= "Andrew Betson",
	version		= PLUGIN_VERSION,
	url			= "https://www.github.com/AndrewBetson/TF2C-MemoryLane/"
}

//Handle g_sdkcall_CTFWeaponBaseGun_GetProjectileDamage;
//Handle g_sdkcall_CTFWeaponBaseGun_GetWeaponSpread;

public void OnPluginStart() {
	GameData game_data = LoadGameConfigFile( "memory_lane.games" );
	if ( game_data == INVALID_HANDLE ) {
		ThrowNativeError( SP_ERROR_NOT_FOUND, "Failed to load game config file." );
	}

	// Minigun ramp-up
	// TODO we don't have dhooks, do this with a mempatch!

/*
	StartPrepSDKCall( SDKCall_Entity );
	{
		PrepSDKCall_SetFromConf( game_data, SDKConf_Signature, "CTFWeaponBaseGun::GetProjectileDamage" );
		PrepSDKCall_SetReturnInfo( SDKType_Float, SDKPass_ByValue );
	}
	g_sdkcall_CTFWeaponBaseGun_GetProjectileDamage = EndPrepSDKCall();

	StartPrepSDKCall( SDKCall_Entity );
	{
		PrepSDKCall_SetFromConf( game_data, SDKConf_Signature, "CTFWeaponBaseGun::GetWeaponSpread" );
		PrepSDKCall_SetReturnInfo( SDKType_Float, SDKPass_ByValue );
	}
	g_sdkcall_CTFWeaponBaseGun_GetWeaponSpread = EndPrepSDKCall();

	Handle detour_CTFMinigun_GetProjectileDamage = DHookCreateFromConf( game_data, "CTFMinigun::GetProjectileDamage" );
	if ( !DHookEnableDetour( detour_CTFMinigun_GetProjectileDamage, true, Detour_CTFMinigun_GetProjectileDamage ) ) {
		ThrowError( "Failed to detour CTFMinigun::GetProjectileDamage" );
	}

	Handle detour_CTFMinigun_GetWeaponSpread = DHookCreateFromConf( game_data, "CTFMinigun::GetWeaponSpread" );
	if ( !DHookEnableDetour( detour_CTFMinigun_GetWeaponSpread, true, Detour_CTFMinigun_GetWeaponSpread ) ) {
		ThrowError( "Failed to detour CTFMinigun::GetWeaponSpread" );
	}
*/

	// Sandman stun

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

	// Eat own dropped sandvich

	MemoryPatch eat_own_dropped_sandvich_patch = MemoryPatch.CreateFromConf( game_data, "CHealthKit::MyTouch::EatOwnDroppedSandvich" );
	if ( !eat_own_dropped_sandvich_patch.Validate() ) {
		ThrowError( "Failed to validate CHealthKit::MyTouch::EatOwnDroppedSandvich memory patch." );
	} else if ( !eat_own_dropped_sandvich_patch.Enable() ) {
		ThrowError( "Failed to enable CHealthKit::MyTouch::EatOwnDroppedSandvich memory patch." );
	}

	// Old caber behavior

	MemoryPatch old_caber_base_damage_patch = MemoryPatch.CreateFromConf( game_data, "CTFStickBomb::Smack::OldBaseDamage" );
	if ( !old_caber_base_damage_patch.Validate() ) {
		ThrowError( "Failed to validate CTFStickBomb::Smack::OldBaseDamage memory patch." );
	} else if ( !old_caber_base_damage_patch.Enable() ) {
		ThrowError( "Failed to enable CTFStickBomb::Smack::OldBaseDamage memory patch." );
	}

	MemoryPatch old_caber_no_damage_falloff_patch = MemoryPatch.CreateFromConf( game_data, "CTFStickBomb::Smack::NoDamageFalloff" );
	if ( !old_caber_no_damage_falloff_patch.Validate() ) {
		ThrowError( "Failed to validate CTFStickBomb::Smack::NoDamageFalloff memory patch." );
	} else if ( !old_caber_no_damage_falloff_patch.Enable() ) {
		ThrowError( "Failed to enable CTFStickBomb::Smack::NoDamageFalloff memory patch." );
	}

	// Old eyelander behavior

	MemoryPatch old_eyelander_deploy_speed = MemoryPatch.CreateFromConf( game_data, "CTFWeaponBase::Deploy::NoHolsterPenalty" );
	if ( !old_eyelander_deploy_speed.Validate() ) {
		ThrowError( "Failed to validate CTFWeaponBase::Deploy::NoHolsterPenalty memory patch." );
	} else if ( !old_eyelander_deploy_speed.Enable() ) {
		ThrowError( "Failed to enable CTFWeaponBase::Deploy::NoHolsterPenalty memory patch." );
	}
}
