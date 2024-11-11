defmodule Mix.Tasks.CopyKatexFonts do
  use Mix.Task

  @shortdoc "Copies KaTeX fonts to the static assets directory"
  def run(_) do
    Mix.shell().info("Copying KaTeX fonts...")
    
    File.mkdir_p!("priv/static/assets/fonts")
    
    Path.wildcard("node_modules/katex/dist/fonts/*")
    |> Enum.each(fn font_file ->
      filename = Path.basename(font_file)
      File.cp!(font_file, "priv/static/assets/fonts/#{filename}")
    end)

    Mix.shell().info("KaTeX fonts copied successfully!")
  end
end 