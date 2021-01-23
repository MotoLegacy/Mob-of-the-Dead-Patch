#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\spawner_shared;
#using scripts\shared\scene_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_zonemgr;

#using scripts\zm\zm_alcatraz_utility;
#using scripts\zm\zm_alcatraz_amb;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using_animtree( "generic" );  

#precache( "model", "p6_zm_al_dream_catcher" );
#precache( "model", "p6_zm_al_dream_catcher_on" );
#precache( "model", "c_zom_zombie_mask_head" );

#precache("fx", "custom/jerri/al_wolfs/soul_charge_start");
#precache("fx", "custom/jerri/al_wolfs/soul_charged");
#precache("fx", "custom/jerri/al_wolfs/hell_portal");
#precache("fx", "custom/jerri/al_wolfs/wolf_bite_blood");

function autoexec init()
{
	level flag::init( "soul_catchers_charged" );
	callback::on_connect( &toggle_redeemer_trigger );
	callback::on_connect( &hellhole_projectile_watch );
	callback::on_connect( &hellhole_tomahawk_watch );
	level.soul_catchers = [];
	level.soul_catchers_vol = [];
	level._effect["soul_charge_start"]	= "custom/jerri/al_wolfs/soul_charge_start";
	level._effect["soul_charged"]	= "custom/jerri/al_wolfs/soul_charged";
	level._effect["hell_portal"]	= "custom/jerri/al_wolfs/hell_portal";
	level._effect["wolf_bite_blood"]	= "custom/jerri/al_wolfs/wolf_bite_blood";
	level.a_wolf_structs = GetEntArray( "wolf_position", "targetname" );
	i = 0;
	while ( i < level.a_wolf_structs.size )
	{
		level.soul_catchers[ i ] = level.a_wolf_structs[ i ];
		level.soul_catchers_vol[ i ] = GetEnt( level.soul_catchers[ i ].target, "targetname" );
		level.wolf_heads[ i ] = GetEnt( level.soul_catchers[ i ].script_label, "targetname" );
		level.wolf_heads[ i ] UseAnimTree(#animtree);
		level.wolf_heads[ i ] Hide();
		level.soul_catchers[ i ].head = level.wolf_heads[ i ];
		level.soul_catchers[ i ].wolf_kill_cooldown = 0;
		level.wolf_bodies[ i ] = GetEnt( level.soul_catchers[ i ].script_friendname, "targetname" );
		level.wolf_bodies[ i ] UseAnimTree(#animtree);
		level.wolf_bodies[ i ] SetModel("tag_origin");
		level.wolf_bodies[ i ] Hide();
		level.soul_catchers[ i ].body = level.wolf_bodies[ i ];
		level.wolf_runes[ i ] = GetEnt(  level.soul_catchers[i].script_noteworthy, "targetname" );
		level.soul_catchers[ i ].rune = level.wolf_runes[ i ];
		i++;
	}
	level flag::wait_till( "all_players_connected" );
	level.no_gib_in_wolf_area = &check_for_zombie_in_wolf_area;
	level.soul_catcher_clip[ "rune_2" ] = GetEnt( "wolf_clip_docks", "targetname" );
	level.soul_catcher_clip[ "rune_3" ] = GetEnt( "wolf_clip_infirmary", "targetname" );
	_a24 = level.soul_catcher_clip;
	_k24 = GetFirstArrayKey( _a24 );
	while ( isdefined( _k24 ) )
	{
		e_clip = _a24[ _k24 ];
		e_clip SetInvisibleToAll();
		e_clip ConnectPaths();
		_k24 = GetNextArrayKey( _a24, _k24 );
	}
	level thread create_anim_references_on_server();
	
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		level.soul_catchers[ i ].souls_received = 0;
		level.soul_catchers[ i ].is_eating = 0;
		level.soul_catchers[ i ] thread soul_catcher_check();
		if ( zm_utility::is_classic() )
		{
			level.soul_catchers[ i ] thread soul_catcher_state_manager( i );
		}
		else
		{
			level.soul_catchers[ i ] thread grief_soul_catcher_state_manager( i );
		}
		level.soul_catchers[ i ] thread wolf_head_removal( "tomahawk_door_sign_" + ( i + 1 ) );
		level.soul_catchers_vol[ i ] = GetEnt( level.soul_catchers[ i ].target, "targetname" );
		i++;
	}
	level.soul_catchers_charged = 0;
	level thread soul_catchers_charged();
	level thread get_the_zoms();
}

function create_anim_references_on_server()
{
	root = %root;
	wolfhead_intro_anim = %o_zombie_dreamcatcher_intro;
	wolfhead_outtro_anim = %o_zombie_dreamcatcher_outtro;
	woflhead_idle_anims = [];
	wolfhead_idle_anim[ 0 ] = %o_zombie_dreamcatcher_idle;
	wolfhead_idle_anim[ 1 ] = %o_zombie_dreamcatcher_idle_twitch_scan;
	wolfhead_idle_anim[ 2 ] = %o_zombie_dreamcatcher_idle_twitch_shake;
	wolfhead_idle_anim[ 3 ] = %o_zombie_dreamcatcher_idle_twitch_yawn;
	wolfhead_body_death = %ai_zombie_dreamcatch_impact;
	wolfhead_body_float = %ai_zombie_dreamcatch_rise;
	wolfhead_body_shrink = %ai_zombie_dreamcatch_shrink_a;
	level.wolfhead_pre_eat_anims = [];
	level.wolfhead_pre_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_r;
	level.wolfhead_pre_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_l;
	level.wolfhead_pre_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_f;
	level.wolfhead_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_align_r;
	level.wolfhead_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_align_l;
	level.wolfhead_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_align_f;
	level.wolfhead_body_anims[ "right" ] = %ai_zombie_dreamcatcher_wallconsume_align_r;
	level.wolfhead_body_anims[ "left" ] = %ai_zombie_dreamcatcher_wallconsume_align_l;
	level.wolfhead_body_anims[ "front" ] = %ai_zombie_dreamcatcher_wallconsume_align_f;
}

function soul_catcher_state_manager (index)
{
	wait 1;
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Hide();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Hide();
		}
	}
	level thread wolf_state_0(index);
	self waittill( "first_zombie_killed_in_zone" );
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Show();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Show();
		}
	}
	if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] SetVisibleToAll();
		level.soul_catcher_clip[ self.script_noteworthy ] DisconnectPaths();
	}
	level thread wolf_state_1(index);
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	self waittill( "finished_eating" );
	while ( !self.is_charged )
	{
		level thread wolf_state_2(index);
		self waittill( "finished_eating" );
		//IPrintLnBold("finished_eating or fully_charged");
	}
	//IPrintLnBold("filling done");
	level thread wolf_state_6(index);
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_outtro );
	wait anim_length;
	if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] Delete();
		level.soul_catcher_clip[ self.script_noteworthy ] ConnectPaths();
	}
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Delete();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Delete();
		}
	}
	level thread wolf_state_7(index);
}

