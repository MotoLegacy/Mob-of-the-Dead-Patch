//
// MIT License
//
// Copyright (c) 2021 MotoLegacy, JariKCoding
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#using scripts\codescripts\struct;

#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_brutus_interface;

#using scripts\shared\weapons\_weaponobjects;

#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_ai_brutus;
#using scripts\zm\_zm_weap_riotshield; 

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\shared\ai\archetype_brutus.gsh;
#insert scripts\shared\ai\utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace BrutusBehavior;

#precache("model", BRUTUS_MODEL_HELMET);
#precache("model", "c_zom_cellbreaker_fb");
#precache("model", "c_zom_cellbreaker_baton");

REGISTER_SYSTEM( "brutus", &__init__, undefined )
	
function __init__() {
    // INIT BEHAVIORS
	InitBrutusBehaviorsAndASM();

    // INIT BLACKBOARD	
	spawner::add_archetype_spawn_function( ARCHETYPE_BRUTUS, &ArchetypeBrutusBlackboardInit );

    // INIT BRUTUS ON SPAWN
	spawner::add_archetype_spawn_function( ARCHETYPE_BRUTUS, &brutusSpawnSetup );

	clientfield::register( "actor", "brutus_helmet_detached", VERSION_DLC1, 1, "int" );
	clientfield::register( "actor", "brutus_spotlight_off", VERSION_DLC1, 2, "int" );
	clientfield::register( "scriptmover", "brutus_lockdown_fx", VERSION_SHIP, 2, "int" );
}

function private InitBrutusBehaviorsAndASM() {
    // SERVICES
    BT_REGISTER_API( "brutusTargetService", 				&BrutusBehavior::brutusTargetService );
    BT_REGISTER_API( "brutusPriorityItemService", 			&BrutusBehavior::brutusPriorityItemService );

    // CONDITIONS
    BT_REGISTER_API( "brutusShouldMelee", 				    &BrutusBehavior::brutusShouldMelee );
    BT_REGISTER_API( "brutusShouldLockDown", 				&BrutusBehavior::brutusShouldLockDown );
    BT_REGISTER_API( "brutusShouldDoGasAttack", 				&BrutusBehavior::brutusShouldDoGasAttack );

	// ACTIONS
	BT_REGISTER_API( "brutusDeath",							&BrutusBehavior::brutusDeath );
	BT_REGISTER_API( "brutusLockDown",						&BrutusBehavior::brutusLockDown );
	BT_REGISTER_API( "brutusGasAttack",						&BrutusBehavior::brutusGasAttack );
    
    // NOTETRACKS
	ASM_REGISTER_NOTETRACK_HANDLER( ASM_BRUTUS_MELEE_NOTETRACK, &BrutusBehavior::brutusNotetrackMelee );
	ASM_REGISTER_NOTETRACK_HANDLER( ASM_BRUTUS_LOCKDOWN_NOTETRACK, &BrutusBehavior::brutusNotetrackLockDown );
	ASM_REGISTER_NOTETRACK_HANDLER( ASM_BRUTUS_TEARGAS_NOTETRACK, &BrutusBehavior::brutusNotetrackTeargas );
}

function private ArchetypeBrutusBlackboardInit() {
	entity = self;

    // CREATE BLACKBOARD
	Blackboard::CreateBlackBoardForEntity( entity );
	
	// USE UTILITY BLACKBOARD
	entity AiUtility::RegisterUtilityBlackboardAttributes();
	
	// CREATE INTERFACE
	ai::CreateInterfaceForEntity( entity );
	
	// CREATE BRUTUS BLACKBOARD
	BB_REGISTER_ATTRIBUTE( LOCOMOTION_SPEED_TYPE,		LOCOMOTION_SPEED_RUN,						undefined );
	BB_REGISTER_ATTRIBUTE( LOCOMOTION_SHOULD_TURN,		SHOULD_NOT_TURN,					&BB_GetShouldTurn );
	BB_REGISTER_ATTRIBUTE( ZOMBIE_DAMAGEWEAPON_TYPE,	ZOMBIE_DAMAGEWEAPON_REGULAR,		undefined );
	BB_REGISTER_ATTRIBUTE( BRUTUS_LOCKDOWN_TYPE,	undefined,		undefined );
	
	// REGISTER ANIMSCRIPTED CALLBACK
	entity.___ArchetypeOnAnimscriptedCallback = &ArchetypeBrutusOnAnimscriptedCallback;
	
	// ENABLE DEBUGGING IN ODYSSEY
	ENABLE_BLACKBOARD_DEBUG_TRACKING( entity );
}

