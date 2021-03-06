script "ed_edTheUndying.ash"
import <ed_util.ash>
import <ed_equipment.ash>
import <ed_eudora.ash>
import <ed_preadventure.ash>

void ed_initializeSettings()
{
	set_property("ed_edSkills", -1);
	set_property("ed_semisub", "pantry");
	set_property("ed_lashes_day1", "");
	set_property("ed_lashes_day2", "");
	set_property("ed_lashes_day3", "");
	set_property("ed_lashes_day4", "");
	set_property("ed_lashes", "");
	set_property("ed_renenutet_day1", "");
	set_property("ed_renenutet_day2", "");
	set_property("ed_renenutet_day3", "");
	set_property("ed_renenutet_day4", "");
	set_property("ed_renenutet", "");
	set_property("ed_chasmBusted", "false");
	set_property("ed_renenutetBought", 0);
	set_property("ed_edCombatCount", 0);
	set_property("choiceAdventure1002", 1);
	set_property("ed_edDelayHauntedKitchen", "true");
	cli_execute("ccs null");
	cli_execute("set battleAction=custom combat script");
	cli_execute("mood apathetic");
	set_property("hpAutoRecoveryItems", "linen bandages");
	set_property("hpAutoRecovery", 0.0);
	set_property("hpAutoRecoveryTarget", 0.0);
}

