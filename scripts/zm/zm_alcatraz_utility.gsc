#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\spawner_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\math_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_afterlife;

#using scripts\zm\zm_prison_weap_quest;
#using scripts\zm\zm_alcatraz_sq_vo;
#using scripts\zm\zm_alcatraz_amb;
#using scripts\zm\zm_prison_sq_wth;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\zm\zm_giant_cleanup_mgr;

function autoexec init()
{
	level.special_weapon_magicbox_check = &check_for_special_weapon_limit_exist;
	level._zmbvoxlevelspecific = &init_level_specific_audio;
	level thread check_solo_status();
	callback::on_connect( &zm_prison_weap_quest::tomahawk_upgrade_quest );
	callback::on_connect( &riotshield_tutorial_hint );
	callback::on_connect( &disable_powerup_if_player_on_bridge );
	level thread enable_powerup_if_no_player_on_bridge();
	callback::on_connect( &player_portal_clue_vo );
	level.wolf_encounter_vo_played = false;
}

function include_craftable( craftable_struct )
{
/#
	IPrintLnBold( "ZM >> include_craftable = " + craftable_struct.name );
#/
	zm_craftables::include_zombie_craftable( craftable_struct );
}

function is_craftable()
{
	return self zm_craftables::is_craftable();
}

function is_part_crafted( craftable_name, part_modelname )
{
	return zm_craftables::is_part_crafted( craftable_name, part_modelname );
}

function wait_for_craftable( craftable_name )
{
	level waittill( craftable_name + "_crafted", player );
	return player;
}

function is_team_on_golden_gate_bridge()
{
	players = GetPlayers();
	e_zone = GetEnt( "bridge_zone", "targetname" );
	_a57 = players;
	_k57 = GetFirstArrayKey( _a57 );
	while ( isdefined( _k57 ) )
	{
		player = _a57[ _k57 ];
		if ( player IsTouching( e_zone ) )
		{
		}
		else return 0;
		_k57 = GetNextArrayKey( _a57, _k57 );
	}
	return 1;
}

function create_tutorial_message( str_msg )
{
	if ( !isdefined( self.client_hint ) )
	{
		self.client_hint = NewClientHudElem( self );
		self.client_hint.alignx = "center";
		self.client_hint.aligny = "middle";
		self.client_hint.horzalign = "center";
		self.client_hint.vertalign = "bottom";
		if ( self IsSplitScreen() )
		{
			self.client_hint.y = -140;
		}
		else
		{
			self.client_hint.y = -250;
		}
		self.client_hint.foreground = 1;
		self.client_hint.font = "default";
		self.client_hint.fontscale = 1.5;
		self.client_hint.alpha = 1;
		self.client_hint.foreground = 1;
		self.client_hint.hidewheninmenu = 1;
		self.client_hint.color = ( 1, 1, 1 );
	}
	self.client_hint SetText( str_msg );
}

function destroy_tutorial_message()
{
	if ( isdefined( self.client_hint ) )
	{
		self.client_hint FadeOverTime( 0.5 );
		self.client_hint.alpha = 0;
		wait 0.5;
		if ( isdefined( self.client_hint ) )
		{
			self.client_hint Destroy();
			self.client_hint = undefined;
		}
	}
}

function get_array_of_farthest( org, array, excluders, max )
{
	sorted_array = util::get_array_of_closest( org, array, excluders );
	if ( isdefined( max ) )
	{
		temp_array = [];
		i = 0;
		while ( i < sorted_array.size )
		{
			temp_array[ temp_array.size ] = sorted_array[ sorted_array.size - i ];
			i++;
		}
		sorted_array = temp_array;
	}
	sorted_array = array::reverse( sorted_array );
	return sorted_array;
}

function drop_all_barriers()
{
	zkeys = GetArrayKeys( level.zones );
	z = 0;
	while ( z < level.zones.size )
	{
		while ( zkeys[ z ] != "start_zone" && zkeys[ z ] != "library_zone" )
		{
			zbarriers = get_all_zone_zbarriers( zkeys[ z ] );
			if ( !isdefined( zbarriers ) )
			{
				z++;
				continue;
			}
			else
			{
				_a155 = zbarriers;
				_k155 = GetFirstArrayKey( _a155 );
				while ( isDefined( _k155 ) )
				{
					zbarrier = _a155[ _k155 ];
					zbarrier_pieces = zbarrier GetNumZBarrierPieces();
					i = 0;
					while ( i < zbarrier_pieces )
					{
						zbarrier HideZBarrierPiece( i );
						zbarrier SetZBarrierPieceState( i, "open" );
						i++;
					}
					wait 0.05;
					_k155 = GetNextArrayKey( _a155, _k155 );
				}
			}
		}
		z++;
	}
}

