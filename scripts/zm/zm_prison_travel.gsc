
#using scripts\zm\_zm_score;
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\array_shared;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;

#using scripts\zm\zm_alcatraz_amb;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_laststand.gsh;

#precache("model", "p6_zm_al_gondola_frame_light_red");
#precache("model", "p6_zm_al_gondola_frame_light_green");
#precache("model", "fxanim_zom_al_gondola_chains_mod");

#precache("fx", "custom/jerri/gondola/gondola_light");

#using_animtree("generic");

function autoexec init()
{
	level thread gondola_hostmigration();
	level.player_intersection_tracker_override = &zombie_alcatraz_player_intersection_tracker_override;
	level flag::init( "gondola_at_roof" );
	level flag::init( "gondola_at_docks" );
	level flag::init( "gondola_in_motion" );
	level flag::init( "gondola_initialized" );
	level._effect["light_gondola"]	= "custom/jerri/gondola/gondola_light";
	e_gondola = GetEnt( "zipline_gondola", "targetname" );
	level.e_gondola = e_gondola;
	e_gondola.location = "roof";
	e_gondola.destination = undefined;
	e_gondola SetMovingPlatformEnabled( 1 );
	light_link = Spawn("script_model", e_gondola GetTagOrigin("tag_origin"));
	light_link.angles = (90,0,0);
	light_link SetModel("tag_origin");
	light_link LinkTo(e_gondola);
	PlayFXOnTag( level._effect[ "light_gondola" ], light_link, "tag_origin" );
	level flag::set( "gondola_at_roof" );
	level.e_gondola.t_ride = GetEnt( "gondola_ride_trigger", "targetname" );
	level.e_gondola.t_ride EnableLinkTo();
	level.e_gondola.t_ride LinkTo( e_gondola );
	t_move_triggers = GetEntArray( "gondola_move_trigger", "targetname" );
	t_call_triggers = GetEntArray( "gondola_call_trigger", "targetname" );
	a_t_gondola_triggers = ArrayCombine( t_move_triggers, t_call_triggers, 1, 0 );
	foreach(trigger in a_t_gondola_triggers)
	{
		trigger SetHintString( "Requires Power" );
		trigger SetCursorHint( "HINT_NOICON" );
	}
	a_gondola_doors = GetEntArray( "gondola_doors", "targetname" );
	foreach(m_door in a_gondola_doors)
	{
		m_door LinkTo( e_gondola );
		e_gondola establish_gondola_door_definition( m_door );
		m_door SetMovingPlatformEnabled( 1 );
	}
	a_gondola_gates = GetEntArray( "gondola_gates", "targetname" );
	foreach(m_gate in a_gondola_gates)
	{
		m_gate linkto( e_gondola );
		e_gondola establish_gondola_gate_definition( m_gate );
		m_gate SetMovingPlatformEnabled( 1 );
	}
	a_gondola_landing_doors = GetEntArray( "gondola_landing_doors", "targetname" );
	foreach(m_door in a_gondola_landing_doors)
	{
		e_gondola establish_gondola_landing_door_definition( m_door );
	}
	a_gondola_landing_gates = GetEntArray( "gondola_landing_gates", "targetname" );
	foreach(m_gate in a_gondola_landing_gates)
	{
		e_gondola establish_gondola_landing_gate_definition( m_gate );
	}
	m_chains = Spawn( "script_model", level.e_gondola.origin );
	m_chains.origin = level.e_gondola.origin;
	m_chains.angles = level.e_gondola.angles;
	m_chains SetModel( "fxanim_zom_al_gondola_chains_mod" );
	m_chains LinkTo( level.e_gondola );
	a_gondola_nodes = GetNodeArray("gondola_pathnode","targetname");
	foreach(node in a_gondola_nodes)
	{
		node LinkTo(e_gondola);
	}
	level.e_gondola.fxanim_chains = m_chains;
	level.gondola_chains_fxanims = [];
	level.gondola_chains_fxanims[ "gondola_chains_start" ] = %fxanim_zom_al_gondola_chains_start_anim;
	level.gondola_chains_fxanims[ "gondola_chains_idle" ] = %fxanim_zom_al_gondola_chains_idle_anim;
	level.gondola_chains_fxanims[ "gondola_chains_end" ] = %fxanim_zom_al_gondola_chains_end_anim;
	
	gondola_lights_red();
	str_notify = level util::waittill_any_array_return( array( "gondola_powered_on_roof", "gondola_powered_on_docks" ) );
	if ( str_notify == "gondola_powered_on_roof" )
	{
		level thread turn_off_opposite_side_gondola_shockbox( "gondola_powered_on_docks" );
		e_gondola gondola_doors_move( "roof", 1 );
	}
	else
	{
		if ( str_notify == "gondola_powered_on_docks" )
		{
			level thread turn_off_opposite_side_gondola_shockbox( "gondola_powered_on_roof" );
			move_gondola( 1 );
		}
	}
	level flag::set( "gondola_initialized" );
	gondola_lights_green();
	array::thread_all( t_move_triggers, &zipline_move_trigger_think );
	array::thread_all( t_call_triggers, &zipline_call_trigger_think );
}

