defmodule Membrane.Audiometer.PeakmeterTest do
  use ExUnit.Case, async: true
  import Membrane.Testing.Assertions
  alias Membrane.Testing

  @module Membrane.Audiometer.Peakmeter

  test "integration" do
    data = [1, 2, 3, 2, 1] |> Enum.map(&<<&1>>)

    {:ok, pipeline} =
      %Testing.Pipeline.Options{
        elements: [source: %Testing.Source{output: data}, peakmeter: @module, sink: Testing.Sink]
      }
      |> Testing.Pipeline.start_link()

    Testing.Pipeline.play(pipeline)
    assert_pipeline_playback_changed(pipeline, _prev_state, :playing)

    assert_pipeline_notified(pipeline, :peakmeter, :underrun)

    Enum.each(data, fn payload ->
      assert_sink_buffer(pipeline, :sink, %Membrane.Buffer{payload: received_payload})
      assert payload == received_payload
    end)

    Testing.Pipeline.stop(pipeline)
    assert_pipeline_playback_changed(pipeline, _prev_state, :stopped)
  end
end
