#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;

#using scripts\zm\zm_alcatraz_sq_vo;
#using scripts\zm\zm_alcatraz_hud_buildables;
#using scripts\zm\zm_alcatraz_amb;

#using scripts\zm\_zm_weap_ammo_counter;
#using scripts\zm\_zm_afterlife;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "xmodel", "veh_t6_dlc_zombie_part_control" );
#precache( "xmodel", "veh_t6_dlc_zombie_part_engine" );
#precache( "xmodel", "veh_t6_dlc_zombie_part_fuel" );
#precache( "xmodel", "veh_t6_dlc_zombie_part_rigging" );

#precache( "xmodel", "p6_zm_al_packasplat_suitcase" );
#precache( "xmodel", "p6_zm_al_packasplat_iv" );
#precache( "xmodel", "p6_zm_al_packasplat_engine" );
#precache( "xmodel", "p6_anim_zm_al_packasplat" );

#precache( "xmodel", "t6_wpn_zmb_shield_dlc2_dmg0_world" );

#precache( "xmodel", "p7_ven_gascan_static" );

#precache( "xmodel", "p6_zm_al_key" );

#using_animtree("generic");

function init_craftables() {
	level thread blundergat_upgrade_station();
	level.craftable_piece_count = 10;
	register_clientfields();
	zm_craftables::add_zombie_craftable( "packasplat", "Hold ^3&&1^7 to craft Blundergat Upgrade", undefined, undefined, &onfullycrafted_packasplat, 1 );
	zm_craftables::add_zombie_craftable_vox_category( "packasplat", "build_bsm" );
	zm_craftables::make_zombie_craftable_open( "packasplat", "p6_anim_zm_al_packasplat", VectorScale( ( 0, 0, 0 ), 90 ) );
	level.craftable_piece_swap_allowed = 0;
	zm_craftables::add_zombie_craftable( "quest_key1" );
	zm_craftables::add_zombie_craftable( "plane", "Hold ^3&&1^7 to build Plane", "Building Plane ...", undefined, &onfullycrafted_plane );
	zm_craftables::add_zombie_craftable( "refuelable_plane", "Hold ^3&&1^7 to Refuel Plane", "Refueling Plane ...", undefined, &onfullycrafted_refueled );
	level thread plane_hud_on_crafted();
	level thread fuel_hud_on_crafted();
	in_game_checklist_setup();
}

