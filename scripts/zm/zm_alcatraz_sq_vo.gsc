#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;


function vo_see_map_trigger()
{
	level endon( "someone_completed_quest_cycle" );
	e_triggerer = undefined;
	radius = GetDvarInt( "revive_trigger_radius" );
	t_map_vo_trigger = Spawn( "trigger_radius", ( 1097, 167, 5613 ), 0, radius, radius );
	t_map_vo_trigger SetHintString( "" );
	t_map_vo_trigger SetCursorHint( "HINT_NOICON" );
	//t_map_vo_trigger = GetEnt( "map_vo_trigger", "targetname" );
	b_has_line_played = 0;
	while ( !b_has_line_played )
	{
		t_map_vo_trigger waittill( "trigger", e_triggerer );
		players = GetPlayers();
		if ( !e_triggerer.dontspeak && !level flag::get( "story_vo_playing" ) )
		{
			level flag::set( "story_vo_playing" );
			e_triggerer zm_utility::do_player_general_vox( "quest", "find_map", undefined, 100 );
			wait 5;
			ArrayRemoveValue( players, e_triggerer );
			closest_other_player = array::get_closest( e_triggerer.origin, players );
			if ( isdefined( closest_other_player ) )
			{
				closest_other_player zm_utility::do_player_general_vox( "quest", "response_map", undefined, 100 );
			}
			b_has_line_played = 1;
			wait 5;
			level flag::clear( "story_vo_playing" );
		}
		wait 0.05;
	}
}

function opening_vo()
{
	level flag::init( "story_vo_playing" );
	load_vo_alias_arrays();
	level flag::wait_till( "afterlife_start_over" );
	wait 1;
	players = GetPlayers();
	vo_play_four_part_conversation( level.four_part_convos[ "start_1_oh_shit_" + randomintrange( 1, 3 ) ] );
	wait 1;
	if ( players.size == 1 )
	{
		players[ 0 ] vo_play_soliloquy( level.soliloquy_convos[ "solo_intro_" + players[ 0 ].character_name ] );
	}
	else
	{
		if ( is_player_character_present( "Arlington" ) )
		{
			vo_play_four_part_conversation( level.four_part_convos[ "intro_plr_3" ] );
		}
	}
	level thread vo_see_map_trigger();
	wait 10;
	vo_play_four_part_conversation( level.four_part_convos[ "during_1_oh_shit" ] );
	level waittill( "end_of_round" );
	wait 5;
	vo_play_four_part_conversation( level.four_part_convos[ "start_2_oh_shit_" + randomintrange( 1, 3 ) ] );
	wait 4;
	vo_play_four_part_conversation( level.four_part_convos[ "start_3_oh_shit" ] );
	level waittill( "end_of_round" );
	wait 3;
	if ( ( get_players_touching( "library_zone" ) + get_players_touching( "spawn_zone" ) ) == 4 )
	{
		vo_play_four_part_conversation( level.four_part_convos[ "start_2_oh_shit" ] );
	}
	wait 1;
}

