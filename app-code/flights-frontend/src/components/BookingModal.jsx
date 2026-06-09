import { useState, useEffect } from "react"

const CLASS_COLORS = {
  "Economy":         { bg: "bg-sky-100 dark:bg-sky-900",    selected: "bg-sky-500 text-white",    label: "bg-sky-200 text-sky-800" },
  "Premium Economy": { bg: "bg-teal-100 dark:bg-teal-900",  selected: "bg-teal-500 text-white",   label: "bg-teal-200 text-teal-800" },
  "Business":        { bg: "bg-amber-100 dark:bg-amber-900", selected: "bg-amber-500 text-white", label: "bg-amber-200 text-amber-800" },
  "First Class":     { bg: "bg-purple-100 dark:bg-purple-900", selected: "bg-purple-500 text-white", label: "bg-purple-200 text-purple-800" },
}

const authHeader = () => ({ "Authorization": `Bearer ${localStorage.getItem("token")}`, "Content-Type": "application/json" })

export default function BookingModal({ flight, onClose, onSuccess }) {
  const [step, setStep] = useState(1)
  const [seats, setSeats] = useState([])
  const [services, setServices] = useState([])
  const [selectedSeat, setSelectedSeat] = useState(null)
  const [selectedServices, setSelectedServices] = useState([])
  const [loadingData, setLoadingData] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState("")

  useEffect(() => {
    Promise.all([
      fetch(`http://localhost:8080/api/flights/${flight.id}/seats`, { headers: authHeader() }).then(r => r.json()),
      fetch("http://localhost:8080/api/extra-services", { headers: authHeader() }).then(r => r.json())
    ]).then(([s, sv]) => {
      setSeats(s)
      setServices(sv)
      setLoadingData(false)
    }).catch(() => {
      setError("Failed to load booking data.")
      setLoadingData(false)
    })
  }, [flight.id])

  const toggleService = (id) =>
    setSelectedServices(prev => prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id])

  const totalPrice = () => {
    const base = parseFloat(flight.price) || 0
    const extras = selectedServices.reduce((sum, id) => {
      const s = services.find(sv => sv.id === id)
      return sum + (s ? parseFloat(s.price) : 0)
    }, 0)
    return (base + extras).toFixed(2)
  }

  const handleConfirm = async () => {
    setSubmitting(true)
    setError("")
    try {
      const res = await fetch("http://localhost:8080/api/reservations", {
        method: "POST",
        headers: authHeader(),
        body: JSON.stringify({
          flightId: flight.id,
          seatId: selectedSeat.id,
          seatSerialNumber: selectedSeat.serialNumber,
          extraServiceIds: selectedServices
        })
      })
      if (!res.ok) throw new Error()
      const data = await res.json()
      onSuccess?.(data.reservationId)
      onClose()
    } catch {
      setError("Booking failed. Please try again.")
    } finally {
      setSubmitting(false)
    }
  }

  const seatsByRow = seats.reduce((acc, s) => {
    if (!acc[s.rowNr]) acc[s.rowNr] = []
    acc[s.rowNr].push(s)
    return acc
  }, {})

  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-white dark:bg-slate-800 rounded-2xl w-full max-w-2xl shadow-2xl flex flex-col max-h-[90vh]">

        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-6 pb-4 border-b border-slate-100 dark:border-slate-700 shrink-0">
          <div>
            <h2 className="text-lg font-medium text-slate-800 dark:text-white">
              {flight.originAirportCode} → {flight.destinationAirportCode}
            </h2>
            <p className="text-xs text-slate-400 mt-0.5">{flight.airlineName} · {flight.price} {flight.currencyCode}</p>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600 text-xl">✕</button>
        </div>

        {/* Step indicator */}
        <div className="flex gap-0 px-6 pt-4 shrink-0">
          {["Seat", "Services", "Confirm"].map((label, i) => (
            <div key={i} className="flex items-center gap-0 flex-1">
              <div className={`flex items-center gap-1.5 ${i + 1 <= step ? "text-blue-600" : "text-slate-300"}`}>
                <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-medium border-2
                  ${i + 1 < step ? "bg-blue-600 border-blue-600 text-white" :
                    i + 1 === step ? "border-blue-600 text-blue-600" :
                    "border-slate-300 text-slate-300"}`}>
                  {i + 1 < step ? "✓" : i + 1}
                </div>
                <span className="text-xs font-medium">{label}</span>
              </div>
              {i < 2 && <div className={`flex-1 h-px mx-2 ${i + 1 < step ? "bg-blue-600" : "bg-slate-200"}`} />}
            </div>
          ))}
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          {loadingData ? (
            <p className="text-center text-slate-400 py-8 animate-pulse">Loading...</p>
          ) : error ? (
            <p className="text-center text-red-500 py-8">{error}</p>
          ) : step === 1 ? (
            <StepSeats seatsByRow={seatsByRow} selectedSeat={selectedSeat} onSelect={setSelectedSeat} />
          ) : step === 2 ? (
            <StepServices services={services} selected={selectedServices} onToggle={toggleService} />
          ) : (
            <StepConfirm flight={flight} seat={selectedSeat} services={services} selectedServices={selectedServices} total={totalPrice()} />
          )}
        </div>

        {/* Footer */}
        <div className="px-6 pb-6 pt-3 border-t border-slate-100 dark:border-slate-700 shrink-0 flex justify-between items-center">
          <button
            onClick={() => setStep(s => s - 1)}
            disabled={step === 1}
            className="px-4 py-2 text-sm text-slate-500 hover:text-slate-700 disabled:opacity-0"
          >
            Back
          </button>
          <span className="text-sm font-medium text-slate-700 dark:text-slate-300">
            Total: {totalPrice()} {flight.currencyCode}
          </span>
          {step < 3 ? (
            <button
              onClick={() => setStep(s => s + 1)}
              disabled={step === 1 && !selectedSeat}
              className="px-5 py-2 bg-blue-700 hover:bg-blue-800 disabled:opacity-40 text-white text-sm rounded-xl font-medium"
            >
              Next
            </button>
          ) : (
            <button
              onClick={handleConfirm}
              disabled={submitting}
              className="px-5 py-2 bg-green-600 hover:bg-green-700 disabled:opacity-50 text-white text-sm rounded-xl font-medium"
            >
              {submitting ? "Booking..." : "Confirm booking"}
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

function StepSeats({ seatsByRow, selectedSeat, onSelect }) {
  const classColors = (classType) => CLASS_COLORS[classType] || CLASS_COLORS["Economy"]

  return (
    <div>
      <p className="text-sm text-slate-500 mb-4">Select your seat</p>

      {/* Legend */}
      <div className="flex gap-3 mb-4 flex-wrap">
        {Object.entries(CLASS_COLORS).map(([name, c]) => (
          <span key={name} className={`text-xs px-2 py-1 rounded-full font-medium ${c.label}`}>{name}</span>
        ))}
        <span className="text-xs px-2 py-1 rounded-full bg-slate-200 text-slate-500">Taken</span>
      </div>

      <div className="flex flex-col gap-1.5">
        {Object.entries(seatsByRow).map(([row, rowSeats]) => (
          <div key={row} className="flex items-center gap-1.5">
            <span className="text-xs text-slate-400 w-5 text-right">{row}</span>
            <div className="flex gap-1.5 flex-wrap">
              {rowSeats.map(seat => {
                const colors = classColors(seat.classType)
                const isSelected = selectedSeat?.id === seat.id
                return (
                  <button
                    key={seat.id}
                    disabled={!seat.available}
                    onClick={() => onSelect(seat)}
                    title={`Row ${seat.rowNr} Col ${seat.colNr} · ${seat.seatType} · ${seat.classType}`}
                    className={`w-9 h-9 rounded-lg text-xs font-medium transition-all border
                      ${!seat.available
                        ? "bg-slate-200 dark:bg-slate-600 text-slate-400 cursor-not-allowed border-slate-200"
                        : isSelected
                          ? `${colors.selected} border-transparent shadow-md scale-105`
                          : `${colors.bg} text-slate-600 dark:text-slate-200 border-slate-200 dark:border-slate-600 hover:scale-105 hover:shadow-sm`
                      }`}
                  >
                    {seat.colNr}
                  </button>
                )
              })}
            </div>
          </div>
        ))}
      </div>

      {selectedSeat && (
        <p className="mt-4 text-sm text-blue-600 font-medium">
          Selected: Row {selectedSeat.rowNr}, Col {selectedSeat.colNr} · {selectedSeat.seatType} · {selectedSeat.classType}
        </p>
      )}
    </div>
  )
}

function StepServices({ services, selected, onToggle }) {
  return (
    <div>
      <p className="text-sm text-slate-500 mb-4">Add extra services (optional)</p>
      <div className="flex flex-col gap-2">
        {services.map(s => (
          <label key={s.id} className={`flex items-center justify-between p-3 rounded-xl border cursor-pointer transition-colors
            ${selected.includes(s.id)
              ? "border-blue-400 bg-blue-50 dark:bg-blue-900/30"
              : "border-slate-200 dark:border-slate-600 hover:border-slate-300"}`}>
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                checked={selected.includes(s.id)}
                onChange={() => onToggle(s.id)}
                className="w-4 h-4 accent-blue-600"
              />
              <span className="text-sm text-slate-700 dark:text-slate-200">{s.name}</span>
            </div>
            <span className="text-sm font-medium text-slate-600 dark:text-slate-300">
              {parseFloat(s.price) === 0 ? "Free" : `+${s.price}`}
            </span>
          </label>
        ))}
      </div>
    </div>
  )
}

function StepConfirm({ flight, seat, services, selectedServices, total }) {
  const chosenServices = services.filter(s => selectedServices.includes(s.id))
  return (
    <div className="flex flex-col gap-4">
      <p className="text-sm text-slate-500">Review your booking before confirming</p>

      <div className="bg-slate-50 dark:bg-slate-700 rounded-xl p-4 flex flex-col gap-2 text-sm">
        <Row label="Flight" value={`${flight.originAirportCode} → ${flight.destinationAirportCode}`} />
        <Row label="Airline" value={flight.airlineName} />
        <Row label="Seat" value={`Row ${seat.rowNr}, Col ${seat.colNr} · ${seat.seatType} · ${seat.classType}`} />
        <Row label="Passenger" value={localStorage.getItem("email") || "—"} />
      </div>

      {chosenServices.length > 0 && (
        <div className="bg-slate-50 dark:bg-slate-700 rounded-xl p-4 flex flex-col gap-2 text-sm">
          <p className="text-xs font-medium text-slate-400 uppercase tracking-wide mb-1">Extra services</p>
          {chosenServices.map(s => (
            <Row key={s.id} label={s.name} value={parseFloat(s.price) === 0 ? "Free" : `+${s.price} ${flight.currencyCode}`} />
          ))}
        </div>
      )}

      <div className="flex justify-between items-center border-t border-slate-200 dark:border-slate-600 pt-3">
        <span className="text-sm font-medium text-slate-600 dark:text-slate-300">Total</span>
        <span className="text-xl font-semibold text-slate-800 dark:text-white">{total} {flight.currencyCode}</span>
      </div>
    </div>
  )
}

function Row({ label, value }) {
  return (
    <div className="flex justify-between">
      <span className="text-slate-400">{label}</span>
      <span className="text-slate-700 dark:text-slate-200 font-medium">{value}</span>
    </div>
  )
}
