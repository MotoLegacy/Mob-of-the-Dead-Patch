
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
#using scripts\shared\spawner_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_melee_weapon;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\zm_packasplat;
#using scripts\zm\zm_alcatraz_amb;

#using scripts\zm\zm_weap_tomahawk;

#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_laststand.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache("model", "t6_wpn_zmb_spoon_world");
#precache("model", "t6_wpn_zmb_spork_world");
#precache("model", "c_zom_inmate_g_rarmspawn");

function autoexec init() {
	if ( isdefined( level.gamedifficulty ) && level.gamedifficulty == 0 ) {
		level thread spoon_easy_cleanup();
		return;
	}
	zm_melee_weapon::init( "spoon_alcatraz");
	zm_melee_weapon::set_fallback_weapon( "spoon_alcatraz", "zombie_fists_bowie" );
	zm_melee_weapon::init( "spork_alcatraz");
	zm_melee_weapon::set_fallback_weapon( "spork_alcatraz", "zombie_fists_bowie" );
	level.tomahawk_spoon = false;
	level.tomahawk_poster = false;
	level thread wait_for_initial_conditions();
	level flag::wait_till( "initial_players_connected" );
	array::thread_all( level.zombie_spawners, &spawner::add_spawn_function, &zombie_spoon_func );
	level thread bucket_init();
	spork_portals = GetEntArray( "afterlife_show_spork", "targetname" );
	foreach(spork_portal in spork_portals) {
		spork_portal SetInvisibleToAll();	
	}
	level.b_spoon_in_tub = 0;
	level.n_spoon_kill_count = 0;
	level flag::init( "spoon_obtained" );
	level flag::init( "charged_spoon" );
}

function spoon_easy_cleanup() {
	spork_portals = GetEntArray( "afterlife_show_spork", "targetname" );
	foreach(spork_portal in spork_portals) {
		spork_portal Delete();
	}
	m_spoon_pickup = GetEnt( "pickup_spoon", "targetname" );
	m_spoon_pickup Delete();
	m_spoon = GetEnt( "zap_spoon", "targetname" );
	m_spoon Delete();
}

function extra_death_func_to_check_for_splat_death() {
	self thread zm_spawner::zombie_death_animscript();
	if ( self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH" ) {
		if ( self.damageweapon.name == "bo2_acidgat_bullet" ) {
			if ( IsPlayer( self.attacker ) ) {
				self notify( "killed_by_a_blundersplat" );
			}
		}
		else {
			if ( self.damageweapon.name == "zombie_tomahawk" ) {
				if ( IsPlayer( self.attacker ) ) {
					self.attacker notify( "got_a_tomahawk_kill" );
				}
			}
		}
	}
	if ( isdefined( self.attacker.killed_with_only_tomahawk ) ) {
		if ( self.damageweapon.name != "zombie_tomahawk" && self.damageweapon != "none" ) {
			self.attacker.killed_with_only_tomahawk = 0;
		}
	}
	if ( isdefined( self.attacker.killed_something_thq ) ) {
		self.attacker.killed_something_thq = 1;
	}
	return 0;
}

function zombie_spoon_func() {
	self.deathfunction = &extra_death_func_to_check_for_splat_death;
	self waittill( "killed_by_a_blundersplat" );
	//IPrintLnBold("killed by blundersplat");
	if ( level flag::get("charged_spoon") || !level.b_spoon_in_tub ) {
		return;
	}
	if ( self IsTouching(GetEnt("shower_zone", "targetname")) ) {
		//IPrintLnBold("killed by blundersplat in shower " + level.n_spoon_kill_count);
		level.n_spoon_kill_count++;
	}
	else {
		return;
	}
	if ( level.n_spoon_kill_count >= 50 ) {
		level flag::set("charged_spoon");
	}
}

