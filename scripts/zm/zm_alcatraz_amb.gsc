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
#using scripts\shared\spawner_shared;
#using scripts\shared\hud_util_shared;

#using scripts\shared\visionset_mgr_shared;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_powerups;
#using scripts\zm\gametypes\_zm_gametype;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_perk_electric_cherry;

#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_alcatraz_sq_vo;
#using scripts\zm\zm_alcatraz_sq_nixie;
#using scripts\zm\zm_alcatraz_utility;
//#using scripts\zm\zm_prison_sq_final;
//#using scripts\zm\zm_prison_travel;

//#using scripts\zm\_zm_ai_brutus;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perks.gsh;

function autoexec main()
{
	level flag::wait_till( "initial_players_connected" );
	level.sndperksacolaloopoverride = &sndperksacolaloop;
	level.sndperksacolajingleoverride = &sndperksacolajingle;
	thread sndstingersetup();
	thread sndlastlifesetup();
	thread sndsetupendgamemusicstates();
	thread sndspectatorsetup();
	//thread sndmusicegg();
}

function sndspectatorsetup()
{
	level flag::wait_till( "initial_players_connected" );
	foreach(player in GetPlayers()) {
		player thread sndspectatorafterliferevert();
	}
}

function sndspectatorafterliferevert()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "spawned_spectator" );
		while ( self.sessionstate == "spectator" )
		{
			wait 1;
		}
		self util::clientnotify( "sndSR" );
	}
}

function sndsetupendgamemusicstates()
{
	level flag::wait_till( "start_zombie_round_logic" );
	//level thread maps/mp/zombies/_zm_audio::setupmusicstate( "game_over_final_good", "mus_zombie_game_over_final_good", 1, 0, undefined, "SILENCE" );
	//level thread maps/mp/zombies/_zm_audio::setupmusicstate( "game_over_final_bad", "mus_zombie_game_over_final_bad", 1, 0, undefined, "SILENCE" );
	//level thread maps/mp/zombies/_zm_audio::setupmusicstate( "game_over_nomove", "mus_zombie_game_over_nomove", 1, 0, undefined, "SILENCE" );
}

function sndperksacolajingle( perksacola )
{
	if ( !isdefined( self.jingle_is_playing ) )
	{
		self.jingle_is_playing = 0;
	}
	if ( !isdefined( self.script_sound ) )
	{
		return;
	}
	if ( !isdefined( self.sndent ) )
	{
		return;
	}
	if ( self.jingle_is_playing == 0 && level.music_override == 0 )
	{
		self.jingle_is_playing = 1;
		self.sndent StopLoopSound( 1 );
		self.sndent PlaySoundWithNotify( self.script_sound, "sndJingleDone" );
		self.sndent waittill( "sndJingleDone" );
		self.sndent PlayLoopSound( "mus_perks_loop", 1 );
		self.jingle_is_playing = 0;
	}
}

function sndperksacolaloop()
{
	self endon( "death" );
	self.sndent = Spawn( "script_origin", self.origin );
	self.sndent PlayLoopSound( "mus_perks_loop", 1 );
	while ( 1 )
	{
		wait RandomFloatRange( 31, 45 );
		if ( RandomInt( 100 ) < 15 )
		{
			self thread sndperksacolajingle();
		}
	}
}

function sndeventstingertriggers()
{
	level flag::wait_till( "start_zombie_round_logic" );
	triggers = GetEntArray( "sndMusicEventStinger", "targetname" );
	_a105 = triggers;
	_k105 = GetFirstArrayKey( _a105 );
	while ( isDefined( _k105 ) )
	{
		trigger = _a105[ _k105 ];
		trigger thread sndeventstingertriggerthink();
		_k105 = GetNextArrayKey( _a105, _k105 );
	}
}

