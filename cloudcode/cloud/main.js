// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

const DEFAULTTAGS = [ 'Terror', 'Torch', 'TerrorTorch', 'GoldenViking', 'reBaked' ];
var Buffer = require('buffer').Buffer;

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

Parse.Cloud.define('getChannelInfo', function(request, response){
	Parse.Cloud.httpRequest({
		method:'GET',
		url: 'https://www.googleapis.com/youtube/v3/search',
		headers:{
			'Content-Type': 'application/json; charset=UTF-8'
		},
		params: {
			part: 'id, snippet',
			type: 'video',
			channelId: 'UCg-Hnkjq8eVT9CSSoot01uw',
			key: 'AIzaSyDU_5S6VMcAWdOmlq039dNAK2LYvA38WhA'
		},

		success: function(httpResponse){
			var items = httpResponse.data.items;
			response.success('Youtube channel has ' + items.length + ' videos.');
		},
		error: function(httpResponse){
			response.error(httpResponse.text);
		}
	});
});

var oauthRequest = {
	method: 'GET',
	url: 'https://accounts.google.com/o/oauth2/auth',
	params: {
		client_id: '925132976135-sue10lp4hf4httfgoakov3ic3dnqas4b.apps.googleusercontent.com',
		scope: 'https://www.googleapis.com/auth/youtube',
		response_type: 'code',
		redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
	}
}

Parse.Cloud.define('login_oAuth', function(request, response){
	Parse.Cloud.httpRequest(oauthRequest)
	.then(function(httpResponse){
		response.success(httpResponse.text);
	},function(httpResponse){
		response.error(httpResponse.text);
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
		request.object.set('isUploaded', false);
		response.success();
	}
});

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
	response.success();
});

function youtubeVideoRequest(params, buffer) {
	return {
		method:'POST',
		url: 'https://www.googleapis.com/upload/youtube/v3/videos',
		headers:{
			'Content-Type': 'application/octet-stream'
		},
		params: {
			part: 'id%2C+snippet',
			channelID: 'UCg-Hnkjq8eVT9CSSoot01uw',
			key: 'AIzaSyDU_5S6VMcAWdOmlq039dNAK2LYvA38WhA'
		},
		body: JSON.stringify({
			kind: 'youtube#video',
			snippet: {
				title: params['title'],
				description: params['description'],
				tags: DEFAULTTAGS
			},
			status: {
				privacyStatuse: 'public',
				embeddable: true,
				license: 'creativeCommon'
			}
		}),
		media_body: buffer
	};
}

Parse.Cloud.job('youtubeUpload', function(request, status) {
	var query = new Parse.Query('Video');

	query.equalTo('isUploaded', false);
	query.find().then(function(videos){
		var promises = [];

		videos.forEach(function(video){
			promises.push(Parse.Cloud.httpRequest({
					method:'GET',
					url: video.get('videoData').url(),
				}).then(function(httpResponse){
					var data = httpResponse.text;
					var buffer = new Buffer(data, 'base64');
					var params = { title: video.get('title'), description: video.get('description') };
					
					return Parse.Cloud.httpRequest(youtubeVideoRequest(params, buffer));	
				}, function(error){
					var reject = 'Failed to fetch video: ' + video.get('objectId') + ' with error:\n    ' + error;
					return Parse.Promise.error(reject);
				}).then(function(httpResponse){
					var success = 'Successfully published video with response:\n    ' + httpResponse.text;
					return Parse.Promise.as(success);
				}, function(httpResponse){
					var rejectmsg = 'Failed to publish video with error:\n     ' + httpResponse.text;
					return Parse.Promise.error(rejectmsg);
				})
			);
		});

		return Parse.Promise.when(promises);
	}).then(function(resolved){
		resolved.forEach(function(promise){
			console.log(promise);
		});
	},function(rejected){
		rejected.forEach(function(promise){
			console.log(promise);
		})
	}).always(function(test){
		console.log(test)
		status.success();
	});
});
