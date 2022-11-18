defmodule Membrane.Audiometer.Peakmeter.AmplitudeTest do
  use ExUnit.Case, async: true

  alias Membrane.Audiometer.Peakmeter.Amplitude
  alias Membrane.RawAudio

  @stream_format_mono_u8 %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u8}
  @stream_format_mono_u16le %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u16le}
  @stream_format_mono_u24le %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u24le}
  @stream_format_mono_u32le %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u32le}
  @stream_format_mono_f32le %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :f32le}
  @stream_format_mono_f64le %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :f64le}
  @stream_format_mono_u16be %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u16be}
  @stream_format_mono_u24be %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u24be}
  @stream_format_mono_u32be %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :u32be}
  @stream_format_mono_f32be %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :f32be}
  @stream_format_mono_f64be %RawAudio{channels: 1, sample_rate: 44_100, sample_format: :f64be}
  @stream_format_stereo_u8 %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u8}
  @stream_format_stereo_u16le %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u16le}
  @stream_format_stereo_u24le %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u24le}
  @stream_format_stereo_u32le %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u32le}
  @stream_format_stereo_u16be %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u16be}
  @stream_format_stereo_u24be %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u24be}
  @stream_format_stereo_u32be %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :u32be}
  @stream_format_stereo_f32le %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :f32le}
  @stream_format_stereo_f32be %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :f32be}
  @stream_format_stereo_f64le %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :f64le}
  @stream_format_stereo_f64be %RawAudio{channels: 2, sample_rate: 44_100, sample_format: :f64be}

  describe "find_amplitudes/2" do
    # errors
    test "if given empty payload it returns an error with :empty as a reason" do
      payload = <<>>

      assert {:error, :empty} = Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)
    end

    # single mono u8
    test "if given payload contains exactly one u8 mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<255::integer-size(8)-unsigned-little>>

      assert {:ok, {[value], _rest}} = Amplitude.find_amplitudes(payload, @stream_format_mono_u8)
      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u8 mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<192::integer-size(8)-unsigned-little>>

      assert {:ok, {[value], _rest}} = Amplitude.find_amplitudes(payload, @stream_format_mono_u8)
      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u8 mono frame that is in the middle of scale it returns :infinity" do
      payload = <<128::integer-size(8)-unsigned-little>>

      assert {:ok, {[value], _rest}} = Amplitude.find_amplitudes(payload, @stream_format_mono_u8)
      assert value == :infinity
    end

    test "if given payload contains exactly one u8 mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(8)-unsigned-little>>

      assert {:ok, {[value], _rest}} = Amplitude.find_amplitudes(payload, @stream_format_mono_u8)
      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u8 mono frame it returns empty rest" do
      payload = <<100::integer-size(8)-unsigned-little>>

      assert {:ok, {_values, <<>>}} = Amplitude.find_amplitudes(payload, @stream_format_mono_u8)
    end

    # single mono u16le
    test "if given payload contains exactly one u16le mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<65_535::integer-size(16)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u16le mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<49_151::integer-size(16)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u16le mono frame that is in the middle of scale it returns :infinity" do
      payload = <<32_768::integer-size(16)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)

      assert value == :infinity
    end

    test "if given payload contains exactly one u16le mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(16)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u16le mono frame it returns empty rest" do
      payload = <<1234::integer-size(16)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16le)
    end

    # single mono u24le
    test "if given payload contains exactly one u24le mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<16_777_215::integer-size(24)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u24le mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<12_582_912::integer-size(24)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24le)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u24le mono frame that is in the middle of scale it returns :infinity" do
      payload = <<8_388_608::integer-size(24)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24le)

      assert value == :infinity
    end

    test "if given payload contains exactly one u24le mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(24)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u24le mono frame it returns empty rest" do
      payload = <<1234::integer-size(24)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24le)
    end

    # single mono u32le
    test "if given payload contains exactly one u32le mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<4_294_967_295::integer-size(32)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u32le mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<3_221_225_472::integer-size(32)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32le)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u32le mono frame that is in the middle of scale it returns :infinity" do
      payload = <<2_147_483_648::integer-size(32)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32le)

      assert value == :infinity
    end

    test "if given payload contains exactly one u32le mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(32)-unsigned-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u32le mono frame it returns empty rest" do
      payload = <<1234::integer-size(32)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32le)
    end

    # single mono u16be
    test "if given payload contains exactly one u16be mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<65_535::integer-size(16)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u16be mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<49_151::integer-size(16)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16be)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u16be mono frame that is in the middle of scale it returns :infinity" do
      payload = <<32_768::integer-size(16)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16be)

      assert value == :infinity
    end

    test "if given payload contains exactly one u16be mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(16)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u16be mono frame it returns empty rest" do
      payload = <<1234::integer-size(16)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u16be)
    end

    # single mono u24be
    test "if given payload contains exactly one u24be mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<16_777_215::integer-size(24)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u24be mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<12_582_912::integer-size(24)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24be)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u24be mono frame that is in the middle of scale it returns :infinity" do
      payload = <<8_388_608::integer-size(24)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24be)

      assert value == :infinity
    end

    test "if given payload contains exactly one u24be mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(24)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u24be mono frame it returns empty rest" do
      payload = <<1234::integer-size(24)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u24be)
    end

    # single mono u32be
    test "if given payload contains exactly one u32be mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<4_294_967_295::integer-size(32)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u32be mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<3_221_225_472::integer-size(32)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32be)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one u32be mono frame that is in the middle of scale it returns :infinity" do
      payload = <<2_147_483_648::integer-size(32)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32be)

      assert value == :infinity
    end

    test "if given payload contains exactly one u32be mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(32)-unsigned-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one u32be mono frame it returns empty rest" do
      payload = <<1234::integer-size(32)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_u32be)
    end

    # single stereo u8 equal
    test "if given payload contains exactly one u8 stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<255::integer-size(8)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u8)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u8 stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<192::integer-size(8)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u8)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u8 stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<128::integer-size(8)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u8)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u8 stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(8)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u8)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u8 stereo frame it returns an empty rest" do
      payload = <<100::integer-size(8)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u8)
    end

    # single stereo u16le equal
    test "if given payload contains exactly one u16le stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<65_535::integer-size(16)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u16le stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<49_151::integer-size(16)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16le)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u16le stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<32_768::integer-size(16)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16le)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u16le stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(16)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u16le stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(16)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16le)
    end

    # single stereo u24le equal
    test "if given payload contains exactly one u24le stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<16_777_215::integer-size(24)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u24le stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<12_582_912::integer-size(24)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24le)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u24le stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<8_388_608::integer-size(24)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24le)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u24le stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(24)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u24le stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(24)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24le)
    end

    # single stereo u32le equal
    test "if given payload contains exactly one u32le stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<4_294_967_295::integer-size(32)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u32le stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<3_221_225_472::integer-size(32)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32le)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u32le stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<2_147_483_648::integer-size(32)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32le)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u32le stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(32)-unsigned-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u32le stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(32)-unsigned-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32le)
    end

    # single stereo u16be equal
    test "if given payload contains exactly one u16be stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<65_535::integer-size(16)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u16be stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<49_151::integer-size(16)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16be)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u16be stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<32_768::integer-size(16)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16be)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u16be stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(16)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u16be stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(16)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u16be)
    end

    # single stereo u24be equal
    test "if given payload contains exactly one u24be stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<16_777_215::integer-size(24)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u24be stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<12_582_912::integer-size(24)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24be)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u24be stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<8_388_608::integer-size(24)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24be)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u24be stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(24)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u24be stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(24)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u24be)
    end

    # single stereo u32be equal
    test "if given payload contains exactly one u32be stereo frame which values are equal and a max value for this format it returns 0 dB" do
      payload = <<4_294_967_295::integer-size(32)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u32be stereo frame which values are equal and neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<3_221_225_472::integer-size(32)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32be)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one u32be stereo frame that is are the middle of the scale it returns :infinity" do
      payload = <<2_147_483_648::integer-size(32)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32be)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one u32be stereo frame which values are equal and a min value for this format it returns 0 dB" do
      payload = <<0::integer-size(32)-unsigned-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one u32be stereo frame it returns an empty rest" do
      payload = <<1234::integer-size(32)-unsigned-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_u32be)
    end

    # single mono f32le
    test "if given payload contains exactly one f32le mono frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert value == :clip
    end

    test "if given payload contains exactly one f32le mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f32le mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one f32le mono frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert value == :infinity
    end

    test "if given payload contains exactly one f32le mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f32le mono frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(32)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)

      assert value == :clip
    end

    test "if given payload contains exactly one f32le mono frame it returns empty rest" do
      payload = <<0.5::float-size(32)-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32le)
    end

    # single mono f32be
    test "if given payload contains exactly one f32be mono frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert value == :clip
    end

    test "if given payload contains exactly one f32be mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f32be mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one f32be mono frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert value == :infinity
    end

    test "if given payload contains exactly one f32be mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f32be mono frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(32)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)

      assert value == :clip
    end

    test "if given payload contains exactly one f32be mono frame it returns empty rest" do
      payload = <<0.5::float-size(32)-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f32be)
    end

    # single stereo f32le
    test "if given payload contains exactly one f32le stereo frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f32le stereo frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f32le stereo frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one f32le stereo frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one f32le stereo frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f32le stereo frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(32)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f32le stereo frame it returns empty rest" do
      payload = <<0.5::float-size(32)-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32le)
    end

    # single stereo f32be
    test "if given payload contains exactly one f32be stereo frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f32be stereo frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f32be stereo frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one f32be stereo frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one f32be stereo frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f32be stereo frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(32)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f32be stereo frame it returns empty rest" do
      payload = <<0.5::float-size(32)-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f32be)
    end

    # single mono f64le
    test "if given payload contains exactly one f64le mono frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert value == :clip
    end

    test "if given payload contains exactly one f64le mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f64le mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one f64le mono frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert value == :infinity
    end

    test "if given payload contains exactly one f64le mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f64le mono frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(64)-little>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)

      assert value == :clip
    end

    test "if given payload contains exactly one f64le mono frame it returns empty rest" do
      payload = <<0.5::float-size(64)-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64le)
    end

    # single mono f64be
    test "if given payload contains exactly one f64be mono frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert value == :clip
    end

    test "if given payload contains exactly one f64be mono frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f64be mono frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert_in_delta value, -6.02, 0.1
    end

    test "if given payload contains exactly one f64be mono frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert value == :infinity
    end

    test "if given payload contains exactly one f64be mono frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert_in_delta value, 0, 0.1
    end

    test "if given payload contains exactly one f64be mono frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(64)-big>>

      assert {:ok, {[value], _rest}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)

      assert value == :clip
    end

    test "if given payload contains exactly one f64be mono frame it returns empty rest" do
      payload = <<0.5::float-size(64)-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload, @stream_format_mono_f64be)
    end

    # single stereo f64le
    test "if given payload contains exactly one f64le stereo frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f64le stereo frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f64le stereo frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one f64le stereo frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one f64le stereo frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f64le stereo frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(64)-little>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f64le stereo frame it returns empty rest" do
      payload = <<0.5::float-size(64)-little>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64le)
    end

    # single stereo f64be
    test "if given payload contains exactly one f64be stereo frame which value is above a max value for this format it returns :clip" do
      payload = <<1.5::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f64be stereo frame which value is a max value for this format it returns 0 dB" do
      payload = <<1::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f64be stereo frame which value is neither a min nor max value for this format it returns amplitude in dB" do
      payload = <<0.5::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert_in_delta value1, -6.02, 0.1
      assert_in_delta value2, -6.02, 0.1
    end

    test "if given payload contains exactly one f64be stereo frame that is in the middle of scale it returns :infinity" do
      payload = <<0::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert value1 == :infinity
      assert value2 == :infinity
    end

    test "if given payload contains exactly one f64be stereo frame which value is a min value for this format it returns 0 dB" do
      payload = <<-1::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert_in_delta value1, 0, 0.1
      assert_in_delta value2, 0, 0.1
    end

    test "if given payload contains exactly one f64be stereo frame which value is over a min value for this format it returns :clip" do
      payload = <<-1.5::float-size(64)-big>>

      assert {:ok, {[value1, value2], _rest}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)

      assert value1 == :clip
      assert value2 == :clip
    end

    test "if given payload contains exactly one f64be stereo frame it returns empty rest" do
      payload = <<0.5::float-size(64)-big>>

      assert {:ok, {_values, <<>>}} =
               Amplitude.find_amplitudes(payload <> payload, @stream_format_stereo_f64be)
    end
  end
end
