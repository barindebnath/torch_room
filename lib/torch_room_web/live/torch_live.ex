defmodule TorchRoomWeb.TorchLive do
  @moduledoc """
  LiveView for the torch room. Manages torch angle and derived intensity in socket assigns.
  """

  use TorchRoomWeb, :live_view

  require Logger

  alias TorchRoom.Torch

  @impl true
  @spec mount(map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    initial_angle = 180

    {:ok,
     assign(socket,
       angle: initial_angle,
       intensity: Torch.intensity(initial_angle),
       angles: Torch.angles()
     )}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("rotate", %{"angle" => raw_angle}, socket) do
    case Integer.parse(raw_angle) do
      {angle, ""} when angle in [0, 60, 120, 180, 240, 300] ->
        {:noreply,
         assign(socket,
           angle: angle,
           intensity: Torch.intensity(angle)
         )}

      _ ->
        Logger.warning("Received invalid torch angle: #{inspect(raw_angle)}")
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="torch-room" class="torch-room">
        <TorchRoomWeb.TorchComponent.torch
          angle={@angle}
          intensity={@intensity}
          angles={@angles}
        />
      </div>

      <div class="torch-dashboard">
        <div class="dashboard-stat">
          <span class="stat-label">Angle</span>
          <span class="stat-value">{@angle}°</span>
        </div>
        <div class="dashboard-stat">
          <span class="stat-label">Intensity</span>
          <span class="stat-value">{@intensity}%</span>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
