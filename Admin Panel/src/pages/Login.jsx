import { useState, useEffect } from "react";
import { signInWithEmailAndPassword, signOut } from "firebase/auth";
import { auth, db } from "../firebaseConfig";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../AuthContext";
import { doc, getDoc } from "firebase/firestore";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [checkingRole, setCheckingRole] = useState(false);
  const navigate = useNavigate();
  const { currentUser } = useAuth();

  // 👇 Redirect already logged-in admins
  useEffect(() => {
    const checkUserRoleAndRedirect = async () => {
      if (currentUser) {
        const userDocRef = doc(db, "users", currentUser.uid);
        const userDoc = await getDoc(userDocRef);
        const role = userDoc.exists() ? userDoc.data().role : null;

        if (role === "admin") {
          navigate("/dashboard");
        } else {
          await signOut(auth);
        }
      }
    };
    checkUserRoleAndRedirect();
  }, [currentUser, navigate]);

  const handleSignIn = async () => {
    setCheckingRole(true);
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      const userDocRef = doc(db, "users", user.uid);
      const userDoc = await getDoc(userDocRef);
      const role = userDoc.exists() ? userDoc.data().role : null;

      if (role !== "admin") {
        await signOut(auth);
        alert("Access denied. Only admins can log in.");
      } else {
        navigate("/dashboard");
      }
    } catch (err) {
      alert(err.message);
    } finally {
      setCheckingRole(false);
    }
  };

  return (
    <div className="min-h-screen flex justify-center items-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-sm w-full">
        <h1 className="text-2xl font-semibold text-center mb-6">Login</h1>
        <input
          type="email"
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          className="w-full p-2 mb-4 border border-gray-300 rounded-lg"
        />
        <input
          type="password"
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          className="w-full p-2 mb-6 border border-gray-300 rounded-lg"
        />
        <button
          onClick={handleSignIn}
          className="w-full bg-blue-500 text-white py-2 rounded-lg hover:bg-blue-600 transition"
          disabled={checkingRole}
        >
          {checkingRole ? "Checking..." : "Sign In"}
        </button>
      </div>
    </div>
  );
}
