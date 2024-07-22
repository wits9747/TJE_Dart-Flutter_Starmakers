importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyChxtLvOJcfQvdke7PMpMtxw87YYq_Kbmg",
  appId: "1:961419777800:web:d706fc5781f003aa507ebd",
  messagingSenderId: "961419777800",
  projectId: "jolii-me",
  authDomain: "lamatt.firebaseapp.com/",
  databaseURL: "https://jolii-me.firebaseio.com",
  storageBucket: "jolii-me.appspot.com",
  measurementId: "G-8SHT2KFELM",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
