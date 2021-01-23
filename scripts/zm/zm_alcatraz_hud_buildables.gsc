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

#using scripts\zm\_zm_score;
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_util_shared;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_clone;

#using scripts\zm\craftables\_zm_craftables;

#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", "splat_blood_logo" );
#precache( "material", "splat_case_logo" );
#precache( "material", "splat_fuse_logo" );
#precache( "material", "shield_clamp_logo" );
#precache( "material", "shield_door_logo" );
#precache( "material", "shield_dolly_logo" );
#precache( "material", "hud_zom_bg" );
#precache( "material", "hud_zom_bg_1" );
#precache( "material", "hud_zom_bg_5" );
#precache( "material", "hud_zom_found" );
#precache( "material", "plane_key_logo" );
#precache( "material", "plane_clothes_logo" );
#precache( "material", "plane_tanks_logo" );
#precache( "material", "plane_engine_logo" );
#precache( "material", "plane_valve_logo" );
#precache( "material", "plane_rigging_logo" );
#precache( "material", "hud_zombie_checkmark" );
#precache( "material", "zom_hud_craftable_plane_gascan" );

function autoexec init()
{
	level.pickedup_case = false;
	level.pickedup_fuse = false;
	level.pickedup_blood = false;
	level.pickedup_dolly = false;
	level.pickedup_door = false;
	level.pickedup_clamp = false;
	level.plane_control = false;
	level.plane_engine = false;
	level.plane_tanks = false;
	level.plane_riggings = false;
	level.plane_clothes = false;
	level.plane_control_built = false;
	level.plane_engine_built = false;
	level.plane_tanks_built = false;
	level.plane_riggings_built = false;
	level.plane_clothes_built = false;
	level.plane_fuel_1 = false;
	level.plane_fuel_2 = false;
	level.plane_fuel_3 = false;
	level.plane_fuel_4 = false;
	level.plane_fuel_5 = false;
	level.plane_fuel1_built = false;
	level.plane_fuel2_built = false;
	level.plane_fuel3_built = false;
	level.plane_fuel4_built = false;
	level.plane_fuel5_built = false;
}

function players_hud_shield_splat(shield, triggerer, part_name)
{
	players = GetPlayers();
	for(i=0; i < players.size; i++)
	{
		players[i] thread show_parts_hud_shield_splat(part_name, shield, triggerer);
	}
}

