
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

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_ai_brutus;

#using scripts\zm\zm_alcatraz_amb;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_laststand.gsh;

#using scripts\shared\ai\zombie_death;

#precache("xanim", "fxanim_zom_al_trap_fan_start_anim");
#precache("xanim", "fxanim_zom_al_trap_fan_idle_anim");
#precache("xanim", "fxanim_zom_al_trap_fan_end_anim");

#precache("model", "p6_zm_al_wall_trap_control_red");
#precache("model", "p6_zm_al_wall_trap_control");

#precache( "fx", "weapon/fx_hero_annhilatr_death_blood" ); 

#define ACID_RAIN_FX			"custom/jerri/al_traps/acid_trap_rain"
#precache( "fx", "custom/jerri/al_traps/acid_trap_rain" ); 

#using_animtree("generic");

function jerri_iprintlnbold( string ) {
	if( isdefined(level.jerri_debug) && level.jerri_debug )
		IPrintLnBold( "^6Jerri Debug:^7 "+string ); 
}

function autoexec init() {
	trig = GetEnt("tower_trap_upgrade_trig", "script_noteworthy");
	model = GetEnt(trig.target,"targetname");
	model.targetname = "afterlife_interact";
	model.script_string = "upgrade_tower_trap";
	trig Delete();

	level._effect["fan_trap_blood"]	= "weapon/fx_hero_annhilatr_death_blood";
	level.jerri_debug = false;
	level thread init_fan_trap_trigs();
	level thread init_acid_trap_trigs();
	level thread init_tower_trap_trigs();
}

function init_fan_trap_trigs() {
	trap_trigs = GetEntArray( "fan_trap_use_trigger", "targetname" );
	for ( i = 0; i < trap_trigs.size; i++ )
	{
		trap_trigs[i] thread fan_trap_think();
	}
	init_fan_fxanim( "wardens_office" );
}

function init_fan_fxanim( str_loc ) {
	e_fan = GetEnt( "fxanim_fan_" + str_loc, "targetname" );
	level.fan_trap_fxanims = [];
	level.fan_trap_fxanims[ "fan_trap_start" ] = %fxanim_zom_al_trap_fan_start_anim;
	level.fan_trap_fxanims[ "fan_trap_idle" ] = %fxanim_zom_al_trap_fan_idle_anim;
	level.fan_trap_fxanims[ "fan_trap_end" ] = %fxanim_zom_al_trap_fan_end_anim;
}

