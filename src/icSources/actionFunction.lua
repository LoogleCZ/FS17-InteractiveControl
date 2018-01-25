--
-- Part of InteractiveControl script.
-- This file contains events for buttons and support functions
--
-- Author: Martin Fabík (LoogleCZ)
-- Author of some events: Andy (GtX)
-- For IC version: 4.0.4
-- You can find whole list of supported events in documentation
--
-- Last edit: 2018-01-25 12:14:00
-- Free for non-comerecial usage
--

--
-- All synch attributes in animations should be set to TRUE.
-- All synch attributes in monitors should be set to TRUE.
-- All synch attributes in visControl should be set to TRUE.
-- All synch attributes in multi buttons should be set to FALSE.
--

--
-- Helper functions
--

local dumpOnImplements = function(self, implements, ICID)
	for _, implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.toggleTipState ~= nil and implement.object.currentFillType ~= FillUtil.FILLTYPE_UNKNOWN and g_currentMission.trailerTipTriggers ~= nil then
				if g_currentMission.trailerTipTriggers[implement.object] ~= nil then
					if g_currentMission.trailerTipTriggers[implement.object][1] ~= nil then
						if self.LIC.interactiveObjects[ICID].isOpen then
							if g_currentMission.currentTipTriggerIsAllowed then
								implement.object:onStartTip(g_currentMission.trailerTipTriggers[implement.object][1], implement.object.preferedTipReferencePointIndex, false);
							else
								local text = g_currentMission.currentTipTrigger:getNotAllowedText(g_currentMission.trailerInTipRange, TipTrigger.TOOL_TYPE_TRAILER);
								if text ~= nil and text ~= "" then
									self.tipErrorMessageTime = 3000;
									self.tipErrorMessage = text;
								end;
							end;
						else
							implement.object:onEndTip();
						end;
					end;
				end;
			end;
		end;
	end;
end;

local dumpGroundOnImplements = function(self, implements, ICID)
	for _, implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.getCanTipToGround ~= nil and implement.object:getCanTipToGround() and implement.object.numTipReferencePoints > 0 then
				if implement.object ~= g_currentMission.trailerInTipRange then
					if self.LIC.interactiveObjects[ICID].isOpen then
						implement.object:onStartTip(nil, implement.object.preferedTipReferencePointIndex, false);
					else
						implement.object:onEndTip();
					end;
				end;
			end;
		end;
	end;
end;

local dumpMixedOnImplements = function(self, implements, id)
	for _, implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.toggleTipState ~= nil 
				and implement.object.currentFillType ~= FillUtil.FILLTYPE_UNKNOWN
				and g_currentMission.trailerTipTriggers ~= nil
				and g_currentMission.trailerTipTriggers[implement.object] ~= nil
				and g_currentMission.trailerTipTriggers[implement.object][1] ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					if g_currentMission.currentTipTriggerIsAllowed then
						implement.object:onStartTip(g_currentMission.trailerTipTriggers[implement.object][1], implement.object.preferedTipReferencePointIndex, false);
					else
						local text = g_currentMission.currentTipTrigger:getNotAllowedText(g_currentMission.trailerInTipRange, TipTrigger.TOOL_TYPE_TRAILER);
						if text ~= nil and text ~= "" then
							self.tipErrorMessageTime = 3000;
							self.tipErrorMessage = text;
						end;
					end;
				else
					implement.object:onEndTip();
				end;
			elseif implement.object.getCanTipToGround ~= nil 
				and implement.object:getCanTipToGround()
				and implement.object.numTipReferencePoints > 0
				and implement.object ~= g_currentMission.trailerInTipRange then
				if self.LIC.interactiveObjects[id].isOpen then
					implement.object:onStartTip(nil, implement.object.preferedTipReferencePointIndex, false);
				else
					implement.object:onEndTip();
				end;
			end;
		end;
	end;
end;

local dumpOnImplementsStatus = function(self, implements, id)
	local status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil then
				if implement.object.toggleTipState ~= nil and implement.object.currentFillType ~= FillUtil.FILLTYPE_UNKNOWN and g_currentMission.trailerTipTriggers ~= nil then
					if g_currentMission.trailerTipTriggers[implement.object] ~= nil then
						if g_currentMission.trailerTipTriggers[implement.object][1] ~= nil then
							status = ((implement.object.tipState == Trailer.TIPSTATE_OPENING or implement.object.tipState == Trailer.TIPSTATE_OPEN)) or status;
						end;
					end;
				end;
			end;
		end;
	end;
	return status;
