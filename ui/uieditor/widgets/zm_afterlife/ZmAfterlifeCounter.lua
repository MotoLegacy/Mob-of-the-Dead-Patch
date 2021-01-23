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

CoD.ZmAfterlifeCounter = InheritFrom(LUI.UIElement)

function CoD.ZmAfterlifeCounter.new(HudRef, InstanceRef, powerup)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.ZmAfterlifeCounter)
    Elem.id = "ZmAfterlifeCounter"
    Elem.soundSet = "default"

    local AfterlifeIcon = LUI.UIImage.new(Elem, Instance)
    AfterlifeIcon:setLeftRight(true, false, 190, 110)
    AfterlifeIcon:setTopBottom(false, true, -80, -40)
    AfterlifeIcon:setImage(RegisterImage("i_afterlife_logo"))
    AfterlifeIcon.FadeIn = 1
    Elem:addElement(AfterlifeIcon)

    local UserAfterLifeCount = LUI.UIText.new(Elem, Instance)
    UserAfterLifeCount:setLeftRight(true, false, 130, 0)
    UserAfterLifeCount:setTopBottom(false, true, -60, -20)
    UserAfterLifeCount:setText("1")
    Elem:addElement(UserAfterLifeCount)

    local function AfterlifeLivesChange(ModelRef)
        local value = Engine.GetModelValue(ModelRef)
        UserAfterLifeCount:setText(value)
    end

    UserAfterLifeCount:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), ("afterlifeLives")), AfterlifeLivesChange)

    local function AfterlifeIconFade(HudObj, EventObj)
        AfterlifeIcon:beginAnimation("keyframe", 2000, false, false, CoD.TweenType.Linear)
        if AfterlifeIcon.FadeIn == 1 then
            AfterlifeIcon:setRGB(1,1,1)
            AfterlifeIcon.FadeIn = 0
        else
            AfterlifeIcon:setRGB(0.6235,0.6235,0.6235)
            AfterlifeIcon.FadeIn = 1
        end
        AfterlifeIcon:registerEventHandler("transition_complete_keyframe", AfterlifeIconFade)
    end

    AfterlifeIcon:beginAnimation("keyframe", 1, false, false, CoD.TweenType.Linear)
    AfterlifeIcon:registerEventHandler("transition_complete_keyframe", AfterlifeIconFade)

    local function ScoreboardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) or
            not Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) or
            not Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE) then
            Elem:setAlpha(0)
        else
            Elem:setAlpha(1)
        end
    end

    Elem:mergeStateConditions({{stateName = "Scoreboard", condition = ScoreboardCallback}})

    local function ScoreboardBitOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function HudBitVisible(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE})
    end

    local function WeaponHudBitVisible(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE})
    end

    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), ScoreboardBitOpen)
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE), HudBitVisible)
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE), WeaponHudBitVisible)

    return Elem
end