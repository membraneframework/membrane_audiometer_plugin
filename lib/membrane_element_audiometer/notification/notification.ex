defmodule Membrane.Element.Audiometer.Peakmeter.Notification.Measurement do
  @moduledoc """
  Struct containing a single measurement.

  Currently it can hold maximum aplitudes for given measurement interval.
  """

  @type t :: %__MODULE__{
          amplitudes: [number | :infinity | :clip]
        }

  defstruct amplitudes: nil
end