void ed_initializeDay(int day)
{
	if(day == 1)
	{
		if(get_property("ed_day1_init") != "finished")
		{
			set_property("ed_renenutetBought", 0);
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}
			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter to Ed the Undying]), $item[Letter to Ed the Undying]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			equipBaseline();

			set_property("ed_day1_init", "finished");
		}
	}
	else if(day == 2)
	{
		if(get_property("ed_day2_init") == "")
		{
			equipBaseline();
			ovenHandle();
			set_property("ed_renenutetBought", 0);
			if((my_meat() > 500))
			{
				buyUpTo(1, $item[Hermit Permit]);
				cli_execute("hermit * clover");
			}
			set_property("ed_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("ed_day3_init") == "")
		{
			set_property("ed_renenutetBought", 0);
			if((my_meat() > 500))
			{
				buyUpTo(1, $item[Hermit Permit]);
				cli_execute("hermit * clover");
			}
			set_property("ed_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("ed_day4_init") == "")
		{
			set_property("ed_renenutetBought", 0);
			cli_execute("hermit * clover");
			set_property("ed_day4_init", "finished");
		}
	}
}

void createBurrito()
{
	if((my_daycount() == 2) && (eudora_current() == $item[Xi Receiver Unit]) && possessEquipment($item[Xiblaxian holo-wrist-puter]) && ((my_fullness() + 4) <= fullness_limit()) && (item_amount($item[Xiblaxian Circuitry]) >= 1) && (item_amount($item[Xiblaxian Polymer]) >= 1) && (item_amount($item[Xiblaxian Alloy]) >= 3))
	{
		if(item_amount($item[Xiblaxian 5D Printer]) == 0)
		{
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
				use(1, $item[Xiblaxian Cache Locator Simcode]);
			}
		}
		if(item_amount($item[Xiblaxian 5D Printer]) > 0)
		{
			int[item] canMake = eudora_xiblaxian();
			if(canMake contains $item[Xiblaxian Ultraburrito])
			{
				if(canMake[$item[Xiblaxian Ultraburrito]] > 0)
				{
					visit_url("shop.php?pwd=&whichshop=5dprinter&action=buyitem&quantity=1&whichrow=339", true);
				}
			}
		}
	}
}

boolean adjustEdHat(string goal)
{
	if(!possessEquipment($item[The Crown of Ed the Undying]))
	{
		return false;
	}
	int option = -1;
	goal = to_lower_case(goal);
	if(((goal == "muscle") || (goal == "bear")) && (get_property("edPiece") != "bear"))
	{
		option = 1;
	}
	else if(((goal == "myst") || (goal == "mysticality") || (goal == "owl")) && (get_property("edPiece") != "owl"))
	{
		option = 2;
	}
	else if(((goal == "moxie") || (goal == "puma")) && (get_property("edPiece") != "puma"))
	{
		option = 3;
	}
	else if(((goal == "ml") || (goal == "hyena")) && (get_property("edPiece") != "hyena"))
	{
		option = 4;
	}
	else if(((goal == "meat") || (goal == "item") || (goal == "items") || (goal == "drops") || (goal == "mouse")) && (get_property("edPiece") != "mouse"))
	{
		option = 5;
	}
	else if(((goal == "regen") || (goal == "regenerate") || (goal == "miss") || (goal == "dodge") || (goal == "weasel")) && (get_property("edPiece") != "weasel"))
	{
		option = 6;
	}

	if(option != -1)
	{
		visit_url("inventory.php?action=activateedhat");
		visit_url("choice.php?pwd=&whichchoice=1063&option=" + option, true);
		return true;
	}
	return false;
}

float edMeatBonus()
{
	if(have_skill($skill[Curse of Fortune]) && (item_amount($item[Ka Coin]) > 0))
	{
		return 200.0;
	}
	return 0.0;
}

boolean ed_doResting()
{
	if(!get_property("chateauAvailable").to_boolean() || get_property("timesRested").to_int() >= total_free_rests() || my_level() < 8 )
	{
		return false;
	}
	if(have_effect($effect[Prayer of Seshat]).to_int() >= 300)
	{
		return false;
	}
	
	if ((my_mp() + 110) < my_maxMP())
	{
	doRest();
	}
	
	if(monster_level_adjustment() > 50)
	{
		buffMaintain($effect[Hide of Sobek], 30, 3, 300);
	}
	buffMaintain($effect[Bounty of Renenutet], 30, 3, 300);
	buffMaintain($effect[Prayer of Seshat], 15, 3, 300);
	buffMaintain($effect[Wisdom of Thoth], 15, 3, 300);
	buffMaintain($effect[Power of Heka], 15, 3, 300);
	
	return true;
}

boolean ed_buySkills()
{
	if(my_level() <= get_property("ed_edSkills").to_int())
	{
		return false;
	}
	int possEdPoints = 0;
	int skillPoints = 0;
	
	string page = visit_url("place.php?whichplace=edbase&action=edbase_book");
	matcher my_skillPoints = create_matcher("You may memorize (\\d\+) more page", page);
	if(my_skillPoints.find())
	{
		skillPoints = to_int(my_skillPoints.group(1));
		if(skillPoints > 0)
		{
			print("Skill points found: " + skillPoints);
			possEdPoints += skillPoints;
		}
		possEdPoints = skillPoints - 1;
		
		if (skillpoints > 8) {
			while(skillPoints > 0)
			{
				skillPoints = skillPoints - 1;
				int skillid = 20;
				if(!have_skill($skill[Curse of Vacation]))
				{
					skillid = 19;
				}
				if(!have_skill($skill[Curse of Fortune]))
				{
					skillid = 18;
				}
				if(!have_skill($skill[Curse of Heredity]))
				{
					skillid = 17;
				}
				if(!have_skill($skill[Curse of Yuck]))
				{
					skillid = 16;
				}
				if(!have_skill($skill[Curse of Indecision]))
				{
					skillid = 15;
				}
				if(!have_skill($skill[Curse of the Marshmallow]))
				{
					skillid = 14;
				}
				if(!have_skill($skill[Wrath of Ra]))
				{
					skillid = 13;
				}
				if(!have_skill($skill[Lash of the Cobra]))
				{
					skillid = 12;
				}
				if(!have_skill($skill[Bounty of Renenutet]))
				{
					skillid = 6;
				}
				if(!have_skill($skill[Shelter of Shed]))
				{
					skillid = 5;
				}
				if(!have_skill($skill[Blessing of Serqet]))
				{
					skillid = 4;
				}
				if(!have_skill($skill[Hide of Sobek]))
				{
					skillid = 3;
				}
				if(!have_skill($skill[Power of Heka]))
				{
					skillid = 2;
				}
				if(!have_skill($skill[Purr of the Feline]))
				{
					skillid = 11;
				}
				if(!have_skill($skill[Storm of the Scarab]))
				{
					skillid = 10;
				}
				if(!have_skill($skill[Roar of the Lion]))
				{
					skillid = 9;
				}
				if(!have_skill($skill[Howl of the Jackal]))
				{
					skillid = 8;
				}
				if(!have_skill($skill[Wisdom of Thoth]))
				{
					skillid = 1;
				}
				if(!have_skill($skill[Fist of the Mummy]))
				{
					skillid = 7;
				}
				if(!have_skill($skill[Prayer of Seshat]))
				{
					skillid = 0;
				}

				visit_url("choice.php?pwd&skillid=" + skillid + "&option=1&whichchoice=1051");
			}
		} else {
			while(skillPoints > 0)
			{
				skillPoints = skillPoints - 1;
				int skillid = 20;
				if(!have_skill($skill[Curse of Vacation]))
				{
					skillid = 19;
				}
				if(!have_skill($skill[Curse of Fortune]))
				{
					skillid = 18;
				}
				if(!have_skill($skill[Curse of Heredity]))
				{
					skillid = 17;
				}
				if(!have_skill($skill[Curse of Yuck]))
				{
					skillid = 16;
				}
				if(!have_skill($skill[Curse of Indecision]))
				{
					skillid = 15;
				}
				if(!have_skill($skill[Curse of the Marshmallow]))
				{
					skillid = 14;
				}
				if(!have_skill($skill[Wrath of Ra]))
				{
					skillid = 13;
				}
				if(!have_skill($skill[Lash of the Cobra]))
				{
					skillid = 12;
				}
				if(!have_skill($skill[Purr of the Feline]))
				{
					skillid = 11;
				}
				if(!have_skill($skill[Storm of the Scarab]))
				{
					skillid = 10;
				}
				if(!have_skill($skill[Roar of the Lion]))
				{
					skillid = 9;
				}
				if(!have_skill($skill[Howl of the Jackal]))
				{
					skillid = 8;
				}
				if(!have_skill($skill[Bounty of Renenutet]))
				{
					skillid = 6;
				}
				if(!have_skill($skill[Shelter of Shed]))
				{
					skillid = 5;
				}
				if(!have_skill($skill[Blessing of Serqet]))
				{
					skillid = 4;
				}
				if(!have_skill($skill[Hide of Sobek]))
				{
					skillid = 3;
				}
				if(!have_skill($skill[Power of Heka]))
				{
					skillid = 2;
				}
				if(!have_skill($skill[Wisdom of Thoth]))
				{
					skillid = 1;
				}
				if(!have_skill($skill[Fist of the Mummy]))
				{
					skillid = 7;
				}
				if(!have_skill($skill[Prayer of Seshat]))
				{
					skillid = 0;
				}

				visit_url("choice.php?pwd&skillid=" + skillid + "&option=1&whichchoice=1051");
			}
		}
		
	}
	#adding this after skill purchase, is mafia not detecting our skills?
	visit_url("charsheet.php");
	
	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_imbuePoints = create_matcher("Impart Wisdom unto Current Servant ..100xp, (\\d\+) remain.", page);
	matcher my_servantPoints = create_matcher("You may release (\\d\+) more servant.", page);
	int imbuePoints = 0;
	int servantPoints = 0;
	if(my_imbuePoints.find())
	{
		imbuePoints = to_int(my_imbuePoints.group(1));
	}
	if(my_servantPoints.find())
	{
		servantPoints = to_int(my_servantPoints.group(1));
	}
	if(imbuePoints > 0)
	{
		print("Imbuement points found: " + imbuePoints);
		possEdPoints += imbuePoints;
	}
	if(servantPoints > 0)
	{
		print("Servant points found: " + servantPoints);
	}
	if(possEdPoints > get_property("edPoints").to_int())
	{
		set_property("edPoints", possEdPoints);
	}
	
	if(servantPoints > 0)
	{
		while(servantPoints > 0)
		{
			int sid = -1;
			if(!have_servant($servant[Maid]))
			{
				sid = 3;
			}
			if(!have_servant($servant[Cat]))
			{
				sid = 1;
			}
			if(!have_servant($servant[Scribe]))
			{
				sid = 5;
			}
			if(!have_servant($servant[Belly-Dancer]) && !have_skill($skill[lash of the cobra]))
			{
				sid = 2;
			}
			if(!have_servant($servant[Cat]) && !have_skill($skill[bounty of renenutet]))
			{
				sid = 1;
			}
			if(!have_servant($servant[Priest]))
			{
				sid = 6;
			}
			if(sid != -1)
			{
				visit_url("choice.php?whichchoice=1053&option=3&pwd&sid=" + sid);
			}
			
			servantPoints -= 1;
		}
	}

	if((imbuePoints > 0) && (my_level() > 2))
	{
		while(imbuePoints > 0)
		{
			servant tryImbue = $servant[none];
			if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
			{
				tryImbue = $servant[Priest];
			}
			else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441) && (imbuePoints > 4))
			{
				tryImbue = $servant[Scribe];
			}
			else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 300))
			{
				tryImbue = $servant[Cat];
			}
			else if(have_servant($servant[Belly-Dancer]) && ($servant[Belly-Dancer].experience < 81))
			{
				tryImbue = $servant[Belly-Dancer];
			}
			else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 221))
			{
				tryImbue = $servant[Scribe];
			}
			else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 221) && have_skill($skill[Curse of Fortune]))
			{
				tryImbue = $servant[Maid];
			}
			else
			{
				if((imbuePoints > 4) && (my_level() >= 9))
				{
					if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 341))
					{
						tryImbue = $servant[Scribe];
					}
				}
			}

			if(tryImbue != $servant[none])
			{
				if(use_servant(tryImbue))
				{
					print("Trying to imbue " + tryImbue + " with glorious wisdom!!", "green");
					visit_url("choice.php?whichchoice=1053&option=5&pwd=");
				}
			}
			
			imbuePoints -= 1;
		}
	}
	
	if((imbuePoints == 0) && (servantPoints == 0) && (skillPoints == 0))
		set_property("ed_edSkills", my_level());

	return true;
}