function include_key_craftable( craftable_name, model_name ) {
	part_key = zm_craftables::generate_zombie_craftable_piece( craftable_name, "key", 32, 15, 0, undefined, &onpickup_key, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
	part = SpawnStruct();
	part.name = craftable_name;
	part zm_craftables::add_craftable_piece( part_key );
	part.triggerthink = &zm_craftables::setup_craftable_pieces;
	include_craftable( part );
}

function include_craftables() {
	level.zombie_include_craftables[ "open_table" ].custom_craftablestub_update_prompt = &prison_open_craftablestub_update_prompt;
	craftable_name = "packasplat";
	packasplat_case = zm_craftables::generate_zombie_craftable_piece( craftable_name, "case", 48, 36, 0, undefined, &onpickup_common, &ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_case", 1, "build_bsm" );
	packasplat_fuse = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuse", 32, 36, 0, undefined, &onpickup_common, &ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_fuse", 1, "build_bsm" );
	packasplat_blood = zm_craftables::generate_zombie_craftable_piece( craftable_name, "blood", 32, 15, 0, undefined, &onpickup_common, &ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_blood", 1, "build_bsm" );
	packasplat = SpawnStruct();
	packasplat.name = craftable_name;
	packasplat zm_craftables::add_craftable_piece( packasplat_case );
	packasplat zm_craftables::add_craftable_piece( packasplat_fuse );
	packasplat zm_craftables::add_craftable_piece( packasplat_blood );
	packasplat.triggerthink = &packasplatcraftable;
	include_craftable( packasplat );
	include_key_craftable( "quest_key1", "p6_zm_al_key" );
	craftable_name = "plane";
	plane_cloth = zm_craftables::generate_zombie_craftable_piece( craftable_name, "cloth", 48, 15, 0, undefined, &onpickup_plane, &ondrop_plane, &oncrafted_plane, undefined, "tag_origin", undefined, 1 );
	plane_fueltanks = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fueltanks", 32, 15, 0, undefined, &onpickup_plane, &ondrop_plane, &oncrafted_plane, undefined, "tag_feul_tanks", undefined, 2 );
	plane_engine = zm_craftables::generate_zombie_craftable_piece( craftable_name, "engine", 32, 62, 0, undefined, &onpickup_plane, &ondrop_plane, &oncrafted_plane, undefined, "tag_origin", undefined, 3 );
	plane_steering = zm_craftables::generate_zombie_craftable_piece( craftable_name, "steering", 32, 15, 0, undefined, &onpickup_plane, &ondrop_plane, &oncrafted_plane, undefined, "tag_control_mechanism", undefined, 4 );
	plane_rigging = zm_craftables::generate_zombie_craftable_piece( craftable_name, "rigging", 32, 15, 0, undefined, &onpickup_plane, &ondrop_plane, &oncrafted_plane, undefined, "tag_origin", undefined, 5 );
	if ( level.is_forever_solo_game) {
		plane_cloth.is_shared = 1;
		plane_fueltanks.is_shared = 1;
		plane_engine.is_shared = 1;
		plane_steering.is_shared = 1;
		plane_rigging.is_shared = 1;
		plane_cloth.client_field_state = undefined;
		plane_fueltanks.client_field_state = undefined;
		plane_engine.client_field_state = undefined;
		plane_steering.client_field_state = undefined;
		plane_rigging.client_field_state = undefined;
	}
	plane_cloth.pickup_alias = "sidequest_sheets";
	plane_fueltanks.pickup_alias = "sidequest_oxygen";
	plane_engine.pickup_alias = "sidequest_engine";
	plane_steering.pickup_alias = "sidequest_valves";
	plane_rigging.pickup_alias = "sidequest_rigging";
	plane = SpawnStruct();
	plane.name = craftable_name;
	plane zm_craftables::add_craftable_piece( plane_cloth );
	plane zm_craftables::add_craftable_piece( plane_engine );
	plane zm_craftables::add_craftable_piece( plane_fueltanks );
	plane zm_craftables::add_craftable_piece( plane_steering );
	plane zm_craftables::add_craftable_piece( plane_rigging );
	plane.triggerthink = &planecraftable;
	plane.custom_craftablestub_update_prompt = &prison_plane_update_prompt;
	include_craftable( plane );
	craftable_name = "refuelable_plane";
	refuelable_plane_gas1 = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuel1", 32, 15, 0, undefined, &onpickup_fuel, &ondrop_fuel, &oncrafted_fuel, undefined, undefined, undefined, 6 );
	refuelable_plane_gas2 = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuel2", 32, 15, 0, undefined, &onpickup_fuel, &ondrop_fuel, &oncrafted_fuel, undefined, undefined, undefined, 7 );
	refuelable_plane_gas3 = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuel3", 32, 15, 0, undefined, &onpickup_fuel, &ondrop_fuel, &oncrafted_fuel, undefined, undefined, undefined, 8 );
	refuelable_plane_gas4 = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuel4", 32, 15, 0, undefined, &onpickup_fuel, &ondrop_fuel, &oncrafted_fuel, undefined, undefined, undefined, 9 );
	refuelable_plane_gas5 = zm_craftables::generate_zombie_craftable_piece( craftable_name, "fuel5", 32, 15, 0, undefined, &onpickup_fuel, &ondrop_fuel, &oncrafted_fuel, undefined, undefined, undefined, 10 );
	if ( level.is_forever_solo_game) {
		refuelable_plane_gas1.is_shared = 1;
		refuelable_plane_gas2.is_shared = 1;
		refuelable_plane_gas3.is_shared = 1;
		refuelable_plane_gas4.is_shared = 1;
		refuelable_plane_gas5.is_shared = 1;
		refuelable_plane_gas1.client_field_state = undefined;
		refuelable_plane_gas2.client_field_state = undefined;
		refuelable_plane_gas3.client_field_state = undefined;
		refuelable_plane_gas4.client_field_state = undefined;
		refuelable_plane_gas5.client_field_state = undefined;
	}
	refuelable_plane = SpawnStruct();
	refuelable_plane.name = craftable_name;
	refuelable_plane zm_craftables::add_craftable_piece( refuelable_plane_gas1 );
	refuelable_plane zm_craftables::add_craftable_piece( refuelable_plane_gas2 );
	refuelable_plane zm_craftables::add_craftable_piece( refuelable_plane_gas3 );
	refuelable_plane zm_craftables::add_craftable_piece( refuelable_plane_gas4 );
	refuelable_plane zm_craftables::add_craftable_piece( refuelable_plane_gas5 );
	refuelable_plane.triggerthink = &planefuelable;
	plane.custom_craftablestub_update_prompt = &prison_plane_update_prompt;
	include_craftable( refuelable_plane );
}

function register_clientfields() {
	bits = 1;
	RegisterClientField( "world", "piece_packasplat_fuse",	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "piece_packasplat_case",	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "piece_packasplat_blood", VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "piece_key_warden", VERSION_SHIP, 1, "int" );
	bits = GetMinBitCountForNum( 5 );
	RegisterClientField( "world", "piece_player_cloth", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "piece_player_fueltanks", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "piece_player_engine", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "piece_player_steering", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "piece_player_rigging", VERSION_SHIP, bits, "int", undefined, false );
	bits = GetMinBitCountForNum( 7 );
	RegisterClientField( "world", "quest_state1", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "quest_state2", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "quest_state3", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "quest_state4", VERSION_SHIP, bits, "int", undefined, false );
	RegisterClientField( "world", "quest_state5", VERSION_SHIP, bits, "int", undefined, false );

	RegisterClientField( "world", "quest_plane_craft_complete", VERSION_SHIP, 1, "int", undefined, false );
}

function packasplatcraftable() {
	zm_craftables::craftable_trigger_think( "packasplat_craftable_trigger", "packasplat", "packasplat", undefined, 1, 0 );
}

function planecraftable() {
	zm_craftables::craftable_trigger_think( "plane_craftable_trigger", "plane", "plane", undefined, 1, 0 );
	level clientfield::set( "quest_plane_craft_complete", 0 );
	i = 1;
	while ( i <= 5 ) {
		level clientfield::set( "quest_state" + i, 2 );
		i++;
	}
}

function planefuelable() {
	level thread planefuelable_think();
}

function planefuelable_think() {
	level flag::wait_till( "spawn_fuel_tanks" );
	level clientfield::set( "quest_plane_craft_complete", 1 );
	level.plane_fuel_1 = false;
	level.plane_fuel_2 = false;
	level.plane_fuel_3 = false;
	level.plane_fuel_4 = false;
	level.plane_fuel_5 = false;
	level.plane_fuel1_built = false;
	level.plane_fuel2_built = false;
	level.plane_fuel3_built = false;
	level.plane_fuel4_built = false;
	level.plane_fuel5_built = false;
	level thread zm_alcatraz_hud_buildables::players_hud_fuel();
	t_plane_fuelable = GetEnt( "plane_fuelable_trigger", "targetname" );
	t_plane_fuelable TriggerEnable(true);
	i = 1;
	while ( i <= 5 ) {
		level clientfield::set( "quest_state" + i, 5 );
		i++;
	}
	zm_craftables::craftable_trigger_think( "plane_fuelable_trigger", "refuelable_plane", "refuelable_plane", undefined, 1, 0 );
}

function ondrop_common( player ) {
/#
	IPrintLnBold( "ZM >> Common part callback onDrop()" );
#/
	self droponmover( player );
	self.piece_owner = undefined;
}

function onpickup_common( player ) {
/#
	IPrintLnBold( "ZM >> Common part callback onPickup()" );
#/
	player PlaySound( "zmb_craftable_pickup" );
	level thread zm_alcatraz_hud_buildables::players_hud_shield_splat(false, player, self.pieceName);
	switch(self.pieceName) {
		case "fuse":
			level thread zm_alcatraz_sq_vo::vo_pickup_gat_piece(2);
			break;
		case "case":
			level thread zm_alcatraz_sq_vo::vo_pickup_gat_piece(0);
			break;
		case "blood":
			level thread zm_alcatraz_sq_vo::vo_pickup_gat_piece(1);
			break;
	}
	self pickupfrommover();
	self.piece_owner = player;
}

function ondisconnect_common( player ) {
	level endon( "crafted_" + self.piecename );
	level endon( "dropped_" + self.piecename );
	player_num = player GetEntityNumber() + 1;
	player waittill( "disconnect" );
	switch( self.piecename ) {
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_dropped( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_dropped( "fueltank" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_dropped( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_dropped( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_dropped( "rigging" );
			break;
	}
	level clientfield::set( field_name, 2 );
	level clientfield::set( "piece_player_" + self.piecename, 0 );
	self zm_craftables::piece_spawn_at( player.origin, player.angles );
	m_plane_piece = zm_craftables::get_craftable_piece_model( "plane", self.piecename );
	if ( isdefined( m_plane_piece ) ) {
		PlayFXOnTag( level._effect[ "quest_item_glow" ], m_plane_piece, "tag_origin" );
	}
	m_fuel_can = zm_craftables::get_craftable_piece_model( "refuelable_plane", self.piecename );
	if ( isdefined( m_fuel_can ) ) {
		PlayFXOnTag( level._effect[ "quest_item_glow" ], m_fuel_can, "tag_origin" );
	}
}

function prison_open_craftablestub_update_prompt( player, b_set_hint_string_now, trigger ) {
	valid = zm_craftables::open_craftablestub_update_prompt( player );
	return valid;
}

function onpickup_key( player ) {
	level.flag_new["key_found"] = true;
	level.key_found = true;
	if ( level.is_master_key_west ) {
		level util::clientnotify( "fxanim_west_pulley_up_start" );
	}
	else {
		level util::clientnotify( "fxanim_east_pulley_up_start" );
	}
	level thread zm_alcatraz_hud_buildables::players_hud_key();
	a_m_checklist = GetEntArray( "plane_checklist", "targetname" );
	foreach(m_checklist in a_m_checklist) {
		m_checklist ShowPart( "j_check_key" );
		m_checklist ShowPart( "j_strike_key" );
	}
	a_door_structs = struct::get_array( "quest_trigger", "script_noteworthy" );
	foreach(struct in a_door_structs) {
		if ( isdefined( struct.unitrigger_stub ) ) {
			struct.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
		}
	}
	player PlaySound( "evt_key_pickup" );
	player thread zm_utility::do_player_general_vox( "quest", "sidequest_key_response", undefined, 100 );
	level clientfield::set( "piece_key_warden", 1 );
}

function prison_plane_update_prompt( player, b_set_hint_string_now, trigger ) {
	return 1;
}

function ondrop_plane( player ) {
/#
	IPrintLnBold( "ZM >> Common part callback onDrop()" );
#/
	level notify( "dropped_" + self.piecename );
	level.plane_pieces_picked_up -= 1;
	self droponmover( player );
	self.piece_owner = undefined;
	PlayFXOnTag( level._effect[ "quest_item_glow" ], self.model, "tag_origin" );
	switch( self.piecename ) {
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_dropped( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_dropped( "fueltank" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_dropped( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_dropped( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_dropped( "rigging" );
			break;
	}
	level clientfield::set( field_name, 2 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, 0 );
	}
}

function onpickup_plane( player ) {
/#
	IPrintLnBold( "ZM >> Common part callback onPickup()" );
#/
	if ( !isdefined( level.plane_pieces_picked_up ) ) {
		level.plane_pieces_picked_up = 0;
		level.sndplanepieces = 1;
	}
	level.plane_pieces_picked_up += 1;
	if ( level.plane_pieces_picked_up == 5 ) {
		level thread roof_nag_vo();
	}
	if ( level.sndplanepieces == level.plane_pieces_picked_up ) {
		level thread zm_alcatraz_amb::sndplaystinger( "piece_" + level.sndplanepieces );
		level.sndplanepieces++;
	}
	player PlaySound( "zmb_craftable_pickup" );
	vo_alias_call = undefined;
	vo_alias_response = undefined;
	self pickupfrommover();
	self.piece_owner = player;
	switch( self.piecename ) {
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_picked_up( "sheets" );
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_picked_up( "fueltank" );
			level flag::set( "docks_gates_remain_open" );
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_picked_up( "engine" );
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_picked_up( "contval" );
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_picked_up( "rigging" );
			break;
	}
	level thread zm_alcatraz_hud_buildables::players_hud_plane(self);
	level clientfield::set( field_name, 3 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, player.characterIndex + 1 );
	}
	vo_alias_call = self check_if_newly_found();
	if ( isdefined( vo_alias_call ) ) {
		level thread play_plane_piece_call_and_response_vo( player, vo_alias_call );
	}
	self thread ondisconnect_common( player );
}

function check_if_newly_found() {
	if ( !level flag::get( self.piecename + "_found" ) ) {
		switch( self.piecename ) {
			case "fueltanks":
				vo_alias_call = "sidequest_oxygen";
				break;
			case "cloth":
				vo_alias_call = "sidequest_sheets";
				break;
			case "engine":
				vo_alias_call = "sidequest_engine";
				break;
			case "steering":
				vo_alias_call = "sidequest_valves";
				break;
			case "rigging":
				vo_alias_call = "sidequest_rigging";
				break;
		}
		level.n_plane_pieces_found++;
		level flag::set( self.piecename + "_found" );
		if ( self.piecename == "cloth" ) {
			level util::clientnotify( "fxanim_dryer_hide_start" );
			m_dryer_model = GetEnt("ind_dryer_model","targetname");
			m_dryer_model HidePart("tag_tshirt_jnt");
			m_dryer_model HidePart("tag_tshirt_bend_01_jnt");
			m_dryer_model HidePart("tag_tshirt_bend_02_jnt");
			m_dryer_model HidePart("tag_tanktop_jnt");
			m_dryer_model HidePart("tag_tanktop_bend_jnt");
			m_dryer_model HidePart("tag_sweater_bend_01_jnt");
			m_dryer_model HidePart("tag_sweater_bend_02_jnt");
			m_dryer_model HidePart("tag_clump_jnt");
			m_dryer_model HidePart("tag_clump2_jnt");
		}
		return vo_alias_call;
	}
}

function play_plane_piece_call_and_response_vo( player, vo_alias_call ) {
	player endon( "death" );
	player endon( "disconnect" );
	n_response_range = 1500;
	players = GetPlayers();
	if ( !level flag::get( "story_vo_playing" ) ) {
		level flag::set( "story_vo_playing" );
		player zm_utility::do_player_general_vox( "quest", vo_alias_call, undefined, 100 );
		wait 5;
		if ( players.size > 1 ) {
			ArrayRemoveValue( players, player );
			closest_other_player = array::get_closest( player.origin, players );
			if ( isdefined( closest_other_player ) ) {
				n_dist = Distance( player.origin, closest_other_player.origin );
				if ( isdefined( closest_other_player ) && n_dist < n_response_range ) {
					if ( level.n_plane_pieces_found < 5 ) {
						vo_alias_response = "sidequest_parts" + level.n_plane_pieces_found + "_prog";
					}
					else {
						vo_alias_response = "sidequest_all_parts";
					}
					closest_other_player zm_utility::do_player_general_vox( "quest", vo_alias_response, undefined, 100 );
				}
			}
		}
		level flag::clear( "story_vo_playing" );
	}
}

function roof_nag_vo() {
	level notify( "roof_nag_vo" );
	level endon( "roof_nag_vo" );
	zone_roof = GetEnt( "zone_roof", "targetname" );
	zone_roof_infirmary = GetEnt( "zone_roof_infirmary", "targetname" );
	n_roof_nag_wait = 60;
	n_roof_nag_max_times = 3;
	while ( !level flag::get( "plane_built" ) && n_roof_nag_max_times > 0 ) {
		wait n_roof_nag_wait;
		b_is_a_player_on_the_roof = 0;
		foreach(player in GetPlayers()) {
			if ( player IsTouching( zone_roof ) || player IsTouching( zone_roof_infirmary ) ) {
				b_is_a_player_on_the_roof = 1;
			}
		}
		if ( !b_is_a_player_on_the_roof ) {
			if ( level.plane_pieces_picked_up == 5 ) {
				players = GetPlayers();
				player = players[ RandomIntRange( 0, players.size ) ];
				if ( isdefined( player ) ) {
					player zm_utility::do_player_general_vox( "quest", "sidequest_roof_nag", undefined, 100 );
					n_roof_nag_wait *= 1.5;
					n_roof_nag_max_times--;
				}
			}
		}
	}
}

function oncrafted_plane( player ) {
	level notify( "crafted_" + self.piecename );
	m_plane_hideable_engine = GetEnt( "plane_hideable_engine", "targetname" );
	m_plane_hideable_clothes_pile = GetEnt( "plane_hideable_clothes_pile", "targetname" );
	m_plane_hideable_engine Ghost();
	m_plane_hideable_clothes_pile Ghost();
	plane_craftable = GetEnt( "plane_craftable", "targetname" );
	plane_craftable HidePart( "tag_support_upper" );
	plane_craftable HidePart( "tag_wings_down" );
	plane_craftable HidePart( "tag_wing_skins_down" );
	plane_craftable HidePart( "tag_wing_skins_up" );
	plane_craftable HidePart( "tag_engines_down" );
	plane_craftable HidePart( "tag_engines_up" );
	plane_craftable HidePart( "tag_engine_ground" );
	plane_craftable HidePart( "tag_clothes_ground" );
	plane_craftable HidePart( "tag_fuel_hose" );
	plane_craftable HidePart( "tag_feul_tanks" );
	plane_craftable HidePart( "tag_control_mechanism" );
	if ( !isdefined( level.sndplanecrafted ) ) {
		level.sndplanecrafted = 0;
	}
	level.sndplanecrafted++;
	level thread zm_alcatraz_amb::sndplaystinger( "plane_crafted_" + level.sndplanecrafted );
	if ( zm_craftables::is_part_crafted( "plane", "rigging" ) ) {
		plane_craftable ShowPart( "tag_support_upper" );
		if ( zm_craftables::is_part_crafted( "plane", "cloth" ) ) {
			plane_craftable ShowPart( "tag_wing_skins_up" );
		}
		if ( zm_craftables::is_part_crafted( "plane", "engine" ) ) {
			plane_craftable ShowPart( "tag_engines_up" );
		}
	}
	else {
		plane_craftable ShowPart( "tag_wings_down" );
		if ( zm_craftables::is_part_crafted( "plane", "cloth" ) ) {
			m_plane_hideable_clothes_pile Show();
		}
		if ( zm_craftables::is_part_crafted( "plane", "engine" ) ) {
			m_plane_hideable_engine Show();
		}
	}
	if ( zm_craftables::is_part_crafted( "plane", "steering" ) ) {
		plane_craftable ShowPart( "tag_control_mechanism" );
	}
	if ( zm_craftables::is_part_crafted( "plane", "fueltanks" ) ) {
		plane_craftable ShowPart( "tag_feul_tanks" );
	}
	if ( zm_craftables::is_part_crafted( "plane", "steering" ) && zm_craftables::is_part_crafted( "plane", "fueltanks" ) ) {
		plane_craftable ShowPart( "tag_fuel_hose" );
	}
	switch( self.piecename ) {
		case "cloth":
			field_name = "quest_state1";
			in_game_checklist_plane_piece_crafted( "sheets" );
			level.plane_clothes_built = true;
			break;
		case "fueltanks":
			field_name = "quest_state2";
			in_game_checklist_plane_piece_crafted( "fueltank" );
			level.plane_tanks_built = true;
			break;
		case "engine":
			field_name = "quest_state3";
			in_game_checklist_plane_piece_crafted( "engine" );
			level.plane_engine_built = true;
			break;
		case "steering":
			field_name = "quest_state4";
			in_game_checklist_plane_piece_crafted( "contval" );
			level.plane_control_built = true;
			break;
		case "rigging":
			field_name = "quest_state5";
			in_game_checklist_plane_piece_crafted( "rigging" );
			level.plane_riggings_built = true;
			break;
	}
	level clientfield::set( field_name, 4 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, 0 );
	}
}

function plane_hud_on_crafted() {
	level endon( "intermission" );
	while(1) {
		zm_craftables::waittill_crafted( "plane" );
		level thread zm_alcatraz_hud_buildables::players_hud_plane();
	}
}

function fuel_hud_on_crafted() {
	level endon( "intermission" );
	while(1) {
		zm_craftables::waittill_crafted( "refuelable_plane" );
		level thread zm_alcatraz_hud_buildables::players_hud_fuel();
	}
}

function ondrop_fuel( player ) {
	level notify( "dropped_" + self.piecename );
	self.piece_owner = undefined;
	PlayFXOnTag( level._effect[ "quest_item_glow" ], self.model, "tag_origin" );
	if ( isdefined( level.sndfuelpieces ) ) {
		level.sndfuelpieces--;
	}
	switch( self.piecename ) {
		case "fuel1":
			field_name = "quest_state1";
			break;
		case "fuel2":
			field_name = "quest_state2";
			break;
		case "fuel3":
			field_name = "quest_state3";
			break;
		case "fuel4":
			field_name = "quest_state4";
			break;
		case "fuel5":
			field_name = "quest_state5";
			break;
	}
	level clientfield::set( field_name, 5 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, 0 );
	}
}

function onpickup_fuel( player ) {
	player PlaySound( "zmb_craftable_pickup" );
	if ( !isdefined( level.sndfuelpieces ) || level.sndfuelpieces >= 5 ) {
		level.sndfuelpieces = 0;
	}
	level.sndfuelpieces++;
	level thread zm_alcatraz_amb::sndplaystinger( "gas_" + level.sndfuelpieces );
	self pickupfrommover();
	self.piece_owner = player;
	if ( isdefined( player ) ) {
		player zm_utility::do_player_general_vox( "quest", "fuel_pickup", undefined, 100 );
	}
	switch( self.piecename ) {
		case "fuel1":
			field_name = "quest_state1";
			break;
		case "fuel2":
			field_name = "quest_state2";
			break;
		case "fuel3":
			field_name = "quest_state3";
			break;
		case "fuel4":
			field_name = "quest_state4";
			break;
		case "fuel5":
			field_name = "quest_state5";
			break;
	}
	level thread zm_alcatraz_hud_buildables::players_hud_fuel(self);
	level clientfield::set( field_name, 6 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, player.characterIndex + 1 );
	}
	self thread ondisconnect_common( player );
}

function oncrafted_fuel( player ) {
	level notify( "crafted_" + self.piecename );
	level.n_plane_fuel_count++;
	switch( self.piecename ) {
		case "fuel1":
			field_name = "quest_state1";
			level.plane_fuel1_built = true;
			break;
		case "fuel2":
			field_name = "quest_state2";
			level.plane_fuel2_built = true;
			break;
		case "fuel3":
			field_name = "quest_state3";
			level.plane_fuel3_built = true;
			break;
		case "fuel4":
			field_name = "quest_state4";
			level.plane_fuel4_built = true;
			break;
		case "fuel5":
			field_name = "quest_state5";
			level.plane_fuel5_built = true;
			break;
	}
	level clientfield::set( field_name, 7 );
	if ( !level.is_forever_solo_game || GetPlayers().size > 1) {
		level clientfield::set( "piece_player_" + self.piecename, 0 );
	}
}

function onfullycrafted_plane( player ) {
	level flag::set( "plane_built" );
	level notify ("plane_fully_build");
	level thread zm_alcatraz_sq_vo::escape_flight_vo();
	level notify( "roof_nag_vo" );
	return 0;
}

function onfullycrafted_packasplat( player ) {
	level notify ("packasplat_fully_built");
	t_upgrade = GetEnt( "blundergat_upgrade", "targetname" );
	t_upgrade.target = self.target;
	t_upgrade.origin = self.origin;
	t_upgrade.angles = self.angles;
	t_upgrade.m_upgrade_machine = zm_craftables::get_craftable_model( "packasplat" );

	alt = RandomIntRange( 1, 3 );
	level thread zm_alcatraz_sq_vo::vo_finalize_gat(alt);
	return 1;
}

function onfullycrafted_refueled( player ) {
	level flag::set( "plane_built" );
	level notify ("plane_fully_fuelled");
	level thread zm_alcatraz_sq_vo::escape_flight_vo();
	level notify( "roof_nag_vo" );
	thread onfullycrafted_refueled_think( player );
	return 0;
}

function onfullycrafted_refueled_think( player ) {
	level flag::wait_till( "spawn_fuel_tanks" );
	level.plane_fuel_1 = false;
	level.plane_fuel_2 = false;
	level.plane_fuel_3 = false;
	level.plane_fuel_4 = false;
	level.plane_fuel_5 = false;
	level.plane_fuel1_built = false;
	level.plane_fuel2_built = false;
	level.plane_fuel3_built = false;
	level.plane_fuel4_built = false;
	level.plane_fuel5_built = false;
	level thread zm_alcatraz_hud_buildables::players_hud_fuel();
	i = 1;
	while ( i <= 5 ) {
		level clientfield::set( "quest_state" + i, 5 );
		i++;
	}
	zm_craftables::stub_uncraft_craftable( self, 1, undefined, undefined, 1 );
}

function sqcommoncraftable() {
	level.sq_craftable = zm_craftables::craftable_trigger_think( "sq_common_craftable_trigger", "sq_common", "sq_common", "", 1, 0 );
}

function onbuyweapon_plane( player ) {
	level notify( "plane_takeoff" );
	//IPrintLnBold( "Plane Bought" );
}

function droponmover( player ) {
	/*while ( isdefined( player ) && player zm_alcatraz_travel::is_player_on_gondola() )
	{
		str_location = undefined;
		if ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving && isdefined( level.e_gondola.destination ) )
		{
			str_location = level.e_gondola.destination;
		}
		else
		{
			str_location = level.e_gondola.location;
		}
		if ( !isdefined( str_location ) )
		{
			str_location = "roof";
		}
		a_s_part_teleport = struct::get_array( "gondola_dropped_parts_" + str_location, "targetname" );
		_a1104 = a_s_part_teleport;
		_k1104 = GetFirstArrayKey( _a1104 );
		while ( isdefined( _k1104 ) )
		{
			struct = _a1104[ _k1104 ];
			if ( isdefined( struct.occupied ) && !struct.occupied )
			{
				self.model.origin = struct.origin;
				self.model.angles = struct.angles;
				struct.occupied = 1;
				self.unitrigger.struct_teleport = struct;
				return;
			}
			else
			{
				_k1104 = GetNextArrayKey( _a1104, _k1104 );
			}
		}
	}*/
}

function pickupfrommover() {
	if ( isdefined( self.unitrigger ) ) {
		if ( isdefined( self.unitrigger.struct_teleport ) ) {
			self.unitrigger.struct_teleport.occupied = 0;
			self.unitrigger.struct_teleport = undefined;
		}
	}
}

function in_game_checklist_setup() {
	a_m_checklist = GetEntArray( "plane_checklist", "targetname" );
	a_str_partnames = [];
	a_str_partnames[ 0 ] = "sheets";
	a_str_partnames[ 1 ] = "fueltank";
	a_str_partnames[ 2 ] = "engine";
	a_str_partnames[ 3 ] = "contval";
	a_str_partnames[ 4 ] = "rigging";
	a_str_partnames[ 5 ] = "key";
	foreach(m_checklist in a_m_checklist) {
		foreach(str_partname in a_str_partnames) {
			m_checklist HidePart( "j_check_" + str_partname );
			m_checklist HidePart( "j_strike_" + str_partname );
		}
	}
}

function in_game_checklist_plane_piece_picked_up( str_partname ) {
	a_m_checklist = GetEntArray( "plane_checklist", "targetname" );
	foreach(m_checklist in a_m_checklist) {
		m_checklist ShowPart( "j_check_" + str_partname );
	}
}

function in_game_checklist_plane_piece_dropped( str_partname ) {
	a_m_checklist = GetEntArray( "plane_checklist", "targetname" );
	foreach(m_checklist in a_m_checklist) {
		m_checklist HidePart( "j_check_" + str_partname );
	}
}

function in_game_checklist_plane_piece_crafted( str_partname ) {
	a_m_checklist = GetEntArray( "plane_checklist", "targetname" );
	foreach(m_checklist in a_m_checklist) {
		m_checklist ShowPart( "j_strike_" + str_partname );
	}
}

function alcatraz_craftable_trigger_think( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) {
	return alcatraz_setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

function alcatraz_setup_unitrigger_craftable( trigger_targetname, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) {
	trig = GetEnt( trigger_targetname, "targetname" );
	if ( !isdefined( trig ) ) {
		return;
	}
	trig.script_length = 386;
	return alcatraz_setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent );
}

function alcatraz_setup_unitrigger_craftable_internal( trig, equipname, weaponname, trigger_hintstring, delete_trigger, persistent ) {
	if ( !isdefined( trig ) ) {
		return;
	}
	unitrigger_stub = SpawnStruct();
	unitrigger_stub.craftablestub = level.zombie_include_craftables[ equipname ];
	angles = trig.script_angles;
	if ( !isdefined( angles ) ) {
		angles = ( 0, 0, 0 );
	}
	unitrigger_stub.origin = trig.origin + ( AnglesToRight( angles ) * -6 );
	unitrigger_stub.angles = trig.angles;
	if ( isdefined( trig.script_angles ) ) {
		unitrigger_stub.angles = trig.script_angles;
	}
	unitrigger_stub.equipname = equipname;
	unitrigger_stub.weaponname = weaponname;
	unitrigger_stub.trigger_hintstring = trigger_hintstring;
	unitrigger_stub.delete_trigger = delete_trigger;
	unitrigger_stub.crafted = 0;
	unitrigger_stub.persistent = persistent;
	unitrigger_stub.usetime = Int( 3000 );
	unitrigger_stub.onbeginuse = &zm_craftables::onbeginuseuts;
	unitrigger_stub.onenduse = &zm_craftables::onenduseuts;
	unitrigger_stub.onuse = &zm_craftables::onuseplantobjectuts;
	unitrigger_stub.oncantuse = &zm_craftables::oncantuseuts;
	if ( isdefined( trig.script_length ) ) {
		unitrigger_stub.script_length = trig.script_length;
	}
	else {
		unitrigger_stub.script_length = 32;
	}
	if ( isdefined( trig.script_width ) ) {
		unitrigger_stub.script_width = trig.script_width;
	}
	else {
		unitrigger_stub.script_width = 100;
	}
	if ( isdefined( trig.script_height ) ) {
		unitrigger_stub.script_height = trig.script_height;
	}
	else {
		unitrigger_stub.script_height = 64;
	}
	unitrigger_stub.target = trig.target;
	unitrigger_stub.targetname = trig.targetname;
	unitrigger_stub.script_noteworthy = trig.script_noteworthy;
	unitrigger_stub.script_parameters = trig.script_parameters;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( isDefined( level.zombie_craftablestubs[ equipname ].hint ) ) {
		unitrigger_stub.hint_string = level.zombie_craftablestubs[ equipname ].hint;
	}
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 0;
	zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( isdefined( unitrigger_stub.craftablestub.custom_craftablestub_update_prompt ) ) {
		unitrigger_stub.custom_craftablestub_update_prompt = unitrigger_stub.craftablestub.custom_craftablestub_update_prompt;
	}
	unitrigger_stub.prompt_and_visibility_func = &zm_craftables::craftabletrigger_update_prompt;
	zm_unitrigger::register_static_unitrigger( unitrigger_stub, &zm_craftables::craftable_place_think );
	unitrigger_stub.piece_trigger = trig;
	trig.trigger_stub = unitrigger_stub;
	unitrigger_stub.zombie_weapon_upgrade = trig.zombie_weapon_upgrade;
	if ( isdefined( unitrigger_stub.target ) ) {
		unitrigger_stub.model = GetEnt( unitrigger_stub.target, "targetname" );
		if ( isdefined( unitrigger_stub.model ) ) {
			if ( isdefined( unitrigger_stub.zombie_weapon_upgrade ) ) {
				unitrigger_stub.model UseWeaponHideTags( unitrigger_stub.zombie_weapon_upgrade );
			}
			unitrigger_stub.model Ghost();
			unitrigger_stub.model NotSolid();
		}
	}
	unitrigger_stub.craftablespawn = unitrigger_stub &zm_craftables::craftable_piece_unitriggers( equipname, unitrigger_stub.origin );
	if ( delete_trigger ) {
		trig Delete();
	}
	level.a_uts_craftables[ level.a_uts_craftables.size ] = unitrigger_stub;
	return unitrigger_stub;
}


function include_craftable( craftable_struct ) {
/#
	IPrintLnBold( "ZM >> include_craftable = " + craftable_struct.name );
#/
	zm_craftables::include_zombie_craftable( craftable_struct );
}

function blundergat_upgrade_station() {
	t_upgrade = GetEnt( "blundergat_upgrade", "targetname" );
	t_upgrade SetHintString( "Hold ^3&&1^7 to convert Blundergat into Acidgat" );
	t_upgrade SetCursorHint( "HINT_NOICON" );
	level waittill ("packasplat_fully_built");
	//zm_craftables::waittill_crafted( "packasplat" );
	m_converter = t_upgrade.m_upgrade_machine;
	v_angles = m_converter GetTagAngles( "tag_origin" );
	v_weapon_origin_offset = ( ( AnglesToForward( v_angles ) * 1 ) + ( AnglesToRight( v_angles ) * 10 ) ) + ( AnglesToUp( v_angles ) * 1.75 );
	v_weapon_angles_offset = ( 0, 90, -90 );
	m_converter.v_weapon_origin = m_converter GetTagOrigin( "tag_origin" ) + v_weapon_origin_offset;
	m_converter.v_weapon_angles = v_angles + v_weapon_angles_offset;
	m_converter UseAnimTree( #Animtree );
	m_converter.fxanims[ "close" ] = %fxanim_zom_al_packasplat_start_anim;
	m_converter.fxanims[ "inject" ] = %fxanim_zom_al_packasplat_idle_anim;
	m_converter.fxanims[ "open" ] = %fxanim_zom_al_packasplat_end_anim;
	m_converter.n_start_time = GetAnimLength( m_converter.fxanims[ "close" ] );
	m_converter.n_idle_time = GetAnimLength( m_converter.fxanims[ "inject" ] );
	m_converter.n_end_time = GetAnimLength( m_converter.fxanims[ "open" ] );
	while ( 1 ) {
		t_upgrade thread blundergat_change_hintstring( "Hold ^3&&1^7 to use Acid Gat Kit" );
		t_upgrade waittill( "trigger", player );
		str_valid_weapon = undefined;
		if ( player HasWeapon( GetWeapon("bo2_blundergat") ) ) {
			str_valid_weapon = "bo2_blundergat";
		}
		else {
			if ( player HasWeapon( GetWeapon("bo2_blundergat_upgraded") ) ) {
				str_valid_weapon = "bo2_blundergat_upgraded";
			}
		}
		if ( isdefined( str_valid_weapon ) ) {
			player TakeWeapon( GetWeapon(str_valid_weapon) );
			player.is_pack_splatting = 1;
			t_upgrade SetInvisibleToAll();
			m_converter.worldgun = zm_utility::spawn_weapon_model( GetWeapon(str_valid_weapon), undefined, m_converter.v_weapon_origin, m_converter.v_weapon_angles );
			m_converter blundergat_upgrade_station_inject( str_valid_weapon );
			t_upgrade thread blundergat_change_hintstring( "Hold ^3&&1^7 to take your converted weapon" );
			if ( isdefined( player ) )
			{
				t_upgrade SetVisibleToPlayer( player );
				t_upgrade thread wait_for_player_to_take( player, str_valid_weapon );
			}
			t_upgrade thread wait_for_timeout();
			t_upgrade util::waittill_any( "acid_timeout", "acid_taken" );
			if ( isdefined( player ) )
			{
				player.is_pack_splatting = undefined;
			}
			m_converter.worldgun Delete();
			wait 0.5;
			t_upgrade SetVisibleToAll();
			continue;
		}
		else {
			t_upgrade thread blundergat_change_hintstring( "Needs Blundergat or Sweeper" );
			wait 2;
		}
	}
}

function wait_for_player_to_take( player, str_valid_weapon ) {
	self endon( "acid_timeout" );
	player endon( "disconnect" );
	while ( 1 ) {
		self waittill( "trigger", trigger_player );
		if ( trigger_player == player ) {
			current_weapon = player GetCurrentWeapon();
			if ( zm_utility::is_player_valid( player ) && !player.is_drinking && !zm_utility::is_placeable_mine( current_weapon ) && !zm_equipment::is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" ) {
				self notify( "acid_taken" );
				player notify( "acid_taken" );
				weapon_limit = 2;
				primaries = player GetWeaponsListPrimaries();
				if ( isdefined( primaries ) && primaries.size >= weapon_limit ) {
					player TakeWeapon( current_weapon );
				}
				str_new_weapon = undefined;
				if ( str_valid_weapon == "bo2_blundergat" ) {
					str_new_weapon = "bo2_acidgat";
				}
				else {
					str_new_weapon = "bo2_acidgat_upgraded";
				}
				if ( player HasWeapon( GetWeapon("bo2_acidgat") ) ) {
					player GiveMaxAmmo( GetWeapon("bo2_acidgat") );
				}
				else if ( player HasWeapon( GetWeapon("bo2_acidgat_upgraded") ) ) {
					player GiveMaxAmmo( GetWeapon("bo2_acidgat_upgraded") );
				}
				else {
					player GiveWeapon( GetWeapon(str_new_weapon) );
					player SwitchToWeapon( GetWeapon(str_new_weapon) );
				}
				player thread zm_utility::do_player_general_vox( "general", "player_recieves_blundersplat" );
				player notify( "player_obtained_acidgat" );
				//player thread player_lost_blundersplat_watcher();
				return;
			}
			else {
				//IPrintLnBold("something went wrong");
			}
		}
		else {
			//IPrintLnBold("wrong player");
		}
		wait 0.05;
	}
}

function blundergat_upgrade_station_inject( str_weapon_model ) {
	wait 0.5;
	self PlaySound( "acid_upgrade" );
	self AnimScripted( "optionalNotify", self.origin , self.angles, self.fxanims[ "close" ]);
	wait self.n_start_time;
	i = 0;
	while ( i < 3 ) {
		self AnimScripted( "optionalNotify", self.origin , self.angles, self.fxanims[ "inject" ]);
		wait self.n_idle_time;
		i++;
	}
	self.worldgun Delete();
	if ( str_weapon_model == "bo2_blundergat" ) {
		self.worldgun = zm_utility::spawn_weapon_model( GetWeapon("bo2_acidgat"), undefined, self.v_weapon_origin, self.v_weapon_angles );
	}
	else {
		self.worldgun = zm_utility::spawn_weapon_model( GetWeapon("bo2_acidgat_upgraded"), undefined, self.v_weapon_origin, self.v_weapon_angles );
	}
	self AnimScripted( "optionalNotify", self.origin , self.angles, self.fxanims[ "open" ]);
	wait self.n_end_time;
	wait 0.5;
}

function player_lost_blundersplat_watcher() {
	while ( isdefined( self ) ) {
		if ( IsAlive( self ) ) {
			primaries = self GetWeaponsListPrimaries();
			if ( !IsInArray( primaries, GetWeapon("bo2_acidgat") ) && !IsInArray( primaries, GetWeapon("bo2_acidgat_upgraded") ) ) {
				if ( isdefined( self.afterlife ) && !self.afterlife ) {
					return;
				}
			}
		}
		else {
			wait 1;
		}
		wait 0.05;
	}
}

function wait_for_timeout() {
	self endon( "acid_taken" );
	wait 15;
	self notify( "acid_timeout" );
}

function blundergat_change_hintstring( hint_string ) {
	self notify( "new_change_hint_string" );
	self endon( "new_change_hint_string" );
	while ( isdefined( self.is_locked ) && self.is_locked ) {
		wait 0.05;
	}
	self SetHintString( hint_string );
	wait 0.05;
	self SetHintString( hint_string );
}