function private ArchetypeBrutusOnAnimscriptedCallback( entity ) {
	// UNREGISTER THE BLACKBOARD
	entity.__blackboard = undefined;
	
	// REREGISTER BLACKBOARD
	entity ArchetypeBrutusBlackboardInit();
}

function private brutusSpawnSetup() {
	//IPrintLnBold("brutusSpawnSetup");
    entity = self;

	entity.health = BRUTUS_STARTING_HEALTH;
	entity.maxHealth = entity.health;

	entity.explosive_dmg_req = level.brutus_expl_dmg_req;
	entity.explosive_dmg_taken = 0;
	entity.has_helmet = true;
	entity.helmet_hits = 0;
	entity.is_brutus = true;
	entity SetPhysParams(10, 0, 60);

	entity thread BrutusServerUtils::brutusAttachHelmet();

	entity.disableAmmoDrop = true;
	entity.ignore_nuke = true;
	entity.ignore_enemy_count = true;
	entity.ignore_round_robbin_death = true;

	entity.priority_item = undefined;

    entity.lockdownState = BRUTUS_LOCKDOWNSTATE_OFF;

	//level thread BrutusServerUtils::brutusSpawnScene( entity );

	AiUtility::AddAiOverrideDamageCallback( entity, &BrutusServerUtils::brutusDamageCallback );
}

function private BB_GetShouldTurn() {
	entity = self;

	if ( isdefined( entity.should_turn ) && entity.should_turn )
	{
		return SHOULD_TURN;
	}
	return SHOULD_NOT_TURN;
}

//----------------------------------------------------------------------------------------------------------------------------
// NOTETRACK HANDLERS
//----------------------------------------------------------------------------------------------------------------------------
function private brutusNotetrackMelee( entity ) {
	if(isdefined(entity.priority_item)) {
		if(entity.interactiontype == "blocker") {
			if( DistanceSquared( entity.origin, entity.goal_pos ) < BRUTUS_MELEE_DIST_SQ * 1.5) {
				interaction = level.interaction_types[ entity.interactiontype ];
				entity [[ interaction.interact_func ]]();
			}
		}
		else {
			if( DistanceSquared( entity.origin, entity.goal_pos ) < BRUTUS_MELEE_DIST_SQ * 0.5 ) {
				interaction = level.interaction_types[ entity.interactiontype ];
				entity [[ interaction.interact_func ]]();
			}
		}
	}

	if( isDefined( entity.brutus_melee_knockdown_function ))
	{
		entity thread [[ entity.brutus_melee_knockdown_function ]]();
	}
	
	hitEntity = entity Melee();
	
	if ( IsDefined( hitEntity ) && IsDefined( entity.brutusMeleeHitCallback ) )
	{
		entity thread [[ entity.brutusMeleeHitCallback ]]( hitEntity );
	}

	if ( AiUtility::shouldAttackObject( entity ) )
	{
		if ( IsDefined( level.attackableCallback ) )
		{
			entity.attackable [[ level.attackableCallback ]]( entity );
		}
	}
}

function private brutusNotetrackLockDown( entity ) {
	if(isdefined(entity.priority_item)) {
		if(entity.interactiontype == "blocker") {
			if( DistanceSquared( entity.origin, entity.goal_pos ) > BRUTUS_MELEE_DIST_SQ * 1.5)
				return false;
		}
		else {
			if( DistanceSquared( entity.origin, entity.goal_pos ) > BRUTUS_MELEE_DIST_SQ * 0.5 )
				return false;
		}
		interaction = level.interaction_types[ entity.interactiontype ];
		entity [[ interaction.interact_func ]]();
	}
}

