--
-- Part of InteractiveControl script.
-- This file contains InteractiveControlEvent class for emitting network events
-- for IC
--
-- Author: Martin Fabík (LoogleCZ)
-- Thanks Adam Maršík for network debugging
-- For IC version: 4.1.0
--
-- Last edit: 2018-08-11 16:30:00
-- Free for non-comerecial usage
--

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
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, self.object);
	end;
	
	self.object:actionOnObject(self.interactiveControlID, self.ICIsOpen, true);
end;
