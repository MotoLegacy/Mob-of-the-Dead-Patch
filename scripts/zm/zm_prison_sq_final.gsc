
#using scripts\zm\_zm_score;
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\gameobjects_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\lui_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_alcatraz_sq_nixie;
#using scripts\zm\_zm_afterlife;
#using scripts\zm\_zm_ai_brutus;
#using scripts\zm\zm_alcatraz_amb;


#precache( "xmodel", "p6_zm_al_audio_headset_icon" );
#precache("material", "waypoint_kill_red");

function onplayerconnect_sq_final() {
}

function stage_one() {
	//level thread stage_two();

	level flag::wait_till( "quest_completed_thrice" );
	level flag::wait_till( "spoon_obtained" );
	level flag::wait_till( "warden_blundergat_obtained" );

	i = 1;
	while ( i < 4 ) {
		m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
		m_nixie_tube thread nixie_tube_scramble_protected_effects( i );
		i++;
	}
	level util::waittill_multiple( "nixie_tube_trigger_1", "nixie_tube_trigger_2", "nixie_tube_trigger_3" );
	level thread nixie_final_codes( 386 );
	level thread nixie_final_codes( 481 );
	level thread nixie_final_codes( 101 );
	level thread nixie_final_codes( 872 );
	level util::waittill_multiple( "nixie_final_" + 386, "nixie_final_" + 481, "nixie_final_" + 101, "nixie_final_" + 872 );
	nixie_tube_off();
	m_nixie_tube = GetEnt( "nixie_tube_1", "targetname" );
	m_nixie_tube PlaySoundWithNotify( "vox_brutus_nixie_right_0", "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
	wait 3;
	level thread stage_two();
}

function sq_final_easy_cleanup() {
	
}

function nixie_tube_off() {
	level notify( "kill_nixie_input" );
	wait 1;
	i = 1;
	while ( i < 4 ) {
		m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
		j = 0;
		while ( j < 10 ) {
			m_nixie_tube HidePart( "J_" + j );
			j++;
		}
		wait 0.3;
		i++;
	}
}

function nixie_final_codes( nixie_code ) {
	zm_alcatraz_sq_nixie::nixie_tube_add_code( nixie_code );
	level waittill( "nixie_" + nixie_code );
	level notify( "kill_nixie_input" );
	level flag::set( "nixie_puzzle_solved" );
	level flag::clear( "nixie_ee_flashing" );
	goal_num_1 = zm_alcatraz_sq_nixie::get_split_number( 1, nixie_code );
	goal_num_2 = zm_alcatraz_sq_nixie::get_split_number( 2, nixie_code );
	goal_num_3 = zm_alcatraz_sq_nixie::get_split_number( 3, nixie_code );
	nixie_tube_win_effects_all_tubes_final( goal_num_2, goal_num_3, goal_num_1 );
	level flag::set( "nixie_ee_flashing" );
	level flag::clear( "nixie_puzzle_solved" );
	zm_alcatraz_sq_nixie::nixie_reset_control( 0 );
	level notify( "nixie_final_" + nixie_code );
}

function nixie_tube_scramble_protected_effects( n_tube_index ) {
	self endon( "nixie_scramble_stop" );
	level endon( "nixie_tube_trigger_" + n_tube_index );
	n_change_rate = 0.1;
	unrestricted_scramble_num = [];
	unrestricted_scramble_num[ 1 ] = array( 0, 2, 5, 6, 7 );
	unrestricted_scramble_num[ 2 ] = array( 2, 4, 5, 6, 9 );
	unrestricted_scramble_num[ 3 ] = array( 0, 3, 4, 7, 8, 9 );
	n_number_to_display = array::random( unrestricted_scramble_num[ n_tube_index ] );
	while ( 1 ) {
		self HidePart( "J_" + n_number_to_display );
		n_number_to_display = array::random( unrestricted_scramble_num[ n_tube_index ] );
		self ShowPart( "J_" + n_number_to_display );
		self PlaySound( "zmb_quest_nixie_count" );
		wait n_change_rate;
	}
}

function nixie_final_audio_cue_code() {
	m_nixie_tube = GetEnt( "nixie_tube_1", "targetname" );
	m_nixie_tube PlaySoundWithNotify( "vox_brutus_nixie_right_0", "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
}

function nixie_tube_win_effects_all_tubes_final( goal_num_1, goal_num_2, goal_num_3 ) {
	if ( !isdefined( goal_num_1 ) ) {
		goal_num_1 = 0;
	}
	if ( !isdefined( goal_num_2 ) ) {
		goal_num_2 = 0;
	}
	if ( !isdefined( goal_num_3 ) ) {
		goal_num_3 = 0;
	}
	a_nixie_tube = [];
	a_nixie_tube[ 1 ] = GetEnt( "nixie_tube_1", "targetname" );
	a_nixie_tube[ 2 ] = GetEnt( "nixie_tube_2", "targetname" );
	a_nixie_tube[ 3 ] = GetEnt( "nixie_tube_3", "targetname" );
	n_off_tube = 1;
	start_time = 0;
	while ( start_time < 2 ) {
		i = 1;
		while ( i < ( 3 + 1 ) ) {
			if ( i == n_off_tube ) {
				a_nixie_tube[ i ] HidePart( "J_" + level.a_nixie_tube_code[ i ] );
				i++;
				continue;
			}
			else {
				a_nixie_tube[ i ] ShowPart( "J_" + level.a_nixie_tube_code[ i ] );
				if ( i == 1 || n_off_tube == 2 && i == 3 && n_off_tube == 1 ) {
					a_nixie_tube[ i ] PlaySound( "zmb_quest_nixie_count" );
				}
			}
			i++;
		}
		n_off_tube++;
		if ( n_off_tube > 3 ) {
			n_off_tube = 1;
		}
		util::wait_network_frame();
		start_time += 0.15;
	}
	a_nixie_tube[ 1 ] ShowPart( "J_" + level.a_nixie_tube_code[ 1 ] );
	a_nixie_tube[ 2 ] ShowPart( "J_" + level.a_nixie_tube_code[ 2 ] );
	a_nixie_tube[ 3 ] ShowPart( "J_" + level.a_nixie_tube_code[ 3 ] );
	while ( level.a_nixie_tube_code[ 1 ] != goal_num_1 || level.a_nixie_tube_code[ 2 ] != goal_num_2 && level.a_nixie_tube_code[ 3 ] != goal_num_3 ) {
		n_current_tube = 1;
		n_goal = goal_num_1;
		if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_1 ) {
			n_current_tube = 2;
			n_goal = goal_num_2;
			if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_2 ) {
				n_current_tube = 3;
				n_goal = goal_num_3;
			}
		}
		util::wait_network_frame();
		j = 0;
		while ( level.a_nixie_tube_code[ n_current_tube ] != n_goal ) {
			a_nixie_tube[ n_current_tube ] HidePart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			level.a_nixie_tube_code[ n_current_tube ]--;

			if ( level.a_nixie_tube_code[ n_current_tube ] == -1 ) {
				level.a_nixie_tube_code[ n_current_tube ] = 9;
			}
			a_nixie_tube[ n_current_tube ] ShowPart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			if ( ( j % 3 ) == 0 ) {
				a_nixie_tube[ n_current_tube ] PlaySound( "zmb_quest_nixie_count" );
			}
			j++;
			wait 0.05;
		}
	}
	a_nixie_tube[ 2 ] PlaySound( "zmb_quest_nixie_count_final" );
	util::wait_network_frame();
}