function zipline_call_trigger_think()
{
	level endon( "interrupt_gondola_call_trigger_" + self.script_string );
	self.cost = 0;
	self.in_use = 0;
	self.is_available = 1;
	e_gondola = level.e_gondola;
	if ( self.script_string == "roof" )
	{
		str_gondola_loc = "docks";
	}
	else
	{
		if ( self.script_string == "docks" )
		{
			str_gondola_loc = "roof";
		}
	}
	while ( 1 )
	{
		self SetHintString( "" );
		level flag::wait_till( "gondola_at_" + str_gondola_loc );
		self notify( "available" );
		self SetHintString( "Press ^3&&1^7 to call gondola" );
		self waittill( "trigger", who );
		if ( who zm_utility::in_revive_trigger() )
		{
			wait 0.05;
			continue;
		}
		if ( !isdefined( self.is_available ) )
		{
			wait 0.05;
			continue;
		}
		if ( zm_utility::is_player_valid( who ) )
		{
			if ( !self.in_use )
			{
				self.in_use = 1;
				if ( self.script_string == "roof" )
				{
					level notify( "interrupt_gondola_move_trigger_docks" );
					str_loc = "docks";
				}
				else
				{
					if ( self.script_string == "docks" )
					{
						level notify( "interrupt_gondola_move_trigger_roof" );
						str_loc = "roof";
					}
				}
				a_t_trig = GetEntArray( "gondola_move_trigger", "targetname" );
				foreach(trigger in a_t_trig)
				{
					if ( trigger.script_string == str_loc )
					{
						t_opposite_move_trigger = trigger;
						break;
					}
				}
				self PlaySound( "zmb_trap_activate" );
				move_gondola();
				t_opposite_move_trigger thread zipline_move_trigger_think();
				self.in_use = 0;
				self PlaySound( "zmb_trap_available" );
				self.is_available = 1;
			}
		}
	}
}

function turn_off_opposite_side_gondola_shockbox( str_notify_opposite )
{
	a_e_afterlife_interacts = GetEntArray( "afterlife_interact", "targetname" );
	foreach(shockbox in a_e_afterlife_interacts)
	{
		if ( isdefined( shockbox.script_string ) )
		{
			if ( shockbox.script_string == str_notify_opposite )
			{
				shockbox notify( "damage" , 500 , level );
			}
		}
	}
}

function gondola_lights_red()
{
	a_m_gondola_lights = GetEntArray( "gondola_state_light", "targetname" );
	_a845 = a_m_gondola_lights;
	_k845 = GetFirstArrayKey( _a845 );
	while ( isDefined( _k845 ) )
	{
		model = _a845[ _k845 ];
		model SetModel( "p6_zm_al_gondola_frame_light_red" );
		util::wait_network_frame();
		_k845 = GetNextArrayKey( _a845, _k845 );
	}
}

