import { useEffect, useMemo, useState } from "react"

export default function BookingModal({ flight, onClose, onComplete }) {
  const [seatMap, setSeatMap] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")
  const [selectedSeats, setSelectedSeats] = useState([])
  const [selectedServices, setSelectedServices] = useState([])
  const [passengers, setPassengers] = useState([])
  const [step, setStep] = useState(1)
  const [bookingResult, setBookingResult] = useState(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    setLoading(true)
    setError("")
    setSeatMap(null)

    fetch(`http://localhost:8080/api/flights/${flight.id}/seat-map`)
      .then(async (res) => {
        if (!res.ok) {
          const text = await res.text()
          throw new Error(text || "Failed to load seat map")
        }
        return res.json()
      })
      .then((data) => {
        setSeatMap(data)
      })
      .catch((err) => {
        setError(err.message || "Unable to load seat map.")
      })
      .finally(() => setLoading(false))
  }, [flight.id])

  useEffect(() => {
    if (!seatMap) return
    setSelectedSeats([])
    setSelectedServices([])
    setPassengers([])
    setBookingResult(null)
    setStep(1)
  }, [seatMap])

  useEffect(() => {
    setPassengers((current) => selectedSeats.map((seat, index) => {
      const existing = current[index]
      return {
        seatLabel: seat,
        firstName: existing?.firstName ?? "",
        lastName: existing?.lastName ?? "",
      }
    }))
  }, [selectedSeats])

  const availableSeatCount = seatMap?.seats.filter((seat) => seat.status === "available").length ?? 0
  const maxSelection = Math.min(availableSeatCount, 6)

  const seatRows = useMemo(() => {
    if (!seatMap) return []
    const rows = [...new Set(seatMap.seats.map((seat) => seat.row))].sort((a, b) => a - b)
    return rows.map((row) => seatMap.seats.filter((seat) => seat.row === row).sort((a, b) => a.col - b.col))
  }, [seatMap])

  const isValidPassenger = (passenger) => passenger.firstName.trim() && passenger.lastName.trim()

  const canProceedToNext = () => {
    if (step === 1) return selectedSeats.length > 0
    if (step === 2) return true
    if (step === 3) return passengers.length > 0 && passengers.every(isValidPassenger)
    if (step === 4) return true
    return false
  }

  const toggleSeat = (label) => {
    if (!seatMap) return
    const seat = seatMap.seats.find((item) => item.label === label)
    if (!seat || seat.status !== "available") return

    setSelectedSeats((current) => {
      if (current.includes(label)) {
        return current.filter((value) => value !== label)
      }
      if (current.length >= maxSelection) return current
      return [...current, label]
    })
  }

  const addPassenger = () => {
    if (!seatMap || selectedSeats.length >= maxSelection) return
    const nextSeat = seatMap.seats.find((seat) => seat.status === "available" && !selectedSeats.includes(seat.label))
    if (nextSeat) {
      setSelectedSeats((current) => [...current, nextSeat.label])
    }
  }

  const toggleService = (serviceId) => {
    setSelectedServices((current) =>
      current.includes(serviceId)
        ? current.filter((id) => id !== serviceId)
        : [...current, serviceId]
    )
  }

  const updatePassenger = (index, field, value) => {
    setPassengers((current) => current.map((passenger, i) => (
      i === index ? { ...passenger, [field]: value } : passenger
    )))
  }

  const handleConfirm = async () => {
    if (!canProceedToNext()) return
    if (!seatMap) return

    setError("")
    setIsSubmitting(true)

    const requestBody = {
      flightId: flight.id,
      passengers,
      serviceIds: selectedServices,
    }

    try {
      const token = localStorage.getItem("token")
      const response = await fetch("http://localhost:8080/api/reservations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: token ? `Bearer ${token}` : "",
        },
        body: JSON.stringify(requestBody),
      })

      if (!response.ok) {
        const text = await response.text()
        throw new Error(text || "Booking request failed")
      }

      const result = await response.json()
      setBookingResult(result)
      setStep(4)
      const boardingTicket = {
        id: result.reservationId ?? `${flight.id}-${Date.now()}`,
        reservationId: result.reservationId,
        flightId: flight.id,
        airlineName: flight.airlineName,
        flightNumber: flight.flightNumber ?? "",
        originCity: flight.originCity,
        destinationCity: flight.destinationCity,
        departureDate: flight.departureDate || flight.departureTime || flight.date || "",
        seatLabels: selectedSeats,
        passengers,
        services: seatMap.services.filter((service) => selectedServices.includes(service.id)),
        totalPrice,
        bookedAt: new Date().toISOString(),
      }
      onComplete?.({ ticketCount: selectedSeats.length, tickets: [boardingTicket] })
    } catch (err) {
      setError(err.message || "Reservation failed. Please try again.")
    } finally {
      setIsSubmitting(false)
    }
  }

  const serviceTotal = seatMap?.services.reduce(
    (sum, service) => selectedServices.includes(service.id) ? sum + Number(service.price ?? 0) : sum,
    0
  ) ?? 0
  const totalPrice = flight.price ? (Number(flight.price) + serviceTotal) * selectedSeats.length : 0

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/70 p-4">
      <div className="w-full max-w-5xl rounded-3xl bg-white dark:bg-slate-900 shadow-2xl ring-1 ring-slate-200 dark:ring-slate-700 overflow-hidden">
        <div className="flex items-center justify-between px-6 py-5 border-b border-slate-200 dark:border-slate-700">
          <div>
            <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Flight booking</h2>
            <p className="text-sm text-slate-500 dark:text-slate-400">{flight.originCity} → {flight.destinationCity} • {flight.airlineName}</p>
          </div>
          <button onClick={onClose} className="text-slate-500 hover:text-slate-900 dark:hover:text-white text-sm">Close</button>
        </div>

        <div className="px-6 py-5">
          <div className="flex flex-wrap gap-2 text-xs font-medium text-slate-500 uppercase tracking-wide mb-4">
            <span className={step === 1 ? "text-blue-700" : ""}>1. Seat</span>
            <span className={step === 2 ? "text-blue-700" : ""}>2. Services</span>
            <span className={step === 3 ? "text-blue-700" : ""}>3. Passengers</span>
            <span className={step === 4 ? "text-blue-700" : ""}>4. Confirmation</span>
          </div>

          {loading && <p className="text-slate-500 text-center">Loading seat map…</p>}
          {error && !loading && <p className="text-red-600 text-center mb-4">{error}</p>}

          {!loading && seatMap && !bookingResult && (
            <>
              {step === 1 && (
                <div className="space-y-4">
                  <div className="relative overflow-hidden rounded-3xl bg-slate-50 dark:bg-slate-800 p-4">
                    <div className="pointer-events-none absolute inset-0 opacity-25">
                      <svg viewBox="0 0 640 280" className="h-full w-full" preserveAspectRatio="xMidYMid slice">
                        <defs>
                          <linearGradient id="planeGradient" x1="0" x2="1" y1="0" y2="1">
                            <stop offset="0%" stopColor="rgba(15,23,42,0.18)" />
                            <stop offset="100%" stopColor="rgba(148,163,184,0.05)" />
                          </linearGradient>
                        </defs>
                        <path d="M100 220 C140 150, 220 120, 310 120 C400 120, 480 150, 520 220 C560 270, 640 280, 640 280 L0 280 C0 280, 80 270, 100 220 Z" fill="url(#planeGradient)" />
                        <path d="M320 120 L340 90 L370 90 L370 100 L410 100 L410 110 L370 110 L370 120 L340 120 Z" fill="rgba(15,23,42,0.18)" />
                        <path d="M240 130 L240 90 L260 90 L260 130 Z" fill="rgba(15,23,42,0.16)" />
                        <path d="M380 130 L380 90 L400 90 L400 130 Z" fill="rgba(15,23,42,0.16)" />
                        <circle cx="320" cy="140" r="36" fill="rgba(15,23,42,0.08)" />
                      </svg>
                    </div>
                    <div className="relative flex items-center justify-between gap-4 mb-4">
                      <div>
                        <p className="text-sm text-slate-500">Select seats</p>
                        <p className="text-base font-semibold text-slate-900 dark:text-slate-100">Pick up to {maxSelection} passenger{maxSelection > 1 ? "s" : ""}</p>
                      </div>
                      <button
                        type="button"
                        onClick={addPassenger}
                        disabled={selectedSeats.length >= maxSelection || availableSeatCount === 0}
                        className="rounded-xl bg-blue-700 hover:bg-blue-800 px-4 py-2 text-sm font-medium text-white disabled:cursor-not-allowed disabled:bg-slate-300"
                      >
                        Add next seat
                      </button>
                    </div>
                    <div className="relative space-y-2 rounded-3xl border border-slate-200 bg-white/90 p-4 shadow-sm dark:border-slate-700 dark:bg-slate-950/70">
                      {seatRows.map((rowSeats) => (
                        <div key={rowSeats[0]?.row} className="flex items-center gap-2">
                          <div className="w-8 text-sm font-semibold text-slate-500">Row {rowSeats[0]?.row}</div>
                          <div className="grid grid-cols-10 gap-2 flex-1">
                            {rowSeats.map((seat) => {
                              const selected = selectedSeats.includes(seat.label)
                              return (
                                <button
                                  key={seat.label}
                                  type="button"
                                  onClick={() => toggleSeat(seat.label)}
                                  disabled={seat.status !== "available" && !selected}
                                  className={`rounded-2xl border px-3 py-2 text-sm font-semibold transition ${
                                    seat.status === "occupied"
                                      ? "border-slate-300 bg-slate-200 text-slate-500 cursor-not-allowed"
                                      : selected
                                      ? "border-blue-700 bg-blue-700 text-white"
                                      : "border-slate-300 bg-white text-slate-700 hover:border-blue-500 hover:text-blue-800"
                                  }`}
                                >
                                  {seat.label}
                                </button>
                              )
                            })}
                          </div>
                        </div>
                      ))}
                    </div>
                    <div className="mt-4 flex flex-wrap gap-3 text-xs text-slate-500">
                      <span>{selectedSeats.length} selected</span>
                      <span>{availableSeatCount} available</span>
                      <span>{seatMap.seats.filter((seat) => seat.status === "occupied").length} occupied</span>
                    </div>
                  </div>
                </div>
              )}

              {step === 2 && (
                <div className="space-y-4">
                  <div className="rounded-3xl bg-slate-50 dark:bg-slate-800 p-4">
                    <p className="text-sm text-slate-500 mb-4">Pick additional services for your booking.</p>
                    <div className="grid gap-3 sm:grid-cols-2">
                      {seatMap.services.map((service) => (
                        <label key={service.id} className="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white dark:bg-slate-900 p-3 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={selectedServices.includes(service.id)}
                            onChange={() => toggleService(service.id)}
                            className="h-4 w-4 rounded text-blue-600"
                          />
                          <div>
                            <div className="font-medium text-slate-900 dark:text-slate-100">{service.serviceName}</div>
                            <div className="text-sm text-slate-500">+{seatMap.currencyCode} {service.price}</div>
                          </div>
                        </label>
                      ))}
                      {seatMap.services.length === 0 && (
                        <p className="text-sm text-slate-500">No additional services available for this flight.</p>
                      )}
                    </div>
                  </div>
                </div>
              )}

              {step === 3 && (
                <div className="space-y-4">
                  <div className="rounded-3xl bg-slate-50 dark:bg-slate-800 p-4">
                    <div className="flex items-center justify-between gap-4 mb-4">
                      <div>
                        <p className="text-sm text-slate-500">Passenger details</p>
                        <p className="text-base font-semibold text-slate-900 dark:text-slate-100">{passengers.length} passenger{passengers.length > 1 ? "s" : ""}</p>
                      </div>
                      <button
                        type="button"
                        onClick={addPassenger}
                        disabled={selectedSeats.length >= maxSelection}
                        className="rounded-xl bg-blue-700 hover:bg-blue-800 px-4 py-2 text-sm font-medium text-white disabled:cursor-not-allowed disabled:bg-slate-300"
                      >
                        Add passenger
                      </button>
                    </div>
                    <div className="space-y-4">
                      {passengers.map((passenger, index) => (
                        <div key={passenger.seatLabel} className="rounded-2xl border border-slate-200 bg-white dark:bg-slate-900 p-4 grid gap-3 sm:grid-cols-3">
                          <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">First name</label>
                            <input
                              value={passenger.firstName}
                              onChange={(e) => updatePassenger(index, "firstName", e.target.value)}
                              className="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm bg-slate-50 dark:bg-slate-800 dark:text-white"
                            />
                          </div>
                          <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Last name</label>
                            <input
                              value={passenger.lastName}
                              onChange={(e) => updatePassenger(index, "lastName", e.target.value)}
                              className="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm bg-slate-50 dark:bg-slate-800 dark:text-white"
                            />
                          </div>
                          <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Seat</label>
                            <input
                              value={passenger.seatLabel}
                              readOnly
                              className="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm bg-slate-50 dark:bg-slate-800 dark:text-white"
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </>
          )}

          {!loading && bookingResult && (
            <div className="space-y-4">
              <div className="rounded-3xl bg-slate-50 dark:bg-slate-800 p-4">
                <h3 className="font-semibold text-slate-900 dark:text-slate-100 mb-3">Booking summary</h3>
                <div className="grid gap-3 sm:grid-cols-2">
                  <div className="rounded-2xl bg-white dark:bg-slate-900 p-4">
                    <p className="text-xs uppercase tracking-wide text-slate-500 mb-2">Flight</p>
                    <p className="font-medium text-slate-900 dark:text-slate-100">{flight.originAirportCode} → {flight.destinationAirportCode}</p>
                    <p className="text-sm text-slate-500">{new Date(flight.departureDatetime).toLocaleDateString()}</p>
                  </div>
                  <div className="rounded-2xl bg-white dark:bg-slate-900 p-4">
                    <p className="text-xs uppercase tracking-wide text-slate-500 mb-2">Total</p>
                    <p className="font-medium text-slate-900 dark:text-slate-100">{seatMap.currencyCode} {bookingResult.totalAmount}</p>
                    <p className="text-sm text-slate-500">{bookingResult.passengerCount} passenger{bookingResult.passengerCount > 1 ? "s" : ""}</p>
                  </div>
                </div>
                <div className="mt-4 rounded-2xl bg-white dark:bg-slate-900 p-4">
                  <h4 className="text-sm font-semibold text-slate-900 dark:text-slate-100 mb-2">Seats</h4>
                  <p className="text-sm text-slate-500">{bookingResult.seatLabels.join(", ")}</p>
                </div>
                {selectedServices.length > 0 ? (
                  <div className="rounded-2xl bg-white dark:bg-slate-900 p-4">
                    <h4 className="text-sm font-semibold text-slate-900 dark:text-slate-100 mb-2">Services</h4>
                    <ul className="text-sm text-slate-500 space-y-1">
                      {selectedServices.map((serviceId) => {
                        const service = seatMap.services.find((item) => item.id === serviceId)
                        return <li key={serviceId}>{service?.serviceName} (+{seatMap.currencyCode} {service?.price})</li>
                      })}
                    </ul>
                  </div>
                ) : (
                  <div className="rounded-2xl bg-white dark:bg-slate-900 p-4">
                    <p className="text-sm text-slate-500">No additional services selected.</p>
                  </div>
                )}
              </div>
            </div>
          )}

          <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex gap-2">
              {step > 1 && !bookingResult && (
                <button
                  type="button"
                  onClick={() => setStep((current) => Math.max(1, current - 1))}
                  className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-800"
                >
                  Back
                </button>
              )}
              {step < 4 && !bookingResult && (
                <button
                  type="button"
                  onClick={() => {
                    if (canProceedToNext()) setStep((current) => Math.min(4, current + 1))
                  }}
                  className="rounded-xl bg-blue-700 hover:bg-blue-800 px-4 py-2 text-sm font-medium text-white disabled:cursor-not-allowed disabled:bg-slate-300"
                  disabled={!canProceedToNext()}
                >
                  Continue
                </button>
              )}
            </div>
            {!bookingResult && step === 4 && (
              <button
                type="button"
                onClick={handleConfirm}
                disabled={isSubmitting}
                className="rounded-xl bg-emerald-600 hover:bg-emerald-700 px-5 py-3 text-sm font-semibold text-white disabled:opacity-60"
              >
                {isSubmitting ? "Confirming..." : "Confirm booking"}
              </button>
            )}
            {bookingResult && (
              <button
                type="button"
                onClick={onClose}
                className="rounded-xl bg-blue-700 hover:bg-blue-800 px-5 py-3 text-sm font-semibold text-white"
              >
                Close booking
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