function sndeventstingertriggerthink()
{
	struct = struct::get( self.target, "targetname" );
	while ( 1 )
	{
		self waittill( "trigger" );
		PlaySoundAtPosition( struct.script_sound, struct.origin );
		level thread sndplaystinger( "trigger_stinger" );
		wait 5;
	}
}

function sndeventtension()
{
	level flag::wait_till( "start_zombie_round_logic" );
	wait 30;
	struct = SpawnStruct();
	while ( 1 )
	{
		tension = sndgettensionlevel( struct );
		waittime = tension.waittime;
		level thread sndplaystinger( tension.tension_level );
		level thread waitfornexttension( waittime );
		level waittill( "sndNextTensionEvent" );
	}
}

function sndgettensionlevel( struct )
{
	tension_level = 0;
	players = GetPlayers();
	_a148 = players;
	_k148 = GetFirstArrayKey( _a148 );
	while ( isdefined( _k148 ) )
	{
		player = _a148[ _k148 ];
		if ( isdefined( player.laststand ) && player.laststand)
		{
			tension_level++;
		}
		_k148 = GetNextArrayKey( _a148, _k148 );
	}
	num_zombs = zombie_utility::get_current_zombie_count();
	if ( num_zombs >= 12 )
	{
		tension_level++;
	}
	enemies = GetAISpeciesArray( "axis", "all" );
	_a161 = enemies;
	_k161 = GetFirstArrayKey( _a161 );
	while ( isdefined( _k161 ) )
	{
		enemy = _a161[ _k161 ];
		if ( enemy.animname == "brutus_zombie" )
		{
			tension_level++;
		}
		_k161 = GetNextArrayKey( _a161, _k161 );
	}
	if ( tension_level > 2 )
	{
		struct.tension_level = "tension_high";
		struct.waittime = 90;
	}
	else
	{
		struct.tension_level = "tension_low";
		struct.waittime = 140;
	}
	return struct;
}

function waitfornexttension( time )
{
	level endon( "sndNextTensionEvent" );
	wait time;
	level notify( "sndNextTensionEvent" );
}

function sndboardmonitor()
{
	while ( 1 )
	{
		level waittill( "last_board_torn", barrier_origin );
		players = GetPlayers();
		_a194 = players;
		_k194 = GetFirstArrayKey( _a194 );
		while ( isdefined( _k194 ) )
		{
			player = _a194[ _k194 ];
			if ( DistanceSquared( player.origin, barrier_origin ) <= 22500 )
			{
				level thread sndplaystinger( "boards_gone" );
				break;
			}
			else
			{
				_k194 = GetNextArrayKey( _a194, _k194 );
			}
		}
	}
}

function locationstingersetup()
{
	level thread locationstingerwait();
}

function locationstingerwait( zone_name, type )
{
	arrayz = sndlocationsarray();
	sndnorepeats = 3;
	numcut = 0;
	level.sndlastzone = undefined;
	level thread sndlocationbetweenroundswait();
	for ( ;; )
	{
		level waittill( "newzoneActive", activezone );
		if ( !sndlocationshouldplay( arrayz, activezone ) )
		{
			wait 0.05;
			continue;
		}
		while ( is_true( level.sndstinger.isplaying ) )
		{
			level thread sndlocationqueue( activezone );
			wait 0.05;
		}
		level thread sndplaystinger( activezone );
		arrayz = sndcurrentlocationarray( arrayz, activezone, numcut, sndnorepeats );
		level.sndlastzone = activezone;
		if ( numcut >= sndnorepeats )
		{
			numcut = 0;
		}
		else
		{
			numcut++;
		}
		level waittill( "between_round_over" );
		while ( is_true( level.sndroundwait ) )
		{
			wait 0.1;
		}
	}
}