boolean ed_eatStuff()
{
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	int canDrink = inebriety_limit() - my_inebriety();
	int canOtherEat = fullness_limit() - my_fullness();
	if(canEat == 0 && canDrink == 0 && canOtherEat == 0)
	{
		return false;
	}
	
//Spleens	
	canEat = min(canEat, item_amount($item[Mummified Beef Haunch]));
	if(canEat > 0)
	{
		chew(canEat, $item[Mummified Beef Haunch]);
	}

	string cookie = get_counters("Fortune Cookie", 0, 200);
	if(cookie != "Fortune Cookie")
	{
		if(my_turncount() < 81)
		{
			return false;
		}
		if((my_meat() >= 500) && have_skill($skill[Replacement Liver]) && ((my_inebriety() == 0) || (my_inebriety() == 3)))
		{
			cli_execute("drink 1 lucky lindy");
		}
		else if((my_meat() >= 40) && have_skill($skill[Replacement Stomach]) && ((my_fullness() == 0) || (fullness_limit() - my_fullness() == 1)))
		{
			buy(1, $item[Fortune Cookie]);
			eat(1, $item[Fortune Cookie]);
		}
	}
	return false;
/*
//Eats
	if(get_property("ed_dickstab").to_boolean() && !get_property("_fancyHotDogEaten").to_boolean() && ((my_fullness() + 2) <= fullness_limit()) && (item_amount($item[Clan VIP Lounge Key]) > 0) && !have_skill($skill[Dog Tired]) && get_property("chateauAvailable").to_boolean())
	{
//We're going to make the assumption here that you keep your hot dog stand stocked properly in advance
		cli_execute("eat 1 sleeping dog");
		if(!get_property("_fancyHotDogEaten").to_boolean())
		{
			abort("Failed eating sleeping dog (eat it manually I suppose?)....");
		}
	}
	if((item_amount($item[Xiblaxian Ultraburrito]) > 0) && (fullness_limit() - my_fullness() > 3) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		createBurrito();
		eat(1, $item[Xiblaxian Ultraburrito]);
	}
	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && ((my_fullness() == 0) || (my_fullness() == 3)) && (fullness_limit() >= 2))
	{
		eat(1, $item[Limp Broccoli]);
	}
	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && (my_fullness() == 2) && (fullness_limit() >= 5) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		eat(1, $item[Limp Broccoli]);
	}
	if((my_level() >= 11) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0))
	{
		eat(1, $item[Astral Hot Dog]);
	}
	if((my_level() >= 9) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0) && (my_adventures() < 4))
	{
		eat(1, $item[Astral Hot Dog]);
	}
	if(((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Tasty Tart]) > 0) && (item_amount($item[Astral Hot Dog]) == 0) )
	{
		eat(3, $item[Tasty Tart]);
	}
	if(((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Tasty Tart]) > 0) && (my_adventures() < 4))
	{
		eat(3, $item[Tasty Tart]);
	}
	
//Drinks
	if(item_amount($item[Astral Pilsner]) > 0)
	{
		if((my_inebriety() < inebriety_limit()) && (my_level() > 9) && (my_adventures() < 8) && (canEat == 0))
		{
			drink(1, $item[Astral Pilsner]);
		}
	}
	
	return true;
*/
	
//EXPERIMENTAL!!!!!! Thanks DeadNed
//
//	record food2beat {
//	   item name;
//	   float goodness;
//	   int size;
//	};
//	 
//	food2beat [int] jerky;
//	 
//	int counter=0;
//	 
//	foreach it in get_inventory() {
//	if (it.fullness >0){
//			string a=it.adventures;
//			string [int] b=split_string(a,"-");
//			float c;
//			int i=0;
//			foreach thing in b{
//					c += b[thing].to_int();
//					i+=1;
//					}
//			float e=c/i;
//	 
//			int h=it.fullness;
//			float j=e/h;
//			if (j==0)
//					j=1;
//		   
//			jerky[counter].name=it;
//			jerky[counter].goodness=j;
//			jerky[counter].size=h;
//			counter +=1;
//	 
//			}
//	}
//	sort jerky by -value.goodness;
//	for key from 0 to 10
//			print(jerky[key].name+": "+to_string(jerky[key].goodness,"%.2f")+" adv/full ("+jerky[key].size+" fullness) "+jerky[key].name.adventures);
//	print(" ");
//	 
//	for i from 0 to 10 {
//			print(" ");
//			print("sim["+i+"]");
//			int turnsGen=0;
//			int stomachSpace= fullness_limit()-my_fullness();
//			while (stomachSpace>0){
//					int eat1=available_amount(jerky[i].name);
//					int eat2=stomachSpace/jerky[i].size; //can't eat half a jerky.
//					if (eat2>eat1)
//							eat2=eat1;
//					if (eat2 != 0){
//							print("you'd eat: "+eat2+" "+jerky[i].name+" if you could!");
//							stomachSpace -= (eat2 * jerky[i].size);
//							turnsGen += (eat2 * jerky[i].goodness*jerky[i].size);
//							print("remaining space:"+stomachSpace);
//							}
//					i+=1;
//			}
//	}
}

