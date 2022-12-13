defmodule Membrane.Audiometer.Peakmeter do
  @moduledoc """
  This element computes peaks in each channel of the given signal at
  regular time intervals, regardless if it receives data or not.

  It uses erlang's `:timer.send_interval/2` which might not provide
  perfect accuracy.

  It accepts audio samples in any format supported by `Membrane.RawAudio`
  module.

  It will periodically emit notifications, of the following format:

  * `{:audiometer, :underrun}` - if there were not enough data to
    compute audio level within given interval,
  * `{:audiometer, {:measurement, measurement}}` - where `measurement`
    is a `Membrane.Audiometer.Peakmeter.Notification.Measurement`
    struct containing computed audio levels. See its documentation for
    more details about the actual value format.

  See `options/0` for available options.
  """
  use Membrane.Filter
  alias __MODULE__.Amplitude
  alias Membrane.Element.PadData
  alias Membrane.RawAudio

  @type amplitude_t :: [number | :infinity | :clip]

  def_input_pad :input,
    availability: :always,
    mode: :pull,
    accepted_format: RawAudio,
    demand_unit: :buffers,
    demand_mode: :auto

  def_output_pad :output,
    availability: :always,
    mode: :pull,
    demand_mode: :auto,
    accepted_format: RawAudio

  def_options interval: [
                spec: Membrane.Time.t(),
                description: """
                How often peakmeter should emit messages containing sound level (in Membrane.Time units).
                """,
                default: Membrane.Time.milliseconds(50),
                inspector: &Membrane.Time.inspect/1
              ]

  # Private API

  @impl true
  def handle_init(_ctx, %__MODULE__{interval: interval}) do
    state = %{
      interval: interval,
      queue: <<>>
    }

    {[], state}
  end

  @impl true
  def handle_playing(_ctx, state) do
    {[start_timer: {:timer, state.interval}], state}
  end

  @impl true
  def handle_process(
        :input,
        %Membrane.Buffer{payload: payload} = buffer,
        _ctx,
        state
      ) do
    new_state = %{state | queue: state.queue <> payload}
    {[buffer: {:output, buffer}], new_state}
  end

  @impl true
  def handle_tick(:timer, %{pads: %{input: %PadData{stream_format: nil}}}, state) do
    {[notify_parent: :underrun], state}
  end

  def handle_tick(:timer, %{pads: %{input: %PadData{stream_format: stream_format}}}, state) do
    frame_size = RawAudio.frame_size(stream_format)

    if byte_size(state.queue) < frame_size do
      {[notify_parent: {:audiometer, :underrun}], state}
    else
      {:ok, {amplitudes, rest}} = Amplitude.find_amplitudes(state.queue, stream_format)
      {[notify_parent: {:amplitudes, amplitudes}], %{state | queue: rest}}
    end
  end
end
