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

#define ARCHETYPE_BRUTUS            "brutus"

#define BRUTUS_STARTING_HEALTH      5000

#define BRUTUS_LOCKDOWNSTATE_OFF    0
#define BRUTUS_LOCKDOWNSTATE_ON    0

// Navmesh
#define BRUTUS_NAVMESH_RADIUS								128
#define BRUTUS_NAVMESH_BOUNDARY_DIST						30

// Melee
#define BRUTUS_MELEE_DIST									85
#define BRUTUS_MELEE_DIST_SQ								BRUTUS_MELEE_DIST * BRUTUS_MELEE_DIST
#define BRUTUS_MELEE_YAW									60

// Damage
#define BRUTUS_DAMAGE_PERCENT                               0.1
#define BRUTUS_SHOTGUN_DAMAGE_MOD                           1.5
#define BRUTUS_HELMET_SHOTS                                 5
#define BRUTUS_POINTS_FOR_HELMET                            250

#define BRUTUS_TAG_HELMET                                   "tag_helmet"
#define BRUTUS_TAG_SPOTLIGHT                                "tag_spotlight"
#define BRUTUS_MODEL_HELMET                                 "c_zom_cellbreaker_helmet"

#define BRUTUS_TEARGAS_WEAPON                               "willy_pete"

#define BRUTUS_FOOTSTEP_EARTHQUAKE_MAX_RADIUS				1500
#define BRUTUS_FOOTSTEP_FX_FILE				                "dlc4/genesis/fx_apothicon_fury_footstep_ch"
#define BRUTUS_FOOTSTEP_FX				                    "fx_brutus_foot_step"
#define BRUTUS_SPOTLIGHT_FX_FILE				            "custom/motdr/brutus/spotlight"
#define BRUTUS_SPOTLIGHT_FX				                    "fx_brutus_spotlight"
#define BRUTUS_DEATH_FX_FILE				                "custom/motdr/brutus/death"
#define BRUTUS_DEATH_FX				                        "fx_brutus_death"
#define BRUTUS_SPAWN_FX_FILE				                "custom/motdr/brutus/spawn"
#define BRUTUS_SPAWN_FX				                        "fx_brutus_spawn"

#define BRUTUS_LOCKDOWN_FX_FILE                             "custom/motdr/brutus/fire_small"
#define BRUTUS_LOCKDOWN_FX                                  "fx_brutus_lockdown_fire"
#define BRUTUS_LOCKDOWN_TYPE                                "_lockdown_type"
#define BRUTUS_LOCKDOWN_TYPE_MAGICBOX                       "magicbox"
#define BRUTUS_LOCKDOWN_TYPE_PERKMACHINE                    "perkmachine"
#define BRUTUS_LOCKDOWN_TYPE_PLANERAMP                      "planeramp"

#define ASM_BRUTUS_MELEE_NOTETRACK						    "fire"
#define ASM_BRUTUS_LOCKDOWN_NOTETRACK						"locked"
#define ASM_BRUTUS_TEARGAS_NOTETRACK						"grenade_drop"