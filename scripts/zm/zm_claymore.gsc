#using scripts\zm\_zm_score;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_util_shared;

#precache( "material", "claymore_hud" );
#precache( "material", "claymore_hud_inactive" );
#precache( "fx", "custom/weapon/fx_claymore_laser" );
#precache( "fx", "explosions/fx_exp_grenade_default" );

/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Zombie Claymores
Scripter: JBird632
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */

function init()
{	
	level._effect["claymore_laser"] = "custom/weapon/fx_claymore_laser";
	level._effect["explosion"] = "explosions/fx_exp_grenade_default";
	claymoreDetectionConeAngle = 70;
	level.claymoreDetectionDot = Cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 20;
	level.claymoreDetectionGracePeriod = .75;
	level thread purchaseClaymores();
	callback::on_spawned( &claymoreSetup );
}

function purchaseClaymores()
{
	oldtrigger = GetEnt("claymore_trigger", "targetname");
	

	trigger = Spawn( "trigger_radius_use", oldtrigger.origin, 0, 40, 40 );
	trigger SetCursorHint( "HINT_NOICON" );
	trigger TriggerIgnoreTeam();
	trigger SetVisibleToAll();
	trigger SetMovingPlatformEnabled( true ); 
	trigger UseTriggerRequireLookAt();
	oldtrigger Delete();
	trigger.zombie_cost = 1000;	
	trigger sethintstring( &"ZOMBIE_CLAYMORE_PURCHASE" );	
	trigger setCursorHint( "HINT_NOICON" );
	trigger.claymore_triggered = false;
	
	level thread give_claymores_after_rounds();

	while(1)
	{
		trigger waittill("trigger", player);
		if ( player zm_utility::in_revive_trigger() )
		{
			continue;
		}
		while ( player zm_utility::has_powerup_weapon() )
		{
			wait 0.1;
		}
		if ( zm_utility::is_player_valid( player ) )
		{
			if( player.score >= trigger.zombie_cost )
			{				
				if ( !player zm_utility::is_player_placeable_mine( GetWeapon("claymore") ) )
				{
					player thread show_claymore_hint( "claymore_purchased" );
					PlaySoundAtPosition( "purchase", trigger.origin );
					player zm_score::minus_to_player_score( trigger.zombie_cost );
					player thread zm_audio::create_and_play_dialog( "weapon_pickup", "grenade" );
					player thread giveClaymores();

					if( trigger.claymore_triggered == false )
					{
						model = getent( trigger.target, "targetname" );
						trigger.claymore_triggered = true;
					}

					trigger SetInvisibleToPlayer(player);
				}
				else {
					player thread show_claymore_hint( "already_purchased" );
				}
			}
		}
		wait(0.05);
	}
}

function give_claymores_after_rounds() {
	level endon("intermission");

	while(1) {
		level waittill( "between_round_over" );
		
		foreach(player in GetPlayers()) {
			if(isdefined(player.has_claymores) && player.has_claymores) {
				claymore = GetWeapon("claymore");
				ammo = player GetWeaponAmmoClip( claymore );
				
				if(ammo < 2) {
					player  GiveWeapon(claymore);
					player 	zm_utility::set_player_placeable_mine( claymore );
					player  SetActionSlot(4,"weapon",claymore);
					player  SetWeaponAmmoClip(claymore,2);
				}
			}
		}
		
		wait(0.05);
	}
}

function giveClaymores()
{
	claymore = getWeapon("claymore");
	self.has_claymores = true;
	self giveweapon(claymore);
	self zm_utility::set_player_placeable_mine( claymore );
	self setactionslot(4, "weapon", claymore);
	self setweaponammoclip(claymore, 2);
	self thread claymore_death_think();

	// Hud
	self.claymoreHud = NewClientHudElem( self );
	self.claymoreHud SetShader( "claymore_hud", 18, 18 );
	self.claymoreHud.horzAlign = "right";
	self.claymoreHud.vertAlign = "bottom";
	self.claymoreHud.x = -36;
	self.claymoreHud.y = -73;
	self.claymoreHud.foreground = true;
	self.claymoreHud.alpha = 1;

	self thread manageClaymoreHud();

	self waittill("death");
	self.claymoreHud hud::destroyElem();
	self.claymoreHud = undefined;
}

