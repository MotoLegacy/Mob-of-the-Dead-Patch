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
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\weapons\_weaponobjects;

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
#using scripts\zm\_util;
#using scripts\zm\_zm_weap_riotshield;

#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\zk_buyable_elevator_v2;

#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_alcatraz_sq_vo;
#using scripts\zm\zm_alcatraz_sq_nixie;
#using scripts\zm\zm_alcatraz_utility;
//#using scripts\zm\zm_prison_sq_final;
#using scripts\zm\zm_prison_travel;

#using scripts\zm\_zm_weap_blundersplat;

#using scripts\zm\_zm_magicbox_prison;
#using scripts\zm\_zm_magicbox_lock;

//#using scripts\zm\_zm_ai_brutus;

#insert scripts\zm\_zm_buildables.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;

#precache( "material", "afterlife_logo" );
#precache( "material", "afterlife_logo_waypoint" );

#precache( "xmodel", "c_zom_player_arlington_fb_chair" );
#precache( "xmodel", "c_zom_player_handsome_fb_chair" );
#precache( "xmodel", "c_zom_player_deluca_fb_chair" );
#precache( "xmodel", "c_zom_player_oleary_fb_chair" );

#precache( "xanim", "ai_zombie_afterlife_stun_a" );

#precache( "fx", "custom/motdr/afterlife/fx_alcatraz_afterlife_zmb_tport" ); 
#precache( "fx", "custom/jerri/tomahawk/fx_tomahawk_upgraded_trail" ); 
#precache( "fx", "custom/jerri/al_afterlife/fx_alcatraz_player" ); 
#precache( "fx", "custom/motdr/afterlife/fx_alcatraz_suicide_area" ); 
#precache( "fx", "custom/motdr/afterlife/fx_alcatraz_afterlife_start" ); 
#precache( "fx", "custom/motdr/afterlife/fx_alcatraz_player_revive" ); 
#precache( "fx", "custom/motdr/afterlife/fx_alcatraz_box_charge" ); 


#precache( "fx", "zombie/fx_elec_player_md_zmb" );
#precache( "fx", "zombie/fx_elec_player_sm_zmb" );
#precache( "fx", "zombie/fx_elec_player_torso_zmb" );

#using_animtree( "generic" );

function give_afterlife() {
    callback::on_connect( &init_player );
    level flag::wait_till( "initial_players_connected" );
	while ( !AreTexturesLoaded() ) {
		WAIT_SERVER_FRAME;
	}
    level notify( "Pack_A_Punch_on" );
    n_start_pos = 1;
    foreach(player in GetPlayers()) {
        if ( isdefined( player.afterlife ) && !player.afterlife ) {
            player thread fake_kill_player( n_start_pos );
			player util::clientnotify( "al_e" );
            n_start_pos++;
        }
    }
}

function fake_kill_player( n_start_pos ) {
    self afterlife_remove();
    self.afterlife = 1;
    e_corpse_location = struct::get( "corpse_starting_point_new_" + n_start_pos, "targetname" );
    self thread afterlife_laststand(false, e_corpse_location.origin);
    self waittill( "player_fake_corpse_created" );
    self thread afterlife_tutorial();
    vec_to_target = self.e_afterlife_corpse.origin - self.origin;
    vec_to_target = VectortoAngles( vec_to_target );
    vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
    self SetPlayerAngles( vec_to_target );
    self notify( "al_all_setup" );
}

function afterlife_tutorial() {
    self endon( "disconnect" );
    level endon( "end_game" );
    level flag::wait_till( "start_zombie_round_logic" );
    wait 3;
    self zm_alcatraz_utility::create_tutorial_message( "Press ^3[{+attack}]^7 to shock" );
    self thread afterlife_tutorial_attack_watch();
    util::waittill_notify_or_timeout( "stop_tutorial", 5 );
    self thread zm_alcatraz_utility::destroy_tutorial_message();
    wait 1;
    if ( IS_TRUE( self.afterlife ) ) {
        self zm_alcatraz_utility::create_tutorial_message( "Press ^3[{+gostand}]^7 to levitate" );
        self thread afterlife_tutorial_jump_watch();
        util::waittill_notify_or_timeout( "stop_tutorial", 5 );
        self thread zm_alcatraz_utility::destroy_tutorial_message();
    }
}

function afterlife_tutorial_attack_watch() {
    self endon( "stop_tutorial" );
    self endon( "disconnect" );
    while ( IS_TRUE( self.afterlife ) && !self IsFiring() ) {
        wait 0.05;
    }
    wait 0.2;
    self notify( "stop_tutorial" );
}

function afterlife_tutorial_jump_watch() {
    self endon( "stop_tutorial" );
    self endon( "disconnect" );
    while ( IS_TRUE( self.afterlife ) && !self zm_utility::is_jumping() ) {
        wait 0.05;
    }
    wait 0.2;
    self notify( "stop_tutorial" );
}

function startxcam()
{
	level flag::wait_till("afterlife_start_over");
	while(1)
	{
		if(self UseButtonPressed())
		{
			IPrintLnBold("xcam enabled");
			//self SetClientUIVisibilityFlag( "weapon_hud_visible", 0 );
			//self DisableWeaponCycling(); 
			self TakeAllWeapons();
			level thread clientfield::set("intoxcam", 1);
			wait 10;
			IPrintLnBold("xcam 2");
			break;
		}
		wait 0.1;
	}
}

function init()
{
	clientfield::register( "toplayer", "player_lives", VERSION_SHIP, 2, "int" );
	clientfield::register( "toplayer", "player_afterlife_mana", VERSION_SHIP, 5, "float" );
	clientfield::register( "scriptmover", "player_corpse_id", VERSION_TU7, 1, "int" );
	clientfield::register( "toplayer", "player_in_afterlife", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "clientfield_afterlife_audio", VERSION_SHIP, 1, "int" );
	clientfield::register( "allplayers", "player_afterlife_fx", VERSION_SHIP, 2, "int" );
	clientfield::register( "toplayer", "player_afterlife_refill", VERSION_SHIP, 1, "int" );
	clientfield::register( "world", "fog_stage", VERSION_SHIP, 2, "int" );
	clientfield::register( "world", "intoxcam", VERSION_SHIP, 1, "int" );

	//callback::on_connect(&startxcam);

	level thread check_solo_status();
	level thread afterlife_special_door_init();
	level.zombiemode_using_afterlife = 1;
	level flag::init( "afterlife_start_over" );
	//callback::on_connect(&af_hands_fire);
	level.afterlife_revive_tool = GetWeapon("bo2_af_revive");
	//level.custom_player_fake_death = &zm_player_fake_death;
	//level.custom_player_fake_death_cleanup = &zm_player_fake_death_cleanup;
	visionset_mgr::register_info( "visionset", "afterlife", 9000, 120, 1, 1 );
	//visionset_mgr::register_info( "overlay", "afterlife_filter", 9000, 120, 1, 1 );
	zm_perks::register_perk_damage_override_func( &afterlife_player_damage_callback );
	afterlife_load_fx();
	level thread afterlife_hostmigration();
	a_afterlife_interact = GetEntArray( "afterlife_interact", "targetname" );
	array::thread_all( a_afterlife_interact, &afterlife_interact_object_think );
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	foreach(struct in a_afterlife_triggers) {
		afterlife_trigger_create( struct );
	}
	level.afterlife_interact_dist = 256;
	level.is_player_valid_override = &is_player_valid_afterlife;
	level.can_revive = &can_revive_override;
	level.round_prestart_func = &afterlife_start_zombie_logic;
	level.custom_pap_validation = &is_player_valid_afterlife;
	level.player_out_of_playable_area_monitor_callback = &player_out_of_playable_area;
	level thread afterlife_gameover_cleanup();
	level.afterlife_zapped = &afterlife_zapped;
	level.afterlife_give_loadout = &afterlife_give_loadout;
	level.afterlife_save_loadout = &afterlife_save_loadout;
	level thread activate_afterlife_spawns();
	level thread activate_afterlife_zombie_spawns();
	level thread power_on_perk_machines();
	level thread afterlife_powerups();
	level thread afterlife_intro_door();
	level thread afterlife_cell_door_1();
	level thread afterlife_cell_door_2();
	level.zombie_spawners = GetEntArray( "zombie_spawner", "script_noteworthy" );
	array::thread_all( level.zombie_spawners, &spawner::add_spawn_function, &afterlife_zombie_damage );
}

function afterlife_gameover_cleanup() {
	level waittill( "end_game" );
	foreach(player in GetPlayers()) {
		player.afterlife = 0;
		player util::clientnotify( "end_game" );
		player notify( "end_game" );
		if ( isdefined( player.client_hint ) ) {
			player.client_hint Destroy();
		}
	}
	wait 5;
	foreach(player in GetPlayers()) {
		//visionset_mgr::deactivate( "overlay", "afterlife_filter", player );
	}
}