boolean ed_needShop()
{
	if(item_amount($item[Ka Coin]) < 10)
	{
		return false;
	}
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	if((canEat == 0) && (item_amount($item[Ka Coin]) < 20))
	{
		return false;
	}

	canEat = max(0, canEat - item_amount($item[Mummified Beef Haunch]));
//Skill limiter helps prevent overspending of Ka on other skills that are not as important as getting your edible organs on day 1
	skill limiter = $skill[Even More Elemental Wards];
	if(my_daycount() >= 2)
	{
		limiter = $skill[Healing Scarabs];
	}
	
	if((canEat == 0) && have_skill(limiter) && (item_amount($item[Linen Bandages]) >= 4) && (get_property("ed_renenutetBought").to_int() >= 7) && (item_amount($item[Holy Spring Water]) >= 1) && (item_amount($item[Talisman of Horus]) >= 1))
	{
		if((item_amount($item[Ka Coin]) > 30) && (item_amount($item[Spirit Beer]) == 0))
		{
			return true;
		}
		if((item_amount($item[Ka Coin]) > 30) && (item_amount($item[Sacramental Wine]) == 0))
		{
			return true;
		}
		if((item_amount($item[Ka Coin]) > 35) && !have_skill($skill[Upgraded Spine]))
		{
			return true;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (item_amount($item[Ka Coin]) > 30))
		{
			return true;
		}
		return false;
	}
	return true;
}