function show_parts_hud_shield_splat(part_name, shield, triggerer)
{
	while(isdefined(self.part_hud_showing) && self.part_hud_showing == true)
	{
		wait 0.5;
	}

	self.part_hud_showing = true;

	self.hud_background = NewClientHudElem( self );
	self.hud_background SetShader( "hud_zom_bg", 96, 32 );
	self.hud_background.foreground = true; 
	self.hud_background.sort = 1; 
	self.hud_background.hidewheninmenu = true; 
	self.hud_background.horzAlign = "left"; 
	self.hud_background.vertAlign = "top";
	self.hud_background.x = 20; 
	self.hud_background.y = 40; 
	self.hud_background.alpha = 0.8;
	
	self.hud_splat_part1 = NewClientHudElem( self );
	if(shield == true)
	{
		self.hud_splat_part1 SetShader( "shield_dolly_logo", 32, 32 );
	}
	else
	{
		self.hud_splat_part1 SetShader( "splat_fuse_logo", 32, 32 );
	}
	self.hud_splat_part1.foreground = true; 
	self.hud_splat_part1.sort = 2; 
	self.hud_splat_part1.hidewheninmenu = true; 
	self.hud_splat_part1.horzAlign = "left"; 
	self.hud_splat_part1.vertAlign = "top";
	self.hud_splat_part1.x = 20; 
	self.hud_splat_part1.y = 40; 
	self.hud_splat_part1.alpha = 0;

	self.hud_splat_part2 = NewClientHudElem( self );
	if(shield == true)
	{
		self.hud_splat_part2 SetShader( "shield_door_logo", 32, 32 );
	}
	else
	{
		self.hud_splat_part2 SetShader( "splat_case_logo", 32, 32 );
	}
	self.hud_splat_part2.foreground = true; 
	self.hud_splat_part2.sort = 3; 
	self.hud_splat_part2.hidewheninmenu = true; 
	self.hud_splat_part2.horzAlign = "left"; 
	self.hud_splat_part2.vertAlign = "top";
	self.hud_splat_part2.x = 52; 
	self.hud_splat_part2.y = 40; 
	self.hud_splat_part2.alpha = 0;

	self.hud_splat_part3 = NewClientHudElem( self );
	if(shield == true)
	{
		self.hud_splat_part3 SetShader( "shield_clamp_logo", 32, 32 );
	}
	else
	{
		self.hud_splat_part3 SetShader( "splat_blood_logo", 32, 32 );
	}
	self.hud_splat_part3.foreground = true; 
	self.hud_splat_part3.sort = 4; 
	self.hud_splat_part3.hidewheninmenu = true; 
	self.hud_splat_part3.horzAlign = "left"; 
	self.hud_splat_part3.vertAlign = "top";
	self.hud_splat_part3.x = 84; 
	self.hud_splat_part3.y = 40; 
	self.hud_splat_part3.alpha = 0;

	self.hud_splat_text = NewClientHudElem( self );
	if(shield == true)
	{
		self.hud_splat_text SetText("Zombie Shield");
	}
	else
	{
		self.hud_splat_text SetText("Acid Gat Kit");
	}
	self.hud_splat_text.foreground = true; 
	self.hud_splat_text.sort = 7; 
	self.hud_splat_text.hidewheninmenu = true; 
	self.hud_splat_text.horzAlign = "left"; 
	self.hud_splat_text.vertAlign = "top";
	self.hud_splat_text.fontscale = 1.5;
	self.hud_splat_text.x = 36; 
	self.hud_splat_text.y = 20; 
	self.hud_splat_text.alpha = 0;
	self.hud_splat_text.color = ( 1, 1, 1 );

   	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0.8;

	found_x = undefined;

	switch(part_name)
   	{
   		case "fuse":
   			found_x = 20;
   			break;
		case "case":
			found_x = 52;
   			break;
		case "blood":
			found_x = 84;
   			break;
   		case "dolly":
   			found_x = 20;
   			break;
		case "door":
			found_x = 52;
   			break;
		case "clamp":
			found_x = 84;
   			break;
		default:
				found_x = -200;
			break;
   	}

	self.hud_splat_part_found = NewClientHudElem( self );
	if(isdefined(part_name))
		self.hud_splat_part_found SetShader( "hud_zom_found", 32, 32 );
	self.hud_splat_part_found.foreground = true; 
	self.hud_splat_part_found.sort = 8; 
	self.hud_splat_part_found.hidewheninmenu = true; 
	self.hud_splat_part_found.horzAlign = "left"; 
	self.hud_splat_part_found.vertAlign = "top";
	self.hud_splat_part_found.x = found_x; 
	self.hud_splat_part_found.y = 40; 
	self.hud_splat_part_found.alpha = 0;

	self.hud_splat_part1 FadeOverTime( 1 );
	if(shield == true)
	{
		if(part_name == "dolly" || level.pickedup_dolly)
		{
			self.hud_splat_part1.alpha = 1;
			level.pickedup_dolly = true;
		} 
		else
		{
			self.hud_splat_part1.alpha = 0.3;
		}
	}
	else
	{
		if(part_name == "fuse" || level.pickedup_fuse)
		{
			self.hud_splat_part1.alpha = 1;
			level.pickedup_fuse = true;
		} 
		else
		{
			self.hud_splat_part1.alpha = 0.3;
		}
	}
	
	
	self.hud_splat_part2 FadeOverTime( 1 );
	if(shield == true)
	{
		if(part_name == "door" || level.pickedup_door)
		{
			self.hud_splat_part2.alpha = 1;
			level.pickedup_door = true;
		}
		else
		{
			self.hud_splat_part2.alpha = 0.3;
		}
	}
	else
	{
		if(part_name == "case" || level.pickedup_case)
		{
			self.hud_splat_part2.alpha = 1;
			level.pickedup_case = true;
		}
		else
		{
			self.hud_splat_part2.alpha = 0.3;
		}
	}
	

	self.hud_splat_part3 FadeOverTime( 1 );
	if(shield == true)
	{
		if(part_name == "clamp" || level.pickedup_clamp)
		{
			self.hud_splat_part3.alpha = 1;
			level.pickedup_clamp = true;
		}
		else
		{
			self.hud_splat_part3.alpha = 0.3;
		}
	}
	else
	{
		if(part_name == "blood" || level.pickedup_blood)
		{
			self.hud_splat_part3.alpha = 1;
			level.pickedup_blood = true;
		}
		else
		{
			self.hud_splat_part3.alpha = 0.3;
		}
	}
	

	self.hud_splat_text FadeOverTime( 1 );
	self.hud_splat_text.alpha = 1;

	wait 1.5;

	total_flash = 3;
	while(total_flash > 0)
	{
		self.hud_splat_part_found FadeOverTime( 0.75 );
		self.hud_splat_part_found.alpha = 1;

		wait 0.75;

		self.hud_splat_part_found FadeOverTime( 0.75 );
		self.hud_splat_part_found.alpha = 0;

		wait 0.75;
		total_flash--;
	}

	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0;

	self.hud_splat_part1 FadeOverTime( 1 );
	self.hud_splat_part1.alpha = 0;

	self.hud_splat_part2 FadeOverTime( 1 );
	self.hud_splat_part2.alpha = 0;

	self.hud_splat_part3 FadeOverTime( 1 );
	self.hud_splat_part3.alpha = 0;


	self.hud_plane_text FadeOverTime( 1 );
	self.hud_plane_text.alpha = 0;

	wait 1;

	self.hud_background Destroy();
	self.hud_splat_part1 Destroy();
	self.hud_splat_part2 Destroy();
	self.hud_splat_part3 Destroy();
	self.hud_splat_text Destroy();
	self.hud_splat_part_found Destroy();

   	self.part_hud_showing = undefined;
}