function get_all_zone_zbarriers( zone_name )
{
	if ( !isdefined( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
	return zone.zbarriers;
}

function player_lightning_manager()
{
	self endon( "disconnect" );
	self.b_lightning = 0;
	a_bad_zones[ 0 ] = "zone_dryer";
	a_bad_zones[ 1 ] = "zone_studio";
	a_bad_zones[ 2 ] = "zone_citadel_stairs";
	a_bad_zones[ 3 ] = "cellblock_shower";
	a_bad_zones[ 4 ] = "zone_citadel";
	a_bad_zones[ 5 ] = "zone_infirmary";
	a_bad_zones[ 6 ] = "zone_infirmary_roof";
	a_bad_zones[ 7 ] = "zone_citadel_shower";
	while ( 1 )
	{
		str_player_zone = self zm_zonemgr::get_player_zone();
		while ( !isdefined( str_player_zone ) )
		{
			wait 1;
		}
		if ( isdefined( level.hostmigrationtimer ) )
		{
			level waittill( "host_migration_end" );
			self.b_lightning = 0;
			//self clientfield::set_to_player( "toggle_lightning", 0 );
			wait 1;
		}
		while ( isdefined( self.afterlife ) || self.afterlife && isdefined( self.scary_lightning ) && self.scary_lightning )
		{
			self.b_lightning = 0;
			//self clientfield::set_to_player( "toggle_lightning", 0 );
			while ( isdefined( self.afterlife ) || self.afterlife && isDefined( self.scary_lightning ) && self.scary_lightning )
			{
				wait 0.05;
			}
		}
		if ( isdefined( self.b_lightning ) && self.b_lightning )
		{
			_a496 = a_bad_zones;
			_k496 = GetFirstArrayKey( _a496 );
			while ( isdefined( _k496 ) )
			{
				str_bad_zone = _a496[ _k496 ];
				if ( str_player_zone == str_bad_zone )
				{
					self.b_lightning = 0;
					//self clientfield::set_to_player( "toggle_lightning", 0 );
					break;
				}
				else
				{
					_k496 = GetNextArrayKey( _a496, _k496 );
				}
			}
		}
		else self.b_lightning = 1;
		_a512 = a_bad_zones;
		_k512 = GetFirstArrayKey( _a512 );
		while ( isdefined( _k512 ) )
		{
			str_bad_zone = _a512[ _k512 ];
			if ( str_player_zone == str_bad_zone )
			{
				self.b_lightning = 0;
			}
			_k512 = GetNextArrayKey( _a512, _k512 );
		}
		if ( isdefined( self.b_lightning ) && self.b_lightning )
		{
			//self clientfield::set_to_player( "toggle_lightning", 1 );
		}
		wait 1;
	}
}

function setting_tutorial_hud()
{
	client_hint = NewClientHudElem( self );
	client_hint.x = 320;
	client_hint.y = 220;
	client_hint.alignx = "center";
	client_hint.aligny = "bottom";
	client_hint.fontscale = 1.6;
	client_hint.alpha = 1;
	client_hint.sort = 20;
	return client_hint;
}

function riotshield_tutorial_hint()
{
	self waittill( "alcatraz_shield_zm_given" );
	wait 4;
	hud = setting_tutorial_hud();
	hud SetText( &"ZM_PRISON_RIOTSHIELD_ATTACK" );
	self util::waittill_notify_or_timeout( "shield_attack", 3 );
	hud SetText( &"ZM_PRISON_RIOTSHIELD_DEPLOY" );
	self util::waittill_notify_or_timeout( "shield_attack", 3 );
	hud Destroy();
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

function disable_powerup_if_player_on_bridge()
{
	self endon( "disconnect" );
	level flag::wait_till( "afterlife_start_over" );
	while ( 1 )
	{
		if ( self is_player_in_zone( "bridge_zone" ) )
		{
			if ( level flag::get( "zombie_drop_powerups" ) )
			{
				level flag::clear( "zombie_drop_powerups" );
			}
		}
		wait 1;
	}
}

function enable_powerup_if_no_player_on_bridge()
{
	level flag::wait_till( "afterlife_start_over" );
	while ( 1 )
	{
		n_player_total = 0;
		n_player_total += zm_zonemgr::get_players_in_zone( "bridge_zone" );
		if ( n_player_total == 0 && !level flag::get( "zombie_drop_powerups" ) )
		{
			level flag::set( "zombie_drop_powerups" );
		}
		wait 1;
	}
}

function print_origin()
{
	while(1)
	{
		if(self UseButtonPressed())
		{
			IPrintLnBold("origin: "+self.origin);
			IPrintLnBold("angle: "+self.angles);
		}
		wait 0.5;
	}
}

function body_testing()
{
	body = 0;
	while(1)
	{
		if (body == 0)
		{
			IPrintLnBold("hide");
			body = 1;
		}
		else
		{
			IPrintLnBold("show");
			body = 0;
		}
		self SetCharacterBodyStyle(body);
		wait 2;
	}
}

function init_level_specific_audio()
{
	level.oh_shit_vo_cooldown = 0;
	level.wolf_kill_vo_cooldown = 0;
	level.wallbuys_purchased = 0;
	SetDvar( "zombie_kills", "5" );
	SetDvar( "zombie_kill_timer", "5" );
	//level._audio_custom_response_line = &alcatraz_audio_custom_response_line;
	
	level thread alcatraz_first_magic_box_seen_vo();
	
	level thread brutus_spawn_vo_watcher();
	level thread brutus_killed_vo_watcher();
	zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_al_vox.csv");
	level thread setup_conversation_vo();
	level flag::wait_till("afterlife_start_over");

	// SPAWN FIXES
    foreach(player in GetPlayers())
	{
        // Dev mode
		if (player.name == "MotoLegacy" || player.name == "JariK") {
			player.score = 100000;
			player.af_lives = -1;
			player _zm_afterlife::afterlife_infinite_mana( 1 );
			player thread print_origin();
			//player thread body_testing();

			//player GiveWeapon(level.weaponRiotshield);
		}

		// Fix the dumb extra 8 rounds in colt
		player SetWeaponAmmoStock(level.start_weapon, 32);
		wait 1;
		player setClientUIVisibilityFlag( "hud_visible", 1 );
		player setClientUIVisibilityFlag( "weapon_hud_visible", 1 );
	}
    // END SPAWN FIXES
	level notify( "Pack_A_Punch_on" );

	wait 5;
	
	level.audio_get_mod_type = &alcatraz_audio_get_mod_type_override;
	level._audio_custom_weapon_check = &alcatraz_audio_custom_weapon_check;
	level.custom_kill_damaged_vo = &zm_audio::custom_kill_damaged_vo;
	level._custom_zombie_oh_shit_vox_func = &alcatraz_custom_zombie_oh_shit_vox;
	level.gib_on_damage = &alcatraz_custom_crawler_spawned_vo;
}

function alcatraz_add_player_dialogue( speaker, category, type, alias, response, chance )
{
	level.vox zm_audio::zmbvoxadd( speaker, category, type, alias, response );
	if ( isdefined( chance ) )
	{
		zm_utility::add_vox_response_chance( type, chance );
	}
}

function alcatraz_audio_get_mod_type_override( impact, mod, weapon, zombie, instakill, dist, player )
{
	close_dist = 4096;
	med_dist = 15376;
	far_dist = 75625;
	a_str_mod = [];
	if ( isdefined( zombie.my_soul_catcher ) )
	{
		if ( isdefined( zombie.my_soul_catcher.wolf_kill_cooldown ) && !zombie.my_soul_catcher.wolf_kill_cooldown )
		{
			//if ( isdefined( player.soul_catcher_cooldown ) && !player.soul_catcher_cooldown )
			//{
				if ( isdefined( zombie.my_soul_catcher.souls_received ) && zombie.my_soul_catcher.souls_received > 0 )
				{
					a_str_mod[ a_str_mod.size ] = "wolf_kill";
				}
			//}
		}
	}

	/*if ( zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" ) {
		if ( zombie.damageweapon.name == "bo2_acidgat_bullet" ) {
			if ( IsPlayer( zombie.attacker ) ) {
				IPrintLnBold("AAAAA");
			}
		}
	}*/

	if ( weapon.name == "bo2_blundergat" || weapon.name == "bo2_blundergat_upgraded" )
	{
		//IPrintLnBold("blunder");
		a_str_mod[ a_str_mod.size ] = "blundergat";
	}
	/*if ( weapon.name == "bo2_acidgat" || weapon.name == "bo2_acidgat_upgraded" )
	{
		IPrintLnBold("acid");
		a_str_mod[ a_str_mod.size ] = "acidgat";
	}
	if ( isdefined( zombie.damageweapon ) && zombie.damageweapon == "bo2_acidgat_bullet" )
	{
		IPrintLnBold("acid");
		a_str_mod[ a_str_mod.size ] = "acidgat";
	}*/
	if ( isdefined( zombie.damageweapon.name ) && zombie.damageweapon.name == "zombie_tomahawk" )
	{
		a_str_mod[ a_str_mod.size ] = "retriever";
	}
	if ( isdefined( zombie.damageweapon.name ) && zombie.damageweapon.name == "zombie_tomahawk_upgraded" )
	{
		a_str_mod[ a_str_mod.size ] = "redeemer";
	}
	if ( weapon.name == "minigun_alcatraz" || weapon.name == "minigun_alcatraz_upgraded" )
	{
		a_str_mod[ a_str_mod.size ] = "death_machine";
	}
	if ( zm_utility::is_headshot( weapon, impact, mod ) && dist >= far_dist )
	{
		a_str_mod[ a_str_mod.size ] = "headshot";
	}
	if ( zm_utility::is_explosive_damage( mod ) && weapon.name != "ray_gun" && weapon.name != "ray_gun_upgraded" && isdefined( zombie.is_on_fire ) && !zombie.is_on_fire )
	{
		if ( !IsInArray( a_str_mod, "retriever" ) && !IsInArray( a_str_mod, "redeemer" ) )
		{
			if ( !instakill )
			{
				a_str_mod[ a_str_mod.size ] = "explosive";
			}
			else
			{
				a_str_mod[ a_str_mod.size ] = "weapon_instakill";
			}
		}
	}
	if ( weapon.name == "ray_gun" || weapon.name == "ray_gun_upgraded" )
	{
		if ( dist > far_dist )
		{
			if ( !instakill )
			{
				a_str_mod[ a_str_mod.size ] = "raygun";
			}
			else
			{
				a_str_mod[ a_str_mod.size ] = "weapon_instakill";
			}
		}
	}
	if ( instakill )
	{
		if ( mod == "MOD_MELEE" )
		{
			a_str_mod[ a_str_mod.size ] = "melee_instakill";
		}
		else
		{
			a_str_mod[ a_str_mod.size ] = "weapon_instakill";
		}
	}
	if ( mod != "MOD_MELEE" && !zombie.has_legs )
	{
		a_str_mod[ a_str_mod.size ] = "crawler";
	}
	if ( mod != "MOD_BURNED" && dist < close_dist )
	{
		a_str_mod[ a_str_mod.size ] = "closekill";
	}
	if ( a_str_mod.size == 0 )
	{
		str_mod_final = "default";
	}
	else if ( a_str_mod.size == 1 )
	{
		str_mod_final = a_str_mod[ 0 ];
	}
	else
	{
		i = 0;
		while ( i < a_str_mod.size )
		{
			if ( math::cointoss() )
			{
				str_mod_final = a_str_mod[ i ];
			}
			i++;
		}
		str_mod_final = a_str_mod[ randomint( a_str_mod.size ) ];
	}
	if ( str_mod_final == "wolf_kill" )
	{
		player thread wolf_kill_cooldown_watcher( zombie.my_soul_catcher );
	}
	return str_mod_final;
}

function wolf_kill_cooldown_watcher( soul_catcher )
{
	self endon( "disconnect" );
	self waittill( "speaking", type );
	if ( type == "wolf_kill" )
	{
		self.soul_catcher_cooldown = 1;
		soul_catcher thread wolf_kill_cooldown();
	}
}

function wolf_kill_cooldown()
{
	self.wolf_kill_cooldown = 1;
	wait 60;
	self.wolf_kill_cooldown = 0;
}

function setup_conversation_vo()
{
	level.conscience_vo = [];
	level.conscience_vo[ "conscience_Finn_convo_1" ] = [];
	level.conscience_vo[ "conscience_Finn_convo_1" ][ 0 ] = "vox_plr_0_finn_self_2_0";
	level.conscience_vo[ "conscience_Finn_convo_1" ][ 1 ] = "vox_plr_0_finn_self_2_1";
	level.conscience_vo[ "conscience_Finn_convo_1" ][ 2 ] = "vox_plr_0_finn_self_2_2";
	level.conscience_vo[ "conscience_Finn_convo_1" ][ 3 ] = "vox_plr_0_finn_self_2_3";
	level.conscience_vo[ "conscience_Finn_convo_1" ][ 4 ] = "vox_plr_0_finn_self_2_4";
	level.conscience_vo[ "conscience_Finn_convo_2" ] = [];
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 0 ] = "vox_plr_0_finn_self_3_0";
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 1 ] = "vox_plr_0_finn_self_3_1";
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 2 ] = "vox_plr_0_finn_self_3_2";
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 3 ] = "vox_plr_0_finn_self_3_3";
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 4 ] = "vox_plr_0_finn_self_3_4";
	level.conscience_vo[ "conscience_Finn_convo_2" ][ 5 ] = "vox_plr_0_finn_self_3_5";
	level.conscience_vo[ "conscience_Sal_convo_1" ] = [];
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 0 ] = "vox_plr_1_sal_self_2_0";
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 1 ] = "vox_plr_1_sal_self_2_1";
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 2 ] = "vox_plr_1_sal_self_2_2";
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 3 ] = "vox_plr_1_sal_self_2_3";
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 4 ] = "vox_plr_1_sal_self_2_4";
	level.conscience_vo[ "conscience_Sal_convo_1" ][ 5 ] = "vox_plr_1_sal_self_2_5";
	level.conscience_vo[ "conscience_Sal_convo_2" ] = [];
	level.conscience_vo[ "conscience_Sal_convo_2" ][ 0 ] = "vox_plr_1_sal_self_3_0";
	level.conscience_vo[ "conscience_Sal_convo_2" ][ 1 ] = "vox_plr_1_sal_self_3_1";
	level.conscience_vo[ "conscience_Sal_convo_2" ][ 2 ] = "vox_plr_1_sal_self_3_2";
	level.conscience_vo[ "conscience_Sal_convo_2" ][ 3 ] = "vox_plr_1_sal_self_3_3";
	level.conscience_vo[ "conscience_Sal_convo_2" ][ 4 ] = "vox_plr_1_sal_self_3_4";
	level.conscience_vo[ "conscience_Billy_convo_1" ] = [];
	level.conscience_vo[ "conscience_Billy_convo_1" ][ 0 ] = "vox_plr_2_billy_self_2_0";
	level.conscience_vo[ "conscience_Billy_convo_1" ][ 1 ] = "vox_plr_2_billy_self_2_1";
	level.conscience_vo[ "conscience_Billy_convo_1" ][ 2 ] = "vox_plr_2_billy_self_2_2";
	level.conscience_vo[ "conscience_Billy_convo_1" ][ 3 ] = "vox_plr_2_billy_self_2_3";
	level.conscience_vo[ "conscience_Billy_convo_1" ][ 4 ] = "vox_plr_2_billy_self_2_4";
	level.conscience_vo[ "conscience_Billy_convo_2" ] = [];
	level.conscience_vo[ "conscience_Billy_convo_2" ][ 0 ] = "vox_plr_2_billy_self_3_0";
	level.conscience_vo[ "conscience_Billy_convo_2" ][ 1 ] = "vox_plr_2_billy_self_3_1";
	level.conscience_vo[ "conscience_Billy_convo_2" ][ 2 ] = "vox_plr_2_billy_self_3_2";
	level.conscience_vo[ "conscience_Billy_convo_2" ][ 3 ] = "vox_plr_2_billy_self_3_3";
	level.conscience_vo[ "conscience_Billy_convo_2" ][ 4 ] = "vox_plr_2_billy_self_3_4";
	level.conscience_vo[ "conscience_Arlington_convo_1" ] = [];
	level.conscience_vo[ "conscience_Arlington_convo_1" ][ 0 ] = "vox_plr_3_arlington_self_2_0";
	level.conscience_vo[ "conscience_Arlington_convo_1" ][ 1 ] = "vox_plr_3_arlington_self_2_2";
	level.conscience_vo[ "conscience_Arlington_convo_1" ][ 2 ] = "vox_plr_3_arlington_self_2_3";
	level.conscience_vo[ "conscience_Arlington_convo_1" ][ 3 ] = "vox_plr_3_arlington_self_2_4";
	level.conscience_vo[ "conscience_Arlington_convo_1" ][ 4 ] = "vox_plr_3_arlington_self_2_5";
	level.conscience_vo[ "conscience_Arlington_convo_2" ] = [];
	level.conscience_vo[ "conscience_Arlington_convo_2" ][ 0 ] = "vox_plr_3_arlington_self_3_0";
	level.conscience_vo[ "conscience_Arlington_convo_2" ][ 1 ] = "vox_plr_3_arlington_self_3_1";
	level.conscience_vo[ "conscience_Arlington_convo_2" ][ 2 ] = "vox_plr_3_arlington_self_3_2";
	level.conscience_vo[ "conscience_Arlington_convo_2" ][ 3 ] = "vox_plr_3_arlington_self_3_3";
	level.conscience_vo[ "conscience_Arlington_convo_2" ][ 4 ] = "vox_plr_3_arlington_self_3_4";
}