function manageClaymoreHud()
{
	self endon("death");

	while(1)
	{
		claymore = GetWeapon("claymore");
		ammo = self GetWeaponAmmoClip( claymore );

		if(ammo <= 0)
			self.claymoreHud SetShader("claymore_hud_inactive", 18, 18);
		else
			self.claymoreHud SetShader("claymore_hud", 18, 18);

		wait(0.1);
	}
}

function init_hint_hudelem( x, y, alignx, aligny, fontscale, alpha )
{
	self.x = x;
	self.y = y;
	self.alignx = alignx;
	self.aligny = aligny;
	self.fontscale = fontscale;
	self.alpha = alpha;
	self.sort = 20;
}

function setup_client_hintelem()
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isdefined( self.hintelem ) )
	{
		self.hintelem = NewClientHudElem( self );
	}
	self.hintelem init_hint_hudelem( 320, 220, "center", "bottom", 1.6, 1 );
}

function show_claymore_hint( string )
{
	self endon( "death" );
	self endon( "disconnect" );
	if ( string == "claymore_purchased" )
	{
		text = &"ZOMBIE_CLAYMORE_HOWTO";
	}
	else
	{
		text = &"ZOMBIE_CLAYMORE_ALREADY_PURCHASED";
	}
	self setup_client_hintelem();
	self.hintelem SetText( text );
	wait 3.5;
	self.hintelem SetText( "" );
	self.hintelem Destroy();
}


function claymore_death_think(claymore)
{
	self waittill("death");

	self.has_claymores = false;
	claymore delete_claymore();
}

function claymoreSetup()
{
	self.has_claymores = false;
	self thread watchClaymores();
}

function watchClaymores()
{
	self endon("disconnect");
	self endon("death");
	
	while(1)
	{
		self waittill( "grenade_fire", claymore, weap );
		
		if(isdefined(weap) && weap.name == "claymore")
		{
			self addClaymoreArray( claymore );
			
			claymore.angles = self.angles;
			claymore.owner = self;
			claymore thread claymoreDetonation();
			claymore thread playClaymoreEffects();
			self thread claymore_death_think(claymore);
		}
	}
}

function claymoreDetonation()
{
	self endon("clyamore_pickup");
	
	self playsound("claymore_plant");
	
	wait(1.1);
	
	detonateRadius = 96;
	
	trigger = spawn("trigger_radius", self.origin + (0,0,0-detonateRadius), 9, detonateRadius, detonateRadius*2);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetInvisibleToAll();
	trigger setvisibletoplayer( self.owner );
	trigger.owner = self.owner;
	trigger sethintstring( "Hold ^3&&1^7 to pick up Claymore" );
	
	trigger enablelinkto();
	trigger linkto( self );
			
	while(1)
	{
		trigger waittill( "trigger", player );
		if(player shouldAffectClaymore( self ) && player != self.owner)
			break;
		else if(player == self.owner)
		{
			trigger delete();
			self pickup_claymores();
			self notify("claymore_pickup");
		}
		wait(0.05);
	}
	
	self notify("claymore_detonate");
	self playsound("claymore_alert");
	wait(0.25);	
	playfx(level._effect["explosion"], self.origin);
	fake_model = spawn("script_model",self.origin);
	fake_model setmodel(self.model);
	self hide();
	tag_origin = spawn("script_model",self.origin);
	tag_origin setmodel("tag_origin");
	tag_origin linkto(fake_model);
	self playsound("claymore_explode");
	earthquake(1, .4, fake_model.origin, 512);
	zombs = getaispeciesarray("axis");
	
	for(i=0;i<zombs.size;i++)
	{
		if(!zombs[i] shouldAffectClaymore( self ))
			continue;
			
		if(zombs[i].origin[2] < fake_model.origin[2] + 80 && zombs[i].origin[2] > fake_model.origin[2] - 80 && DistanceSquared(zombs[i].origin, fake_model.origin) < 200 * 200)
		{
			if(isdefined(zombs[i].is_brutus) && zombs[i].is_brutus)
				zombs[i] doDamage( 500, self.origin);
			else
				zombs[i] doDamage(zombs[i].health + 666, self.origin);
			self.owner zm_score::add_to_player_score(60);
			self.owner.kills++;
		}
	}
	
	trigger delete();
	fake_model delete();
	tag_origin delete();
		
	if( isdefined( self ) )
		self delete();
}

