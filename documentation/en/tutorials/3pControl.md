# Using IC for 3 point hitches (& other stuff)

Interactive Control comes with various events for controling implements. Here is qick introduction of some of these events. Here is [full list of supported events](../components/supportedButtonEvents.md).

## Overview

IC controls actions by name - IC does not simulate key events etc... With IC you can control following events:

* Tipping
* Filling
* Turn state
* Folding
* Raising and lowering

Each of this action categories is divided into three basic subcategories: 

* Front implements
* Rear implements
* All inmplements together (you don't have to use [multiButtons](../components/components_multibuttons.md))

Please note, that all of this action categories is used for **implements** not for vehicle itself. For attacher vehicle there are special events - see them in [list of supported events](../components/supportedButtonEvents.md). For example: when you want to have `filling` event for self propeled sprayer, you can't use event `implements.filling.all`, but you will use `filling` instead

## MP synchronization

All events for implements is basically synchronized by game itself so there is no need for setting `synch` attribute of component to `true`. If anyone will have some troubles with synchronization in this events, send me an [mail](mailto:mar.fabik@gmail.com) or open new issue.

## How to determine `front` and `rear` implements

Front and rear implements are determined by `Z` axis of model - so it is mandatory to have proper model (all of models in base game is along `Z` axis). All attacher joints from model is saved into table and when calling an event this joints is searched for attached vehicles.

## Special subcategories

As I mention before, each action category is divided into three basic subcategories. But there is some exceptions:

### Tipping

is divided first into:

* Tipping into trigger
* Dumping to ground
* Mixed - that means if there is trigger, tip to trigger - otherwise dump to ground

### Folding 

is divided first into:

* Folding to middle
* Normal folding

For example: full event name of tipping to trigger for front implements will be `implements.tipping.trigger.front`

## Using with outside IC

Some tractors have control panel for 3p hitches outside. You can do it with IC too! Just look at this [tutorial for outside IC](./outsideIC.md) to see more.

Thats all for this tutorial. See [more tutorials here](../tutorials.md)
