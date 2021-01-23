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

#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perks;
#insert scripts\zm\_zm_perks.gsh;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
//#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;


#using scripts\zm\zm_usermap;

// Hells Tomahawk
    #using scripts\zm\zm_weap_tomahawk;

//Elevator
    #using scripts\zm\zk_buyable_elevator_v2;

//Perk Warps
#using scripts\zm\zm_alcatraz_perks;

//Claymore
#using scripts\zm\zm_claymore;

//Custom Box
#using scripts\zm\_zm_magicbox_prison;  

//Dog Heads
#using scripts\zm\zm_prison_weap_quest;

//Music Easter Egg
#using scripts\zm\_zm_easteregg_song;

#using scripts\zm\_zm_ai_brutus;
#using scripts\shared\ai\archetype_brutus;

#using scripts\zm\zm_prison_travel;
#using scripts\zm\zm_prison_traps;
#using scripts\zm\zm_alcatraz_craftables;
#using scripts\zm\_zm_afterlife;
#using scripts\zm\zm_alcatraz_sq;
#using scripts\zm\zm_prison_sq_final;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    // Wall uzi changes
    structs = struct::get_array("weapon_upgrade", "targetname");
	foreach(struct in structs) {
    	if(struct.zombie_weapon_upgrade == "bo2_uzi") {
        	struct.zombie_weapon_upgrade = "smg_uzi";
    	}
	}

    // Fix box spot
    wardenBox = struct::get("chest_2", "script_noteworthy");
    wardenBoxBarrier = GetEnt("chest_2_zbarrier", "script_noteworthy");
    cafeBox = struct::get("start_chest", "script_noteworthy");
    cafeBoxBarrier = GetEnt("start_chest_zbarrier", "script_noteworthy");

    if (RandomInt(2)) {
        cafeBox.script_noteworthy = "chest_2";
        cafeBoxBarrier.script_noteworthy = "chest_2_zbarrier";
        wardenBox.script_noteworthy = "start_chest";
        wardenBoxBarrier.script_noteworthy = "start_chest_zbarrier";
    }

    
    //level thread intro_credits();

    level thread alpha_hud_init();

    callback::on_connect(&check_shield_ammo); 

    level thread _zm_afterlife::give_afterlife();
    level thread _zm_afterlife::init(); 
    level thread zm_alcatraz_sq::start_alcatraz_sidequest();
    level thread zm_alcatraz_craftables::include_craftables();
    level thread zm_alcatraz_craftables::init_craftables();
    level thread zm_prison_sq_final::stage_one();

    level.dog_rounds_allowed = false;

    zm_usermap::main();

    callback::on_spawned(&give_knife);

    callback::on_spawned( &bo2_deathhands );
    callback::on_connect( &adjust_aflives );
    
    startingWeapon = "bo3_m1911";
    weapon = getWeapon(startingWeapon);
    level.start_weapon = (weapon);
    level._zombie_custom_add_weapons =&custom_add_weapons;
    
    level.pack_a_punch_camo_index = 26;
    
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func =&usermap_test_zone_init;
    init_zones[0] = "start_zone";
    init_zones[1] = "library_zone";
    init_zones[2] = "gondola_ride_zone";
    init_zones[3] = "bridge_zone";
    level thread zm_zonemgr::manage_zones( init_zones );

    level thread zm_claymore::init();
    level thread zm_easteregg_song::init();

    level.pathdist_type = PATHDIST_ORIGINAL;
    level thread play_location_music_init();

    // changing starting points
    level.player_starting_points = 500;

    // Remove perk limit
	level.perk_purchase_limit = 6;

    level thread lightningstrikes_init();

    level flag::wait_till( "initial_blackscreen_passed" );
    
    level thread zm_perks::spare_change();
    level thread permapowerup();
    level thread fix_door_sounds();
}

