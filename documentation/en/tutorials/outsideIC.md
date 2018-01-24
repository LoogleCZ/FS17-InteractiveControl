# Using outside IC

In Interactive Control you can easily use outside control. This useful feature is used for basik things like opening doors from outside or for complex solutions like control of [3 point hitches](./3pControl.md). In this tutorial I'll show you, how to setup outside IC component, where you should be on the alert when using outside components, etc...

## Preparing 3D model.

First of all, you need to prepare 3D model. Some (probably most of) IC buttons will need to be duplicated for using IC from outside and inside at once. You'll need to set up these buttons just same as inside buttons (you can use [this tutorial](./settingUpI3D.md))

## Using outside IC - general

All you need to do for enabling outside IC is to set component's `isOutside` attribute to `true`. Like here:

```xml
<interactiveComponents outsideTriggerOn="true" minOutsideDistance="5">
	<animations>
		<animation name="ic_Door" mark="0>0|10|0|3|1|0|0" size="0.1" animName="Left_Door" initAction="true" isOutside="true"/>
	</animations>
</interactiveComponents>
```

After that, button will be activated from outside, but cannot be triggered from inside. For simple animations you can use same mark for outside and inside variant of component. Thats OK but you might have some issues with visibility.

## Using outside IC - animations and vis control

When you using outside IC for animations (or for visibility control), you should be awared of this things:

1) When you want to save animation's status, you need to save it only once. To do this, just simply set `saveAnimationStatus` in one of animations to `false`
2) You will need to synchronize buttons' status after user interact. To do that, please visit [Button Listeners components](../components/component_buttonListeners.md)

## Using outside IC - everything else

There is no other problems with outside IC except, that if you will try to synchronize status between two buttons that is synchronized automatically, you can get some weird results.

## Other tutorials

Thats all for this tutorial. See [more tutorials here](../tutorials.md)