function wolf_state_0(index)
{
	rune = level.wolf_runes[index];
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	//level.wolf_heads[index].portal_fx = Spawn("script_model", ( rune.origin - rune_forward * 2.5 ) - rune_up * 24 );
	//level.wolf_heads[index].portal_fx SetModel("tag_origin");
	//PlayFXOnTag(level._effect["hell_portal"],level.wolf_heads[index].portal_fx, "tag_origin" );
	//level.wolf_heads[index].portal_fx = PlayFX( level._effect["hell_portal"], ( rune.origin - rune_forward * 2.5 ) - rune_up * 24, rune_forward, rune_up );
	level.wolf_heads[index] Hide();
	level.wolf_runes[ index ] Show();
	level.wolf_bodies[index] Hide();
}

function wolf_state_1(index)
{
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Hide();
	level.wolf_bodies[index] Hide();
	level.wolf_heads[index] thread wolfhead_arrive(  level.wolf_runes[index] );
}

function wolfhead_arrive( rune )
{
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	rune.portal_fx = Spawn("script_model", rune.origin + (0,0,10) );
	rune.portal_fx SetModel("tag_origin");
	rune.portal_fx.angles = rune.angles + (0,90,0);
	PlayFXOnTag(level._effect["hell_portal"],rune.portal_fx, "tag_origin" );
	//self.portal_fx = PlayFX(  level._effect["hell_portal"],  ( rune.origin - rune_forward * 2.5 ) - rune_up * 24, rune_forward, rune_up  );
	self PlaySound(  "evt_wolfhead_spawn" );
	self.wolf_ent = Spawn( "script_origin", self.origin );
	self.wolf_ent PlayLoopSound( "evt_wolfhead_fire_loop" );
	n_anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	self AnimScripted( "notify", self.origin, self.angles, %o_zombie_dreamcatcher_intro, "normal", %o_zombie_dreamcatcher_intro, 1, 0.3 );
	//self AnimScripted( "notify" , self.origin , self.angles, %o_zombie_dreamcatcher_intro );
	wait n_anim_length;
}