boolean ed_shopping()
{
	if(!ed_needShop())
	{
		return false;
	}
	print("Time to shop!", "green");
	wait(1);
	visit_url("choice.php?pwd=&whichchoice=1023&option=1", true);

	if(get_property("ed_breakstone").to_boolean())
	{
		visit_url("place.php?whichplace=edunder&action=edunder_hippy");
		visit_url("choice.php?pwd&whichchoice=1057&option=1", true);
		set_property("ed_breakstone", false);
	}
	
	int skillBuy = 0;
	int coins = item_amount($item[Ka Coin]);
	if(!have_skill($skill[Upgraded Legs]) && get_property("ed_legsbeforebread").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
			visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
			visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
			visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
		}
	}
	
	if((my_daycount() == 2) && !have_skill($skill[Even More Elemental Wards]) && my_spleen_use() >= 20)
	{
	
	}
	else
	{
		if(((my_spleen_use() + 5) <= spleen_limit()) && ((my_adventures() < 25) || have_skill($skill[More Elemental Wards])))
		{
			int canEat = (spleen_limit() - my_spleen_use()) / 5;
			canEat = canEat - item_amount($item[Mummified Beef Haunch]);
			while((coins >= 15) && (canEat > 0))
			{
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=428", true);
				print("Bought a mummified beef haunch!", "green");
				coins = coins - 15;
				canEat = canEat - 1;
			}
		}
	}
	
	if(!have_skill($skill[More Legs]) && get_property("ed_legsbeforebread").to_boolean())
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	} else if(!have_skill($skill[Extra Spleen]))
	{
		if(coins >= 5)
		{
			print("Buying Extra Spleen", "green");
			skillBuy = 30;
		}
	} else if(!have_skill($skill[Another Extra Spleen]))
	{
		if(coins >= 10)
		{
			print("Buying Another Extra Spleen", "green");
			skillBuy = 31;
		}
	} else if(!have_skill($skill[Upgraded Legs]) && !get_property("ed_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	} else if(!get_property("ed_dickstab").to_boolean() && (((item_amount($item[Holy Spring Water]) < 3) && (my_maxMP() < 80)) ||
	((item_amount($item[spirit beer]) < 3) && ((my_maxMP() < 180) && (my_maxMP() > 79))) || ((item_amount($item[sacramental wine]) < 3) && (my_maxMP() > 179))))
	{
		while((item_amount($item[Holy Spring Water]) < 3) && (coins > 1) && (my_maxMP() < 80))
		{
			print("Buying Holy Spring Water", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
			coins -= 1;
		}
		while((item_amount($item[spirit beer]) < 3) && (coins > 2) && (my_maxMP() < 180) && (my_maxMP() > 79))
		{
			print("Buying Spirit Beer", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
			coins -= 2;
		}
		while((item_amount($item[sacramental wine]) < 3) && (coins > 3) && (my_maxMP() > 179))
		{
			print("Buying Sacramental Wine", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=433", true);
			coins -= 3;
		}
	} else if(!have_skill($skill[More Legs]) && !get_property("ed_dickstab").to_boolean())
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	} else if(!have_skill($skill[Yet Another Extra Spleen]))
	{
		if(coins >= 15)
		{
			print("Buying Yet Another Extra Spleen", "green");
			skillBuy = 32;
		}
	} else if(!have_skill($skill[Replacement Stomach]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Stomach", "green");
			skillBuy = 28;
		}
	} else if(!have_skill($skill[Still Another Extra Spleen]))
	{
		if(coins >= 20)
		{
			print("Buying Still Another Extra Spleen", "green");
			skillBuy = 33;
		}
	} else if(!have_skill($skill[Just One More Extra Spleen]))
	{
		if(coins >= 25)
		{
			print("Buying Just One More Extra Spleen", "green");
			skillBuy = 34;
		}
	} else if(!have_skill($skill[Replacement Liver]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Liver", "green");
			skillBuy = 29;
		}
	} else if(!have_skill($skill[Elemental Wards]) && get_property("ed_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	} else if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{
		if(coins >= 30)
		{
			print("Buying Okay Seriously, This is the Last Spleen", "green");
			skillBuy = 35;
		}
	} else if((get_property("ed_renenutetBought").to_int() < 7) && (coins > 1))
	{
		while((get_property("ed_renenutetBought").to_int() < 7) && (coins > 1))
		{
			print("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			set_property("ed_renenutetBought", 1 + get_property("ed_renenutetBought").to_int());
			coins = coins - 1;
			if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
			{
				break;
			}
		}
	} else if(!have_skill($skill[Upgraded Legs]))
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	} else if(!have_skill($skill[More Legs]))
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	} else if(!have_skill($skill[Tougher Skin]) && (((my_daycount() > 1) && (coins > 20)) || (monster_level_adjustment() > 50)))
	{
		print("Buying Tougher Skin (10)", "green");
		skillBuy = 39;
	} else if(!have_skill($skill[Elemental Wards]))
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	} else if(!have_skill($skill[More Elemental Wards]))
	{
		if(coins >= 20)
		{
			print("Buying More Elemental Wards", "green");
			skillBuy = 45;
		}
	} else if(!have_skill($skill[Even More Elemental Wards]))
	{
		if(coins >= 30)
		{
			print("Buying Even More Elemental Wards", "green");
			skillBuy = 46;
		}
	} else if(have_skill($skill[Okay Seriously, This is the Last Spleen]) &&
	((item_amount($item[Linen Bandages]) < 4) || (item_amount($item[Talisman of Horus]) < 2) ||
	(item_amount($item[sacramental wine]) < 3) || ((item_amount($item[silk bandages]) < 3) && (my_level() > 11)) ||
	(item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2))
	{
		while((item_amount($item[Linen Bandages]) < 4) && (coins >= 4))
		{
			print("Buying Linen Bandages", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=429", true);
			#buy(1, $item[Linen Bandages]);
			coins -= 1;
		}
		while((item_amount($item[Talisman of Horus]) < 2) && (coins >= 5))
		{
			print("Buying Talisman of Horus", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=693", true);
			#buy(1, $item[Talisman of Horus]);
			coins -= 5;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (coins >= 30))
		{
			print("Buying Ancient Cure-all", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=435", true);
			coins -= 3;
		}
		while((item_amount($item[sacramental wine]) < 3) && (coins > 3))
		{
			print("Buying Sacramental Wine", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=433", true);
			coins -= 3;
		}
		while((item_amount($item[silk bandages]) < 3) && (coins > 5))
		{
			print("Buying Silk Bandages", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=431", true);
			coins -= 5;
		}
	} else if(!have_skill($skill[Upgraded Arms]) && (my_daycount() > 1) && (coins > 20))
	{
		print("Buying Upgraded Arms (20)", "green");
		skillBuy = 37;
	} else if(!have_skill($skill[Armor Plating]) && (my_daycount() > 1) && (coins > 20))
	{
		print("Buying Armor Plating (10)", "green");
		skillBuy = 40;
	} else if(!have_skill($skill[Upgraded Spine]) && (my_daycount() > 1) && (coins > 20))
	{
		print("Buying Upgraded Spine (20)", "green");
		skillBuy = 38;
	} else if((!have_skill($skill[Healing Scarabs])) && (my_daycount() > 1) && (coins > 20))
	{
		print("Buying Healing Scarabs", "green");
		skillBuy = 43;
	}

	if(skillBuy != 0)
	{
		visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
		visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
		visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
	}
	visit_url("place.php?whichplace=edunder&action=edunder_leave");
	visit_url("choice.php?pwd=&whichchoice=1024&option=1", true);
	return true;
}

boolean ed_handleAdventureServant(location loc)
{
//Default state (priest) and handling getting gifts
	if(!use_servant($servant[priest]))
	{
		return false;
	}
	use_servant($servant[Priest]);
	if(($servant[Scribe].experience == 441) && !have_skill($skill[Gift of the Scribe]) && have_servant($servant[Scribe]))
	{
		use_servant($servant[Scribe]);
	}
	if(($servant[Cat].experience == 441) && !have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]))
	{
		use_servant($servant[Cat]);
	}
	boolean reassign = false;
	if((my_daycount() > 1) && (my_level() > 10))
	{
		reassign = true;
	}
	if(reassign)
	{
		if((!have_skill($skill[Gift of the Scribe]) || (my_level() < 13)) && have_servant($servant[Scribe]))
		{
			use_servant($servant[Scribe]);
		}
		else if(!have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]) && !get_property("ed_galleryFarm").to_boolean())
		{
			use_servant($servant[Cat]);
		}
		else
		{
			use_servant($servant[Scribe]);
		}
	}

//Per location handling
	if((loc == $location[The Defiled Nook]) ||
		(loc == $location[The Haunted Library]) ||
		(loc == $location[The Haunted Laundry Room]) ||
		(loc == $location[The Haunted Wine Cellar]) ||
		(loc == $location[Oil Peak]) ||
		(loc == $location[The Hidden Bowling Alley]) ||
		(loc == $location[The Hidden Temple]) ||
		(loc == $location[A-Boo Peak]) ||
		(loc == $location[The Hidden Park]) && (get_property("relocatePygmyJanitor") == 25))
	{
		if(!use_servant($servant[Cat]))
		{
			if(!use_servant($servant[Scribe]))
			{
				use_servant($servant[Maid]);
			}
		}
	}
	if((loc == $location[The Dark Neck of the Woods]) ||
		(loc == $location[The Dark Heart of the Woods]) ||
		(loc == $location[The Dark Elbow of the Woods]))
	{
		if((get_property("ed_pirateoutfit") != "finished") && (get_property("ed_pirateoutfit") != "almost") && (item_amount($item[Hot Wing]) < 3))
		{
			if(!use_servant($servant[Cat]))
			{
				use_servant($servant[Scribe]);
			}
		}
		else
		{
			if(!use_servant($servant[Scribe]))
			{
				use_servant($servant[Cat]);
			}
		}
	}
	if((loc == $location[The Defiled Alcove]) ||
		(loc == $location[The Defiled Cranny]) ||
		(loc == $location[The Defiled Niche]) ||
		(loc == $location[The Haunted Bedroom]) ||
		(loc == $location[The Haunted Ballroom]) ||
		(loc == $location[The Haunted Billiards Room]) ||
		(loc == $location[The Haunted Kitchen]) ||
		(loc == $location[The Haunted Bathroom]) ||
		(loc == $location[The Haunted Library]) ||
		(loc == $location[The Haunted Gallery] && get_property("ed_galleryFarm").to_boolean()))
	{
		if(!use_servant($servant[Scribe]))
		{
			//use_servant($servant[Cat]);
		}
	}
	if(loc == $location[The Themthar Hills])
	{
		use_servant($servant[Maid]);
	}
//The cat is swapped in at the shrines while macheteing them because your servant still gets xp points and it usually still needs some at this point, also sparrows. :D
	if((loc == $location[Next To That Barrel With Something Burning In It]) ||
		(loc == $location[Out By That Rusted-Out Car]) ||
		(loc == $location[Over Where The Old Tires Are]) ||
		(loc == $location[Near an Abandoned Refrigerator]) ||
		(loc == $location[The Black Forest] && item_amount($item[reassembled blackbird]) == 0) ||
		(loc == $location[An Overgrown Shrine (Northwest)]) ||
		(loc == $location[An Overgrown Shrine (Northeast)]) ||
		(loc == $location[An Overgrown Shrine (Southwest)]) ||
		(loc == $location[An Overgrown Shrine (Southeast)]) ||
		(loc == $location[A Massive Ziggurat] && item_amount($item[stone triangle]) == 0))
	{
		use_servant($servant[Cat]);
	}
	
	return false;
}

boolean ed_preAdv(int num, location loc)
{
	set_location(loc);
	ed_handleAdventureServant(loc);
	ed_preadventure();
	
//Attempts to farm ultra-burrito ingredients if you have that option available
	if((have_equipped($item[Xiblaxian Holo-Wrist-Puter])) && (howLongBeforeHoloWristDrop() <= 1))
	{
		string area = loc.environment;
		item replace = $item[none];
		if((item_amount($item[Pirate Fledges]) > 0) && (can_equip($item[Pirate Fledges])))
		{
			replace = $item[Pirate Fledges];
		}

		# If we migrate all Ed workaround combats to the bypasser, we don't need to check main.php
		if(!contains_text(visit_url("main.php"), "Combat"))
		{
			if(loc == $location[Noob Cave])
			{
				equip($slot[acc3], replace);
				return true;
			}
			
			if((area == "indoor") && (item_amount($item[Xiblaxian Circuitry]) > 0))
			{
				equip($slot[acc3], replace);
			}
			else if((area == "outdoor") && (item_amount($item[Xiblaxian Polymer]) > 0))
			{
				equip($slot[acc3], replace);
			}
			else if((area == "underground") && (item_amount($item[Xiblaxian Alloy]) > 2))
			{
				equip($slot[acc3], replace);
			}
			else
			{
				print("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
			}
		}
	}

	return true;
}

boolean ed_ccAdv(int num, location loc, string option, boolean skipFirstLife)
{
	boolean status = false;
	if(option == "")
		option = "ed_edCombatHandler";
	if(!skipFirstLife)
	{
		ed_preAdv(num, loc);
	}
	
	while(num > 0)
	{
		set_property("autoAbortThreshold", "-10.0");
		num = num - 1;
		if(num > 1)
		{
			print("This fight and " + num + " more left.", "blue");
		}

		set_property("ed_disableAdventureHandling", "yes");
		set_property("ed_edCombatHandler", "");
		if(!skipFirstLife)
		{
			set_property("ed_edCombatStage", 0);
			print("Starting Ed Battle at " + loc, "blue");
			status = adv1(loc, 1, option);
			if(!status && (get_property("lastEncounter") == "Like a Bat Into Hell"))
			{
				set_property("ed_disableAdventureHandling", "no");
				abort("Either a\) We had a connection problem and lost track of the battle, or b\) we were defeated multiple times beyond our usual UNDYING. Manually handle the fight and rerun.");
			}
		}
		
		if(last_monster() == $monster[Crate])
		{
			abort("We went to the Noob Cave for reals... uh oh");
		}

		string page = visit_url("main.php");
		if(contains_text(page, "whichchoice value=1023"))
		{
			print("Ed has UNDYING once!" , "blue");
			if(!ed_shopping())
			{
				visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
			}
			set_property("ed_edCombatStage", 1);
			print("Ed returning to battle Stage 1", "blue");

			if(get_property("_edDefeats").to_int() == 0)
			{
				print("Monster defeated in initialization, aborting attempt.", "red");
				set_property("ed_edCombatStage", 0);
				set_property("ed_disableAdventureHandling", "no");
				cli_execute("ed_postadventure.ash");
				return true;
			}

			status = adv1(loc, 1, option);
			if(last_monster() == $monster[Crate])
			{
				abort("We went to the Noob Cave for reals... uh oh");
			}

			page = visit_url("main.php");
			if(contains_text(page, "whichchoice value=1023"))
			{
				print("Ed has UNDYING twice! Time to kick ass!" , "blue");
				visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
				set_property("ed_edCombatStage", 2);
				print("Ed returning to battle Stage 2", "blue");
				
				if(get_property("_edDefeats").to_int() == 0)
				{
					print("Monster defeated in initialization, aborting attempt.", "red");
					set_property("ed_edCombatStage", 0);
					set_property("ed_disableAdventureHandling", "no");
					cli_execute("ed_postadventure.ash");
					return true;
				}
				
				status = adv1(loc, 1, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}

				page = visit_url("main.php");
				
				if((contains_text(page, "whichchoice value=1023")) && (item_amount($item[rock band flyers]) == 1) && (get_property("flyeredML").to_int() < 10000) && (item_amount($item[ka coin]) > 2))
				{
					print("Ed has UNDYING thrice! Time to flyer ass!" , "blue");
					visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
					set_property("ed_edCombatStage", 3);
					print("Ed returning to battle Stage 3", "blue");

					if(get_property("_edDefeats").to_int() == 0)
					{
						print("Monster defeated in initialization, aborting attempt.", "red");
						set_property("ed_edCombatStage", 0);
						set_property("ed_disableAdventureHandling", "no");
						cli_execute("ed_postadventure.ash");
						return true;
					}
					
					status = adv1(loc, 1, option);
					if(last_monster() == $monster[Crate])
					{
						abort("We went to the Noob Cave for reals... uh oh");
					}

					page = visit_url("main.php");
					if(contains_text(page, "whichchoice value=1023"))
					{
						print("Ed has UNDYING fhrice?! Time to finish flyering ass!" , "blue");
						visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
						set_property("ed_edCombatStage", 4);
						print("Ed returning to battle Stage 4", "blue");
						
						if(get_property("_edDefeats").to_int() == 0)
						{
							print("Monster defeated in initialization, aborting attempt.", "red");
							set_property("ed_edCombatStage", 0);
							set_property("ed_disableAdventureHandling", "no");
							cli_execute("ed_postadventure.ash");
							return true;
						}
						
						status = adv1(loc, 1, option);
						if(last_monster() == $monster[Crate])
						{
							abort("We went to the Noob Cave for reals... uh oh");
						}

						page = visit_url("main.php");
						if(contains_text(page, "What? That's outrageous!"))
						{
							abort("Too many undeaths aren't good for you, pay up to continue.");
						}
					}
				}
				else if(contains_text(page, "What? That's outrageous!")) 
				{
					abort("Third deaths the toll, pay up if you wish to continue.");
				}
			}
		}
		
		set_property("ed_edCombatStage", 0);
		set_property("ed_disableAdventureHandling", "no");
		cli_execute("ed_postadventure.ash");
	}
	return status;
}