end;

local dumpGroundOnImplementsStatus = function(self, implements, id)
	local status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil then
				if implement.object.getCanTipToGround ~= nil and implement.object:getCanTipToGround() and implement.object.numTipReferencePoints > 0 then
					status = ((implement.object.tipState == Trailer.TIPSTATE_OPENING or implement.object.tipState == Trailer.TIPSTATE_OPEN)) or status;
				end;
			end;
		end;
	end;
	return status;
end;

local dumpMixedOnImplementsStatus = function(self, implements, id)
	local status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil then
				status = ((implement.object.tipState == Trailer.TIPSTATE_OPENING or implement.object.tipState == Trailer.TIPSTATE_OPEN)) or status;
			end;
		end;
	end;
	return status;
end;

local fillOnImplements = function(self, implements, id)
	for _, implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.isFilling ~= nil and implement.object.setIsFilling ~= nil then
				for _, trigger in ipairs(implement.object.fillTriggers) do
					if trigger:getIsActivatable(implement.object) then
						implement.object:setIsFilling(self.LIC.interactiveObjects[id].isOpen);
						break;
					end;
				end;
			end;
		end;
	end;
end;

local fillOnImplementsStatus = function(self, implements, id)	
	status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil then
				if implement.object.isFilling ~= nil and implement.object.setIsFilling ~= nil then
					for _, trigger in ipairs(implement.object.fillTriggers) do
						status = (implement.object.isFilling and trigger:getIsActivatable(implement.object)) or status;
					end;
					if status then
						break;
					end;
				end;
			end;
		end;
	end;
	return status;
end;

local turnOnOnImplements = function(self, implements, id)
	for _,implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.setIsTurnedOn ~= nil and implement.object:getIsTurnedOnAllowed() then
				implement.object:setIsTurnedOn(self.LIC.interactiveObjects[id].isOpen);
			end;
		end;
	end;
end;

local turnOnOnImplementsStatus = function(self, implements, id)
	status = false;
	if self:getIsActive() then
		for _,implement in pairs(implements) do
			if implement.object ~= nil then
				status = implement.object:getIsTurnedOn() or status;
			end;
		end;
	end;
	return status;
end;

local lowerOnImplements = function(self, implements, id)
	for _, implement in pairs(implements) do
		if implement.object ~= nil then
			if implement.object.isPickupLowered ~= nil and implement.object.setPickupState ~= nil then
				implement.object:setPickupState(self.LIC.interactiveObjects[id].isOpen);
			elseif implement.object.setFoldState ~= nil and implement.object.foldMiddleAnimTime then
				if implement.object:getIsFoldAllowed() then
					local dir = 1;
					if not self.LIC.interactiveObjects[id].isOpen then
						dir = -1;
					end;
					dir = dir * implement.object.turnOnFoldDirection;
					if dir == implement.object.turnOnFoldDirection then
						implement.object:setFoldState(dir, false);
					else
						implement.object:setFoldState(dir, true);
					end;
				end;
			end;
			for _,attImpl in pairs(implement.object.attacherVehicle.attachedImplements) do
				if attImpl.object == implement.object then
					implement.object.attacherVehicle:setJointMoveDown(attImpl.jointDescIndex ,self.LIC.interactiveObjects[id].isOpen);
					break;
				end;
			end;
		end;
	end;
end;

local lowerOnImplementsStatus = function(self, implements, id)
	local status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil then
				if implement.object.isPickupLowered ~= nil and implement.object.setPickupState ~= nil then
					status = implement.object.isPickupLowered or status;
				elseif implement.object.setFoldState ~= nil and implement.object.foldMiddleAnimTime ~= nil then
					status = (implement.object.turnOnFoldDirection == -1 and implement.object.foldAnimTime + 0.01 < implement.object.foldMiddleAnimTime) or (implement.object.turnOnFoldDirection == 1 and implement.object.foldAnimTime - 0.01 > implement.object.foldMiddleAnimTime) or status;
				else
					for _,attImpl in pairs(implement.object.attacherVehicle.attachedImplements) do
						if attImpl.object == implement.object then
							status = implement.object:isLowered() or status;
							break;
						end;
					end;
				end;
			end;
		end;
	end;
	return status;
