#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\zm\zm_alcatraz_utility;
#using scripts\zm\_zm_utility;

#precache( "material", "zm_al_wth_zombie" );

function autoexec init()
{
	callback::on_connect(&onplayerconnect_sq_wth);
}

function onplayerconnect_sq_wth()
{
	if ( !isdefined( level.wth_lookat_point ) )
	{
		level.wth_lookat_point = struct::get( "struct_gg_look", "targetname" );
	}
	self thread track_player_eyes();
}

function track_player_eyes()
{
	self endon( "disconnect" );
	b_saw_the_wth = 0;
	while ( !b_saw_the_wth )
	{
		n_time = 0;
		while ( self AdsButtonPressed() && n_time < 25 )
		{
			n_time++;
			wait 0.05;
		}
		if ( n_time >= 25 && self AdsButtonPressed() && self zm_alcatraz_utility::is_player_in_zone( "roof_zone" ) && sq_is_weapon_sniper( self GetCurrentWeapon() ) && zm_utility::is_player_looking_at( level.wth_lookat_point.origin, 0.9, 0, undefined ) )
		{
			self zm_utility::do_player_general_vox( "general", "scare_react", undefined, 100 );
			self PlaySoundToPlayer( "zmb_easteregg_face", self );
			self.wth_elem = NewClientHudElem( self );
			self.wth_elem.horzalign = "fullscreen";
			self.wth_elem.vertalign = "fullscreen";
			self.wth_elem.sort = 1000;
			self.wth_elem.foreground = 0;
			self.wth_elem SetShader( "zm_al_wth_zombie", 640, 480 );
			self.wth_elem.hidewheninmenu = 1;
			self.wth_elem.alpha = 1;
			j_time = 0;
			while ( self AdsButtonPressed() && j_time < 5 )
			{
				j_time++;
				wait 0.05;
			}
			self.wth_elem Destroy();
			b_saw_the_wth = 1;
		}
		wait 0.05;
	}
}

function sq_is_weapon_sniper( str_weapon )
{
	if(str_weapon.name == "sniper_dsr50" || str_weapon.name == "sniper_dsr50_upgraded" || str_weapon.name == "sniper_barretm82" || str_weapon.name == "sniper_barretm82_upgraded")
	{
		return 1;
	}
	return 0;
}