function alcatraz_custom_zombie_oh_shit_vox()
{
	self endon( "death_or_disconnect" );
	while ( 1 )
	{
		wait 1;
		if ( isdefined( self.oh_shit_vo_cooldown ) && self.oh_shit_vo_cooldown )
		{
			continue;
		}
		players = GetPlayers();
		zombs = zombie_utility::get_round_enemy_array();
		if ( players.size <= 1 )
		{
			n_distance = 250;
			n_zombies = 5;
			n_chance = 30;
			n_cooldown_time = 20;
		}
		else
		{
			n_distance = 250;
			n_zombies = 5;
			n_chance = 30;
			n_cooldown_time = 15;
		}
		close_zombs = 0;
		i = 0;
		while ( i < zombs.size )
		{
			if ( isdefined( zombs[ i ].favoriteenemy ) || zombs[ i ].favoriteenemy == self && !isdefined( zombs[ i ].favoriteenemy ) )
			{
				if ( DistanceSquared( zombs[ i ].origin, self.origin ) < ( n_distance * n_distance ) )
				{
					close_zombs++;
				}
			}
			i++;
		}
		if ( close_zombs >= n_zombies )
		{
			if ( RandomInt( 100 ) < n_chance && isdefined( self.isonbus ) && !self.isonbus )
			{
				self zm_audio::create_and_play_dialog( "general", "oh_shit" );
				self thread global_oh_shit_cooldown_timer( n_cooldown_time );
				wait n_cooldown_time;
			}
		}
	}
}

