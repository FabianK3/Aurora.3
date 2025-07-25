// Uniform slot
/datum/gear/uniform
	display_name = "kilt"
	path = /obj/item/clothing/under/kilt
	slot = slot_w_uniform
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/New()
	..()
	gear_tweaks += list(GLOB.gear_tweak_uniform_rolled_state)

/datum/gear/uniform/iacjumpsuit
	display_name = "IAC Jumpsuit"
	path = /obj/item/clothing/under/rank/iacjumpsuit
	allowed_roles = list("Chief Medical Officer", "Physician", "Surgeon", "Pharmacist", "Paramedic", "Medical Intern", "Medical Personnel")

/datum/gear/uniform/jumpsuit
	display_name = "generic jumpsuits"
	description = "A selection of generic colored jumpsuits."
	path = /obj/item/clothing/under/color/grey

/datum/gear/uniform/jumpsuit/New()
	..()
	var/list/jumpsuit = list()
	jumpsuit["black jumpsuit"] = /obj/item/clothing/under/color/black
	jumpsuit["grey jumpsuit"] = /obj/item/clothing/under/color/grey
	jumpsuit["white jumpsuit"] = /obj/item/clothing/under/color/white
	jumpsuit["dark red jumpsuit"] = /obj/item/clothing/under/color/darkred
	jumpsuit["red jumpsuit"] = /obj/item/clothing/under/color/red
	jumpsuit["light red jumpsuit"] = /obj/item/clothing/under/color/lightred
	jumpsuit["light brown jumpsuit"] = /obj/item/clothing/under/color/lightbrown
	jumpsuit["brown jumpsuit"] = /obj/item/clothing/under/color/brown
	jumpsuit["yellow jumpsuit"] = /obj/item/clothing/under/color/yellow
	jumpsuit["yellow green jumpsuit"] = /obj/item/clothing/under/color/yellowgreen
	jumpsuit["light green jumpsuit"] = /obj/item/clothing/under/color/lightgreen
	jumpsuit["green jumpsuit"] = /obj/item/clothing/under/color/green
	jumpsuit["aqua jumpsuit"] = /obj/item/clothing/under/color/aqua
	jumpsuit["light blue jumpsuit"] = /obj/item/clothing/under/color/lightblue
	jumpsuit["blue jumpsuit"] = /obj/item/clothing/under/color/blue
	jumpsuit["dark blue jumpsuit"] = /obj/item/clothing/under/color/darkblue
	jumpsuit["purple jumpsuit"] = /obj/item/clothing/under/color/purple
	jumpsuit["light purple jumpsuit"] = /obj/item/clothing/under/color/lightpurple
	jumpsuit["pink jumpsuit"] = /obj/item/clothing/under/color/pink
	jumpsuit["orange jumpsuit"] = /obj/item/clothing/under/color/orange
	gear_tweaks += new /datum/gear_tweak/path(jumpsuit)

/datum/gear/uniform/colorjumpsuit
	display_name = "jumpsuit (recolorable)"
	path = /obj/item/clothing/under/color/colorable
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/suit
	display_name = "suit selection"
	description = "A selection of formal suits."
	path = /obj/item/clothing/under/sl_suit

/datum/gear/uniform/suit/New()
	..()
	var/list/suits = list()
	suits["amish suit"] = /obj/item/clothing/under/sl_suit
	suits["black suit"] = /obj/item/clothing/under/suit_jacket
	suits["burgundy suit"] = /obj/item/clothing/under/suit_jacket/burgundy
	suits["charcoal suit"] = /obj/item/clothing/under/suit_jacket/charcoal
	suits["checkered suit"] = /obj/item/clothing/under/suit_jacket/checkered
	suits["executive suit"] = /obj/item/clothing/under/suit_jacket/really_black
	suits["navy suit"] = /obj/item/clothing/under/suit_jacket/navy
	suits["purple suit"] = /obj/item/clothing/under/lawyer/purple
	suits["red suit"] = /obj/item/clothing/under/suit_jacket/red
	suits["red lawyer suit"] = /obj/item/clothing/under/lawyer/red
	suits["tan suit"] = /obj/item/clothing/under/suit_jacket/tan
	suits["white suit"] = /obj/item/clothing/under/suit_jacket/white
	suits["nt skirtsuit"] = /obj/item/clothing/under/suit_jacket/nt_skirtsuit
	gear_tweaks += new /datum/gear_tweak/path(suits)