function stage_two() {
	audio_logs = [];
	audio_logs[ 0 ] = [];
	audio_logs[ 0 ][ 0 ] = "vox_guar_tour_vo_1_0";
	audio_logs[ 0 ][ 1 ] = "vox_guar_tour_vo_2_0";
	audio_logs[ 0 ][ 2 ] = "vox_guar_tour_vo_3_0";
	audio_logs[ 2 ] = [];
	audio_logs[ 2 ][ 0 ] = "vox_guar_tour_vo_4_0";
	audio_logs[ 3 ] = [];
	audio_logs[ 3 ][ 0 ] = "vox_guar_tour_vo_5_0";
	audio_logs[ 3 ][ 1 ] = "vox_guar_tour_vo_6_0";
	audio_logs[ 4 ] = [];
	audio_logs[ 4 ][ 0 ] = "vox_guar_tour_vo_7_0";
	audio_logs[ 5 ] = [];
	audio_logs[ 5 ][ 0 ] = "vox_guar_tour_vo_8_0";
	audio_logs[ 6 ] = [];
	audio_logs[ 6 ][ 0 ] = "vox_guar_tour_vo_9_0";
	audio_logs[ 6 ][ 1 ] = "vox_guar_tour_vo_10_0";
	play_sq_audio_log( 0, audio_logs[ 0 ], 0 );
	i = 2;
	while ( i <= 6 ) {
		play_sq_audio_log( i, audio_logs[ i ], 1 );
		i++;
	}
	level.m_headphones Delete();
	t_plane_fly_afterlife = GetEnt( "plane_fly_afterlife_trigger", "script_noteworthy" );
	t_plane_fly_afterlife PlaySound( "zmb_laugh_child" );
	trigger_is_on = 0;
	while ( 1 ) {
		wait 0.1;
		players = GetPlayers();
		if ( players.size > 1 || level.is_forever_solo_game) {
			arlington_is_present = 0;
			foreach(player in players) {
				if ( isdefined( player ) && player.character_name == "Arlington" ) {
					arlington_is_present = 1;
				}
			}
			if ( arlington_is_present && !trigger_is_on ) {
				t_plane_fly_afterlife TriggerEnable(true);
				trigger_is_on = 1;
			}
			else {
				if ( !arlington_is_present && trigger_is_on ) {
					t_plane_fly_afterlife TriggerEnable(false);
					trigger_is_on = 0;
				}
			}
		}
		else {
			if ( trigger_is_on ) {
				t_plane_fly_afterlife TriggerEnable(false);
				trigger_is_on = 0;
			}
		}
		wait 0.1;
	}
}

