//
// MIT License
//
// Copyright (c) 2021 MotoLegacy, JariKCoding
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\zm\zm_alcatraz_utility;
#using scripts\zm\_zm_utility;

#precache( "material", "clickbait_face" );

function autoexec init()
{
	callback::on_connect(&onplayerconnect_sq_clickbait);
}

function onplayerconnect_sq_clickbait()
{
	if ( !isdefined( level.clickbait_lookat_point ) )
	{
		level.clickbait_lookat_point = struct::get( "struct_clickbait_look", "targetname" );
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
		if ( n_time >= 25 && self AdsButtonPressed() && self zm_alcatraz_utility::is_player_in_zone( "cafe_zone_b" ) && sq_is_weapon_sniper( self GetCurrentWeapon() ) && zm_utility::is_player_looking_at( level.clickbait_lookat_point.origin, 0.9, 0, undefined ) )
		{
			self zm_utility::do_player_general_vox( "general", "scare_react", undefined, 100 );
			self PlaySoundToPlayer( "clickbait_sound", self );
			self.clickbait_elem = NewClientHudElem( self );
			self.clickbait_elem.horzalign = "fullscreen";
			self.clickbait_elem.vertalign = "fullscreen";
			self.clickbait_elem.sort = 1000;
			self.clickbait_elem.foreground = 0;
			self.clickbait_elem SetShader( "clickbait_face", 640, 480 );
			self.clickbait_elem.hidewheninmenu = 1;
			self.clickbait_elem.alpha = 1;
			j_time = 0;
			while ( self AdsButtonPressed() && j_time < 5 )
			{
				j_time++;
				wait 0.05;
			}
			self.clickbait_elem Destroy();
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