function wolf_state_2( index )
{
	//IPrintLnBold("wolf_state_2");
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Hide();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_heads[index] thread wolfhead_idle();
}

function wolfhead_idle()
{
	self endon( "wolf_eating" );
	self endon( "wolf_departing" );
	self notify( "wolf_idling" );
	//IPrintLnBold("wolf_idling");
	level.wolf_head_idle_anims = [];
	level.wolf_head_idle_anims[0] = %o_zombie_dreamcatcher_idle;
	level.wolf_head_twitch_anims = [];
	level.wolf_head_twitch_anims[0] = %o_zombie_dreamcatcher_idle_twitch_scan;
	level.wolf_head_twitch_anims[1] = %o_zombie_dreamcatcher_idle_twitch_shake;
	level.wolf_head_twitch_anims[2] = %o_zombie_dreamcatcher_idle_twitch_yawn;
	while(1)
	{
		random_idle_anim = array::random( level.wolf_head_idle_anims );
		n_anim_length = GetAnimLength( random_idle_anim );
		self AnimScripted( "notify", self.origin, self.angles, random_idle_anim, "normal", random_idle_anim, 1, 0.3 );
		//self AnimScripted( "notify" , self.origin , self.angles, random_idle_anim );
		wait n_anim_length;
		random_twitch_anim = array::random( level.wolf_head_twitch_anims );
		n_anim_length = GetAnimLength( random_twitch_anim );
		self AnimScripted( "notify", self.origin, self.angles, random_twitch_anim, "normal", random_twitch_anim, 1, 0.3 );
		//self AnimScripted( "notify" , self.origin , self.angles, random_twitch_anim );
		wait n_anim_length;
	}
}

function wolf_state_6(index)
{
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Show();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_runes[index] StopLoopSound();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_heads[index] thread wolfhead_depart( level.wolf_runes[index] );
}

function wolfhead_depart( rune )
{
	self AnimScripted( "notify", self.origin, self.angles, %o_zombie_dreamcatcher_outtro, "normal", %o_zombie_dreamcatcher_outtro, 1, 0.3 );
	//self AnimScripted( "notify" , self.origin , self.angles, %o_zombie_dreamcatcher_outtro );
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	rune.portal_fx Delete();
	self.portal_fx = PlayFX( level._effect["hell_portal_close"], ( rune.origin - rune_forward * 2.5 ) - rune_up * 24, rune_forward, rune_up);
	self PlaySound( "evt_wolfhead_depart" );
	self.wolf_ent StopLoopSound();
	self.wolf_ent Delete();
	self notify( "wolf_departing" );
}

function wolf_state_7(index)
{
	level.wolf_heads[index] Hide();
	level.wolf_runes[index] Show();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_runes[index] SetModel( "p6_zm_al_dream_catcher_on" );
	PlayFXOnTag(  level._effect["soul_charged"], level.wolf_runes[index], "tag_origin" );
	level.wolf_runes[index] PlayLoopSound( "evt_runeglow_loop" );
}

function wolf_state_eat(index , n_eating_anim ,zombie)
{
	if( n_eating_anim == 3)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "front", index );
	}
	if( n_eating_anim == 4)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "right", index );
	}
	if( n_eating_anim == 5)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "left", index );
	}
}

