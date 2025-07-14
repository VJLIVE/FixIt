import React, { createContext, useState, useEffect, useContext } from "react";
import { auth } from "./firebaseConfig"; // Firebase authentication instance
import { onAuthStateChanged } from "firebase/auth";

// Create an AuthContext
const AuthContext = createContext();

// AuthProvider to wrap the app and provide auth state
export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, setCurrentUser);
    return () => unsubscribe(); // Clean up subscription on unmount
  }, []);

  return (
    <AuthContext.Provider value={{ currentUser }}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook to use the Auth context
export function useAuth() {
  return useContext(AuthContext);
}