function headphones_rotate() {
	self endon( "death" );
	while ( isdefined(self) ) {
		self RotateYaw( 360, 3 );
		self waittill( "rotatedone" );
	}
}

function play_sq_audio_log( num, a_vo, b_use_trig ) {
	v_pos = struct::get( "sq_at_" + num, "targetname" ).origin;
	if ( !isdefined( level.m_headphones ) ) {
		level.m_headphones = Spawn( "script_model", v_pos );
		//level.m_headphones Ghostindemo();
		level.m_headphones SetModel( "p6_zm_al_audio_headset_icon" );
		PlayFXOnTag( level._effect[ "powerup_on" ], level.m_headphones, "tag_origin" );
		level.m_headphones thread headphones_rotate();
		level.m_headphones PlayLoopSound( "zmb_spawn_powerup_loop" );
		level.m_headphones TriggerEnable(false);
	}
	else {
		level.m_headphones TriggerEnable(true);
		level.m_headphones.origin = v_pos;
	}
	if ( b_use_trig ) {
		trigger = Spawn( "trigger_radius", level.m_headphones.origin , 0, 30, 150 );
		trigger waittill( "trigger" );
		trigger Delete();
	}
	level.m_headphones TriggerEnable(false);
	//level setclientfield( "toggle_futz", 1 );
	foreach(player in GetPlayers()) {
		VisionSetNaked( "zombie_noire", 0.05 ); 
	}
	i = 0;
	while ( i < a_vo.size ) {
		level.m_headphones PlaySoundWithNotify( a_vo[ i ], "at_done" );
		level.m_headphones waittill( "at_done" );
		wait 0.5;
		i++;
	}
	//level setclientfield( "toggle_futz", 0 );
	foreach(player in GetPlayers()) {
		VisionSetNaked( "zm_factory" ); 
	}
	level.m_headphones Delete();
}