function global_oh_shit_cooldown_timer( n_cooldown_time )
{
	self endon( "disconnect" );
	self.oh_shit_vo_cooldown = 1;
	wait n_cooldown_time;
	self.oh_shit_vo_cooldown = 0;
}

function alcatraz_custom_crawler_spawned_vo()
{
	self endon( "death" );
	if ( isdefined( self.a.gib_ref ) && IsAlive( self ) )
	{
		if ( self.a.gib_ref != "no_legs" || self.a.gib_ref == "right_leg" && self.a.gib_ref == "left_leg" )
		{
			if ( isdefined( self.attacker ) && IsPlayer( self.attacker ) )
			{
				if ( isdefined( self.attacker.crawler_created_vo_cooldown ) && self.attacker.crawler_created_vo_cooldown )
				{
					return;
				}
				rand = RandomIntRange( 0, 100 );
				if ( rand < 15 )
				{
					self.attacker zm_audio::create_and_play_dialog( "general", "crawl_spawn" );
					self.attacker thread crawler_created_vo_cooldown();
				}
			}
		}
	}
}

function crawler_created_vo_cooldown()
{
	self endon( "disconnect" );
	self.crawler_created_vo_cooldown = 1;
	wait 30;
	self.crawler_created_vo_cooldown = 0;
}