function wolfhead_eat_aligned( zombie ,direction, index )
{
	self endon( "wolf_idling" );
	self endon( "wolf_departing" );
	self notify( "wolf_eating" );
	level.wolf_bodies[ index ] EnableLinkTo();
	zombie EnableLinkTo();
	zombie LinkTo(level.wolf_bodies[ index ]);
	self wolfhead_pre_eat_aligned( zombie,  direction );
	level.wolf_bodies[ index ].origin = self GetTagOrigin( "tag_mouth_fx" );
	level.wolf_bodies[ index ].angles = self GetTagAngles( "tag_mouth_fx" );
	zombie.angles = self GetTagAngles( "tag_mouth_fx" );
	level.wolf_bodies[ index ] LinkTo( self, "tag_mouth_fx", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	n_anim_length = GetAnimLength( level.wolfhead_eat_anims[direction] );
	
	//self thread play_blood_fx_on_bite();
	self AnimScripted( "notify", self.origin, self.angles, level.wolfhead_eat_anims[direction], "normal", level.wolfhead_eat_anims[direction], 1, 0.3 ); 
	//self AnimScripted( "notify" , self.origin , self.angles, level.wolfhead_eat_anims[direction] );
	//zombie AnimScripted( "notify", zombie.origin, zombie.angles, level.wolfhead_body_anims[direction], "normal", level.wolfhead_body_anims[direction], 1, 0.3 ); 
	zombie AnimScripted( "notify" , zombie.origin , zombie.angles, level.wolfhead_body_anims[direction] );
	wait n_anim_length;
	self PlaySound( "evt_wolfhead_eat" );
	self Unlink();
	zombie Delete();
	level.wolf_bodies[ index ] Unlink();
}

function wolfhead_pre_eat_aligned( zombie, direction )
{
	s_closest = util::get_array_of_closest( self.origin, level.a_wolf_structs );
	m_body = s_closest[0].body;
	m_wolf = s_closest[0].head;
	m_wolf AnimScripted( "notify", m_wolf.origin, m_wolf.angles, level.wolfhead_pre_eat_anims[direction], "normal", level.wolfhead_pre_eat_anims[direction], 1, 0.3 );
	//m_wolf AnimScripted( "notify" , m_wolf.origin , m_wolf.angles, level.wolfhead_pre_eat_anims[direction] );
	m_body Unlink();
	m_body Show();
	m_body body_moveto_wolf( m_wolf, zombie );
}

function play_blood_fx_on_bite(  )
{
	self waittill( "bite", note );
	//PlayFXOnTag(  level._effect["soul_charge_impact"], self, "TAG_MOUTH_FX" );
	//PlayFXOnTag( level._effect["wolf_bite_blood"], self, "TAG_MOUTH_FX" );
}

function body_moveto_wolf( m_wolf, zombie )
{
	self.m_soul_fx_player = Spawn(  self GetTagOrigin( "J_SpineLower" ), "script_model" );
	self.m_soul_fx_player SetModel( "tag_origin" );
	//zombie AnimScripted( "notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_rise, "normal", %ai_zombie_dreamcatch_rise, 1, 0.3 );
	zombie AnimScripted( "notify" , zombie.origin , zombie.angles, %ai_zombie_dreamcatch_rise );
	vec_dir = m_wolf.origin - self.origin;
	vec_dir_scaled = VectorScale( vec_dir, 0.2 );
	self.m_soul_fx_player.angles = VectortoAngles( vec_dir );
	self.m_soul_fx_player LinkTo( self );
	PlayFXOnTag(  level._effect["soul_charge_start"], self, "tag_origin" );
	self PlaySound( "evt_soulsuck_body" );
	self MoveTo( self.origin + vec_dir_scaled, 1.5, 1.5 );
	self waittill( "movedone" );
	zombie.angles = self.angles;
	//zombie AnimScripted( "notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_shrink_a, "normal", %ai_zombie_dreamcatch_shrink_a, 1, 0.3 );
	zombie AnimScripted( "notify" , zombie.origin , zombie.angles, %ai_zombie_dreamcatch_shrink_a );
	zombie_move_offset = AnglesToForward( m_wolf.angles ) * 36 + AnglesToUp( m_wolf.angles ) * 0;
	self MoveTo( m_wolf.origin + zombie_move_offset, 0.5, 0.5 );
	self waittill( "movedone" );
	self.m_soul_fx_player Unlink();
	self.m_soul_fx_player Delete();
	self.m_soul_fx_player = undefined;
}

function grief_soul_catcher_state_manager( index )
{
	wait 1;
	while ( 1 )
	{
		level thread wolf_state_0(index);
		self waittill( "first_zombie_killed_in_zone" );
		if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] SetVisibleToAll();
			level.soul_catcher_clip[ self.script_noteworthy ] DisconnectPaths();
		}
		level thread wolf_state_1(index);
		anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
		wait anim_length;
		while ( !self.is_charged )
		{
			level thread wolf_state_2(index);
			self util::waittill_either( "fully_charged", "finished_eating" );
		}
		level thread wolf_state_6(index);
		anim_length = GetAnimLength( %o_zombie_dreamcatcher_outtro );
		wait anim_length;
		if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] SetInvisibleToAll();
			level.soul_catcher_clip[ self.script_noteworthy ] ConnectPaths();
		}
		self.souls_received = 0;
		level thread wolf_spit_out_powerup();
		wait 20;
		self thread soul_catcher_check();
	}
}

