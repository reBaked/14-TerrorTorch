// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
function isDefined(arg){
	return (typeof arg !== 'undefined');
}

function setOptionals(object, params, fields){
	for(var i = 0; i < fields.length; i++){
		if(isDefined(params[fields[i]])){
			object.set(fields[i], params[fields[i]]);
		}
	}
}

function hasRequired(params, fields){
	var error = "Missing"
	var failed = false;
	for(var i = 0; i < fields.length; i++){
		if(!isDefined(params[fields[i]])){
			error = error + " " + fields[i];
			failed = true;
		}	
	}

	if(failed){
		var result = false;
		result.error = error;
		return result;
	} else {
		return true;
	}
}

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
	var meetsRequired = hasRequired(request.params, ['username', 'email', 'password', 'vendorID']);

	if(meetsRequired){
		var user = new Parse.User();
		user.setUsername(request.params['username']);
		user.setPassword(request.params['password']);
		user.setEmail(request.params['email']);
		user.set("vendorID",request.params['vendorID']);

		setOptionals(user, request.params, ['firstname', 'lastname']);

		user.signUp(null, {
			success: function(user) {
   				response.success();
  			},
  			error: function(user, error) {
    			response.error(error.code + " " + error.message);
 			}
		});
	} else {
		response.error(meetsRequired.error);
	}
});

Parse.Cloud.define("loginUser", function(request, response){
	var username = request.params['username'];
	var password = request.params['password'];

	var meetsRequired = hasRequired(request.params, ['username', 'password']);
	if(meetsRequired){
		Parse.User.logIn(request.params['username'], request.params['password'], {
			success: function(user){
				response.success({
					firstname:user.get('firstname'),
					lastname:user.get('lastname')
				});
			},
			error: function(user, error){
				response.error(error.code + " " + error.message);
			}
		})
	} else {
		response.error(meetsRequired.error);
	}
});



Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	if(!request.object.get("vendorID")){
		response.error("User's vendorId is required for signup");
	} else {
		response.success();
	}
});
