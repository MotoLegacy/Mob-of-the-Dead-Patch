#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\exploder_shared;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\_zm_ai_brutus;
#using scripts\zm\_zm_afterlife;

function setup_nixie_tubes_puzzle()
{
	level flag::init( "nixie_puzzle_completed" );
	level flag::init( "nixie_puzzle_solved" );
	level flag::init( "nixie_countdown_started" );
	level flag::init( "nixie_countdown_expired" );
	level flag::init( "nixie_ee_flashing" );
	level.a_nixie_tube_code = [];
	level.a_nixie_tube_solution = [];
	t_elevator_door = GetEnt( "nixie_elevator_door", "targetname" );
	t_elevator_door TriggerEnable(false);
	m_rigging = zm_craftables::get_craftable_piece_model( "plane", "rigging" );
	m_citadel_elevator = GetEnt( "rigging_link_thing", "script_noteworthy" );
	m_rigging LinkTo( m_citadel_elevator );
	level thread nixie_tube_notifier();
	m_citadel_elevator = GetEntArray( "citadel_elevator", "targetname" );
	door_clips = GetEntArray("cell_connecting_door","targetname");
	m_elevator_bottom_gate_l = GetEnt( "elevator_bottom_gate_l", "targetname" );
	clip = ArrayGetClosest( m_elevator_bottom_gate_l.origin, door_clips ); 
	clip Delete();
	foreach(model in m_citadel_elevator)
	{
		model MoveTo( model.origin + ( 0, 0, 700 ), 3, 1, 1 );
	}
	level thread nixie_tube_elevator_door();
	while ( !level flag::get( "nixie_puzzle_completed" ) )
	{
		generate_unrestricted_nixie_tube_solution();
		n_code = nixie_tube_add_code( level.a_nixie_tube_solution[ 1 ], level.a_nixie_tube_solution[ 2 ], level.a_nixie_tube_solution[ 3 ] );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
			m_nixie_tube thread nixie_tube_thread( i );
			m_nixie_clues = GetEntArray( "nixie_clue_" + i, "script_noteworthy" );
			foreach(m_nixie_clue in m_nixie_clues)
			{
				j = 0;
				while ( j < 10 )
				{
					m_nixie_clue HidePart( "J_" + j );
					j++;
				}
			}
			players = GetPlayers();
			_a76 = players;
			_k76 = GetFirstArrayKey( _a76 );
			while ( isdefined( _k76 ) )
			{
				player = _a76[ _k76 ];
				if ( isdefined( player ) && isdefined( player.afterlife ) && player.afterlife )
				{
					foreach(m_nixie_clue in m_nixie_clues)
					{
						m_nixie_clue SetVisibleToPlayer( player );
					}
				}
				_k76 = GetNextArrayKey( _a76, _k76 );
			}
			foreach(m_nixie_clue in m_nixie_clues)
			{
				m_nixie_clue ShowPart( "J_" + level.a_nixie_tube_solution[ i ] );
			}
			i++;
		}
		level waittill( "nixie_" + n_code );
		level flag::set( "nixie_puzzle_solved" );
		nixie_tube_remove_code( n_code );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_clues = GetEntArray( "nixie_clue_" + i, "script_noteworthy" );
			foreach(m_nixie_clue in m_nixie_clues)
			{
				m_nixie_clue SetInvisibleToAll();
			}
			i++;
		}
		nixie_tube_2 = GetEnt( "nixie_tube_2", "targetname" );
		nixie_tube_2 PlaySound( "zmb_quest_nixie_success" );
		level thread nixie_tube_elevator_drops();
		nixie_tube_win_effects_all_tubes( 0, 6, 0 );
		wait 0.5;
		n_countdown = 60;
		level thread sndnixietubecountdown( n_countdown );
		i = 1;
		while ( i < 4 )
		{
			m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
			level notify( "nixie_tube_trigger_" + i );
			m_nixie_tube thread nixie_tube_thread_play_countdown( i, n_countdown );
			i++;
		}
		level flag::set( "nixie_countdown_started" );
		level flag::wait_till( "nixie_countdown_expired" );
		if ( !level flag::get( "nixie_puzzle_completed" ) )
		{
			t_elevator_door = GetEnt( "nixie_elevator_door", "targetname" );
			t_elevator_door TriggerEnable(false);
			level flag::clear( "nixie_countdown_started" );
			level flag::clear( "nixie_countdown_expired" );
			level flag::clear( "nixie_puzzle_solved" );
			nixie_tube_elevator_rises();
		}
	}
	m_nixie_tube = GetEnt( "nixie_tube_2", "targetname" );
	m_nixie_tube PlaySound( "zmb_quest_nixie_success" );
