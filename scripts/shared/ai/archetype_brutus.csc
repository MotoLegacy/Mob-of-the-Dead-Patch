//
// MIT License
//
// Copyright (c) 2021 MotoLegacy, JariKCoding
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#using scripts\shared\ai_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\archetype_brutus.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;

#precache( "client_fx", BRUTUS_FOOTSTEP_FX_FILE );
#precache( "client_fx", BRUTUS_LOCKDOWN_FX_FILE );
#precache( "client_fx", BRUTUS_SPOTLIGHT_FX_FILE );
#precache( "client_fx", BRUTUS_DEATH_FX_FILE );
#precache( "client_fx", BRUTUS_SPAWN_FX_FILE );

function autoexec main() {
    clientfield::register( "actor", "brutus_helmet_detached", VERSION_DLC1, 1, "int", &BrutusClientUtils::brutus_detach_helmet, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "actor", "brutus_spotlight_off", VERSION_SHIP, 2, "int", &BrutusClientUtils::brutus_spotlight_off, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "scriptmover", "brutus_lockdown_fx", VERSION_SHIP, 2, "int", &BrutusClientUtils::brutus_lockdown_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

    ai::add_archetype_spawn_function( ARCHETYPE_BRUTUS, &BrutusClientUtils::brutusSpawn );
}

function autoexec precache() {
    level._effect[ BRUTUS_FOOTSTEP_FX ]				= BRUTUS_FOOTSTEP_FX_FILE;
    level._effect[ BRUTUS_SPOTLIGHT_FX ]		    = BRUTUS_SPOTLIGHT_FX_FILE;
    level._effect[ BRUTUS_LOCKDOWN_FX ]				= BRUTUS_LOCKDOWN_FX_FILE;
    level._effect[ BRUTUS_DEATH_FX ]				= BRUTUS_DEATH_FX_FILE;
    level._effect[ BRUTUS_SPAWN_FX ]				= BRUTUS_SPAWN_FX_FILE;
}   

#namespace BrutusClientUtils;

function private brutusSpawn( localClientNum ) {
	level._footstepCBFuncs[ self.archetype ] = &brutusProcessFootstep;
	// setting sound context with wait to ensure the entity is fully spawned  
	//level thread mechzSndContext( self );
	PlayFX( localClientNum, level._effect[ BRUTUS_SPAWN_FX ], self.origin );
	self.spotlight_fx = PlayFXOnTag( localClientNum, level._effect[ BRUTUS_SPOTLIGHT_FX ], self, BRUTUS_TAG_SPOTLIGHT );
    self MapShaderConstant(localClientNum, 0, "scriptVector2", 0, 1, 1, 1 );
	self.spotlight_on = true;
}

function brutusProcessFootstep( localClientNum, pos, surface, notetrack, bone ) {
	e_player = GetLocalPlayer( localClientNum );
	n_dist = DistanceSquared( pos, e_player.origin );
	n_brutus_dist = ( BRUTUS_FOOTSTEP_EARTHQUAKE_MAX_RADIUS * BRUTUS_FOOTSTEP_EARTHQUAKE_MAX_RADIUS );
	if(n_brutus_dist>0)
		n_scale = ( n_brutus_dist - n_dist ) / n_brutus_dist;
	else
		return;
	
	if( n_scale > 1 || n_scale < 0 ) return;
		
	if( n_scale <= 0.01 ) return;
	earthquake_scale = n_scale * 0.1;
	
	if( earthquake_scale > 0.01)
        e_player Earthquake( earthquake_scale, 0.1, pos, n_dist );
	
	if( n_scale <= 1 && n_scale > 0.8 )
		e_player PlayRumbleOnEntity( localClientNum, "shotgun_fire" );
	else if( n_scale <= 0.8 && n_scale > 0.4 )
		e_player PlayRumbleOnEntity( localClientNum, "damage_heavy" );
	else
		e_player PlayRumbleOnEntity( localClientNum, "reload_small" );
	
	fx = PlayFXOnTag( localClientNum, level._effect[ BRUTUS_FOOTSTEP_FX ], self, bone );
}

function brutus_detach_helmet( localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump )
{
	pos = self GetTagOrigin( BRUTUS_TAG_HELMET );
	ang = self GetTagAngles( BRUTUS_TAG_HELMET );
	velocity = self GetVelocity();

    //IPrintLnBold(pos);
	
	dynent = CreateDynEntAndLaunch( localClientNum, BRUTUS_MODEL_HELMET, pos + (0,0,30), ang, self.origin, velocity );
    //IPrintLnBold("launch helmet");
	//playFXonTag( localClientNum, level._effect[ MECHZ_FACEPLATE_OFF_FX ], self, BRUTUS_TAG_HELMET );
	//self setsoundentcontext("movement", "loud");
	//self playsound (0, "zmb_ai_mechz_faceplate");		
}

function brutus_lockdown_fx( localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump ) {
    if(newValue != 0) {
        self.brutuslockdownfx = PlayFXOnTag( localClientNum, level._effect[ BRUTUS_LOCKDOWN_FX ], self, "tag_origin" );
        players = GetLocalPlayers();
        for(i = 0; i < players.size; i++) {
            players[i] Earthquake( 0.5, 0.1, self.origin, 1500 );
            playerlocalclientnum = players[i] GetLocalClientNumber();
            PlayRumbleOnPosition( playerlocalclientnum, "damage_heavy", self.origin );
        }
    }
    else {
        StopFX(localClientNum, self.brutuslockdownfx);
    }
}

function brutus_spotlight_off( localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump ) {
	if( self.spotlight_on === true && newValue != 0 && isdefined( self.spotlight_fx )) {
		StopFX( localClientNum, self.spotlight_fx );
		self.spotlight_on = false;
        self MapShaderConstant(localClientNum, 0, "scriptVector2", 0, 0, 1, 1 );
		PlayFX( localClientNum, level._effect[ BRUTUS_DEATH_FX ], self.origin );
	}
}