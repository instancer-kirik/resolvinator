defmodule Resolvinator.NLP do
  @moduledoc """
  Natural Language Processing module for Resolvinator.
  Provides text analysis, embedding generation, and similarity computation
  capabilities for project descriptions and requirements.

  Uses Bumblebee for ML-based text processing and analysis.
  """

  require Logger
  alias Nx.Tensor

  @doc """
  Generates embeddings for the given text using a pre-trained transformer model.
  Returns {:ok, embeddings} on success, {:error, reason} on failure.
  """
  @spec get_embeddings(String.t()) :: {:ok, Nx.Tensor.t()} | {:error, String.t()}
  def get_embeddings(text) when is_binary(text) do
    try do
      {:ok, model} = Bumblebee.load_model({:hf, "sentence-transformers/all-mpnet-base-v2"})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "sentence-transformers/all-mpnet-base-v2"})

      inputs = Bumblebee.apply_tokenizer(tokenizer, text)
      embeddings = Bumblebee.generate(model, inputs)

      {:ok, embeddings}
    rescue
      e ->
        Logger.error("Failed to generate embeddings: #{inspect(e)}")
        {:error, "Failed to generate embeddings"}
    end
  end
  def get_embeddings(_), do: {:error, "Invalid input text"}

  @doc """
  Extracts key phrases from text using NLP techniques.
  Returns a list of important phrases and their relevance scores.
  """
  @spec extract_key_phrases(String.t()) :: {:ok, list(%{phrase: String.t(), score: float()})} | {:error, String.t()}
  def extract_key_phrases(text) when is_binary(text) do
    try do
      {:ok, model} = Bumblebee.load_model({:hf, "microsoft/keyword-extractor"})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "microsoft/keyword-extractor"})

      inputs = Bumblebee.apply_tokenizer(tokenizer, text)
      outputs = Bumblebee.generate(model, inputs)

      phrases = process_key_phrases(outputs)
      {:ok, phrases}
    rescue
      e ->
        Logger.error("Failed to extract key phrases: #{inspect(e)}")
        {:error, "Failed to extract key phrases"}
    end
  end
  def extract_key_phrases(_), do: {:error, "Invalid input text"}

  @doc """
  Computes semantic similarity between two embedding tensors.
  Returns a float between 0 and 1, where 1 indicates perfect similarity.
  """
  @spec compute_similarity(Nx.Tensor.t(), Nx.Tensor.t()) :: float()
  def compute_similarity(%Tensor{} = emb1, %Tensor{} = emb2) do
    # Compute cosine similarity between embeddings
    dot_product = Nx.dot(emb1, Nx.transpose(emb2))
    norm1 = Nx.sqrt(Nx.sum(Nx.multiply(emb1, emb1)))
    norm2 = Nx.sqrt(Nx.sum(Nx.multiply(emb2, emb2)))

    Nx.divide(dot_product, Nx.multiply(norm1, norm2))
    |> Nx.to_number()
  end

  @doc """
  Classifies text into predefined categories using a fine-tuned model.
  Returns the most likely category and confidence score.
  """
  @spec classify_text(String.t()) :: {:ok, %{category: String.t(), confidence: float()}} | {:error, String.t()}
  def classify_text(text) when is_binary(text) do
    try do
      {:ok, model} = Bumblebee.load_model({:hf, "resolvinator/project-classifier"})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "resolvinator/project-classifier"})

      inputs = Bumblebee.apply_tokenizer(tokenizer, text)
      %{predictions: predictions} = Bumblebee.generate(model, inputs)

      {category, confidence} = get_top_prediction(predictions)
      {:ok, %{category: category, confidence: confidence}}
    rescue
      e ->
        Logger.error("Failed to classify text: #{inspect(e)}")
        {:error, "Failed to classify text"}
    end
  end
  def classify_text(_), do: {:error, "Invalid input text"}

  @doc """
  Analyzes sentiment and key aspects of project descriptions.
  Returns sentiment scores and identified aspects.
  """
  @spec analyze_sentiment(String.t()) :: {:ok, map()} | {:error, String.t()}
  def analyze_sentiment(text) when is_binary(text) do
    try do
      {:ok, model} = Bumblebee.load_model({:hf, "nlptown/bert-base-multilingual-uncased-sentiment"})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "nlptown/bert-base-multilingual-uncased-sentiment"})

      inputs = Bumblebee.apply_tokenizer(tokenizer, text)
      outputs = Bumblebee.generate(model, inputs)

      {:ok, process_sentiment_output(outputs)}
    rescue
      e ->
        Logger.error("Failed to analyze sentiment: #{inspect(e)}")
        {:error, "Failed to analyze sentiment"}
    end
  end
  def analyze_sentiment(_), do: {:error, "Invalid input text"}

  # Private functions

  defp process_key_phrases(outputs) do
    outputs.predictions
    |> Enum.map(fn pred ->
      %{
        phrase: pred.text,
        score: pred.score
      }
    end)
    |> Enum.sort_by(& &1.score, :desc)
  end

  defp get_top_prediction(predictions) do
    predictions
    |> Enum.max_by(& &1.score)
    |> then(& {&1.label, &1.score})
  end

  defp process_sentiment_output(outputs) do
    %{
      sentiment: outputs.label,
      confidence: outputs.score,
      aspects: extract_aspects(outputs)
    }
  end

  defp extract_aspects(outputs) do
    outputs.aspects
    |> Enum.map(fn aspect ->
      %{
        aspect: aspect.text,
        sentiment: aspect.sentiment,
        confidence: aspect.confidence
      }
    end)
  end
end
