#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_weap_ammo_counter.gsh;

#precache( "client_fx", AMMO_COUNTER_DIGIT_0 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_1 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_2 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_3 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_4 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_5 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_6 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_7 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_8 );
#precache( "client_fx", AMMO_COUNTER_DIGIT_9 );

#namespace zm_weap_ammo_counter;
	
REGISTER_SYSTEM_EX( "zm_weap_ammo_counter", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "toplayer", "ammo_counter", 9000, 2, "int", &ammo_counter_active, 0, 1 );
	
	level._effect[ "ammo_counter" ] = [];
	level._effect[ "ammo_counter" ][ 0 ] = AMMO_COUNTER_DIGIT_0;
	level._effect[ "ammo_counter" ][ 1 ] = AMMO_COUNTER_DIGIT_1;
	level._effect[ "ammo_counter" ][ 2 ] = AMMO_COUNTER_DIGIT_2;
	level._effect[ "ammo_counter" ][ 3 ] = AMMO_COUNTER_DIGIT_3;
	level._effect[ "ammo_counter" ][ 4 ] = AMMO_COUNTER_DIGIT_4;
	level._effect[ "ammo_counter" ][ 5 ] = AMMO_COUNTER_DIGIT_5;
	level._effect[ "ammo_counter" ][ 6 ] = AMMO_COUNTER_DIGIT_6;
	level._effect[ "ammo_counter" ][ 7 ] = AMMO_COUNTER_DIGIT_7;
	level._effect[ "ammo_counter" ][ 8 ] = AMMO_COUNTER_DIGIT_8;
	level._effect[ "ammo_counter" ][ 9 ] = AMMO_COUNTER_DIGIT_9;		
}	

function ammo_counter_active( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self.ammo_counter_show = newval;
	self notify( "ammo_counter_update" );
}

function __main__()
{	
	callback::on_localplayer_spawned( &localplayer_spawned );
}

function localplayer_spawned( localClientNum )
{
	self thread ammo_counter_display( localClientNum );
	self thread ammo_counter_ammo_watcher( localClientNum );
}

function ammo_counter_ammo_watcher( localclientnum )
{
	self endon( "disconnect" );
	
	current_ammo = 0;
	while ( 1 )
	{		
		currentweapon = getCurrentWeapon( localclientnum );
		
		clip_ammo = getWeaponAmmoClip( localclientnum, currentweapon );
		if ( !isDefined( clip_ammo ) )
			clip_ammo = 0;
		
		if ( clip_ammo != current_ammo )
		{
			current_ammo = clip_ammo;
			self notify( "ammo_counter_update" );
		}
		
		wait .01;
	}
}

function ammo_counter_display( localclientnum )
{
	self endon( "disconnect" );
	
	current_units = -1;
	current_tens = -1;
	current_hundreds = -1;
	current_weapon = undefined;
	
	counter_0 = undefined;
	counter_1 = undefined;
	counter_2 = undefined;
	
	while ( 1 )
	{
		self waittill( "ammo_counter_update" );
		
		if ( !isDefined( self.ammo_counter_show ) || !self.ammo_counter_show )
		{
			if ( isDefined( counter_0 ) )
				stopFX( localclientnum, counter_0 );
			if ( isDefined( counter_1 ) )
				stopFX( localclientnum, counter_1 );
			if ( isDefined( counter_2 ) )
				stopFX( localclientnum, counter_2 );
			
			continue;
		}
		
		currentweapon = getCurrentWeapon( localclientnum );
		
		clip_ammo = getWeaponAmmoClip( localclientnum, currentweapon );
		if ( !isDefined( clip_ammo ) )
			clip_ammo = 0;
	
		units_clip = int( clip_ammo % 10 );
		tens_clip = int( ( ( clip_ammo - units_clip ) % 100 ) / 10 );
		hundreds_clip = int( ( clip_ammo - ( units_clip + ( tens_clip * 10 ) ) ) / 100 );
		
		if ( hundreds_clip != current_hundreds || currentweapon != current_weapon )
		{
			if ( isDefined( counter_0 ) )
				stopFX( localclientnum, counter_0 );
			if ( clip_ammo > 99 && viewmodelHasTag( localclientnum, AMMO_COUNTER_HUNDREDS_TAG ) )
				counter_0 = playViewmodelFx( localclientnum, level._effect[ "ammo_counter" ][ hundreds_clip ], AMMO_COUNTER_HUNDREDS_TAG );
			
			current_hundreds = hundreds_clip;
		}
		if ( tens_clip != current_tens || currentweapon != current_weapon )
		{
			if ( isDefined( counter_1 ) )
				stopFX( localclientnum, counter_1 );
			if ( clip_ammo > 9 && viewmodelHasTag( localclientnum, AMMO_COUNTER_TENS_TAG ) )
				counter_1 = playViewmodelFx( localclientnum, level._effect[ "ammo_counter" ][ tens_clip ], AMMO_COUNTER_TENS_TAG );
			
			current_tens = tens_clip;
		}
		if ( units_clip != current_units || currentweapon != current_weapon )
		{
			if ( isDefined( counter_2 ) )
				stopFX( localclientnum, counter_2 );
			if ( viewmodelHasTag( localclientnum, AMMO_COUNTER_UNITS_TAG ) )
				counter_2 = playViewmodelFx( localclientnum, level._effect[ "ammo_counter" ][ units_clip ], AMMO_COUNTER_UNITS_TAG );
			
			current_units = units_clip;
		}
		current_weapon = currentweapon;
	}
}