function fan_trap_think() {
	triggers = GetEntArray( self.targetname, "targetname" );
	self.cost = 1000;
	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();
	self.in_use = 0;
	self.is_available = 1;
	self.has_been_used = 0;
	self.zombie_dmg_trig = GetEnt( self.target, "targetname" );
	self.zombie_dmg_trig.script_string = self.script_string;
	self.zombie_dmg_trig.in_use = 0;
	self.rumble_trig = GetEnt( "fan_trap_rumble", "targetname" );
	light_name = self get_trap_light_name();
	zapper_light_red( light_name );
	self SetHintString( &"ZOMBIE_NEED_POWER" );
	level waittill( "activate_warden_office" );
	//level flag::wait_till( "power_on" );
	zapper_light_green( light_name );
	self SetHintString( &"ZOMBIE_BUTTON_BUY_TRAP" , self.cost );
	while ( 1 ) {
		self waittill( "trigger", who );
		jerri_iprintlnbold("trigger");
		if ( who zm_utility::in_revive_trigger() ) {
			jerri_iprintlnbold("in revive");
			continue;
		}
		if ( !isDefined( self.is_available ) ) {
			jerri_iprintlnbold("not available");
			continue;
		}
		if ( zm_utility::is_player_valid( who ) ) {
			if ( who.score >= self.cost ) {
				if ( !self.zombie_dmg_trig.in_use ) {
					if ( !self.has_been_used ) {
						self.has_been_used = 1;
						level thread zm_alcatraz_amb::sndplaystinger( "trap" );
						who zm_utility::do_player_general_vox( "general", "discover_trap" );
					}
					else {
						who zm_utility::do_player_general_vox( "general", "start_trap" );
					}
					self.zombie_dmg_trig.in_use = 1;
					self.zombie_dmg_trig.active = 1;
					jerri_iprintlnbold("activated");
					self PlaySound( "zmb_trap_activate" );
					self thread fan_trap_move_switch( self );
					self waittill( "switch_activated" );
					who zm_score::minus_to_player_score( self.cost );
					level.trapped_track[ "fan" ] = 1;
					level notify( "trap_activated" );
					for ( i = 0; i < triggers.size; i++ ) {
						triggers[i] SetHintString(&"ZOMBIE_TRAP_ACTIVE");
					}
					self.zombie_dmg_trig SetVisibleToAll();
					self thread activate_fan_trap();
					self.zombie_dmg_trig waittill( "trap_finished_" + self.script_string );
					//clientnotify( self.script_string + "off" );
					self.zombie_dmg_trig notify( "fan_trap_finished" );
					self.zombie_dmg_trig.active = 0;
					self.zombie_dmg_trig SetInvisibleToAll();
					for ( i = 0; i < triggers.size; i++ ) {
						triggers[i] SetHintString(&"ZOMBIE_TRAP_COOLDOWN");
					}
					wait 25;
					self PlaySound( "zmb_trap_available" );
					self notify( "available" );
					self.zombie_dmg_trig.in_use = 0;
					for ( i = 0; i < triggers.size; i++ )
					{
						triggers[i] SetHintString( &"ZOMBIE_BUTTON_BUY_TRAP" , self.cost );
					}
				}
				else {
					jerri_iprintlnbold("dam trig in use");
				}
			}
			else {
				PlaySoundAtPosition( "nsz_deny", who.origin );
				jerri_iprintlnbold("not enough money");
			}
		}
	}
}

function activate_fan_trap() {
	self.zombie_dmg_trig thread fan_trap_damage( self );
	e_fan = GetEnt( "fxanim_fan_" + self.script_string, "targetname" );
	e_fan UseAnimTree( #animtree );
	e_fan PlaySound( "zmb_trap_fan_start" );
	e_fan PlayLoopSound( "zmb_trap_fan_loop", 2 );
	n_start_time = GetAnimLength( level.fan_trap_fxanims[ "fan_trap_start" ] );
	n_idle_time = GetAnimLength( level.fan_trap_fxanims[ "fan_trap_idle" ] );
	n_end_time = GetAnimLength( level.fan_trap_fxanims[ "fan_trap_end" ] );
	e_fan AnimScripted( "optionalNotify", e_fan.origin , e_fan.angles, level.fan_trap_fxanims[ "fan_trap_start" ]);
	wait n_start_time;
	e_fan AnimScripted( "optionalNotify", e_fan.origin , e_fan.angles, level.fan_trap_fxanims[ "fan_trap_idle" ]);
	self thread fan_trap_timeout();
	self thread fan_trap_rumble_think();
	self.zombie_dmg_trig waittill( "trap_finished_" + self.script_string );
	e_fan AnimScripted( "optionalNotify", e_fan.origin , e_fan.angles, level.fan_trap_fxanims[ "fan_trap_end" ]);
	foreach(player in GetPlayers()) {
		if ( IS_TRUE( player.fan_trap_rumble ) ) {
			//player setclientfieldtoplayer( "rumble_fan_trap", 0 );
			player.fan_trap_rumble = 0;
		}
	}
	e_fan StopLoopSound( 0.75 );
	e_fan PlaySound( "zmb_trap_fan_end" );
	wait n_end_time;
}

function fan_trap_rumble_think() {
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	while ( 1 ) {
		self.rumble_trig waittill( "trigger", ent );
		if ( IsPlayer( ent ) ) {
			if ( !IS_TRUE( ent.fan_trap_rumble ) ) {
				self thread fan_trap_rumble( ent );
			}
		}
		wait 0.05;
	}
}

function fan_trap_rumble( player ) {
	player endon( "death" );
	player endon( "disconnect" );
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	while ( 1 ) {
		if ( player IsTouching( self.rumble_trig ) ) {
			player.fan_trap_rumble = 1;
			player thread fan_trap_rumble_player();
			wait 0.25;
			continue;
		}
		else {
			//player setclientfieldtoplayer( "rumble_fan_trap", 0 );
			player.fan_trap_rumble = 0;
			return;
		}
		wait 0.05;
	}
}

function fan_trap_rumble_player() {
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "rumble_fan_trap_finished" );
	Earthquake( 0.15, 1, self.origin, 1500 );
	self PlayRumbleOnEntity( "damage_light" );
	wait 0.25;
	self notify( "rumble_fan_trap_finished" );
}

