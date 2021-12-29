#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\util_shared;
#using scripts\shared\postfx_shared;
#using scripts\zm\zm_prison_sq_final;

#using scripts\zm\_filter;

#using scripts\zm\_zm_magicbox_prison;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_player_down" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_afterlife_pixies" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_ghost_vm_wrist" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_ghost_vm_wrist_r" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_ghost_body" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_afterlife_transition" );
#precache( "client_fx", "custom/motdr/afterlife/fx_alcatraz_afterlife_damage" );

function autoexec init()
{
	level._effect["afterlife_pixie_dust"] = "custom/motdr/afterlife/fx_alcatraz_afterlife_pixies";
	level._effect["afterlife_ghost_fx"] = "custom/motdr/afterlife/fx_alcatraz_ghost_body";
	level._effect["afterlife_ghost_h_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_head";
	level._effect["afterlife_ghost_arm_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_arm";
	level._effect["afterlife_ghost_hand_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand";
	level._effect["afterlife_ghost_hand_r_fx"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r";
	level._effect["fx_alcatraz_ghost_vm_wrist"] = "custom/motdr/afterlife/fx_alcatraz_ghost_vm_wrist";
	level._effect["fx_alcatraz_ghost_vm_wrist_r"] = "custom/motdr/afterlife/fx_alcatraz_ghost_vm_wrist_r";
	level._effect["afterlife_damage"] = "custom/motdr/afterlife/fx_alcatraz_afterlife_damage";
	level._effect["afterlife_transition"] = "custom/motdr/afterlife/fx_alcatraz_afterlife_transition";
	level._effect["afterlife_corpse"] = "custom/motdr/afterlife/fx_alcatraz_player_down";
	level._effect["fx_alcatraz_ghost_spectate"] = "maps/zombie_alcatraz/fx_alcatraz_ghost_spec";

	clientfield::register( "toplayer", "player_lives", VERSION_SHIP, 2, "int", &set_player_lives, 0, 1 );
	clientfield::register( "toplayer", "player_afterlife_mana", VERSION_SHIP, 5, "float", &set_player_mana, 0, 1 );
	clientfield::register( "scriptmover", "player_corpse_id", VERSION_TU7, 1, "int", &assign_corpse_owner, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "player_in_afterlife", VERSION_SHIP, 1,	"int",	&toggle_player_afterlife, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "clientfield_afterlife_audio", VERSION_SHIP, 1,	"int",	&afterlifeaudio, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers", "player_afterlife_fx", VERSION_SHIP, 2, "int",	&toggle_player_afterlife_fx, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "player_afterlife_refill", VERSION_SHIP, 1, "int", &toggle_player_refill_fx, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "fog_stage", VERSION_SHIP, 2,	"int",	&fog_stage_notifies, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "world", "intoxcam", VERSION_SHIP, 1, "int", &intoxcam, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	SetupClientFieldCodeCallbacks( "scriptmover", 1, "player_corpse_id" );

	callback::on_localclient_connect( &player_init_afterlife );
}

function intoxcam( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	PlayMainCamXCam( localClientNum, "ui_cam_endgame_testing", 1, "cam_topscorers", "topscorers", (1445.64,-862,5607.73), (0,180,0) );
}

function set_player_lives( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.lives = newval;
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "afterlifeLives" ), newVal );
}

function set_player_mana( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.mana = newval;
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "afterlifeMana" ), newVal );
}

function assign_corpse_owner( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if(newval == 1)
	{
		self.player = newval;
		self.afterlife_corpse_fx = PlayFXOnTag( localclientnum, level._effect["afterlife_corpse"], self, "tag_origin" );
	}
	else
	{
		StopFX(localclientnum, self.afterlife_corpse_fx);
	}
}

function toggle_player_afterlife( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "playerInAfterlife" ), newVal );
	player = GetLocalPlayer( localclientnum );
	if(newval == 1)
	{
		self.afterlife = 1;
		
		//player thread postfx::playPostfxBundle( "pstfx_zm_beast_mode_loop" );
		//self thread afterlife_mana_rumble();
		self thread afterlife_damage_fx();
		self thread sndafterlifeleak( localclientnum );
		self thread afterlife_ambientroom( localclientnum );
	}
	else
	{
		self.afterlife = 0;
		//player postfx::exitPostfxBundle();
		self notify( "stop_damage_fx" );
		self notify( "sndEndLeak" );
	}
}

function afterlife_ambientroom(localclientnum)
{
	self endon( "disconnect" );
	level waittill( "al_e", localclientnum);
	ForceAmbientRoom("sndHealth_LowHealth");
	level waittill( "al_l", localclientnum);
	ForceAmbientRoom("");
}