function afterlife_load_fx() {
	level._effect[ "afterlife_teleport" ] = "custom/motdr/afterlife/fx_alcatraz_afterlife_zmb_tport";
	level._effect[ "teleport_ball" ] = "custom/jerri/tomahawk/fx_tomahawk_upgraded_trail";
	level._effect[ "afterlife_kill_point_fx" ] = "custom/motdr/afterlife/fx_alcatraz_suicide_area";
	level._effect[ "afterlife_enter" ] = "custom/motdr/afterlife/fx_alcatraz_afterlife_start";
	level._effect[ "afterlife_leave" ] = "custom/motdr/afterlife/fx_alcatraz_player_revive";
	level._effect[ "afterlife_pixie_dust" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies";
	level._effect[ "afterlife_corpse" ] = "custom/motdr/afterlife/fx_alcatraz_player_down";
	level._effect[ "afterlife_damage" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage";
	level._effect[ "afterlife_ghost_h_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_head";
	level._effect[ "afterlife_ghost_arm_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_arm";
	level._effect[ "afterlife_ghost_hand_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand";
	level._effect[ "afterlife_ghost_hand_r_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r";
	level._effect[ "afterlife_transition" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition";
	level._effect[ "fx_alcatraz_ghost_vm_wrist" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist";
	level._effect[ "fx_alcatraz_ghost_vm_wrist_r" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r";
	level._effect[ "fx_alcatraz_ghost_spectate" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_spec";
	level._effect[ "afterlife_ghost_fx" ] = "custom/jerri/al_afterlife/fx_alcatraz_player";

	level._effect[ "box_activated" ] = "custom/motdr/afterlife/fx_alcatraz_box_charge";

	level._effect["elec_md"]							= "zombie/fx_elec_player_md_zmb";
	level._effect["elec_sm"]							= "zombie/fx_elec_player_sm_zmb";
	level._effect["elec_torso"]							= "zombie/fx_elec_player_torso_zmb";
}

function afterlife_start_zombie_logic()
{
	level flag::wait_till( "start_zombie_round_logic" );
	wait 0.5;
	b_everyone_alive = 0;
	while ( !IS_TRUE( b_everyone_alive ) ) {
		b_everyone_alive = 1;
		foreach(player in GetPlayers()) {
			if ( IS_TRUE( player.afterlife ) ) {
				b_everyone_alive = 0;
				wait 0.05;
				break;
			}
		}
		wait 0.1;
	}
	wait 0.5;
	while ( level.intermission ) {
		wait 0.05;
	}
	level flag::set( "afterlife_start_over" );
	wait 2;
	array::thread_all( GetPlayers(), &afterlife_add );
}

function is_player_valid_afterlife( player )
{
	if ( IS_TRUE( player.afterlife ) ) {
		return 0;
	}
	return 1;
}

function can_revive_override( revivee )
{
	if ( isdefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	return 1;
}

function player_out_of_playable_area()
{
	if ( isdefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	if ( isdefined( self.on_a_plane ) && self.on_a_plane )
	{
		return 0;
	}
	return 1;
}

function init_player()
{
	level flag::wait_till( "initial_players_connected" );
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		self.af_lives = 3;
	}
	else
	{
		self.af_lives = 1;
	}
	self clientfield::set_to_player( "player_lives", self.af_lives );
	self.afterlife = 0;
	self.afterliferound = level.round_number;
	self.afterlifedeaths = 0;
	self thread afterlife_doors_close();
	self thread afterlife_player_refill_watch();
}

function afterlife_remove( b_afterlife_death )
{
	if ( !isdefined( b_afterlife_death ) )
	{
		b_afterlife_death = 0;
	}
	if ( isdefined( b_afterlife_death ) && b_afterlife_death )
	{
		self.af_lives = 0;
	}
	else
	{
		if ( self.af_lives > 0 )
		{
			self.af_lives--;
		}
	}
	self notify( "sndLifeGone" );
	self clientfield::set_to_player( "player_lives", self.af_lives );
}

function afterlife_add()
{
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		if ( self.af_lives < 3 )
		{
			self.af_lives++;
			self thread afterlife_add_fx();
		}
	}
	else
	{
		if ( self.af_lives < 1 )
		{
			self.af_lives++;
			self thread afterlife_add_fx();
		}
	}
	self PlaySoundToPlayer( "zmb_afterlife_add", self );
	self clientfield::set_to_player( "player_lives", self.af_lives );
}

function afterlife_add_fx()
{
	if ( isdefined( self.afterlife ) && !self.afterlife )
	{
		self clientfield::set_to_player( "player_afterlife_refill", 1 );
		wait 3;
		if ( isdefined( self.afterlife ) && !self.afterlife )
		{
			self clientfield::set_to_player( "player_afterlife_refill", 0 );
		}
	}
}

function afterlife_player_refill_watch()
{
	self endon( "disconnect" );
	self endon( "_zombie_game_over" );
	level endon( "stage_final" );
	while ( 1 )
	{
		level waittill( "end_of_round" );
		wait 2;
		self afterlife_add();
		reset_all_afterlife_unitriggers();
	}
}

function afterlife_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isdefined( eattacker ) )
	{
		if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie )
		{
			if ( isdefined( eattacker.custom_damage_func ) )
			{
				//idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
				idamage = 25;
			}
			else
			{
				if ( isdefined( eattacker.meleedamage ) && smeansofdeath != "MOD_GRENADE_SPLASH" )
				{
					//idamage = eattacker.meleedamage;
					idamage = 25;
				}
				idamage = 17;
			}
			if ( isdefined( self.afterlife ) && self.afterlife )
			{
				//self afterlife_reduce_mana( 10 );
				self util::clientnotify( "al_d" );
				return 0;
			}
		}
	}
	if ( isdefined( self.afterlife ) && self.afterlife )
	{
		return 0;
	}
	if( sweapon.name == "ray_gun" || sweapon.name == "ray_gun_upgraded")
	{
		idamage = 25;
	}
	if( sweapon.name == "launch_usrpg" || sweapon.name == "launch_usrpg_upgraded")
	{
		idamage = 25;
	}
	if( sweapon.name == "bo2_1911_upgraded" || sweapon.name == "bo2_1911_upgraded_lh")
	{
		idamage = 25;
	}
	if ( isdefined( eattacker ) && isdefined( eattacker.is_zombie ) || eattacker.is_zombie && IsPlayer( eattacker ) )
	{
		if ( isdefined( self.hasriotshield ) && self.hasriotshield && isDefined( vdir ) )
		{
			item_dmg = 100;
			if ( isdefined( eattacker.custom_item_dmg ) )
			{
				item_dmg = eattacker.custom_item_dmg;
			}
			if ( isdefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
			{
				if ( self riotshield::player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
					return 0;
				}
			}
			else
			{
				if ( !isDefined( self.riotshieldentity ) )
				{
					if ( !self riotshield::player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
					{
						self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
						return 0;
					}
				}
			}
		}
	}

	if ( smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" && smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( sweapon == GetWeapon("bo2_acidgat_bullet") )
		{
			if ( self HasPerk( "specialty_flakjacket" ) )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 0;
			}
			if ( isalive( self ) && isdefined( self.is_zombie ) && !self.is_zombie )
			{
				self.use_adjusted_grenade_damage = 1;
				idamage = 10;
			}
		}
		else
		{
			if ( self HasPerk( "specialty_flakjacket" ) )
			{
				return 0;
			}
			
			if ( self.health > 75 && isdefined( self.is_zombie ) && !self.is_zombie )
			{
				idamage = 75;
			}
		}
	}
	
	if ( sweapon == GetWeapon("tower_trap") || sweapon == GetWeapon("tower_trap_upgraded") )
	{
		self.use_adjusted_grenade_damage = 1;
		return 0;
	}
	if ( idamage >= self.health && isdefined( level.intermission ) && !level.intermission )
	{
		if ( self.af_lives > 0 && isdefined( self.afterlife ) && !self.afterlife )
		{
			self PlaySoundToPlayer( "zmb_afterlife_death", self );
			self afterlife_remove();
			self.afterlife = 1;
			self thread afterlife_laststand();
			if ( self.health <= 1 )
			{
				return 0;
			}
			else
			{
				idamage = self.health - 1;
			}
		}
		else
		{
			self thread last_stand_conscience_vo();
		}
	}
	return idamage;
}

function afterlife_enter()
{
	if ( !isdefined( self.afterlife_visionset ) || self.afterlife_visionset == 0 )
	{
		visionset_mgr::activate( "visionset", "afterlife", self );
		//visionset_mgr::activate( "overlay", "afterlife_filter", self );
		self.afterlife_visionset = 1;
	}
	self util::clientnotify( "al_e" );
	self FreezeControls( 0 );
	self thread zm_player_fake_death_cleanup();
	self thread af_make_waypoint();
	self.old_charactertype = self GetCharacterBodyType();
	self SetCharacterBodyType(4);
	self.dontspeak = true;
	self.ghost_fx_link = Spawn("script_model",self.origin);
	self.ghost_fx_link SetModel("tag_origin");
	self.ghost_fx_link LinkTo( self, "tag_origin");
	//PlayFXOnTag(level._effect["afterlife_ghost_fx"],self.ghost_fx_link, "tag_origin");
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 0 );
	self thread afterlife_doors_open();
	self thread af_jump_logic();
	self clientfield::set_to_player( "player_in_afterlife", 1 );
	self clientfield::set( "player_afterlife_fx", 2 );
	self afterlife_create_mana_bar( self.e_afterlife_corpse );
	if ( !isdefined( self.keep_perks ) && level flag::get( "afterlife_start_over" ) )
	{
		self zm_laststand::increment_downed_stat();
	}
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	foreach(struct in a_afterlife_triggers) {
		struct.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
	}
	a_exterior_goals = struct::get_array( "exterior_goal", "targetname" );
	foreach(struct in a_exterior_goals) {
		if ( isdefined( struct.unitrigger_stub ) )
		{
			struct.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
		}
	}
}

function afterlife_leave( b_revived )
{
	if ( !isdefined( b_revived ) )
	{
		b_revived = 1;
	}
	self util::clientnotify( "al_t" );
	if ( isdefined( self.afterlife_visionset ) && self.afterlife_visionset )
	{
		visionset_mgr::deactivate( "visionset", "afterlife", self );
		//visionset_mgr::deactivate( "overlay", "afterlife_filter", self ); 
		self.afterlife_visionset = 0;
	}
	if(isdefined(self.progressBar))
	{
		self.progressBar hud::destroyElem(); 
		self.progressText hud::destroyElem();
		self.progressBar Destroy();
		self.progressText Destroy();
	}
	self util::clientnotify( "al_l" );
	self.dontspeak = 0;
	self.ghost_fx_link Delete();
	self thread afterlife_doors_close();
	self.health = self.maxhealth;
	self clientfield::set_to_player( "player_in_afterlife", 0 );
	self clientfield::set( "player_afterlife_fx", 1 );
	self clientfield::set_to_player( "clientfield_afterlife_audio", 0 );
	self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self AllowStand( 1 );
	self AllowCrouch( 1 );
	self AllowProne( 1 );
	self AllowSlide( 1 );
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 1 );
	self SetCharacterBodyType(self.old_charactertype);
	self.af_wp hud::destroyElem(); 
	self.af_wp Destroy();
	
	if ( self.e_afterlife_corpse.revivetrigger.origin != self.e_afterlife_corpse.origin )
	{
		self SetOrigin( self.e_afterlife_corpse.revivetrigger.origin );
	}
	else
	{
		self SetOrigin( self.e_afterlife_corpse.origin );
	}
	if ( isdefined( level.e_gondola ) )
	{
		a_gondola_doors_gates = zm_prison_travel::get_gondola_doors_and_gates();
		i = 0;
		while ( i < a_gondola_doors_gates.size )
		{
			if ( self.e_afterlife_corpse IsTouching( a_gondola_doors_gates[ i ] ) )
			{
				if ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
				{
					str_location = level.e_gondola.destination;
				}
				else
				{
					str_location = level.e_gondola.location;
				}
				a_s_orgs = struct::get_array( "gondola_dropped_parts_" + str_location, "targetname" );
				foreach(struct in a_s_orgs) {
					if ( !PositionWouldTelefrag( struct.origin ) )
					{
						self SetOrigin( struct.origin );
						break;
					}
				}
			}
			else i++;	
		}
	}
	self SetPlayerAngles( self.e_afterlife_corpse.angles );
	self.afterlife = 0;
	self afterlife_laststand_cleanup( self.e_afterlife_corpse );
	if ( isdefined( b_revived ) && !b_revived )
	{
		self afterlife_remove( 1 );
		while(!self laststand::player_is_in_laststand())
		{
			self DoDamage(self.health + 10000, self.origin);
			wait 0.05;
		}
	}
	reset_all_afterlife_unitriggers();
	wait 1;
	self.ignoreme = 0;
	wait 3;
	self DisableInvulnerability();
}

function af_make_waypoint()
{
	if ( !level flag::get( "afterlife_start_over" ) )
	{
		self.af_wp = NewClientHudElem(self);	 
	}
	else
	{
		self.af_wp = NewHudElem();	 
	}
	self.af_wp SetWayPoint( true, "afterlife_logo_waypoint" );
	self.af_wp.x = self.e_afterlife_corpse.origin[0];
	self.af_wp.y = self.e_afterlife_corpse.origin[1];
	self.af_wp.z = self.e_afterlife_corpse.origin[2]+30; 
}

function afterlife_laststand( b_electric_chair, neworigin )
{
	if ( !isdefined( b_electric_chair ) )
	{
		b_electric_chair = 0;
	}
	self endon( "disconnect" );
	self endon( "afterlife_bleedout" );
	level endon( "end_game" );
	if ( isdefined( level.afterlife_laststand_override ) )
	{
		self thread [[ level.afterlife_laststand_override ]]( b_electric_chair );
		return;
	}
	self.dontspeak = true;
	self.health = 1000;
	if(!isdefined(neworigin))
	{
		neworigin = self.origin;
	}
	b_has_electric_cherry = 0;
	if(level flag::get("afterlife_start_over") && !b_electric_chair)
	{
		level notify( "fake_death" );
		self notify( "fake_death" );
		stance = self GetStance();
		self.ignoreme = 1;
		self EnableInvulnerability();
		//self TakeAllWeapons();
		//self thread fall_down( (0,0,0), stance);
	}
	if ( self HasPerk( "specialty_electriccherry" ) )
	{
		b_has_electric_cherry = 1;
	}
	self [[ level.afterlife_save_loadout ]]();
	self afterlife_fake_death();
	if ( isdefined( b_electric_chair ) && !b_electric_chair )
	{
		wait 1;
	}
	if ( isdefined( b_has_electric_cherry ) && b_has_electric_cherry && isdefined( b_electric_chair ) && !b_electric_chair )
	{
		self zm_perk_electric_cherry::electric_cherry_laststand();
		wait 2;
	}
	self clientfield::set_to_player( "clientfield_afterlife_audio", 1 );
	if ( level flag::get( "afterlife_start_over" ) )
	{
		self util::clientnotify( "al_t" );
		wait 1;
		self thread lui::screen_flash( 0.5, 1, 0.5, 1, "white" );
		//self AllowStand(1);
		//self AllowCrouch(1);
		//wait 0.1;
		//self SetStance("stand");
		wait 0.5;
		self PlaySoundToPlayer( "zmb_afterlife_start", self );
		self FreezeControls( 0 );
		self SetStance("stand");
		wait 0.1;
		self FreezeControls( 1 );
	}
	self Ghost();
	self.e_afterlife_corpse = self afterlife_spawn_corpse( neworigin );
	self thread afterlife_clean_up_on_disconnect();
	self notify( "player_fake_corpse_created" );
	self afterlife_fake_revive();
	self afterlife_enter();
	self.e_afterlife_corpse clientfield::set( "player_corpse_id", self GetEntityNumber() + 1 );
	wait 0.5;
	//self SetStance("stand");
	self Show();
	self FreezeControls( 0 );
	self DisableInvulnerability();
	self.e_afterlife_corpse waittill( "player_revived", e_reviver );
	self.e_afterlife_corpse.revive_hud Destroy();
	self thread lui::screen_flash( 0.1, 0.5, 0.5, 1, "black" );
	self notify ("afterlife_over");
	//self waittill( "player_revived");
	self SetEverHadWeaponAll( 1 );
	self EnableInvulnerability();
	self.afterlife_revived = 1;
	self EnableWeapons();
	PlaySoundAtPosition( "zmb_afterlife_spawn_leave", self.e_afterlife_corpse.origin );
	self PlaySound( "zmb_afterlife_end" );
	self thread afterlife_revive_invincible();
	self afterlife_leave();
	self PlaySound( "zmb_afterlife_revived_gasp" );
}

function afterlife_clean_up_on_disconnect()
{
	e_corpse = self.e_afterlife_corpse;
	e_corpse endon( "death" );
	self waittill( "disconnect" );
	if ( isdefined( e_corpse.revivetrigger ) )
	{
		e_corpse notify( "stop_revive_trigger" );
		e_corpse.revivetrigger Delete();
		e_corpse.revivetrigger = undefined;
	}
	e_corpse clientfield::set( "player_corpse_id", 0 );
	util::wait_network_frame();
	util::wait_network_frame();
	e_corpse.weaponmodel Delete();
	e_corpse Delete();
}

function afterlife_revive_invincible()
{
	self endon( "disconnect" );
	wait 2;
	self DisableInvulnerability();
	self SetEverHadWeaponAll( 0 );
	self.afterlife_revived = undefined;
}

function afterlife_laststand_cleanup( corpse )
{
	self [[ level.afterlife_give_loadout ]]();
	self afterlife_corpse_cleanup( corpse );
}

function afterlife_create_mana_bar( corpse )
{
	if ( self.afterliferound == level.round_number )
	{
		if ( !isdefined( self.keep_perks ) || self.afterlifedeaths == 0 )
		{
			self.afterlifedeaths++;
		}
	}
	else
	{
		self.afterliferound = level.round_number;
		self.afterlifedeaths = 1;
	}
	self.manacur = 200;
	self thread afterlife_mana_watch( corpse );
	self thread afterlife_lightning_watch( corpse );
	self thread afterlife_jump_watch( corpse );
}

function afterlife_infinite_mana( b_infinite )
{
	if ( !isdefined( b_infinite ) )
	{
		b_infinite = 1;
	}
	if ( isdefined( b_infinite ) && b_infinite )
	{
		self.infinite_mana = 1;
	}
	else
	{
		self.infinite_mana = 0;
	}
}

function afterlife_mana_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( self.manacur > 0 )
	{
		wait 0.05;
		self afterlife_reduce_mana( 0.05 * self.afterlifedeaths * 3 );
		if ( self.manacur < 0 )
		{
			self.manacur = 0;
		}
		n_mapped_mana = math::linear_map( self.manacur, 0, 200, 0, 1 );
		self clientfield::set_to_player( "player_afterlife_mana", n_mapped_mana );
	}
	self thread lui::screen_flash( 0.1, 0.5, 0.5, 1, "black" );
	if ( isdefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
		{
			wait 0.05;
		}
	}
	corpse notify( "stop_revive_trigger" );
	
	wait 0.5;
	self notify( "out_of_mana" );
	self afterlife_leave( 0 );
}

function afterlife_doors_open()
{
	n_network_sent = 0;
	a_show = GetEntArray( "afterlife_show", "targetname" );
	a_show = ArrayCombine( a_show, GetEntArray( "afterlife_prop", "script_noteworthy" ), 0, 0 );
	foreach(ent in a_show) {
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			util::wait_network_frame();
		}
		if ( isdefined( ent ) )
		{
			ent SetVisibleToPlayer( self );
		}
	}
	a_hide = GetEntArray( "afterlife_door", "targetname" );
	a_hide = ArrayCombine( a_hide, GetEntArray( "zombie_door", "targetname" ), 0, 0 );
	a_hide = ArrayCombine( a_hide, GetEntArray( "quest_trigger", "script_noteworthy" ), 0, 0 );
	a_hide = ArrayCombine( a_hide, GetEntArray( "trap_trigger", "script_noteworthy" ), 0, 0 );
	a_hide = ArrayCombine( a_hide, GetEntArray( "travel_trigger", "script_noteworthy" ), 0, 0 );
	foreach(ent in a_hide) {
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			util::wait_network_frame();
		}
		if ( isdefined( ent ) )
		{
			ent SetInvisibleToPlayer( self );
		}
	}
	if ( isdefined( self.claymores ) )
	{
		foreach(claymore in self.claymores) {
			if ( isdefined( claymore.pickuptrigger ) )
			{
				claymore.pickuptrigger SetInvisibleToPlayer( self );
			}
		}
	}
}

function afterlife_doors_close()
{
	n_network_sent = 0;
	a_hide = GetEntArray( "afterlife_show", "targetname" );
	a_hide = ArrayCombine( a_hide, GetEntArray( "afterlife_prop", "script_noteworthy" ), 0, 0 );
	_a943 = a_hide;
	_k943 = GetFirstArrayKey( _a943 );
	while ( isdefined( _k943 ) )
	{
		ent = _a943[ _k943 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			util::wait_network_frame();
		}
		if ( isdefined( ent ) )
		{
			ent SetInvisibleToPlayer( self );
		}
		_k943 = GetNextArrayKey( _a943, _k943 );
	}
	a_show = GetEntArray( "afterlife_door", "targetname" );
	a_show = ArrayCombine( a_show, GetEntArray( "zombie_door", "targetname" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "quest_trigger", "script_noteworthy" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "trap_trigger", "script_noteworthy" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "travel_trigger", "script_noteworthy" ), 0, 0 );
	_a962 = a_show;
	_k962 = GetFirstArrayKey( _a962 );
	while ( isdefined( _k962 ) )
	{
		ent = _a962[ _k962 ];
		n_network_sent++;
		if ( n_network_sent > 10 )
		{
			n_network_sent = 0;
			util::wait_network_frame();
		}
		if ( isDefined( ent ) )
		{
			ent SetVisibleToPlayer( self );
		}
		_k962 = GetNextArrayKey( _a962, _k962 );
	}
	if ( isdefined( self.claymores ) )
	{
		_a979 = self.claymores;
		_k979 = GetFirstArrayKey( _a979 );
		while ( isdefined( _k979 ) )
		{
			claymore = _a979[ _k979 ];
			if ( isdefined( claymore.pickuptrigger ) )
			{
				claymore.pickuptrigger SetVisibleToPlayer( self );
			}
			_k979 = GetNextArrayKey( _a979, _k979 );
		}
	}
}

function afterlife_corpse_cleanup( corpse )
{
	PlaySoundAtPosition( "zmb_afterlife_revived", corpse.origin );
	if ( isdefined( corpse.revivetrigger ) )
	{
		corpse notify( "stop_revive_trigger" );
		corpse.revivetrigger Delete();
		corpse.revivetrigger = undefined;
	}
	corpse clientfield::set( "player_corpse_id", 0 );
	corpse afterlife_corpse_remove_pois();
	util::wait_network_frame();
	util::wait_network_frame();
	corpse.weaponmodel Delete();
	corpse Delete();
	self.e_afterlife_corpse = undefined;
}

function afterlife_spawn_corpse( neworigin )
{
	if(!isdefined(neworigin))
	{
		neworigin = self.origin;
	}

	// drop corpse origin to floor (in case of jump)
	trace = bullettrace( neworigin, neworigin + (0,0,-256), false, undefined );
	ground_pos = trace["position"];
	if( isdefined(ground_pos) )
	{
		neworigin = ( neworigin[0], neworigin[1], ground_pos[2] );
	}


	if ( isdefined( self.is_on_gondola ) && self.is_on_gondola && level.e_gondola.destination == "roof" )
	{
		corpse = zm_alcatraz_sq::spawn_player_clone( self, neworigin, undefined );
	}
	else
	{
		trace_start = neworigin;
		trace_end = neworigin + VectorScale( ( 0, 0, 1 ), 500 );
		corpse_trace = PlayerPhysicsTrace( trace_start, trace_end );
		corpse = zm_alcatraz_sq::spawn_player_clone( self, neworigin, undefined );
	}
	corpse.angles = self.angles;
	corpse.ignoreme = 1;
	corpse.weaponmodel = corpse zm_alcatraz_sq::clone_give_weapon( "bo3_m1911" );
	corpse zm_alcatraz_sq::clone_animate( "afterlife" );
	corpse.revive_hud = self afterlife_revive_hud_create();
	corpse thread afterlife_revive_trigger_spawn( self);
	if ( level flag::get( "solo_game" ) )
	{
		corpse thread afterlife_corpse_create_pois();
	}
	return corpse;
}

function afterlife_corpse_create_pois()
{
	/*n_attractors = Ceil( zombie_utility::get_current_zombie_count() / 3 );
	if ( n_attractors < 4 )
	{
		n_attractors = 4;
	}
	a_nodes = afterlife_corpse_get_array_poi_positions();
	self.pois = [];
	while ( isdefined( a_nodes ) && a_nodes.size > 3 )
	{
		i = 0;
		while ( i < 3 )
		{
			self.pois[ i ] = afterlife_corpse_create_poi( a_nodes[ i ].origin, n_attractors );
			wait 0.05;
			i++;
		}
	}*/
}

function afterlife_corpse_create_poi( v_origin, n_attractors )
{
	e_poi = Spawn( "script_origin", v_origin );
	e_poi zm_utility::create_zombie_point_of_interest( 10000, 24, 5000, 1 );
	e_poi thread zm_utility::create_zombie_point_of_interest_attractor_positions();

	return e_poi;
}

function afterlife_corpse_remove_pois()
{
	/*if ( !isdefined( self.pois ) )
	{
		return;
	}
	i = 0;
	while ( i < self.pois.size )
	{
		zm_utility::remove_poi_attractor( self.pois[ i ] );
		self.pois[ i ] Delete();
		i++;
	}
	self.pois = undefined;*/
}

function afterlife_corpse_get_array_poi_positions()
{
	n_ideal_dist_sq = 490000;
	a_nodes = GetAnyNodeArray( self.origin, 1200 );
	i = 0;
	while ( i < a_nodes.size )
	{
		if ( !a_nodes[ i ] is_valid_teleport_node() )
		{
		}
		i++;
	}
	a_nodes = array::remove_undefined( a_nodes, false );
	return array::randomize( a_nodes );
}

function afterlife_revive_hud_create()
{
	self.revive_hud = NewClientHudElem( self );
	self.revive_hud.alignx = "center";
	self.revive_hud.aligny = "middle";
	self.revive_hud.horzalign = "center";
	self.revive_hud.vertalign = "bottom";
	self.revive_hud.y = -160;
	self.revive_hud.foreground = 1;
	self.revive_hud.font = "default";
	self.revive_hud.fontscale = 1.5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 1, 1, 1 );
	self.revive_hud.hidewheninmenu = 1;
	self.revive_hud SetText( "" );
	return self.revive_hud;
}

function afterlife_revive_trigger_spawn( player )
{
	radius = GetDvarInt( "revive_trigger_radius" );
	self.revivetrigger = Spawn( "trigger_radius", ( 0, 0, 1 ), 0, radius, radius );
	self.revivetrigger SetHintString( "" );
	self.revivetrigger SetCursorHint( "HINT_NOICON" );
	self.revivetrigger SetMovingPlatformEnabled( 1 );
	self.revivetrigger EnableLinkTo();
	self.revivetrigger.origin = self.origin;
	self.revivetrigger LinkTo( self );
	self.revivetrigger.beingrevived = 0;
	self.revivetrigger.createtime = GetTime();
	self thread afterlife_revive_trigger_think();
}

/*function afterlife_revive_trigger_think( person )
{
	person endon( "disconnect" );
	self.revivetrigger endon( "stop_revive_trigger" );
	person endon( "death" );
	wait 1;
	while(isdefined(self.revivetrigger))
	{
		self.revivetrigger SetHintString( "Press and Hold ^3&&1^7 to Revive" ); 
		self.revivetrigger waittill( "trigger", player ); 
		if(player UseButtonPressed())
		{
			self.revivetrigger SetHintString( "" );
			success = player revive_progress( self.revivetrigger ); 
			if(success)
			{
				revived = true;
				self.e_afterlife_corpse notify( "player_revived", player );
				self notify( "player_revived" , player);
				person notify ("afterlife_over");
				person thread lui::screen_flash( 0.1, 0.5, 0.5, 1, "black" );	
				player AllowProne( true );      
				player AllowMelee( true );
				player AllowAds( true );
				self.revivetrigger.beingrevived = 0;
				break;
			}
		}
		if(isdefined(self.revivetrigger.beingrevived))
		{
			self.revivetrigger.beingrevived = 0;
		}
		wait 0.05;
	}
}*/

function afterlife_revive_trigger_think()
{
	self endon( "disconnect" );
	self endon( "stop_revive_trigger" );
	self endon( "death" );
	wait 1;
	while ( 1 )
	{
		wait 0.1;
		self.revivetrigger SetHintString( "" );
		players = GetPlayers();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] afterlife_can_revive( self ) )
			{
				self.revivetrigger SetReviveHintString( &"GAME_BUTTON_TO_REVIVE_PLAYER", self.team );
				break;
			}
			else
			{
				i++;
			}
		}
		i = 0;
		while ( i < players.size )
		{
			reviver = players[ i ];
			if ( self == reviver || !reviver is_reviving_afterlife( self ) )
			{
				i++;
				continue;
			}
			else
			{
				gun = reviver GetCurrentWeapon();
/#
				assert( isdefined( gun ) );
#/
				if ( gun == level.revive_tool || gun == level.afterlife_revive_tool )
				{
					i++;
					continue;
				}
				else
				{
					if ( isdefined( reviver.afterlife ) && reviver.afterlife )
					{
						reviver GiveWeapon( level.afterlife_revive_tool );
						reviver SwitchToWeapon( level.afterlife_revive_tool );
						reviver SetWeaponAmmoStock( level.afterlife_revive_tool, 1 );
					}
					else
					{
						reviver GiveWeapon( level.weaponReviveTool );
						reviver SwitchToWeapon( level.weaponReviveTool );
						reviver SetWeaponAmmoStock( level.weaponReviveTool, 1 );
					}
					revive_success = reviver afterlife_revive_do_revive( self, gun );
					reviver zm_laststand::revive_give_back_weapons( gun );
					if ( IsPlayer( self ) )
					{
						self AllowJump( 1 );
					}
					self.laststand = undefined;
					if ( revive_success )
					{
						self notify( "player_revived" , reviver);
						self thread zm_laststand::revive_success( reviver );
						self laststand::cleanup_suicide_hud();
						return;
					}
				}
			}
			i++;
		}
	}
}

