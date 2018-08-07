--
-- Big thanks to all of those who helped with development of IC
-- SFM-Modding, Andy, Ago and others...
-- Original IC:                     Manuel Leithner
-- Edit IC and current development: Martin Fabík (LoogleCZ)
-- Revision for FS17:               Andy (GtX)
-- Testing (Game version: 1.5.1.0):
-- and others...
-- 
-- Free for non-comerecial usage
--
-- GitHub project: https://github.com/LoogleCZ/FS17-InteractiveControl
-- If anyone found errors, please contact me at mar.fabik@gmail.com or report it on GitHub
--
-- version ID   - 4.0.5
-- version date - 2018-02-24 00:39:00
--

InteractiveControl = {};

InteractiveControl.OBJECT_TYPE_ANIMATION         = 0;
InteractiveControl.OBJECT_TYPE_EVENT_BUTTON      = 1;
InteractiveControl.OBJECT_TYPE_MONITOR           = 2;
InteractiveControl.OBJECT_TYPE_MONITOR_LAYER_BTN = 3;
InteractiveControl.OBJECT_TYPE_VISIBILITY        = 4;
InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS     = 5;

local MDR = g_currentModDirectory;
source(MDR.."icSources/actionFunction.lua");
source(MDR.."icSources/InteractiveControlEvent.lua");

function InteractiveControl.prerequisitesPresent(specializations) -- OK
	if not SpecializationUtil.hasSpecialization(AnimatedVehicle, specializations) then
		print("Warning: Specialization InteractiveControl needs the specialization AnimatedVehicle");
		return false;
	end;
	return true;
end;

function InteractiveControl:preLoad(savegame) -- OK
	self.renderOverlayAndInfo = SpecializationUtil.callSpecializationsFunction("renderOverlayAndInfo");
	self.toggleICState = SpecializationUtil.callSpecializationsFunction("toggleICState");
	self.actionOnObject = SpecializationUtil.callSpecializationsFunction("actionOnObject");
	self.updateOpenStatus = SpecializationUtil.callSpecializationsFunction("updateOpenStatus");
	self.checkButtonVisible = SpecializationUtil.callSpecializationsFunction("checkButtonVisible");
	self.buttonSoundUpdate = SpecializationUtil.callSpecializationsFunction("buttonSoundUpdate");
	
	self.LIC = {}; -- prepare 'namespace'
	self.LIC.interactiveObjects = {};
	self.LIC.objectsListeners = {};
	self.LIC.getElementListeners = {};
	self.LIC.partsLength = {};
	self.LIC.sounds = {};
	self.LIC.joints = {};
	self.LIC.joints.front = {};
	self.LIC.joints.back = {};
	self.LIC.playerRotBackup = {};
	self.LIC.loadICButtonFromXML = InteractiveControl.loadICButtonFromXML;
end;