function load_vo_alias_arrays()
{
	level.four_part_convos = [];
	level.four_part_convos[ "intro_plr_1" ] = [];
	level.four_part_convos[ "intro_plr_1" ][ 0 ] = "vox_plr_1_start_1_oh_shit1_0";
	level.four_part_convos[ "intro_plr_3" ] = [];
	level.four_part_convos[ "intro_plr_3" ][ 0 ] = "vox_plr_3_chair2_var6_0";
	level.four_part_convos[ "intro_plr_3" ][ 1 ] = "vox_plr_3_chair2_var7_0";
	level.four_part_convos[ "intro_plr_3" ][ 2 ] = "vox_plr_3_chair2_var8_0";
	level.four_part_convos[ "start_1_oh_shit_1" ] = [];
	level.four_part_convos[ "start_1_oh_shit_1" ][ 0 ] = "vox_plr_1_start_1_oh_shit4_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 1 ] = "vox_plr_2_start_1_oh_shit5_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 2 ] = "vox_plr_0_start_1_oh_shit6_0";
	level.four_part_convos[ "start_1_oh_shit_1" ][ 3 ] = "vox_plr_3_start_1_oh_shit7_0";
	level.four_part_convos[ "start_1_oh_shit_2" ] = [];
	level.four_part_convos[ "start_1_oh_shit_2" ][ 0 ] = "vox_plr_3_start_1_oh_shit8_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 1 ] = "vox_plr_2_start_1_oh_shit9_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 2 ] = "vox_plr_1_start_1_oh_shit10_0";
	level.four_part_convos[ "start_1_oh_shit_2" ][ 3 ] = "vox_plr_0_start_1_oh_shit11_0";
	level.four_part_convos[ "during_1_oh_shit" ] = [];
	level.four_part_convos[ "during_1_oh_shit" ][ 0 ] = "vox_plr_0_during_1_oh_shit5_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 1 ] = "vox_plr_3_during_1_oh_shit6_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 2 ] = "vox_plr_1_during_1_oh_shit7_0";
	level.four_part_convos[ "during_1_oh_shit" ][ 3 ] = "vox_plr_2_during_1_oh_shit8_0";
	level.four_part_convos[ "start_2_oh_shit_1" ] = [];
	level.four_part_convos[ "start_2_oh_shit_1" ][ 0 ] = "vox_plr_3_start_2_oh_shit12_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 1 ] = "vox_plr_0_start_2_oh_shit13_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 2 ] = "vox_plr_2_start_2_oh_shit14_0";
	level.four_part_convos[ "start_2_oh_shit_1" ][ 3 ] = "vox_plr_1_start_2_oh_shit15_0";
	level.four_part_convos[ "start_2_oh_shit_2" ] = [];
	level.four_part_convos[ "start_2_oh_shit_2" ][ 0 ] = "vox_plr_0_start_2_oh_shit16_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 1 ] = "vox_plr_2_start_2_oh_shit17_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 2 ] = "vox_plr_3_start_2_oh_shit18_0";
	level.four_part_convos[ "start_2_oh_shit_2" ][ 3 ] = "vox_plr_1_start_2_oh_shit19_0";
	level.four_part_convos[ "start_3_oh_shit" ] = [];
	level.four_part_convos[ "start_3_oh_shit" ][ 0 ] = "vox_plr_3_start_3_oh_shit13_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 1 ] = "vox_plr_2_start_3_oh_shit14_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 2 ] = "vox_plr_1_start_3_oh_shit15_0";
	level.four_part_convos[ "start_3_oh_shit" ][ 3 ] = "vox_plr_0_start_3_oh_shit16_0";
	level.four_part_convos[ "start_2_oh_shit" ] = [];
	level.four_part_convos[ "start_2_oh_shit" ][ 0 ] = "vox_plr_1_start_2_oh_shit9_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 1 ] = "vox_plr_0_start_2_oh_shit10_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 2 ] = "vox_plr_1_start_2_oh_shit11_0";
	level.four_part_convos[ "start_2_oh_shit" ][ 3 ] = "vox_plr_2_start_2_oh_shit12_0";
	level.four_part_convos[ "chair1" ] = [];
	level.four_part_convos[ "chair1" ][ 0 ] = "vox_plr_1_chair1_var1_0";
	level.four_part_convos[ "chair1" ][ 1 ] = "vox_plr_2_chair1_var2_0";
	level.four_part_convos[ "chair1" ][ 2 ] = "vox_plr_3_chair1_var3_0";
	level.four_part_convos[ "chair1" ][ 3 ] = "vox_plr_1_chair1_var4_0";
	level.four_part_convos[ "chair1" ][ 4 ] = "vox_plr_3_chair1_var5_0";
	level.four_part_convos[ "chair2" ] = [];
	level.four_part_convos[ "chair2" ][ 0 ] = "vox_plr_2_chair2_var1_0";
	level.four_part_convos[ "chair2" ][ 1 ] = "vox_plr_3_chair2_var2_0";
	level.four_part_convos[ "chair2" ][ 1 ] = "vox_plr_0_chair2_var3_0";
	level.four_part_convos[ "chair2" ][ 2 ] = "vox_plr_3_chair2_var5_0";
	level.four_part_convos[ "chair2" ][ 3 ] = "vox_plr_1_chair2_var4_0";
	level.four_part_convos[ "chair_combat_1" ] = [];
	level.four_part_convos[ "chair_combat_1" ][ 0 ] = "vox_plr_3_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 1 ] = "vox_plr_1_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 2 ] = "vox_plr_2_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_1" ][ 3 ] = "vox_plr_0_chair3_var_3_0";
	level.four_part_convos[ "chair_combat_2" ] = [];
	level.four_part_convos[ "chair_combat_2" ][ 0 ] = "vox_plr_0_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 1 ] = "vox_plr_3_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 2 ] = "vox_plr_2_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 3 ] = "vox_plr_1_chair4_var_4_0";
	level.four_part_convos[ "chair_combat_2" ][ 4 ] = "vox_plr_3_chair4_var_4_1";
	level.four_part_convos[ "bridge_visit1_alt1" ] = [];
	level.four_part_convos[ "bridge_visit1_alt1" ][ 0 ] = "vox_plr_3_bridge_var1_1_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 1 ] = "vox_plr_2_bridge_var1_2_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 2 ] = "vox_plr_0_bridge_var1_3_0";
	level.four_part_convos[ "bridge_visit1_alt1" ][ 3 ] = "vox_plr_1_bridge_var1_4_0";
	level.four_part_convos[ "bridge_visit1_alt2" ] = [];
	level.four_part_convos[ "bridge_visit1_alt2" ][ 0 ] = "vox_plr_1_bridge_var2_1_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 1 ] = "vox_plr_0_bridge_var2_2_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 2 ] = "vox_plr_1_bridge_var2_3_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 3 ] = "vox_plr_2_bridge_var2_4_0";
	level.four_part_convos[ "bridge_visit1_alt2" ][ 4 ] = "vox_plr_3_bridge_var2_5_0";
	level.four_part_convos[ "bridge_visit1_alt3" ] = [];
	level.four_part_convos[ "bridge_visit1_alt3" ][ 0 ] = "vox_plr_0_bridge_var2_6_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 1 ] = "vox_plr_2_bridge_var2_7_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 2 ] = "vox_plr_3_bridge_var2_8_0";
	level.four_part_convos[ "bridge_visit1_alt3" ][ 3 ] = "vox_plr_1_bridge_var2_9_0";
	level.four_part_convos[ "bridge_visit1_alt4" ] = [];
	level.four_part_convos[ "bridge_visit1_alt4" ][ 0 ] = "vox_plr_1_bridge_var2_10_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 1 ] = "vox_plr_2_bridge_var2_11_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 2 ] = "vox_plr_0_bridge_var2_12_0";
	level.four_part_convos[ "bridge_visit1_alt4" ][ 3 ] = "vox_plr_3_bridge_var2_13_0";
	level.four_part_convos[ "bridge_visit2_alt1" ] = [];
	level.four_part_convos[ "bridge_visit2_alt1" ][ 0 ] = "vox_plr_0_bridge_var5_1_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 1 ] = "vox_plr_3_bridge_var5_2_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 2 ] = "vox_plr_0_bridge_var5_3_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 3 ] = "vox_plr_3_bridge_var6_1_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 4 ] = "vox_plr_2_bridge_var5_5_0";
	level.four_part_convos[ "bridge_visit2_alt1" ][ 5 ] = "vox_plr_3_bridge_var5_4_0";
	level.four_part_convos[ "bridge_visit2_alt2" ] = [];
	level.four_part_convos[ "bridge_visit2_alt2" ][ 0 ] = "vox_plr_3_bridge_var6_3_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 1 ] = "vox_plr_1_bridge_var6_4_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 2 ] = "vox_plr_3_bridge_var6_5_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 3 ] = "vox_plr_2_bridge_var6_2_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 4 ] = "vox_plr_3_bridge_var6_6_0";
	level.four_part_convos[ "bridge_visit2_alt2" ][ 5 ] = "vox_plr_0_bridge_var6_7_0";
	level.four_part_convos[ "bridge_visit2_alt3" ] = [];
	level.four_part_convos[ "bridge_visit2_alt3" ][ 0 ] = "vox_plr_3_bridge_var6_8_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 1 ] = "vox_plr_2_bridge_var6_9_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 2 ] = "vox_plr_3_bridge_var6_10_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 3 ] = "vox_plr_2_bridge_var6_11_0";
	level.four_part_convos[ "bridge_visit2_alt3" ][ 3 ] = "vox_plr_3_bridge_var6_12_0";
	level.four_part_convos[ "bridge_visit2_alt4" ] = [];
	level.four_part_convos[ "bridge_visit2_alt4" ][ 0 ] = "vox_plr_0_bridge_var6_13_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 1 ] = "vox_plr_2_bridge_var6_14_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 2 ] = "vox_plr_1_bridge_var6_15_0";
	level.four_part_convos[ "bridge_visit2_alt4" ][ 3 ] = "vox_plr_3_bridge_var6_16_0";
	level.four_part_convos[ "alcatraz_return_alt1" ] = [];
	level.four_part_convos[ "alcatraz_return_alt1" ][ 0 ] = "vox_plr_0_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 1 ] = "vox_plr_3_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 2 ] = "vox_plr_2_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt1" ][ 3 ] = "vox_plr_1_start_2_4_player_0";
	level.four_part_convos[ "alcatraz_return_alt2" ] = [];
	level.four_part_convos[ "alcatraz_return_alt2" ][ 0 ] = "vox_plr_2_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 1 ] = "vox_plr_3_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 2 ] = "vox_plr_0_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_alt2" ][ 3 ] = "vox_plr_1_start_2_4_player_1";
	level.four_part_convos[ "alcatraz_return_quest_reset" ] = [];
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 0 ] = "vox_plr_3_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 1 ] = "vox_plr_1_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 2 ] = "vox_plr_2_start_2_2_3_players_0";
	level.four_part_convos[ "alcatraz_return_quest_reset" ][ 3 ] = "vox_plr_0_start_2_2_3_players_0";
	level.soliloquy_convos[ "solo_intro_Billy" ] = [];
	level.soliloquy_convos[ "solo_intro_Billy" ][ 0 ] = "vox_plr_2_start_1_billy_0";
	level.soliloquy_convos[ "solo_intro_Billy" ][ 1 ] = "vox_plr_2_start_1_billy_1";
	level.soliloquy_convos[ "solo_intro_Billy" ][ 2 ] = "vox_plr_2_start_1_billy_2";
	level.soliloquy_convos[ "solo_intro_Sal" ] = [];
	level.soliloquy_convos[ "solo_intro_Sal" ][ 0 ] = "vox_plr_1_start_1_sal_0";
	level.soliloquy_convos[ "solo_intro_Sal" ][ 1 ] = "vox_plr_1_start_1_sal_1";
	level.soliloquy_convos[ "solo_intro_Sal" ][ 2 ] = "vox_plr_1_start_1_sal_2";
	level.soliloquy_convos[ "solo_intro_Finn" ] = [];
	level.soliloquy_convos[ "solo_intro_Finn" ][ 0 ] = "vox_plr_0_start_1_finn_0";
	level.soliloquy_convos[ "solo_intro_Finn" ][ 1 ] = "vox_plr_0_start_1_finn_1";
	level.soliloquy_convos[ "solo_intro_Finn" ][ 2 ] = "vox_plr_0_start_1_finn_2";
	level.soliloquy_convos[ "solo_intro_Arlington" ] = [];
	level.soliloquy_convos[ "solo_intro_Arlington" ][ 0 ] = "vox_plr_3_start_1_arlington_0";
	level.soliloquy_convos[ "solo_intro_Arlington" ][ 1 ] = "vox_plr_3_start_1_arlington_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 0 ] = "vox_plr_1_purgatory_sal_var1_0";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 1 ] = "vox_plr_1_purgatory_sal_var1_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 2 ] = "vox_plr_1_purgatory_sal_var1_2";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 3 ] = "vox_plr_1_purgatory_sal_var1_3";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt1" ][ 4 ] = "vox_plr_1_purgatory_sal_var1_4";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 0 ] = "vox_plr_1_purgatory_sal_var2_0";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 1 ] = "vox_plr_1_purgatory_sal_var2_1";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 2 ] = "vox_plr_1_purgatory_sal_var2_2";
	level.soliloquy_convos[ "purgatory_Sal_visit1_alt2" ][ 3 ] = "vox_plr_1_purgatory_sal_var2_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 0 ] = "vox_plr_1_purgatory_sal_var3_0";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 1 ] = "vox_plr_1_purgatory_sal_var3_1";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 2 ] = "vox_plr_1_purgatory_sal_var3_2";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 3 ] = "vox_plr_1_purgatory_sal_var3_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt1" ][ 4 ] = "vox_plr_1_purgatory_sal_var3_4";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 0 ] = "vox_plr_1_purgatory_sal_var4_0";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 1 ] = "vox_plr_1_purgatory_sal_var4_1";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 2 ] = "vox_plr_1_purgatory_sal_var4_3";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 3 ] = "vox_plr_1_purgatory_sal_var4_4";
	level.soliloquy_convos[ "purgatory_Sal_visit2_alt2" ][ 4 ] = "vox_plr_1_purgatory_sal_var4_5";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 0 ] = "vox_plr_2_purgatory_billy_var1_0";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 1 ] = "vox_plr_2_purgatory_billy_var1_1";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt1" ][ 2 ] = "vox_plr_2_purgatory_billy_var1_2";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 0 ] = "vox_plr_2_purgatory_billy_var2_0";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 1 ] = "vox_plr_2_purgatory_billy_var2_1";
	level.soliloquy_convos[ "purgatory_Billy_visit1_alt2" ][ 2 ] = "vox_plr_2_purgatory_billy_var2_2";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 0 ] = "vox_plr_2_purgatory_billy_var3_0";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 1 ] = "vox_plr_2_purgatory_billy_var3_1";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 2 ] = "vox_plr_2_purgatory_billy_var3_2";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt1" ][ 3 ] = "vox_plr_2_purgatory_billy_var3_3";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 0 ] = "vox_plr_2_purgatory_billy_var4_0";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 1 ] = "vox_plr_2_purgatory_billy_var4_1";
	level.soliloquy_convos[ "purgatory_Billy_visit2_alt2" ][ 2 ] = "vox_plr_2_purgatory_billy_var4_2";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 0 ] = "vox_plr_0_purgatory_finn_var1_0";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 1 ] = "vox_plr_0_purgatory_finn_var1_1";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 2 ] = "vox_plr_0_purgatory_finn_var1_2";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt1" ][ 3 ] = "vox_plr_0_purgatory_finn_var1_3";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 0 ] = "vox_plr_0_purgatory_finn_var2_0";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 1 ] = "vox_plr_0_purgatory_finn_var2_1";
	level.soliloquy_convos[ "purgatory_Finn_visit1_alt2" ][ 2 ] = "vox_plr_0_purgatory_finn_var2_2";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 0 ] = "vox_plr_0_purgatory_finn_var3_0";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 1 ] = "vox_plr_0_purgatory_finn_var3_1";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt1" ][ 2 ] = "vox_plr_0_purgatory_finn_var3_2";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 0 ] = "vox_plr_0_purgatory_finn_var4_0";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 1 ] = "vox_plr_0_purgatory_finn_var4_1";
	level.soliloquy_convos[ "purgatory_Finn_visit2_alt2" ][ 2 ] = "vox_plr_0_purgatory_finn_var4_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 0 ] = "vox_plr_3_purgatory_arlington_var1_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 1 ] = "vox_plr_3_purgatory_arlington_var1_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt1" ][ 2 ] = "vox_plr_3_purgatory_arlington_var1_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 0 ] = "vox_plr_3_purgatory_arlington_var2_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 1 ] = "vox_plr_3_purgatory_arlington_var2_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit1_alt2" ][ 2 ] = "vox_plr_3_purgatory_arlington_var2_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 0 ] = "vox_plr_3_purgatory_arlington_var3_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 1 ] = "vox_plr_3_purgatory_arlington_var3_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt1" ][ 2 ] = "vox_plr_3_purgatory_arlington_var3_2";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ] = [];
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 0 ] = "vox_plr_3_purgatory_arlington_var4_0";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 1 ] = "vox_plr_3_purgatory_arlington_var4_1";
	level.soliloquy_convos[ "purgatory_Arlington_visit2_alt2" ][ 2 ] = "vox_plr_3_purgatory_arlington_var4_2";
	level.soliloquy_convos[ "electric_chair_Finn" ] = [];
	level.soliloquy_convos[ "electric_chair_Finn" ][ 0 ] = "vox_plr_0_chair4_var_4_0";
	level.soliloquy_convos[ "electric_chair_Sal" ] = [];
	level.soliloquy_convos[ "electric_chair_Sal" ][ 0 ] = "vox_plr_1_chair1_var1_0";
	level.soliloquy_convos[ "electric_chair_Billy" ] = [];
	level.soliloquy_convos[ "electric_chair_Billy" ][ 0 ] = "vox_plr_2_chair1_var2_0";
	level.soliloquy_convos[ "electric_chair_Arlington" ] = [];
	level.soliloquy_convos[ "electric_chair_Arlington" ][ 0 ] = "vox_plr_3_chair3_var_3_0";
	level.soliloquy_convos[ "shield_pickup_Sal_alt1" ][ 0 ] = "vox_plr_1_build_zs_pickup_0";
	level.soliloquy_convos[ "shield_pickup_Sal_alt2" ][ 0 ] = "vox_plr_1_build_zs_pickup_1";
	level.soliloquy_convos[ "shield_pickup_Sal_alt3" ][ 0 ] = "vox_plr_1_build_zs_pickup_2";
	level.soliloquy_convos[ "shield_pickup_Billy_alt1" ][ 0 ] = "vox_plr_2_build_zs_pickup_0";
	level.soliloquy_convos[ "shield_pickup_Billy_alt2" ][ 0 ] = "vox_plr_2_build_zs_pickup_1";
	level.soliloquy_convos[ "shield_pickup_Billy_alt3" ][ 0 ] = "vox_plr_2_build_zs_pickup_2";
	level.soliloquy_convos[ "shield_pickup_Finn_alt1" ][ 0 ] = "vox_plr_0_build_zs_pickup_0";
	level.soliloquy_convos[ "shield_pickup_Finn_alt2" ][ 0 ] = "vox_plr_0_build_zs_pickup_1";
	level.soliloquy_convos[ "shield_pickup_Finn_alt3" ][ 0 ] = "vox_plr_0_build_zs_pickup_2";
	level.soliloquy_convos[ "shield_pickup_Arlington_alt1" ][ 0 ] = "vox_plr_3_build_zs_pickup_0";
	level.soliloquy_convos[ "shield_pickup_Arlington_alt2" ][ 0 ] = "vox_plr_3_build_zs_pickup_1";
	level.soliloquy_convos[ "shield_pickup_Arlington_alt3" ][ 0 ] = "vox_plr_3_build_zs_pickup_2";
	level.soliloquy_convos[ "shield_final_Sal_alt1" ][ 0 ] = "vox_plr_1_build_zs_final_0";
	level.soliloquy_convos[ "shield_final_Sal_alt2" ][ 0 ] = "vox_plr_1_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Sal_alt3" ][ 0 ] = "vox_plr_1_build_zs_final_2";
	level.soliloquy_convos[ "shield_final_Billy_alt1" ][ 0 ] = "vox_plr_2_build_zs_final_0";
	level.soliloquy_convos[ "shield_final_Billy_alt2" ][ 0 ] = "vox_plr_2_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Billy_alt3" ][ 0 ] = "vox_plr_2_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Finn_alt1" ][ 0 ] = "vox_plr_0_build_zs_final_0";
	level.soliloquy_convos[ "shield_final_Finn_alt2" ][ 0 ] = "vox_plr_0_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Finn_alt3" ][ 0 ] = "vox_plr_0_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Arlington_alt1" ][ 0 ] = "vox_plr_3_build_zs_final_0";
	level.soliloquy_convos[ "shield_final_Arlington_alt2" ][ 0 ] = "vox_plr_3_build_zs_final_1";
	level.soliloquy_convos[ "shield_final_Arlington_alt3" ][ 0 ] = "vox_plr_3_build_zs_final_2";
	level.soliloquy_convos[ "gat_pickup_Sal_alt1" ][ 0 ] = "vox_plr_1_build_bsm_pickup_0";
	level.soliloquy_convos[ "gat_pickup_Sal_alt2" ][ 0 ] = "vox_plr_1_build_bsm_pickup_1";
	level.soliloquy_convos[ "gat_pickup_Sal_alt3" ][ 0 ] = "vox_plr_1_build_bsm_pickup_2";
	level.soliloquy_convos[ "gat_pickup_Billy_alt1" ][ 0 ] = "vox_plr_2_build_bsm_pickup_0";
	level.soliloquy_convos[ "gat_pickup_Billy_alt2" ][ 0 ] = "vox_plr_2_build_bsm_pickup_1";
	level.soliloquy_convos[ "gat_pickup_Billy_alt3" ][ 0 ] = "vox_plr_2_build_bsm_pickup_2";
	level.soliloquy_convos[ "gat_pickup_Finn_alt1" ][ 0 ] = "vox_plr_0_build_bsm_pickup_0";
	level.soliloquy_convos[ "gat_pickup_Finn_alt2" ][ 0 ] = "vox_plr_0_build_bsm_pickup_1";
	level.soliloquy_convos[ "gat_pickup_Finn_alt3" ][ 0 ] = "vox_plr_0_build_bsm_pickup_2";
	level.soliloquy_convos[ "gat_pickup_Arlington_alt1" ][ 0 ] = "vox_plr_3_build_bsm_pickup_0";
	level.soliloquy_convos[ "gat_pickup_Arlington_alt2" ][ 0 ] = "vox_plr_3_build_bsm_pickup_1";
	level.soliloquy_convos[ "gat_pickup_Arlington_alt3" ][ 0 ] = "vox_plr_3_build_bsm_pickup_2";
	level.soliloquy_convos[ "gat_final_Sal_alt1" ][ 0 ] = "vox_plr_1_build_bsm_final_0";
	level.soliloquy_convos[ "gat_final_Sal_alt2" ][ 0 ] = "vox_plr_1_build_bsm_final_1";
	level.soliloquy_convos[ "gat_final_Sal_alt3" ][ 0 ] = "vox_plr_1_build_bsm_final_2";
	level.soliloquy_convos[ "gat_final_Billy_alt1" ][ 0 ] = "vox_plr_2_build_bsm_final_0";
	level.soliloquy_convos[ "gat_final_Billy_alt2" ][ 0 ] = "vox_plr_2_build_bsm_final_1";
	level.soliloquy_convos[ "gat_final_Billy_alt3" ][ 0 ] = "vox_plr_2_build_bsm_final_2";
	level.soliloquy_convos[ "gat_final_Finn_alt1" ][ 0 ] = "vox_plr_0_build_bsm_final_0";
	level.soliloquy_convos[ "gat_final_Finn_alt2" ][ 0 ] = "vox_plr_0_build_bsm_final_1";
	level.soliloquy_convos[ "gat_final_Finn_alt3" ][ 0 ] = "vox_plr_0_build_bsm_final_2";
	level.soliloquy_convos[ "gat_final_Arlington_alt1" ][ 0 ] = "vox_plr_3_build_bsm_final_0";
	level.soliloquy_convos[ "gat_final_Arlington_alt2" ][ 0 ] = "vox_plr_3_build_bsm_final_1";
	level.soliloquy_convos[ "gat_final_Arlington_alt3" ][ 0 ] = "vox_plr_3_build_bsm_final_2";
}

