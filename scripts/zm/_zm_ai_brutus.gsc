#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_alcatraz_amb;
#using scripts\zm\zm_alcatraz_utility;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\zm\_zm_magicbox_prison;

#insert scripts\shared\ai\archetype_brutus.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\aat_zm.gsh;

#precache("model", "c_zom_cellbreaker_fb");
#precache( "fx", BRUTUS_DEATH_FX_FILE );


#namespace zm_ai_brutus;

function autoexec init() {
    level.dog_rounds_allowed=0; 
    level thread setupInteractionTypes();
    level.custom_perk_validation = &checkPerkMachineValid;
	level.custom_craftable_validation = &checkCraftableTableValid;
    level.custom_magicbox_validation = &checkMagicboxValid;
	level.custom_plane_validation = &checkPlaneValid;
    level flag::wait_till( "initial_blackscreen_passed" );
    level thread setupBrutusInterestPoints();
    level.brutus_alarm_chance = 100;
    level.num_pulls_since_brutus_spawn = 0;
	level.brutus_last_spawn_round = 0;
	level.brutus_round_count = 0;
    level.brutus_min_pulls_between_box_spawns = 4;
    level.brutus_min_round_fq = 4;
	level.brutus_max_round_fq = 7;
	level.brutus_min_spawn_delay = 10;
	level.brutus_max_spawn_delay = 60;
    level.brutus_count = 0;
	level.sndbrutusistalking = 0;
	level.brutus_team_points_for_death = 500;
	level.brutus_player_points_for_death = 250;
	level.brutus_health = 1000;
	level.brutus_health_increase = 1500;
	level.brutus_explosive_damage_increase = 600;
	level.brutus_players_in_zone_spawn_point_cap = 120;
	level.brutus_max_count = 1;
	level.zombie_brutus_locations = [];
	locs = struct::get_array( "brutus_spawner_spot", "targetname" );
	foreach(struct in locs) {
		switch(struct.script_string) {
			case "start_zone":
				level.zombie_brutus_locations["start_zone"] = struct;
				level.zombie_brutus_locations["library_zone"] = struct;
				level.zombie_brutus_locations["cellblock_leftside_zone"] = struct;
				break;
			case "enter_cb_rs_zone":
				level.zombie_brutus_locations["cellblock_rightside_zone"] = struct;
				level.zombie_brutus_locations["cellblock_dogfeeder_zone_b"] = struct;
				level.zombie_brutus_locations["cellblock_dogfeeder_zone"] = struct;
				level.zombie_brutus_locations["cellblock_dogfeeder_zone_c"] = struct;
				break;
			case "enter_ele_zone":
				level.zombie_brutus_locations["top_dogfeeder_zone"] = struct;
				level.zombie_brutus_locations["top_dogfeeder_zone_b"] = struct;
				level.zombie_brutus_locations["top_dogfeeder_zone_c"] = struct;
				level.zombie_brutus_locations["top_dogfeeder_zone_d"] = struct;
				level.zombie_brutus_locations["top_dogfeeder_zone_e"] = struct;
				level.zombie_brutus_locations["gondola_roof_zone"] = struct;
				level.zombie_brutus_locations["gondola_ride_zone"] = struct;
				break;
			case "enter_cafe_zone":
				level.zombie_brutus_locations["cafe_zone"] = struct;
				level.zombie_brutus_locations["cafe_zone_b"] = struct;
				break;
			case "enter_main_cell_zone":
				level.zombie_brutus_locations["cellblock_hallway_zone"] = struct;
				level.zombie_brutus_locations["cellblock_out_wardens_zone"] = struct;
				level.zombie_brutus_locations["cellblock_out_wardens_zone_b"] = struct;
				break;
			case "enter_wardens_zone":
				level.zombie_brutus_locations["wardens_zone"] = struct;
				level.zombie_brutus_locations["wardens_ext_zone"] = struct;
				break;
			case "enter_roof_zone":
				level.zombie_brutus_locations["roof_zone"] = struct;
				break;
			case "enter_shower_zone":
				level.zombie_brutus_locations["shower_zone"] = struct;
				level.zombie_brutus_locations["underground_ss_zone"] = struct;
				break;
			case "enter_underground_zone":
				level.zombie_brutus_locations["underground_wo_zone"] = struct;
				level.zombie_brutus_locations["underground_zone_c"] = struct;
				level.zombie_brutus_locations["underground_zone_b"] = struct;
				level.zombie_brutus_locations["underground_zone_d"] = struct;
				level.zombie_brutus_locations["underground_zone"] = struct;
				break;
			case "enter_tunnel_zone":
				level.zombie_brutus_locations["tunnel_stairs_zone"] = struct;
				level.zombie_brutus_locations["tunnel_zone"] = struct;
				level.zombie_brutus_locations["tunnel_zone_b"] = struct;
				level.zombie_brutus_locations["tunnel_zone_c"] = struct;
				break;
			case "enter_docks_zone":
				level.zombie_brutus_locations["docks_zone"] = struct;
				level.zombie_brutus_locations["docks_zone_b"] = struct;
				level.zombie_brutus_locations["docks_zone_c"] = struct;
				break;
			case "enter_docks_jugg_zone":
				level.zombie_brutus_locations["upper_docks_zone"] = struct;
				break;
			case "bridge_zone":
				level.zombie_brutus_locations["bridge_zone"] = struct;
				break;
			case "enter_cafe_stairs_zone":
				level.zombie_brutus_locations["infirmary_zone_b"] = struct;
				level.zombie_brutus_locations["infirmary_zone_c"] = struct;
				level.zombie_brutus_locations["infirmary_zone"] = struct;
				level.zombie_brutus_locations["cafe_stair_zone"] = struct;
				break;
			case "enter_cb_ls_zone":
				level.zombie_brutus_locations["cellblock_leftside_zone_b"] = struct;
				level.zombie_brutus_locations["cellblock_leftside_zone_c"] = struct;
				break;
		}
	}
	ug_docks = SpawnStruct();
	ug_docks.origin = (-760, -3212, 4394);
	level.zombie_brutus_locations["ug_docks_zone_d"] = ug_docks;
	level.zombie_brutus_locations["ug_docks_zone_e"] = ug_docks;
	level.zombie_brutus_locations["ug_docks_zone_c"] = ug_docks;
	level.zombie_brutus_locations["ug_docks_zone_b"] = ug_docks;
	level.zombie_brutus_locations["ug_docks_zone"] = ug_docks;
	docks = SpawnStruct();
	docks.origin = (-542, -3475, 4394);
	level.zombie_brutus_locations["docks_room_zone"] = docks;

	level thread aat::register_immunity( ZM_AAT_BLAST_FURNACE_NAME, ARCHETYPE_BRUTUS, true, true, true );
	level thread aat::register_immunity( ZM_AAT_DEAD_WIRE_NAME, ARCHETYPE_BRUTUS, true, true, true );
	level thread aat::register_immunity( ZM_AAT_FIRE_WORKS_NAME, ARCHETYPE_BRUTUS, true, true, true );
	level thread aat::register_immunity( ZM_AAT_THUNDER_WALL_NAME, ARCHETYPE_BRUTUS, true, true, true );
	level thread aat::register_immunity( ZM_AAT_TURNED_NAME, ARCHETYPE_BRUTUS, true, true, true );

    level thread brutusSpawningLogic();
	level thread initFX();
	wait 5;
	foreach(player in GetPlayers()) {
		//player thread testing();
	}
	//level notify( "spawn_brutus" );
}

