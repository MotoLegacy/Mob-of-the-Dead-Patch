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
#using scripts\shared\trigger_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\zm_weap_tomahawk.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_util;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;


#using scripts\zm\zm_prison_spoon;
#using scripts\zm\zm_prison_sq_bg;

#precache( "model", TOMAHAWK_MODEL );
#precache( "model", TOMAHAWK_UG_MODEL );
#precache( "fx", TOMAHAWK_CHARGE_FX );
#precache( "fx", TOMAHAWK_CHARGE_FX_UG );
#precache( "fx", TOMAHAWK_TRAIL_FX );
#precache( "fx", TOMAHAWK_TRAIL_FX_UG );
#precache( "fx", TOMAHAWK_CHARGED_TRAIL_FX );
#precache( "fx", TOMAHAWK_IMPACT_FX );
#precache( "fx", TOMAHAWK_IMPACT_UG_FX );

#namespace zm_weap_tomahawk; 

//*****************************************************************************
// MAIN
//*****************************************************************************

function autoexec init()
{	
	clientfield::register( "toplayer", "tomahawk_in_use", 9000, 2, "int" );
	clientfield::register( "toplayer", "upgraded_tomahawk_in_use", 9000, 1, "int" );
	clientfield::register( "scriptmover", "play_tomahawk_fx", 9000, 2, "int" );
	clientfield::register( "actor", "play_tomahawk_hit_sound", 9000, 1, "int" );
	callback::on_connect( &tomahawk_on_player_connect );
	level thread tomahawk_pickup();
	level.zombie_weapons_no_max_ammo = [];
	level.zombie_weapons_no_max_ammo[ "bouncing_tomahawk_zm" ] = 1;
	level.zombie_weapons_no_max_ammo[ "upgraded_tomahawk_zm" ] = 1;
	level.a_tomahawk_pickup_funcs = [];
	
	zm_utility::register_tactical_grenade_for_level( "zombie_tomahawk" );
	zm_utility::register_tactical_grenade_for_level( "zombie_tomahawk_upgraded" );
}

function tomahawk_on_player_connect()
{
	self.current_tomahawk_weapon = "zombie_tomahawk";
	self thread watch_for_tomahawk_throw();
	self thread watch_for_tomahawk_charge();
}

function watch_for_tomahawk_throw()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( !isSubStr( weapname.name, "tomahawk" ) )
			continue;
		
		grenade.use_grenade_special_bookmark = 1;
		grenade.grenade_multiattack_bookmark_count = 1;
		grenade.low_level_instant_kill_charge = 1;
		grenade.owner = self;
		self notify( "throwing_tomahawk" );
		if ( isDefined( self.n_tomahawk_cooking_time ) )
			grenade.n_cookedtime = grenade.birthtime - self.n_tomahawk_cooking_time;
		else
			grenade.n_cookedtime = 0;
		
		self thread check_for_time_out( grenade );
		self thread tomahawk_thrown( grenade );
	}
}

function watch_for_tomahawk_charge()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_pullback", weaponname );
		if ( !isSubStr( weaponname.name, "tomahawk" ) )
			continue;
		
		self thread watch_for_grenade_cancel();
		self thread play_charge_fx();
		self.n_tomahawk_cooking_time = getTime();
		self util::waittill_either( "grenade_fire", "grenade_throw_cancelled" );
		wait .05;
		self.n_tomahawk_cooking_time = undefined;
	}
}

function watch_for_grenade_cancel()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	waitTillFrameEnd;
	while( self isThrowingGrenade() )
		wait .05;
	
	self notify( "grenade_throw_cancelled" );
}

