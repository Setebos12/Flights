import { useState } from "react"

export default function LoginForm({ onLogin, onClose, onSwitchToRegister }) {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError("")

    try {
      const res = await fetch("http://localhost:8080/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password })
      })

      if (!res.ok) {
        setError("Invalid email or password")
        setLoading(false)
        return
      }

      const data = await res.json()
      localStorage.setItem("token", data.token)
      localStorage.setItem("userId", data.userId)
      localStorage.setItem("email", data.email)
      onLogin(data)
    } catch (err) {
      setError("Connection error. Try again.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white dark:bg-slate-800 rounded-2xl p-8 w-full max-w-md shadow-2xl">

        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-medium text-slate-800 dark:text-white">Sign in</h2>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600 text-xl">✕</button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Email</label>
            <input type="email" value={email} onChange={e => setEmail(e.target.value)}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="jan.kowalski@email.pl" required />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Password</label>
            <input type="password" value={password} onChange={e => setPassword(e.target.value)}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="••••••••" required />
          </div>

          {error && <p className="text-red-500 text-sm">{error}</p>}

          <button type="submit" disabled={loading}
            className="h-11 bg-blue-700 hover:bg-blue-800 disabled:opacity-50 text-white rounded-xl text-sm font-medium">
            {loading ? "Signing in..." : "Sign in"}
          </button>
        </form>

        <p className="text-center text-sm text-slate-500 mt-4">
          Don't have an account?{" "}
          <button onClick={onSwitchToRegister} className="text-blue-600 hover:underline font-medium">Register</button>
        </p>
      </div>
    </div>
  )
}