function InteractiveControl:load(savegame)
	local calculateFinalItemIndex = function(itemType, index)
		local calculateIndex=0;
		for i=itemType-1, 0, -1 do
			calculateIndex = calculateIndex + self.LIC.partsLength[i];
		end;
		return calculateIndex+index;
	end;
	
	self.LIC.toggleStyleState = 1;
	self.LIC.lastMouseXPos = 0;
	self.LIC.lastMouseYPos = 0;
	self.LIC.foundInteractiveObject = nil;
	self.LIC.isMouseActive = false;
	self.LIC.isInOutsideRange = false;
	self.LIC.isInitialized = false;
	self.LIC.isClicked = false;
	self.LIC.lastCamIndexUsed = nil;
	self.LIC.outsideTriggerOn = Utils.getNoNil(getXMLBool(self.xmlFile,"vehicle.interactiveComponents#outsideTriggerOn"), false);
	self.LIC.minOutsideDistance = Utils.getNoNil(getXMLFloat(self.xmlFile,"vehicle.interactiveComponents#minOutsideDistance"), 3);
	
	
	-- ===== Loading data from XML =========== --
	local j = 0;
	local i = 0;
	-- ==== Determine front or rear joints === --
	for k,joint in pairs(self.attacherJoints) do
		if joint.jointType == AttacherJoints.JOINTTYPE_IMPLEMENT or joint.jointType == AttacherJoints.JOINTTYPE_CUTTER or joint.jointType == AttacherJoints.JOINTTYPE_CUTTERHARVESTER or joint.jointType == AttacherJoints.JOINTTYPE_TRAILER or joint.jointType == AttacherJoints.JOINTTYPE_TRAILERLOW then
			local x,y,z = getWorldTranslation(self.attacherJoints[k].jointTransform);
			local rx,ry,rz = worldToLocal(self.rootNode,x,y,z);
			if rz > 0 then
				table.insert(self.LIC.joints.front,k);
			else
				table.insert(self.LIC.joints.back,k);
			end;
		end;
	end;
	-- ============= Animations ============== --
	
	if hasXMLProperty(self.xmlFile, "vehicle.interactiveComponents.windows") then
		print("[ERROR]: Windows nodes are deprecated in this version of IC.");
		print("   Please use animations.animation notation instead");
	end;
	
	i = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_ANIMATION] = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.animations.animation(%d)", i);
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		local animation = getXMLString(self.xmlFile, key .. "#animName");
		local looping = Utils.getNoNil(getXMLBool(self.xmlFile, key.."#looping"), false);
		local speedScale = -Utils.getNoNil(getXMLFloat(self.xmlFile, key .. "#animSpeedScale"), 1);
		local clipParent = Utils.indexToObject(self.components, getXMLString(self.xmlFile, key .. "#clipRoot"));
		local animClip = nil;
		if clipParent ~= nil and clipParent ~= 0 then
			animClip = {};
			animClip.animCharSet = getAnimCharacterSet(clipParent);
			if animClip.animCharSet ~= 0 then
				local clip = getAnimClipIndex(animClip.animCharSet, getXMLString(self.xmlFile, key .. "#clip"));
				assignAnimTrackClip(animClip.animCharSet, 0, clip);
				setAnimTrackLoopState(animClip.animCharSet, 0, looping);
				animClip.animDuration = getAnimClipDuration(animClip.animCharSet, clip);
				setAnimTrackTime(animClip.animCharSet, 0, 0);
			end;
		end;
		if animation ~= nil or animClip ~= nil then
			self.LIC.interactiveObjects[j] = {};
			self.LIC.interactiveObjects[j].animation = animation;
			self.LIC.interactiveObjects[j].animClip = animClip;
			self.LIC.interactiveObjects[j].speedScale = speedScale;
			self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_ANIMATION;
			self.LIC.interactiveObjects[j].looping = looping;
			self.LIC.interactiveObjects[j].saveStatus = Utils.getNoNil(getXMLBool(self.xmlFile, key .. "#saveAnimationStatus"), false);
			self.LIC:loadICButtonFromXML(self, self.xmlFile, key, self.LIC.interactiveObjects[j], j);
			self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_ANIMATION] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_ANIMATION] + 1;
			j = j + 1;
		else
			print(string.format("[ERROR]: Cannot load Interactive Compoment - vehicle.interactiveComponents.animations.animation(%d)",i));
			print("  - Missing animation name or animation clip. Please state valid animation name or valid clipRoot");
		end;
		i = i + 1;
	end;
	--============= Event buttons =============--	
	i = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_EVENT_BUTTON] = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.buttons.button(%d)", i);
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		local event = getXMLString(self.xmlFile, key .. "#event");
		if event ~= nil then
			self.LIC.interactiveObjects[j] = {};
			self.LIC.interactiveObjects[j].event = event;
			self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_EVENT_BUTTON;
			self.LIC:loadICButtonFromXML(self, self.xmlFile, key, self.LIC.interactiveObjects[j], j);
			j = j + 1;
			self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_EVENT_BUTTON] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_EVENT_BUTTON] + 1;
		else
			print(string.format("[ERROR]: Cannot load event button - vehicle.interactiveComponents.buttons.button(%d)",i));
			print("  - You must fill event attribute!");
		end;		
		i = i + 1;
	end;
	--================ Monitors ===============--
	i = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR_LAYER_BTN] = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.monitors.monitor(%d)", i);	
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		local layerBackupPos = getXMLString(self.xmlFile, key .. "#layerClosePos");
		local layerVisPos = getXMLString(self.xmlFile, key .. "#layerVisPos");
		if layerBackupPos ~= nil and layerVisPos ~= nil then
			local defaultLayer = getXMLInt(self.xmlFile, key .. "#defaultLayer");
			self.LIC.interactiveObjects[j] = {};
			self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_MONITOR;
			self.LIC.interactiveObjects[j].useStart = Utils.getNoNil(getXMLBool(self.xmlFile, key .. "#useStart"), true);
			self.LIC.interactiveObjects[j].startAnimation = getXMLString(self.xmlFile, key .. "#animName");
			self.LIC.interactiveObjects[j].defaultLayer = defaultLayer;
			self.LIC.interactiveObjects[j].moveDef = Utils.getNoNil(getXMLBool(self.xmlFile, key .. "#moveDefaultLayer"), false);
			self.LIC.interactiveObjects[j].layerBackupPos = {};
			self.LIC.interactiveObjects[j].layerBackupPos[1],self.LIC.interactiveObjects[j].layerBackupPos[2],self.LIC.interactiveObjects[j].layerBackupPos[3] = Utils.getVectorFromString(layerBackupPos);
			self.LIC.interactiveObjects[j].layerVisPos = {};
			self.LIC.interactiveObjects[j].layerVisPos[1],self.LIC.interactiveObjects[j].layerVisPos[2],self.LIC.interactiveObjects[j].layerVisPos[3] = Utils.getVectorFromString(layerVisPos);
			self.LIC.interactiveObjects[j].layerIndexes = {};
			local k = 0;
			local upperLayerIndex = j;
			while true do
				local key2 = string.format(key..".layer(%d)", k);
				if not hasXMLProperty(self.xmlFile, key2) then
					break;
				end;
				local index = Utils.indexToObject(self.components, getXMLString(self.xmlFile, key2 .. "#index"));				
				if index ~= nil then
					local name = Utils.getNoNil((getXMLString(self.xmlFile, key2 .. "#name")), "modHub_error");
					local onMessage = g_i18n:getText(Utils.getNoNil(getXMLString(self.xmlFile, key2 .. "#onMessage"), "action_turnOnOBJECT"));
					local offMessage =  g_i18n:getText(Utils.getNoNil(getXMLString(self.xmlFile, key2 .. "#offMessage"), "action_turnOffOBJECT"));
					
					local markOpenData = {};
					local markCloseData = {};
					markOpenData.mark, markOpenData.size, markOpenData.pulse, markOpenData.scaleX, markOpenData.scaleY, markOpenData.scaleZ, markOpenData.pulsingMark, markOpenData.pulseScaleX, markOpenData.pulseScaleY, markOpenData.pulseScaleZ, markOpenData.playClickSound = InteractiveControl:loadMarkSettings(self.components, self.xmlFile, key2 .. ".open");
					markCloseData.mark, markCloseData.size, markCloseData.pulse, markCloseData.scaleX, markCloseData.scaleY, markCloseData.scaleZ, markCloseData.pulsingMark, markCloseData.pulseScaleX, markCloseData.pulseScaleY, markCloseData.pulseScaleZ, markOpenData.playClickSound = InteractiveControl:loadMarkSettings(self.components, self.xmlFile, key2 .. ".close");
					self.LIC.interactiveObjects[upperLayerIndex].layerIndexes[k] = index;
					if markOpenData.mark ~= nil and markCloseData.mark ~= nil then
						j = j + 1;
						self.LIC.interactiveObjects[j] = {};
						self.LIC.interactiveObjects[j].event = "open";
						self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_MONITOR_LAYER_BTN;
						self.LIC.interactiveObjects[j].index = k;
						self.LIC.interactiveObjects[j].name = name;
						for k,v in pairs(markOpenData) do 
							self.LIC.interactiveObjects[j][k] = v;
						end;
						self.LIC.interactiveObjects[j].onMessage = onMessage;
						self.LIC.interactiveObjects[j].offMessage = onMessage;
						self.LIC.interactiveObjects[j].synch = self.LIC.interactiveObjects[upperLayerIndex].synch;
						self.LIC.interactiveObjects[j].parentLayer = upperLayerIndex;
						self.LIC.interactiveObjects[j].isOpen = false;
						self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] + 1;
						j = j + 1;
						self.LIC.interactiveObjects[j] = {};
						self.LIC.interactiveObjects[j].event = "close";
						self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_MONITOR_LAYER_BTN;
						self.LIC.interactiveObjects[j].index = k;
						self.LIC.interactiveObjects[j].name = name;
						for k,v in pairs(markCloseData) do 
							self.LIC.interactiveObjects[j][k] = v;
						end;
						self.LIC.interactiveObjects[j].onMessage = offMessage;
						self.LIC.interactiveObjects[j].offMessage = offMessage;
						self.LIC.interactiveObjects[j].synch = self.LIC.interactiveObjects[upperLayerIndex].synch;
						self.LIC.interactiveObjects[j].parentLayer = upperLayerIndex;
						self.LIC.interactiveObjects[j].isOpen = false;
						self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] + 1;
						setVisibility(index, false);
					end;
				else
					print("[ERROR]: Error while loading monitor layer - you must specify layer index.");
				end;
				k = k + 1;
			end;
			j = j + 1;
			self:actionOnObject(upperLayerIndex, false);
			self.LIC:loadICButtonFromXML(self, self.xmlFile, key, self.LIC.interactiveObjects[upperLayerIndex], upperLayerIndex);
			self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MONITOR] + 1;
		else
			print(string.format("[ERROR]: Cannot load Interactive monitor - vehicle.interactiveComponents.monitors.monitor(%d)",i));
			print("  - invalid backup and vis positions");
		end;
		i = i + 1;
	end;
	--========== Visibility	buttons ===========--	
	i = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_VISIBILITY] = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.visControls.button(%d)", i);
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		self.LIC.interactiveObjects[j] = {};
		self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_VISIBILITY;
		self.LIC.interactiveObjects[j].typeChange = Utils.getNoNil(getXMLString(self.xmlFile, key .. "#typeChange"), "set");
		local controlObject = getXMLString(self.xmlFile, key .. "#controlElem");
		local defVis = getXMLBool(self.xmlFile, key .. "#defaultVis");
		if controlObject ~= nil then
			self.LIC.interactiveObjects[j].controlObject = Utils.indexToObject(self.components, controlObject); 
		end;
		self.LIC.interactiveObjects[j].objects = {};
		local k = 0;
		local l = 1;
		while true do
			local key2 = string.format(key..".object(%d)", k);
			if not hasXMLProperty(self.xmlFile, key2) then
				break;
			end;
			local index = getXMLString(self.xmlFile, key2.."#index");
			local statusNegation = Utils.getNoNil(getXMLBool(self.xmlFile, key2.."#neg"), false);
			if index ~= nil then
				self.LIC.interactiveObjects[j].objects[l] = {object=Utils.indexToObject(self.components, index), neg=statusNegation};
				if defVis ~= nil then
					setVisibility(self.LIC.interactiveObjects[j].objects[l].object, not( defVis == statusNegation ) );
				end;
				l = l + 1;
			end;
			k = k + 1;
		end;
		self.LIC.interactiveObjects[j].saveStatus = Utils.getNoNil(getXMLBool(self.xmlFile, key .. "#saveAnimationStatus"), false);
		self.LIC:loadICButtonFromXML(self, self.xmlFile, key, self.LIC.interactiveObjects[j], j);
		self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_VISIBILITY] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_VISIBILITY] + 1;
		j = j + 1;
		i = i + 1;
	end;
	--============ MULTI BUTTONS ==============--
	i = 0;
	self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS] = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.multiButtons.mbutton(%d)", i);	
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		self.LIC.interactiveObjects[j] = {};
		self.LIC:loadICButtonFromXML(self, self.xmlFile, key, self.LIC.interactiveObjects[j], j);
		self.LIC.interactiveObjects[j].objectType = InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS;
		
		if hasXMLProperty(self.xmlFile, key..".control") then
			local mbtype = getXMLString(self.xmlFile, key..".control#type");
			if InteractiveControl[mbtype] ~= nil and type(InteractiveControl[mbtype]) == "number" then
				local index = getXMLInt(self.xmlFile, key..".control#index");
				if index <= self.LIC.partsLength[InteractiveControl[mbtype]] then
					local indexFinal = calculateFinalItemIndex(InteractiveControl[mbtype], index);
					self.LIC.interactiveObjects[j].controlElement = indexFinal;
				end;
			else
				print("[ERROR]: Interactive control: invalid type in " .. key .. ".control");
			end;
		end;
		local k = 0;
		self.LIC.interactiveObjects[j].actionElements = {};
		while true do
			key2 = string.format(key..".part(%d)",k);
			if not hasXMLProperty(self.xmlFile, key2) then
				break;
			end;
			local mbtype = getXMLString(self.xmlFile, key2.."#type");
			if InteractiveControl[mbtype] ~= nil and type(InteractiveControl[mbtype]) == "number" then
				local index = getXMLInt(self.xmlFile, key2.."#index");
				local neg = Utils.getNoNil(getXMLInt(self.xmlFile, key2.."#negStatus"),false);
				if index <= self.LIC.partsLength[InteractiveControl[mbtype]] then
					local indexFinal = calculateFinalItemIndex(InteractiveControl[mbtype], index);
					self.LIC.interactiveObjects[j].actionElements[indexFinal] = neg;
				end;
			else
				print("[ERROR]: Interactive control: invalid type in " .. key2);
			end;
			k = k + 1;
		end;
		j = j + 1;
		self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS] = self.LIC.partsLength[InteractiveControl.OBJECT_TYPE_MULTI_BUTTONS] + 1;
		i = i + 1;
	end;
	-- ======= Cross button listenesr ======== --
	i = 0;
	while true do
		local key = string.format("vehicle.interactiveComponents.buttonsListeners.listener(%d)", i);	
		if not hasXMLProperty(self.xmlFile, key) then
			break;
		end;
		self.LIC.objectsListeners[i] = {};
		local j = 0;
		while true do
			local key2 = string.format(key .. ".element(%d)", j);
			if not hasXMLProperty(self.xmlFile, key2) then
				break;
			end;
			local Ltype = getXMLString(self.xmlFile, key2.."#type");
			if InteractiveControl[Ltype] ~= nil and type(InteractiveControl[Ltype]) == "number" then
				local Oindex = getXMLInt(self.xmlFile, key2.."#index");
				if Oindex ~= nil and self.LIC.partsLength[InteractiveControl[Ltype]] ~= nil and Oindex <= self.LIC.partsLength[InteractiveControl[Ltype]] then
					local indexFinal = calculateFinalItemIndex(InteractiveControl[Ltype], Oindex);
					table.insert(self.LIC.objectsListeners[i],indexFinal);
					if self.LIC.getElementListeners[indexFinal] == nil then
						table.insert(self.LIC.getElementListeners,indexFinal,{});
					end;
					self.LIC.getElementListeners[indexFinal][table.getn(self.LIC.getElementListeners[indexFinal])] = i;
				end;
			else
				print("[ERROR]: Invalid type in " .. key2);
			end;
			j = j + 1;
		end;
		i = i + 1;
	end;
	--============= Load sounds ===============--
	if self.isClient then
		i = 0;
		while true do
			local key = string.format("vehicle.interactiveComponents.sounds.sound(%d)", i)
			if not hasXMLProperty(self.xmlFile, key) then
				break
			end;
			
			local index = getXMLInt(self.xmlFile, key.."#index");
			local stype = getXMLString(self.xmlFile, key.."#type");
			if InteractiveControl[stype] ~= nil and type(InteractiveControl[stype]) == "number" then
				if index <= self.LIC.partsLength[InteractiveControl[stype]] then
					local sound = {};
					sound.componentIndex = calculateFinalItemIndex(InteractiveControl[stype], index);
					sound.componentStatus = self.LIC.interactiveObjects[sound.componentIndex].isOpen;
					sound.openingSound = SoundUtil.loadSample(self.xmlFile, {}, key..".opening", nil, self.baseDirectory);
					sound.closingSound = SoundUtil.loadSample(self.xmlFile, {}, key..".closing", nil, self.baseDirectory);
					sound.openSound = SoundUtil.loadSample(self.xmlFile, {}, key..".open", nil, self.baseDirectory);
					sound.closeSound = SoundUtil.loadSample(self.xmlFile, {}, key..".close", nil, self.baseDirectory);
					table.insert(self.LIC.sounds, sound);
				else					
					print("[ERROR]: Index out of range in " .. tostring(key));
				end;
			else
				print("[ERROR]: Invalid component type in " .. tostring(key));
			end;
			i = i + 1			
		end;
	end;