end;

local foldOnImplementsFinish = function(self, implements, id)
	for _, implement in pairs(implements) do
		if implement.object ~= nil and implement.object.getIsFoldAllowed ~= nil then
			if implement.object:getIsFoldAllowed() then
				local dir = 1;
				if not self.LIC.interactiveObjects[id].isOpen then
					dir = -1;
				end;
				dir = dir * implement.object.turnOnFoldDirection;
				implement.object:setFoldState(dir, false);
			end;
		end;
	end;
end;

local foldOnImplementsFinishStatus = function(self, implements, id)
	local status = false;
	if self:getIsActive() then
		for _, implement in pairs(implements) do
			if implement.object ~= nil and implement.object.getIsFoldAllowed ~= nil then
				status = (implement.object.turnOnFoldDirection == -1 and implement.object.foldAnimTime + 0.01 < 1) or (implement.object.turnOnFoldDirection == 1 and implement.object.foldAnimTime - 0.01 > 0) or status;
			end;
		end;
	end;
	return status;
end;

local foldOnImplementsMiddle = function(self, implements, id)
	for _, implement in pairs(implements) do
		if implement.object ~= nil and implement.object.getIsFoldAllowed ~= nil then
			if implement.object:getIsFoldAllowed() then
				local dir = 1;
				if not self.LIC.interactiveObjects[id].isOpen then
					dir = -1;
				end;
				dir = dir * implement.object.turnOnFoldDirection;
				implement.object:setFoldState(dir, (self.LIC.interactiveObjects[id].isOpen));
			end;
		end;
	end;
end;

--[[
	Switch
]]--