function private brutusNotetrackTeargas( entity ) {
	v_org_left = entity GetTagOrigin( "TAG_WEAPON_LEFT" );
	v_org_right = entity GetTagOrigin( "TAG_WEAPON_RIGHT" );
	entity thread sndPlayDelayedSmokeAudio( v_org_left, v_org_right );
	entity MagicGrenadeType( GetWeapon(BRUTUS_TEARGAS_WEAPON), v_org_left, ( 0, 0, 0 ), 0.4 );
	entity MagicGrenadeType( GetWeapon(BRUTUS_TEARGAS_WEAPON), v_org_right, ( 0, 0, 0 ), 0.4 );
}

function private sndplaydelayedsmokeaudio( org1, org2 ) {
	wait 1.5;
	PlaySoundAtPosition( "zmb_ai_brutus_gas_explode", org1 );
	wait 0.25;
	PlaySoundAtPosition( "zmb_ai_brutus_gas_explode", org2 );
}

//----------------------------------------------------------------------------------------------------------------------------
// BEHAVIOR TREE
//----------------------------------------------------------------------------------------------------------------------------
function private brutusTargetService( entity ) {
    if ( IS_TRUE( entity.ignoreall ) ) {
		return false;
	}

	if(isdefined(entity.priority_item)) {
		origin = entity.priority_item.origin;
		// Change the origin if its a blocker
		/*if(entity.interactiontype == "blocker") {
			end = struct::get(entity.priority_item.target, "targetname");
			origin = end.origin;
			if(!(entity FindPath(entity.origin, origin))) {
				query_result = PositionQuery_Source_Navigation(origin, 0, 100, 50, 16 );
				bestone = undefined;
				if ( query_result.data.size )
				{
					a_s_locs = array::randomize( query_result.data );
					if ( isdefined( a_s_locs ) )
					{
						i = 0;
						foreach( s_loc in a_s_locs )
						{
							if ( zm_utility::check_point_in_playable_area( s_loc.origin ) && entity FindPath(entity.origin, s_loc.origin) )
							{
								zone = zm_zonemgr::get_zone_from_position(entity.origin + (0,0,30), true);
								zoneStruct = zm_zonemgr::get_zone_from_position(s_loc.origin + (0,0,30), true);
								if(zone != zoneStruct) {
									continue;
								}
								if(!isdefined(bestone) || Distance(bestone.origin, origin) > Distance(s_loc.origin, origin)) {
									bestone = s_loc;
								}
							}
						}
					}
				}
			}
			if(isdefined(bestone)) {
				origin = bestone.origin;
			}
		}*/
		targetPos = GetClosestPointOnNavMesh( origin, BRUTUS_NAVMESH_RADIUS, BRUTUS_NAVMESH_BOUNDARY_DIST );
		if(targetPos && entity FindPath(entity.origin, targetPos)) {
			entity.goal_pos = targetPos;
			entity SetGoal( targetPos );		
			return true;
		}
		else {
			entity.priority_item = undefined;
		}
	}

    entity.ignore_player = [];
	players = GetPlayers();
	
	foreach ( player in players ) {
		if ( player IsNoTarget() ||
			player.ignoreme || 
			player laststand::player_is_in_laststand() || 
			(isdefined(player.afterlife) && player.afterlife) )
		{
			
			entity.ignore_player[ entity.ignore_player.size ] = player;
		}
	}

    player = undefined;

    if ( isdefined( entity.brutusClosestValidPlayer ) )
	{
		player = [[ entity.brutusClosestValidPlayer ]]( entity.origin, entity.ignore_player );
	}
	else
	{
		player = zombie_utility::get_closest_valid_player( entity.origin, entity.ignore_player );
	}

	//IPrintLnBold("Going after player " + player.name);
    entity.favoriteenemy = player;

    if( !isdefined( player ) || player IsNoTarget() )
	{
		if( isdefined( entity.ignore_player ) )
		{
			if( isdefined(level._should_skip_ignore_player_logic) && [[level._should_skip_ignore_player_logic]]() )
			{
				return;
			}
			entity.ignore_player = [];
		}
		//IPrintLnBold("Cant find player, targeting myself");
		entity.goal_pos = entity.origin;
		entity SetGoal( entity.origin );		
		return false;
	}
    else
	{
		targetPos = GetClosestPointOnNavMesh( player.origin, BRUTUS_NAVMESH_RADIUS, BRUTUS_NAVMESH_BOUNDARY_DIST );
		if ( isdefined( targetPos ) )
		{
			if(!entity FindPath(entity.origin, targetPos)) {
				//IPrintLnBold("Got player, cant find path");
			}
			entity.goal_pos = targetPos;
			entity SetGoal( targetPos );		
			return true;
		}
		else
		{
			//IPrintLnBold("Cant find valid point on navmesh, targeting myself");
			entity.goal_pos = entity.origin;
			entity SetGoal( entity.origin );
			return false;
		}
	}
}

