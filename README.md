# Helix-LSCS-Compat
This plugin adds some item bases and an attribute to add some compatibility between the Helix gamemode and the LSCS addon.

Look in [LSCSCompat\items](https://github.com/Solace140/Helix-LSCS-Compat/tree/main/LSCSCompat/items) for examples itemizing force abilities, lightsaber hilts and lightsaber crystals.
Simply put the entity class (find the desired item in the spawn menu, right click, copy) into the ITEM.class field.

Keep in mind this does not affect the functionality or appearance of any LSCS items, merely lets you equip them through the Helix inventory.

This also adds a stat that influences a player's maximum force points, and in-game config for base force points and stat scaling.

Known issues:
For hilts and crystals, if both hands have the same item equipped, unequipping one will remove both from the player's inventory. For now, unequip both then equip the desired items.

Documentation:
[Helix](https://docs.gethelix.co)
[LSCS lua functions](https://github.com/SpaxscE/lscs_public/blob/main/zz_templates_and_info/useful_lua_functions.txt)
