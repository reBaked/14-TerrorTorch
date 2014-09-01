// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
 
Parse.Cloud.define("hello", function(request, response){
	var firstname = request.params['firstname'];
	var lastname = request.params['lastname'];
	if(typeof firstname !== 'undefined' && typeof lastname !== 'undefined'){
		response.success("Hello " + firstname + " " + lastname + ", congratulations on sending a request to our TerrorTorch backend." );
	} else {
		response.error("I'm sorry I don't talk to strangers");
	}
});

Parse.Cloud.define("createUser", function(request, response){
	var username = request.params['username'];
	var email = request.params['email'];
	var password = request.params['password'];
	var vendorID = request.params['vendorID'];

	var missingFields = "Missing"
	var failed = false;
	if(typeof username === 'undefined'){
		missingFields = missingFields + " username";
		failed = true;
	}

	if(typeof email === 'undefined') {
		missingFields = missingFields + " email";
		failed = true;
	}

	if(typeof password === 'undefined'){
		missingFields = missingFields + " password";
		failed = true;
	}

	if(typeof password === 'undefined'){
		missingFields = missingFields + " vendorId";
		failed = true;
	}

	if(failed){
		response.error(missingFields);
	} else {
		var user = new Parse.User();
		user.setUsername(username);
		user.setPassword(password);
		user.setEmail(email);
		user.set("vendorID",vendorID);
		user.signUp(null, {
			success: function(user) {
   				response.success();
  			},
  			error: function(user, error) {
    			response.error(error.code + " " + error.message);
 			}
		});
	}
});

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	if(!request.object.get("vendorID")){
		response.error("User's vendorId is required for signup");
	} else {
		response.success();
	}
});