/#
	IPrintLnBold( "nixie puzzle solved!" );
#/
	level flag::clear( "nixie_puzzle_solved" );
	array::delete_all( GetEntArray( "wires_nixie_elevator", "script_noteworthy" ) );
	exploder::stop_exploder( 3400 );
	exploder::stop_exploder( 3500 );
	exploder::stop_exploder( 3600 );
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
		//m_nixie_tube thread _zm_afterlife::afterlife_interact_object_think();
		m_nixie_tube thread nixie_tube_thread( i );
		i++;
	}
}

function generate_unrestricted_nixie_tube_solution()
{
	a_restricted_solutions = [];
	a_restricted_solutions[ 0 ] = 115;
	a_restricted_solutions[ 1 ] = 935;
	a_restricted_solutions[ 2 ] = 386;
	a_restricted_solutions[ 3 ] = 481;
	a_restricted_solutions[ 4 ] = 101;
	a_restricted_solutions[ 5 ] = 872;
	a_restricted_solutions[ 6 ] = 666;
	a_numbers = [];
	i = 0;
	while ( i < 10 )
	{
		a_numbers[ i ] = i;
		i++;
	}
	i = 1;
	while ( i < 4 )
	{
		n_index = RandomInt( a_numbers.size );
		level.a_nixie_tube_solution[ i ] = a_numbers[ n_index ];
		ArrayRemoveIndex( a_numbers, n_index );
		i++;
	}
	i = 0;
	while ( i < a_restricted_solutions.size )
	{
		b_is_restricted_solution = 1;
		restricted_solution = [];
		j = 1;
		while ( j < 4 )
		{
			restricted_solution[ j ] = get_split_number( j, a_restricted_solutions[ i ] );
			if ( restricted_solution[ j ] != level.a_nixie_tube_solution[ j ] )
			{
				b_is_restricted_solution = 0;
			}
			j++;
		}
		if ( b_is_restricted_solution )
		{
			n_index = RandomInt( a_numbers.size );
			level.a_nixie_tube_solution[ 3 ] = a_numbers[ n_index ];
		}
		i++;
	}
}

function nixie_tube_notifier()
{
	if ( !isdefined( level.a_important_codes ) )
	{
		level.a_important_codes = [];
		level.a_important_codes[ level.a_important_codes.size ] = 115;
		level.a_important_codes[ level.a_important_codes.size ] = 935;
		level.a_important_codes[ level.a_important_codes.size ] = 666;
	}
	level thread nixie_115();
	level thread nixie_935();
	level thread nixie_666();
	while ( !isdefined( level.a_nixie_tube_code ) || !isdefined( level.a_nixie_tube_code[ 3 ] ) )
	{
		wait 1;
	}
	while ( 1 )
	{
		codes_to_check = ArrayCopy( level.a_important_codes );
		non_array_value = ( level.a_nixie_tube_code[ 1 ] * 100 ) + ( level.a_nixie_tube_code[ 2 ] * 10 ) + level.a_nixie_tube_code[ 3 ];
		_a240 = codes_to_check;
		_k240 = GetFirstArrayKey( _a240 );
		while ( isdefined( _k240 ) )
		{
			code = _a240[ _k240 ];
			if ( code == non_array_value )
			{
				level notify( "nixie_" + code );
			}
			_k240 = GetNextArrayKey( _a240, _k240 );
		}
		wait 2;
	}
}

function nixie_tube_add_code( a, b, c )
{
	if ( isdefined( b ) )
	{
		non_array_value = ( a * 100 ) + ( b * 10 ) + c;
	}
	else
	{
		non_array_value = a;
	}
	level.a_important_codes[ level.a_important_codes.size ] = non_array_value;
	return non_array_value;
}

function nixie_tube_remove_code( a, b, c )
{
	if ( isDefined( b ) )
	{
		non_array_value = ( a * 100 ) + ( b * 10 ) + c;
	}
	else
	{
		non_array_value = a;
	}
	ArrayRemoveValue( level.a_important_codes, non_array_value );
}

function sndnixietubecountdown( num )
{
	level endon( "sndEndNixieCount" );
	ent = GetEnt( "nixie_tube_2", "targetname" );
	i = num;
	while ( i > 0 )
	{
		if ( i <= 10 )
		{
			ent PlaySound( "zmb_quest_nixie_count_final" );
		}
		else
		{
			ent PlaySound( "zmb_quest_nixie_count" );
		}
		wait 1;
		i--;

	}
	ent PlaySound( "zmb_quest_nixie_fail" );
}