end;

function InteractiveControl:postLoad(savegame) -- init actions here
	local calculateFinalItemIndex = function(itemType, index)
		local calculateIndex=0;
		for i=itemType-1, 0, -1 do
			calculateIndex = calculateIndex + self.LIC.partsLength[i];
		end;
		return calculateIndex+index;
	end;

	for k,_ in pairs(self.LIC.interactiveObjects) do
		if self.LIC.interactiveObjects[k].initAction ~= nil and self.LIC.interactiveObjects[k].initAction then
			self:actionOnObject(k, self.LIC.interactiveObjects[k].isOpen, true);
		end;
		self:checkButtonVisible(k);
	end;

	if savegame ~= nil then
		local icToggleStyle = getXMLInt(savegame.xmlFile, savegame.key..".interactiveControl#toggleStyle");
		if icToggleStyle ~= nil then
			self.LIC.toggleStyleState = icToggleStyle;
		end;
		
		local i = 0;
		while true do
			local key = savegame.key .. string.format(".interactiveControl.animation(%d)", i);
			if not hasXMLProperty(savegame.xmlFile, key) then
				break;
			end;
			local index = getXMLInt(savegame.xmlFile, key .. "#id");
			if index == nil then
				break;
			end;
			local status = Utils.getNoNil(getXMLBool(savegame.xmlFile, key .. "#status"), false);
			index = calculateFinalItemIndex(InteractiveControl.OBJECT_TYPE_ANIMATION, index);
			self:actionOnObject(index, status, true);
			i = i + 1;
		end;
		
		local i = 0;
		while true do
			local key = savegame.key .. string.format(".interactiveControl.visControl(%d)", i);
			if not hasXMLProperty(savegame.xmlFile, key) then
				break;
			end;
			local index = getXMLInt(savegame.xmlFile, key .. "#id");
			if index == nil then
				break;
			end;
			local status = Utils.getNoNil(getXMLBool(savegame.xmlFile, key .. "#status"), false);
			index = calculateFinalItemIndex(InteractiveControl.OBJECT_TYPE_ANIMATION, index);
			self:actionOnObject(index, status, true);
			i = i + 1;
		end;
	end;