function players_hud_key()
{
	players = GetPlayers();
	for(i=0; i < players.size; i++)
	{
		players[i] thread show_key_hud();
	}
}

function show_key_hud()
{
	while(isdefined(self.part_hud_showing) && self.part_hud_showing == true)
	{
		wait 0.5;
	}

	self.part_hud_showing = true;

	self.hud_background_key = NewClientHudElem( self );
	self.hud_background_key SetShader( "hud_zom_bg_1", 32, 32 );
	self.hud_background_key.foreground = true; 
	self.hud_background_key.sort = 1; 
	self.hud_background_key.hidewheninmenu = true; 
	self.hud_background_key.horzAlign = "left"; 
	self.hud_background_key.vertAlign = "top";
	self.hud_background_key.x = 20; 
	self.hud_background_key.y = 40; 
	self.hud_background_key.alpha = 0.8;

	self.hud_key = NewClientHudElem( self );
	self.hud_key SetShader( "plane_key_logo", 32, 32 );
	self.hud_key.foreground = true; 
	self.hud_key.sort = 2; 
	self.hud_key.hidewheninmenu = true; 
	self.hud_key.horzAlign = "left"; 
	self.hud_key.vertAlign = "top";
	self.hud_key.x = 20; 
	self.hud_key.y = 40; 
	self.hud_key.alpha = 0.3;

	self.hud_key_text = NewClientHudElem( self );
	self.hud_key_text SetText("Wardens Key");
	self.hud_key_text.foreground = true; 
	self.hud_key_text.sort = 7; 
	self.hud_key_text.hidewheninmenu = true; 
	self.hud_key_text.horzAlign = "left"; 
	self.hud_key_text.vertAlign = "top";
	self.hud_key_text.x = 36; 
	self.hud_key_text.y = 20; 
	self.hud_key_text.fontscale = 1.5;
	self.hud_key_text.alpha = 0;
	self.hud_key_text.color = ( 1, 1, 1 );

	self.hud_background_key FadeOverTime( 1 );
	self.hud_background_key.alpha = 0.8;

	self.hud_key FadeOverTime( 1 );
	self.hud_key.alpha = 1;

	self.hud_key_text fadeOverTime( 1 );
	self.hud_key_text.alpha = 1;

	wait 4;

	self.hud_background_key FadeOverTime( 1 );
	self.hud_background_key.alpha = 0;

	self.hud_key FadeOverTime( 1 );
	self.hud_key.alpha = 0;

	self.hud_key_text FadeOverTime( 1 );
	self.hud_key_text.alpha = 0;

	wait 1;

	self.hud_background_key Destroy();
	self.hud_key Destroy();
	self.hud_key_text Destroy();

	self.part_hud_showing = undefined;
}

function players_hud_plane(part_name)
{
	players = GetPlayers();
	for(i=0; i < players.size; i++)
	{
		players[i] thread show_parts_hud_plane(part_name);
	}
}

