import { Link } from "react-router-dom";
import { useAuth } from "../AuthContext";

export default function Home() {
  const { currentUser } = useAuth();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-blue-700 text-white py-4 px-8 shadow">
        <h1 className="text-2xl font-bold">FixIt — Complaint Management System</h1>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto p-6 space-y-8">
        {/* Intro Section */}
        <section className="mt-6">
          <h2 className="text-xl font-semibold mb-2 text-blue-600">Problem Statement</h2>
          <p className="text-gray-700">
            In many colleges and universities, students frequently encounter
            maintenance issues — such as broken furniture, faulty electrical
            fittings, leaking taps, or unclean areas. Unfortunately, the process
            of reporting these problems is often manual, slow, and ineffective.
          </p>
        </section>

        {/* Solution Section */}
        <section>
          <h2 className="text-xl font-semibold mb-2 text-blue-600">Proposed Solution</h2>
          <p className="text-gray-700">
            <strong>FixIt</strong> solves this by enabling students to quickly
            raise tickets with images & descriptions through a mobile app. Admins
            can track, update, and resolve complaints in real time, improving
            campus maintenance & student experience.
          </p>
        </section>

        {/* Key Features */}
        <section className="bg-gray-100 rounded-md p-4">
          <h2 className="text-lg font-semibold mb-2 text-blue-600">🌟 Key Features</h2>
          <ul className="list-disc pl-6 text-gray-700 space-y-1">
            <li>Role-based login (Student & Admin)</li>
            <li>Students can raise tickets with images & track progress</li>
            <li>Admins can view & update status of tickets</li>
            <li>Optional AI: Auto-categorize issues using Gemini API</li>
          </ul>
        </section>

        {/* Navigation */}
        <section>
          {currentUser ? (
            <div className="space-y-2">
              <Link
                to="/dashboard"
                className="inline-block bg-green-600 text-white py-2 px-4 rounded hover:bg-green-700"
              >
                Go to Dashboard
              </Link>
              <p className="text-xs text-gray-500">
                (Dashboard will show options based on your role: Admin)
              </p>
            </div>
          ) : (
            <Link
              to="/login"
              className="inline-block bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700"
            >
              Login to Continue
            </Link>
          )}
        </section>
      </main>

      {/* Footer */}
      <footer className="mt-12 text-center text-xs text-gray-400 py-4">
        Built with Flutter + Firebase + Vite React | © 2025 FixIt
      </footer>
    </div>
  );
}
