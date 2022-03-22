defmodule Membrane.Audiometer.Peakmeter do
  @moduledoc """
  This element computes peaks in each channel of the given signal at
  regular time intervals, regardless if it receives data or not.

  It uses erlang's `:timer.send_interval/2` which might not provide
  perfect accuracy.

  It accepts data of any format specified in Membrane.Caps.Audio.Raw
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
    caps: RawAudio,
    demand_unit: :buffers,
    demand_mode: :auto

  def_output_pad :output,
    availability: :always,
    mode: :pull,
    demand_mode: :auto,
    caps: RawAudio

  def_options interval: [
                type: :integer,
                description: """
                How often peakmeter should emit messages containing sound level (in Membrane.Time units).
                """,
                default: 50 |> Membrane.Time.milliseconds()
              ]

  # Private API

  @impl true
  def handle_init(%__MODULE__{interval: interval}) do
    state = %{
      interval: interval,
      queue: <<>>
    }

    {:ok, state}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {{:ok, start_timer: {:timer, state.interval}}, state}
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    {{:ok, stop_timer: :timer}, state}
  end

  @impl true
  def handle_process(
        :input,
        %Membrane.Buffer{payload: payload} = buffer,
        _context,
        state
      ) do
    new_state = %{state | queue: state.queue <> payload}
    {{:ok, buffer: {:output, buffer}}, new_state}
  end

  @impl true
  def handle_tick(:timer, %{pads: %{input: %PadData{caps: nil}}}, state) do
    {{:ok, notify: :underrun}, state}
  end

  def handle_tick(:timer, %{pads: %{input: %PadData{caps: caps}}}, state) do
    frame_size = RawAudio.frame_size(caps)

    if byte_size(state.queue) < frame_size do
      {{:ok, notify: {:audiometer, :underrun}}, state}
    else
      {:ok, {amplitudes, rest}} = Amplitude.find_amplitudes(state.queue, caps)
      {{:ok, notify: {:amplitudes, amplitudes}}, %{state | queue: rest}}
    end
  end
end
