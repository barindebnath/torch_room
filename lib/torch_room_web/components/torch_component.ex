defmodule TorchRoomWeb.TorchComponent do
  @moduledoc """
  Reusable function component rendering the SVG torch and its six directional target points.
  """

  use Phoenix.Component

  @doc """
  Renders the torch SVG with rotation and intensity cone, plus the six hover targets.

  ## Attributes
  - `angle` — current torch angle in degrees (0 | 60 | 120 | 180 | 240 | 300)
  - `intensity` — current light intensity (0–100)
  - `angles` — list of all valid angles to render as hover targets
  """
  attr :angle, :integer, required: true
  attr :intensity, :integer, required: true
  attr :angles, :list, required: true

  def torch(assigns) do
    ~H"""
    <div class="torch-wrapper">
      <%!-- Light cone: opacity driven by intensity --%>
      <div
        class="light-cone"
        style={"transform: rotate(#{@angle}deg); opacity: #{@intensity / 100};"}
      />

      <%!-- Torch body SVG --%>
      <div
        class="torch-body"
        style={"transform: rotate(#{@angle}deg);"}
      >
        <svg viewBox="0 0 40 40" width="40" height="40" class="flashlight-svg">
          <!-- Metallic Body Handle -->
          <rect
            x="17.5"
            y="16"
            width="5"
            height="18"
            fill="#3a3a4a"
            rx="1.5"
            stroke="#1a1a24"
            stroke-width="1"
          />
          <!-- Rubber grip lines -->
          <line x1="18.5" y1="20" x2="21.5" y2="20" stroke="#1a1a24" stroke-width="1" />
          <line x1="18.5" y1="24" x2="21.5" y2="24" stroke="#1a1a24" stroke-width="1" />
          <line x1="18.5" y1="28" x2="21.5" y2="28" stroke="#1a1a24" stroke-width="1" />
          <!-- On/Off Switch Button -->
          <rect x="19" y="22" width="2" height="3" fill="#ff3b30" rx="0.5" />
          <!-- Beveled Head/Reflector -->
          <path
            d="M 14 6 L 26 6 L 22.5 16 L 17.5 16 Z"
            fill="#5a5a6e"
            stroke="#1a1a24"
            stroke-width="1"
          />
          <!-- Lit Glass Lens (Glowing) -->
          <ellipse cx="20" cy="6" rx="6" ry="2" fill="#ffd700" />
          <!-- Inner bulb glow detail -->
          <circle cx="20" cy="7.5" r="1.5" fill="#ffffff" />
        </svg>
      </div>

      <%!-- Six directional hover targets --%>
      <div class="torch-targets">
        <div
          :for={target_angle <- @angles}
          id={"target-#{target_angle}"}
          class={["torch-target", target_angle == @angle && "active"]}
          style={point_style(target_angle)}
          phx-hook=".RotateOnHover"
          phx-value-angle={target_angle}
        />
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
    </div>
    """
  end

  # Positions each target point on a circle around the torch centre.
  # Returns an inline style string with `top` and `left` offsets.
  @spec point_style(integer()) :: String.t()
  defp point_style(angle_deg) do
    radius = 80
    angle_rad = angle_deg * :math.pi() / 180
    x = 50 + radius * :math.sin(angle_rad)
    y = 50 - radius * :math.cos(angle_rad)
    "top: #{Float.round(y, 2)}%; left: #{Float.round(x, 2)}%;"
  end
end