/datum/gear/uniform/scrubs
	display_name = "scrubs selection"
	path = /obj/item/clothing/under/rank/medical/surgeon/zavod
	allowed_roles = list("Scientist", "Research Intern", "Chief Medical Officer", "Physician", "Surgeon", "Pharmacist", "Paramedic", "Medical Intern", "Xenobiologist", "Research Director", "Investigator", "Medical Personnel", "Science Personnel")

/datum/gear/uniform/scrubs/New()
	..()
	var/list/scrubs = list()
	scrubs["scrubs, nanotrasen navy blue"] = /obj/item/clothing/under/rank/medical/surgeon
	scrubs["scrubs, zeng-hu purple"] = /obj/item/clothing/under/rank/medical/surgeon/zeng
	scrubs["scrubs, PMCG blue"] = /obj/item/clothing/under/rank/medical/surgeon/pmc
	scrubs["scrubs, PMCG grey"] = /obj/item/clothing/under/rank/medical/surgeon/pmc/alt
	scrubs["scrubs, zavodskoi black"] = /obj/item/clothing/under/rank/medical/surgeon/zavod
	scrubs["scrubs, idris green"] = /obj/item/clothing/under/rank/medical/surgeon/idris

	gear_tweaks += new /datum/gear_tweak/path(scrubs)

/datum/gear/uniform/colorable_scrubs
	display_name = "colorable scrubs"
	description = "It's made of a special fiber that provides minor protection against biohazards."
	path = /obj/item/clothing/under/rank/medical/generic
	allowed_roles = list("Scientist", "Research Intern", "Chief Medical Officer", "Physician", "Surgeon", "Pharmacist", "Paramedic", "Medical Intern", "Xenobiologist", "Research Director", "Investigator", "Medical Personnel", "Science Personnel")
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION | GEAR_HAS_ACCENT_COLOR_SELECTION

/datum/gear/uniform/dress
	display_name = "dress selection"
	description = "A selection of dresses."
	path = /obj/item/clothing/under/sundress

/datum/gear/uniform/dress/New()
	..()
	var/list/dress = list()
	dress["sundress"] = /obj/item/clothing/under/sundress
	dress["sundress, white"] = /obj/item/clothing/under/sundress_white
	dress["dress, flame"] = /obj/item/clothing/under/dress/dress_fire
	dress["dress, orange"] = /obj/item/clothing/under/dress/dress_orange
	dress["dress, yellow"] = /obj/item/clothing/under/dress/dress_yellow
	dress["dress, white"] = /obj/item/clothing/under/dress/white
	dress["dress, stripped"] = /obj/item/clothing/under/dress/stripeddress
	dress["dress, sailor"] = /obj/item/clothing/under/dress/sailordress
	dress["dress, red swept"] = /obj/item/clothing/under/dress/red_swept_dress
	dress["dress, black tango"] = /obj/item/clothing/under/dress/blacktango
	dress["dress, black tango alternative"] = /obj/item/clothing/under/dress/blacktango/alt
	dress["cheongsam, white"] = /obj/item/clothing/under/cheongsam
	dress["cheongsam, red"] = /obj/item/clothing/under/cheongsam/red
	dress["cheongsam, blue"] = /obj/item/clothing/under/cheongsam/blue
	dress["cheongsam, green"] = /obj/item/clothing/under/cheongsam/green
	dress["cheongsam, purple"] = /obj/item/clothing/under/cheongsam/purple
	gear_tweaks += new /datum/gear_tweak/path(dress)

/datum/gear/uniform/uniform_captain
	display_name = "uniform, captain dress"
	path = /obj/item/clothing/under/dress/dress_cap
	allowed_roles = list("Captain")

/datum/gear/uniform/bridge_crew
	display_name = "bridge crew uniform selection"
	path = /obj/item/clothing/under/rank/bridge_crew/alt
	allowed_roles = list("Bridge Crew", "Captain", "Executive Officer")

/datum/gear/uniform/bridge_crew/New()
	..()
	var/list/bridgecrew = list()
	bridgecrew["bridge crew uniform, skirt"] = /obj/item/clothing/under/rank/bridge_crew/alt
	bridgecrew["bridge crew uniform, skirt, white"] = /obj/item/clothing/under/rank/bridge_crew/alt/white
	bridgecrew["bridge crew uniform, san colettish"] = /obj/item/clothing/under/rank/bridge_crew/sancolette
	bridgecrew["bridge crew uniform, san colettish, blue"] = /obj/item/clothing/under/rank/bridge_crew/sancolette/alt
	gear_tweaks += new /datum/gear_tweak/path(bridgecrew)