function soul_catcher_check()
{
	self.is_charged = 0;
	while ( 1 )
	{
		if ( self.souls_received >= 6 )
		{
			level.soul_catchers_charged++;
			level thread zm_alcatraz_amb::sndplaystinger( "tomahawk_" + level.soul_catchers_charged );
			self.is_charged = 1;
			self notify( "fully_charged" );
			//IPrintLnBold("fully_charged");
			break;
		}
		else
		{
			wait 0.05;
		}
	}
	if ( level.soul_catchers_charged == 1 )
	{
		self thread first_wolf_complete_vo();
	}
	else
	{
		if ( level.soul_catchers_charged >= level.soul_catchers.size )
		{
			self thread final_wolf_complete_vo();
		}
	}
}

function wolf_spit_out_powerup()
{
	if ( isdefined( level.enable_magic ) && !level.enable_magic )
	{
		return;
	}
	power_origin_struct = struct::get( "wolf_puke_powerup_origin", "targetname" );
	if ( randomint( 100 ) < 20 )
	{
		i = 0;
		while ( i < level.zombie_powerup_array.size )
		{
			if ( level.zombie_powerup_array[ i ] == "meat_stink" )
			{
				level.zombie_powerup_index = i;
				found = 1;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	else
	{
		level.zombie_powerup_index = RandomInt( level.zombie_powerup_array.size );
		while ( level.zombie_powerup_array[ level.zombie_powerup_index ] == "nuke" )
		{
			wait 0.05;
		}
	}
	spawn_infinite_powerup_drop( power_origin_struct.origin, level.zombie_powerup_array[ level.zombie_powerup_index ] );
	power_ups = util::get_array_of_closest( power_origin_struct.origin, level.active_powerups, undefined, undefined, 100 );
	if ( isdefined( power_ups[ 0 ] ) )
	{
		power_ups[ 0 ] MoveZ( 120, 4 );
	}
}

function get_the_zoms()
{
	while(1)
	{
		wait(.1); 
		zoms = GetAISpeciesArray("axis"); 
		for (i=0;i<zoms.size;i++)
		{
			if ( isdefined(zoms[i].is_accounted) && zoms[i].is_accounted == true)
			{

			}
			else
			{
				if(isdefined(zoms[i].is_brutus) && zoms[i].is_brutus)
				{

				}
				else
				{
					zoms[i].is_accounted = true;
					zoms[i] thread watch_for_death(); 
				}
			}
			
		}
	}
}

function watch_for_death()
{
	self waittill("death");
	//IPrintLnBold("zombie_died");
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		if ( self IsTouching( level.soul_catchers_vol[ i ] ) && !level.soul_catchers[ i ].is_charged)
		{
			if ( level.soul_catchers[ i ].is_eating == true)
			{
				return;
			}
			if ( level.soul_catchers[ i ].souls_received >= 6 )
			{
				return;
			}
			if(!isdefined(self))
			{
				return;
			}
			self.my_soul_catcher = level.soul_catchers[ i ];
			if ( isdefined( self.my_soul_catcher.souls_received ) && self.my_soul_catcher.souls_received == 0 )
			{
				if ( isdefined( level.wolf_encounter_vo_played ) && !level.wolf_encounter_vo_played )
				{
					if ( level.soul_catchers_charged == 0 )
					{
						self.my_soul_catcher thread first_wolf_encounter_vo();
					}
				}
			}
			origin = self.origin;
			self Hide();
			level.soul_catchers[ i ].is_eating = true;
			clone = self get_zombie_clone();
			clone UseAnimTree(#animtree);
			clone thread do_impact_anim();
			if ( level.soul_catchers[ i ].souls_received == 0 )
			{
				level.soul_catchers[ i ] notify( "first_zombie_killed_in_zone" );
				level.soul_catchers[ i ] thread notify_wolf_intro_anim_complete();
			}
			if ( level.soul_catchers[ i ].souls_received == 0 )
			{
				level.soul_catchers[ i ] waittill( "wolf_intro_anim_complete" );
			}
			while(!isdefined(clone.wolf_impact_done))
			{
				wait 0.05;
			}
			clone.my_soul_catcher = level.soul_catchers[ i ];
			clone pose_dead_body();
			n_eating_anim = clone which_eating_anim();
			level thread wolf_state_eat(i , n_eating_anim,clone);
			if ( n_eating_anim == 3 )
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_f );
			}
			else if ( n_eating_anim == 4 )
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_r );
			}
			else
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_l );
			}
			wait ( total_wait_time - 0.5 );
			level.soul_catchers[ i ].souls_received++;
			wait 0.5;
			level.soul_catchers[ i ] notify( "finished_eating" );
			//IPrintLnBold("finished_eating");
			level.soul_catchers[ i ].is_eating = false;
			clone Delete();
			return;
		}
		i++;
	}
}

