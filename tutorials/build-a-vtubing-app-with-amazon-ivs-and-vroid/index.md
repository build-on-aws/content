---
title: "How To Build a VTubing App With Amazon Interactive Video Service and VRoid"
description: "Live stream a 3D avatar that mimics your body movements."
tags:
  - amazon-ivs
  - tutorials
  - twitch
  - vtubing
images:
  thumbnail: images/vtubing-ivs-demo.gif
  banner: images/vtubing-ivs-demo.gif
  hero: images/vtubing-ivs-demo.gif
  background: images/vtubing-ivs-demo.gif
authorGithubAlias: tonyv
authorName: Tony Vu
date: 2023-12-15
---

Have you ever wanted to express yourself in a more imaginative way under the guise of a virtual character? Imagine if you could create or summon a virtual avatar of your liking, have it mimic your body movements on camera, and stream to thousands. In this tutorial, you will learn how to do just that by creating your own VTubing app.

Virtual YouTubing, or V-Tubing for short, is the practice among live streamers of using virtual avatars to either present their brand, their personality, or their identity through means outside of a face cam.

With that context set, I will walk you through a step by step process of building a web app to render a 3D character from VRoid Hub, animate it based on your body movements, and live stream to Amazon Interactive Video Service (IVS). [VRoid Hub](https://hub.vroid.com/en) is an online platform created by Pixiv used to host and share 3D character models. You will be using a model we created and uploaded to VRoid Hub as your avatar. The Three VRM SDK from Pixiv will be used for rendering the digital character. VRM is a file format for handling 3D character models. To have your avatar animate and mimic your body movements, you will be using the MediaPipe Holistic library and [Kalidokit](https://github.com/yeemachine/kalidokit).

> The code for this tutorial is available on [Github](#). You can also try a [live demo](https://dev.d218eir1ybnzul.amplifyapp.com/) of this web app.

## What You Will Learn

- How to render a 3D virtual character
- How to animate a 3D virtual character with your own body movements
- How to live stream 3D your virtual character to Amazon IVS

| Attributes          |                                                                                                                   |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| ✅ AWS Level        | Intermediate - 200                                                                                                |
| ⏱ Time to complete  | 60 minutes                                                                                                        |
| 💰 Cost to complete | Free when using the AWS Free Tier                                                                                 |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/)<br>                                             |
| 💻 Code Sample      | [GitHub](#)                                                                                                       |
| 📢 Feedback         | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ? |
| ⏰ Last Updated     | 2023-12-15                                                                                                        |

| ToC |
| --- |

## Solution Overview

This tutorial consists of five parts:

- Part 1 - Download Your 3D Character
- Part 2 - Setup HTML To Display the Camera Feed and Live Stream Controls
- Part 3 - Rendering a Virtual Character With the Three VRM SDK
- Part 4 - Animating a Virtual Character With Your Own Body Movements
- Part 5 - Live Stream Your Virtual Character to Amazon IVS

For brevity, this tutorial will only focus on the key steps needed to load, animate, and live stream your virtual avatar. The complete code example can be found on [Github](#).

## Part 1 - Download your 3D character

For this tutorial, we have created our own 3D character using [VRoid Studio](https://vroid.com/en/studio). VRoid Studio is a 3D character creator tool that lets you export VRM files locally or upload them to VRoid Hub to share with the public. After creating our 3D character, we have saved it in VRM format and made it available [here](https://d1l5n2avb89axj.cloudfront.net/avatar-first.vrm) for use in this tutorial and [on VRoid Hub here](https://hub.vroid.com/en/characters/1692004541821223967/models/6410417122824343972). VRM is a file format for handling 3D character models.

> You can optionally integrate with the [VRoid Hub API](https://developer.vroid.com/en/api/) to programmatically download and use other 3D characters from VRoid Hub.

## Part 2 - Setup HTML to display the camera feed and live stream controls

Create the following HTML in an `index.html`. In the `<body>` element, we first add a `<video>` element for displaying the front facing camera feed. This will be useful to see how well our avatar mimics our own movements. Additionally, add buttons to join what is known in Amazon IVS terminology as a stage. A stage is a virtual space where participants exchange audio and/or video. Joining a stage will enable us to live stream our avatar to the stage audience or other participants in the stage. We will also add a modal containing a form to add a participant token. A participant token can be thought of as a password needed to join a stage. It also identifies to Amazon IVS which stage someone wants to join. Later on in this tutorial, we will explain how to create a stage and a participant token. In the `<head>` tag, we have added some CSS styling files which you can find on the Github repo here.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Amazon IVS VTuber Demo</title>
    <meta name="description" content="Amazon IVS VTuber Demo" />
    <link rel="stylesheet" href="style.css" />
    <link rel="stylesheet" href="modal.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.css" />
  </head>
  <body>
    <div class="preview">
      <video class="input_video" width="1280px" height="720px" autoplay muted playsinline></video>
    </div>
    <nav>
      <button id="settings-btn" class="button-open"" class="button button-outline">Settings</button>
      <button id="join-stage-btn" class="button button-outline">Join stage</button>
    </nav>

    <section class="modal hidden">
      <div>
        <h3>Settings</h3>
      </div>

      <input type="text" id="participant-token" placeholder="Enter a participant token"  />
      <button class="btn" id="submit-btn">Submit</button>
    </section>
    <div class="overlay hidden"></div>
  </body>
</html>
```

## Part 3 - Rendering a virtual character with the three VRM SDK

The next step is to render your digital character, represented in a VRM file, onto a canvas. To render VRM files onto a canvas, we will be using the [Three-VRM](https://github.com/pixiv/three-vrm) library and its prerequisites including [Three.js](https://github.com/mrdoob/three.js/) and [GLTFLoader](https://threejs.org/docs/#examples/en/loaders/GLTFLoader). Three.js is a popular JavaScript 3D library. GLFTLoader is a component in Three.js for loading 3D models in glTF (GL Transmission Format) format, which is a standard file format for three-dimensional scenes and models. We will also be using a Three.js add-on called [OrbitControls](https://threejs.org/docs/#examples/en/controls/OrbitControls) to allow us to rotate the view of our avatar when we rotate it. Add the following `<script>` elements inside your `<head>` element to use these libraries.

```html
<script src="https://unpkg.com/three@0.133.0/build/three.js"></script>
<script src="https://unpkg.com/three@0.133.0/examples/js/loaders/GLTFLoader.js"></script>
<script src="https://unpkg.com/@pixiv/three-vrm@0.6.7/lib/three-vrm.js"></script>
<script src="https://unpkg.com/three@0.133.0/examples/js/controls/OrbitControls.js"></script>
```

After importing these libraries, let’s create a JavaScript file, `app.js`, to write the code for utilizing these libraries and the rest of this tutorial. Import it right before the closing `</body>` tag as follows.

```html
<script src="app.js"></script>
</body>
```

Next, inside `app.js`, initialize an instance of the WebGLRenderer which we will be using to dynamically add a `<canvas>` element to our HTML. This canvas element will be used to render our avatar. The `currrentVrm` variable will be used later when we animate our avatar.

```javascript
let currentVrm;

const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
document.body.appendChild(renderer.domElement);
```

Next, create an instance of `PerspectiveCamera` that defines how much of the avatar is seen on screen in degrees, its aspect ratio, and how much of the avatar is seen on screen if it's panned further away from the camera. We also create an instance of `OrbitControls` that will allow us to rotate the view of our avatar by clicking and dragging.

```javascript
const orbitCamera = new THREE.PerspectiveCamera(
  35,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
orbitCamera.position.set(0.0, 1.4, 0.7);

const orbitControls = new THREE.OrbitControls(orbitCamera, renderer.domElement);
orbitControls.screenSpacePanning = true;
orbitControls.target.set(0.0, 1.4, 0.0);
orbitControls.update();
```

Let's use the Three.js library next to load an instance of a [scene](https://threejs.org/docs/#api/en/scenes/Scene). A scene acts as a virtual stage where our avatar will be placed for rendering. We also create an instance of `DirectionalLight` to add some light to the scene. Finally, create an instance of `Three.Clock` so that we can use it later for managing and synchronizing the animation of our avatar.

```javascript
const scene = new THREE.Scene();

const light = new THREE.DirectionalLight(0xffffff);
light.position.set(1.0, 1.0, 1.0).normalize();
scene.add(light);

const clock = new THREE.Clock();
```

Next, let's load our digital character into the scene using the VRM file we downloaded earlier. In the following code snippet, we use the Three-VRM library and `GLTFLoader` from Three.js to do just that.

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

  (progress) =>
    console.log(
      "Loading model...",
      100.0 * (progress.loaded / progress.total),
      "%"
    ),

  (error) => console.error(error)
);
```

## Part 4 - Animating a virtual character with your own body movements

To start animating your virtual character, add `<script>` elements for the [Kalidokit](https://github.com/yeemachine/kalidokit) library, [MediaPipe Holistic](https://github.com/google/mediapipe/blob/master/docs/solutions/holistic.md) library, and camera utility module from MediaPipe to the `<head>` element in `index.html`. MediaPipe Holistic is a computer vision pipeline used to track a user’s body movements, facial expressions, and hand gestures. This is useful for animating your digital avatar to mimic your own movements. Kalidokit includes the use of blendshapes for facial animation and kinematics solvers for body movements to create more realistic digital avatars. Blendshapes are a technique used in character animation to create a wide range of facial animations. Kinematics solvers are algorithms used to calculate the position and orientation of an avatar’s limbs. When making our avatar animate, aka character rigging, a kinematics solver helps determine how a character’s joints and bones should move to achieve a desired pose or animation. In short, MediaPipe Holistic tracks your physical movements while Kalidokit takes those as inputs to animate your avatar. The camera utility module from MediaPipe will simplify the process of providing our front-facing camera input to MediaPipe Holistic. MediaPipe Holistic needs this camera input to do hand, face and body movement tracking.

```html
<script
  src="https://cdn.jsdelivr.net/npm/@mediapipe/holistic@0.5.1635989137/holistic.js"
  crossorigin="anonymous"
></script>
<script src="https://cdn.jsdelivr.net/npm/kalidokit@1.1/dist/kalidokit.umd.js"></script>
<script
  src="https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils/camera_utils.js"
  crossorigin="anonymous"
></script>
```

Now let's initialize our animation by defining an `animate` function in `app.js`. In this function, we call `requestAnimationFrame`, which is provided by the Kalidokit library. This function is used to smoothly update and render animations of our avatar in sync with the browser's refresh rate. It ensures fluid motion for tracking and applying real-time face, body, and hand movements captured from our camera. After defining, we also make sure to call it as when load `app.js`.

```javascript
function animate() {
  requestAnimationFrame(animate);

  if (currentVrm) {
    currentVrm.update(clock.getDelta());
  }
  renderer.render(scene, orbitCamera);
}
animate();
```

Next, let’s add code for our avatar rigging logic, which is the process of creating a flexible skeleton for our avatar. These are helper functions which we will be calling to help animate the avatar. These functions are responsible for forming different parts of a digital skeleton for our avatar and mapping real-time landmark data provided by the MediaPipe Holistic library. Landmark data consists of coordinates that pinpoint specific body, face and and hand positions by the MediaPipe Holistic library when we face the camera. They allow us to accurately translate our physical movements into avatar animation. The `rigRotation` helper function involves adjusting the angles of the joints or bones in our avatar's digital skeleton to match our own movements. This includes movements like turning the head or bending an elbow. The `rigPosition` helper function deals with moving the entire character or parts of it in the scene to follow our own positional movements. This could be movements like shifting side to side. The `rigFace` helper function adjusts our avatar's facial structure to mirror our own facial movements like blinking and mouth movement for speaking.

```javascript
const rigRotation = (
  name,
  rotation = { x: 0, y: 0, z: 0 },
  dampener = 1,
  lerpAmount = 0.3
) => {
  if (!currentVrm) {
    return;
  }
  const Part = currentVrm.humanoid.getBoneNode(
    THREE.VRMSchema.HumanoidBoneName[name]
  );
  if (!Part) {
    return;
  }

  let euler = new THREE.Euler(
    rotation.x * dampener,
    rotation.y * dampener,
    rotation.z * dampener
  );
  let quaternion = new THREE.Quaternion().setFromEuler(euler);
  Part.quaternion.slerp(quaternion, lerpAmount);
};

const rigPosition = (
  name,
  position = { x: 0, y: 0, z: 0 },
  dampener = 1,
  lerpAmount = 0.3
) => {
  if (!currentVrm) {
    return;
  }
  const Part = currentVrm.humanoid.getBoneNode(
    THREE.VRMSchema.HumanoidBoneName[name]
  );
  if (!Part) {
    return;
  }
  let vector = new THREE.Vector3(
    position.x * dampener,
    position.y * dampener,
    position.z * dampener
  );
  Part.position.lerp(vector, lerpAmount);
};

let oldLookTarget = new THREE.Euler();
const rigFace = (riggedFace) => {
  if (!currentVrm) {
    return;
  }
  rigRotation("Neck", riggedFace.head, 0.7);

  const Blendshape = currentVrm.blendShapeProxy;
  const PresetName = THREE.VRMSchema.BlendShapePresetName;

  riggedFace.eye.l = lerp(
    clamp(1 - riggedFace.eye.l, 0, 1),
    Blendshape.getValue(PresetName.Blink),
    0.5
  );
  riggedFace.eye.r = lerp(
    clamp(1 - riggedFace.eye.r, 0, 1),
    Blendshape.getValue(PresetName.Blink),
    0.5
  );
  riggedFace.eye = Kalidokit.Face.stabilizeBlink(
    riggedFace.eye,
    riggedFace.head.y
  );
  Blendshape.setValue(PresetName.Blink, riggedFace.eye.l);

  Blendshape.setValue(
    PresetName.I,
    lerp(riggedFace.mouth.shape.I, Blendshape.getValue(PresetName.I), 0.5)
  );
  Blendshape.setValue(
    PresetName.A,
    lerp(riggedFace.mouth.shape.A, Blendshape.getValue(PresetName.A), 0.5)
  );
  Blendshape.setValue(
    PresetName.E,
    lerp(riggedFace.mouth.shape.E, Blendshape.getValue(PresetName.E), 0.5)
  );
  Blendshape.setValue(
    PresetName.O,
    lerp(riggedFace.mouth.shape.O, Blendshape.getValue(PresetName.O), 0.5)
  );
  Blendshape.setValue(
    PresetName.U,
    lerp(riggedFace.mouth.shape.U, Blendshape.getValue(PresetName.U), 0.5)
  );

  let lookTarget = new THREE.Euler(
    lerp(oldLookTarget.x, riggedFace.pupil.y, 0.4),
    lerp(oldLookTarget.y, riggedFace.pupil.x, 0.4),
    0,
    "XYZ"
  );
  oldLookTarget.copy(lookTarget);
  currentVrm.lookAt.applyer.lookAt(lookTarget);
};
```

Next, create the `animateVRM` function which will receive real-time landmark data from the MediaPipe Holistic library via the `results` argument. Using this landmark data, we can pass it to Kalidokit to animate the corresponding body parts of our avatar. Once we have the landmark data, we call the rigging helper functions we just created to animate our avatar.

```javascript
const animateVRM = (vrm, results) => {
  if (!vrm) {
    return;
  }
  let riggedPose, riggedLeftHand, riggedRightHand, riggedFace;

  const faceLandmarks = results.faceLandmarks;
  const pose3DLandmarks = results.ea;
  const pose2DLandmarks = results.poseLandmarks;
  const leftHandLandmarks = results.rightHandLandmarks;
  const rightHandLandmarks = results.leftHandLandmarks;

  // Animate Face
  if (faceLandmarks) {
    riggedFace = Kalidokit.Face.solve(faceLandmarks, {
      runtime: "mediapipe",
      video: videoElement,
    });
    rigFace(riggedFace);
  }

  // Animate Pose
  if (pose2DLandmarks && pose3DLandmarks) {
    riggedPose = Kalidokit.Pose.solve(pose3DLandmarks, pose2DLandmarks, {
      runtime: "mediapipe",
      video: videoElement,
    });
    rigRotation("Hips", riggedPose.Hips.rotation, 0.7);
    rigPosition(
      "Hips",
      {
        x: -riggedPose.Hips.position.x, // Reverse direction
        y: riggedPose.Hips.position.y + 1, // Add a bit of height
        z: -riggedPose.Hips.position.z, // Reverse direction
      },
      1,
      0.07
    );

    rigRotation("Chest", riggedPose.Spine, 0.25, 0.3);
    rigRotation("Spine", riggedPose.Spine, 0.45, 0.3);

    rigRotation("RightUpperArm", riggedPose.RightUpperArm, 1, 0.3);
    rigRotation("RightLowerArm", riggedPose.RightLowerArm, 1, 0.3);
    rigRotation("LeftUpperArm", riggedPose.LeftUpperArm, 1, 0.3);
    rigRotation("LeftLowerArm", riggedPose.LeftLowerArm, 1, 0.3);

    rigRotation("LeftUpperLeg", riggedPose.LeftUpperLeg, 1, 0.3);
    rigRotation("LeftLowerLeg", riggedPose.LeftLowerLeg, 1, 0.3);
    rigRotation("RightUpperLeg", riggedPose.RightUpperLeg, 1, 0.3);
    rigRotation("RightLowerLeg", riggedPose.RightLowerLeg, 1, 0.3);
  }

  // Animate Hands
  if (leftHandLandmarks) {
    riggedLeftHand = Kalidokit.Hand.solve(leftHandLandmarks, "Left");
    rigRotation("LeftHand", {
      z: riggedPose.LeftHand.z,
      y: riggedLeftHand.LeftWrist.y,
      x: riggedLeftHand.LeftWrist.x,
    });
    rigRotation("LeftRingProximal", riggedLeftHand.LeftRingProximal);
    rigRotation("LeftRingIntermediate", riggedLeftHand.LeftRingIntermediate);
    rigRotation("LeftRingDistal", riggedLeftHand.LeftRingDistal);
    rigRotation("LeftIndexProximal", riggedLeftHand.LeftIndexProximal);
    rigRotation("LeftIndexIntermediate", riggedLeftHand.LeftIndexIntermediate);
    rigRotation("LeftIndexDistal", riggedLeftHand.LeftIndexDistal);
    rigRotation("LeftMiddleProximal", riggedLeftHand.LeftMiddleProximal);
    rigRotation(
      "LeftMiddleIntermediate",
      riggedLeftHand.LeftMiddleIntermediate
    );
    rigRotation("LeftMiddleDistal", riggedLeftHand.LeftMiddleDistal);
    rigRotation("LeftThumbProximal", riggedLeftHand.LeftThumbProximal);
    rigRotation("LeftThumbIntermediate", riggedLeftHand.LeftThumbIntermediate);
    rigRotation("LeftThumbDistal", riggedLeftHand.LeftThumbDistal);
    rigRotation("LeftLittleProximal", riggedLeftHand.LeftLittleProximal);
    rigRotation(
      "LeftLittleIntermediate",
      riggedLeftHand.LeftLittleIntermediate
    );
    rigRotation("LeftLittleDistal", riggedLeftHand.LeftLittleDistal);
  }
  if (rightHandLandmarks) {
    riggedRightHand = Kalidokit.Hand.solve(rightHandLandmarks, "Right");
    rigRotation("RightHand", {
      z: riggedPose.RightHand.z,
      y: riggedRightHand.RightWrist.y,
      x: riggedRightHand.RightWrist.x,
    });
    rigRotation("RightRingProximal", riggedRightHand.RightRingProximal);
    rigRotation("RightRingIntermediate", riggedRightHand.RightRingIntermediate);
    rigRotation("RightRingDistal", riggedRightHand.RightRingDistal);
    rigRotation("RightIndexProximal", riggedRightHand.RightIndexProximal);
    rigRotation(
      "RightIndexIntermediate",
      riggedRightHand.RightIndexIntermediate
    );
    rigRotation("RightIndexDistal", riggedRightHand.RightIndexDistal);
    rigRotation("RightMiddleProximal", riggedRightHand.RightMiddleProximal);
    rigRotation(
      "RightMiddleIntermediate",
      riggedRightHand.RightMiddleIntermediate
    );
    rigRotation("RightMiddleDistal", riggedRightHand.RightMiddleDistal);
    rigRotation("RightThumbProximal", riggedRightHand.RightThumbProximal);
    rigRotation(
      "RightThumbIntermediate",
      riggedRightHand.RightThumbIntermediate
    );
    rigRotation("RightThumbDistal", riggedRightHand.RightThumbDistal);
    rigRotation("RightLittleProximal", riggedRightHand.RightLittleProximal);
    rigRotation(
      "RightLittleIntermediate",
      riggedRightHand.RightLittleIntermediate
    );
    rigRotation("RightLittleDistal", riggedRightHand.RightLittleDistal);
  }
};
```

Finally, let's setup and configure an instance of the MediaPipe Holistic library. First, we need to get the camera feed using the MediaPipe camera utilities module and render it to our `<video>` element. We then pass in the `<video>` element from our HTML to MediaPipe Holistic so that it process it and provide landmark data. Once Holistic finishes processing the camera data from the `<video>` element, it invokes a callback function with the resulting landmark data. Those results are then passed to the `animateVRM` function we created earlier to animate our avatar.

```javascript
let videoElement = document.querySelector(".input_video");

const onResults = (results) => {
  // Animate model
  animateVRM(currentVrm, results);
};

const holistic = new Holistic({
  locateFile: (file) => {
    return `https://cdn.jsdelivr.net/npm/@mediapipe/holistic@0.5.1635989137/${file}`;
  },
});

holistic.setOptions({
  modelComplexity: 1,
  smoothLandmarks: true,
  minDetectionConfidence: 0.7,
  minTrackingConfidence: 0.7,
  refineFaceLandmarks: true,
});

// Pass holistic a callback function
holistic.onResults(onResults);

// Use `Mediapipe` utils to get camera
const camera = new Camera(videoElement, {
  onFrame: async () => {
    await holistic.send({ image: videoElement });
  },
  width: 640,
  height: 480,
});
camera.start();
```

## Part 5 - Live stream your virtual character to Amazon IVS

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

Once we have a MediaStream we want to publish to an audience and we need to join a stage. Joining a stage enables us to live stream the video feed to the audience or other participants in the stage. If we don’t want to live stream anymore, we can leave the stage. Let’s add event listeners that listen for click events when an end user clicks the join or leave stage buttons and implement the appropriate logic.

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

Finally, let’s add some logic to listen for Stage events. These events occur when the state of the stage you’ve joined changes such as when someone joins or leaves it. Using these events, you can dynamically update the HTML code to display a new participant’s video feed when they join or remove it from display when they leave. The setupParticipant and teardownParticipant functions do each of these actions respectively. As a next step, we call the join method on the stage object to join the stage.

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

stage.on(
  StageEvents.STAGE_PARTICIPANT_STREAMS_ADDED,
  (participant, streams) => {
    console.log("Participant Media Added: ", participant, streams);
  }
);

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

In this tutorial, you created a VTubing app by leveraging Pixiv’s SDKs to display a virtual avatar character and live stream it using Amazon IVS. VTubing opens the doors to an exciting world of virtual content creation. By following the steps outlined in this tutorial, you have gained the knowledge and tools necessary to bring your unique virtual persona to life. To learn more about live streaming with Amazon IVS, check out the blog post about [Creating Safer Online Communities using AI](https://community.aws/livestreams/build-on-live-events/open-source-and-machine-learning/creating-safer-online-communities-using-ai).

If you enjoyed this tutorial, found any issues, or have feedback for us, <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">please send it our way!</a>

## About the Author

Tony Vu is a Senior Partner Engineer at Twitch. He specializes in assessing partner technology for integration with Amazon Interactive Video Service (IVS), aiming to develop and deliver comprehensive joint solutions to our IVS customers. Tony enjoys writing and sharing content on [LinkedIn](https://www.linkedin.com/in/tonyv/).