function initFX() {
	level._effect[ BRUTUS_DEATH_FX ]				= BRUTUS_DEATH_FX_FILE;
}

function jarik_testing_stuff(string) {
	
}

function testing() {
	while(1) {
		wait 1;
		zone = zm_zonemgr::get_zone_from_position(self.origin + (0,0,30), true);
		IPrintLnBold(zone);
	}
}

function setupInteractionTypes() {
    level.interaction_types = [];
    level.interaction_types[ "magic_box" ] = SpawnStruct();
	level.interaction_types[ "magic_box" ].priority = 0;
	level.interaction_types[ "magic_box" ].animstate = "scene_zm_brutus_lockdown_magicbox";
	level.interaction_types[ "magic_box" ].notify_name = "box_lock_anim";
	level.interaction_types[ "magic_box" ].action_notetrack = "locked";
	level.interaction_types[ "magic_box" ].end_notetrack = "lock_done";
	level.interaction_types[ "magic_box" ].validity_func = &isMagicBoxValid;
	level.interaction_types[ "magic_box" ].get_func = &getMagicBoxes;
	level.interaction_types[ "magic_box" ].value_func = &getDistScore;
	level.interaction_types[ "magic_box" ].interact_func = &magicboxLock;
	level.interaction_types[ "magic_box" ].spawn_bias = 1000;
	level.interaction_types[ "magic_box" ].num_times_to_scale = 1;
	level.interaction_types[ "magic_box" ].unlock_cost = 2000;
    level.interaction_types[ "perk_machine" ] = SpawnStruct();
	level.interaction_types[ "perk_machine" ].priority = 1;
	level.interaction_types[ "perk_machine" ].animstate = "scene_zm_brutus_lockdown_perkmachine";
	level.interaction_types[ "perk_machine" ].notify_name = "perk_lock_anim";
	level.interaction_types[ "perk_machine" ].action_notetrack = "locked";
	level.interaction_types[ "perk_machine" ].validity_func = &isPerkMachineValid;
	level.interaction_types[ "perk_machine" ].get_func = &getPerkMachines;
	level.interaction_types[ "perk_machine" ].value_func = &getDistScore;
	level.interaction_types[ "perk_machine" ].interact_func = &perkMachineLock;
	level.interaction_types[ "perk_machine" ].spawn_bias = 800;
	level.interaction_types[ "perk_machine" ].num_times_to_scale = 3;
	level.interaction_types[ "perk_machine" ].unlock_cost = 2000;
	level.interaction_types[ "craftable_table" ] = SpawnStruct();
	level.interaction_types[ "craftable_table" ].priority = 2;
	level.interaction_types[ "craftable_table" ].animstate = "scene_zm_brutus_lockdown_blocker";
	level.interaction_types[ "craftable_table" ].notify_name = "table_smash_anim";
	level.interaction_types[ "craftable_table" ].action_notetrack = "fire";
	level.interaction_types[ "craftable_table" ].validity_func = &isCraftableTableValid;
	level.interaction_types[ "craftable_table" ].get_func = &getCraftableTables;
	level.interaction_types[ "craftable_table" ].value_func = &getDistScore;
	level.interaction_types[ "craftable_table" ].interact_func = &craftableTableLock;
	level.interaction_types[ "craftable_table" ].spawn_bias = 600;
	level.interaction_types[ "craftable_table" ].num_times_to_scale = 1;
	level.interaction_types[ "craftable_table" ].unlock_cost = 2000;
	level.interaction_types[ "craftable_table" ].interaction_z_offset = -15;
	level.interaction_types[ "craftable_table" ].interaction_yaw_offset = 270;
	level.interaction_types[ "craftable_table" ].fx_z_offset = -44;
	level.interaction_types[ "craftable_table" ].fx_yaw_offset = 270;
	level.interaction_types[ "trap" ] = SpawnStruct();
	level.interaction_types[ "trap" ].priority = 3;
	level.interaction_types[ "trap" ].animstate = "scene_zm_brutus_lockdown_blocker";
	level.interaction_types[ "trap" ].notify_name = "trap_smash_anim";
	level.interaction_types[ "trap" ].action_notetrack = "fire";
	level.interaction_types[ "trap" ].validity_func = &isTrapValid;
	level.interaction_types[ "trap" ].get_func = &getTraps;
	level.interaction_types[ "trap" ].value_func = &getDistScore;
	level.interaction_types[ "trap" ].interact_func = &trapSmash;
	level.interaction_types[ "trap" ].spawn_bias = 400;
	level.interaction_types[ "trap" ].interaction_z_offset = -15;
	level.interaction_types[ "plane_ramp" ] = SpawnStruct();
	level.interaction_types[ "plane_ramp" ].priority = 4;
	level.interaction_types[ "plane_ramp" ].animstate = "scene_zm_brutus_lockdown_blocker";
	level.interaction_types[ "plane_ramp" ].notify_name = "plane_lock_anim";
	level.interaction_types[ "plane_ramp" ].action_notetrack = "locked";
	level.interaction_types[ "plane_ramp" ].end_notetrack = "lock_done";
	level.interaction_types[ "plane_ramp" ].validity_func = &isPlaneRampValid;
	level.interaction_types[ "plane_ramp" ].get_func = &getPlaneRamps;
	level.interaction_types[ "plane_ramp" ].value_func = &getDistScore;
	level.interaction_types[ "plane_ramp" ].interact_func = &planeRampLock;
	level.interaction_types[ "plane_ramp" ].spawn_bias = 500;
	level.interaction_types[ "plane_ramp" ].num_times_to_scale = 3;
	level.interaction_types[ "plane_ramp" ].unlock_cost = 2000;
	level.interaction_types[ "plane_ramp" ].interaction_z_offset = -60;
	level.interaction_types[ "plane_ramp" ].fx_z_offset = -60;
	level.interaction_types[ "plane_ramp" ].fx_x_offset = 70;
	level.interaction_types[ "plane_ramp" ].fx_yaw_offset = 90;
    level.interaction_types[ "blocker" ] = SpawnStruct();
	level.interaction_types[ "blocker" ].priority = 5;
	level.interaction_types[ "blocker" ].animstate = "scene_zm_brutus_lockdown_blocker";
	level.interaction_types[ "blocker" ].notify_name = "board_smash_anim";
	level.interaction_types[ "blocker" ].action_notetrack = "fire";
	level.interaction_types[ "blocker" ].validity_func = &isBlockerValid;
	level.interaction_types[ "blocker" ].get_func = &getBlockers;
	level.interaction_types[ "blocker" ].value_func = &getDistScore;
	level.interaction_types[ "blocker" ].interact_func = &blockerSmash;
	level.interaction_types[ "blocker" ].spawn_bias = 50;
    level.interaction_priority = [];
    foreach(interaction_type in GetArrayKeys( level.interaction_types )) {
        level.interaction_priority[ level.interaction_types[ interaction_type ].priority ] = interaction_type;
    }
}

