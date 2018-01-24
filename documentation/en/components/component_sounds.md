# Sounds components

Sounds component is used for assign sound for some other component. You can define sounds for some state or for state change. Please note that some events/components cannot have continuous sound (like events that cannot be assumed as open or close).

## Sounds components syntax

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<sounds>
	[<sound
		index=""
		type=""
		>
		[<opening //SoundUtil sample attributes>]
		[<closing //SoundUtil sample attributes>]
		[<open  //SoundUtil sample attributes>]
		[<close  //SoundUtil sample attributes>]
	</sound>]
</sounds>]
```

## Attributes and nodes

The following table will explain what certain attributes do:

| Attribute | Data type  | Default value        | Exmplanation |
|:--------- |:----------:|:-------------------- | ------------ |
| index     | int        |                      | Index of IC element for sound assigment. Don't forget that indexation starts from 0 |
| type      | string     |                      | IC component type. List of available types can be found below |

Type attribute can be filled with one of these:

* OBJECT_TYPE_ANIMATION
* OBJECT_TYPE_EVENT_BUTTON
* OBJECT_TYPE_MONITOR
* OBJECT_TYPE_VISIBILITY
* OBJECT_TYPE_MULTI_BUTTONS

## Minimal sound settings

Minimal sound settings can look like this:

```xml
<interactiveComponents>
	<animations>
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|4" size="0.1" animName="Left_Door" initAction="true" saveAnimationStatus="true" />
	</animations>
	<sounds>
		<sound index="0" type="OBJECT_TYPE_ANIMATION">
			<opening file="sounds/doorOpen.wav"  pitchOffset="1" indoorVolumeFactor="0.5" indoorLowpassGain="1.0" outdoorVolumeFactor="0.5" outdoorLowpassGain="0.3"/>
			<closing file="sounds/doorClose.wav" pitchOffset="1" indoorVolumeFactor="0.7" indoorLowpassGain="1.0" outdoorVolumeFactor="0.5" outdoorLowpassGain="0.3"/>
		</sound>
	</sounds>
</interactiveComponents>
```