function vo_bridge_soliloquy()
{
	if ( level.n_quest_iteration_count < 3 )
	{
		convo = level.soliloquy_convos[ "purgatory_" + self.character_name + "_visit" + level.n_quest_iteration_count + "_alt" + RandomIntRange( 1, 3 ) ];
		if ( isdefined( convo ) )
		{
			self vo_play_soliloquy( convo );
		}
	}
}

function vo_bridge_four_part_convo()
{
	if ( level.n_quest_iteration_count < 3 )
	{
		convo = level.four_part_convos[ "bridge_visit" + level.n_quest_iteration_count + "_alt" + RandomIntRange( 1, 5 ) ];
		if ( isdefined( convo ) )
		{
			vo_play_four_part_conversation( convo );
		}
	}
}

function vo_pickup_shield_piece( num )
{
	convo = level.soliloquy_convos[ "shield_pickup_" + self.character_name + "_alt" + num ];
	if ( isdefined( convo ) )
	{
		self vo_play_soliloquy( convo );
	}
}

function vo_finalize_shield( num )
{
	convo = level.soliloquy_convos[ "shield_final_" + self.character_name + "_alt" + num ];
	if ( isdefined( convo ) )
	{
		self vo_play_soliloquy( convo );
	}
}

function vo_pickup_gat_piece( num )
{
	convo = level.soliloquy_convos[ "gat_pickup_" + self.character_name + "_alt" + num ];
	if ( isdefined( convo ) )
	{
		self vo_play_soliloquy( convo );
	}
}