end;

function InteractiveControl:getSaveAttributesAndNodes(nodeIdent)
	local calculateSmallIndexForm = function(objectType, index) 
		local minusIndex=0;
		for i=objectType-1, 0, -1 do
			minusIndex = minusIndex - self.LIC.partsLength[i];
		end;
		return minusIndex+index;
	end;

    local nodes = "\t\t<interactiveControl toggleStyle=\"" .. self.LIC.toggleStyleState .. "\">\n";
	for k,v in pairs(self.LIC.interactiveObjects) do
		if v.objectType == InteractiveControl.OBJECT_TYPE_ANIMATION then
			if v.saveStatus then
				nodes = nodes .. '\t\t\t<animation id="' .. calculateSmallIndexForm(InteractiveControl.OBJECT_TYPE_ANIMATION, k) .. '" status="' .. tostring(v.isOpen) .. '"/>\n';
			end;
		end;
		if v.objectType == InteractiveControl.OBJECT_TYPE_VISIBILITY then
			if v.saveStatus and v.controlObject ~= nil then
				nodes = nodes .. '\t\t\t<visControl id="' .. calculateSmallIndexForm(InteractiveControl.OBJECT_TYPE_VISIBILITY, k) .. '" status="' .. tostring(v.isOpen) .. '"/>\n';
			end;
		end;
	end;
    nodes = nodes .. "\t\t</interactiveControl>";
    return nil, nodes;