function nixie_tube_thread( n_tube_index, b_force_reset )
{
	if ( !isdefined( b_force_reset ) )
	{
		b_force_reset = 1;
	}
	level endon( "kill_nixie_input" );
	if ( b_force_reset )
	{
		level.a_nixie_tube_code[ n_tube_index ] = 0;
	}
	self thread _zm_afterlife::afterlife_interact_object_think();
	i = 0;
	while ( i < 10 )
	{
		self HidePart( "J_off" );
		self HidePart( "J_" + i );
		i++;
	}
	self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
	while ( !level flag::get( "nixie_puzzle_solved" ) )
	{
		level waittill( "nixie_tube_trigger_" + n_tube_index );
		//IPrintLnBold("nixie triggerent");
		if ( level flag::get( "nixie_puzzle_solved" ) )
		{
			continue;
		}
		i = 0;
		while ( i < 10 )
		{
			self HidePart( "J_" + i );
			i++;
		}
		level.a_nixie_tube_code[ n_tube_index ]++;
		if ( level.a_nixie_tube_code[ n_tube_index ] > 9 )
		{
			level.a_nixie_tube_code[ n_tube_index ] = 0;
		}
		self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait 0.05;
		self notify( "afterlife_interact_reset" );
	}
}

function nixie_tube_win_effects( n_tube_index, n_blink_rate )
{
	if ( !isdefined( n_blink_rate ) )
	{
		n_blink_rate = 0.25;
	}
	while ( !level flag::get( "nixie_countdown_started" ) )
	{
		self HidePart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
		self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
	}
	self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
}

function nixie_tube_win_effects_all_tubes( goal_num_1, goal_num_2, goal_num_3 )
{
	if ( !isdefined( goal_num_1 ) )
	{
		goal_num_1 = 0;
	}
	if ( !isdefined( goal_num_2 ) )
	{
		goal_num_2 = 0;
	}
	if ( !isdefined( goal_num_3 ) )
	{
		goal_num_3 = 0;
	}
	a_nixie_tube = [];
	a_nixie_tube[ 1 ] = GetEnt( "nixie_tube_1", "targetname" );
	a_nixie_tube[ 2 ] = GetEnt( "nixie_tube_2", "targetname" );
	a_nixie_tube[ 3 ] = GetEnt( "nixie_tube_3", "targetname" );
	n_off_tube = 1;
	start_time = 0;
	while ( start_time < 3 )
	{
		i = 1;
		while ( i < ( 3 + 1 ) )
		{
			if ( i == n_off_tube )
			{
				a_nixie_tube[ i ] HidePart( "J_" + level.a_nixie_tube_code[ i ] );
				i++;
				continue;
			}
			else
			{
				a_nixie_tube[ i ] ShowPart( "J_" + level.a_nixie_tube_code[ i ] );
				if ( i == 1 || n_off_tube == 2 && i == 3 && n_off_tube == 1 )
				{
					a_nixie_tube[ i ] PlaySound( "zmb_quest_nixie_count" );
				}
			}
			i++;
		}
		n_off_tube++;
		if ( n_off_tube > 3 )
		{
			n_off_tube = 1;
		}
		util::wait_network_frame();
		start_time += 0.15;
	}
	a_nixie_tube[ 1 ] ShowPart( "J_" + level.a_nixie_tube_code[ 1 ] );
	a_nixie_tube[ 2 ] ShowPart( "J_" + level.a_nixie_tube_code[ 2 ] );
	a_nixie_tube[ 3 ] ShowPart( "J_" + level.a_nixie_tube_code[ 3 ] );
	while ( level.a_nixie_tube_code[ 1 ] != goal_num_1 || level.a_nixie_tube_code[ 2 ] != goal_num_2 && level.a_nixie_tube_code[ 3 ] != goal_num_3 )
	{
		n_current_tube = 1;
		n_goal = goal_num_1;
		if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_1 )
		{
			n_current_tube = 2;
			n_goal = goal_num_2;
			if ( level.a_nixie_tube_code[ n_current_tube ] == goal_num_2 )
			{
				n_current_tube = 3;
				n_goal = goal_num_3;
			}
		}
		j = 0;
		while ( j < 10 )
		{
			a_nixie_tube[ n_current_tube ] HidePart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			level.a_nixie_tube_code[ n_current_tube ]--;

			if ( level.a_nixie_tube_code[ n_current_tube ] == -1 )
			{
				level.a_nixie_tube_code[ n_current_tube ] = 9;
			}
			a_nixie_tube[ n_current_tube ] ShowPart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			if ( ( j % 3 ) == 0 )
			{
				a_nixie_tube[ n_current_tube ] PlaySound( "zmb_quest_nixie_count" );
			}
			wait 0.05;
			j++;
		}
		util::wait_network_frame();
		j = 0;
		while ( level.a_nixie_tube_code[ n_current_tube ] != n_goal )
		{
			a_nixie_tube[ n_current_tube ] HidePart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			level.a_nixie_tube_code[ n_current_tube ]--;

			if ( level.a_nixie_tube_code[ n_current_tube ] == -1 )
			{
				level.a_nixie_tube_code[ n_current_tube ] = 9;
			}
			a_nixie_tube[ n_current_tube ] ShowPart( "J_" + level.a_nixie_tube_code[ n_current_tube ] );
			if ( ( j % 3 ) == 0 )
			{
				a_nixie_tube[ n_current_tube ] PlaySound( "zmb_quest_nixie_count" );
			}
			j++;
			wait 0.05;
		}
	}
	a_nixie_tube[ 2 ] PlaySound( "zmb_quest_nixie_count_final" );
	util::wait_network_frame();
}