function vo_finalize_gat( num )
{
	convo = level.soliloquy_convos[ "gat_final_" + self.character_name + "_alt" + num ];
	if ( isdefined( convo ) )
	{
		self vo_play_soliloquy( convo );
	}
}

function vo_play_soliloquy( convo )
{
	self endon( "disconnect" );
	if ( !isdefined( convo ) )
	{
		return;
	}
	if ( !level flag::get( "story_vo_playing" ) )
	{
		level flag::set( "story_vo_playing" );
		self thread vo_play_soliloquy_disconnect_listener();
		self.dontspeak = 1;
		//self clientfield::set_to_player( "isspeaking", 1 );
		i = 0;
		while ( i < convo.size )
		{
			if ( isdefined( self.afterlife ) && self.afterlife )
			{
				self.dontspeak = 0;
				//self clientfield::set_to_player( "isspeaking", 0 );
				level flag::clear( "story_vo_playing" );
				self notify( "soliloquy_vo_done" );
				return;
			}
			else
			{
				self PlaySoundWithNotify( convo[ i ], "sound_done" + convo[ i ] );
				self waittill( "sound_done" + convo[ i ] );
			}
			wait 1;
			i++;
		}
		self.dontspeak = 0;
		//self clientfield::set_to_player( "isspeaking", 0 );
		level flag::clear( "story_vo_playing" );
		self notify( "soliloquy_vo_done" );
	}
}

