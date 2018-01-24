# Button listeners components

Button listeners are used for synchronize component status with other component. First of all you need some other components set. All following code examples is done inside `<interactiveComponents>` xml node.

## Button listeners syntax 

Or you can visit [whole XML schema documentation](../XMLFormatDocumentation.md):

```xml
[<buttonsListeners>
	[<listener>
		<element type="objectType"//string index=""//int />
		[<element type="objectType"//string index=""//int />]
		<!-- from element 0 to element n -->
	</listener>]
	<!-- from listener 0 to listener n -->
</buttonsListeners>]
```

Where `objectType` is one of the following types:

* OBJECT_TYPE_ANIMATION
* OBJECT_TYPE_EVENT_BUTTON
* OBJECT_TYPE_MONITOR
* OBJECT_TYPE_VISIBILITY
* OBJECT_TYPE_MULTI_BUTTONS

and index is number between 0 and n. N is count of components of cetrain types minus one. Indexing starts from 0.

## Example of usage

You can use button listener to synchronize animation status. This is useful when using inside and outside components that cannot be synchronized by computing. Example of this synchronization:

```xml
<interactiveComponents outsideTriggerOn="true" minOutsideDistance="5">
	<animations>
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|4" size="0.1" animName="Left_Door" initAction="true" saveAnimationStatus="true" /> 
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|0" size="0.1" animName="Left_Door" initAction="true" isOutside="true"/>
	</animations>
	<buttonsListeners>
		<listener>
			<element type="OBJECT_TYPE_ANIMATION" index="0" />
			<element type="OBJECT_TYPE_ANIMATION" index="1" />
		</listener>
	</buttonsListeners>
</interactiveComponents>
```