function get_zombie_clone()
{
	gib_ref = "";
	if(IsDefined( self.a.gib_ref ))
	{
		gib_ref = self.a.gib_ref; 
	} 
	
	limb_data = getLimbData( gib_ref, self);
	// self hide();
	zombie_clone = spawn("script_model", self.origin);
	zombie_clone.angles = self.angles;
	zombie_clone SetModel( limb_data["body"] );
	zombie_clone Attach( limb_data["head"] );
	zombie_clone Attach( limb_data["legs"] );
	self Delete();
	
	return zombie_clone; 	
}

function getLimbData(gib_ref, zombie)
{
    temp_array = [];
 
 	//Setup Default model
    temp_array["head"] = "c_zom_zombie_mask_head";
    temp_array["body"] = zombie.torsoDmg1;
    temp_array["legs"] = zombie.legDmg1;
    temp_array["type"] = "zombie";

    if(gib_ref == "right_arm")
    {  
        if(IsDefined( zombie.torsoDmg2 ))
        {
            temp_array["body"] = zombie.torsoDmg2;
            return temp_array;
        }
    }
 
    if(gib_ref == "left_arm")
    {
        if(IsDefined( zombie.torsoDmg3 ))
        {
            temp_array["body"] = zombie.torsoDmg3;
        }
    }

    if(gib_ref == "guts")
    {
        if(IsDefined( zombie.torsoDmg4 ))
        {
            temp_array["body"] = zombie.legDtorsoDmg4mg3;
        }
    }

    if(gib_ref == "head")
    {
        if(IsDefined( zombie.torsoDmg5 ))
        {
            temp_array["body"] = zombie.torsoDmg5;
        }
    }
 
    if(gib_ref == "right_leg")
    {  
        if(IsDefined( zombie.legDmg2 ))
        {
            temp_array["legs"] = zombie.legDmg2;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "left_leg")
    {
        if(IsDefined( zombie.legDmg3 ))
        {
            temp_array["legs"] = zombie.legDmg3;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "no_legs")
    {
        if(IsDefined( zombie.legDmg4 ))
        {
            temp_array["legs"] = zombie.legDmg4;
            temp_array["type"] = "crawler";
        }
    }
 
    return temp_array;
}

function do_impact_anim()
{
	self.wolf_impact_done = undefined;
	//self AnimScripted( "notify", self.origin, self.angles, %ai_zombie_dreamcatch_impact, "normal", %ai_zombie_dreamcatch_impact, 1, 0.3 );
	self AnimScripted( "notify" , self.origin , self.angles, %ai_zombie_dreamcatch_impact);
	wait GetAnimLength(%ai_zombie_dreamcatch_impact) - 0.1;
	self.noragdoll = true;
	self.nodeathragdoll = true;
	self.wolf_impact_done = true;
}

function pose_dead_body()
{
	//s_closest = array::get_all_closest( self.origin, level.a_wolf_structs, undefined, 1, 500 );
	s_closest = util::get_array_of_closest( self.origin, level.a_wolf_structs );
	m_body = s_closest[0].body;
	m_wolf = s_closest[0].head;
	m_body.origin = self.origin;
	m_body.angles = self.angles;
}

function check_for_zombie_in_wolf_area()
{
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		if ( self IsTouching( level.soul_catchers_vol[ i ] ) )
		{
			if ( !level.soul_catchers[ i ].is_charged && !level.soul_catchers[ i ].is_eating )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

function notify_wolf_intro_anim_complete()
{
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	self notify( "wolf_intro_anim_complete" );
}

function which_eating_anim()
{
	soul_catcher = self.my_soul_catcher;
	forward_dot = VectorDot( AnglesToForward( soul_catcher.angles ), VectorNormalize( self.origin - soul_catcher.origin ) );
	if ( forward_dot > 0.85 )
	{
		return 3;
	}
	else
	{
		right_dot = VectorDot( AnglesToRight( soul_catcher.angles ), self.origin - soul_catcher.origin );
		if ( right_dot > 0 )
		{
			return 4;
		}
		else
		{
			return 5;
		}
	}
}

function wolf_head_removal( wolf_head_model_string )
{
	wolf_head_model = GetEnt( wolf_head_model_string, "targetname" );
	wolf_head_model SetModel( "p6_zm_al_dream_catcher" );
	self waittill( "fully_charged" );
	wolf_head_model SetModel( "p6_zm_al_dream_catcher_on" );
}

function soul_catchers_charged()
{
	while ( 1 )
	{
		if ( level.soul_catchers_charged >= level.soul_catchers.size )
		{
			level flag::set( "soul_catchers_charged" );
			level notify( "soul_catchers_charged" );
			door_models = GetEntArray("tomahawk_room","targetname");
			foreach(door in door_models)
			{
				door.origin = door.origin - (0,0,1000);
				door ConnectPaths();
				door Delete();
			}
			return;
		}
		else
		{
			wait 1;
		}
	}
}

function first_wolf_encounter_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 2;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread zm_utility::do_player_general_vox( "general", "wolf_encounter" );
			level.wolf_encounter_vo_played = 1;
			return;
		}
		else
		{
			i++;
		}
	}
}

function first_wolf_complete_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread zm_utility::do_player_general_vox( "general", "wolf_complete" );
			return;
		}
		else
		{
			i++;
		}
	}
}