function afterlife_damage_fx()
{
	self endon( "disconnect" );
	self endon( "stop_damage_fx" );
	while(1)
	{
		level waittill( "al_d", localclientnum );
		PlaySound( 0, "zmb_afterlife_impact", ( 0, 0, 0 ) );
		PlayViewmodelFX( localclientnum, level._effect["afterlife_damage"], "tag_weapon_right" );
	}
}

function afterlifeaudio( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if(newval == 1)
	{
		self activateafterlifeaudio();
	}
	else
	{
		self deactivateafterlifeaudio();
	}
}

function activateafterlifeaudio()
{
	//activateambientroom( 0, "afterlife", 98 );
	PlaySound( 0, "zmb_afterlife_start", ( 0, 0, 0 ) );
	audio::snd_set_snapshot( "zmb_afterlife" );
	//audio::setsoundcontext( "grass", "in_grass" );
}

function deactivateafterlifeaudio()
{
	//deactivateambientroom( 0, "afterlife", 98 );
	PlaySound( 0, "zmb_afterlife_end", ( 0, 0, 0 ) );
	audio::snd_set_snapshot( "default" );
	//audio::setsoundcontext( "grass", "no_grass" );
}

function toggle_player_afterlife_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump ) {
	self notify( "stop_player_fx" );
	if ( isdefined( self.player_afterlife_third_fx ) ) {	
		StopFX( localClientNum, self.player_afterlife_third_fx );			
	}
	if(isdefined(self.ghostloopsound)) {
		self.ghostloopsound StopLoopSound( 0.05 );
		self.ghostloopsound Delete();
	}
	if(newval == 2) {
		self thread player_afterlife_first_fx( localclientnum );
		self thread player_afterlife_third_fx( localclientnum );
	}
}

function player_afterlife_first_fx( localclientnum ) {
	self endon( "stop_player_fx" );
	i = 0;
	while(self.afterlife == 1 || i < 20) {
		PlayViewmodelFX( localclientnum, level._effect["fx_alcatraz_ghost_vm_wrist"], "j_wrist_le" );
		PlayViewmodelFX( localclientnum, level._effect["fx_alcatraz_ghost_vm_wrist_r"], "j_wrist_ri" );
		wait 0.1;
		PlayViewmodelFX( localclientnum, level._effect["afterlife_pixie_dust"], "tag_weapon" );
		wait 0.1;
		i++;
	}
}

function player_afterlife_third_fx( localclientnum ) {
	self endon( "stop_player_fx" );
	self endon( "entityshutdown" );
	self util::waittill_dobj( localclientnum );
	ent = Spawn( localclientnum, self.origin, "script_origin" );
	ent LinkTo( self, "tag_origin" );
	id = ent PlayLoopSound( "zmb_afterlife_ghost_loop" );
	self.ghostloopsound = ent;
	self thread snddeleteent( ent, id );
	self.player_afterlife_third_fx = PlayFXOnTag( localclientnum, level._effect[ "afterlife_ghost_fx" ], self, "J_spine4" );
	
}

function sndafterlifeleak( localclientnum ) {
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
	while(self.afterlife == 1) {
		val = Abs( self.mana - 1 );
		volume = audio::scale_speed( 0.5, 1, 0, 1, val );
		pitch = audio::scale_speed( 0.5, 1, 1, 2, val );
		SetSoundVolume( id, volume );
		SetSoundVolumeRate( id, 0.1 );
		SetSoundPitch( id, pitch );
		SetSoundPitchRate( id, 0.1 );
		wait 0.05;
	}
	self notify( "sndEndLeak" );
}

function sndafterlifeleakdelete( ent ) {
	self util::waittill_any( "sndEndLeak", "disconnect", "lastStandEnd" );
	ent StopLoopSound( 0.05 );
	wait 1;
	ent Delete();
}

function snddeleteent( ent, id ) {
	wait 1;
	while(self.afterlife == 1) {
		wait 0.1;
	}
	ent StopLoopSound( id, 0.05 );
	wait 1;
	ent Delete();
}

function toggle_player_refill_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump ) {
	if(newVal == 1) {
		self.afterlife = 1;
		self thread player_afterlife_first_fx( localclientnum );
	}
	else {
		self.afterlife = 0;
		self notify( "stop_player_fx" );
	}
}

function player_init_afterlife( localclientnum ) {
	player = GetLocalPlayer( localclientnum );
	player thread afterlife_transition_fx();
}

function afterlife_transition_fx() {
	self endon( "disconnect" );
	while(1) {
		level waittill( "al_t", localclientnum );
		PlayViewmodelFX( localclientnum, level._effect["afterlife_transition"], "tag_weapon_right" );
	}
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