defmodule Temperatura do
  def iniciar do
    monitor_pid = spawn(fn -> monitor() end)
    alerta_pid = spawn(fn -> alerta() end)
    spawn(fn -> sensor(monitor_pid) end)
  end

  defp sensor(monitor_pid) do
    temperatura = :rand.uniform(90) - 30 # Genera un valor entre -30 y 60 grados Celsius
    send(monitor_pid, {:sensor, temperatura})
    send(alerta_pid, {:sensor, temperatura})
    :timer.sleep(5000)
    sensor(monitor_pid)
  end

  defp monitor do
    receive do
      {:sensor, temperatura} ->
        IO.puts("La temperatura es de: #{temperatura} grados")
        monitor()
    end
  end

  defp alerta do
    receive do
      {:sensor, temperatura} ->
        if temperatura < -10 or temperatura > 40 do
          IO.puts("Alerta de temperatura extrema: #{temperatura} grados")
        end
        alerta()
    end
  end
end

Temperatura.iniciar()
