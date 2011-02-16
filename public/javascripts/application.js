// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// these functions used to set the active tab in the task details section
function set_details_tab_to_comments(domid) {	
	$(domid + "_description_tab").removeClassName("active");
	$(domid + "_comments_tab").addClassName("active");
	$(domid + "_description").hide();
	$(domid + "_comments").show();
}
function set_details_tab_to_description(domid) {	
	$(domid + "_comments_tab").removeClassName("active");
	$(domid + "_description_tab").addClassName("active");
	$(domid + "_comments").hide();
	$(domid + "_description").show();
}

// show and hide the topics menu for a task
// TODO: I think the menuname parameter is redundant here
// TODO: Use a seperate function to generate the ID for consistency
function toggle_tam_submenu(submenu, domid, menuname) {
	
	$$("ul.dir").each(function(value, index) {
		value.addClassName("inactive");
	});
	$(submenu + "_"+ menuname +"_" + domid).removeClassName("inactive");
	$(submenu + "_"+ menuname +"_" + domid).toggle();
	
}
