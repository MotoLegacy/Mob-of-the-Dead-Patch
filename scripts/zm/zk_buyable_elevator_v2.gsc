// ZombieKid164's buyable elevator
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;

#using_animtree( "generic" );

function autoexec init()
{
	level flag::wait_till("initial_players_connected");
	//Things you can edit below \/
	//level.elevator_cost = 0; // Change this to change the cost of the elevator. Leave it undefined to make it free.
	level.elevate_height = 525; //This is how far the elevator will travel up.
	level.elevator_transition_time = 5; //How long it will take for the elevator travel.
	level.elevator_cooldown_time = 10; // Cooldown time of the elevator.
	level.zk_debug = false; //Enable or disable this to show action text in game. (Ex: "Debug: Elevator Moving" will be shown on the screen)
	level.change_door_direction = true; //Change this to true if your doors slide backwards or forwards instead of side to side.
	//Things you can edit above /\

	level.elevator_trigger = GetEnt( "elevator_trigger", "targetname" );
	level.elevator_trigger_top = GetEnt( "elevator_trigger_top", "targetname" );
	level.elevator_trigger_outside_bottom = GetEnt( "elevator_trigger_outside_bottom", "targetname");
	level.elevator_trigger_outside_top = GetEnt( "elevator_trigger_outside_top", "targetname");
	level.elevator_models = GetEntArray("elevator", "targetname" );
	level.elevator_top_door = GetEnt("top_door", "targetname" );
	level.elevator_bottom_door = GetEnt("bottom_door", "targetname" );
	level.elevator_top_door_clip = GetEnt("top_door_clip", "targetname" );
	level.elevator_bottom_door_clip = GetEnt("bottom_door_clip", "targetname" );
	level.elevator_top_door UseAnimTree(#animtree);
	level.elevator_bottom_door UseAnimTree(#animtree);
	level.elevator_called = false;
	main(); 
}

function main()
{
	level endon( "intermission" ); 
	wait_for_power();
	level notify("marathon_on");
	thread bottom_door_open();
	level.elevator_trigger_top SetHintString( "" );

	while(1)
	{
		thread wait_for_buy_bottom();
		thread wait_for_call_top();
		thread zk_print("Waiting for Buy or Call");
		level waittill("Elevator_Used");
		level notify("elevator_moving");
		thread zk_print("Elevator Moving");
		thread clear_trigger_text();

		thread bottom_door_close();
		wait(1);
		thread elevator_rise( level.elevate_height, level.elevator_transition_time );
		wait( level.elevator_transition_time );
		thread top_door_open();
		level.elevator_trigger_top SetHintString( "Elevator is cooling down." );
		level.elevator_trigger_outside_bottom SetHintString( "Elevator is cooling down." );
		wait( level.elevator_cooldown_time );

		thread wait_for_buy_top();
		thread wait_for_call_bottom();
		thread zk_print("Waiting for Buy or Call");
		level waittill("Elevator_Used");
		level notify("elevator_moving");
		thread zk_print("Elevator Moving");
		thread clear_trigger_text();

		level.elevator_trigger_top SetHintString( "" );
		thread top_door_close();
		wait(1);
		thread elevator_fall( level.elevate_height, level.elevator_transition_time );
		wait( level.elevator_transition_time );
		thread bottom_door_open();
		level.elevator_trigger SetHintString( "Elevator is cooling down." );
		level.elevator_trigger_outside_top SetHintString( "Elevator is cooling down." );
		wait( level.elevator_cooldown_time );
	}
}

function elevator_rise( height, speed )
{
	foreach(model in level.elevator_models)
	{
		model movez (height, speed);
	}
	level.elevator_models[0] waittill ("movedone");
}

function elevator_fall( height, speed )
{
	foreach(model in level.elevator_models)
	{
		model movez (height - (height * 2), speed);
	}
	level.elevator_models[0] waittill ("movedone");
}

function bottom_door_open()
{
	level.elevator_bottom_door_clip Hide();
	level.elevator_bottom_door_clip ConnectPaths();
	level.elevator_bottom_door AnimScripted( "notify" , level.elevator_bottom_door.origin , level.elevator_bottom_door.angles, %p7_fxanim_zm_zod_gate_scissor_open_anim );
}

function bottom_door_close()
{
	level.elevator_bottom_door_clip Show();
	level.elevator_bottom_door_clip DisconnectPaths();
	level.elevator_bottom_door AnimScripted( "notify" , level.elevator_bottom_door.origin , level.elevator_bottom_door.angles, %p7_fxanim_zm_zod_gate_scissor_close_anim );
}

function top_door_open()
{
	level.elevator_top_door_clip Hide();
	level.elevator_top_door_clip ConnectPaths();
	level.elevator_top_door AnimScripted( "notify" , level.elevator_top_door.origin , level.elevator_top_door.angles, %p7_fxanim_zm_zod_gate_scissor_open_anim );
}

function top_door_close()
{
	level.elevator_top_door_clip Show();
	level.elevator_top_door_clip DisconnectPaths();
	level.elevator_top_door AnimScripted( "notify" , level.elevator_top_door.origin , level.elevator_top_door.angles, %p7_fxanim_zm_zod_gate_scissor_close_anim );
}

function wait_for_power()
{
	level.elevator_trigger_outside_bottom SetHintString( &"ZOMBIE_NEED_POWER" );
	level.elevator_trigger_outside_top SetHintString( &"ZOMBIE_NEED_POWER" );
	level waittill("elevator_activate");
	level.elevator_trigger_outside_bottom SetHintString( "" );
	level.elevator_trigger_outside_top SetHintString( "" );
	thread zk_print("Starting Elevator");
}

function wait_for_buy_bottom()
{
	level endon("elevator_moving");
	if( isDefined(level.elevator_cost) )
	{
		while(1)
		{
			level.elevator_trigger SetHintString( "Hold ^3&&1^7 to Use Elevator [Cost: "+level.elevator_cost+"]" ); 
			level.elevator_trigger waittill( "trigger", player ); 
			if( isDefined(level.elevator_cost) && player.score >= level.elevator_cost )
			{
				player zm_score::minus_to_player_score( level.elevator_cost );
				level notify("Elevator_Used");
				thread zk_print("Elevator Bought");
				break; 
			}
			else if( isDefined( level.elevator_cost ) && player.score < level.elevator_cost )
			{
				level.elevator_trigger SetHintString( "You do not have enough money." );
				wait(4); 
				level.elevator_trigger SetHintString( "Hold ^3&&1^7 to Use Elevator [Cost: "+level.elevator_cost+"]" );
				continue; 
			}
		}
	}
	else 
	{
		level.elevator_trigger SetHintString( "Hold ^3&&1^7 to Use Elevator" ); 
		level.elevator_trigger waittill( "trigger", player ); 
		level.elevator_trigger SetHintString( "" );
		level notify("Elevator_Used");
		thread zk_print("Elevator Bought [Free]");
	}
}

function wait_for_buy_top()
{
	level endon("elevator_moving");
	if( isDefined(level.elevator_cost) )
	{
		while(1)
		{
			level.elevator_trigger_top SetHintString( "Hold ^3&&1^7 to Use Elevator [Cost: "+level.elevator_cost+"]" ); 
			level.elevator_trigger_top waittill( "trigger", player ); 
			if( isDefined(level.elevator_cost) && player.score >= level.elevator_cost )
			{
				player zm_score::minus_to_player_score( level.elevator_cost );
				level notify("Elevator_Used");
				thread zk_print("Elevator Bought");
				break; 
			}
			else if( isDefined( level.elevator_cost ) && player.score < level.elevator_cost )
			{
				level.elevator_trigger_top SetHintString( "You do not have enough money." );
				wait(4); 
				level.elevator_trigger_top SetHintString( "Hold ^3&&1^7 to Use Elevator [Cost: "+level.elevator_cost+"]" );
				continue; 
			}
		}
	}
	else 
	{
		level.elevator_trigger_top SetHintString( "Hold ^3&&1^7 to Use Elevator" ); 
		level.elevator_trigger_top waittill( "trigger", player ); 
		level.elevator_trigger_top SetHintString( "" );
		level notify("Elevator_Used");
		thread zk_print("Elevator Bought [Free]");
	}
}

function wait_for_call_bottom()
{
	self endon("elevator_moving");
	level.elevator_trigger_outside_bottom SetHintString( "Hold ^3&&1^7 to Call Elevator" );
	level.elevator_trigger_outside_bottom waittill( "trigger", player ); 
	level.elevator_trigger_outside_bottom SetHintString( "" );
	level notify("Elevator_Used");
	thread zk_print("Elevator Called");
}

function wait_for_call_top()
{
	self endon("elevator_moving");
	level.elevator_trigger_outside_top SetHintString( "Hold ^3&&1^7 to Call Elevator" );
	level.elevator_trigger_outside_top waittill( "trigger", player ); 
	level.elevator_trigger_outside_top SetHintString( "" );
	level notify("Elevator_Used");
	thread zk_print("Elevator Called");
}

function zk_print( string ) 
{
	if( level.zk_debug == true )
	{
		iprintlnbold( "Debug: "+string ); 
	}
}

function clear_trigger_text()
{
	level.elevator_trigger_outside_top SetHintString( "" );
	level.elevator_trigger_outside_bottom SetHintString( "" );
	level.elevator_trigger SetHintString( "" );
	level.elevator_trigger_top SetHintString( "" );
}