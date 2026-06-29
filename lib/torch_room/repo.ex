defmodule TorchRoom.Repo do
  use Ecto.Repo,
    otp_app: :torch_room,
    adapter: Ecto.Adapters.Postgres
end
