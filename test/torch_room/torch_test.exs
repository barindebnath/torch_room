defmodule TorchRoom.TorchTest do
  use ExUnit.Case, async: true

  alias TorchRoom.Torch

  describe "intensity/1" do
    test "returns 100 at 180 degrees (pointing toward viewer)" do
      assert Torch.intensity(180) == 100
    end

    test "returns 10 at 0 degrees (pointing away)" do
      assert Torch.intensity(0) == 10
    end

    test "is symmetric around 180 degrees" do
      assert Torch.intensity(60) == Torch.intensity(300)
      assert Torch.intensity(120) == Torch.intensity(240)
    end

    test "returns 0 for invalid angles" do
      assert Torch.intensity(45) == 0
    end
  end

  describe "angles/0" do
    test "returns exactly 6 angles" do
      assert length(Torch.angles()) == 6
    end

    test "all angles are multiples of 60" do
      assert Enum.all?(Torch.angles(), fn a -> rem(a, 60) == 0 end)
    end
  end
end