function nixie_tube_thread_play_countdown( n_tube_index, n_countdown )
{
	level endon( "end_nixie_countdown" );
	n_tick_duration = 1;
	level.a_nixie_tube_code[ n_tube_index ] = get_split_number( n_tube_index, n_countdown );
/#
	IPrintLnBold( "tube " + n_tube_index + " number is " + level.a_nixie_tube_code[ n_tube_index ] );
#/
	i = 0;
	while ( i < 10 )
	{
		self HidePart( "J_" + i );
		i++;
	}
	self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
	while ( n_countdown )
	{
		n_countdown--;

		self HidePart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		level.a_nixie_tube_code[ n_tube_index ] = get_split_number( n_tube_index, n_countdown );
		self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_tick_duration;
	}
	level flag::set( "nixie_countdown_expired" );
	wait 0.05;
	level flag::clear( "nixie_countdown_expired" );
}

function get_split_number( n_tube_index, n_countdown )
{
	if ( n_tube_index == 1 )
	{
		return ( n_countdown - ( n_countdown % 100 ) ) / 100;
	}
	if ( n_tube_index == 2 )
	{
		n_temp = n_countdown % 100;
		n_temp -= n_countdown % 10;
		n_temp /= 10;
		return n_temp;
	}
	if ( n_tube_index == 3 )
	{
		return n_countdown % 10;
	}
}

function nixie_tube_elevator_drops()
{
	n_elevator_drop_duration = 3;
	zm_alcatraz_sq::array_set_visible_to_all( GetEntArray( "generator_wires", "script_noteworthy" ), 0 );
	exploder::exploder( 3400 );
	exploder::exploder( 3500 );
	exploder::exploder( 3600 );
	m_citadel_elevator = GetEntArray( "citadel_elevator", "targetname" );
	m_rigging = zm_craftables::get_craftable_piece_model( "plane", "rigging" );
	PlayFXOnTag( level._effect[ "elevator_fall" ], m_rigging, "tag_origin" );
	m_rigging PlaySound( "zmb_quest_elevator_move" );
	foreach(model in m_citadel_elevator)
	{
		model MoveTo( model.origin - ( 0, 0, 700 ), n_elevator_drop_duration, 1, 1 );
	}
	wait n_elevator_drop_duration;
	t_elevator_door = GetEnt( "nixie_elevator_door", "targetname" );
	t_elevator_door TriggerEnable(true);
	foreach(model in m_citadel_elevator)
	{
		model ConnectPaths();
	}
}

function nixie_tube_elevator_rises()
{
	elevator_rise_duration = 3;
	zm_alcatraz_sq::array_set_visible_to_all( GetEntArray( "generator_wires", "script_noteworthy" ), 1 );
	exploder::stop_exploder( 3400 );
	exploder::stop_exploder( 3500 );
	exploder::stop_exploder( 3600 );
	m_citadel_elevator = GetEntArray( "citadel_elevator", "targetname" );
	foreach(model in m_citadel_elevator)
	{
		model MoveTo( model.origin + ( 0, 0, 700 ), elevator_rise_duration, 1, 1 );
	}
	m_citadel_elevator[0] PlaySound( "zmb_quest_elevator_move" );
	wait elevator_rise_duration;
}

