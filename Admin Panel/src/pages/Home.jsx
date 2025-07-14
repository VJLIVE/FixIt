import { Link } from "react-router-dom";
import { useAuth } from "../AuthContext";

export default function Home() {
  const { currentUser } = useAuth();

  return (
    <div className="min-h-screen flex justify-center items-center bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-sm w-full text-center">
        <h1 className="text-2xl font-semibold mb-6">Welcome to Firebase Authentication</h1>

        {currentUser ? (
          <Link
            to="/dashboard"
            className="block bg-green-500 text-white py-2 rounded-lg mb-4 hover:bg-green-600 transition"
          >
            Go to Dashboard
          </Link>
        ) : (
          <>
            <Link
              to="/login"
              className="block bg-blue-500 text-white py-2 rounded-lg mb-4 hover:bg-blue-600 transition"
            >
              Login
            </Link>
          </>
        )}
      </div>
    </div>
  );
}
