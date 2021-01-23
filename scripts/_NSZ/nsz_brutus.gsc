//
// MIT License
//
// Copyright (c) 2021 JariKCoding, NateSmithZombies
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
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\math_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_magicbox_prison;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_alcatraz_utility;

#insert scripts\shared\aat_zm.gsh;

#using_animtree( "generic" ); 

#namespace brutus; 

#precache( "model", "brutus_helmet" );
#precache( "model", "bo2_brutus_fb_death" );
#precache( "model", "perk_clip" );

#define SPAWN_FX			"_NSZ/Brutus/spawn_fx"
#precache( "fx", SPAWN_FX ); 

#define CHEST_FX			"_NSZ/Brutus/chest_fx"
#precache( "fx", CHEST_FX ); 

#define HELMET_SMOKE			"_NSZ/Brutus/helmet_smoke"
#precache( "fx", HELMET_SMOKE ); 

#define LOCK_FX			"fire/fx_fire_ground_rubble_50x50"
#precache( "fx", LOCK_FX ); 

#define BOX_IDLE_FX			"custom/jerri/al_box/al_box_idle"
#precache( "fx", "custom/jerri/al_box/al_box_idle" ); 
#define BOX_INITIAL_FX			"custom/jerri/al_box/al_box_initial"
#precache( "fx", "custom/jerri/al_box/al_box_initial" ); 

function nsz_iprintlnbold( string )
{
	if( isDefined(level.nsz_debug) && level.nsz_debug )
		iprintlnbold( "^6NSZ Debug:^7 "+string ); 
}

function init()
{
	// ================ Begin: Variables You Can Change if You Like :Begin =====================
	level.brutus_debug = false; 		// Used for testing, if it is true brutus Spawns on round 1
	level.player_debug = false; 		// Used to set players invicible for testing 
	level.max_brutus = 2; 			// The maximum brutuss you want
	level.min_brutus_round = 5; 		//  The minimum rounds to wait until brutus spawns next
	level.max_brutus_round = 7; 		//  The max rounds to wait until brutus spawns next
	level.multiple_brutus_round = 20; 	// If you want multiple brutuss, they will spawn in multiples after this round
	level.brutus_base_health = 5000; 		// How much base health you want brutus to have. This health is multiplied by the round number. It caps at 35000 health
	level.brutus_lock_machines = false; 		// Set to true if you have placed and want Brtutus to lock Perk Machines/PaP
	// ================ End: Variables You Can Change if You Like :End =====================
	level.current_brutuses = 0; 

	thread priority_structs_spawn();

	level flag::init( "brutus_setup_complete" );
	level thread setup_interaction_matrix();
	level.sndbrutusistalking = 0;
	level.brutus_health = 500;
	level.brutus_health_increase = 3000;
	level.brutus_round_count = 0;
	level.brutus_last_spawn_round = 0;
	level.brutus_count = 0;
	level.brutus_max_count = 1;
	level.brutus_damage_percent = 0.1;
	level.brutus_helmet_shots = 5;
	level.brutus_team_points_for_death = 500;
	level.brutus_player_points_for_death = 250;
	level.brutus_points_for_helmet = 250;
	level.brutus_alarm_chance = 100;
	level.brutus_min_alarm_chance = 100;
	level.brutus_alarm_chance_increment = 10;
	level.brutus_max_alarm_chance = 200;
	level.brutus_min_round_fq = 4;
	level.brutus_max_round_fq = 7;
	level.brutus_reset_dist_sq = 262144;
	level.brutus_aggro_dist_sq = 16384;
	level.brutus_aggro_earlyout = 12;
	level.brutus_blocker_pieces_req = 1;
	level.brutus_zombie_per_round = 1;
	level.brutus_players_in_zone_spawn_point_cap = 120;
	level.brutus_teargas_duration = 7;
	level.player_teargas_duration = 2;
	level.brutus_teargas_radius = 64;
	level.num_pulls_since_brutus_spawn = 0;
	level.brutus_min_pulls_between_box_spawns = 4;
	level.brutus_explosive_damage_for_helmet_pop = 1500;
	level.brutus_explosive_damage_increase = 6000;
	level.brutus_failed_paths_to_teleport = 4;
	level.brutus_do_prologue = 1;
	level.brutus_min_spawn_delay = 10;
	level.brutus_max_spawn_delay = 60;
	level.brutus_respawn_after_despawn = 1;
	level.brutus_in_grief = 0;

	

	level.zombie_brutus_locations = struct::get_array( "brutus_spawner_spot", "targetname" );
	foreach(struct in level.zombie_brutus_locations)
	{
		zone = zm_zonemgr::get_zone_from_position(struct.origin + (0,0,30), true);
		struct.zone_name = zone;
	}
	
	thread main(); 
}

