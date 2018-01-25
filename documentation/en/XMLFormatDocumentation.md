# IC XML Scheme documentation

In this file I will describe XML schema for Interactive Control. In shema I'll be using this symbols with this meaning:

* `( x | y )` - this means, that script using x OR y - not both at same time
* `[xyz=""]` - means that attribute is not required and default value is no set
* `[xyz="abc"]` - optional attribute with default value
* `[xyz="" abc="xyz"]` - list of optional attributes - if you fill one you must fill other
* `xyz=""//type` - means that attribute has type `type`
* Also whole tag can be optional
* Everything outside of [] breackets is required and without propper filling script will not work!

If you have any question regards this XML scheme, send me mail at [mar.fabik@gmail.com](mailto:mar.fabik@gmail.com) with subject "IC - XML schema".

```xml
<!-- IC XML schema documentation -->
<interactiveComponents [outsideTriggerOn="false"//bool [minOutsideDistance="3"//float]]>
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
			[useStart="true"//bool]
			[playClickSound="false"//bool] >
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
					]
					[playClickSound="false"//bool] />]
				[<close 
					[mark=""//i3d_node
						[size="0.05"//float]
						[pulsingMark="false"//bool
							[pulseScale="0.01 0.01 0.01"//i3d_coords]
						]
					]
					[playClickSound="false"//bool] />]
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
			[playClickSound="false"//bool] >
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
	<!-- multi buttons needs revision -->
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
			[initAction="false"//bool]
			[playClickSound="false"//bool >
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
	[<buttonsListeners>
		[<listener>
			<element type="objectType"//string index=""//int />
			[<element type="objectType"//string index=""//int />]
			<!-- from element 0 to element n -->
		</listener>]
		<!-- from listener 0 to listener n -->
	</buttonsListeners>]
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
</interactiveComponents>
```
