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

CoD.ZmMotdrInventoryItem = InheritFrom(LUI.UIElement)

function CoD.ZmMotdrInventoryItem.new(HudRef, InstanceRef, ItemImageRef, ClientfieldRef, characterImgClientfield)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.ZmMotdrInventoryItem)
    Elem.id = "ZmMotdrInventoryItem"
    Elem.soundSet = "default"

    local ItemBorder = LUI.UIImage.new()
	ItemBorder:setLeftRight(true, true, 0, 0)
    ItemBorder:setTopBottom(true, true, 0, 0)
    ItemBorder:setImage(RegisterImage("i_hud_zom_bg_1"))
    Elem:addElement(ItemBorder)
    Elem.ItemBorder = ItemBorder

    local ItemImage = LUI.UIImage.new()
	ItemImage:setLeftRight(true, true, 0, 0)
    ItemImage:setTopBottom(true, true, 0, 0)
    ItemImage:setAlpha(0.3)
    ItemImage:setImage(RegisterImage(ItemImageRef))
    Elem:addElement(ItemImage)
    Elem.ItemImage = ItemImage

    local ItemCheckmark = LUI.UIImage.new()
	ItemCheckmark:setLeftRight(true, true, 0, 0)
    ItemCheckmark:setTopBottom(true, true, 0, 0)
    ItemCheckmark:setAlpha(0)
    ItemCheckmark:setImage(RegisterImage("i_hud_zombie_checkmark"))
    Elem:addElement(ItemCheckmark)
    Elem.ItemCheckmark = ItemCheckmark

    local PlayerImage = LUI.UIImage.new()
	PlayerImage:setLeftRight(false, true, -10, 10)
    PlayerImage:setTopBottom(false, true, -10, 10)
    PlayerImage:setImage(RegisterImage("blacktransparent"))
    Elem:addElement(PlayerImage)
    Elem.PlayerImage = PlayerImage

    local function ItemStateUpdate(ModelRef)
		HudRef:updateElementState(Elem, {
            name = "model_validation",
            menu = HudRef,
            modelValue = Engine.GetModelValue(ModelRef),
            modelName = ClientfieldRef
        })
	end
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), ClientfieldRef), ItemStateUpdate)
    
    if characterImgClientfield then
        local function getCharacterImage(characterIndex)
            if characterIndex == 1 then
                return "oleary_head_img"
            elseif characterIndex == 2 then
                return "deluca_head_img"
            elseif characterIndex == 3 then
                return "handsome_head_img"
            elseif characterIndex == 4 then
                return "arlington_head_img"
            end
            return "blacktransparent"
        end
        local function characterImgUpdate(ModelRef)
            local modelValue = Engine.GetModelValue(ModelRef)
            if modelValue then
                PlayerImage:setImage(RegisterImage(getCharacterImage(modelValue)))
            end
        end
        Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "piece_player_" .. characterImgClientfield), characterImgUpdate)
    end

    local function resetProperties()
        Elem.ItemImage:completeAnimation()
        Elem.ItemCheckmark:completeAnimation()
        Elem.ItemImage:setAlpha(0.3)
        Elem.ItemImage:setImage(RegisterImage(ItemImageRef))
        Elem.ItemCheckmark:setAlpha(0)
    end

    local function InventoryItemDefault()
        resetProperties()
    end

    local function InventoryItemPickedUp()
        resetProperties()
        Elem:setupElementClipCounter(1)
        Elem.ItemImage:completeAnimation()
        Elem.ItemImage:setAlpha(1)
        Elem.clipFinished(Elem.ItemImage, {})
    end

    local function InventoryItemCrafted()
        resetProperties()
        Elem:setupElementClipCounter(2)
        Elem.ItemImage:completeAnimation()
        Elem.ItemImage:setAlpha(1)
        Elem.clipFinished(Elem.ItemImage, {})
        Elem.ItemCheckmark:completeAnimation()
        Elem.ItemCheckmark:setAlpha(1)
        Elem.clipFinished(Elem.ItemCheckmark, {})
    end

    local function InventoryItemFuelDropped()
        resetProperties()
        Elem:setupElementClipCounter(1)
        Elem.ItemImage:completeAnimation()
        Elem.ItemImage:setImage(RegisterImage("i_zom_hud_craftable_plane_gascan"))
        Elem.clipFinished(Elem.ItemImage, {})
    end

    local function InventoryItemFuelPickedUp()
        resetProperties()
        Elem:setupElementClipCounter(1)
        Elem.ItemImage:completeAnimation()
        Elem.ItemImage:setAlpha(1)
        Elem.ItemImage:setImage(RegisterImage("i_zom_hud_craftable_plane_gascan"))
        Elem.clipFinished(Elem.ItemImage, {})
    end

    local function InventoryItemFuelCrafted()
        resetProperties()
        Elem:setupElementClipCounter(2)
        Elem.ItemImage:completeAnimation()
        Elem.ItemImage:setAlpha(1)
        Elem.ItemImage:setImage(RegisterImage("i_zom_hud_craftable_plane_gascan"))
        Elem.clipFinished(Elem.ItemImage, {})
        Elem.ItemCheckmark:completeAnimation()
        Elem.ItemCheckmark:setAlpha(1)
        Elem.clipFinished(Elem.ItemCheckmark, {})
    end

    Elem.clipsPerState = {
        DefaultState = {DefaultClip = InventoryItemDefault},
        PickedUp = {DefaultClip = InventoryItemPickedUp},
        Crafted = {DefaultClip = InventoryItemCrafted},
        FuelDropped = {DefaultClip = InventoryItemFuelDropped},
        FuelPickedUp = {DefaultClip = InventoryItemFuelPickedUp},
        FuelCrafted = {DefaultClip = InventoryItemFuelCrafted}
    }

    return Elem
end