function vo_play_soliloquy_disconnect_listener()
{
	self endon( "soliloquy_vo_done" );
	self waittill( "disconnect" );
	level flag::clear( "story_vo_playing" );
}

function vo_play_four_part_conversation( convo )
{
	if ( !isdefined( convo ) )
	{
		return;
	}
	players = GetPlayers();
	if ( players.size == 4 && !level flag::get( "story_vo_playing" ) )
	{
		level flag::set( "story_vo_playing" );
		old_speaking_player = undefined;
		speaking_player = undefined;
		n_dist = 0;
		n_max_reply_dist = 1500;
		e_arlington = undefined;
		e_sal = undefined;
		e_billy = undefined;
		e_finn = undefined;
		_a513 = players;
		_k513 = GetFirstArrayKey( _a513 );
		while ( isdefined( _k513 ) )
		{
			player = _a513[ _k513 ];
			if ( isdefined( player ) )
			{
				switch( player.character_name )
				{
					case "Arlington":
						e_arlington = player;
						break;
					break;
					case "Sal":
						e_sal = player;
						break;
					break;
					case "Billy":
						e_billy = player;
						break;
					break;
					case "Finn":
						e_finn = player;
						break;
					break;
				}
			}
			_k513 = GetNextArrayKey( _a513, _k513 );
		}
		if ( isdefined( e_arlington ) && isdefined( e_sal ) || !isdefined( e_billy ) && !isdefined( e_finn ) )
		{
			return;
		}
		else _a542 = players;
		_k542 = GetFirstArrayKey( _a542 );
		while ( isdefined( _k542 ) )
		{
			player = _a542[ _k542 ];
			if ( isdefined( player ) )
			{
				player.dontspeak = 1;
				//player clientfield::set_to_player( "isspeaking", 1 );
			}
			_k542 = GetNextArrayKey( _a542, _k542 );
		}
		i = 0;
		while ( i < convo.size )
		{
			players = GetPlayers();
			if ( players.size != 4 )
			{
				_a557 = players;
				_k557 = GetFirstArrayKey( _a557 );
				while ( isdefined( _k557 ) )
				{
					player = _a557[ _k557 ];
					if ( isdefined( player ) )
					{
						player.dontspeak = 0;
						//player clientfield::set_to_player( "isspeaking", 0 );
					}
					_k557 = GetNextArrayKey( _a557, _k557 );
				}
				level flag::clear( "story_vo_playing" );
				return;
			}
			if ( IsSubStr( convo[ i ], "plr_0" ) )
			{
				speaking_player = e_finn;
			}
			else if ( IsSubStr( convo[ i ], "plr_1" ) )
			{
				speaking_player = e_sal;
			}
			else if ( IsSubStr( convo[ i ], "plr_2" ) )
			{
				speaking_player = e_billy;
			}
			else
			{
				if ( IsSubStr( convo[ i ], "plr_3" ) )
				{
					speaking_player = e_arlington;
				}
			}
			if ( isdefined( old_speaking_player ) )
			{
				n_dist = Distance( old_speaking_player.origin, speaking_player.origin );
			}
			if ( speaking_player.afterlife || n_dist > n_max_reply_dist )
			{
				_a593 = players;
				_k593 = GetFirstArrayKey( _a593 );
				while ( isdefined( _k593 ) )
				{
					player = _a593[ _k593 ];
					if ( isdefined( player ) )
					{
						player.dontspeak = 0;
						//player clientfield::set_to_player( "isspeaking", 0 );
					}
					_k593 = GetNextArrayKey( _a593, _k593 );
				}
				level flag::clear( "story_vo_playing" );
				return;
			}
			else
			{
				speaking_player PlaySoundWithNotify( convo[ i ], "sound_done" + convo[ i ] );
				speaking_player waittill( "sound_done" + convo[ i ] );
				old_speaking_player = speaking_player;
			}
			wait 1;
			i++;
		}
		_a613 = players;
		_k613 = GetFirstArrayKey( _a613 );
		while ( isDefined( _k613 ) )
		{
			player = _a613[ _k613 ];
			if ( isdefined( player ) )
			{
				player.dontspeak = 0;
				//player clientfield::set_to_player( "isspeaking", 0 );
			}
			_k613 = GetNextArrayKey( _a613, _k613 );
		}
		level flag::clear( "story_vo_playing" );
	}
}

