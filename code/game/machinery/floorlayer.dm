/obj/machinery/floorlayer
	name = "automatic floor layer"
	desc = "A large piece of machinery used that can place, dismantle, and collect floor tiles."
	icon = 'icons/obj/floor_layer.dmi'
	icon_state = "floor_layer"
	density = TRUE
	var/turf/old_turf
	var/on = FALSE
	var/obj/item/stack/tile/T
	var/list/mode = list("dismantle"=0,"laying"=0,"collect"=0)

/obj/machinery/floorlayer/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "Use a screwdriver to set which tile to lay, a wrench to configure the various modes, and a crowbar to take out tiles."
	. += "Clicking on it with an empty hand will turn it on and off."

/obj/machinery/floorlayer/feedback_hints(mob/user, distance, is_adjacent)
	. += ..()
	var/dismantle = mode["dismantle"]
	var/laying = mode["laying"]
	var/collect = mode["collect"]
	var/number = 0
	if (T)
		number = T.get_amount()
	. += "\The [src] has [number] tile\s, dismantle is [dismantle ? "on" : "off"], laying is [laying ? "on" : "off"], collect is [collect ? "on" : "off"]."

/obj/machinery/floorlayer/Initialize()
	. = ..()
	T = new /obj/item/stack/tile/floor/full_stack(src)

/obj/machinery/floorlayer/Move(new_turf,M_Dir)
	. = ..()

	if(on)
		if(mode["dismantle"])
			dismantle_floor(old_turf)

		if(mode["laying"])
			lay_floor(old_turf)

		if(mode["collect"])
			collect_tiles(old_turf)

	old_turf = new_turf

/obj/machinery/floorlayer/attack_hand(mob/user)
	on = !on
	user.visible_message("<b>[user]</b> has [!on ? "de" : ""]activated \the [src].", SPAN_NOTICE("You [!on ? "de" : ""]activate \the [src]."))

/obj/machinery/floorlayer/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.iswrench())
		var/m = tgui_input_list(user, "Choose work mode", "Mode", mode)
		mode[m] = !mode[m]
		var/O = mode[m]
		user.visible_message("<b>[user]</b> has set \the [src] [m] mode [!O ? "off" : "on"].", SPAN_NOTICE("You set \the [src] [m] mode [!O ? "off":"on"]."))
		return TRUE

	if(istype(attacking_item, /obj/item/stack/tile))
		to_chat(user, SPAN_NOTICE("You successfully load \the [attacking_item] into \the [src]."))
		user.drop_from_inventory(attacking_item, src)
		take_tile(attacking_item)
		return TRUE

	if(attacking_item.iscrowbar())
		if(!length(contents))
			to_chat(user, SPAN_NOTICE("\The [src] is empty."))
		else
			var/obj/item/stack/tile/E = tgui_input_list(user, "Choose which set of tiles you want to remove.", "Tiles", contents)
			if(E)
				to_chat(user, SPAN_NOTICE("You remove \the [E] from \the [src]."))
				user.put_in_hands(E)
				T = null
		return TRUE

	if(attacking_item.isscrewdriver())
		T = tgui_input_list(user, "Choose which set of tiles you want \the [src] to lay.", "Tiles", contents)
		return TRUE

/obj/machinery/floorlayer/proc/reset()
	on = FALSE

/obj/machinery/floorlayer/proc/dismantle_floor(var/turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			if(!T.broken && !T.burnt)
				new T.flooring.build_type(T)
			T.make_plating()
		return T.is_plating()
	return FALSE

/obj/machinery/floorlayer/proc/take_new_stack()
	for(var/obj/item/stack/tile/tile in contents)
		T = tile
		return TRUE
	return FALSE

/obj/machinery/floorlayer/proc/sort_stacks()
	for(var/obj/item/stack/tile/tile1 in contents)
		if (tile1 && tile1.get_amount() > 0)
			if (!T || T.type == tile1.type)
				T = tile1
			if (tile1.get_amount() < tile1.max_amount)
				for(var/obj/item/stack/tile/tile2 in contents)
					if (tile2 != tile1 && tile2.type == tile1.type)
						tile2.transfer_to(tile1)

/obj/machinery/floorlayer/proc/lay_floor(var/turf/w_turf)
	if(!T)
		if(!take_new_stack())
			return FALSE
	w_turf.attackby(T, src)
	return TRUE

/obj/machinery/floorlayer/proc/take_tile(var/obj/item/stack/tile/tile)
	if(!T)
		T = tile
	tile.forceMove(src)

	sort_stacks()

/obj/machinery/floorlayer/proc/collect_tiles(var/turf/w_turf)
	for(var/obj/item/stack/tile/tile in w_turf)
		take_tile(tile)