function alcatraz_first_magic_box_seen_vo()
{
	level flag::wait_till( "start_zombie_round_logic" );
	magicbox = level.chests[ level.chest_index ];
	foreach(player in GetPlayers()) {
		player thread wait_and_play_first_magic_box_seen_vo( magicbox.unitrigger_stub );
	}
}

function wait_and_play_first_magic_box_seen_vo( struct )
{
	self endon( "disconnect" );
	level endon( "first_maigc_box_discovered" );
	while ( 1 )
	{
		if ( DistanceSquared( self.origin, struct.origin ) < 40000 )
		{
			if ( self zm_utility::is_player_looking_at( struct.origin, 0.25 ) )
			{
				if ( isdefined( self.dontspeak ) && !self.dontspeak )
				{
					self thread zm_audio::create_and_play_dialog( "general", "discover_box" );
					level notify( "first_maigc_box_discovered" );
					return;
				}
			}
		}
		else
		{
			wait 0.1;
		}
		wait 0.05;
	}
	
}

function alcatraz_audio_custom_weapon_check( weapon, magic_box )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( isdefined( magic_box ) && magic_box )
	{
		type = self zm_weapons::weapon_type_check( weapon );
		return type;
	}
	if ( IsSubStr( weapon.name, "upgraded" ) )
	{
		self thread zm_audio::create_and_play_dialog( "general", "wpck_pap" );
	}
	else if ( level.wallbuys_purchased == 0 )
	{
		self thread zm_audio::create_and_play_dialog( "general", "discover_wall_buy" );
		level.wallbuys_purchased++;
	}
	else
	{
		self thread zm_audio::create_and_play_dialog( "general", "generic_wall_buy" );
	}
	return "crappy";
}

