// Initialize Firebase - runs before Flutter app
if (typeof firebase !== 'undefined') {
  console.log('✓ Firebase SDK loaded');
  
  // Initialize Firebase app with config
  firebase.initializeApp({
    apiKey: "AIzaSyBf9_Utm1ytapgNUN19tE3L8uSzDXEQcyM",
    authDomain: "todolist-7bebc.firebaseapp.com",
    projectId: "todolist-7bebc",
    storageBucket: "todolist-7bebc.firebasestorage.app",
    messagingSenderId: "314034792177",
    appId: "1:314034792177:web:fe76bf8892bed5a2d22b50"
  });
  
  console.log('✓ Firebase initialized in JavaScript');
  window.firebaseReady = true;
} else {
  console.warn('⚠ Firebase SDK not loaded yet');
  window.firebaseReady = false;
}
