/*#===================================================================###
###                                                                   ###
###                                                                   ###
###         	 Harry Bo21s Black Ops 3 Acidgat v1.0.0	  	          ###
###                                                                   ###
###                                                                   ###
###===================================================================#*/
/*=======================================================================

								CREDITS

=========================================================================
Lilrifa
Easyskanka
ProRevenge
DTZxPorter
Zeroy
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MZSlayer
AndyWhelen
HitmanVere
ProGamerzFTW
Scobalula
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
=======================================================================*/
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\system_shared;
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
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_net;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_blundersplat.gsh;

#namespace zm_weap_blundersplat; 

REGISTER_SYSTEM( "zm_weap_blundersplat", &__init__, undefined )

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{		
	callback::on_connect( &blundersplat_on_player_connect );
	
	zm_spawner::register_zombie_damage_callback( &blundersplat_zombie_wait_for_blundersplat_hit );	
}

function blundersplat_on_player_connect()
{
	self thread blundersplat_wait_for_blundersplat_fired();
}

function blundersplat_wait_for_blundersplat_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	for ( ;; )
	{
		self waittill( "weapon_fired", str_weapon );
		if ( str_weapon.name == BLUNDERSPLAT_WEAPONFILE || str_weapon.name == BLUNDERSPLAT_UPGRADED_WEAPONFILE )
		{
			self blundersplat_additional_fire( ( str_weapon.name == BLUNDERSPLAT_WEAPONFILE ) );
			self blundersplat_additional_fire( ( str_weapon.name == BLUNDERSPLAT_WEAPONFILE ) );
			self blundersplat_additional_fire( ( str_weapon.name == BLUNDERSPLAT_WEAPONFILE ) );
		}
	}
}

function blundersplat_additional_fire( is_not_upgraded )
{
	if ( !isDefined( is_not_upgraded ) )
		is_not_upgraded = 1;
	
	fire_angles = self getPlayerAngles();
	fire_origin = self getPlayerCameraPos();
	
	v_player_angles = vectorToAngles( self getWeaponForwardDir() );
	v_player_angles = blundersplat_randomize_angles( v_player_angles );
	v_shot_start = self getWeaponMuzzlePoint();
	
	a_targets = arrayCombine( getaiarray( "axis" ), getvehiclearray( "axis" ), 0, 0 );
	a_targets = util::get_array_of_closest( self.origin, a_targets, undefined, undefined, 1500 );
	if ( is_not_upgraded )
		n_fuse_timer = randomFloatRange( 1, 2.5 );
	else
		n_fuse_timer = randomFloatRange( 3, 4 );
	
	_a161 = a_targets;
	_k161 = getFirstArrayKey( _a161 );
	while ( isDefined( _k161 ) )
	{
		target = _a161[ _k161 ];
		if ( util::within_fov( v_shot_start, v_player_angles, target.origin, cos( 30 ) ) )
		{
			if ( isAi( target ) )
			{
				if ( !isDefined( target.blundersplat_marked ) )
				{
					a_tags = [];
					a_tags[ 0 ] = "j_hip_le";
					a_tags[ 1 ] = "j_hip_ri";
					a_tags[ 2 ] = "j_spine4";
					a_tags[ 3 ] = "j_elbow_le";
					a_tags[ 4 ] = "j_elbow_ri";
					a_tags[ 5 ] = "j_clavicle_le";
					a_tags[ 6 ] = "j_clavicle_ri";
					str_tag = a_tags[ randomInt( a_tags.size ) ];
					b_trace_pass = bulletTracePassed( v_shot_start, target gettagorigin( str_tag ), 1, self, target );
					if ( b_trace_pass )
					{
						target thread blundersplat_marked();
						e_dart = self magicMissile( getWeapon( BLUNDERSPLAT_PROJECTILE_WEAPONFILE ), v_shot_start, target getTagOrigin( str_tag ), self );
						e_dart thread blundersplat_reset_grenade_fuse( n_fuse_timer, is_not_upgraded );
						return;
					}
				}
			}
		}
		_k161 = getNextArrayKey( _a161, _k161 );
	}
	v_shot_end = v_shot_start + ( anglesToForward( v_player_angles ) * 20000 );

	e_dart = self magicMissile( getWeapon( BLUNDERSPLAT_PROJECTILE_WEAPONFILE ), v_shot_start, v_shot_end, self );
	e_dart thread blundersplat_reset_grenade_fuse( n_fuse_timer );
}

function blundersplat_waittill_still_or_bounce()
{
	self endon( "death" );
	self endon( "grenade_bounce" );
	prev_origin = self.origin;
	while ( 1 )
	{
		wait .05;
		if ( prev_origin == self.origin )
			break;
		
		prev_origin = self.origin;
	}
}

