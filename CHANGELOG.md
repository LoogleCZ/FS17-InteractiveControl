# Changelog for Interactive Control script

## 4.0.5 - Dev. version

### Added

* Support for handbrake. This feature needs handrake mod.
* New attribute `toggleStyle` on IC root tag. This attribute allows you to define default toggle style for IC

### Changed

* Fix outside camera (Issue #1). Now there is no ugly bug with camera position after turning outside IC off.
* Fix behaviour of of attached implement with IC (Issue #2).
* Improvement of code in main update.
* Fix issue #4 - saving toggle style.
* Fix issue #5 - update error in turnOn events when retrieving status.

## 4.0.4 - 2018-01-25

### Added

* Support for _click_ sound. This sound uses `g_currentMission.sampleToggleLights` sample so user does not need to create his own sample. (Suggested by GtX from LS Modcompany)

### Changed

* Fix update status for this events (Suggested by GtX from LS Modcompany)
    * `radio.channelUp` - now remaining always as _close_
    * `radio.channelDown` - now remaining always as _close_
	* `lights.beaconLights` - there was a bug with calculating open status of this event.
* Update documentation because of click sound.
* Fix some documentation issues

## 4.0.3 - 2018-01-24

First release for Farming Simulator 17
