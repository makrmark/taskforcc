// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function show_details_tab(dom_id, tabname) {
	// first hide any displayed tabs
	$$(dom_id + " .task-details.tab").each(function(value, index) {
		value.removeClassName("active");
	});

	// then show the named tab
	$(dom_id + "_" + tabname).addClassName("active")

	// hide any active 'hide' links
	$$(dom_id + ".tab-link.active").each(function(value, index) {
		value.hide();		
	});
	
	// show the regular links
	$$(dom_id + ".tab-link").each(function(value, index) {
		value.hide();		
	});
	
}


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

/* show and hide the spinner when submitting a comment */
function show_comment_spinner(domid) {
	$(domid + "_comment_field").hide()
	$(domid + "_comment_spinner" ).show()	
}
function hide_comment_spinner(domid) {
	$(domid + "_comment_spinner" ).hide()
	$(domid + "_comment_field" ).show()
	
}