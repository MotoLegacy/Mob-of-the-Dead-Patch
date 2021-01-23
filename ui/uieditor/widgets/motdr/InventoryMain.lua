--[[
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
]]

require("ui.uieditor.widgets.motdr.InventoryItem")

CoD.ZmMotdrInventory = InheritFrom(LUI.UIElement)

function CoD.ZmMotdrInventory.new(HudRef, InstanceRef)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.ZmMotdrInventory)
    Elem.id = "ZmMotdrInventory"
    Elem.soundSet = "default"

    local backgroundQuestItemsText = LUI.UIImage.new()
	backgroundQuestItemsText:setLeftRight(true, false, 0, 322)
    backgroundQuestItemsText:setTopBottom(true, false, 0, 32)
    backgroundQuestItemsText:setImage(RegisterImage("$white"))
    backgroundQuestItemsText:setRGB(0.6,0.6,0.6)
    backgroundQuestItemsText:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundQuestItemsText:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundQuestItemsText)

    local QuestItemsText = LUI.UIText.new()
	QuestItemsText:setLeftRight(true, false, 5, 322)
    QuestItemsText:setTopBottom(true, false, 0, 32)
    QuestItemsText:setText("Quest Items")
    QuestItemsText:setRGB(0.50908, 0.50908, 0.50908)
	QuestItemsText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	QuestItemsText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    QuestItemsText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(QuestItemsText)
    
    local backgroundRecipesText = LUI.UIImage.new()
	backgroundRecipesText:setLeftRight(true, false, 368, 695)
    backgroundRecipesText:setTopBottom(true, false, 0, 32)
    backgroundRecipesText:setImage(RegisterImage("$white"))
    backgroundRecipesText:setRGB(0.6,0.6,0.6)
    backgroundRecipesText:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundRecipesText:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundRecipesText)

    local RecipesText = LUI.UIText.new()
	RecipesText:setLeftRight(true, false, 373, 695)
    RecipesText:setTopBottom(true, false, 0, 32)
    RecipesText:setText("Recipes")
    RecipesText:setRGB(0.50908, 0.50908, 0.50908)
	RecipesText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	RecipesText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    RecipesText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(RecipesText)
    
    local backgroundKey = LUI.UIImage.new()
	backgroundKey:setLeftRight(true, false, 0, 55)
    backgroundKey:setTopBottom(false, true, -80, 0)
    backgroundKey:setImage(RegisterImage("$white"))
    backgroundKey:setRGB(0.6,0.6,0.6)
    backgroundKey:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundKey:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundKey)

    local KeyText = LUI.UIText.new()
	KeyText:setLeftRight(true, false, 5, 55)
    KeyText:setTopBottom(false, true, -80, -55)
    KeyText:setText("Key")
	KeyText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	KeyText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    KeyText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(KeyText)

    local KeyItem = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_key_logo", "piece_key_warden")
	KeyItem:setLeftRight(true, false, 5, 50)
    KeyItem:setTopBottom(false, true, -50, -5)
    local function KeyItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_key_warden", 1)
	end
	KeyItem:mergeStateConditions({
        {stateName = "PickedUp", condition = KeyItemPickedUp}
    })
    Elem:addElement(KeyItem)
    
    local backgroundPlane = LUI.UIImage.new()
	backgroundPlane:setLeftRight(true, false, 67, 322)
    backgroundPlane:setTopBottom(false, true, -80, 0)
    backgroundPlane:setImage(RegisterImage("$white"))
    backgroundPlane:setRGB(0.6,0.6,0.6)
    backgroundPlane:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundPlane:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundPlane)

    local PlaneText = LUI.UIText.new()
	PlaneText:setLeftRight(true, false, 72, 322)
    PlaneText:setTopBottom(false, true, -80, -55)
    PlaneText:setText("Plane Parts")
	PlaneText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	PlaneText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    PlaneText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(PlaneText)

    local function ItemStateUpdate(ModelRef)
        local modelValue = Engine.GetModelValue(ModelRef)
        if modelValue then
            if modelValue == 0 then
                PlaneText:setText("Plane Parts")
            else
                PlaneText:setText("Fuel Canisters")
            end
        end
	end
	Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "quest_plane_craft_complete"), ItemStateUpdate)

    local PlanePart1Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_clothes_logo", "quest_state1", "cloth")
	PlanePart1Item:setLeftRight(true, false, 72, 117)
    PlanePart1Item:setTopBottom(false, true, -50, -5)
    local function PlanePart1ItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state1", 3)
    end
    local function PlanePart1ItemCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state1", 4)
    end
    local function PlanePart1ItemFuelDefault(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state1", 5)
    end
    local function PlanePart1ItemFuelPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state1", 6)
    end
    local function PlanePart1ItemFuelCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state1", 7)
	end
	PlanePart1Item:mergeStateConditions({
        {stateName = "PickedUp", condition = PlanePart1ItemPickedUp},
        {stateName = "Crafted", condition = PlanePart1ItemCrafted},
        {stateName = "FuelDropped", condition = PlanePart1ItemFuelDefault},
        {stateName = "FuelPickedUp", condition = PlanePart1ItemFuelPickedUp},
        {stateName = "FuelCrafted", condition = PlanePart1ItemFuelCrafted}
    })
    Elem:addElement(PlanePart1Item)

    local PlanePart2Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_tanks_logo", "quest_state2", "fueltanks")
	PlanePart2Item:setLeftRight(true, false, 122, 167)
    PlanePart2Item:setTopBottom(false, true, -50, -5)
    local function PlanePart2ItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state2", 3)
    end
    local function PlanePart2ItemCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state2", 4)
    end
    local function PlanePart2ItemFuelDefault(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state2", 5)
    end
    local function PlanePart2ItemFuelPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state2", 6)
    end
    local function PlanePart2ItemFuelCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state2", 7)
	end
	PlanePart2Item:mergeStateConditions({
        {stateName = "PickedUp", condition = PlanePart2ItemPickedUp},
        {stateName = "Crafted", condition = PlanePart2ItemCrafted},
        {stateName = "FuelDropped", condition = PlanePart2ItemFuelDefault},
        {stateName = "FuelPickedUp", condition = PlanePart2ItemFuelPickedUp},
        {stateName = "FuelCrafted", condition = PlanePart2ItemFuelCrafted}
    })
    Elem:addElement(PlanePart2Item)

    local PlanePart3Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_engine_logo", "quest_state3", "engine")
	PlanePart3Item:setLeftRight(true, false, 172, 217)
    PlanePart3Item:setTopBottom(false, true, -50, -5)
    local function PlanePart3ItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state3", 3)
    end
    local function PlanePart3ItemCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state3", 4)
    end
    local function PlanePart3ItemFuelDefault(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state3", 5)
    end
    local function PlanePart3ItemFuelPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state3", 6)
    end
    local function PlanePart3ItemFuelCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state3", 7)
	end
	PlanePart3Item:mergeStateConditions({
        {stateName = "PickedUp", condition = PlanePart3ItemPickedUp},
        {stateName = "Crafted", condition = PlanePart3ItemCrafted},
        {stateName = "FuelDropped", condition = PlanePart3ItemFuelDefault},
        {stateName = "FuelPickedUp", condition = PlanePart3ItemFuelPickedUp},
        {stateName = "FuelCrafted", condition = PlanePart3ItemFuelCrafted}
    })
    Elem:addElement(PlanePart3Item)

    local PlanePart4Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_valve_logo", "quest_state4", "steering")
	PlanePart4Item:setLeftRight(true, false, 222, 267)
    PlanePart4Item:setTopBottom(false, true, -50, -5)
    local function PlanePart4ItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state4", 3)
    end
    local function PlanePart4ItemCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state4", 4)
    end
    local function PlanePart4ItemFuelDefault(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state4", 5)
    end
    local function PlanePart4ItemFuelPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state4", 6)
    end
    local function PlanePart4ItemFuelCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state4", 7)
	end
	PlanePart4Item:mergeStateConditions({
        {stateName = "PickedUp", condition = PlanePart4ItemPickedUp},
        {stateName = "Crafted", condition = PlanePart4ItemCrafted},
        {stateName = "FuelDropped", condition = PlanePart4ItemFuelDefault},
        {stateName = "FuelPickedUp", condition = PlanePart4ItemFuelPickedUp},
        {stateName = "FuelCrafted", condition = PlanePart4ItemFuelCrafted}
    })
    Elem:addElement(PlanePart4Item)

    local PlanePart5Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_plane_rigging_logo", "quest_state5", "rigging")
	PlanePart5Item:setLeftRight(true, false, 272, 317)
    PlanePart5Item:setTopBottom(false, true, -50, -5)
    local function PlanePart5ItemPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state5", 3)
    end
    local function PlanePart5ItemCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state5", 4)
    end
    local function PlanePart5ItemFuelDefault(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state5", 5)
    end
    local function PlanePart5ItemFuelPickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state5", 6)
    end
    local function PlanePart5ItemFuelCrafted(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "quest_state5", 7)
	end
	PlanePart5Item:mergeStateConditions({
        {stateName = "PickedUp", condition = PlanePart5ItemPickedUp},
        {stateName = "Crafted", condition = PlanePart5ItemCrafted},
        {stateName = "FuelDropped", condition = PlanePart5ItemFuelDefault},
        {stateName = "FuelPickedUp", condition = PlanePart5ItemFuelPickedUp},
        {stateName = "FuelCrafted", condition = PlanePart5ItemFuelCrafted}
    })
    Elem:addElement(PlanePart5Item)
    
    local backgroundShield = LUI.UIImage.new()
	backgroundShield:setLeftRight(true, false, 368, 522)
    backgroundShield:setTopBottom(false, true, -80, 0)
    backgroundShield:setImage(RegisterImage("$white"))
    backgroundShield:setRGB(0.6,0.6,0.6)
    backgroundShield:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundShield:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundShield)

    local ShieldText = LUI.UIText.new()
	ShieldText:setLeftRight(true, false, 372, 530)
    ShieldText:setTopBottom(false, true, -80, -55)
    ShieldText:setText("Shield")
	ShieldText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	ShieldText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    ShieldText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(ShieldText)

    local ShieldPart1Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_shield_dolly_logo", "piece_riotshield_dolly")
	ShieldPart1Item:setLeftRight(true, false, 372, 417)
    ShieldPart1Item:setTopBottom(false, true, -50, -5)
    local function ShieldPart1PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_riotshield_dolly", 1)
	end
	ShieldPart1Item:mergeStateConditions({
        {stateName = "PickedUp", condition = ShieldPart1PickedUp}
    })
    Elem:addElement(ShieldPart1Item)

    local ShieldPart2Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_shield_door_logo", "piece_riotshield_door")
	ShieldPart2Item:setLeftRight(true, false, 422, 467)
    ShieldPart2Item:setTopBottom(false, true, -50, -5)
    local function ShieldPart2PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_riotshield_door", 1)
	end
	ShieldPart2Item:mergeStateConditions({
        {stateName = "PickedUp", condition = ShieldPart2PickedUp}
    })
    Elem:addElement(ShieldPart2Item)

    local ShieldPart3Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_shield_clamp_logo", "piece_riotshield_clamp")
	ShieldPart3Item:setLeftRight(true, false, 472, 517)
    ShieldPart3Item:setTopBottom(false, true, -50, -5)
    local function ShieldPart3PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_riotshield_clamp", 1)
	end
	ShieldPart3Item:mergeStateConditions({
        {stateName = "PickedUp", condition = ShieldPart3PickedUp}
    })
    Elem:addElement(ShieldPart3Item)
    
    local backgroundAcidGat = LUI.UIImage.new()
	backgroundAcidGat:setLeftRight(true, false, 540, 695)
    backgroundAcidGat:setTopBottom(false, true, -80, 0)
    backgroundAcidGat:setImage(RegisterImage("$white"))
    backgroundAcidGat:setRGB(0.6,0.6,0.6)
    backgroundAcidGat:setMaterial(RegisterMaterial("uie_scene_blur_pass_1"))
    backgroundAcidGat:setShaderVector(0.000000, 0, 20, 0.000000, 0.000000)
    Elem:addElement(backgroundAcidGat)
    
    local AcidGatText = LUI.UIText.new()
	AcidGatText:setLeftRight(true, false, 545, 702)
    AcidGatText:setTopBottom(false, true, -80, -55)
    AcidGatText:setText("Acid Gat Kit")
	AcidGatText:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	AcidGatText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    AcidGatText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    Elem:addElement(AcidGatText)

    local AcidPart1Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_splat_fuse_logo", "piece_packasplat_fuse")
	AcidPart1Item:setLeftRight(true, false, 545, 590)
    AcidPart1Item:setTopBottom(false, true, -50, -5)
    local function AcidPart1PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_packasplat_fuse", 1)
	end
	AcidPart1Item:mergeStateConditions({
        {stateName = "PickedUp", condition = AcidPart1PickedUp}
    })
    Elem:addElement(AcidPart1Item)

    local AcidPart2Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_splat_case_logo", "piece_packasplat_case")
	AcidPart2Item:setLeftRight(true, false, 595, 640)
    AcidPart2Item:setTopBottom(false, true, -50, -5)
    local function AcidPart2PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_packasplat_case", 1)
	end
	AcidPart2Item:mergeStateConditions({
        {stateName = "PickedUp", condition = AcidPart2PickedUp}
    })
    Elem:addElement(AcidPart2Item)

    local AcidPart3Item = CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, "i_splat_blood_logo", "piece_packasplat_blood")
	AcidPart3Item:setLeftRight(true, false, 645, 690)
    AcidPart3Item:setTopBottom(false, true, -50, -5)
    local function AcidPart3PickedUp(arg0, arg2, arg3)
		return IsModelValueEqualTo(InstanceRef, "piece_packasplat_blood", 1)
	end
	AcidPart3Item:mergeStateConditions({
        {stateName = "PickedUp", condition = AcidPart3PickedUp}
    })
    Elem:addElement(AcidPart3Item)

    local function ScoreboardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) and
        not Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_GAME_ENDED) then
            Elem:setAlpha(1)
        else
            Elem:setAlpha(0)
        end
    end

    Elem:mergeStateConditions({{stateName = "Inventory", condition = ScoreboardCallback}})

    local function ScoreboardBitOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function GameEndedBitOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED})
    end
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), ScoreboardBitOpen)
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED), GameEndedBitOpen)

    return Elem
end