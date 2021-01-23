
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
#insert scripts\zm\_zm_laststand.gsh;
#using scripts\shared\array_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_equipment;

#using scripts\zm\zm_weap_tomahawk;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache("model", "p6_zm_al_skull_afterlife");

function autoexec init() {
	level flag::wait_till( "initial_blackscreen_passed" );
	level flag::init( "warden_blundergat_obtained" );
	level thread wait_for_initial_conditions();
}

function wait_for_initial_conditions()
{
	t_reward_pickup = GetEnt( "sq_bg_reward_pickup", "targetname" );
	t_reward_pickup SetHintString( "" );
	t_reward_pickup SetCursorHint( "HINT_NOICON" );

	level.tomahawk_macguffins = false;

	level waittill( "bouncing_tomahawk_zm_aquired" );

	level.tomahawk_macguffins = true;

	level.sq_bg_macguffins = [];
	a_s_mcguffin = GetEntArray( "struct_sq_bg_macguffin", "targetname" );
	foreach(struct in a_s_mcguffin) {
		m_temp = Spawn( "script_model", struct.origin );
		m_temp.targetname = "sq_bg_macguffin";
		m_temp SetModel( "p6_zm_al_skull_afterlife" );
		m_temp.angles = struct.angles;
		m_temp Ghost();
		level.sq_bg_macguffins[ level.sq_bg_macguffins.size ] = m_temp;
		wait 0.05;
	}
	array::thread_all( level.sq_bg_macguffins, &sq_bg_macguffin_think );
	level.a_tomahawk_pickup_funcs[ level.a_tomahawk_pickup_funcs.size ] = &tomahawk_the_macguffin;
	level thread check_sq_bg_progress();
	level waittill( "all_macguffins_acquired" );

	t_reward_pickup thread give_sq_bg_reward();
}

function sq_bg_macguffin_think() {
	self endon( "sq_bg_macguffin_received_by_player" );
	self thread enable_afterlife_prop();
	self.health = 10000;
	self SetCanDamage( 1 );
	self SetForceNoCull();
	while ( isdefined(self) ) {
		self waittill( "damage", amount, attacker );
		if ( attacker == level || IsPlayer( attacker ) && attacker GetCurrentWeapon().name == "lightning_hands" ) {
			//playfx( level._effect[ "ee_skull_shot" ], self.origin );
			self PlaySound( "zmb_powerpanel_activate" );
			self thread disable_afterlife_prop();
			self thread wait_and_hide_sq_bg_macguffin();
		}
	}
}

function wait_and_hide_sq_bg_macguffin() {
	self notify( "restart_show_timer" );
	self endon( "restart_show_timer" );
	self endon( "caught_by_tomahawk" );
	wait 1.6;
	self thread enable_afterlife_prop();
}

function tomahawk_the_macguffin( grenade, n_grenade_charge_power ) {
	if ( !isdefined( level.sq_bg_macguffins ) || level.sq_bg_macguffins.size <= 0 ) {
		return 0;
	}
	foreach(macguffin in level.sq_bg_macguffins) {
		if ( DistanceSquared( macguffin.origin, grenade.origin ) < 10000 ) {
			m_tomahawk = zm_weap_tomahawk::tomahawk_spawn( grenade.origin );
			m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
			macguffin notify( "caught_by_tomahawk" );
			macguffin.origin = grenade.origin;
			macguffin LinkTo( m_tomahawk );
			macguffin thread disable_afterlife_prop();
			self thread zm_weap_tomahawk::tomahawk_return_player( m_tomahawk );
			self thread give_player_macguffin_upon_receipt( m_tomahawk, macguffin );
			return 1;
		}
	}
	return 0;
}

function give_player_macguffin_upon_receipt( m_tomahawk, m_macguffin ) {
	self endon( "disconnect" );
	while ( isdefined( m_tomahawk ) ) {
		wait 0.05;
	}
	m_macguffin notify( "sq_bg_macguffin_received_by_player" );
	ArrayRemoveValue( level.sq_bg_macguffins, m_macguffin );
	m_macguffin Delete();
	PlaySoundAtPosition( "purchase", self.origin );
	level notify( "sq_bg_macguffin_collected" );
}