/datum/gear/uniform/turtleneck
	display_name = "tacticool turtleneck"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/dominia
	display_name = "dominian suit selection"
	description = "A selection of Dominian suits."
	path = /obj/item/clothing/under/dominia
	flags = GEAR_HAS_DESC_SELECTION
	culture_restriction = list(/singleton/origin_item/culture/dominia, /singleton/origin_item/culture/dominian_unathi)

/datum/gear/uniform/dominia/New()
	..()
	var/list/suit = list()
	suit["dominian suit, red"] = /obj/item/clothing/under/dominia/imperial_suit
	suit["dominian suit, black"] = /obj/item/clothing/under/dominia/imperial_suit/black
	suit["strelitz dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/strelitz
	suit["volvalaad dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/volvalaad
	suit["kazhkz dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/kazhkz
	suit["han'san dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/hansan
	suit["caladius dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/caladius
	suit["zhao dominian suit"] = /obj/item/clothing/under/dominia/imperial_suit/zhao
	suit["lyodsuit"] = /obj/item/clothing/under/dominia/lyodsuit
	suit["hoodied lyodsuit"] = /obj/item/clothing/under/dominia/lyodsuit/hoodie
	gear_tweaks += new /datum/gear_tweak/path(suit)

/datum/gear/uniform/dominia_dress
	display_name = "dominian dress selection"
	description = "A selection of Dominian dresses."
	path = /obj/item/clothing/under/dominia/dress
	culture_restriction = list(/singleton/origin_item/culture/dominia, /singleton/origin_item/culture/dominian_unathi)

/datum/gear/uniform/dominia_dress/New()
	..()
	var/list/suit = list()
	for(var/dress in typesof(/obj/item/clothing/under/dominia/dress/noble))
		var/obj/item/clothing/under/dominia/dress/noble/D = new dress
		suit["[D.name]"] = D.type
	suit["dominia noble greatdress"] = /obj/item/clothing/under/dominia/dress
	for(var/dress in typesof(/obj/item/clothing/under/dominia/dress/fancy))
		var/obj/item/clothing/under/dominia/dress/D = new dress //I'm not typing all this shit manually. Jesus christ.
		suit["[D.name]"] = D.type
	gear_tweaks += new /datum/gear_tweak/path(suit)

/datum/gear/uniform/fisanduhian_sweater
	display_name = "fisanduhian sweater"
	path = /obj/item/clothing/under/dominia/sweater
	flags = GEAR_HAS_DESC_SELECTION
	culture_restriction = list(/singleton/origin_item/culture/dominia, /singleton/origin_item/culture/dominian_unathi)

/datum/gear/uniform/vysoka
	display_name = "vysokan temperwear"
	description = "A loose outfit of thinned and shredded ohdker fur."
	path = /obj/item/clothing/under/vysoka
	flags = GEAR_HAS_DESC_SELECTION
	origin_restriction = list(/singleton/origin_item/origin/vysoka, /singleton/origin_item/origin/ipc_vysoka)

/datum/gear/uniform/elyra_holo
	display_name = "elyran holographic suit selection"
	description = "A marvel of Elyran technology, uses hardlight fabric and masks to transform a skin-tight, cozy suit into cultural apparel of your choosing. Has a dial for Midenean, Aemaqii and Persepolis clothes respectively."
	path = /obj/item/clothing/under/elyra_holo
	flags = GEAR_HAS_DESC_SELECTION

/datum/gear/uniform/elyra_holo/New()
	..()
	var/list/suit = list()
	suit["elyran holographic suit, feminine"] = /obj/item/clothing/under/elyra_holo
	suit["elyran holographic suit, masculine"] = /obj/item/clothing/under/elyra_holo/masc
	gear_tweaks += new /datum/gear_tweak/path(suit)

/datum/gear/uniform/miscellaneous/kimono
	display_name = "kimono"
	path = /obj/item/clothing/under/kimono
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/circuitry
	display_name = "jumpsuit, circuitry (empty)"
	path = /obj/item/clothing/under/circuitry

/datum/gear/uniform/pyjama
	display_name = "pyjamas"
	path = /obj/item/clothing/under/pj/blue

/datum/gear/uniform/pyjama/New()
	..()
	var/list/pyjamas = list()
	pyjamas["blue pyjamas"] = /obj/item/clothing/under/pj/blue
	pyjamas["red pyjamas"] = /obj/item/clothing/under/pj/red
	gear_tweaks += new /datum/gear_tweak/path(pyjamas)

/datum/gear/uniform/miscellaneous/hanbok
	display_name = "hanbok selection"
	description = "A selection of Konyanger formalwear."
	path = /obj/item/clothing/under/konyang

/datum/gear/uniform/miscellaneous/hanbok/New()
	..()
	var/list/hanbok = list()
	hanbok["magenta-blue hanbok"] = /obj/item/clothing/under/konyang
	hanbok["white-pink hanbok"] = /obj/item/clothing/under/konyang/pink
	hanbok["white-blue hanbok"] = /obj/item/clothing/under/konyang/blue
	hanbok["male hanbok"] = /obj/item/clothing/under/konyang/male
	gear_tweaks += new /datum/gear_tweak/path(hanbok)

/datum/gear/uniform/miscellaneous/hanbokcolorable
	display_name = "colorable hanbok selection"
	description = "A selection of Konyanger formalwear."
	path = /obj/item/clothing/under/konyang/male/shortsleeve
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/miscellaneous/hanbokcolorable/New()
	..()
	var/list/hanbokcolorable = list()
	hanbokcolorable["short sleeve hanbok"] = /obj/item/clothing/under/konyang/male/shortsleeve
	hanbokcolorable["sleeveless hanbok"] = /obj/item/clothing/under/konyang/male/sleeveless
	gear_tweaks += new /datum/gear_tweak/path(hanbokcolorable)

/datum/gear/uniform/konyang
	display_name = "konyanger dress"
	path = /obj/item/clothing/under/konyangdress
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION

/datum/gear/uniform/konyangtraditional
	display_name = "traditional konyanger dress selection"
	description = "A selection of traditional Konyanger formal and religious wear."
	path = /obj/item/clothing/under/konyangdresstraditional
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION

/datum/gear/uniform/konyangtraditional/New()
	..()
	var/list/konyangtraditional = list()
	konyangtraditional["pink traditional konyanger dress"] = /obj/item/clothing/under/konyangdresstraditional
	konyangtraditional["green traditional konyanger dress"] = /obj/item/clothing/under/konyangdresstraditional/green
	konyangtraditional["blue traditional konyanger dress"] = /obj/item/clothing/under/konyangdresstraditional/blue
	konyangtraditional["national-colored traditional konyanger dress"] = /obj/item/clothing/under/konyangdresstraditional/national
	konyangtraditional["national-colored traditional konyanger dress with vest"] = /obj/item/clothing/under/konyangdresstraditional/national/vest
	gear_tweaks += new /datum/gear_tweak/path(konyangtraditional)

/datum/gear/uniform/zhongshan
	display_name = "zhongshan suit"
	path = /obj/item/clothing/under/zhongshan
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION

/datum/gear/uniform/gadpathur
	display_name = "gadpathurian fatigues"
	path = /obj/item/clothing/under/uniform/gadpathur
	flags = GEAR_HAS_DESC_SELECTION
	origin_restriction = list(/singleton/origin_item/origin/gadpathur)

/datum/gear/uniform/miscellaneous/qipao
	display_name = "qipao"
	path = /obj/item/clothing/under/qipao
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/miscellaneous/qipao/New()
	..()
	var/list/qipao = list()
	qipao["qipao"] = /obj/item/clothing/under/qipao
	qipao["slim qipao"] = /obj/item/clothing/under/qipao2
	gear_tweaks += new /datum/gear_tweak/path(qipao)

/datum/gear/uniform/miscellaneous/fetil_dress
	display_name = "fetil dress"
	description = "A flowing dress from the Fetil islands on Port Antillia, usually in either white or muted dark shades. Great for dancing."
	path = /obj/item/clothing/under/antillean
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/miscellaneous/fetil_dress/New()
	..()
	var/list/fetil_dress = list()
	fetil_dress["fetil dress, red flairs"] = /obj/item/clothing/under/antillean
	fetil_dress["fetil dress, gold flairs"] = /obj/item/clothing/under/antillean/goldflair
	gear_tweaks += new /datum/gear_tweak/path(fetil_dress)

/datum/gear/uniform/miscellaneous/galatea_uniform
	display_name = "galatean uniform"
	description = "A work uniform often worn by citizens of the Federal Technology of Galatea."
	path = /obj/item/clothing/under/galatea
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION
	origin_restriction = list(/singleton/origin_item/origin/galatea)

/datum/gear/uniform/miscellaneous/dress_colorable
	display_name = "dress selection (colorable)"
	path = /obj/item/clothing/under/dress/colorable
	flags = GEAR_HAS_NAME_SELECTION | GEAR_HAS_DESC_SELECTION | GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/miscellaneous/dress_colorable/New()
	..()
	var/list/dress_colorable = list()
	dress_colorable["strapless midi dress"] = /obj/item/clothing/under/dress/colorable
	dress_colorable["sleeveless A-line dress"] = /obj/item/clothing/under/dress/colorable/sleeveless
	dress_colorable["longsleeve A-line dress"] = /obj/item/clothing/under/dress/colorable/longsleeve
	dress_colorable["evening gown"] = /obj/item/clothing/under/dress/colorable/evening_gown
	dress_colorable["tea-length dress"] = /obj/item/clothing/under/dress/colorable/tea_dress
	dress_colorable["open-shoulder dress"] = /obj/item/clothing/under/dress/colorable/open_shoulder
	dress_colorable["asymmetric dress"] = /obj/item/clothing/under/dress/colorable/asymmetric

	gear_tweaks += new /datum/gear_tweak/path(dress_colorable)

/*
	Uniform Rolled State Adjustment
*/

#define UNIFORM_UNROLLED "Unrolled"
#define UNIFORM_ROLLED_SLEEVES "Rolled Sleeves"
#define UNIFORM_ROLLED_DOWN "Rolled Down"

GLOBAL_DATUM_INIT(gear_tweak_uniform_rolled_state, /datum/gear_tweak/uniform_rolled_state, new())

/datum/gear_tweak/uniform_rolled_state/get_contents(var/metadata)
	return "Rolled State: [metadata]"

/datum/gear_tweak/uniform_rolled_state/get_default()
	return UNIFORM_UNROLLED

/datum/gear_tweak/uniform_rolled_state/get_metadata(var/user, var/metadata, var/gear_path)
	var/list/possible_states = list(UNIFORM_UNROLLED)
	var/obj/item/clothing/under/uniform = gear_path

	var/rolled_sleeves_state = initial(uniform.rolled_sleeves)
	var/rolled_down_state = initial(uniform.rolled_down)

	var/icon/under_icon = INV_W_UNIFORM_DEF_ICON
	if(rolled_sleeves_state == -1 || rolled_down_state == -1)
		if(initial(uniform.contained_sprite))
			under_icon = initial(uniform.icon)
		else if(initial(uniform.icon_override))
			under_icon = initial(uniform.icon_override)

	if(rolled_sleeves_state != -1 || ("[initial(uniform.icon_state)]_r[initial(uniform.contained_sprite) ? "_un" : "_s"]" in icon_states(under_icon)))
		possible_states += UNIFORM_ROLLED_SLEEVES

	if(rolled_down_state != -1 || ("[initial(uniform.icon_state)]_d[initial(uniform.contained_sprite) ? "_un" : "_s"]" in icon_states(under_icon)))
		possible_states += UNIFORM_ROLLED_DOWN

	var/input = tgui_input_list(user, "Choose in which state you want your uniform to spawn in.", "Uniform State", possible_states, metadata)

	if(!input)
		input = metadata
	return input


/datum/gear_tweak/uniform_rolled_state/tweak_item(var/obj/item/clothing/under/uniform, var/metadata, var/title, var/gear_path)
	if(!istype(uniform))
		return

	if(uniform.rolled_sleeves != -1)
		uniform.rolled_sleeves = metadata == UNIFORM_ROLLED_SLEEVES ? TRUE : FALSE
	if(uniform.rolled_down != -1)
		uniform.rolled_down = metadata == UNIFORM_ROLLED_DOWN ? TRUE : FALSE

	if(uniform.rolled_sleeves == 1)
		uniform.handle_rollsleeves()
	if(uniform.rolled_down == 1)
		uniform.handle_rollsuit()

#undef UNIFORM_UNROLLED
#undef UNIFORM_ROLLED_SLEEVES
#undef UNIFORM_ROLLED_DOWN
