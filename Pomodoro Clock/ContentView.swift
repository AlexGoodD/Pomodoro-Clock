import SwiftUI

struct ContentView: View {
    @State private var tiempoRestante = 1 // 1 segundo para pruebas
    @State private var tiempoTrabajo = 1 // 1 segundo para pruebas
    @State private var tiempoDescanso = 2 // 2 segundos para pruebas
    @State private var tiempoDescansoLargo = 3 // 2 segundos para pruebas
    @State private var enTrabajo = true
    @State private var cicloContador = 0 // No. veces que se hace un ciclo
    @State private var progresoActual: CGFloat = 0.0 // Progreso actual
    @State private var temporizador: Timer?

    var body: some View {
        ZStack {
            
            //Fondo blanco
            RoundedRectangle(cornerRadius: 32.0)
                .fill(Color.white)
                .frame(width: 315, height: 315)

            // Fondo borde progreso
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(enTrabajo ? Color.red.opacity(0.2) : Color.blue.opacity(0.2), lineWidth: 15)
                .frame(width: 300, height: 300)
            
            // Borde progreso
            RoundedRectangle(cornerRadius: 25.0)
                .trim(from: 0.0, to: progresoActual)
                .stroke(enTrabajo ? Color.red : Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: 300, height: 300)
                .animation(.linear(duration: 1), value: progresoActual)

            // Elementos dentro del reloj
            VStack {
                RollingNumber(targetValue: $cicloContador)
                    .font(.system(size: 20))
                    .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                    .foregroundColor(.white)
                    .clipShape(Circle())

                Text("\(formatearTiempo(tiempoRestante))")
                    .font(.system(size: 72, weight: .semibold, design: .monospaced))
                    .foregroundColor(.brown)

                HStack {
                    Button(action: temporizador == nil ? iniciarTemporizador : detenerTemporizador) {
                        Image(systemName: temporizador == nil ? "play.fill" : "pause.fill")
                            .font(.system(size: 15))
                            .padding(10)
                            .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: terminarTemporizador) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15))
                            .padding(10)
                            .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .onAppear {
            progresoActual = calcularProgreso()
        }
    }
    
    // Formato de numeros

    func formatearTiempo(_ segundosTotales: Int) -> String {
        let minutos = segundosTotales / 60
        let segundos = segundosTotales % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }

    func iniciarTemporizador() {
        if temporizador != nil { return }
        temporizador = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if tiempoRestante > 0 {
                tiempoRestante -= 1
                progresoActual = calcularProgreso()
            } else {
                enTrabajo.toggle()
                cicloContador = enTrabajo ? cicloContador : min(9, cicloContador + 1)

                if !enTrabajo {
                    if cicloContador == 4 || cicloContador == 8 {
                        tiempoRestante = tiempoDescansoLargo
                    } else {
                        tiempoRestante = tiempoDescanso
                    }
                } else {
                    tiempoRestante = tiempoTrabajo
                }

                progresoActual = 0.0
            }
        }
    }


    func detenerTemporizador() {
        temporizador?.invalidate()
        temporizador = nil
    }

    // Reinicia todos los elementos
    func terminarTemporizador() {
        detenerTemporizador()
        tiempoRestante = tiempoTrabajo
        enTrabajo = true
        progresoActual = 0.0
        cicloContador = 0
    }

    func calcularProgreso() -> CGFloat {
            let tiempoTotal: Int
            
            if enTrabajo {
                tiempoTotal = tiempoTrabajo
            } else {
                tiempoTotal = (cicloContador == 4 || cicloContador == 8) ? tiempoDescansoLargo : tiempoDescanso
            }
            
            return CGFloat(tiempoTotal - tiempoRestante) / CGFloat(tiempoTotal)
        }
    }

#Preview {
    ContentView()
}
