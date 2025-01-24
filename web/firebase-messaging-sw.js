importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-messaging.js');

// Initialize Firebase
firebase.initializeApp({
    apiKey: 'AIzaSyCtU-2RGfB0NtSh6MXvmQ2taptC34XazFg',
    appId: '1:372617062510:web:7dc12c513cd9ba47265e7f',
    messagingSenderId: '372617062510',
    projectId: 'blood-donation-app-57be3',
    authDomain: 'blood-donation-app-57be3.firebaseapp.com',
    storageBucket: 'blood-donation-app-57be3.firebasestorage.app',
    measurementId: 'G-4JQXCNEMDW',

});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('Received background message:', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/firebase-logo.png',
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