function brutus_spawn_vo_watcher()
{
	level.total_brutuses_spawned = 0;
	while ( 1 )
	{
		level waittill( "brutus_spawned", ai_brutus );
		if ( !isdefined( ai_brutus ) )
		{
			continue;
		}
		if ( isdefined( level.brutus_spawn_vo_cooldown ) && level.brutus_spawn_vo_cooldown )
		{
			continue;
		}
		ai_brutus thread brutus_reaction_vo_watcher();
		ai_brutus thread brutus_helmet_pop_vo_watcher();
		if ( level.total_brutuses_spawned == 0 )
		{
			str_vo_category = "brutus_encounter";
		}
		else
		{
			str_vo_category = "brutus_arrival";
		}
		wait 3;
		if ( !IsAlive( ai_brutus ) )
		{
			continue;
		}
		a_players = GetPlayers();
		a_closest = util::get_array_of_closest( ai_brutus.origin, a_players );
		i = 0;
		while ( i < a_closest.size )
		{
			if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
			{
				if ( IsAlive( a_closest[ i ] ) && IsAlive( ai_brutus ) )
				{
					a_closest[ i ] thread zm_audio::create_and_play_dialog( "general", str_vo_category );
					level thread brutus_spawn_vo_cooldown();
				}
			}
			i++;
		}
	}
}

function brutus_spawn_vo_cooldown()
{
	level.brutus_spawn_vo_cooldown = 1;
	wait 30;
	level.brutus_spawn_vo_cooldown = 0;
}

function brutus_reaction_vo_watcher()
{
	self endon( "death" );
	level endon( "restart_brutus_reaction_vo_watcher" );
	if ( IsAlive( self ) )
	{
		wait RandomFloatRange( 20, 40 );
		a_players = GetPlayers();
		a_closest = util::get_array_of_closest( self.origin, a_players );
		i = 0;
		while ( i < a_closest.size )
		{
			if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
			{
				if ( DistanceSquared( a_closest[ i ].origin, self.origin ) < 1000000 )
				{
					a_closest[ i ] thread zm_audio::create_and_play_dialog( "general", "brutus_reaction" );
				}
			}
			i++;
		}
	}
}

function brutus_helmet_pop_vo_watcher()
{
	self endon( "death" );
	level waittill( "brutus_helmet_removed", player );
	wait 3;
	if ( IsAlive( player ) )
	{
		player thread zm_audio::create_and_play_dialog( "general", "brutus_reaction" );
	}
	level notify( "restart_brutus_reaction_vo_watcher" );
	self thread brutus_reaction_vo_watcher();
}

function brutus_killed_vo_watcher()
{
	while ( 1 ) {
		level waittill( "brutus_killed", player );
		wait 5;
		if ( IsAlive( player ) ) {
			player thread zm_audio::create_and_play_dialog( "general", "brutus_defeated" );
		}
	}
}

function easter_egg_song_vo( player )
{
	wait 3.5;
	if ( IsAlive( player ) )
	{
		player thread zm_audio::create_and_play_dialog( "quest", "find_secret" );
	}
	else
	{
		foreach(player in GetPlayers()) {
			if ( IsAlive( player ) )
			{
				if ( isdefined( player.dontspeak ) && !player.dontspeak )
				{
					player thread zm_audio::create_and_play_dialog( "quest", "find_secret" );
				}
			}
		}
	}
}

