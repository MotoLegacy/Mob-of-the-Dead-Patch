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
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_weap_ammo_counter.gsh;
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

#namespace zm_weap_ammo_counter; 

REGISTER_SYSTEM_EX( "zm_weap_ammo_counter", &__init__, undefined, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{	
	clientfield::register( "toplayer", "ammo_counter", 9000, 2, "int" );

	callback::on_connect( &on_player_connect );
}

function on_player_connect()
{
	self thread ammo_counter_reload_watcher();
}

function ammo_counter_reload_watcher()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self clientfield::set_to_player( "ammo_counter", 1 );
		
		self waittill( "reload_start" );
		
		self clientfield::set_to_player( "ammo_counter", 0 );
		
		while ( self isReloading() )
			wait .05;
		
		
	}
}