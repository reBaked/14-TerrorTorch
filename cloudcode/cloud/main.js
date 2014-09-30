// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

const DEFAULTTAGS = [ 'Terror', 'Torch', 'TerrorTorch', 'GoldenViking', 'reBaked' ];
const ACCESSTOKEN = 'ya29.jwCBVF_Az_MziK5DeUnUZaGkvPLRhFsH7Ls07RdHsEcdwAx5G1UZiwZD';
const DEVELOPERKEY = 'AI39si5N2umfI-AdQ5Hiz-48Bkr73yXBbY5_fZXYvN1tjVLAX8NU-IcwT9NjQAoEbkdjTR93IDFnz-lsEzV_wC8vv83zXLjg6g';
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
		client_id: '673341941039-qsut16q5jgn9qmrgofrh66n36ltr1nrs.apps.googleusercontent.com',
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
			access_token: ACCESSTOKEN
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

function youtubePublishRequest(params, buffer){
	var httpBody = '--f93dcbA3\n'+
				'Content-Type: application/atom+xml; charset=UTF-8\n\n'+
				'<?xml version="1.0"?>'+
				'<entry xmlns="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" xmlns:yt="http://gdata.youtube.com/schemas/2007">'+
					'<media:group>'+
					'<media:title type="plain">Bad Wedding Toast</media:title>'+
					'<media:description type="plain"> I gave a bad toast at my friend\'s wedding. </media:description>'+
					'<media:category scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People </media:category>'+
					'<media:keywords>toast, wedding</media:keywords>'+
					'</media:group>'+
				'</entry>\n'+
				'--f93dcbA3\n'+
				'Content-Type: application/octet-stream\n'+
				'Content-Transfer-Encoding: binary\n\n'+
				 buffer+'\n'+
				 '--f93dcbA3--\n';
	return {
		method:'POST',
		url: 'http://uploads.gdata.youtube.com/feeds/api/users/default/uploads',
		headers:{
			'Authorization': 'Bearer '+ACCESSTOKEN,
			'GData-Version': 2,
			'X-GData-Key': 'key='+DEVELOPERKEY,
			'Slug': 'TestVideo.mov',
			'Content-Type': 'multipart/related; boundary=f93dcbA3',
			'Content-Length': httpBody.length,
			'Connection': 'close'
		},
		body: httpBody
	}
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
					console.log("Attempting to publish video...")
					return Parse.Cloud.httpRequest(youtubePublishRequest(params, buffer));	
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