end

function InteractiveControl:delete()
	if self.isClient then
		for _,v in pairs(self.LIC.sounds) do
			SoundUtil.deleteSample(v.openingSound);
			SoundUtil.deleteSample(v.closingSound);
			SoundUtil.deleteSample(v.openSound);
			SoundUtil.deleteSample(v.closeSound);
		end;
	end;
end;

function InteractiveControl:readStream(streamId, connection) -- OK
	local icCount = streamReadInt8(streamId);
	for i=0, icCount do
		local isOpen = streamReadBool(streamId);
		if self.LIC.interactiveObjects[i] ~= nil then
			if self.LIC.interactiveObjects[i].synch then
				self:actionOnObject(i, isOpen, false);
			end;
		end;
	end;
end;

function InteractiveControl:writeStream(streamId, connection) -- OK
	local icCount = (table.getn(self.LIC.interactiveObjects)-1);
	streamWriteInt8(streamId, icCount);
	for i=0, icCount do
		streamWriteBool(streamId, self.LIC.interactiveObjects[i].isOpen);
	end;
end;

function InteractiveControl:mouseEvent(posX, posY, isDown, isUp, button) -- OK
	self.LIC.lastMouseXPos = posX;
    self.LIC.lastMouseYPos = posY;
end;

function InteractiveControl:keyEvent(unicode, sym, modifier, isDown) -- OK
end;

