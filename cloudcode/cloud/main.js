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
	var error = { 
		code:107,
		message:'Missing field(s):'
	}
	var failed = false;
	for(var i = 0; i < fields.length; i++){
		if(!isDefined(params[fields[i]])){
			error.message = error.message + ' ' + fields[i];
			failed = true;
		}	
	}

	if(failed){
		return {hasRequired:false, error:error};
	} else {
		return {hasRequired:true};
	}
}

function attemptLogin(params, callback){
	var result = new Parse.Promise();

	if(isDefined(params['sessiontoken'])){
		result = Parse.User.become(params.sessiontoken);
	} 

	else if(!isDefined(params['username']) && !isDefined(params['email'])){
		result = Parse.Promise.error({
			code:204,
			message:'Must provide a username or email'
		});
	} 

	else if(!isDefined(params['password'])){
		result = Parse.Promise.error({
			code:200,
			message:'Must provide a password or valid sessiontoken'
		});
	} 

	else {
		//Username or email must have been provided
		var loginname = (isDefined(params['username'])) ? params.username : params.email;
		result = Parse.User.logIn(params.username, params.password);
	}

	if(isDefined(callback)){
		if(isDefined(callback.success)){
			result.done(function(user){
				callback.success(user);
			});
		}

		if(isDefined(callback.error)){
			result.fail(function(error){
				callback.error(null, error);
			});
		}
	}

	return result;
} 

Parse.Cloud.define('hello', function(request, response){
	var firstname = request.params['firstname'];
	var lastname = request.params['lastname'];
	if(typeof firstname !== 'undefined' && typeof lastname !== 'undefined'){
		response.success('Hello ' + firstname + ' ' + lastname + ', congratulations on sending a request to our TerrorTorch backend.' );
	} else {
		response.error('I\'m sorry I don\'t talk to strangers');
	}
});

Parse.Cloud.define('createUser', function(request, response){
	var params = hasRequired(request.params, ['username', 'email', 'password', 'vendorid']);

	if(params.hasRequired == true){
		var user = new Parse.User();
		user.setUsername(request.params.username);
		user.setPassword(request.params.password);
		user.setEmail(request.params.email);
		user.set('vendorid',request.params.vendorid);

		setOptionals(user, request.params, ['firstname', 'lastname']);

		user.signUp(null, {
			success: function(user) {
   				response.success('Successfully created new user: ' + user.getUsername());
  			},
  			error: function(user, error) {
    			response.error(error.code + ' ' + error.message);
 			}
		});
	} else {
		response.error(params.error.code + ' ' + params.error.message);
	}
});

Parse.Cloud.define('loginUser', function(request, response){
	var params = hasRequired(request.params, ['username', 'password']);
	
	if(params.hasRequired){
		attemptLogin(request.params, {
			success: function(user){
				response.success({
					firstname:user.get('firstname'),
					lastname:user.get('lastname'),
					sessiontoken:user.getSessionToken()
				});
			}, 
			error: function(user, error){
				response.error(error.code + ' ' + error.message);
			}
		});
	} else {
		response.error(params.error.code + ' ' + params.error.message);
	}
});

Parse.Cloud.define('createVideo', function(request, response){
	var params = hasRequired(request.params, ['title', 'length']);
	var promise = Parse.Promise.as();

	if(!params.hasRequired){
		response.error(params.error.code + ' ' + params.error.message);
		return;
	}

	if(request.user == null){
		promise = attemptLogin(request.params);
	}

	promise.done(function(user){
		var VideoClass = Parse.Object.extend('Video');
		var video = new VideoClass();
		video.set('title', request.params.title);
		video.set('length', request.params.length);

		setOptionals(video, request.params, ['description', 'videoData']);

		video.save({
			success: function(video){
				response.success('Video was successfully saved');
			},
			error: function(video, error){
				response.error(error.code + ' ' + error.message);
			}
		});
	});

	promise.fail(function(error){
		response.error(error.code + ' ' + error.message);
	});	
});

Parse.Cloud.beforeSave('Video', function(request, response){
	if(request.master){
		response.success();
		return;
	}

	if(request.user == null){
		response.error('You must be authenticated before saving a video');
		return;
	}

	if(!request.object.get('title')){
		response.error('Video must have a title');
	} else {
		request.object.set('createdBy', request.user);
		response.success();
	}
})

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	response.success();
});
