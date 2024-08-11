defmodule GTemperatura do
  use GenServer

  def start_link do
    IO.puts("[GTemperatura] iniciando el sensor!")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def sensor do
    temperatura = :rand.uniform(90) - 30
    GenServer.call(__MODULE__, {:monitor, temperatura})
    GenServer.call(__MODULE__, {:alerta, temperatura})
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:monitor, temperatura}, _from, state) do
    {:reply, "La temperatura es de: #{temperatura} grados", state}
  end

  @impl true
  def handle_call({:alerta, temperatura}, _from, state) do
    if temperatura < -10 or temperatura > 40 do
      {:reply, "Alerta de temperatura extrema: #{temperatura} grados", state}
    else
      {:reply, "Temperatura normal: #{temperatura} grados", state}
    end
  end


  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end


  @impl true
  def handle_cast({:monitor, temperatura, caller}, state) do
    Process.send_after(caller, {:result, "La temperatura es de: #{temperatura} grados"}, 2000)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:alerta, temperatura, caller}, state) do
    Process.send_after(caller, {:result, "Alerta de temperatura extrema: #{temperatura} grados"}, 2000)
    {:noreply, state}
  end
end
