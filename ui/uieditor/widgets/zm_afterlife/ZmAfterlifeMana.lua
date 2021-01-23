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

CoD.ZmAfterlifeMana = InheritFrom(LUI.UIElement)

function CoD.ZmAfterlifeMana.new(HudRef, InstanceRef)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.ZmAfterlifeMana)
    Elem.id = "ZmAfterlifeMana"
    Elem.soundSet = "default"

    local returnval1 = LUI.UIImage.new()
	returnval1:setLeftRight(true, true, 0.000000, 0.000000)
	returnval1:setTopBottom(true, true, 0.000000, 0.000000)
	returnval1:setImage(RegisterImage("hud_zombie_afterlife_icon_white"))
	Elem:addElement(returnval1)
    Elem.TimeBarBack = returnval1

    
    
	local returnval2 = LUI.UIImage.new()
	returnval2:setLeftRight(true, true, 0.000000, 0.000000)
	returnval2:setTopBottom(true, true, 0.000000, 0.000000)
	returnval2:setImage(RegisterImage("hud_zombie_afterlife_icon"))
	returnval2:setMaterial(LUI.UIImage.GetCachedMaterial("uie_wipe"))
	returnval2:setShaderVector(1.000000, 0.010000, 0.000000, 0.000000, 0.000000)
	returnval2:setShaderVector(2.000000, 1.000000, 0.000000, 0.000000, 0.000000)
	returnval2:setShaderVector(3.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	Elem:addElement(returnval2)
    Elem.TimeBarFill = returnval2

    local returnval4 = LUI.UIImage.new()
	returnval4:setLeftRight(true, true, -7.500000, 7.500000)
	returnval4:setTopBottom(true, true, -5.000000, 5.000000)
	returnval4:setImage(RegisterImage("hud_zombie_afterlife_icon_glow"))
    returnval4:setMaterial(LUI.UIImage.GetCachedMaterial("uie_wipe"))
    --returnval4:setAlpha(0.5)
    returnval4:setRGB(0.15686,0.9843,1)
	returnval4:setShaderVector(1.000000, 0.010000, 0.000000, 0.000000, 0.000000)
	returnval4:setShaderVector(2.000000, 1.000000, 0.000000, 0.000000, 0.000000)
	returnval4:setShaderVector(3.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	Elem:addElement(returnval4)
    Elem.TimeBarGlow = returnval4

    local function __FUNC_AB2_(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
        if ModelValue then
            returnval2:beginAnimation("keyframe", 1500.000000)
            returnval4:beginAnimation("keyframe", 1500.000000)
			returnval2:setShaderVector(0.000000, ModelValue, 0.000000, 0.000000, 0.000000)
			returnval4:setShaderVector(0.000000, ModelValue, 0.000000, 0.000000, 0.000000)
		end
	end
	returnval2:subscribeToGlobalModel(InstanceRef, "PerController", "afterlifeMana", __FUNC_AB2_)
    
    local returnval3 = LUI.UIImage.new()
	returnval3:setLeftRight(true, true, 0.000000, 0.000000)
	returnval3:setTopBottom(true, true, 0.000000, 0.000000)
	returnval3:setAlpha(0.000000)
	returnval3:setImage(RegisterImage("hud_zombie_afterlife_icon"))
	returnval3:setMaterial(LUI.UIImage.GetCachedMaterial("uie_wipe_delta"))
	returnval3:setShaderVector(0.000000, 0.430000, 0.460000, 0.000000, 0.000000)
	returnval3:setShaderVector(1.000000, 0.020000, 0.020000, 0.000000, 0.000000)
	returnval3:setShaderVector(2.000000, 0.000000, 1.000000, 0.000000, 0.000000)
	returnval3:setShaderVector(3.000000, 0.000000, 0.000000, 0.000000, 0.000000)
	Elem:addElement(returnval3)
    Elem.TimeBarFill0 = returnval3

    local function __FUNC_C3A_()
		Elem:setupElementClipCounter(3.000000)
		returnval1:completeAnimation()
		Elem.TimeBarBack:setAlpha(0.000000)
		Elem.clipFinished(returnval1, {})
		returnval2:completeAnimation()
		Elem.TimeBarFill:setAlpha(0.000000)
		Elem.clipFinished(returnval2, {})
		returnval3:completeAnimation()
		Elem.TimeBarFill0:setAlpha(0.000000)
		Elem.clipFinished(returnval3, {})
		returnval4:completeAnimation()
		Elem.TimeBarGlow:setAlpha(0.000000)
		Elem.clipFinished(returnval4, {})
	end
	local function __FUNC_DEE_()
		Elem:setupElementClipCounter(3.000000)
		returnval1:completeAnimation()
		Elem.TimeBarBack:setAlpha(1.000000)
		Elem.clipFinished(returnval1, {})
		returnval2:completeAnimation()
		Elem.TimeBarFill:setAlpha(1.000000)
		Elem.TimeBarFill:setMaterial(LUI.UIImage.GetCachedMaterial("uie_wipe"))
		Elem.TimeBarFill:setShaderVector(1.000000, 0.010000, 0.000000, 0.000000, 0.000000)
		Elem.TimeBarFill:setShaderVector(2.000000, 1.000000, 0.000000, 0.000000, 0.000000)
		Elem.TimeBarFill:setShaderVector(3.000000, 0.000000, 0.000000, 0.000000, 0.000000)
		Elem.clipFinished(returnval2, {})
		returnval4:completeAnimation()
		Elem.TimeBarGlow:setAlpha(1.000000)
		Elem.TimeBarGlow:setMaterial(LUI.UIImage.GetCachedMaterial("uie_wipe"))
		Elem.TimeBarGlow:setShaderVector(1.000000, 0.010000, 0.000000, 0.000000, 0.000000)
		Elem.TimeBarGlow:setShaderVector(2.000000, 1.000000, 0.000000, 0.000000, 0.000000)
		Elem.TimeBarGlow:setShaderVector(3.000000, 0.000000, 0.000000, 0.000000, 0.000000)
		Elem.clipFinished(returnval4, {})
		returnval3:completeAnimation()
		Elem.TimeBarFill0:setAlpha(0.000000)
		Elem.clipFinished(returnval3, {})
	end
	Elem.clipsPerState = {
        DefaultState = {DefaultClip = __FUNC_C3A_},
        Visible = {DefaultClip = __FUNC_DEE_}
    }

    local function __FUNC_10EA_(arg0, arg2, arg3)
        local ModelValue = Engine.GetModelValue(Engine.GetModel(Engine.GetModelForController(InstanceRef), "playerInAfterlife"))
		return ModelValue == 1
	end
    Elem:mergeStateConditions({{stateName = "Visible", condition = __FUNC_10EA_}})

	local function __FUNC_11BD_(ModelRef)
		HudRef:updateElementState(Elem, {
            name = "model_validation",
            menu = HudRef,
            modelValue = Engine.GetModelValue(ModelRef),
            modelName = "playerInAfterlife"
        })
	end
	Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "playerInAfterlife"), __FUNC_11BD_)
    
    local function __FUNC_134B_(Elem)
		Elem.TimeBarFill:close()
	end
	LUI.OverrideFunction_CallOriginalSecond(Elem, "close", __FUNC_134B_)

    return Elem
end