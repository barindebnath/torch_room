defmodule TorchRoom.Torch do
  @moduledoc """
  Domain logic for torch state: valid angles and derived intensity values.
  """

  @type angle :: 0 | 60 | 120 | 180 | 240 | 300
  @type intensity :: non_neg_integer()

  @angles [0, 60, 120, 180, 240, 300]

  @doc """
  Returns the list of valid torch angles (degrees), evenly spaced around a circle.
  """
  @spec angles() :: [angle()]
  def angles, do: @angles

  @doc """
  Returns the light intensity (0–100) for a given angle.
  Intensity peaks when the torch points toward the viewer (180°)
  and dims as it rotates away.
  """
  @spec intensity(angle()) :: intensity()
  def intensity(0), do: 10
  def intensity(60), do: 30
  def intensity(120), do: 60
  def intensity(180), do: 100
  def intensity(240), do: 60
  def intensity(300), do: 30
  def intensity(_), do: 0
end