function fix_door_sounds()
{
    // Door sounds
    sdoors = GetEntArray("spawn_door", "targetname"); 
    spawnDoor = ArrayGetClosest((2034.24, 75.283, 5606.34), sdoors);
    spawnDoor.script_sound = "sml_door_open_00";

    spawnCell = ArrayGetClosest((203.489, -224.637, 5607.59), sdoors);
    spawnCell.script_sound = "prison_bar_door";

    zdoors = GetEntArray("cell_connecting_door", "targetname");
    cellDoor = ArrayGetClosest((1543.73, -1306.04, 5714.84), zdoors);
    cellDoor.script_sound = "prison_bar_door";

    cafeArr = GetEntArray("cafe_slide_door", "targetname");
    cafeDoor = ArrayGetClosest((2133.74, -942.807, 5609.31), cafeArr);
    cafeDoor.script_sound = "prison_bar_door";

    wotoug = GetEntArray("wo_to_ug_door", "targetname");
    wo_to_ug_door = ArrayGetClosest((-534.422, -1981.55, 5398.1), wotoug);
    wo_to_ug_door.script_sound = "sml_door_open_00";

    shtoug = GetEntArray("showera_to_ug_door", "targetname");
    showera_to_ug_door = ArrayGetClosest((1020.83, -476.939, 5384.12), shtoug);
    showera_to_ug_door.script_sound = "sml_door_open_00";

    fff = GetEntArray("ug_to_t_door", "targetname");
    ug_to_t_door = ArrayGetClosest((195.794, -1146.17, 5368.91), fff);
    ug_to_t_door.script_sound = "prison_bar_door";

    fff = GetEntArray("tunnel_to_ug_docks_door", "targetname");
    tunnel_to_ug_docks_door = ArrayGetClosest((-40.5519, -2248.93, 4515.08), fff);
    tunnel_to_ug_docks_door.script_sound = "sml_door_open_00";

    fff = GetEntArray("docks_ug_to_room_zone", "targetname");
    docks_ug_to_room_zone = ArrayGetClosest((-554.634, -3305.17, 4393.45), fff);
    docks_ug_to_room_zone.script_sound = "prison_bar_door";

    fff = GetEntArray("docks_room_to_docks_zone", "targetname");
    docks_room_to_docks_zone = ArrayGetClosest((-169.809, -3957.66, 4393.45), fff);
    docks_room_to_docks_zone.script_sound = "sml_door_open_00";

    fff = GetEntArray("docks_ug_to_jugg", "targetname");
    docks_ug_to_jugg = ArrayGetClosest((146.125, -3465.73, 4619.18), fff);
    docks_ug_to_jugg.script_sound = "prison_bar_door";

    fff = GetEntArray("dog_door", "targetname");
    dog_door = ArrayGetClosest((504.318, -1214.23, 5707.27), fff);
    dog_door.script_sound = "prison_bar_door";

    fff = GetEntArray("ele_door", "targetname");
    ele_door = ArrayGetClosest((505.001, -510.297, 5822.81), fff);
    ele_door.script_sound = "prison_bar_door";

    fff = GetEntArray("infir_or_cb_door", "targetname");
    infir_or_cb_door = ArrayGetClosest((2246.87, -1058.13, 5818.97), fff);
    infir_or_cb_door.script_sound = "sml_door_open_00";

    fff = GetEntArray("cafe_stairs_door", "targetname");
    cafe_stairs_door = ArrayGetClosest((2311.61, -742.277, 5608.31), fff);
    cafe_stairs_door.script_sound = "sml_door_open_00";

    fff = GetEntArray("door_to_base", "targetname");
    door_to_base = ArrayGetClosest((2145.36, -1028.28, 5610.56), fff);
    door_to_base.script_sound = "prison_bar_door";

    roof_door_model = GetEnt("roof_door_model", "targetname");
    roof_door_model.script_sound = "sml_door_open_00";
}

