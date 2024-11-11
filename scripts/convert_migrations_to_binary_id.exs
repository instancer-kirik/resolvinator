defmodule MigrationConverter do
  @migrations_path "priv/repo/migrations"

  def run do
    IO.puts("\n=== Migration Binary ID Converter ===\n")
    
    # First analyze and show what will be changed
    analyze_and_report()
    
    # Ask for confirmation before making changes
    if confirm_changes?() do
      update_migrations()
      print_next_steps()
    else
      IO.puts("\nOperation cancelled. No changes were made.")
    end
  end

  defp analyze_and_report do
    migrations = analyze_migrations()
    needs_update = Enum.filter(migrations, & &1.needs_update)
    
    IO.puts("Found #{length(needs_update)} migrations that need updates:\n")
    
    Enum.each(needs_update, fn migration ->
      IO.puts("• #{migration.file}")
      IO.puts("  Tables: #{Enum.join(migration.table_names, ", ")}")
      IO.puts("")
    end)
  end

  defp analyze_migrations do
    @migrations_path
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(fn file ->
      content = File.read!(file)
      %{
        file: Path.basename(file),
        needs_update: needs_binary_id_update?(content),
        table_names: extract_table_names(content),
        has_references: has_references?(content),
        has_binary_id: has_binary_id?(content)
      }
    end)
  end

  defp update_migrations do
    IO.puts("\nUpdating migrations...")
    
    results = @migrations_path
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(fn file ->
      content = File.read!(file)
      updated_content = convert_to_binary_id(content)
      
      if content != updated_content do
        File.write!(file, updated_content)
        {:updated, Path.basename(file)}
      else
        {:unchanged, Path.basename(file)}
      end
    end)

    # Report results
    {updated, unchanged} = Enum.split_with(results, fn {status, _} -> status == :updated end)
    
    IO.puts("\nResults:")
    IO.puts("• Updated #{length(updated)} files")
    IO.puts("• Unchanged #{length(unchanged)} files")
    
    Enum.each(updated, fn {:updated, file} ->
      IO.puts("  ✓ #{file}")
    end)
  end

  defp needs_binary_id_update?(content) do
    !has_binary_id?(content) && (creates_table?(content) || has_references?(content))
  end

  defp creates_table?(content) do
    String.contains?(content, "create table")
  end

  defp has_references?(content) do
    String.contains?(content, "references(")
  end

  defp has_binary_id?(content) do
    String.contains?(content, ":binary_id")
  end

  defp extract_table_names(content) do
    ~r/create table\(:(\w+)/
    |> Regex.scan(content)
    |> Enum.map(fn [_, table] -> table end)
  end

  defp convert_to_binary_id(content) do
    content
    |> add_primary_key_binary_id()
    |> add_references_binary_id()
  end

  defp add_primary_key_binary_id(content) do
    content
    |> String.replace(
      ~r/create table\(:(\w+)\b(?!\s*,\s*primary_key:)([^d]|$)/,
      "create table(:\\1, primary_key: false) do\n      add :id, :binary_id, primary_key: true\\2"
    )
  end

  defp add_references_binary_id(content) do
    content
    |> String.replace(
      ~r/references\(:(\w+)(?!\s*,\s*type:)([^,\)]*)\)/,
      "references(:\\1, type: :binary_id\\2)"
    )
  end

  defp confirm_changes? do
    IO.puts("\nThis will modify your migration files. Make sure you have committed any changes to version control.")
    IO.puts("Do you want to proceed? [y/N]")
    
    IO.gets("")
    |> String.trim()
    |> String.downcase()
    |> String.starts_with?("y")
  end

  defp print_next_steps do
    IO.puts("""
    
    === Next Steps ===
    
    1. Make sure this is in your config/config.exs:
    
       config :resolvinator, Resolvinator.Repo,
         migration_primary_key: [type: :binary_id],
         migration_foreign_key: [type: :binary_id]
    
    2. Reset your database with these commands:
    
       mix ecto.drop
       mix ecto.create
       mix ecto.migrate
    
    3. If you have seed data:
       mix run priv/repo/seeds.exs
    """)
  end
end

# Run the converter
MigrationConverter.run() 