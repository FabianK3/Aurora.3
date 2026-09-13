/obj/vehicle/atv
	name = "atv"
	desc = "This is an ATV. It's made for all kinds of terrain, providing mobility where larger vehicles would fail."
	icon = 'icons/obj/vehicle/atv.dmi'
	icon_state = "atv_off"

	load_item_visible = 1
	mob_offset_y = 5
	health = 100
	maxhealth = 100

	fire_dam_coeff = 0.6
	brute_dam_coeff = 0.5
	var/protection_percent = 60

	/// Speed on land. Higher is slower.
	/// If 0 it can't go on land turfs at all.
	var/land_speed = 1.4
	/// Speed if walk intent is on.
	/// Should be slower, but does not crash into other bikes or people at this speed.
	/// If land speed is 0, still can't go on land turfs at all.
	var/land_speed_careful = 2.2
	/// Same as land speed, but for space turfs.
	var/space_speed = 1
	/// Same as land speed if walk intent is on, but for space turfs.
	var/space_speed_careful = 2

	var/passenger = null
	var/crate = null

	/// Registration plate string of the vehicle, visible on examine,
	/// to distingush different vehicles of the same type from each other.
	/// Also used to check if the key is for this vehicle.
	/// If null, it is randomly generated on init.
	var/registration_plate = null
	/// Key type accepted in vehicle ignition.
	var/key_type = /obj/item/key/bike
	/// Actual key object in the vehicle ignition, or null if no key in ignition.
	/// To actually start the vehicle, key data needs to match with the registration plate string.
	var/obj/item/key/bike/key = null
	/// If TRUE, vehicle spawns with the key that matches its registration plate string.
	/// If FALSE, the key needs to be mapped/spawned somewhere outside of the vehicle,
	/// otherwise it will be an unusable prop.
	var/spawns_with_key = TRUE
	/// If TRUE, the key will spawned elsewhere designated by `/obj/effect/landmark/bike_key_spawner`.
	var/auto_spawn_key_elsewhere = FALSE

/obj/vehicle/atv/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "Click-drag yourself onto the bike to climb onto it."
	. += "Click-drag it onto yourself to access its mounted storage."
	. += "Click the bike with a key to put it in, and click the bike with empty hand to take it out. The bike won't run without a key."
	. += "CTRL-click the bike to toggle the engine."
	. += "ALT-click to toggle the kickstand which prevents movement by driving and dragging."
	. += "Click the resist button or type \"resist\" in the command bar at the bottom of your screen to get off the bike."
	. += "Go fast! Use the RUN intent to go fast! Just be careful you don't run anyone over."

/obj/vehicle/atv/feedback_hints(mob/user, distance, is_adjacent)
	. += ..()
	if(distance <= 4)
		. += "\The [src] has a small registration plate on the back, '[registration_plate]'."
		if(key)
			. += "\The [src] has \a [key] in."
		else
			. += "\The [src] does not have a key in."

/obj/vehicle/atv/Destroy()
	QDEL_NULL(key)
	return ..()

/obj/vehicle/atv/setup_vehicle()
	..()
	turn_off()
	AddOverlays(image(icon, "atv_off_overlay", MOB_LAYER + 1))
	icon_state = "atv_off"

	if(!registration_plate)
		generate_registration_plate()

	if(spawns_with_key)
		key = new key_type(src)
		key.key_data = registration_plate

	if(auto_spawn_key_elsewhere)
		var/list/our_z_levels = GetConnectedZlevels(z)
		for(var/obj/effect/landmark/bike_key_spawner/spawner in GLOB.landmarks_list)
			if(!(spawner.z in our_z_levels)) // this spawner isn't in the same map as us
				continue

			if(key_type in spawner.allowed_key_types)
				var/obj/item/key/bike/spawned_key = new key_type(get_turf(spawner))
				spawned_key.key_data = registration_plate
				spawned_key.pixel_x = pick(-8, 0, 8) // the key sprite appears nicely placed on the tables in these values
				spawned_key.pixel_y = pick(0, 8)
				break

