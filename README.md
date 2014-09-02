14-TerrorTorch
==============

https://www.reBaked.com/projects/14

## Attention Collaborators

#### Either open an issue or respond to an issue before developing a feature. This way we avoid multiple branches working on the same thing.

=======
## UI Explanation
1.  On launch of app
  *  Show splash screen of logo for a few seconds (thinking 3 seconds, but would like to experiment)
  *  Present the main screen

2.  Main screen
  * Light controls
    *  On / Off toggle
    *  Brightness
  *  Present button (or similar) to enter Sound boxes
  *  Present button (or similar) to enter Shop
  *  Present button (or similar) to enter Settings
  *  Present button (or similar) to enter TerrorMode

3.  Sound box - a sound box is a soundboard where it's possible to audition a few pre-selected types of sounds.
  *  Present 5 icons for each type of sound in the soundbox
  *  Play the sound when the icon is tapped

4.  Settings
  *  App configuration
  *  About
    *  Display the TerrorTorch logo
    *  Link to www.goldenviking.org
    *  Names of all of the people that worked on this app

5.  TerrorMode
  *  A button which starts a 15 sec countdown to activating the mode (the countown time value could be an app setting).  This is to give the user enough time to place the device and get out of the view of the camera.
  *  When activated...
    1.  App will turn-on video camera.
    2.  App will detect when a significant number of pixels have changed on the video feed (and just assume it's a person).
    3.  App will start recording video camera.
    4.  App will play sounds.  Hopefully getting a reaction from the person or animal who walked into the frame.
    5.  App will stop recording after 10 seconds.
    6.  App will assist in uploading the video to YouTube.  Possibly supporting other platforms as time permits.

========
## Parse Cloud Code

parsecloud.sh - Bash script for sending a simple command to our backend. Must be able to see and run utility.sh in order to execute correctly.

1.  Bash commands
  * setParseEnviroonment [appname]
    * spe
    * Can be configured to use different apps
  * parseFunction [function] [[key] [value]...]
    * pf
    * Currently supports String, boolean and numbers

2. Cloud functions
  * hello()
    * **Required**
      * firstname(String)
      * lastname(String)
  * createUser()
    * **Required**
      * username(String)
      * password(String)
      * email(String)
      * vendorID(String) //Will later be used to authenticate user's device
    * **Optional**
      * firstname(String)
      * lastname(String)

Example of use (in terminal):
```bash
 . ~/bash/parsecloud.sh
 spe terrortorch
   -> TerrorTorch environment set
 pf hello firstname Alfred lastname Cepeda
   -> Sending data: {"firstname":"Alfred","lastname":"Cepeda"}
   -> {"result":"Hello Alfred Cepeda, congratulations on sending a request to our TerrorTorch backend."}
```

## Vision and Purpose

**TerrorTorch's main draw is its TerrorMode.**  It is intended to be a single IAP to unlock the feature.

When in TerrorMode, the user will select a sound and prop the phone to point its camera where an unsuspecting victim will walk by the camera.  The camera will detect a person walking into the frame, start recording video, then play the configured sound.  The intention is to startle the person walking into the frame and capture the experience.  Ideally then making it easy to post the video capture to YouTube.

The soundboard and lighting features are meant to be the freebies.  Hoping the free features are enough to tempt the frugal users to at least install the app.
