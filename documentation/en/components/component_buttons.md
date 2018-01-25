# Buttons components

Buttons are used to trigger some ingame functions. Also can be used for trigger user functions from other scripts, but this require editation of `actionFunction.lua`. All following code examples is done inside `<interactiveComponents>` xml node.

## Buttons components syntax

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<buttons>
	[<button 
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
		event=""//string
		[defaultStatus="false"//bool]
		[synch="true"//bool]
		[initAction="false"//bool]
		[playClickSound="false"//bool] />]
	<!-- 
		from button(0) to button(n)
		thus first button have index 0. This is useful for multi-buttons and debugging
	-->
</buttons>]
```

## Buttons attributtes

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
| defaultStatus       | bool       | false                | Default status of component. Component's status will be set to this value when loading |
| synch               | bool       | true                 | Tell the script if component will be synchronized via IC or not. In animations is recomended to set synch to `true` (or do not state synch attribute) |
| initAction          | bool       | false                | If set to `true`, component will be triggered at loading to synchronize state and actual status. In animations is recomended to set `initAction` to `true` |
| event               | string     | NONE - must fill     | Event name that will be triggered when clicked. You can see all available events in [this list](./supportedButtonEvents.md) |
| playClickSound      | bool       | false                | If click sound will be played when clicking the mark. |

__(*)__: If you use component in multi buttons or buttons listeners, this attribute will be ignored and action will be triggered anyway. For example: multibutton from inside will be triggered and contain animation from outside. Animation will be played anyway.

__(**)__: You have to set i3d node properly first. See how in [this tutorial](../tutorials/settingUpI3D.md).

## Minimal event button setting

All you have to do when creating event button is this:

```xml
<interactiveComponents>
	<buttons>
		<button event="eventName" /> 
	</buttons>
</interactiveComponents>
```