function fan_trap_timeout() {
	self.zombie_dmg_trig endon( "trap_finished_" + self.script_string );
	n_duration = 0;
	while ( n_duration < 25 ) {
		wait 0.05;
		n_duration += 0.05;
	}
	self.zombie_dmg_trig notify( "trap_finished_" + self.script_string );
}

function fan_trap_damage( parent ) {
	if ( isDefined( level.custom_fan_trap_damage_func ) ) {
		self thread [[ level.custom_fan_trap_damage_func ]]( parent );
		return;
	}
	self endon( "fan_trap_finished" );
	while ( 1 ) {
		self waittill( "trigger", ent );
		if ( IsPlayer( ent ) ) {
			ent thread player_fan_trap_damage();
			continue;
		}
		else {
			if ( IS_TRUE( ent.is_brutus ) ) {
				ent zm_ai_brutus::trapDamageCallback( self );
				return;
			}
			if ( !isDefined( ent.marked_for_death ) ) {
				ent.marked_for_death = 1;
				ent thread zombie_fan_trap_death();
			}
		}
	}
}

function player_fan_trap_damage() {
	self endon( "death" );
	self endon( "disconnect" );
	if ( !self HasPerk( "specialty_armorvest" ) || ( self.health - 100 ) < 1 ) {
		self DoDamage( self.health + 1000, self.origin );
	}
	else {
		self DoDamage( 50, self.origin );
	}
}

function zombie_fan_trap_death() {
	if ( !isdefined( self.is_brutus ) ) {
		self.a.gib_ref = array::random( array( "guts", "right_arm", "left_arm", "head" ) );
		self thread zombie_death::do_gib();
	}
	origin = self GetTagOrigin("J_Spine1");
	PlayFX( level._effect["fan_trap_blood"], self.origin + (0,0,35) );
	self DoDamage( self.health + 1000, self.origin );
}