function player_portal_clue_vo()
{
	self endon( "death" );
	self endon( "disconnect" );
	level flag::wait_till( "afterlife_start_over" );
	wait 1;
	while ( 1 )
	{
		self waittill( "player_fake_corpse_created" );
		self.e_afterlife_corpse waittill( "player_revived", e_reviver );
		if ( self == e_reviver && !level.someone_has_visited_nml )
		{
			wait 3;
			self zm_utility::do_player_general_vox( "general", "portal_clue", undefined, 100 );
			return;
		}
		wait 0.1;
	}
}
/*
function setup_personality_character_exerts()
{
	level.exert_sounds[ 1 ][ "burp" ][ 0 ] = "vox_plr_0_exert_burp_0";
	level.exert_sounds[ 1 ][ "burp" ][ 1 ] = "vox_plr_0_exert_burp_1";
	level.exert_sounds[ 1 ][ "burp" ][ 2 ] = "vox_plr_0_exert_burp_2";
	level.exert_sounds[ 1 ][ "burp" ][ 3 ] = "vox_plr_0_exert_burp_3";
	level.exert_sounds[ 1 ][ "burp" ][ 4 ] = "vox_plr_0_exert_burp_4";
	level.exert_sounds[ 1 ][ "burp" ][ 5 ] = "vox_plr_0_exert_burp_5";
	level.exert_sounds[ 1 ][ "burp" ][ 6 ] = "vox_plr_0_exert_burp_6";
	level.exert_sounds[ 2 ][ "burp" ][ 0 ] = "vox_plr_1_exert_burp_0";
	level.exert_sounds[ 2 ][ "burp" ][ 1 ] = "vox_plr_1_exert_burp_1";
	level.exert_sounds[ 2 ][ "burp" ][ 2 ] = "vox_plr_1_exert_burp_2";
	level.exert_sounds[ 2 ][ "burp" ][ 3 ] = "vox_plr_1_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 0 ] = "vox_plr_2_exert_burp_0";
	level.exert_sounds[ 3 ][ "burp" ][ 1 ] = "vox_plr_2_exert_burp_1";
	level.exert_sounds[ 3 ][ "burp" ][ 2 ] = "vox_plr_2_exert_burp_2";
	level.exert_sounds[ 3 ][ "burp" ][ 3 ] = "vox_plr_2_exert_burp_3";
	level.exert_sounds[ 3 ][ "burp" ][ 4 ] = "vox_plr_2_exert_burp_4";
	level.exert_sounds[ 3 ][ "burp" ][ 5 ] = "vox_plr_2_exert_burp_5";
	level.exert_sounds[ 3 ][ "burp" ][ 6 ] = "vox_plr_2_exert_burp_6";
	level.exert_sounds[ 4 ][ "burp" ][ 0 ] = "vox_plr_3_exert_burp_0";
	level.exert_sounds[ 4 ][ "burp" ][ 1 ] = "vox_plr_3_exert_burp_1";
	level.exert_sounds[ 4 ][ "burp" ][ 2 ] = "vox_plr_3_exert_burp_2";
	level.exert_sounds[ 4 ][ "burp" ][ 3 ] = "vox_plr_3_exert_burp_3";
	level.exert_sounds[ 4 ][ "burp" ][ 4 ] = "vox_plr_3_exert_burp_4";
	level.exert_sounds[ 4 ][ "burp" ][ 5 ] = "vox_plr_3_exert_burp_5";
	level.exert_sounds[ 4 ][ "burp" ][ 6 ] = "vox_plr_3_exert_burp_6";
	level.exert_sounds[ 1 ][ "hitmed" ][ 0 ] = "vox_plr_0_exert_pain_medium_0";
	level.exert_sounds[ 1 ][ "hitmed" ][ 1 ] = "vox_plr_0_exert_pain_medium_1";
	level.exert_sounds[ 1 ][ "hitmed" ][ 2 ] = "vox_plr_0_exert_pain_medium_2";
	level.exert_sounds[ 1 ][ "hitmed" ][ 3 ] = "vox_plr_0_exert_pain_medium_3";
	level.exert_sounds[ 2 ][ "hitmed" ][ 0 ] = "vox_plr_1_exert_pain_medium_0";
	level.exert_sounds[ 2 ][ "hitmed" ][ 1 ] = "vox_plr_1_exert_pain_medium_1";
	level.exert_sounds[ 2 ][ "hitmed" ][ 2 ] = "vox_plr_1_exert_pain_medium_2";
	level.exert_sounds[ 2 ][ "hitmed" ][ 3 ] = "vox_plr_1_exert_pain_medium_3";
	level.exert_sounds[ 3 ][ "hitmed" ][ 0 ] = "vox_plr_2_exert_pain_medium_0";
	level.exert_sounds[ 3 ][ "hitmed" ][ 1 ] = "vox_plr_2_exert_pain_medium_1";
	level.exert_sounds[ 3 ][ "hitmed" ][ 2 ] = "vox_plr_2_exert_pain_medium_2";
	level.exert_sounds[ 3 ][ "hitmed" ][ 3 ] = "vox_plr_2_exert_pain_medium_3";
	level.exert_sounds[ 4 ][ "hitmed" ][ 0 ] = "vox_plr_3_exert_pain_medium_0";
	level.exert_sounds[ 4 ][ "hitmed" ][ 1 ] = "vox_plr_3_exert_pain_medium_1";
	level.exert_sounds[ 4 ][ "hitmed" ][ 2 ] = "vox_plr_3_exert_pain_medium_2";
	level.exert_sounds[ 4 ][ "hitmed" ][ 3 ] = "vox_plr_3_exert_pain_medium_3";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 0 ] = "vox_plr_0_exert_pain_high_0";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 1 ] = "vox_plr_0_exert_pain_high_1";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 2 ] = "vox_plr_0_exert_pain_high_2";
	level.exert_sounds[ 1 ][ "hitlrg" ][ 3 ] = "vox_plr_0_exert_pain_high_3";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 0 ] = "vox_plr_1_exert_pain_high_0";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 1 ] = "vox_plr_1_exert_pain_high_1";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 2 ] = "vox_plr_1_exert_pain_high_2";
	level.exert_sounds[ 2 ][ "hitlrg" ][ 3 ] = "vox_plr_1_exert_pain_high_3";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 0 ] = "vox_plr_2_exert_pain_high_0";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 1 ] = "vox_plr_2_exert_pain_high_1";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 2 ] = "vox_plr_2_exert_pain_high_2";
	level.exert_sounds[ 3 ][ "hitlrg" ][ 3 ] = "vox_plr_2_exert_pain_high_3";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 0 ] = "vox_plr_3_exert_pain_high_0";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 1 ] = "vox_plr_3_exert_pain_high_1";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 2 ] = "vox_plr_3_exert_pain_high_2";
	level.exert_sounds[ 4 ][ "hitlrg" ][ 3 ] = "vox_plr_3_exert_pain_high_3";
}*/