function show_parts_hud_plane(part)
{
	while(isdefined(self.part_hud_showing) && self.part_hud_showing == true)
	{
		wait 0.5;
	}

	part_name = part.pieceName;

	self.part_hud_showing = true;

	self.hud_background = NewClientHudElem( self );
	self.hud_background SetShader( "hud_zom_bg_5", 160, 32 );
	self.hud_background.foreground = true; 
	self.hud_background.sort = 1; 
	self.hud_background.hidewheninmenu = true; 
	self.hud_background.horzAlign = "left"; 
	self.hud_background.vertAlign = "top";
	self.hud_background.x = 20; 
	self.hud_background.y = 40; 
	self.hud_background.alpha = 0.8;
	
	self.hud_plane_part1 = NewClientHudElem( self );
	self.hud_plane_part1 SetShader( "plane_clothes_logo", 32, 32 );
	self.hud_plane_part1.foreground = true; 
	self.hud_plane_part1.sort = 2; 
	self.hud_plane_part1.hidewheninmenu = true; 
	self.hud_plane_part1.horzAlign = "left"; 
	self.hud_plane_part1.vertAlign = "top";
	self.hud_plane_part1.x = 20; 
	self.hud_plane_part1.y = 40; 
	self.hud_plane_part1.alpha = 0;
	self.hud_plane_built_part1 = NewClientHudElem( self );
	self.hud_plane_built_part1 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_plane_built_part1.foreground = true; 
	self.hud_plane_built_part1.sort = 3; 
	self.hud_plane_built_part1.hidewheninmenu = true; 
	self.hud_plane_built_part1.horzAlign = "left"; 
	self.hud_plane_built_part1.vertAlign = "top";
	self.hud_plane_built_part1.x = 20; 
	self.hud_plane_built_part1.y = 40; 
	self.hud_plane_built_part1.alpha = 0;

	self.hud_plane_part2 = NewClientHudElem( self );
	self.hud_plane_part2 SetShader( "plane_tanks_logo", 32, 32 );
	self.hud_plane_part2.foreground = true; 
	self.hud_plane_part2.sort = 3; 
	self.hud_plane_part2.hidewheninmenu = true; 
	self.hud_plane_part2.horzAlign = "left"; 
	self.hud_plane_part2.vertAlign = "top";
	self.hud_plane_part2.x = 52; 
	self.hud_plane_part2.y = 40; 
	self.hud_plane_part2.alpha = 0;
	self.hud_plane_built_part2 = NewClientHudElem( self );
	self.hud_plane_built_part2 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_plane_built_part2.foreground = true; 
	self.hud_plane_built_part2.sort = 4; 
	self.hud_plane_built_part2.hidewheninmenu = true; 
	self.hud_plane_built_part2.horzAlign = "left"; 
	self.hud_plane_built_part2.vertAlign = "top";
	self.hud_plane_built_part2.x = 52; 
	self.hud_plane_built_part2.y = 40; 
	self.hud_plane_built_part2.alpha = 0;

	self.hud_plane_part3 = NewClientHudElem( self );
	self.hud_plane_part3 SetShader( "plane_engine_logo", 32, 32 );
	self.hud_plane_part3.foreground = true; 
	self.hud_plane_part3.sort = 4; 
	self.hud_plane_part3.hidewheninmenu = true; 
	self.hud_plane_part3.horzAlign = "left"; 
	self.hud_plane_part3.vertAlign = "top";
	self.hud_plane_part3.x = 84; 
	self.hud_plane_part3.y = 40; 
	self.hud_plane_part3.alpha = 0;
	self.hud_plane_built_part3 = NewClientHudElem( self );
	self.hud_plane_built_part3 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_plane_built_part3.foreground = true; 
	self.hud_plane_built_part3.sort = 5; 
	self.hud_plane_built_part3.hidewheninmenu = true; 
	self.hud_plane_built_part3.horzAlign = "left"; 
	self.hud_plane_built_part3.vertAlign = "top";
	self.hud_plane_built_part3.x = 84; 
	self.hud_plane_built_part3.y = 40; 
	self.hud_plane_built_part3.alpha = 0;

	self.hud_plane_part4 = NewClientHudElem( self );
	self.hud_plane_part4 SetShader( "plane_valve_logo", 32, 32 );
	self.hud_plane_part4.foreground = true; 
	self.hud_plane_part4.sort = 5; 
	self.hud_plane_part4.hidewheninmenu = true; 
	self.hud_plane_part4.horzAlign = "left"; 
	self.hud_plane_part4.vertAlign = "top";
	self.hud_plane_part4.x = 116; 
	self.hud_plane_part4.y = 40; 
	self.hud_plane_part4.alpha = 0;
	self.hud_plane_built_part4 = NewClientHudElem( self );
	self.hud_plane_built_part4 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_plane_built_part4.foreground = true; 
	self.hud_plane_built_part4.sort = 6; 
	self.hud_plane_built_part4.hidewheninmenu = true; 
	self.hud_plane_built_part4.horzAlign = "left"; 
	self.hud_plane_built_part4.vertAlign = "top";
	self.hud_plane_built_part4.x = 116; 
	self.hud_plane_built_part4.y = 40; 
	self.hud_plane_built_part4.alpha = 0;

	self.hud_plane_part5 = NewClientHudElem( self );
	self.hud_plane_part5 SetShader( "plane_rigging_logo", 32, 32 );
	self.hud_plane_part5.foreground = true; 
	self.hud_plane_part5.sort = 6; 
	self.hud_plane_part5.hidewheninmenu = true; 
	self.hud_plane_part5.horzAlign = "left"; 
	self.hud_plane_part5.vertAlign = "top";
	self.hud_plane_part5.x = 148; 
	self.hud_plane_part5.y = 40; 
	self.hud_plane_part5.alpha = 0;
	self.hud_plane_built_part5 = NewClientHudElem( self );
	self.hud_plane_built_part5 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_plane_built_part5.foreground = true; 
	self.hud_plane_built_part5.sort = 7; 
	self.hud_plane_built_part5.hidewheninmenu = true; 
	self.hud_plane_built_part5.horzAlign = "left"; 
	self.hud_plane_built_part5.vertAlign = "top";
	self.hud_plane_built_part5.x = 148; 
	self.hud_plane_built_part5.y = 40; 
	self.hud_plane_built_part5.alpha = 0;

	self.hud_plane_text = NewClientHudElem( self );
	self.hud_plane_text SetText("Plane Parts");
	self.hud_plane_text.foreground = true; 
	self.hud_plane_text.sort = 7; 
	self.hud_plane_text.hidewheninmenu = true; 
	self.hud_plane_text.horzAlign = "left"; 
	self.hud_plane_text.vertAlign = "top";
	self.hud_plane_text.fontscale = 1.5;
	self.hud_plane_text.x = 36; 
	self.hud_plane_text.y = 20; 
	self.hud_plane_text.alpha = 0;
	self.hud_plane_text.color = ( 1, 1, 1 );

   	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0.8;

	found_x = undefined;

	switch(part_name)
   	{
   		case "cloth":
   			found_x = 20;
   			break;
		case "fueltanks":
			found_x = 52;
   			break;
		case "engine":
			found_x = 84;
   			break;
   		case "steering":
			found_x = 116;
   			break;
   		case "rigging":
			found_x = 148;
   			break;
		default:
				found_x = -200;
			break;
   	}

	self.hud_plane_part_found = NewClientHudElem( self );
	if(isDefined(part_name))
		self.hud_plane_part_found SetShader( "hud_zom_found", 32, 32 );
	self.hud_plane_part_found.foreground = true; 
	self.hud_plane_part_found.sort = 8; 
	self.hud_plane_part_found.hidewheninmenu = true; 
	self.hud_plane_part_found.horzAlign = "left"; 
	self.hud_plane_part_found.vertAlign = "top";
	self.hud_plane_part_found.x = found_x; 
	self.hud_plane_part_found.y = 40; 
	self.hud_plane_part_found.alpha = 0;

	self.hud_plane_part1 FadeOverTime( 1 );
	if(part_name == "cloth" || level.plane_clothes)
	{
		self.hud_plane_part1.alpha = 1;
		level.plane_clothes = true;
	}
	else 
	{
		self.hud_plane_part1.alpha = 0.3;
	}
	if(level.plane_clothes_built)
	{
		self.hud_plane_built_part1.alpha = 1;
	}
	
	self.hud_plane_part2 FadeOverTime( 1 );
	if(part_name == "fueltanks" || level.plane_tanks)
	{
		self.hud_plane_part2.alpha = 1;
		level.plane_tanks = true;
	} 
	else 
	{
		self.hud_plane_part2.alpha = 0.3;
	}
	if(level.plane_tanks_built)
	{
		self.hud_plane_built_part2.alpha = 1;
	}

	self.hud_plane_part3 FadeOverTime( 1 );
	if(part_name == "engine" || level.plane_engine)
	{
		self.hud_plane_part3.alpha = 1;
		level.plane_engine = true;
	} 
	else 
	{
		self.hud_plane_part3.alpha = 0.3;
	}
	if(level.plane_engine_built)
	{
		self.hud_plane_built_part3.alpha = 1;
	}

	self.hud_plane_part4 FadeOverTime( 1 );
	if(part_name == "steering" || level.plane_control)
	{
		self.hud_plane_part4.alpha = 1;
		level.plane_control = true;
	} 
	else 
	{
		self.hud_plane_part4.alpha = 0.3;
	}
	if(level.plane_control_built)
	{
		self.hud_plane_built_part4.alpha = 1;
	}

	self.hud_plane_part5 FadeOverTime( 1 );
	if(part_name == "rigging" || level.plane_riggings)
	{
		self.hud_plane_part5.alpha = 1;
		level.plane_riggings = true;
	} 
	else 
	{
		self.hud_plane_part5.alpha = 0.3;
	}
	if(level.plane_riggings_built)
	{
		self.hud_plane_built_part5.alpha = 1;
	}

	self.hud_plane_text FadeOverTime( 1 );
	self.hud_plane_text.alpha = 1;

	wait 1.5;

	total_flash = 3;
	while(total_flash > 0)
	{
		self.hud_plane_part_found FadeOverTime( 0.75 );
		self.hud_plane_part_found.alpha = 1;

		wait 0.75;

		self.hud_plane_part_found FadeOverTime( 0.75 );
		self.hud_plane_part_found.alpha = 0;

		wait 0.75;
		total_flash--;
	}

	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0;

	self.hud_plane_part1 FadeOverTime( 1 );
	self.hud_plane_part1.alpha = 0;
	self.hud_plane_built_part1 FadeOverTime( 1 );
	self.hud_plane_built_part1.alpha = 0;

	self.hud_plane_part2 FadeOverTime( 1 );
	self.hud_plane_part2.alpha = 0;
	self.hud_plane_built_part2 FadeOverTime( 1 );
	self.hud_plane_built_part2.alpha = 0;

	self.hud_plane_part3 FadeOverTime( 1 );
	self.hud_plane_part3.alpha = 0;
	self.hud_plane_built_part3 FadeOverTime( 1 );
	self.hud_plane_built_part3.alpha = 0;

	self.hud_plane_part4 FadeOverTime( 1 );
	self.hud_plane_part4.alpha = 0;
	self.hud_plane_built_part4 FadeOverTime( 1 );
	self.hud_plane_built_part4.alpha = 0;

	self.hud_plane_part5 FadeOverTime( 1 );
	self.hud_plane_part5.alpha = 0;
	self.hud_plane_built_part5 FadeOverTime( 1 );
	self.hud_plane_built_part5.alpha = 0;

	self.hud_plane_text FadeOverTime( 1 );
	self.hud_plane_text.alpha = 0;

	wait 1;

	self.hud_background Destroy();
	self.hud_plane_part1 Destroy();
	self.hud_plane_part2 Destroy();
	self.hud_plane_part3 Destroy();
	self.hud_plane_part4 Destroy();
	self.hud_plane_part5 Destroy();
	self.hud_plane_built_part1 Destroy();
	self.hud_plane_built_part2 Destroy();
	self.hud_plane_built_part3 Destroy();
	self.hud_plane_built_part4 Destroy();
	self.hud_plane_built_part5 Destroy();
	self.hud_plane_text Destroy();
	self.hud_plane_part_found Destroy();

   	self.part_hud_showing = undefined;
}

