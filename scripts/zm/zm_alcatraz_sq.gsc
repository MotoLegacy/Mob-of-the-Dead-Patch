#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\lui_shared;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_ai_brutus;

#using scripts\zm\zm_alcatraz_sq_vo;
#using scripts\zm\zm_alcatraz_sq_nixie;
#using scripts\zm\zm_prison_sq_final;
#using scripts\zm\zm_alcatraz_amb;

#using scripts\zm\_zm_afterlife;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "fx", "custom/jerri/buildable/buildable_fx" );
#precache( "fx", "custom/jerri/buildable/key_elec_fx" );
#precache( "fx", "custom/jerri/buildable/key_take_fx" );
#precache( "fx", "custom/jerri/plane/fx_alcatraz_unlock_door" );
#precache( "fx", "custom/jerri/plane/generator_on" );
#precache( "fx", "custom/jerri/plane/fx_alcatraz_panel_ol" );
#precache( "fx", "custom/jerri/plane/fx_alcatraz_plane_apear" );
#precache( "fx", "custom/jerri/plane/fx_alcatraz_plane_trail" );
#precache( "fx", "custom/jerri/plane/fx_alcatraz_flight_lightning" );
#precache( "fx", "custom/jerri/plane/fx_wardens_office_door" );
#precache( "fx", "custom/jerri/plane/elec_chair_inside" );
#precache( "fx", "weather/fx_lightning_clouds_close_inf" );
#precache( "fx", "weather/fx_cloud_cover_vertical_infection" );
#precache( "fx", "zombie/fx_ritual_barrier_defend_door_wide_zod_zmb" );

#precache( "xmodel", "p6_zm_al_power_station_panels_03" );
#precache( "xmodel", "p6_zm_al_shock_box_on" );

#precache( "xmodel", "c_zom_player_oleary_fb_chair" );
#precache( "xmodel", "c_zom_player_deluca_fb_chair" );
#precache( "xmodel", "c_zom_player_handsome_fb_chair" );
#precache( "xmodel", "c_zom_player_arlington_fb_chair" );

#using_animtree("generic");

function init()
{
	//registerclientfield( "world", "fake_master_key", 9000, 2, "int" );
	level._effect["key_glint"]	= "custom/jerri/buildable/key_take_fx";
	level._effect["key_elec_fx"]	= "custom/jerri/buildable/key_elec_fx";
	level._effect["quest_item_glow"]	= "custom/jerri/buildable/buildable_fx";
	level._effect["fx_alcatraz_unlock_door"]	= "custom/jerri/plane/fx_alcatraz_unlock_door";
	level._effect["fx_alcatraz_panel_on_2"]	= "custom/jerri/plane/generator_on";
	level._effect["fx_alcatraz_panel_ol"]	= "custom/jerri/plane/fx_alcatraz_panel_ol";
	level._effect["fx_alcatraz_plane_apear"]	= "custom/jerri/plane/fx_alcatraz_plane_apear";
	level._effect["fx_alcatraz_plane_trail"]	= "custom/jerri/plane/fx_alcatraz_plane_trail";
	level._effect["fx_alcatraz_flight_lightning"]	= "custom/jerri/plane/fx_alcatraz_flight_lightning";
	level._effect["fx_alcatraz_flight_lightning_new"]	= "weather/fx_lightning_clouds_close_inf";
	level._effect["fx_wardens_office_door"]	= "custom/jerri/plane/fx_wardens_office_door";
	level._effect["fx_alcatraz_elec_chair"]	= "custom/jerri/plane/elec_chair_inside";
	level._effect["fog_rolling_in"] = "weather/fx_cloud_cover_vertical_infection";
	level._effect["lockdown_fx"] = "zombie/fx_ritual_barrier_defend_door_wide_zod_zmb";
	level flag::init( "map_revealed" );
	level.flag_new["key_found"] = false;
	level.key_found = false;
	level flag::init( "cloth_found" );
	level flag::init( "fueltanks_found" );
	level flag::init( "engine_found" );
	level flag::init( "steering_found" );
	level flag::init( "rigging_found" );
	level flag::init( "plane_ready" );
	level flag::init( "plane_built" );
	level flag::init( "plane_boarded" );
	level flag::init( "plane_departed" );
	level flag::init( "plane_approach_bridge" );
	level flag::init( "plane_zapped" );
	level flag::init( "plane_crashed" );
	level flag::init( "portal_open" );
	level flag::init( "spawn_fuel_tanks" );
	level flag::init( "plane_is_away" );
	level flag::init( "plane_trip_to_nml_successful" );
	level flag::init( "story_vo_playing" );
	level flag::init( "docks_inner_gate_unlocked" );
	level flag::init( "docks_inner_gate_open" );
	level flag::init( "docks_outer_gate_open" );
	level flag::init( "docks_gates_remain_open" );
	level flag::init( "generator_challenge_completed" );
	level flag::init( "dryer_cycle_active" );
	level flag::init( "quest_completed_thrice" );
	level flag::init( "final_quest_ready" );
	level flag::init( "final_quest_audio_tour_started" );
	level flag::init( "final_quest_audio_tour_finished" );
	level flag::init( "final_quest_plane_built" );
	level flag::init( "final_quest_plane_boarded" );
	level flag::init( "final_quest_plane_departed" );
	level flag::init( "final_quest_plane_zapped" );
	level flag::init( "final_quest_plane_crashed" );
	level flag::init( "final_quest_final_battle_started" );
	level flag::init( "final_quest_good_wins" );
	level flag::init( "final_quest_evil_wins" );
}

function start_alcatraz_sidequest()
{
	init();
	callback::on_connect( &player_disconnect_watcher );
	callback::on_connect( &player_death_watcher );

	level flag::wait_till( "start_zombie_round_logic" );
	level clientfield::set( "fog_stage", 3 );
	
	level.n_quest_iteration_count = 1;
	level.n_plane_fuel_count = 5;
	level.n_plane_pieces_found = 0;
	level.final_flight_players = [];
	level.final_flight_activated = 0;
	level.characters_in_nml = [];
	level.someone_has_visited_nml = 0;
	//level.custom_game_over_hud_elem = &zm_prison_sq_final::custom_game_over_hud_elem;
	prevent_theater_mode_spoilers();
	setup_key_doors();
	setup_puzzle_piece_glint();
	setup_puzzles();
	setup_quest_triggers();
	zm_prison_sq_final::final_flight_setup();
	level thread warden_fence_hotjoin_handler();
	if ( isdefined( level.host_migration_listener_custom_func ) )
	{
		level thread [[ level.host_migration_listener_custom_func ]]();
	}
	else
	{
		level thread host_migration_listener();
	}
	if ( isdefined( level.manage_electric_chairs_custom_func ) )
	{
		level thread [[ level.manage_electric_chairs_custom_func ]]();
	}
	else
	{
		level thread manage_electric_chairs();
	}
	if ( isdefined( level.plane_flight_thread_custom_func ) )
	{
		level thread [[ level.plane_flight_thread_custom_func ]]();
	}
	else
	{
		level thread plane_flight_thread();
	}
	if ( isdefined( level.track_quest_status_thread_custom_func ) )
	{
		level thread [[ level.track_quest_status_thread_custom_func ]]();
	}
	else
	{
		level thread track_quest_status_thread();
	}
	zm_alcatraz_sq_vo::opening_vo();
}

