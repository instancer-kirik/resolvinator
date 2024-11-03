defmodule Resolvinator.Content.SolutionDescription do
  use Resolvinator.Content.ContentDescription,
    table_name: "solution_descriptions",
    content_type: :solution,
    content_module: Resolvinator.Content.Solution,
    foreign_key: :solution_id
end