function sndlocationsarray()
{
	arrayz = [];
	arrayz[ 0 ] = "cellblock_leftside_zone";
	arrayz[ 1 ] = "shower_zone";
	arrayz[ 2 ] = "infirmary_zone";
	arrayz[ 3 ] = "tunnel_stairs_zone";
	arrayz[ 4 ] = "roof_zone";
	arrayz[ 5 ] = "ug_docks_zone_e";
	arrayz[ 6 ] = "zone_studio";
	arrayz[ 7 ] = "wardens_zone";
	return arrayz;
}

function sndlocationshouldplay( arrayz, activezone )
{
	shouldplay = 0;
	_a280 = arrayz;
	_k280 = GetFirstArrayKey( _a280 );
	while ( isdefined( _k280 ) )
	{
		place = _a280[ _k280 ];
		if ( place == activezone )
		{
			shouldplay = 1;
		}
		_k280 = GetNextArrayKey( _a280, _k280 );
	}
	if ( shouldplay == 0 )
	{
		return shouldplay;
	}
	playersinlocal = 0;
	players = GetPlayers();
	_a291 = players;
	_k291 = GetFirstArrayKey( _a291 );
	while ( isdefined( _k291 ) )
	{
		player = _a291[ _k291 ];
		if ( player zm_alcatraz_utility::is_player_in_zone( activezone ) )
		{
			if ( !is_true( player.afterlife ) )
			{
				playersinlocal++;
			}
		}
		_k291 = GetNextArrayKey( _a291, _k291 );
	}
	if ( playersinlocal >= 1 )
	{
		shouldplay = 1;
	}
	else
	{
		shouldplay = 0;
	}
	return shouldplay;
}

function sndcurrentlocationarray( current_array, activezone, numcut, max_num_removed )
{
	if ( numcut >= max_num_removed )
	{
		current_array = sndlocationsarray();
	}
	_a314 = current_array;
	_k314 = GetFirstArrayKey( _a314 );
	while ( isdefined( _k314 ) )
	{
		place = _a314[ _k314 ];
		if ( place == activezone )
		{
			ArrayRemoveValue( current_array, place );
			break;
		}
		else
		{
			_k314 = GetNextArrayKey( _a314, _k314 );
		}
	}
	return current_array;
}

function sndlocationbetweenrounds()
{
	level endon( "newzoneActive" );
	activezones = zm_zonemgr::get_active_zone_names();
	_a331 = activezones;
	_k331 = GetFirstArrayKey( _a331 );
	while ( isdefined( _k331 ) )
	{
		zone = _a331[ _k331 ];
		if ( isdefined( level.sndlastzone ) && zone == level.sndlastzone )
		{
		}
		else
		{
			players = GetPlayers();
			_a337 = players;
			_k337 = GetFirstArrayKey( _a337 );
			while ( isdefined( _k337 ) )
			{
				player = _a337[ _k337 ];
				if ( is_true( player.afterlife ) )
				{
				}
				else
				{
					if ( player zm_alcatraz_utility::is_player_in_zone( zone ) )
					{
						wait 0.1;
						level notify( "newzoneActive" );
						return;
					}
				}
				_k337 = GetNextArrayKey( _a337, _k337 );
			}
		}
		_k331 = GetNextArrayKey( _a331, _k331 );
	}
}

function sndlocationbetweenroundswait()
{
	level flag::wait_till( "afterlife_start_over" );
	while ( is_true( level.sndroundwait ) )
	{
		wait 0.1;
	}
	while ( 1 )
	{
		level thread sndlocationbetweenrounds();
		level waittill( "between_round_over" );
		while ( is_true( level.sndroundwait ) )
		{
			wait 0.1;
		}
	}
}

function sndlocationqueue( zone )
{
	level endon( "newzoneActive" );
	while ( is_true( level.sndstinger.isplaying ) )
	{
		wait 0.5;
	}
	level notify( "newzoneActive" );
}