function revive_progress( trigger )
{
	self begin_revive(); 
	if(isdefined(self.progressBar))
	{
		self.progressBar hud::destroyElem();
		self.progressText hud::destroyElem(); 
		self.progressBar Destroy();
		self.progressText Destroy();
	}
	self.progressBar = self hud::createPrimaryProgressBar();
	revivetime = 3;
	if(isdefined(self.afterlife) && self.afterlife)
	{
		revivetime = 1;
	}
	self.progressBar hud::updateBar( .01, 1 / revivetime );
	self.progressText = self hud::createPrimaryProgressBarText();
	self.progressText SetText( "Reviving..." );
	time = 0;
	trigger.beingrevived = 1;
	while( self UseButtonPressed() )
	{
		time += .05;
		wait .05;
		if( time >= revivetime )
		{
			self.progressBar hud::destroyElem(); 
			self.progressText hud::destroyElem(); 
			self.progressBar Destroy();
			self.progressText Destroy();
			wait(0.05);  
			self end_revive(); 
			return true; 
		}
	}
	self.progressBar hud::destroyElem(); 
	self.progressText hud::destroyElem();
	self.progressBar Destroy();
	self.progressText Destroy();
	wait(0.05);  
	self end_revive(); 
	return false;
}

function begin_revive()
{
	self.old_weap = self GetCurrentWeapon(); 
	if(self.afterlife == true)
	{
		gun = GetWeapon("bo2_af_revive");
	}
	else 
	{
		gun = level.weaponReviveTool;
	}
	self GiveWeapon( gun ); 
	self SwitchToWeaponImmediate( gun );
	self SetStance( "stand" );
	wait(0.1); 
	self DisableWeaponCycling(); 
	self DisableOffhandWeapons(); 
}