function getDistScore( object ) {
	/*dist = PathDistance( self.origin, object.origin, true, self, level.pathdist_type );
	if(isdefined(dist))
		return 9999999999;
	return dist;*/

	return DistanceSquared( self.origin, object.origin );
}

function setupBrutusInterestPoints() {
	buildTrapArray();
    foreach(zone_name in GetArrayKeys( level.zones )) {
		level thread getZoneCraftableTables( zone_name );
        level thread getZonePerkMachines(zone_name);
        level thread getZoneBlockers(zone_name);
        level thread getZoneTraps(zone_name);
		level thread getZonePlaneRamp(zone_name);
    }
}

function buildTrapArray() {
	fan_array = GetEntArray( "acid_trap_trigger", "targetname" );
	acid_array = GetEntArray( "fan_trap_use_trigger", "targetname" );
	tower_trap_array = GetEntArray( "tower_trap_activate_trigger", "targetname" );
	level.trap_triggers = ArrayCombine( fan_array, acid_array, 0, 0 );
	level.trap_triggers = ArrayCombine( level.trap_triggers, tower_trap_array, 0, 0 );
}

function isMagicBoxValid() {
    if ( isdefined( self.is_locked ) && self.is_locked )
		return 0;
	if ( self zm_magicbox::is_chest_active() && self == level.chests[ level.chest_index ] )
		return 1;
	return 0;
}

function getMagicBoxes( zone_name ) {
	return level.zones[ zone_name ].magic_boxes;
}

function magicboxLock() {
	self endon( "death" );
	if ( level flag::get( "moving_chest_now" ) ) {
		self.priority_item = undefined;
		return;
	}
	magic_box = self.priority_item;
	if ( !isdefined( magic_box ) )
		return;
	magic_box.zbarrier _zm_magicbox_prison::set_magic_box_zbarrier_state( "locking" );
	self PlaySound( "zmb_brutus_clang" );
    self.priority_item.is_locked = true;
	magic_box.locked_cost = getScalingLockCost( "magic_box", magic_box );
	level.lockdown_track[ "magic_box" ] = 1;
	level notify( "brutus_locked_object" );
    self.priority_item = undefined;
}

function checkMagicboxValid( player ) {
	if ( isdefined( self.is_locked ) && self.is_locked ) {
		if ( player.score >= self.locked_cost ) {
			player zm_score::minus_to_player_score( self.locked_cost );
			self.is_locked = false;
			self.locked_cost = undefined;
			self.zbarrier _zm_magicbox_prison::set_magic_box_zbarrier_state( "unlocking" );
		}
		return 0;
	}
	return 1;
}

function getZonePerkMachines(zone_name) {
    zone = level.zones[ zone_name ];
	zone.perk_machines = [];
    foreach(perk in GetArrayKeys(level._custom_perks)) {
        machineArray = GetEntArray( perk, "script_noteworthy" );
        foreach(machineTrig in machineArray) {
            if ( machineTrig zm_zonemgr::entity_in_zone( zone_name, 1 ) ) {
                zone.perk_machines[ zone.perk_machines.size ] = machineTrig;
            }
        }
    }
}

