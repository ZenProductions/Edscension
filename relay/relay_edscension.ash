// Thanks to relay_bumcheekascend.ash for a starting point here.

record setting {
	string name;
	string type;
	string condition;
	string description;
	string value;
};

setting[int] s;
string[string] fields;
boolean success;

void handleSetting(int x)
{
	string color = "white";
	switch(s[x].condition)
	{
	case "ANY":		color = "#00ffff";		break;
	case "PRE":		color = "#ffff00";		break;
	case "POST":	color = "#00ff00";		break;
	case "ACTION":	color = "#af6fbf";		break;
	default:		color = "#ffffff";		break;
	}
	switch(s[x].type)
	{
	case "boolean":
		write("<tr bgcolor="+color+"><td align=center>"+s[x].name+"</td><td align=center><select name='"+s[x].name+"'>");
		if(get_property(s[x].name) == "true")
		{
			write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
		}
		else
		{
			write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
		}
		writeln("</td><td>"+s[x].description+"</td></tr>");
		break;
	default:
		writeln("<tr bgcolor="+color+"><td align=center>"+s[x].name+"</td><td><input type='text' name='"+s[x].name+"' value='"+get_property(s[x].name)+"' /></td><td>"+s[x].description+"</td></tr>");
		break;
	}
	writeln("<input type='hidden' name='"+s[x].name+"_didchange' value='"+get_property(s[x].name)+"' />");
}

void generateTrackingData(string tracked, boolean hasSkill)
{
	int day = 0;
	string[int] tracking = split_string(get_property(tracked), ",");
	foreach x in tracking
	{
		if(tracking[x] == "")
		{
			continue;
		}
		matcher paren = create_matcher("[()]", tracking[x]);
		tracking[x] = replace_all(paren, "");
		string[int] current = split_string(tracking[x], ":");
		int curDay = to_int(current[0]);
		string enemy = current[1];

		string skillUsed = "";
		int turns = 0;

		if(hasSkill)
		{
			skillUsed = current[2];
			turns = to_int(current[3]);
		}
		else
		{
			turns = to_int(current[2]);
		}
		if(curDay > day)
		{
			day = curDay;
			if(day > 1)
			{
				writeln("<br><br>");
			}
			writeln("Day " + day + ": ");
		}
		if(hasSkill)
		{
			writeln("(" + enemy + ":" + skillUsed + ":" + turns + "), ");
		}
		else
		{
			writeln("(" + enemy + ":" + turns + "), ");
		}
	}
}

void write_styles()
	{
	writeln("<style type='text/css'>"+			
			"body {"+
			"width: 75%;"+
			"margin: auto;"+
			"background: #EAEAEA;"+
			"text-align:center;"+
			"padding:0;"+
			"cursor:default;"+
			"user-select: none;"+
			"-webkit-user-select: none;"+
			"-moz-user-select: text;}"+
			
			"heading {"+
				"font-family:times;"+
				"font-size:425%;"+
				"color:#000;}"+
			"</style>");
	}

void main()
{
	write_styles();
	writeln("<html><head><br><title>Edscension Multi-Variable Manager</title></head>");
	writeln("<body><heading>Edscension Multi-Variable Manager</heading><br><br>");

	file_to_map("ed_ascend_settings.txt", s);

	boolean dickstab = false;

	fields = form_fields();
	if(count(fields) > 0)
	{
		foreach x in fields
		{
			if(contains_text(x, "_didchange"))
			{
				continue;
			}

			string oldSetting = form_field(x + "_didchange");
			if(oldSetting == fields[x])
			{
				if(get_property(x) != fields[x])
				{
					writeln("You did not change setting " + x + ". It changed since you last loaded the page, ignoring.<br>");
				}
				continue;
			}

			if(x == "ed_dickstab")
			{
				if((fields[x] != get_property("ed_dickstab")) && (fields[x] == "true"))
				{
					dickstab = true;
				}
			}
			if(get_property(x) != fields[x])
			{
				writeln("Changing setting " + x + " to " + fields[x] + "<br>");
				set_property(x, fields[x]);
			}
		}
	}

	if(dickstab)
	{
		writeln("ed_dickstab was just set to true<br>");
		writeln("Your warranty has been declared void.<br>");
		set_property("ed_voidWarranty", "rekt");
		writeln("Togging incompatible settings. You can re-enabled them here if you so desire. This resetting only takes effect upon setting ed_dickstab to true.<br><br>");
		if(!get_property("ed_edDelayHauntedKitchen").to_boolean())
		{
			set_property("ed_edDelayHauntedKitchen", true);
			writeln("Enabled ed_edDelayHauntedKitchen.<br>");
		}
	}

	writeln("<form action='' method='post'>");
	writeln("<table><tr><th width=20%>Setting</th><th width=20%>Value</th><th width=60%>Description</th></tr>");

	foreach x in s
	{
		if(s[x].condition != "ANY")
		{
			continue;
		}
		handleSetting(x);
	}
	foreach x in s
	{
		if(s[x].condition != "PRE")
		{
			continue;
		}
		handleSetting(x);
	}
	foreach x in s
	{
		if(s[x].condition != "POST")
		{
			continue;
		}
		handleSetting(x);
	}
	foreach x in s
	{
		if(s[x].condition != "ACTION")
		{
			continue;
		}
		handleSetting(x);
	}

	writeln("<tr><td align=center colspan='3'><input type='submit' name='' value='Save Changes'/></td></tr></table></form>");
	writeln("<table><tr><th>Settings Color Codings</th></tr>");
	writeln("<tr bgcolor=#00ffff><td>Anytime: This setting can be changed at any time and takes effect immediately.</td></tr>");
	writeln("<tr bgcolor=#ffff00><td>Pre: This setting takes effect on the next run that is started with the script.</td></tr>");
	writeln("<tr bgcolor=#00ff00><td>Post: This setting is set by the first run of the script but can be overrode after that. Translation: Run script on day 1, after first adventure, set these however you like.</td></tr>");
	writeln("<tr bgcolor=#af6fbf><td>Action: This causes something to immediately (or when reasonable) happen.</td></tr>");
	writeln("</table>");

	writeln("<h2>Banishes</h2>");
	generateTrackingData("ed_banishes", true);

	writeln("<h2>Yellow Rays <img src=\"images/itemimages/eyes.gif\"></h2>");
	generateTrackingData("ed_yellowRays", true);

	writeln("<h2>Sniffing</h2>");
	generateTrackingData("ed_sniffs", true);

	writeln("<h2>Lash of the Cobra <img src=\"images/itemimages/cobrahead.gif\"></h2>");
	generateTrackingData("ed_lashes", false);

	writeln("<h2>Talisman of Renenutet <img src=\"images/itemimages/tal_r.gif\"></h2>");
	generateTrackingData("ed_renenutet", false);

	writeln("<h2>Info</h2>");
	writeln("Ascension: " + my_ascensions() + "<br>");
	writeln("Day: " + my_daycount() + "<br>");
	writeln("Turns Played: " + my_turncount() + "<br>");
	writeln("Combats: " + get_property("ed_edCombatCount") + "<br>");
	writeln("Version: " + svn_info("edscension").last_changed_rev + "<br>");
	writeln("</body></html>");
}