/obj/vehicle/atv/proc/generate_registration_plate()
	registration_plate = "[rand(100,999)]-[rand(1000,9999)]"

/obj/vehicle/atv/CtrlClick(var/mob/user)
	if(Adjacent(user) && anchored)
		toggle_engine(user)
	else
		return ..()

/obj/vehicle/atv/proc/toggle_engine(var/mob/user)
	if(use_check_and_message(user))
		return

	if(!on)
		if(!key)
			to_chat(user, SPAN_WARNING("You cannot turn \the [src] on, without a key."))
			return

		if((key.key_data != registration_plate))
			user.visible_message("\The [user] turns \a [key] in the ignition of \the [src].", "You turn \a [key] in the ignition of \the [src], but it lets out a sharp buzz.")
		else
			user.visible_message("\The [user] turns \a [key] in the ignition of \the [src].", "You turn \a [key] in the ignition of \the [src], and it beeps happily.")
			turn_on()
			src.visible_message("\The [src] rumbles to life.", "You hear something rumble deeply.")
			playsound(src, 'sound/machines/vehicles/bike_start.ogg', 100, 1)
	else
		turn_off()
		src.visible_message("\The [src] putters before turning off.", "You hear something putter slowly.")

/obj/vehicle/atv/AltClick(var/mob/user)
	return ..()

/obj/vehicle/atv/load(var/atom/movable/C)
	var/mob/living/M = C
	if(!istype(C)) return 0
	if(M.buckled_to || M.restrained() || !Adjacent(M) || !M.Adjacent(src))
		return 0
	return ..(M)

/obj/vehicle/atv/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	return ..()

/obj/vehicle/atv/mouse_drop_receive(atom/dropped, mob/user, params)
	if(!load(dropped))
		to_chat(user, SPAN_WARNING("You were unable to load \the [dropped] onto \the [src]."))
		return

/obj/vehicle/atv/attack_hand(var/mob/user as mob)
	if(key)
		to_chat(user, "You take \the [key] out of \the [src]")
		user.put_in_hands(key)
		key = null
		if(on)
			toggle_engine(user)
	else if(user != load && load)
		user.visible_message ("[user] starts to unbuckle [load] from \the [src]!")
		if(do_after(user, 8 SECONDS, src))
			unload(load)
			to_chat(user, "You unbuckle [load] from \the [src]")
			to_chat(load, "You were unbuckled from \the [src] by [user]")

/obj/vehicle/atv/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/key))
		if(!key)
			if(istype(attacking_item, key_type))
				user.drop_from_inventory(attacking_item, src)
				key = attacking_item
				to_chat(user, SPAN_NOTICE("You put \the [attacking_item] in \the [src]."))
				update_icon()
			else
				to_chat(user, SPAN_NOTICE("You try to put \the [attacking_item] in \the [src], but it does not fit."))
		else
			to_chat(user, SPAN_NOTICE("\The [src] already has a key in it."))
	..()

/obj/vehicle/atv/relaymove(mob/living/user, direction)
	. = ..()

	if(user != load || !on || user.incapacitated())
		return
	return Move(get_step(src, direction))

/obj/vehicle/atv/RunOver(var/mob/living/carbon/human/H)
	var/mob/living/M

	if(!buckled)
		return

	if(istype(buckled, /mob/living))
		M = buckled

	var/collision_damage = clamp((maxhealth/6), 5, 30)
	if(M.m_intent == M_RUN)
		M.attack_log += "\[[time_stamp()]\]<font color='orange'> Was rammed by [src]</font>"
		M.attack_log += "\[[time_stamp()]\] <span class='warning'>rammed[M.name] ([M.ckey]) rammed [H.name] ([H.ckey]) with the [src].</span>"
		msg_admin_attack("[src] crashed into [key_name(H)] at (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>)" )
		src.visible_message(SPAN_DANGER("\The [src] runs over \the [H]!"))
		H.apply_damage(collision_damage, DAMAGE_BRUTE)
		H.apply_effect(4, WEAKEN)
		return TRUE