function sndstingersetup()
{
	level.sndmusicstingerevent = &sndplaystinger;
	level.sndstinger = SpawnStruct();
	level.sndstinger.ent = Spawn( "script_origin", ( 0, 0, 0 ) );
	level.sndstinger.queue = 0;
	level.sndstinger.isplaying = 0;
	level.sndstinger.states = [];
	level.sndroundwait = 1;
	level flag::wait_till( "initial_blackscreen_passed" );
	createstingerstate( "door_open", "mus_event_group_03", 2.5, "ignore" );
	createstingerstate( "gondola", "mus_event_tension_strings_01", 0.1, "reject" );
	createstingerstate( "boards_gone", "mus_event_group_02", 0.5, "ignore" );
	createstingerstate( "trigger_stinger", "mus_event_group_02", 0.1, "ignore" );
	createstingerstate( "brutus_spawn", "mus_event_brutus_spawn", 1.5, "queue" );
	createstingerstate( "brutus_death", "mus_event_brutus_death", 0.1, "ignore" );
	createstingerstate( "tension_low", "mus_event_tension_piano_01", 0.75, "reject" );
	createstingerstate( "tension_high", "mus_event_tension_piano_02", 0.75, "reject" );
	createstingerstate( "cellblock_leftside_zone", "mus_event_location_cellblock", 0.75, "queue" );
	createstingerstate( "infirmary_zone", "mus_event_location_infirmary", 0.75, "queue" );
	createstingerstate( "zone_studio", "mus_event_location_powerroom", 0.75, "queue" );
	createstingerstate( "roof_zone", "mus_event_location_roof", 0.75, "queue" );
	createstingerstate( "shower_zone", "mus_event_location_shower", 0.75, "queue" );
	createstingerstate( "tunnel_stairs_zone", "mus_event_location_stairwell", 0.75, "queue" );
	createstingerstate( "ug_docks_zone_e", "mus_event_location_dock", 0.75, "queue" );
	createstingerstate( "wardens_zone", "mus_event_location_warden", 0.75, "queue" );
	createstingerstate( "piece_1", "mus_event_piece_1", 0, "queue" );
	createstingerstate( "piece_2", "mus_event_piece_2", 0, "queue" );
	createstingerstate( "piece_3", "mus_event_piece_3", 0, "queue" );
	createstingerstate( "piece_4", "mus_event_piece_4", 0, "queue" );
	createstingerstate( "piece_5", "mus_event_piece_5", 0, "queue" );
	createstingerstate( "piece_mid", "mus_event_piece_mid", 0, "ignore" );
	createstingerstate( "gas_1", "mus_event_piece_1", 0, "reject" );
	createstingerstate( "gas_2", "mus_event_piece_2", 0, "reject" );
	createstingerstate( "gas_3", "mus_event_piece_3", 0, "reject" );
	createstingerstate( "gas_4", "mus_event_piece_4", 0, "reject" );
	createstingerstate( "gas_5", "mus_event_piece_5", 0, "reject" );
	createstingerstate( "plane_crafted_1", "mus_event_plane_1", 0, "reject" );
	createstingerstate( "plane_crafted_2", "mus_event_plane_2", 0, "reject" );
	createstingerstate( "plane_crafted_3", "mus_event_plane_3", 0, "reject" );
	createstingerstate( "plane_crafted_4", "mus_event_plane_4", 0, "reject" );
	createstingerstate( "plane_crafted_5", "mus_event_plane_5", 0, "reject" );
	createstingerstate( "trap", "mus_event_trap", 0, "reject" );
	createstingerstate( "tomahawk_1", "mus_event_tomahawk_2", 0.5, "ignore" );
	createstingerstate( "tomahawk_2", "mus_event_tomahawk_3", 0.5, "ignore" );
	createstingerstate( "tomahawk_3", "mus_event_tomahawk_4", 0.5, "ignore" );
	createstingerstate( "quest_generic", "mus_event_quest_generic", 0.5, "reject" );
	createstingerstate( "laundry_defend", "mus_laundry_defend", 0, "ignore" );
	createstingerstate( "plane_takeoff", "mus_event_plane_takeoff", 0, "ignore" );
	createstingerstate( "at_golden_gate", "mus_event_golden_gate", 0, "ignore" );
	createstingerstate( "spoon", "mus_event_spoon", 0, "ignore" );
	createstingerstate( "spork", "mus_event_spork", 0, "ignore" );
	level thread sndstingerroundwait();
	level thread sndboardmonitor();
	level thread locationstingersetup();
}

