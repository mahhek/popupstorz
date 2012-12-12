function update_form_values(params){    
    var str = $.parseJSON(params);
    $("#searched_location").attr("value",str.location.toString());
    $("#searched_from").attr("value",str.search_from.toString());
    $("#searched_to").attr("value",str.search_to.toString());
}