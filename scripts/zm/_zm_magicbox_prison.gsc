#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_bb;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_daily_challenges;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_magicbox;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "xmodel", "p6_anim_zm_al_magic_box_lock_red" );
#precache( "fx", "custom/jerri/al_box/al_box_initial" ); 
#precache( "fx", "custom/jerri/al_box/al_box_idle" ); 
#precache( "fx", "custom/jerri/al_box/al_box_fire" );

function autoexec init()
{
	clientfield::register( "zbarrier", "magicbox_initial_fx_new", VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "magicbox_amb_fx", VERSION_SHIP, 2, "int" );
	clientfield::register( "zbarrier", "magicbox_open_fx_new", VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "magicbox_leaving_fx", VERSION_SHIP, 1, "int" );

	level._effect[ "lght_marker" ] = "custom/jerri/al_box/al_box_ray";
	//level._effect[ "lght_marker_flare" ] = "maps/zombie_alcatraz/fx_zmb_tranzit_marker_fl";
	level._effect[ "poltergeist" ] = "system_elements/fx_null";
	level._effect[ "box_gone_ambient" ] = "custom/jerri/al_box/al_box_idle";
	level._effect[ "box_here_ambient" ] = "custom/jerri/al_box/al_box_fire";
	level._effect[ "box_is_open" ] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_open";
	level._effect[ "box_is_locked" ] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_lock";
	level._effect[ "box_is_leaving" ] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_leave";
	level.using_locked_magicbox = 1;
	level.chest_joker_model = "p6_anim_zm_al_magic_box_lock_red";
	level.chest_joker_custom_movement = &custom_joker_movement;
	level.magic_box_zbarrier_state_func = &set_magic_box_zbarrier_state;
	level thread wait_then_create_base_magic_box_fx();
	level thread handle_fire_sale();
	level flag::wait_till( "initial_blackscreen_passed" );
	/*foreach(player in GetPlayers())
	{
		player.score = 100000;
	}*/
}

function custom_joker_movement()
{
	v_origin = self.weapon_model.origin - VectorScale( ( 0, 1, 0 ), 5 );
	self.weapon_model Delete();
	m_lock = Spawn( "script_model", v_origin );
	m_lock SetModel( level.chest_joker_model );
	m_lock.angles = self.angles + VectorScale( ( 0, 1, 0 ), 180 );
	wait 0.5;
	level notify( "weapon_fly_away_start" );
	wait 1;
	m_lock RotateYaw( 3000, 4, 4 );
	wait 3;
	m_lock MoveZ( 20, 0.5, 0.5 );
	m_lock waittill( "movedone" );
	m_lock MoveZ( -100, 0.5, 0.5 );
	m_lock waittill( "movedone" );
	m_lock Delete();
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

function wait_then_create_base_magic_box_fx()
{
	while ( !isdefined( level.chests ) )
	{
		wait 0.1;
	}
	while ( !isdefined( level.chests[ level.chests.size - 1 ].zbarrier ) )
	{
		wait 0.1;
	}
	foreach(chest in level.chests)
	{
		chest.zbarrier clientfield::set( "magicbox_initial_fx_new", 1 );
	}
}

function set_magic_box_zbarrier_state( state )
{
	i = 0;
	while ( i < self GetNumZBarrierPieces() )
	{
		self HideZBarrierPiece( i );
		i++;
	}
	self notify( "zbarrier_state_change" );
	switch( state )
	{
		case "away":
			self ShowZBarrierPiece( 0 );
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		case "arriving":
			self ShowZBarrierPiece( 1 );
			self thread magic_box_arrives();
			self.state = "arriving";
			break;
		case "initial":
			self ShowZBarrierPiece( 1 );
			self thread magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
			self.state = "close";
			break;
		case "open":
			self ShowZBarrierPiece( 2 );
			self thread magic_box_opens();
			self.state = "open";
			break;
		case "close":
			self ShowZBarrierPiece( 2 );
			self thread magic_box_closes();
			self.state = "close";
			break;
		case "leaving":
			self ShowZBarrierPiece( 1 );
			self thread magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
			break;
		default:
			if ( isdefined( level.custom_magicbox_state_handler ) )
			{
				self [[ level.custom_magicbox_state_handler ]]( state );
			}
			break;
	}
}

function magic_box_initial()
{
	self SetZBarrierPieceState( 1, "open" );
	wait 1;
	self clientfield::set( "magicbox_amb_fx", 1 );
}

function magic_box_arrives()
{
	self clientfield::set( "magicbox_leaving_fx", 0 );
	self clientfield::set( "magicbox_amb_fx", 1 );
	self SetZBarrierPieceState( 1, "opening" );
	while ( self GetZBarrierPieceState( 1 ) == "opening" )
	{
		wait 0.05;
	}
	self notify( "arrived" );
	self.state = "close";
}

function magic_box_leaves()
{
	self clientfield::set( "magicbox_leaving_fx", 1 );
	self clientfield::set( "magicbox_open_fx_new", 0 );
	self SetZBarrierPieceState( 1, "closing" );
	self PlaySound( "zmb_hellbox_rise" );
	while ( self GetZBarrierPieceState( 1 ) == "closing" )
	{
		wait 0.1;
	}
	self notify( "left" );
	self clientfield::set( "magicbox_amb_fx", 0 );
}

function magic_box_opens()
{
	self clientfield::set( "magicbox_open_fx_new", 1 );
	self SetZBarrierPieceState( 2, "opening" );
	self PlaySound( "zmb_hellbox_open" );
	while ( self GetZBarrierPieceState( 2 ) == "opening" )
	{
		wait 0.1;
	}
	self notify( "opened" );
}

function magic_box_closes()
{
	self SetZBarrierPieceState( 2, "closing" );
	self PlaySound( "zmb_hellbox_close" );
	while ( self GetZBarrierPieceState( 2 ) == "closing" )
	{
		wait 0.1;
	}
	self notify( "closed" );
	self clientfield::set( "magicbox_open_fx_new", 0 );
}

function magic_box_do_weapon_rise()
{
	self endon( "box_hacked_respin" );
	self SetZBarrierPieceState( 3, "closed" );
	self SetZBarrierPieceState( 4, "closed" );
	util::wait_network_frame();
	self ZBarrierPieceUseBoxRiseLogic( 3 );
	self ZBarrierPieceUseBoxRiseLogic( 4 );
	self ShowZBarrierPiece( 3 );
	self ShowZBarrierPiece( 4 );
	self SetZBarrierPieceState( 3, "opening" );
	self SetZBarrierPieceState( 4, "opening" );
	while ( self GetZBarrierPieceState( 3 ) != "open" )
	{
		wait 0.5;
	}
	self HideZBarrierPiece( 3 );
	self HideZBarrierPiece( 4 );
}

function handle_fire_sale()
{
	while ( 1 )
	{
		level waittill( "fire_sale_off" );
		i = 0;
		while ( i < level.chests.size )
		{
			if ( level.chest_index != i && isdefined( level.chests[ i ].was_temp ) )
			{
				level.chests[ i ].zbarrier clientfield::set( "magicbox_amb_fx", 0 );
			}
			i++;
		}
	}
}