function final_flight_setup() {
	t_plane_fly_afterlife = GetEnt( "plane_fly_afterlife_trigger", "script_noteworthy" );
	t_plane_fly_afterlife thread final_flight_trigger();
	t_plane_fly_afterlife TriggerEnable(false);
}

function final_flight_trigger() {
	t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
	self SetCursorHint( "HINT_NOICON" );
	self SetHintString( "" );
	while ( 1 ) {
		self waittill( "trigger", e_triggerer );
		wait 0.05;
		if ( IsPlayer( e_triggerer ) ) {
			players = GetPlayers();
			// SOLO EE
			if ( players.size < 2 && !level.is_forever_solo_game) {
				wait 0.05;
				continue;
			}
			b_everyone_is_ready = 1;
			foreach(player in players) {
				if ( isdefined( player ) && player.sessionstate == "spectator" || player laststand::player_is_in_laststand() || !IsAlive(player) ) {
					b_everyone_is_ready = 0;
				}
			}
			if ( !b_everyone_is_ready ) {
				wait 0.05;
				continue;
			}
			if ( level flag::get( "plane_is_away" ) ) {
				wait 0.05;
				continue;
			}
			level flag::set( "plane_is_away" );
			t_plane_fly TriggerEnable(false);
			t_plane_fly.trigger_off = 1;
			foreach(player in players) {
				if ( isdefined( player ) ) {
/#
					IPrintLnBold( "LINK PLAYER TO PLANE, START COUNTDOWN IF NOT YET STARTED" );
#/
					player thread final_flight_player_thread();
				}
			}
			return;
		}
	}
}

