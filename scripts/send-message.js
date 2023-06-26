var admin = require('firebase-admin');

var serviceAccount = require('./google-services.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const token = 'fxiDAHc3T0mbS9S6RulkVk:APA91bG5YFy93Px-rosZFx1SmAnchBlbBIw7tQuNd-OR4u_Y8RwisfUSFHFeAmyf8QIoLpnc8NgixElO_1NaXLcrwGGVZUu-2EUdIZkSmEwVCiBlZ5ezQNQXdiI0z4iucwMkvOvD5r-5';

const message = {
  notification: {
    title: 'Hey, Pavlo',
    body: 'This is a test notification!'
  },
  token: token
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.error('Error sending message:', error);
  });