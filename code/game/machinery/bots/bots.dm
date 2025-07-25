// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/mob/npc/aibots.dmi'
	layer = MOB_LAYER
	light_range = 3
	use_power = POWER_USE_OFF
	var/obj/item/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots

/obj/machinery/bot/condition_hints(mob/user, distance, is_adjacent)
	. += list()
	. = ..()
	if (src.health < maxhealth)
		if (src.health > maxhealth/3)
			. += SPAN_WARNING("[src]'s parts look loose.")
		else
			. += SPAN_DANGER("[src]'s parts look very loose!")

/obj/machinery/bot/Initialize(mapload, d, populate_components, is_internal)
	. = ..()
	add_to_target_grid()

/obj/machinery/bot/Destroy()
	clear_from_target_grid()
	return ..()

/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	set_light(initial(light_range))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	set_light(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/emag_act(var/remaining_charges, var/user)
	if(locked && !emagged)
		locked = 0
		emagged = 1
		to_chat(user, SPAN_WARNING("You short out [src]'s maintenance hatch lock."))
		log_and_message_admins("emagged [src]'s maintenance hatch lock")
		return 1

	if(!locked && open && emagged == 1)
		emagged = 2
		log_and_message_admins("emagged [src]'s inner circuits")
		return 1

/obj/machinery/bot/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.isscrewdriver())
		if(!locked)
			open = !open
			to_chat(user, SPAN_NOTICE("Maintenance panel is now [src.open ? "opened" : "closed"]."))
		return TRUE
	else if(attacking_item.iswelder())
		if(health < maxhealth)
			if(open)
				health = min(maxhealth, health+10)
				user.visible_message(SPAN_WARNING("[user] repairs [src]!"),SPAN_NOTICE("You repair [src]!"))
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			else
				to_chat(user, SPAN_NOTICE("Unable to repair with the maintenance panel closed."))
		else
			to_chat(user, SPAN_NOTICE("[src] does not need a repair."))
		return TRUE
	else
		if(hasvar(attacking_item,"force") && hasvar(attacking_item,"damtype"))
			switch(attacking_item.damtype)
				if("fire")
					src.health -= attacking_item.force * fire_dam_coeff
				if("brute")
					src.health -= attacking_item.force * brute_dam_coeff
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			. = ..()
			healthcheck()
			return .
		else
			return ..()

/obj/machinery/bot/bullet_act(var/obj/projectile/Proj)
	if(!(Proj.damage_type == DAMAGE_BRUTE || Proj.damage_type == DAMAGE_BURN))
		return BULLET_ACT_BLOCK

	. = ..()
	if(. != BULLET_ACT_HIT)
		return .

	health -= Proj.damage
	healthcheck()

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	. = ..()

	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(src.loc)
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.set_dir(pick(GLOB.cardinals))

	QDEL_IN(pulse2, 10)

	if (on)
		turn_off()
	addtimer(CALLBACK(src, PROC_REF(post_emp), was_on), severity * 300)

/obj/machinery/bot/proc/post_emp(was_on)
	stat &= ~EMPED
	if (was_on)
		turn_on()

/obj/machinery/bot/attack_ai(mob/user as mob)
	if(!ai_can_interact(user))
		return
	src.attack_hand(user)

/obj/machinery/bot/attack_hand(var/mob/living/carbon/human/user)

	if(!istype(user))
		return ..()

	if(user.species.can_shred(user))
		src.health -= rand(15,30)*brute_dam_coeff
		src.visible_message(SPAN_DANGER("[user] has slashed [src]!"))
		playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
		if(prob(10))
			new /obj/effect/decal/cleanable/blood/oil(src.loc)
		healthcheck()

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in GLOB.cardinals)
		var/turf/simulated/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L


// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)

	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return 0
		return 1

	if(DirBlockedWithAccess(A,adir, ID))
		return 1

	if(DirBlockedWithAccess(B,rdir, ID))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.atom_flags & ATOM_FLAG_CHECKS_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc,var/dir,var/obj/item/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if( dir & D.dir )	return !D.check_access(ID)

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
		else return !D.check_access(ID)	// it's a real, air blocking door
	return 0
