---
title: "How to build a VTubing app with Amazon IVS and VRoid"
description: "A step by step guide to set up a 3D virtual avatar that follows your body movements and leverage live streaming from Amazon IVS to broadcast to a large audience."
tags:
  - tutorials
  - aws
  - amazon-ivs
  - vtubing
  - vroid
  - pixiv
images:
  thumbnail: images/vtubing-ivs-demo.gif
  banner: images/vtubing-ivs-demo.gif
  hero: images/vtubing-ivs-demo.gif
  background: images/vtubing-ivs-demo.gif
authorGithubAlias: tonyv
authorName: Tony Vu
date: YYYY-MM-DD
---

Have you ever wanted to express yourself in a more imaginative way under the guise of a virtual character? Imagine if you could create or summon a virtual avatar of your liking, have it mimic your body movements on camera, and stream to thousands. In this tutorial, you will learn how to do just that by creating your own VTubing app.

Virtual YouTubing, or V-Tubing for short, is the practice among live streamers of using virtual avatars to either present their brand, their personality, or their identity through means outside of a face cam.

With that context set, I will walk you through a step by step process of building a web app to load a 3D character from VRoid Hub, animate it based on your body movements, and live stream to Amazon IVS. [VRoid Hub](https://hub.vroid.com/en) is an online platform created by Pixiv used to host and share 3D character models. You will be using the VRoid Hub API to import a digital character from VRoid Hub and use it as your avatar. The Three VRM SDK from Pixiv will be used for rendering the digital character. To have your avatar animate and mimic your body movements, you will be using the MediaPipe Holistic library and [Kalidokit](https://github.com/yeemachine/kalidokit).

> The code for this tutorial is available on [Github](#). You can also try a [live demo](https://dev.d218eir1ybnzul.amplifyapp.com/) of this web app.

## What you will learn

- How to import virtual characters from VRoid Hub
- How to animate a virtual character with your own body movements
- How to live stream your virtual character to Amazon IVS

| Attributes          |                                                                                                                                |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| ✅ AWS Level        | Intermediate - 200                                                                                                             |
| ⏱ Time to complete  | 15 minutes                                                                                                                     |
| 💰 Cost to complete | Free when using the AWS Free Tier or USD 1.01                                                                                  |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/)<br>- [Pixiv Account](https://accounts.pixiv.net/signup) <br> |
| 💻 Code Sample      | Code sample used in tutorial on [GitHub](#)                                                                                    |
| 📢 Feedback         | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?              |
| ⏰ Last Updated     | YYYY-MM-DD                                                                                                                     |

| ToC |
| --- |

## Solution Overview

This tutorial consists of 4 parts:

- Part 1 - Integrating with the VRoid Hub API and loading an avatar
- Part 2 - Rendering a virtual character with the three VRM SDK
- Part 3 - Animating a virtual character with your own body movements
- Part 4 - Live stream your virtual character to Amazon IVS

For brevity, this tutorial will only focus on the key steps needed to load, animate, and live stream your virtual avatar. The complete code example can be found on [Github](#).

## Part 1 - Integrating with the VRoid Hub API and loading an avatar

First, [sign up for a Pixiv account](https://accounts.pixiv.net/signup) and follow the [VRoid Hub quick start guide](https://developer.vroid.com/en/api/quick-start.html) to create an application. Once you create an application, you can reference the [code sample](https://github.com/pixiv/VRoidHub-API-Example) provided by Pixiv that demonstrates how to download a character on the VRoid Hub as a VRM file. VRM is a file format for handling 3D character models. For this tutorial, we have created our own 3D character using [VRoid Studio](https://vroid.com/en/studio). VRoid Studio is a 3D character creator tool that lets you export VRM files locally or upload them to VRoid Hub to share with the public. After creating our 3D character, we have saved it in VRM format and made it available [here](https://d1l5n2avb89axj.cloudfront.net/avatar-first.vrm) for use in this tutorial and [on VRoid Hub here](https://hub.vroid.com/en/characters/1692004541821223967/models/6410417122824343972).

## Part 2 - Rendering a virtual character with the three VRM SDK

The next step is to render your digital character, represented in a VRM file, onto a canvas. To render VRM files onto a canvas, we will be using the [Three-VRM](https://github.com/pixiv/three-vrm) library and its prerequisites including [Three.js](https://github.com/mrdoob/three.js/) and [GLTFLoader](https://threejs.org/docs/#examples/en/loaders/GLTFLoader). Three.js is a popular JavaScript 3D library.GLFTLoader is a component in Three.js for loading 3D models in glTF (GL Transmission Format) format, which is a standard file format for three-dimensional scenes and models. We will also be using a Three.js add-on called [OrbitControls](https://threejs.org/docs/#examples/en/controls/OrbitControls) to allow us to rotate the view of our avatar when we rotate it.

Create the HTML in an index.html and include the scripts for these libraries as follows.

```html
<script src="https://unpkg.com/three@0.133.0/build/three.js"></script>
<script src="https://unpkg.com/three@0.133.0/examples/js/loaders/GLTFLoader.js"></script>
<script src="https://unpkg.com/@pixiv/three-vrm@0.6.7/lib/three-vrm.js"></script>
<script src="https://unpkg.com/three@0.133.0/examples/js/controls/OrbitControls.js"></script>
```

After importing these libraries, let’s use the Three.js library to load a [scene object](https://threejs.org/docs/#api/en/scenes/Scene). A scene is used in Three.js to load in our 3D character or avatar. You will then use the [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer) provided by Three.js to to actually display the scene. Using the renderer object created from WebGLRenderer, we dynamically add a canvas element to our HTML. This canvas element will be used to render the scene and our avatar.

```javascript
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
document.body.appendChild(renderer.domElement);
```

Next, let's load our digital character into the scene using the VRM file retrieved from the VRoid Hub API earlier. In the following code snippet, we use the Three-VRM library and GLTFLoader from Three.js to do just that.

```javascript
// Load our 3D character from a VRM file via a Cloudfront distribution
const loader = new THREE.GLTFLoader();
loader.crossOrigin = "anonymous";
loader.load(
  // Replace this with the URL to your own VRM file
  "https://d1l5n2avb89axj.cloudfront.net/avatar-first.vrm",

  (gltf) => {
    THREE.VRMUtils.removeUnnecessaryJoints(gltf.scene);

    THREE.VRM.from(gltf).then((vrm) => {
      scene.add(vrm.scene);
      currentVrm = vrm;
      currentVrm.scene.rotation.y = Math.PI;
    });
  },

  (progress) => console.log("Loading model...", 100.0 * (progress.loaded / progress.total), "%"),

  (error) => console.error(error)
);
```

## Part 3 - Animating a virtual character with your own body movements

To start animating your virtual character, install the [Kalidokit](https://github.com/yeemachine/kalidokit) and [MediaPipe Holistic](https://github.com/google/mediapipe/blob/master/docs/solutions/holistic.md) libraries. MediaPipe Holistic is a computer vision pipeline used to track a user’s body movements, facial expressions, and hand gestures. This is useful for animating your digital avatar to mimic your own movements. Kalidokit includes the use of blendshapes for facial animation and kinematics solvers for body movements to create more realistic digital avatars. Blendshapes are a technique used in character animation to create a wide range of facial animations. Kinematics solvers are algorithms used to calculate the position and orientation of an avatar’s limbs. When making our avatar animate, aka character rigging, a kinematics solver helps determine how a character’s joints and bones should move to achieve a desired pose or animation. In short, Mediapipe Holistic tracks your physical movements while Kalidokit takes those as inputs to animate your avatar.

```html
<script src="https://cdn.jsdelivr.net/npm/@mediapipe/holistic@0.5.1635989137/holistic.js" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/kalidokit@1.1/dist/kalidokit.umd.js"></script>
```

Now let’s add code for our character rigging logic and create the animateVRM function. The animateVRM function will be used to get landmark data from MediaPipe Holistic passed in via the results argument. In the context of rigging, landmark data refers to specific points of a body part. Using the landmark data from MediaPipe Holistic, we can pass it to Kalidokit to animate specific body parts. You can view the complete function for doing the animation [here]().

## Part 4 - Live stream your virtual character to Amazon IVS

At this point, we have a virtual avatar drawn on a canvas that can mimic our upper body movements. Now, let’s integrate the Amazon IVS Web Broadcast SDK with the web app to live stream and enable the world to see our avatar. To start live streaming, there are three core concepts that make real-time live streaming work.

- [Stage](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/web-publish-subscribe.html#web-publish-subscribe-concepts-stage): A virtual space where participants exchange audio or video. The Stage class is the main point of interaction between the host application and the SDK.
- [StageStrategy](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/web-publish-subscribe.html#web-publish-subscribe-concepts-strategy): An interface that provides a way for the host application to communicate the desired state of the stage to the SDK
- [Events](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/web-publish-subscribe.html#web-publish-subscribe-concepts-events): You can use an instance of a stage to communicate state changes such as when someone leaves or joins it, among other events.

To publish our video so the audience can see it, let’s capture the MediaStream from our canvas element and assign it to avatarStream in a function called init(). We use the captureStream method of the Canvas API to do so.

```javascript
const init = async () => {
  const avatarStream = renderer.domElement.captureStream();
};
```

Once we have a MediaStream we want to publish to an audience, we need to join a stage. Joining a stage enables us to live stream the video feed to the audience or other participants in the stage. If we don’t want to live stream anymore, we can leave the stage. Let’s add event listeners that listen for click events when an end user clicks the join or leave stage buttons and implement the appropriate logic.

```javascript
const init = async () => {
  const avatarStream = renderer.domElement.captureStream();

  joinBtn.addEventListener("click", () => {
    if (tokenInput.value.length === 0) {
      openModal();
    } else {
      joinStage(avatarStream);
    }
  });
};
```

Next, let’s add the logic for the joinStage function. In this function, we’re going to get the MediaStream from the user’s microphone so that we can publish it to the stage. Publishing is the act of sending audio and/or video to the stage so other participants can see or hear the participant that has joined.

Within this function, we also need to use the MediaStream instances from the microphone and the canvas to create instances of a LocalStageStream. Using these [LocalStageStream](https://aws.github.io/amazon-ivs-web-broadcast/docs/sdk-reference/classes/LocalStageStream) instances, we implement the stageStreamsToPublish function on the StageStrategy interface. In the stageStreamsToPublish function we simply return the instances of LocalStageStream in an array so that the audience can hear our audio and see our avatar

Concurrently, we also need to implement the shouldPublishParticipant and return true. This indicates whether a particular participant should publish. Additionally, we also need to implement the [shouldSubscribeToParticipant](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/web-publish-subscribe.html#web-publish-subscribe-concepts-events#web-publish-subscribe-concepts-strategy-participants), which indicates whether our app should subscribe to the remote participant’s audio only, audio and video, or nothing at all.

Lastly, create a new Stage object passing in the participant token and strategy object we set up earlier as arguments. The participant token is used to authenticate with the stage as well as identify which stage we are joining. You can get a participant token by [creating a stage in the console](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/web-publish-subscribe.html#web-publish-subscribe-concepts-events#web-publish-subscribe-concepts-strategy-participants) and subsequently [creating a participant token](https://docs.aws.amazon.com/ivs/latest/RealTimeUserGuide/getting-started-distribute-tokens.html#getting-started-distribute-tokens-console) within that stage. The strategy object defines what we want to publish for the audience to see once we join the stage. Later on, we will call the join method on a stage object to join a stage.

```javascript
const joinStage = async (avatarStream) => {
  if (connected || joining) {
    return;
  }
  joining = true;
  joinBtn.addEventListener("click", () => {
    leaveStage();
    joinBtn.innerText = "Leave Stage";
  });
  const token = tokenInput.value;

  if (!token) {
    window.alert("Please enter a participant token");
    joining = false;
    return;
  }

  localMic = await navigator.mediaDevices.getUserMedia({
    video: false,
    audio: true,
  });

  avatarStageStream = new LocalStageStream(avatarStream.getVideoTracks()[0]);
  micStageStream = new LocalStageStream(localMic.getAudioTracks()[0]);

  const strategy = {
    stageStreamsToPublish() {
      return [avatarStageStream, micStageStream];
    },
    shouldPublishParticipant() {
      return true;
    },
    shouldSubscribeToParticipant() {
      return SubscribeType.AUDIO_VIDEO;
    },
  };

  stage = new Stage(token, strategy);
};
```

Finally, let’s add some logic to listen for Stage events. These events occur when the state of the stage you’ve joined changes such as when someone joins or leaves it. Using these events, you can dynamically update the HTML code to display a new participant’s video feed when they join or remove it from display when they leave. The setupParticipant and teardownParticipant functions do each of these actions respectively. As a step step we call the join method on the stage object to join the stage.

```javascript
// Other available events:
// https://aws.github.io/amazon-ivs-web-broadcast/docs/sdk-guides/stages#events
stage.on(StageEvents.STAGE_CONNECTION_STATE_CHANGED, (state) => {
  connected = state === ConnectionState.CONNECTED;

  if (connected) {
    joining = false;
  }
});

const leaveStage = async () => {
  stage.leave();

  joining = false;
  connected = false;
};

stage.on(StageEvents.STAGE_PARTICIPANT_JOINED, (participant) => {
  console.log("Participant Joined:", participant);
});

stage.on(StageEvents.STAGE_PARTICIPANT_STREAMS_ADDED, (participant, streams) => {
  console.log("Participant Media Added: ", participant, streams);
});

stage.on(StageEvents.STAGE_PARTICIPANT_LEFT, (participant) => {
  console.log("Participant Left: ", participant);
});

try {
  await stage.join();
} catch (err) {
  joining = false;
  connected = false;
  console.error(err.message);
}
```

At this point, we are now broadcasting our live avatar feed that is mimicking our body movements to a stage. To test if someone else joining the stage can see your avatar, open the [Amazon IVS Real-Time Streaming Web Sample](https://codepen.io/amazon-ivs/project/editor/DYapzL#) in another browser window, create another participant token, provide it in this browser window and click join stage. You should now see the avatar move as you move on camera. Notice the latency can sub-second and can be as low as 300ms. This is how other audience members joining the stage would see your avatar.

## Conclusion

In this tutorial, you created a VTubing app by leveraging Pixiv’s APIs and SDKs to display a virtual avatar character and live stream it using Amazon IVS. VTubing opens the doors to an exciting world of virtual content creation. By following the steps outlined in this tutorial, you have gained the knowledge and tools necessary to bring your unique virtual persona to life.

If you enjoyed this tutorial, found any issues, or have feedback for us, <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">please send it our way!</a>

## About the Author

Tony Vu is a Senior Partner Engineer at Twitch. He specializes in assessing partner technology for integration with Amazon Interactive Video Service (IVS), aiming to develop and deliver comprehensive joint solutions to our IVS customers. Tony enjoys writing and sharing content on [LinkedIn](https://www.linkedin.com/in/tonyv/).
