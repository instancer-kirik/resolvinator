defmodule Resolvinator.Projects.Types.Music do
	@behaviour Resolvinator.Projects.ProjectType

	@impl true
	def validate_settings(settings) do
		with {:ok, _} <- validate_bpm(get_in(settings, ["metadata", "bpm"])),
				 {:ok, _} <- validate_key(get_in(settings, ["metadata", "key"])) do
			:ok
		else
			{:error, msg} -> {:error, msg}
		end
	end

	@impl true
	def required_fields, do: [:bpm, :key]

	@impl true
	def default_settings do
		%{
			"metadata" => %{
				"bpm" => nil,
				"key" => nil,
				"time_signature" => "4/4",
				"genre" => nil
			},
			"audio_settings" => %{
				"sample_rate" => 44100,
				"bit_depth" => 24,
				"master_output_level" => 0
			}
		}
	end

	defp validate_bpm(nil), do: {:error, "BPM is required"}
	defp validate_bpm(bpm) when is_number(bpm) and bpm > 0, do: {:ok, bpm}
	defp validate_bpm(_), do: {:error, "Invalid BPM value"}

	defp validate_key(nil), do: {:error, "Key is required"}
	defp validate_key(key) when is_binary(key), do: {:ok, key}
	defp validate_key(_), do: {:error, "Invalid key value"}
end