function InteractiveControl:update(dt) -- OK
	if self.isClient then
		if self:getIsActiveForSound() then -- sounds
			for _,v in pairs(self.LIC.sounds) do
				local object = self.LIC.interactiveObjects[v.componentIndex];
				
				if object.isOpen and v.openSound ~= nil then
					SoundUtil.playSample(v.openSound, 0, 0, nil);
				else
					SoundUtil.stopSample(v.openSound);
				end;
				if not object.isOpen and v.closeSound ~= nil then
					SoundUtil.playSample(v.closeSound, 0, 0, nil);
				else
					SoundUtil.stopSample(v.closeSound);
				end;
				if object.isOpen ~= v.componentStatus then
					if object.isOpen and v.openingSound ~= nil then
						SoundUtil.playSample(v.openingSound, 1, 0, nil);
						if v.closingSound ~= nil then
							SoundUtil.stopSample(v.closingSound);
						end;
					end;
					if not object.isOpen and v.closingSound ~= nil then
						SoundUtil.playSample(v.closingSound, 1, 0, nil);
						if v.openingSound ~= nil then
							SoundUtil.stopSample(v.openingSound);
						end;
					end;
				end;
				v.componentStatus = object.isOpen;
			end;
		end;
		
		-- if user toggle cam disable IC
		if self.LIC.lastCamIndexUsed ~= nil
			and self.LIC.lastCamIndexUsed ~= self.camIndex then
			self:toggleICState(nil, false);
		end;
		
		if self.isMotorStarted then -- monitor on/off on start
			self.forceIsActive = true;
			if not self.LIC.isInitialized then
				self.LIC.isInitialized = not self.LIC.isInitialized;
				for k,v in pairs(self.LIC.interactiveObjects) do
					if v.objectType == InteractiveControl.OBJECT_TYPE_MONITOR and v.useStart then
						self:actionOnObject(k, true);
					end;
				end;
			end;
		else
			self.forceIsActive = false;
			if self.LIC.isInitialized then
				self.LIC.isInitialized = not self.LIC.isInitialized;
				for k,v in pairs(self.LIC.interactiveObjects) do
					if v.objectType == InteractiveControl.OBJECT_TYPE_MONITOR and v.useStart then
						self:actionOnObject(k, false);
					end;
				end;
			end;
		end;

		if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT) and self.LIC.foundInteractiveObject ~= nil then
			if not self.LIC.isClicked then
				self.LIC.isClicked = true;
				self:actionOnObject(self.LIC.foundInteractiveObject);
				if self:getIsActiveForSound() then
					if self.LIC.interactiveObjects[self.LIC.foundInteractiveObject].playClickSound and g_currentMission.sampleToggleLights ~= nil then
						SoundUtil.playSample(g_currentMission.sampleToggleLights, 1, 0, 1);
					end;
				end;
			end;
		else
			self.LIC.isClicked = false;
		end;
		
		if self.LIC.isInOutsideRange or (self:getIsActive() and self:getIsActiveForInput(false) and not self:hasInputConflictWithSelection() and self.isEntered) then
			if self:getIsActive() then -- toggle IC toggle type (only when we have help)
				if InputBinding.hasEvent(InputBinding.INTERACTIVE_CONTROL_MODE) then
					self.LIC.toggleStyleState = self.LIC.toggleStyleState + 1;
					if self.LIC.toggleStyleState > 2 then
						self.LIC.toggleStyleState = 1;
					end;
				end;
			end;
			
			if self.LIC.toggleStyleState == 1 then
				if InputBinding.hasEvent(InputBinding.INTERACTIVE_CONTROL_SWITCH) then
					self:toggleICState(self.LIC.isInOutsideRange);
				end;
				if self.LIC.isMouseActive then
					g_currentMission:addHelpButtonText(g_i18n:getText("InteractiveControl_Off"), InputBinding.INTERACTIVE_CONTROL_SWITCH);
				else
					g_currentMission:addHelpButtonText(g_i18n:getText("InteractiveControl_On"), InputBinding.INTERACTIVE_CONTROL_SWITCH);
				end;
			elseif self.LIC.toggleStyleState == 2 then
				if InputBinding.isPressed(InputBinding.INTERACTIVE_CONTROL_SWITCH) then
					if not self.LIC.isMouseActive then
						self:toggleICState(self.LIC.isInOutsideRange, true);
					end;
				else
					if self.LIC.isMouseActive then
						self:toggleICState(self.LIC.isInOutsideRange, false);
					end;
				end;
				if not self.LIC.isMouseActive then
					g_currentMission:addHelpButtonText(g_i18n:getText("InteractiveControl_On"), InputBinding.INTERACTIVE_CONTROL_SWITCH);
				end;
			end;
			
			-- help for toggle style
			if self.LIC.toggleStyleState == 1 then
				if self.LIC.isMouseActive then
					g_currentMission:addHelpButtonText(string.format(g_i18n:getText("InteractiveControl_ModeSelect"), g_i18n:getText("button_normal")), InputBinding.INTERACTIVE_CONTROL_MODE, nil, GS_PRIO_HIGH)
				end;
			elseif self.LIC.toggleStyleState == 2 then
				if self.LIC.isMouseActive then
					g_currentMission:addHelpButtonText(string.format(g_i18n:getText("InteractiveControl_ModeSelect"), g_i18n:getText("InteractiveControl_Quick")), InputBinding.INTERACTIVE_CONTROL_MODE, nil, GS_PRIO_HIGH)
				end;
			end;
		end;

		-- reset components
		for _,v in pairs(self.LIC.interactiveObjects) do
			v.isEntered = false;
			if v.pulse ~= nil then
				if v.pulsingMark then
					setScale(v.pulse, v.scaleX, v.scaleY, v.scaleZ);
				end;
			end;
		end;
		
		-- for outside IC
		if self.LIC.isMouseActive then
			if not self.isEntered then
				self.LIC.foundInteractiveObject = nil; -- reset and search again
				self.LIC.lastMouseXPos = InputBinding.mousePosXLast;
				self.LIC.lastMouseYPos = InputBinding.mousePosYLast;
				if self.LIC.lastMouseXPos ~= nil and self.LIC.lastMouseYPos ~= nil then
					for k,v in pairs(self.LIC.interactiveObjects) do
						if v.canOutside and v.mark ~= nil and (v.doNotShow == nil or v.doNotShow == false) then
							local worldX,worldY,worldZ = getWorldTranslation(v.mark);
							local x,y,z = project(worldX,worldY,worldZ);
							if z <= 1 then
								if self.LIC.lastMouseXPos > (x-v.size/2) and self.LIC.lastMouseXPos < (x+v.size/2) then
									if self.LIC.lastMouseYPos > (y-v.size/2) and self.LIC.lastMouseYPos < (y+v.size/2) then
										v.isEntered = true;
										self:updateOpenStatus(k);
										self:renderOverlayAndInfo(v);
										self.LIC.foundInteractiveObject = k;
										break;
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		
			if self.LIC.foundInteractiveObject ~= nil then
				local foundItem = self.LIC.interactiveObjects[self.LIC.foundInteractiveObject];
				if foundItem.pulse ~= nil then
					if foundItem.pulsingMark then
						local sx,sy,sz = getScale(foundItem.pulse);
						sx = sx - (foundItem.pulseScaleX/400) * dt;
						sy = sy - (foundItem.pulseScaleY/400) * dt;
						sz = sz - (foundItem.pulseScaleZ/400) * dt;
						if sx < (foundItem.scaleX - foundItem.pulseScaleX)
							or sy < (foundItem.scaleY - foundItem.pulseScaleY)
							or sz < (foundItem.scaleZ - foundItem.pulseScaleZ) then
							setScale(foundItem.pulse,
								(foundItem.scaleX + foundItem.pulseScaleX),
								(foundItem.scaleY + foundItem.pulseScaleY),
								(foundItem.scaleZ + foundItem.pulseScaleZ));
						else
							setScale(foundItem.pulse, sx, sy, sz);
						end;
					end;
				end;
			end;
		else
			self.LIC.foundInteractiveObject = nil; -- reset because we don't have IC
		end;
	end;
