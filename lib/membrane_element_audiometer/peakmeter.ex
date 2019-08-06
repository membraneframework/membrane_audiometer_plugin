defmodule Membrane.Element.Audiometer.Peakmeter do
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
    is a `Membrane.Element.Audiometer.Peakmeter.Notification.Measurement`
    struct containing computed audio levels. See its documentation for
    more details about the actual value format.
   
  See `options/0` for available options.
  """
  use Membrane.Element.Base.Filter
  use Membrane.Log, tags: :membrane_element_audiometer
  alias Membrane.Caps.Audio.Raw
  alias Membrane.Element.Audiometer.Peakmeter.Helper.Amplitude
  alias Membrane.Element.Audiometer.Peakmeter.Notification.Measurement

  def_input_pad :input, 
    availability: :always, 
    mode: :pull, 
    caps: Raw, 
    demand_unit: :buffers

  def_output_pad :output, 
    availability: :always, 
    mode: :pull, 
    caps: Raw

  def_options interval: [
                type: :integer,
                description: """
                How often peakmeter should emit messages containing sound level (in Membrane.Time units).
                """,
                default: 50 |> Membrane.Time.millisecond()
              ]

  # Private API

  @impl true
  def handle_init(%__MODULE__{interval: interval}) do
    state = %{
      interval: interval,
      queue: <<>>,
      timer: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {:ok, timer} = :timer.send_interval(state.interval |> Membrane.Time.to_milliseconds(), :tick)
    {:ok, %{state | timer: timer}}
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    {:ok, :cancel} = :timer.cancel(state.timer)
    {:ok, %{state | timer: nil}}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _context, state) do
    {{:ok, [demand: {:input, size}]}, state}
  end

  def handle_demand(:output, _size, :bytes, _ctx, state) do
    {{:ok, demand: :input}, state}
  end

  @impl true
  def handle_process(
        :input,
        %Membrane.Buffer{payload: payload} = buffer,
        _context,
        state
      ) do
    new_state = %{state | queue: state.queue <> payload}
    {{:ok, [buffer: {:output, buffer}]}, new_state}
  end

  @impl true
  def handle_other(
        :tick,
        %Membrane.Element.CallbackContext.Other{
          pads: %{input: %Membrane.Element.Pad.Data{caps: nil}}
        },
        state
      ) do
    {{:ok, notify: {:audiometer, :underrun}}, state}
  end

  def handle_other(
        :tick,
        %Membrane.Element.CallbackContext.Other{
          pads: %{input: %Membrane.Element.Pad.Data{caps: caps}}
        },
        state
      ) do
    frame_size = Raw.frame_size(caps)

    if byte_size(state.queue) < frame_size do
      {{:ok, notify: {:audiometer, :underrun}}, state}
    else
      {:ok, {amplitudes, rest}} = Amplitude.find_amplitudes(state.queue, caps)
      notification = {:audiometer, {:measurement, %Measurement{amplitudes: amplitudes}}}
      {{:ok, notify: notification}, %{state | queue: rest}}
    end
  end
end
