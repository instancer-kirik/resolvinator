defmodule MigrationFixer do
  @migrations_path "priv/repo/migrations"

  def run do
    IO.puts("\n=== Migration Fixer ===\n")
    
    migrations = list_migration_files()
    Enum.each(migrations, fn file ->
      content = File.read!(file)
      updated_content = fix_migration_content(content)
      if content != updated_content do
        IO.puts("Fixing #{Path.basename(file)}")
        File.write!(file, updated_content)
      end
    end)

    IO.puts("\nDone! Now run:\n")
    IO.puts("mix ecto.drop")
    IO.puts("mix ecto.create")
    IO.puts("mix ecto.migrate")
  end

  defp list_migration_files do
    Path.wildcard(Path.join(@migrations_path, "*.exs"))
  end

  defp fix_migration_content(content) do
    content
    |> fix_table_definitions()
    |> fix_references()
    |> fix_timestamps()
    |> fix_indexes()
  end

  defp fix_table_definitions(content) do
    content
    |> String.replace(
      ~r/create table\(:([^\s,]+)(?:\s*,[^)]*)?+\)\s*do\s*(?:add :id,[^\n]*\n\s*)*(?=add|timestamps|\s*end)/m,
      "create table(:\\1, primary_key: false) do\n      add :id, :binary_id, primary_key: true\n      "
    )
  end

  defp fix_references(content) do
    content
    |> String.replace(
      ~r/references\(:([^\s,)]+)(?!\s*,\s*type:\s*:binary_id)([^,)]*)\)/,
      "references(:\\1, type: :binary_id\\2)"
    )
  end

  defp fix_timestamps(content) do
    content
    |> String.replace(
      ~r/timestamps\(\)/,
      "timestamps(type: :utc_datetime)"
    )
    |> String.replace(
      ~r/timestamps\(([^)]*)\)/,
      fn full ->
        if String.contains?(full, "type:") do
          full
        else
          String.replace(full, ")", ", type: :utc_datetime)")
        end
      end
    )
  end

  defp fix_indexes(content) do
    content
    |> String.replace(
      ~r/create unique_index\(:([^\s,]+),\s*\[(:[^\]]+)\](?!\s*,\s*name:)/,
      "create unique_index(:\\1, [\\2], name: :\\1_\\2_index"
    )
  end
end

MigrationFixer.run() 