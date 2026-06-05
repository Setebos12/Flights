import { useState } from "react"

export default function RegisterForm({ onLogin, onClose, onSwitchToLogin }) {
  const [form, setForm] = useState({ email: "", password: "", confirmPassword: "", firstName: "", lastName: "", phoneNumber: "" })
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)

  const set = (field) => (e) => setForm(prev => ({ ...prev, [field]: e.target.value }))

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (form.password !== form.confirmPassword) {
      setError("Passwords do not match")
      return
    }
    if (form.password.length < 8) {
      setError("Password must be at least 8 characters")
      return
    }

    setLoading(true)
    setError("")

    try {
      const res = await fetch("http://localhost:8080/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: form.email,
          password: form.password,
          firstName: form.firstName,
          lastName: form.lastName,
          phoneNumber: form.phoneNumber || null
        })
      })

      if (res.status === 409) {
        setError("An account with this email already exists")
        setLoading(false)
        return
      }

      if (!res.ok) {
        setError("Registration failed. Please try again.")
        setLoading(false)
        return
      }

      const data = await res.json()
      localStorage.setItem("token", data.token)
      localStorage.setItem("userId", data.userId)
      localStorage.setItem("email", data.email)
      onLogin(data)
    } catch {
      setError("Connection error. Try again.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white dark:bg-slate-800 rounded-2xl p-8 w-full max-w-md shadow-2xl">

        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-medium text-slate-800 dark:text-white">Create account</h2>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600 text-xl">✕</button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div className="flex gap-3">
            <div className="flex-1">
              <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">First name</label>
              <input type="text" value={form.firstName} onChange={set("firstName")}
                className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Jan" required />
            </div>
            <div className="flex-1">
              <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Last name</label>
              <input type="text" value={form.lastName} onChange={set("lastName")}
                className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Kowalski" required />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Email</label>
            <input type="email" value={form.email} onChange={set("email")}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="jan.kowalski@email.pl" required />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Phone number <span className="normal-case font-normal">(optional)</span></label>
            <input type="tel" value={form.phoneNumber} onChange={set("phoneNumber")}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="+48501234567" />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Password</label>
            <input type="password" value={form.password} onChange={set("password")}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="••••••••" required />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Confirm password</label>
            <input type="password" value={form.confirmPassword} onChange={set("confirmPassword")}
              className="w-full h-11 border border-slate-200 dark:border-slate-600 rounded-xl px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="••••••••" required />
          </div>

          {error && <p className="text-red-500 text-sm">{error}</p>}

          <button type="submit" disabled={loading}
            className="h-11 bg-blue-700 hover:bg-blue-800 disabled:opacity-50 text-white rounded-xl text-sm font-medium">
            {loading ? "Creating account..." : "Create account"}
          </button>
        </form>

        <p className="text-center text-sm text-slate-500 mt-4">
          Already have an account?{" "}
          <button onClick={onSwitchToLogin} className="text-blue-600 hover:underline font-medium">Sign in</button>
        </p>
      </div>
    </div>
  )
}