/obj/vehicle/atv/proc/check_destination(var/turf/destination)
	var/static/list/types = typecacheof(list(/turf/space))
	if((is_type_in_typecache(destination,types) && !locate(/obj/structure/lattice)) || pulledby)
		return TRUE
	else
		return FALSE

/obj/vehicle/atv/Move(var/turf/destination)
	var/mob/living/rider = buckled
	if(!istype(buckled))
		return

	var/is_careful = (rider.m_intent != M_RUN)
	var/is_on_space = check_destination(destination)

	if(!land_speed)
		return FALSE
	move_delay = (is_careful ? land_speed_careful : land_speed)

	return ..()

/obj/vehicle/atv/turn_on()
	update_icon()

	if(ismob(pulledby))
		var/mob/M = pulledby
		M.stop_pulling()
	..()

/obj/vehicle/atv/turn_off()
	update_icon()
	..()

/obj/vehicle/atv/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	if(buckled && prob(protection_percent))
		return buckled.bullet_act(arglist(args))

	..()

/obj/vehicle/atv/update_icon()
	ClearOverlays()

	if(on)
		AddOverlays(image(icon, "atv_on_overlay", MOB_LAYER + 1))
		icon_state = "atv_on"
	else
		AddOverlays(image(icon, "atv_off_overlay", MOB_LAYER + 1))
		icon_state = "atv_off"

	..()

/obj/vehicle/atv/Collide(var/atom/movable/AM)
	. = ..()
	collide_act(AM)

/obj/vehicle/atv/proc/collide_act(var/atom/movable/AM)
	var/mob/living/M
	if(!buckled)
		return
	if(istype(buckled, /mob/living))
		M = buckled
	if(M.m_intent == M_RUN)
		if (istype(AM, /obj/vehicle))
			M.setMoveCooldown(10)
			var/obj/vehicle/V = AM
			if(prob(50))
				if(V.buckled)
					if(ishuman(V.buckled))
						var/mob/living/carbon/human/I = V.buckled
						I.visible_message(SPAN_DANGER("\The [I] falls off from \the [V]"))
						V.unload(I)
						I.throw_at(get_edge_target_turf(V.loc, V.loc.dir), 5, 1)
						I.apply_effect(2, WEAKEN)
				if(prob(25))
					if(ishuman(buckled))
						var/mob/living/carbon/human/C = buckled
						C.visible_message(SPAN_DANGER ("\The [C] falls off from \the [src]!"))
						unload(C)
						C.throw_at(get_edge_target_turf(loc, loc.dir), 5, 1)
						C.apply_effect(2, WEAKEN)

		if(isliving(AM))
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Was rammed by [src]</font>"
				M.attack_log += "\[[time_stamp()]\] <span class='warning'>rammed[M.name] ([M.ckey]) rammed [H.name] ([H.ckey]) with the [src].</span>"
				msg_admin_attack("[src] crashed into [key_name(H)] at (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>)" )
				src.visible_message(SPAN_DANGER("\The [src] smashes into \the [H]!"))
				playsound(src, SFX_SWING_HIT, 50, 1)
				H.apply_damage(20, DAMAGE_BRUTE)
				H.throw_at(get_edge_target_turf(loc, loc.dir), 5, 1)
				H.apply_effect(4, WEAKEN)
				M.setMoveCooldown(10)
				return TRUE

			else
				var/mob/living/L = AM
				src.visible_message(SPAN_DANGER("\The [src] smashes into \the [L]!"))
				playsound(src, SFX_SWING_HIT, 50, 1)
				L.throw_at(get_edge_target_turf(loc, loc.dir), 5, 1)
				L.apply_damage(20, DAMAGE_BRUTE)
				M.setMoveCooldown(10)
				return TRUE