function usermap_test_zone_init()
{
    //Spawn Zones - Left Side - 
    zm_zonemgr::add_adjacent_zone("start_zone", "cellblock_leftside_zone", "enter_leftside_zone");
    zm_zonemgr::add_adjacent_zone("cellblock_leftside_zone", "cellblock_leftside_zone_b");
    zm_zonemgr::add_adjacent_zone("cellblock_leftside_zone_b", "cellblock_leftside_zone_c");
    zm_zonemgr::add_adjacent_zone("cellblock_leftside_zone_b", "cellblock_hallway_zone", "enter_main_cell_zone");

    //Spawn Zones - Right Side - 
    zm_zonemgr::add_adjacent_zone("library_zone", "cellblock_rightside_zone", "enter_rightside_zone");
    zm_zonemgr::add_adjacent_zone("cellblock_rightside_zone", "cellblock_dogfeeder_zone");
    zm_zonemgr::add_adjacent_zone("cellblock_dogfeeder_zone", "cellblock_dogfeeder_zone_b");
    zm_zonemgr::add_adjacent_zone("cellblock_dogfeeder_zone_b", "cellblock_dogfeeder_zone_c");

    //Main CellBlock Zones
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone_c", "cellblock_hallway_zone", "enter_main_cell_zone_v2");
    zm_zonemgr::add_adjacent_zone("cellblock_hallway_zone", "cellblock_out_wardens_zone");
    zm_zonemgr::add_adjacent_zone("cellblock_out_wardens_zone", "cellblock_out_wardens_zone_b");
    zm_zonemgr::add_adjacent_zone("cellblock_out_wardens_zone", "cutoff_wardens_zone");

    //Wardens Office Zones
    zm_zonemgr::add_adjacent_zone("cellblock_out_wardens_zone", "wardens_zone", "enter_wardens_zone");
    zm_zonemgr::add_adjacent_zone("wardens_zone", "wardens_ext_zone"); 

    //Top Section of Cell Block Zones
    zm_zonemgr::add_adjacent_zone("cellblock_rightside_zone", "top_dogfeeder_zone", "enter_ele_zone");
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone", "top_dogfeeder_zone_b");
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone_b", "top_dogfeeder_zone_c");
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone_c", "gondola_roof_zone");
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone_b", "top_dogfeeder_zone_d");
    zm_zonemgr::add_adjacent_zone("top_dogfeeder_zone_d", "top_dogfeeder_zone_e");
    zm_zonemgr::add_adjacent_zone("cellblock_dogfeeder_zone_e", "infirmary_zone", "enter_cb_or_infir_zone");


    //Infirmary Zones
    zm_zonemgr::add_adjacent_zone("cafe_stair_zone", "infirmary_zone");
    zm_zonemgr::add_adjacent_zone("infirmary_zone", "infirmary_zone_b");
    zm_zonemgr::add_adjacent_zone("infirmary_zone_b", "infirmary_zone_c");
  

    //Cafe Zones
    zm_zonemgr::add_adjacent_zone("cellblock_leftside_zone_b", "cafe_zone", "enter_cafe_zone");
    zm_zonemgr::add_adjacent_zone("cafe_zone", "cafe_zone_b");
    zm_zonemgr::add_adjacent_zone("cafe_zone", "cafe_stair_zone", "enter_cafe_stairs_zone");

    //Base Zones
    zm_zonemgr::add_adjacent_zone("cafe_zone", "base_zone", "enter_base_zone");
    zm_zonemgr::add_adjacent_zone("base_zone", "base_lift_zone");
    zm_zonemgr::add_adjacent_zone("base_lift_zone", "under_base_zone");

    //Roof Zones
    zm_zonemgr::add_adjacent_zone("infirmary_zone_c", "roof_zone", "enter_roof_zone");
    zm_zonemgr::add_adjacent_zone("roof_zone", "roof_zone_b");


    //Shower Zones
    zm_zonemgr::add_adjacent_zone("cellblock_leftside_zone_b", "shower_zone", "enter_shower_zone");
    zm_zonemgr::add_adjacent_zone("shower_zone", "underground_ss_zone");
    zm_zonemgr::add_adjacent_zone("underground_ss_zone", "underground_zone", "enter_ug_f_s_zone");

    //Underground Zones
    zm_zonemgr::add_adjacent_zone("cellblock_out_wardens_zone_b", "underground_wo_zone", "enter_underground_zone");
    zm_zonemgr::add_adjacent_zone("underground_wo_zone", "underground_zone_c");
    zm_zonemgr::add_adjacent_zone("underground_zone_c", "underground_zone_b");
    zm_zonemgr::add_adjacent_zone("underground_zone_b", "underground_zone_d");
    zm_zonemgr::add_adjacent_zone("underground_zone_b", "underground_zone");
 
 
    //Tunnel Zones
    zm_zonemgr::add_adjacent_zone("underground_zone_d", "tunnel_stairs_zone", "enter_tunnel_zone");
    zm_zonemgr::add_adjacent_zone("tunnel_stairs_zone", "tunnel_stairs_zone_b");
    zm_zonemgr::add_adjacent_zone("tunnel_stairs_zone_b", "tunnel_zone");
    zm_zonemgr::add_adjacent_zone("tunnel_zone", "tunnel_zone_b");
    zm_zonemgr::add_adjacent_zone("tunnel_zone_b", "tunnel_zone_c");


    //Underground Before Docks
    zm_zonemgr::add_adjacent_zone("tunnel_zone_b", "ug_docks_zone", "enter_ug_docks_zone");
    zm_zonemgr::add_adjacent_zone("ug_docks_zone", "ug_docks_zone_b");
    zm_zonemgr::add_adjacent_zone("ug_docks_zone_b", "ug_docks_zone_c");
    zm_zonemgr::add_adjacent_zone("ug_docks_zone_c", "ug_docks_zone_d");
    zm_zonemgr::add_adjacent_zone("ug_docks_zone_d", "ug_docks_zone_e");


    //Underground Docks Room
    zm_zonemgr::add_adjacent_zone("ug_docks_zone_d", "docks_room_zone", "enter_docks_room_zone");
    zm_zonemgr::add_adjacent_zone("docks_room_zone", "docks_room_zone_b");
    zm_zonemgr::add_adjacent_zone("docks_room_zone", "docks_zone", "enter_docks_zone");


    //Docks Zones
    zm_zonemgr::add_adjacent_zone("ug_docks_zone_e", "upper_docks_zone", "enter_docks_jugg_zone");
    zm_zonemgr::add_adjacent_zone("upper_docks_zone", "docks_zone");
    zm_zonemgr::add_adjacent_zone("docks_zone", "docks_zone_b");
    zm_zonemgr::add_adjacent_zone("docks_zone_b", "docks_zone_c");


    level flag::init( "always_on" );
    level flag::set( "always_on" );
}   

function custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_motd_weapons.csv", 1);
}

function give_knife()
{
    //self GiveWeapon(GetWeapon("sps_shank"));
}
    function autoexec alpha_hud_init()
{
    callback::on_spawned( &alpha_hud );
}

function alpha_hud()
{
    //self thread creat_alpha_hud( "Shifty If Seen", 65, 25, 2, 5, "left", "bottom" );
    //self thread creat_alpha_hud( self.name, 65, 50, 2, 5, "left", "bottom" );
    //self thread creat_alpha_hud( "Mob of the Dead Remastered Fixes [BETA]", 2, 5, 2, 5, "left", "top" );
    //self thread creat_alpha_hud( "Mob of the Dead", -20, -50, 2, 5, "right", "top" );
    //self thread creat_alpha_hud( self.name, -100, -230, 2, 5, "center", "center" );
    //self thread creat_alpha_hud( self.name, 100, -230, 2, 5, "center", "center" );
}


/*function intro_credits()
{
    thread creat_simple_intro_hud( "Alcatraz Island", 30, 100, 4, 5, "left", "bottom" );
    thread creat_simple_intro_hud( "Mob of the Dead", 71, 75, 2, 5, "left", "bottom" );
    thread creat_simple_intro_hud( "31/12/1933", 82, 50, 2, 5 , "left", "bottom" );
    thread creat_simple_intro_hud( "Map Made By: ShiftyGam3r101", -35, -20, 2, 5, "right", "top" );
    thread creat_simple_intro_hud( "Scripter: JerriGaming", -20, -45, 2, 5, "right", "top" );
    thread creat_simple_intro_hud( "All Other Addition Helpers Found In Credits!", -60, -70, 2, 5 , "right", "top" );
}*/