function shouldAffectClaymore( claymore )
{
	pos = self.origin + (0,0,32);
	
	dirToPos = pos - claymore.origin;
	claymoreForward = AnglesToForward( claymore.angles );
	
	dist = VectorDot( dirToPos, claymoreForward );
	if ( dist < level.claymoreDetectionMinDist )
		return false;
	
	dirToPos = vectornormalize( dirToPos );
	
	dot = VectorDot( dirToPos, claymoreForward );
	return ( dot > level.claymoreDetectionDot );
}

function pickup_claymores()
{
	self endon("death");

	claymore = GetWeapon("claymore");
	ammo = self.owner GetWeaponAmmoClip( claymore );
	if(ammo < 2)
		new_ammo = self.owner GetWeaponAmmoClip( claymore ) + 1;
	else
		new_ammo = 2;
	self.owner  giveweapon(claymore);
	self.owner zm_utility::set_player_placeable_mine( claymore );
	self.owner  setactionslot(4,"weapon",claymore);
	self.owner  setweaponammoclip(claymore,new_ammo);
	self Delete();
}

function playClaymoreEffects()
{
	fx = spawn("script_model", self.origin - (0,0,50));
	fx.angles = self.angles;
	fx setmodel("tag_origin");
	
	playfxontag(level._effect["claymore_laser"], fx, "tag_origin");
	
	while(isDefined(self))
		wait(0.05);
	
	fx delete();
}

function addClaymoreArray( claymore )
{
	if( !isdefined(self.claymoreArray) )
		self.claymoreArray = [];
	
	if( self.claymoreArray.size >= 10 )
	{
		newArray = [];
		explodingClaymore = self.claymoreArray[0];
		
		for( i = 1; i < self.claymoreArray.size; i++ )
		{
			index = newArray.size;
			newArray[index] = self.claymoreArray[i];
			newArray[index].index = index;
		}
			
		explodingClaymore thread earlyExplode();
		self.claymoreArray = newArray;
	}
	
	index = self.claymoreArray.size;
	self.claymoreArray[index] = claymore;
	self.claymoreArray[index].index = index;
}

function removeClaymoreArray( claymore )
{
	newArray = [];
	skipIndex = claymore.index;
	
	for( i = 0; i < self.claymoreArray.size; i++ )
	{
		if( i == skipIndex )
			continue;
			
		index = newArray.size;
		newArray[index] = self.claymoreArray[i];
		newArray[index].index = index;
	}
	
	self.claymoreArray = newArray;
	
	claymore thread delete_claymore();
}

function earlyExplode()
{
	self notify("early_explode");
	self notify("claymore_detonate");
	
	self playsound("claymore_alert");
	wait(0.1);
	playfx(level._effect["explosion"], self.origin);
	earthquake(1, .4, self.origin, 512);
	zombs = getaispeciesarray("axis");
	
	for(i=0;i<zombs.size;i++)
	{
		if(!zombs[i] shouldAffectClaymore( self ))
			continue;
		if(zombs[i].origin[2] < self.origin[2] + 80 && zombs[i].origin[2] > self.origin[2] - 80 && DistanceSquared(zombs[i].origin, self.origin) < 200 * 200)
		{
			zombs[i] doDamage(zombs[i].health + 666, self.origin);
			self.owner zm_score::add_to_player_score(60);
			self.owner.kills++;
		}
	}
	
	playsoundatposition("claymore_explode", self.origin);
	self thread delete_claymore();
}

function delete_claymore()
{
	self notify("deleted");
	
	if(isdefined(self.trigger))
		self.trigger delete();
	if(isdefined(self))
		self delete();
}