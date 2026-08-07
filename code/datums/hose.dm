// Generic bendable hose visual with pixel-distance limiting.

// Like AdjacentTurfs, but always permits stepping onto the goal turf even if it is blocked by dense contents.
/turf/proc/AdjacentTurfsHose(var/turf/goal)
	. = list()
	for(var/turf/t in orange(src, 1))
		if(t == goal)
			. += t
			continue
		if(t.density)
			continue
		if(LinkBlocked(src, t))
			continue
		if(TurfBlockedNonWindow(t))
			continue
		. += t

/datum/hose_visual
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state = ""
	var/max_length_px = 0
	var/current_length_px = 0
	var/sleep_time = 1
	var/finished = FALSE
	var/timing_id = null
	var/recalculating = FALSE
	var/beam_type = /obj/effect/ehose
	var/datum/callback/on_limit_reached = null
	var/segment_length_px = 5
	var/midpoint_jitter_px = 3
	var/list/route_turfs = null
	var/preserve_path = TRUE
	var/hidden_due_to_length = FALSE

	var/last_origin_x = null
	var/last_origin_y = null
	var/last_origin_z = null
	var/last_target_x = null
	var/last_target_y = null
	var/last_target_z = null

/datum/hose_visual/New(hose_origin, hose_target, hose_icon = 'icons/effects/beam.dmi', hose_icon_state = "hose", hose_max_length_px = 160, time = -1, hose_beam_type = /obj/effect/ehose, hose_sleep_time = 1, datum/callback/limit_callback = null, hose_segment_length_px = 5, hose_preserve_path = TRUE)
	origin = hose_origin
	target = hose_target
	max_length_px = hose_max_length_px
	base_icon = new(hose_icon, hose_icon_state)
	icon = hose_icon
	icon_state = hose_icon_state
	beam_type = hose_beam_type
	sleep_time = hose_sleep_time
	on_limit_reached = limit_callback
	segment_length_px = max(1, round(hose_segment_length_px))
	preserve_path = hose_preserve_path

	if(time != -1)
		addtimer(CALLBACK(src, PROC_REF(End), TRUE), time)

/datum/hose_visual/proc/Start()
	register_endpoint_signals(origin)
	register_endpoint_signals(target)
	recalculate()

/datum/hose_visual/proc/register_endpoint_signals(atom/endpoint)
	if(!ismovable(endpoint))
		return
	RegisterSignal(endpoint, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_endpoint_pre_move))
	RegisterSignal(endpoint, COMSIG_MOVABLE_MOVED, PROC_REF(on_endpoint_moved))
	RegisterSignal(endpoint, COMSIG_QDELETING, PROC_REF(on_endpoint_deleted))