function gondola_lights_green()
{
	a_m_gondola_lights = GetEntArray( "gondola_state_light", "targetname" );
	_a857 = a_m_gondola_lights;
	_k857 = GetFirstArrayKey( _a857 );
	while ( isDefined( _k857 ) )
	{
		model = _a857[ _k857 ];
		model SetModel( "p6_zm_al_gondola_frame_light_green" );
		util::wait_network_frame();
		_k857 = GetNextArrayKey( _a857, _k857 );
	}
}


function establish_gondola_door_definition( m_door )
{
	str_identifier = m_door.script_noteworthy;
	switch( str_identifier )
	{
		case "roof left":
			self.door_roof_left = m_door;
			break;
		case "roof right":
			self.door_roof_right = m_door;
			break;
		case "docks left":
			self.door_docks_left = m_door;
			break;
		case "docks right":
			self.door_docks_right = m_door;
			break;
	}
}

function establish_gondola_gate_definition( m_gate )
{
	str_identifier = m_gate.script_noteworthy;
	switch( str_identifier )
	{
		case "roof left":
			self.gate_roof_left = m_gate;
			break;
		case "roof right":
			self.gate_roof_right = m_gate;
			break;
		case "docks left":
			self.gate_docks_left = m_gate;
			break;
		case "docks right":
			self.gate_docks_right = m_gate;
			break;
	}
}

function establish_gondola_landing_door_definition( m_door )
{
	str_identifier = m_door.script_noteworthy;
	switch( str_identifier )
	{
		case "roof left":
			self.landing_door_roof_left = m_door;
			break;
		case "roof right":
			self.landing_door_roof_right = m_door;
			break;
		case "docks left":
			self.landing_door_docks_left = m_door;
			break;
		case "docks right":
			self.landing_door_docks_right = m_door;
			break;
	}
}

function establish_gondola_landing_gate_definition( m_gate )
{
	str_identifier = m_gate.script_noteworthy;
	switch( str_identifier )
	{
		case "roof left":
			self.landing_gate_roof_left = m_gate;
			break;
		case "roof right":
			self.landing_gate_roof_right = m_gate;
			break;
		case "docks left":
			self.landing_gate_docks_left = m_gate;
			break;
		case "docks right":
			self.landing_gate_docks_right = m_gate;
			break;
	}
}

function zipline_move_trigger_think()
{
	level endon( "interrupt_gondola_move_trigger_" + self.script_string );
	self.cost = 750;
	self.in_use = 0;
	self.is_available = 1;
	self SetHintString( "" );
	while ( 1 )
	{
		level flag::wait_till( "gondola_at_" + self.script_string );
		self SetHintString( "Press ^3&&1^7 to use Gondola [Cost: "+self.cost+"]" );
		self waittill( "trigger", who );
		if ( who zm_utility::in_revive_trigger() )
		{
			wait 0.05;
			continue;
		} 
		if ( !isDefined( self.is_available ) )
		{
			wait 0.05;
			continue;
		}
		if ( zm_utility::is_player_valid( who ) )
		{
			if ( who.score >= self.cost )
			{
				if ( !self.in_use )
				{
					self.in_use = 1;
					self.is_available = undefined;
					PlaySoundAtPosition( "purchase", who.origin );
					who zm_score::minus_to_player_score( self.cost );
					if ( self.script_string == "roof" )
					{
						level notify( "interrupt_gondola_call_trigger_docks" );
						str_loc = "docks";
					}
					else
					{
						if ( self.script_string == "docks" )
						{
							level notify( "interrupt_gondola_call_trigger_roof" );
							str_loc = "roof";
						}
					}
					a_t_trig = GetEntArray( "gondola_call_trigger", "targetname" );
					_a298 = a_t_trig;
					_k298 = GetFirstArrayKey( _a298 );
					while ( isDefined( _k298 ) )
					{
						trigger = _a298[ _k298 ];
						if ( trigger.script_string == str_loc )
						{
							t_opposite_call_trigger = trigger;
							break;
						}
						else
						{
							_k298 = GetNextArrayKey( _a298, _k298 );
						}
					}
					move_gondola();
					t_opposite_call_trigger thread zipline_call_trigger_think();
					t_opposite_call_trigger PlaySound( "zmb_trap_available" );
					self.in_use = 0;
					self.is_available = 1;
				}
			}
		}
	}
}