function creat_alpha_hud( text, align_x, align_y, font_scale, fade_time, alignx, aligny )
{
    hud = NewClientHudElem(self);
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = false;
    hud.alignX = alignx;
    hud.alignY = aligny;
    hud.horzAlign = alignx;
    hud.vertAlign = aligny;
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 0.4;
    hud SetText( text );
}

function lightningstrikes_init()
{
    structs = struct::get_array("lightning_struct","targetname");
    level._effect["lightning_fx"]    = "weather/fx_lightning_clouds_close_inf";
    foreach(struct in structs)
    {
        struct thread do_lightning();
    }
}

function do_lightning()
{
    while(1)
    {
        wait RandomIntRange(15,25);
        PlayFX(level._effect["lightning_fx"], self.origin + (0,0,1500));
    }
}


function play_location_music_init()
{
    triggers = GetEntArray("location_music","targetname");
    foreach(trigger in triggers)
    {
        foreach(player in GetPlayers())
        {
            trigger thread play_music(player);
        }
    }
}

function play_music(player)
{
    while(1)
    {
        self waittill("trigger", user);
        if(player == user)
        {
            player PlayLocalSound(self.script_string);
            return;
        }
        wait 0.05;
    }
}

function permapowerup()
{
    perma_powerups = GetEntArray("perma_powerup","targetname");
    
    random = RandomIntRange(0, 101);
    if (random <= 50)
    {
        powerup_name = "double_points";
    }
    else if (random <= 95)
    {
        powerup_name = "insta_kill";
    }
    else 
    {
        powerup_name = "full_ammo";
    }
    for(i=0;i<perma_powerups.size;i++)
        perma_powerups[i] thread zm_powerups::specific_powerup_drop(powerup_name, perma_powerups[i].origin, undefined, undefined, undefined, undefined, true);
}

//BO2 Deathhands Animation
function bo2_deathhands()
{
    self thread giveDeathHands();
}

function adjust_aflives() 
{
    level flag::get( "initial_blackscreen_passed" );
    
    if (CountPlayers() < 2)
        return;

    foreach(player in GetPlayers()) {
        if (player.af_lives != 0)
            player.af_lives = 1;
    }
}

function giveDeathHands()
{
    level waittill( "intermission" ); 

    self thread player1_deathhands();
    self thread player2_deathhands();
    self thread player3_deathhands();
    self thread player4_deathhands();
}

function func_giveWeapon(weapon)
{
    self TakeWeapon(self GetCurrentWeapon());
    weapon = getWeapon(weapon);
    self GiveWeapon(weapon);
    self GiveMaxAmmo(weapon);
    self SwitchToWeapon(weapon);
}

function player1_deathhands() //Dempsey
{
    players = GetPlayers();
    player_1 = players[0];
    if ( self.playername == ""+player_1.playername+"" )
    {
    self func_giveWeapon("bo2_deathhands");
    }
}

function player2_deathhands() //Nikolai
{
    players = GetPlayers();
    player_2 = players[1];
    if ( self.playername == ""+player_2.playername+"" )
    {
    self func_giveWeapon("bo2_deathhands");
    }
}

function player3_deathhands() //Richtofen
{
    players = GetPlayers();
    player_3 = players[2];
    if ( self.playername == ""+player_3.playername+"" )
    {
    self func_giveWeapon("bo2_deathhands");
    }
}

function player4_deathhands() //Takeo
{
    players = GetPlayers();
    player_4 = players[3];
    if ( self.playername == ""+player_4.playername+"" )
    {
    self func_giveWeapon("bo2_deathhands");
    }
}

function check_shield_ammo()
{
    while(1)
    {
        if(self HasWeapon(level.weaponRiotshield))
        {
            self SetWeaponAmmoClip(level.weaponRiotshield, 0);
            self SetWeaponAmmoStock(level.weaponRiotshield, 0);
            self clientfield::set( "rs_ammo", 0 );
        }
        wait 0.3;
    }
}