function final_wolf_complete_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread zm_utility::do_player_general_vox( "general", "wolf_final" );
			return;
		}
		else
		{
			i++;
		}
	}
}

function tomahawk_upgrade_quest()
{
	if ( isdefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
	{
		return;
	}
	self endon( "disconnect" );
	self.tomahawk_upgrade_kills = 0;
	while ( self.tomahawk_upgrade_kills < 15 )
	{
		self waittill( "got_a_tomahawk_kill" );
		self.tomahawk_upgrade_kills++;
	}
	wait 1;
	level thread zm_alcatraz_amb::sndplaystinger( "quest_generic" );
	e_org = Spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org PlaySoundWithNotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org Delete();
	while ( level.round_number < 10 )
	{
		wait 0.5;
	}
	self flag::init( "gg_round_done" );
	while ( !self flag::get( "gg_round_done" ) )
	{
		level waittill( "between_round_over" );
		self.killed_with_only_tomahawk = 1;
		self.killed_something_thq = 0;
		if ( !self zm_alcatraz_utility::is_player_in_zone( "bridge_zone" ) )
		{
			wait 0.05;
			continue;
		}
		level waittill( "end_of_round" );
		if ( !self.killed_with_only_tomahawk || !self.killed_something_thq )
		{
			wait 0.05;
			continue;
		}
		if ( !self zm_alcatraz_utility::is_player_in_zone( "bridge_zone" ) )
		{
			wait 0.05;
			continue;
		}
		wait 0.05;
		self flag::set( "gg_round_done" );
	}
	level thread zm_alcatraz_amb::sndplaystinger( "quest_generic" );
	e_org = Spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org PlaySoundWithNotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org Delete();
	self notify( "hellhole_time" );
	self waittill( "tomahawk_in_hellhole" );
	if ( isdefined( self.retriever_trigger ) )
	{
		self.retriever_trigger SetInvisibleToPlayer( self );
	}
	else
	{
		trigger = GetEnt( "retriever_pickup_trigger", "script_noteworthy" );
		self.retriever_trigger = trigger;
		self.retriever_trigger SetInvisibleToPlayer( self );
	}
	self TakeWeapon( GetWeapon("zombie_tomahawk") );
	self zm_utility::set_player_tactical_grenade( "none" );
	self notify( "tomahawk_upgraded_swap" );
	level thread zm_alcatraz_amb::sndplaystinger( "quest_generic" );
	e_org = Spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org PlaySoundWithNotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org Delete();
	level waittill( "end_of_round" );
	self.current_tomahawk_weapon = "zombie_tomahawk_upgraded";
}

function toggle_redeemer_trigger()
{
	self endon( "disconnect" );
	level flag::wait_till( "tomahawk_pickup_complete" );
	upgraded_tomahawk_trigger = GetEnt( "redeemer_pickup_trigger", "script_noteworthy" );
	upgraded_tomahawk_trigger SetInvisibleToPlayer( self );
	tomahawk_model = GetEnt( "spinning_tomahawk_pickup", "targetname" );
	while ( 1 )
	{
		if ( isdefined( self.current_tomahawk_weapon ) && self.current_tomahawk_weapon == "zombie_tomahawk_upgraded" )
		{
			break;
		}
		else wait 1;
	}
	while ( 1 )
	{
		if ( isdefined( self.afterlife ) && self.afterlife )
		{
			upgraded_tomahawk_trigger SetVisibleToPlayer( self );
			tomahawk_model SetVisibleToPlayer( self );
		}
		else
		{
			upgraded_tomahawk_trigger SetInvisibleToPlayer( self );
			tomahawk_model SetInvisibleToPlayer( self );
		}
		wait 1;
	}
}

function hellhole_projectile_watch()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( weapname == GetWeapon("frag_grenade") )
		{
			self thread hellhole_grenades( grenade );
		}
	}
}

