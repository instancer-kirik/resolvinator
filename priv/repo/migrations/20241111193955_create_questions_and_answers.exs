defmodule Resolvinator.Repo.Migrations.CreateQuestionsAndAnswers do
  use Ecto.Migration
  use Resolvinator.Schema.ContentFields

  def change do
    # Create Answers table first
    create table(:answers, primary_key: false) do
      add_content_fields()
      
      add :answer_type, :string
      add :is_accepted, :boolean, default: false
      add :references, {:array, :string}, default: []
      add :code_snippets, {:array, :map}, default: []
    end

    # Create Questions table
    create table(:questions, primary_key: false) do
      add_content_fields()
      
      add :question_type, :string
      add :context, :string
      add :expected_answer_format, :string
      add :difficulty_level, :string
      add :is_answered, :boolean, default: false
      add :answer_count, :integer, default: 0
      add :subject_area, :string
      add :theorem_references, {:array, :string}, default: []
      add :difficulty_rating, :integer
      add :requires_proof, :boolean, default: false
      add :proof_technique_hints, {:array, :string}, default: []
      add :math_content, :map
      add :accepted_answer_id, references(:answers, type: :binary_id, on_delete: :nilify_all)
    end

    # Add question_id to answers after questions table exists
    alter table(:answers) do
      add :question_id, references(:questions, type: :binary_id, on_delete: :delete_all)
    end

    # Add common indexes
    add_content_indexes(:questions)
    add_content_indexes(:answers)

    # Add relationship-specific indexes
    create index(:answers, [:question_id])
    create index(:questions, [:accepted_answer_id])

    # Create relationship tables
    create table(:question_topic_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question_id, references(:questions, type: :binary_id, on_delete: :delete_all)
      add :topic_id, references(:topics, type: :binary_id, on_delete: :delete_all)
    end

    create table(:question_prerequisites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question_id, references(:questions, type: :binary_id, on_delete: :delete_all)
      add :prerequisite_id, references(:questions, type: :binary_id, on_delete: :delete_all)
    end

    create table(:question_theorem_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question_id, references(:questions, type: :binary_id, on_delete: :delete_all)
      add :theorem_id, references(:theorems, type: :binary_id, on_delete: :delete_all)
    end

    # Create relationship indexes
    create unique_index(:question_topic_relationships, [:question_id, :topic_id])
    create unique_index(:question_prerequisites, [:question_id, :prerequisite_id])
    create unique_index(:question_theorem_relationships, [:question_id, :theorem_id])
  end

  def down do
    drop_if_exists table(:question_theorem_relationships)
    drop_if_exists table(:question_prerequisites)
    drop_if_exists table(:question_topic_relationships)
    drop_if_exists table(:answers)
    drop_if_exists table(:questions)
  end
end