function move_gondola( b_suppress_doors_close )
{
	if ( !isDefined( b_suppress_doors_close ) )
	{
		b_suppress_doors_close = 0;
	}
	//level util::clientnotify( "sndGS" );
	gondola_lights_red();
	e_gondola = level.e_gondola;
	t_ride = level.e_gondola.t_ride;
	e_gondola.is_moving = 1;
	if ( e_gondola.location == "roof" )
	{
		s_moveloc = GetEnt( "gondola_struct_docks", "targetname" );
		e_gondola.destination = "docks";
	}
	else
	{
		if ( e_gondola.location == "docks" )
		{
			s_moveloc = GetEnt( "gondola_struct_roof", "targetname" );
			e_gondola.destination = "roof";
		}
	}
	if ( level flag::get( "gondola_initialized" ) )
	{
		level flag::set( "gondola_roof_zone" );
		level flag::set( "upper_docks_zone" );
		level flag::set( "gondola_ride_zone_enabled" );
	}
	level flag::clear( "gondola_at_" + e_gondola.location );
	if ( isDefined( b_suppress_doors_close ) && !b_suppress_doors_close )
	{
		e_gondola gondola_doors_move( e_gondola.location, -1 );
	}
	level notify( "gondola_moving" );
	a_t_move = GetEntArray( "gondola_move_trigger", "targetname" );
	_a455 = a_t_move;
	_k455 = GetFirstArrayKey( _a455 );
	while ( isDefined( _k455 ) )
	{
		trigger = _a455[ _k455 ];
		trigger SetHintString( "" );
		_k455 = GetNextArrayKey( _a455, _k455 );
	}
	a_t_call = GetEntArray( "gondola_call_trigger", "targetname" );
	_a461 = a_t_call;
	_k461 = GetFirstArrayKey( _a461 );
	while ( isDefined( _k461 ) )
	{
		trigger = _a461[ _k461 ];
		trigger SetHintString( "Gondola active" );
		_k461 = GetNextArrayKey( _a461, _k461 );
	}
	check_when_gondola_moves_if_groundent_is_undefined( e_gondola );
	a_players = GetPlayers();
	_a472 = a_players;
	_k472 = GetFirstArrayKey( _a472 );
	while ( isDefined( _k472 ) )
	{
		player = _a472[ _k472 ];
		if ( player is_player_on_gondola() )
		{
			//player clientfield::set_to_player( "rumble_gondola", 1 );
			player thread check_for_death_on_gondola( e_gondola );
			player.is_on_gondola = 1;
			level thread zm_alcatraz_amb::sndplaystinger( "gondola", player );
		}
		if ( isdefined( player.e_afterlife_corpse ) && player.e_afterlife_corpse IsTouching( t_ride ) )
		{
			player.e_afterlife_corpse thread link_corpses_to_gondola( e_gondola );
		}
		_k472 = GetNextArrayKey( _a472, _k472 );
	}
	e_gondola thread create_gondola_poi();
	level thread gondola_moving_vo();
	e_gondola thread gondola_physics_explosion( 10 );
	e_gondola MoveTo( s_moveloc.origin, 10, 1, 1 );
	level flag::set( "gondola_in_motion" );
	level.gondola_in_motion = true;
	e_gondola thread gondola_chain_fx_anim();
	e_gondola PlaySound( "zmb_gondola_start" );
	e_gondola PlayLoopSound( "zmb_gondola_loop", 1 );
	e_gondola waittill( "movedone" );
	all_players_on_gondola = true;
	players = GetPlayers();
	foreach(player in players)
	{
		if ( isdefined( player ) && player.sessionstate == "spectator" || !player.is_on_gondola )
		{
			all_players_on_gondola = false;
		}
	}
	if(all_players_on_gondola)
	{
		old_zombie_count = zombie_utility::get_current_zombie_count();
		zombies = GetAISpeciesArray( "axis", "all" );
		for(i = 0; i < zombies.size; i++)
		{
			if(isdefined(zombies[i].is_brutus) && zombies[i].is_brutus)
			{

			}
			else
			{
				zombies[i] DoDamage(zombies[i].health + 666, (0, 0, 0));
			}	
		}
		level.zombie_total += old_zombie_count;
	}
	level flag::clear( "gondola_in_motion" );
	level.gondola_in_motion = false;
	e_gondola StopLoopSound( 0.5 );
	e_gondola thread sndcooldown();
	e_gondola PlaySound( "zmb_gondola_stop" );
	//player_escaped_gondola_failsafe();
	a_players = GetPlayers();
	_a517 = a_players;
	_k517 = GetFirstArrayKey( _a517 );
	while ( isdefined( _k517 ) )
	{
		player = _a517[ _k517 ];
		if ( isDefined( player.is_on_gondola ) && player.is_on_gondola )
		{
			//player clientfield::set_to_player( "rumble_gondola", 0 );
			player.is_on_gondola = 0;
		}
		_k517 = GetNextArrayKey( _a517, _k517 );
	}
	e_gondola gondola_doors_move( e_gondola.destination, 1 );
	e_gondola.is_moving = 0;
	e_gondola thread tear_down_gondola_poi();
	wait 1;
	//level util::clientnotify( "sndGE" );
	if ( e_gondola.location == "roof" )
	{
		e_gondola.location = "docks";
		str_zone = "upper_docks_zone";
	}
	else
	{
		if ( e_gondola.location == "docks" )
		{
			e_gondola.location = "roof";
			str_zone = "gondola_roof_zone";
		}
	}
	level notify( "gondola_arrived", str_zone );
	gondola_cooldown();
	level flag::set( "gondola_at_" + e_gondola.location );
	level notify ( "gondola_at_" + e_gondola.location );
}