function players_hud_fuel(part_name)
{
	players = GetPlayers();
	for(i=0; i < players.size; i++)
	{
		players[i] thread show_fuel_hud(part_name);
	}
}

function show_fuel_hud(part)
{
	while(isdefined(self.part_hud_showing) && self.part_hud_showing == true)
	{
		wait 0.5;
	}

	part_name = part.pieceName;

	self.part_hud_showing = true;

	self.hud_background = NewClientHudElem( self );
	self.hud_background SetShader( "hud_zom_bg_5", 160, 32 );
	self.hud_background.foreground = true; 
	self.hud_background.sort = 1; 
	self.hud_background.hidewheninmenu = true; 
	self.hud_background.horzAlign = "left"; 
	self.hud_background.vertAlign = "top";
	self.hud_background.x = 20; 
	self.hud_background.y = 40; 
	self.hud_background.alpha = 0.8;
	
	self.hud_fuel_part1 = NewClientHudElem( self );
	self.hud_fuel_part1 SetShader( "zom_hud_craftable_plane_gascan", 32, 32 );
	self.hud_fuel_part1.foreground = true; 
	self.hud_fuel_part1.sort = 2; 
	self.hud_fuel_part1.hidewheninmenu = true; 
	self.hud_fuel_part1.horzAlign = "left"; 
	self.hud_fuel_part1.vertAlign = "top";
	self.hud_fuel_part1.x = 20; 
	self.hud_fuel_part1.y = 40; 
	self.hud_fuel_part1.alpha = 0;
	self.hud_fuel_built_part1 = NewClientHudElem( self );
	self.hud_fuel_built_part1 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_fuel_built_part1.foreground = true; 
	self.hud_fuel_built_part1.sort = 3; 
	self.hud_fuel_built_part1.hidewheninmenu = true; 
	self.hud_fuel_built_part1.horzAlign = "left"; 
	self.hud_fuel_built_part1.vertAlign = "top";
	self.hud_fuel_built_part1.x = 20; 
	self.hud_fuel_built_part1.y = 40; 
	self.hud_fuel_built_part1.alpha = 0;

	self.hud_fuel_part2 = NewClientHudElem( self );
	self.hud_fuel_part2 SetShader( "zom_hud_craftable_plane_gascan", 32, 32 );
	self.hud_fuel_part2.foreground = true; 
	self.hud_fuel_part2.sort = 3; 
	self.hud_fuel_part2.hidewheninmenu = true; 
	self.hud_fuel_part2.horzAlign = "left"; 
	self.hud_fuel_part2.vertAlign = "top";
	self.hud_fuel_part2.x = 52; 
	self.hud_fuel_part2.y = 40; 
	self.hud_fuel_part2.alpha = 0;
	self.hud_fuel_built_part2 = NewClientHudElem( self );
	self.hud_fuel_built_part2 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_fuel_built_part2.foreground = true; 
	self.hud_fuel_built_part2.sort = 4; 
	self.hud_fuel_built_part2.hidewheninmenu = true; 
	self.hud_fuel_built_part2.horzAlign = "left"; 
	self.hud_fuel_built_part2.vertAlign = "top";
	self.hud_fuel_built_part2.x = 52; 
	self.hud_fuel_built_part2.y = 40; 
	self.hud_fuel_built_part2.alpha = 0;

	self.hud_fuel_part3 = NewClientHudElem( self );
	self.hud_fuel_part3 SetShader( "zom_hud_craftable_plane_gascan", 32, 32 );
	self.hud_fuel_part3.foreground = true; 
	self.hud_fuel_part3.sort = 4; 
	self.hud_fuel_part3.hidewheninmenu = true; 
	self.hud_fuel_part3.horzAlign = "left"; 
	self.hud_fuel_part3.vertAlign = "top";
	self.hud_fuel_part3.x = 84; 
	self.hud_fuel_part3.y = 40; 
	self.hud_fuel_part3.alpha = 0;
	self.hud_fuel_built_part3 = NewClientHudElem( self );
	self.hud_fuel_built_part3 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_fuel_built_part3.foreground = true; 
	self.hud_fuel_built_part3.sort = 5; 
	self.hud_fuel_built_part3.hidewheninmenu = true; 
	self.hud_fuel_built_part3.horzAlign = "left"; 
	self.hud_fuel_built_part3.vertAlign = "top";
	self.hud_fuel_built_part3.x = 84; 
	self.hud_fuel_built_part3.y = 40; 
	self.hud_fuel_built_part3.alpha = 0;

	self.hud_fuel_part4 = NewClientHudElem( self );
	self.hud_fuel_part4 SetShader( "zom_hud_craftable_plane_gascan", 32, 32 );
	self.hud_fuel_part4.foreground = true; 
	self.hud_fuel_part4.sort = 5; 
	self.hud_fuel_part4.hidewheninmenu = true; 
	self.hud_fuel_part4.horzAlign = "left"; 
	self.hud_fuel_part4.vertAlign = "top";
	self.hud_fuel_part4.x = 116; 
	self.hud_fuel_part4.y = 40; 
	self.hud_fuel_part4.alpha = 0;
	self.hud_fuel_built_part4 = NewClientHudElem( self );
	self.hud_fuel_built_part4 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_fuel_built_part4.foreground = true; 
	self.hud_fuel_built_part4.sort = 6; 
	self.hud_fuel_built_part4.hidewheninmenu = true; 
	self.hud_fuel_built_part4.horzAlign = "left"; 
	self.hud_fuel_built_part4.vertAlign = "top";
	self.hud_fuel_built_part4.x = 116; 
	self.hud_fuel_built_part4.y = 40; 
	self.hud_fuel_built_part4.alpha = 0;

	self.hud_fuel_part5 = NewClientHudElem( self );
	self.hud_fuel_part5 SetShader( "zom_hud_craftable_plane_gascan", 32, 32 );
	self.hud_fuel_part5.foreground = true; 
	self.hud_fuel_part5.sort = 6; 
	self.hud_fuel_part5.hidewheninmenu = true; 
	self.hud_fuel_part5.horzAlign = "left"; 
	self.hud_fuel_part5.vertAlign = "top";
	self.hud_fuel_part5.x = 148; 
	self.hud_fuel_part5.y = 40; 
	self.hud_fuel_part5.alpha = 0;
	self.hud_fuel_built_part5 = NewClientHudElem( self );
	self.hud_fuel_built_part5 SetShader( "hud_zombie_checkmark", 32, 32 );
	self.hud_fuel_built_part5.foreground = true; 
	self.hud_fuel_built_part5.sort = 7; 
	self.hud_fuel_built_part5.hidewheninmenu = true; 
	self.hud_fuel_built_part5.horzAlign = "left"; 
	self.hud_fuel_built_part5.vertAlign = "top";
	self.hud_fuel_built_part5.x = 148; 
	self.hud_fuel_built_part5.y = 40; 
	self.hud_fuel_built_part5.alpha = 0;

	self.hud_fuel_text = NewClientHudElem( self );
	self.hud_fuel_text SetText("Fuel Canisters");
	self.hud_fuel_text.foreground = true; 
	self.hud_fuel_text.sort = 7; 
	self.hud_fuel_text.fontscale = 1.5;
	self.hud_fuel_text.hidewheninmenu = true; 
	self.hud_fuel_text.horzAlign = "left"; 
	self.hud_fuel_text.vertAlign = "top";
	self.hud_fuel_text.x = 36; 
	self.hud_fuel_text.y = 20; 
	self.hud_fuel_text.alpha = 0;
	self.hud_fuel_text.color = ( 1, 1, 1 );

   	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0.8;

	found_x = undefined;

	switch(part_name)
   	{
   		case "fuel1":
   			found_x = 20;
   			break;
		case "fuel2":
			found_x = 52;
   			break;
		case "fuel3":
			found_x = 84;
   			break;
   		case "fuel4":
			found_x = 116;
   			break;
   		case "fuel5":
			found_x = 148;
   			break;
		default:
				found_x = -200;
			break;
   	}

	self.hud_fuel_part_found = NewClientHudElem( self );
	if(isdefined(part_name))
		self.hud_fuel_part_found SetShader( "hud_zom_found", 32, 32 );
	self.hud_fuel_part_found.foreground = true; 
	self.hud_fuel_part_found.sort = 8; 
	self.hud_fuel_part_found.hidewheninmenu = true; 
	self.hud_fuel_part_found.horzAlign = "left"; 
	self.hud_fuel_part_found.vertAlign = "top";
	self.hud_fuel_part_found.x = found_x; 
	self.hud_fuel_part_found.y = 40; 
	self.hud_fuel_part_found.alpha = 0;

	self.hud_fuel_part1 FadeOverTime( 1 );
	if(part_name == "fuel1" || level.plane_fuel_1)
	{
		self.hud_fuel_part1.alpha = 1;
		level.plane_fuel_1 = true;
	} else {
		self.hud_fuel_part1.alpha = 0.3;
	}
	if(level.plane_fuel1_built)
	{
		self.hud_fuel_built_part1.alpha = 1;
	}
	
	self.hud_fuel_part2 FadeOverTime( 1 );
	if(part_name == "fuel2" || level.plane_fuel_2)
	{
		self.hud_fuel_part2.alpha = 1;
		level.plane_fuel_2 = true;
	} else {
		self.hud_fuel_part2.alpha = 0.3;
	}
	if(level.plane_fuel2_built)
	{
		self.hud_fuel_built_part2.alpha = 1;
	}

	self.hud_fuel_part3 FadeOverTime( 1 );
	if(part_name == "fuel3" || level.plane_fuel_3)
	{
		self.hud_fuel_part3.alpha = 1;
		level.plane_fuel_3 = true;
	} else {
		self.hud_fuel_part3.alpha = 0.3;
	}
	if(level.plane_fuel3_built)
	{
		self.hud_fuel_built_part3.alpha = 1;
	}

	self.hud_fuel_part4 FadeOverTime( 1 );
	if(part_name == "fuel4" || level.plane_fuel_4)
	{
		self.hud_fuel_part4.alpha = 1;
		level.plane_fuel_4 = true;
	} else {
		self.hud_fuel_part4.alpha = 0.3;
	}
	if(level.plane_fuel4_built)
	{
		self.hud_fuel_built_part4.alpha = 1;
	}

	self.hud_fuel_part5 FadeOverTime( 1 );
	if(part_name == "fuel5" || level.plane_fuel_5)
	{
		self.hud_fuel_part5.alpha = 1;
		level.plane_fuel_5 = true;
	} else {
		self.hud_fuel_part5.alpha = 0.3;
	}
	if(level.plane_fuel5_built)
	{
		self.hud_fuel_built_part5.alpha = 1;
	}

	self.hud_fuel_text fadeOverTime( 1 );
	self.hud_fuel_text.alpha = 1;

	wait 1.5;

	total_flash = 3;
	while(total_flash > 0)
	{
		self.hud_fuel_part_found FadeOverTime( 0.75 );
		self.hud_fuel_part_found.alpha = 1;

		wait 0.75;

		self.hud_fuel_part_found FadeOverTime( 0.75 );
		self.hud_fuel_part_found.alpha = 0;

		wait 0.75;
		total_flash--;
	}

	self.hud_background FadeOverTime( 1 );
	self.hud_background.alpha = 0;

	self.hud_fuel_part1 FadeOverTime( 1 );
	self.hud_fuel_part1.alpha = 0;
	self.hud_fuel_built_part1 FadeOverTime( 1 );
	self.hud_fuel_built_part1.alpha = 0;

	self.hud_fuel_part2 FadeOverTime( 1 );
	self.hud_fuel_part2.alpha = 0;
	self.hud_fuel_built_part2 FadeOverTime( 1 );
	self.hud_fuel_built_part2.alpha = 0;

	self.hud_fuel_part3 FadeOverTime( 1 );
	self.hud_fuel_part3.alpha = 0;
	self.hud_fuel_built_part3 FadeOverTime( 1 );
	self.hud_fuel_built_part3.alpha = 0;

	self.hud_fuel_part4 FadeOverTime( 1 );
	self.hud_fuel_part4.alpha = 0;
	self.hud_fuel_built_part4 FadeOverTime( 1 );
	self.hud_fuel_built_part4.alpha = 0;

	self.hud_fuel_part5 FadeOverTime( 1 );
	self.hud_fuel_part5.alpha = 0;
	self.hud_fuel_built_part5 FadeOverTime( 1 );
	self.hud_fuel_built_part5.alpha = 0;

	self.hud_fuel_text FadeOverTime( 1 );
	self.hud_fuel_text.alpha = 0;

	wait 1;

	self.hud_background Destroy();
	self.hud_fuel_part1 Destroy();
	self.hud_fuel_part2 Destroy();
	self.hud_fuel_part3 Destroy();
	self.hud_fuel_part4 Destroy();
	self.hud_fuel_part5 Destroy();
	self.hud_fuel_built_part1 Destroy();
	self.hud_fuel_built_part2 Destroy();
	self.hud_fuel_built_part3 Destroy();
	self.hud_fuel_built_part4 Destroy();
	self.hud_fuel_built_part5 Destroy();
	self.hud_fuel_text Destroy();
	self.hud_fuel_part_found Destroy();

   	self.part_hud_showing = undefined;
}