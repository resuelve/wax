defmodule WhatsappCache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init do
    {:ok, Map.new()}
  end

  def add(url, result) do
    GenServer.call(__MODULE__, {:add, url, result})
  end

  def get(url) do
    GenServer.call(__MODULE__, {:get, url})
  end

  def handle_call({:get, url}, _from, state) do
    result = Map.get(state, url)
    {:reply, result, state}
  end

  def handle_cast({:add, url, result}, state) do
    new_state = Map.put(state, url, result)
    {:noreply, new_state}
  end
end
