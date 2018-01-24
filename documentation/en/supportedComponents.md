# List of supported components in IC

This is list of supported components in IC. Each component have own documentation, so please look at it.

* __Animations__
  Animations are used to control visuals of model. They are also used in combination with other components
  Example of usage: Door animation, wipers, etc...
  [Component documentation](./components/component_animations.md)
* __Buttons__
  Buttons are used to trigger some action. IC provides several events that can be used in buttons.
  Example of usage: Implement control, lights control, etc...
  [Component documentation](./components/component_buttons.md)
* __Monitors__
  Monitors is used to interactively display tabs with informations like on real monitor. More explanation is on components page.
  Example of usage: Ingame display with info 4 tabs - on each tab is some buttons.
  [Component documentation](./components/component_monitors.md)
* __Visibility control__
  Visibility control is used for toggling some 3d ojects on/off. For complex solutions with turn on/off animation I'd recomend you __Animations__
  Example of usage: Toggling small decoration objects such as indoor fan, etc...
  [Component documentation](./components/component_visibilityControl.md)
* __Multi buttons__
  Multi buttons is useful when you need to trigger more then one IC component by one click.
  Example of usage: You want to play some animation when lowering vehicle from IC
  [Component documentation](./components/component_multibuttons.md)
* __Button listeners__
  Button listeners are used to synchronize status between buttons.
  Example of usage: Synchronize status between inside and outside door open
  [Component documentation](./components/component_buttonListeners.md)
* __Sounds__
  IC also allow you to assign sounds to each component. 
  Example of usage: beep sound effect when clicking some indoor button like lift implement.
  [Component documentation](./components/component_sounds.md)
