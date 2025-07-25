// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "mounted flash"
	desc = "A mounted flash. Disorientates anyone caught in its range."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	obj_flags = OBJ_FLAG_MOVES_UNSUPPORTED
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 20 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1
	idle_power_usage = 2
	movable_flags = MOVABLE_FLAG_PROXMOVE
	var/_wifi_id
	var/datum/wifi/receiver/button/flasher/wifi_receiver

/obj/machinery/flasher/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "Use a wirecutter on this to disconnect the flashbulb, disabling it. Use wirecutters again to reconnect it."

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1

/obj/machinery/flasher/Initialize()
	. = ..()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

/obj/machinery/flasher/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/flasher/power_change()
	..()
	if ( !(stat & NOPOWER) )
		icon_state = "[base_state]1"
//		src.sd_SetLuminosity(2)
	else
		icon_state = "[base_state]1-p"
//		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/attacking_item, mob/user)
	if (attacking_item.iswirecutter())
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message(SPAN_WARNING("[user] has disconnected the [src]'s flashbulb!"), SPAN_WARNING("You disconnect the [src]'s flashbulb!"))
		if (!src.disable)
			user.visible_message(SPAN_WARNING("[user] has connected the [src]'s flashbulb!"), SPAN_WARNING("You connect the [src]'s flashbulb!"))
		return TRUE

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if(!ai_can_interact(user))
		return
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	src.last_flash = world.time
	use_power_oneoff(1500)

	for (var/mob/O in viewers(range, get_turf(src)))
		if(!O.flash_act(ignore_inherent = TRUE))
			continue

		var/flash_time = strength
		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			flash_time *= H.species.flash_mod

		O.Weaken(flash_time)

/obj/machinery/flasher/emp_act(severity)
	. = ..()

	if(stat & (BROKEN|NOPOWER))
		return

	if(prob(75/severity))
		flash()

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if (src.anchored)
		src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/attacking_item, mob/user)
	if (attacking_item.iswrench())
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			user.show_message(SPAN_WARNING("[src] can now be moved."))
			ClearOverlays()

		else if (src.anchored)
			user.show_message(SPAN_WARNING("[src] is now secured."))
			AddOverlays("[base_state]-s")
		return TRUE

/obj/machinery/button/flasher
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."

/obj/machinery/button/flasher/attack_hand(mob/user as mob)

	if(..())
		return

	use_power_oneoff(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in SSmachinery.machinery)
		if(M.id == src.id)
			M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
