importScripts(
  "https://www.gstatic.com/firebasejs/9.9.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.9.0/firebase-messaging-compat.js"
);

const firebaseConfig = {
  apiKey: "AIzaSyCzmk8TYZcLF-NxVlsfUzWE_URfTWwMjy4",
  authDomain: "douchat-ed564.firebaseapp.com",
  projectId: "douchat-ed564",
  storageBucket: "douchat-ed564.appspot.com",
  messagingSenderId: "610795338007",
  appId: "1:610795338007:web:403d43bbff8e4cbf9a5f52",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
