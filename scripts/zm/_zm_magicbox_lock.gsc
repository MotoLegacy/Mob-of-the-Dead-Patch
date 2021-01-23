#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_magicbox;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_zm_magicbox_prison;

#namespace zm_magicbox_lock;

function autoexec init()
{
	level.locked_magic_box_cost = 2000;
	level.custom_magicbox_state_handler = &set_locked_magicbox_state;
	zm_utility::add_zombie_hint( "locked_magic_box_cost", &"ZOMBIE_LOCKED_COST_2000" );
}

function watch_for_lock()
{
	self endon( "user_grabbed_weapon" );
	self endon( "chest_accessed" );
	self waittill( "box_locked" );
	self notify( "kill_chest_think" );
	self.grab_weapon_hint = 0;
	self.chest_user = undefined;
	wait 0.1;
	self thread zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
	self.unitrigger_stub zm_unitrigger::run_visibility_function_for_all_triggers();
	self thread zm_magicbox::treasure_chest_think();
}

function clean_up_locked_box()
{
	self endon( "box_spin_done" );
	self.owner waittill( "box_locked" );
	if ( isdefined( self.weapon_model ) )
	{
		self.weapon_model Delete();
		self.weapon_model = undefined;
	}
	if ( isdefined( self.weapon_model_dw ) )
	{
		self.weapon_model_dw Delete();
		self.weapon_model_dw = undefined;
	}
	self HideZBarrierPiece( 3 );
	self HideZBarrierPiece( 4 );
	self SetZBarrierPieceState( 3, "closed" );
	self SetZBarrierPieceState( 4, "closed" );
}

function magic_box_locks()
{
	self.owner.is_locked = 1;
	self.owner notify( "box_locked" );
	self PlaySound( "zmb_hellbox_lock" );
	self clientfield::set( "magicbox_open_fx", 0 );
	self clientfield::set( "magicbox_amb_fx", 2 );
	self SetZBarrierPieceState( 5, "closing" );
	while ( self GetZBarrierPieceState( 5 ) == "closing" )
	{
		wait 0.5;
	}
	self notify( "locked" );
}

function magic_box_unlocks()
{
	zm_unitrigger::unregister_unitrigger( self.owner.unitrigger_stub );
	self PlaySound( "zmb_hellbox_unlock" );
	self SetZBarrierPieceState( 5, "opening" );
	while ( self GetZBarrierPieceState( 5 ) == "opening" )
	{
		wait 0.5;
	}
	self SetZBarrierPieceState( 2, "closed" );
	self ShowZBarrierPiece( 2 );
	self HideZBarrierPiece( 5 );
	self notify( "unlocked" );
	self.owner.is_locked = 0;
	zm_unitrigger::register_unitrigger( self.owner.unitrigger_stub );
	self clientfield::set( "magicbox_amb_fx", 1 );
}

function set_locked_magicbox_state( state )
{
	switch( state )
	{
		case "locking":
			self ShowZBarrierPiece( 5 );
			self thread magic_box_locks();
			self.state = "locking";
			break;
		case "unlocking":
			self ShowZBarrierPiece( 5 );
			self magic_box_unlocks();
			self.state = "close";
			break;
	}
}