function priority_structs_spawn()
{
	level.priority_structs = [];
	struct = Spawn("script_model", (2726,-558,5609.68) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "magic_box";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (3173,-1123,5819.23) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "magic_box";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (-1344,-1606,5607.73) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "magic_box";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (45,-944,5368.19) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "magic_box";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (-712,-4686,4355.48) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "magic_box";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;

	struct = Spawn("script_model", (-72,-4078,4380.14) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "craftable_table";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (3257,-1148,5610.83) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "craftable_table";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (995,-796,5826.22) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "craftable_table";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;

	struct = Spawn("script_model", (-903,-2034,5607.72) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "perk_machine";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (-13,-1484,5389.31) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "perk_machine";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (4268,-1023,5819.19) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "perk_machine";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (812,-870,5825.22) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "perk_machine";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
	struct = Spawn("script_model", (221,-3671,4619.31) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "perk_machine";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;

	struct = Spawn("script_model", (3641,-864,5987) );
	struct.targetname = "priority_struct";
	struct.script_noteworthy = "plane_ramp";
	struct SetModel("tag_origin");
	level.priority_structs[level.priority_structs.size] = struct;
}

function main()
{
	level flag::wait_till( "all_players_connected" ); 
	level thread get_brutus_interest_points();
	level.custom_craftable_validation = &check_craftable_table_valid;
	level.custom_perk_validation = &check_perk_machine_valid;
	level.custom_plane_validation = &check_plane_valid;
	level.nsz_debug = true; 
	level activate_brutus_spawns(); 
	level thread brutus_spawning_logic(); 
	if( level.player_debug )
	{
		foreach( player in getplayers() )
			player EnableInvulnerability(); 
	}
	level flag::wait_till( "initial_blackscreen_passed" );
	//level notify( "spawn_brutus", 1 );
}

function check_craftable_table_valid( player )
{
	if ( !isdefined( self.stub ) && isdefined( self.is_locked ) && self.is_locked )
	{
		if ( player.score >= self.locked_cost )
		{
			player zm_score::minus_to_player_score( self.locked_cost );
			self.is_locked = 0;
			self.locked_cost = undefined;
			self.lock_fx Delete();
		}
		return 0;
	}
	else
	{
		if ( isdefined( self.stub ) && isdefined( self.stub.is_locked ) && self.stub.is_locked )
		{
			if ( player.score >= self.stub.locked_cost )
			{
				player zm_score::minus_to_player_score( self.stub.locked_cost );
				self.stub.is_locked = 0;
				self.stub.locked_cost = undefined;
				self.stub.lock_fx Delete();
				self.stub thread zm_craftables::craftablestub_update_prompt( player );
				self SetHintString( self.stub.hint_string );
			}
			return 0;
		}
	}
	return 1;
}

function check_perk_machine_valid( player )
{
	if ( isdefined( self.is_locked ) && self.is_locked )
	{
		if ( player.score >= self.locked_cost )
		{
			player zm_score::minus_to_player_score( self.locked_cost );
			self.is_locked = 0;
			self.locked_cost = undefined;
			self.lock_fx Delete();
			self zm_perks::reset_vending_hint_string();
		}
		return 0;
	}
	return 1;
}

function check_plane_valid( player )
{
	if ( isdefined( self.fly_trigger_target ) )
	{
		plane_struct = self.fly_trigger_target;
	}
	else
	{
		plane_struct = self;
	}
	if ( isdefined( plane_struct.is_locked ) && plane_struct.is_locked )
	{
		if ( player.score >= plane_struct.locked_cost )
		{
			player zm_score::minus_to_player_score( plane_struct.locked_cost );
			plane_struct.is_locked = 0;
			plane_struct.locked_cost = undefined;
			plane_struct.lock_fx Delete();
			plane_struct zm_alcatraz_sq::reset_plane_hint_string( player );
		}
		return 0;
	}
	return 1;
}

function setup_interaction_matrix()
{
	level.interaction_types = [];
	level.interaction_types[ "magic_box" ] = SpawnStruct();
	level.interaction_types[ "magic_box" ].priority = 0;
	level.interaction_types[ "magic_box" ].animstate = %brutus_lock_box;
	level.interaction_types[ "magic_box" ].notify_name = "box_lock_anim";
	level.interaction_types[ "magic_box" ].action_notetrack = "locked";
	level.interaction_types[ "magic_box" ].end_notetrack = "lock_done";
	level.interaction_types[ "magic_box" ].validity_func = &is_magic_box_valid;
	level.interaction_types[ "magic_box" ].get_func = &get_magic_boxes;
	level.interaction_types[ "magic_box" ].value_func = &get_dist_score;
	level.interaction_types[ "magic_box" ].interact_func = &magic_box_lock;
	level.interaction_types[ "magic_box" ].spawn_bias = 1000;
	level.interaction_types[ "magic_box" ].num_times_to_scale = 1;
	level.interaction_types[ "magic_box" ].unlock_cost = 2000;
	level.interaction_types[ "perk_machine" ] = SpawnStruct();
	level.interaction_types[ "perk_machine" ].priority = 1;
	level.interaction_types[ "perk_machine" ].animstate = %brutus_lock_perk;
	level.interaction_types[ "perk_machine" ].notify_name = "perk_lock_anim";
	level.interaction_types[ "perk_machine" ].action_notetrack = "locked";
	level.interaction_types[ "perk_machine" ].validity_func = &is_perk_machine_valid;
	level.interaction_types[ "perk_machine" ].get_func = &get_perk_machines;
	level.interaction_types[ "perk_machine" ].value_func = &get_dist_score;
	level.interaction_types[ "perk_machine" ].interact_func = &perk_machine_lock;
	level.interaction_types[ "perk_machine" ].spawn_bias = 800;
	level.interaction_types[ "perk_machine" ].num_times_to_scale = 3;
	level.interaction_types[ "perk_machine" ].unlock_cost = 2000;
	level.interaction_types[ "craftable_table" ] = SpawnStruct();
	level.interaction_types[ "craftable_table" ].priority = 2;
	level.interaction_types[ "craftable_table" ].animstate = %brutus_lock_box;
	level.interaction_types[ "craftable_table" ].notify_name = "table_smash_anim";
	level.interaction_types[ "craftable_table" ].action_notetrack = "fire";
	level.interaction_types[ "craftable_table" ].validity_func = &is_craftable_table_valid;
	level.interaction_types[ "craftable_table" ].get_func = &get_craftable_tables;
	level.interaction_types[ "craftable_table" ].value_func = &get_dist_score;
	level.interaction_types[ "craftable_table" ].interact_func = &craftable_table_lock;
	level.interaction_types[ "craftable_table" ].spawn_bias = 600;
	level.interaction_types[ "craftable_table" ].num_times_to_scale = 1;
	level.interaction_types[ "craftable_table" ].unlock_cost = 2000;
	level.interaction_types[ "craftable_table" ].interaction_z_offset = -15;
	level.interaction_types[ "craftable_table" ].interaction_yaw_offset = 270;
	level.interaction_types[ "craftable_table" ].fx_z_offset = -44;
	level.interaction_types[ "craftable_table" ].fx_yaw_offset = 270;
	/*level.interaction_types[ "trap" ] = SpawnStruct();
	level.interaction_types[ "trap" ].priority = 3;
	level.interaction_types[ "trap" ].animstate = %brutus_lock_box;
	level.interaction_types[ "trap" ].notify_name = "trap_smash_anim";
	level.interaction_types[ "trap" ].action_notetrack = "fire";
	level.interaction_types[ "trap" ].validity_func = &is_trap_valid;
	level.interaction_types[ "trap" ].get_func = &get_traps;
	level.interaction_types[ "trap" ].value_func = &get_dist_score;
	level.interaction_types[ "trap" ].interact_func = &trap_smash;
	level.interaction_types[ "trap" ].spawn_bias = 400;
	level.interaction_types[ "trap" ].interaction_z_offset = -15;*/
	level.interaction_types[ "plane_ramp" ] = SpawnStruct();
	level.interaction_types[ "plane_ramp" ].priority = 4;
	level.interaction_types[ "plane_ramp" ].animstate = %brutus_lock_box;
	level.interaction_types[ "plane_ramp" ].notify_name = "plane_lock_anim";
	level.interaction_types[ "plane_ramp" ].action_notetrack = "locked";
	level.interaction_types[ "plane_ramp" ].end_notetrack = "lock_done";
	level.interaction_types[ "plane_ramp" ].validity_func = &is_plane_ramp_valid;
	level.interaction_types[ "plane_ramp" ].get_func = &get_plane_ramps;
	level.interaction_types[ "plane_ramp" ].value_func = &get_dist_score;
	level.interaction_types[ "plane_ramp" ].interact_func = &plane_ramp_lock;
	level.interaction_types[ "plane_ramp" ].spawn_bias = 500;
	level.interaction_types[ "plane_ramp" ].num_times_to_scale = 3;
	level.interaction_types[ "plane_ramp" ].unlock_cost = 2000;
	level.interaction_types[ "plane_ramp" ].interaction_z_offset = -60;
	level.interaction_types[ "plane_ramp" ].fx_z_offset = -60;
	level.interaction_types[ "plane_ramp" ].fx_x_offset = 70;
	level.interaction_types[ "plane_ramp" ].fx_yaw_offset = 90;
	/*level.interaction_types[ "blocker" ] = SpawnStruct();
	level.interaction_types[ "blocker" ].priority = 5;
	level.interaction_types[ "blocker" ].animstate = %brutus_lock_box;
	level.interaction_types[ "blocker" ].notify_name = "board_smash_anim";
	level.interaction_types[ "blocker" ].action_notetrack = "fire";
	level.interaction_types[ "blocker" ].validity_func = &is_blocker_valid;
	level.interaction_types[ "blocker" ].get_func = &get_blockers;
	level.interaction_types[ "blocker" ].value_func = &get_dist_score;
	level.interaction_types[ "blocker" ].interact_func = &blocker_smash;
	level.interaction_types[ "blocker" ].spawn_bias = 50;*/
	level.interaction_priority = [];
	interaction_types = GetArrayKeys( level.interaction_types );
	i = 0;
	while ( i < interaction_types.size )
	{
		int_type = interaction_types[ i ];
		interaction = level.interaction_types[ int_type ];
/#
		assert( !isdefined( level.interaction_priority[ interaction.priority ] ) );
#/
		level.interaction_priority[ interaction.priority ] = int_type;
		i++;
	}
/#
	i = 0;
	while ( i < interaction_types.size )
	{
		assert( isdefined( level.interaction_priority[ i ] ) );
		i++;
	}
#/
}

function brutus_spawning_logic()
{
	level.brutus_spawners = GetEntArray( "zombie_brutus", "script_noteworthy" ); 
	if ( !level.brutus_in_grief )
	{
		level thread enable_brutus_rounds();
	}
	if ( isdefined( level.chests ) )
	{
		i = 0;
		while ( i < level.chests.size )
		{
			level.chests[ i ] thread wait_on_box_alarm();
			i++;
		}
	}
	while ( 1 )
	{
		level waittill( "spawn_brutus", num );
		i = 0;
		if(!isdefined(num))
		{
			num = 1;
		}
		while ( i < num )
		{
			ai = zombie_utility::spawn_zombie( level.brutus_spawners[ 0 ] );
			ai thread brutus_spawn();
			i++;
		}
		if ( isdefined( ai ) )
		{
			ai PlaySound( "brutus_prespawn" );
		}
	}
}

function enable_brutus_rounds()
{
	level.brutus_rounds_enabled = 1;
	level flag::init( "brutus_round" );
	level thread brutus_round_tracker();
}

function brutus_round_tracker()
{
	level.next_brutus_round = RandomIntRange( level.brutus_min_round_fq, level.brutus_max_round_fq );
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while ( 1 )
	{
		level waittill( "between_round_over" );
		players = GetPlayers();
		if ( level.round_number < 9 && isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
		{
			//IPrintLnBold("SOlo game");
		}
		else if ( level.next_brutus_round <= level.round_number )
		{
			if ( zm_alcatraz_utility::is_team_on_golden_gate_bridge() )
			{
				level.next_brutus_round = level.round_number + 1;
			}
			wait RandomFloatRange( level.brutus_min_spawn_delay, level.brutus_max_spawn_delay );
			if ( attempt_brutus_spawn( level.brutus_zombie_per_round ) )
			{
				level.music_round_override = 1;
				//level thread zm_audio::change_zombie_music( "brutus_round_start" );
				level thread sndforcewait();
				if(!zm_alcatraz_utility::is_team_on_golden_gate_bridge())
					level.next_brutus_round = level.round_number + RandomIntRange( level.brutus_min_round_fq, level.brutus_max_round_fq );
			}
		}
	}
}

function sndforcewait()
{
	wait 10;
	level.music_round_override = 0;
}

function wait_on_box_alarm()
{
	while ( 1 )
	{
		self.zbarrier waittill( "randomization_done" );
		level.num_pulls_since_brutus_spawn++;
		if ( level.brutus_in_grief )
		{
			level.brutus_min_pulls_between_box_spawns = RandomIntRange( 7, 10 );
		}
		if ( level.num_pulls_since_brutus_spawn >= level.brutus_min_pulls_between_box_spawns )
		{
			rand = RandomInt( 1000 );
			if ( level.brutus_in_grief )
			{
				level notify( "spawn_brutus" );
				break;
			}
			else if ( rand <= level.brutus_alarm_chance )
			{
				if ( level flag::get( "moving_chest_now" ) )
				{
					continue;
				}
				if ( attempt_brutus_spawn( 1 ) )
				{
					if ( level.next_brutus_round == ( level.round_number + 1 ) )
					{
						level.next_brutus_round++;
					}
					level.brutus_alarm_chance = level.brutus_min_alarm_chance;
				}
				break;
			}
			else
			{
				if ( level.brutus_alarm_chance < level.brutus_max_alarm_chance )
				{
					level.brutus_alarm_chance += level.brutus_alarm_chance_increment;
				}
			}
		}
	}
}

function attempt_brutus_spawn( n_spawn_num )
{
	if ( ( level.brutus_count + n_spawn_num ) > level.brutus_max_count )
	{
/#
		iprintln( "Brutus max count reached - Preventing Brutus from spawning!" );
#/
		return 0;
	}
	level notify( "spawn_brutus" );
	return 1;
}

function activate_brutus_spawns()
{
	level.brutus_spawn_points = []; 

	structs = struct::get_array( "brutus_spawner_spot", "targetname" ); 
	foreach( point in structs )
		point thread wait_for_activation(); 
}

function wait_for_activation()
{
	if( self.script_string == "start_zone" )
		level.brutus_spawn_points[ level.brutus_spawn_points.size ] = self; 
	else
	{
		flag = self.script_string; 
		level flag::wait_till( flag ); 
		level.brutus_spawn_points[ level.brutus_spawn_points.size ] = self; 
	}
}

function brutus_spawn( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name)
{
	level.brutus_count++; 
	level.num_pulls_since_brutus_spawn = 0;
	spawner = GetEnt( "zombie_brutus", "script_noteworthy" ); 
	//wait( RandomIntRange( 5, 20 ) );
	wait 1;
	self attach_light(); 
	self thread zombie_spawn_init();
	self thread boss_footsteps(); 
	self thread melee_track(); 
	self thread note_tracker(); 
	self thread aat_override(); 
	self thread zombie_utility::round_spawn_failsafe();
	if ( !isdefined( has_helmet ) )
	{
		self.has_helmet = 1;
	}
	else
	{
		self.has_helmet = has_helmet;
	}
	if ( !isdefined( helmet_hits ) )
	{
		self.helmet_hits = 0;
	}
	else
	{
		self.helmet_hits = helmet_hits;
	}
	if ( !isdefined( explosive_dmg_taken ) )
	{
		self.explosive_dmg_taken = 0;
	}
	else
	{
		self.explosive_dmg_taken = explosive_dmg_taken;
	}
	if ( !isdefined( starting_health ) )
	{
		self brutus_health_increases();
		self.maxhealth = level.brutus_health;
		self.health = level.brutus_health;
	}
	else
	{
		self.maxhealth = starting_health;
		self.health = starting_health;
	}
	//IPrintLnBold("Health: "+ self.health);
	self.explosive_dmg_req = level.brutus_expl_dmg_req;
	self.actor_damage_func = &brutus_damage_override;
	self.non_attacker_func = &brutus_non_attacker_damage_override;
	self.deathanim = %brutus_death; 
	self BloodImpact( "normal" ); 
	self.no_damage_points = true; 
	self.allowpain = false; 
	self.ignoreall = true; 
	self.ignoreme = true; 
	self.ignore_all_poi = 1;
	self.is_brutus = 1;
	self.melee_anim_func = &melee_anim_func;
	self.meleedamage = 99;
	self.allowmelee = true; 
	self.needs_run_update = true; 
	self.no_powerups = true; 
	self.canattack = false; 
	self.goalRadius = 32; 
	self.is_on_fire = true; 
	self.gibbed = true; 
	self.variant_type = 0; 
	self.zombie_move_speed = "sprint"; 
	self.zombie_arms_position = "down"; 
	self.ignore_nuke = true; 
	self.instakill_func = &anti_instakill; 
	self.ignore_enemy_count = true; 
	self PushActors( true );
	self.lightning_chain_immune = true; 
	self.tesla_damage_func = &anti_instakill; 
	if ( isdefined( zone_name ) && zone_name == "bridge_zone" )
	{
		wait RandomFloat( 1.5 );
		spawn_pos = self get_random_brutus_spawn_pos( zone_name );
	}
	else
	{
		spawn_pos = self get_best_brutus_spawn_pos( zone_name );
	}
	if ( isdefined( level.brutus_do_prologue ) && level.brutus_do_prologue )
	{
		self brutus_spawn_prologue( spawn_pos );
	}
	if ( self.has_helmet )
	{
		//self Detach( self.helmet );
		self attach_helmet(); 
	}
	self thread brutus_death();

	self zm_spawner::zombie_complete_emerging_into_playable_area();
	self zm_spawner::zombie_setup_attack_properties();
	self SetFreeCameraLockOnAllowed( 0 );
	level thread zm_spawner::zombie_death_event( self );
	self thread zm_spawner::enemy_death_detection();

	if ( !isdefined( spawn_pos ) )
	{
/#
		println( "ERROR: Tried to spawn brutus with no brutus spawn_positions!\n" );
		iprintln( "ERROR: Tried to spawn brutus with no brutus spawn_positions!" );
#/
		self Delete();
		return;
	} 
	self ForceTeleport( spawn_pos.origin, spawn_pos.angles, 1 ); 
	self.not_interruptable = 1;
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_spawn ); 
	PlayFx( SPAWN_FX, self.origin ); 
	Earthquake( 0.4, 4, self.origin, 5000 ); 
	wait( GetAnimLength( %brutus_spawn ) );
	self.not_interruptable = 0; 

	self thread brutus_find_flesh(); 
	level notify( "brutus_spawned" );
}

function melee_anim_func()
{
	self.next_leap_time = GetTime() + 1500;
}

function brutus_spawn_prologue( spawn_pos )
{
	PlaySoundAtPosition( "zmb_ai_brutus_prespawn", spawn_pos.origin );
	wait 3;
}


function get_random_brutus_spawn_pos( zone_name )
{
	zone_spawn_pos = [];
	i = 0;
	while ( i < level.zombie_brutus_locations.size )
	{
		name = zm_zonemgr::get_zone_from_position(level.zombie_brutus_locations[ i ].origin + (0,0,30), true);
		if ( isdefined( zone_name ) && name != zone_name )
		{
			i++;
			continue;
		}
		else
		{
			zone_spawn_pos[ zone_spawn_pos.size ] = i;
		}
		i++;
	}
	if ( zone_spawn_pos.size > 0 )
	{
		pos_idx = RandomInt( zone_spawn_pos.size );
		return level.zombie_brutus_locations[ zone_spawn_pos[ pos_idx ] ];
	}
	return undefined;
}

function brutus_death()
{
	self endon( "brutus_cleanup" );
	self thread brutus_cleanup();
	self waittill( "death" );
	self thread sndbrutusvox( "vox_brutus_brutus_defeated" );
	//level thread zm_audio::sndmusicstingerevent( "brutus_death" );
	level.brutus_count--;

	PlayFX( level._effect[ "brutus_death" ], self.origin );
	PlaySoundAtPosition( "zmb_ai_brutus_death", self.origin );
	if ( zombie_utility::get_current_zombie_count() == 0 && level.zombie_total == 0 )
	{
		level.last_brutus_origin = self.origin;
		level notify( "last_brutus_down" );
		if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
		{
			level.next_brutus_round = level.round_number + 1;
		}
	}
	else
	{
		if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
		{
			level.zombie_total++;
			level.zombie_total_subtract++;
			level thread brutus_round_spawn_failsafe_respawn();
		}
	}
	if ( isdefined( self.suppress_brutus_powerup_drop ) && !self.suppress_brutus_powerup_drop )
	{
		if ( isdefined( level.global_brutus_powerup_prevention ) && !level.global_brutus_powerup_prevention )
		{
			if ( self zm_zonemgr::entity_in_zone( "zone_golden_gate_bridge" ) )
			{
				level.global_brutus_powerup_prevention = 1;
			}
			if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
			{
				level.powerup_drop_count = level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] - 1;
			}
			level.zombie_vars[ "zombie_drop_item" ] = 1;
			level thread zm_powerups::powerup_drop( self.origin );
		}
	}
	if ( IsPlayer( self.attacker ) )
	{
		event = "death";
		if ( IsSubStr( self.damageweapon, "knife_ballistic_" ) )
		{
			event = "ballistic_knife_death";
		}
		self.attacker thread zm_utility::do_player_general_vox( "general", "brutus_killed", 20, 20 );
		if ( level.brutus_in_grief )
		{
			team_points = level.brutus_team_points_for_death;
			player_points = level.brutus_player_points_for_death;
			a_players = GetPlayers( self.team );
		}
		else
		{
			multiplier = zm_score::get_points_multiplier( self );
			team_points = multiplier * zm_utility::round_up_score( level.brutus_team_points_for_death, 5 );
			player_points = multiplier * zm_utility::round_up_score( level.brutus_player_points_for_death, 5 );
			a_players = GetPlayers();
		}
		_a922 = a_players;
		_k922 = GetFirstArrayKey( _a922 );
		while ( isdefined( _k922 ) )
		{
			player = _a922[ _k922 ];
			if ( !zm_utility::is_player_valid( player ) )
			{
			}
			else
			{
				player zm_score::add_to_player_score( team_points );
				if ( player == self.attacker )
				{
					player zm_score::add_to_player_score( player_points );
					level notify( "brutus_killed" );
				}
				player.pers[ "score" ] = player.score;
			}
			_k922 = GetNextArrayKey( _a922, _k922 );
		}
	}
	self notify( "brutus_cleanup" );
}

function brutus_cleanup()
{
	self waittill( "brutus_cleanup" );
	level.sndbrutusistalking = 0;
	if ( isdefined( self.sndbrutusmusicent ) )
	{
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
}

function brutus_round_spawn_failsafe_respawn()
{
	while ( 1 )
	{
		wait 2;
		if ( attempt_brutus_spawn( 1 ) )
		{
			return;
		}
		else
		{
		}
	}
}

function sndbrutusvox( alias, num )
{
	self endon( "brutus_cleanup" );
	if ( !isdefined( alias ) )
	{
		return;
	}
	num_variants = zm_spawner::get_number_variants( alias );
	if ( num_variants <= 0 )
	{
		return;
	}
	if ( isdefined( num ) && num <= num_variants )
	{
		num_variants = num;
	}
	if ( !level.sndbrutusistalking )
	{
		level.sndbrutusistalking = 1;
		alias = ( alias + "_" ) + RandomIntRange( 0, num_variants );
		playbacktime = SoundGetPlaybackTime( alias );
		if ( playbacktime >= 0 )
		{
			playbacktime *= 0.001;
		}
		else
		{
			playbacktime = 1;
		}
		self PlaySoundOnTag( alias, "J_head" );
		wait playbacktime;
		level.sndbrutusistalking = 0;
	}
}

function get_best_brutus_spawn_pos( zone_name )
{
	val = 0;
	i = 0;
	while ( i < level.zombie_brutus_locations.size )
	{
		name = zm_zonemgr::get_zone_from_position(level.zombie_brutus_locations[ i ].origin + (0,0,30) , true);
		if ( isdefined( zone_name ) && name != zone_name )
		{
			i++;
			continue;
		}
		else
		{
			newval = self get_brutus_spawn_pos_val( level.zombie_brutus_locations[ i ] );
			if ( newval > val )
			{
				val = newval;
				pos_idx = i;
			}
		}
		i++;
	}
	if ( isdefined( pos_idx ) )
	{
		return level.zombie_brutus_locations[ pos_idx ];
	}
	else
	{
		return undefined;
	}
}

function get_brutus_spawn_pos_val( brutus_pos )
{
	score = 0;
	//zone_name = brutus_pos.script_string;
	zone_name = zm_zonemgr::get_zone_from_position(brutus_pos.origin + (0,0,30), true);
	if ( !zm_zonemgr::zone_is_enabled( zone_name ) )
	{
		return 0;
	}
	a_players_in_zone = zm_zonemgr::get_players_in_zone( zone_name, 1 );
	if ( a_players_in_zone.size == 0 )
	{
		return 0;
	}
	else
	{
		n_score_addition = 1;
		i = 0;
		while ( i < a_players_in_zone.size )
		{
			if ( self FindPath( brutus_pos.origin, a_players_in_zone[ i ].origin ) )
			{
				n_dist = Distance2D( brutus_pos.origin, a_players_in_zone[ i ].origin );
				n_score_addition += math::linear_map( n_dist, 2000, 0, 0, level.brutus_players_in_zone_spawn_point_cap );
			}
			i++;
		}
		if ( n_score_addition > level.brutus_players_in_zone_spawn_point_cap )
		{
			n_score_addition = level.brutus_players_in_zone_spawn_point_cap;
		}
		score += n_score_addition;
	}
	if ( !level.brutus_in_grief )
	{
		interaction_types = GetArrayKeys( level.interaction_types );
		interact_array = level.interaction_types;
		i = 0;
		while ( i < interaction_types.size )
		{
			int_type = interaction_types[ i ];
			interaction = interact_array[ int_type ];
			interact_points = [[ interaction.get_func ]]( zone_name );
			j = 0;
			while ( j < interact_points.size )
			{
				if ( interact_points[ j ] [[ interaction.validity_func ]]() )
				{
					score += interaction.spawn_bias;
				}
				j++;
			}
			i++;
		}
	}
	return score;
}

function brutus_non_attacker_damage_override( damage, weapon )
{
	scaled_dmg = 0;
	if ( weapon.name == "tower_trap" )
	{
		scaled_dmg = self scale_helmet_damage( undefined, damage, 0.1, 0.01, vectorScale( ( 0, 0, 0 ), 10 ) );
	}
	return Int( scaled_dmg );
}

function brutus_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, poffsettime, boneindex )
{
	if ( isdefined( attacker ) && IsAlive( attacker ) && IsPlayer( attacker ) || level.zombie_vars[ attacker.team ][ "zombie_insta_kill" ] && isdefined( attacker.personal_instakill ) && attacker.personal_instakill )
	{
		n_brutus_damage_percent = 1;
		n_brutus_headshot_modifier = 2;
	}
	else
	{
		n_brutus_damage_percent = level.brutus_damage_percent;
		n_brutus_headshot_modifier = 1;
	}
	if ( isdefined( weapon ) && is_weapon_shotgun( weapon ) )
	{
		n_brutus_damage_percent *= level.brutus_shotgun_damage_mod;
		n_brutus_headshot_modifier *= level.brutus_shotgun_damage_mod;
	}
	if ( isdefined( weapon.name ) && weapon.name == "zombie_tomahawk" && isdefined( inflictor ) )
	{
		self PlaySound( "wpn_tomahawk_imp_zombie" );
		if ( self.has_helmet )
		{
			if ( damage == 1 )
			{
				return 0;
			}
			if ( isdefined( inflictor.n_cookedtime ) && inflictor.n_cookedtime >= 2000 )
			{
				self.helmet_hits = level.brutus_helmet_shots;
			}
			else
			{
				if ( isdefined( inflictor.n_grenade_charge_power ) && inflictor.n_grenade_charge_power >= 2 )
				{
					self.helmet_hits = level.brutus_helmet_shots;
				}
				else
				{
					self.helmet_hits++;
				}
			}
			if ( self.helmet_hits >= level.brutus_helmet_shots )
			{
				self thread brutus_remove_helmet( vdir );
				if ( level.brutus_in_grief )
				{
					player_points = level.brutus_points_for_helmet;
				}
				else
				{
					multiplier = zm_score::get_points_multiplier( self );
					player_points = multiplier * zm_utility::round_up_score( level.brutus_points_for_helmet, 5 );
				}
				if ( isdefined( attacker ) && IsPlayer( attacker ) )
				{
					attacker zm_score::add_to_player_score( player_points );
					attacker.pers[ "score" ] = attacker.score;
					level notify( "brutus_helmet_removed" );
				}
			}
			return damage * n_brutus_damage_percent;
		}
		else
		{
			return damage;
		}
	}
	if ( isdefined( meansofdeath ) || meansofdeath == "MOD_MELEE" && meansofdeath == "MOD_IMPACT" )
	{
		if ( weapon.name == "alcatraz_shield" )
		{
			shield_damage = level.zombie_vars[ "riotshield_fling_damage_shield" ];
			//inflictor zm_weap_riotshield_prison::player_damage_shield( shield_damage, 0 );
			return 0;
		}
	}
	if ( isdefined( level.zombiemode_using_afterlife ) && level.zombiemode_using_afterlife && weapon.name == "lightning_hands" )
	{
		self thread brutus_afterlife_teleport();
		return 0;
	}
	if ( zm_utility::is_explosive_damage( meansofdeath ) )
	{
		self.explosive_dmg_taken += damage;
		if ( !self.has_helmet )
		{
			scaler = n_brutus_headshot_modifier;
		}
		else
		{
			scaler = level.brutus_damage_percent;
		}
		if ( self.explosive_dmg_taken >= self.explosive_dmg_req && isdefined( self.has_helmet ) && self.has_helmet )
		{
			self thread brutus_remove_helmet( vectorScale( ( 0, 0, 0 ), 10 ) );
			if ( level.brutus_in_grief )
			{
				player_points = level.brutus_points_for_helmet;
			}
			else
			{
				multiplier = zm_score::get_points_multiplier( self );
				player_points = multiplier * zm_utility::round_up_score( level.brutus_points_for_helmet, 5 );
			}
			attacker zm_score::add_to_player_score( player_points );
			attacker.pers[ "score" ] = inflictor.score;
		}
		return damage * 0.1;
	}
	else
	{
		if ( shitloc != "head" && shitloc != "helmet" )
		{
			return damage * n_brutus_damage_percent;
		}
		else
		{
			return Int( self scale_helmet_damage( attacker, damage, n_brutus_headshot_modifier, n_brutus_damage_percent, vdir ) );
		}
	}
}

function is_weapon_shotgun( sweapon )
{
	if ( sweapon.weapClass == "spread" )
	{
		return 1;
	}
	return 0;
}

function scale_helmet_damage( attacker, damage, headshot_mod, damage_mod, vdir )
{
	if ( !self.has_helmet )
	{
		return damage * headshot_mod;
	}
	else
	{
		self.helmet_hits++;
		if ( self.helmet_hits >= level.brutus_helmet_shots )
		{
			self thread brutus_remove_helmet( vdir );
			if ( level.brutus_in_grief )
			{
				player_points = level.brutus_points_for_helmet;
			}
			else
			{
				multiplier = zm_score::get_points_multiplier( self );
				player_points = multiplier * zm_utility::round_up_score( level.brutus_points_for_helmet, 5 );
			}
			if ( isdefined( attacker ) && IsPlayer( attacker ) )
			{
				attacker zm_score::add_to_player_score( player_points );
				attacker.pers[ "score" ] = attacker.score;
				level notify( "brutus_helmet_removed" );
			}
		}
		return damage * damage_mod;
	}
}

function brutus_remove_helmet( vdir )
{
	self.has_helmet = 0;
	self Detach( self.helmet );
	self PlaySound( "evt_brutus_helmet" );
	launch_pos = self.origin + vectorScale( ( 0, 0, 0 ), 85 );
	CreateDynEntAndLaunch( self.helmet, launch_pos, self.angles, launch_pos, vdir );
	if ( isdefined( self.suppress_teargas_behavior ) && !self.suppress_teargas_behavior )
	{
		self thread brutus_fire_teargas_when_possible();
		if ( isdefined( self.not_interruptable ) && self.not_interruptable )
		{
			return;
		}
		self.not_interruptable = 1;
		self PlaySound( "vox_brutus_exert" );
		self AnimScripted( "note_notify", self.origin, self.angles, %brutus_headpain, undefined, undefined, undefined, .1 ); 
		wait(GetAnimLength(%brutus_headpain));
		self AnimScripted( "note_notify", self.origin, self.angles, %brutus_enrage, undefined, undefined, undefined, .1 ); 
		wait(GetAnimLength(%brutus_enrage));
		//self AnimScripted( self.origin, self.angles, "zm_pain" );
		//self maps/mp/animscripts/zm_shared::donotetracks( "pain_anim" );
		self.not_interruptable = 0;
	}
}

function brutus_fire_teargas_when_possible()
{
	self endon( "death" );
	wait 0.2;
	while ( isdefined( self.not_interruptable ) && self.not_interruptable )
	{
		wait 0.05;
	}
	self.not_interruptable = 1;
	self PlaySound( "vox_brutus_enraged" );
	//self AnimScripted( self.origin, self.angles, "zm_teargas_attack" );
	//self thread maps/mp/animscripts/zm_shared::donotetracks( "teargas_anim" );
	//self waittillmatch( "teargas_anim" );
	//return "grenade_drop";
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_gasattack, undefined, undefined, undefined, .1 ); 
	wait(GetAnimLength(%brutus_gasattack));
	v_org_left = self GetTagOrigin( "TAG_WEAPON_LEFT" );
	v_org_right = self GetTagOrigin( "TAG_WEAPON_RIGHT" );
	self thread sndplaydelayedsmokeaudio( v_org_left, v_org_right );
	self MagicGrenadeType( GetWeapon("willy_pete"), v_org_left, ( 0, 0, 0 ), 0.4 );
	self MagicGrenadeType( GetWeapon("willy_pete"), v_org_right, ( 0, 0, 0 ), 0.4 );
	//self waittillmatch( "teargas_anim" );
	//return "end";
	self.not_interruptable = 0;
}

function sndplaydelayedsmokeaudio( org1, org2 )
{
	wait 1.5;
	PlaySoundAtPosition( "zmb_ai_brutus_gas_explode", org1 );
	wait 0.25;
	PlaySoundAtPosition( "zmb_ai_brutus_gas_explode", org2 );
}

function brutus_afterlife_teleport()
{
	PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
	self Hide();
	wait 0.1;
	self notify( "brutus_cleanup" );
	if ( isdefined( self.sndbrutusmusicent ) )
	{
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
	level thread respawn_brutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone );
	level.brutus_count--;
	self.helmet Delete();
	self Delete();
}

function brutus_health_increases()
{
	if ( level.round_number > level.brutus_last_spawn_round )
	{
		a_players = GetPlayers();
		n_player_modifier = 1;
		if ( a_players.size > 1 )
		{
			n_player_modifier = a_players.size * 0.75;
		}
		level.brutus_round_count++;
		level.brutus_health = Int( level.brutus_health_increase * n_player_modifier * level.brutus_round_count );
		level.brutus_expl_dmg_req = Int( level.brutus_explosive_damage_increase * n_player_modifier * level.brutus_round_count );
		if ( level.brutus_health >= ( 5000 * n_player_modifier ) )
		{
			level.brutus_health = Int( 5000 * n_player_modifier );
		}
		if ( level.brutus_expl_dmg_req >= ( 4500 * n_player_modifier ) )
		{
			level.brutus_expl_dmg_req = Int( 4500 * n_player_modifier );
		}
		level.brutus_last_spawn_round = level.round_number;
	}
}

function attach_light()
{
	fire_angles = self.angles; 
	fire_angles_forward = AnglesToForward( fire_angles );
	fire_init = self.origin+(0,0,57);
	impact = fire_init + vectorScale( fire_angles_forward, 9 );
	light = Spawn( "script_model", impact ); 
	light SetModel( "tag_origin" ); 
	light.angles = self.angles; 
	light EnableLinkTo(); 
	light LinkTo( self, "j_spineupper" ); 
	PlayFXOnTag( CHEST_FX, light, "tag_origin" ); 
	
	self.light = light; 
}
function aat_override()
{
	while( isDefined(self) )
	{
		self.aat_cooldown_start[ZM_AAT_BLAST_FURNACE_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_DEAD_WIRE_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_FIRE_WORKS_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_THUNDER_WALL_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_TURNED_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		wait(0.05); 
	}
}

function debug_health()
{
	while(1)
	{
		self.health = 100000; 
		wait(0.05); 
	}
}

function custom_find_flesh()
{
	self endon( "death" ); 
	self endon( "locking_target" ); 

	while(1)
	{
		if( isDefined(self.brutus_enemy) && zm_utility::is_player_valid(self.brutus_enemy) && isDefined(self.brutus_enemy.brutus_track_countdown) && self.brutus_enemy.brutus_track_countdown > 0 )
		{
			self.brutus_enemy.brutus_track_countdown -= 0.05;
			self.v_zombie_custom_goal_pos = self.brutus_enemy.origin; 
		}
		else
		{
			nsz_iprintlnbold( "^3Aquiring New Brutus Target" ); 
			players = GetPlayers(); 
			targets = array::get_all_closest( self.origin, players ); 
			
			for( i=0;i<targets.size;i++ )
			{
				if( zm_utility::is_player_valid( targets[i] ) )
				{
					self.brutus_enemy = targets[i]; 
					self.v_zombie_custom_goal_pos = self.brutus_enemy.origin; 
					
					nsz_iprintlnbold( "^2Aquired New Brutus Target" ); 
					if( !isDefined(targets[i].brutus_track_countdown) )
						targets[i].brutus_track_countdown = 2; 
					if( isDefined(targets[i].brutus_track_countdown) && targets[i].brutus_track_countdown <= 0 )
						targets[i].brutus_track_countdown = 2; 
					break; 
				}
			}
		}
		wait(0.05); 
	}
}

function brutus_find_flesh()
{
	self endon( "death" );
	level endon( "intermission" );
	self thread brutus_goal_watcher();
	self thread brutus_watch_for_gondola();
	self thread brutus_stuck_watcher();
	if ( level.intermission )
	{
		return;
	}
	self.ignore_player = [];
	while ( 1 )
	{
		//IPrintLnBold("find flesh");
		while ( self.not_interruptable )
		{
			//IPrintLnBold("Not interuptable");
			wait 0.05;
		}
		player = brutus_get_closest_valid_player();
		//IPrintLnBold("Closest player: " + player.name);
		brutus_zone = zm_zonemgr::get_zone_from_position( self.origin );
		if ( !isdefined( brutus_zone ) )
		{
			brutus_zone = self.prev_zone;
			while ( !isdefined( brutus_zone ) )
			{
				wait 1;
			}
			wait 0.05;
		}
		player_zone = undefined;
		self.prev_zone = brutus_zone;
		if ( !isdefined( player ) )
		{
			self.priority_item = self get_priority_item_for_brutus( brutus_zone );
		}
		else 
		{
			player_zone = player zm_zonemgr::get_player_zone();
		}
		if ( isdefined( player_zone ) )
		{
			self.priority_item = self get_priority_item_for_brutus( player_zone );
		}
		else
		{
			self.priority_item = self get_priority_item_for_brutus( brutus_zone );
		}
		if ( isdefined( player ) && DistanceSquared( self.origin, player.origin ) < level.brutus_aggro_dist_sq && isdefined( player_zone ) && should_brutus_aggro( player_zone, brutus_zone ) )
		{
			//IPrintLnBold("Player : " + player.name);
			self.brutus_enemy = player; 
			self.favorite_enemy = player;
			self.goal_pos = player.origin;
			self.v_zombie_custom_goal_pos = self.goal_pos;
			//brutus_start_basic_find_flesh();
		}
		else
		{
			if ( isdefined( self.priority_item ) )
			{
				
				//brutus_stop_basic_find_flesh();
				self.goalradius = 12;
				self.custom_goalradius_override = 12;
				//self.goal_pos = self get_interact_offset( self.priority_item, self.ai_state_type );
				struct = ArrayGetClosest(self.priority_item.origin ,level.priority_structs);
				//IPrintLnBold("priority_item new : " + struct.origin);
				//self setgoalpos( struct.origin );
				self.v_zombie_custom_goal_pos = struct.origin;
				if(Distance2D(struct.origin, self.origin) < 65)
				{
					//IPrintLnBold("Reached goal");
					self notify("priority_goal");
				}
				//break;
			}
			else if ( isdefined( player ) )
			{
				//IPrintLnBold("Player : " + player.name);
				self.brutus_enemy = player; 
				self.favorite_enemy = player;
				self.goal_pos = self.favorite_enemy.origin;
				self.v_zombie_custom_goal_pos = self.goal_pos;
				//brutus_start_basic_find_flesh();
				//self custom_find_flesh();
				//break;
			}
			else
			{
				//IPrintLnBold("Idle");
				self.goal_pos = self.origin;
				self.ai_state = "idle";
				//self setanimstatefromasd( "zm_idle" );
				//self setgoalpos( self.goal_pos );
				self.v_zombie_custom_goal_pos = self.goal_pos;
			}
		}
		wait 0.5;
	}
}

function should_brutus_aggro( player_zone, brutus_zone )
{
	if ( !isdefined( player_zone ) || !isdefined( brutus_zone ) )
	{
		return 0;
	}
	if ( player_zone == brutus_zone )
	{
		return 1;
	}
	if ( isdefined( level.zones[ brutus_zone ].adjacent_zones ) && isdefined( level.zones[ brutus_zone ].adjacent_zones[ player_zone ] ) )
	{
		return 1;
	}
	return 0;
}

function get_interact_offset( item, target_type )
{
/#
	assert( isdefined( level.interaction_types[ target_type ] ) );
#/
	interaction = level.interaction_types[ target_type ];
	anim_state = interaction.animstate;
	//animationid = self getanimfromasd( anim_state, 0 );
	if(target_type == "magic_box")
	{
		animationid = %brutus_lock_box;
	}
	else if(target_type == "perk_machine")
	{
		animationid = %brutus_lock_perk;
	}
	else
	{
		animationid = %brutus_lock_box;
	}
	origin = item.origin;
	angles = item.angles;
	if ( isdefined( interaction.interaction_z_offset ) )
	{
		origin += ( 0, 0, interaction.interaction_z_offset );
	}
	if ( isdefined( interaction.interaction_yaw_offset ) )
	{
		angles += ( 0, interaction.interaction_yaw_offset, 0 );
	}
	return GetStartOrigin( origin, angles, animationid );
}

function get_priority_item_for_brutus( zone_name, do_secondary_zone_checks )
{
	interact_types = level.interaction_types;
	interact_prio = level.interaction_priority;
	i = 0;
	while ( i < interact_prio.size )
	{
		best_score = -1;
		best_object = undefined;
		int_type = interact_prio[ i ];
		int_struct = interact_types[ int_type ];
		int_objects = self [[ int_struct.get_func ]]( zone_name );
		j = 0;
		while ( j < int_objects.size )
		{
			if ( int_objects[ j ] [[ int_struct.validity_func ]]() )
			{
				score = self [[ int_struct.value_func ]]( int_objects[ j ] );
/#
				assert( score >= 0 );
#/
				if ( score < best_score || best_score < 0 )
				{
					best_object = int_objects[ j ];
					best_score = score;
				}
			}
			j++;
		}
		if ( isdefined( best_object ) )
		{
			self.ai_state_type = int_type;
			return best_object;
		}
		i++;
	}
	if ( isdefined( do_secondary_zone_checks ) && do_secondary_zone_checks )
	{
		adj_zone_names = GetArrayKeys( level.zones[ zone_name ].adjacent_zones );
		i = 0;
		while ( i < adj_zone_names.size )
		{
			if ( !zm_zonemgr::zone_is_enabled( adj_zone_names[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				best_object = get_priority_item_for_brutus( adj_zone_names[ i ] );
				if ( isdefined( best_object ) )
				{
					return best_object;
				}
			}
			i++;
		}
		global_zone_names = GetArrayKeys( level.zones );
		i = 0;
		while ( i < global_zone_names.size )
		{
			if ( global_zone_names[ i ] == zone_name )
			{
				i++;
				continue;
			}
			else if ( zone_array_contains( adj_zone_names, global_zone_names[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( !zm_zonemgr::zone_is_enabled( global_zone_names[ i ] ) )
			{
				i++;
				continue;
			}
			else
			{
				best_object = get_priority_item_for_brutus( global_zone_names[ i ] );
				if ( isdefined( best_object ) )
				{
					return best_object;
				}
			}
			i++;
		}
	}
	return undefined;
}

function brutus_goal_watcher()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "priority_goal" );
		interaction = level.interaction_types[ self.ai_state_type ];
		origin = self.priority_item.origin;
		angles = self.priority_item.angles;
		if ( isdefined( interaction.interaction_z_offset ) )
		{
			origin += ( 0, 0, interaction.interaction_z_offset );
		}
		if ( isdefined( interaction.interaction_yaw_offset ) )
		{
			angles += ( 0, interaction.interaction_yaw_offset, 0 );
		}
		self.not_interruptable = 1;
		//self AnimScripted( origin, angles, interaction.animstate );
		self AnimScripted( "note_notify", self.origin, self.angles, interaction.animstate ); 
		//self thread maps/mp/animscripts/zm_shared::donotetracks( interaction.notify_name );
		self thread snddointeractionvox( interaction.notify_name );
		//self waittillmatch( interaction.notify_name );
		wait(GetAnimLength(interaction.animstate));
		//return interaction.action_notetrack;
		self brutus_lockdown_client_effects();
		self thread [[ interaction.interact_func ]]();
		self.priority_item = undefined;
		self.not_interruptable = 0;
		self notify("goal_hit");
		while ( !isdefined( self.priority_item ) )
		{
			wait 0.05;
		}
	}
}

function snddointeractionvox( type )
{
	alias = "vox_brutus_brutus_lockbox";
	num = undefined;
	switch( type )
	{
		case "box_lock_anim":
			alias = "vox_brutus_brutus_lockbox";
			break;
		case "perk_lock_anim":
			alias = "vox_brutus_brutus_lockbox";
			num = 5;
			break;
		case "table_smash_anim":
			alias = "vox_brutus_brutus_lockbox";
			num = 5;
			break;
		case "trap_smash_anim":
			alias = "vox_brutus_brutus_lockbox";
			num = 5;
			break;
		case "plane_lock_anim":
			alias = "vox_brutus_brutus_lockbox";
			num = 5;
			break;
		case "board_smash_anim":
			alias = "vox_brutus_brutus_lockbox";
			num = 5;
			break;
	}
	self thread sndbrutusvox( alias, num );
}

function brutus_lockdown_client_effects( delay )
{
	self endon( "death" );
	if ( isdefined( delay ) )
	{
		wait delay;
	}
	if ( self.brutus_lockdown_state )
	{
		self.brutus_lockdown_state = 0;
		//self clientfield::set( "brutus_lock_down", 0 );
	}
	else
	{
		self.brutus_lockdown_state = 1;
		//self clientfield::set( "brutus_lock_down", 1 );
	}
}

function zone_array_contains( zone_array, zone_name )
{
	j = 0;
	while ( j < zone_array.size )
	{
		if ( zone_array[ j ] == zone_name )
		{
			return 1;
		}
		j++;
	}
	return 0;
}

function brutus_get_closest_valid_player()
{
	valid_player_found = 0;
	players = GetPlayers();
	if ( isdefined( level._zombie_using_humangun ) && level._zombie_using_humangun )
	{
		players = ArrayCombine( players, level._zombie_human_array, 0, 0 );
	}
	while ( isdefined( self.ignore_player ) && self.ignore_player.size > 0 )
	{
		i = 0;
		while ( i < self.ignore_player.size )
		{
			ArrayRemoveValue( players, self.ignore_player[ i ] );
			i++;
		}
		wait 0.05;
	}
	if ( !valid_player_found )
	{
		/*if ( isdefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
		{
			player = get_closest_player_using_paths( self.origin, players );
		}
		else
		{*/
			player = ArrayGetClosest( self.origin, players );
		//}
		if ( !isdefined( player ) )
		{
			return undefined;
		}
		if ( isdefined( level._zombie_using_humangun ) && level._zombie_using_humangun && IsAI( player ) )
		{
			return player;
		}
		if ( !zm_utility::is_player_valid( player, 1 ) )
		{
			ArrayRemoveValue( players, player );
		}
		return player;
	}
}

function get_perk_trig( perk )
{
	perk_trigs = GetEntArray( "zombie_vending", "targetname" ); 
	foreach( trig in perk_trigs )
	{
		if( trig.script_noteworthy == perk )
			return trig; 
	}
}

function get_closest_box( org )
{
	box = ArrayGetClosest( org, level.chests );
	return box; 
}

function waittill_perk_lock_complete( lock_struct )
{
	self notify( "locking_target" ); 
	
	while( Distance2d(lock_struct.origin, self.origin) > 10 )
	{
		self.v_zombie_custom_goal_pos = lock_struct.origin; 
		wait(0.05); 
	}
	
	fx = struct::get_array( lock_struct.target, "targetname" ); 
	fx = array::get_all_closest( lock_struct.origin, fx ); 
	self OrientMode( "face point", undefined, undefined, fx[0].origin ); 
	self util::waittill_any_timeout(0.5, "orientdone" );
	
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_lock_perk ); 
	wait( GetAnimLength( %brutus_lock_perk )/2 ); 
	lock_struct.alread_locked = true; 
	foreach( spot in fx )
	{
		nsz_iprintlnbold( "^2Light Fire" ); 
		spot.model = spawn( "script_model", spot.origin ); 
		spot.model SetModel( "tag_origin" ); 
		PlayFxOnTag( LOCK_FX, spot.model, "tag_origin" ); 
	}
	
	nsz_iprintlnbold( "^2Locked: "+lock_struct.script_string ); 
	trig = get_perk_trig( lock_struct.script_string ); 
	if( !isDefined(trig) )
		iprintlnbold( "^1No Perk Trig" ); 
	trig SetTeamForTrigger( "axis" ); 
	// iprintlnbold( trig.origin ); 
	trig.machine PlayLoopSound( "brutus_lock_loop" ); 
	trig SetInvisibleToAll(); 
	t_use = Spawn( "trigger_radius_use", trig.origin, 0, 60, 80 );
	t_use TriggerIgnoreTeam();
	t_use SetVisibleToAll();
	t_use SetTeamForTrigger( "none" );
	t_use UseTriggerRequireLookAt();
	t_use SetCursorHint( "HINT_NOICON" );
	t_use SetHintString( "Press and Hold ^3&&1^7 to Unlock [Cost: 2000]" ); 
	
	t_use.perk_trigger = trig; 
	t_use.fx = fx; 
	t_use.cost = 2000; 
	t_use.lock_struct = lock_struct; 
	
	t_use thread locked_think(); 
}

function waittill_box_lock_complete( lock_struct, box_trig )
{
	self notify( "locking_target" );
	
	while( Distance2d(lock_struct.origin, self.origin) > 65 )
	{
		self.v_zombie_custom_goal_pos = lock_struct.origin; 
		wait(0.05); 
	}
	
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_lock_box ); 
	wait( GetAnimLength( %brutus_lock_box )/2 ); 
	lock_struct.alread_locked = true; 
	fx = struct::get_array( lock_struct.target, "targetname" ); 
	foreach( spot in fx )
	{
		nsz_iprintlnbold( "^2Light Fire" ); 
		spot.model = spawn( "script_model", spot.origin ); 
		spot.model SetModel( "tag_origin" ); 
		PlayFxOnTag( LOCK_FX, spot.model, "tag_origin" ); 
	}
		
	trig = box_trig; 
	// machine = getentarray( level._custom_perks[ perk ].radiant_machine_name, "targetname");
	
	// trig SetInvisibleToAll(); 
	trig notify( "kill_chest_think" ); 
	thread zm_unitrigger::unregister_unitrigger(trig.unitrigger_stub);
	//if( trig.zbarrier.state == "open" )
		//trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("close");
	trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("locking");
	t_use = Spawn( "trigger_radius_use", trig.origin, 0, 40, 80 );
	t_use TriggerIgnoreTeam();
	t_use SetVisibleToAll();
	t_use SetTeamForTrigger( "none" );
	t_use UseTriggerRequireLookAt();
	t_use SetCursorHint( "HINT_NOICON" );
	t_use SetHintString( "Press and Hold ^3&&1^7 to Unlock [Cost: 2000]" ); 
	
	t_use.fx = fx; 
	t_use.cost = 2000; 
	t_use.lock_struct = lock_struct; 
	t_use.sound_ent = t_use.fx[0].model; 
	t_use.sound_ent PlayLoopSound( "brutus_lock_loop" ); 
	
	t_use thread locked_think( trig ); 
}

function locked_think( trig )
{
	while(1)
	{
		self waittill( "trigger", player ); 
		if( player.score >= self.cost )
		{
			player zm_score::minus_to_player_score( self.cost ); 
			PlaySoundAtPosition( "zmb_cha_ching", self.origin ); 
			if( isDefined(self.perk_trigger) )
				self.perk_trigger.machine StopLoopSound(2); 
			if( isDefined(self.bench_trig) )
				self.bench_trig SetVisibleToAll();
			if( isDefined(self.sound_ent) )
				self.sound_ent StopLoopSound(2); 
			wait(0.05); 
			if( isDefined(self.perk_trigger) )
				self.perk_trigger SetTeamForTrigger( "allies" ); 
			foreach( fx in self.fx )
				fx.model delete(); 
			self.lock_struct.alread_locked = undefined; 
			self Delete(); 
			if( isDefined(trig) )
			{
				trig thread zm_magicbox::treasure_chest_think(); 
				trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("unlocking"); 
			}
		}
		else 
			PlaySoundAtPosition( "nsz_deny", player.origin ); 
	}
}

function IS_TRUE( statement )
{
	if( isDefined(statement) && statement )
		return true; 
	return false; 
}

function choose_a_spawn()
{
	// nsz_iprintlnbold( "^5 Choose a Spot" ); 
	players = GetPlayers(); 
	players = array::randomize( players ); 
	player = players[0]; 
	
	if( !level.brutus_spawn_points.size )
		nsz_iprintlnbold( "^1 No brutus Spots Are Init" ); 
	
	option = ArrayGetClosest( player.origin, level.brutus_spawn_points ); 
	// nsz_iprintlnbold( option.script_string ); 
	
	return option; 
}

function boss_think()
{
	self endon( "death" ); 
	assert( !self.isdog );
	
	self.ai_state = "zombie_think";
	self.find_flesh_struct_string = "find_flesh";

	self SetGoal( self.origin );
	self PathMode( "move allowed" );
	self.zombie_think_done = true;
}

function boss_footsteps()
{
	self endon( "death" ); 
	
	while(1)
	{
		self waittill( "footstep" ); 
		Earthquake( 0.15, 1, self.origin ,750 );
		// PlayRumbleOnPosition( "grenade_rumble", self.origin );  fix later
		self PlaySound( "brutus_step_0"+randomintrange(0,2) ); 
	}
}

function melee_track()
{
	self endon( "death" ); 
	
	while(1)
	{
		if( Distance2D( self.brutus_enemy.origin, self.origin ) < 75 && BulletTracePassed( self.brutus_enemy.origin, self.origin, 0, self, self.brutus_enemy ) && !self.brutus_enemy.afterlife && !self.brutus_enemy laststand::player_is_in_laststand())
		{
			num = RandomIntRange(0,2);
			if (num == 1)
			{
				self AnimScripted( "note_notify", self.origin, self.angles, %brutus_swing ); 
				wait( GetAnimLength( %brutus_swing ) ); 
			}
			else
			{
				self AnimScripted( "note_notify", self.origin, self.angles, %brutus_swing_alt ); 
				wait( GetAnimLength( %brutus_swing_alt ) ); 
			}
		}
		wait(0.05); 
	}
}

function brutus_temp_despawn( brutus, endon_notify, respawn_notify )
{
	level endon( endon_notify );
	align_struct = Spawn( "script_model", brutus.origin );
	align_struct.angles = brutus.angles;
	align_struct SetModel( "tag_origin" );
	if ( brutus IsTouching( level.e_gondola.t_ride ) && isdefined( brutus.force_gondola_teleport ) && brutus.force_gondola_teleport )
	{
		brutus.force_gondola_teleport = 0;
		align_struct LinkTo( level.e_gondola );
		brutus LinkTo( align_struct );
	}
	brutus.not_interruptable = 1;
	PlayFXOnTag( level._effect[ "brutus_spawn" ], align_struct, "tag_origin" );
	//brutus animscripted( brutus.origin, brutus.angles, "zm_taunt" );
	//brutus maps/mp/animscripts/zm_shared::donotetracks( "taunt_anim" );
	brutus AnimScripted( "note_notify", brutus.origin, brutus.angles, %brutus_lock_box ); 
	wait( GetAnimLength( %brutus_lock_box ) ); 
	brutus.not_interruptable = 0;
	brutus Ghost();
	brutus notify( "brutus_cleanup" );
	brutus notify( "brutus_teleporting" );
	if ( isdefined( align_struct ) )
	{
		align_struct Delete();
	}
	if ( isdefined( brutus.sndbrutusmusicent ) )
	{
		brutus.sndbrutusmusicent Delete();
		brutus.sndbrutusmusicent = undefined;
	}
	health = brutus.health;
	has_helmet = brutus.has_helmet;
	helmet_hits = brutus.helmet_hits;
	explosive_dmg_taken = brutus.explosive_dmg_taken;
	zone_name = brutus.force_zone;
	brutus.helmet Delete();
	brutus Delete();
	level.brutus_count--;

	level waittill( respawn_notify );
	wait RandomFloatRange( 1, 2.5 );
	level thread respawn_brutus( health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
}

function respawn_brutus( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name, b_no_current_valid_targets )
{
	if ( isdefined( b_no_current_valid_targets ) && b_no_current_valid_targets )
	{
		zone_name = brutus_watch_for_new_valid_targets();
	}
	else
	{
		wait 5;
	}
	ai = zombie_utility::spawn_zombie( level.brutus_spawners[ 0 ] );
	ai thread brutus_spawn( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
	ai.force_zone = zone_name;
}

function brutus_watch_for_new_valid_targets()
{
	level thread brutus_watch_for_gondola_arrive();
	level thread brutus_watch_for_non_afterlife_players();
	level waittill( "brutus_valid_targets_arrived", zone_name );
	return zone_name;
}

function brutus_watch_for_gondola_arrive()
{
	level endon( "brutus_valid_targets_arrived" );
	level waittill( "gondola_arrived", zone_name );
	level notify( "brutus_valid_targets_arrived" );
}

function brutus_watch_for_gondola()
{
	self endon( "death" );
	while ( 1 )
	{
		level waittill( "gondola_moving" );
		if ( !level.brutus_in_grief && self IsTouching( level.e_gondola.t_ride ) )
		{
			self.force_gondola_teleport = 1;
		}
		wait 0.05;
	}
}

function brutus_stuck_watcher()
{
	self notify( "new_stuck_watcher" );
	self endon( "death" );
	self endon( "new_stuck_watcher" );
	self.fail_count = 0;
	self thread watch_for_valid_melee();
	self thread watch_for_riot_shield_melee();
	while ( 1 )
	{
		while ( !isdefined( self.goal_pos ) )
		{
			wait 0.05;
		}
		while ( self.not_interruptable )
		{
			wait 1;
		}
		if ( !self FindPath( self.origin, self.goal_pos ) )
		{
			self.fail_count++;
		}
		else
		{
			self.fail_count = 0;
		}
		if ( self.fail_count >= level.brutus_failed_paths_to_teleport )
		{
			self brutus_stuck_teleport();
			return;
		}
		wait 1;
	}
}

function brutus_stuck_teleport()
{
	self endon( "death" );
	align_struct = Spawn( "script_model", self.origin );
	align_struct.angles = self.angles;
	align_struct SetModel( "tag_origin" );
	if ( self IsTouching( level.e_gondola.t_ride ) && isdefined( self.force_gondola_teleport ) && self.force_gondola_teleport )
	{
		//self.force_gondola_teleport = 0;
		//align_struct LinkTo( level.e_gondola );
		//self LinkTo( align_struct );
	}
	self.not_interruptable = 1;
	PlayFXOnTag( level._effect[ "brutus_spawn" ], align_struct, "tag_origin" );
	//self animscripted( self.origin, self.angles, "zm_taunt" );
	//self maps/mp/animscripts/zm_shared::donotetracks( "taunt_anim" );
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_spawn ); 
	wait( GetAnimLength( %brutus_spawn ) ); 
	self.not_interruptable = 0;
	self Ghost();
	self notify( "brutus_cleanup" );
	self notify( "brutus_teleporting" );
	if ( isdefined( align_struct ) )
	{
		align_struct Delete();
	}
	if ( isdefined( self.sndbrutusmusicent ) )
	{
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
	if ( isdefined( level.brutus_respawn_after_despawn ) && level.brutus_respawn_after_despawn )
	{
		b_no_current_valid_targets = are_all_targets_invalid();
		level thread respawn_brutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone, b_no_current_valid_targets );
	}
	level.brutus_count--;

	self.helmet Delete();
	self Delete();
}

function are_all_targets_invalid()
{
	a_players = GetPlayers();
	_a1238 = a_players;
	_k1238 = GetFirstArrayKey( _a1238 );
	while ( isdefined( _k1238 ) )
	{
		player = _a1238[ _k1238 ];
		if ( isdefined( player.is_on_gondola ) && !player.is_on_gondola && isdefined( player.afterlife ) && !player.afterlife )
		{
			return 0;
		}
		_k1238 = GetNextArrayKey( _a1238, _k1238 );
	}
	return 1;
}

function watch_for_valid_melee()
{
	self endon( "new_stuck_watcher" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "melee_anim" );
		if ( isdefined( self.favorite_enemy ) && DistanceSquared( self.origin, self.favorite_enemy.origin ) < 16384 && isdefined( self.favorite_enemy.is_on_gondola ) && !self.favorite_enemy.is_on_gondola )
		{
			self.fail_count = 0;
		}
	}
}

function watch_for_riot_shield_melee()
{
	self endon( "new_stuck_watcher" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "item_attack" );
		self.fail_count = 0;
		wait 0.05;
	}
}


function brutus_watch_for_non_afterlife_players()
{
	level endon( "brutus_valid_targets_arrived" );
	b_all_players_in_afterlife = 1;
	while ( b_all_players_in_afterlife )
	{
		a_players = GetPlayers();
		_a1273 = a_players;
		_k1273 = GetFirstArrayKey( _a1273 );
		while ( isdefined( _k1273 ) )
		{
			player = _a1273[ _k1273 ];
			if ( isdefined( player.afterlife ) && !player.afterlife && !player laststand::player_is_in_laststand() )
			{
				b_all_players_in_afterlife = 0;
			}
			_k1273 = GetNextArrayKey( _a1273, _k1273 );
		}
		wait 0.5;
	}
	level notify( "brutus_valid_targets_arrived" );
}

function note_tracker()
{
	self endon( "death" ); 
	
	while(1)
	{
		self waittill( "note_notify", note ); 
		if( note == "swing" )
		{
			chance =  RandomIntRange(0,2); 
			self PlaySound( "brutus_swing_0"+chance ); 
			PlaySoundAtPosition( "brutus_vox_swing", self.origin ); 
			players = GetPlayers(); 
			foreach( player in players )
			{
				if( Distance2d(player.origin, self.origin) < 150 && self.brutus_enemy == player )
				{
					Earthquake( .25, 3, player.origin, 50 ); 
					player ShellShock( "frag_grenade_mp", 1 ); 
					player DoDamage( 75, self.origin, self ); 
				}
			}
		}
		if( note == "spawn_complete" )
		{
			self PlaySound( "brutus_spawn" ); 
			Earthquake( 0.4, 4, self.origin, 1000 ); 
		}
		if( note == "summon" )
		{
			self PlaySound( "brutus_spawn" ); 
			PlaySoundAtPosition( "brutus_vox_yell", self.origin ); 
		}
		
		if( note == "lock" )
		{
			self PlaySound( "brutus_lock" ); 
			PlaySoundAtPosition( "brutus_vox_swing", self.origin ); 
			self PlaySound( "brutus_clang" ); 
		}
		
	}
}

function new_death()
{
	self waittill( "death" );
	self.light Delete(); 
	level.current_brutuses--; 	
	
	if( level.current_brutuses < 1 )
		thread zm_powerups::specific_powerup_drop( undefined, self.origin);
	
	self PlaySound( "brutus_helmet" ); 
	self PlaySound( "brutus_defeated_0"+randomintrange(0,3) ); 
	self PlaySound( "brutus_death" ); 
	nsz_iprintlnbold( "^2Brutus Died" ); 
	clone = Spawn( "script_model", self.origin ); 
	clone.angles = self.angles; 
	clone SetModel( "bo2_brutus_fb" ); 
	self Hide(); 
	clone UseAnimTree( #animtree ); 
	clone AnimScripted( "placeholder", clone.origin, clone.angles, %brutus_death );	
	wait( GetAnimLength(%brutus_death) ); 
	self.helmet Delete();
	self Delete(); 
	wait(30); 
	clone Delete(); 
}

function attach_helmet()
{
	self.helmet = spawn( "script_model", self GetTagOrigin("j_head") ); 
	self.helmet SetModel( "brutus_helmet" ); 
	self.helmet.angles = self GetTagAngles("j_head"); 
	self.helmet EnableLinkTo(); 
	self.helmet LinkTo( self, "j_head" ); 
}

function playsound_to_players(sound)
{
	players = GetPlayers(); 
	foreach( player in players )
		player PlayLocalSound( sound );
}

function track_helmet()
{
	pop_off = self.health/2; 
	while(self.health > pop_off )
		wait(0.05); 
	
	self PlaySound( "brutus_helmet" ); 
	self PlaySound( "brutus_vox_yell" ); 
	
	self.helmet Unlink(); 
	self.helmet Launch( (0,0,200), (0,200,200) ); 
	
	PlayFXOnTag( HELMET_SMOKE, self, "j_head" ); 
	
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_headpain, undefined, undefined, undefined, .1 ); 
	wait( GetAnimLength(%brutus_headpain) ); 
	self AnimScripted( "note_notify", self.origin, self.angles, %brutus_enrage, undefined, undefined, undefined, .2 ); 
	wait(5); 
	self.helmet delete(); 
}

function anti_instakill( player, mod, hit_location )
{
	return true; 
}

// set up zombie walk cycles ================================================================================
function zombie_spawn_init()
{
	self.targetname = "zombie_boss";
	self.script_noteworthy = undefined;

	//A zombie was spawned - recalculate zombie array
	zm_utility::recalc_zombie_array();
	self.animname = "zombie_boss"; 		
	
	//pre-spawn gamemodule init
	// if(isdefined(zm_utility::get_gamemode_var("pre_init_zombie_spawn_func")))
	// {
		// self [[zm_utility::get_gamemode_var("pre_init_zombie_spawn_func")]]();
	// }
	 
	self.ignoreme = false;
	self.allowdeath = true; 			// allows death during animscripted calls
	self.force_gib = true; 		// needed to make sure this guy does gibs
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	self allowedStances( "stand" );
	
	//needed to make sure zombies don't distribute themselves amongst players
	self.attackerCountThreatScale = 0;
	//reduce the amount zombies favor their current enemy
	self.currentEnemyThreatScale = 0;
	//reduce the amount zombies target recent attackers
	self.recentAttackerThreatScale = 0;
	//zombies dont care about whether players are in cover
	self.coverThreatScale = 0;
	//make sure zombies have 360 degree visibility
	self.fovcosine = 0;
	self.fovcosinebusy = 0;
	
	self.zombie_damaged_by_bar_knockdown = false; // This tracks when I can knock down a zombie with a bar

	self.gibbed = false; 
	self.head_gibbed = false;
	
	// might need this so co-op zombie players cant block zombie pathing
//	self PushPlayer( true ); 
//	self.meleeRange = 128; 
//	self.meleeRangeSq = anim.meleeRange * anim.meleeRange; 

	self setPhysParams( 15, 0, 72 );
	self.goalradius = 32;
	
	self.disableArrivals = true; 
	self.disableExits = true; 
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;


	self.holdfire			= true;	//no firing - performance gain

	self.badplaceawareness = 0;
	self.chatInitialized = false;
	self.missingLegs = false;

	if ( !isdefined( self.zombie_arms_position ) )
	{
		if(randomint( 2 ) == 0)
			self.zombie_arms_position = "up";
		else
			self.zombie_arms_position = "down";
	}
	
	self.a.disablepain = true;
	self zm_utility::disable_react(); // SUMEET - zombies dont use react feature.

	// if ( isdefined( level.zombie_health ) )
	// {
		// self.maxhealth = level.zombie_health; 
		
		// if( IsDefined(level.a_zombie_respawn_health[ self.archetype ] ) && level.a_zombie_respawn_health[ self.archetype ].size > 0 )
		// {
			// self.health = level.a_zombie_respawn_health[ self.archetype ][0];
			// ArrayRemoveValue(level.a_zombie_respawn_health[ self.archetype ], level.a_zombie_respawn_health[ self.archetype ][0]);		
		// }
		// else
		// {
			// self.health = level.zombie_health;
		// }	 
	// }
	// else
	// {
		// self.maxhealth = level.zombie_vars["zombie_health_start"]; 
		// self.health = self.maxhealth; 
	// }

	self.freezegun_damage = 0;

	//setting avoidance parameters for zombies
	self setAvoidanceMask( "avoid none" );

	// wait for zombie to teleport into position before pathing
	self PathMode( "dont move" );

	// level thread zombie_death_event( self );

	// We need more script/code to get this to work properly
//	self add_to_spectate_list();
//	self random_tan(); 
	self zm_utility::init_zombie_run_cycle(); 
	self thread boss_think(); 
	// self thread zombie_utility::zombie_gib_on_damage(); 
	self thread zm_spawner::zombie_damage_failsafe();
	
	self thread zm_spawner::enemy_death_detection();

	if(IsDefined(level._zombie_custom_spawn_logic))
	{
		if(IsArray(level._zombie_custom_spawn_logic))
		{
			for(i = 0; i < level._zombie_custom_spawn_logic.size; i ++)
			{
			self thread [[level._zombie_custom_spawn_logic[i]]]();
			}
		}
		else
		{
			self thread [[level._zombie_custom_spawn_logic]]();
		}
	}
	
	// if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
	// {
		// if ( !IS_TRUE( self.is_inert ) )
		// {
			// self thread zombie_utility::delayed_zombie_eye_glow();	// delayed eye glow for ground crawlers (the eyes floated above the ground before the anim started)
		// }
	// }
	self.deathFunction = &zm_spawner::zombie_death_animscript;
	self.flame_damage_time = 0;

	self.meleeDamage = 60;	// 45
	self.no_powerups = true;
	
	// self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );

	self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
	self.tesla_head_gib_func = &zm_spawner::zombie_tesla_head_gib;

	self.team = level.zombie_team;
	
	// No sight update
	self.updateSight = false;

	// self.heroweapon_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;
	// self.sword_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;

	if ( isDefined(level.achievement_monitor_func) )
	{
		self [[level.achievement_monitor_func]]();
	}

	// gamemodule post init
	// if(isdefined(zm_utility::get_gamemode_var("post_init_zombie_spawn_func")))
	// {
		// self [[zm_utility::get_gamemode_var("post_init_zombie_spawn_func")]]();
	// }

	if ( isDefined( level.zombie_init_done ) )
	{
		self [[ level.zombie_init_done ]]();
	}
	self.zombie_init_done = true;

	self notify( "zombie_init_done" );
}

function get_brutus_interest_points()
{
	zone_names = GetArrayKeys( level.zones );
	i = 0;
	while ( i < zone_names.size )
	{
		self thread get_zone_perk_machines( zone_names[ i ] );
		self thread get_zone_craftable_tables( zone_names[ i ] );
		self thread get_zone_traps( zone_names[ i ] );
		self thread get_zone_plane_ramp( zone_names[ i ] );
		i++;
	}
	build_trap_array();
	level flag::set( "brutus_setup_complete" );
}

function build_trap_array()
{
	fan_array = GetEntArray( "acid_trap_trigger", "targetname" );
	acid_array = GetEntArray( "fan_trap_use_trigger", "targetname" );
	level.trap_triggers = ArrayCombine( fan_array, acid_array, 0, 0 );
}

function get_zone_perk_machines( zone_name )
{
	zone = level.zones[ zone_name ];
	zone.perk_machines = [];
	machine_array = [];
	add_machines_in_zone( zone, zone_name, "vending_doubletap" );
	add_machines_in_zone( zone, zone_name, "vending_jugg" );
	add_machines_in_zone( zone, zone_name, "vending_sleight" );
	add_machines_in_zone( zone, zone_name, "vending_deadshot" );
	add_machines_in_zone( zone, zone_name, "vending_electriccherry" );
}

function get_zone_craftable_tables( zone_name )
{
	level flag::wait_till( "initial_players_connected" );
	zone = level.zones[ zone_name ];
	zone.craftable_tables = [];
	while ( level.a_uts_craftables.size == 0 )
	{
		wait 1;
	}
	scr_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	craftable_tables = level.a_uts_craftables;
	i = 0;
	while ( i < craftable_tables.size )
	{
		if ( !isdefined( craftable_tables[ i ].origin ) )
		{
			i++;
			continue;
		}
		else
		{
			scr_org.origin = craftable_tables[ i ].origin;
			wait 0.05;
			if ( craftable_tables[ i ].equipname == "open_table" && scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
			{
				zone.craftable_tables[ zone.craftable_tables.size ] = struct::get( craftable_tables[ i ].target, "targetname" );
			}
		}
		i++;
	}
	scr_org Delete();
}

function get_zone_traps( zone_name )
{
	zone = level.zones[ zone_name ];
	zone.traps = [];
	acid_traps = GetEntArray( "acid_trap_trigger", "targetname" );
	scr_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	i = 0;
	while ( i < acid_traps.size )
	{
		target_struct = struct::get( acid_traps[ i ].script_parameters, "targetname" );
		acid_traps[ i ].target_struct = target_struct;
		scr_org.origin = target_struct.origin;
		wait 0.05;
		if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
		{
			zone.traps[ zone.traps.size ] = acid_traps[ i ].target_struct;
			target_struct.trigger = acid_traps[ i ];
		}
		i++;
	}
	fan_traps = GetEntArray( "fan_trap_use_trigger", "targetname" );
	i = 0;
	while ( i < fan_traps.size )
	{
		target_struct = struct::get( fan_traps[ i ].script_parameters, "targetname" );
		fan_traps[ i ].target_struct = target_struct;
		scr_org.origin = target_struct.origin;
		wait 0.05;
		if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
		{
			zone.traps[ zone.traps.size ] = fan_traps[ i ].target_struct;
			target_struct.trigger = fan_traps[ i ];
		}
		i++;
	}
	tower_traps = GetEntArray( "tower_trap_activate_trigger", "targetname" );
	i = 0;
	while ( i < tower_traps.size )
	{
		target_struct = struct::get( tower_traps[ i ].script_parameters, "targetname" );
		tower_traps[ i ].target_struct = target_struct;
		scr_org.origin = target_struct.origin;
		wait 0.05;
		if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
		{
			zone.traps[ zone.traps.size ] = tower_traps[ i ].target_struct;
			target_struct.trigger = tower_traps[ i ];
		}
		i++;
	}
	scr_org Delete();
}

function get_zone_plane_ramp( zone_name )
{
	level flag::wait_till( "initial_players_connected" );
	zone = level.zones[ zone_name ];
	zone.plane_triggers = [];
	scr_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	fly_trigger = GetEnt( "plane_fly_trigger", "targetname" );
	scr_org.origin = fly_trigger.origin;
	if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
	{
		fly_trigger_target = Spawn( "script_model", ( 0, 0, 0 ) );
		fly_trigger_target.targetname = "fly_target";
		fly_trigger.fly_trigger_target = fly_trigger_target;
		fly_trigger_target.fly_trigger = fly_trigger;
		zone.plane_triggers[ zone.plane_triggers.size ] = fly_trigger_target;
	}
	while ( level.a_uts_craftables.size == 0 )
	{
		wait 1;
	}
	i = 0;
	while ( i < level.a_uts_craftables.size )
	{
		if ( level.a_uts_craftables[ i ].equipname == "plane" )
		{
			scr_org.origin = level.a_uts_craftables[ i ].origin;
			wait 0.05;
			if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) )
			{
				zone.plane_triggers[ zone.plane_triggers.size ] = level.a_uts_craftables[ i ];
				fly_trigger_target.origin = level.a_uts_craftables[ i ].origin;
				fly_trigger_target.angles = level.a_uts_craftables[ i ].angles;
			}
		}
		i++;
	}
	scr_org Delete();
}

function add_machines_in_zone( zone, zone_name, match_string )
{
	machine_array = GetEntArray( match_string, "targetname" );
	i = 0;
	while ( i < machine_array.size )
	{
		if ( machine_array[ i ] zm_zonemgr::entity_in_zone( zone_name, 1 ) )
		{
			zone.perk_machines[ zone.perk_machines.size ] = machine_array[ i ];
		}
		i++;
	}
}

function is_magic_box_valid()
{
	if ( self zm_magicbox::is_chest_active() && self == level.chests[ level.chest_index ] )
	{
		return 1;
	}
	return 0;
}

function get_magic_boxes( zone_name )
{
/#
	assert( isdefined( level.zones[ zone_name ] ) );
#/
	return level.zones[ zone_name ].magic_boxes;
}

function get_trap_score( object )
{
	if ( SightTracePassed( self.origin + ( 0, 0, 0 ), object.origin, 0, self ) )
	{
		return 0;
	}
	return DistanceSquared( self.origin, object.origin );
}

function get_dist_score( object )
{
	return DistanceSquared( self.origin, object.origin );
}

function get_perk_machine_trigger()
{
	if ( self.targetname == "vendingelectric_cherry" )
	{
		perk_machine = GetEnt( "vending_electriccherry", "target" );
	}
	else if ( self.targetname == "vending_deadshot_model" )
	{
		perk_machine = GetEnt( "vending_deadshot", "target" );
	}
	else
	{
		perk_machine = GetEnt( self.targetname, "target" );
	}
	return perk_machine;
}

function get_perk_machines( zone_name )
{
/#
	assert( isdefined( level.zones[ zone_name ] ) );
#/
	return level.zones[ zone_name ].perk_machines;
}

function is_perk_machine_valid()
{
	trigger = self get_perk_machine_trigger();
	if ( isdefined( trigger.is_locked ) && trigger.is_locked )
	{
		return 0;
	}
	if ( isdefined( trigger.power_on ) && trigger.power_on )
	{
		return 1;
	}
	return 0;
}

function get_trigger_for_craftable()
{
	i = 0;
	while ( i < level.a_uts_craftables.size )
	{
		if ( isdefined( level.a_uts_craftables[ i ].target ) && level.a_uts_craftables[ i ].target == self.targetname )
		{
			return level.a_uts_craftables[ i ];
		}
		i++;
	}
	trig_ent = GetEnt( self.targetname, "target" );
	return trig_ent;
}

function get_craftable_tables( zone_name )
{
/#
	assert( isdefined( level.zones[ zone_name ] ) );
#/
	return level.zones[ zone_name ].craftable_tables;
}

function is_craftable_table_valid()
{
	table_trig = self get_trigger_for_craftable();
	if ( isdefined( table_trig.is_locked ) && table_trig.is_locked )
	{
		return 0;
	}
	if ( isdefined( table_trig.removed ) && table_trig.removed )
	{
		return 0;
	}
	return 1;
}

function get_closest_trap_for_brutus()
{
	best_dist = -1;
	best_trap = undefined;
	i = 0;
	while ( i < level.trap_triggers.size )
	{
		if ( !( level.trap_triggers[ i ] [[ level.interaction_types[ "trap" ].validity_func ]]() ) )
		{
			i++;
			continue;
		}
		else
		{
			dist = DistanceSquared( self.origin, level.trap_triggers[ i ].origin );
			if ( dist < best_dist || best_dist < 0 )
			{
				best_dist = dist;
				best_trap = level.trap_triggers[ i ];
			}
		}
		i++;
	}
	return best_trap;
}

function get_traps( zone_name )
{
/#
	assert( isdefined( level.zones[ zone_name ] ) );
#/
	return level.zones[ zone_name ].traps;
}

function is_trap_valid()
{
	if ( isdefined( self.trigger.zombie_dmg_trig ) && isdefined( self.trigger.zombie_dmg_trig.active ) && self.trigger.zombie_dmg_trig.active )
	{
		return 1;
	}
	else
	{
		if ( isdefined( self.trigger.active ) && self.trigger.active )
		{
			return 1;
		}
	}
	return 0;
}

function get_plane_ramps( zone_name )
{
/#
	assert( isdefined( level.zones[ zone_name ] ) );
#/
	return level.zones[ zone_name ].plane_triggers;
}

function is_plane_ramp_valid()
{
	if ( isdefined( self.fly_trigger ) && isdefined( self.fly_trigger.trigger_off ) && self.fly_trigger.trigger_off )
	{
		return 0;
	}
	if ( isdefined( self.is_locked ) && self.is_locked )
	{
		return 0;
	}
	if ( isdefined( self.equipname ) && isdefined( self.crafted ) && self.crafted )
	{
		return 0;
	}
	return 1;
}

function get_blockers( zone_name )
{
	return zm_zonemgr::get_zone_zbarriers( zone_name );
}

function is_blocker_valid()
{
	closed_pieces = self GetZBarrierPieceIndicesInState( "closed" );
	if ( closed_pieces.size >= level.brutus_blocker_pieces_req )
	{
		return 1;
	}
	return 0;
}

function magic_box_lock()
{
	self endon( "death" );
	if ( level flag::get( "moving_chest_now" ) )
	{
		self.priority_item = undefined;
		return;
	}
	magic_box = self.priority_item;
	if ( !isdefined( magic_box ) )
	{
		return;
	}
	magic_box notify( "kill_chest_think" ); 
	thread zm_unitrigger::unregister_unitrigger(magic_box.unitrigger_stub);
	magic_box.zbarrier _zm_magicbox_prison::set_magic_box_zbarrier_state( "locking" );
	self PlaySound( "zmb_ai_brutus_clang" );
	magic_box.locked_cost = get_scaling_lock_cost( "magic_box", magic_box );
	hint_string = get_lock_hint_string( magic_box.locked_cost );
	t_use = Spawn( "trigger_radius_use", magic_box.origin, 0, 40, 80 );
	t_use TriggerIgnoreTeam();
	t_use SetVisibleToAll();
	t_use SetTeamForTrigger( "none" );
	t_use UseTriggerRequireLookAt();
	t_use SetCursorHint( "HINT_NOICON" );
	t_use SetHintString( hint_string ); 
	t_use.cost = magic_box.locked_cost; 
	level.lockdown_track[ "magic_box" ] = 1;
	level notify( "brutus_locked_object" );
	t_use thread locked_think_box( magic_box ); 
	self.priority_item = undefined;
}

function brutus_spawn_zone_locked( zone_name )
{
	ai = zombie_utility::spawn_zombie( level.brutus_spawners[ 0 ] );
	ai thread brutus_spawn( undefined, undefined, undefined, undefined, zone_name );
	ai.force_zone = zone_name;
	if ( isdefined( ai ) )
	{
		ai PlaySound( "brutus_prespawn" );
		return ai;
	}
}

function brutus_spawn_in_zone( zone_name, zone_locked )
{
	if ( isdefined( zone_locked ) && zone_locked )
	{
		return brutus_spawn_zone_locked( zone_name );
	}
	else
	{
		ai = zombie_utility::spawn_zombie( level.brutus_spawners[ 0 ] );
		ai thread brutus_spawn( undefined, undefined, undefined, undefined, zone_name );
		if ( isdefined( ai ) )
		{
			ai PlaySound( "brutus_prespawn" );
			return ai;
		}
	}
}

function trap_damage_callback( trap )
{
	self endon( "death" );
	if ( isdefined( self.not_interruptable ) && !self.not_interruptable )
	{
		self.not_interruptable = 1;
		self AnimScripted( "note_notify", self.origin, self.angles, %brutus_lock_box ); 
		wait(GetAnimLength(%brutus_lock_box));
		if ( trap.targetname == "fan_trap" )
		{
			trap notify( "trap_finished_" + trap.script_string );
		}
		else
		{
			if ( trap.targetname == "acid_trap" )
			{
				trap notify( "acid_trap_fx_done" );
			}
		}
		self.not_interruptable = 0;
	}
}


function locked_think_box( trig )
{
	while(1)
	{
		self waittill( "trigger", player ); 
		if( player.score > self.cost )
		{
			player zm_score::minus_to_player_score( self.cost ); 
			PlaySoundAtPosition( "zmb_cha_ching", self.origin ); 
			if( isDefined(self.sound_ent) )
				self.sound_ent StopLoopSound(2); 
			wait(0.05); 
			self Delete(); 
			if( isDefined(trig) )
			{
				trig thread zm_magicbox::treasure_chest_think(); 
				trig.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("unlocking"); 
			}
		}
		else 
			PlaySoundAtPosition( "nsz_deny", player.origin ); 
	}
}

function perk_machine_lock()
{
	self endon( "death" );
	perk_machine = self.priority_item get_perk_machine_trigger();
	if ( !isdefined( perk_machine ) )
	{
		return;
	}
	int_struct = level.interaction_types[ "perk_machine" ];
	if ( perk_machine.target == "vending_jugg" || perk_machine.target == "vending_deadshot" )
	{
		lock_fx = level._effect[ "brutus_lockdown_sm" ];
	}
	else
	{
		lock_fx = level._effect[ "brutus_lockdown" ];
	}
	perk_machine.lock_fx = Spawn( "script_model", self.priority_item.origin );
	perk_machine.lock_fx.angles = self.priority_item.angles;
	perk_machine.lock_fx = offset_fx_struct( int_struct, perk_machine.lock_fx );
	perk_machine.lock_fx SetModel( "tag_origin" );
	PlayFXOnTag( LOCK_FX, perk_machine.lock_fx, "tag_origin" );
	perk_machine.lock_fx PlaySound( "zmb_ai_brutus_clang" );
	perk_machine.is_locked = 1;
	perk_machine.locked_cost = get_scaling_lock_cost( "perk_machine", perk_machine );
	perk_machine SetHintString( &"ZOMBIE_LOCKED_COST", perk_machine.locked_cost );
	level.lockdown_track[ perk_machine.script_string ] = 1;
	level notify( "brutus_locked_object" );
	self.priority_item = undefined;
}

function craftable_table_lock()
{
	self endon( "death" );
	table_struct = self.priority_item;
	if ( !isdefined( table_struct ) )
	{
		return;
	}
	craftable_table = table_struct get_trigger_for_craftable();
	int_struct = level.interaction_types[ "craftable_table" ];
	craftable_table.lock_fx = Spawn( "script_model", table_struct.origin );
	craftable_table.lock_fx.angles = table_struct.angles;
	craftable_table.lock_fx = offset_fx_struct( int_struct, craftable_table.lock_fx );
	craftable_table.lock_fx SetModel( "tag_origin" );
	PlayFXOnTag( LOCK_FX, craftable_table.lock_fx, "tag_origin" );
	craftable_table.lock_fx PlaySound( "zmb_ai_brutus_clang" );
	craftable_table.is_locked = 1;
	craftable_table.locked_cost = get_scaling_lock_cost( "craftable_table", craftable_table );
	craftable_table.hint_string = get_lock_hint_string( craftable_table.locked_cost );
	if ( !isdefined( craftable_table.equipname ) )
	{
		craftable_table SetHintString( craftable_table.hint_string );
	}
	if ( isdefined( craftable_table.targetname ) && craftable_table.targetname == "blundergat_upgrade" )
	{
		level.lockdown_track[ "craft_kit" ] = 1;
	}
	if ( isdefined( craftable_table.weaponname ) && craftable_table.weaponname == "alcatraz_shield" )
	{
		level.lockdown_track[ "craft_shield" ] = 1;
	}
	level notify( "brutus_locked_object" );
	self.priority_item = undefined;
}

function trap_smash()
{
	self endon( "death" );
	trap = self.priority_item.trigger;
	if ( !isdefined( trap ) )
	{
		return;
	}
	if ( trap.targetname == "fan_trap_use_trigger" )
	{
		trap.zombie_dmg_trig notify( "trap_finished_" + trap.script_string );
	}
	else if ( trap.targetname == "acid_trap_trigger" )
	{
		trap.zombie_dmg_trig notify( "acid_trap_fx_done" );
	}
	else
	{
		if ( trap.targetname == "tower_trap_activate_trigger" )
		{
			trap notify( "tower_trap_off" );
		}
	}
	trap PlaySound( "zmb_ai_brutus_clang" );
	self.priority_item = undefined;
}

function plane_ramp_lock()
{
	self endon( "death" );
	plane_ramp = self.priority_item;
	if ( !isdefined( plane_ramp ) )
	{
		return;
	}
	int_struct = level.interaction_types[ "plane_ramp" ];
	plane_ramp.lock_fx = Spawn( "script_model", plane_ramp.origin );
	plane_ramp.lock_fx.angles = plane_ramp.angles;
	plane_ramp.lock_fx = offset_fx_struct( int_struct, plane_ramp.lock_fx );
	plane_ramp.lock_fx SetModel( "tag_origin" );
	plane_ramp.lock_fx PlaySound( "zmb_ai_brutus_clang" );
	PlayFXOnTag( LOCK_FX, plane_ramp.lock_fx, "tag_origin" );
	plane_ramp.is_locked = 1;
	plane_ramp.locked_cost = get_scaling_lock_cost( "plane_ramp", plane_ramp );
	plane_ramp.hint_string = get_lock_hint_string( plane_ramp.locked_cost );
	plane_ramp zm_unitrigger::run_visibility_function_for_all_triggers();
	level.lockdown_track[ "plane_ramp" ] = 1;
	level notify( "brutus_locked_object" );
	if ( !isdefined( plane_ramp.equipname ) )
	{
		plane_ramp.fly_trigger SetHintString( plane_ramp.hint_string );
	}
}

function blocker_smash()
{
	self endon( "death" );
	self PlaySound( "vox_brutus_enraged" );
	self PlaySound( "zmb_ai_brutus_window_teardown" );
	blocker = self.priority_item;
	self PlaySound( "zmb_ai_brutus_clang" );
	if ( !isdefined( blocker ) )
	{
		return;
	}
	num_pieces = blocker GetNumZBarrierPieces();
	i = 0;
	while ( i < num_pieces )
	{
		blocker HideZBarrierPiece( i );
		blocker SetZBarrierPieceState( i, "open" );
		i++;
	}
	if ( !isdefined( blocker.script_string ) )
	{
		smash_fx_alias = "brutus_smash_default";
	}
	else
	{
		smash_fx_alias = "brutus_smash_" + blocker.script_string;
	}
	forward = AnglesToForward( blocker.angles + vectorScale( ( 0, 0, 0 ), 180 ) );
	if ( isdefined( level._effect[ smash_fx_alias ] ) )
	{
		PlayFX( level._effect[ smash_fx_alias ], blocker.origin, forward );
	}
	else
	{
		PlayFX( level._effect[ "brutus_smash_default" ], blocker.origin, forward );
	}
	self.priority_item = undefined;
}

function offset_fx_struct( int_struct, fx_struct )
{
	if ( isdefined( int_struct.fx_x_offset ) )
	{
		fx_struct.origin += ( int_struct.fx_x_offset, 0, 0 );
	}
	if ( isdefined( int_struct.fx_y_offset ) )
	{
		fx_struct.origin += ( 0, int_struct.fx_y_offset, 0 );
	}
	if ( isdefined( int_struct.fx_z_offset ) )
	{
		fx_struct.origin += ( 0, 0, int_struct.fx_z_offset );
	}
	if ( isdefined( int_struct.fx_yaw_offset ) )
	{
		fx_struct.angles += ( 0, int_struct.fx_yaw_offset, 0 );
	}
	return fx_struct;
}

function get_scaling_lock_cost( int_type, object )
{
	interaction = level.interaction_types[ int_type ];
	base_cost = interaction.unlock_cost;
	if ( !isdefined( object.num_times_locked ) )
	{
		object.num_times_locked = 0;
	}
	object.num_times_locked++;
	num_times_locked = object.num_times_locked;
	if ( num_times_locked > interaction.num_times_to_scale )
	{
		num_times_locked = interaction.num_times_to_scale;
	}
	return num_times_locked * base_cost;
}

function get_lock_hint_string( cost )
{
	switch( cost )
	{
		case 2000:
			return &"ZOMBIE_LOCKED_COST_2000";
		case 4000:
			return &"ZOMBIE_LOCKED_COST_4000";
		case 6000:
			return &"ZOMBIE_LOCKED_COST_6000";
		default:
			return &"ZOMBIE_LOCKED_COST";
	}
}

function get_fly_trigger()
{
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size )
	{
		if ( isdefined( plane_triggers[ i ].fly_trigger ) )
		{
			return plane_triggers[ i ];
		}
		i++;
	}
}

