defmodule Membrane.Audiometer.PeakmeterTest do
  use ExUnit.Case, async: true
  import Membrane.ChildrenSpec
  import Membrane.Testing.Assertions
  alias Membrane.RawAudio
  alias Membrane.Testing

  @module Membrane.Audiometer.Peakmeter

  test "integration" do
    data = [1, 2, 3, 2, 1] |> Enum.map(&<<&1>>)

    structure = [
      child(:source, %Testing.Source{
        output: data,
        stream_format: %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :s16le}
      })
      |> child(:peakmeter, @module)
      |> child(:sink, Testing.Sink)
    ]

    pipeline = Membrane.Testing.Pipeline.start_link_supervised!(structure: structure)

    assert_pipeline_play(pipeline)

    assert_pipeline_notified(pipeline, :peakmeter, {:audiometer, :underrun})

    Enum.each(data, fn payload ->
      assert_sink_buffer(pipeline, :sink, %Membrane.Buffer{payload: received_payload})
      assert payload == received_payload
    end)
  end
end