function private brutusPriorityItemService( entity ) {
	//IPrintLnBold("GOing for priority item");
	brutus_zone = zm_zonemgr::get_zone_from_position( entity.origin );
	if(!isdefined(brutus_zone))
		return false;

	//IPrintLnBold("In zone: " + brutus_zone);

	if(isdefined(entity.priority_item))
		return;

	player_zone = undefined;
	if(isdefined(entity.favoriteenemy)) {
		player_zone = entity.favoriteenemy zm_zonemgr::get_player_zone();
	}
	if(player_zone) {
		entity.priority_item = entity BrutusServerUtils::brutusGetPriorityItem(player_zone);
	}
	else {
		entity.priority_item = entity BrutusServerUtils::brutusGetPriorityItem(brutus_zone);
	}
}

//----------------------------------------------------------------------------------------------------------------------------------
// CONDITIONS
//----------------------------------------------------------------------------------------------------------------------------------
function brutusShouldMelee( entity ) {
    if( !isdefined( entity.favoriteenemy ) )
		return false;

	/*if(isdefined(entity.priority_item) && !entity FindPath(entity.origin, entity.priority_item.origin))
		return false;*/

	if( DistanceSquared( entity.origin, entity.favoriteenemy.origin ) > BRUTUS_MELEE_DIST_SQ )
		return false;
	
	if ( entity.favoriteenemy IsNoTarget() )
		return false;

	yaw = abs( zombie_utility::getYawToEnemy() );
	if( ( yaw > BRUTUS_MELEE_YAW ) )
		return false;
	
	if ( entity.favoriteenemy laststand::player_is_in_laststand() )
		return false;

	if ( IS_TRUE(entity.favoriteenemy.afterlife) )
		return false;

	return true;
}

function private brutusShouldLockDown( entity ) {
	if( !isdefined(entity.priority_item) )
		return false;

	/*if(entity.interactiontype == "blocker") {
		if( DistanceSquared( entity.origin, entity.goal_pos ) > BRUTUS_MELEE_DIST_SQ)
			return false;
	}
	else {*/
	if( DistanceSquared( entity.origin, entity.goal_pos ) > BRUTUS_MELEE_DIST_SQ * 0.5 )
		return false;
	//}

	// if( DistanceSquared( entity.origin, entity.priority_item.origin ) > BRUTUS_MELEE_DIST_SQ * 2 )
	// 	return false;

	// Cant do this or else he will get stuck
	/*yaw = abs( entity zombie_utility::GetYawToSpot(entity.priority_item.origin) );
	if( yaw > BRUTUS_MELEE_YAW ){
		entity LookAtEntity(entity.priority_item);
		return false;
	}*/

	return true;
}

function private brutusShouldDoGasAttack( entity ) {
	if( !entity.has_helmet )
		return false;

	if ( entity.helmet_hits < BRUTUS_HELMET_SHOTS )
		return false;

	return true;
}

//----------------------------------------------------------------------------------------------------------------------------------
// ACTIONS
//----------------------------------------------------------------------------------------------------------------------------------
function private brutusDeath( entity ) {
	entity notify( "death" );
	entity.helmet Delete();
	entity.baton Delete();
	entity BrutusServerUtils::brutus_turn_off_spotlight( true );
}

function private brutusLockDown( entity ) {
	interaction = level.interaction_types[ entity.interactiontype ];
	entity thread scene::play( interaction.animstate, array( entity ) );
}