/datum/hose_visual/proc/unregister_endpoint_signals(atom/endpoint)
	if(!ismovable(endpoint))
		return
	UnregisterSignal(endpoint, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

/datum/hose_visual/proc/on_endpoint_deleted(datum/source, force)
	SIGNAL_HANDLER
	End()

/datum/hose_visual/proc/on_endpoint_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	recalculate_in(0)

/datum/hose_visual/proc/on_endpoint_pre_move(datum/source, atom/newloc)
	SIGNAL_HANDLER

	if(QDELETED(src) || finished)
		return

	var/atom/movable/mover = source
	var/turf/new_turf = get_turf(newloc)
	if(!istype(new_turf))
		return

	var/predicted_distance = get_predicted_pixel_distance(mover, new_turf)
	if(predicted_distance < max_length_px)
		hidden_due_to_length = FALSE
		return

	if(!on_limit_reached)
		hidden_due_to_length = TRUE
		Reset()
		return

	return invoke_limit_callback(mover, newloc, predicted_distance)

/datum/hose_visual/proc/invoke_limit_callback(atom/movable/mover, atom/attempted_newloc, predicted_distance)
	if(on_limit_reached)
		var/callback_result = on_limit_reached.Invoke(src, mover, attempted_newloc, predicted_distance, max_length_px)
		if(isnum(callback_result))
			return callback_result
		if(callback_result)
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
		return

	return

/datum/hose_visual/proc/recalculate()
	if(QDELETED(src) || finished)
		return

	if(recalculating)
		recalculate_in(sleep_time)
		return

	recalculating = TRUE
	timing_id = null

	var/list/origin_point = get_point_data(origin)
	var/list/target_point = get_point_data(target)

	if(!origin_point || !target_point)
		Reset()
		recalculating = FALSE
		after_calculate()
		return

	current_length_px = get_pixel_distance_from_points(origin_point, target_point)

	if(!on_limit_reached && current_length_px >= max_length_px)
		hidden_due_to_length = TRUE
		Reset()
		recalculating = FALSE
		after_calculate()
		return

	hidden_due_to_length = FALSE

	if(position_changed(origin_point, target_point))
		cache_positions(origin_point, target_point)
		Reset()
		Draw(origin_point, target_point)

	recalculating = FALSE
	after_calculate()

/datum/hose_visual/proc/recalculate_in(time)
	if(QDELETED(src) || finished)
		return
	timing_id = addtimer(CALLBACK(src, PROC_REF(recalculate)), time, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/datum/hose_visual/proc/after_calculate()
	if(QDELETED(src) || finished || isnull(sleep_time))
		return
	timing_id = addtimer(CALLBACK(src, PROC_REF(recalculate)), sleep_time, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/datum/hose_visual/proc/End(destroy_self = TRUE)
	if(finished)
		return

	finished = TRUE
	if(timing_id)
		deltimer(timing_id)
		timing_id = null

	unregister_endpoint_signals(origin)
	unregister_endpoint_signals(target)
	Reset()

	if(!QDELING(src) && destroy_self)
		qdel(src)

/datum/hose_visual/proc/Reset()
	QDEL_LIST(elements)

/datum/hose_visual/Destroy()
	if(timing_id)
		deltimer(timing_id)
	timing_id = null

	unregister_endpoint_signals(origin)
	unregister_endpoint_signals(target)
	Reset()

	origin = null
	target = null
	on_limit_reached = null
	route_turfs = null
	return ..()

/datum/hose_visual/proc/Draw(list/origin_point, list/target_point)
	if(!origin_point || !target_point)
		return

	if(origin_point["z"] != target_point["z"])
		return

	var/turf/origin_turf = get_turf(origin)
	var/turf/target_turf = get_turf(target)
	var/list/current_route_turfs = get_routed_turfs(origin_turf, target_turf)

	if(!islist(current_route_turfs) || current_route_turfs.len < 2)
		if(origin_turf == target_turf)
			draw_leg(origin_point["x"], origin_point["y"], target_point["x"], target_point["y"], origin_point["z"])
		return

	var/list/route_points = build_route_points(current_route_turfs, origin_point, target_point)
	if(!islist(route_points) || route_points.len < 2)
		return

	for(var/index in 1 to route_points.len - 1)
		var/list/start_point = route_points[index]
		var/list/end_point = route_points[index + 1]
		draw_leg(start_point["x"], start_point["y"], end_point["x"], end_point["y"], start_point["z"])


/datum/hose_visual/proc/get_routed_turfs(turf/origin_turf, turf/target_turf)
	if(!istype(origin_turf) || !istype(target_turf) || origin_turf.z != target_turf.z)
		route_turfs = null
		return null

	if(!islist(route_turfs) || !route_turfs.len)
		route_turfs = build_full_route(origin_turf, target_turf)
		return route_turfs

	trim_route_to_existing_endpoints(origin_turf, target_turf)

	var/turf/route_start = route_turfs[1]
	var/turf/route_end = route_turfs[route_turfs.len]
	if(!istype(route_start) || !istype(route_end) || route_start.z != origin_turf.z || route_end.z != target_turf.z)
		route_turfs = build_full_route(origin_turf, target_turf)
		return route_turfs

	var/list/prefix = AStar(origin_turf, route_start, /turf/proc/AdjacentTurfsHose, /turf/proc/Distance, 0, 256, 0, null, route_start)
	var/list/suffix = AStar(route_end, target_turf, /turf/proc/AdjacentTurfsHose, /turf/proc/Distance, 0, 256, 0, null, target_turf)

	if(!islist(prefix) || !prefix.len || !islist(suffix) || !suffix.len)
		if(preserve_path)
			return route_turfs
		route_turfs = build_full_route(origin_turf, target_turf)
		return route_turfs

	var/list/merged = list()
	for(var/prefix_index in 1 to prefix.len)
		merged += prefix[prefix_index]

	if(route_turfs.len > 2)
		for(var/core_index in 2 to route_turfs.len - 1)
			merged += route_turfs[core_index]

	if(suffix.len > 1)
		for(var/suffix_index in 2 to suffix.len)
			merged += suffix[suffix_index]

	route_turfs = simplify_turf_path(merged)
	return route_turfs

/datum/hose_visual/proc/trim_route_to_existing_endpoints(turf/origin_turf, turf/target_turf)
	if(!islist(route_turfs) || route_turfs.len < 2)
		return

	var/origin_index = route_turfs.Find(origin_turf)
	var/target_index = route_turfs.Find(target_turf)

	if(origin_index && target_index)
		if(origin_index <= target_index)
			route_turfs = route_turfs.Copy(origin_index, target_index + 1)
		else
			route_turfs = route_turfs.Copy(target_index, origin_index + 1)
			if(route_turfs.len)
				route_turfs = reverseList(route_turfs)
		return

	if(origin_index)
		route_turfs = route_turfs.Copy(origin_index, 0)

	target_index = route_turfs.Find(target_turf)
	if(target_index)
		route_turfs = route_turfs.Copy(1, target_index + 1)

/datum/hose_visual/proc/simplify_turf_path(list/path)
	if(!islist(path) || path.len <= 2)
		return path

	var/list/simplified = list()
	for(var/path_index in 1 to path.len)
		var/turf/current = path[path_index]
		if(!current)
			continue

		var/already_index = simplified.Find(current)
		if(already_index)
			simplified.Cut(already_index + 1, 0)
			continue

		simplified += current

	return simplified

/datum/hose_visual/proc/build_full_route(turf/origin_turf, turf/target_turf)
	var/list/path = AStar(origin_turf, target_turf, /turf/proc/AdjacentTurfsHose, /turf/proc/Distance, 0, 256, 0, null, target_turf)
	if(!islist(path) || !path.len)
		return null
	return path

/datum/hose_visual/proc/build_route_points(list/path, list/origin_point, list/target_point)
	var/list/route_points = list(origin_point)

	// Keep every path step so visuals cannot cut across blockers, but jitter midpoints for a less boxy look.
	if(path.len > 2)
		for(var/path_index in 2 to path.len - 1)
			var/turf/current_turf = path[path_index]
			route_points += list(jittered_turf_point(path, path_index, current_turf))

	route_points += list(target_point)
	return route_points

/datum/hose_visual/proc/jittered_turf_point(list/path, path_index, turf/current_turf)
	var/list/base = turf_center_point(current_turf)
	if(path_index <= 1 || path_index >= path.len)
		return base

	var/turf/previous_turf = path[path_index - 1]
	var/turf/next_turf = path[path_index + 1]
	if(!previous_turf || !next_turf)
		return base

	var/in_dx = current_turf.x - previous_turf.x
	var/in_dy = current_turf.y - previous_turf.y
	var/out_dx = next_turf.x - current_turf.x
	var/out_dy = next_turf.y - current_turf.y

	var/is_corner = (in_dx != out_dx) || (in_dy != out_dy)
	var/jitter_strength = is_corner ? midpoint_jitter_px : max(1, round(midpoint_jitter_px * 0.5))
	if(jitter_strength <= 0)
		return base

	var/path_dx = next_turf.x - previous_turf.x
	var/path_dy = next_turf.y - previous_turf.y
	if(!path_dx && !path_dy)
		path_dx = in_dx
		path_dy = in_dy
	if(!path_dx && !path_dy)
		return base

	var/path_angle = delta_to_angle(path_dx, path_dy)
	var/perp_angle = path_angle + 90
	var/jitter = rand(-jitter_strength, jitter_strength)

	base["x"] += round(sin(perp_angle) * jitter)
	base["y"] += round(cos(perp_angle) * jitter)
	return base

/datum/hose_visual/proc/turf_center_point(turf/T)
	var/half_icon = round(world.icon_size * 0.5)
	return list(
		"x" = (world.icon_size * T.x) + half_icon,
		"y" = (world.icon_size * T.y) + half_icon,
		"z" = T.z,
	)

/datum/hose_visual/proc/draw_leg(start_x, start_y, end_x, end_y, z_level)
	var/dx = end_x - start_x
	var/dy = end_y - start_y
	var/length = round(sqrt((dx ** 2) + (dy ** 2)))
	if(length <= 0)
		return
	var/angle = delta_to_angle(dx, dy)
	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(angle)
	var/unit_x = sin(angle)
	var/unit_y = cos(angle)
	var/anchor_offset = max(0, round((world.icon_size * 0.5) - 1))

	for(var/N in 0 to length step segment_length_px)
		var/ratio = N / length
		var/anchor_x = round(start_x + (dx * ratio))
		var/anchor_y = round(start_y + (dy * ratio))
		var/point_x = round(anchor_x + (unit_x * anchor_offset))
		var/point_y = round(anchor_y + (unit_y * anchor_offset))

		var/tile_x = FLOOR(point_x / world.icon_size, 1)
		var/tile_y = FLOOR(point_y / world.icon_size, 1)
		tile_x = clamp(tile_x, 1, world.maxx)
		tile_y = clamp(tile_y, 1, world.maxy)

		var/turf/segment_turf = locate(tile_x, tile_y, z_level)
		if(!segment_turf)
			continue

		var/obj/effect/ehose/segment = new beam_type(segment_turf)
		segment.owner = src
		segment.icon = base_icon
		segment.transform = rot_matrix
		segment.pixel_x = point_x - (tile_x * world.icon_size)
		segment.pixel_y = point_y - (tile_y * world.icon_size)
		elements += segment
		CHECK_TICK

/datum/hose_visual/proc/position_changed(list/origin_point, list/target_point)
	if(isnull(last_origin_x) || isnull(last_target_x))
		return TRUE

	if(last_origin_x != origin_point["x"])
		return TRUE
	if(last_origin_y != origin_point["y"])
		return TRUE
	if(last_origin_z != origin_point["z"])
		return TRUE
	if(last_target_x != target_point["x"])
		return TRUE
	if(last_target_y != target_point["y"])
		return TRUE
	if(last_target_z != target_point["z"])
		return TRUE

	return FALSE

/datum/hose_visual/proc/cache_positions(list/origin_point, list/target_point)
	last_origin_x = origin_point["x"]
	last_origin_y = origin_point["y"]
	last_origin_z = origin_point["z"]
	last_target_x = target_point["x"]
	last_target_y = target_point["y"]
	last_target_z = target_point["z"]

/datum/hose_visual/proc/get_point_data(atom/A, turf/override_turf = null)
	if(QDELETED(A))
		return null

	var/turf/T = override_turf ? override_turf : get_turf(A)
	if(!istype(T))
		return null

	return list(
		"x" = (world.icon_size * T.x) + A.pixel_x,
		"y" = (world.icon_size * T.y) + A.pixel_y,
		"z" = T.z,
	)

/datum/hose_visual/proc/get_pixel_distance_from_points(list/origin_point, list/target_point)
	if(!origin_point || !target_point)
		return INFINITY
	if(origin_point["z"] != target_point["z"])
		return INFINITY

	var/dx = target_point["x"] - origin_point["x"]
	var/dy = target_point["y"] - origin_point["y"]
	return sqrt((dx ** 2) + (dy ** 2))

/datum/hose_visual/proc/get_predicted_pixel_distance(atom/movable/mover, turf/new_turf)
	var/turf/origin_override = null
	var/turf/target_override = null

	if(mover == origin)
		origin_override = new_turf
	else if(mover == target)
		target_override = new_turf

	var/list/origin_point = get_point_data(origin, origin_override)
	var/list/target_point = get_point_data(target, target_override)
	return get_pixel_distance_from_points(origin_point, target_point)

/obj/effect/ehose
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	plane = ABOVE_LIGHTING_PLANE
	layer = BEAM_PROJECTILE_LAYER
	blend_mode = BLEND_DEFAULT
	var/datum/hose_visual/owner

/obj/effect/ehose/tesla_act()
	return

/obj/effect/ehose/Destroy()
	owner = null
	return ..()

/atom/proc/Hose(atom/HoseTarget, icon_state = "hose", icon = 'icons/effects/beam.dmi', max_length_px = 160, time = -1, hose_type = /datum/hose_visual, hose_sleep_time = 1, datum/callback/limit_callback = null, segment_length_px = 5, preserve_path = TRUE)
	if(time >= INFINITY)
		crash_with("Tried to create hose with infinite time!")
		return null

	var/datum/hose_visual/new_hose = new hose_type(src, HoseTarget, icon, icon_state, max_length_px, time, /obj/effect/ehose, hose_sleep_time, limit_callback, segment_length_px, preserve_path)
	INVOKE_ASYNC(new_hose, TYPE_PROC_REF(/datum/hose_visual, Start))
	return new_hose
