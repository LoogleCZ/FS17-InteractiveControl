# Supperted events for buttons

in Interactive Control version 4.0.0. from XX.XX.2017. If you have any question or idea for new event, let me know at [mar.fabik@gmail.com](mailto:mar.fabik@gmail.com).

Please note, that some events are not tested in multiplayer yet, or I'm not sure which state use. This events have aetrisk(*) in synch attribute. If event doesn't work in MP, you could try to switch synch attribute. If event doesn't work either with synch true and false, please let me know at [mar.fabik@gmail.com](mailto:mar.fabik@gmail.com).

If you're using scripts events (GearboxAddon, Cablight, etc...) buttons will be shown only if requested script is available. If script is not presented, notice is produced (in log).

## Events for steerable vehicles

### Driving

| Event name                       | Synch attribute | Affected script     | Description                                    | Usage notes and limitations                                                                                                                           | 
| -------------------------------- |:---------------:|:-------------------:| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| steering.motorIgnition           | `false`         | Base game           | Start or Stop Vehicle engine                   |                                                                                                                                                       |
| steering.reverseDriving          | `false`         | Base game           | Change driving direction of supported vehicles | This event is designed for use on vehicles that have a reverse driving feature like the Valtra's; needs specialization ReverseDriving for proper work |
| steering.crabSteering.1          | `false`         | Base game           | Set crab steering type 1                       | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.crabSteering.2          | `false`         | Base game           | Set crab steering type 2                       | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.crabSteering.3          | `false`         | Base game           | Set crab steering type 3                       | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.crabSteering.4          | `false`         | Base game           | Set crab steering type 4                       | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.crabSteering.cycle      | `false`         | Base game           | Cyclically rotate between crab steer states    | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.crabSteering.12         | `false`         | Base game           | Toggle betweeb crab steer state 1 and 2        | This event is designed for use on vehicles that have crab steering feature; needs specialization CrabSteering for proper work                         |
| steering.cruiseControl.toggle    | `false`         | Base game           | Turn on/off cruise controll                    |                                                                                                                                                       |
| steering.cruiseControl.speedUp   | `false`         | Base game           | Set speed up on cruise controll                |                                                                                                                                                       |
| steering.cruiseControl.speedDown | `false`         | Base game           | Set speed down on cruise controll              |                                                                                                                                                       |
| steering.lockMovingTools         | `false`         | lockMovingTools.lua | Lock Mouse control tools on vehicle            | This event is designed for use lockMovingTools.lua version 1.0 or greater                                                                             |

### Turnsignals

| Event name        | Synch attribute | Affected script | Description                  |
| ----------------- |:---------------:|:---------------:| ---------------------------- |
| turnsignal.hazard | `false`         | Base game       | Turn on/off hazard lights    |
| turnsignal.right  | `false`         | Base game       | Turn on/off right turnsignal |
| turnsignal.left   | `false`         | Base game       | Turn on/off right turnsignal |

### Lights

| Event name          | Synch attribute | Affected script | Description                                    | Usage notes and limitations                                             | 
| ------------------- |:---------------:|:---------------:| ---------------------------------------------- | ----------------------------------------------------------------------- |
| lights.front        | `false`         | Base game       | Turn on/off front lights                       |                                                                         |
| lights.highBeam     | `false`         | Base game       | Turn on/off high beam lights                   |                                                                         |
| lights.frontWork    | `false`         | Base game       | Turn on/off front work lights                  |                                                                         |
| lights.rearWork     | `false`         | Base game       | Turn on/off rear work lights                   |                                                                         |
| lights.beaconLights | `true`          | Base game       | Turn on/off beacon lights                      |                                                                         |
| lights.cablight     | `false`         | Cablight.lua    | Turn on/off cablight                           | This event needs Cablight.lua version 1.2 and higher for proper working |

### Link to global scripts events

Link to global scripts is script provided by Mogli (biedens) for better integration with GearboxAddon. This script is currently with no development support so it may not work in some circumstances.

You can use `LinkToGlobalScripts` (l2gs) script with IC. All zou have to do is name zour event like `l2gs.l2gsFunction`. Down below you can find some useful functions that is provided in version `2017/10/25 - version 2.0 (FS17)` also with proper IC name.

Example of usage: you want to call function `l2gsToggleDC4WD` from l2gs script. Proper name in this case will be `l2gs.ToggleDC4WD`


## Events for controling attached inplements

Please note, that front/rear attacher joint is determined by position against `Z` axis. If you will (for some reason) use different mod orientation, side recognition will not for for your mod, so you **cannot use front/rear events in your mod**

