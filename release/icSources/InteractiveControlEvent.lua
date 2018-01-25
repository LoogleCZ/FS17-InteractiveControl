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
	self.interactiveControlID = streamReadInt8(streamId);
	self.ICIsOpen = streamReadBool(streamId);
    self:run(connection);
end;

function InteractiveControlEvent:writeStream(streamId, connection)
	writeNetworkNodeObject(streamId, self.object);
	streamWriteInt8(streamId, self.interactiveControlID);
	streamWriteBool(streamId, self.ICIsOpen);
end;

function InteractiveControlEvent:run(connection)
	if self.object ~= nil then
		self.object:actionOnObject(self.interactiveControlID, self.ICIsOpen, true);
		if not connection:getIsServer() then
			g_server:broadcastEvent(InteractiveControlEvent:new(self.object, self.interactiveControlID, self.ICIsOpen), nil, connection, self.object);
		end;
	end;
end;