function createstingerstate( state, alias, prewait, interrupt )
{
	s = level.sndstinger;
	if ( !isdefined( s.states[ state ] ) )
	{
		s.states[ state ] = SpawnStruct();
		s.states[ state ].alias = alias;
		s.states[ state ].prewait = prewait;
		s.states[ state ].interrupt = interrupt;
	}
}

function sndplaystinger( state, player )
{
	s = level.sndstinger;
	if ( !isdefined( s.states[ state ] ) )
	{
		return;
	}
	interrupt = s.states[ state ].interrupt == "ignore";
	if ( !is_true( s.isplaying ) || is_true( interrupt ) )
	{
		if ( interrupt )
		{
			wait s.states[ state ].prewait;
			playstinger( state, player, 1 );
		}
		else if ( !level.sndroundwait )
		{
			s.isplaying = 1;
			wait s.states[ state ].prewait;
			playstinger( state, player, 0 );
			level notify( "sndStingerDone" );
			s.isplaying = 0;
		}
		else
		{
			if ( s.states[ state ].interrupt == "queue" )
			{
				level thread sndqueuestinger( state, player );
			}
		}
		return;
	}
	if ( s.states[ state ].interrupt == "queue" )
	{
		level thread sndqueuestinger( state, player );
	}
}

function playstinger( state, player, ignore )
{
	s = level.sndstinger;
	if ( !isdefined( s.states[ state ] ) )
	{
		return;
	}
	if ( is_true( level.music_override ) )
	{
		return;
	}
	if ( is_true( ignore ) )
	{
		if ( isdefined( player ) )
		{
			player PlaySoundToPlayer( s.states[ state ].alias, player );
		}
		else
		{
			s.ent PlaySound( s.states[ state ].alias );
		}
	}
	else if ( isdefined( player ) )
	{
		player PlaySoundToPlayer( s.states[ state ].alias, player );
		wait 8;
	}
	else
	{
		s.ent PlaySoundWithNotify( s.states[ state ].alias, "sndStingerDone" );
		s.ent waittill( "sndStingerDone" );
	}
}

function sndqueuestinger( state, player )
{
	s = level.sndstinger;
	if ( is_true( s.queue ) )
	{
		return;
	}
	else
	{
		s.queue = 1;
		while ( 1 )
		{
			if ( is_true( level.sndroundwait ) || is_true( s.isplaying ) )
			{
				wait 0.5;
				continue;
			}
			else
			{
				break;
			}
			wait 0.05;
		}
		level thread sndplaystinger( state, player );
		s.queue = 0;
	}
}

function sndstingerroundwait()
{
	level flag::wait_till( "afterlife_start_over" );
	wait 28;
	level.sndroundwait = 0;
	while ( 1 )
	{
		level waittill( "end_of_round" );
		level notify( "sndStopBrutusLoop" );
		level thread sndstingerroundwait_start();
		wait 0.05;
	}
}

function sndstingerroundwait_start()
{
	level.sndroundwait = 1;
	wait 0.05;
	level thread sndstingerroundwait_end();
}

function sndstingerroundwait_end()
{
	level endon( "end_of_round" );
	level waittill( "between_round_over" );
	wait 28;
	level.sndroundwait = 0;
}

function sndlastlifesetup()
{
	level flag::wait_till( "start_zombie_round_logic" );
	if ( level flag::get( "solo_game" ) )
	{
		level thread sndlastlife_solo();
	}
	else
	{
		level thread sndlastlife_multi();
	}
}