function wait_for_initial_conditions() {
	m_spoon_pickup = GetEnt( "pickup_spoon", "targetname" );
	m_spoon_pickup Ghost();
	while ( !isdefined( level.characters_in_nml ) || level.characters_in_nml.size == 0 ) {
		wait 1;
	}
	level flag::wait_till( "soul_catchers_charged" );
	level.tomahawk_poster = true;
	level waittill("poster_gone");
	spork_doors = GetEntArray( "spork_door", "targetname" );
	foreach(spork_door in spork_doors) {
		spork_door.targetname = "afterlife_door";
	}
	spork_portals = GetEntArray( "afterlife_show_spork", "targetname" );
	foreach(spork_portal in spork_portals) {
		spork_portal.targetname = "afterlife_show";
	}
	m_spoon = GetEnt( "zap_spoon", "targetname" );
	t_spoon = GetEnt( "zap_spoon_trig", "targetname" );
	//m_spoon ghostindemo();
	b_spoon_shocked = 0;
	while ( !b_spoon_shocked && isdefined(t_spoon) ) {
		t_spoon waittill( "trigger", player );
		if ( player GetCurrentWeapon().name == "lightning_hands" ) {
			b_spoon_shocked = 1;
			t_spoon Delete();
			m_spoon Delete();
			player PlaySoundToPlayer( "zmb_spooky_laugh", player );
		}
	}
	m_spoon_pickup Show();
	m_spoon_pickup.health = 10000;
	m_spoon_pickup SetCanDamage( 1 );
	level.tomahawk_spoon = true;
}

function tomahawk_the_poster( grenade, player) {
	m_poster = GetEnt( "poster", "targetname" );
	if ( DistanceSquared( m_poster.origin, grenade.origin ) < 40000 ) {
		level.tomahawk_poster = false;
		PlaySoundAtPosition( "zmb_squest_spoon_poster", m_poster.origin );
		m_poster Delete();
		if ( isdefined( player ) && IsPlayer( player ) ) {
			player zm_utility::do_player_general_vox( "quest", "secret_poster", undefined, 100 );
		}
		m_tomahawk = zm_weap_tomahawk::tomahawk_spawn( grenade.origin );
		self thread zm_weap_tomahawk::tomahawk_return_player( m_tomahawk, 0 );
		wait 1;
		player thread zm_utility::do_player_general_vox( "quest", "pick_up_easter_egg" );
		level notify("poster_gone");
		return 1;
	}
	return 0;
}

function tomahawk_the_spoon( grenade, n_grenade_charge_power ) {
	//IPrintLnBold("tomahawk spoon called");
	if ( self HasWeapon( GetWeapon("spoon_alcatraz") ) || self HasWeapon( GetWeapon("spork_alcatraz") ) ) {
		return 0;
	}
	m_spoon = GetEnt( "pickup_spoon", "targetname" );
	if ( DistanceSquared( m_spoon.origin, grenade.origin ) < 40000 ) {
		//IPrintLnBold("spoon at range");
		m_tomahawk = zm_weap_tomahawk::tomahawk_spawn( grenade.origin );
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		m_player_spoon = Spawn( "script_model", grenade.origin );
		m_player_spoon SetModel( "t6_wpn_zmb_spoon_world" );
		m_player_spoon LinkTo( m_tomahawk );
		m_tomahawk.spoon = m_player_spoon;
		self thread zm_weap_tomahawk::tomahawk_return_player( m_tomahawk, 0 );
		self thread give_player_spoon_upon_receipt( m_tomahawk, m_player_spoon );
		self thread dip_the_spoon();
		level flag::set( "spoon_obtained" );
		self PlaySoundToPlayer( "vox_brutus_easter_egg_101_0", self );
		return 1;
	}
	return 0;
}

function give_player_spoon_upon_receipt( m_tomahawk, m_player_spoon ) {
	while ( isdefined( m_tomahawk ) ) {
		wait 0.05;
	}
	//IPrintLnBold("spoon delete");
	m_player_spoon Delete();
	if ( !self HasWeapon( GetWeapon("spoon_alcatraz") ) && !self HasWeapon( GetWeapon("spork_alcatraz") )  ) {
		self TakeWeapon( self zm_utility::get_player_melee_weapon());
		self GiveWeapon( GetWeapon("spoon_alcatraz") );
		//self zm_utility::set_player_melee_weapon( GetWeapon("spoon_alcatraz") );
		//IPrintLnBold("new knife set");
		level thread zm_alcatraz_amb::sndplaystinger( "spoon", self );
		wait 0.05;
	}
	wait 1;
	self thread zm_utility::do_player_general_vox( "quest", "pick_up_easter_egg" );
}

