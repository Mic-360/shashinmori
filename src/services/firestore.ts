import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { config } from "../config/env.js";
import type {
  PhotoRecord,
  StorageStatusRecord,
  UploadRecord,
  UserRecord
} from "../types/models.js";

function getFirebaseApp() {
  const existing = getApps()[0];
  if (existing) {
    return existing;
  }

  return initializeApp({
    credential: cert({
      projectId: config.firebaseProjectId,
      clientEmail: config.firebaseClientEmail,
      privateKey: config.firebasePrivateKey
    })
  });
}

export const firebaseApp = getFirebaseApp();
export const db = getFirestore(firebaseApp);
export const firebaseAuth = getAuth(firebaseApp);

db.settings({ ignoreUndefinedProperties: true });

export const timestampNow = () => Timestamp.now();

export function usersCollection() {
  return db.collection("users") as FirebaseFirestore.CollectionReference<UserRecord>;
}

export function uploadsCollection() {
  return db.collection("uploads") as FirebaseFirestore.CollectionReference<UploadRecord>;
}

export function photosCollection() {
  return db.collection("photos") as FirebaseFirestore.CollectionReference<PhotoRecord>;
}

export function systemCollection() {
  return db.collection("system") as FirebaseFirestore.CollectionReference<StorageStatusRecord>;
}
