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

#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_zm_zonemgr;

#namespace zm_alcatraz_visions;

function autoexec init()
{
    visionset_mgr::register_info( "visionset", "zm_alcatraz_cellblock", 9000, 120, 1, 1 );
    visionset_mgr::register_info( "visionset", "zm_alcatraz_underground", 9000, 120, 1, 1 );
    visionset_mgr::register_info( "visionset", "zm_alcatraz_outside", 9000, 120, 1, 1 );
    //visionset_mgr::register_info( "visionset", "zm_alcatraz_bw", 9000, 120, 1, 1 );

    level flag::wait_till( "initial_blackscreen_passed" );

    foreach(player in GetPlayers())
    {
        player thread vision_zone_check();
    }
}

function vision_zone_check()
{
    for(;;)
    {
        old_vision = self.current_vision;
        current_zone = self zm_zonemgr::get_player_zone();

        //IPrintLnBold("name: " + self.name + " | zone: " + current_zone);

        switch(current_zone)
        {
            case "gondola_roof_zone":
            case "upper_docks_zone":
            case "roof_zone":
            case "docks_zone":
                self.current_vision = "zm_alcatraz_outside";
                break;
            case "shower_zone":
            case "cellblock_out_wardens_zone_b":
            case "ug_docks_zone_e":
            case "docks_room_zone":
                self.current_vision = "zm_alcatraz_underground";
                break;
            case "top_dogfeeder_zone_c":
            case "cellblock_hallway_zone":
            case "cellblock_out_wardens_zone":
            case "cellblock_leftside_zone_b":
            case "infirmary_zone_c":
            case "start_zone":
                self.current_vision = "zm_alcatraz_cellblock";
                break;
            default:
                break;
        }

        /*if (self.current_vision != old_vision) {
            IPrintLnBold("switching vision to: " + self.current_vision);
            //visionset_mgr::deactivate( "visionset", old_vision, self );
            //wait 0.05;
            visionset_mgr::activate( "visionset", self.current_vision, self );
        }*/
        wait 1;
    }
}