function bucket_init() {
	level.t_bathtub = GetEnt( "tub_trigger", "targetname" );
	level.t_bathtub UseTriggerRequireLookAt();
	level.t_bathtub TriggerIgnoreTeam();
	level.t_bathtub SetHintString( "" );
	level.t_bathtub SetCursorHint( "HINT_NOICON" );
}

function wait_for_bucket_activated( player ) {
	if ( isdefined( player ) ) {
		while ( isdefined(level.t_bathtub) ) {
			level.t_bathtub waittill( "trigger", who );
			if ( who == player ) {
				return;
			}
		}
	}
	else {
		level.t_bathtub waittill( "trigger", who );
	}
}

function dip_the_spoon() {
	self endon( "disconnect" );
	wait_for_bucket_activated( self );
	self TakeWeapon( self zm_utility::get_player_melee_weapon() );
	self GiveWeapon( level.weaponBaseMelee );
	//self zm_utility::set_player_melee_weapon( level.weaponBaseMelee );
	self.spoon_in_tub = 1;
	self thread spoon_visual_state_1();
	wait 5;
	level.b_spoon_in_tub = 1;
	level flag::wait_till( "charged_spoon" );
	//IPrintLnBold("changing done");
	wait 1;
	foreach(player in GetPlayers()) {
		player PlaySoundToPlayer("zmb_spooky_laugh", player);
	}
	//level.t_bathtub PlaySound( "zmb_spooky_laugh" );
	self thread thrust_the_spork();
}

function thrust_the_spork() {
	self endon( "disconnect" );
	wait_for_bucket_activated( self );
	self thread spoon_visual_state_2();
	wait 5;
	wait_for_bucket_activated( self );
	self TakeWeapon( self zm_utility::get_player_melee_weapon() );
	self GiveWeapon( GetWeapon("spork_alcatraz") );
	//self zm_utility::set_player_melee_weapon( "spork_alcatraz" );
	level thread zm_alcatraz_amb::sndplaystinger( "spork", self );
	self.spoon_in_tub = undefined;
	self thread spoon_visual_state_3();
	wait 1;
	self thread zm_utility::do_player_general_vox( "quest", "pick_up_easter_egg" );
}

function spoon_visual_state_1() {
	s_spoon_pos = GetEnt( "struct_spoon_start", "targetname" );
	m_spoon = Spawn( "script_model", s_spoon_pos.origin );
	m_spoon SetModel( "t6_wpn_zmb_spoon_world" );
	m_spoon PlaySoundToPlayer( "zmb_squest_spoon_in", self );
	m_spoon SetInvisibleToAll();
	m_spoon SetVisibleToPlayer(self);
	i = 0;
	while( i < 10) {
		m_spoon RotateYaw( 90, 1 );
		wait 0.15;
		i++;
	}
	m_spoon MoveTo( m_spoon.origin - ( 0, 0, 36 ), 5 );
	m_spoon waittill( "movedone" );
	m_spoon Delete();
}

function spoon_visual_state_2() {
	s_spoon = GetEnt( "s_rising_spork", "targetname" );
	s_arm = GetEnt( "s_rising_arm", "targetname" );
	self.my_m_spoon = Spawn( "script_model", s_spoon.origin );
	self.my_m_spoon SetInvisibleToAll();
	self.my_m_spoon SetVisibleToPlayer(self);
	self.my_m_spoon SetModel( "t6_wpn_zmb_spork_world" );
	self.my_m_spoon.angles = s_spoon.angles;
	m_arm = Spawn( "script_model", s_arm.origin  );
	m_arm SetModel( "c_zom_inmate_g_rarmspawn" );
	m_arm SetInvisibleToAll();
	m_arm SetVisibleToPlayer(self);
	m_arm.angles = s_arm.angles;
	m_arm PlaySoundToPlayer( "zmb_squest_spork_out", self );
	self.my_m_spoon LinkTo( m_arm );
	m_arm MoveTo( m_arm.origin + ( 0, 0, 26 ), 5 );
}

function spoon_visual_state_3() {
	self.my_m_spoon Delete();
}