function get_build_trigger()
{
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size )
	{
		if ( isdefined( plane_triggers[ i ].equipname ) && plane_triggers[ i ].equipname == "plane" )
		{
			return plane_triggers[ i ];
		}
		i++;
	}
}

function get_fuel_trigger()
{
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size )
	{
		if ( isdefined( plane_triggers[ i ].equipname ) && plane_triggers[ i ].equipname == "refuelable_plane" )
		{
			return plane_triggers[ i ];
		}
		i++;
	}
}

function transfer_plane_trigger( from, to )
{
	if ( from == "fly" )
	{
		from_trigger = get_fly_trigger();
	}
	else if ( from == "build" )
	{
		from_trigger = get_build_trigger();
	}
	else
	{
		from_trigger = get_fuel_trigger();
	}
	if ( to == "fly" )
	{
		to_trigger = get_fly_trigger();
	}
	else if ( to == "build" )
	{
		to_trigger = get_build_trigger();
	}
	else
	{
		to_trigger = get_fuel_trigger();
	}
	to_trigger.lock_fx = from_trigger.lock_fx;
	to_trigger.is_locked = from_trigger.is_locked;
	to_trigger.num_times_locked = from_trigger.num_times_locked;
	to_trigger.hint_string = from_trigger.hint_string;
	to_trigger.locked_cost = from_trigger.locked_cost;
	from_trigger.lock_fx = undefined;
	from_trigger.is_locked = 0;
	from_trigger.locked_cost = undefined;
	if ( from == "fly" )
	{
		t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
		t_plane_fly SetHintString( &"ZM_PRISON_PLANE_BOARD" );
	}
}