function electric_chair_vo()
{
	if ( level.n_quest_iteration_count == 1 )
	{
		e_nml_zone = GetEnt( "bridge_zone", "targetname" );
		n_players_on_bridge_count = get_players_touching( "bridge_zone" );
		players = GetPlayers();
		if ( players.size == 4 && n_players_on_bridge_count == 4 )
		{
			if ( count_zombies_in_zone( "bridge_zone" ) > 0 )
			{
				vo_play_four_part_conversation( level.four_part_convos[ "chair_combat_" + randomintrange( 1, 3 ) ] );
			}
			else
			{
				vo_play_four_part_conversation( level.four_part_convos[ "chair" + randomintrange( 1, 3 ) ] );
			}
			return;
		}
		else
		{
			if ( isdefined( players[ 0 ] ) && players[ 0 ] IsTouching( e_nml_zone ) )
			{
				character_name = players[ 0 ].character_name;
				players[ 0 ] vo_play_soliloquy( level.soliloquy_convos[ "electric_chair_" + character_name ] );
			}
		}
	}
}

function escape_flight_vo()
{
	e_roof_zone = GetEnt( "roof_zone", "targetname" );
	players = GetPlayers();
	player = players[ RandomIntRange( 0, players.size ) ];
	if ( isdefined( player ) && player IsTouching( e_roof_zone ) )
	{
		player thread zm_utility::do_player_general_vox( "quest", "build_plane", undefined, 100 );
	}
	level flag::wait_till( "plane_boarded" );
	if ( level.final_flight_activated )
	{
		return;
	}
	while ( level.characters_in_nml.size == 0 )
	{
		wait 0.1;
	}
	wait 1;
	if ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ RandomIntRange( 0, level.characters_in_nml.size ) ];
		players = GetPlayers();
		_a687 = players;
		_k687 = GetFirstArrayKey( _a687 );
		while ( isdefined( _k687 ) )
		{
			player = _a687[ _k687 ];
			if ( isdefined( player ) && player.character_name == character_name )
			{
				player thread zm_utility::do_player_general_vox( "quest", "plane_takeoff" );
			}
			_k687 = GetNextArrayKey( _a687, _k687 );
		}
		wait 0.05;
	}
	level flag::wait_till( "plane_departed" );
	wait 2;
	if ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ randomintrange( 0, level.characters_in_nml.size ) ];
		players = GetPlayers();
		_a703 = players;
		_k703 = GetFirstArrayKey( _a703 );
		while ( isdefined( _k703 ) )
		{
			player = _a703[ _k703 ];
			if ( isdefined( player ) && player.character_name == character_name )
			{
				player PlaySound( "vox_plr_" + player.characterindex + "_plane_flight_0" );
			}
			_k703 = GetNextArrayKey( _a703, _k703 );
		}
		wait 0.05;
	}
	level flag::wait_till( "plane_approach_bridge" );
	wait 3.5;
	if ( level.characters_in_nml.size > 0 )
	{
		character_name = level.characters_in_nml[ randomintrange( 0, level.characters_in_nml.size ) ];
		players = GetPlayers();
		_a719 = players;
		_k719 = GetFirstArrayKey( _a719 );
		while ( isdefined( _k719 ) )
		{
			player = _a719[ _k719 ];
			if ( isdefined( player ) && player.character_name == character_name )
			{
				player PlaySound( "vox_plr_" + player.characterindex + "_plane_crash_0" );
			}
			_k719 = GetNextArrayKey( _a719, _k719 );
		}
		wait 0.05;
	}
	level flag::wait_till( "plane_zapped" );
	players = GetPlayers();
	_a732 = players;
	_k732 = GetFirstArrayKey( _a732 );
	while ( isdefined( _k732 ) )
	{
		player = _a732[ _k732 ];
		if ( isdefined( player ) && IsInArray( level.characters_in_nml, player.character_name ) )
		{
			player thread player_scream_thread();
		}
		_k732 = GetNextArrayKey( _a732, _k732 );
	}
}

