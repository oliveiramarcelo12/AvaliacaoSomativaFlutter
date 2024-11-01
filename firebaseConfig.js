// firebaseConfig.js
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDhcqrkLeDPOtZzxqSwOsl9EsWm7xRH6pc",
  authDomain: "testefirebasenoite.firebaseapp.com",
  projectId: "testefirebasenoite",
  storageBucket: "testefirebasenoite.appspot.com",
  messagingSenderId: "197911325551",
  appId: "1:197911325551:android:06d24774ec7d85c196569a"
};

// Inicializar o Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