function host_migration_listener()
{
	level endon( "end_game" );
	level notify( "afterlife_hostmigration" );
	level endon( "afterlife_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
		m_plane_about_to_crash = GetEnt( "plane_about_to_crash", "targetname" );
		veh_plane_flyable = GetEnt( "plane_flyable", "targetname" );
		a_players = GetPlayers();
		if ( level flag::get( "plane_boarded" ) && !level flag::get( "plane_departed" ) )
		{
			_a215 = a_players;
			_k215 = GetFirstArrayKey( _a215 );
			while ( isdefined( _k215 ) )
			{
				player = _a215[ _k215 ];
				if ( isdefined( player ) && isdefined( player.character_name ) && IsInArray( level.characters_in_nml, player.character_name ) )
				{
					player PlayerLinkToDelta( m_plane_craftable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
				}
				_k215 = GetNextArrayKey( _a215, _k215 );
			}
		}
		else if ( level flag::get( "plane_departed" ) && !level flag::get( "plane_approach_bridge" ) )
		{
			_a225 = a_players;
			_k225 = GetFirstArrayKey( _a225 );
			while ( isdefined( _k225 ) )
			{
				player = _a225[ _k225 ];
				if ( isdefined( player ) && isdefined( player.character_name ) && IsInArray( level.characters_in_nml, player.character_name ) )
				{
					player PlayerLinkToDelta( veh_plane_flyable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
				}
				_k225 = GetNextArrayKey( _a225, _k225 );
			}
		}
		else if ( level flag::get( "plane_approach_bridge" ) && !level flag::get( "plane_zapped" ) )
		{
			_a235 = a_players;
			_k235 = GetFirstArrayKey( _a235 );
			while ( isdefined( _k235 ) )
			{
				player = _a235[ _k235 ];
				if ( isdefined( player ) && isdefined( player.character_name ) && IsInArray( level.characters_in_nml, player.character_name ) )
				{
					player PlayerLinkToAbsolute( veh_plane_flyable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
				}
				_k235 = GetNextArrayKey( _a235, _k235 );
			}
		}
		else if ( level flag::get( "plane_zapped" ) && !level flag::get( "plane_crashed" ) )
		{
			_a245 = a_players;
			_k245 = GetFirstArrayKey( _a245 );
			while ( isdefined( _k245 ) )
			{
				player = _a245[ _k245 ];
				if ( isdefined( player ) && isdefined( player.character_name ) && IsInArray( level.characters_in_nml, player.character_name ) )
				{
					player PlayerLinkToDelta( m_plane_about_to_crash, "tag_player_crouched_" + ( player.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
				}
				_k245 = GetNextArrayKey( _a245, _k245 );
			}
		}
		setup_puzzle_piece_glint();
		//clientfield::set( "fake_master_key", level.is_master_key_west + 1 );
		if ( !level flag::get( "key_found" ) )
		{
			if ( level.is_master_key_west )
			{
				exploder::exploder( 101 );
				break;
			}
			else
			{
				exploder::exploder( 100 );
			}
		}
	}
}

function prevent_theater_mode_spoilers()
{
	level flag::wait_till( "initial_blackscreen_passed" );
	//triggers = GetEntArray( "plane_fly_afterlife_trigger", "targetname" );
	//IPrintLnBold("triggers : " + triggers.size);
	m_plane_flyable = GetEnt( "plane_flyable", "targetname" );
	m_plane_flyable SetInvisibleToAll();
	m_plane_hideable_engine = GetEnt( "plane_hideable_engine", "targetname" );
	m_plane_hideable_engine Ghost();
	m_plane_hideable_clothes_pile = GetEnt( "plane_hideable_clothes_pile", "targetname" );
	m_plane_hideable_clothes_pile Ghost();
	a_str_partnames = [];
	a_str_partnames[ 0 ] = "cloth";
	a_str_partnames[ 1 ] = "steering";
	i = 0;
	while ( i < a_str_partnames.size )
	{
		m_plane_piece = zm_craftables::get_craftable_piece_model( "plane", a_str_partnames[ i ] );
		if ( isdefined( m_plane_piece ) )
		{
			m_plane_piece SetInvisibleToAll();
		}
		i++;
	}
	m_master_key = zm_craftables::get_craftable_piece_model( "quest_key1", "key" );
	if ( isdefined( m_master_key ) )
	{
		m_master_key SetInvisibleToAll();
	}
}

function setup_puzzle_piece_glint()
{
	wait 1;
	a_str_partnames = [];
	a_str_partnames[ 0 ] = "cloth";
	a_str_partnames[ 1 ] = "fueltanks";
	a_str_partnames[ 2 ] = "engine";
	a_str_partnames[ 3 ] = "steering";
	a_str_partnames[ 4 ] = "rigging";
	i = 0;
	while ( i < a_str_partnames.size )
	{
		m_plane_piece = zm_craftables::get_craftable_piece_model( "plane", a_str_partnames[ i ] );
		if ( isdefined( m_plane_piece ) )
		{
			PlayFXOnTag( level._effect[ "quest_item_glow" ], m_plane_piece, "tag_origin" );
		}
		m_fuel_can = zm_craftables::get_craftable_piece_model( "refuelable_plane", "fuel" + ( i + 1 ) );
		if ( isdefined( m_fuel_can ) )
		{
			PlayFXOnTag( level._effect[ "quest_item_glow" ], m_fuel_can, "tag_origin" );
		}
		i++;
	}
	m_master_key = zm_craftables::get_craftable_piece_model( "quest_key1", "key" );
	if ( isdefined( m_master_key ) )
	{
		PlayFXOnTag( level._effect[ "key_glint" ], m_master_key, "tag_origin" );
	}
	m_fake_plane_steering = GetEnt( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
	if ( isdefined( m_fake_plane_steering ) )
	{
		PlayFXOnTag( level._effect[ "quest_item_glow" ], m_fake_plane_steering, "tag_origin" );
	}
}

function setup_key_doors()
{
	width = 0;
	height = 0;
	length = 0;
	piece_number = 1;
	while ( piece_number < 6 )
	{
		switch( piece_number )
		{
			case 1:
				width = 120;
				height = 112;
				length = 120;
				break;
			case 2:
				width = 120;
				height = 112;
				length = 124;
				break;
			case 3:
				width = 108;
				height = 112;
				length = 90;
				break;
			case 4:
				width = 98;
				height = 112;
				length = 108;
				break;
			case 5:
				width = 60;
				height = 112;
				length = 90;
				break;
		}
		create_key_door_unitrigger( piece_number, width, height, length );
		piece_number++;
	}
}

function create_key_door_unitrigger( piece_num, width, height, length )
{
	t_key_door = struct::get( "key_door_" + piece_num + "_trigger", "targetname" );
	t_key_door.unitrigger_stub = SpawnStruct();
	t_key_door.unitrigger_stub.origin = t_key_door.origin;
	t_key_door.unitrigger_stub.angles = t_key_door.angles;
	t_key_door.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	t_key_door.unitrigger_stub.hint_string = "Need Warden's Key";
	t_key_door.unitrigger_stub.cursor_hint = "HINT_NOICON";
	t_key_door.unitrigger_stub.script_width = width;
	t_key_door.unitrigger_stub.script_height = height;
	t_key_door.unitrigger_stub.script_length = length;
	t_key_door.unitrigger_stub.n_door_index = piece_num;
	t_key_door.unitrigger_stub.require_look_at = 0;
	t_key_door.unitrigger_stub.prompt_and_visibility_func = &key_door_trigger_visibility;
	zm_unitrigger::register_static_unitrigger( t_key_door.unitrigger_stub, &master_key_door_trigger_thread );
}

function key_door_trigger_visibility( player )
{
	/*if ( !player.afterlife && isdefined( self.stub.master_key_door_opened ) && !self.stub.master_key_door_opened )
	{
		
	}*/
	if ( self.stub.n_door_index == 2 )
	{
		b_is_invis = !level flag::get( "generator_challenge_completed" );
	}
	self SetInvisibleToPlayer( player, b_is_invis );
	if( level.key_found )
	{
		self SetHintString( "Hold ^3&&1^7 to open" );
	}
	else
	{
		self SetHintString( self.stub.hint_string );
	}
	return !b_is_invis;
}

function master_key_door_trigger_thread()
{
	self endon( "death" );
	self endon( "kill_trigger" );
	n_door_index = self.stub.n_door_index;
	b_door_open = 0;
	while ( !b_door_open )
	{
		self waittill( "trigger", e_triggerer );
		if ( e_triggerer zm_craftables::is_holding_part("quest_key1","key") )
		{
			self.stub.master_key_door_opened = 1;
			self.stub zm_unitrigger::run_visibility_function_for_all_triggers();
			level thread open_custom_door_master_key( n_door_index, e_triggerer );
			self PlaySound( "evt_quest_door_open" );
			b_door_open = 1;
			continue;
		}
		else
		{
			e_triggerer thread zm_utility::do_player_general_vox( "quest", "sidequest_key", undefined, 100 );

			//IPrintLnBold( "missing key!" );

		}
	}
	level thread zm_unitrigger::unregister_unitrigger( self.stub );
}

function open_custom_door_master_key( n_door_index, e_triggerer )
{
	m_lock = GetEnt( "masterkey_lock_" + n_door_index, "targetname" );
	m_lock PlaySound( "zmb_quest_key_unlock" );
	PlayFXOnTag( level._effect[ "fx_alcatraz_unlock_door" ], m_lock, "tag_origin" );
	wait 0.5;
	m_lock Delete();
	switch( n_door_index )
	{
		case 1:
			shower_key_door = GetEnt( "shower_key_door", "targetname" );
			//shower_key_door MoveTo( shower_key_door.origin + VectorScale( ( 0, 1, 0 ), 80 ), 0.25 );
			shower_key_door RotateTo((0, 160, 0), 1);
			gate_1_monsterclip = GetEnt( "shower_key_door_monsterclip", "targetname" );
			gate_1_monsterclip SetInvisibleToAll();
			gate_1_monsterclip ConnectPaths();
			gate_1_monsterclip Delete();
			shower_key_door ConnectPaths();
			if ( isdefined( e_triggerer ) )
			{
				e_triggerer door_rumble_on_open();
			}
			shower_key_door PlaySound( "zmb_chainlink_open" );
			break;
		case 2:
			admin_powerhouse_puzzle_door_clip = GetEnt( "admin_powerhouse_puzzle_door_clip", "targetname" );
			admin_powerhouse_puzzle_door_clip Delete();
			admin_powerhouse_puzzle_door = GetEnt( "admin_powerhouse_puzzle_door", "targetname" );
			admin_powerhouse_puzzle_door RotateYaw( 90, 0.5 );
			admin_powerhouse_puzzle_door PlaySound( "zmb_chainlink_open" );
			break;
		case 3:
			m_nixie_door_left = GetEnt( "nixie_door_left", "targetname" );
			m_nixie_door_right = GetEnt( "nixie_door_right", "targetname" );
			m_nixie_weaponclip = GetEnt( "nixie_weaponclip", "targetname" );
			m_nixie_door_left RotateYaw( -165, 0.5 );
			m_nixie_door_right RotateYaw( 165, 0.5 );
			m_nixie_weaponclip Delete();
			if ( isdefined( e_triggerer ) )
			{
				e_triggerer door_rumble_on_open();
			}
			break;
		case 4:
			m_gate_01 = GetEnt( "cable_puzzle_gate_01", "targetname" );
			m_gate_01 MoveTo( m_gate_01.origin + ( -16, 80, 0 ), 0.5 );
			//m_gate_01 RotatePitch((0, 430, 0), 1);
			m_gate_01 ConnectPaths();
			gate_1_monsterclip = GetEnt( "docks_gate_1_monsterclip", "targetname" );
			gate_1_monsterclip.origin += VectorScale( ( 0, 0, 1 ), 256 );
			gate_1_monsterclip DisconnectPaths();
			//gate_1_monsterclip.origin -= VectorScale( ( 0, 0, 0 ), 256 );
			if ( isdefined( e_triggerer ) )
			{
				e_triggerer door_rumble_on_open();
			}
			m_gate_01 PlaySound( "zmb_chainlink_open" );
			level flag::set( "docks_inner_gate_unlocked" );
			level flag::set( "docks_inner_gate_open" );
			break;
		case 5:
			m_infirmary_case_door_left = GetEnt( "infirmary_case_door_left", "targetname" );
			m_infirmary_case_door_right = GetEnt( "infirmary_case_door_right", "targetname" );
			m_infirmary_case_door_left RotateYaw( -165, 0.5 );
			m_infirmary_case_door_right RotateYaw( 165, 0.5 );
			m_fake_plane_steering = GetEnt( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
			m_plane_steering = zm_craftables::get_craftable_piece_model( "plane", "steering" );
			m_plane_steering MoveTo( m_fake_plane_steering.origin, 0.05 );
			m_plane_steering.angles = m_fake_plane_steering.angles;
			m_plane_steering SetVisibleToAll();
			m_fake_plane_steering Hide();
			if ( isdefined( e_triggerer ) )
			{
				e_triggerer door_rumble_on_open();
			}
			m_infirmary_case_door_right PlaySound( "zmb_cabinet_door" );
			break;
	}
}

function door_rumble_on_open()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	//self clientfield::set_to_player( "rumble_door_open", 1 );
	//util::wait_network_frame();
	//self clientfield::set_to_player( "rumble_door_open", 0 );
}

function setup_puzzles()
{
	level thread setup_master_key();
	level thread setup_dryer_challenge();
	level thread setup_generator_challenge();
	level thread zm_alcatraz_sq_nixie::setup_nixie_tubes_puzzle();
	level thread setup_gate_puzzle();
}

function setup_quest_triggers()
{
	t_plane_fuelable = GetEnt( "plane_fuelable_trigger", "targetname" );
	t_plane_fuelable TriggerEnable(false);
	t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
	t_plane_fly SetCursorHint( "HINT_NOICON" );
	t_plane_fly SetHintString( "Hold ^3&&1^7 to Board Plane" );
	t_plane_fly.require_look_at = 0;
	t_plane_fly thread plane_fly_trigger_thread();
}

function setup_master_key()
{
	level.is_master_key_west = RandomIntRange( 0, 2 );
	//clientfield::set( "fake_master_key", level.is_master_key_west + 1 );
	if ( level.is_master_key_west )
	{
		level thread key_pulley( "west" );
		exploder::exploder( 101 );
		array::delete_all( GetEntArray( "wires_pulley_east", "script_noteworthy" ) );
	}
	else
	{
		level thread key_pulley( "east" );
		exploder::exploder( 100 );
		array::delete_all( GetEntArray( "wires_pulley_west", "script_noteworthy" ) );
	}
}

function key_pulley( str_master_key_location )
{
	if ( level.is_master_key_west )
	{
		t_other_hurt_trigger = GetEnt( "pulley_hurt_trigger_east", "targetname" );
		t_other_panel = GetEnt( "master_key_pulley_east", "targetname" );
	}
	else
	{
		t_other_hurt_trigger = GetEnt( "pulley_hurt_trigger_west", "targetname" );
		t_other_panel = GetEnt( "master_key_pulley_west", "targetname" );
	}
	t_other_hurt_trigger Delete();
	t_other_panel SetModel( "p6_zm_al_power_station_panels_03" );
	t_pulley_hurt_trigger = GetEnt( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
	t_pulley_hurt_trigger thread zm_alcatraz_sq_vo::sndhitelectrifiedpulley( str_master_key_location );
	m_master_key_pulley = GetEnt( "master_key_pulley_" + str_master_key_location, "targetname" );
	m_master_key_pulley play_fx( "fx_alcatraz_panel_on_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );
	m_master_key_pulley_animthing = GetEnt(m_master_key_pulley.target, "targetname");
	key_origin = m_master_key_pulley_animthing GetTagOrigin("tag_key");
	m_master_key_fake = Spawn("script_model", key_origin);
	m_master_key_fake SetModel("p6_zm_al_key");
	m_master_key_fake LinkTo(m_master_key_pulley_animthing, "tag_key");
	buildfx = Spawn("script_model", m_master_key_fake.origin); 
	buildfx SetModel("tag_origin"); 
	PlayFXOnTag( level._effect[ "key_elec_fx" ], buildfx, "tag_origin" );
	m_master_key_pulley thread _zm_afterlife::afterlife_interact_object_think();
	level waittill( "master_key_pulley_" + str_master_key_location );
	m_master_key_pulley PlaySound( "zmb_quest_generator_panel_spark" );
	m_master_key_pulley notify( "power_down" );
	m_master_key_pulley SetModel( "p6_zm_al_power_station_panels_03" );
	PlayFXOnTag( level._effect[ "fx_alcatraz_panel_ol" ], m_master_key_pulley, "tag_origin" );
	m_master_key_pulley play_fx( "fx_alcatraz_panel_off_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );
	if ( level.is_master_key_west )
	{
		exploder::stop_exploder( 101 );
		array::delete_all( GetEntArray( "wires_pulley_west", "script_noteworthy" ) );
	}
	else
	{
		exploder::stop_exploder( 100 );
		array::delete_all( GetEntArray( "wires_pulley_east", "script_noteworthy" ) );
	}
	t_hurt_trigger = GetEnt( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
	t_hurt_trigger Delete();
	m_master_key_pulley_animthing UseAnimTree(#animtree);
	m_master_key_pulley_animthing AnimScripted( "test", m_master_key_pulley_animthing.origin, m_master_key_pulley_animthing.angles, %fxanim_zom_al_key_pulley_down_anim ); 
	buildfx Delete();
	wait 3;
	m_master_key_fake Delete();
	m_master_key = zm_craftables::get_craftable_piece_model( "quest_key1", "key" );
	if ( isdefined( m_master_key ) )
	{
		m_master_key.origin = m_master_key_pulley_animthing GetTagOrigin("tag_key");
		m_master_key SetVisibleToAll();
	}
}

function setup_dryer_challenge()
{
	t_dryer = GetEnt( "dryer_trigger", "targetname" );
	t_dryer SetCursorHint( "HINT_NOICON" );
	t_dryer SetHintString( "Hold ^3&&1^7 to activate Laundry Machine" );
	t_dryer thread dryer_trigger_thread();
	t_dryer thread dryer_zombies_thread();
	t_dryer TriggerEnable(false);
	level waittill( "laundry_power_switch_afterlife" );
/#
	IPrintLnBold( "dryer can now be activated" );
#/
	t_dryer TriggerEnable(true);
	PlaySoundAtPosition("evt_dryer_rdy_bell", t_dryer.origin);
	//t_dryer PlaySound( "evt_dryer_rdy_bell" );
	wait 1;
	players = GetPlayers();
	_a900 = players;
	_k900 = GetFirstArrayKey( _a900 );
	while ( isdefined( _k900 ) )
	{
		player = _a900[ _k900 ];
		if ( !player.afterlife && Distance( player.origin, t_dryer.origin ) < 1500 )
		{
			player thread zm_utility::do_player_general_vox( "general", "power_on", undefined, 100 );
			return;
		}
		_k900 = GetNextArrayKey( _a900, _k900 );
	}
}

function dryer_trigger_thread()
{
	self endon( "death" );
	shower_clips = GetEntArray("shower_lockdown_clip","targetname");
	foreach(clip in shower_clips)
	{
		clip MoveTo(clip.origin - 500, 1);
	}
	m_dryer_model = GetEnt("ind_dryer_model","targetname");
	m_dryer_model UseAnimTree(#animtree); 
	n_dryer_cycle_duration = 30;
	a_dryer_spawns = [];
	sndent = Spawn( "script_origin", ( 1613, 10599, 1203 ) );

	can_activate = 0;

	while(can_activate == 0)
	{
		self waittill( "trigger", player );

		if ( isdefined( player.afterlife ) && player.afterlife )
		{
			can_activate = 0;
		}
		else
		{
			can_activate = 1;
		}
	}

	self TriggerEnable(false);
	level.fog_fx_laundry = [];
	level thread spawn_laundry_fog();
	//level clientfield::set( "dryer_stage", 2 );
	m_dryer_model AnimScripted( "optionalNotify", m_dryer_model.origin , m_dryer_model.angles, %fxanim_zom_al_industrial_dryer_start_anim);
	dryer_playerclip = GetEnt( "dryer_playerclip", "targetname" );
	dryer_playerclip MoveTo( dryer_playerclip.origin + vectorScale( ( 0, 0, 0 ), 104 ), 0.05 );

	// laugh and al death (notifier)
	//level.zmb_laugh_alias
	player PlaySoundToPlayer( "zmb_spooky_laugh", player );
	player PlaySoundToPlayer( "zmb_afterlife_end", player );

	collision1 = Spawn("script_model", (2079, -1370, 5607), 1);
	collision1 SetModel("zm_collision_perks1");
	collision1.script_noteworthy = "clip";
	collision1 DisconnectPaths();

	collision2 = Spawn("script_model", (1019, -502, 5388), 1);
	collision2 SetModel("zm_collision_perks1");
	collision2.script_noteworthy = "clip";
	collision2 DisconnectPaths();

	spot1 = Spawn("script_model", (2079, -1370, 5607));
	spot1.angles = (0,-90,0);
	spot1 SetModel("tag_origin");
	PlayFXOnTag(level._effect["lockdown_fx"], spot1, "tag_origin");
	spot2 = Spawn("script_model", (1019, -502, 5388));
	spot2.angles = (0,0,0);
	spot2 SetModel("tag_origin");
	PlayFXOnTag(level._effect["lockdown_fx"], spot2, "tag_origin");

	level util::clientnotify( "sndFF" );
	//if ( isdefined( level.music_override ) && !level.music_override )
	//{
		level notify( "sndStopBrutusLoop" );
		level thread zm_alcatraz_amb::sndplaystinger( "laundry_defend" );
	//}
	exploder::exploder( 1000 );
	self thread snddryercountdown( n_dryer_cycle_duration );
	PlaySoundAtPosition("evt_dryer_start", self.origin);
	//sndent PlaySound( "evt_dryer_start" );
	self PlayLoopSound( "evt_dryer_lp" );
	level util::clientnotify( "fxanim_dryer_start" );
	level flag::set( "dryer_cycle_active" );
	wait (GetAnimLength( %fxanim_zom_al_industrial_dryer_start_anim ));
	m_dryer_model AnimScripted( "optionalNotify", m_dryer_model.origin , m_dryer_model.angles, %fxanim_zom_al_industrial_dryer_idle_anim);
	sndset = sndmusicvariable();
	level util::clientnotify( "fxanim_dryer_idle_start" );
	i = 3;
	while ( i > 0 )
	{
/#
		IPrintLnBold( ( ( i / 3 ) * n_dryer_cycle_duration ) + " seconds left!" );
#/
		wait ( n_dryer_cycle_duration / 3 );
		i--;

	}
	m_dryer_model AnimScripted( "optionalNotify", m_dryer_model.origin , m_dryer_model.angles, %fxanim_zom_al_industrial_dryer_end_anim);
	level util::clientnotify( "fxanim_dryer_end_start" );
	wait (GetAnimLength( %fxanim_zom_al_industrial_dryer_end_anim ));
	level flag::clear( "dryer_cycle_active" );
	dryer_playerclip = GetEnt( "dryer_playerclip", "targetname" );
	dryer_playerclip Delete();
	level thread delete_laundry_fog();
	self StopLoopSound();
	PlaySoundAtPosition("evt_dryer_stop", self.origin);
	//sndent PlaySound( "evt_dryer_stop" );
	if ( isdefined( sndset ) && sndset )
	{
		level.music_override = 0;
	}
	shower_clips = GetEntArray("shower_lockdown_clip","targetname");
	foreach(clip in shower_clips)
	{
		clip MoveTo(clip.origin - 500, 1);
	}
	spot1 Delete();
	spot2 Delete();
	collision1.origin -= (0,0,500);
	collision1 ConnectPaths();
	collision2.origin -= (0,0,500);
	collision2 ConnectPaths();
	level util::clientnotify( "sndFF" );
	//level clientfield::set( "dryer_stage", 3 );
	exploder::stop_exploder( 900 );
	exploder::stop_exploder( 1000 );
	m_sheets = zm_craftables::get_craftable_piece_model( "plane", "cloth" );
	pickupthing = struct::get("sheets_pickup_point","targetname");
	m_sheets.origin = pickupthing.origin;
	m_sheets SetVisibleToAll();
	//m_sheets Ghost();
	self Delete();
	sndent thread delaysndenddelete();
}

function spawn_laundry_fog()
{
	spot = Spawn("script_model",(1965,-278,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
	spot = Spawn("script_model",(1563,-399,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
	spot = Spawn("script_model",(2000,-967,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
	spot = Spawn("script_model",(1553,-979,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
	spot = Spawn("script_model",(1734,-1419,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
	spot = Spawn("script_model",(1753,-34,5482));
	spot SetModel("tag_origin");
	PlayFXOnTag(level._effect["fog_rolling_in"], spot, "tag_origin");
	level.fog_fx_laundry[level.fog_fx_laundry.size] = spot;
}

function delete_laundry_fog()
{
	foreach(spot in level.fog_fx_laundry)
	{
		spot Delete();
	}
}

function sndmusicvariable()
{
	if ( isdefined( level.music_override ) && !level.music_override )
	{
		level.music_override = 1;
		return 1;
	}
	return 0;
}

function dryer_zombies_thread()
{
	n_zombie_count_min = 20;
	level thread shower_zomb_spawns();
	e_shower_zone = GetEnt( "shower_zone", "targetname" );
	level flag::wait_till( "dryer_cycle_active" );
	players = GetPlayers();
	if ( level.round_number > 4 || players.size == 1 )
	{
		if ( level.zombie_total < n_zombie_count_min )
		{
			level.zombie_total = n_zombie_count_min;
		}
		while ( level flag::get( "dryer_cycle_active" ) )
		{
			a_zombies_in_shower = [];
			a_zombies_in_shower = get_zombies_touching_volume( "axis", "shower_zone", undefined );
			if ( a_zombies_in_shower.size < n_zombie_count_min )
			{
				e_zombie = get_farthest_available_zombie( e_shower_zone );
				if ( isdefined( e_zombie ) && !IsInArray( a_zombies_in_shower, e_zombie ) )
				{
					e_zombie notify( "zapped" );
					e_zombie thread dryer_teleports_zombie();
				}
			}
			wait 1;
		}
	}
	else 
		level thread zm_ai_brutus::brutusSpawnInZone( "shower_zone" );
}

function shower_zomb_spawns()
{
	level.shower_zomb_spawns = [];
	spot = Spawn("script_model", (1882,-1425,5400));
	spot SetModel("tag_origin");
	level.shower_zomb_spawns[level.shower_zomb_spawns.size] = spot;
	spot = Spawn("script_model", (1532,-1187,5400));
	spot SetModel("tag_origin");
	level.shower_zomb_spawns[level.shower_zomb_spawns.size] = spot;
	spot = Spawn("script_model", (1415,-400,5400));
	spot SetModel("tag_origin");
	level.shower_zomb_spawns[level.shower_zomb_spawns.size] = spot;
	spot = Spawn("script_model", (1861,-12,5400));
	spot SetModel("tag_origin");
	level.shower_zomb_spawns[level.shower_zomb_spawns.size] = spot;
	spot = Spawn("script_model", (2050,-661,5400));
	spot SetModel("tag_origin");
	level.shower_zomb_spawns[level.shower_zomb_spawns.size] = spot;
}

function get_farthest_available_zombie( e_landmark )
{
	if ( !isdefined( e_landmark ) )
	{
		return undefined;
	}
	while ( 1 )
	{
		a_zombies = GetAIArray( level.zombie_team );
		if ( isdefined( a_zombies ) )
		{
			zombies = util::get_array_of_closest( e_landmark.origin, a_zombies );
			x = 0;
			while ( x < zombies.size )
			{
				zombie = zombies[ x ];
				if ( isdefined( zombie ) && IsAlive( zombie ) && isDefined( zombie.in_the_ground ) && !zombie.in_the_ground && isdefined( zombie.gibbed ) && !zombie.gibbed && isdefined( zombie.head_gibbed ) && !zombie.head_gibbed && isdefined( zombie.is_being_used_as_spawnpoint ) && !zombie.is_being_used_as_spawnpoint && zombie zm_utility::in_playable_area() )
				{
					zombie.is_being_used_as_spawnpoint = 1;
					return zombie;
				}
				x++;
			}
		}
		else return undefined;
		wait 0.05;
	}
}

function get_zombies_touching_volume( team, volume_name, volume )
{
	if ( !isdefined( volume ) )
	{
		volume = GetEnt( volume_name, "targetname" );
/#
		assert( isdefined( volume ), volume_name + " does not exist" );
#/
	}
	guys = GetAIArray( team );
	guys_touching_volume = [];
	i = 0;
	while ( i < guys.size )
	{
		if ( guys[ i ] IsTouching( volume ) )
		{
			guys_touching_volume[ guys_touching_volume.size ] = guys[ i ];
		}
		i++;
	}
	return guys_touching_volume;
}

function dryer_teleports_zombie()
{
	self endon( "death" );
	self endon( "zapped" );
	if ( self.ai_state == "find_flesh" )
	{
		self.zapped = 1;
		//a_nodes = struct::get_array( "dryer_zombie_teleports", "targetname" );
		nd_target = array::random( level.shower_zomb_spawns );
		PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
		self hide();
		linker = Spawn( "script_origin", ( 0, 0, 0 ) );
		//linker thread linker_delete_watch( self );
		linker.origin = self.origin;
		linker.angles = self.angles;
		self LinkTo( linker );
		linker MoveTo( nd_target.origin, 0.05 );
		linker waittill( "movedone" );
		PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
		linker Delete();
		self Show();
		self.zapped = undefined;
		//self.ignoreall = 1;
		//self notify( "stop_find_flesh" );
		//self thread afterlife_zapped_fx();
		//self AnimScripted( self.origin, self.angles, "zm_afterlife_stun" );
		//self maps/mp/animscripts/shared::donotetracks( "stunned" );
		//self.ignoreall = 0;
		//self thread zm_ai_basic::find_flesh();
	}
}

function delaysndenddelete()
{
	wait 5;
	self Delete();
}

function snddryercountdown( num )
{
	ent = Spawn( "script_origin", self.origin );
	i = num;
	while ( i > 0 )
	{
		if ( i <= 10 )
		{
			PlaySoundAtPosition( "zmb_quest_nixie_count_final", ent.origin );
			//ent PlaySound( "zmb_quest_nixie_count_final" );
		}
		else
		{
			PlaySoundAtPosition( "dryer_click", ent.origin );
			//ent PlaySound( "zmb_quest_nixie_count" );
		}
		wait 1;
		i--;

	}
	ent Delete();
}

function setup_generator_challenge()
{
	level.n_generator_panels_active = 0;
	generator_soundent = Spawn( "script_origin", ( -467, 6388, 132 ) );
	i = 1;
	while ( i < 4 )
	{
		level thread generator_panel_trigger_thread( i, generator_soundent );
		i++;
	}
	level thread generator_challenge_main_thread();
}

function generator_challenge_main_thread()
{
	exploder::exploder( 2000 );
	door = GetEnt("admin_powerhouse_puzzle_door","targetname");
	fx_thing = Spawn("script_model", door.origin);
	fx_thing SetModel("tag_origin");
	fx_thing.angles = door.angles;
	PlayFXOnTag(level._effect["fx_wardens_office_door"] ,fx_thing, "tag_origin" );
	while ( !level flag::get( "generator_challenge_completed" ) )
	{
		if ( level.n_generator_panels_active == 3 )
		{
/#
			IPrintLnBold( "generator overloaded!" );
#/
			level flag::set( "generator_challenge_completed" );
		}
		wait 0.1;
	}
	fx_thing Delete();
	level util::clientnotify( "sndWard" );
	level thread zm_alcatraz_amb::sndplaystinger( "piece_mid" );
	t_warden_fence_damage = GetEnt( "warden_fence_damage", "targetname" );
	t_warden_fence_damage Delete();
	//level clientfield::set( "warden_fence_down", 1 );
	array::delete_all( GetEntArray( "generator_wires", "script_noteworthy" ) );
	wait 3;
	exploder::stop_exploder( 2000 );
	wait 1;
	players = GetPlayers();
	player = players[ RandomIntRange( 0, players.size ) ];
	player zm_utility::do_player_general_vox( "general", "power_off", undefined, 100 );
}

function generator_panel_trigger_thread( n_panel_index, generator_soundent )
{
	self endon( "death" );
	m_generator_panel = GetEnt( "generator_panel_" + n_panel_index, "targetname" );
	m_generator_panel thread _zm_afterlife::afterlife_interact_object_think();
	m_generator_panel play_fx( "fx_alcatraz_panel_on_2", m_generator_panel.origin, m_generator_panel.angles, "generator_panel_" + n_panel_index + "_afterlife", 1, undefined, undefined );
	level waittill( "generator_panel_" + n_panel_index + "_afterlife" );
	m_generator_panel notify( "generator_panel_" + n_panel_index + "_afterlife" );
/#
	IPrintLnBold( "generator panel " + n_panel_index + " overloaded!" );
#/
	level.n_generator_panels_active += 1;
	m_generator_panel SetModel( "p6_zm_al_power_station_panels_03" );
	PlayFXOnTag( level._effect[ "fx_alcatraz_panel_ol" ], m_generator_panel, "tag_origin" );
	m_generator_panel play_fx( "fx_alcatraz_panel_off_2", m_generator_panel.origin, m_generator_panel.angles, undefined, 1, undefined, undefined );
	set_generator_vfx_amount( level.n_generator_panels_active, generator_soundent );
	PlaySoundAtPosition( "zmb_quest_generator_panel_spark", m_generator_panel.origin );
}

function set_generator_vfx_amount( n_vfx_amount, generator_soundent )
{
	if ( n_vfx_amount == 1 )
	{
		generator_soundent PlayLoopSound( "zmb_quest_generator_loop1" );
	}
	if ( n_vfx_amount == 2 )
	{
		generator_soundent StopLoopSound();
		wait 0.05;
		generator_soundent PlayLoopSound( "zmb_quest_generator_loop2" );
	}
	if ( n_vfx_amount == 3 )
	{
		exploder::exploder( 3100 );
		exploder::exploder( 3200 );
		exploder::exploder( 3300 );
		generator_soundent StopLoopSound();
		wait 0.05;
		generator_soundent PlayLoopSound( "zmb_quest_generator_loop3" );
	}
}

function setup_gate_puzzle()
{
	self endon( "death" );
	is_gate_toggled = 0;
	is_inner_gate_toggleable = 0;
	m_gate_02 = GetEnt( "cable_puzzle_gate_02", "targetname" );
	n_gate_move_duration = 0.5;
	m_docks_shockbox = GetEnt( "docks_panel", "targetname" );
	array_set_visible_to_all( GetEntArray( "wires_docks_gate_toggle", "script_noteworthy" ), 0 );
	a_players = [];
	a_players = GetPlayers();
	if ( a_players.size > 1 )
	{
		is_inner_gate_toggleable = 1;
	}
	m_docks_shockbox thread _zm_afterlife::afterlife_interact_object_think();
	while ( 1 )
	{
		level waittill( "cable_puzzle_gate_afterlife" );
		array_set_visible_to_all( GetEntArray( "wires_docks_gate_toggle", "script_noteworthy" ), 1 );
		if ( is_inner_gate_toggleable && level flag::get( "docks_inner_gate_unlocked" ) )
		{
			level thread toggle_inner_gate( n_gate_move_duration );
		}
		if ( !level flag::get( "docks_outer_gate_open" ) && !level flag::get( "docks_gates_remain_open" ))
		{
			m_gate_02 MoveTo( m_gate_02.origin + ( -16, 80, 0 ), n_gate_move_duration );
			wait ( n_gate_move_duration + 0.25 );
			m_gate_02 ConnectPaths();
			gate_2_monsterclip = GetEnt( "docks_gate_2_monsterclip", "targetname" );
			gate_2_monsterclip.origin += VectorScale( ( 0, 0, 1 ), 256 );
			gate_2_monsterclip DisconnectPaths();
			
			m_gate_02 PlaySound( "zmb_chainlink_close" );
		}
		else
		{
			if ( !level flag::get( "docks_gates_remain_open" ) )
			{
				m_gate_02 MoveTo( m_gate_02.origin - ( -16, 80, 0 ), n_gate_move_duration );
				wait ( n_gate_move_duration + 0.25 );
				m_gate_02 DisconnectPaths();
				gate_2_monsterclip = GetEnt( "docks_gate_2_monsterclip", "targetname" );
				gate_2_monsterclip.origin -= VectorScale( ( 0, 0, 1 ), 256 );
				gate_2_monsterclip ConnectPaths();
				m_gate_02 PlaySound( "zmb_chainlink_open" );
			}
		}
		level flag::toggle( "docks_outer_gate_open" );

		//IPrintLnBold( "gate toggled!" );

		wait n_gate_move_duration;

		//IPrintLnBold( "gate ready to be re-toggled" );

		m_docks_shockbox notify( "afterlife_interact_reset" );
		array_set_visible_to_all( GetEntArray( "wires_docks_gate_toggle", "script_noteworthy" ), 0 );
	}
}

function toggle_inner_gate( n_gate_move_duration )
{
	a_m_gate_01 = GetEntArray( "cable_puzzle_gate_01", "targetname" );
	if ( level flag::get( "docks_inner_gate_open" ) && !level flag::get( "docks_gates_remain_open" ) )
	{
		i = 0;
		while ( i < a_m_gate_01.size )
		{
			a_m_gate_01[ i ] MoveTo( a_m_gate_01[ i ].origin - ( -16, 80, 0 ), n_gate_move_duration );
			i++;
		}
		wait ( n_gate_move_duration + 0.25 );
		i = 0;
		while ( i < a_m_gate_01.size )
		{
			a_m_gate_01[ i ] DisconnectPaths();
			i++;
		}
		gate_1_monsterclip = GetEnt( "docks_gate_1_monsterclip", "targetname" );
		gate_1_monsterclip.origin -= vectorScale( ( 0, 0, 1 ), 256 );
		gate_1_monsterclip ConnectPaths();
		a_m_gate_01[ 0 ] PlaySound( "zmb_chainlink_close" );
	}
	else
	{
		i = 0;
		while ( i < a_m_gate_01.size )
		{
			a_m_gate_01[ i ] MoveTo( a_m_gate_01[ i ].origin + ( -16, 80, 0 ), n_gate_move_duration );
			i++;
		}
		wait ( n_gate_move_duration + 0.25 );
		i = 0;
		while ( i < a_m_gate_01.size )
		{
			a_m_gate_01[ i ] ConnectPaths();
			i++;
		}
		gate_1_monsterclip = GetEnt( "docks_gate_1_monsterclip", "targetname" );
		gate_1_monsterclip.origin += vectorScale( ( 0, 0, 1 ), 256 );
		gate_1_monsterclip DisconnectPaths();
		
		a_m_gate_01[ 0 ] PlaySound( "zmb_chainlink_open" );
	}
	level flag::toggle( "docks_inner_gate_open" );
}

function plane_fly_trigger_thread()
{
	self SetCursorHint( "HINT_NOICON" );
	self SetHintString( "Hold ^3&&1^7 to Board Plane" );
	//level flag::wait_till( "initial_players_connected" );
	//flag::wait_till( "brutus_setup_complete" );
	self TriggerEnable(false);
	self.trigger_off = 1;
	wait 1;
	//IPrintLnBold("hide plane");
	m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
	m_plane_craftable Show();
	/*m_plane_craftable HidePart( "tag_support_upper" );
	m_plane_craftable HidePart( "tag_wing_skins_up" );
	m_plane_craftable HidePart( "tag_engines_up" );
	m_plane_craftable HidePart( "tag_feul_tanks" );
	m_plane_craftable HidePart( "tag_control_mechanism" );
	m_plane_craftable HidePart( "tag_engine_ground" );
	m_plane_craftable HidePart( "tag_clothes_ground" );
	m_plane_craftable HidePart( "tag_fuel_hose" );
	level waittill("plane_fully_build");*/
	//IPrintLnBold("plane crafted");
	zm_ai_brutus::transfer_plane_trigger( "build", "fly" );
	self TriggerEnable(true);
	self.trigger_off = 0;
	while ( isdefined( self ) )
	{
		self waittill( "trigger", e_triggerer );
		if ( IsPlayer( e_triggerer ) )
		{
			if ( level.n_plane_fuel_count == 5 )
			{
				if ( isdefined( level.custom_plane_validation ) )
				{
					valid = self [[ level.custom_plane_validation ]]( e_triggerer );
					if ( !valid )
					{
						continue;
					}
				}
				self SetInvisibleToPlayer( e_triggerer );
				if ( isdefined( level.plane_boarding_thread_custom_func ) )
				{
					e_triggerer thread [[ level.plane_boarding_thread_custom_func ]]();
					break;
				}
				else
				{
					e_triggerer thread plane_boarding_thread();
				}
			}
		}
	}
}

function plane_boarding_thread()
{
	self endon( "death_or_disconnect" );
	level flag::set( "plane_is_away" );
	self thread player_disconnect_watcher();
	self thread player_death_watcher();

	//IPrintLnBold( "plane boarding thread started" );

	level flag::set( "plane_boarded" );
	//self clientfield::set_to_player( "effects_escape_flight", 1 );
	level.brutus_respawn_after_despawn = 0;
	a_nml_teleport_targets = [];
	i = 1;
	while ( i < 6 )
	{
		a_nml_teleport_targets[ i - 1 ] = struct::get( "nml_telepoint_" + i, "targetname" );
		i++;
	}
	level.characters_in_nml[ level.characters_in_nml.size ] = self.character_name;
	self.on_a_plane = 1;
	level.someone_has_visited_nml = 1;
	self.n_passenger_index = level.characters_in_nml.size;
	m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
	m_plane_about_to_crash = GetEnt( "plane_about_to_crash", "targetname" );
	veh_plane_flyable = GetEnt( "plane_flyable", "targetname" );
	t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
	t_plane_fly SetHintString( "Hold ^3&&1^7 to Board Plane" );
	self AllowCrouch( 1 );
	self SetCharacterBodyStyle(1);
	self EnableInvulnerability();
	self PlayerLinkToDelta( m_plane_craftable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	self AllowStand( 0 );
	level flag::wait_till( "plane_departed" );
	level notify( "sndStopBrutusLoop" );
	self util::clientnotify( "sndPS" );
	self PlaySoundToPlayer( "zmb_plane_takeoff", self );
	level thread zm_alcatraz_amb::sndplaystinger( "plane_takeoff", self );
	self PlayerLinkToDelta( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	//self clientfield::set_to_player( "effects_escape_flight", 2 );
	level flag::wait_till( "plane_approach_bridge" );
	self thread snddelayedimp();
	//self clientfield::set_to_player( "effects_escape_flight", 3 );
	self Unlink();
	self PlayerLinkToAbsolute( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	level flag::wait_till( "plane_zapped" );
	level flag::set( "activate_player_zone_bridge" );
	self PlaySoundToPlayer( "zmb_plane_fall", self );
	//self clientfield::set_to_player( "effects_escape_flight", 4 );
	self.dontspeak = 1;
	//self clientfield::set_to_player( "isspeaking", 1 );
	self PlayerLinkToDelta( m_plane_about_to_crash, "tag_player_crouched_" + ( self.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
	self ForceGrenadeThrow();
	str_current_weapon = self GetCurrentWeapon();
	self GiveWeapon( GetWeapon("falling_hands") );
	self SwitchToWeaponImmediate( GetWeapon("falling_hands") );
	self SetCharacterBodyStyle(0);
	players = GetPlayers();
	_a1548 = players;
	_k1548 = GetFirstArrayKey( _a1548 );
	while ( isdefined( _k1548 ) )
	{
		player = _a1548[ _k1548 ];
		if ( player != self )
		{
			player SetInvisibleToPlayer( self );
		}
		_k1548 = GetNextArrayKey( _a1548, _k1548 );
	}
	level flag::wait_till( "plane_crashed" );
	//self clientfield::set_to_player( "effects_escape_flight", 5 );
	self TakeWeapon( GetWeapon("falling_hands") );
	if ( isdefined( str_current_weapon ) && str_current_weapon != "none" )
	{
		self SwitchToWeaponImmediate( str_current_weapon );
	}
	self thread lui::screen_flash( 0.5, 2, 0.5, 1, "black" );
	self thread snddelayedmusic();
	self Unlink();
	self AllowStand( 1 );
	self SetStance( "stand" );
	players = GetPlayers();
	_a1571 = players;
	_k1571 = GetFirstArrayKey( _a1571 );
	while ( isdefined( _k1571 ) )
	{
		player = _a1571[ _k1571 ];
		if ( player != self )
		{
			player SetVisibleToPlayer( self );
		}
		_k1571 = GetNextArrayKey( _a1571, _k1571 );
	}
	level flag::clear( "spawn_zombies" );
	self SetOrigin( a_nml_teleport_targets[ self.n_passenger_index ].origin );
	e_poi = struct::get( "plane_crash_poi", "targetname" );
	vec_to_target = e_poi.origin - self.origin;
	vec_to_target = VectortoAngles( vec_to_target );
	vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
	self SetPlayerAngles( vec_to_target );
	n_shellshock_duration = 5;
	self ShellShock( "explosion", n_shellshock_duration );
	self.dontspeak = 0;
	//self clientfield::set_to_player( "isspeaking", 0 );
	self notify( "player_at_bridge" );
	wait n_shellshock_duration;
	self DisableInvulnerability();
	self.on_a_plane = 0;
	if ( level.characters_in_nml.size == 1 )
	{
		self zm_alcatraz_sq_vo::vo_bridge_soliloquy();
	}
	else
	{
		if ( level.characters_in_nml.size == 4 )
		{
			zm_alcatraz_sq_vo::vo_bridge_four_part_convo();
		}
	}
	wait 10;
	self PlaySoundToPlayer( "zmb_ggb_swarm_start", self );
	level flag::set( "spawn_zombies" );
	level.brutus_respawn_after_despawn = 1;
	wait 5;
	character_name = level.characters_in_nml[ RandomIntRange( 0, level.characters_in_nml.size ) ];
	players = GetPlayers();
	_a1625 = players;
	_k1625 = GetFirstArrayKey( _a1625 );
	while ( isdefined( _k1625 ) )
	{
		player = _a1625[ _k1625 ];
		if ( isdefined( player ) && player.character_name == character_name )
		{
			player thread zm_utility::do_player_general_vox( "quest", "zombie_arrive_gg", undefined, 100 );
		}
		_k1625 = GetNextArrayKey( _a1625, _k1625 );
	}
}

function snddelayedimp()
{
	self endon( "disconnect" );
	wait 6;
	self PlaySoundToPlayer( "zmb_plane_explode", self );
}

function snddelayedmusic()
{
	self endon( "disconnect" );
	wait 1;
	level thread zm_alcatraz_amb::sndplaystinger( "at_golden_gate", self );
	self util::clientnotify( "sndPE" );
}

function track_quest_status_thread()
{
	while ( 1 )
	{
		while ( level.characters_in_nml.size == 0 )
		{
			wait 1;
		}
		while ( level.characters_in_nml.size > 0 )
		{
			wait 1;
		}
		if ( level flag::get( "plane_trip_to_nml_successful" ) )
		{
			bestow_quest_rewards();
			level flag::clear( "plane_trip_to_nml_successful" );
		}
		level notify( "bridge_empty" );
		level waittill( "start_of_round" );
		if ( level.n_quest_iteration_count == 2 )
		{
			zm_alcatraz_sq_vo::vo_play_four_part_conversation( level.four_part_convos[ "alcatraz_return_alt" + randomintrange( 0, 2 ) ] );
		}
		prep_for_new_quest();
		level waittill("plane_fully_fuelled");
		//zm_craftables::waittill_crafted( "refuelable_plane" );
		zm_ai_brutus::transfer_plane_trigger( "fuel", "fly" );
		t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
		t_plane_fly TriggerEnable(true);
		t_plane_fly.trigger_off = 0;
	}
}

function bestow_quest_rewards()
{
	level.n_quest_iteration_count += 1;
	if ( level.n_quest_iteration_count == 2 )
	{
		//IPrintLnBold("all perks unlocked + intro powerup restored");
		level notify( "unlock_all_perk_machines" );
		level notify( "intro_powerup_restored" );
	}
	else
	{
		if ( level.n_quest_iteration_count == 4 )
		{
			//IPrintLnBold("quest completed thrice");
			level flag::set( "quest_completed_thrice" );
		}
	}
}

function prep_for_new_quest()
{
	i = 1;
	while ( i < 4 )
	{
		str_trigger_targetname = "trigger_electric_chair_" + i;
		t_electric_chair = GetEnt( str_trigger_targetname, "targetname" );
		t_electric_chair SetHintString( "Hold ^3&&1^7 to Activate Chair" );
		t_electric_chair TriggerEnable(true);
		i++;
	}
	level flag::set( "spawn_fuel_tanks" );
	wait 0.05;
	level flag::clear( "spawn_fuel_tanks" );
	i = 0;
	while ( i < level.a_uts_craftables.size )
	{
		if ( level.a_uts_craftables[ i ].equipname == "refuelable_plane" )
		{
			t_plane_fuelable = level.a_uts_craftables[ i ];
			level.zones[ "roof_zone" ].plane_triggers[ level.zones[ "roof_zone" ].plane_triggers.size ] = t_plane_fuelable;
			break;
		}
		else
		{
			i++;
		}
	}
	t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
	t_plane_fly TriggerEnable(false);
	players = GetPlayers();
	t_plane_fly SetVisibleToAll();
	zm_ai_brutus::transfer_plane_trigger( "fly", "fuel" );
	i = 1;
	while ( i < 5 )
	{
		m_electric_chair = GetEnt( "electric_chair_" + i, "targetname" );
		m_electric_chair notify( "bridge_empty" );
		i++;
	}
	setup_puzzle_piece_glint();
/#
	IPrintLnBold( "plane location reset" );
#/
	m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
	m_plane_craftable Show();
	PlayFXOnTag( level._effect[ "fx_alcatraz_plane_apear" ], m_plane_craftable, "tag_origin" );
	veh_plane_flyable = GetEnt( "plane_flyable", "targetname" );
	veh_plane_flyable AttachPath( GetVehicleNode( "zombie_plane_underground", "targetname" ) );
	zm_alcatraz_sq_vo::vo_play_four_part_conversation( level.four_part_convos[ "alcatraz_return_quest_reset" ] );
	level flag::clear( "plane_is_away" );
}

function plane_flight_thread()
{
	while ( 1 )
	{
		m_plane_about_to_crash = GetEnt( "plane_about_to_crash", "targetname" );
		m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
		t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
		veh_plane_flyable = GetEnt( "plane_flyable", "targetname" );
		m_plane_about_to_crash Ghost();
		level flag::wait_till( "plane_boarded" );
		level util::clientnotify( "sndPB" );
		if ( isdefined( level.music_override ) && !level.music_override )
		{
			t_plane_fly PlayLoopSound( "mus_event_plane_countdown_loop", 0.25 );
		}
		i = 10;
		while ( i > 0 )
		{

			//IPrintLnBold( "TAKE-OFF IN " + i + "..." );

			veh_plane_flyable PlaySound( "zmb_plane_countdown_tick" );
			wait 1;
			i--;

		}
		t_plane_fly StopLoopSound( 2 );
		exploder::exploder( 10000 );
		veh_plane_flyable AttachPath( GetVehicleNode( "zombie_plane_flight_path", "targetname" ) );
		veh_plane_flyable StartPath();
		level flag::set( "plane_departed" );
		t_plane_fly TriggerEnable(false);
		t_plane_fly.trigger_off = 1;
		m_plane_craftable Ghost();
		veh_plane_flyable SetVisibleToAll();
		level clientfield::set( "fog_stage", 1 );
		PlayFXOnTag( level._effect[ "fx_alcatraz_plane_trail" ], veh_plane_flyable, "tag_origin" );
		wait 2;
		PlayFXOnTag( level._effect[ "fx_alcatraz_plane_trail" ], veh_plane_flyable, "tag_origin" );
		wait 3;
		exploder::exploder( 10001 );
		wait 4;
		//PlayFXOnTag( level._effect[ "fx_alcatraz_flight_lightning" ], veh_plane_flyable, "tag_origin" );
		PlayFX(level._effect[ "fx_alcatraz_flight_lightning_new" ],veh_plane_flyable.origin + (0,0,1500) );
		//level clientfield::set( "scripted_lightning_flash", 1 );
		wait 1;
		level flag::set( "plane_approach_bridge" );
		exploder::stop_exploder( 10001 );
		level clientfield::set( "fog_stage", 2 );
		veh_plane_flyable AttachPath( GetVehicleNode( "zombie_plane_bridge_approach", "targetname" ) );
		veh_plane_flyable StartPath();
		wait 6;
		//PlayFXOnTag( level._effect[ "fx_alcatraz_flight_lightning" ], veh_plane_flyable, "tag_origin" );
		PlayFX(level._effect[ "fx_alcatraz_flight_lightning_new" ],veh_plane_flyable.origin + (0,0,1500) );
		//level clientfield::set( "scripted_lightning_flash", 1 );
		veh_plane_flyable waittill( "reached_end_node" );
		level flag::set( "plane_zapped" );
		level clientfield::set( "fog_stage", 3 );
		veh_plane_flyable SetInvisibleToAll();
		n_crash_duration = 2.25;
		nd_plane_about_to_crash_1 = struct::get( "plane_about_to_crash_point_1", "targetname" );
		m_plane_about_to_crash.origin = nd_plane_about_to_crash_1.origin;
		nd_plane_about_to_crash_2 = struct::get( "plane_about_to_crash_point_2", "targetname" );
		m_plane_about_to_crash MoveTo( nd_plane_about_to_crash_2.origin, n_crash_duration );
		m_plane_about_to_crash thread spin_while_falling();
		exploder::stop_exploder( 10000 );
		m_plane_about_to_crash waittill( "movedone" );
		level flag::set( "plane_crashed" );
		wait 2;
		//level clientfield::set( "scripted_lightning_flash", 1 );
		m_plane_about_to_crash.origin += vectorScale( ( 0, 0, 1 ), 2048 );
		wait 4;
		veh_plane_flyable SetVisibleToAll();
		veh_plane_flyable play_fx( "fx_alcatraz_plane_fire_trail", veh_plane_flyable.origin, veh_plane_flyable.angles, "reached_end_node", 1, "tag_origin", undefined );
		veh_plane_flyable AttachPath( GetVehicleNode( "zombie_plane_bridge_flyby", "targetname" ) );
		veh_plane_flyable StartPath();
		veh_plane_flyable thread sndpc();
		veh_plane_flyable waittill( "reached_end_node" );
		veh_plane_flyable SetInvisibleToAll();
		wait 20;
		if ( !level.final_flight_activated )
		{
			if ( isdefined( level.brutus_on_the_bridge_custom_func ) )
			{
				level thread [[ level.brutus_on_the_bridge_custom_func ]]();
				break;
			}
			else
			{
				level thread brutus_on_the_bridge();
			}
		}
		level flag::clear( "plane_built" );
		level flag::clear( "plane_boarded" );
		level flag::clear( "plane_departed" );
		level flag::clear( "plane_approach_bridge" );
		level flag::clear( "plane_zapped" );
		level flag::clear( "plane_crashed" );
		level.n_plane_fuel_count = 0;
	}
}

function sndpc()
{
	self PlayLoopSound( "zmb_plane_fire", 4 );
	wait 6;
	self PlaySound( "zmb_plane_fire_whoosh" );
	wait 1;
	self StopLoopSound( 3 );
}

function brutus_on_the_bridge()
{
	level endon( "bridge_empty" );
	n_round_on_bridge = 1;
	n_desired_spawn_count = 0;
	n_spawn_cap = 4;
	level.n_bridge_brutuses_killed = 0;
	if ( isdefined( level.last_brutus_on_bridge_custom_func ) )
	{
		level thread [[ level.last_brutus_on_bridge_custom_func ]]();
	}
	else
	{
		level thread last_brutus_on_bridge();
	}
	if ( isdefined( level.brutus_despawn_manager_custom_func ) )
	{
		level thread [[ level.brutus_despawn_manager_custom_func ]]();
	}
	else
	{
		level thread brutus_despawn_manager();
	}
	while ( 1 )
	{
		level.brutus_last_spawn_round = 0;
		n_desired_spawn_count = Int( Min( n_round_on_bridge, n_spawn_cap ) );
		n_brutuses_on_bridge_count = get_bridge_brutus_count();
		n_spawns_needed = n_desired_spawn_count - n_brutuses_on_bridge_count;
		i = n_spawns_needed;
		while ( i > 0 )
		{
			//ai = undefined;
			//IPrintLnBold("Spawning bridge brutus");
			zm_ai_brutus::brutusSpawnInZone( "bridge_zone", 1 );
			/*if ( isdefined( ai ) )
			{
				ai.is_bridge_brutus = 1;
				if ( level.n_bridge_brutuses_killed == 0 )
				{
					ai thread suppress_brutus_bridge_powerups();
				}
			}*/
			wait RandomFloatRange( 15, 20 );
			i--;

		}
		level waittill( "start_of_round" );
		n_round_on_bridge++;
	}
}

function last_brutus_on_bridge()
{
	level endon( "bridge_empty" );
	e_gg_zone = GetEnt( "bridge_zone", "targetname" );
	a_bridge_brutuses = [];
	while ( 1 )
	{
		a_bridge_brutuses = get_bridge_brutuses();
		if ( a_bridge_brutuses.size > 1 )
		{
			_a2012 = a_bridge_brutuses;
			_k2012 = GetFirstArrayKey( _a2012 );
			while ( isdefined( _k2012 ) )
			{
				brutus = _a2012[ _k2012 ];
				if ( isdefined( brutus ) )
				{
					brutus.suppress_teargas_behavior = 1;
				}
				_k2012 = GetNextArrayKey( _a2012, _k2012 );
			}
		}
		else if ( a_bridge_brutuses.size == 1 )
		{
			a_bridge_brutuses[ 0 ].suppress_teargas_behavior = 0;
		}
		wait 0.05;
	}
}

function suppress_brutus_bridge_powerups()
{
	self endon( "brutus_teleporting" );
	level endon( "bridge_empty" );
	level endon( "first_bridge_brutus_killed" );
	self waittill( "death" );
	level.n_bridge_brutuses_killed++;
	if ( level.n_bridge_brutuses_killed >= 1 )
	{
		level.global_brutus_powerup_prevention = 1;
		level thread allow_brutus_powerup_spawning();
		level notify( "first_bridge_brutus_killed" );
	}
}

function allow_brutus_powerup_spawning()
{
	level notify( "only_one_powerup_thread" );
	level endon( "only_one_powerup_thread" );
	level waittill( "bridge_empty" );
	level.global_brutus_powerup_prevention = 0;
}

function get_bridge_brutuses()
{
	e_gg_zone = GetEnt( "bridge_zone", "targetname" );
	a_bridge_brutuses = [];
	zombies = GetAISpeciesArray( "axis", "all" );
	i = 0;
	while ( i < zombies.size )
	{
		if ( isdefined( zombies[ i ].is_brutus ) && zombies[ i ].is_brutus )
		{
			brutus = zombies[ i ];
			if ( brutus IsTouching( e_gg_zone ) )
			{
				brutus.is_bridge_brutus = 1;
				a_bridge_brutuses[ a_bridge_brutuses.size ] = brutus;
			}
		}
		i++;
	}
	return a_bridge_brutuses;
}

function brutus_despawn_manager()
{
	level notify( "brutus_despawn_manager" );
	level endon( "brutus_despawn_manager" );
	level endon( "bridge_empty" );
	e_gg_zone = GetEnt( "bridge_zone", "targetname" );
	while ( 1 )
	{
		b_is_time_to_despawn = 0;
		while ( !b_is_time_to_despawn )
		{
			b_is_time_to_despawn = 1;
			players = GetPlayers();
			_a2098 = players;
			_k2098 = GetFirstArrayKey( _a2098 );
			while ( isdefined( _k2098 ) )
			{
				player = _a2098[ _k2098 ];
				if ( isdefined( player ) && player IsTouching( e_gg_zone ) && !player.afterlife && !player laststand::player_is_in_laststand() )
				{
					b_is_time_to_despawn = 0;
				}
				_k2098 = GetNextArrayKey( _a2098, _k2098 );
			}
			wait 0.05;
		}
		zombies = GetAISpeciesArray( "axis", "all" );
		i = 0;
		while ( i < zombies.size )
		{
			if ( isdefined( zombies[ i ].is_brutus ) && zombies[ i ].is_brutus && isdefined( zombies[ i ].is_bridge_brutus ) && zombies[ i ].is_bridge_brutus )
			{
				level thread zm_ai_brutus::brutusTempDespawn( zombies[ i ], "bridge_empty", "bring_bridge_brutuses_back" );
			}
			i++;
		}
		b_is_time_to_bring_back = 0;
		while ( !b_is_time_to_bring_back )
		{
			b_is_time_to_bring_back = 0;
			players = GetPlayers();
			_a2125 = players;
			_k2125 = GetFirstArrayKey( _a2125 );
			while ( isdefined( _k2125 ) )
			{
				player = _a2125[ _k2125 ];
				if ( isdefined( player ) && player IsTouching( e_gg_zone ) && !player.afterlife && !player laststand::player_is_in_laststand() )
				{
					b_is_time_to_bring_back = 1;
				}
				_k2125 = GetNextArrayKey( _a2125, _k2125 );
			}
			wait 0.05;
		}
		level notify( "bring_bridge_brutuses_back" );
	}
}

function get_bridge_brutus_count()
{
	n_touching_count = 0;
	e_gg_zone = GetEnt( "bridge_zone", "targetname" );
	zombies = GetAISpeciesArray( "axis", "all" );
	i = 0;
	while ( i < zombies.size )
	{
		if ( isdefined( zombies[ i ].is_brutus ) && zombies[ i ].is_brutus )
		{
			brutus = zombies[ i ];
			if ( brutus IsTouching( e_gg_zone ) )
			{
				n_touching_count++;
			}
		}
		i++;
	}
	return n_touching_count;
}

function clean_up_bridge_brutuses()
{
	zombies = GetAISpeciesArray( "axis", "all" );
	i = 0;
	while ( i < zombies.size )
	{
		if ( isdefined( zombies[ i ].is_brutus ) && zombies[ i ].is_brutus && isdefined( zombies[ i ].is_bridge_brutus ) && zombies[ i ].is_bridge_brutus )
		{
			brutus = zombies[ i ];
			brutus DoDamage( 10000, brutus.origin );
		}
		i++;
	}
}

function spin_while_falling()
{
	self endon( "movedone" );
	while ( 1 )
	{
		self.angles += VectorScale( ( 0, 0, 0 ), 4 );
		wait 0.05;
	}
}

function manage_electric_chairs()
{
	level notify( "manage_electric_chairs" );
	level endon( "manage_electric_chairs" );
	n_chairs_wait = 60;
	while ( 1 )
	{
		level flag::wait_till( "plane_approach_bridge" );
		i = 1;
		while ( i < 5 )
		{
			str_trigger_targetname = "trigger_electric_chair_" + i;
			t_electric_chair = GetEnt( str_trigger_targetname, "targetname" );
			if ( isdefined( level.electric_chair_trigger_thread_custom_func ) )
			{
				t_electric_chair thread [[ level.electric_chair_trigger_thread_custom_func ]]( i );
			}
			else
			{
				t_electric_chair thread electric_chair_trigger_thread( i );
			}
			t_electric_chair SetCursorHint( "HINT_NOICON" );
			t_electric_chair SetHintString( "Hold ^3&&1^7 to Activate Chair" );
			t_electric_chair UseTriggerRequireLookAt();
			i++;
		}
		if ( level.final_flight_activated )
		{
			level.revive_trigger_should_ignore_sight_checks = &zm_prison_sq_final::revive_trigger_should_ignore_sight_checks;
			j = 0;
			while ( j < level.final_flight_players.size )
			{
				m_electric_chair = GetEnt( "electric_chair_" + ( j + 1 ), "targetname" );
				corpse = level.final_flight_players[ j ].e_afterlife_corpse;
				newcorpse = spawn_player_clone( self, m_electric_chair.origin, undefined );
				newcorpse.angles = m_electric_chair.angles;
				//newcorpse LinkTo( m_electric_chair, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
				newcorpse clone_animate( "chair" );
				wait 1;
				corpse.revivetrigger Unlink();
				corpse.revivetrigger.origin = m_electric_chair.origin + ( 64, 0, 32 );
				//level.final_flight_players[ j ].e_afterlife_corpse = newcorpse;
				j++;
			}
			j = 1;
			while ( j < 5 )
			{
				str_trigger_targetname = "trigger_electric_chair_" + j;
				t_electric_chair = GetEnt( str_trigger_targetname, "targetname" );
				t_electric_chair TriggerEnable(false);
				j++;
			}
			while ( level flag::get( "plane_approach_bridge" ) )
			{
				wait 1;
			}
		}
		else
		 i = 1;
		while ( i < 5 )
		{
			m_electric_chair = GetEnt( "electric_chair_" + i, "targetname" );
			m_electric_chair Hide();
			str_trigger_targetname = "trigger_electric_chair_" + i;
			t_electric_chair = GetEnt( str_trigger_targetname, "targetname" );
			t_electric_chair TriggerEnable(false);
			i++;
		}
		level flag::wait_till( "plane_crashed" );
		wait n_chairs_wait;
		exploder::exploder( 666 );
		i = 1;
		while ( i < 5 )
		{
			m_electric_chair = GetEnt( "electric_chair_" + i, "targetname" );
			m_electric_chair Show();
			m_electric_chair thread snddelayedchairaudio( i );
			str_trigger_targetname = "trigger_electric_chair_" + i;
			t_electric_chair = GetEnt( str_trigger_targetname, "targetname" );
			t_electric_chair TriggerEnable(true);
			i++;
		}
		wait 3;
		zm_alcatraz_sq_vo::electric_chair_vo();
		wait 6;
	}
}

function snddelayedchairaudio( i )
{
	wait ( i / 10 );
	self PlaySound( "zmb_quest_electricchair_spawn" );
}

function electric_chair_trigger_thread( chair_number )
{
	level notify( "electric_chair_trigger_thread_" + chair_number );
	level endon( "electric_chair_trigger_thread_" + chair_number );
	m_electric_chair = GetEnt( "electric_chair_" + chair_number, "targetname" );
	n_effects_wait_1 = 4;
	n_effects_wait_2 = 0.15;
	n_effects_wait_3 = 2;
	n_effects_wait_4 = 2;
	n_effects_duration = n_effects_wait_1 + n_effects_wait_2 + n_effects_wait_3 + n_effects_wait_4;
	while ( 1 )
	{
		self waittill( "trigger", e_triggerer );
		character_name = e_triggerer.character_name;
		if ( IsPlayer( e_triggerer ) && !e_triggerer.afterlife )
		{
			e_triggerer EnableInvulnerability();
			self SetHintString( "" );
			self TriggerEnable(false);
			level flag::set( "plane_trip_to_nml_successful" );
			if ( level.characters_in_nml.size == 1 )
			{
				clean_up_bridge_brutuses();
			}
			v_origin = m_electric_chair GetTagOrigin( "seated" ) + ( 10, 0, -40 );
			v_seated_angles = m_electric_chair GetTagAngles( "seated" );
			m_linkpoint = spawn_model( "tag_origin", v_origin, v_seated_angles );
			if ( isdefined( level.electric_chair_player_thread_custom_func ) )
			{
				e_triggerer thread [[ level.electric_chair_player_thread_custom_func ]]( m_linkpoint, chair_number, n_effects_duration );
			}
			else
			{
				e_triggerer thread electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration );
			}
			chair_corpse = e_triggerer spawn_player_clone( e_triggerer, m_electric_chair.origin, undefined );
			chair_corpse LinkTo( m_electric_chair, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
			chair_corpse.ignoreme = 1;
			chair_corpse Show();
			chair_corpse DetachAll();
			chair_corpse SetVisibleToAll();
			chair_corpse SetInvisibleToPlayer( e_triggerer );
			chair_corpse clone_animate( "chair" );
			if ( isdefined( e_triggerer ) )
			{
				//e_triggerer clientfield::set_to_player( "rumble_electric_chair", 1 );
			}
			wait n_effects_wait_1;
			m_fx_1 = spawn_model( "tag_origin", ( -516.883, -3912.04, -7494.9 ), vectorScale( ( 0, 0, 0 ), 180 ) );
			m_fx_2 = spawn_model( "tag_origin", ( -517.024, -3252.66, -7496.2 ), ( 0, 0, 0 ) );
			//level clientfield::set( "scripted_lightning_flash", 1 );
			wait n_effects_wait_2;
			PlayFXOnTag( level._effect[ "fx_alcatraz_lightning_finale" ], m_fx_1, "tag_origin" );
			PlayFXOnTag( level._effect[ "fx_alcatraz_lightning_finale" ], m_fx_2, "tag_origin" );
			PlayFX(level._effect[ "fx_alcatraz_flight_lightning_new" ],(-12295.2,25951,7356.22 ) + (0,0,1500));
			PlayFX(level._effect[ "fx_alcatraz_flight_lightning_new" ],(-12310.2,27016,7356.22 ) + (0,0,1500));
			m_fx_3 = spawn_model( "tag_origin", ( -753.495, -3092.62, -8416.6 ), vectorScale( ( 0, 0, 0 ), 270 ) );
			PlayFXOnTag( level._effect[ "fx_alcatraz_lightning_wire" ], m_fx_3, "tag_origin" );
			wait n_effects_wait_3;
			m_electric_chair play_fx( "fx_alcatraz_elec_chair", m_electric_chair.origin, m_electric_chair.angles, "bridge_empty" );
			if ( isdefined( e_triggerer ) )
			{
				//e_triggerer clientfield::set_to_player( "rumble_electric_chair", 2 );
			}
			wait n_effects_wait_4;
			PlayFXOnTag( level._effect[ "afterlife_teleport" ], m_electric_chair, "tag_origin" );
			if ( isdefined( e_triggerer ) )
			{
				e_triggerer PlaySoundToPlayer( "zmb_afterlife_death", e_triggerer );
			}
			chair_corpse Delete();
			if ( level.characters_in_nml.size == 1 )
			{
				clean_up_bridge_brutuses();
			}
			if ( IsInArray( level.characters_in_nml, character_name ) )
			{
				ArrayRemoveValue( level.characters_in_nml, character_name );
			}
			m_fx_1 Delete();
			m_fx_2 Delete();
			self SetHintString( "Hold ^3&&1^7 to Activate Chair" );
			self TriggerEnable(true);
		}
	}
}

function electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration )
{
	self endon( "death_or_disconnect" );
	e_home_telepoint = struct::get( "home_telepoint_" + chair_number, "targetname" );
	e_corpse_location = struct::get( "corpse_starting_point_new_" + chair_number, "targetname" );
	self DisableWeapons();
	self EnableInvulnerability();
	self SetStance( "stand" );
	self PlayerLinkToDelta( m_linkpoint, "tag_origin", 1, 20, 20, 20, 20 );
	self SetPlayerAngles( m_linkpoint.angles );
	self PlaySoundToPlayer( "zmb_electric_chair_2d", self );
	self zm_utility::do_player_general_vox( "quest", "chair_electrocution", undefined, 100 );
	self Ghost();
	self.ignoreme = 1;
	self.dontspeak = 1;
	//self clientfield::set_to_player( "isspeaking", 1 );
	wait ( n_effects_duration - 2 );
	switch( self.character_name )
	{
		case "Arlington":
			self PlaySoundOnTag( "vox_plr_3_arlington_electrocution_0", "J_Head" );
			break;
		case "Sal":
			self PlaySoundOnTag( "vox_plr_1_sal_electrocution_0", "J_Head" );
			break;
		case "Billy":
			self PlaySoundOnTag( "vox_plr_2_billy_electrocution_0", "J_Head" );
			break;
		case "Finn":
			self PlaySoundOnTag( "vox_plr_0_finn_electrocution_0", "J_Head" );
			break;
	}
	wait 2;
	level.zones[ "bridge_zone" ].is_enabled = 1;
	level.zones[ "bridge_zone" ].is_spawning_allowed = 1;
	self.keep_perks = 1;
	self DisableInvulnerability();
	self.afterlife = 1;
	self thread _zm_afterlife::afterlife_laststand( 1, e_corpse_location.origin );
	self Unlink();
	self SetStance( "stand" );
	self waittill( "player_fake_corpse_created" );
	self thread track_player_completed_cycle();
	self SetOrigin( e_home_telepoint.origin );
	self EnableWeapons();
	//self clientfield::set_to_player( "rumble_electric_chair", 0 );
	if ( level.n_quest_iteration_count == 2 )
	{
		self waittill( "player_revived" );
		wait 1;
		self zm_utility::do_player_general_vox( "quest", "start_2", undefined, 100 );
	}
}

function track_player_completed_cycle()
{
	self endon( "disconnect" );
	self.e_afterlife_corpse waittill( "death" );
	self notify( "player_completed_cycle" );
	level notify( "someone_completed_quest_cycle" );
}

function reset_plane_hint_string( player )
{
	if ( isdefined( self.stub ) )
	{
/#
		IPrintLnBold( "Error: This should have been handled by the craftables callback" );
#/
	}
	else
	{
		self.fly_trigger SetHintString( "Hold ^3&&1^7 to Begin Take-Off" );
	}
}

function play_fx( str_fx, v_origin, v_angles, time_to_delete_or_notify, b_link_to_self, str_tag, b_no_cull )
{
	if ( isdefined( time_to_delete_or_notify ) && !IsString( time_to_delete_or_notify ) && time_to_delete_or_notify == -1 && isdefined( b_link_to_self ) && b_link_to_self && isdefined( str_tag ) )
	{
		PlayFXOnTag( getfx( str_fx ), self, str_tag );
		return self;
	}
	else
	{
		m_fx = spawn_model( "tag_origin", v_origin, v_angles );
		if ( isdefined( b_link_to_self ) && b_link_to_self )
		{
			if ( isdefined( str_tag ) )
			{
				m_fx LinkTo( self, str_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
			}
			else
			{
				m_fx LinkTo( self );
			}
		}
		if ( isdefined( b_no_cull ) && b_no_cull )
		{
			m_fx SetForceNoCull();
		}
		PlayFXOnTag( getfx( str_fx ), m_fx, "tag_origin" );
		m_fx thread _play_fx_delete( self, time_to_delete_or_notify );
		return m_fx;
	}
}

function spawn_model( model_name, origin, angles, n_spawnflags )
{
	if ( !isdefined( n_spawnflags ) )
	{
		n_spawnflags = 0;
	}
	if ( !isdefined( origin ) )
	{
		origin = ( 0, 0, 0 );
	}
	model = Spawn( "script_model", origin, n_spawnflags );
	model SetModel( model_name );
	if ( isdefined( angles ) )
	{
		model.angles = angles;
	}
	return model;
}

function getfx( fx )
{
/#
	assert( isDefined( level._effect[ fx ] ), "Fx " + fx + " is not defined in level._effect." );
#/
	return level._effect[ fx ];
}

function _play_fx_delete( ent, time_to_delete_or_notify )
{
	if ( !isdefined( time_to_delete_or_notify ) )
	{
		time_to_delete_or_notify = -1;
	}
	if ( IsString( time_to_delete_or_notify ) )
	{
		ent util::waittill_either( "death", time_to_delete_or_notify );
	}
	else if ( time_to_delete_or_notify > 0 )
	{
		ent util::waittill_notify_or_timeout( "death", time_to_delete_or_notify );
	}
	else
	{
		ent waittill( "death" );
	}
	if ( isdefined( self ) )
	{
		self Delete();
	}
}

function player_disconnect_watcher()
{
	if ( isdefined( level.player_disconnect_watcher_custom_func ) )
	{
		self thread [[ level.player_disconnect_watcher_custom_func ]]();
		return;
	}
	self notify( "disconnect_watcher" );
	self endon( "disconnect_watcher" );
	level endon( "bridge_empty" );
/#
	IPrintLnBold( "player_disconnect_watcher" );
#/
	if ( !isdefined( self.character_name ) )
	{
		wait 0.1;
	}
	character_name = self.character_name;
	self waittill( "disconnect" );
/#
	IPrintLnBold( character_name + " disconnected!" );
#/
	if ( IsInArray( level.characters_in_nml, character_name ) )
	{
		ArrayRemoveValue( level.characters_in_nml, character_name );
		level flag::set( "spawn_zombies" );
		level.brutus_respawn_after_despawn = 1;
	}
}

function player_death_watcher()
{
	/*if ( isdefined( level.player_death_watcher_custom_func ) )
	{
		self thread [[ level.player_death_watcher_custom_func ]]();
		return;
	}*/
	self notify( "player_death_watcher" );
	self endon( "player_death_watcher" );
	level endon( "bridge_empty" );
/#
	IPrintLnBold( "player_death_watcher" );
#/
	e_gg_zone = GetEnt( "bridge_zone", "targetname" );
	nml_trip_is_over = 0;
	while ( !nml_trip_is_over )
	{
		level waittill( "start_of_round" );
		nml_trip_is_over = 1;
		players = GetPlayers();
		_a2671 = players;
		_k2671 = GetFirstArrayKey( _a2671 );
		while ( isdefined( _k2671 ) )
		{
			player = _a2671[ _k2671 ];
			if ( player IsTouching( e_gg_zone ) || isdefined( player.on_a_plane ) && player.on_a_plane )
			{
				nml_trip_is_over = 0;
				if ( !IsInArray( level.characters_in_nml, player.character_name ) )
				{
					level.characters_in_nml[ level.characters_in_nml.size ] = player.character_name;
				}
			}
			_k2671 = GetNextArrayKey( _a2671, _k2671 );
		}
		wait 0.05;
	}
	while ( isdefined( level.characters_in_nml ) && level.characters_in_nml.size > 0 )
	{
		i = 0;
		while ( i < level.characters_in_nml.size )
		{
			character_name = level.characters_in_nml[ i ];
			if ( IsInArray( level.characters_in_nml, character_name ) )
			{
				ArrayRemoveValue( level.characters_in_nml, character_name );
			}
			i++;
		}
		wait 0.05;
	}
	level flag::set( "spawn_zombies" );
	level.brutus_respawn_after_despawn = 1;
}

function array_set_visible_to_all( a_ents, is_visible )
{
	if ( is_visible )
	{
		_a2707 = a_ents;
		_k2707 = GetFirstArrayKey( _a2707 );
		while ( isdefined( _k2707 ) )
		{
			ent = _a2707[ _k2707 ];
			ent SetVisibleToAll();
			_k2707 = GetNextArrayKey( _a2707, _k2707 );
		}
	}
	else _a2714 = a_ents;
	_k2714 = GetFirstArrayKey( _a2714 );
	while ( isdefined( _k2714 ) )
	{
		ent = _a2714[ _k2714 ];
		ent SetInvisibleToAll();
		_k2714 = GetNextArrayKey( _a2714, _k2714 );
	}
}

function warden_fence_hotjoin_handler()
{
	while ( 1 )
	{
		level waittill( "warden_fence_up" );
		exploder::stop_exploder( 2000 );
		exploder::exploder( 2000 );
		wait 0.05;
	}
}

function spawn_player_clone( player, origin, forceweapon, forcemodel )
{
	clone = Spawn("script_model", origin);
	switch( player.character_name )
	{
		case "Finn":
			model = "c_zom_player_oleary_fb_chair";
			break;
		case "Sal":
			model = "c_zom_player_deluca_fb_chair";
			break;
		case "Billy":
			model = "c_zom_player_handsome_fb_chair";
			break;
		case "Arlington":
			model = "c_zom_player_arlington_fb_chair";
			break;
	}
	clone SetModel(model);

	return clone;
}

function clone_animate( animtype )
{
	self UseAnimTree( #animtree );
	switch( animtype )
	{
		case "afterlife":
			self AnimScripted( "test", self.origin, self.angles, %pb_afterlife_laststand_idle ); 
			break;
		case "chair":
			self AnimScripted( "test", self.origin, self.angles, %ai_actor_elec_chair_idle ); 
			break;
	}
}

function clone_give_weapon( weapon )
{
	weaponModel = zm_utility::spawn_weapon_model( GetWeapon(weapon), undefined, self GetTagOrigin("tag_weapon_right"), self GetTagAngles("tag_weapon_right") );
	if (weaponModel != "" && weaponModel != "none" )
	{
		weaponModel LinkTo(self,"tag_weapon_right");
	}
	return weaponModel;
}