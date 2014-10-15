14-TerrorTorch
==============

https://www.reBaked.com/projects/14

## Attention Collaborators

#### Either open an issue or respond to an issue before developing a feature. This way we avoid multiple branches working on the same thing.

=======
## UI Explanation
1.  On launch of app
  *  Show splash screen of logo for a few seconds
  *  Present the main screen

2.  Main screen
  *  Present a TerrorTorch logo in the nav.  When touched, the app should enter the About page.
  *  Present button (or similar) to enter the SoundBox
  *  Present button (or similar) to enter TerrorMode
  *  Show a single gallery of videos in reverse-chronological order.  Merge together:
      * Videos from our YouTube channel
      * Videos recorded on the device

3.  SoundBox - a sound box is a soundboard where it's possible to audition a few pre-selected types of sounds.
  *  Present 5 icons for each type of sound in the SoundBox
  *  Play the sound when the icon is tapped

4.  About view
  *  App configuration (if any is required)
  *  About
    *  Display the TerrorTorch logo
    *  Link to www.goldenviking.org
    *  Names of all of the people that worked on this app

5.  TerrorMode
  *  A button which starts a countdown to activating the mode.  This is to give the user enough time to place the device and get out of the view of the camera.
  *  When activated...
    1.  App will turn-on video camera.
    2.  App will detect when a significant number of pixels have changed on the video feed (and just assume it's a person).
    3.  App will start recording video camera.
    4.  App will play sounds.  Hopefully getting a reaction from the person or animal who walked into the frame.
    5.  App will stop recording after 10 seconds.
    6.  App will assist in uploading the video to YouTube.

## Vision and Purpose

**TerrorTorch's main draw is its TerrorMode.** 

When in TerrorMode, the user will select a sound and prop the phone to point its camera where an unsuspecting victim will walk by the camera.  The camera will detect a person walking into the frame, start recording video, then play the configured sound.  The intention is to startle the person walking into the frame and capture the experience.  Ideally then making it easy to post the video capture to YouTube.