function sndlastlife_solo()
{
	player = GetPlayers()[ 0 ];
	player endon("disconnect");
	while ( 1 )
	{
		player waittill( "sndLifeGone" );
		if ( player.lives == 0 )
		{
			while ( is_true( player.afterlife ) )
			{
				wait 0.1;
			}
			level notify( "sndStopBrutusLoop" );
			//level thread maps/mp/zombies/_zm_audio::change_zombie_music( "last_life" );
			level waittill( "end_of_round" );
		}
	}
}

function sndlastlife_multi()
{
	level endon( "end_of_round" );
	level thread sndlastlife_multi_reset();
	sndplayersdead = 0;
	while ( 1 )
	{
		level waittill( "bleed_out" );
		sndplayersdead++;
		players = GetPlayers();
		if ( ( players.size - sndplayersdead ) <= 1 )
		{
			last_alive = sndlastlife_multi_getlastplayer();
			while ( last_alive.lives > 0 )
			{
				wait 0.1;
			}
			while ( is_true( last_alive.afterlife ) )
			{
				wait 0.1;
			}
			level notify( "sndStopBrutusLoop" );
			//level thread maps/mp/zombies/_zm_audio::change_zombie_music( "last_life" );
			return;
		}
	}
}

function sndlastlife_multi_getlastplayer()
{
	level endon( "end_of_round" );
	wait 0.5;
	players = GetPlayers();
	_a645 = players;
	_k645 = GetFirstArrayKey( _a645 );
	while ( isdefined( _k645 ) )
	{
		dude = _a645[ _k645 ];
		if ( dude.sessionstate == "spectator" )
		{
		}
		else
		{
			return dude;
		}
		_k645 = GetNextArrayKey( _a645, _k645 );
	}
}

function sndlastlife_multi_reset()
{
	level waittill( "end_of_round" );
	level thread sndlastlife_multi();
}

function sndmusicegg()
{
	origins = [];
	origins[ 0 ] = ( 338, 10673, 1378 );
	origins[ 1 ] = ( 2897, 9475, 1564 );
	origins[ 2 ] = ( -1157, 5217, -72 );
	level.meteor_counter = 0;
	level.music_override = 0;
	i = 0;
	while ( i < origins.size )
	{
		level thread sndmusicegg_wait( origins[ i ] );
		i++;
	}
}

function sndmusicegg_wait( bottle_origin )
{
	temp_ent = Spawn( "script_origin", bottle_origin );
	temp_ent PlayLoopSound( "zmb_meteor_loop" );
	//temp_ent thread maps/mp/zombies/_zm_sidequests::fake_use( "main_music_egg_hit", ::sndmusicegg_override );
	temp_ent waittill( "main_music_egg_hit", player );
	temp_ent StopLoopSound( 1 );
	player PlaySound( "zmb_meteor_activate" );
	level.meteor_counter += 1;
	if ( level.meteor_counter == 3 )
	{
		level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song", 170 );
		//level thread easter_egg_song_vo( player );
	}
	else
	{
		wait 1.5;
		temp_ent Delete();
	}
}

function sndmusicegg_override()
{
	if ( is_true( level.music_override ) )
	{
		return 0;
	}
	return 1;
}

function sndmuseggplay( ent, alias, time )
{
	level.music_override = 1;
	wait 1;
	ent PlaySound( alias );
	level thread sndeggmusicwait( time );
	level util::waittill_either( "end_game", "sndSongDone" );
	ent StopSounds();
	wait 0.05;
	ent Delete();
	level.music_override = 0;
}

function sndeggmusicwait( time )
{
	level endon( "end_game" );
	wait time;
	level notify( "sndSongDone" );
}

function is_true(thing)
{
	if(isdefined(thing) && thing)
		return 1;
	else
		return 0;
}