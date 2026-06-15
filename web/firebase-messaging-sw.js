importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCQjTiOSB_D9kYg2tMIN0iIjS-vbNH5ne0",
  authDomain: "mirchi-ott.firebaseapp.com",
  projectId: "mirchi-ott",
  storageBucket: "mirchi-ott.firebasestorage.app",
  messagingSenderId: "399081225701",
  appId: "1:399081225701:web:9f92eeb3b185c34ede430c",
  measurementId: "G-YEZ9EVGS3J"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
