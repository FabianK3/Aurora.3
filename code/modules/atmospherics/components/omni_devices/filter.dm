//--------------------------------------------
// Gas filter - omni variant
//--------------------------------------------
/obj/machinery/atmospherics/omni/filter
	name = "omni gas filter"
	icon_state = "map_filter"
	base_icon = "filter"

	var/list/active_filters = new()
	var/datum/omni_port/input
	var/datum/omni_port/output

	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 15000			//15000 W ~ 20 HP

	var/max_flow_rate = ATMOS_DEFAULT_VOLUME_FILTER
	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_FILTER

	var/list/filtering_outputs = list()	//maps gasids to gas_mixtures

/obj/machinery/atmospherics/omni/filter/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "Filters gas from a custom input direction, with up to two filtered outputs and an 'everything else' output."
	. += "The filtered output's arrows glow orange."

/obj/machinery/atmospherics/omni/filter/Initialize()
	. = ..()
	rebuild_filtering_list()
	for(var/datum/omni_port/P in ports)
		P.air.volume = ATMOS_DEFAULT_VOLUME_FILTER

/obj/machinery/atmospherics/omni/filter/Destroy()
	input = null
	output = null
	active_filters.Cut()
	return ..()

/obj/machinery/atmospherics/omni/filter/sort_ports()
	for(var/datum/omni_port/P in ports)
		if(P.update)
			if(output == P)
				output = null
			if(input == P)
				input = null
			if(active_filters.Find(P))
				active_filters -= P

			P.air.volume = 200
			switch(P.mode)
				if(ATM_INPUT)
					input = P
				if(ATM_OUTPUT)
					output = P
				if(ATM_O2 to ATM_H2O)
					active_filters += P

/obj/machinery/atmospherics/omni/filter/error_check()
	if(!input || !output || !active_filters)
		return 1
	if(active_filters.len < 1) //requires at least 1 filter ~otherwise why are you using a filter?
		return 1

	return 0

/obj/machinery/atmospherics/omni/filter/process()
	if(!..())
		return 0

	var/datum/gas_mixture/output_air = output.air	//BYOND doesn't like referencing "output.air.return_pressure()" so we need to make a direct reference
	var/datum/gas_mixture/input_air = input.air		// it's completely happy with them if they're in a loop though i.e. "P.air.return_pressure()"... *shrug*

	//Figure out the amount of moles to transfer
	var/transfer_moles = (set_flow_rate/input_air.volume)*input_air.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_FILTER)
		power_draw = filter_gas_multi(src, filtering_outputs, input_air, output_air, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

		if(input.network)
			input.network.update = 1
		if(output.network)
			output.network.update = 1
		for(var/datum/omni_port/P in active_filters)
			if(P.network)
				P.network.update = 1

	return 1

/obj/machinery/atmospherics/omni/filter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/list/data = new()

	data = build_uidata()

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "omni_filter.tmpl", "Omni Filter Control", 470, 330)
		ui.set_initial_data(data)

		ui.open()

/obj/machinery/atmospherics/omni/filter/proc/build_uidata()
	var/list/data = new()

	data["power"] = use_power
	data["config"] = configuring
	data["last_power_draw"] = last_power_draw
	data["max_power_draw"] = power_rating

	var/portData[0]
	for(var/datum/omni_port/P in ports)
		if(!configuring && P.mode == 0)
			continue

		var/input = 0
		var/output = 0
		var/filter = 1
		var/f_type = null
		switch(P.mode)
			if(ATM_INPUT)
				input = 1
				filter = 0
			if(ATM_OUTPUT)
				output = 1
				filter = 0
			if(ATM_O2 to ATM_H2O)
				f_type = mode_send_switch(P.mode)

		portData[++portData.len] = list("dir" = dir_name(P.dir, capitalize = 1), \
										"input" = input, \
										"output" = output, \
										"filter" = filter, \
										"f_type" = f_type)

	if(portData.len)
		data["ports"] = portData
	if(output)
		data["set_flow_rate"] = round(set_flow_rate*10)		//because nanoui can't handle rounded decimals.
		data["last_flow_rate"] = round(last_flow_rate*10)

	return data

/obj/machinery/atmospherics/omni/filter/proc/mode_send_switch(var/mode = ATM_NONE)
	switch(mode)
		if(ATM_O2)
			return "Oxygen"
		if(ATM_N2)
			return "Nitrogen"
		if(ATM_CO2)
			return "Carbon Dioxide"
		if(ATM_P)
			return "Phoron" //*cough* Plasma *cough*
		if(ATM_N2O)
			return "Nitrous Oxide"
		if(ATM_H)
			return "Hydrogen"
		if(ATM_2H)
			return "Deuterium"
		if(ATM_3H)
			return "Tritium"
		if(ATM_HE)
			return "Helium"
		if(ATM_B)
			return "Boron"
		if(ATM_SO2)
			return "Sulfur Dioxide"
		if(ATM_NO2)
			return "Nitrogen Dioxide"
		if(ATM_CL2)
			return "Chlorine"
		if(ATM_H2O)
			return "Steam"
		else
			return null