All events in following tables are for **attached implements**. If you want to use IC in trailer (as outside IC) or in self-propelled vehicles (for example sprayer), please see [events for all vehicles](#events-for-all-vehicles)
   
State for this events is calculated first and then all implements is synchronized in current action. So for example if you will use IC for turning on implements, at one time will be all implements active or all implements off.

### Tipping

| Event name                       | Synch attribute | Affected script | Description                                                                              |
| -------------------------------- |:---------------:|:---------------:| ---------------------------------------------------------------------------------------- |
| implements.tipping.trigger.all   | `false`         | Base game       | Tip all implements (if trigger found and it's possible) into trigger                     |
| implements.tipping.trigger.front | `false`         | Base game       | Tip only front implements (if trigger found and it's possible) into trigger              |
| implements.tipping.trigger.rear  | `false`         | Base game       | Tip only rear implements (if trigger found and it's possible) into trigger               |
| implements.tipping.ground.all    | `false`         | Base game       | Tip all implements on ground (if implement(s) **isn't** on trigger)                      |
| implements.tipping.ground.front  | `false`         | Base game       | Tip only front implements on ground (if implement(s) **isn't** on trigger)               |
| implements.tipping.ground.rear   | `false`         | Base game       | Tip only rear implements on ground (if implement(s) **isn't** on trigger)                |
| implements.tipping.mixed.all     | `false`         | Base game       | Determine if implements will be tipped on ground or into trigger (for all implements)    |
| implements.tipping.mixed.front   | `false`         | Base game       | Determine if implements will be tipped on ground or into trigger (only front implements) |
| implements.tipping.mixed.rear    | `false`         | Base game       | Determine if implements will be tipped on ground or into trigger (only rear implements)  |

### Filling

| Event name               | Synch attribute | Affected script | Description                                                      |
| ------------------------ |:---------------:|:---------------:| ---------------------------------------------------------------- |
| implements.filling.all   | `false`         | Base game       | Start/stop filling all implements, if they are in trigger area   |
| implements.filling.front | `false`         | Base game       | Start/stop filling front implements, if they are in trigger area |
| implements.filling.rear  | `false`         | Base game       | Start/stop filling rear implements, if they are in trigger area  |

### Turn state

| Event name                 | Synch attribute | Affected script | Description                                    |
| -------------------------- |:---------------:|:---------------:| ---------------------------------------------- |
| implements.turnState.all   | `false`         | Base game       | Change turn state of all attached implements   |
| implements.turnState.front | `false`         | Base game       | Change turn state of front attached implements |
| implements.turnState.rear  | `false`         | Base game       | Change turn state of rear attached implements  |

### Folding implements

| Event name                   | Synch attribute | Affected script | Description                                      |
| ---------------------------- |:---------------:|:---------------:| ------------------------------------------------ |
| implements.fold.all          | `false`         | Base game       | Fold/unfold completely all attached implements   |
| implements.fold.front        | `false`         | Base game       | Fold/unfold completely front attached implements |
| implements.fold.rear         | `false`         | Base game       | Fold/unfold completely rear attached implements  |
| implements.fold.middle.all   | `false`         | Base game       | Fold/unfold partially all attached implements    |
| implements.fold.middle.front | `false`         | Base game       | Fold/unfold partially front attached implements  |
| implements.fold.middle.rear  | `false`         | Base game       | Fold/unfold partially rear attached implements   |

### Raising and lowering

| Event name                  | Synch attribute | Affected script | Description                                                          |
| --------------------------- |:---------------:|:---------------:| -------------------------------------------------------------------- |
| implements.raiseLower.all   | `false`         | Base game       | Raise or lower (depending on actual state) all attached implements.  |
| implements.raiseLower.front | `false`         | Base game       | Raise or lower (depending on actual state) front attached implements |
| implements.raiseLower.rear  | `false`         | Base game       | Raise or lower (depending on actual state) rear attached implements  |

## <a name="events-for-all-vehicles"></a>Events for all vehicles

This events controls current vehicle (i.e. vehicle that contains this script) or global game

### Radio

Events for controlling radio if supported

| Event name        | Synch attribute | Affected script | Description               |
| ----------------- |:---------------:|:---------------:| ------------------------- |
| radio.state       | `false`         | Base game       | Turn radion on/off        |
| radio.channelUp   | `false`         | Base game       | Browse radio channel up   |
| radio.channelDown | `false`         | Base game       | Browse radio channel down |

### Tipping

| Event name      | Synch attribute | Affected script | Description                                                                        |
| --------------- |:---------------:|:---------------:| ---------------------------------------------------------------------------------- |
| tipping.trigger | `false`         | Base game       | Tip vehicle in trigger if possible                                                 |
| tipping.ground  | `false`         | Base game       | Tip vehicle on ground if possible                                                  |
| tipping.mixed   | `false`         | Base game       | Determine where tip (on ground or in trigger) and start/stop tipping (if possible) |

### Filling

| Event name | Synch attribute | Affected script | Description                                       |
| ---------- |:---------------:|:---------------:| ------------------------------------------------- |
| filling    | `false`         | Base game       | Start/stop filling vehicle if its in fill trigger |

### Turning on/off

| Event name | Synch attribute | Affected script | Description         |
| ---------- |:---------------:|:---------------:| ------------------- |
| turnState  | `false`         | Base game       | Turn on/off vehicle |

### Folding

| Event name  | Synch attribute | Affected script | Description                   |
| ----------- |:---------------:|:---------------:| ----------------------------- |
| fold        | `false`         | Base game       | Fold/unfold vehicle           |
| fold.middle | `false`         | Base game       | Partially fold/unfold vehicle |

### Raising and lowering

| Event name | Synch attribute | Affected script | Description                                                    |
| ---------- |:---------------:|:---------------:| -------------------------------------------------------------- |
| raiseLower | `false`         | Base game       | raise/lower vehicle part (for example potato harvester header) |

### Mix

| Event name | Synch attribute | Affected script | Description                                               |
| ---------- |:---------------:|:---------------:| --------------------------------------------------------- |
| mix.cover  | `false`         | Base game       | change cover state of vehicle. Needs Cover specialization |

## Events for harvesters

Most harvester functions can be done with [events for all vehicles](#events-for-all-vehicles). But there is some events that cannot be done this way.

| Event name | Synch attribute | Affected script | Description               |
| ---------- |:---------------:|:---------------:| ------------------------- |
| chopper    | `false`         | Base game       | Turn on/off straw chopper |
| pipe       | `false`         | Base game       | Change pipe state         |