function alcatraz_audio_custom_response_line( player, index, category, type )
{
	if ( type == "revive_up" )
	{
		player thread play_vo_category_on_closest_player( "general", "revive_player" );
	}
	else if ( type == "headshot" )
	{
		if ( math::cointoss() )
		{
			player thread play_vo_category_on_closest_player( "kill", "headshot_respond_to_plr_" + player.characterindex );
		}
		else
		{
			player thread play_vo_category_on_closest_player( "kill", "headshot_respond_generic" );
		}
	}
	else
	{
		if ( type == "oh_shit" )
		{
			player thread play_vo_category_on_closest_player( "general", "surrounded_respond_to_plr_" + player.characterindex );
			player thread global_oh_shit_cooldown_timer( 15 );
		}
	}
}

function play_vo_category_on_closest_player( category, type )
{
	a_players = GetPlayers();
	if ( a_players.size <= 1 )
	{
		return;
	}
	ArrayRemoveValue( a_players, self );
	a_closest = ArraySort( a_players, self.origin, 1 );
	if ( DistanceSquared( self.origin, a_closest[ 0 ].origin ) <= 250000 )
	{
		if ( IsAlive( a_closest[ 0 ] ) )
		{
			a_closest[ 0 ] zm_audio::create_and_play_dialog( category, type );
		}
	}
}

function check_for_special_weapon_limit_exist( weapon )
{
	if ( weapon.name != "bo2_blundergat" && weapon.name != "minigun_alcatraz" )
	{
		return 1;
	}
	players = GetPlayers();
	count = 0;
	if ( weapon.name == "bo2_blundergat" )
	{
		if ( self zm_weapons::has_weapon_or_upgrade( "bo2_acidgat" ) )
		{
			return 0;
		}
		if ( self afterlife_weapon_limit_check( "bo2_blundergat" ) )
		{
			return 0;
		}
		limit = level.limited_weapons[ "bo2_blundergat" ];
	}
	else
	{
		if ( self afterlife_weapon_limit_check( "minigun_alcatraz" ) )
		{
			return 0;
		}
		limit = level.limited_weapons[ "minigun_alcatraz" ];
	}
	i = 0;
	while ( i < players.size )
	{
		if ( weapon.name == "bo2_blundergat" )
		{
			if ( players[ i ] zm_weapons::has_weapon_or_upgrade( "bo2_acidgat" ) || isdefined( players[ i ].is_pack_splatting ) && players[ i ].is_pack_splatting )
			{
				count++;
				i++;
				continue;
			}
		}
		else
		{
			if ( players[ i ] afterlife_weapon_limit_check( weapon.name ) )
			{
				count++;
			}
		}
		i++;
	}
	if ( count >= limit )
	{
		return 0;
	}
	return 1;
}

function afterlife_weapon_limit_check( limited_weapon )
{
	if ( isdefined( self.afterlife ) && self.afterlife )
	{
		if ( limited_weapon == "bo2_blundergat" )
		{
			_a1577 = self.loadout;
			_k1577 = GetFirstArrayKey( _a1577 );
			while ( isdefined( _k1577 ) )
			{
				weapon = _a1577[ _k1577 ];
				if ( weapon.name != "bo2_blundergat" && weapon.name != "bo2_blundergat_upgraded" || weapon.name == "bo2_acidgat" && weapon.name == "bo2_acidgat_upgraded" )
				{
					return 1;
				}
				_k1577 = GetNextArrayKey( _a1577, _k1577 );
			}
		}
		else if ( limited_weapon == "minigun_alcatraz" )
		{
			_a1587 = self.loadout;
			_k1587 = GetFirstArrayKey( _a1587 );
			while ( isdefined( _k1587 ) )
			{
				weapon = _a1587[ _k1587 ];
				if ( weapon.name == "minigun_alcatraz" || weapon.name == "minigun_alcatraz_upgraded" )
				{
					return 1;
				}
				_k1587 = GetNextArrayKey( _a1587, _k1587 );
			}
		}
	}
	return 0;
}

function door_rumble_on_buy()
{
	//self clientfield::set_to_player( "rumble_door_open", 1 );
	util::wait_network_frame();
	//self clientfield::set_to_player( "rumble_door_open", 0 );
}

function is_player_in_zone( zone_name )
{
	zone = level.zones[ zone_name ];
	i = 0;
	while ( i < zone.volumes.size )
	{
		if ( self IsTouching( level.zones[ zone_name ].volumes[ i ] ) && self.sessionstate != "spectator" )
		{
			return 1;
		}
		i++;
	}
	return 0;
}
