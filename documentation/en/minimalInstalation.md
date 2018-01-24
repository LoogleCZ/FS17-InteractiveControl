# Minimal instalation of IC

this tutorial will explain, how to integrate Interactive Control into your mod. Please note, that this tutorial is minimalistic - if you want to do more, please feel free to experimentations. Demonstrative modDesc.xml is available [here](./code/modDesc.xml).

## Step 1

Download latest release of IC from this GitHub repository. Then extract directory icSources into your mod directory. This will let you good base for later usage. It is better to have IC files together, separated from other files while developing new mod, because IC itself have lots of files.

## Step 2

Register specialization in `modDesc.xml`.

You will need to tell game that IC is part of your mod. This is done normally through `<specializations>`. In IC only thing you need to register as specialization is `InteractiveControl.lua` file. Here is an example.

```xml
<modDesc descVersion="37">
	<!-- rest of your modDesc here -->
	<specializations>
		<!-- rest of the specializations -->
		<specialization name="InteractiveControl" className="InteractiveControl" filename="icSources/InteractiveControl.lua"/>
	</specializations>
</modDesc>
```

[example modDesc.xml file](./code/modDesc.xml)

## Step 3

Prepare l10n and input bindings entries

You must tell game which key will be used by default to user interaction. This is done by `<inputBindings>` tag in `modDesc.xml`. Also you need to insert some default `<l10n>` entries. 
__ATTENTION__: If you want localize your IC into another language that is not here, please consider contribution with your translation.
Also __please note__ that actual localization entries are located in [separate file](./code/l10n_entries.xml) so you can easy have localized IC.

```xml
<modDesc descVersion="37">
	<!-- rest of your nodDesc here -->
	<inputBindings>
		<!-- another input bindings here -->
		<input name="INTERACTIVE_CONTROL_SWITCH" category="VEHICLE" key1="KEY_lalt"        key2="" button="" device="0" mouse="" />
		<input name="INTERACTIVE_CONTROL_MODE"   category="VEHICLE" key1="KEY_lctrl KEY_m" key2="" button="" device="0" mouse="" />
	</inputBindings>
	
	<l10n>
		<!-- another l10n entries here -->
		<text name="InteractiveControl_Off">
			<en>Disable IC</en>
		</text>
		<text name="InteractiveControl_On">
			<en>Activate IC</en>
		</text>
		<text name="InteractiveControl_ModeSelect">
			<en>IC toggle mode: %s</en>
		</text>
		<text name="InteractiveControl_Quick">
			<en>Quick</en>
		</text>
		<text name="input_INTERACTIVE_CONTROL_SWITCH">
			<en>Turn Interactive Control on/off</en>
		</text>
		<text name="input_INTERACTIVE_CONTROL_MODE">
			<en>Change Interactive Control toggle style</en>
		</text>
	</l10n>
</modDesc>
```

## Step 4

Since you have everything prepared for use, you need to add interactive constrol specialization into your vehicle type. This is done also in `modDesc.xml` in `<vehicleTypes>` section. Here is an example:

```xml
<modDesc descVersion="37">
	<!-- rest of your modDesc here -->
	<vehicleTypes>
		<!-- maybe other vehicleTypes -->
		<type name="yourVehicleType" className="Vehicle" filename="$dataS/scripts/vehicles/Vehicle.lua">
			<!-- rest of vehicle specializations here -->
			<specialization name="InteractiveControl"/>
		</type>
	</vehicleTypes>
</modDesc>
```

By now you have done minimal modDesc instalation, but also some vehicle xml editing is needed. So follow the Step 5

## Step 5

Open you mod xml file, and scroll at the and of file. Before `</vehicle>` closing tag insert this construction:

```xml
<vehicle type="yourVehicleType">
	<!-- rest of vehicle xml file here -->
	<interactiveComponents>
		<!-- this will be used in later tutorials -->
	</interactiveComponents>
</vehicle>
```

If you want to know more about xml nodes and attributes used in IC script, please follow [this link to IC XML format documentation](./XMLFormatDocumentation.md)

## Other useful links and tutorials

* [List of components](./supportedComponents.md)
* [IC XML format documentation](./XMLFormatDocumentation.md)
* [Setting up I3D buttons](./tutorials/settingUp3D.md)
* [Using outside IC for animations](./tutorials/outsideIC.md)
* [Using outside IC for 3 point hitches](./tutorials/3pControl.md)
* [How to make IC optional in shop](./tutorials/optionalIC.md)
* [Supported button events in IC](./components/supportedButtonEvents.md)
* [List of texts that is used by IC](./usedTexts.md) & [Default (localized) l10n entries](./code/l10n_entries.xml)