end;

function InteractiveControl:updateTick(dt) -- OK
	if g_currentMission.player ~= nil then
		local px, py, pz = getWorldTranslation(self.rootNode); 
		local vx, vy, vz = getWorldTranslation(g_currentMission.player.rootNode);
		local distance = Utils.vector3Length(px-vx, py-vy, pz-vz);
		if self.LIC.outsideTriggerOn then
			if distance < self.LIC.minOutsideDistance then
				self.LIC.isInOutsideRange = true;
			else
				if self.LIC.isInOutsideRange then
					self:toggleICState(nil, false);
					self.LIC.isInOutsideRange = false;
				end;
			end;
		end;
	end;
end;

function InteractiveControl:draw() -- OK - inside needs to be in draw for more accurate results
	if self.LIC.isMouseActive and self.isEntered then
		self.LIC.foundInteractiveObject = nil; -- reset and search again
		if self.LIC.lastMouseXPos ~= nil and self.LIC.lastMouseYPos ~= nil then
			for k,v in pairs(self.LIC.interactiveObjects) do
				if v.mark ~= nil and not v.canOutside and (v.doNotShow == nil or v.doNotShow == false) then
					local worldX,worldY,worldZ = getWorldTranslation(v.mark);
					local x,y,z = project(worldX,worldY,worldZ);
					if z <= 1 then
						if self.LIC.lastMouseXPos > (x-v.size/2) and self.LIC.lastMouseXPos < (x+v.size/2) then
							if self.LIC.lastMouseYPos > (y-v.size/2) and self.LIC.lastMouseYPos < (y+v.size/2) then
								v.isEntered = true;
								self:updateOpenStatus(k);
								self:renderOverlayAndInfo(v);
								self.LIC.foundInteractiveObject = k;
								break;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

function InteractiveControl:onEnter() -- OK
end;

function InteractiveControl:onLeave() -- OK
	self:toggleICState(nil, false);
	if g_gui.currentGui == nil then
		InputBinding.setShowMouseCursor(false);
	end;
end;

function InteractiveControl:renderOverlayAndInfo(object) -- OK
	local message = "";
	if object.isOpen then
		message = object.offMessage;
	else
		message = object.onMessage;
	end;
	if g_currentMission.showHudEnv then
		g_currentMission:addExtraPrintText(string.format(message, object.name));
	end;
	if object.renderStatusText then
		setTextColor(1.0, 1.0, 1.0, 1.0);
		setTextAlignment(RenderText.ALIGN_CENTER); 				
		renderText( 0.5, 0.06, 0.02, string.format(message, object.name));
	end;
end;

function InteractiveControl:toggleICState(isOutside, forceStatus) -- OK
	if self.isClient then
		if self.LIC.isMouseActive == nil then
			self.LIC.isMouseActive = false;
			self:toggleICState(false, true);
			self:toggleICState(false, false);
		end;
		if self.LIC.isMouseActive ~= forceStatus then
			if forceStatus == nil then
				self.LIC.isMouseActive = not self.LIC.isMouseActive;
			else
				self.LIC.isMouseActive = forceStatus;
			end;
			
			if self.LIC.isMouseActive then
				if g_currentMission.player ~= nil then
					local x,y,z = getRotation(g_currentMission.player.cameraNode);
					g_currentMission.player.backupCamPosition = {x,y,z};
					g_currentMission.player.walkingIsLocked = true;
				end;
				InputBinding.setShowMouseCursor(true);
				
				if self.cameras ~= nil then
					for _,v in pairs(self.cameras) do
						v.isActivated = false;
					end;
				end;
				if self.camIndex ~= nil then
					self.LIC.lastCamIndexUsed = self.camIndex;
				end;
				
				for k,v in pairs(self.LIC.interactiveObjects) do
					if v.doNotShow == nil or v.doNotShow == false then
						if isOutside and v.canOutside then
							if v.mark ~= nil then
								setVisibility(v.mark, true);
							end;
						elseif (not isOutside or isOutside == nil) and not v.canOutside then
							if v.mark ~= nil then
								setVisibility(v.mark, true);
							end;
						end;
					end;
				end;
			else
				self.LIC.foundInteractiveObject = nil;
				if g_currentMission.player ~= nil then
					g_currentMission.player.walkingIsLocked = false;
					g_currentMission.player.rotX = g_currentMission.player.backupCamPosition[1];
					g_currentMission.player.rotY = g_currentMission.player.backupCamPosition[2];
				end;
				InputBinding.setShowMouseCursor(false);
				
				if self.cameras ~= nil then
					for _,v in pairs(self.cameras) do
						v.isActivated = true;
					end;
				end;
				
				for _,v in pairs(self.LIC.interactiveObjects) do
					v.isEntered = false;
					if v.mark ~= nil then
						setVisibility(v.mark, false);
					end;
				end;
			end;
		end;
	end;