function fan_trap_move_switch( parent ) {
	light_name = "";
	tswitch = GetEnt( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch RotatePitch( -180, 0.5 );
	tswitch PlaySound( "evt_switch_flip_trap" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch RotatePitch( 180, 0.5 );
	zapper_light_green( light_name );
}

function init_acid_trap_trigs() {
	trap_trigs = GetEntArray( "acid_trap_trigger", "targetname" );
	for ( i = 0; i < trap_trigs.size; i++ ) {
		trap_trigs[i] thread acid_trap_think();
	}
	level thread acid_trap_host_migration_listener();
}

function acid_trap_think() {
	triggers = GetEntArray( self.targetname, "targetname" );
	self.is_available = 1;
	self.has_been_used = 0;
	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();
	self.cost = 1000;
	self.in_use = 0;
	self.zombie_dmg_trig = GetEnt( self.target, "targetname" );
	self.zombie_dmg_trig.in_use = 0;
	light_name = self get_trap_light_name();
	zapper_light_red( light_name );
	self SetHintString( &"ZOMBIE_NEED_POWER" );
	level flag::wait_till( "enter_cafe_zone" );
	//level flag::wait_till_any( "activate_cafeteria", "activate_infirmary" );
	zapper_light_green( light_name );
	self SetHintString( &"ZOMBIE_BUTTON_BUY_TRAP" , self.cost );
	while ( 1 ) {
		self waittill( "trigger", who );
		if ( who zm_utility::in_revive_trigger() ) {
			continue;
		}
		if ( !isDefined( self.is_available ) ) {
			continue;
		}
		if ( zm_utility::is_player_valid( who ) ) {
			if ( who.score >= self.cost ) {
				if ( !self.zombie_dmg_trig.in_use ) {
					if ( !self.has_been_used ) {
						self.has_been_used = 1;
						level thread zm_alcatraz_amb::sndplaystinger( "trap" );
						who zm_utility::do_player_general_vox( "general", "discover_trap" );
					}
					else {
						who zm_utility::do_player_general_vox( "general", "start_trap" );
					}
					self.zombie_dmg_trig.in_use = 1;
					self.zombie_dmg_trig.active = 1;
					self PlaySound( "zmb_trap_activate" );
					self thread acid_trap_move_switch( self );
					self waittill( "switch_activated" );
					who zm_score::minus_to_player_score( self.cost );
					level.trapped_track[ "acid" ] = 1;
					level notify( "trap_activated" );
					//who maps/mp/zombies/_zm_stats::increment_client_stat( "prison_acid_trap_used", 0 );
					for ( i = 0; i < triggers.size; i++ ) {
						triggers[i] SetHintString(&"ZOMBIE_TRAP_ACTIVE");
					}
					self thread activate_acid_trap();
					wait 2;
					self.zombie_dmg_trig waittill( "acid_trap_fx_done" );
					if ( isDefined( self.fx_org ) ) {
						self.fx_org Delete();
					}
					if ( isDefined( self.zapper_fx_org ) ) {
						self.zapper_fx_org Delete();
					}
					if ( isDefined( self.zapper_fx_switch_org ) ) {
						self.zapper_fx_switch_org delete();
					}
					self.zombie_dmg_trig notify( "acid_trap_finished" );
					self.zombie_dmg_trig.active = 0;
					for ( i = 0; i < triggers.size; i++ ) {
						triggers[i] SetHintString(&"ZOMBIE_TRAP_COOLDOWN");
					}
					wait 25;
					self PlaySound( "zmb_trap_available" );
					self notify( "available" );
					self.zombie_dmg_trig.in_use = 0;
					for ( i = 0; i < triggers.size; i++ )
					{
						triggers[i] SetHintString( &"ZOMBIE_BUTTON_BUY_TRAP" , self.cost );
					}
				}
			}
			else {
				PlaySoundAtPosition( "nsz_deny", who.origin );
				jerri_iprintlnbold("not enough money");
			}
		}
	}
}

function activate_acid_trap() {
	fire_points = struct::get_array( "acid_trap_fire_point", "targetname" );
	i = 0;
	while ( i < fire_points.size ) {
		wait 0.05;
		fire_points[ i ] thread acid_trap_fx( self );
		i++;
	}
	self.zombie_dmg_trig thread acid_trap_damage();
}

function acid_trap_damage() {
	if ( isDefined( level.custom_acid_trap_damage_func ) ) {
		self thread [[ level.custom_acid_trap_damage_func ]]();
		return;
	}
	self endon( "acid_trap_finished" );
	while ( 1 ) {
		self waittill( "trigger", ent );
		if ( IsPlayer( ent ) ) {
			ent thread player_acid_damage( self );
			continue;
		}
		else {
			if ( IS_TRUE( ent.is_brutus ) ) {
				ent zm_ai_brutus::trapDamageCallback( self );
				return;
			}
			if ( !isDefined( ent.marked_for_death ) ) {
				ent.marked_for_death = 1;
				ent thread zombie_acid_damage();
			}
		}
	}
}

function zombie_acid_damage() {
	self endon( "death" );
	wait RandomFloatRange( 0.25, 2 );
	if ( !isDefined( self.is_brutus ) ) {
		self.a.gib_ref = array::random( array( "right_arm", "left_arm", "head", "right_leg", "left_leg", "no_legs" ) );
		zombie_death::do_gib();
	}
	self DoDamage( self.health + 1000, self.origin );
}

function player_acid_damage( t_damage ) {
	self endon( "death" );
	self endon( "disconnect" );
	t_damage endon( "acid_trap_finished" );
	if ( !isdefined( self.is_in_acid ) && !self laststand::player_is_in_laststand() ) {
		self.is_in_acid = 1;
		self thread player_acid_damage_cooldown();
		while ( self IsTouching( t_damage ) && !self laststand::player_is_in_laststand() && !self.afterlife )
		{
			self DoDamage( self.maxhealth / 2, self.origin );
			wait 1;
		}
	}
}

function player_acid_damage_cooldown() {
	self endon( "disconnect" );
	wait 1;
	if ( isdefined( self ) )
	{
		self.is_in_acid = undefined;
	}
}

function acid_trap_fx( notify_ent ) {
	notify_ent.zombie_dmg_trig endon( "acid_trap_fx_done" );
	acid_fx = Spawn("script_model", self.origin); 
	notify_ent.zombie_dmg_trig thread watchFxEarlyEnd(acid_fx);
	acid_fx.angles = self.angles;
	acid_fx SetModel("tag_origin"); 
	PlayFXOnTag( ACID_RAIN_FX , acid_fx, "tag_origin" );
	wait 25;
	acid_fx Delete();
	notify_ent.zombie_dmg_trig notify( "acid_trap_fx_done" );
}

function watchFxEarlyEnd(acid_fx) {
	notify_ent.zombie_dmg_trig waittill( "acid_trap_fx_done" );
	if(isdefined(acid_fx)) {
		acid_fx Delete();
	}
}

function acid_trap_move_switch( parent ) {
	light_name = "";
	tswitch = GetEnt( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch RotatePitch( -180, 0.5 );
	tswitch PlaySound( "amb_sparks_l_b" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch RotatePitch( 180, 0.5 );
	zapper_light_green( light_name );
}

function acid_trap_host_migration_listener() {
	level endon( "end_game" );
	level notify( "acid_trap_hostmigration" );
	level endon( "acid_trap_hostmigration" );
	while ( 1 ) {
		level waittill( "host_migration_end" );
		trap_trigs = GetEntArray( "acid_trap_trigger", "targetname" );
		_a623 = trap_trigs;
		_k623 = GetFirstArrayKey( _a623 );
		while ( isDefined( _k623 ) ) {
			trigger = _a623[ _k623 ];
			if ( isDefined( trigger.zombie_dmg_trig ) && isDefined( trigger.zombie_dmg_trig.active ) ) {
				if ( trigger.zombie_dmg_trig.active == 1 ) {
					break;
				}
			}
			else {
				_k623 = GetNextArrayKey( _a623, _k623 );
			}
		}
	}
}


function init_tower_trap_trigs() {
	trap_trigs = GetEntArray( "tower_trap_activate_trigger", "targetname" );
	foreach(trigger in trap_trigs) {
		trigger thread tower_trap_trigger_think();
	}
}

function tower_trap_trigger_think() {
	self.range_trigger = GetEnt( self.target, "targetname" );
	self.upgrade_trigger = GetEnt( self.script_string, "script_noteworthy" );
	self.cost = 1000;
	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();
	light_name = self get_trap_light_name();
	zapper_light_green( light_name );
	self.is_available = 1;
	self.in_use = 0;
	self.has_been_used = 0;
	self.sndtowerent = Spawn( "script_origin", ( -21, 5584, 356 ) );
	while ( 1 ) {
		self SetHintString( &"ZOMBIE_BUTTON_BUY_TRAP", self.cost );
		self waittill( "trigger", who );
		if ( who zm_utility::in_revive_trigger() ) {
			continue;
		}
		if ( !isdefined( self.is_available ) ) {
			continue;
		}
		if ( zm_utility::is_player_valid( who ) ) {
			if ( who.score >= self.cost ) {
				if ( !self.in_use ) {
					if ( !self.has_been_used ) {
						self.has_been_used = 1;
						who zm_utility::do_player_general_vox( "general", "discover_trap" );
					}
					else {
						who zm_utility::do_player_general_vox( "general", "start_trap" );
					}
					self.in_use = 1;
					self.active = 1;
					PlaySoundAtPosition( "purchase", who.origin );
					self thread tower_trap_move_switch( self );
					self PlaySound( "zmb_trap_activate" );
					self waittill( "switch_activated" );
					who zm_score::minus_to_player_score( self.cost );
					level.trapped_track[ "tower" ] = 1;
					level notify( "trap_activated" );
					self SetHintString( &"ZOMBIE_TRAP_ACTIVE" );
					self.sndtowerent PlaySound( "zmb_trap_tower_start" );
					self.sndtowerent PlayLoopSound( "zmb_trap_tower_loop", 1 );
					self thread activate_tower_trap();
					self thread tower_trap_timer();
					self thread tower_upgrade_trigger_think();
					level thread open_tower_trap_upgrade_panel();
					level thread tower_trap_upgrade_panel_closes_early();
					self waittill( "tower_trap_off" );
					self.sndtowerent StopLoopSound( 1 );
					self.sndtowerent PlaySound( "zmb_trap_tower_end" );
					model = GetEnt("upgrade_tower_trap","script_string");
					model notify( "afterlife_interact_reset" );
					self.active = 0;
					self SetHintString( &"ZOMBIE_TRAP_COOLDOWN" );
					zapper_light_red( light_name );
					wait 25;
					self PlaySound( "zmb_trap_available" );
					self notify( "available" );
					self.in_use = 0;
					self.upgrade_trigger notify( "available" );
					self.upgrade_trigger.in_use = 0;
				}
			}
		}
	}
}

function tower_upgrade_trigger_think() {
	self endon( "tower_trap_off" );
	self.upgrade_trigger.cost = 1000;
	self.upgrade_trigger.in_use = 0;
	self.upgrade_trigger.is_available = 1;
	while ( 1 ) {
		level waittill( "upgrade_tower_trap" );
		level.trapped_track[ "tower_upgrade" ] = 1;
		level notify( "tower_trap_upgraded" );
		level notify( "close_tower_trap_upgrade_panel" );
		self upgrade_tower_trap_weapon();
		self notify( "tower_trap_reset_timer" );
		self thread tower_trap_timer();
		self waittill( "tower_trap_off" );
		wait 25;
	}
}

function open_tower_trap_upgrade_panel() {
	e_door = GetEnt( "tower_shockbox_door", "targetname" );
	e_door MoveTo( e_door.origin + vectorScale( ( 0, 1, 0 ), 40 ), 1 );
	level waittill( "close_tower_trap_upgrade_panel" );
	e_door MoveTo( e_door.origin - vectorScale( ( 0, 1, 0 ), 40 ), 1 );
}

function tower_trap_upgrade_panel_closes_early() {
	level endon( "tower_trap_upgraded" );
	n_waittime = 24;
	wait n_waittime;
	level notify( "close_tower_trap_upgrade_panel" );
}

function tower_trap_move_switch( parent ) {
	light_name = "";
	tswitch = GetEnt( "trap_handle_" + parent.script_linkto, "targetname" );
	light_name = parent get_trap_light_name();
	zapper_light_red( light_name );
	tswitch RotatePitch( -180, 0.5 );
	tswitch PlaySound( "amb_sparks_l_b" );
	tswitch waittill( "rotatedone" );
	self notify( "switch_activated" );
	self waittill( "available" );
	tswitch RotatePitch( 180, 0.5 );
	if ( isdefined( parent.script_noteworthy ) ) {
		zapper_light_green( light_name );
	}
}

function activate_tower_trap()
{
	self endon( "tower_trap_off" );
	self.weapon_name = "tower_trap";
	self.tag_to_target = "J_Head";
	self.trap_reload_time = 0.75;
	while ( 1 ) {
		zombies = GetAISpeciesArray( "axis", "all" );
		zombies_sorted = [];
		foreach(zombie in zombies) {
			if ( zombie IsTouching( self.range_trigger ) && IsAlive(zombie)) {
				zombies_sorted[ zombies_sorted.size ] = zombie;
			}
			wait 0.05;
		}
		if ( zombies_sorted.size <= 0 ) {
			wait 0.05;
		}
		else {
			self tower_trap_fires( zombies_sorted);
		}
		wait 0.05;
	}
}

function upgrade_tower_trap_weapon() {
	self.weapon_name = "tower_trap_upgraded";
	self.tag_to_target = "J_SpineLower";
	self.trap_reload_time = 1.5;
}

function tower_trap_timer() {
	self endon( "tower_trap_reset_timer" );
	wait 25;
	self notify( "tower_trap_off" );
}

function zapper_light_red( lightname ) {
	zapper_lights = GetEntArray( lightname, "targetname" );
	i = 0;
	while ( i < zapper_lights.size ) {
		zapper_lights[ i ] SetModel( "p6_zm_al_wall_trap_control_red" );
		i++;
	}
}

function tower_trap_fires( a_zombies ) {
	if ( isdefined( level.custom_tower_trap_fires_func ) ) {
		self thread [[ level.custom_tower_trap_fires_func ]]( a_zombies );
		return;
	}
	self endon( "tower_trap_off" );
	e_org = GetEnt( self.range_trigger.target, "targetname" );
	e_org.team = "allies";
	e_org.pers[ "team" ] = "allies";
	e_org.sessionteam = "allies";
	n_index = RandomIntRange( 0, a_zombies.size );
	while ( IsAlive( a_zombies[ n_index ] ) ) {
		e_target = a_zombies[ n_index ];
		v_zombietarget = e_target GetTagOrigin( self.tag_to_target );
		if ( BulletTracePassed( e_org.origin, v_zombietarget, 1, undefined ) ) {
			MagicBullet( GetWeapon(self.weapon_name), e_org.origin, v_zombietarget );
			wait self.trap_reload_time;
			continue;
		}
		else {
			ArrayRemoveValue( a_zombies, e_target, 0 );
			util::wait_network_frame();
			if ( a_zombies.size <= 0 ) {
				return;
			}
			else {
				n_index = RandomIntRange( 0, a_zombies.size );
			}
		}
		wait 0.05;
	}
}

function zapper_light_green( lightname ) {
	zapper_lights = GetEntArray( lightname, "targetname" );
	i = 0;
	while ( i < zapper_lights.size )
	{
		zapper_lights[ i ] SetModel( "p6_zm_al_wall_trap_control" );
		i++;
	}
}

function get_trap_light_name() {
	tswitch = GetEnt( "trap_handle_" + self.script_linkto, "targetname" );
	switch( tswitch.script_linkname )
	{
		case "1":
		case "2":
			light_name = "trap_control_wardens_office";
			break;
		case "3":
		case "4":
		case "5":
			light_name = "trap_control_cafeteria";
			break;
		case "99":
			light_name = "trap_control_docks";
			break;
	}
	return light_name;
}