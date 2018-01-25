# Animations component

Animation control in IC is done very simply and it is easy to understand. First of all we need to have some animations created for our mod. All following code examples is done inside `<interactiveComponents>` xml node. Animations component was before called `windows`, so if you're upgrating your mod to new version, you must rename it and check the correctness of work of IC in your mod.

## Animations component syntax 

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<animations>
	[<animation 
		[name="modHub_error"//l10n_entry] 
		[mark=""//i3d_node
			[size="0.05"//float]
			[renderStatusText="true"//bool]
			[onMessage="action_turnOnOBJECT"//l10n_entry]
			[offMessage="action_turnOffOBJECT"//l10n_entry]
			[isOutside="false"//bool]
			[pulsingMark="false"//bool
				[pulseScale="0.01 0.01 0.01"//i3d_coords]
			]
		]
		(animName=""//string | clipRoot=""//i3d_node clip=""//string)
		[defaultStatus="false"//bool]
		[synch="true"//bool]
		[initAction="false"//bool]
		[looping="false"//bool]
		[animSpeedScale="1"//float]
		[saveAnimationStatus="false"//bool]
		[playClickSound="false"//bool] />]
	<!-- 
		from animation(0) to animation(n)
		thus first animation have index 0. This is useful for multi-buttons and debugging
	-->
</animations>]
```

From syntax above you can see that minimal setup is something like this:

```xml
<animations>
	<animation animName="nameOfYourAnimation"/>
</animations>
```

This will create interactive component that can be used in multiButtons, etc...

## Animations attributtes

The following table will explain what certain attributes do:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| name                | l10n entry | modHub_error         | Name of IC component. Will be used in combination with onMessage and offMessage (this messages should be done with %s placeholder inside). Instead of placeholder in this messages, name will be used |
| mark                | i3d node   |                      | Mark of IC component used for user interaction. IF user click on this node, action will be triggered (in this case animation will be played/stopped when looping) |
| size                | float      | 0.05                 | Size of clickable area for `mark` |
| renderStatusText    | bool       | true                 | Whether render onMessage and offMessage at the bottom of screen in addition to default help entry (useful for players with disabled help window) |
| onMessage           | l10n entry | action_turnOnOBJECT  | Message used to display information that current mark will activate component. Should be with %s placeholder for component `name` |
| offMessage          | l10n entry | action_turnOffOBJECT | Message used to display information that current mark will deactivate component. Should be with %s placeholder for component `name` |
| *isOutside          | bool       | false                | Determine if component can be used from outside of vehicle. |
| **pulsingMark       | bool       | false                | If set to true, mark will be pulsing when hovering on it. |
| pulseScale          | i3d coords | 0.01 0.01 0.01       | Tell the script how much will mark pulse. |
| animName            | string     | NONE - must be set   | Name of an xml animation used by IC. |
| clipRoot            | i3d node   | NONE - must be set   | Animation root in i3d scene. |
| clip                | string     | NONE - must be set   | Clip name under `clipRoot` in I3D scheme |
| defaultStatus       | bool       | false                | Default status of component. Component's status will be set to this value when loading |
| synch               | bool       | true                 | Tell the script if component will be synchronized via IC or not. In animations is recomended to set synch to `true` (or do not state synch attribute) |
| initAction          | bool       | false                | If set to `true`, component will be triggered at loading to synchronize state and actual status. In animations is recomended to set `initAction` to `true` |
| looping             | bool       | false                | Used for looping animations like wiper. Tell IC that this animation is looping so IC can interact properly. |
| animSpeedScale      | float      | 1                    | Spped of played animation in range with bounds 1 and -1. If set to -1, animation will be played in reverse. |
| saveAnimationStatus | bool       | false                | You can tell if you want to save your animation status or not. If set to `true` commponent's status will be saved when exit and after reloading game animation remains open/close |
| playClickSound      | bool       | false                | If click sound will be played when clicking the mark. |

__(*)__: If you use component in multi buttons or buttons listeners, this attribute will be ignored and action will be triggered anyway. For example: multibutton from inside will be triggered and contain animation from outside. Animation will be played anyway.

__(**)__: You have to set i3d node properly first. See how in [this tutorial](../tutorials/settingUpI3D.md).

## Setting up animation properly 

You can use two types of animations: 

1) XML animations in vehicle.xml
2) I3D animations in vehicle's I3D file

if you state both types in one animation, I3D animations have higher priority. Only limitation of I3D animations is, that script cannot recognize status of anim track when animation is not looping directly. Then status is calculated by user's interaction.

## Saving animation status

You can save animation status in IC. But note, that you can save only one animation if you don't want glitched behavior. Examine following example:

```xml
<interactiveComponents outsideTriggerOn="true" minOutsideDistance="5">
	<animations>
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|4" size="0.1" animName="Left_Door" initAction="true" saveAnimationStatus="true" /> 
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|0" size="0.1" animName="Left_Door" initAction="true" saveAnimationStatus="true" isOutside="true"/>
	</animations>
</interactiveComponents>
```

We have two animations components with `saveAnimationStatus="true"`. When you save game with this, IC will open left door after startup for first component, but second component will set status back to `close` because for now, it is `open`. To fix this, you need to set `saveAnimationStatus` only once per animation like this:

```xml
<interactiveComponents outsideTriggerOn="true" minOutsideDistance="5">
	<animations>
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|4" size="0.1" animName="Left_Door" initAction="true" saveAnimationStatus="true" /> 
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|0" size="0.1" animName="Left_Door" initAction="true" isOutside="true"/>
	</animations>
</interactiveComponents>
```

It is almost done for now, but not complete yet. This example still can have some glitches. To remove them, please link animations with [buttons listener component](./component_buttonListeners.md)
