# Changelog for Interactive Control script

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