function InteractiveControl:actionOnObject(id, isObjectOpen, noEventSend)
	self:updateOpenStatus(id);
	
	if isObjectOpen ~= nil then
		self.LIC.interactiveObjects[id].isOpen = isObjectOpen;
	else
		self.LIC.interactiveObjects[id].isOpen = ( not self.LIC.interactiveObjects[id].isOpen );
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_ANIMATION then
		if self.LIC.interactiveObjects[id].animClip ~= nil then 
			if self.LIC.interactiveObjects[id].animClip.animCharSet ~= nil then
				if self.LIC.interactiveObjects[id].looping then
					if not self.LIC.interactiveObjects[id].isOpen then
						disableAnimTrack(self.LIC.interactiveObjects[id].animClip.animCharSet, 0);
					else
						enableAnimTrack(self.LIC.interactiveObjects[id].animClip.animCharSet, 0);
					end;
				else
					if self.LIC.interactiveObjects[id].isOpen then
						if self.LIC.interactiveObjects[id].animClip.animCharSet ~= 0 then
							if getAnimTrackTime(self.LIC.interactiveObjects[id].animClip.animCharSet, 0) < 0.0 then
								setAnimTrackTime(self.LIC.interactiveObjects[id].animClip.animCharSet, 0, 0.0);
							end;
							setAnimTrackSpeedScale(self.LIC.interactiveObjects[id].animClip.animCharSet, 0, -self.LIC.interactiveObjects[id].speedScale);
							enableAnimTrack(self.LIC.interactiveObjects[id].animClip.animCharSet, 0);
						end;
					else
						if self.LIC.interactiveObjects[id].animClip.animCharSet ~= 0 then
							if getAnimTrackTime(self.LIC.interactiveObjects[id].animClip.animCharSet, 0) > self.LIC.interactiveObjects[id].animClip.animDuration then
								setAnimTrackTime(self.LIC.interactiveObjects[id].animClip.animCharSet, 0, self.LIC.interactiveObjects[id].animClip.animDuration);
							end;
							setAnimTrackSpeedScale(self.LIC.interactiveObjects[id].animClip.animCharSet, 0, self.LIC.interactiveObjects[id].speedScale);
							enableAnimTrack(self.LIC.interactiveObjects[id].animClip.animCharSet, 0);
						end;
					end;
				end;
			end;
		else
			if self.LIC.interactiveObjects[id].looping then
				if self.LIC.interactiveObjects[id].isOpen then
					self:playAnimation(self.LIC.interactiveObjects[id].animation, self.LIC.interactiveObjects[id].speedScale, Utils.clamp(self:getAnimationTime(self.LIC.interactiveObjects[id].animation), 0, 1), true);
				else
					self:stopAnimation(self.LIC.interactiveObjects[id].animation, true);
				end;
			else
				if self.LIC.interactiveObjects[id].isOpen then
					self:playAnimation(self.LIC.interactiveObjects[id].animation, -self.LIC.interactiveObjects[id].speedScale, Utils.clamp(self:getAnimationTime(self.LIC.interactiveObjects[id].animation), 0, 1), true);
				else
					self:playAnimation(self.LIC.interactiveObjects[id].animation, self.LIC.interactiveObjects[id].speedScale, Utils.clamp(self:getAnimationTime(self.LIC.interactiveObjects[id].animation), 0, 1), true);
				end;
			end;
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_EVENT_BUTTON then
		--[[ Driving ]]--
		if self.LIC.interactiveObjects[id].event == "steering.motorIgnition" then
			if not g_currentMission.missionInfo.automaticMotorStartEnabled then
				if not self.LIC.interactiveObjects[id].isOpen then
					self:stopMotor();
				else
					self:startMotor();
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.reverseDriving" then
			if self.isReverseDriving ~= nil then
				self:setIsReverseDriving(self.LIC.interactiveObjects[id].isOpen);
			end
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.1" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 1 then
				self:setCrabSteering(1);
				self.LIC.interactiveObjects[id].isOpen = true;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.2" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 2 then
				self:setCrabSteering(2);
				self.LIC.interactiveObjects[id].isOpen = true;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.3" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 3 then
				self:setCrabSteering(3);
				self.LIC.interactiveObjects[id].isOpen = true;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.4" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 4 then
				self:setCrabSteering(4);
				self.LIC.interactiveObjects[id].isOpen = true;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.12" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 2 then
				if self.LIC.interactiveObjects[id].isOpen then
					self:setCrabSteering(2);
				else
					self:setCrabSteering(1);
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.cycle" then
			if self.setCrabSteering ~= nil then
				local actualCS = self.crabSteering.state + 1;
				if actualCS > self.crabSteering.stateMax then
					actualCS = 1;
				end;
				self:setCrabSteering(actualCS);
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.toggle" then
			if self.cruiseControl ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_ACTIVE);
				else
					self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF);
				end;			
			end;			
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.speedUp" then
			if self.cruiseControl ~= nil then
				self:setCruiseControlMaxSpeed(self.cruiseControl.speed + 1);
				if self.cruiseControl.speed ~= self.cruiseControl.speedSent then
					if g_server ~= nil then
						g_server:broadcastEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed), nil, nil, self);
					else
						g_client:getServerConnection():sendEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed));
					end;
					self.cruiseControl.speedSent = self.cruiseControl.speed;
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.speedDown" then
			if self.cruiseControl ~= nil then
				self:setCruiseControlMaxSpeed(self.cruiseControl.speed - 1);
				if self.cruiseControl.speed ~= self.cruiseControl.speedSent then
					if g_server ~= nil then
						g_server:broadcastEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed), nil, nil, self);
					else
						g_client:getServerConnection():sendEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed));
					end;
					self.cruiseControl.speedSent = self.cruiseControl.speed;
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.lockMovingTools" then
			if self.lmt ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					self.lmt.toolState = 2;
				else
					self.lmt.toolState = 1;
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.hazard" then
			if self.setTurnLightState ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					self:setTurnLightState(Lights.TURNLIGHT_HAZARD);
				else
					self:setTurnLightState(Lights.TURNLIGHT_OFF);
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.right" then
			if self.setTurnLightState ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					self:setTurnLightState(Lights.TURNLIGHT_RIGHT);
				else
					self:setTurnLightState(Lights.TURNLIGHT_OFF);
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.left" then
			if self.setTurnLightState ~= nil then
				if self.LIC.interactiveObjects[id].isOpen then
					self:setTurnLightState(Lights.TURNLIGHT_LEFT);
				else
					self:setTurnLightState(Lights.TURNLIGHT_OFF);
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.front" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 1 then
				if self.LIC.interactiveObjects[id].isOpen ~= ( bitAND(self.lightsTypesMask, 2^0) == 1 ) then
					self:setLightsTypesMask(bitXOR(self.lightsTypesMask, 2^0));
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.highBeam" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 4 then
				if self.LIC.interactiveObjects[id].isOpen ~= ( bitAND(self.lightsTypesMask, 2^3) == 8 ) then
					self:setLightsTypesMask(bitXOR(self.lightsTypesMask, 2^3));
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.frontWork" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 3 then
				if self.LIC.interactiveObjects[id].isOpen ~= ( bitAND(self.lightsTypesMask, 2^2) == 4 ) then
					self:setLightsTypesMask(bitXOR(self.lightsTypesMask, 2^2));
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.rearWork" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 2 then
				if self.LIC.interactiveObjects[id].isOpen ~= ( bitAND(self.lightsTypesMask, 2^1) == 2 ) then
					self:setLightsTypesMask(bitXOR(self.lightsTypesMask, 2^1));
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.beaconLights" then
			if self.setBeaconLightsVisibility ~= nil then
				self:setBeaconLightsVisibility(self.LIC.interactiveObjects[id].isOpen, true, true);
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.cablight" then
			if self.cl ~= nil then
				self:setCablight(self.LIC.interactiveObjects[id].isOpen, true);
			end;
		elseif string.sub( self.LIC.interactiveObjects[id].event, 1, 5 ) == "l2gs." and type( self["l2gs" .. string.sub(self.LIC.interactiveObjects[id].event, 6)] ) == "function" then
			local fct = self["l2gs" .. string.sub(self.LIC.interactiveObjects[id].event, 6)];
			fct( self );
			
		--[[ Implements below ]]--
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				dumpOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				dumpOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				dumpOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				dumpGroundOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				dumpGroundOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				dumpGroundOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				dumpMixedOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				dumpMixedOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				dumpMixedOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				fillOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				fillOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				fillOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				turnOnOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				turnOnOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				turnOnOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				lowerOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				lowerOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				lowerOnImplements(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				foldOnImplementsFinish(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				foldOnImplementsFinish(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				foldOnImplementsFinish(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.all" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "");
				foldOnImplementsMiddle(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.front" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "front");
				foldOnImplementsMiddle(self, implements, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.rear" then
			if self:getIsActive() then
				local implements = InteractiveControl:getICimplements(self, "back");
				foldOnImplementsMiddle(self, implements, id);
			end;
		--[[ current vehicle ]]--	
		elseif self.LIC.interactiveObjects[id].event == "tipping.trigger" then
			if self:getIsActive() then
				dumpOnImplements(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "tipping.ground" then
			if self:getIsActive() then
				dumpGroundOnImplements(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "tipping.mixed" then
			if self:getIsActive() then
				dumpMixedOnImplements(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "filling" then
			if self:getIsActive() then
				fillOnImplements(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "fold" then
			if self:getIsActive() then
				foldOnImplementsFinish(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "fold.middle" then
			if self:getIsActive() then
				foldOnImplementsMiddle(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnState" then
			if self:getIsActive() then
				turnOnOnImplements(self, {{object=self}}, id);
			end;
		elseif self.LIC.interactiveObjects[id].event == "raiseLower" then
			if self:getIsActive() then
				lowerOnImplements(self, {{object=self}}, id);
			end;
		--[[ MIX ]]--
		elseif self.LIC.interactiveObjects[id].event == "radio.state" then
			if g_soundPlayer ~= nil then
				g_gameSettings:setValue("radioIsActive", self.LIC.interactiveObjects[id].isOpen);
				if self.LIC.interactiveObjects[id].isOpen then
					g_currentMission:playRadio();
				else
					g_currentMission:pauseRadio();
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "radio.channelUp" then
			if g_soundPlayer ~= nil then
				if g_gameSettings:getValue("radioIsActive") then
					g_soundPlayer:nextChannel();
				end;
			end;
		elseif self.LIC.interactiveObjects[id].event == "radio.channelDown" then
			if g_soundPlayer ~= nil then
				if g_gameSettings:getValue("radioIsActive") then
					g_soundPlayer:previousChannel();
				end;
			end;	
		elseif self.LIC.interactiveObjects[id].event == "mix.cover" then
			if self.setCoverState ~= nil then
				self:setCoverState(self.LIC.interactiveObjects[id].isOpen);
			end;
		--[[ harvesters ]]--
		elseif self.LIC.interactiveObjects[id].event == "chopper" then
			if self.setIsStrawEnabled ~= nil then
				self:setIsStrawEnabled(self.LIC.interactiveObjects[id].isOpen);
			end;
		elseif self.LIC.interactiveObjects[id].event == "pipe" then
			if self.setPipeState ~= nil then
				local nextState = self.pipeTargetState+1;
				if nextState > self.pipeNumStates then
					nextState = 1;
				end;
				if self:getIsPipeStateChangeAllowed(nextState) then
					self:setPipeState(nextState);
				elseif nextState ~= 1 and self:getIsPipeStateChangeAllowed(1) then
					self:setPipeState(1);
				end;
			end;
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_VISIBILITY then
		if self.LIC.interactiveObjects[id].typeChange == "set" then
			if self.LIC.interactiveObjects[id].controlObject ~= nil then
				for _,v2 in ipairs(self.LIC.interactiveObjects[id].objects) do
					setVisibility(v2.object, not( self.LIC.interactiveObjects[id].isOpen == v2.neg ));
				end;
			end;
		elseif self.LIC.interactiveObjects[id].typeChange == "toggle" then
			for _,v2 in ipairs(self.LIC.interactiveObjects[id].objects) do
				setVisibility(v2.object, not getVisibility(v2.object));
			end;
		else
			print("Invalid change type in Interactive Visibility object!")
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_MONITOR then
		local dir = 1;
		if not self.LIC.interactiveObjects[id].isOpen then
			dir = -1;
		end;
		if self.LIC.interactiveObjects[id].startAnimation ~= nil then
			self:playAnimation(self.LIC.interactiveObjects[id].startAnimation, dir, Utils.clamp(self:getAnimationTime(self.LIC.interactiveObjects[id].startAnimation), 0, 1), true);
		end;
		for _,v in pairs(self.LIC.interactiveObjects[id].layerIndexes) do
			setTranslation(v, unpack(self.LIC.interactiveObjects[id].layerBackupPos));
			setVisibility(v, false);
		end;
		if self.LIC.interactiveObjects[id].isOpen then
			setTranslation(self.LIC.interactiveObjects[id].layerIndexes[(self.LIC.interactiveObjects[id].defaultLayer)], unpack(self.LIC.interactiveObjects[id].layerVisPos));
			setVisibility(self.LIC.interactiveObjects[id].layerIndexes[(self.LIC.interactiveObjects[id].defaultLayer)], true);
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_MONITOR_LAYER_BTN then
		if self.LIC.interactiveObjects[id].event == "open" then
			for _,v1 in pairs(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes) do
				setVisibility(v1, false);
				setTranslation(v1, unpack(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerBackupPos));
			end;
			if not self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].moveDef then
				setVisibility(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].defaultLayer)], true);
				setTranslation(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].defaultLayer)], unpack(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerVisPos));
			end;
			setVisibility(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[id].index)], true);
			setTranslation(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[id].index)], unpack(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerVisPos));
		elseif self.LIC.interactiveObjects[id].event == "close" then
			for _,v1 in pairs(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes) do
				setVisibility(v1, false);
				setTranslation(v1, unpack(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerBackupPos));
			end;
			setVisibility(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].defaultLayer)], true);
			setTranslation(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerIndexes[(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].defaultLayer)], unpack(self.LIC.interactiveObjects[(self.LIC.interactiveObjects[id].parentLayer)].layerVisPos));
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS then
		local open = nil;
		if self.LIC.interactiveObjects[id].controlElement ~= nil then
			open = self.LIC.interactiveObjects[id].isOpen;
		end;
		for k,v in pairs(self.LIC.interactiveObjects[id].actionElements) do
			if v then
				self:actionOnObject(k,not open);
			else
				self:actionOnObject(k,open);
			end;
		end;
	end;
	
	if self.LIC.getElementListeners[id] ~= nil then
		for _,v in pairs(self.LIC.getElementListeners[id]) do
			for _,v2 in pairs(self.LIC.objectsListeners[v]) do
				if v2 ~= id then
					self.LIC.interactiveObjects[v2].isOpen = self.LIC.interactiveObjects[id].isOpen;
				end;
			end;
		end;
	end;
	
	if (noEventSend == nil or noEventSend == false) and self.LIC.interactiveObjects[id].synch then
		if g_server ~= nil then
			g_server:broadcastEvent(InteractiveControlEvent:new(self, id, self.LIC.interactiveObjects[id].isOpen), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(InteractiveControlEvent:new(self, id, self.LIC.interactiveObjects[id].isOpen));
		end;
	end;
end;

function InteractiveControl:updateOpenStatus(id)
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_ANIMATION then
		if self.LIC.interactiveObjects[id].animClip ~= nil then 
			if self.LIC.interactiveObjects[id].animClip.animCharSet ~= nil then
				if self.LIC.interactiveObjects[id].looping then
					self.LIC.interactiveObjects[id].isOpen = isAnimTrackEnabled(self.LIC.interactiveObjects[id].animClip.animCharSet, 0);
				else
					-- I3D not looping - no controll!!!!
				end;
			end;
		else
			if self.LIC.interactiveObjects[id].looping then
				self.LIC.interactiveObjects[id].isOpen = self:getIsAnimationPlaying(self.LIC.interactiveObjects[id].animation);
			else
				self.LIC.interactiveObjects[id].isOpen = ( (self.animations[self.LIC.interactiveObjects[id].animation].currentSpeed > 0) and ((self:getAnimationTime(self.LIC.interactiveObjects[id].animation) > 0) or self:getIsAnimationPlaying(self.LIC.interactiveObjects[id].animation)) );
			end;
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_EVENT_BUTTON then
		if self.LIC.interactiveObjects[id].event == "steering.motorIgnition" then
			self.LIC.interactiveObjects[id].isOpen = self.isMotorStarted;
		elseif self.LIC.interactiveObjects[id].event == "steering.reverseDriving" then
			if self.isReverseDriving ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.isReverseDriving;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.1" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 1 then
				self.LIC.interactiveObjects[id].isOpen = self.crabSteering.state == 1;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.2" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 2 then
				self.LIC.interactiveObjects[id].isOpen = self.crabSteering.state == 2;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.3" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 3 then
				self.LIC.interactiveObjects[id].isOpen = self.crabSteering.state == 3;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.4" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 4 then
				self.LIC.interactiveObjects[id].isOpen = self.crabSteering.state == 4;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.12" then
			if self.setCrabSteering ~= nil and self.crabSteering.stateMax >= 2 then
				self.LIC.interactiveObjects[id].isOpen = self.crabSteering.state == 2;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.crabSteering.cycle" then
			-- This event cannot be assumed as open or close
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.toggle" then
			if self.cruiseControl ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE;
			end;
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.speedUp" then
			self.LIC.interactiveObjects[id].isOpen = false;
		elseif self.LIC.interactiveObjects[id].event == "steering.cruiseControl.speedDown" then
			self.LIC.interactiveObjects[id].isOpen = false;
		elseif self.LIC.interactiveObjects[id].event == "steering.lockMovingTools" then
			if self.lmt ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.lmt.toolState == 2;
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.hazard" then
			if self.turnLightState ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.turnLightState == Lights.TURNLIGHT_HAZARD
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.right" then
			if self.turnLightState ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.turnLightState == Lights.TURNLIGHT_RIGHT
			end;
		elseif self.LIC.interactiveObjects[id].event == "turnsignal.left" then
			if self.turnLightState ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.turnLightState == Lights.TURNLIGHT_LEFT
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.front" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 1 then
				self.LIC.interactiveObjects[id].isOpen = ( bitAND(self.lightsTypesMask, 2^0) == 1 );
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.highBeam" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 4 then
				self.LIC.interactiveObjects[id].isOpen = ( bitAND(self.lightsTypesMask, 2^3) == 8 );
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.frontWork" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 3 then
				self.LIC.interactiveObjects[id].isOpen = ( bitAND(self.lightsTypesMask, 2^2) == 4 );
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.rearWork" then
			if self.numLightTypes ~= nil and self.numLightTypes >= 2 then
				self.LIC.interactiveObjects[id].isOpen = ( bitAND(self.lightsTypesMask, 2^1) == 2 );
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.beaconLights" then
			if self.setBeaconLightsVisibility ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.beaconLightsActive;
			end;
		elseif self.LIC.interactiveObjects[id].event == "lights.cablight" then
			if self.cl ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.cl.turnOn;
			end;
		--[[ Implements below ]]--
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = dumpOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = dumpOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.trigger.back" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = dumpOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = dumpGroundOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = dumpGroundOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.ground.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = dumpGroundOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = dumpMixedOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = dumpMixedOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.tipping.mixed.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = dumpMixedOnImplementsStatus(self, implements, id);
		
		--[[ Implements ]]--
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = fillOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = fillOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.filling.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = fillOnImplementsStatus(self, implements, id);
			
		--[[ Turning on ]]--
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = turnOnOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = turnOnOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.turnState.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = turnOnOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = lowerOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = lowerOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.raiseLower.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = lowerOnImplementsStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.all" then
			local implements = InteractiveControl:getICimplements(self, "");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.front" then
			local implements = InteractiveControl:getICimplements(self, "front");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		elseif self.LIC.interactiveObjects[id].event == "implements.fold.middle.rear" then
			local implements = InteractiveControl:getICimplements(self, "back");
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, implements, id);
		--[[ current vehicle ]]--
		elseif self.LIC.interactiveObjects[id].event == "tipping.trigger" then
			self.LIC.interactiveObjects[id].isOpen = dumpOnImplementsStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "tipping.ground" then
			self.LIC.interactiveObjects[id].isOpen = dumpGroundOnImplementsStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "tipping.mixed" then
			self.LIC.interactiveObjects[id].isOpen = dumpMixedOnImplementsStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "filling" then
			self.LIC.interactiveObjects[id].isOpen = fillOnImplementsStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "fold" then
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "fold.middle" then
			self.LIC.interactiveObjects[id].isOpen = foldOnImplementsFinishStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "turnState" then
			self.LIC.interactiveObjects[id].isOpen = turnOnOnImplementsStatus(self, {{object=self}}, id);
		elseif self.LIC.interactiveObjects[id].event == "raiseLower" then
			self.LIC.interactiveObjects[id].isOpen = lowerOnImplementsStatus(self, {{object=self}}, id);
		--[[ MIX ]]--
		elseif self.LIC.interactiveObjects[id].event == "radio.state" then
			self.LIC.interactiveObjects[id].isOpen = false;
			if g_soundPlayer ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.LIC.interactiveObjects[id].isOpen or g_gameSettings:getValue("radioIsActive");
			end;
		elseif self.LIC.interactiveObjects[id].event == "radio.channelUp" then
			self.LIC.interactiveObjects[id].isOpen = false;
		elseif self.LIC.interactiveObjects[id].event == "radio.channelDown" then
			self.LIC.interactiveObjects[id].isOpen = false;
		elseif self.LIC.interactiveObjects[id].event == "mix.cover" then
			if self.setCoverState ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.isCoverOpen;
			end;
		--[[ harvesters ]]--
		elseif self.LIC.interactiveObjects[id].event == "chopper" then
			if self.isStrawEnabled ~= nil then
				self.LIC.interactiveObjects[id].isOpen = self.isStrawEnabled;
			end;
		elseif self.LIC.interactiveObjects[id].event == "pipe" then
			self.LIC.interactiveObjects[id].isOpen = self.pipeTargetState ~= 1;
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_VISIBILITY then
		if self.LIC.interactiveObjects[id].typeChange == "set" then
			if self.LIC.interactiveObjects[id].controlObject ~= nil then
				self.LIC.interactiveObjects[id].isOpen = getVisibility(self.LIC.interactiveObjects[id].controlObject);
			end;
		end;
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_MONITOR then
		-- there is no way
	end;
	
	if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS then
		if self.LIC.interactiveObjects[id].controlElement ~= nil then
			self:updateOpenStatus(self.LIC.interactiveObjects[id].controlElement);
			self.LIC.interactiveObjects[id].isOpen = self.LIC.interactiveObjects[self.LIC.interactiveObjects[id].controlElement].isOpen;
		end;
	end;
end;

function InteractiveControl:checkButtonVisible(id)
	if force == nil or force == false then
		if self.LIC.interactiveObjects[id].objectType == InteractiveControl.OBJECT_TYPE_EVENT_BUTTON then
			if string.sub( self.LIC.interactiveObjects[id].event, 1, 5 ) == "l2gs." and type( self["l2gs" .. string.sub(self.LIC.interactiveObjects[id].event, 6)] ) ~= "function" then
				self.LIC.interactiveObjects[id].doNotShow = true;
			end;
		end;
	end;
end;
