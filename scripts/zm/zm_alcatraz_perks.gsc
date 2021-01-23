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

#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\exploder_shared;

#insert scripts\zm\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;

#precache( "xmodel", "p7_zm_vending_jugg_bo3_warp" );
#precache( "xmodel", "p7_zm_vending_sleight_bo3_warp" );
#precache( "xmodel", "p7_zm_vending_doubletap2_bo3_warp" );
#precache( "xmodel", "p7_zm_vending_packapunch_on_warp" );
#precache( "xmodel", "p7_zm_vending_deadshot_warp" );
#precache( "xmodel", "wardog_t6_perk_machine_cherry_warp" );

function autoexec init()
{
	level._effect["al_perk_warp"]	= "custom/jerri/al_perks/key_elec_fx";
	level thread jugg_warp_init();
	level thread speed_warp_init();
	level thread tap_warp_init();
	level thread cherry_warp_init();
	level thread ads_warp_init();
}

function jugg_warp_init()
{
	level waittill("juggernog_on");
	self PlayLoopSound("perksacola_loop");
	jugg_model = GetEntArray("vending_jugg","targetname");
	for ( i = 0; i < jugg_model.size; i++ )
	{
		jugg_model[i] thread machine_warp(JUGGERNAUT_MACHINE_DISABLED_MODEL,"p7_zm_vending_jugg_bo3_warp");
	}
}

function speed_warp_init()
{
	level waittill("sleight_on");
	self PlayLoopSound("perksacola_loop");
	speed_model = GetEntArray("vending_sleight","targetname");
	for ( i = 0; i < speed_model.size; i++ )
	{
		speed_model[i] thread machine_warp(SLEIGHT_OF_HAND_MACHINE_ACTIVE_MODEL,"p7_zm_vending_sleight_bo3_warp");
	}
}

function tap_warp_init()
{
	level waittill("doubletap_on");
	self PlayLoopSound("perksacola_loop");
	tap_model = GetEntArray(DOUBLETAP2_RADIANT_MACHINE_NAME,"targetname");
	for ( i = 0; i < tap_model.size; i++ )
	{
		tap_model[i] thread machine_warp(DOUBLETAP2_MACHINE_DISABLED_MODEL,"p7_zm_vending_doubletap2_bo3_warp");
	}
}

function ads_warp_init()
{
	level waittill("deadshot_on");
	self PlayLoopSound("perksacola_loop");
	ads_model = GetEntArray(DEADSHOT_RADIANT_MACHINE_NAME,"targetname");
	for ( i = 0; i < ads_model.size; i++ )
	{
		ads_model[i] thread machine_warp(DEADSHOT_MACHINE_ACTIVE_MODEL,"p7_zm_vending_deadshot_warp");
	}
}

function cherry_warp_init()
{
	level waittill("electric_cherry_on");
	self PlayLoopSound("perksacola_loop");
	cherry_model = GetEntArray(ELECTRIC_CHERRY_RADIANT_MACHINE_NAME,"targetname");
	for ( i = 0; i < cherry_model.size; i++ )
	{
		cherry_model[i] thread machine_warp(ELECTRIC_CHERRY_MACHINE_ACTIVE_MODEL,"wardog_t6_perk_machine_cherry_warp");
	}
}

function pap_warp_init()
{
	level waittill( "Pack_A_Punch_on" );
	IPrintLnBold("pap on");
	pap_model = GetEntArray("vending_packapunch","target");
	IPrintLnBold("pieces found: " + pap_model.size);
	for ( i = 0; i < pap_model.size; i++ )
	{
		pap_model[i].pap_machine thread machine_warp("p7_zm_vending_packapunch_on","p7_zm_vending_packapunch_on_warp");
	}
}

function machine_warp(old_model, new_model)
{
	while(1)
	{
		self SetModel(new_model);
		PlayFX(level._effect["al_perk_warp"],self.origin );
		rand = RandomIntRange(0,4);
		PlaySoundAtPosition("perka_warp_0" + rand, self.origin);
		wait RandomFloatRange(0.2,0.5);
		self SetModel(old_model);
		// moto - should only play once.
		//rand = RandomIntRange(0,4);
		//PlaySoundAtPosition("perka_warp_0" + rand, self.origin);
		PlayFX(level._effect["al_perk_warp"],self.origin );
		wait RandomFloatRange(0.7,1.2);
	}
}
