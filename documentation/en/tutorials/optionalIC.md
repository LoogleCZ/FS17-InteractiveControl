# How to make IC optional feature

You can also make IC optional in shop. It's not an hard task - all you need to do is follow this steps:

## Step 1 - Prepare modDesc

You need to prepare separate vehicle types - one for you vehicle with IC and one for you vehicle without IC. Also you'll need to add store icon to you mod's directory. One of this icon can be found in release under folder `store`. Here is text for store to display when user select that he want have mod with IC (text is for l10n):

```xml
<text name="configuration_IC">
	<en>+ Interactive Control (IC)</en>
	<de>+ Interactive Control (IC)</de>
</text>
<text name="configuration_Standard">
	<en>Standard</en>
	<de>Standard</de>
</text>
```

## Step 2 - vehicle's xml

In vehicle's xml you need to add this part of xml:

```xml
<vehicleTypeConfigurations>
	<vehicleTypeConfiguration name="$l10n_configuration_Standard" price="0" vehicleType="__YOUR_VEHICLE_TYPE_WITHOUT_IC__">
	</vehicleTypeConfiguration>
	<vehicleTypeConfiguration name="$l10n_configuration_IC" price="0" vehicleType="__YOUR_VEHICLE_TYPE_WITH_IC__" icon="store/config_IC.dds">
	</vehicleTypeConfiguration>
</vehicleTypeConfigurations>
```

Where you need to fill parts with capitals. Sure you can use standard game configuration options for different vehicle types like `objectChange`, etc...

## Other tutorials

Thats all for this tutorial. See [more tutorials here](../tutorials.md)