/obj/machinery/atmospherics/omni/filter/Topic(href, href_list)
	if(..()) return 1
	switch(href_list["command"])
		if("power")
			if(!configuring)
				update_use_power(!use_power)
			else
				update_use_power(POWER_USE_OFF)
		if("configure")
			configuring = !configuring
			if(configuring)
				update_use_power(POWER_USE_OFF)

	//only allows config changes when in configuring mode ~otherwise you'll get weird pressure stuff going on
	if(configuring && !use_power)
		switch(href_list["command"])
			if("set_flow_rate")
				var/new_flow_rate = input(usr,"Enter new flow rate limit (0-[max_flow_rate]L/s)","Flow Rate Control",set_flow_rate) as num
				set_flow_rate = between(0, new_flow_rate, max_flow_rate)
			if("switch_mode")
				switch_mode(dir_flag(href_list["dir"]), mode_return_switch(href_list["mode"]))
			if("switch_filter")
				var/new_filter = input(usr,"Select filter mode:","Change filter",href_list["mode"]) in list("None", "Oxygen", "Nitrogen", "Carbon Dioxide", "Phoron", "Nitrous Oxide", "Hydrogen", "Deuterium", "Tritium", "Helium", "Boron", "Sulfur Dioxide", "Nitrogen Dioxide", "Chlorine", "Steam")
				switch_filter(dir_flag(href_list["dir"]), mode_return_switch(new_filter))

	update_icon()
	SSnanoui.update_uis(src)
	return

/obj/machinery/atmospherics/omni/filter/proc/mode_return_switch(var/mode)
	switch(mode)
		if("Oxygen")
			return ATM_O2
		if("Nitrogen")
			return ATM_N2
		if("Carbon Dioxide")
			return ATM_CO2
		if("Phoron")
			return ATM_P
		if("Nitrous Oxide")
			return ATM_N2O
		if("Hydrogen")
			return ATM_H
		if("Deuterium")
			return ATM_2H
		if("Tritium")
			return ATM_3H
		if("Helium")
			return ATM_HE
		if("Boron")
			return ATM_B
		if("Sulfur Dioxide")
			return ATM_SO2
		if("Nitrogen Dioxide")
			return ATM_NO2
		if("Chlorine")
			return ATM_CL2
		if("Steam")
			return ATM_H2O
		if("in")
			return ATM_INPUT
		if("out")
			return ATM_OUTPUT
		if("None")
			return ATM_NONE
		else
			return null

/obj/machinery/atmospherics/omni/filter/proc/switch_filter(var/dir, var/mode)
	//check they aren't trying to disable the input or output ~this can only happen if they hack the cached tmpl file
	for(var/datum/omni_port/P in ports)
		if(P.dir == dir)
			if(P.mode == ATM_INPUT || P.mode == ATM_OUTPUT)
				return

	switch_mode(dir, mode)

/obj/machinery/atmospherics/omni/filter/proc/switch_mode(var/port, var/mode)
	if(mode == null || !port)
		return
	var/datum/omni_port/target_port = null
	var/list/other_ports = new()

	for(var/datum/omni_port/P in ports)
		if(P.dir == port)
			target_port = P
		else
			other_ports += P

	var/previous_mode = null
	if(target_port)
		previous_mode = target_port.mode
		target_port.mode = mode
		if(target_port.mode != previous_mode)
			handle_port_change(target_port)
			rebuild_filtering_list()
		else
			return
	else
		return

	for(var/datum/omni_port/P in other_ports)
		if(P.mode == mode)
			var/old_mode = P.mode
			P.mode = previous_mode
			if(P.mode != old_mode)
				handle_port_change(P)

	update_ports()

/obj/machinery/atmospherics/omni/filter/proc/rebuild_filtering_list()
	filtering_outputs.Cut()
	for(var/datum/omni_port/P in ports)
		var/gasid = mode_to_gasid(P.mode)
		if(gasid)
			filtering_outputs[gasid] = P.air

/obj/machinery/atmospherics/omni/filter/proc/handle_port_change(var/datum/omni_port/P)
	switch(P.mode)
		if(ATM_NONE)
			initialize_directions &= ~P.dir
			P.disconnect()
		else
			initialize_directions |= P.dir
			P.connect()
	P.update = 1