function gondola_moving_vo()
{
	if ( isdefined( level.custom_gondola_moving_vo_func ) )
	{
		self thread [[ level.custom_gondola_moving_vo_func ]]();
		return;
	}
	a_players = array_players_on_gondola();
	if ( a_players.size > 0 )
	{
		a_players = array::randomize( a_players );
		a_players[ 0 ] thread zm_utility::do_player_general_vox( "general", "use_gondola" );
	}
}

function array_players_on_gondola()
{
	a_players_on_gondola = [];
	a_players = GetPlayers();
	_a885 = a_players;
	_k885 = GetFirstArrayKey( _a885 );
	while ( isdefined( _k885 ) )
	{
		player = _a885[ _k885 ];
		if ( player is_player_on_gondola() )
		{
			a_players_on_gondola[ a_players_on_gondola.size ] = player;
		}
		_k885 = GetNextArrayKey( _a885, _k885 );
	}
	return a_players_on_gondola;
}

function check_for_death_on_gondola( e_gondola )
{
	self endon( "disconnect" );
	self endon( "afterlife_bleedout" );
	e_gondola endon( "movedone" );
	self waittill( "player_fake_corpse_created" );
	self.e_afterlife_corpse endon( "player_revived" );
	self.e_afterlife_corpse LinkTo( e_gondola );
}

function link_corpses_to_gondola( e_gondola )
{
	e_gondola endon( "movedone" );
	if ( isdefined( self ) )
	{
		self LinkTo( e_gondola );
	}
}

