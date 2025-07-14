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
    <div className="min-h-screen bg-gradient-to-br from-blue-100 via-blue-200 to-blue-300 flex items-center justify-center">
      <div className="bg-white rounded-2xl shadow-xl p-8 sm:p-10 w-full max-w-md">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-blue-700 mb-2">Admin Login</h1>
          <p className="text-gray-500 mb-6 text-sm">Sign in to access the admin dashboard</p>
        </div>

        <div className="space-y-4">
          <input
            type="email"
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Email"
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
          <input
            type="password"
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Password"
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
          <button
            onClick={handleSignIn}
            disabled={checkingRole}
            className={`w-full py-3 text-white rounded-lg font-medium ${
              checkingRole
                ? "bg-blue-300 cursor-not-allowed"
                : "bg-blue-600 hover:bg-blue-700 transition"
            }`}
          >
            {checkingRole ? "Checking..." : "Sign In"}
          </button>
        </div>

        <div className="mt-6 text-center text-xs text-gray-400">
          © 2025 FixIt Admin Panel
        </div>
      </div>
    </div>
  );
}
