
#using scripts\zm\_zm_score;
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\laststand_shared;
#insert scripts\zm\_zm_laststand.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#define N_SPLAT_PULSE_DAMAGE_MAX		5000
#define N_SPLAT_PULSE_DAMAGE_MIN		2500

#precache( "fx", "custom/jerri/acidgat/explosion" );

function autoexec init()
{
	level._effect["acid_exp"] = "custom/jerri/acidgat/explosion";
	callback::on_connect( &blundergat_player_connect );
}

function blundergat_player_connect()
{
	self thread wait_for_blundersplat_fired();
	self thread wait_for_blundersplat_upgraded_fired();
}

function wait_for_blundersplat_fired()
{
	self endon("disconnect");
	while(1)
	{
		self waittill( "weapon_fired");
		wanted_gun = GetWeapon("bo2_acidgat");
		currentgun = self GetCurrentWeapon();
		if(currentgun == wanted_gun)
		{
			thread blundergat_fired(false , 2);
			util::wait_network_frame();
			thread blundergat_fired(false , 2);
			util::wait_network_frame();
			thread blundergat_fired(false , 2);
			wait 1;
		}
		util::wait_network_frame();
	}
}

function wait_for_blundersplat_upgraded_fired()
{
	self endon("disconnect");
	while(1)
	{
		self waittill( "weapon_fired");
		wanted_gun = GetWeapon("bo2_acidgat_upgraded");
		currentgun = self GetCurrentWeapon();
		if(currentgun == wanted_gun)
		{
			self thread blundergat_fired(true , 5);
			util::wait_network_frame();
			self thread blundergat_fired(true , 5); 
			util::wait_network_frame();
			self thread blundergat_fired(true , 5);
			wait 1;
		}
		util::wait_network_frame();
	}
}

function blundergat_fired(is_upgraded,duration)
{
	radius = 200;
	radius_crawl = 300;

	forward = self GetEye(); 
	vec = AnglesToForward(self GetPlayerAngles());
	end = (vec[0] * 100000000, vec[1] * 100000000, vec[2] * 100000000); 
	acid_trace = BulletTrace( forward, end, 0, self )[ "position" ];

	acidfx = spawn("script_model", acid_trace + (0,0,0)); 
	acidfx SetModel("acidgat_projectile"); 
	acidfx.angles = (90,0,0); 

	
	acidfx zm_utility::create_zombie_point_of_interest( 1536, 96, 10000 );

	self thread stick_acid(acidfx);

	acidfx.attract_to_origin = true;
	
	wait duration;

	random = randomintrange(0, 4); 
	playsoundatposition ("explo_0"+random, acidfx.origin);

	acidfx.attract_to_origin = false;

	PlayFX( level._effect[ "acid_exp" ], acidfx.origin );

	Earthquake( 0.5, 3, acidfx.origin, 350 );

	acidfx hide();

	a_ai_targets = GetAITeamArray( "axis" );
		
	foreach( ai_target in a_ai_targets )
	{
		if ( isdefined( ai_target ) ) 
		{
			n_distance_to_target = Distance( ai_target.origin, acidfx.origin );
			if(isdefined(ai_target.is_brutus) && ai_target.is_brutus)
			{
				continue;
			}
			if ( n_distance_to_target > radius )
			{
				continue;
			}
			ai_target DoDamage( ai_target.health + 666, ai_target.origin );
			ai_target notify("killed_by_a_blundersplat");
			self zm_score::add_to_player_score(50);
		}
	}
	owndistance = Distance(self.origin, acidfx.origin);
	if ( owndistance < radius)
	{
		self DoDamage (self.health - 30 , self.origin);
	}
	wait 3;
	acidfx delete();
}

function stick_acid(acidfx)
{
	zombs = GetAITeamArray( "axis" );
	for(k=0;k<zombs.size;k++)
	{
		if(self IsLookingAt(zombs[k]) )
		{
			rand = randomint(17);
			tag = undefined;
			if(rand == 0 )
			{
				tag = "J_SpineLower";
			}
			else if(rand == 1 )
			{
				tag = "J_Spine4";
			}
			else if(rand == 2 )
			{
				tag = "J_SpineUpper";
			}
			else if(rand == 3 )
			{
				tag = "J_SpineLower";
			}
			else if(rand == 4 )
			{
				tag = "J_Shoulder_LE";
			}
			else if(rand == 5 )
			{
				tag = "J_Elbow_LE";
			}
			else if(rand == 6 )
			{
				tag = "J_Wrist_LE";
			}
			else if(rand == 7 )
			{
				tag = "J_Shoulder_RI";
			}
			else if(rand == 8 )
			{
				tag = "J_Elbow_RI";
			}
			else if(rand == 9 )
			{
				tag = "J_Wrist_RI";
			}
			else if(rand == 10 )
			{
				tag = "J_Wrist_RI";
			}
			else if(rand == 11 )
			{
				tag = "J_Hip_LE";
			}
			else if(rand == 12 )
			{
				tag = "J_Knee_LE";
			}
			else if(rand == 13 )
			{
				tag = "J_Ankle_LE";
			}
			else if(rand == 14 )
			{
				tag = "J_Ankle_RI";
			}
			else if(rand == 15 )
			{
				tag = "j_neck";
			}
			else if(rand == 16 )
			{
				tag = "j_head";
			}

			acidfx.origin = zombs[k] GetTagOrigin(tag);
			acidfx.angles = zombs[k] GetTagOrigin(tag);
			acidfx LinkTo(zombs[k], "j_spine4");
		}
	}
}