function final_flight_player_thread()
{
	self endon( "death_or_disconnect" );
	self.on_a_plane = 1;
	self.dontspeak = 1;
	//self setclientfieldtoplayer( "isspeaking", 1 );
/#
	IPrintLnBold( "plane boarding thread started" );
#/
	if ( !IS_TRUE(self.afterlife) ) {
		self.keep_perks = 1;
		self _zm_afterlife::afterlife_remove();
		self.afterlife = 1;
		self thread _zm_afterlife::afterlife_laststand();
		self waittill( "player_fake_corpse_created" );
	}
	self _zm_afterlife::afterlife_infinite_mana( 1 );
	level.final_flight_activated = 1;
	level.final_flight_players[ level.final_flight_players.size ] = self;
	a_nml_teleport_targets = [];
	i = 1;
	while ( i < 6 ) {
		a_nml_teleport_targets[ i - 1 ] = struct::get( "nml_telepoint_" + i, "targetname" );
		i++;
	}
	self.n_passenger_index = level.final_flight_players.size;
	a_players = [];
	a_players = GetPlayers();
	if ( a_players.size == 1 ) {
		self.n_passenger_index = 1;
	}
	m_plane_craftable = GetEnt( "plane_craftable", "targetname" );
	m_plane_about_to_crash = GetEnt( "plane_about_to_crash", "targetname" );
	m_plane_about_to_crash Ghost();
	veh_plane_flyable = GetEnt( "plane_flyable", "targetname" );
	veh_plane_flyable Show();
	level flag::set( "plane_boarded" );
	t_plane_fly = GetEnt( "plane_fly_trigger", "targetname" );
	str_hint_string = "BOARD FINAL FLIGHT";
	t_plane_fly SetHintString( str_hint_string );
	self PlayerLinkToDelta( m_plane_craftable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	self AllowCrouch( 1 );
	self AllowStand( 0 );
	self util::clientnotify( "sndFFCON" );
	level flag::wait_till( "plane_departed" );
	level notify( "sndStopBrutusLoop" );
	self util::clientnotify( "sndPS" );
	self PlaySoundToPlayer( "zmb_plane_takeoff", self );
	level thread zm_alcatraz_amb::sndplaystinger( "plane_takeoff", self );
	m_plane_craftable Ghost();
	self PlayerLinkToDelta( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	//self setclientfieldtoplayer( "effects_escape_flight", 1 );
	level flag::wait_till( "plane_approach_bridge" );
	self thread zm_alcatraz_sq::snddelayedimp();
	//self setclientfieldtoplayer( "effects_escape_flight", 2 );
	self Unlink();
	self PlayerLinkToAbsolute( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
	level flag::wait_till( "plane_zapped" );
	level flag::set( "activate_player_zone_bridge" );
	self PlaySoundToPlayer( "zmb_plane_fall", self );
	//self setclientfieldtoplayer( "effects_escape_flight", 3 );
	self.dontspeak = 1;
	//self setclientfieldtoplayer( "isspeaking", 1 );
	self PlayerLinkToDelta( m_plane_about_to_crash, "tag_player_crouched_" + ( self.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
	level flag::wait_till( "plane_crashed" );
	self thread lui::screen_flash( 0, 2, 0.5, 1, "black" );
	//self thread fadetoblackforxsec( 0, 2, 0, 0,5, "black" );
	self Unlink();
	self AllowStand( 1 );
	self SetStance( "stand" );
	self AllowCrouch( 0 );
	level flag::clear( "spawn_zombies" );
	self SetOrigin( a_nml_teleport_targets[ self.n_passenger_index ].origin );
	e_poi = struct::get( "plane_crash_poi", "targetname" );
	vec_to_target = e_poi.origin - self.origin;
	vec_to_target = VectortoAngles( vec_to_target );
	vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
	self SetPlayerAngles( vec_to_target );
	n_shellshock_duration = 5;
	self ShellShock( "explosion", n_shellshock_duration );
	self.on_a_plane = 0;
	stage_final();
}

function stage_final() {
	//level.custom_game_over_hud_elem = &custom_game_over_hud_elem;
	level notify( "stage_final" );
	level endon( "stage_final" );
	b_everyone_alive = 0;
	while ( isdefined( b_everyone_alive ) && !b_everyone_alive ) {
		b_everyone_alive = 1;
		foreach(player in GetPlayers()) {
			if ( IS_TRUE( player.afterlife ) ) {
				b_everyone_alive = 0;
				wait 0.05;
				break;
			}
		}
	}
	level._should_skip_ignore_player_logic = &final_showdown_zombie_logic;
	level flag::set( "spawn_zombies" );
	foreach(player in GetPlayers())
	{
		player thread _zm_afterlife::afterlife_remove(1);
	}
	//array::thread_all( GetPlayers(), &_zm_afterlife::afterlife_remove );
	p_weasel = undefined;
	a_player_team = [];
	a_players = GetPlayers();
	foreach(player in a_players) {
		player.dontspeak = 1;
		if ( player GetCharacterBodyType() == 3 || player GetCharacterBodyType() == 8 ) {
			p_weasel = player;
		}
		else a_player_team[ a_player_team.size ] = player;
	}
	if ( isdefined( p_weasel ) && a_player_team.size > 0 ) {
		level.longregentime = 1000000;
		level.playerhealth_regularregendelay = 1000000;
		p_weasel.team = level.zombie_team;
		p_weasel.pers[ "team" ] = level.zombie_team;
		p_weasel.sessionteam = level.zombie_team;
		p_weasel.maxhealth = a_player_team.size * 2000;
		p_weasel.health = p_weasel.maxhealth;
		foreach(player in a_player_team) {
			player.maxhealth = 2000;
			player.health = player.maxhealth;
		}
		s_start_point = struct::get( "final_fight_starting_point_weasel", "targetname" );
		if ( isdefined( p_weasel ) && isdefined( s_start_point ) ) {
			PlayFX( level._effect[ "afterlife_teleport" ], p_weasel.origin );
			p_weasel SetOrigin( s_start_point.origin );
			p_weasel SetPlayerAngles( s_start_point.angles );
			p_weasel.ignoreme = true;
			PlayFX( level._effect[ "afterlife_teleport" ], p_weasel.origin );
		}
		i = 0;
		while ( i < a_player_team.size ) {
			s_start_point = struct::get( "final_fight_starting_point_hero_" + ( i + 1 ), "targetname" );
			if ( isdefined( a_player_team[ i ] ) && isdefined( s_start_point ) ) {
				PlayFX( level._effect[ "afterlife_teleport" ], a_player_team[ i ].origin );
				a_player_team[ i ] SetOrigin( s_start_point.origin );
				a_player_team[ i ] SetPlayerAngles( s_start_point.angles );
				PlayFX( level._effect[ "afterlife_teleport" ], a_player_team[ i ].origin );
			}
			i++;
		}
		level thread final_showdown_track_weasel( p_weasel );
		level thread final_showdown_track_team( a_player_team );
		n_spawns_needed = 2;
		i = n_spawns_needed;
		while ( i > 0 ) {
			zm_ai_brutus::brutusSpawnInZone( "bridge_zone" );
			i--;
		}
		level thread final_battle_vo( p_weasel, a_player_team );
		level notify( "pop_goes_the_weasel_achieved" );
		level waittill( "showdown_over" );
	}
	else {
		if ( isdefined( p_weasel ) ) {
			level.winner = "weasel";
		}
		else {
			level.winner = "team";
		}
	}
	level.brutus_respawn_after_despawn = 0;
	level thread clean_up_final_brutuses();
	wait 2;
	if ( level.winner == "weasel" ) 	{
		foreach(player in GetPlayers()) {
			player FreezeControls( 1 );
			//player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_ee_good_ending", 0 );
			player thread lui::screen_flash( 0.5, 5, 0, 1, "white" );
			player create_ending_message( "THE CYCLE IS BROKEN." );
			player.client_hint.sort = 55;
			player.client_hint.color = ( 1, 1, 1 );
			PlaySoundAtPosition( "zmb_quest_final_white_good", ( 1, 1, 1 ) );
			level.sndgameovermusicoverride = "game_over_final_good";
		}
		level.custom_intermission = &player_intermission_bridge;
	}
	else {
		a_players = GetPlayers();
		foreach(player in GetPlayers()) {
			player FreezeControls( 1 );
			//player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_ee_bad_ending", 0 );
			player thread lui::screen_flash( 0.5, 5, 0, 1, "white" );
			player create_ending_message( "THE CYCLE CONTINUES..." );
			player.client_hint.sort = 55;
			player.client_hint.color = ( 1, 1, 1 );
			PlaySoundAtPosition( "zmb_quest_final_white_bad", ( 1, 1, 1 ) );
			level.sndgameovermusicoverride = "game_over_final_bad";
		}
	}
	wait 5;
	foreach(player in GetPlayers()) {
		if ( isdefined( player.client_hint ) ) {
			player thread destroy_tutorial_message();
		}
		if ( isdefined( player.revivetrigger ) ) {
			player thread zm_laststand::revive_success( player, 0 );
			player laststand::cleanup_suicide_hud();
		}
		if ( isdefined( player ) ) {
			player Ghost();
		}
	}
	if ( isdefined( p_weasel ) ) {
		p_weasel.team = "allies";
		p_weasel.pers[ "team" ] = "allies";
		p_weasel.sessionteam = "allies";
		p_weasel Ghost();
	}
	level notify( "end_game" );
}

function destroy_tutorial_message() {
	if ( isdefined( self.client_hint ) ) {
		self.client_hint FadeOverTime( 0.5 );
		self.client_hint.alpha = 0;
		wait 0.5;
		if ( isdefined( self.client_hint ) ) {
			self.client_hint Destroy();
			self.client_hint = undefined;
		}
	}
}

function final_showdown_track_weasel( p_weasel ) {
	level endon( "showdown_over" );
	while ( 1 ) {
		if ( !isdefined( p_weasel ) || p_weasel laststand::player_is_in_laststand() ) {
			level.winner = "team";
			level notify( "showdown_over" );
		}
		wait 0.05;
	}
}

function final_showdown_track_team( a_player_team ) {
	level endon( "showdown_over" );
	while ( 1 ) {
		weasel_won = 1;
		foreach(player in a_player_team) {
			if ( zombie_utility::is_player_valid( player, 0, 0 ) ) {
				weasel_won = 0;
			}
		}
		if ( isdefined( weasel_won ) && weasel_won ) {
			level.winner = "weasel";
			level notify( "showdown_over" );
		}
		wait 0.05;
	}
}

function final_showdown_zombie_logic() {
	foreach(player in GetPlayers()) {
		if ( player GetCharacterBodyType() == 3 || player GetCharacterBodyType() == 8 ) {
			self.ignore_player[ self.ignore_player.size ] = player;
		}
	}
	return 1;
}

function final_showdown_create_icon( player, enemy ) {
	height_offset = 60;
	hud_elem = NewClientHudElem( player );
	hud_elem.x = enemy.origin[ 0 ];
	hud_elem.y = enemy.origin[ 1 ];
	hud_elem.z = enemy.origin[ 2 ] + height_offset;
	hud_elem.alpha = 1;
	hud_elem.archived = 1;
	hud_elem SetShader( "waypoint_kill_red", 8, 8 );
	hud_elem SetWayPoint( 1 );
	hud_elem.foreground = 1;
	hud_elem.hidewheninmenu = 1;
	hud_elem thread final_showdown_update_icon( enemy );
	util::waittill_any_ents( level, "showdown_over", enemy, "disconnect" );
	hud_elem Destroy();
}

function final_showdown_update_icon( enemy ) {
	level endon( "showdown_over" );
	enemy endon( "disconnect" );
	height_offset = 60;
	while ( isdefined( enemy ) ) {
		self.x = enemy.origin[ 0 ];
		self.y = enemy.origin[ 1 ];
		self.z = enemy.origin[ 2 ] + height_offset;
		wait 0.05;
	}
}

function revive_trigger_should_ignore_sight_checks( player_down ) {
	if ( level.final_flight_activated ) {
		return 1;
	}
	return 0;
}

function final_battle_vo( p_weasel, a_player_team ) {
	level endon( "showdown_over" );
	wait 10;
	a_players = ArrayCopy( a_player_team );
	player = a_players[ RandomIntRange( 0, a_players.size ) ];
	ArrayRemoveValue( a_players, player );
	if ( a_players.size > 0 ) {
		player_2 = a_players[ RandomIntRange( 0, a_players.size ) ];
	}
	if ( isdefined( player ) ) {
		player final_battle_reveal();
	}
	wait 3;
	if ( isdefined( p_weasel ) ) {
		p_weasel PlaySoundOnTag( "vox_plr_3_end_scenario_0", "J_Head" );
	}
	wait 1;
	foreach(player in a_player_team) {
		level thread final_showdown_create_icon( player, p_weasel );
		level thread final_showdown_create_icon( p_weasel, player );
	}
	wait 10;
	if ( isdefined( player_2 ) ) {
		player_2 PlaySoundOnTag( "vox_plr_" + player_2.characterindex + "_end_scenario_1", "J_Head" );
	}
	else {
		if ( isdefined( player ) ) {
			player PlaySoundOnTag( "vox_plr_" + player.characterindex + "_end_scenario_1", "J_Head" );
		}
	}
	wait 4;
	if ( isdefined( p_weasel ) ) {
		p_weasel PlaySoundOnTag( "vox_plr_3_end_scenario_1", "J_Head" );
		p_weasel.dontspeak = 0;
	}
	foreach(player in a_player_team) {
		player.dontspeak = 0;
	}
}

function final_battle_reveal() {
	self endon( "death_or_disconnect" );
	self PlaySoundWithNotify( "vox_plr_" + self.characterindex + "_end_scenario_0", "showdown_icon_reveal" );
	self waittill( "showdown_icon_reveal" );
}

function player_intermission_bridge() {
	//self CloseMenu();
	self CloseInGameMenu();
	level endon( "stop_intermission" );
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "_zombie_game_over" );
	self.score = self.score_total;
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = struct::get_array( "final_cam", "targetname" );
	if ( !isdefined( points ) || points.size == 0 ) {
		points = GetEntArray( "info_intermission", "classname" );
		if ( points.size < 1 ) {
			return;
		}
	}
	self.game_over_bg = NewClientHudElem( self );
	self.game_over_bg.horzalign = "fullscreen";
	self.game_over_bg.vertalign = "fullscreen";
	self.game_over_bg SetShader( "black", 640, 480 );
	self.game_over_bg.alpha = 1;
	org = undefined;
	while ( 1 ) {
		points = array::randomize( points );
		i = 0;
		while ( i < points.size ) {
			point = points[ i ];
			if ( !isdefined( org ) ) {
				self Spawn( point.origin, point.angles );
			}
			if ( isdefined( points[ i ].target ) ) {
				if ( !isdefined( org ) ) {
					org = Spawn( "script_model", self.origin + vectorScale( ( 1, 1, 1 ), 60 ) );
					org SetModel( "tag_origin" );
				}
				org.origin = points[ i ].origin;
				org.angles = points[ i ].angles;
				foreach(player in GetPlayers()) {
					player CameraSetPosition( org );
					player CameraSetLookAt();
					player CameraActivate( 1 );
				}
				speed = 20;
				if ( isdefined( points[ i ].speed ) ) {
					speed = points[ i ].speed;
				}
				target_point = struct::get( points[ i ].target, "targetname" );
				dist = Distance( points[ i ].origin, target_point.origin );
				time = dist / speed;
				q_time = time * 0.25;
				if ( q_time > 1 ) {
					q_time = 1;
				}
				self.game_over_bg FadeOverTime( q_time );
				self.game_over_bg.alpha = 0;
				org MoveTo( target_point.origin, time, q_time, q_time );
				org RotateTo( target_point.angles, time, q_time, q_time );
				wait ( time - q_time );
				self.game_over_bg FadeOverTime( q_time );
				self.game_over_bg.alpha = 1;
				wait q_time;
			}
			else {
				self.game_over_bg FadeOverTime( 1 );
				self.game_over_bg.alpha = 0;
				wait 5;
				self.game_over_bg thread zm::fade_up_over_time( 1 );
			}
			i++;
		}
		wait 0.05;
	}
}

function create_ending_message( str_msg ) {
	if ( !isdefined( self.client_hint ) ) {
		self.client_hint = NewClientHudElem( self );
		self.client_hint.alignx = "center";
		self.client_hint.aligny = "middle";
		self.client_hint.horzalign = "center";
		self.client_hint.vertalign = "bottom";
		if ( self IsSplitScreen() ) {
			self.client_hint.y = -140;
		}
		else {
			self.client_hint.y = -250;
		}
		self.client_hint.foreground = 1;
		self.client_hint.font = "default";
		self.client_hint.fontscale = 50;
		self.client_hint.alpha = 1;
		self.client_hint.foreground = 1;
		self.client_hint.hidewheninmenu = 1;
		self.client_hint.color = ( 1, 1, 1 );
	}
	self.client_hint SetText( str_msg );
}

function custom_game_over_hud_elem( player ) {
	game_over = NewClientHudElem( player );
	game_over.alignx = "center";
	game_over.aligny = "middle";
	game_over.horzalign = "center";
	game_over.vertalign = "middle";
	game_over.y -= 130;
	game_over.foreground = 1;
	game_over.fontscale = 3;
	game_over.alpha = 0;
	game_over.color = ( 1, 1, 1 );
	game_over.hidewheninmenu = 1;
	if ( isdefined( level.winner ) ) {
		game_over SetText( &"ZM_PRISON_LIFE_OVER" );
	}
	else {
		game_over SetText( &"ZOMBIE_GAME_OVER" );
	}
	game_over FadeOverTime( 1 );
	game_over.alpha = 1;
	if ( player IsSplitScreen() ) {
		game_over.fontscale = 2;
		game_over.y += 40;
	}
	return game_over;
}

function clean_up_final_brutuses() {
	while ( 1 ) {
		zombies = GetAISpeciesArray( "axis", "all" );
		i = 0;
		while ( i < zombies.size ) {
			zombies[ i ] DoDamage( 10000, zombies[ i ].origin );
			i++;
		}
		wait 1;
	}
}


