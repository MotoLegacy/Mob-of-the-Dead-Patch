#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\zm_alcatraz_amb;

function autoexec main()
{
	clientfield::register( "toplayer", "player_lives", 9000, 2, "int", &set_player_lives, 0, 1 );
	clientfield::register( "toplayer", "player_afterlife_mana", 9000, 5, "float", &set_player_mana, 0, 1 );
	clientfield::register( "toplayer", "player_in_afterlife", 9000, 1, "int", &toggle_player_afterlife, 0, 1 );
	clientfield::register( "allplayers", "player_afterlife_fx", 9000, 1, "int", &toggle_player_afterlife_fx, 1, 0 );
	clientfield::register( "toplayer", "clientfield_afterlife_audio", 9000, 1, "int", &zm_alcatraz_amb::afterlifeaudio, 0 , 1);
	clientfield::register( "toplayer", "player_afterlife_refill", 9000, 1, "int", &toggle_player_refill_fx, 0, 1 );
	clientfield::register( "scriptmover", "player_corpse_id", 9000, 3, "int", &assign_corpse_owner, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	setupclientfieldcodecallbacks( "toplayer", 1, "player_lives" );
	setupclientfieldcodecallbacks( "toplayer", 1, "player_in_afterlife" );
	setupclientfieldcodecallbacks( "toplayer", 1, "player_afterlife_mana" );
	setupclientfieldcodecallbacks( "scriptmover", 1, "player_corpse_id" );
	visionset_mgr::register_visionset_info( "zm_afterlife", 9000, 1, "zm_afterlife", "zm_afterlife" );
	visionset_mgr::register_overlay_info_style_filter( "zm_afterlife_filter", 9000, 1, 5, 0, "generic_filter_afterlife_alcatraz" );

	// Were gonna keep this in or else it crashes
	clientfield::register( "world", "fog_stage", VERSION_SHIP, 2,	"int",	&fog_stage_notifies, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );

	afterlife_load_fx();
	callback::on_localclient_connect(&player_init_afterlife);
}

function fog_stage_notifies( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	switch ( newval )
	{
		case 1:
			SetWorldFogActiveBank( localclientnum, 4 );
			break;
		case 2:
			SetWorldFogActiveBank( localclientnum, 8 );
			break;
		case 3:
			SetWorldFogActiveBank( localclientnum, 1 );
			break;
	}
}

function afterlife_load_fx()
{
	level._effect["afterlife_pixie_dust"] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies";
	level._effect["afterlife_ghost_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_body";
	level._effect["afterlife_ghost_h_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_head";
	level._effect["afterlife_ghost_arm_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_arm";
	level._effect["afterlife_ghost_hand_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand";
	level._effect["afterlife_ghost_hand_r_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r";
	level._effect["fx_alcatraz_ghost_vm_wrist"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist";
	level._effect["fx_alcatraz_ghost_vm_wrist_r"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r";
	level._effect["afterlife_damage"] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage";
	level._effect["afterlife_transition"] = "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition";
	level._effect["afterlife_corpse"] = "maps/zombie_alcatraz/fx_alcatraz_player_down";
	level._effect["fx_alcatraz_ghost_spectate"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_spec";
}

function player_init_afterlife( localclientnum )
{
	player = GetLocalPlayer( localclientnum );
	player init_filter_afterlife();
	player thread afterlife_transition_fx();
	//player thread afterlife_watch_spectator( localclientnum );
}

function afterlife_watch_spectator( localclientnum )
{
	self endon( "entityshutdown" );
	self endon( "death_or_disconnect" );
	self.camera_mode = "normal";
	self.last_camera_mode = "normal";
	//self thread track_camera_mode( localclientnum );
	switch ( self.camera_mode )
	{
		case "normal":
			self notify( "stop_player_fx" );
			self.last_camera_mode = self.camera_mode;
			break;
		case "spectating_1st_afterlife":
			self thread player_afterlife_first_fx( localclientnum );
			self.last_camera_mode = self.camera_mode;
			break;
		case "spectating_3rd_afterlife":
			self thread player_afterlife_spectator_fx( localclientnum );
			self.last_camera_mode = self.camera_mode;
			break;
	}
	wait 0.05;
}

function track_camera_mode( localclientnum )
{
	self endon( "entityshutdown" );
	self endon( "death_or_disconnect" );
	player = PlayerBeingSpectated( localclientnum );
	self.camera_mode = "spectating_3rd_afterlife";
	self.camera_mode = "normal";
	self.camera_mode = "spectating_1st_afterlife";
	self.camera_mode = "normal";
	self.camera_mode = "normal";
	wait 0.05;
}

function afterlife_mana_rumble()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	localclientnum = self GetLocalClientNumber();
	self PlayRumbleOnEntity( localclientnum, "damage_heavy" );
	wait 0.25;
	self PlayRumbleOnEntity( localclientnum, "damage_light" );
	wait 0.5;
	self PlayRumbleOnEntity( localclientnum, "damage_light" );
	wait 0.75;
	wait 0.25;
}

function init_filter_afterlife()
{
	filter::init_filter_indices();
	filter::map_material_helper( self, "generic_filter_afterlife_alcatraz" );
}

function set_player_mana( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.mana = newval;
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "afterlifeMana" ), newVal );
}

function set_player_lives( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.lives = newval;
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "afterlifeLives" ), newVal );
}

function assign_corpse_owner( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.player = newval;
	PlayFXOnTag( localclientnum, level._effect["afterlife_corpse"], self, "tag_origin" );
}

function toggle_player_afterlife_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self thread player_afterlife_first_fx( localclientnum );
	self thread player_afterlife_third_fx( localclientnum );
	self notify( "stop_player_fx" );
}

function player_afterlife_first_fx( localclientnum )
{
	self notify( "stop_player_fx" );
	self endon( "stop_player_fx" );
	while(1)
	{
		PlayViewmodelFX( localclientnum, level._effect["fx_alcatraz_ghost_vm_wrist"], "j_wrist_le" );
		PlayViewmodelFX( localclientnum, level._effect["fx_alcatraz_ghost_vm_wrist_r"], "j_wrist_ri" );
		wait 0.1;
		PlayViewmodelFX( localclientnum, level._effect["afterlife_pixie_dust"], "tag_weapon" );
		wait 0.1;
	}
}

function player_afterlife_third_fx( localclientnum )
{
	self notify( "stop_player_fx" );
	self endon( "stop_player_fx" );
	self endon( "entityshutdown" );
	self util::waittill_dobj( localclientnum );
	ent = Spawn( localclientnum, self.origin, "script_origin" );
	ent LinkTo( self, "tag_origin" );
	ent PlayLoopSound( "zmb_afterlife_ghost_loop" );
	self thread snddeleteent( ent );
	while(1)
	{
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_fx"], self, "J_spine4" );
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_h_fx"], self, "J_head" );
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_arm_fx"], self, "J_elbow_ri" );
		wait 0.1;
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_arm_fx"], self, "J_elbow_le" );
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_hand_r_fx"], self, "J_wrist_ri" );
		PlayFXOnTag( localclientnum, level._effect["afterlife_ghost_hand_fx"], self, "J_wrist_le" );
		wait 0.1;
	}
}

function player_afterlife_spectator_fx( localclientnum )
{
	self notify( "stop_player_fx" );
	self endon( "stop_player_fx" );
	self endon( "entityshutdown" );
	self util::waittill_dobj( localclientnum );
	ent = Spawn( localclientnum, self.origin, "script_origin" );
	ent LinkTo( self, "tag_origin" );
	ent PlayLoopSound( "zmb_afterlife_ghost_loop" );
	self thread snddeleteent( ent );
	player = PlayerBeingSpectated( localclientnum );
	while(1)
	{
		PlayFX( localclientnum, level._effect["fx_alcatraz_ghost_spectate"], player.origin +  ( 0, 0, 40 ) );
		wait 0.05;
		waitrealtime( 0.1 );
	}
}

function afterlife_damage_fx()
{
	self endon( "disconnect" );
	self endon( "stop_damage_fx" );
	while(1)
	{
		level waittill( "al_d", localclientnum );
		PlaySound( 0, "zmb_afterlife_impact", ( 0, 0, 0 ) );
		PlayViewmodelFX( localclientnum, level._effect["afterlife_damage"], "tag_weapon" );
	}
}

function afterlife_transition_fx()
{
	self endon( "disconnect" );
	while(1)
	{
		level waittill( "al_t", localclientnum );
		PlayViewmodelFX( localclientnum, level._effect["afterlife_transition"], "tag_weapon" );
	}
}

function toggle_player_refill_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self thread player_afterlife_first_fx( localclientnum );
	self notify( "stop_player_fx" );
}

function toggle_player_afterlife( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if(newval)
	{
		self.afterlife = 1;
		self thread afterlife_mana_rumble();
		self thread afterlife_damage_fx();
		//self thread sndafterlifeleak( localclientnum );
	}
	else
	{
		self.afterlife = 0;
		self notify( "stop_damage_fx" );
		self notify( "sndEndLeak" );
	}
}

function sndafterlifeleak( localclientnum )
{
	self endon( "sndEndLeak" );
	self endon( "lastStandEnd" );
	id = undefined;
	wait 2;
	ent = Spawn( 0, ( 0, 0, 0 ), "script_origin" );
	id = ent PlayLoopSound( "zmb_afterlife_leak", 0.5 );
	self thread sndafterlifeleakdelete( ent );
	SetSoundVolume( id, 0 );
	SetSoundVolumeRate( id, 4 );
	SetSoundPitch( id, 1 );
	SetSoundPitchRate( id, 4 );
	wait 1;
	val = abs( self.mana - 1 );
	volume = audio::scale_speed( 0.5, 1, 0, 1, val );
	pitch = audio::scale_speed( 0.5, 1, 1, 2, val );
	SetSoundVolume( id, volume );
	SetSoundVolumeRate( id, 0.1 );
	SetSoundPitch( id, pitch );
	SetSoundPitchRate( id, 0.1 );
	wait 0.05;
	self notify( "sndEndLeak" );
}

function sndafterlifeleakdelete( ent )
{
	self util::waittill_any( "sndEndLeak", "disconnect", "lastStandEnd" );
	ent StopLoopSound( 0.05 );
	wait 1;
	ent Delete();
}

function snddeleteent( ent )
{
	self util::waittill_any( "stop_player_fx", "entityshutdown" );
	ent Delete();
}