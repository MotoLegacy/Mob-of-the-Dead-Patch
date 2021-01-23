#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_powerups;

#using scripts\zm\gametypes\_zm_gametype;

#using scripts\zm\zm_alcatraz_utility;
//#using scripts\zm\zm_alcatraz_travel_bo3;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;

#using_animtree( "generic" );

#precache( "xmodel", "p6_zm_al_shock_box_on" );
#precache( "material", "waypoint_revive_afterlife" );

#precache( "fx", "custom/jerri/al_afterlife/fx_alcatraz_afterlife_zmb_tport" ); 
#precache( "fx", "custom/jerri/tomahawk/fx_tomahawk_upgraded_trail" ); 
#precache( "fx", "custom/jerri/al_afterlife/fx_alcatraz_player" ); 

#define SHOCKBOXMODELON "p6_zm_al_shock_box_on"
#define SHOCKBOXMODELOFF "p6_zm_al_shock_box_off"

function init()
{
	level thread give_afterlife();
	level.zombiemode_using_afterlife = 1;
	level flag::init( "afterlife_start_over" );
	level.afterlife_revive_tool = GetWeapon("lightning_hands_revive");
	visionset_mgr::register_info( "visionset", "afterlife", 9000, 120, 1, 1 );
	visionset_mgr::register_info( "overlay", "afterlife_filter", 9000, 120, 1, 1 );
	clientfield::register( "toplayer", "player_lives", 9000, 2, "int" );
	clientfield::register( "toplayer", "player_in_afterlife", 9000, 1, "int" );
	clientfield::register( "toplayer", "player_afterlife_mana", 9000, 5, "float" );
	clientfield::register( "allplayers", "player_afterlife_fx", 9000, 1, "int" );
	clientfield::register( "toplayer", "clientfield_afterlife_audio", 9000, 1, "int" );
	clientfield::register( "toplayer", "player_afterlife_refill", 9000, 1, "int" );
	clientfield::register( "scriptmover", "player_corpse_id", 9000, 3, "int" );

	// Were gonna keep this in or else it crashes
	clientfield::register( "world", "fog_stage", VERSION_SHIP, 2, "int" );

	afterlife_load_fx();
	level thread afterlife_hostmigration();
	level thread afterlife_special_door_init();
	a_afterlife_interact = GetEntArray( "afterlife_interact", "targetname" );
	array::thread_all( a_afterlife_interact, &afterlife_interact_object_think );
	level.zombie_spawners = GetEntArray( "zombie_spawner", "script_noteworthy" );
	array::thread_all( level.zombie_spawners, &spawner::add_spawn_function, &afterlife_zombie_damage );
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	foreach(struct in a_afterlife_triggers)
	{
		afterlife_trigger_create( struct );
	}
	level.afterlife_interact_dist = 256;
	level.is_player_valid_override = &is_player_valid_afterlife;
	level.can_revive = &can_revive_override;
	level.round_prestart_func = &afterlife_start_zombie_logic;
	level.custom_pap_validation = &is_player_valid_afterlife;
	level.player_out_of_playable_area_monitor_callback = &player_out_of_playable_area;
	level thread afterlife_gameover_cleanup();
	level.afterlife_get_spawnpoint = &afterlife_get_spawnpoint;
	level.afterlife_zapped = &afterlife_zapped;
	level.afterlife_give_loadout = &afterlife_give_loadout;
	level.afterlife_save_loadout = &afterlife_save_loadout;
	level thread power_on_perk_machines();
	level thread afterlife_powerups();
	level thread afterlife_intro_door();
	level thread afterlife_cell_door_1();
	level thread afterlife_cell_door_2();
}

function afterlife_gameover_cleanup()
{
	level waittill( "end_game" );
	foreach(player in GetPlayers())
	{
		player.afterlife_active = 0;
		player util::clientnotify( "end_game" );
		player notify( "end_game" );
		if ( isdefined( player.client_hint ) )
		{
			player.client_hint Destroy();
		}
	}
	wait 5;
	foreach(player in GetPlayers())
	{
		if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			visionset_mgr::deactivate( "overlay", "afterlife_filter", player );
		}
	}
}

