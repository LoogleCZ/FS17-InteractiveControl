# Multi buttons

Multi buttons is useful when you need to trigger more than one IC component by one click. You can set unlimit components to trigger for only one clickable button.

## Multi buttons syntax

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<multiButtons>
	<mbutton
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
		[defaultStatus="false"//bool]
		[synch="true"//bool]
		[initAction="false"//bool] >
		[<control
			type=""//string
			index=""//int />]
		[<part
			type=""//string
			index=""//int
			[negStatus="false"//bool] />]
		<!--
			You can set only one < control > element per mbutton
			You can set n partial elements for one mbutton
		-->
	</mbutton>
	<!-- 
		from mbutton(0) to mbutton(n) 
		this first mbutton have index 0 for multi-buttons
	-->
</multiButtons>]
```

## Attributes and nodes

The following table will explain what certain attributes do:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| name                | l10n entry | modHub_error         | Name of IC component. Will be used in combination with onMessage and offMessage (this messages should be done with %s placeholder inside). Instead of placeholder in this messages, name will be used |
| mark                | i3d node   |                      | Mark of IC component used for user interaction. IF user click on this node, actions will be triggered. |
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

__(*)__: If you use component in multi buttons or buttons listeners, this attribute will be ignored and action will be triggered anyway. For example: multibutton from inside will be triggered and contain animation from outside. Animation will be played anyway.

__(**)__: You have to set i3d node properly first. See how in [this tutorial](../tutorials/settingUpI3D.md).

### Setting up comntrol element

If you want, you can set up control element for multi button. If control element is set all parts of multibutton will be synchronized by this control IC element.

Attributes of control element:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| type                | string     |                      | IC component type. List of available types can be found below |
| index               | int        |                      | Index of IC element that will be used as control. Don't forget that indexation starts from 0 |

### Partial components

In multibutton you can set unlimited ammount of parts. Each part will be triggered after clicking `mark` object. Available part attributes is:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| type                | string     |                      | IC component type. List of available types can be found below |
| index               | int        |                      | Index of IC element that will be used as control. Don't forget that indexation starts from 0 |
| negStatus           | bool       | false                | Define if action under this part will be triggered with opposite status. |

### Type attributes

Type attributes can be filled with one of these:

* OBJECT_TYPE_ANIMATION
* OBJECT_TYPE_EVENT_BUTTON
* OBJECT_TYPE_MONITOR
* OBJECT_TYPE_VISIBILITY
* OBJECT_TYPE_MULTI_BUTTONS

## Minimal multiButtons setup

Minimal setup can be like this. Since multibuttons makes sense only with combination of more components, this example includes also animations and event buttons.

```xml
<interactiveComponents>
	<animations>
		<animation animName="DisplayLowerChange"/> <!-- OBJECT_TYPE_ANIMATION index 0 -->
	</animations>
	<buttons>
		<button event="implements.raiseLower.all" /> <!-- OBJECT_TYPE_EVENT_BUTTON index 0 -->
	</buttons>
	<multiButtons>
		<mbutton name="LowerAll" mark="0>1|2|3">
			<control type="OBJECT_TYPE_EVENT_BUTTON" index="0" />
			<part type="OBJECT_TYPE_EVENT_BUTTON" index="0" />
			<part type="OBJECT_TYPE_ANIMATION" index="0" negStatus="false" />
		</mbutton>
	</multiButtons>
<interactiveComponents>
```

As you can see, if you want to use some component in multibutton no mark is set. Sure you can set mark also for event button and animation but then it will be complicated to synchronize it.
