defmodule Resolvinator.Content.ProblemDescription do
  use Resolvinator.Content.ContentDescription,
    table_name: "problem_descriptions",
    content_type: :problem,
    content_module: Resolvinator.Content.Problem,
    foreign_key: :problem_id
end
