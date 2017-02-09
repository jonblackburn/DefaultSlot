# DefaultSlot
Default Slot is a project I created to help me with one of my biggest in-game obstacles. Forgetting to re-slot my potions 
after siege.

Frequently after flipping to my catapult or my ballista I'd mindlessly wander off and find myself engaged in group or 1 v. 1
battles and when I'd get low on HP I'd pop my pot only to find the Ballista circle on the ground in those final seconds before
I die.  

This addon fixes that problem.  It allows me to specify a slot that will be my default slot (hence the name). And a length of time
in seconds that is allowed to elapse before the currently slotted item gets flipped to the default slot.

## Dependencies
The addon uses the LibAddonMenu-2.0 library to add settings to the addon settings menu.

## Version History

### 0.1 Initial Version
First build that was uploaded to GitHub

### O.1.1 Updated to support API Level 18 (Homestead Update).

#### Key Features
- [x] Can configure the default slot by number, a texture slot key is shown on the settings screen that shows how the numbers align
- [x] Can configure the amount of time in seconds to wait before triggering the change back to the default slot.
- [x] Can enable or disable siege suppression, this makes it so default slot will not activate and change the active slot while siege is active.

#### Known Issuse
- [ ] Debug messages are shown in chat log and there is no way to turn them off without a code change.  I've not decided if I want this to be a user setting.
- [ ] Siege suppression doesn't work on Keep Door and Keep Wall repair kits.

