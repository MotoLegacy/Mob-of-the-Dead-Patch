#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_weap_tomahawk.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

#precache( "client_fx", "harry/tomahawk/fx_tomahawk_glow" );
#precache( "client_fx", "harry/tomahawk/fx_tomahawk_glow_ug" );

#namespace zm_weap_tomahawk; 

function autoexec init()
{
	level._effect[ "tomahawk_pickup" ] = "harry/tomahawk/fx_tomahawk_glow";
	level._effect[ "tomahawk_pickup_upgrade" ] = "harry/tomahawk/fx_tomahawk_glow_ug";
	clientfield::register( "toplayer", "tomahawk_in_use", 9000, 2, "int", &tomahawk_in_use, 0, 1 );
	setupClientFieldCodeCallbacks( "toplayer", 1, "tomahawk_in_use" );
	clientfield::register( "toplayer", "upgraded_tomahawk_in_use", 9000, 1, "int", &tomahawk_in_use, 0, 1 );
	setupClientFieldCodeCallbacks( "toplayer", 1, "upgraded_tomahawk_in_use" );
	clientfield::register( "scriptmover", "play_tomahawk_fx", 9000, 2, "int", &play_tomahawk_pickup_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "play_tomahawk_hit_sound", 9000, 1, "int", &play_sound_on_zombies, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}


function tomahawk_in_use( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
}

function play_tomahawk_pickup_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self util::waittill_dobj( localclientnum );
	if(newval == 1)
	{
		e_pickup_fx = struct::get("tomahawk_pickup_pos", "targetname" );
		e_pickup_fx = Spawn( localclientnum, self.origin, "script_model" );
		e_pickup_fx.angles = self.angles;
		e_pickup_fx.targetname = "tomahawk_pickup_fx_origin";
		e_pickup_fx SetModel( "tag_origin" );
		self.tomahawk_glow_fx = PlayFXOnTag( localclientnum, level._effect["tomahawk_pickup"], e_pickup_fx, "tag_origin" );
	}
	else
	{
		StopFX( localClientNum, self.tomahawk_glow_fx );
		e_pickup_fx = struct::get( "tomahawk_pickup_pos", "targetname" );
		e_pickup_upgrade_fx = Spawn( localclientnum, e_pickup_fx.origin, "script_model" );
		e_pickup_upgrade_fx.angles = e_pickup_fx.angles;
		e_pickup_upgrade_fx.targetname = "tomahawk_pickup_upgrade_fx_origin";
		e_pickup_upgrade_fx SetModel( "tag_origin" );
		self.tomahawk_glow_fx = PlayFXOnTag( localclientnum, level._effect["tomahawk_pickup_upgrade"], e_pickup_upgrade_fx, "tag_origin" );
	}
	
}

function play_sound_on_zombies( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self PlaySound( localclientnum, "wpn_tomahawk_impact" );
}
