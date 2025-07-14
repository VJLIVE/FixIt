import { useNavigate } from "react-router-dom";
import { useAuth } from "../AuthContext";
import { auth, db } from "../firebaseConfig";
import { signOut } from "firebase/auth";
import { collection, query, where, getDocs, orderBy } from "firebase/firestore";
import { useEffect, useState } from "react";
import dayjs from "dayjs";

export default function Dashboard() {
  const { currentUser } = useAuth();
  const navigate = useNavigate();
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);

  const handleSignOut = () => {
    signOut(auth)
      .then(() => navigate("/"))
      .catch((error) => console.error("Error signing out: ", error));
  };

  const fetchComplaints = async () => {
    setLoading(true);
    try {
      const q = query(
        collection(db, "complaints"),
        orderBy("createdAt", "desc")
      );
      const snapshot = await getDocs(q);
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setComplaints(data);
    } catch (err) {
      console.error("Error fetching complaints:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!currentUser) {
      navigate("/login");
      return;
    }

    fetchComplaints();
  }, [currentUser, navigate]);

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-blue-600 text-white px-6 py-4 flex justify-between items-center">
        <h1 className="text-xl font-bold">Dashboard</h1>
        <button
          onClick={handleSignOut}
          className="bg-red-500 px-3 py-1 rounded hover:bg-red-600 text-sm"
        >
          Sign Out
        </button>
      </header>

      <main className="max-w-4xl mx-auto p-4">
        <h2 className="text-2xl font-semibold mb-4">
          Welcome, {currentUser?.email}
        </h2>

        <h3 className="text-xl font-semibold my-4">📋 My Complaints</h3>

        {loading ? (
          <p>Loading complaints...</p>
        ) : complaints.length === 0 ? (
          <p className="text-gray-500">You have not raised any complaints yet.</p>
        ) : (
          <div className="grid gap-4">
            {complaints.map((complaint) => (
              <div
                key={complaint.id}
                className="bg-white p-4 rounded shadow flex flex-col sm:flex-row gap-4"
              >
                <div className="flex-shrink-0 w-full sm:w-40 h-40 overflow-hidden rounded">
                  <img
                    src={complaint.imageUrl}
                    alt={complaint.title}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex-1">
                  <div className="flex justify-between items-center mb-2">
                    <h4 className="text-lg font-bold">{complaint.title}</h4>
                    <span
                      className={`text-sm px-2 py-1 rounded ${complaint.status === "Pending"
                          ? "bg-yellow-100 text-yellow-800"
                          : complaint.status === "In Progress"
                            ? "bg-blue-100 text-blue-800"
                            : "bg-green-100 text-green-800"
                        }`}
                    >
                      {complaint.status}
                    </span>
                  </div>
                  <p className="text-gray-700 text-sm">{complaint.description}</p>
                  <p className="text-gray-500 text-sm mt-1">
                    📍 {complaint.address}
                  </p>
                  <p className="text-gray-400 text-xs mt-2">
                    Raised on:{" "}
                    {complaint.createdAt?.seconds
                      ? dayjs(complaint.createdAt.seconds * 1000).format(
                        "MMM D, YYYY h:mm A"
                      )
                      : "N/A"}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