end;

function InteractiveControl:loadICButtonFromXML(vehicle, xmlFile, key, ICBtn, index) -- OK
	ICBtn.name = g_i18n:getText(Utils.getNoNil((getXMLString(xmlFile, key .. "#name")), "modHub_error"));

	ICBtn.mark, ICBtn.size, ICBtn.pulse, ICBtn.scaleX, ICBtn.scaleY, ICBtn.scaleZ, ICBtn.pulsingMark, ICBtn.pulseScaleX, ICBtn.pulseScaleY, ICBtn.pulseScaleZ, ICBtn.playClickSound = InteractiveControl:loadMarkSettings(vehicle.components, xmlFile, key);
	
	ICBtn.renderStatusText = Utils.getNoNil(getXMLBool(xmlFile, key .. "#renderStatusText"), true);
	ICBtn.isOpen = Utils.getNoNil((getXMLBool(xmlFile, key .. "#defaultStatus")), false);
	ICBtn.onMessage = g_i18n:getText(Utils.getNoNil(getXMLString(xmlFile, key .. "#onMessage"), "action_turnOnOBJECT"));
	ICBtn.offMessage =  g_i18n:getText(Utils.getNoNil(getXMLString(xmlFile, key .. "#offMessage"), "action_turnOffOBJECT"));
		
	ICBtn.canOutside =  Utils.getNoNil(getXMLBool(xmlFile, key.."#isOutside"), false);
	ICBtn.synch =  Utils.getNoNil(getXMLBool(xmlFile, key.."#synch"), true);
	
	ICBtn.isEntered = false;
	
	local initAction = Utils.getNoNil((getXMLBool(xmlFile, key .. "#initAction")), false);
	if initAction and index ~= nil and vehicle.isServer then
		ICBtn.initAction = true;
	end;
end;

function InteractiveControl:loadMarkSettings(components ,xmlFile, key) -- OK
	if not hasXMLProperty(xmlFile, key) then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil;
	end;
	local mark = Utils.indexToObject(components, getXMLString(xmlFile, key .. "#mark"));
	local size = Utils.getNoNil((getXMLFloat(xmlFile, key .. "#size")), 0.05);
	local pulse = nil;
	local scaleX,scaleY,scaleZ = nil,nil,nil;
	local pulsingMark = Utils.getNoNil(getXMLBool(xmlFile, key .. "#pulsingMark"), false);
	local pulseScaleX,pulseScaleY,pulseScaleZ = Utils.getVectorFromString(Utils.getNoNil(getXMLString(xmlFile, key .. "#pulseScale"), "0.01 0.01 0.01"));
	if mark ~= nil then
		setVisibility(mark,false);
		pulse = getChildAt(mark, 0);
		scaleX, scaleY, scaleZ = getScale(pulse);
	end;
	local playSound = Utils.getNoNil(getXMLBool(xmlFile, key.."#playClickSound"), false);
	return mark, size, pulse, scaleX, scaleY, scaleZ, pulsingMark, pulseScaleX, pulseScaleY, pulseScaleZ, playSound;
end;

function InteractiveControl:getICimplements(vehicle, which)
	local implements = {};
	if which == nil or which == "" then
		if vehicle ~= nil and vehicle.attachedImplements ~= nil then
			for _, implement in pairs(vehicle.attachedImplements) do
				table.insert(implements, implement);
				local subImplements = InteractiveControl:getICimplements(implement.object, "");
				for _,v in pairs(subImplements) do
					table.insert(implements, v);
				end;
			end;
		end;
	elseif which == "front" and vehicle.LIC ~= nil then
		for _, index in pairs(vehicle.LIC.joints.front) do
			local implementIndex = vehicle:getImplementIndexByJointDescIndex(index);
			local implement = vehicle.attachedImplements[implementIndex];
			if implement ~= nil then
				table.insert(implements, implement);
				local subImplements = InteractiveControl:getICimplements(implement.object, "");
				for _,v in pairs(subImplements) do
					table.insert(implements, v);
				end;
			end;
		end;
	elseif which == "back" and vehicle.LIC ~= nil then
		for _, index in pairs(vehicle.LIC.joints.back) do
			local implementIndex = vehicle:getImplementIndexByJointDescIndex(index);
			local implement = vehicle.attachedImplements[implementIndex];
			if implement ~= nil then
				table.insert(implements, implement);
				local subImplements = InteractiveControl:getICimplements(implement.object, "");
				for _,v in pairs(subImplements) do
					table.insert(implements, v);
				end;
			end;
		end;
	end;
	return implements;
end;
