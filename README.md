# TorchRoom

TorchRoom is a premium, interactive web application built with **Elixir** and **Phoenix LiveView** that simulates a dark room illuminated dynamically by a rotating flashlight. 

The room is rendered as a floating 3D isometric mockup. Moving your cursor over different walls or floor surfaces rotates the central flashlight towards your cursor, dynamically changing the lighting gradients and surface reflections.

## Features

- **3D Isometric Block**: An open-top isometric room model showing walls with flat thickness top-faces, outer side faces, and floor slab depth.
- **Surface-based Interaction**: Transparent SVG polygon overlays map mouse hovers directly to the room's interior walls and floor.
- **2D Flat Target Decals**: Minimalist, flat target circular indicators placed on each region. Hovering over a target highlights it in glowing gold, while others remain dim grey.
- **Dynamic Radial Lighting**: Translucent surface overlays calculate reflections dynamically based on the flashlight's angle.
- **High Contrast Styling**: Immersive viewport centering with shadow boundaries on a sleek slate-indigo `#222235` backdrop.
- **Interactive JS Hooks**: Uses a colocated Phoenix LiveView JS hook (`RotateOnHover`) to handle mouse interactions efficiently.

---

## Technical Stack & Architecture

- **Backend / Real-time**: [Elixir 1.16](https://elixir-lang.org/) and [Phoenix LiveView 1.8](https://phoenixframework.org/) for real-time reactivity without client-side frameworks.
- **Client-Server Interop**: Phoenix LiveView Colocated Hook (`RotateOnHover`) listening to mouse entries and pushing rotation events back to the server.
- **Styling**: Tailwind CSS combined with custom CSS rules in `assets/css/app.css`.
- **Server**: Powered by Bandit HTTP Server.

---

## Getting Started

### Prerequisites

You will need Elixir, Erlang, and Node.js installed. We recommend using [asdf](https://github.com/asdf-vm/asdf) with the `.tool-versions` file included in the project.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/barindebnath/torch_room.git
   cd torch_room
   ```

2. Setup dependencies and databases:
   ```bash
   mix setup
   ```

3. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

---

## Development & Testing

### Running Tests
To run unit and integration tests:
```bash
mix test
```

### Precommit Checks
We use a custom `mix precommit` alias to run compilation checks, formatting, Credo static analysis, and automated tests. Run it before making any commits:
```bash
mix precommit
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
