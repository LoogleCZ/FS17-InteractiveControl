# Monitors components

Monitors is used for manage tabs on display in game. It works by hiding/showing i3d nodes and disabling i3d components in that node. All following code examples is done inside `<interactiveComponents>` xml node.

## Monitos component syntax

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<monitors>
	<monitor 
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
		[initAction="false"//bool]
		[defaultLayer=""//int
			[moveDefaultLayer="false"//bool]
		]
		layerVisPos=""//i3d_coords
		layerClosePos=""//i3d_coords
		[animName=""//string]
		[useStart="true"//bool] >
		<layer
			index=""//i3d_node
			[name="ERROR"//l10n_entry]
			[onMessage="ic_button_on"//l10n_entry] 
			[offMessage="ic_button_off"//l10n_entry]
			[renderStatusText="true"//bool]>
			[<open
				[mark=""//i3d_node
					[size="0.05"//float]
					[pulsingMark="false"//bool
						[pulseScale="0.01 0.01 0.01"//i3d_coords]
					]
				]/>]
			[<close 
				[mark=""//i3d_node
					[size="0.05"//float]
					[pulsingMark="false"//bool
						[pulseScale="0.01 0.01 0.01"//i3d_coords]
					]
				]/>]
		</layer>
		<!--
			Note - open and close tag should be omitted only in case of default layer!
			From layer(0) to layer(n)
		-->
	</monitor>
	<!--
		From monitor(0) to monitor(n)
		this first monitor have index 0 for multi-buttons
	-->
</monitors>]
```

Creating monitor make sense only if you have at least two layers. 

## Monitors attributes and nodes attributtes

The following table will explain what certain attributes of this component do:

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
| defaultLayer        | int        |                      | Index of defautl layer used by monitor. If not set, no layer is defaut thus all layers is tabs on fixed background. |
| layerVisPos         | i3d coords |                      | Required attribute. Define position of layer when visible (for example 0 0 0). |
| layerClosePos       | i3d coords |                      | Required attribute. Monitor component will use this position to hide layer. This is used when layer contain some other clickable component and because you can click on hide component, translating whole layer to something like "10 10 10" will cause that all buttons will be out of clickable radius so no misclick can occur |
| moveDefaultLayer    | bool       | false                | Determine if default layer will be moved when toggling to other tab. If set to false, default layer stay on background all the time. |
| animName            | string     |                      | Name of animation that will be used at monitor start. When no animations is set nothing happens. |
| useStart            | bool       | true                 | Define if monitor will use motor start (when motor is on monitor automatically turns on if sets to `true`) or not |

__(*)__: If you use component in multi buttons or buttons listeners, this attribute will be ignored and action will be triggered anyway. For example: multibutton from inside will be triggered and contain animation from outside. Animation will be played anyway.

__(**)__: You have to set i3d node properly first. See how in [this tutorial](../tutorials/settingUpI3D.md).

### Layer node

Layer node contains information about single layer of monitor. Layer contains information about it's open and close button.

Here is list of attributes for one layer:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| index               | i3d node   |                      | 3D index of layer in model. Component will work with this index and will be showing and tranlating this index |
| name                | l10n entry | modHub_error         | Name of layer. This name will be used in combination with onMessage and offMessage for displaing information about turn on/off the layer |
| onMessage           | l10n entry | action_turnOnOBJECT  | Message used when displaing information about showing layer (layer is turned off and we want to open it - open button) |
| offMessage          | l10n entry | action_turnOffOBJECT | Message used when displaing information about showing layrt (layer is turned on and we want to close it - close button) |
| renderStatusText    | bool       | true                 | Define if we want to render text when hovering over close or open button |

### Open and close layer node

For opening and closing layers there is two nodes with separate mark options - because close button is usually in layer itself, but we don't want to have open button inside something that is not visible. So open button can have different mark.

Here is attributes that is common for open and close node:

| Attribute           | Data type  | Default value        | Exmplanation |
|:------------------- |:----------:|:-------------------- | ------------ |
| mark                | i3d node   |                      | Mark of IC component used for user interaction. IF user click on this node, layer will be opened/closed depending of node type. |
| size                | float      | 0.05                 | Size of clickable area for `mark` |
| pulsingMark         | bool       | false                | If set to true, mark will be pulsing when hovering on it. |
| pulseScale          | i3d coords | 0.01 0.01 0.01       | Tell the script how much will mark pulse. |

## Minimal monitor setting

All you have to do when creating monitor with one function layer and one default layer is this:

```xml
<interactiveComponents>
	<monitors>
		<monitor defaultLayer="0" layerVisPos="0 0 0" layerClosePos="10 10 10">
			<layer index="0>1|2|2" /> <!-- default layer -->
			<layer index="0>1|2|3"> <!-- normal layer that can be opened and closed -->
				<open mark="0>1|4" />
				<close mark="0>1|2|3|0" />
			</layer>
		</monitor>
	</monitors>
</interactiveComponents>
```

## Note when using multibuttons

If you're using multibuttons for monitors, there is different index counting for monitors' indexes. Each monitor have it's own index plus each open and close layer have their own index. This indexes are same type as monitor.

Demonstrative example on basic setup:

```xml
<interactiveComponents>
	<monitors>
		<monitor defaultLayer="0" layerVisPos="0 0 0" layerClosePos="10 10 10"> <!-- type monitor, index 0 -->
			<layer index="0>1|2|2" />
			<layer index="0>1|2|3">
				<open mark="0>1|4" /> <!-- type monitor, index 1 -->
				<close mark="0>1|2|3|0" /> <!-- index 2 -->
			</layer>
		</monitor>
		<monitor defaultLayer="0" layerVisPos="0 0 0" layerClosePos="10 10 10"> <!-- index 3 -->
			<layer index="0>1|5|2">
				<open mark="0>1|7" /> <!-- index 4 -->
				<close mark="0>1|5|2|0" /> <!-- index 5 -->
			</layer>
			<layer index="0>1|5|3">
				<open mark="0>1|6" /> <!-- index 6 -->
				<close mark="0>1|5|3|0" /> <!-- index index 7 -->
			</layer>
		</monitor>
	</monitors>
</interactiveComponents>
```
