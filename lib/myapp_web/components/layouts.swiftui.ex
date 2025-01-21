defmodule MyappWeb.Layouts.SwiftUI do
  use MyappNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
