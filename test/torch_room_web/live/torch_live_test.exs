defmodule TorchRoomWeb.TorchLiveTest do
  use TorchRoomWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "mounts with default angle 180 and intensity 100", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "rotate(180deg)"
      assert html =~ "opacity: 1"
    end
  end

  describe "rotate event" do
    test "rotating to 0 degrees sets intensity to 10%", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      html =
        view
        |> element("[phx-value-angle='0']")
        |> render_hook("rotate", %{"angle" => "0"})

      assert html =~ "rotate(360deg)"
      assert html =~ "opacity: 0.1"
    end

    test "rotating to 180 degrees sets intensity to 100%", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      html =
        view
        |> element("[phx-value-angle='180']")
        |> render_hook("rotate", %{"angle" => "180"})

      assert html =~ "opacity: 1"
    end

    test "ignores invalid angle values", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      html = render_hook(view, "rotate", %{"angle" => "999"})
      # Socket state remains default (180deg / 100%)
      assert html =~ "rotate(180deg)"
      assert html =~ "opacity: 1"
      assert html =~ "180°"
      assert html =~ "100%"
    end
  end
end