function play_charge_fx()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );
	waitTillFrameEnd;
	time_to_pulse = 1000;
	while ( 1 )
	{
		time = getTime() - self.n_tomahawk_cooking_time;
		self.current_tactical_grenade = self zm_utility::get_player_tactical_grenade();
		if ( time >= time_to_pulse )
		{
			if ( self.current_tactical_grenade.name == "zombie_tomahawk_upgraded" )
				playFxOnTag( TOMAHAWK_CHARGE_FX_UG, self, "tag_origin" );
			else
				playFxOnTag( TOMAHAWK_CHARGE_FX, self, "tag_origin" );
			
			time_to_pulse += 1000;
			self playRumbleOnEntity( "reload_small" );
		}
		if ( time_to_pulse > 2400 && self.current_tactical_grenade.name != "zombie_tomahawk_upgraded" )
			return;
		else
		{
			if ( time_to_pulse >= 3400 )
				return;
			else
				wait .05;
			
		}
	}
}

function get_grenade_charge_power( player )
{
	player endon( "disconnect" );
	if ( self.n_cookedtime > 1000 && self.n_cookedtime < 2000 )
	{
		if ( player.current_tomahawk_weapon == "zombie_tomahawk_upgraded" )
			return 4.5;
		
		return 1.5;
	}
	else
	{
		if ( self.n_cookedtime > 2000 && self.n_cookedtime < 3000 )
		{
			if ( player.current_tomahawk_weapon == "zombie_tomahawk_upgraded" )
				return 6;
			
			return 2;
		}
		else
		{
			if ( self.n_cookedtime >= 3000 && player.current_tomahawk_weapon != "zombie_tomahawk_upgraded" )
				return 2;
			else
			{
				if ( self.n_cookedtime >= 3000 )
					return 3;
				
			}
		}
	}
	return 1;
}

function tomahawk_thrown( grenade )
{
	self endon( "disconnect" );
	grenade endon( "in_hellhole" );
	grenade_owner = undefined;
	if ( isDefined( grenade.owner ) )
		grenade_owner = grenade.owner;
	
	playfxontag( TOMAHAWK_CHARGED_TRAIL_FX, grenade, "tag_origin" );
	self clientfield::set_to_player( "tomahawk_in_use", 2 );
	grenade util::waittill_either( "death", "time_out" );
	grenade_origin = grenade.origin;
	a_zombies = getAiSpeciesArray( "axis", "all" );
	n_grenade_charge_power = grenade get_grenade_charge_power( self );
	a_zombies = util::get_array_of_closest( grenade_origin, a_zombies, undefined, undefined, 200 );
	a_powerups = util::get_array_of_closest( grenade_origin, level.active_powerups, undefined, undefined, 200 );
	if( level.tomahawk_spoon == true)
	{
		complete = self zm_prison_spoon::tomahawk_the_spoon(grenade, n_grenade_charge_power);
		if(complete == 1)
		{
			return;
		}
	}
	if( level.tomahawk_poster == true)
	{
		complete = self zm_prison_spoon::tomahawk_the_poster(grenade, self);
		if(complete == 1)
		{
			return;
		}
	}
	if( level.tomahawk_macguffins == true)
	{
		complete = self zm_prison_sq_bg::tomahawk_the_macguffin(grenade, n_grenade_charge_power);
		if(complete == 1)
		{
			return;
		}
	}
	if ( isDefined( a_powerups ) && a_powerups.size > 0 )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		_a256 = a_powerups;
		_k256 = getFirstArrayKey( _a256 );
		while ( isDefined( _k256 ) )
		{
			powerup = _a256[ _k256 ];
			powerup.origin = grenade_origin;
			powerup linkTo( m_tomahawk );
			m_tomahawk.a_has_powerup = a_powerups;
			_k256 = getNextArrayKey( _a256, _k256 );
		}
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	if ( !isDefined( a_zombies ) )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	else
	{
		_a276 = a_zombies;
		_k276 = getFirstArrayKey( _a276 );
		while ( isDefined( _k276 ) )
		{
			ai_zombie = _a276[ _k276 ];
			ai_zombie.hit_by_tomahawk = 0;
			_k276 = getNextArrayKey( _a276, _k276 );
		}
	}
	if ( isDefined( a_zombies[ 0 ] ) && isAlive( a_zombies[ 0 ] ) )
	{
		v_zombiepos = a_zombies[ 0 ].origin;
		if ( distanceSquared( grenade_origin, v_zombiepos ) <= 4900 )
		{
			a_zombies[ 0 ] clientfield::set( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = calculate_tomahawk_damage( a_zombies[ 0 ], n_grenade_charge_power, grenade );
			a_zombies[ 0 ] doDamage( n_tomahawk_damage, grenade_origin, self, grenade, "none", "MOD_GRENADE", 0, getWeapon( "zombie_tomahawk" ) );
			a_zombies[ 0 ].hit_by_tomahawk = 1;
			if(n_tomahawk_damage >= a_zombies[ 0 ].health)
				self notify("got_a_tomahawk_kill");
			self zm_score::add_to_player_score( 10 );
			self thread tomahawk_ricochet_attack( grenade_origin, n_grenade_charge_power );
		}
		else
		{
			m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
			m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
			self thread tomahawk_return_player( m_tomahawk, 0 );
		}
	}
	else
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, n_grenade_charge_power );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		if ( isDefined( grenade ) )
			grenade delete();
		
		self thread tomahawk_return_player( m_tomahawk, 0 );
	}
}