function blundersplat_reset_grenade_fuse( n_fuse_timer, is_not_upgraded )
{
	if ( !isDefined( is_not_upgraded ) )
		is_not_upgraded = 1;
	
	if ( !isDefined( n_fuse_timer ) )
		n_fuse_timer = randomfloatrange( 1, 1.5 );
	
	self blundersplat_waittill_still_or_bounce();
	a_grenades = getEntArray( "grenade", "classname" );
	_a375 = a_grenades;
	_k375 = getFirstArrayKey( _a375 );
	while ( isDefined( _k375 ) )
	{
		e_grenade = _a375[ _k375 ];
		if ( isDefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" && !isDefined( e_grenade.fuse_reset ) )
		{
			e_grenade.fuse_reset = 1;
			e_grenade.fuse_time = n_fuse_timer;
			e_grenade resetMissileDetonationTime( n_fuse_timer );
			if ( is_not_upgraded )
				e_grenade zm_utility::create_zombie_point_of_interest( 250, 5, 10000 );
			else
				e_grenade zm_utility::create_zombie_point_of_interest( 500, 10, 10000 );
			
			return;
		}
		_k375 = getNextArrayKey( _a375, _k375 );
	}
}

function blundersplat_zombie_wait_for_blundersplat_hit()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( weaponname.name == BLUNDERSPLAT_PROJECTILE_WEAPONFILE )
		{
			if ( !isDefined( self.blundersplat_tagged ) )
			{
				a_grenades = getentarray( "grenade", "classname" );
				if ( !isDefined( a_grenades ) || a_grenades.size <= 0 )
					continue;
				
				self.blundersplat_tagged = 1;
				_a66 = a_grenades;
				_k66 = getFirstArrayKey( _a66 );
				while ( isDefined( _k66 ) )
				{
					e_grenade = _a66[ _k66 ];
					if ( isDefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" )
					{
						if ( e_grenade islinkedto( self ) )
						{
							// while ( !isDefined( e_grenade.fuse_time ) )
							// 	wait .05;
							
							e_grenade.fuse_time = 3;
							n_fuse_timer = e_grenade.fuse_time;
							e_grenade thread blundersplat_grenade_detonate_on_target_death( self );
						}
					}
					_k66 = getNextArrayKey( _a66, _k66 );
				}
				self thread blundersplat_target_animate_and_die( n_fuse_timer, inflictor );
				self thread blundersplat_target_check_for_grenade_hits();
			}
		}
	}
}

function blundersplat_target_check_for_grenade_hits()
{
	self endon( "death" );
	self endon( "blundersplat_target_timeout" );
	while ( 1 )
	{
		self waittill( "damage", amount, inflictor, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( weaponname.name == BLUNDERSPLAT_PROJECTILE_WEAPONFILE )
		{
			a_grenades = getEntArray( "grenade", "classname" );
			_a317 = a_grenades;
			_k317 = getFirstArrayKey( _a317 );
			while ( isDefined( _k317 ) )
			{
				e_grenade = _a317[ _k317 ];
				if ( isDefined( e_grenade.model ) && e_grenade.model == "t6_wpn_zmb_projectile_blundergat" )
				{
					if ( e_grenade islinkedto( self ) )
						e_grenade thread blundersplat_grenade_detonate_on_target_death( self );
					
				}
				_k317 = getNextArrayKey( _a317, _k317 );
			}
		}
	}
}

function blundersplat_marked()
{
	self endon( "death" );
	self.blundersplat_marked = 1;
	wait 1;
	self.blundersplat_marked = undefined;
}

function blundersplat_grenade_detonate_on_target_death( target )
{
	self endon( "death" );
	target endon( "blundersplat_target_timeout" );
	target waittill( "blundersplat_target_killed" );
	self.fuse_reset = 1;
	self resetMissileDetonationTime( .05 );
}

function blundersplat_target_animate_and_die( n_fuse_timer, inflictor )
{
	self endon( "death" );
	self endon( "blundersplat_target_timeout" );
	self thread blundersplat_target_timeout( n_fuse_timer );
	self thread blundersplat_check_for_target_death( inflictor );
	self thread blundersplat_target_acid_stun_anim();
	wait n_fuse_timer;
	self notify( "killed_by_a_blundersplat" );
	self dodamage( self.health + 1000, self.origin );
}

function blundersplat_target_timeout( n_fuse_timer )
{
	self endon( "death" );
	wait n_fuse_timer;
	self notify( "blundersplat_target_timeout" );
}

function blundersplat_check_for_target_death( inflictor )
{
	self waittill( "death" );
	self notify( "killed_by_a_blundersplat" );
	self notify( "blundersplat_target_killed" );
}

function blundersplat_randomize_angles( angles )
{
	n_x = angles[ 0 ] - 5 + randomInt( 5 );
	n_y = angles[ 1 ] - 5 + randomInt( 5 );
	n_z = angles[ 2 ] - 5 + randomInt( 5 );
	return ( n_x, n_y, n_z );
}

function blundersplat_target_acid_stun_anim()
{
	self endon( "death" );
	while ( 1 )
	{
		ground_ent = self getGroundEnt();
		if ( isDefined( ground_ent ) && !IS_TRUE( ground_ent.classname == "worldspawn" ) )
			self linkTo( ground_ent );
		
		if ( !IS_TRUE( self.missingLegs ) )
		{
			int = randomInt( 5 );
			switch ( int )
			{
				case 0:
					anim_to_play = "ai_zombie_acid_stun_a";
				case 1:
					anim_to_play = "ai_zombie_acid_stun_b";
				case 2:
					anim_to_play = "ai_zombie_acid_stun_c";
				case 3:
					anim_to_play = "ai_zombie_acid_stun_d";
				case 4:
					anim_to_play = "ai_zombie_acid_stun_e";
					
			}
			self animation::play( anim_to_play );
			wait getAnimLength( anim_to_play );
		}
		wait .05;
	}
}