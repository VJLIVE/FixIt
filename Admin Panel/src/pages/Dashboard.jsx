import { useNavigate } from "react-router-dom";
import { useAuth } from "../AuthContext";
import { auth } from "../firebaseConfig";
import { signOut } from "firebase/auth";

export default function Dashboard() {
  const { currentUser } = useAuth();
  const navigate = useNavigate();

  if (!currentUser) {
    navigate("/login");
    return null;
  }

  const handleSignOut = () => {
    signOut(auth)
      .then(() => {
        navigate("/");
      })
      .catch((error) => {
        console.error("Error signing out: ", error);
      });
  };

  return (
    <div className="min-h-screen flex justify-center items-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-sm w-full text-center">
        <h1 className="text-2xl font-semibold mb-6">Dashboard</h1>
        <p className="mb-4">You are logged in as {currentUser.email}</p>
        <button
          onClick={handleSignOut}
          className="bg-red-500 text-white py-2 px-4 rounded-lg hover:bg-red-600 transition"
        >
          Sign Out
        </button>
      </div>
    </div>
  );
}
