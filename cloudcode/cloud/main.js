// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
 
Parse.Cloud.define("hello", function(request, response){
	var firstname = request.params.firstname
	var lastname = request.params.lastname
	if(typeof firstname !== 'undefined' && typeof lastname !== 'undefined'){
		response.success("Hello " + firstname + " " + lastname + ", congratulations on sending a request to our TerrorTorch backend." );
	} else {
		response.error("I'm sorry I don't talk to strangers");
	}
});