function player_scream_thread()
{
	self endon( "death" );
	self endon( "disconnect" );
	players = GetPlayers();
	_a749 = players;
	_k749 = GetFirstArrayKey( _a749 );
	while ( isdefined( _k749 ) )
	{
		player = _a749[ _k749 ];
		if ( isdefined( player ) && IsInArray( level.characters_in_nml, player.character_name ) )
		{
			player PlaySoundToPlayer( "vox_plr_" + player.characterindex + "_free_fall_0", self );
		}
		_k749 = GetNextArrayKey( _a749, _k749 );
	}
	level flag::wait_till( "plane_crashed" );
	self StopSounds();
	self.dontspeak = 0;
	//player clientfield::set_to_player( "isspeaking", 0 );
}

function sndhitelectrifiedpulley( str_master_key_location )
{
	self endon( "master_key_pulley_" + str_master_key_location );
	while ( 1 )
	{
		self waittill( "trigger", e_triggerer );
		self PlaySound( "fly_elec_sparks_key" );
		wait 1;
	}
}

function is_player_character_present( character_name )
{
	if ( !isdefined( character_name ) )
	{
		return 0;
	}
	players = GetPlayers();
	_a785 = players;
	_k785 = GetFirstArrayKey( _a785 );
	while ( isdefined( _k785 ) )
	{
		player = _a785[ _k785 ];
		if ( isdefined( player.character_name ) && player.character_name == character_name )
		{
			return 1;
		}
		_k785 = GetNextArrayKey( _a785, _k785 );
	}
	return 0;
}

function get_players_touching( scr_touched_name )
{
	n_touching_count = 0;
	e_touched = GetEnt( scr_touched_name, "targetname" );
/#
	assert( isdefined( e_touched ) );
#/
	a_players = GetPlayers();
	_a803 = a_players;
	_k803 = GetFirstArrayKey( _a803 );
	while ( isdefined( _k803 ) )
	{
		player = _a803[ _k803 ];
		if ( isdefined( player ) && player IsTouching( e_touched ) )
		{
			n_touching_count++;
		}
		_k803 = GetNextArrayKey( _a803, _k803 );
	}
	return n_touching_count;
}

function count_zombies_in_zone( volume )
{
	e_zone = GetEnt( volume, "targetname" );
	if ( !isdefined( e_zone ) )
	{
		return;
	}
	n_zombie_count = 0;
	zombies = GetAISpeciesArray( "axis", "all" );
	i = 0;
	while ( i < zombies.size )
	{
		if ( zombies[ i ] IsTouching( e_zone ) )
		{
			n_zombie_count++;
		}
		i++;
	}
	return n_zombie_count;
}
