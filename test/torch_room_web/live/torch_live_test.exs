defmodule TorchRoomWeb.TorchLiveTest do
  use TorchRoomWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "mounts with default angle 180 and intensity 25", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "rotate(180deg)"
      assert html =~ "opacity: 0.25"
    end
  end

  describe "rotate event" do
    test "hovering over 0 degrees zone points to 0 degrees with intensity 100", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      html =
        view
        |> element("[phx-value-angle='0']")
        |> render_hook("rotate", %{"angle" => "0"})

      assert html =~ "rotate(360deg)"
      assert html =~ "opacity: 1"
    end

    test "hovering over 180 degrees zone points to 180 degrees with intensity 25", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      html =
        view
        |> element("[phx-value-angle='180']")
        |> render_hook("rotate", %{"angle" => "180"})

      assert html =~ "rotate(180deg)"
      assert html =~ "opacity: 0.25"
    end

    test "ignores invalid angle values", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      html = render_hook(view, "rotate", %{"angle" => "999"})
      # Socket state remains default (180deg / 25%)
      assert html =~ "rotate(180deg)"
      assert html =~ "opacity: 0.25"
    end
  end
end
