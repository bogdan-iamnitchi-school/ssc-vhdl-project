import array
import math

def generate_sine_wave(duration, sample_rate, frequency):
    num_samples = int(duration * sample_rate)
    samples = array.array('h', [int(32767.0 * math.sin(2.0 * math.pi * frequency * t / sample_rate)) for t in range(num_samples)])
    return samples

def write_pcm_file(pcm_data, output_file):
    with open(output_file, 'wb') as pcm_file:
        pcm_data.tofile(pcm_file)

# Example usage:
duration = 5  # seconds
sample_rate = 44100  # Hz
frequency = 1000  # Hz

pcm_data = generate_sine_wave(duration, sample_rate, frequency)
write_pcm_file(pcm_data, 'test.pcm')