function gondola_doors_move( str_side, n_state )
{
	if ( str_side == "roof" )
	{
		m_door_left = self.door_roof_left;
		m_gate_left = self.gate_roof_left;
		m_door_right = self.door_roof_right;
		m_gate_right = self.gate_roof_right;
		m_landing_door_left = self.landing_door_roof_left;
		m_landing_gate_left = self.landing_gate_roof_left;
		m_landing_door_right = self.landing_door_roof_right;
		m_landing_gate_right = self.landing_gate_roof_right;
		n_side_modifier = 1;
	}
	else
	{
		if ( str_side == "docks" )
		{
			m_door_left = self.door_docks_left;
			m_gate_left = self.gate_docks_left;
			m_door_right = self.door_docks_right;
			m_gate_right = self.gate_docks_right;
			m_landing_door_left = self.landing_door_docks_left;
			m_landing_gate_left = self.landing_gate_docks_left;
			m_landing_door_right = self.landing_door_docks_right;
			m_landing_gate_right = self.landing_gate_docks_right;
			n_side_modifier = -1;
		}
	}
	a_doors_and_gates = [];
	a_doors_and_gates[ 0 ] = m_door_left;
	a_doors_and_gates[ 1 ] = m_gate_left;
	a_doors_and_gates[ 2 ] = m_door_right;
	a_doors_and_gates[ 3 ] = m_gate_right;
	a_landing_doors_and_gates = [];
	a_landing_doors_and_gates[ 0 ] = m_landing_door_left;
	a_landing_doors_and_gates[ 1 ] = m_landing_gate_left;
	a_landing_doors_and_gates[ 2 ] = m_landing_door_right;
	a_landing_doors_and_gates[ 3 ] = m_landing_gate_right;
	foreach(m_model in a_doors_and_gates)
	{
		m_model Unlink();
	}
	m_door_left PlaySound( "zmb_gondola_door" );
	if ( n_state == 1 )
	{
		gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right );
		gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right );
		if ( n_side_modifier == 1 )
		{
			top_node_r = GetNode( "nd_gond_top_r", "targetname" );
			top_node_r node_add_connection( GetNode( "nd_on_top_r", "targetname" ) );
		}
		else
		{
			bottom_node_r = GetNode( "nd_gond_bottom_r", "targetname" );
			bottom_node_r node_add_connection( GetNode( "nd_on_bottom_r", "targetname" ) );
		}
	}
	else
	{
		gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right );
		gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right );
		if ( n_side_modifier == 1 )
		{
			top_node_r = GetNode( "nd_gond_top_r", "targetname" );
			top_node_r node_disconnect_from_path();
		}
		else
		{
			bottom_node_r = GetNode( "nd_gond_bottom_r", "targetname" );
			bottom_node_r node_disconnect_from_path();
		}
	}
	foreach(m_model in a_doors_and_gates)
	{
		m_model LinkTo( self );
		/*if( n_state == 1 )
		{
			m_model ConnectPaths();	
		}
		else
		{
			m_model DisconnectPaths();
		}*/
	}
	/*foreach(m_model in a_landing_doors_and_gates)
	{
		if( n_state == 1 )
		{
			m_model ConnectPaths();	
		}
		else
		{
			m_model DisconnectPaths();
		}
	}
	if( n_state == 1 )
	{
		level.e_gondola ConnectPaths();	
	}
	else
	{
		level.e_gondola DisconnectPaths();
	}*/
}

function gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right )
{
	m_gate_left MoveTo( m_gate_left.origin + ( 22.5 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_gate_right MoveTo( m_gate_right.origin + ( 22.5 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_gate_left MoveTo( m_landing_gate_left.origin + ( 22.5 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_gate_right MoveTo( m_landing_gate_right.origin + ( 22.5 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_gate_right waittill( "movedone" );
}

function gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right )
{
	m_door_left MoveTo( m_door_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_gate_left MoveTo( m_gate_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_door_right MoveTo( m_door_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_gate_right MoveTo( m_gate_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_door_left MoveTo( m_landing_door_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_gate_left MoveTo( m_landing_gate_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_door_right MoveTo( m_landing_door_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_landing_gate_right MoveTo( m_landing_gate_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
	m_gate_right waittill( "movedone" );
}

function gondola_physics_explosion( n_move_time )
{
	self endon( "movedone" );
	i = 0;
	while ( i < 2 )
	{
		PhysicsExplosionSphere( self.origin, 1000, 0.1, 0.1 );
		wait ( n_move_time / 2 );
		i++;
	}
}

function gondola_chain_fx_anim()
{
	m_chains = self.fxanim_chains;
	m_chains UseAnimTree( #animtree );
	n_start_time = GetAnimLength( level.gondola_chains_fxanims[ "gondola_chains_start" ] );
	n_idle_time = GetAnimLength( level.gondola_chains_fxanims[ "gondola_chains_idle" ] );
	m_chains AnimScripted( "optionalNotify", m_chains.origin , m_chains.angles, level.gondola_chains_fxanims[ "gondola_chains_start" ]);
	wait n_start_time;
	m_chains AnimScripted( "optionalNotify", m_chains.origin , m_chains.angles, level.gondola_chains_fxanims[ "gondola_chains_idle" ]);
	while ( level flag::get( "gondola_in_motion" ) )
	{
		wait n_idle_time;
	}
	m_chains AnimScripted( "optionalNotify", m_chains.origin , m_chains.angles, level.gondola_chains_fxanims[ "gondola_chains_end" ]);
}

function sndcooldown()
{
	self PlaySound( "zmb_gond_pwr_dn" );
	self PlayLoopSound( "zmb_gondola_cooldown_lp", 1 );
	wait 10;
	wait 3.5;
	self StopLoopSound( 0.5 );
	self PlaySound( "zmb_gond_pwr_on" );
}

function create_gondola_poi()
{
	foreach(player in GetPlayers())
	{
		if ( isdefined( player.is_on_gondola ) && !player.is_on_gondola )
		{
			return;
		}
	}
	s_poi = GetEnt( "gondola_poi_" + self.destination, "targetname" );
	e_poi = Spawn( "script_origin", s_poi.origin );
	e_poi zm_utility::create_zombie_point_of_interest( 10000, 30, 5000, 1 );
	e_poi thread zm_utility::create_zombie_point_of_interest_attractor_positions();
	self.poi = e_poi;
}

function tear_down_gondola_poi()
{
	if ( isDefined( self.poi ) )
	{
		zm_utility::remove_poi_attractor( self.poi );
		self.poi Delete();
	}
}

function check_when_gondola_moves_if_groundent_is_undefined( e_gondola )
{
	wait 1;
	a_zombies = GetAIArray( level.zombie_team );
	a_zombies = util::get_array_of_closest( e_gondola.origin, a_zombies );
	i = 0;
	while ( i < a_zombies.size )
	{
		if ( DistanceSquared( e_gondola.origin, a_zombies[ i ].origin ) < 90000 )
		{
			ground_ent = a_zombies[ i ] GetGroundEnt();
			if ( !isdefined( ground_ent ) )
			{
				a_zombies[ i ] DoDamage( a_zombies[ i ].health + 1000, a_zombies[ i ].origin );
			}
		}
		i++;
	}
}

function gondola_cooldown()
{
	a_t_call = GetEntArray( "gondola_call_trigger", "targetname" );
	foreach(trigger in a_t_call)
	{
		trigger SetHintString( "The Gondola is recharging" );
	}
	a_t_move = GetEntArray( "gondola_move_trigger", "targetname" );
	foreach(trigger in a_t_move)
	{
		trigger SetHintString( "The Gondola is recharging" );
	}
	wait 10;
	gondola_lights_green();
}

function link_player_to_gondola()
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( self ) )
	{
		return;
	}
	if ( self is_player_on_gondola() )
	{
		e_origin = Spawn( "script_origin", self.origin );
		e_origin.angles = self.angles;
		level.hm_link_origins[ level.hm_link_origins.size ] = e_origin;
		e_origin LinkTo( level.e_gondola );
		//IPrintLnBold("on gondola");
		self PlayerLinkTo( e_origin );
	}
}

function is_player_on_gondola()
{
	if ( IsPlayer( self ) )
	{
		if ( self IsTouching( level.e_gondola.t_ride ) )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
}

function gondola_hostmigration()
{
	level endon( "end_game" );
	level notify( "gondola_hostmigration" );
	level endon( "gondola_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_begin" );
		level.hm_link_origins = [];
		foreach(player in GetPlayers())
		{
			player thread link_player_to_gondola();
		}
		level waittill( "host_migration_end" );
		foreach(player in GetPlayers())
		{
			player Unlink();
		}
		foreach(e_origin in level.hm_link_origins)
		{
			e_origin Delete();
		}
	}
}

function get_gondola_doors_and_gates()
{
	if ( isdefined( level.e_gondola ) )
	{
		a_doors_gates = [];
		a_doors_gates[ 0 ] = level.e_gondola.door_roof_left;
		a_doors_gates[ 1 ] = level.e_gondola.door_roof_right;
		a_doors_gates[ 2 ] = level.e_gondola.door_docks_left;
		a_doors_gates[ 3 ] = level.e_gondola.door_docks_right;
		a_doors_gates[ 4 ] = level.e_gondola.gate_roof_left;
		a_doors_gates[ 5 ] = level.e_gondola.gate_roof_right;
		a_doors_gates[ 6 ] = level.e_gondola.gate_docks_left;
		a_doors_gates[ 7 ] = level.e_gondola.gate_docks_right;
		a_doors_gates[ 8 ] = level.e_gondola.landing_door_roof_left;
		a_doors_gates[ 9 ] = level.e_gondola.landing_door_roof_right;
		a_doors_gates[ 10 ] = level.e_gondola.landing_door_docks_left;
		a_doors_gates[ 11 ] = level.e_gondola.landing_door_docks_right;
		a_doors_gates[ 12 ] = level.e_gondola.landing_gate_roof_left;
		a_doors_gates[ 13 ] = level.e_gondola.landing_gate_roof_right;
		a_doors_gates[ 14 ] = level.e_gondola.landing_gate_docks_left;
		a_doors_gates[ 15 ] = level.e_gondola.landing_gate_docks_right;
		return a_doors_gates;
	}
}

function zombie_alcatraz_player_intersection_tracker_override( other_player )
{
	if ( isdefined( self.afterlife_revived ) || self.afterlife_revived && isdefined( other_player.afterlife_revived ) && other_player.afterlife_revived )
	{
		return 1;
	}
	if ( isdefined( self.is_on_gondola ) && self.is_on_gondola && isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
	{
		return 1;
	}
	if ( isdefined( other_player.is_on_gondola ) && other_player.is_on_gondola && isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
	{
		return 1;
	}
	return 0;
}

function player_escaped_gondola_failsafe()
{
	foreach(player in GetPlayers())
	{
		while ( isdefined( player.is_on_gondola ) && player.is_on_gondola )
		{
			while ( !player is_player_on_gondola() )
			{
				if ( isdefined( player.afterlife ) && !player.afterlife && IsAlive( player ) )
				{
					a_s_orgs = struct::get_array( "gondola_dropped_parts_" + level.e_gondola.destination, "targetname" );
					foreach(struct in a_s_orgs)
					{
						if ( !PositionWouldTelefrag( struct.origin ) )
						{
							player SetOrigin( struct.origin );
							break;
						}
					}
				}
			}
		}
	}
}

function node_add_connection( nd_node )
{
	if ( !NodesAreLinked( self, nd_node ) )
	{
		if ( !isdefined( self.a_node_path_connections ) )
		{
			self.a_node_path_connections = [];
		}
		zm_utility::link_nodes( self, nd_node );
		zm_utility::link_nodes( nd_node, self );
		self.a_node_path_connections[ self.a_node_path_connections.size ] = nd_node;
	}
}

function node_disconnect_from_path()
{
	if ( isdefined( self.a_node_path_connections ) )
	{
		i = 0;
		while ( i < self.a_node_path_connections.size )
		{
			nd_node = self.a_node_path_connections[ i ];
			zm_utility::unlink_nodes( self, nd_node );
			zm_utility::unlink_nodes( nd_node, self );
			i++;
		}
	}
	self.a_node_path_connections = undefined;
}