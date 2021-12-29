// clientscripts/mp/zm_alcatraz_craftables.csc

#using scripts\zm\craftables\_zm_craftables;
#using scripts\shared\clientfield_shared;

#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_utility;

#using scripts\zm\_zm_weap_ammo_counter;
#using scripts\zm\_zm_afterlife;
#using scripts\shared\ai\archetype_brutus;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

function init_craftables()
{
	level.craftable_piece_count = 10;
	register_clientfields();
	zm_craftables::add_zombie_craftable( "alcatraz_shield_zm" );
	zm_craftables::add_zombie_craftable( "packasplat" );
	zm_craftables::add_zombie_craftable( "plane" );
	level thread zm_craftables::set_clientfield_craftables_code_callbacks();
}

function include_craftables()
{
	zm_craftables::include_zombie_craftable( "alcatraz_shield_zm" );
	zm_craftables::include_zombie_craftable( "packasplat" );
	zm_craftables::include_zombie_craftable( "plane" );
}

function register_clientfields()
{
	visionset_mgr::register_visionset_info( "afterlife", 9000, 1, "afterlife", "afterlife" );

	//visionset_mgr::register_overlay_info_style_filter( "afterlife_filter", 9000, 1, 5, 0, "generic_filter_afterlife_alcatraz" );

	bits = 1;
	clientfield::register( "world", "piece_packasplat_fuse",	VERSION_SHIP, 1, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_packasplat_case", VERSION_SHIP, 1, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_packasplat_blood",	VERSION_SHIP, 1, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_key_warden",	VERSION_SHIP, 1, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );

	bits = GetMinBitCountForNum( 5 );
	clientfield::register( "world", "piece_player_cloth",	VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_player_fueltanks", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_player_engine",	VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_player_steering",	VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "piece_player_rigging",	VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );

	bits = GetMinBitCountForNum( 7 );
	clientfield::register( "world", "quest_state1", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "quest_state2", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "quest_state3", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "quest_state4", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "quest_state5", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
	bits = 1;
	clientfield::register( "world", "quest_plane_craft_complete", VERSION_SHIP, bits, "int", &SetPlayerUI, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function SetPlayerUI( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump ) {
	model = CreateUIModel( GetUIModelForController( localClientNum ), fieldname );
	SetUIModelValue( model, newVal );
}