function nixie_tube_elevator_door()
{
	t_elevator_door = GetEnt( "nixie_elevator_door", "targetname" );
	t_elevator_door SetHintString( "Press &&1 to open door" );
	t_elevator_door waittill( "trigger", e_triggerer );
	m_elevator_bottom_gate_l = GetEnt( "elevator_bottom_gate_l", "targetname" );
	m_elevator_bottom_gate_r = GetEnt( "elevator_bottom_gate_r", "targetname" );
	brushes_door_left = GetEntArray("elevator_bottom_gate_l_brushes", "targetname");
	foreach(brush in brushes_door_left)
	{
		brush LinkTo(m_elevator_bottom_gate_l);
	}
	brushes_door_right = GetEntArray("elevator_bottom_gate_r_brushes", "targetname");
	foreach(brush in brushes_door_right)
	{
		brush LinkTo(m_elevator_bottom_gate_r);
	}
	m_elevator_bottom_gate_l RotateYaw( -90, 0.5 );
	m_elevator_bottom_gate_r RotateYaw( 90, 0.5 );
	elevator_door_playerclip = GetEnt( "elevator_door_playerclip", "targetname" );
	elevator_door_playerclip Delete();
	level flag::set( "nixie_puzzle_completed" );
	level notify( "sndEndNixieCount" );
	level notify( "end_nixie_countdown" );
	level flag::set( "nixie_countdown_expired" );
	wait 0.05;
	level flag::clear( "nixie_countdown_expired" );
	t_elevator_door Delete();
}

function nixie_tube_win_effects_ee( n_tube_index )
{
	n_blink_rate = 0.25;
	while ( !level flag::get( "nixie_ee_flashing" ) )
	{
		self HidePart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
		self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
		wait n_blink_rate;
	}
	self ShowPart( "J_" + level.a_nixie_tube_code[ n_tube_index ] );
}

function nixie_115()
{
	level waittill( "nixie_" + 115 );
	level notify( "kill_nixie_input" );
	level flag::set( "nixie_puzzle_solved" );
	level flag::clear( "nixie_ee_flashing" );
	level thread nixie_115_audio();
	nixie_tube_win_effects_all_tubes( 6, 6, 6 );
	level flag::set( "nixie_ee_flashing" );
	level flag::clear( "nixie_puzzle_solved" );
	nixie_reset_control();
}

function nixie_115_audio()
{
	m_nixie_tube = GetEnt( "nixie_tube_1", "targetname" );
	n_random_line = RandomInt( 3 );
	m_nixie_tube PlaySoundWithNotify( "vox_brutus_scary_voice_" + n_random_line, "scary_voice" );
	m_nixie_tube waittill( "scary_voice" );
}

function nixie_935()
{
	level waittill( "nixie_" + 935 );
	level notify( "kill_nixie_input" );
	level flag::set( "nixie_puzzle_solved" );
	level flag::clear( "nixie_ee_flashing" );
	level thread nixie_935_audio();
	nixie_tube_win_effects_all_tubes( 7, 7, 7 );
	level flag::set( "nixie_ee_flashing" );
	level flag::clear( "nixie_puzzle_solved" );
	nixie_reset_control();
}

function nixie_666()
{
	level waittill( "nixie_" + 666 );
	level notify( "kill_nixie_input" );
	level flag::set( "nixie_puzzle_solved" );
	level flag::clear( "nixie_ee_flashing" );
	level thread zm_ai_brutus::brutusSpawnInZone( "tunnel_stairs_zone" ); //FIXME - 'tunnel_stairs_zone' has no effect
	nixie_tube_win_effects_all_tubes( 4, 2, 0 ); //FIXME - find real value
	level flag::set( "nixie_ee_flashing" );
	level flag::clear( "nixie_puzzle_solved" );
	nixie_reset_control();
}

function nixie_935_audio()
{
	/*if ( isdefined( level.music_override ) && !level.music_override )
	{
		level.music_override = 1;
		//fuck
		wait 140;
		level.music_override = 0;
	}
	else
	{
		m_nixie_tube = GetEnt( "nixie_tube_1", "targetname" );
		n_random_line = RandomInt( 3 );
		m_nixie_tube PlaySoundWithNotify( "vox_brutus_scary_voice_" + n_random_line, "scary_voice" );
		m_nixie_tube waittill( "scary_voice" );
	}*/
	foreach(player in GetPlayers())
    {
    	player PlaySoundToPlayer( "mus_zmb_secret_song_2", player );
    }
}

function nixie_reset_control( b_reset_control )
{
	i = 1;
	while ( i < 4 )
	{
		m_nixie_tube = GetEnt( "nixie_tube_" + i, "targetname" );
		m_nixie_tube thread _zm_afterlife::afterlife_interact_object_think();
		m_nixie_tube thread nixie_tube_thread( i, b_reset_control );
		i++;
	}
}
