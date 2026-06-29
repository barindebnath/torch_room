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
       display_angle: initial_angle,
       intensity: Torch.intensity(initial_angle),
       angles: Torch.angles()
     )}
  end

  @impl true
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("rotate", %{"angle" => raw_angle}, socket) do
    case Integer.parse(raw_angle) do
      {target_angle, ""} when target_angle in [0, 60, 120, 180, 240, 300] ->
        current_display_angle = socket.assigns.display_angle
        new_display_angle = shortest_path_angle(current_display_angle, target_angle)

        {:noreply,
         assign(socket,
           angle: target_angle,
           display_angle: new_display_angle,
           intensity: Torch.intensity(target_angle)
         )}

      _ ->
        Logger.warning("Received invalid torch angle: #{inspect(raw_angle)}")
        {:noreply, socket}
    end
  end

  defp shortest_path_angle(current_angle, target_angle) do
    d = rem(target_angle - current_angle, 360)

    cond do
      d > 180 -> current_angle + d - 360
      d <= -180 -> current_angle + d + 360
      true -> current_angle + d
    end
  end

  @spec wall_opacity(atom(), integer()) :: float()
  defp wall_opacity(surface_name, angle) do
    target_angles = [0, 60, 120, 180, 240, 300]

    closest =
      Enum.min_by(target_angles, fn t ->
        d = abs(t - angle)
        min(d, 360 - d)
      end)

    case {surface_name, closest} do
      {:left_wall, 300} -> 0.9
      {:left_wall, 240} -> 0.6
      {:left_wall, 0} -> 0.3
      {:left_wall, _} -> 0.0
      {:right_wall, 60} -> 0.9
      {:right_wall, 120} -> 0.6
      {:right_wall, 0} -> 0.3
      {:right_wall, _} -> 0.0
      {:floor, 180} -> 0.9
      {:floor, t} when t in [120, 240] -> 0.5
      {:floor, 0} -> 0.3
      {:floor, _} -> 0.0
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <!-- GitHub corner logo link -->
      <a
        href="https://github.com/barindebnath/torch_room"
        target="_blank"
        rel="noopener noreferrer"
        class="github-corner-link"
        title="View Source on GitHub"
      >
        <svg viewBox="0 0 16 16" width="24" height="24" fill="currentColor">
          <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
        </svg>
      </a>

      <div class="room-page-container">
        <div class="room-box-wrapper">
          <div id="torch-room" class="torch-room">
            <!-- 3D Isometric Zoomed Out Room SVG -->
            <svg
              class="room-3d-bg"
              viewBox="0 0 800 600"
              width="100%"
              height="100%"
              preserveAspectRatio="none"
            >
              <defs>
                <!-- Wall Gradients (Inside faces) -->
                <linearGradient id="leftWallGrad" x1="0" y1="0.5" x2="1" y2="0.5">
                  <stop offset="0%" stop-color="#020205" />
                  <stop offset="100%" stop-color="#080810" />
                </linearGradient>
                <linearGradient id="rightWallGrad" x1="1" y1="0.5" x2="0" y2="0.5">
                  <stop offset="0%" stop-color="#020205" />
                  <stop offset="100%" stop-color="#080810" />
                </linearGradient>

                <!-- ── LIGHTING OVERLAY GRADIENTS (Absolute space centered at 400,350) ── -->
                <radialGradient
                  id="leftWallLight"
                  cx="400"
                  cy="350"
                  r="300"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop offset="0%" stop-color="#ffd700" stop-opacity="0.4" />
                  <stop offset="100%" stop-color="#ffd700" stop-opacity="0.0" />
                </radialGradient>
                <radialGradient
                  id="rightWallLight"
                  cx="400"
                  cy="350"
                  r="300"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop offset="0%" stop-color="#ffd700" stop-opacity="0.4" />
                  <stop offset="100%" stop-color="#ffd700" stop-opacity="0.0" />
                </radialGradient>
                <radialGradient
                  id="floorLight"
                  cx="400"
                  cy="350"
                  r="250"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop offset="0%" stop-color="#ffd700" stop-opacity="0.45" />
                  <stop offset="100%" stop-color="#ffd700" stop-opacity="0.0" />
                </radialGradient>
              </defs>

              <!-- ── 1. FLOOR SLAB (3D Block) ── -->
              <!-- Floor Top Face -->
              <polygon points="150,350 400,230 650,350 400,470" fill="#0c0c16" />
              <!-- Floor Front-Left thickness -->
              <polygon points="150,350 400,470 400,490 150,370" fill="#06060c" />
              <!-- Floor Front-Right thickness -->
              <polygon points="400,470 650,350 650,370 400,490" fill="#080812" />

              <!-- ── 2. WALLS (3D Blocks) ── -->
              <!-- Left Wall Inside Face -->
              <polygon points="150,350 400,230 400,50 150,170" fill="url(#leftWallGrad)" />
              <!-- Left Wall Top Face (Thickness) -->
              <polygon points="150,170 400,50 380,40 130,160" fill="#141424" />
              <!-- Left Wall Outer Side Face -->
              <polygon points="130,160 130,340 150,350 150,170" fill="#040408" />

              <!-- Right Wall Inside Face -->
              <polygon points="400,230 650,350 650,170 400,50" fill="url(#rightWallGrad)" />
              <!-- Right Wall Top Face (Thickness) -->
              <polygon points="650,170 400,50 420,40 670,160" fill="#141424" />
              <!-- Right Wall Outer Side Face -->
              <polygon points="670,160 670,340 650,350 650,170" fill="#040408" />

              <!-- ── 3. INTERACTIVE LIGHTING OVERLAYS (Reactive) ── -->
              <!-- Floor Light overlay -->
              <polygon
                points="150,350 400,230 650,350 400,470"
                fill="url(#floorLight)"
                opacity={wall_opacity(:floor, @angle)}
                style="transition: opacity 0.4s ease-in-out; pointer-events: none;"
              />
              <!-- Left Wall Light overlay -->
              <polygon
                points="150,350 400,230 400,50 150,170"
                fill="url(#leftWallLight)"
                opacity={wall_opacity(:left_wall, @angle)}
                style="transition: opacity 0.4s ease-in-out; pointer-events: none;"
              />
              <!-- Right Wall Light overlay -->
              <polygon
                points="400,230 650,350 650,170 400,50"
                fill="url(#rightWallLight)"
                opacity={wall_opacity(:right_wall, @angle)}
                style="transition: opacity 0.4s ease-in-out; pointer-events: none;"
              />

              <!-- ── 4. OUTLINE EDGE LINES (3D Details) ── -->
              <!-- Junction lines (Inside corners) -->
              <line x1="400" y1="230" x2="400" y2="50" stroke="#1f1f2e" stroke-width="1.5" />
              <line x1="150" y1="350" x2="400" y2="230" stroke="#1c1c2a" stroke-width="1" />
              <line x1="650" y1="350" x2="400" y2="230" stroke="#1c1c2a" stroke-width="1" />

              <!-- Outer/Top edges -->
              <line x1="150" y1="170" x2="400" y2="50" stroke="#252538" stroke-width="1" />
              <line x1="650" y1="170" x2="400" y2="50" stroke="#252538" stroke-width="1" />

              <!-- ── 4.5. 2D FLAT TARGET DECALS ── -->
              <!-- Upper Left Wall Target (300°) -->
              <g class="target-decal">
                <circle
                  cx="275"
                  cy="155"
                  r="8"
                  fill="none"
                  stroke={if @angle == 300, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 300, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="275"
                  cy="155"
                  r="3"
                  fill={if @angle == 300, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 300, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- Lower Left Wall Target (240°) -->
              <g class="target-decal">
                <circle
                  cx="275"
                  cy="245"
                  r="8"
                  fill="none"
                  stroke={if @angle == 240, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 240, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="275"
                  cy="245"
                  r="3"
                  fill={if @angle == 240, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 240, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- Upper Right Wall Target (60°) -->
              <g class="target-decal">
                <circle
                  cx="525"
                  cy="155"
                  r="8"
                  fill="none"
                  stroke={if @angle == 60, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 60, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="525"
                  cy="155"
                  r="3"
                  fill={if @angle == 60, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 60, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- Lower Right Wall Target (120°) -->
              <g class="target-decal">
                <circle
                  cx="525"
                  cy="245"
                  r="8"
                  fill="none"
                  stroke={if @angle == 120, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 120, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="525"
                  cy="245"
                  r="3"
                  fill={if @angle == 120, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 120, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- Back Floor Target (0°) -->
              <g class="target-decal">
                <circle
                  cx="400"
                  cy="310"
                  r="8"
                  fill="none"
                  stroke={if @angle == 0, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 0, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="400"
                  cy="310"
                  r="3"
                  fill={if @angle == 0, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 0, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- Front Floor Target (180°) -->
              <g class="target-decal">
                <circle
                  cx="400"
                  cy="410"
                  r="8"
                  fill="none"
                  stroke={if @angle == 180, do: "#ffd700", else: "#484860"}
                  stroke-width="1.2"
                  stroke-dasharray="2,2"
                  opacity={if @angle == 180, do: "0.9", else: "0.4"}
                  style="transition: stroke 0.4s ease, opacity 0.4s ease;"
                />
                <circle
                  cx="400"
                  cy="410"
                  r="3"
                  fill={if @angle == 180, do: "#ffd700", else: "#35354a"}
                  opacity={if @angle == 180, do: "1.0", else: "0.5"}
                  style="transition: fill 0.4s ease, opacity 0.4s ease;"
                />
              </g>

              <!-- ── 5. TRANSPARENT HOVER ZONES (OVERLAYS) ── -->
              <!-- Upper Left Wall Zone (300°) -->
              <polygon
                id="zone-300"
                points="150,170 400,50 400,140 150,260"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="300"
              />
              <!-- Lower Left Wall Zone (240°) -->
              <polygon
                id="zone-240"
                points="150,260 400,140 400,230 150,350"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="240"
              />
              <!-- Upper Right Wall Zone (60°) -->
              <polygon
                id="zone-60"
                points="400,50 650,170 650,260 400,140"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="60"
              />
              <!-- Lower Right Wall Zone (120°) -->
              <polygon
                id="zone-120"
                points="400,140 650,260 650,350 400,230"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="120"
              />
              <!-- Back Floor Zone (0°) -->
              <polygon
                id="zone-0"
                points="150,350 400,230 650,350 400,350"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="0"
              />
              <!-- Front Floor Zone (180°) -->
              <polygon
                id="zone-180"
                points="150,350 400,350 650,350 400,470"
                fill="white"
                opacity="0"
                style="cursor: pointer; pointer-events: auto;"
                phx-hook=".RotateOnHover"
                phx-value-angle="180"
              />
            </svg>

            <TorchRoomWeb.TorchComponent.torch
              angle={@angle}
              display_angle={@display_angle}
              intensity={@intensity}
              angles={@angles}
            />
          </div>
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
      </div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".RotateOnHover">
        export default {
          mounted() {
            this.el.addEventListener("mouseenter", () => {
              let angle = this.el.getAttribute("phx-value-angle")
              this.pushEvent("rotate", { angle: angle })
            })
          }
        }
      </script>
    </Layouts.app>
    """
  end
end
