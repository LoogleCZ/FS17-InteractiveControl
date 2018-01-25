# Visibility control component

Visibility control component can be used for small decoratiove changes made by user, such as indoor fan, etc... For complex solution, for example with fold/unfold animation you can use [animation component](./commponent_animations.md)

## Visibility control component syntax

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<visControls>
	[<button 
		[name="modHub_error"]
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
		[initAction="false"//bool]
		[typeChange="set"//string ('set' or 'toggle')]
		[controlElem=""//i3d_node]
		[defaultVis=""//bool]
		[saveAnimationStatus="false"//bool]
		[playClickSound="false"//bool] >]
			[<object
				index=""//i3d_node
				[neg="false"//bool] />]
		<!--
			you must state at least one object
			upper limit for objects is not set
		-->
	</button>]
	<!-- 
		from button(0) to button(n) 
		this first button have index 0 for multi-buttons
	-->
</visControls>]
```

## Visibility control attributes and nodes

The following table will explain what certain attributes do:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| name                | l10n entry | modHub_error         | Name of IC component. Will be used in combination with onMessage and offMessage (this messages should be done with %s placeholder inside). Instead of placeholder in this messages, name will be used |
| mark                | i3d node   |                      | Mark of IC component used for user interaction. If user click on this node, action will be triggered. |
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
| typeChange          | string     | set                  | Determine changing visibility style. Can be set to `set` or `toggle`. If you'll use `set` option you must also add `controlElem` attribute with valid object by which will be other objects synchronized. |
| controlElem         | i3d node   |                      | Control element for `set` change type. By this element will be synchronized other objects. Dous not make sense with `toggle` change style |
| defaultVis          | bool       |                      | determine default visibility status after game load. This option will not be used in next loading when `saveAnimationStatus` is set to `true` |
| saveAnimationStatus | bool       | false                | You can tell if you want to save your animation status or not. If set to `true` commponent's status will be saved when exit and after reloading game animation remains open/close. Does not make sense if using `typeChange` set to `toggle` |
| playClickSound      | bool       | false                | If click sound will be played when clicking the mark. |

__(*)__: If you use component in multi buttons or buttons listeners, this attribute will be ignored and action will be triggered anyway. For example: multibutton from inside will be triggered and contain animation from outside. Animation will be played anyway.

__(**)__: You have to set i3d node properly first. See how in [this tutorial](../tutorials/settingUpI3D.md).

When `typeChange` is set to `toggle`, button cannot be assumed as open or close.

There is also at least one mandatory `object` node. These objects will be affected by component. Attributes of each `object` is following:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| index               | i3d node   |                      | Index of object in i3d that will be affected by component. |
| neg                 | bool       | false                | If component will be toggled in opposite to normal status |

## Minimal visibility button settings

All you have to do when creating visibility button element is this:

```xml
<interactiveComponents>
	<visControls>
		<button typeChange="toggle">
			<object index="0>1|2|3" />
		</button>
	</visControls>
</interactiveComponents>
```