function afterlife_load_fx()
{
	level._effect[ "afterlife_teleport" ] = "custom/jerri/al_afterlife/fx_alcatraz_afterlife_zmb_tport";
	level._effect[ "teleport_ball" ] = "custom/jerri/tomahawk/fx_tomahawk_upgraded_trail";
	level._effect[ "afterlife_kill_point_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_suicide_area";
	level._effect[ "afterlife_enter" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_start";
	level._effect[ "afterlife_leave" ] = "maps/zombie_alcatraz/fx_alcatraz_player_revive";
	level._effect[ "afterlife_pixie_dust" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies";
	level._effect[ "afterlife_corpse" ] = "maps/zombie_alcatraz/fx_alcatraz_player_down";
	level._effect[ "afterlife_damage" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage";
	level._effect[ "afterlife_ghost_h_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_head";
	level._effect[ "afterlife_ghost_arm_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_arm";
	level._effect[ "afterlife_ghost_hand_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand";
	level._effect[ "afterlife_ghost_hand_r_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r";
	level._effect[ "afterlife_transition" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition";
	level._effect[ "fx_alcatraz_ghost_vm_wrist" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist";
	level._effect[ "fx_alcatraz_ghost_vm_wrist_r" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r";
	level._effect[ "fx_alcatraz_ghost_spectate" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_spec";
	level._effect["afterlife_ghost_fx"] = "custom/jerri/al_afterlife/fx_alcatraz_player";
	/*level._effect[ "afterlife_teleport" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_zmb_tport";
	level._effect[ "teleport_ball" ] = "weapon/tomahawk/fx_tomahawk_trail_ug";
	level._effect[ "afterlife_kill_point_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_suicide_area";
	level._effect[ "afterlife_enter" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_start";
	level._effect[ "afterlife_leave" ] = "maps/zombie_alcatraz/fx_alcatraz_player_revive";
	level._effect[ "afterlife_pixie_dust" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies";
	level._effect[ "afterlife_corpse" ] = "maps/zombie_alcatraz/fx_alcatraz_player_down";
	level._effect[ "afterlife_damage" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage";
	level._effect[ "afterlife_ghost_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_body";
	level._effect[ "afterlife_ghost_h_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_head";
	level._effect[ "afterlife_ghost_arm_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_arm";
	level._effect[ "afterlife_ghost_hand_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand";
	level._effect[ "afterlife_ghost_hand_r_fx" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r";
	level._effect[ "afterlife_transition" ] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition";
	level._effect[ "fx_alcatraz_ghost_vm_wrist" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist";
	level._effect[ "fx_alcatraz_ghost_vm_wrist_r" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r";
	level._effect[ "fx_alcatraz_ghost_spectate" ] = "maps/zombie_alcatraz/fx_alcatraz_ghost_spec";*/
}

function afterlife_start_zombie_logic()
{
	level flag::wait_till( "start_zombie_round_logic" );
	wait 0.5;
	b_everyone_alive = 0;
	while ( isdefined( b_everyone_alive ) && !b_everyone_alive )
	{
		b_everyone_alive = 1;
		foreach(player in GetPlayers())
		{
			if ( isdefined( player.afterlife_active ) && player.afterlife_active )
			{
				b_everyone_alive = 0;
				wait 0.05;
				break;
			}
		}
	}
	wait 0.5;
	while ( level.intermission )
	{
		wait 0.05;
	}
	level flag::set( "afterlife_start_over" );
	wait 2;
	array::thread_all( GetPlayers(), &afterlife_add );
}

function is_player_valid_afterlife( player )
{
	if ( isdefined( player.afterlife_active ) && player.afterlife_active )
	{
		return 0;
	}
	return 1;
}

function can_revive_override( revivee )
{
	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
	{
		return 0;
	}
	return 1;
}

function player_out_of_playable_area()
{
	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
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
	self.afterlife_active = 0;
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
	if ( isdefined( self.afterlife_active ) && !self.afterlife_active )
	{
		self clientfield::set_to_player( "player_afterlife_refill", 1 );
		wait 3;
		if ( isdefined( self.afterlife_active ) && !self.afterlife_active )
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

function afterlife_enter()
{
	if ( !isdefined( self.afterlife_visionset ) || self.afterlife_visionset == 0 )
	{
		visionset_mgr::activate( "visionset", "afterlife", self );
		if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			visionset_mgr::activate( "overlay", "afterlife_filter", self );
		}
		self.afterlife_visionset = 1;
	}
	self.old_charactertype = self GetCharacterBodyType();
	self.old_gravity = self GetPlayerGravity();
	self SetCharacterBodyType(4);
	self SetPlayerGravity(200);
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 0 );
	self SetClientUIVisibilityFlag( "is_player_zombie", 1 );
	//self SetJumpHeight( 150 );
	self AllowDoubleJump( true );
	self thread afterlife_doors_open();
	self clientfield::set_to_player( "player_in_afterlife", 1 );
	self clientfield::set( "player_afterlife_fx", 1 );
	self afterlife_create_mana_bar( self.e_afterlife_corpse );
	if ( !isdefined( self.keep_perks ) && level flag::get( "afterlife_start_over" ) )
	{
		self zm_laststand::increment_downed_stat();
	}
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	foreach(struct in a_afterlife_triggers)
	{
		struct.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
	}
	a_exterior_goals = struct::get_array( "exterior_goal", "targetname" );
	foreach(struct in a_exterior_goals)
	{
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
		if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
		{
			visionset_mgr::deactivate( "overlay", "afterlife_filter", self );
		}
		self.afterlife_visionset = 0;
	}
	self.dontspeak = 0;
	self thread afterlife_doors_close();
	self.health = self.maxhealth;
	self clientfield::set_to_player( "player_in_afterlife", 0 );
	self clientfield::set( "player_afterlife_fx", 0 );
	self clientfield::set_to_player( "clientfield_afterlife_audio", 0 );
	self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self AllowStand( 1 );
	self AllowCrouch( 1 );
	self AllowProne( 1 );
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 1 );
	self SetClientUIVisibilityFlag( "is_player_zombie", 0 );
	self SetCharacterBodyType(self.old_charactertype);
	self SetPlayerGravity(self.old_gravity);
	self AllowDoubleJump( false );
	//self SetJumpHeight( 64 );
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
		/*a_gondola_doors_gates = zm_alcatraz_travel::get_gondola_doors_and_gates();
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
				foreach(struct in a_s_orgs)
				{
					if ( !PositionWouldTelefrag( struct.origin ) )
					{
						self SetOrigin( struct.origin );
						break;
					}
				}
			}
			else i++;
		}*/
	}
	self SetPlayerAngles( self.e_afterlife_corpse.angles );
	self.afterlife_active = 0;
	self afterlife_laststand_cleanup( self.e_afterlife_corpse );
	if ( isdefined( b_revived ) && !b_revived )
	{
		self afterlife_remove( 1 );
		self DoDamage( 1000, self.origin );
	}
	reset_all_afterlife_unitriggers();
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
	self.dontspeak = 1;
	self.health = 1000;
	if(!isdefined(neworigin))
	{
		neworigin = self.origin;
	}
	b_has_electric_cherry = 0;
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
		self thread hud::fade_to_black_for_x_sec( 0, 1, 0.5, 0.5, "white" );
		wait 0.5;
	}
	self Ghost();
	self.e_afterlife_corpse = self afterlife_spawn_corpse(neworigin);
	self thread afterlife_clean_up_on_disconnect();
	self notify( "player_fake_corpse_created" );
	self afterlife_fake_revive();
	self afterlife_enter();
	self.e_afterlife_corpse clientfield::set( "player_corpse_id", self GetEntityNumber() + 1 );
	wait 0.5;
	self Show();
	//if ( isdefined( self.hostmigrationcontrolsfrozen ) && !self.hostmigrationcontrolsfrozen )
	//{
		self FreezeControls( 0 );
	//}
	self DisableInvulnerability();
	self.e_afterlife_corpse waittill( "player_revived", e_reviver );
	self notify( "player_revived" );
	self SetEverHadWeaponAll( 1 );
	self EnableInvulnerability();
	self.afterlife_revived = 1;
	PlaySoundAtPosition( "zmb_afterlife_spawn_leave", self.e_afterlife_corpse.origin );
	self afterlife_leave();
	self thread afterlife_revive_invincible();
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
	e_corpse notify( "disconnect" );
	util::wait_network_frame();
	util::wait_network_frame();
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
	self thread afterlife_jump_energy_watch( corpse );
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
	if ( isdefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
		{
			wait 0.05;
		}
	}
	corpse notify( "stop_revive_trigger" );
	self thread hud::fade_to_black_for_x_sec( 0, 0.5, 0.5, 0.5, "black" );
	wait 0.5;
	self notify( "out_of_mana" );
	self afterlife_leave( 0 );
}

function afterlife_doors_open()
{
	n_network_sent = 0;
	a_show = GetEntArray( "afterlife_show", "targetname" );
	a_show = ArrayCombine( a_show, GetEntArray( "afterlife_prop", "script_noteworthy" ), 0, 0 );
	foreach(ent in a_show)
	{
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
	foreach(ent in a_hide)
	{
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
		foreach(claymore in self.claymores)
		{
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
	foreach(ent in a_hide)
	{
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
	a_show = GetEntArray( "afterlife_door", "targetname" );
	a_show = ArrayCombine( a_show, GetEntArray( "zombie_door", "targetname" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "quest_trigger", "script_noteworthy" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "trap_trigger", "script_noteworthy" ), 0, 0 );
	a_show = ArrayCombine( a_show, GetEntArray( "travel_trigger", "script_noteworthy" ), 0, 0 );
	foreach(ent in a_show)
	{
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
	if ( isdefined( self.claymores ) )
	{
		foreach(claymore in self.claymores)
		{
			if ( isdefined( claymore.pickuptrigger ) )
			{
				claymore.pickuptrigger SetVisibleToPlayer( self );
			}
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
	corpse Delete();
	self.e_afterlife_corpse = undefined;
}

function afterlife_spawn_corpse(neworigin)
{
	if(!isdefined(neworigin))
	{
		neworigin = self.origin;
	}
	if ( isdefined( self.is_on_gondola ) && self.is_on_gondola && level.e_gondola.destination == "roof" )
	{
		corpse = spawn_player_clone( self, neworigin, undefined );
	}
	else
	{
		trace_start = neworigin;
		trace_end = neworigin + ( 0, 0, -500  );
		corpse_trace = PlayerPhysicsTrace( trace_start, trace_end );
		corpse = spawn_player_clone( self, neworigin, undefined );
	}
	corpse.angles = self.angles;
	corpse.ignoreme = 1;
	corpse clone_give_weapon( GetWeapon("pistol_standard") );
	corpse clone_animate( "afterlife" );
	corpse.revive_hud = self afterlife_revive_hud_create();
	corpse thread afterlife_revive_trigger_spawn();
	if ( level flag::get( "solo_game" ) )
	{
		corpse thread afterlife_corpse_create_pois();
	}
	return corpse;
}

function afterlife_corpse_create_pois()
{
	n_attractors = Ceil( zombie_utility::get_current_zombie_count() / 3 );
	if ( n_attractors < 4 )
	{
		n_attractors = 4;
	}
	a_nodes = afterlife_corpse_get_array_poi_positions();
	self.pois = [];
	if ( isdefined( a_nodes ) && a_nodes.size > 3 )
	{
		i = 0;
		while ( i < 3 )
		{
			self.pois[ i ] = afterlife_corpse_create_poi( a_nodes[ i ].origin, n_attractors );
			wait 0.05;
			i++;
		}
	}
}

function afterlife_corpse_create_poi( v_origin, n_attractors )
{
	e_poi = Spawn( "script_origin", v_origin );
	e_poi zm_utility::create_zombie_point_of_interest( 10000, 24, 5000, 1 );
	e_poi thread zm_utility::create_zombie_point_of_interest_attractor_positions();
/#
	e_poi thread zm_utility::print3d_ent( "Corpse POI" );
#/
	return e_poi;
}

function afterlife_corpse_remove_pois()
{
	if ( !isdefined( self.pois ) )
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
	self.pois = undefined;
}

function afterlife_corpse_get_array_poi_positions()
{
	n_ideal_dist_sq = 490000;
	good_nodes = [];
	a_nodes = PositionQuery_Source_Navigation(self.origin + (0,0,5) , 0, 1200, 100, 32 ).data;
	i = 0;
	while ( i < a_nodes.size )
	{
		if ( a_nodes[ i ] is_valid_teleport_node() )
		{
			good_nodes[good_nodes.size] = a_nodes[ i ];
		}
		i++;
	}
	good_nodes = array::remove_undefined( good_nodes );
	return array::randomize( good_nodes );
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

function afterlife_revive_trigger_spawn()
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
			if ( !reviver is_reviving_afterlife( self ) )
			{
				i++;
				continue;
			}
			else
			{
				gun = reviver GetCurrentWeapon();
				if ( gun == level.revive_tool || gun == level.afterlife_revive_tool )
				{
					IPrintLnBold("WRONG GUN");
					i++;
					continue;
				}
				else
				{
					if ( isdefined( reviver.afterlife_active ) && reviver.afterlife_active )
					{
						reviver GiveWeapon( level.afterlife_revive_tool );
						reviver SwitchToWeapon( level.afterlife_revive_tool );
						reviver SetWeaponAmmoStock( level.afterlife_revive_tool, 1 );
					}
					else
					{
						reviver GiveWeapon( level.revive_tool );
						reviver SwitchToWeapon( level.revive_tool );
						reviver SetWeaponAmmoStock( level.revive_tool, 1 );
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

function afterlife_can_revive( revivee )
{
	/*if ( isdefined( self.afterlife_active ) && self.afterlife_active && isdefined( self.e_afterlife_corpse ) && self.e_afterlife_corpse != revivee )
	{
		return 0;
	}*/
	if ( !isdefined( revivee.revivetrigger ) )
	{
		return 0;
	}
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
	if ( !ignore_sight_checks )
	{
		if ( !self zm_utility::is_facing( revivee ) )
		{
			return 0;
		}
		if ( !SightTracePassed( self.origin + vectorScale( ( 0, 0, 1 ), 50 ), revivee.origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, undefined ) )
		{
			return 0;
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
	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
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
		self.revivetexthud.color = ( 1, 1, 1 );
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
		}
	}
	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
	{
		self TakeWeapon( level.afterlife_revive_tool );
	}
	else
	{
		self TakeWeapon( level.revive_tool );
	}
	e_fx Delete();
	if ( isdefined( self.reviveprogressbar ) )
	{
		self.reviveprogressbar hud::destroyelem();
		self.reviveprogressbar Destroy();
	}
	if ( isdefined( self.revivetexthud ) )
	{
		self.revivetexthud hud::destroyelem();
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
		return false;
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
	index = GetFirstArrayKey( primaries );
	while ( isdefined( index ) )
	{
		weapon = primaries[ index ];
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
		index = GetNextArrayKey( primaries, index );
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
	if ( self HasWeapon( GetWeapon("bouncing_tomahawk") ) || self HasWeapon( GetWeapon("upgraded_tomahawk") ) )
	{
		self.loadout.hastomahawk = 1;
		self clientfield::set_to_player( "tomahawk_in_use", 0 );
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
		foreach(weapon in primaries)
		{
			self TakeWeapon( weapon );
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
	self SetSpawnWeapon( loadout.weapons[ loadout.current_weapon ] );
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
		self GiveWeapon( self.current_tomahawk_weapon );
		self zm_utility::set_player_tactical_grenade( self.current_tomahawk_weapon );
		self clientfield::set_to_player( "tomahawk_in_use", 1 );
	}
	self.score = loadout.score;
	perk_array = zm_perks::get_perk_array();
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
			if ( loadout.perks[ i ] == "specialty_finalstand" )
			{
				i++;
				continue;
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
}

function afterlife_fake_death()
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	self TakeAllWeapons();
	self AllowStand( 0 );
	self AllowCrouch( 0 );
	self AllowProne( 1 );
	self SetStance( "prone" );
	if ( self zm_utility::is_jumping() )
	{
		while ( self zm_utility::is_jumping() )
		{
			wait 0.05;
		}
	}
	PlayFX( level._effect[ "afterlife_enter" ], self.origin );
	self.ignoreme = 1;
	self EnableInvulnerability();
	self FreezeControls( 1 );
}

function afterlife_fake_revive()
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	PlaySoundAtPosition( "zmb_afterlife_spawn_leave", self.origin );
	if ( level flag::get( "afterlife_start_over" ) )
	{
		spawnpoint = [[ level.afterlife_get_spawnpoint ]]();
		trace_start = spawnpoint.origin;
		trace_end = spawnpoint.origin + vectorScale( ( 0, 0, 1 ), 200 );
		respawn_trace = PlayerPhysicsTrace( trace_start, trace_end );
		self SetOrigin( respawn_trace );
		self SetPlayerAngles( spawnpoint.angles );
		PlaySoundAtPosition( "zmb_afterlife_spawn_enter", spawnpoint.origin );
	}
	else
	{
		PlaySoundAtPosition( "zmb_afterlife_spawn_enter", self.origin );
	}
	self AllowStand( 1 );
	self AllowCrouch( 0 );
	self AllowProne( 0 );
	self.ignoreme = 0;
	self SetStance( "stand" );
	self GiveWeapon( GetWeapon("lightning_hands") );
	self SwitchToWeapon( GetWeapon("lightning_hands") );
	self.score = 0;
	wait 1;
}

function afterlife_get_spawnpoint()
{
	query_result = PositionQuery_Source_Navigation(self.origin + (0,0,5) , 0, 500, 100, 32 );
	a_nodes = array::randomize( query_result.data );
	foreach(spawnpoint in a_nodes) {
		if(spawnpoint is_valid_teleport_node())
			return spawnpoint;
	}
	return self;

	/*spawnpoint = check_for_valid_spawn_in_zone( self );
	if ( !isdefined( spawnpoint ) )
	{
		spawnpoint = zm::check_for_valid_spawn_near_position( self, self.origin, 1 );
	}
	if ( !isdefined( spawnpoint ) )
	{
		spawnpoint = zm::check_for_valid_spawn_near_team( self, 1 );
	}
	if ( !isdefined( spawnpoint ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( location != "default" && location == "" && isdefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
		spawnpoints = [];
		structs = struct::get_array( "initial_spawn", "script_noteworthy" );
		if ( isdefined( structs ) )
		{
			foreach(struct in structs)
			{
				if ( isdefined( struct.script_string ) )
				{
					tokens = StrTok( struct.script_string, " " );
					foreach(token in tokens)
					{
						if ( token == match_string )
						{
							spawnpoints[ spawnpoints.size ] = struct;
						}
					}
				}
			}
		}
		if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
		{
			spawnpoints = struct::get_array( "initial_spawn_points", "targetname" );
		}
/#
		assert( isdefined( spawnpoints ), "Could not find initial spawn points!" );
#/
		spawnpoint = zm::getfreespawnpoint( spawnpoints, self );
	}
	return spawnpoint;*/
}

function check_for_valid_spawn_in_zone( player )
{
	a_spawn_points = zm_gametype::get_player_spawns_for_gametype();
	if ( isdefined( level.e_gondola ) && isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
	{
		/*if ( player zm_alcatraz_travel::is_player_on_gondola() )
		{
			if ( level.e_gondola.destination == "roof" )
			{
				str_player_zone = "zone_cellblock_west_gondola";
			}
			else
			{
				if ( level.e_gondola.destination == "docks" )
				{
					str_player_zone = "zone_dock";
				}
			}
		}
		else
		{*/
			str_player_zone = player zm_zonemgr::get_player_zone();
		//}
	}
	else
	{
		str_player_zone = player zm_zonemgr::get_player_zone();
	}
/#
	IPrintLnBold( "The player is not in a zone at origin " + player.origin );
#/
	foreach(spawn_point in a_spawn_points)
	{
		if ( spawn_point.script_noteworthy == str_player_zone )
		{
			a_spawn_structs = struct::get_array( spawn_point.target, "targetname" );
			a_spawn_structs = util::get_array_of_closest( player.origin, a_spawn_structs );
			foreach(s_spawn in a_spawn_structs)
			{
				if ( !level flag::get( "afterlife_start_over" ) )
				{
					if ( isdefined( s_spawn.en_num ) && s_spawn.en_num != player.playernum )
					{

					}
				}
				else
				{
					if ( PositionWouldTelefrag( s_spawn.origin ) || DistanceSquared( player.origin, s_spawn.origin ) < 250000 )
					{
						break;
					}
					else 
						return s_spawn;
				}
			}
			a_spawn_structs = zm_alcatraz_utility::get_array_of_farthest( player.origin, a_spawn_structs, undefined, 250000 );
			foreach(s_spawn in a_spawn_structs)
			{
				if ( PositionWouldTelefrag( s_spawn.origin ) )
				{

				}
				else return s_spawn;
			}
		}
	}
	return undefined;
}

function afterlife_save_perks( ent )
{
	perk_array = ent zm_perks::get_perk_array();
	foreach(perk in perk_array)
	{
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
		foreach(player in GetPlayers())
		{
			player clientfield::set_to_player( "player_lives", player.af_lives );
			if ( isdefined( player.e_afterlife_corpse ) )
			{
				player.e_afterlife_corpse clientfield::set( "player_corpse_id", 0 );
			}
		}
		util::wait_network_frame();
		util::wait_network_frame();
		foreach(player in GetPlayers())
		{
			if ( isdefined( player.e_afterlife_corpse ) )
			{
				player.e_afterlife_corpse clientfield::set( "player_corpse_id", player GetEntityNumber() + 1 );
			}
		}
	}
}

function afterlife_reduce_mana( n_mana )
{
	if ( isdefined( self.afterlife_active ) && !self.afterlife_active )
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

function afterlife_jump_energy_watch( corpse )
{
	self endon( "disconnect" );
	corpse endon( "player_revived" );
	while ( 1 ) {
		energy = 0.3;
		self SetDoubleJumpEnergy(energy);
		while ( self zm_utility::is_jumping() || self IsDoubleJumping() ) {
			if( energy > 0)
				energy -= 0.1;
			wait 0.1;
			self SetDoubleJumpEnergy(energy);
		}
		wait 0.1;
	}
}

function afterlife_trigger_create( s_origin )
{
	s_origin.unitrigger_stub = SpawnStruct();
	s_origin.unitrigger_stub.origin = s_origin.origin;
	s_origin.unitrigger_stub.radius = 36;
	s_origin.unitrigger_stub.height = 256;
	s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
	s_origin.unitrigger_stub.hint_string = &"ZM_PRISON_AFTERLIFE_KILL";
	s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_origin.unitrigger_stub.require_look_at = 1;
	s_origin.unitrigger_stub.prompt_and_visibility_func = &afterlife_trigger_visibility;
	zm_unitrigger::unitrigger_force_per_player_triggers( s_origin.unitrigger_stub, 1 );
	zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, &afterlife_trigger_think );
}

function reset_all_afterlife_unitriggers()
{
	a_afterlife_triggers = struct::get_array( "afterlife_trigger", "targetname" );
	foreach(struct in a_afterlife_triggers)
	{
		zm_unitrigger::unregister_unitrigger( struct.unitrigger_stub );
		zm_unitrigger::register_static_unitrigger( struct.unitrigger_stub, &afterlife_trigger_think );
	}
}

function afterlife_trigger_visibility( player )
{
	b_is_invis = player.afterlife_active;
	self SetInvisibleToPlayer( player, b_is_invis );
	if ( player.af_lives == 0 )
	{
		self SetHintString( &"ZM_PRISON_OUT_OF_LIVES" );
	}
	else
	{
		self SetHintString( self.stub.hint_string );
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
			self PlaySound( "zmb_no_cha_ching" );
			wait 0.1;
			continue;
		}
		if ( player zm_laststand::is_reviving_any() || player laststand::player_is_in_laststand() )
		{
			wait 0.1;
			continue;
		}
		if ( isdefined( player.afterlife_active ) && !player.afterlife_active )
		{
			self SetInvisibleToPlayer( player, 1 );
			self PlaySound( "zmb_afterlife_trigger_activate" );
			player PlaySoundToPlayer( "zmb_afterlife_trigger_electrocute", player );
			player thread afterlife_trigger_used_vo();
			self SetHintString( "" );
			player.keep_perks = 1;
			player afterlife_remove();
			player.afterlife_active = 1;
			player thread afterlife_laststand();
			e_fx = Spawn( "script_model", self.origin );
			e_fx SetModel( "tag_origin" );
			e_fx.angles = vectorScale( ( 0, 0, 1 ), 90 );
			PlayFXOnTag( level._effect[ "afterlife_kill_point_fx" ], e_fx, "tag_origin" );
			wait 2;
			e_fx Delete();
			self SetHintString( &"ZM_PRISON_AFTERLIFE_KILL" );
		}
	}
}

function afterlife_interact_object_think()
{
	self endon( "afterlife_interact_complete" );
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
	self.health = 5000;
	self SetCanDamage( 1 );
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
		if ( isdefined( self.script_string ) && self.script_string == "intro_powerup_activate" )
		{
			self.t_bump = Spawn( "trigger_radius", self.origin + vectorScale( ( 0, 0, 1 ), 28 ), 0, 28, 64 );
		}
		else
		{
			if ( IsSubStr( self.model, "p6_zm_al_shock_box" ) )
			{
				trig_spawn_offset = ( 0, 11, 46 );
				str_hint = &"ZM_PRISON_AFTERLIFE_INTERACT";
			}
			else
			{
				if ( IsSubStr( self.model, "p6_zm_al_power_station_panels" ) )
				{
					trig_spawn_offset = ( 32, 35, 58 );
					str_hint = &"ZM_PRISON_AFTERLIFE_OVERLOAD";
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
				self.t_bump SetHintString( &"ZM_PRISON_AFTERLIFE_INTERACT" );
			}
		}
		self waittill( "damage", amount, attacker );
		if ( attacker == level || IsPlayer( attacker ) && attacker GetCurrentWeapon().name == "lightning_hands" )
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
							if ( isdefined( self.t_bump ) )
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
							self SetModel( SHOCKBOXMODELON );
							self AnimScripted( "close", self.origin, self.angles, level.shockbox_anim[ "on" ] );
						}
						n_count++;
						if ( n_total_interact_count <= 0 || n_count < n_total_interact_count )
						{
							self waittill( "afterlife_interact_reset" );
							self PlayLoopSound( "zmb_afterlife_shockbox_off", 1 );
							if ( self.model == "p6_zm_al_shock_box_on" )
							{
								self SetModel( SHOCKBOXMODELOFF );
								self AnimScripted( "close", self.origin, self.angles, level.shockbox_anim[ "off" ] );
							}
							if ( isdefined( self.unitrigger_stub ) )
							{
								self.unitrigger_stub.is_activated_in_afterlife = 0;
								self.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
							}
							break;
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

function afterlife_trigger_visible_in_afterlife( player )
{
	if ( isdefined( self.stub.is_activated_in_afterlife ) )
	{
		b_is_invis = self.stub.is_activated_in_afterlife;
	}
	self SetInvisibleToPlayer( player, b_is_invis );
	self SetHintString( self.stub.hint_string );
	if ( !b_is_invis )
	{
		if ( player zm_utility::is_player_looking_at( self.origin, 0,25 ) )
		{
			if ( math::cointoss() )
			{
				player thread zm_audio::create_and_play_dialog( "general", "need_electricity" );
			}
			else
			{
				player thread zm_audio::create_and_play_dialog( "general", "electric_zap" );
			}
		}
	}
	return !b_is_invis;
}

function afterlife_interact_hint_trigger_think()
{
	self endon( "kill_trigger" );
	while ( 1 )
	{
		self waittill( "trigger" );
		wait 1000;
	}
}

function afterlife_interact_object_fx_cooldown()
{
	wait 2;
	self.playing_fx = undefined;
}

function afterlife_zombie_damage()
{
	self.actor_damage_func = &afterlife_damage_func;
}

function afterlife_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( sweapon.name == "lightning_hands" )
	{
		if ( !isdefined( self.zapped ) )
		{
			a_zombies = util::get_array_of_closest( self.origin, GetAISpeciesArray( level.zombie_team ), undefined, 5, 80 );
			i = 0;
			while ( i < a_zombies.size )
			{
				if ( IsAlive( a_zombies[ i ] ) && !isdefined( a_zombies[ i ].zapped ) )
				{
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
	query_result = PositionQuery_Source_Navigation(self.origin + (0,0,5) , 0, 1200, 100, 32 );
	a_nodes = array::randomize( query_result.data );
	nd_target = undefined;
	i = 0;
	while ( i < a_nodes.size )
	{
		if ( Distance2DSquared( a_nodes[ i ].origin, self.origin ) > n_ideal_dist_sq )
		{
			if ( a_nodes[ i ] is_valid_teleport_node() )
			{
				nd_target = a_nodes[ i ];
				break;
			}
		}
		i++;
	}
	if ( !isdefined( nd_target ) )
	{
		i = 0;
		while ( i < a_nodes.size )
		{
			if ( Distance2DSquared( a_nodes[ i ].origin, self.origin ) > n_min_dist_sq )
			{
				if ( a_nodes[ i ] is_valid_teleport_node() )
				{
					nd_target = a_nodes[ i ];
					break;
				}
			}
			i++;
		}
	}
	if ( isdefined( nd_target ) )
	{
		v_fx_offset = vectorScale( ( 0, 0, 1 ), 40 );
		PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
		PlaySoundAtPosition( "zmb_afterlife_zombie_warp_out", self.origin );
		self Hide();
		linker = Spawn( "script_model", self.origin + v_fx_offset );
		linker SetModel( "tag_origin" );
		PlayFXOnTag( level._effect[ "teleport_ball" ], linker, "tag_origin" );
		linker thread linker_delete_watch( self );
		self LinkTo( linker );
		linker MoveTo( nd_target.origin + v_fx_offset, 1 );
		linker waittill( "movedone" );
		linker Delete();
		PlayFX( level._effect[ "afterlife_teleport" ], self.origin );
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
	//self notify( "stop_find_flesh" );
	self thread afterlife_zapped_fx();
	i = 0;
	while ( i < 3 )
	{
		// TODO: Make it so anims plays with ASMRequestSubstate
		//self animscripted( self.origin, self.angles, "zm_afterlife_stun" );
		//self maps/mp/animscripts/shared::donotetracks( "stunned" );
		wait 1;
		i++;
	}
	self.ignoreall = 0;
	//self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

function is_valid_teleport_node()
{
	if ( !zm_utility::check_point_in_enabled_zone( self.origin ) )
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
	foreach(player in GetPlayers())
	{
		if ( isdefined( player.afterlife_active ) && player.afterlife_active )
		{
			self SetVisibleToPlayer( player );
		}
		else
		{
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
		while ( a_players.size > 1 )
		{
			foreach(player in GetPlayers())
			{
				if ( player != self )
				{
					if ( DistanceSquared( self.origin, player.origin ) < 1000000 )
					{
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
	self.dontspeak = 0;
}

function conscience_vo_ended_early( str_alias )
{
	self notify( "conscience_VO_end_early" );
	self endon( "conscience_VO_end_early" );
	self util::waittill_any( "player_revived", "player_suicide", "zombified", "death", "end_game" );
	self.dontspeak = 0;
	self StopLocalSound( str_alias );
}

function afterlife_trigger_used_vo()
{
	a_vo = level.exert_sounds[ self.characterindex + 1 ][ "hitlrg" ];
	n_index = RandomInt( a_vo.size );
	self PlaySound( a_vo[ n_index ] );
}

// ALCATRAZ CLASSIC STUFF

function give_afterlife()
{
	callback::on_connect( &init_player );
	level flag::wait_till( "initial_players_connected" );
	SetDvar( "doublejump_enabled", 1 );
	wait 0.5;
	n_start_pos = 1;
	foreach(player in GetPlayers())
	{
		if ( isdefined( player.afterlife_active ) && !player.afterlife_active )
		{
			player thread fake_kill_player( n_start_pos );
			n_start_pos++;
		}
	}
	level flag::wait_till("initial_blackscreen_passed");
	level.overridePlayerDamage = &player_damage_override;
}

function fake_kill_player( n_start_pos )
{
	self afterlife_remove();
	e_corpse_location = struct::get( "corpse_starting_point_new_" + n_start_pos, "targetname" );
	self.afterlife_active = 1;
	self thread afterlife_laststand(false, e_corpse_location.origin);
	self waittill( "player_fake_corpse_created" );
	self thread afterlife_tutorial();
	trace_start = e_corpse_location.origin;
	trace_end = e_corpse_location.origin + vectorScale( ( 0, 0, 1 ), 100 );
	corpse_trace = PhysicsTrace( trace_start, trace_end, vectorScale( ( 0, 0, 1 ), 10 ), vectorScale( ( 0, 0, 1 ), 10 ), self.e_afterlife_corpse );
	self.e_afterlife_corpse.origin = corpse_trace[ "position" ];
	vec_to_target = self.e_afterlife_corpse.origin - self.origin;
	vec_to_target = VectortoAngles( vec_to_target );
	vec_to_target = ( 0, vec_to_target[ 1 ], 0 );
	self SetPlayerAngles( vec_to_target );
	self notify( "al_all_setup" );
}

function afterlife_tutorial()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	level flag::wait_till( "start_zombie_round_logic" );
	wait 3;
	self zm_alcatraz_utility::create_tutorial_message( &"ZM_PRISON_AFTERLIFE_HOWTO" );
	self thread afterlife_tutorial_attack_watch();
	util::waittill_notify_or_timeout( "stop_tutorial", 5 );
	self thread zm_alcatraz_utility::destroy_tutorial_message();
	wait 1;
	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
	{
		self zm_alcatraz_utility::create_tutorial_message( &"ZM_PRISON_AFTERLIFE_HOWTO_2" );
		self thread afterlife_tutorial_jump_watch();
		util::waittill_notify_or_timeout( "stop_tutorial", 5 );
		self thread zm_alcatraz_utility::destroy_tutorial_message();
	}
}

function afterlife_tutorial_attack_watch()
{
	self endon( "stop_tutorial" );
	self endon( "disconnect" );
	while ( isdefined( self.afterlife_active ) && self.afterlife_active && !self IsFiring() )
	{
		wait 0.05;
	}
	wait 0.2;
	self notify( "stop_tutorial" );
}

function afterlife_tutorial_jump_watch()
{
	self endon( "stop_tutorial" );
	self endon( "disconnect" );
	while ( isdefined( self.afterlife_active ) && self.afterlife_active && !self zm_utility::is_jumping() )
	{
		wait 0.05;
	}
	wait 0.2;
	self notify( "stop_tutorial" );
}

function afterlife_special_door_init()
{
	level thread wardens_office_door();
	level thread shower_door();
	level thread roof_door();
}

function wardens_office_door()
{
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

function shower_door()
{
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

function roof_door()
{
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

function power_on_perk_machines()
{
	level util::waittill_any( "unlock_all_perk_machines", "open_sesame" );
	foreach(e_shockbox in GetEntArray( "perk_afterlife_trigger", "script_noteworthy" ))
	{
		e_shockbox notify( "damage", 500 , level );
		wait 1;
	}
}

function afterlife_powerups()
{
	level flag::wait_till("initial_players_connected");
	level._powerup_grab_check = &cell_grab_check;
	s_powerup_loc = struct::get( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	s_powerup_loc = struct::get( "powerup_cell_1", "targetname" );
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "insta_kill" );
	}
	s_powerup_loc = struct::get( "powerup_cell_2", "targetname" );
	if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "double_points" );
	}
	else
	{
		spawn_infinite_powerup_drop( s_powerup_loc.origin, "full_ammo" );
	}
}

function cell_grab_check( player )
{
	cell_powerup = struct::get( "powerup_cell_1", "targetname" );
	if ( self.origin == ( cell_powerup.origin + VectorScale( ( 0, 0, 1 ), 40 ) ) )
	{
		m_door = GetEnt( "powerup_cell_door_1", "targetname" );
		if ( !isdefined( m_door.opened ) )
		{
			return 0;
		}
	}
	cell_powerup = struct::get( "powerup_cell_2", "targetname" );
	if ( self.origin == ( cell_powerup.origin + VectorScale( ( 0, 0, 1 ), 40 ) ) )
	{
		m_door = GetEnt( "powerup_cell_door_2", "targetname" );
		if ( !isdefined( m_door.opened ) )
		{
			return 0;
		}
	}
	return 1;
}

function afterlife_intro_door()
{
	level waittill( "intro_powerup_restored" );
	s_powerup_loc = struct::get( "powerup_start", "targetname" );
	spawn_infinite_powerup_drop( s_powerup_loc.origin );
}

function afterlife_cell_door_1()
{
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

function afterlife_cell_door_2()
{
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

function spawn_infinite_powerup_drop( v_origin, str_type )
{
	level._powerup_timeout_override = &powerup_infinite_time;
	if ( isdefined( str_type ) )
	{
		intro_powerup = zm_powerups::specific_powerup_drop( str_type, v_origin );
	}
	else
	{
		intro_powerup = zm_powerups::powerup_drop( v_origin );
	}
	level._powerup_timeout_override = undefined;
}

function powerup_infinite_time()
{
}

// SOMETHING NEW

function player_damage_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	iDamage = self zm::check_player_damage_callbacks( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );
	
	if( self.scene_takedamage === false )
	{
		return 0;
	}

	if ( IsDefined( eAttacker ) && IS_TRUE( eAttacker.b_aat_fire_works_weapon ) )
	{
		return 0;
	}
	
	if ( IS_TRUE( self.use_adjusted_grenade_damage ) )
    {
        self.use_adjusted_grenade_damage = undefined;
        if( ( self.health > iDamage ) )
        {
        	return iDamage;
        }
    }

	if ( !iDamage )
	{
		return 0;
	}
	
	// WW (8/20/10) - Sledgehammer fix for Issue 43492. This should stop the player from taking any damage while in laststand
	if( self laststand::player_is_in_laststand() )
	{
		return 0;
	}
	
	if ( isDefined( eInflictor ) )
	{
		if ( IS_TRUE( eInflictor.water_damage ) )
		{
			return 0;
		}
	}

	if ( isDefined( eAttacker ) )
	{
		if( IS_EQUAL( eAttacker.owner, self ) ) 
		{
			return 0;
		}
		
		if( isDefined( self.ignoreAttacker ) && self.ignoreAttacker == eAttacker ) 
		{
			return 0;
		}
		
		// AR (5/30/12) - Stop Zombie players from damaging other Zombie players
		if ( IS_TRUE( self.is_zombie ) && IS_TRUE( eAttacker.is_zombie ) )
		{
			return 0;
		}
		
		if( (isDefined( eAttacker.is_zombie ) && eAttacker.is_zombie) )
		{
			self.ignoreAttacker = eAttacker;
			self thread zm::remove_ignore_attacker();

			if ( isdefined( eAttacker.custom_damage_func ) )
			{
				iDamage = eAttacker [[ eAttacker.custom_damage_func ]]( self );
			}
		}
		
		eAttacker notify( "hit_player" ); 

		if ( isdefined( eAttacker ) && isdefined( eAttacker.func_mod_damage_override ) )
		{
			sMeansOfDeath = eAttacker [[ eAttacker.func_mod_damage_override ]]( eInflictor, sMeansOfDeath, weapon );
		}
		
		if( sMeansOfDeath != "MOD_FALLING" )
		{
			self thread zm::playSwipeSound( sMeansOfDeath, eattacker );
			if( IS_TRUE(eattacker.is_zombie) || IsPlayer(eAttacker) )
				self PlayRumbleOnEntity( "damage_heavy" );
			
			if( IS_TRUE(eattacker.is_zombie) )
			{
				self zm_audio::create_and_play_dialog( "general", "attacked" );
			}
			
			canExert = true;
			
			if ( IS_TRUE( level.pers_upgrade_flopper ) )
			{
				// If the player has persistent flopper power, then no exert on explosion
				if ( IS_TRUE( self.pers_upgrades_awarded[ "flopper" ] ) )
				{
					canExert = ( sMeansOfDeath != "MOD_PROJECTILE_SPLASH" && sMeansOfDeath != "MOD_GRENADE" && sMeansOfDeath != "MOD_GRENADE_SPLASH" );
				}
			}
			
			if ( IS_TRUE( canExert ) )
			{
			    if(RandomIntRange(0,1) == 0 )
			    {
			    	self thread zm_audio::playerExert( "hitmed" );
			        //self thread zm_audio::create_and_play_dialog( "general", "hitmed" );
			    }
			    else
			    {
			    	self thread zm_audio::playerExert( "hitlrg" );
			        //self thread zm_audio::create_and_play_dialog( "general", "hitlrg" );
			    }
			}
		}
	}
	
	//Audio(RG:2/1/2016) adding underwater drowning exert.
	if ( isDefined( sMeansOfDeath) && sMeansOfDeath == "MOD_DROWN")
	{
		self thread zm_audio::playerExert( "drowning", true );
		self.voxDrowning = true;
	}
	
	if( isdefined( level.perk_damage_override ) )
	{
		foreach( func in level.perk_damage_override )
		{
			n_damage = self [[ func ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );
			if( isdefined( n_damage ) )
			{
				iDamage = n_damage;		
			}
		}
	}	
	finalDamage = iDamage;

	if ( isdefined( self.afterlife_active ) && self.afterlife_active )
	{
		return 0;
	}
	
		
	// claymores and freezegun shatters, like bouncing betties, harm no players
	if ( zm_utility::is_placeable_mine( weapon ) )
	{
		return 0;
	}

	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}

	// exploding quads should not kill player
	if ( IsDefined( eInflictor ) && IsDefined( eInflictor.archetype ) && eInflictor.archetype == ARCHETYPE_ZOMBIE_QUAD )
	{
		if ( sMeansOfDeath == "MOD_EXPLOSIVE" )
		{
			if ( self.health > 75 )
			{
				return 75;
			}
		}
	}
	
	// Players can't die from cooked grenade if trhey have the bgb Danger Closet
	if ( sMeansOfDeath == "MOD_SUICIDE" && self bgb::is_enabled( "zm_bgb_danger_closest" ) )
	{
		return 0;
	}
	
	if ( sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE" )
	{
		if( self bgb::is_enabled( "zm_bgb_danger_closest" ) )
		{
			return 0;
		}
		
		// player explosive splash damage (caps explosive damage), fixes raygun damage being fatal (or grenades) when damaging yourself
		if ( !IS_TRUE( self.is_zombie ) )
		{
			// Don't do this for projectile damage coming from zombies
			if ( !isdefined( eAttacker ) || ( !IS_TRUE( eAttacker.is_zombie ) && !IS_TRUE( eAttacker.b_override_explosive_damage_cap ) ) )
			{
				// Only do it for ray gun
				if( isdefined(weapon.name) && ((weapon.name == "ray_gun") || ( weapon.name == "ray_gun_upgraded" )) )
				{
					// Clamp it, we don't want to increase the damage from player raygun splash damage or grenade splash damage
					// Don't create more damage than we are trying to apply
					if ( ( self.health > 25 ) && ( iDamage > 25 ) )
					{
						return 25;
					}
				}
				else if ( ( self.health > 75 ) && ( iDamage > 75 ) )
				{
					return 75;
				}
			}
		}
	}

	if( iDamage < self.health )
	{
		if ( IsDefined( eAttacker ) )
		{
			if( IsDefined( level.custom_kill_damaged_VO ) )
			{
				eAttacker thread [[ level.custom_kill_damaged_VO ]]( self );
			}
			else
			{
				eAttacker.sound_damage_player = self;	
			}
			
			if( IS_TRUE( eAttacker.missingLegs ) )
			{
			    self zm_audio::create_and_play_dialog( "general", "crawl_hit" );
			}
		}
		
		// MM (08/10/09)
		return finalDamage;
	}

	// Afterlife Down
	if ( self.af_lives > 0 && isdefined( self.afterlife_active ) && !self.afterlife_active )
	{
		self PlaySoundToPlayer( "zmb_afterlife_death", self );
		self afterlife_remove();
		self.afterlife_active = 1;
		self thread afterlife_laststand();
		return 0;
	}
	else
	{
		self thread last_stand_conscience_vo();
	}
	
	//player died
	if( isdefined( eAttacker ) )
	{
		if(isDefined(eAttacker.animname) && eAttacker.animname == "zombie_dog")
		{
			self zm_stats::increment_client_stat( "killed_by_zdog" );
			self zm_stats::increment_player_stat( "killed_by_zdog" );
		}
		else if(IS_TRUE(eAttacker.is_avogadro))
		{
			self zm_stats::increment_client_stat( "killed_by_avogadro", false );
			self zm_stats::increment_player_stat( "killed_by_avogadro" );
		}
	}

	self thread zm::clear_path_timers();
		
	if( level.intermission )
	{
		level waittill( "forever" );
	}
	
	// AR (3/7/12) - Keep track of which player killed player in Zombify modes like Cleansed / Turned
	// Confirmed with Alex 
	if ( level.scr_zm_ui_gametype == "zcleansed" && iDamage > 0 )
	{
		if ( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && eAttacker.team != self.team && ( ( !IS_TRUE( self.laststand ) && !self laststand::player_is_in_laststand() ) || !IsDefined( self.last_player_attacker ) ) )
		{
			// Restore Health To Zombie Player
			//--------------------------------
			if ( IsDefined( eAttacker.maxhealth ) && IS_TRUE( eAttacker.is_zombie ) )
			{
				eAttacker.health = eAttacker.maxhealth;
			}
			
			//self.last_player_attacker = eAttacker;

			if ( IsDefined( level.player_kills_player ) )
			{
				self thread [[ level.player_kills_player]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime );
			}			
		}
	}
	
	if ( self.lives > 0 && self HasPerk( PERK_WHOSWHO ) )
	{
		self.lives--;
		if ( IsDefined( level.whoswho_laststand_func ) )
		{
			self thread [[ level.whoswho_laststand_func]]();
			return 0;
		}			
	}	
	
	players = GetPlayers();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] == self || players[i].is_zombie || players[i] laststand::player_is_in_laststand() || players[i].sessionstate == "spectator" )
		{
			count++;
		}
	}
	
	if( count < players.size || (isDefined(level._game_module_game_end_check) && ![[level._game_module_game_end_check]]()) )
	{
		if ( IsDefined( self.lives ) && self.lives > 0 && IS_TRUE( level.force_solo_quick_revive ) &&  self HasPerk( PERK_QUICK_REVIVE ) )
		{
			self thread zm::wait_and_revive();
		}
		
		// MM (08/10/09)
		return finalDamage;
	}
	
	// PORTIZ 7/27/16: added level.no_end_game_check here, because if it's true by this point, this function will end up returning finalDamage anyway. additionally, 
	// no_end_game_check has been updated to support incrementing/decrementing, which makes it more robust than a single level.check_end_solo_game_override as more
	// mechanics are introduced that require solo players to go into last stand instead of losing the game immediately
	if ( players.size == 1 && level flag::get( "solo_game" ) )
	{
		if ( IS_TRUE( level.no_end_game_check ) || ( isdefined( level.check_end_solo_game_override ) && [[level.check_end_solo_game_override]]() ) )
		{
			return finalDamage;
		}
		else if ( self.lives == 0 || !self HasPerk( PERK_QUICK_REVIVE ) )
		{
			self.intermission = true;
		}
	}
	
	
	
	
	// WW (01/05/11): When a two players enter a system link game and the client drops the host will be treated as if it was a solo game
	// when it wasn't. This led to SREs about undefined and int being compared on death (self.lives was never defined on the host). While
	// adding the check for the solo game flag we found that we would have to create a complex OR inside of the if check below. By breaking
	// the conditions out in to their own variables we keep the complexity without making it look like a mess.
	solo_death = ( players.size == 1 && level flag::get( "solo_game" ) && ( self.lives == 0  || !self HasPerk(PERK_QUICK_REVIVE) ) ); // there is only one player AND the flag is set AND self.lives equals 0
	non_solo_death = ( ( count > 1 || ( players.size == 1 && !level flag::get( "solo_game" ) ) ) /*&& !level.is_zombie_level*/ ); // the player size is greater than one OR ( players.size equals 1 AND solo flag isn't set ) AND not a zombify game level
	if ( (solo_death || non_solo_death) && !IS_TRUE(level.no_end_game_check ) ) // if only one player on their last life or any game that started with more than one player
	{	
		level notify("stop_suicide_trigger");
		self AllowProne( true ); //just in case
		self thread zm_laststand::PlayerLastStand( eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime );
		if( !isdefined( vDir ) )
		{
			vDir = ( 1.0, 0.0, 0.0 );
		}
		self FakeDamageFrom(vDir);
		
		level notify("last_player_died");
		if ( isdefined(level.custom_player_fake_death) )
			self thread [[level.custom_player_fake_death]](vDir, sMeansOfDeath);
		else
			self thread zm::player_fake_death();
	}

	if( count == players.size && !IS_TRUE( level.no_end_game_check ) )
	{
		if ( players.size == 1 && level flag::get( "solo_game" ))
		{
			if ( self.lives == 0 || !self HasPerk(PERK_QUICK_REVIVE) ) // && !self laststand::player_is_in_laststand()
			{
				self.lives = 0;
				level notify("pre_end_game");
				util::wait_network_frame();
				if(level flag::get("dog_round"))
				{
					zm::increment_dog_round_stat( "lost" );	
						
				}				
				level notify( "end_game" );
			}
			else
			{
				return finalDamage;
			}
		}
		else
		{
			level notify("pre_end_game");
			util::wait_network_frame();
			if(level flag::get("dog_round"))
			{
				zm::increment_dog_round_stat( "lost" );	
					
			}
			level notify( "end_game" );
		}
		return 0;	// MM (09/16/09) Need to return something
	}
	else
	{
		// MM (08/10/09)
		
		surface = "flesh";
		
		return finalDamage;
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