function check_for_time_out( grenade )
{
	self endon( "disconnect" );
	grenade endon( "death" );
	wait .5;
	grenade notify( "time_out" );
}

function tomahawk_ricochet_attack( grenade_origin, tomahawk_charge_power )
{
	self endon( "disconnect" );
	a_zombies = getAiSpeciesArray( "axis", "all" );
	a_zombies = util::get_array_of_closest( grenade_origin, a_zombies, undefined, undefined, TOMAHAWK_RANGE );
	a_zombies = array::reverse( a_zombies );
	if ( !isDefined( a_zombies ) )
	{
		m_tomahawk = tomahawk_spawn( grenade_origin, tomahawk_charge_power );
		m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	m_tomahawk = tomahawk_spawn( grenade_origin, tomahawk_charge_power );
	m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
	self thread tomahawk_attack_zombies( m_tomahawk, a_zombies );
}

function tomahawk_attack_zombies( m_tomahawk, a_zombies )
{
	self endon( "disconnect" );
	if ( !isDefined( a_zombies ) )
	{
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	if ( a_zombies.size <= 4 )
		n_attack_limit = a_zombies.size;
	else
		n_attack_limit = 4;
	
	i = 0;
	while ( i < n_attack_limit )
	{
		if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
		{
			tag = "j_head";
			if ( IS_TRUE( a_zombies[ i ].isdog ) )
				tag = "j_spine1";
			
			if ( isDefined( a_zombies[ i ].hit_by_tomahawk ) && !a_zombies[ i ].hit_by_tomahawk )
			{
				v_target = a_zombies[ i ] getTagOrigin( tag );
				m_tomahawk moveTo( v_target, .3 );
				m_tomahawk waittill( "movedone" );
				if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
				{
					if ( self.current_tactical_grenade.name == "zombie_tomahawk_upgraded" )
						playFxOnTag( TOMAHAWK_IMPACT_UG_FX, a_zombies[ i ], tag );
					else
						playFxOnTag( TOMAHAWK_IMPACT_FX, a_zombies[ i ], tag );
					
					playFxOnTag( level._effect[ "tomahawk_fire_dot" ], a_zombies[ i ], "j_spineupper" ); // HARRY_NOTE: CURRENTLY UNUSED
					a_zombies[ i ] clientfield::set( "play_tomahawk_hit_sound", 1 );
					n_tomahawk_damage = calculate_tomahawk_damage( a_zombies[ i ], m_tomahawk.n_grenade_charge_power, m_tomahawk );
					a_zombies[ i ] doDamage( n_tomahawk_damage, m_tomahawk.origin, self, m_tomahawk, "none", "MOD_GRENADE", 0, getWeapon( "zombie_tomahawk" ) );
					a_zombies[ i ].hit_by_tomahawk = 1;
					if(n_tomahawk_damage >= a_zombies[ i ].health)
						self notify("got_a_tomahawk_kill");
					self zm_score::add_to_player_score( 10 );
				}
			}
		}
		wait .2;
		i++;
	}
	self thread tomahawk_return_player( m_tomahawk, n_attack_limit );
}

function tomahawk_return_player( m_tomahawk, num_zombie_hit )
{
	self endon( "disconnect" );
	self playsound( "wpn_tomahawk_incoming" );
	n_dist = distance2dSquared( m_tomahawk.origin, self.origin );
	if ( !isDefined( num_zombie_hit ) )
		num_zombie_hit = 5;
	
	while ( n_dist > 4096 )
	{
		m_tomahawk moveTo( self getEye(), .25 );
		if ( num_zombie_hit < 5 )
		{
			self tomahawk_check_for_zombie( m_tomahawk );
			num_zombie_hit++;
		}
		wait 0.1;
		n_dist = distance2dSquared( m_tomahawk.origin, self getEye() );
	}
	if ( isDefined( m_tomahawk.a_has_powerup ) )
	{
		_a470 = m_tomahawk.a_has_powerup;
		_k470 = getFirstArrayKey( _a470 );
		while ( isDefined( _k470 ) )
		{
			powerup = _a470[ _k470 ];
			if ( isDefined( powerup ) )
				powerup.origin = self.origin;
			
			_k470 = getNextArrayKey( _a470, _k470 );
		}
	}
	m_tomahawk delete();
	self playSoundToPlayer( "wpn_tomahawk_catch_plr", self );
	self playSound( "wpn_tomahawk_catch_npc" );
	wait TOMAHAWK_RECHARGE_TIME;
	self playSoundToPlayer( "wpn_tomahawk_cooldown", self );
	self giveMaxAmmo( self.current_tactical_grenade );
	a_zombies = getAiSpeciesArray( "axis", "all" );
	self clientfield::set_to_player( "tomahawk_in_use", 3 );
}

function tomahawk_check_for_zombie( grenade )
{
	self endon( "disconnect" );
	grenade endon( "death" );
	a_zombies = getAiSpeciesArray( "axis", "all" );
	a_zombies = util::get_array_of_closest( grenade.origin, a_zombies, undefined, undefined, 100 );
	if ( isDefined( a_zombies[ 0 ] ) && distance2dSquared( grenade.origin, a_zombies[ 0 ].origin ) <= 10000 )
	{
		if ( isDefined( a_zombies[ 0 ].hit_by_tomahawk ) && !a_zombies[ 0 ].hit_by_tomahawk )
			self tomahawk_hit_zombie( a_zombies[ 0 ], grenade );
		
	}
}

function tomahawk_hit_zombie( ai_zombie, grenade )
{
	self endon( "disconnect" );
	if ( isDefined( ai_zombie ) && isalive( ai_zombie ) )
	{
		tag = "j_head";
		if ( IS_TRUE( ai_zombie.isdog ) )
			tag = "j_spine1";
		
		v_target = ai_zombie getTagOrigin( tag );
		grenade moveTo( v_target, .3 );
		grenade waittill( "movedone" );
		if ( isDefined( ai_zombie ) && isAlive( ai_zombie ) )
		{
			if ( self.current_tactical_grenade.name == "zombie_tomahawk_upgraded" )
				playFxOnTag( TOMAHAWK_IMPACT_UG_FX, ai_zombie, tag );
			else
				playFxOnTag( TOMAHAWK_IMPACT_FX, ai_zombie, tag );
			
			ai_zombie clientfield::set( "play_tomahawk_hit_sound", 1 );
			n_tomahawk_damage = calculate_tomahawk_damage( ai_zombie, grenade.n_grenade_charge_power, grenade );
			ai_zombie doDamage( n_tomahawk_damage, grenade.origin, self, grenade, "none", "MOD_GRENADE", 0, getWeapon( "zombie_tomahawk" ) );
			ai_zombie.hit_by_tomahawk = 1;
			if(n_tomahawk_damage >= ai_zombie.health)
				self notify("got_a_tomahawk_kill");
			self zm_score::add_to_player_score( 10 );
		}
	}
}

function tomahawk_spawn( grenade_origin, charged )
{
	m_tomahawk = spawn( "script_model", grenade_origin );
	m_tomahawk setModel( TOMAHAWK_MODEL );
	if ( self.current_tactical_grenade.name == "zombie_tomahawk_upgraded" )
		m_tomahawk setModel( TOMAHAWK_UG_MODEL );
	
	m_tomahawk thread tomahawk_spin();
	m_tomahawk playloopsound( "wpn_tomahawk_spin" );
	if ( self.current_tactical_grenade.name == "zombie_tomahawk_upgraded" )
		playFxOnTag( TOMAHAWK_TRAIL_FX_UG, m_tomahawk, "tag_origin" );
	else
		playFxOnTag( TOMAHAWK_TRAIL_FX, m_tomahawk, "tag_origin" );
	
	if ( isDefined( charged ) && charged > 1 )
		playFxOnTag( TOMAHAWK_CHARGED_TRAIL_FX, m_tomahawk, "tag_origin" );
	
	m_tomahawk.low_level_instant_kill_charge = 1;
	return m_tomahawk;
}

function tomahawk_spin()
{
	self endon( "death" );
	while ( isDefined( self ) )
	{
		self rotatePitch( 90, .2 );
		wait .15;
	}
}

function tomahawk_pickup()
{
	// flag::wait_till( "soul_catchers_charged" );
	level flag::init( "tomahawk_pickup_complete" );
	door = getEnt( "tomahawk_room_door", "targetname" );
	door trigger::trigger_turns_off();
	door connectPaths();
	
	s_pos_tomahawk = undefined;
	s_pos_tomahawk = struct::get( "tomahawk_pickup_pos", "targetname" );
	if ( isDefined( s_pos_tomahawk ) )
	{
		m_tomahawk = spawn( "script_model", s_pos_tomahawk.origin );
		m_tomahawk.targetname = "spinning_tomahawk_pickup";
		m_tomahawk setModel( TOMAHAWK_MODEL );
		m_tomahawk clientfield::set( "play_tomahawk_fx", 1 );
		m_tomahawk thread tomahawk_pickup_spin();
		m_tomahawk playLoopSound( "amb_tomahawk_swirl" );
	
		trigger = spawn( "trigger_radius_use", s_pos_tomahawk.origin, 0, 100, 150 );
		trigger.script_noteworthy = "retriever_pickup_trigger";
		trigger useTriggerRequireLookAt();
		trigger triggerIgnoreTeam();
		trigger setHintString( "Hold ^3&&1^7 for Hell's Retriever" );
		trigger setCursorHint( "HINT_NOICON" );
	
		trigger thread tomahawk_pickup_trigger( "zombie_tomahawk" );
	}
	if ( isDefined( s_pos_tomahawk ) )
	{
		trigger_upgraded = spawn( "trigger_radius_use", s_pos_tomahawk.origin, 0, 100, 150 );
		trigger_upgraded useTriggerRequireLookAt();
		trigger_upgraded triggerIgnoreTeam();
		m_tomahawk clientfield::set( "play_tomahawk_fx", 2 );
		trigger_upgraded.script_noteworthy = "redeemer_pickup_trigger";
		trigger_upgraded setHintString( "Hold ^3&&1^7 for Hell's Redeemer" );
		trigger_upgraded setCursorHint( "HINT_NOICON" );
	
		trigger_upgraded thread tomahawk_pickup_trigger( "zombie_tomahawk_upgraded" );
	}
	level flag::set( "tomahawk_pickup_complete" );
}

function tomahawk_pickup_trigger( tomahawk )
{
	while( 1 )
	{
		self waittill( "trigger", player );

		if(isdefined(player.afterlife) && player.afterlife && tomahawk == "zombie_tomahawk")
		{
			continue;
		}
		
		if ( player hasWeapon( getWeapon( tomahawk ) ) )
		{
			wait .05;
			continue;
		}
		if ( isDefined( player.current_tactical_grenade ) )
			player takeWeapon( player.current_tactical_grenade );
		
		player zm_utility::disable_player_move_states( 1 );
		gun = player getCurrentWeapon();
		level notify( "bouncing_tomahawk_zm_aquired" );
		player zm_stats::increment_player_stat( "prison_tomahawk_acquired" );
		player GiveWeapon( GetWeapon( tomahawk + "_flourish" ) );
		player thread tomahawk_update_hud_on_last_stand();
		player SwitchToWeapon( GetWeapon( tomahawk + "_flourish" ) );
		player util::waittill_any( "player_downed", "weapon_change_complete" );
		player SwitchToWeapon( gun );
		player zm_utility::enable_player_move_states();
		player.loadout.hastomahawk = 1;
		player TakeWeapon( GetWeapon( tomahawk + "_flourish" ) );
		
		name = "Hell's Retriever";
		if ( tomahawk == "zombie_tomahawk_upgraded" )
			name = "Hell's Redeemer";
		
		player thread tomahawk_tutorial_hint( name );
		
		player GiveWeapon( GetWeapon( tomahawk ) );
		player zm_utility::set_player_tactical_grenade( getWeapon( tomahawk ) );
		player notify( "tomahawk_picked_up" );
		level notify( "bouncing_tomahawk_zm_aquired" );
		player notify( "player_obtained_tomahawk" );
		player zm_stats::increment_player_stat( "prison_tomahawk_acquired" );
	}
}

function tomahawk_pickup_spin()
{
	self endon( "death" );
	while ( 1 )
	{
		self RotateYaw( 90, 1 );
		wait .15;
	}
}

function calculate_tomahawk_damage( n_target_zombie, n_tomahawk_power, tomahawk )
{
	if ( n_tomahawk_power > 2 )
		return n_target_zombie.health + 1;
	else
	{
		if ( level.round_number >= 10 && level.round_number < 13 && tomahawk.low_level_instant_kill_charge <= 3 )
		{
			tomahawk.low_level_instant_kill_charge += 1;
			return n_target_zombie.health + 1;
		}
		else
		{
			if ( level.round_number >= 13 && level.round_number < 15 && tomahawk.low_level_instant_kill_charge <= 2 )
			{
				tomahawk.low_level_instant_kill_charge += 1;
				return n_target_zombie.health + 1;
			}
			else
				return 1000 * n_tomahawk_power;
			
		}
	}
}

function setting_tutorial_hud()
{
	client_hint = newClientHudElem( self );
	client_hint.alignx = "center";
	client_hint.aligny = "middle";
	client_hint.horzalign = "center";
	client_hint.vertalign = "bottom";
	client_hint.y = -120;
	client_hint.foreground = 1;
	client_hint.font = "default";
	client_hint.fontscale = 1.5;
	client_hint.alpha = 1;
	client_hint.color = ( 1, 1, 1 );
	return client_hint;
}

function tomahawk_tutorial_hint( name )
{
	hud = setting_tutorial_hud();
	hud setText( "Press [{+smoke}] to Throw the " + name );
	self util::waittill_notify_or_timeout( "throwing_tomahawk", 5 );
	wait 1;
	hud destroy();
}

function tomahawk_update_hud_on_last_stand()
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "tomahawk_upgraded_swap" );
	while ( 1 )
	{
		self util::waittill_either( "entering_last_stand", "fake_death" );
		self clientfield::set_to_player( "tomahawk_in_use", 0 );
		self waittill( "player_revived" );
		if ( isAlive( self ) )
		{
			wait .05;
			self clientfield::set_to_player( "tomahawk_in_use", 1 );
			self giveweapon( self.current_tomahawk_weapon );
			self givemaxammo( self.current_tomahawk_weapon );
			self zm_utility::set_player_tactical_grenade( getWeapon( self.current_tomahawk_weapon ) );
		}
	}
}
