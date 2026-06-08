import { useState, useEffect } from "react"
import SearchForm from "./components/SearchForm"
import FlightList from "./components/FlightList"
import AnalyticsDashboard from "./components/analytics/AnalyticsDashboard"
import LoginForm from "./components/LoginForm"
import RegisterForm from "./components/RegisterForm"

export default function App() {
  const [flights, setFlights] = useState([])
  const [loading, setLoading] = useState(false)
  const [view, setView] = useState("search") // "search" | "analytics"
  // auth
  const [user, setUser] = useState(null)
  const [isAdmin, setIsAdmin] = useState(false)
  const [isLoginOpen, setIsLoginOpen] = useState(false)
  const [isRegisterOpen, setIsRegisterOpen] = useState(false)

  // login check
  useEffect(() => {
      const token = localStorage.getItem("token")
      const email = localStorage.getItem("email")
      const storedAdmin = localStorage.getItem("isAdmin") === "true"
      const emailAdmin = email?.toLowerCase().includes("admin")
      if (token && email) {
        setUser({ token, email })
        setIsAdmin(storedAdmin || emailAdmin)
      }
    }, [])

  useEffect(() => {
      if (view === "analytics" && !isAdmin) {
        setView("search")
      }
    }, [view, isAdmin])

  const searchFlights = async (params) => {
    setLoading(true)
    const query = new URLSearchParams()
    if (params.originCode) query.append("originCode", params.originCode)
    if (params.destinationCode) query.append("destinationCode", params.destinationCode)
    if (params.date) query.append("date", params.date)
    if (params.minPrice) query.append("minPrice", params.minPrice)
    if (params.maxPrice) query.append("maxPrice", params.maxPrice)

    // headers building - JWT if logged in
        const headers = {}
        const token = localStorage.getItem("token")
        if (token && token !== "null" && token !== "undefined") {
          headers["Authorization"] = `Bearer ${token}`
        }

        try {
          const res = await fetch(`http://localhost:8080/api/flights/search?${query}`, {
            headers: headers
          })
          const data = await res.json()
          setFlights(data)
        } catch (error) {
          console.error("Błąd pobierania lotów:", error)
        } finally {
          setLoading(false)
        }
    }

        const handleLoginSuccess = (userData) => {
            const admin = Boolean(
              userData?.isAdmin ||
              userData?.roles?.includes("ADMIN") ||
              userData?.roles?.includes("ROLE_ADMIN") ||
              userData?.email?.toLowerCase().includes("admin")
            )
            setUser(userData)
            setIsAdmin(admin)
            localStorage.setItem("isAdmin", admin ? "true" : "false")
            setIsLoginOpen(false)
          }

          const handleLogout = () => {
            localStorage.removeItem("token")
            localStorage.removeItem("userId")
            localStorage.removeItem("email")
            localStorage.removeItem("isAdmin")
            setUser(null)
            setIsAdmin(false)
            setView("search") // reset view
          }

  return (
      <div className="min-h-screen bg-slate-100 dark:bg-slate-900">
        <nav className="bg-blue-950 dark:bg-slate-950 px-6 py-3 flex items-center justify-between">

          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2">
              <span className="text-white text-2xl">✈</span>
              <span className="text-white font-medium tracking-wide text-lg">SkySearch</span>
            </div>
            <div className="flex gap-1 ml-2">
              <button
                id="nav-search"
                onClick={() => setView("search")}
                className={`px-4 py-1.5 rounded-md text-sm font-medium transition-colors ${
                  view === "search"
                    ? "bg-white/15 text-white"
                    : "text-blue-200 hover:text-white hover:bg-white/10"
                }`}
              >
                Search Flights
              </button>
              {isAdmin && (
                <button
                  id="nav-analytics"
                  onClick={() => setView("analytics")}
                  className={`px-4 py-1.5 rounded-md text-sm font-medium transition-colors ${
                    view === "analytics"
                      ? "bg-white/15 text-white"
                      : "text-blue-200 hover:text-white hover:bg-white/10"
                  }`}
                >
                  Analytics
                </button>
              )}
            </div>
          </div>

          <div className="flex items-center gap-4">
            {user ? (
              <>
                <span className="text-blue-200 text-sm hidden sm:inline font-medium">
                  {user.email}
                </span>
                <button
                  onClick={handleLogout}
                  className="px-4 py-1.5 bg-red-600 hover:bg-red-700 text-white rounded-md text-sm font-medium transition-colors shadow-sm"
                >
                  Sign Out
                </button>
              </>
            ) : (
              <button
                onClick={() => setIsLoginOpen(true)}
                className="px-4 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition-colors shadow-sm"
              >
                Sign In
              </button>
            )}
          </div>

        </nav>
        {view === "search" ? (
          <>
            <SearchForm onSearch={searchFlights} />
            <div className="max-w-4xl mx-auto px-4 py-6">
              {loading && <p className="text-slate-500 text-center animate-pulse">Searching...</p>}
              <FlightList flights={flights} user={user} onRequireLogin={() => setIsLoginOpen(true)} />
            </div>
          </>
        ) : (
          <AnalyticsDashboard />
        )}
        {isLoginOpen && (
          <LoginForm
            onLogin={handleLoginSuccess}
            onClose={() => setIsLoginOpen(false)}
            onSwitchToRegister={() => { setIsLoginOpen(false); setIsRegisterOpen(true) }}
          />
        )}
        {isRegisterOpen && (
          <RegisterForm
            onLogin={handleLoginSuccess}
            onClose={() => setIsRegisterOpen(false)}
            onSwitchToLogin={() => { setIsRegisterOpen(false); setIsLoginOpen(true) }}
          />
        )}
      </div>
    )
}