function check_sq_bg_progress() {
	n_macguffins_total = level.sq_bg_macguffins.size;
	n_macguffins_collected = 0;
	while ( 1 )
	{
		level waittill( "sq_bg_macguffin_collected", player );
		n_macguffins_collected++;
		if ( n_macguffins_collected >= n_macguffins_total )
		{
			level notify( "all_macguffins_acquired" );
			break;
		}
		else {
			play_sq_bg_collected_vo( player );
		}
		wait 0.5;
	}
	wait 1;
	player PlaySoundToPlayer( "zmb_laugh_child", player );
}

function give_sq_bg_reward() {
	s_reward_origin = struct::get( "sq_bg_reward", "targetname" );
	t_near = Spawn( "trigger_radius", s_reward_origin.origin, 0, 196, 64 );

	blundergat = GetWeapon("bo2_blundergat");
	while ( isdefined(t_near) ) {
		t_near waittill( "trigger", ent );
		if ( IsPlayer( ent ) ) {
			t_near thread sq_bg_spawn_rumble();
			break;
		}
		else {
			wait 0.1;
		}
	}
	a_players = GetPlayers();
	if ( a_players.size == 1 ) {
		if ( a_players[ 0 ] HasWeapon( blundergat ) ) {
			str_reward_weapon = GetWeapon("bo2_acidgat");
			str_loc = "Press ^2&&1^7 to get Acidgat";
		}
		else {
			str_reward_weapon = blundergat;
			str_loc = "Press ^2&&1^7 to get Blundergat";
		}
	}
	else {
		str_reward_weapon = blundergat;
		str_loc = "Press ^2&&1^7 to get Blundergat";
	}
	m_reward_model = zm_utility::spawn_weapon_model( str_reward_weapon, undefined, s_reward_origin.origin, s_reward_origin.angles );
	m_reward_model MoveTo( m_reward_model.origin + vectorScale( ( 0, 0, 1 ), 14 ), 5 );
	//level setclientfield( "sq_bg_reward_portal", 1 );
	self SetHintString( str_loc );
	while ( isdefined(self) ) {
		self waittill( "trigger", player );
		current_weapon = player GetCurrentWeapon();
		if ( zm_utility::is_player_valid( player ) && player.is_drinking > 0 && !zm_utility::is_placeable_mine( current_weapon ) && !zm_equipment::is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" ) {
			if ( player HasWeapon( str_reward_weapon ) ) {
/#
				iprintln( "Player has" + str_reward_weapon + " , so don't give him another one" );
#/
			}
		}
		else {
			self Delete();
		}
		//level setclientfield( "sq_bg_reward_portal", 0 );
		wait 0.05;
		m_reward_model Delete();
		player take_old_weapon_and_give_reward( current_weapon, str_reward_weapon );
	}
	t_near Delete();
}

function sq_bg_spawn_rumble() {
	foreach(player in GetPlayers()) {
		if ( player IsTouching( self ) ) {
			player ShellShock( "explosion", 1 );
		}
	}
}

function take_old_weapon_and_give_reward( current_weapon, reward_weapon, weapon_limit_override ) {
	if ( !isdefined( weapon_limit_override ) ) {
		weapon_limit_override = 0;
	}
	if ( weapon_limit_override == 1 ) {
		self TakeWeapon( current_weapon );
	}
	else {
		primaries = self GetWeaponsListPrimaries();
		if ( isdefined( primaries ) && primaries.size >= 2 ) {
			self TakeWeapon( current_weapon );
		}
	}
	self GiveWeapon( reward_weapon );
	self SwitchToWeapon( reward_weapon );
	level flag::set( "warden_blundergat_obtained" );
	self PlaySoundToPlayer( "vox_brutus_easter_egg_872_0", self );
}

function play_sq_bg_collected_vo( player ) {
	player endon( "disconnect" );
	wait 1;
	player thread zm_utility::do_player_general_vox( "quest", "pick_up_easter_egg" );
}

function enable_afterlife_prop() {
	self Show();
	self.script_noteworthy = "afterlife_prop";
	foreach(player in GetPlayers()) {
		if ( isdefined( player.afterlife ) && player.afterlife ) {
			self SetVisibleToPlayer( player );
		}
		else {
			self SetInvisibleToPlayer( player );
		}
	}
}

function disable_afterlife_prop() {
	self.script_noteworthy = undefined;
	self SetVisibleToAll();
}