function hellhole_tomahawk_watch()
{
	self endon( "disconnect" );
	self waittill( "hellhole_time" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		if ( weapname == GetWeapon("zombie_tomahawk") || weapname == GetWeapon("zombie_tomahawk_upgraded") )
		{
			self thread hellhole_tomahawk( grenade );
		}
	}
}

function hellhole_grenades( grenade )
{
	grenade endon( "death" );
	trig_hellhole = GetEnt( "trig_cellblock_hellhole", "targetname" );
	//IPrintLnBold("Trigs: " + trig_hellhole.size);
	while ( !grenade IsTouching( trig_hellhole ) )
	{
		//IPrintLnBold("Not touching");
		wait 0.05;
	}
	self zm_score::add_to_player_score( 20 );
	PlayFX( level._effect[ "tomahawk_hellhole" ], grenade.origin );
	PlaySoundAtPosition( "wpn_grenade_poof", grenade.origin );
	grenade Delete();
}

function hellhole_tomahawk( grenade )
{
	grenade endon( "death" );
	trig_hellhole = GetEnt( "trig_cellblock_hellhole", "targetname" );
	while ( !grenade IsTouching( trig_hellhole ) )
	{
		wait 0.05;
	}
	self notify( "tomahawk_in_hellhole" );
	grenade notify( "in_hellhole" );
	PlayFX( level._effect[ "tomahawk_hellhole" ], grenade.origin );
	PlaySoundAtPosition( "wpn_grenade_poof", grenade.origin );
	grenade Delete();
}

function spawn_infinite_powerup_drop( v_origin, str_type )
{
	if ( isdefined( str_type ) )
	{
		intro_powerup = zm_powerups::specific_powerup_drop( str_type, v_origin );
	}
	else
	{
		intro_powerup = zm_powerups::powerup_drop( v_origin );
	}
}