function end_revive()
{
	self TakeWeapon( level.weaponReviveTool );
	self TakeWeapon( GetWeapon("bo2_af_revive") ); 
	self SwitchToWeapon( self.old_weap ); 
	self EnableWeaponCycling(); 
	self EnableOffhandWeapons();
}

function afterlife_can_revive( revivee )
{
	if ( !IsAlive( self ) )
	{
		return 0;
	}
	if ( self laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( self zm_utility::has_powerup_weapon() )
	{
		return 0;
	}
	ignore_sight_checks = 0;
	ignore_touch_checks = 0;
	if ( isdefined( level.revive_trigger_should_ignore_sight_checks ) )
	{
		ignore_sight_checks = [[ level.revive_trigger_should_ignore_sight_checks ]]( self );
		if ( ignore_sight_checks && isdefined( revivee.revivetrigger.beingrevived ) && revivee.revivetrigger.beingrevived == 1 )
		{
			ignore_touch_checks = 1;
		}
	}
	if ( !ignore_touch_checks )
	{
		if ( !self IsTouching( revivee.revivetrigger ) )
		{
			return 0;
		}
	}
	if( !ignore_sight_checks )
	{
		if ( !self laststand::is_facing( revivee ) )
		{
			return false;
		}

		if ( !SightTracePassed( self.origin + ( 0, 0, 50 ), revivee.origin + ( 0, 0, 30 ), false, undefined ) )				
		{
			return false;
		}

		//chrisp - fix issue where guys can sometimes revive thru a wall	
		if ( !BulletTracePassed( self.origin + (0, 0, 50), revivee.origin + (0, 0, 30), false, undefined ) )
		{
			return false;
		}	
	}
	return 1;
}

function afterlife_revive_do_revive( playerbeingrevived, revivergun )
{
/#
	assert( self is_reviving_afterlife( playerbeingrevived ) );
#/
	revivetime = 3;
	playloop = 0;
	if ( isdefined( self.afterlife ) && self.afterlife )
	{
		playloop = 1;
		revivetime = 1;
	}
	timer = 0;
	revived = 0;
	playerbeingrevived.revivetrigger.beingrevived = 1;
	playerbeingrevived.revive_hud SetText( &"GAME_PLAYER_IS_REVIVING_YOU", self );
	playerbeingrevived laststand::revive_hud_show_n_fade( 3 );
	playerbeingrevived.revivetrigger SetHintString( "" );
	if ( IsPlayer( playerbeingrevived ) )
	{
		playerbeingrevived StartRevive( self );
	}
	if ( !isdefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar = self hud::createprimaryprogressbar();
	}
	if ( !isdefined( self.revivetexthud ) )
	{
		self.revivetexthud = NewClientHudElem( self );
	}
	self thread revive_clean_up_on_gameover();
	self thread zm_laststand::laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );
	if ( !isdefined( self.is_reviving_any ) )
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread zm_laststand::laststand_clean_up_reviving_any( playerbeingrevived );
	self.reviveprogressbar hud::updatebar( 0.01, 1 / revivetime );
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if ( self IsSplitScreen() )
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1.8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = ( 1, 1, 1 );
	self.revivetexthud.hidewheninmenu = 1;
	if ( isdefined( self.pers_upgrades_awarded[ "revive" ] ) && self.pers_upgrades_awarded[ "revive" ] )
	{
		self.revivetexthud.color = ( 0.5, 0.5, 1 );
	}
	self.revivetexthud SetText( &"GAME_REVIVING" );
	self thread zm_laststand::check_for_failed_revive( playerbeingrevived );
	e_fx = Spawn( "script_model", playerbeingrevived.revivetrigger.origin );
	e_fx SetModel( "tag_origin" );
	e_fx thread revive_fx_clean_up_on_disconnect( playerbeingrevived );
	PlayFXOnTag( level._effect[ "afterlife_leave" ], e_fx, "tag_origin" );
	if ( isdefined( playloop ) && playloop )
	{
		e_fx PlayLoopSound( "zmb_afterlife_reviving", 0.05 );
	}
	while ( self is_reviving_afterlife( playerbeingrevived ) )
	{
		wait 0.05;
		timer += 0.05;
		if ( self laststand::player_is_in_laststand() )
		{
			break;
		}
		else if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
		{
			break;
		}
		else
		{
			if ( timer >= revivetime )
			{
				revived = 1;
				break;
			}
			else
			{
			}
		}
	}
	e_fx Delete();
	if ( isdefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar hud::destroyelem();
	}
	if ( isdefined( self.revivetexthud ) )
	{
		self.revivetexthud Destroy();
	}
	if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
	{
	}
	else if ( !revived )
	{
		if ( IsPlayer( playerbeingrevived ) )
		{
			playerbeingrevived StopRevive( self );
		}
	}
	playerbeingrevived.revivetrigger SetHintString( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	playerbeingrevived.revivetrigger.beingrevived = 0;
	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;

	if ( !revived )
	{
		playerbeingrevived thread zm_laststand::checkforbleedout( self );
	}
	return revived;
}

function revive_fx_clean_up_on_disconnect( e_corpse )
{
	self endon( "death" );
	e_corpse waittill( "disconnect" );
	self Delete();
}

function revive_clean_up_on_gameover()
{
	self endon( "do_revive_ended_normally" );
	level waittill( "end_game" );
	if ( isdefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar hud::destroyelem();
	}
	if ( isdefined( self.revivetexthud ) )
	{
		self.revivetexthud Destroy();
	}
}

function is_reviving_afterlife( revivee )
{
	if ( self UseButtonPressed() )
	{
		return afterlife_can_revive( revivee );
	}
	else
	{
		return 0;
	}
}

function afterlife_save_loadout()
{
	primaries = self GetWeaponsListPrimaries();
	currentweapon = self GetCurrentWeapon();
	self.loadout = SpawnStruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = 0;
	_a1516 = primaries;
	index = GetFirstArrayKey( _a1516 );
	while ( isdefined( index ) )
	{
		weapon = _a1516[ index ];
		self.loadout.weapons[ index ] = weapon;
		self.loadout.stockcount[ index ] = self GetWeaponAmmoStock( weapon );
		self.loadout.clipcount[ index ] = self GetWeaponAmmoClip( weapon );
		if ( isdefined( weapon.dualwieldweapon ) )
		{
			weapon_dw = weapon.dualwieldweapon;
			self.loadout.clipcount2[ index ] = self GetWeaponAmmoClip( weapon_dw );
		}
		weapon_alt = weapon.altWeapon ;
		if ( isdefined( weapon_alt) && weapon_alt != "none" )
		{
			self.loadout.stockcountalt[ index ] = self GetWeaponAmmoStock( weapon_alt );
			self.loadout.clipcountalt[ index ] = self GetWeaponAmmoClip( weapon_alt );
		}
		if ( weapon == currentweapon )
		{
			self.loadout.current_weapon = index;
		}
		index = GetNextArrayKey( _a1516, index );
	}
	if (IS_TRUE(self.hasriotshield))
	{
		shield_health = self DamageRiotShield(0);
		shield_damage = level.weaponRiotshield.weaponstarthitpoints - shield_health;

		self.loadout.shielddamage = shield_damage;
		//IPrintLnBold("dmg: " + self.loadout.shielddamage);
	}
	self.loadout.equipment = self zm_equipment::get_player_equipment();
	if ( isdefined( self.loadout.equipment ) )
	{
		self zm_equipment::take( self.loadout.equipment );
	}
	if ( self HasWeapon( GetWeapon("claymore") ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self GetWeaponAmmoClip( GetWeapon("claymore") );
	}
	if ( self HasWeapon( GetWeapon("emp_grenade") ) )
	{
		self.loadout.hasemp = 1;
		self.loadout.empclip = self GetWeaponAmmoClip( GetWeapon("emp_grenade") );
	}
	if ( self HasWeapon( GetWeapon("zombie_tomahawk") ) || self HasWeapon( GetWeapon("zombie_tomahawk_upgraded") ) )
	{
		self.loadout.hastomahawk = 1;
		self clientfield::set_to_player( "tomahawk_in_use", 0 );
	}
	if ( self HasWeapon( GetWeapon("spoon_alcatraz") ) )
	{
		self.loadout.hasspoon = 1;
	}
	if ( self HasWeapon( GetWeapon("spork_alcatraz") ) )
	{
		self.loadout.hasspork = 1;
	}
	self.loadout.perks = afterlife_save_perks( self );
	lethal_grenade = self zm_utility::get_player_lethal_grenade();
	if ( self HasWeapon( lethal_grenade ) )
	{
		self.loadout.grenade = self GetWeaponAmmoClip( lethal_grenade );
	}
	else
	{
		self.loadout.grenade = 0;
	}
	self.loadout.lethal_grenade = lethal_grenade;
	self zm_utility::set_player_lethal_grenade( undefined );
}

function afterlife_give_loadout()
{
	self TakeAllWeapons();
	loadout = self.loadout;
	primaries = self GetWeaponsListPrimaries();
	if ( loadout.weapons.size > 1 || primaries.size > 1 )
	{
		_a1601 = primaries;
		_k1601 = GetFirstArrayKey( _a1601 );
		while ( isdefined( _k1601 ) )
		{
			weapon = _a1601[ _k1601 ];
			self TakeWeapon( weapon );
			_k1601 = GetNextArrayKey( _a1601, _k1601 );
		}
	}
	i = 0;
	while ( i < loadout.weapons.size )
	{
		if ( !isdefined( loadout.weapons[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( loadout.weapons[ i ] == "none" )
		{
			i++;
			continue;
		}
		else
		{
			weapon = loadout.weapons[ i ];
			stock_amount = loadout.stockcount[ i ];
			clip_amount = loadout.clipcount[ i ];
			if ( !self HasWeapon( weapon ) )
			{
				weapon = self zm_weapons::give_build_kit_weapon( weapon );
				self notify( "weapon_give", weapon );
				self zm_weapons::get_pack_a_punch_weapon_options( weapon );
				self SetWeaponAmmoStock( weapon, stock_amount );
				self SetWeaponAmmoClip( weapon, clip_amount );
				if ( isdefined( weapon.dualwieldweapon ) )
				{
					weapon_dw = weapon.dualwieldweapon;
					self SetWeaponAmmoClip( weapon_dw, loadout.clipcount2[ i ] );
				}
				weapon_alt = weapon.altWeapon ;
				if ( isdefined(weapon_alt) && weapon_alt != "none" )
				{
					self SetWeaponAmmoStock( weapon_alt, loadout.stockcountalt[ i ] );
					self SetWeaponAmmoClip( weapon_alt, loadout.clipcountalt[ i ] );
				}
			}
		}
		i++;
	}
	if ( isdefined( self zm_utility::get_player_melee_weapon() ) )
	{
		self GiveWeapon( self zm_utility::get_player_melee_weapon() );
	}
	self SwitchToWeaponImmediate( loadout.weapons[ loadout.current_weapon ] );
	
	self zm_equipment::give( self.loadout.equipment );
	if ( isdefined( loadout.hasclaymore ) && loadout.hasclaymore && !self HasWeapon( GetWeapon("claymore") ) )
	{
		self GiveWeapon( GetWeapon("claymore") );
		self zm_utility::set_player_placeable_mine( GetWeapon("claymore") );
		self SetActionSlot( 4, "weapon", GetWeapon("claymore") );
		self SetWeaponAmmoClip( GetWeapon("claymore"), loadout.claymoreclip );
	}
	if ( isdefined( loadout.hasemp ) && loadout.hasemp )
	{
		self GiveWeapon( GetWeapon("emp_grenade") );
		self SetWeaponAmmoClip( GetWeapon("emp_grenade"), loadout.empclip );
	}
	if ( isdefined( loadout.hastomahawk ) && loadout.hastomahawk )
	{
		self GiveWeapon( GetWeapon(self.current_tomahawk_weapon) );
		self zm_utility::set_player_tactical_grenade( GetWeapon(self.current_tomahawk_weapon) );
		self clientfield::set_to_player( "tomahawk_in_use", 1 );
	}
	if ( isdefined( loadout.hasspoon ) && loadout.hasspoon )
	{
		self TakeWeapon( self zm_utility::get_player_melee_weapon() );
		self GiveWeapon( GetWeapon("spoon_alcatraz") );
	}
	if ( isdefined( loadout.hasspork ) && loadout.hasspork )
	{
		self TakeWeapon( self zm_utility::get_player_melee_weapon() );
		self GiveWeapon( GetWeapon("spork_alcatraz") );
	}
	if (isdefined( loadout.shielddamage ) && loadout.shielddamage)
	{
		// restore shield health
		//IPrintLnBold("damaging shield: " + loadout.shielddamage);
		self DamageRiotShield(loadout.shielddamage);
		self riotshield::player_set_shield_health(loadout.shielddamage, 1500);
	}
	self.score = loadout.score;
	perk_array = self zm_perks::get_perk_array();
	i = 0;
	while ( i < perk_array.size )
	{
		perk = perk_array[ i ];
		perk_str = perk + "_stop";
		self notify( perk_str );
		i++;
	}
	if ( isdefined( self.keep_perks ) && self.keep_perks && isdefined( loadout.perks ) && loadout.perks.size > 0 )
	{
		i = 0;
		while ( i < loadout.perks.size )
		{
			if ( self HasPerk( loadout.perks[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( loadout.perks[ i ] == "specialty_quickrevive" && level flag::get( "solo_game" ) )
			{
				level.solo_game_free_player_quickrevive = 1;
			}
			else
			{
				zm_perks::give_perk( loadout.perks[ i ] );
			}
			i++;
		}
	}
	self.keep_perks = undefined;
	self zm_utility::set_player_lethal_grenade( self.loadout.lethal_grenade );
	if ( loadout.grenade > 0 )
	{
		curgrenadecount = 0;
		if ( self HasWeapon( self zm_utility::get_player_lethal_grenade() ) )
		{
			self GetWeaponAmmoClip( self zm_utility::get_player_lethal_grenade() );
		}
		else
		{
			self GiveWeapon( self zm_utility::get_player_lethal_grenade() );
		}
		self SetWeaponAmmoClip( self zm_utility::get_player_lethal_grenade(), loadout.grenade + curgrenadecount );
	}
	wait 0.1;
	self SwitchToWeaponImmediate( loadout.weapons[ loadout.current_weapon ] );
}

function afterlife_fake_death()
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	self TakeAllWeapons();
	/*self AllowStand( 0 );
	self AllowCrouch( 0 );
	self AllowProne( 1 );*/
	wait 0.1;
	self SetStance( "prone" );
	wait 0.1;
	self FreezeControls( 1 );
	SetDvar("cg_drawgun", 0);
	while ( self zm_utility::is_jumping() )
	{
		wait 0.05;
	}
	PlayFX( level._effect[ "afterlife_enter" ], self.origin );
	self PlaySoundToPlayer( "zmb_afterlife_death", self );
	self.ignoreme = 1;
	self EnableInvulnerability();
}

function afterlife_fake_revive()
{
	PlaySoundAtPosition( "zmb_afterlife_spawn_leave", self.origin );
	if ( level flag::get( "afterlife_start_over" ) )
	{
		spawnpoint = self choose_a_spawn();
		self._fall_down_anchor Delete();
		if(isdefined(spawnpoint)) {
			self SetOrigin( spawnpoint.origin );
			self SetPlayerAngles( spawnpoint.angles );
		}
		PlaySoundAtPosition( "zmb_afterlife_spawn_enter", self.origin );
	}
	else
	{
		PlaySoundAtPosition( "zmb_afterlife_spawn_enter", self.origin );
	}
	self AllowCrouch( 0 );
	self AllowProne( 0 );
	self AllowSlide( 0 );
	self GiveWeapon( GetWeapon("lightning_hands") );
	self SwitchToWeapon( GetWeapon("lightning_hands") );
	self SetStance("stand");
	self zm_score::minus_to_player_score(self.score);
	SetDvar("cg_drawgun", 1);
	wait 1;
	self.ignoreme = 0;
}

function activate_afterlife_spawns()
{
	level.afterlife_spawn_points = []; 

	structs = struct::get_array( "afterlife_spawner_spot", "targetname" ); 
	foreach( point in structs )
	{
		level.afterlife_spawn_points[ level.afterlife_spawn_points.size ] = point;
	}
}

function choose_a_spawn()
{ 
	spot = undefined;
	foreach(spawn in level.afterlife_spawn_points)
	{
		player_zone = zm_zonemgr::get_zone_from_position(self.origin + (0,0,100), true);
		spawn_zone = zm_zonemgr::get_zone_from_position(spawn.origin, true);
		if(player_zone == spawn_zone)
		{
			spot = spawn;
			break;
		}
	}
	return spot;
}

function afterlife_save_perks( ent )
{
	perk_array = ent zm_perks::get_perk_array();
	foreach(perk in perk_array) {
		perk_str = perk + "_stop";
		ent notify( perk_str );
	}
	return perk_array;
}

function afterlife_hostmigration()
{
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		foreach(player in GetPlayers()) {
			self clientfield::set_to_player( "player_lives", self.af_lives );
			if ( isdefined( player.e_afterlife_corpse ) ) {
				player.e_afterlife_corpse clientfield::set( "player_corpse_id", 0 );
			}
		}
		util::wait_network_frame();
		util::wait_network_frame();
		foreach(player in GetPlayers()) {
			if ( isdefined( player.e_afterlife_corpse ) ) {
				player.e_afterlife_corpse clientfield::set( "player_corpse_id", player GetEntityNumber() + 1 );
			}
		}
	}
}

function afterlife_reduce_mana( n_mana )
{
	if ( isdefined( self.afterlife ) && !self.afterlife )
	{
		return;
	}
	if ( isdefined( level.hostmigrationtimer ) )
	{
		return;
	}
	if ( isdefined( self.infinite_mana ) && self.infinite_mana )
	{
		self.manacur = 200;
		return;
	}
/#
	if ( GetDvarInt( "zombie_cheat" ) >= 1 )
	{
		self.manacur = 200;
		return;
	}
#/
	if ( isdefined( self.e_afterlife_corpse ) && isdefined( self.e_afterlife_corpse.revivetrigger.beingrevived ) && self.e_afterlife_corpse.revivetrigger.beingrevived )
	{
		return;
	}
	self.manacur -= n_mana;
}

function afterlife_lightning_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( 1 )
	{
		self waittill( "weapon_fired" );
		self afterlife_reduce_mana( 1 );
		wait 0.05;
	}
}

function afterlife_jump_watch( corpse )
{
	self endon( "death" );
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( 1 )
	{
		if ( self zm_utility::is_jumping() )
		{
			self afterlife_reduce_mana( 0.3 );
			Earthquake( 0.1, 0.05, self.origin, 200, self );
		}
		wait 0.05;
	}
}

function afterlife_trigger_create( s_origin )
{
	s_origin.unitrigger_stub = SpawnStruct();
	s_origin.unitrigger_stub.origin = s_origin.origin;
	s_origin.unitrigger_stub.radius = 36;
	s_origin.unitrigger_stub.height = 256;
	s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	s_origin.unitrigger_stub.hint_string = "Press ^3&&1^7 to enter Afterlife";
	s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_origin.unitrigger_stub.require_look_at = 1;
	s_origin.unitrigger_stub.prompt_and_visibility_func = &afterlife_trigger_visibility;
	zm_unitrigger::unitrigger_force_per_player_triggers( s_origin.unitrigger_stub, 1 );
	zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, &afterlife_trigger_think );
}

function reset_all_afterlife_unitriggers()
{
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	_a2129 = a_afterlife_triggers;
	_k2129 = GetFirstArrayKey( _a2129 );
	while ( isdefined( _k2129 ) )
	{
		struct = _a2129[ _k2129 ];
		zm_unitrigger::unregister_unitrigger( struct.unitrigger_stub );
		zm_unitrigger::register_static_unitrigger( struct.unitrigger_stub, &afterlife_trigger_think );
		_k2129 = GetNextArrayKey( _a2129, _k2129 );
	}
}

function afterlife_trigger_visibility( player )
{
	b_is_invis = player.afterlife;
	self SetInvisibleToPlayer( player, b_is_invis );
	if ( player.af_lives <= 0 )
	{
		self SetHintString( "No Afterlife Remaining" );
	}
	else
	{
		self SetHintString( "Press ^3&&1^7 to enter Afterlife" );
		if ( !isdefined( player.has_played_afterlife_trigger_hint ) && player zm_utility::is_player_looking_at( self.stub.origin, 0.25 ) )
		{
			if ( isdefined( player.dontspeak ) && !player.dontspeak )
			{
				player thread zm_audio::create_and_play_dialog( "general", "killswitch_clue" );
				player.has_played_afterlife_trigger_hint = 1;
			}
		}
	}
	return !b_is_invis;
}

function afterlife_trigger_think()
{
	self endon( "kill_trigger" );
	level flag::wait_till( "start_zombie_round_logic" );
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( player.af_lives <= 0 )
		{
			wait 0.1;
			self PlaySound( "zmb_no_cha_ching" );
			continue;
		}
		if ( player zm_laststand::is_reviving_any() || player laststand::player_is_in_laststand() )
		{
			wait 0.1;
			continue;
		}
		if ( !IS_TRUE(player.afterlife) && player.af_lives > 0)
		{
			self SetInvisibleToPlayer( player, 1 );
			player PlaySound( "zmb_afterlife_trigger_activate" );
			player PlaySoundToPlayer( "zmb_afterlife_trigger_electrocute", player );
			player thread afterlife_trigger_used_vo();
			self SetHintString( "" );
			player.keep_perks = 1;
			player afterlife_remove();
			player.afterlife = 1;
			player thread afterlife_laststand();
			e_fx = Spawn( "script_model", self.origin );
			e_fx SetModel( "tag_origin" );
			e_fx.angles = VectorScale( ( 0, 0, 1 ), 90 );
			PlayFXOnTag( level._effect[ "afterlife_kill_point_fx" ], e_fx, "tag_origin" );
			wait 2;
			e_fx Delete();
			self SetHintString( "Press ^3&&1^7 to enter Afterlife" );
		}
	}
}

function afterlife_interact_object_think()
{
	self endon( "afterlife_interact_complete" );
	level.afterlife_interact_dist = 256;
	if ( isdefined( self.script_int ) && self.script_int > 0 )
	{
		n_total_interact_count = self.script_int;
	}
	else
	{
		if ( !isdefined( self.script_int ) || isdefined( self.script_int ) && self.script_int <= 0 )
		{
			n_total_interact_count = 0;
		}
	}
	n_count = 0;
	self.health = 50000;
	self SetCanDamage(true);
	self UseAnimTree( #animtree );
	self PlayLoopSound( "zmb_afterlife_shockbox_off", 1 );
	if ( !isdefined( level.shockbox_anim ) )
	{
		level.shockbox_anim[ "on" ] = %fxanim_zom_al_shock_box_on_anim;
		level.shockbox_anim[ "off" ] = %fxanim_zom_al_shock_box_off_anim;
	}
	trig_spawn_offset = ( 0, 0, 1 );
	if ( self.model != "p6_anim_zm_al_nixie_tubes" )
	{
		if ( isDefined( self.script_string ) && self.script_string == "intro_powerup_activate" )
		{
			self.t_bump = Spawn( "trigger_radius", self.origin + VectorScale( ( 0, 0, 1 ), 28 ), 0, 28, 64 );
		}
		else
		{
			if ( IsSubStr( self.model, "p6_zm_al_shock_box" ) )
			{
				trig_spawn_offset = ( 0, 11, 46 );
				str_hint = "Shock to turn on power";
			}
			else
			{
				if ( IsSubStr( self.model, "p6_zm_al_power_station_panels" ) )
				{
					trig_spawn_offset = ( 32, 35, 58 );
					str_hint = "Shock to overload";
				}
			}
			afterlife_interact_hint_trigger_create( self, trig_spawn_offset, str_hint );
		}
	}
	while ( 1 )
	{
		if ( isdefined( self.unitrigger_stub ) )
		{
			self.unitrigger_stub.is_activated_in_afterlife = 0;
		}
		else
		{
			if ( isdefined( self.t_bump ) )
			{
				self.t_bump SetCursorHint( "HINT_NOICON" );
				self.t_bump SetHintString( "Shock to turn on power" );
			}
		}
		self waittill( "damage", amount, attacker );
		if ( attacker == level || IsPlayer( attacker ) && attacker GetCurrentWeapon() == GetWeapon("lightning_hands") )
		//if ( attacker == level || IsPlayer( attacker ) )
		{
			if ( isdefined( self.script_string ) )
			{
				if ( isdefined( level.afterlife_interact_dist ) )
				{
					if ( attacker == level || DistanceSquared( attacker.origin, self.origin ) < ( level.afterlife_interact_dist * level.afterlife_interact_dist ) )
					{
						level notify( self.script_string );
						if ( isdefined( self.unitrigger_stub ) )
						{
							self.unitrigger_stub.is_activated_in_afterlife = 1;
							self.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
						}
						else
						{
							if ( isDefined( self.t_bump ) )
							{
								self.t_bump SetHintString( "" );
							}
						}
						self PlayLoopSound( "zmb_afterlife_shockbox_on", 1 );
						if ( self.model == "p6_zm_al_shock_box_off" )
						{
							if ( !isdefined( self.playing_fx ) )
							{
								PlayFXOnTag( level._effect[ "box_activated" ], self, "tag_origin" );
								self.playing_fx = 1;
								self thread afterlife_interact_object_fx_cooldown();
								self PlaySound( "zmb_powerpanel_activate" );
							}
							self SetModel( "p6_zm_al_shock_box_on" );
							self AnimScripted( "test", self.origin, self.angles, level.shockbox_anim[ "on" ] );
						}
						n_count++;
						if ( n_total_interact_count <= 0 || n_count < n_total_interact_count )
						{
							self waittill( "afterlife_interact_reset" );
							self PlayLoopSound( "zmb_afterlife_shockbox_off", 1 );
							if ( self.model == "p6_zm_al_shock_box_on" )
							{
								self SetModel( "p6_zm_al_shock_box_off" );
								self AnimScripted( "test", self.origin, self.angles, level.shockbox_anim[ "off" ] );
							}
							if ( isdefined( self.unitrigger_stub ) )
							{
								self.unitrigger_stub.is_activated_in_afterlife = 0;
								self.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
							}
						}
						else
						{
							if ( isdefined( self.t_bump ) )
							{
								self.t_bump Delete();
							}
							return;
						}
					}
				}
			}
		}
		else
		{
		}
	}
}

function afterlife_interact_hint_trigger_create( m_interact, v_trig_offset, str_hint )
{
	m_interact.unitrigger_stub = SpawnStruct();
	m_interact.unitrigger_stub.origin = ( ( m_interact.origin + ( AnglesToForward( m_interact.angles ) * v_trig_offset[ 0 ] ) ) + ( AnglesToRight( m_interact.angles ) * v_trig_offset[ 1 ] ) ) + ( AnglesToUp( m_interact.angles ) * v_trig_offset[ 2 ] );
	m_interact.unitrigger_stub.radius = 40;
	m_interact.unitrigger_stub.height = 64;
	m_interact.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	m_interact.unitrigger_stub.hint_string = str_hint;
	m_interact.unitrigger_stub.cursor_hint = "HINT_NOICON";
	m_interact.unitrigger_stub.require_look_at = 1;
	m_interact.unitrigger_stub.ignore_player_valid = 1;
	m_interact.unitrigger_stub.prompt_and_visibility_func = &afterlife_trigger_visible_in_afterlife;
	zm_unitrigger::register_static_unitrigger( m_interact.unitrigger_stub, &afterlife_interact_hint_trigger_think );
}

function afterlife_trigger_visible_in_afterlife( player ) {
	if ( isdefined( self.stub.is_activated_in_afterlife ) ) {
		b_is_invis = self.stub.is_activated_in_afterlife;
	}
	self SetInvisibleToPlayer( player, b_is_invis );
	self SetHintString( self.stub.hint_string );
	if ( !b_is_invis ) {
		if ( player zm_utility::is_player_looking_at( self.origin, 0.25 ) ) {
			if ( math::cointoss() ) {
				player thread zm_audio::create_and_play_dialog( "general", "need_electricity" );
			}
			else {
				player thread zm_audio::create_and_play_dialog( "general", "electric_zap" );
			}
		}
	}
	return !b_is_invis;
}

function afterlife_interact_hint_trigger_think() {
	self endon( "kill_trigger" );
	while ( 1 ) {
		self waittill( "trigger" );
		wait 1000;
	}
}

function afterlife_interact_object_fx_cooldown() {
	wait 2;
	self.playing_fx = undefined;
}

function afterlife_zombie_damage() {
	self.actor_damage_func = &afterlife_damage_func;
}

function afterlife_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( sweapon.name == "lightning_hands" ) {
		if ( !IS_TRUE( self.zapped ) ) {
			a_zombies = util::get_array_of_closest( self.origin, zombie_utility::get_round_enemy_array(), undefined, 5, 80 );
			i = 0;
			while ( i < a_zombies.size ) {
				if ( IsAlive( a_zombies[ i ] ) && !isdefined( a_zombies[ i ].zapped ) ) {
					a_zombies[ i ] notify( "zapped" );
					a_zombies[ i ] thread [[ level.afterlife_zapped ]]();
					wait 0.05;
				}
				i++;
			}
		}
		return 0;
	}
	return idamage;
}

function afterlife_zapped()
{
	self endon( "death" );
	self endon( "zapped" );
	self.zapped = 1;
	n_ideal_dist_sq = 490000;
	n_min_dist_sq = 10000;
	a_nodes = level.afterlife_zomb_spawn_points; 
	a_nodes = array::randomize( a_nodes );
	nd_target = undefined;
	nd_target = self af_zomb_choose_a_spawn();
	if ( isdefined( nd_target ) ) {
		v_fx_offset = VectorScale( ( 0, 0, 1 ), 40 );
		fx = Spawn("script_model", self.origin);
		fx.angles = (0,0,0);
		fx SetModel("tag_origin");
		PlayFXOnTag( level._effect[ "afterlife_teleport" ], fx, "tag_origin" );
		PlaySoundAtPosition( "zmb_afterlife_zombie_warp_out", self.origin );
		self Hide();
		linker = Spawn( "script_model", self.origin + v_fx_offset );
		linker SetModel( "tag_origin" );
		PlayFXOnTag( level._effect[ "teleport_ball" ], linker, "tag_origin" );
		linker thread linker_delete_watch( self );
		self LinkTo( linker );
		linker MoveTo( nd_target.origin + v_fx_offset + (RandomIntRange(-50, 50), RandomIntRange(-50, 50), 0), 1 );
		linker waittill( "movedone" );
		linker Delete();
		fx2 = Spawn("script_model", self.origin);
		fx2.angles = (0,0,0);
		fx2 SetModel("tag_origin");
		PlayFXOnTag( level._effect[ "afterlife_teleport" ], fx2, "tag_origin" );
		PlaySoundAtPosition( "zmb_afterlife_zombie_warp_in", self.origin );
		self Show();
	}
	else
	{
/#
		IPrintLnBold( "Could not teleport" );
#/
		PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
		PlaySoundAtPosition( "zmb_afterlife_zombie_warp_out", self.origin );
		level.zombie_total++;
		self Delete();
		return;
	}
	self.zapped = undefined;
	self.ignoreall = 1;
	self thread afterlife_zapped_fx();
	self thread deletefxStructs(fx, fx2);
	i = 0;
	while ( i < 3 )
	{
		self AnimScripted( "something", self.origin, self.angles, "ai_zombie_afterlife_stun_a" );
		wait GetAnimLength( "ai_zombie_afterlife_stun_a" );
		i++;
	}
	self.ignoreall = 0;
}

function deletefxStructs(fx, fx2) {
	wait 1;
	fx Delete();
	fx2 Delete();
}

function activate_afterlife_zombie_spawns()
{
	level.afterlife_zomb_spawn_points = []; 

	structs = struct::get_array( "afterlife_zomb_tele_spot", "targetname" ); 
	foreach( point in structs )
		level.afterlife_zomb_spawn_points[ level.afterlife_zomb_spawn_points.size ] = point;  
}

function afterlife_zomb_wait_for_activation()
{
	if( self.script_string == "start_zone" || self.script_string == "library_zone" || self.script_string == "gondola_ride_zone" || self.script_string == "bridge_zone" )
		level.afterlife_zomb_spawn_points[ level.afterlife_zomb_spawn_points.size ] = self; 
	else
	{
		flag = self.script_string; 
		level flag::wait_till( flag ); 
		level.afterlife_zomb_spawn_points[ level.afterlife_zomb_spawn_points.size ] = self; 
	}
}

function af_zomb_choose_a_spawn()
{
	foreach(spawn in level.afterlife_zomb_spawn_points) {
		player_zone = zm_zonemgr::get_zone_from_position(self.origin, true);
		spawn_zone = zm_zonemgr::get_zone_from_position(spawn.origin, true);
		if(player_zone == spawn_zone && Distance(self.origin, spawn.origin ) > 150) {
			return spawn;
		}
	}
	return undefined;
}

function is_valid_teleport_node()
{
	if ( !zm_utility::check_point_in_enabled_zone( self.origin ) )
	{
		return 0;
	}
	if ( self.type != "Path" )
	{
		return 0;
	}
	if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "no_teleport" )
	{
		return 0;
	}
	if ( isdefined( self.no_teleport ) && self.no_teleport )
	{
		return 0;
	}
	return 1;
}

function linker_delete_watch( ai_zombie )
{
	self endon( "death" );
	ai_zombie waittill( "death" );
	self Delete();
}

function afterlife_zapped_fx()
{
	self endon( "death" );
	PlayFXOnTag( level._effect[ "elec_torso" ], self, "J_SpineLower" );
	self PlaySound( "zmb_elec_jib_zombie" );
	wait 1;
	tagarray = [];
	tagarray[ 0 ] = "J_Elbow_LE";
	tagarray[ 1 ] = "J_Elbow_RI";
	tagarray[ 2 ] = "J_Knee_RI";
	tagarray[ 3 ] = "J_Knee_LE";
	tagarray = array::randomize( tagarray );
	PlayFXOnTag( level._effect[ "elec_md" ], self, tagarray[ 0 ] );
	self PlaySound( "zmb_elec_jib_zombie" );
	wait 1;
	self PlaySound( "zmb_elec_jib_zombie" );
	tagarray[ 0 ] = "J_Wrist_RI";
	tagarray[ 1 ] = "J_Wrist_LE";
	if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
	{
		tagarray[ 2 ] = "J_Ankle_RI";
		tagarray[ 3 ] = "J_Ankle_LE";
	}
	tagarray = array::randomize( tagarray );
	PlayFXOnTag( level._effect[ "elec_sm" ], self, tagarray[ 0 ] );
	PlayFXOnTag( level._effect[ "elec_sm" ], self, tagarray[ 1 ] );
}

function enable_afterlife_prop()
{
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

function disable_afterlife_prop()
{
	self.script_noteworthy = undefined;
	self SetVisibleToAll();
}

function last_stand_conscience_vo()
{
	self endon( "player_revived" );
	self endon( "player_suicide" );
	self endon( "zombified" );
	self endon( "disconnect" );
	self endon( "end_game" );
	if ( !isdefined( self.conscience_vo_played ) )
	{
		self.conscience_vo_played = 0;
	}
	self.conscience_vo_played++;
	convo = [];
	convo = level.conscience_vo[ "conscience_" + self.character_name + "_convo_" + self.conscience_vo_played ];
	if ( isdefined( convo ) )
	{
		wait 5;
		a_players = GetPlayers();
		if ( a_players.size > 1 ) {
			foreach(player in a_players) {
				if ( player != self ) {
					if ( DistanceSquared( self.origin, player.origin ) < 1000000 ) {
						return;
					}
				}
			}
		}
		self.dontspeak = 1;
		i = 0;
		while ( i < convo.size )
		{
			n_duration = SoundGetPlaybackTime( convo[ i ] );
			self PlaySoundToPlayer( convo[ i ], self );
			self thread conscience_vo_ended_early( convo[ i ] );
			wait ( n_duration / 1000 );
			wait 0.5;
			i++;
		}
	}
	self.dontspeak = undefined;
}

function conscience_vo_ended_early( str_alias )
{
	self notify( "conscience_VO_end_early" );
	self endon( "conscience_VO_end_early" );
	self util::waittill_any( "player_revived", "player_suicide", "zombified", "death", "end_game" );
	self.dontspeak = undefined;
	self StopLocalSound( str_alias );
}

function afterlife_trigger_used_vo()
{
	a_vo = level.exert_sounds[ self.characterindex + 1 ][ "hitlrg" ];
	n_index = RandomInt( a_vo.size );
	self PlaySound( a_vo[ n_index ] );
}

function zm_player_fake_death_cleanup()
{
	if ( isdefined( self._fall_down_anchor ) )
	{
		self._fall_down_anchor Delete();
		self._fall_down_anchor = undefined;
	}
}

function zm_player_fake_death( vdir )
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	stance = self GetStance();
	self.ignoreme = 1;
	self EnableInvulnerability();
	self TakeAllWeapons();
	if ( isdefined( self.insta_killed ) && self.insta_killed )
	{
		IPrintLnBold("Normal fake death");
		self zm::player_fake_death();
		self AllowProne( 1 );
		self AllowCrouch( 0 );
		self AllowStand( 0 );
		wait 0.1;
		//self SetStance("prone");
		wait 0.25;
		self FreezeControls( 1 );
	}
	else
	{
		self FreezeControls( 1 );
		self thread fall_down( vdir, stance );
		wait 1;
	}
}

function fall_down( vdir, stance )
{
	self endon( "disconnect" );
	level endon( "game_module_ended" );
	self Ghost();
	origin = self.origin;
	xyspeed = ( 0, 0, 0 );
	angles = self GetPlayerAngles();
	angles = ( angles[ 0 ], angles[ 1 ], angles[ 2 ] + RandomFloatRange( -5, 5 ) );
	if ( isdefined( vdir ) && Length( vdir ) > 0 )
	{
		xyspeedmag = 40 + RandomInt( 12 ) + RandomInt( 12 );
		xyspeed = xyspeedmag * VectorNormalize( ( vdir[ 0 ], vdir[ 1 ], 0 ) );
	}
	linker = Spawn( "script_origin", ( 0, 0, 0 ) );
	linker.origin = origin;
	linker.angles = angles;
	self._fall_down_anchor = linker;
	self PlayerLinkTo( linker );
	self PlaySoundToPlayer( "zmb_player_death_fall", self );
	falling = stance != "prone";
	if ( falling )
	{
		origin = PlayerPhysicsTrace( origin, origin + xyspeed );
		eye = self GetEye();
		floor_height = ( 10 + origin[ 2 ] ) - eye[ 2 ];
		origin += ( 0, 0, floor_height );
		lerptime = 0.5;
		linker MoveTo( origin, lerptime, lerptime );
		linker RotateTo( angles, lerptime, lerptime );
	}
	self FreezeControls( 1 );
	if ( falling )
	{
		IPrintLnBold("Movedone 1");
		linker waittill( "movedone" );
	}
	self GiveWeapon( GetWeapon("bo2_deathhands") );
	self SwitchToWeaponImmediate( GetWeapon("bo2_deathhands") );
	if ( falling )
	{
		bounce = RandomInt( 4 ) + 8;
		origin = ( origin + ( 0, 0, bounce ) ) - ( xyspeed * 0.1 );
		lerptime = bounce / 50;
		linker MoveTo( origin, lerptime, 0, lerptime );
		IPrintLnBold("Movedone 2");
		linker waittill( "movedone" );
		origin = ( origin + ( 0, 0, bounce * -1 ) ) + ( xyspeed * 0.1 );
		lerptime /= 2;
		linker MoveTo( origin, lerptime, lerptime );
		linker waittill( "movedone" );
		IPrintLnBold("Movedone 3");
		linker MoveTo( origin, 5, 0 );
	}
	wait 15;
	linker Delete();
}

function check_solo_status()
{
	if ( GetNumExpectedPlayers() == 1 || !SessionModeIsOnlineGame() && !SessionModeIsPrivate() )
	{
		level.is_forever_solo_game = 1;
	}
	else
	{
		level.is_forever_solo_game = 0;
	}
}

function af_jump_logic()
{
	self endon ("afterlife_over");
	self endon ("disconnect");
	self endon ("player_revived");

	while(1) {
		current_height = self.origin[2];
		wait(.05);
		
		if ( self is_jumping() )
		{
			for(k=0;k<9;k++) // 10 times
			{
				current_height = self.origin[2];
				self SetVelocity(self GetVelocity() + (0,0,45) );
				wait(.05);
				if (self.origin[2] < current_height)
					break;
			}
			while(1)
			{
				current_height = self.origin[2];
				wait(.05);
				if (self.origin[2] < current_height)
					break;
			}
			while( self is_falling() )
			{
				// iprintlnbold("self is falling"); 
				self SetVelocity(self GetVelocity() + (0,0,35) );
				wait(.05);
			}
		}
	}
}

function is_jumping() {
	current_height = self.origin[2];
	wait(0.05);
	if ( self GetStance() == "stand" && self.origin[2] > current_height + 6 && !self IsOnGround() )
		return true; // current_height + 6 to account for stairs 
	else
		return false; 
}

function is_falling() {
	current_height = self.origin[2];
	wait(0.05);
	if ( !self IsOnGround() && self.origin[2] < current_height )
		return true; 
	else
		return false; 
}

function afterlife_special_door_init() {
	level thread wardens_office_door();
	level thread shower_door();
	level thread roof_door();
}

function wardens_office_door() {
    level flag::init("activate_warden_office");
    level waittill("activate_warden_office");
    level notify("activate_warden_office_trap");
    level flag::set("activate_warden_office");
    level flag::set( "enter_wardens_zone" );
    clip = GetEnt("wardens_office_door_clip","targetname");
    clip SetInvisibleToAll();
    clip ConnectPaths();
    clip Delete();
    door = GetEnt("wardens_office_door_model","targetname");
    scale = 1;
    vector = VectorScale( door.script_vector, scale );
    door MoveTo( door.origin + vector, 1 ); 
}

function shower_door() {
    level waittill("enter_shower_zone");
    level flag::set( "enter_shower_zone" );
    clip = GetEnt("metal_shower_door_clip","targetname");
    clip SetInvisibleToAll();
    clip ConnectPaths();
    clip Delete();
    door = GetEnt("metal_shower_door_model","targetname");
    rot_angle = door.script_angles;
    door RotateTo( rot_angle, 1 );
}

function roof_door() {
    level waittill("enter_roof_zone");
    level flag::set( "enter_roof_zone" );
    clip = GetEnt("roof_door_clip","targetname");
    clip SetInvisibleToAll();
    clip ConnectPaths();
    clip Delete();
    door = GetEnt("roof_door_model","targetname");
    rot_angle = door.script_angles;
    door RotateTo( rot_angle, 1 );
}

function afterlife_powerups() {
	level flag::wait_till("initial_players_connected");
	level._powerup_grab_check = &cell_grab_check;
	s_powerup_loc = struct::get( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	s_powerup_loc = struct::get( "powerup_cell_1", "targetname" );
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game ) {
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else {
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "insta_kill" );
	}
	s_powerup_loc = struct::get( "powerup_cell_2", "targetname" );
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game ) {
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else {
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "full_ammo" );
	}
}

function cell_grab_check( player )
{
	cell_powerup = struct::get( "powerup_cell_1", "targetname" );
	if ( self.origin == ( cell_powerup.origin + VectorScale( ( 0, 0, 1 ), 40 ) ) ) {
		m_door = GetEnt( "powerup_cell_door_1", "targetname" );
		if ( !isdefined( m_door.opened ) ) {
			return 0;
		}
	}
	cell_powerup = struct::get( "powerup_cell_2", "targetname" );
	if ( self.origin == ( cell_powerup.origin + VectorScale( ( 0, 0, 1 ), 40 ) ) ) {
		m_door = GetEnt( "powerup_cell_door_2", "targetname" );
		if ( !isdefined( m_door.opened ) ) {
			return 0;
		}
	}
	return 1;
}

function afterlife_intro_door() {
	level waittill( "intro_powerup_restored" );
	s_powerup_loc = struct::get( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin );
}

function afterlife_cell_door_1() {
	m_door = GetEnt( "powerup_cell_door_1", "targetname" );
	level waittill( "cell_1_powerup_activate" );
	wait 1;
	array::delete_all( GetEntArray( "wires_cell_cafeteria", "script_noteworthy" ) );
	m_door_clip = GetEnt( "powerup_door_cafe_side_clip", "targetname" );
	m_door_clip SetInvisibleToAll();
	m_door_clip ConnectPaths();
	m_door.opened = 1;
	m_door MoveTo( m_door.origin + (36.389, 0, 0), 2, 1 );
	m_door PlaySound( "zmb_jail_door" );
}

function afterlife_cell_door_2() {
	m_door = GetEnt( "powerup_cell_door_2", "targetname" );
	level waittill( "cell_2_powerup_activate" );
	wait 1;
	array::delete_all( GetEntArray( "wires_cell_michigan", "script_noteworthy" ) );
	m_door_clip = GetEnt( "powerup_door_hallway_side_clip", "targetname" );
	m_door_clip SetInvisibleToAll();
	m_door_clip ConnectPaths();
	m_door.opened = 1;
	m_door MoveTo( m_door.origin + (-31.26, 0, 0), 2, 1 );
	m_door PlaySound( "zmb_jail_door" );
}

function spawn_infinite_powerup_drop( v_origin, str_type ) {
	level._powerup_timeout_override = &powerup_infinite_time;
	if ( isdefined( str_type ) ) {
		intro_powerup = zm_powerups::specific_powerup_drop( str_type, v_origin );
	}
	else {
		intro_powerup = zm_powerups::powerup_drop( v_origin );
	}
	level._powerup_timeout_override = undefined;
}

function powerup_infinite_time() {
}

function power_on_perk_machines() {
	level util::waittill_any( "unlock_all_perk_machines", "open_sesame" );
	a_shockboxes = GetEntArray( "perk_afterlife_trigger", "script_noteworthy" );
	foreach(e_shockbox in a_shockboxes) {
		e_shockbox notify( "damage", 500 , level );
		wait 1;
	}
}