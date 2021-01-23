#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;

#using scripts\zm\_zm_weapons; 

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;

#precache( "client_fx", "custom/jerri/al_box/al_box_idle" );
#precache( "client_fx", "custom/jerri/al_box/al_box_fire" );

function autoexec init()
{
	level._effect["box_is_open"] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_open";
	level._effect["box_is_locked"] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_lock";
	level._effect["box_gone_ambient"] = "custom/jerri/al_box/al_box_idle";
	level._effect["box_here_ambient"] = "custom/jerri/al_box/al_box_fire";
	level._effect["box_is_leaving"] = "maps/zombie_alcatraz/fx_alcatraz_magicbox_leave";
	clientfield::register( "zbarrier", "magicbox_initial_fx_new", VERSION_SHIP, 1, "int", &magicbox_initial_closed_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "magicbox_amb_fx", VERSION_SHIP, 2, "int", &magicbox_ambient_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "magicbox_open_fx_new", VERSION_SHIP, 1, "int", &magicbox_open_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "magicbox_leaving_fx", VERSION_SHIP, 1, "int", &magicbox_leaving_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function magicbox_initial_closed_fx_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self thread magicbox_initial_closed_fx( localClientNum, newVal );
}

function magicbox_ambient_fx_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self thread magicbox_ambient_fx( localClientNum, newVal );
}

function magicbox_open_fx_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self thread magicbox_open_fx( localClientNum, newVal );
}

function magicbox_leaving_fx_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self thread magicbox_leaving( localClientNum, newVal );
}

function magicbox_initial_closed_fx( localClientNum, newVal)
{
	DEFAULT( self.ambient_obj_array, [] );
	DEFAULT( self.ambient_fx_array, [] );

	if ( !isdefined( self.ambient_obj_array[localClientNum] ) )
	{
		fx_obj = Spawn( localClientNum, self.origin, "script_model" ); 
		fx_obj SetModel( "tag_origin" ); 
		fx_obj.angles = self.angles;
		self.ambient_obj_array[localClientNum] = fx_obj;
		WAIT_CLIENT_FRAME;
	}

	self closed_obj_cleanup( localClientNum );

	if ( newVal )
	{
		self.ambient_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_gone_ambient"], self.ambient_obj_array[localClientNum], "tag_origin" );
	}
}

function closed_obj_cleanup( localClientNum )
{
	if ( isdefined( self.ambient_fx_array[localClientNum] ) )
	{
		StopFX( localClientNum, self.ambient_fx_array[localClientNum] );
		self.ambient_fx_array[localClientNum] = undefined; 
	}
	
	self notify( "end_demo_jump_listener" );
}

function magicbox_open_fx( localClientNum, newVal)
{
	DEFAULT( self.open_obj_array, [] );
	DEFAULT( self.open_fx_array, [] );

	if ( !isdefined( self.open_obj_array[localClientNum] ) )
	{
		fx_obj = Spawn( localClientNum, self.origin, "script_model" ); 
		fx_obj SetModel( "tag_origin" ); 
		fx_obj.angles = self.angles;
		self.open_obj_array[localClientNum] = fx_obj;
		WAIT_CLIENT_FRAME;
	}

	self open_obj_cleanup( localClientNum );

	if ( newVal )
	{
		self.open_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_is_open"], self.open_obj_array[localClientNum], "tag_origin" );
	}
}

function open_obj_cleanup( localClientNum )
{
	if ( isdefined( self.open_fx_array[localClientNum] ) )
	{
		StopFX( localClientNum, self.open_fx_array[localClientNum] );
		self.open_fx_array[localClientNum] = undefined; 
	}
	
	self notify( "end_demo_jump_listener" );
}

function magicbox_leaving( localClientNum, newVal)
{
	DEFAULT( self.leaving_obj_array, [] );
	DEFAULT( self.leaving_fx_array, [] );

	if ( !isdefined( self.leaving_obj_array[localClientNum] ) )
	{
		fx_obj = Spawn( localClientNum, self.origin, "script_model" ); 
		fx_obj SetModel( "tag_origin" ); 
		fx_obj.angles = self.angles;
		self.leaving_obj_array[localClientNum] = fx_obj;
		WAIT_CLIENT_FRAME;
	}

	self leaving_obj_cleanup( localClientNum );

	if ( newVal )
	{
		self.leaving_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_is_leaving"], self.leaving_obj_array[localClientNum], "tag_origin" );
	}
}

function leaving_obj_cleanup( localClientNum )
{
	if ( isdefined( self.leaving_fx_array[localClientNum] ) )
	{
		StopFX( localClientNum, self.leaving_fx_array[localClientNum] );
		self.leaving_fx_array[localClientNum] = undefined; 
	}
	
	self notify( "end_demo_jump_listener" );
}

function magicbox_ambient_fx( localClientNum, newVal)
{
	DEFAULT( self.ambient_obj_array, [] );
	DEFAULT( self.ambient_fx_array, [] );

	if ( !isdefined( self.ambient_obj_array[localClientNum] ) )
	{
		fx_obj = Spawn( localClientNum, self.origin, "script_model" ); 
		fx_obj SetModel( "tag_origin" ); 
		fx_obj.angles = self.angles;
		self.ambient_obj_array[localClientNum] = fx_obj;
		WAIT_CLIENT_FRAME;
	}

	self ambient_obj_cleanup( localClientNum );

	if ( newVal )
	{
		self.ambient_obj_array[localClientNum] StopLoopSound(0.5);
		if(isdefined(self.owner.is_locked) && self.owner.is_locked)
		{
			self.ambient_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_is_locked"], self.ambient_obj_array[localClientNum], "tag_origin" );
			self.ambient_obj_array[localClientNum] PlayLoopSound( "zmb_hellbox_amb_high" );
		}
		else
		{
			self.ambient_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_here_ambient"], self.ambient_obj_array[localClientNum], "tag_origin" );
			self.ambient_obj_array[localClientNum] PlayLoopSound( "zmb_hellbox_amb_high" );
		}	
	}
	else
	{
		self.ambient_fx_array[localClientNum] = PlayFXOnTag( localClientNum, level._effect["box_gone_ambient"], self.ambient_obj_array[localClientNum], "tag_origin" );
		self.ambient_obj_array[localClientNum] PlayLoopSound( "zmb_hellbox_amb_low" );
	}
}

function ambient_obj_cleanup( localClientNum )
{
	if ( isdefined( self.ambient_fx_array[localClientNum] ) )
	{
		StopFX( localClientNum, self.ambient_fx_array[localClientNum] );
		self.ambient_fx_array[localClientNum] = undefined; 
	}
	
	self notify( "end_demo_jump_listener" );
}