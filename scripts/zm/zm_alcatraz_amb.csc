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
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_alcatraz_amb;

function autoexec main()
{
	SetSoundContext( "grass", "no_grass" );
	SetSoundContext( "f35", "exterior" );

	level thread sndstartambience();
	level thread sndforcefieldwait();
	level thread sndwardenofficeelectricity();
	level thread sndplanesnapshot();
	level thread sndgondolaloops();
	level thread sndplanealarmoneshots();
	level thread snddefendeventscreams();
	level thread hellhole_loop();
	level thread sndspectatorreset();
	level thread sndfinalflightcontext();
}

function sndfinalflightcontext()
{
	level waittill( "sndFFCON" );
	SetSoundContext( "f35", "interior" );
}

function sndgameoversnapshot()
{
	level waittill( "zesn" );
	wait 0.5;
	audio::snd_set_snapshot( "zmb_mus_gameover" );
}

function sndgameoverwhitescreen()
{
	level waittill( "sndSQF" );
	audio::snd_set_snapshot( "zmb_mus_gameover" );
}

function hellhole_loop()
{
	audio::playloopat( "amb_hellhole_loop", ( 868, 9631, 1318 ) );
}

function sndwardenofficeelectricity()
{
	audio::playloopat( "amb_electrical_fence", ( -865, 9515, 1399 ) );
	level waittill( "sndWard" );
	audio::stoploopat( "amb_electrical_fence", ( -865, 9515, 1399 ) );
}

function sndstartambience()
{
	thread snd_start_autofx_audio();
}

function snd_start_autofx_audio()
{
	audio::snd_play_auto_fx( "fx_alcatraz_fire_md", "amb_fire_lrg", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_fire_sm", "amb_fire_med", 0, 0, 0, 1 );
	audio::snd_play_auto_fx( "fx_alcatraz_fire_xsm", "amb_fire_sml", 0, 0, 0, 1 );
	audio::snd_play_auto_fx( "fx_alcatraz_ceiling_fire", "amb_fire_med", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_water_drip", "amb_water_drip", 0, 0, 0, 1 );
	audio::snd_play_auto_fx( "fx_alcatraz_flies", "amb_flies", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_blood_drip", "amb_blood_drips", 0, 0, 0, 1 );
	audio::snd_play_auto_fx( "fx_alcatraz_light_tinhat", "amb_hanging_light", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_light_tinhat_oo", "amb_hanging_light", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_steam_pipe_2", "amb_steam_pipe", 0, 0, 0, 0 );
	audio::snd_play_auto_fx( "fx_alcatraz_light_round_oo", "amb_outside_lights", 0, 0, 0, 0 );
}

function afterlifeaudio( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self activateafterlifeaudio();
	self deactivateafterlifeaudio();
}

function activateafterlifeaudio()
{
	//activateambientroom( 0, "afterlife", 98 );
	PlaySound( 0, "zmb_afterlife_start", ( 0, 0, 0 ) );
	audio::snd_set_snapshot( "zmb_afterlife" );
	SetSoundContext( "grass", "in_grass" );
}

function deactivateafterlifeaudio()
{
	//deactivateambientroom( 0, "afterlife", 98 );
	PlaySound( 0, "zmb_afterlife_end", ( 0, 0, 0 ) );
	audio::snd_set_snapshot( "default" );
	SetSoundContext( "grass", "no_grass" );
}

function sndspectatorreset()
{
	level waittill( "sndSR" );
	self notify( "sndEndLeak" );
	//deactivateambientroom( 0, "afterlife", 98 );
	audio::snd_set_snapshot( "default" );
	SetSoundContext( "grass", "no_grass" );
}

function sndforcefieldwait()
{
	locations = [];
	locations[0] = ( 1225, 9992, 1190 );
	locations[1] = ( 2142, 9212, 1395 );
	steam = [];
	steam[0] = ( 2011, 10220, 1278 );
	steam[1] = ( 2066, 9941, 1278 );
	steam[2] = ( 2081, 9689, 1279 );
	steam[3] = ( 2010, 9229, 1279 );
	steam[4] = ( 1716, 9228, 1278 );
	steam[5] = ( 1659, 9672, 1276 );
	steam[6] = ( 1856, 9792, 1309 );
	steam[7] = ( 1701, 9929, 1280 );
	steam[8] = ( 1826, 10068, 1262 );
	steam[9] = ( 1606, 10226, 1276 );
	steam[10] = ( 1829, 10223, 1278 );
	steam[11] = ( 2097, 10222, 1280 );
	steam[12] = ( 1918, 9503, 1309 );
	steam[13] = ( 1672, 10322, 1263 );
	steam[14] = ( 1586, 10598, 1257 );
	while(1)
	{
		level waittill( "sndFF" );
		thread sndstartff( locations, steam );
		level waittill( "sndFF" );
		thread sndendff( locations, steam );
	}
}

function sndstartff( array, array2 )
{
	foreach ( place in array )
	{
		PlaySound( 0, "zmb_quest_forcefield_start", place );
		audio::playloopat( "zmb_quest_forcefield_loop", place );
	}
	foreach ( position in array2 )
	{
		PlaySound( 0, "evt_shower_steam_srt", position );
		wait 0.05;
		audio::playloopat( "evt_shower_steam", position );
	}
}

function sndendff( array, array2 )
{
	foreach ( place in array )
	{
		audio::stoploopat( "zmb_quest_forcefield_loop", place );
		PlaySound( 0, "zmb_quest_forcefield_end", place );
	}
	foreach ( position in array2 )
	{
		audio::stoploopat( "evt_shower_steam", position );
		wait 0.05;
		PlaySound( 0, "evt_shower_steam_stop", position );
	}
}

function sndplanesnapshot()
{
	level waittill( "sndPS" );
	level waittill( "sndPE" );
}

function sndgondolaloops()
{
	while(1)
	{
		level waittill( "sndGS" );
		audio::playloopat( "zmb_gondola_generator_loop", ( 895, 8219, 1680 ) );
		audio::playloopat( "zmb_gondola_wheels", ( 899, 5928, 435 ) );
		audio::playloopat( "zmb_gondola_generator_loop", ( 863, 5606, 333 ) );
		level waittill( "sndGE" );
		audio::stoploopat( "zmb_gondola_generator_loop", ( 895, 8219, 1680 ) );
		audio::stoploopat( "zmb_gondola_wheels", ( 899, 5928, 435 ) );
		audio::stoploopat( "zmb_gondola_generator_loop", ( 863, 5606, 333 ) );
	}
}

function sndplanealarmoneshots()
{
	while(1)
	{
		level waittill( "sndPB" );
		PlaySound( 0, "zmb_plane_countdown_alarm", ( 756, 9664, 2153 ) );
		wait 0.1;
		PlaySound( 0, "zmb_plane_countdown_alarm", ( 4852, 9653, 1980 ) );
	}
}

function snddefendeventscreams()
{
	while(1)
	{
		level waittill( "sndFF" );
		PlaySound( 0, "zmb_easteregg_scream", ( 2233, 10345, 1224 ) );
		wait 1;
		PlaySound( 0, "zmb_easteregg_laugh", ( 1597, 10068, 1228 ) );
	}
}