function private brutusGasAttack( entity ) {
	entity PlaySound( "zmb_brutus_helmet" );
	entity PlaySound( "zmb_vocals_brutus_enraged" );
	if(isdefined(entity.favoriteenemy)) {
		if ( isdefined( entity.brutusHelmetDestroyedCallback ) ) {
			entity thread [[ entity.brutusHelmetDestroyedCallback ]]( entity, entity.favoriteenemy );
		}
	}
	entity BrutusServerUtils::brutusRemoveHelmet();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#namespace BrutusServerUtils;

function brutusDamageCallback( inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex ) {
	entity = self;

	if ( isdefined( attacker ) && IsAlive( attacker ) && IsPlayer( attacker ) || level.zombie_vars[ attacker.team ][ "zombie_insta_kill" ] && isdefined( attacker.personal_instakill ) && attacker.personal_instakill ) {
		n_brutus_damage_percent = 1;
		n_brutus_headshot_modifier = 2;
	}
	else {
		n_brutus_damage_percent = BRUTUS_DAMAGE_PERCENT;
		n_brutus_headshot_modifier = 1;
	}

	if ( isdefined( weapon ) && weapon.weapClass == "spread" ) {
		n_brutus_damage_percent *= BRUTUS_SHOTGUN_DAMAGE_MOD;
		n_brutus_headshot_modifier *= BRUTUS_SHOTGUN_DAMAGE_MOD;
	}

	if ( isdefined( weapon ) && weapon.name == "zombie_tomahawk" && isdefined( inflictor ) ) {
		self PlaySound( "wpn_tomahawk_imp_zombie" );
		if ( self.has_helmet ) {
			if ( damage == 1 ) {
				return 0;
			}
			if ( isdefined( inflictor.n_cookedtime ) && inflictor.n_cookedtime >= 2000 ) {
				self.helmet_hits = BRUTUS_HELMET_SHOTS;
			}
			else {
				if ( isdefined( inflictor.n_grenade_charge_power ) && inflictor.n_grenade_charge_power >= 2 ) {
					self.helmet_hits = BRUTUS_HELMET_SHOTS;
				}
				else {
					self.helmet_hits++;
				}
			}
			if ( self.helmet_hits >= BRUTUS_HELMET_SHOTS ) {
				self thread brutusRemoveHelmet();
				multiplier = zm_score::get_points_multiplier( self );
				player_points = multiplier * zm_utility::round_up_score( BRUTUS_POINTS_FOR_HELMET, 5 );
				if ( isdefined( attacker ) && IsPlayer( attacker ) )
				{
					attacker zm_score::add_to_player_score( player_points );
					level notify( "brutus_helmet_removed", attacker );
				}
			}
			return damage * n_brutus_damage_percent;
		}
		else {
			return damage;
		}
	}
	if ( isdefined( mod ) || mod == "MOD_MELEE" && mod == "MOD_IMPACT" ) {
		if ( weapon.name == "zod_riotshield" ) {
			shield_damage = level.zombie_vars[ "riotshield_fling_damage_shield" ];
			inflictor riotshield::player_damage_shield( shield_damage, 0 );
			return 0;
		}
	}
	if ( weapon.name == "lightning_hands" ) {
		entity thread zm_ai_brutus::brutusAfterlifeTeleport();
		return 0;
	}
	if ( zm_utility::is_explosive_damage( mod ) ) {
		entity.explosive_dmg_taken += damage;
		if ( !entity.has_helmet )
			scaler = n_brutus_headshot_modifier;
		else
			scaler = BRUTUS_DAMAGE_PERCENT;
		if ( entity.explosive_dmg_taken >= entity.explosive_dmg_req && isDefined( self.has_helmet ) && self.has_helmet ) {
			entity.helmet_hits = BRUTUS_HELMET_SHOTS;
			multiplier = zm_score::get_points_multiplier( self );
			player_points = multiplier * zm_utility::round_up_score( BRUTUS_POINTS_FOR_HELMET, 5 );
			attacker zm_score::add_to_player_score( player_points );
		}
		return damage * scaler;
	}
	else {
		if ( hitLoc != "head" && hitLoc != "helmet" )
			return damage * n_brutus_damage_percent;
		else
			return Int( self brutusScaleHelmetDamage( attacker, damage, n_brutus_headshot_modifier, n_brutus_damage_percent, dir ) );
	}
}

function brutusScaleHelmetDamage(attacker, damage, headshot_mod, damage_mod, vdir) {
	entity = self;
	
	if ( !entity.has_helmet ) {
		return damage * headshot_mod;
	}
	else {
		entity.helmet_hits++;
		if ( entity.helmet_hits >= BRUTUS_HELMET_SHOTS ) {
			multiplier = zm_score::get_points_multiplier( self );
			player_points = multiplier * zm_utility::round_up_score( BRUTUS_POINTS_FOR_HELMET, 5 );
			if ( isdefined( attacker ) && IsPlayer( attacker ) ) {
				attacker zm_score::add_to_player_score( player_points );
				/*IPrintLnBold("NEW HIDE TAG");
				entity Detach( entity.helmet );
				CreateDynEntAndLaunch( entity.helmet, entity.origin + ( 0, 0, 85 ), entity.angles, entity.origin + ( 0, 0, 85 ), vdir );*/
				level notify( "brutus_helmet_removed", attacker );
			}
		}
		return damage * damage_mod;
	}
}

function brutusAttachHelmet() {
	entity = self;

	entity.helmet = Spawn( "script_model", entity GetTagOrigin(BRUTUS_TAG_HELMET) ); 
	entity.helmet SetModel( BRUTUS_MODEL_HELMET ); 
	entity.helmet.angles = entity GetTagAngles(BRUTUS_TAG_HELMET); 
	entity.helmet EnableLinkTo(); 
	entity.helmet LinkTo( entity, BRUTUS_TAG_HELMET ); 

	entity.baton = Spawn( "script_model", entity GetTagOrigin("j_wrist_ri") ); 
	entity.baton SetModel( "c_zom_cellbreaker_baton" ); 
	entity.baton.angles = entity GetTagAngles("j_wrist_ri"); 
	entity.baton EnableLinkTo(); 
	entity.baton LinkTo( entity, "j_wrist_ri" ); 
}

function brutusRemoveHelmet() {
	entity = self;

	entity.has_helmet = false;
	entity.helmet Unlink(); 
	entity.helmet Launch( (0,0,200), (0,200,200) ); 
	entity PlaySound( "zmb_vocals_brutus_exert" );
	entity clientfield::set( "brutus_helmet_detached", 1 );
}

function brutusSpawnScene( entity ) {
	entity scene::play( "scene_zm_brutus_spawn", array( entity ) );
}

function brutusGetPriorityItem( zone_name, do_secondary_zone_checks=false ) {
	interact_types = level.interaction_types;
	foreach(int_type in level.interaction_priority) {
		best_score = -1;
		best_object = undefined;
		int_struct = interact_types[ int_type ];
		int_objects = self [[ int_struct.get_func ]]( zone_name );
		foreach(object in int_objects) {
			if ( object [[ int_struct.validity_func ]]() ) {
				score = self [[ int_struct.value_func ]]( object );
				if ( score < best_score || best_score < 0 ) {
					best_object = object;
					best_score = score;
				}
			}
		}
		if(isdefined(best_object)) {
			self.interactiontype = int_type;
			//Blackboard::SetBlackBoardAttribute( self, BRUTUS_LOCKDOWN_TYPE, int_struct.animstate );
			return best_object;
		}
	}
	if( do_secondary_zone_checks ) {
		foreach(adj_zone in GetArrayKeys( level.zones[ zone_name ].adjacent_zones )) {
			if(zm_zonemgr::zone_is_enabled( adj_zone )) {
				best_object = self brutusGetPriorityItem( adj_zone );
				if ( isdefined( best_object ) )
				{
					return best_object;
				}
			}
		}
	}
	return undefined;
}	

function brutus_turn_off_spotlight( spotlight_broken ) {
	if( spotlight_broken !== true )
		self clientfield::set( "brutus_spotlight_off", 1 );
	else
		self clientfield::set( "brutus_spotlight_off", 2 );
}