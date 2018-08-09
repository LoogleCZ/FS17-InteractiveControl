--[[
I made some quick changes here to eliminate a MP error when I did a quick check.
I have not done a check in MP with more than one player yet. I will do this tomorrow but I wanted to make sure you were happy with the dirrection of the script :-)

-- OK thats OK
]]--

InteractiveControlEvent = {};
InteractiveControlEvent_mt = Class(InteractiveControlEvent, Event);

InitEventClass(InteractiveControlEvent, "InteractiveControlEvent");

function InteractiveControlEvent:emptyNew()
    local self = Event:new(InteractiveControlEvent_mt);
    return self;
end;

function InteractiveControlEvent:new(object, interactiveControlID, ICIsOpen)
    local self = InteractiveControlEvent:emptyNew()
    self.object = object;
	self.interactiveControlID = interactiveControlID;
	self.ICIsOpen = ICIsOpen;
    return self;
end;

function InteractiveControlEvent:readStream(streamId, connection)
	self.object = readNetworkNodeObject(streamId);
	print("IC Debug: Calling readNetworkNodeObject on " .. tostring(streamId) .. ". Readed: " .. tostring(self.object));
	self.interactiveControlID = streamReadInt8(streamId);
	print("IC Debug: Calling streamReadInt8 on " .. tostring(streamId) .. ". Readed: " .. tostring(self.interactiveControlID));
	self.ICIsOpen = streamReadBool(streamId);
	print("IC Debug: Calling streamReadBool on " .. tostring(streamId) .. ". Readed: " .. tostring(self.ICIsOpen));
    self:run(connection);
end;

function InteractiveControlEvent:writeStream(streamId, connection)
	writeNetworkNodeObject(streamId, self.object);
	print("IC Debug: Calling writeNetworkNodeObject on " .. tostring(streamId) .. ". Written: " .. tostring(self.object));
	streamWriteInt8(streamId, self.interactiveControlID);
	print("IC Debug: Calling streamWriteInt8 on " .. tostring(streamId) .. ". Written: " .. tostring(self.interactiveControlID));
	streamWriteBool(streamId, self.ICIsOpen);
	print("IC Debug: Calling streamWriteBool on " .. tostring(streamId) .. ". Written: " .. tostring(self.ICIsOpen));
end;

function InteractiveControlEvent:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, self.object);
		print("IC Debug: Decided to broadcast over " .. tostring(connection));
	end;
	
	self.object:actionOnObject(self.interactiveControlID, self.ICIsOpen, true);
end;