function checkPerkMachineValid( player ) {
	if ( isdefined( self.is_locked ) && self.is_locked ) {
		if ( player.score >= self.locked_cost ) {
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

function isPerkMachineValid() {
	if ( isdefined( self.is_locked ) && self.is_locked )
		return 0;
	if ( isdefined( self.power_on ) && self.power_on )
		return 1;
	return 0;
}

function getPerkMachines( zone_name ) {
	return level.zones[ zone_name ].perk_machines;
}

function perkMachineLock() {
    self endon( "death" );

    perk_machine = self.priority_item;
    if(isdefined(perk_machine.lock_fx)) {
        perk_machine.lock_fx Delete();
        perk_machine.lock_fx = undefined;
    }
    perk_machine.lock_fx = Spawn( "script_model", perk_machine.machine.origin );
	perk_machine.lock_fx.angles = perk_machine.machine.angles;
	perk_machine.lock_fx SetModel( "tag_origin" );
    perk_machine.lock_fx clientfield::set( "brutus_lockdown_fx", 1 );
    perk_machine.lock_fx PlaySound( "zmb_brutus_clang" );

    perk_machine.is_locked = true;
    perk_machine.locked_cost = getScalingLockCost( "perk_machine", perk_machine );
	perk_machine SetHintString( &"ZOMBIE_LOCKED_COST", perk_machine.locked_cost );
    level.lockdown_track[ perk_machine.script_string ] = 1;
    level notify( "brutus_locked_object" );
    self.priority_item = undefined;
}

function isBlockerValid() {
	if ( !zm_utility::all_chunks_destroyed( self, self.barrier_chunks ) ) {
		return 1;
	}
	return 0;
}

function getBlockers( zone_name ) {
	return zm_zonemgr::get_zone_zbarriers( zone_name );
}

function blockerSmash() {
    self endon( "death" );
	self PlaySound( "zmb_vocals_brutus_enraged" );
	self PlaySound( "zmb_ai_brutus_window_teardown" );
    blocker = self.priority_item;
	self PlaySound( "zmb_brutus_clang" );
	if ( !isdefined( blocker ) ) {
		return;
	}
    if(isdefined(blocker.zbarrier)) {
        for(x = 0; x < blocker.zbarrier GetNumZBarrierPieces(); x ++) {
            if(blocker.zbarrier GetZBarrierPieceState(x) == "closed" || blocker.zbarrier GetZBarrierPieceState(x) == "closing") {
                blocker.zbarrier SetZBarrierPieceState(x, "opening");
            }
        }
    }
    if(isdefined(blocker.clip)) {
        blocker.clip TriggerEnable( false ); 
        blocker.clip ConnectPaths();
    }
    else {
        zm_blockers::blocker_connect_paths(blocker.neg_start, blocker.neg_end);
    }
    self.priority_item = undefined;
}

function getZoneBlockers( zone_name ) {
    zone = level.zones[ zone_name ];
	zone.zbarriers = [];
    foreach(exterior_goal in level.exterior_goals) {
        if ( zm_zonemgr::get_zone_from_position( exterior_goal.origin, true ) == zone_name ) {
            zone.zbarriers[ zone.zbarriers.size ] = exterior_goal;
        }
    }
}

function getTriggerForCraftable() {
	i = 0;
	while ( i < level.a_uts_craftables.size ) {
		if ( isdefined( level.a_uts_craftables[ i ].target ) && level.a_uts_craftables[ i ].target == self.targetname ) {
			return level.a_uts_craftables[ i ];
		}
		i++;
	}
	trig_ent = GetEnt( self.targetname, "target" );
	return trig_ent;
}

function isCraftableTableValid() {
	table_trig = self getTriggerForCraftable();
	if ( isdefined( table_trig.is_locked ) && table_trig.is_locked ) {
		return 0;
	}
	if ( isdefined( table_trig.removed ) && table_trig.removed ) {
		return 0;
	}
	return 1;
}

function getCraftableTables( zone_name ) {
	return level.zones[ zone_name ].craftable_tables;
}

function craftableTableLock() {
	self endon( "death" );
	table_struct = self.priority_item;
	if ( !isdefined( table_struct ) ) {
		return;
	}
	craftable_table = table_struct getTriggerForCraftable();
	int_struct = level.interaction_types[ "craftable_table" ];
	craftable_table.lock_fx = Spawn( "script_model", table_struct.origin );
	craftable_table.lock_fx.angles = table_struct.angles;
	//craftable_table.lock_fx = offset_fx_struct( int_struct, craftable_table.lock_fx );
	craftable_table.lock_fx SetModel( "tag_origin" );
	craftable_table.lock_fx clientfield::set( "brutus_lockdown_fx", 1 );
	craftable_table.lock_fx PlaySound( "zmb_ai_brutus_clang" );
	craftable_table.is_locked = 1;
	craftable_table.locked_cost = getScalingLockCost( "craftable_table", craftable_table );
	craftable_table.hint_string = getLockHintString( craftable_table.locked_cost );
	if ( !isdefined( craftable_table.equipname ) ) {
		craftable_table SetHintString( craftable_table.hint_string );
	}
	if ( isdefined( craftable_table.targetname ) && craftable_table.targetname == "blundergat_upgrade" ) {
		level.lockdown_track[ "craft_kit" ] = 1;
	}
	if ( isdefined( craftable_table.weaponname ) && craftable_table.weaponname == "alcatraz_shield_zm" ) {
		level.lockdown_track[ "craft_shield" ] = 1;
	}
	level notify( "brutus_locked_object" );
	self.priority_item = undefined;
}

function checkCraftableTableValid( player ) {
	if ( !isdefined( self.stub ) && isdefined( self.is_locked ) && self.is_locked ) {
		if ( player.score >= self.locked_cost ) {
			player zm_score::minus_to_player_score( self.locked_cost );
			self.is_locked = 0;
			self.locked_cost = undefined;
			self.lock_fx Delete();
		}
		return 0;
	}
	else {
		if ( isdefined( self.stub ) && isdefined( self.stub.is_locked ) && self.stub.is_locked ) {
			if ( player.score >= self.stub.locked_cost ) {
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

function getZoneCraftableTables( zone_name ) {
	level flag::wait_till( "initial_players_connected" );
	zone = level.zones[ zone_name ];
	zone.craftable_tables = [];
	while ( level.a_uts_craftables.size == 0 ) {
		wait 1;
	}
	scr_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	craftable_tables = level.a_uts_craftables;
	i = 0;
	while ( i < craftable_tables.size ) {
		if ( !isdefined( craftable_tables[ i ].origin ) ) {
			i++;
			continue;
		}
		else {
			scr_org.origin = craftable_tables[ i ].origin;
			wait 0.05;
			if ( craftable_tables[ i ].equipname == "open_table" && scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) ) {
				zone.craftable_tables[ zone.craftable_tables.size ] = struct::get( craftable_tables[ i ].target, "targetname" );
			}
		}
		i++;
	}
	scr_org Delete();
}

function isTrapValid() {
	if ( isdefined( self.zombie_dmg_trig ) && isdefined( self.zombie_dmg_trig.active ) && self.zombie_dmg_trig.active ) {
		return 1;
	}
	else {
		if ( isdefined( self.active ) && self.active ) {
			return 1;
		}
	}
	return 0;
}

function getTraps( zone_name ) {
	return level.zones[ zone_name ].traps;
}

function trapSmash() {
	self endon( "death" );
	trap = self.priority_item;
	if ( !isdefined( trap ) ) {
		return;
	}
	if ( trap.targetname == "fan_trap_use_trigger" ) {
		trap.zombie_dmg_trig notify( "trap_finished_" + trap.script_string );
	}
	else if ( trap.targetname == "acid_trap_trigger" ) {
		trap.zombie_dmg_trig notify( "acid_trap_fx_done" );
	}
	else {
		if ( trap.targetname == "tower_trap_activate_trigger" ) {
			trap notify( "tower_trap_off" );
		}
	}
	trap PlaySound( "zmb_ai_brutus_clang" );
	self.priority_item = undefined;
}

function getZoneTraps(zone_name) {
	zone = level.zones[ zone_name ];
	zone.traps = [];
    foreach(trap in level.trap_triggers) {
        if ( zm_zonemgr::get_zone_from_position( trap.origin, true ) == zone_name ) {
			jarik_testing_stuff("Got trap in zone " + zone_name);
            zone.traps[ zone.traps.size ] = trap;
        }
    }
}

function isPlaneRampValid() {
	if ( isdefined( self.fly_trigger ) && isdefined( self.fly_trigger.trigger_off ) && self.fly_trigger.trigger_off ) {
		return 0;
	}
	if ( isdefined( self.is_locked ) && self.is_locked ) {
		return 0;
	}
	if ( isdefined( self.equipname ) && isdefined( self.crafted ) && self.crafted ) {
		return 0;
	}
	return 1;
}

function getPlaneRamps( zone_name ) {
	return level.zones[ zone_name ].plane_triggers;
}

function planeRampLock() {
	self endon( "death" );
	plane_ramp = self.priority_item;
	if ( !isdefined( plane_ramp ) ) {
		return;
	}
	int_struct = level.interaction_types[ "plane_ramp" ];
	plane_ramp.lock_fx = Spawn( "script_model", plane_ramp.origin );
	plane_ramp.lock_fx.angles = plane_ramp.angles;
	//plane_ramp.lock_fx = offset_fx_struct( int_struct, plane_ramp.lock_fx );
	plane_ramp.lock_fx SetModel( "tag_origin" );
	plane_ramp.lock_fx PlaySound( "zmb_ai_brutus_clang" );
	plane_ramp.lock_fx clientfield::set( "brutus_lockdown_fx", 1 );
	plane_ramp.is_locked = 1;
	jarik_testing_stuff("lock " + plane_ramp.targetname);
	plane_ramp.locked_cost = getScalingLockCost( "plane_ramp", plane_ramp );
	plane_ramp.hint_string = getLockHintString( plane_ramp.locked_cost );
	plane_ramp zm_unitrigger::run_visibility_function_for_all_triggers();
	level.lockdown_track[ "plane_ramp" ] = 1;
	level notify( "brutus_locked_object" );
	if ( !isdefined( plane_ramp.equipname ) ) {
		plane_ramp.fly_trigger SetHintString( plane_ramp.hint_string );
	}
	self.priority_item = undefined;
}

function getZonePlaneRamp( zone_name ) {
	level flag::wait_till( "initial_players_connected" );
	zone = level.zones[ zone_name ];
	zone.plane_triggers = [];
	scr_org = Spawn( "script_origin", ( 0, 0, 0 ) );
	fly_trigger = GetEnt( "plane_fly_trigger", "targetname" );
	scr_org.origin = fly_trigger.origin;
	if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) ) {
		fly_trigger_target = Spawn( "script_model", ( 0, 0, 0 ) );
		fly_trigger_target.targetname = "fly_target";
		fly_trigger.fly_trigger_target = fly_trigger_target;
		fly_trigger_target.fly_trigger = fly_trigger;
		zone.plane_triggers[ zone.plane_triggers.size ] = fly_trigger_target;
	}
	while ( level.a_uts_craftables.size == 0 ) {
		wait 1;
	}
	i = 0;
	while ( i < level.a_uts_craftables.size ) {
		if ( level.a_uts_craftables[ i ].equipname == "plane" ) {
			scr_org.origin = level.a_uts_craftables[ i ].origin;
			wait 0.05;
			if ( scr_org zm_zonemgr::entity_in_zone( zone_name, 1 ) ) {
				zone.plane_triggers[ zone.plane_triggers.size ] = level.a_uts_craftables[ i ];
				fly_trigger_target.origin = level.a_uts_craftables[ i ].origin;
				fly_trigger_target.angles = level.a_uts_craftables[ i ].angles;
			}
		}
		i++;
	}
	scr_org Delete();
}

function checkPlaneValid( player ) {
	if ( isdefined( self.fly_trigger_target ) ) {
		plane_struct = self.fly_trigger_target;
	}
	else {
		plane_struct = self;
	}
	if ( isdefined( plane_struct.is_locked ) && plane_struct.is_locked ) {
		if ( player.score >= plane_struct.locked_cost ) {
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


function getScalingLockCost( int_type, object ) {
	interaction = level.interaction_types[ int_type ];
	base_cost = interaction.unlock_cost;
	if ( !isdefined( object.num_times_locked ) ) {
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

function getLockHintString( cost ) {
	switch( cost ) {
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

function brutusSpawningLogic() {
    level thread enableBrutusRounds();
    if( isdefined( level.chests ) ) {
        foreach(chest in level.chests) {
            chest thread waitOnBoxAlarm();
        }
	}
    while ( 1 ) {
		level waittill( "spawn_brutus", num );
        if(!isdefined(num)) {
            num = 1;
        }
		for(i = 0; i < num; i++) {
            jarik_testing_stuff("spawning brutus");
            level thread brutusSpawn();
        }
		if ( num > 0 ) {
			//ai PlaySound( "zmb_ai_brutus_spawn_2d" );
			foreach(player in GetPlayers()) {
				player PlaySoundToPlayer( "zmb_brutus_spawn_2d", player );
			}
		}
	}
}

function enableBrutusRounds() {
	level.brutus_rounds_enabled = 1;
	level flag::init( "brutus_round" );
	level thread brutusRoundTracker();
}

function brutusRoundTracker() {
    level.next_brutus_round = level.round_number + RandomIntRange( level.brutus_min_round_fq, level.brutus_max_round_fq );
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
    while(1) {
        level waittill( "between_round_over" );
        jarik_testing_stuff("new round " + level.next_brutus_round);
        if ( level.round_number < 9 && isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game ) {

        }
        else if ( level.next_brutus_round <= level.round_number ) {
            if ( zm_alcatraz_utility::is_team_on_golden_gate_bridge() )
			{
				level.next_brutus_round = level.round_number + 1;
			}
            wait RandomFloatRange( level.brutus_min_spawn_delay, level.brutus_max_spawn_delay );
            jarik_testing_stuff("trying to spawn brutus");
            if ( attemptBrutusSpawn( level.brutus_zombie_per_round ) ) {
				/*level.music_round_override = 1;
				level thread maps/mp/zombies/_zm_audio::change_zombie_music( "brutus_round_start" );
				level thread sndforcewait();*/
				level.next_brutus_round = level.round_number + RandomIntRange( level.brutus_min_round_fq, level.brutus_max_round_fq );
			}
        }
    }
}

function waitOnBoxAlarm() {
	while ( 1 ) {
		self.zbarrier waittill( "randomization_done" );
		level.num_pulls_since_brutus_spawn++;
		if ( level.num_pulls_since_brutus_spawn >= level.brutus_min_pulls_between_box_spawns ) {
			rand = RandomInt( 1000 );
			if ( rand <= level.brutus_alarm_chance ) {
				if ( level flag::get( "moving_chest_now" ) ) {
					continue;
				}
				if ( attemptBrutusSpawn( 1 ) ) {
					if ( level.next_brutus_round == ( level.round_number + 1 ) ) {
						level.next_brutus_round++;
					}
					level.brutus_alarm_chance = level.brutus_min_alarm_chance;
				}
				break;
			}
			else {
				if ( level.brutus_alarm_chance < level.brutus_max_alarm_chance ) {
					level.brutus_alarm_chance += level.brutus_alarm_chance_increment;
				}
			}
		}
	}
}

function attemptBrutusSpawn( n_spawn_num ) {
	jarik_testing_stuff("attemptBrutusSpawn");
	if ( ( level.brutus_count + n_spawn_num ) > level.brutus_max_count ) {
		return 0;
	}
	jarik_testing_stuff("attemptBrutusSpawn good");
	level notify( "spawn_brutus" );
	return 1;
}

function brutusSpawn(starting_health, has_helmet=true, helmet_hits=0, explosive_dmg_taken=0, zone_name) {
    level.num_pulls_since_brutus_spawn = 0;
    if ( isdefined( zone_name ) && zone_name == "bridge_zone" ) {
		wait RandomFloat( 1.5 );
		spawn_pos = getRandomBrutusSpawnPos( zone_name );
	}
	else {
		jarik_testing_stuff("getting best spawn");
		spawn_pos = getBestBrutusSpawnPos( zone_name );
	}
	if(!isdefined(spawn_pos)) {
		jarik_testing_stuff("No spawnpoint found");
		return;
	}
	jarik_testing_stuff("Spawnpos: " + spawn_pos.origin);
	PlaySoundAtPosition( "zmb_brutus_prespawn", spawn_pos.origin );
	wait 3;
	e_ai = SpawnActor( "spawner_zm_cellbreaker", spawn_pos.origin, (0,0,0), "brutus", 1, 1 );
	e_ai.ignore_enemy_count = true;
	if ( !isdefined( starting_health ) ) {
		e_ai brutusHealthIncreases();
		e_ai.maxhealth = level.brutus_health;
		e_ai.health = level.brutus_health;
	}
	else {
		e_ai.maxhealth = starting_health;
		e_ai.health = starting_health;
	}
	e_ai.explosive_dmg_req = level.brutus_expl_dmg_req;
	e_ai.has_helmet = has_helmet;
	e_ai.explosive_dmg_taken = explosive_dmg_taken;
	e_ai.helmet_hits = helmet_hits;
	if ( !e_ai.has_helmet ) {
		e_ai Detach( BRUTUS_MODEL_HELMET );
	}
	e_ai thread sndDelayedMusic();
	if(zone_name == "bridge_zone") {
		e_ai.is_bridge_brutus = 1;
		if ( level.n_bridge_brutuses_killed == 0 ) {
			e_ai thread zm_alcatraz_sq::suppress_brutus_bridge_powerups();
		}
	}
	level.brutus_count++;
	PlaySoundAtPosition( "zmb_brutus_spawn", self.origin );
	e_ai thread brutusDeath();
	e_ai scene::play( "scene_zm_brutus_spawn", array( e_ai ) );
	e_ai thread brutusStuckWatcher();
	level notify( "brutus_spawned", e_ai );
}

function brutusSpawnInZone( zone_name, zone_locked ) {
	if ( isdefined( zone_locked ) && zone_locked ) {
		return brutusSpawnZoneLocked( zone_name );
	}
	else {
		level thread brutusSpawn( undefined, undefined, undefined, undefined, zone_name );
		foreach(player in GetPlayers()) {
			player PlaySoundToPlayer( "zmb_brutus_spawn_2d", player );
		}
	}
}

function brutusSpawnZoneLocked( zone_name ) {
	level thread brutusSpawn( undefined, undefined, undefined, undefined, zone_name );
	//ai.force_zone = zone_name;
	foreach(player in GetPlayers()) {
		player PlaySoundToPlayer( "zmb_brutus_spawn_2d", player );
	}
}

function brutusTempDespawn( brutus, endon_notify, respawn_notify ) {
	level endon( endon_notify );
	align_struct = Spawn( "script_model", brutus.origin );
	align_struct.angles = brutus.angles;
	align_struct setmodel( "tag_origin" );
	if ( brutus IsTouching( level.e_gondola.t_ride ) && isdefined( brutus.force_gondola_teleport ) && brutus.force_gondola_teleport ) {
		brutus.force_gondola_teleport = 0;
		align_struct LinkTo( level.e_gondola );
		brutus LinkTo( align_struct );
	}
	PlayFXOnTag( level._effect[ BRUTUS_DEATH_FX ], align_struct, "tag_origin" );
	brutus scene::play( "scene_zm_brutus_taunt", array( brutus ) );
	brutus Ghost();
	brutus notify( "brutus_cleanup" );
	brutus notify( "brutus_teleporting" );
	if ( isdefined( align_struct ) ) {
		align_struct Delete();
	}
	if ( isdefined( brutus.sndbrutusmusicent ) ) {
		brutus.sndbrutusmusicent Delete();
		brutus.sndbrutusmusicent = undefined;
	}
	health = brutus.health;
	has_helmet = brutus.has_helmet;
	helmet_hits = brutus.helmet_hits;
	explosive_dmg_taken = brutus.explosive_dmg_taken;
	zone_name = brutus.force_zone;
	brutus.helmet Delete();
	brutus.baton Delete();
	brutus Delete();
	level.brutus_count--;

	level waittill( respawn_notify );
	wait RandomFloatRange( 1, 2.5 );
	level thread respawnBrutus( health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
}

function brutusAfterlifeTeleport() {
	PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
	self Hide();
	wait 0.1;
	self notify( "brutus_cleanup" );
	if ( isdefined( self.sndbrutusmusicent ) )
	{
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
	level thread respawnBrutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone );
	level.brutus_count--;

	self.helmet Delete();
	self.baton Delete();
	self Delete();
}

function respawnBrutus( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name, b_no_current_valid_targets ) {
	jarik_testing_stuff("Respawning start");
	if ( isdefined( b_no_current_valid_targets ) && b_no_current_valid_targets ) {
		jarik_testing_stuff("Getting new zone");
		zone_name = brutusWatchForNewValidTargets();
		jarik_testing_stuff("New zone: " + zone_name);
	}
	else {
		wait 5;
	}
	jarik_testing_stuff("Respawning");
	level thread brutusSpawn(starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name);
}

function brutusWatchForNewValidTargets() {
	level thread brutusWatchForGondolaArrive();
	level thread brutusWatchForNonAfterlifePlayers();
	level waittill( "brutus_valid_targets_arrived", zone_name );
	return zone_name;
}

function brutusWatchForGondolaArrive() {
	level endon( "brutus_valid_targets_arrived" );
	level waittill( "gondola_arrived", zone_name );
	level notify( "brutus_valid_targets_arrived", zone_name );
}

function brutusWatchForNonAfterlifePlayers() {
	level endon( "brutus_valid_targets_arrived" );
	b_all_players_in_afterlife = 1;
	zone_name = undefined;
	while ( b_all_players_in_afterlife ) {
		foreach(player in GetPlayers()) {
			if ( isdefined( player.afterlife ) && !player.afterlife && !player laststand::player_is_in_laststand() ) {
				b_all_players_in_afterlife = 0;
				zone_name = player zm_zonemgr::get_player_zone();
				if(zone_name == "gondola_ride_zone") {
					b_all_players_in_afterlife = 1;
					zone_name = undefined;
				}
			}
		}
		wait 0.5;
	}
	level notify( "brutus_valid_targets_arrived", zone_name );
}

function sndDelayedMusic() {
	self endon( "death" );
	if ( !isdefined( self.sndbrutusmusicent ) ) {
		sndentorigin = self GetTagOrigin( "J_spineupper" );
		self.sndbrutusmusicent = Spawn( "script_origin", sndentorigin );
		self.sndbrutusmusicent LinkTo( self, "J_spineupper" );
		self.sndbrutusmusicent PlayLoopSound( "mus_event_brutus_loop" );
	}
	self thread sndbrutusloopwatcher( self.sndbrutusmusicent );
}

function sndBrutusLoopWatcher( ent ) {
	self endon( "death" );
	level waittill( "sndStopBrutusLoop" );
	ent StopLoopSound( 1 );
	wait 1;
	ent Delete();
}

function brutusDeath() {
	self endon( "brutus_cleanup" );
	self thread brutus_cleanup();
	self waittill( "death" );
	self thread sndBrutusVox( "zmb_vocals_brutus_defeated" );
	level.brutus_count--;
	level thread zm_alcatraz_amb::sndplaystinger( "brutus_death" );
	PlaySoundAtPosition( "zmb_brutus_death", self.origin );
	if ( !IS_TRUE(self.suppress_brutus_powerup_drop) ) {
		if ( !IS_TRUE(level.global_brutus_powerup_prevention) )
		{
			if ( self zm_zonemgr::entity_in_zone( "bridge_zone" ) )
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
	if ( IsPlayer( self.attacker ) ) {
		self.attacker thread zm_utility::do_player_general_vox( "general", "brutus_killed", 20, 20 );
		multiplier = zm_score::get_points_multiplier( self );
		team_points = multiplier * zm_utility::round_up_score( level.brutus_team_points_for_death, 5 );
		player_points = multiplier * zm_utility::round_up_score( level.brutus_player_points_for_death, 5 );
		foreach(player in GetPlayers()) {
			if ( zm_utility::is_player_valid( player ) ) {
				player zm_score::add_to_player_score( team_points );
				if ( player == self.attacker ) {
					player zm_score::add_to_player_score( player_points );
					level notify( "brutus_killed", player );
				}
			}
		}
	}
	self notify( "brutus_cleanup" );
}

function brutus_cleanup() {
	self waittill( "brutus_cleanup" );
	level.sndbrutusistalking = 0;
	if ( isdefined( self.sndbrutusmusicent ) ) {
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
}

function sndBrutusVox( alias, num ) {
	self endon( "brutus_cleanup" );
	if ( !isdefined( alias ) ) {
		return;
	}
	num_variants = zm_spawner::get_number_variants( alias );
	if ( num_variants <= 0 ) {
		return;
	}
	if ( isdefined( num ) && num <= num_variants ) {
		num_variants = num;
	}
	if ( !level.sndbrutusistalking ) {
		level.sndbrutusistalking = 1;
		alias = ( alias + "_" ) + RandomIntRange( 0, num_variants );
		playbacktime = SoundGetPlaybackTime( alias );
		self PlaySoundOnTag( alias, "J_head" );
		wait playbacktime;
		level.sndbrutusistalking = 0;
	}
}

function brutusHealthIncreases() {
	if ( level.round_number > level.brutus_last_spawn_round ) {
		a_players = GetPlayers();
		n_player_modifier = 1;
		if ( a_players.size > 1 ) {
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


function getRandomBrutusSpawnPos( zone_name ) {
	zone_spawn_pos = [];
	foreach(zone in GetArrayKeys(level.zombie_brutus_locations)) {
		if ( isdefined( zone_name ) && zone == zone_name ) {
			zone_spawn_pos[ zone_spawn_pos.size ] = zone;
		}
	}
	if ( zone_spawn_pos.size > 0 ) {
		return level.zombie_brutus_locations[ array::random(zone_spawn_pos) ];
	}
	return undefined;
}

function getBestBrutusSpawnPos( zone_name ) {
	val = 0;
	foreach(zone in GetArrayKeys(level.zombie_brutus_locations)) {
		if ( isdefined( zone_name ) && zone != zone_name ) {
			continue;
		}
		else {
			newval = getBrutusSpawnPosVal( level.zombie_brutus_locations[ zone ], zone );
			if ( newval > val ) {
				val = newval;
				pos_idx = zone;
			}
		}
	}
	if ( isdefined( pos_idx ) ) {
		return level.zombie_brutus_locations[ pos_idx ];
	}
	enemy = getFavoriteEnemy();
	playerZone = enemy zm_zonemgr::get_player_zone();
	zone = level.zones[playerZone];
	zoneEnts = ArrayCombine(zone.zbarriers, zone.magic_boxes, true, false);
	zoneEnts = ArrayCombine(zoneEnts, zone.volumes, true, false);
	zoneEnts = array::randomize(zoneEnts);
	foreach(ent in zoneEnts) {
		if ( !zm_utility::check_point_in_playable_area( ent.origin ) )
			continue;

		query_result = PositionQuery_Source_Navigation(ent.origin, 100, 500, 200, 32 );
		if ( query_result.data.size ) {
			a_s_locs = array::randomize( query_result.data );
		
			if ( isdefined( a_s_locs ) ) {
				i = 0;
				foreach( s_loc in a_s_locs ) {
					if ( zm_utility::check_point_in_playable_area( s_loc.origin ) ) {
						return s_loc;
					}
				}
			}
		}
	}
	jarik_testing_stuff("Spawn stuff failed, getting random spawn");
	return array::random(level.zombie_brutus_locations);
}

function getFavoriteEnemy() {
	e_least_hunted = undefined;
	players = array::randomize(GetPlayers());
	foreach(player in players) {
		if( !zm_utility::is_player_valid( player ) ) {
			continue;
		}
		if(isdefined(player.afterlife) && player.afterlife) {
			continue;
		}
		if(player IsNoTarget() || player.ignoreme) {
			continue;
		}
		e_least_hunted = player;
	}
	return e_least_hunted;
}

function getBrutusSpawnPosVal( brutus_pos, zone_name ) {
	score = 0;
	if ( !zm_zonemgr::zone_is_enabled( zone_name ) ) {
		return 0;
	}
	a_players_in_zone = zm_zonemgr::get_players_in_zone( zone_name, 1 );
	if ( a_players_in_zone.size == 0 ) {
		return 0;
	}
	else {
		n_score_addition = 1;
		i = 0;
		while ( i < a_players_in_zone.size ) {
			if ( self FindPath( brutus_pos.origin, a_players_in_zone[ i ].origin) ) {
				n_dist = Distance2D( brutus_pos.origin, a_players_in_zone[ i ].origin );
				n_score_addition += math::linear_map( n_dist, 2000, 0, 0, level.brutus_players_in_zone_spawn_point_cap );
			}
			i++;
		}
		if ( n_score_addition > level.brutus_players_in_zone_spawn_point_cap ) {
			n_score_addition = level.brutus_players_in_zone_spawn_point_cap;
		}
		score += n_score_addition;
	}
	interaction_types = GetArrayKeys( level.interaction_types );
	interact_array = level.interaction_types;
	i = 0;
	while ( i < interaction_types.size ) {
		int_type = interaction_types[ i ];
		interaction = interact_array[ int_type ];
		interact_points = [[ interaction.get_func ]]( zone_name );
		j = 0;
		while ( j < interact_points.size ) {
			if ( interact_points[ j ] [[ interaction.validity_func ]]() ) {
				score += interaction.spawn_bias;
			}
			j++;
		}
		i++;
	}
	return score;
}

function get_fly_trigger() {
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size ) {
		if ( isdefined( plane_triggers[ i ].fly_trigger ) ) {
			return plane_triggers[ i ];
		}
		i++;
	}
}

function get_build_trigger() {
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size ) {
		if ( isdefined( plane_triggers[ i ].equipname ) && plane_triggers[ i ].equipname == "plane" ) {
			return plane_triggers[ i ];
		}
		i++;
	}
}

function get_fuel_trigger() {
	plane_triggers = level.zones[ "roof_zone" ].plane_triggers;
	i = 0;
	while ( i < plane_triggers.size ) {
		if ( isdefined( plane_triggers[ i ].equipname ) && plane_triggers[ i ].equipname == "refuelable_plane" ) {
			return plane_triggers[ i ];
		}
		i++;
	}
}

function transfer_plane_trigger( from, to ) {
	if ( from == "fly" ) {
		from_trigger = get_fly_trigger();
	}
	else if ( from == "build" ) {
		from_trigger = get_build_trigger();
	}
	else
	{
		from_trigger = get_fuel_trigger();
	}
	if ( to == "fly" ) {
		to_trigger = get_fly_trigger();
	}
	else if ( to == "build" ) {
		to_trigger = get_build_trigger();
	}
	else {
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
	if ( from == "fly" ) {
		t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
		t_plane_fly SetHintString( "Hold ^3&&1^7 to Board Plane" );
	}
}

function trapDamageCallback( trap ) {
	self endon( "death" );
	self scene::play( "scene_zm_brutus_taunt", array( self ) );
	if ( trap.targetname == "fan_trap" ) {
		trap notify( "trap_finished_" + trap.script_string );
	}
	else {
		if ( trap.targetname == "acid_trap" )
		{
			trap notify( "acid_trap_fx_done" );
		}
	}
}

function brutusWatchForGondola() {
	self endon( "death" );
	while ( 1 ) {
		level waittill( "gondola_moving" );
		if ( self IsTouching( level.e_gondola.t_ride ) ) {
			self.force_gondola_teleport = 1;
		}
		wait 0.05;
	}
}

function brutusStuckWatcher() {
	self notify( "new_stuck_watcher" );
	self endon( "death" );
	self endon( "new_stuck_watcher" );
	self.fail_count = 0;
	while(1) {
		while(!isdefined(self.goal_pos)) {
			wait 0.1;
		}
		hasTarget = false;
		if(isdefined(self.goal_pos)) {
			if(self FindPath(self.origin, self.goal_pos)) {
				hasTarget = true;
			}
		}
		if(!hasTarget) {
			self.fail_count++;
			jarik_testing_stuff("FAILING");
		}
		else {
			self.fail_count = 0;
		}
		if ( self.fail_count >= 5 ) {
			self brutusStuckTeleport();
			return;
		}
		wait 1;
	}
}

function brutusStuckTeleport() {
	jarik_testing_stuff("TELEPORTING THE BITCH");
	self endon( "death" );
	align_struct = Spawn( "script_model", self.origin );
	align_struct.angles = self.angles;
	align_struct SetModel( "tag_origin" );
	if ( self IsTouching( level.e_gondola.t_ride ) && isdefined( self.force_gondola_teleport ) && self.force_gondola_teleport ) {
		self.force_gondola_teleport = 0;
		align_struct LinkTo( level.e_gondola );
		self LinkTo( align_struct );
	}
	PlayFXOnTag( level._effect[ BRUTUS_DEATH_FX ], align_struct, "tag_origin" );
	self scene::play( "scene_zm_brutus_taunt", array( self ) );
	self ghost();
	self notify( "brutus_cleanup" );
	self notify( "brutus_teleporting" );
	if ( isdefined( align_struct ) )  {
		align_struct Delete();
	}
	if ( isdefined( self.sndbrutusmusicent ) ) {
		self.sndbrutusmusicent Delete();
		self.sndbrutusmusicent = undefined;
	}
	b_no_current_valid_targets = areAllTargetsInvalid();
	level thread respawnBrutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone, b_no_current_valid_targets );
	level.brutus_count--;

	self.helmet Delete();
	self.baton Delete();
	self Delete();
}

function areAllTargetsInvalid() {
	foreach(player in GetPlayers()) {
		if ( isdefined( player.is_on_gondola ) && !player.is_on_gondola && isdefined( player.afterlife ) && !player.afterlife ) {
			return 0;
		}
	}
	return 1;
}
