defmodule TorchRoomWeb.OnMount do
  @moduledoc """
  Centralised `on_mount` callbacks for LiveView sessions.
  Attach to live_session in router.ex — do not scatter mount logic across LiveViews.
  """
  @doc """
  Default mount hook. Extend this when adding authentication or session hydration.
  """
  @spec on_mount(atom(), map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:cont, Phoenix.LiveView.Socket.t()}
  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
